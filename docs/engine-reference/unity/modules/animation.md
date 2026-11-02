# Unity 6.3 — 动画模块参考

**Last verified:** 2026-02-13
**Knowledge Gap:** Unity 6 动画改进、Timeline 增强

---

## 概述

Unity 6.3 动画系统：
- **Animator Controller (Mecanim)**：基于状态机（推荐）
- **Timeline**：电影化序列、过场动画
- **Animation Rigging**：程序化运行时动画
- **旧版 Animation**：已弃用，应避免

---

## 相较 2022 LTS 的关键变更

### Animation Rigging 包（Unity 6 中已生产就绪）

```csharp
// Install: Package Manager > Animation Rigging
// Runtime IK, aim constraints, procedural animation
```

### Timeline 改进
- 更好的性能
- 更多轨道类型
- 改进的信号系统

---

## Animator Controller (Mecanim)

### 基本设置

```csharp
// Create: Assets > Create > Animator Controller
// Add to GameObject: Add Component > Animator
// Assign Controller: Animator > Controller = YourAnimatorController
```

### 状态过渡

```csharp
Animator animator = GetComponent<Animator>();

// ✅ Trigger transition
animator.SetTrigger("Jump");

// ✅ Bool parameter
animator.SetBool("IsRunning", true);

// ✅ Float parameter (blend trees)
animator.SetFloat("Speed", currentSpeed);

// ✅ Integer parameter
animator.SetInteger("WeaponType", 2);
```

### 动画层
- **Base Layer**：默认动画（移动）
- **Override Layers**：替换基础层（例如武器切换）
- **Additive Layers**：在基础层之上叠加（例如呼吸、瞄准偏移）

```csharp
// Set layer weight (0-1)
animator.SetLayerWeight(1, 0.5f); // 50% blend
```

---

## 混合树

### 1D 混合树（速度混合）

```csharp
// Idle (Speed = 0) → Walk (Speed = 0.5) → Run (Speed = 1.0)
animator.SetFloat("Speed", moveSpeed);
```

### 2D 混合树（方向移动）

```csharp
// X-axis: Strafe (-1 to 1)
// Y-axis: Forward/Back (-1 to 1)
animator.SetFloat("MoveX", input.x);
animator.SetFloat("MoveY", input.y);
```

---

## 动画事件

### 从动画片段触发事件

```csharp
// Add in Animation window: Right-click timeline > Add Animation Event
// Must have matching method on GameObject:

public void OnFootstep() {
    // Play footstep sound
    AudioSource.PlayClipAtPoint(footstepClip, transform.position);
}

public void OnAttackHit() {
    // Deal damage
    DealDamageInFrontOfPlayer();
}
```

---

## 根运动

### 通过动画实现角色移动

```csharp
Animator animator = GetComponent<Animator>();
animator.applyRootMotion = true; // Move character based on animation

void OnAnimatorMove() {
    // Custom root motion handling
    transform.position += animator.deltaPosition;
    transform.rotation *= animator.deltaRotation;
}
```

---

## Animation Rigging（Unity 6+）

### IK（反向运动学）

```csharp
// Install: Package Manager > Animation Rigging
// Add: Rig Builder component + Rig GameObject

// Two Bone IK (Arm/Leg)
// - Add Two Bone IK Constraint
// - Assign Tip (hand/foot), Mid (elbow/knee), Root (shoulder/hip)
// - Set Target (where hand/foot should reach)

// Runtime control:
TwoBoneIKConstraint ikConstraint = rig.GetComponentInChildren<TwoBoneIKConstraint>();
ikConstraint.data.target = targetTransform;
ikConstraint.weight = 1f; // 0-1 blend
```

### 瞄准约束（Look At）

```csharp
// Character looks at target
MultiAimConstraint aimConstraint = rig.GetComponentInChildren<MultiAimConstraint>();
aimConstraint.data.sourceObjects[0] = new WeightedTransform(targetTransform, 1f);
```

---

## Timeline（过场动画）

### Timeline 基本设置

```csharp
// Create: Assets > Create > Timeline
// Add to GameObject: Add Component > Playable Director
// Assign Timeline: Playable Director > Playable = YourTimeline

// Play from script:
PlayableDirector director = GetComponent<PlayableDirector>();
director.Play();
```

### Timeline 轨道
- **Activation Track**：启用/禁用 GameObject
- **Animation Track**：在 Animator 上播放动画
- **Audio Track**：同步音频播放
- **Cinemachine Track**：相机运动
- **Signal Track**：在特定时间触发事件

### 信号系统（事件）

```csharp
// Create Signal Asset: Assets > Create > Signals > Signal
// Add Signal Emitter to Timeline track
// Add Signal Receiver component to GameObject

public class CutsceneEvents : MonoBehaviour {
    public void OnDialogueStart() {
        // Triggered by signal
    }
}
```

---

## 动画播放控制

### 直接播放动画（不使用状态机）

```csharp
// ✅ CrossFade (smooth transition)
animator.CrossFade("Attack", 0.2f); // 0.2s transition

// ✅ Play (instant)
animator.Play("Idle");

// ❌ Avoid: Legacy Animation component
Animation anim = GetComponent<Animation>(); // DEPRECATED
```

---

## 动画曲线

### 自定义属性动画

```csharp
// In Animation window: Add Property > Custom Component > Your Script > Your Float

public class WeaponTrail : MonoBehaviour {
    public float trailIntensity; // Animated by clip

    void Update() {
        // Intensity controlled by animation curve
        trailRenderer.startWidth = trailIntensity;
    }
}
```

---

## 性能优化

### 剔除
- `Animator > Culling Mode`：
  - **Always Animate**：始终更新（开销大）
  - **Cull Update Transforms**：屏幕外时停止更新骨骼（推荐）
  - **Cull Completely**：屏幕外时停止所有动画

### LOD（细节层次）
- 为远处角色使用更简单的动画
- 减少 LOD 网格的骨骼数量

---

## 常见模式

### 检查动画是否结束

```csharp
AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);
if (stateInfo.IsName("Attack") && stateInfo.normalizedTime >= 1.0f) {
    // Attack animation finished
}
```

### 覆盖动画速度

```csharp
animator.speed = 1.5f; // 150% speed
```

### 获取当前动画名称

```csharp
AnimatorClipInfo[] clipInfo = animator.GetCurrentAnimatorClipInfo(0);
string currentClip = clipInfo[0].clip.name;
```

---

## 调试

### Animator 窗口
- `Window > Animation > Animator`
- 可视化状态机，查看当前状态

### Animation 窗口
- `Window > Animation > Animation`
- 编辑动画片段，添加事件

---

## 来源
- https://docs.unity3d.com/6000.0/Documentation/Manual/AnimationOverview.html
- https://docs.unity3d.com/Packages/com.unity.animation.rigging@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.timeline@1.8/manual/index.html
