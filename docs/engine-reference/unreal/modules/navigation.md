# Unreal Engine 5.8 — 导航模块参考

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Knowledge Gap:** UE 5.7-5.8 导航改进

> **UE 5.8 变更：** 静态网格可以在导航网格（navmesh）生成期间定义
> 自己的可行走区域（按网格设置区域代价，例如让 AI 绕着沙发走
> 而不是从上面走过），通过网格上的标记与 NavCollision 上的区域类
> 设置按网格启用。Mover 获得了对 Detour Crowd 的 NavWalking 支持。
> 来源：UE 5.8 发布说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

UE 5.8 导航系统：
- **Nav Mesh**：面向 AI 的自动寻路网格
- **AI Controller**：控制 AI 移动与行为
- **Behavior Trees**：AI 决策（在 AI 模块中介绍）

---

## Nav Mesh 设置

### 添加 Nav Mesh Bounds Volume

1. Place Actors > Volumes > Nav Mesh Bounds Volume
2. 缩放以覆盖可行走区域
3. 按 `P` 切换 Nav Mesh 可视化（绿色覆盖层）

### Nav Mesh 设置

```cpp
// Project Settings > Engine > Navigation System
// - Generate Navigation Only Around Navigation Invokers: Performance optimization
// - Auto Update Enabled: Rebuild NavMesh when geometry changes
```

---

## AI Controller 与移动

### 创建 AI Controller

```cpp
UCLASS()
class AEnemyAIController : public AAIController {
    GENERATED_BODY()

public:
    void BeginPlay() override {
        Super::BeginPlay();

        // Move to location
        FVector TargetLocation = FVector(1000, 0, 0);
        MoveToLocation(TargetLocation);
    }
};
```

### 为 Pawn 指定 AI Controller

```cpp
UCLASS()
class AEnemyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AEnemyCharacter() {
        // ✅ Assign AI Controller class
        AIControllerClass = AEnemyAIController::StaticClass();
        AutoPossessAI = EAutoPossessAI::PlacedInWorldOrSpawned;
    }
};
```

---

## 基础 AI 移动

### 移动到位置

```cpp
AAIController* AIController = Cast<AAIController>(GetController());
if (AIController) {
    FVector TargetLocation = FVector(1000, 0, 0);
    EPathFollowingRequestResult::Type Result = AIController->MoveToLocation(TargetLocation);

    if (Result == EPathFollowingRequestResult::RequestSuccessful) {
        UE_LOG(LogTemp, Warning, TEXT("Moving to location"));
    }
}
```

### 移动到 Actor

```cpp
AActor* Target = /* Get target actor */;
AIController->MoveToActor(Target, 100.0f); // Stop 100 units away
```

### 停止移动

```cpp
AIController->StopMovement();
```

---

## 寻路事件

### 移动完成时

```cpp
UCLASS()
class AEnemyAIController : public AAIController {
    GENERATED_BODY()

public:
    void BeginPlay() override {
        Super::BeginPlay();

        // Bind to move completed event
        ReceiveMoveCompleted.AddDynamic(this, &AEnemyAIController::OnMoveCompleted);
    }

    UFUNCTION()
    void OnMoveCompleted(FAIRequestID RequestID, EPathFollowingResult::Type Result) {
        if (Result == EPathFollowingResult::Success) {
            UE_LOG(LogTemp, Warning, TEXT("Reached destination"));
        } else {
            UE_LOG(LogTemp, Warning, TEXT("Failed to reach destination"));
        }
    }
};
```

---

## 寻路查询

### 查找通往某位置的路径

```cpp
#include "NavigationSystem.h"
#include "NavigationPath.h"

UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
if (NavSys) {
    FVector Start = GetActorLocation();
    FVector End = TargetLocation;

    FPathFindingQuery Query;
    Query.StartLocation = Start;
    Query.EndLocation = End;
    Query.NavData = NavSys->GetDefaultNavDataInstance();

    FPathFindingResult Result = NavSys->FindPathSync(Query);

    if (Result.IsSuccessful()) {
        UNavigationPath* NavPath = Result.Path.Get();
        // Use path points: NavPath->GetPathPoints()
    }
}
```

### 检查位置是否可达

```cpp
UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
FNavLocation OutLocation;
bool bReachable = NavSys->ProjectPointToNavigation(TargetLocation, OutLocation);

if (bReachable) {
    UE_LOG(LogTemp, Warning, TEXT("Location is reachable"));
}
```

---

## Nav Mesh 修改器

### Nav Modifier Volume（阻挡/允许区域）

1. Place Actors > Volumes > Nav Modifier Volume
2. 配置 Area Class（例如用 NavArea_Null 阻挡，用 NavArea_LowHeight 表示蹲行）

---

## 自定义导航区域

### 创建自定义 Nav Area

```cpp
UCLASS()
class UNavArea_Jump : public UNavArea {
    GENERATED_BODY()

public:
    UNavArea_Jump() {
        DefaultCost = 10.0f; // Higher cost = AI avoids unless necessary
        FixedAreaEnteringCost = 100.0f; // One-time cost to enter
    }
};
```

### 使用自定义 Nav Area

```cpp
// Assign to Nav Modifier Volume or geometry
```

---

## Nav Mesh 生成

### 运行时重建 Nav Mesh

```cpp
UNavigationSystemV1* NavSys = UNavigationSystemV1::GetCurrent(GetWorld());
NavSys->Build(); // Rebuild entire NavMesh
```

### 动态 Nav Mesh（移动障碍物）

```cpp
// Enable: Project Settings > Navigation System > Runtime Generation = Dynamic

// Mark actor as dynamic obstacle:
UStaticMeshComponent* Mesh = /* Get mesh */;
Mesh->SetCanEverAffectNavigation(true);
Mesh->bDynamicObstacle = true;
```

---

## Nav Link（离网连接）

### Nav Link Proxy（跳跃、传送）

1. Place Actors > Navigation > Nav Link Proxy
2. 设置起点与终点
3. 配置：
   - **Direction**：单向或双向
   - **Smart Link**：在通过时播放角色动画

---

## 人群管理

### Detour Crowd（避免重叠）

```cpp
// Enable: Character Movement Component > Avoidance Enabled = true

// Configure avoidance group and flags
UCharacterMovementComponent* MoveComp = GetCharacterMovement();
MoveComp->SetAvoidanceGroup(1);
MoveComp->SetGroupsToAvoid(1);
MoveComp->SetAvoidanceEnabled(true);
```

---

## 性能技巧

### Nav Mesh 优化

```cpp
// Reduce tile size for large worlds:
// Project Settings > Navigation System > Cell Size = 19 (default)

// Use Navigation Invokers for dynamic generation:
// Only generate NavMesh around players/important actors
```

---

## 调试

### 可视化 Nav Mesh

```cpp
// Console commands:
// show navigation - Toggle NavMesh visualization
// p - Toggle NavMesh (editor viewport)

// Draw debug path:
if (NavPath) {
    for (int i = 0; i < NavPath->GetPathPoints().Num() - 1; i++) {
        DrawDebugLine(GetWorld(), NavPath->GetPathPoints()[i], NavPath->GetPathPoints()[i + 1], FColor::Green, false, 5.0f, 0, 5.0f);
    }
}
```

---

## 常见模式

### 在路径点之间巡逻

```cpp
UPROPERTY(EditAnywhere, Category = "AI")
TArray<AActor*> PatrolPoints;

int32 CurrentPatrolIndex = 0;

void OnMoveCompleted(FAIRequestID RequestID, EPathFollowingResult::Type Result) {
    if (Result == EPathFollowingResult::Success) {
        // Move to next waypoint
        CurrentPatrolIndex = (CurrentPatrolIndex + 1) % PatrolPoints.Num();
        MoveToActor(PatrolPoints[CurrentPatrolIndex]);
    }
}
```

### 追逐玩家

```cpp
void Tick(float DeltaTime) {
    Super::Tick(DeltaTime);

    AAIController* AIController = Cast<AAIController>(GetController());
    APawn* PlayerPawn = GetWorld()->GetFirstPlayerController()->GetPawn();

    if (AIController && PlayerPawn) {
        float Distance = FVector::Dist(GetActorLocation(), PlayerPawn->GetActorLocation());

        if (Distance < 1000.0f) {
            // Chase player
            AIController->MoveToActor(PlayerPawn, 100.0f);
        } else {
            // Stop chasing
            AIController->StopMovement();
        }
    }
}
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/navigation-system-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/ai-in-unreal-engine/
