# Unreal Engine 5.8 — 当前最佳实践

**Last verified:** 2026-10-17（5.8 固定项：项目设置、C++ 标准、Blueprint Nativization、MegaLights、Substrate、Object Pooling 示例、日志）；2026-02-13（文件其余部分，针对 5.7 编写）

现代 UE5 模式，可能不在 LLM 的训练数据中。
这些是截至 UE 5.8 可用于生产的建议。

---

## 项目设置

### 新项目请使用 UE 5.8
- 最新版本：5.8（最新热修复 5.8.3，2026 年 9 月）
- MegaLights 与 Iris 在 5.8 中可用于生产（依据发布说明；Iris 插件仍带有 Beta 标记）；Substrate 与 PCG 自 5.7 起就已如此
- 需要 C++20 工具链：Windows 上需 Visual Studio 2022 17.14 或更新版本（推荐 2026），参见 `breaking-changes.md` → Platform-Specific

### 选择合适的渲染特性
- **Lumen**：实时全局光照（大多数项目推荐）
- **Nanite**：面向高面数网格的虚拟化几何体（细节丰富的环境推荐）
- **MegaLights**：以一致的 GPU 开销支持大量投射阴影的动态光源（5.8 中可用于生产；复杂光照推荐）
- **Substrate**：模块化材质系统（推荐；自 5.7 起对新项目自动启用）

---

## 命令行 — 构建与自动化测试（按平台）

在运行测试之前，先构建项目自己的编辑器目标（全新检出的代码没有
已编译的游戏模块），然后用编辑器运行自动化测试。Epic
建议构建 `<Project>Editor` 而不是 `UnrealEditor`，这样 `.uproject`
禁用的模块会保持禁用。请以绝对路径提供项目。

| 步骤 | Windows | Linux | macOS |
|------|---------|-------|-------|
| 构建编辑器目标 | `Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe <Project>Editor Win64 Development -Project="<abs>/<Project>.uproject"` | `Engine/Build/BatchFiles/Linux/Build.sh <Project>Editor Linux Development -Project="<abs>/<Project>.uproject"` | `Engine/Build/BatchFiles/Mac/Build.sh <Project>Editor Mac Development -Project="<abs>/<Project>.uproject"` |
| 用于命令行走的编辑器可执行文件 | `Engine/Binaries/Win64/UnrealEditor-Cmd.exe` | `Engine/Binaries/Linux/UnrealEditor` | **NOT SOURCEABLE** — Epic 仅记录了 `Engine/Binaries/Mac/UnrealEditor.app` 包，未记录其中的命令行编辑器 |
| 打包构建 | `Engine/Binaries/DotNET/AutomationTool/AutomationTool.exe BuildCookRun … -platform=Win64` | `Engine/Build/BatchFiles/RunUAT.sh BuildCookRun … -platform=Linux` | `Engine/Build/BatchFiles/RunUAT.sh BuildCookRun … -platform=Mac` |

自动化参数在每个平台上都相同：
`"<abs>/<Project>.uproject" -ExecCmds="Automation RunTests <Project>.; Quit" -unattended -nullrhi -stdout -FullStdOutLogOutput`。
`RunTests` 是部分（子串）匹配。每个测试会打印
`Test Completed. Result={<status>}`，运行结束时打印
`**** TEST COMPLETE. EXIT CODE: <n> ****` — 退出码 0 表示没有测试失败。
每个 `-ExecCmds` 只允许一个 `Automation` 运行请求，并且 `-testexit=` 是
遗留用法。

Windows 列是在 UE 5.7 上运行得到的。Linux 与 macOS 列来自
Epic 的文档以及 Epic 员工的论坛回答（来源见下）；Epic 从未
打印完整的 Linux 测试命令行，因此该行由可执行文件与
平台无关参数拼装而成。

来源：
- Linux 与 Mac 上的 Build.sh、平台名称 — *Create an Installed Build*：https://dev.epicgames.com/documentation/en-us/unreal-engine/create-an-installed-build-of-unreal-engine?application_version=5.7
- `RunUBT.sh <Target> [Linux|Mac] Development` — *Unreal Insights*：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-insights-in-unreal-engine?application_version=5.7
- `Engine/Binaries/Linux/UnrealEditor`、`Engine/Binaries/Mac/UnrealEditor.app` — *Onboarding Licensees*：https://dev.epicgames.com/documentation/en-us/unreal-engine/onboarding-licensees-in-unreal-engine?application_version=5.7 以及 *Linux Development Quickstart*：https://dev.epicgames.com/documentation/en-us/unreal-engine/linux-development-quickstart-for-unreal-engine?application_version=5.7
- `-nullrhi`、`-unattended`、`-stdout`、`-ExecCmds` — *Command-Line Arguments Reference*：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-command-line-arguments-reference?application_version=5.7
- 从命令行运行测试 — *Run Automation Tests*：https://dev.epicgames.com/documentation/en-us/unreal-engine/run-automation-tests-in-unreal-engine?application_version=5.7 ；结果行与退出码 — *Review Test Results*：https://dev.epicgames.com/documentation/en-us/unreal-engine/review-test-results-in-unreal-engine?application_version=5.7
- Mac/Linux 上 `Engine/Build/BatchFiles` 中的 `RunUAT.sh` — *Unreal Automation Tool Overview*：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-automation-tool-overview-for-unreal-engine?application_version=5.7

---

## C++ 编码

### 使用现代 C++ 特性（C++20，UE 5.8 的最低要求）

UE 5.8 将 C++20 设为下限：`CppStandardVersion.Cpp14` 与 `Cpp17` 被标记为
过时（"no longer allowed, code will not compile with this version"），
且 `Minimum = Cpp20`。C++23 可选但被标记为实验性。

```cpp
// ✅ Use TObjectPtr<T> (UE5 type-safe pointers)
UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComp;

// ✅ Structured bindings
if (auto [bSuccess, Value] = TryGetValue(); bSuccess) {
    // Use Value
}

// ✅ Concepts and constraints (C++20)
template<typename T>
concept Damageable = requires(T t, float damage) {
    { t.TakeDamage(damage) } -> std::same_as<void>;
};
```

### 使用 UPROPERTY() 进行垃圾回收

```cpp
// ✅ UPROPERTY ensures GC doesn't delete this
UPROPERTY()
TObjectPtr<AActor> MyActor;

// ❌ Raw pointers can become dangling
AActor* MyActor; // Dangerous! May be garbage collected
```

### 使用 UFUNCTION() 暴露到蓝图

```cpp
// ✅ Callable from Blueprint
UFUNCTION(BlueprintCallable, Category="Combat")
void TakeDamage(float Damage);

// ✅ Implementable in Blueprint
UFUNCTION(BlueprintImplementableEvent, Category="Combat")
void OnDeath();
```

---

## 蓝图最佳实践

### 蓝图与 C++ 的取舍

- **C++**：核心玩法系统、性能关键代码、底层引擎交互
- **Blueprint**：快速原型、内容创作、数据驱动逻辑、设计师工作流

### 蓝图性能技巧

```cpp
// ✅ Use Event Tick sparingly (expensive)
// Prefer timers or events

// ✅ Move hot Blueprint logic to C++ by hand
// (Blueprint Nativization is gone: UE 5.8's packaging settings keep only an
// unused EProjectPackagingBlueprintNativizationMethod enum, no setting)

// ✅ Cache frequently accessed components
// Don't call GetComponent every tick
```

---

## 渲染（UE 5.8）

### 使用 Lumen 实现全局光照

```cpp
// Enable: Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// Real-time GI, no lightmap baking needed (RECOMMENDED)
```

### 对高面数网格使用 Nanite

```cpp
// Enable on Static Mesh: Details > Nanite Settings > Enable Nanite Support
// Automatically LODs millions of triangles (RECOMMENDED for detailed meshes)
```

### 对复杂光照使用 MegaLights（UE 5.5+，5.8 中可用于生产）

```cpp
// Enable: Project Settings > Engine > Rendering > Direct Lighting > MegaLights
//   (r.MegaLights.EnableForProject, default 0; a Post Process Volume can
//   override it, and it can be disabled per light)
// Many shadow-casting lights at a consistent, low GPU cost
```

### 使用 Substrate 材质（5.7 中可用于生产）

```cpp
// New projects created in 5.7+ have Substrate enabled automatically.
// Existing projects keep their setting; to enable it:
//   Project Settings > Engine > Rendering > Substrate > Substrate materials
//   (r.Substrate, read-only at runtime, editor restart required)
// Modular, physically accurate materials (RECOMMENDED for new projects)
```

---

## Enhanced Input 系统

### 设置 Enhanced Input

```cpp
// 1. Create Input Action (IA_Jump)
// 2. Create Input Mapping Context (IMC_Default)
// 3. Add mapping: IA_Jump → Space Bar

// C++ Setup:
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"

void AMyCharacter::BeginPlay() {
    Super::BeginPlay();

    if (APlayerController* PC = Cast<APlayerController>(GetController())) {
        if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
            ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer())) {
            Subsystem->AddMappingContext(DefaultMappingContext, 0);
        }
    }
}

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMyCharacter::Move);
}

void AMyCharacter::Move(const FInputActionValue& Value) {
    FVector2D MoveVector = Value.Get<FVector2D>();
    AddMovementInput(GetActorForwardVector(), MoveVector.Y);
    AddMovementInput(GetActorRightVector(), MoveVector.X);
}
```

---

## Gameplay Ability System（GAS）

### 复杂玩法使用 GAS

```cpp
// ✅ Use GAS for: Abilities, buffs, damage calculation, cooldowns
// Modular, scalable, multiplayer-ready

// Install: Enable "Gameplay Abilities" plugin

// Example Ability:
UCLASS()
class UGA_Fireball : public UGameplayAbility {
    GENERATED_BODY()

public:
    virtual void ActivateAbility(...) override {
        // Ability logic
        SpawnFireball();
        CommitAbility(); // Commit cost/cooldown
    }
};
```

---

## World Partition（大型世界）

### 开放世界使用 World Partition

```cpp
// Enable: World Settings > Enable World Partition
// Automatically streams world cells based on player location

// Data Layers: Organize content (e.g., "Gameplay", "Audio", "Lighting")
// Runtime Data Layers: Load/unload at runtime
```

---

## Niagara（视觉特效）

### 使用 Niagara（而非 Cascade）

```cpp
// Create: Content Browser > Right Click > FX > Niagara System
// GPU-accelerated, node-based particle system (RECOMMENDED)

// Spawn particles:
UNiagaraComponent* NiagaraComp = UNiagaraFunctionLibrary::SpawnSystemAtLocation(
    GetWorld(),
    ExplosionSystem,
    GetActorLocation()
);
```

---

## MetaSounds（音频）

### 程序化音频使用 MetaSounds

```cpp
// Create: Content Browser > Right Click > Sounds > MetaSound Source
// Node-based audio, replaces Sound Cue for complex logic (RECOMMENDED)

// Play MetaSound:
UAudioComponent* AudioComp = UGameplayStatics::SpawnSound2D(
    GetWorld(),
    MetaSoundSource
);
```

---

## 复制（多玩家）

### 服务器权威模式

```cpp
// ✅ Client sends input, server validates and replicates
UFUNCTION(Server, Reliable)
void Server_Move(FVector Direction);

void AMyCharacter::Server_Move_Implementation(FVector Direction) {
    // Server validates and applies movement
    AddMovementInput(Direction);
}

// ✅ Replicate important state
UPROPERTY(Replicated)
int32 Health;

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}
```

---

## 性能优化

### 使用对象池（Object Pooling）

```cpp
// ✅ Reuse objects instead of Spawn/Destroy
// The pool is a member of a UCLASS. UPROPERTY() makes the container a GC
// reference, so inactive pooled actors are not collected (same rule as the
// GC section above).
UPROPERTY()
TArray<TObjectPtr<AActor>> ProjectilePool;

//
// AActor has no IsActive()/SetActive() -- those are UActorComponent members.
// A parked actor is hidden, has no collision and does not tick.
AActor* GetPooledProjectile() {
    for (AActor* Proj : ProjectilePool) {
        if (Proj && Proj->IsHidden()) {
            Proj->SetActorHiddenInGame(false);
            Proj->SetActorEnableCollision(true);
            Proj->SetActorTickEnabled(true);
            return Proj;
        }
    }
    // Pool exhausted, spawn new
    return SpawnNewProjectile();
}

void ReturnToPool(AActor* Proj) {
    Proj->SetActorHiddenInGame(true);
    Proj->SetActorEnableCollision(false);
    Proj->SetActorTickEnabled(false);
}
```

### 使用实例化静态网格

```cpp
// ✅ Hierarchical Instanced Static Mesh Component (HISM)
// Render thousands of identical meshes in one draw call
UHierarchicalInstancedStaticMeshComponent* HISM = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Trees"));
for (int i = 0; i < 1000; i++) {
    HISM->AddInstance(FTransform(RandomLocation));
}
```

---

## 调试

### 使用日志

```cpp
// ✅ Structured logging
UE_LOG(LogTemp, Warning, TEXT("Player health: %d"), Health);

// Custom log category
DECLARE_LOG_CATEGORY_EXTERN(LogMyGame, Log, All);
DEFINE_LOG_CATEGORY(LogMyGame);
UE_LOG(LogMyGame, Error, TEXT("Critical error!"));

// UE 5.8: UE_LOGF takes a printf-style format literal given as "..." or
// UTF8TEXT("...") (LogMacros.h). Epic asks new code to use it: UE_LOG "will
// eventually be deprecated", and 5.8 ships ConvertUELog.py to convert most uses.
UE_LOGF(LogMyGame, Warning, "Player health: %d", Health);
```

### 使用 Visual Logger

```cpp
// ✅ Visual debugging
#include "VisualLogger/VisualLogger.h"

UE_VLOG_SEGMENT(this, LogTemp, Log, StartPos, EndPos, FColor::Red, TEXT("Raycast"));
UE_VLOG_LOCATION(this, LogTemp, Log, TargetLocation, 50.f, FColor::Green, TEXT("Target"));
```

---

## 总结：UE 5.8 推荐技术栈

| 特性 | 2026 年选用 | 说明 |
|---------|------------------|-------|
| **光照** | Lumen + MegaLights | 实时 GI，大量投射阴影的光源 |
| **几何体** | Nanite | 高面数网格，自动 LOD |
| **材质** | Substrate | 模块化、物理精确 |
| **输入** | Enhanced Input | 可重绑定、模块化 |
| **视觉特效** | Niagara | GPU 加速 |
| **音频** | MetaSounds | 程序化音频 |
| **世界流式加载** | World Partition | 大型开放世界 |
| **玩法** | Gameplay Ability System | 复杂技能、增益 |

---

**Sources:**
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-documentation?application_version=5.8
- UE 5.8 发布说明（MegaLights 可用于生产、Iris 可用于生产、Platform SDK Upgrades、`UE_LOGF` 升级说明）：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8
- 5.8 引擎源码，读取自 2026-10-17 的 UE 5.8.1 安装：C++ 标准 — `Engine/Source/Programs/UnrealBuildTool/System/CppCompileEnvironment.cs`（`enum CppStandardVersion`）；Blueprint Nativization — `Engine/Source/Developer/DeveloperToolSettings/Classes/Settings/ProjectPackagingSettings.h`（该枚举是引擎源码中仅存的引用）；MegaLights 设置 — `Engine/Source/Runtime/Engine/Classes/Engine/RendererSettings.h`（`bEnableMegaLights`，类别 DirectLighting）以及 `Engine/Source/Runtime/Renderer/Private/MegaLights/MegaLights.cpp`（默认 0）；Substrate — `RendererSettings.h`（`bEnableSubstrate`，类别 Substrate）以及 `Engine/Source/Runtime/RenderCore/Private/RenderUtils.cpp`（"New projects created with 5.7, will have Substrate enabled automatically"）；`UE_LOGF` — `Engine/Source/Runtime/Core/Public/Logging/LogMacros.h`
- 对象池相关调用 — `Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h`（UE 5.8.1：`SetActorHiddenInGame`、`SetActorEnableCollision`、`SetActorTickEnabled`、`IsHidden`；没有 `IsActive`/`SetActive`）以及 `Engine/Source/Runtime/Engine/Classes/Components/ActorComponent.h`（`UActorComponent::SetActive`/`IsActive`）；`AActor` API，UE 5.8：https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/AActor?application_version=5.8
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- 对象池容器（`UPROPERTY() TArray<TObjectPtr<AActor>>`）— *Unreal Object Handling*（UPROPERTY 引用会让对象保持存活，"whether it's a simple Object pointer or an Unreal Engine container class"；裸指针 "will not be automatically nulled, nor will it prevent garbage collection"）：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-object-handling-in-unreal-engine?application_version=5.7 ；*Object Pointers*（"TObjectPtr is only garbage collection safe if it is marked as a UPROPERTY"；用它替代裸指针）：https://dev.epicgames.com/documentation/en-us/unreal-engine/object-pointers-in-unreal-engine?application_version=5.7
