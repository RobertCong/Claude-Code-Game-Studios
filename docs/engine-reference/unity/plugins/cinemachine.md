# Unity 6.3 — Cinemachine

**Last verified:** 2026-02-13
**Status:** 生产就绪
**Package:** `com.unity.cinemachine` v3.0+（Package Manager）

---

## 概述

**Cinemachine** 是 Unity 的虚拟相机系统，无需手动编写脚本即可实现专业的动态相机行为。它是 Unity 相机工作的行业标准。

**使用 Cinemachine 的场景：**
- 第三人称跟随相机
- 过场动画与电影化内容
- 相机混合与过渡
- 动态相机取景
- 屏幕抖动与相机效果

**⚠️ Knowledge Gap:** Cinemachine 3.0（Unity 6）相较 2.x 是一次重大重写。许多 API 名称和组件都已更改。

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 "Cinemachine"
3. 安装 `Cinemachine`（版本 3.0+）

---

## 核心概念

### 1. **虚拟相机**
- 定义相机行为（位置、旋转、镜头）
- 可以存在多个虚拟相机；同一时间只有一个处于 "live" 状态

### 2. **Cinemachine Brain**
- 主 Camera 上的组件
- 在虚拟相机之间混合
- 将虚拟相机设置应用到 Unity Camera

### 3. **优先级**
- 虚拟相机具有优先级数值
- 优先级最高的相机处于活动状态
- 优先级变化时平滑混合

---

## 基本设置

### 1. 将 Cinemachine Brain 添加到 Main Camera

```csharp
// Automatically added when creating first virtual camera
// Or manually: Add Component > Cinemachine Brain
```

### 2. 创建虚拟相机

`GameObject > Cinemachine > Cinemachine Camera`

这将创建一个带默认设置的 **CinemachineCamera** GameObject。

---

## 虚拟相机组件

### CinemachineCamera（Unity 6 / Cinemachine 3.0+）

```csharp
using Unity.Cinemachine;

public class CameraController : MonoBehaviour {
    public CinemachineCamera virtualCamera;

    void Start() {
        // Set priority (higher = active)
        virtualCamera.Priority = 10;

        // Set follow target
        virtualCamera.Follow = playerTransform;

        // Set look-at target
        virtualCamera.LookAt = playerTransform;
    }
}
```

---

## 跟随模式（Body 组件）

### 第三人称跟随（Orbital Follow）

```csharp
// In Inspector:
// CinemachineCamera > Body > 3rd Person Follow

// Configure:
// - Shoulder Offset: (0.5, 0, 0) for over-shoulder
// - Camera Distance: 5.0
// - Vertical Damping: 0.5 (smooth up/down)
```

### Framing Transposer（平滑跟随）

```csharp
// CinemachineCamera > Body > Position Composer

// Configure:
// - Screen Position: Center (0.5, 0.5)
// - Dead Zone: Don't move camera if target within zone
// - Damping: Smooth following
```

### Hard Lock（精确跟随）

```csharp
// CinemachineCamera > Body > Hard Lock to Target
// Camera exactly matches target position (no offset or damping)
```

---

## 瞄准模式（Aim 组件）

### Composer（框定目标）

```csharp
// CinemachineCamera > Aim > Composer

// Configure:
// - Tracked Object Offset: Aim at target's head instead of feet
// - Screen Position: Where target appears on screen
// - Dead Zone: Don't rotate if target within zone
```

### Look At Target

```csharp
// CinemachineCamera > Aim > Rotate With Follow Target
// Camera rotation matches target rotation (e.g., first-person)
```

---

## 相机之间的混合

### 基于优先级的混合

```csharp
public CinemachineCamera normalCamera; // Priority: 10
public CinemachineCamera aimCamera;    // Priority: 5

void StartAiming() {
    // Set aim camera to higher priority
    aimCamera.Priority = 15; // Now active
    // Brain automatically blends from normalCamera to aimCamera
}

void StopAiming() {
    aimCamera.Priority = 5; // Back to normal
}
```

### 自定义混合时间

```csharp
// Create Custom Blends Asset:
// Assets > Create > Cinemachine > Cinemachine Blender Settings

// In Cinemachine Brain:
// - Custom Blends = your asset
// - Configure blend times per camera pair
```

---

## 相机抖动

### Impulse Source（触发抖动）

```csharp
using Unity.Cinemachine;

public class ExplosionShake : MonoBehaviour {
    public CinemachineImpulseSource impulseSource;

    void Explode() {
        // Trigger camera shake
        impulseSource.GenerateImpulse();
    }
}
```

### Impulse Listener（接收抖动）

```csharp
// Add to CinemachineCamera:
// Add Component > CinemachineImpulseListener

// Impulse listener automatically receives shake from nearby Impulse Sources
```

---

## Freelook 相机（带鼠标视角的第三人称）

### Cinemachine Free Look

```csharp
// GameObject > Cinemachine > Cinemachine Free Look

// Creates 3 rigs (Top, Middle, Bottom) that blend based on vertical input
// Configure:
// - Orbit Radius: Distance from target
// - Height Offset: Camera height at each rig
// - X/Y Axis: Mouse or joystick input
```

---

## 状态驱动相机（基于 Animator）

### Cinemachine State-Driven Camera

```csharp
// GameObject > Cinemachine > Cinemachine State-Driven Camera

// Configure:
// - Animated Target: Character with Animator
// - Layer: Animator layer to track
// - State: Assign camera per animation state (Idle, Run, Jump, etc.)

// Camera automatically switches based on animation state
```

---

## Dolly 轨道（过场动画）

### Cinemachine Dolly Track

```csharp
// 1. Create Spline: GameObject > Cinemachine > Cinemachine Spline

// 2. Create Dolly Camera:
//    GameObject > Cinemachine > Cinemachine Camera
//    Body > Spline Dolly
//    Assign Spline

// 3. Animate dolly position on spline (Timeline or script)
```

---

## 常见模式

### 第三人称跟随相机

```csharp
// CinemachineCamera
// - Follow: Player Transform
// - Body: 3rd Person Follow (shoulder offset, distance: 5)
// - Aim: Composer (frame player at center)
```

---

### 瞄准相机（拉近）

```csharp
// Normal Camera (Priority 10):
//   - Distance: 5.0

// Aim Camera (Priority 5):
//   - Distance: 2.0
//   - FOV: Narrower

// Script:
void StartAiming() {
    aimCamera.Priority = 15; // Blend to aim camera
}
```

---

### 过场动画相机序列

```csharp
// Use Timeline:
// 1. Create Timeline (Assets > Create > Timeline)
// 2. Add Cinemachine Track
// 3. Add virtual cameras as clips
// 4. Timeline automatically blends between cameras
```

---

## 从 Cinemachine 2.x（Unity 2021）迁移

### API 变更（Unity 6 / Cinemachine 3.0）

```csharp
// ❌ OLD (Cinemachine 2.x):
CinemachineVirtualCamera vcam;
vcam.m_Follow = target;

// ✅ NEW (Cinemachine 3.0+):
CinemachineCamera vcam;
vcam.Follow = target; // Cleaner API
```

**主要变更：**
- `CinemachineVirtualCamera` → `CinemachineCamera`
- `m_Follow`、`m_LookAt` → `Follow`、`LookAt`（无 "m_" 前缀）
- 组件为清晰起见已重命名
- 更好的性能

---

## 性能提示

- 限制活动的虚拟相机数量（仅在需要时激活）
- 使用低优先级相机，而不是销毁/创建相机
- 远离玩家时禁用虚拟相机

---

## 调试

### Cinemachine 调试

```csharp
// Window > Analysis > Cinemachine Debugger
// Shows active camera, blend info, shot quality
```

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html
- https://learn.unity.com/tutorial/cinemachine
