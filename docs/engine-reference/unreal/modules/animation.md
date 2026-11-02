# Unreal Engine 5.8 — 动画模块参考

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Knowledge Gap:** UE 5.4-5.8 动画创作改进、Control Rig 2.0

> **UE 5.8 变更：** Smart names 已弃用 — `FSmartName`、
> `FSmartNameMapping` 与 `FSmartNameContainer` 带有 `UE_DEPRECATED(5.8, "Smart
> names and their mappings are no longer used")`（`Engine/Source/Runtime/Engine/Classes/Animation/SmartName.h`）。
> 5.0-5.6 中未反射且已弃用的 Animation、Control Rig、Persona 与 Live Link API
> 已被移除（例如 `UMotionWarpingComponent::GetCharacterOwner`
> → `GetOwnerAdapter()->GetActor()`）。Control Rig Physics 与 RigMapper
> 重定向工具为 Beta；Sequencer 中的 Animation Mixing 与 Direct Mesh
> Controls 为 Experimental。来源：UE 5.8 发布说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

UE 5.8 动画系统：
- **Animation Blueprint**：基于状态机的动画逻辑
- **Control Rig**：运行时程序化动画（在 UE5 中可用于生产）
- **IK Rig + Retargeter**：现代重定向系统
- **Sequencer**：过场动画

---

## Animation Blueprint

### 创建 Animation Blueprint

1. Content Browser > Right Click > Animation > Animation Blueprint
2. 选择父类：`AnimInstance`
3. 选择骨架

### 动画状态机（Animation State Machine）

```cpp
// In Animation Blueprint Event Graph:
// - State Machine drives animation states (Idle, Walk, Run, Jump)
// - Blend Spaces for directional movement

// Access in C++:
UAnimInstance* AnimInstance = Mesh->GetAnimInstance();
AnimInstance->Montage_Play(AttackMontage);
```

---

## 播放动画蒙太奇（Animation Montage）

### Animation Montage

```cpp
// Play montage
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
AnimInstance->Montage_Play(AttackMontage, 1.0f);

// Stop montage
AnimInstance->Montage_Stop(0.2f, AttackMontage);

// Check if montage is playing
bool bIsPlaying = AnimInstance->Montage_IsPlaying(AttackMontage);
```

### Montage Notify 事件

```cpp
// Add notify event in Animation Montage (right-click timeline > Add Notify > New Notify)
// Implement in C++:

UCLASS()
class UMyAnimInstance : public UAnimInstance {
    GENERATED_BODY()

public:
    UFUNCTION()
    void AnimNotify_AttackHit() {
        // Called when notify is reached
        DealDamage();
    }
};
```

---

## 混合空间（Blend Space）

### 一维混合空间（速度混合）

```cpp
// Create: Content Browser > Animation > Blend Space 1D
// Horizontal Axis: Speed (0 = Idle, 1 = Walk, 2 = Run)
// Add animations at key points

// Use in Anim Blueprint:
// - Get speed from character
// - Feed into Blend Space
```

### 二维混合空间（方向移动）

```cpp
// Create: Content Browser > Animation > Blend Space
// Horizontal Axis: Direction X (-1 to 1)
// Vertical Axis: Direction Y (-1 to 1)
// Place animations (Fwd, Back, Left, Right, diagonal)
```

---

## Control Rig（程序化动画）

### 创建 Control Rig

1. Content Browser > Animation > Control Rig
2. 选择骨架
3. 构建 Rig 层级（骨骼、控制器、IK）

### 在 Animation Blueprint 中使用 Control Rig

```cpp
// Add "Control Rig" node to Anim Blueprint
// Assign Control Rig asset
// Procedurally modify bones at runtime
```

### 在 C++ 中使用 Control Rig

```cpp
// Get control rig component
UControlRig* ControlRig = /* Get from animation instance */;

// Set control value
ControlRig->SetControlValue<FVector>(TEXT("IK_Hand_R"), TargetLocation);
```

---

## IK Rig 与重定向（UE5）

### 创建 IK Rig

1. Content Browser > Animation > IK Rig
2. 选择骨架
3. 添加 IK 目标（手、脚）
4. 设置求解器链

### 重定向动画

1. 为源骨架创建 IK Rig
2. 为目标骨架创建 IK Rig
3. 创建 IK Retargeter 资源
4. 指定源与目标 IK Rig
5. 批量重定向动画

### 在 C++ 中重定向

```cpp
// Retargeting is primarily editor-based
// Animations are retargeted once, then used normally
```

---

## 动画通知状态（Animation Notify State）

### 自定义 Notify State（基于时长的事件）

```cpp
UCLASS()
class UAnimNotifyState_Invulnerable : public UAnimNotifyState {
    GENERATED_BODY()

public:
    virtual void NotifyBegin(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, float TotalDuration, const FAnimNotifyEventReference& EventReference) override {
        // Start invulnerability
        AMyCharacter* Character = Cast<AMyCharacter>(MeshComp->GetOwner());
        Character->bIsInvulnerable = true;
    }

    virtual void NotifyEnd(USkeletalMeshComponent* MeshComp, UAnimSequenceBase* Animation, const FAnimNotifyEventReference& EventReference) override {
        // End invulnerability
        AMyCharacter* Character = Cast<AMyCharacter>(MeshComp->GetOwner());
        Character->bIsInvulnerable = false;
    }
};
```

---

## 骨骼网格与插槽（Socket）

### 将物体附加到插槽

```cpp
// Create socket in Skeletal Mesh Editor (Skeleton Tree > Add Socket)

// Attach component to socket
UStaticMeshComponent* Weapon = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Weapon"));
Weapon->SetupAttachment(GetMesh(), TEXT("hand_r_socket"));
```

---

## 动画曲线（Animation Curve）

### 使用动画曲线

```cpp
// Add curve to animation:
// Animation Editor > Curves > Add Curve

// Read curve value in Anim Blueprint or C++:
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
float CurveValue = AnimInstance->GetCurveValue(TEXT("MyCurve"));
```

---

## 根运动（Root Motion）

### 启用根运动

```cpp
// In Animation Sequence: Asset Details > Root Motion > Enable Root Motion

// In Character class:
GetCharacterMovement()->bAllowPhysicsRotationDuringAnimRootMotion = true;
```

---

## 动画层（Linked Anim Graph）

### 使用链接动画层

```cpp
// Create separate Anim Blueprints for layers (e.g., upper body, lower body)
// Link in main Anim Blueprint: Add "Linked Anim Graph" node

// Dynamically switch layers:
UAnimInstance* AnimInstance = GetMesh()->GetAnimInstance();
AnimInstance->LinkAnimClassLayers(NewLayerClass);
```

---

## Sequencer（过场动画）

### 创建 Sequence

1. Content Browser > Cinematics > Level Sequence
2. 添加轨道：Camera、Character、Animation 等

### 从 C++ 播放 Sequence

```cpp
#include "LevelSequenceActor.h"
#include "LevelSequencePlayer.h"

ALevelSequenceActor* SequenceActor = /* Spawn or find in level */;
SequenceActor->GetSequencePlayer()->Play();
```

---

## 性能技巧

### 动画优化

```cpp
// LOD (Level of Detail) for skeletal meshes
// Reduce bone count for distant characters

// Anim Blueprint optimization:
// - Use "Anim Node Relevancy" (skip updates when not visible)
// - Disable updates when off-screen:
GetMesh()->VisibilityBasedAnimTickOption = EVisibilityBasedAnimTickOption::OnlyTickPoseWhenRendered;
```

---

## 调试

### 动画调试可视化

```cpp
// Console commands:
// showdebug animation - Show animation state info
// a.VisualizeSkeletalMeshBones 1 - Show skeleton bones

// Draw debug bones:
DrawDebugCoordinateSystem(GetWorld(), BoneLocation, BoneRotation, 50.0f, false, -1.0f, 0, 2.0f);
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/animation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/control-rig-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/ik-rig-in-unreal-engine/
