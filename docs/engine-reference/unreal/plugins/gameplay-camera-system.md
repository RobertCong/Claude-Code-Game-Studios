# Unreal Engine 5.8 — Gameplay Camera System

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Status:** ⚠️ Experimental (introduced in UE 5.5; still flagged Experimental in 5.8)
**Plugin:** `GameplayCameras`（内置，在 Plugins 中启用）

> **UE 5.8 变更：** 摄像机组件可以运行自己的摄像机系统
> （"standalone" 模式，即默认模式），或仅运行一个摄像机求值上下文。玩家
> 摄像机管理器现在将视图目标作为 "blackbox" 运行；
> 若要混合或使用子导演，必须通过专用的新方法（例如 "Activate Gameplay Camera"）
> 激活程序化摄像机。Rig/modifier 的激活以及 shake 启动/停止方法已被移动；
> 新增了 "aim-at" 摄像机动作与摄像机动作服务。`GameplayCameras.uplugin`（5.8.1）
> 被标记为 Experimental 且默认启用。来源：UE 5.8 发布说明，
> https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

**Gameplay Camera System** 是 UE 5.5 引入的模块化摄像机管理框架。
它用一套灵活的、基于节点的系统取代传统摄像机设置，处理
摄像机模式、混合以及上下文感知的摄像机行为。

**使用 Gameplay Cameras 的场景：**
- 动态摄像机行为（第三人称、瞄准、载具、过场）
- 上下文感知的摄像机切换（战斗、探索、对话）
- 模式之间的平滑摄像机混合
- 程序化摄像机运动（摄像机抖动、延迟、偏移）

**⚠️ 警告：** 该插件在 UE 5.5-5.8 中为实验性。预期未来版本会有 API 变更。

---

## 核心概念

### 1. **Camera Rig**
- 定义摄像机配置（位置、旋转、FOV 等）
- 模块化节点图（类似 Material Editor）

### 2. **Camera Director**
- 管理哪个摄像机 rig 处于激活状态
- 处理摄像机 rig 之间的混合

### 3. **Camera Nodes**
- 摄像机行为的构建块：
  - **Position Nodes**：Orbit、Follow、Fixed Position
  - **Rotation Nodes**：Look At、Match Actor Rotation
  - **Modifiers**：Camera Shake、Lag、Offset

---

## 设置

### 1. 启用插件

`Edit > Plugins > Gameplay Cameras > Enabled > Restart`

### 2. 添加摄像机组件

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

UCLASS()
class AMyCharacter : public ACharacter {
    GENERATED_BODY()

public:
    AMyCharacter() {
        // Create camera component
        CameraComponent = CreateDefaultSubobject<UGameplayCameraComponent>(TEXT("GameplayCamera"));
        CameraComponent->SetupAttachment(RootComponent);
    }

protected:
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
    TObjectPtr<UGameplayCameraComponent> CameraComponent;
};
```

---

## 创建 Camera Rig

### 1. 创建 Camera Rig 资源

1. Content Browser > Gameplay > Gameplay Camera Rig
2. 打开 Camera Rig Editor（基于节点的图）

### 2. 构建 Camera Rig（示例：第三人称）

**节点设置：**
```
Actor Position (Character)
  ↓
Orbit Node (Orbit around character)
  ↓
Offset Node (Shoulder offset)
  ↓
Look At Node (Look at character)
  ↓
Camera Output
```

---

## 摄像机节点

### 位置节点

#### Orbit Node（第三人称）
- 围绕目标 actor 环绕
- 配置：
  - **Orbit Distance**：距目标的距离（例如 300 单位）
  - **Pitch Range**：最小/最大俯仰角
  - **Yaw Range**：最小/最大偏航角

#### Follow Node（平滑跟随）
- 带延迟地跟随目标
- 配置：
  - **Lag Speed**：摄像机追上目标的速度
  - **Offset**：相对目标的固定偏移

#### Fixed Position Node
- 世界空间中的静态摄像机位置

---

### 旋转节点

#### Look At Node
- 让摄像机朝向目标
- 配置：
  - **Target**：要看向的 actor 或组件
  - **Offset**：注视偏移（例如瞄准头部而不是脚部）

#### Match Actor Rotation
- 匹配目标 actor 的旋转
- 适用于第一人称或载具摄像机

---

### 修饰节点

#### Camera Shake
- 添加程序化抖动（例如脚步、爆炸）
- 配置：
  - **Shake Pattern**：Perlin 噪声、正弦波、自定义
  - **Amplitude**：抖动强度

#### Camera Lag
- 对摄像机运动进行平滑阻尼
- 配置：
  - **Lag Speed**：阻尼系数（0 = 立即，值越大延迟越大）

#### Offset Node
- 相对计算位置的静态偏移
- 适用于肩部摄像机偏移

---

## Camera Director（在 Rig 之间切换）

### 指定 Camera Rig

```cpp
#include "GameplayCameras/Public/GameplayCameraComponent.h"

void AMyCharacter::SetCameraMode(UGameplayCameraRig* NewRig) {
    if (CameraComponent) {
        CameraComponent->SetCameraRig(NewRig);
    }
}
```

### 在 Camera Rig 之间混合

```cpp
// Blend to aiming camera over 0.5 seconds
CameraComponent->BlendToCameraRig(AimingCameraRig, 0.5f);
```

---

## 示例：第三人称 + 瞄准

### 1. 创建两个 Camera Rig

**第三人称 Rig：**
```
Actor Position → Orbit (distance: 300) → Look At → Output
```

**瞄准 Rig：**
```
Actor Position → Orbit (distance: 150) → Offset (shoulder) → Look At → Output
```

### 2. 瞄准时切换

```cpp
UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> ThirdPersonRig;

UPROPERTY(EditAnywhere, Category = "Camera")
TObjectPtr<UGameplayCameraRig> AimingRig;

void StartAiming() {
    CameraComponent->BlendToCameraRig(AimingRig, 0.3f); // Blend over 0.3s
}

void StopAiming() {
    CameraComponent->BlendToCameraRig(ThirdPersonRig, 0.3f);
}
```

---

## 常见模式

### 过肩摄像机

```
Actor Position
  ↓
Orbit Node (distance: 250, yaw offset: 30°)
  ↓
Offset Node (X: 0, Y: 50, Z: 50) // Shoulder offset
  ↓
Look At Node (target: Character head)
  ↓
Output
```

---

### 载具摄像机

```
Vehicle Position
  ↓
Follow Node (lag: 0.2)
  ↓
Offset Node (behind vehicle: X: -400, Z: 150)
  ↓
Look At Node (target: Vehicle)
  ↓
Output
```

---

### 第一人称摄像机

```
Character Head Socket
  ↓
Match Actor Rotation
  ↓
Output
```

---

## 摄像机抖动

### 触发摄像机抖动

```cpp
#include "GameplayCameras/Public/GameplayCameraShake.h"

void TriggerExplosionShake() {
    if (APlayerController* PC = GetWorld()->GetFirstPlayerController()) {
        if (UGameplayCameraComponent* CameraComp = PC->FindComponentByClass<UGameplayCameraComponent>()) {
            CameraComp->PlayCameraShake(ExplosionShakeClass, 1.0f);
        }
    }
}
```

---

## 性能技巧

- 限制摄像机抖动频率（不要每帧触发）
- 谨慎使用摄像机延迟（高延迟值开销较大）
- 缓存摄像机 rig 引用（不要每帧搜索）

---

## 调试

### 摄像机调试可视化

```cpp
// Console commands:
// GameplayCameras.Debug 1 - Show active camera rig info
// showdebug camera - Show camera debug info
```

---

## 从旧版摄像机迁移

### 旧的 Spring Arm + Camera Component

```cpp
// ❌ OLD: Spring Arm Component
USpringArmComponent* SpringArm;
UCameraComponent* Camera;

// ✅ NEW: Gameplay Camera Component
UGameplayCameraComponent* CameraComponent;
// Build orbit + look-at rig in Camera Rig asset
```

---

## 限制（实验性状态）

- **API 不稳定**：后续版本中预期会有破坏性变更（5.8 已重构组件与激活 API）
- **文档有限**：官方文档仍在演进
- **蓝图支持**：主要面向 C++（蓝图支持正在改善）
- **生产风险**：发布前请充分测试

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/
- UE 5.5+ 发布说明
- **Note:** 该系统为实验性。请始终查看最新官方文档以了解 API 变更。
