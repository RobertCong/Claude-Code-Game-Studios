# Unity 6.3 LTS — 破坏性变更

**Last verified:** 2026-02-13

本文档记录了 Unity 2022 LTS（可能存在于模型训练数据中）与 Unity 6.3 LTS（当前版本）之间的破坏性 API 变更和行为差异。按风险等级组织。

## HIGH RISK — 会破坏现有代码

### Entities/DOTS API 全面重构
**Versions:** Entities 1.0+ (Unity 6.0+)

```csharp
// ❌ OLD (pre-Unity 6, GameObjectEntity pattern)
public class HealthComponent : ComponentData {
    public float Value;
}

// ✅ NEW (Unity 6+, IComponentData)
public struct HealthComponent : IComponentData {
    public float Value;
}

// ❌ OLD: ComponentSystem
public class DamageSystem : ComponentSystem { }

// ✅ NEW: ISystem (unmanaged, Burst-compatible)
public partial struct DamageSystem : ISystem {
    public void OnCreate(ref SystemState state) { }
    public void OnUpdate(ref SystemState state) { }
}
```

**Migration:** 遵循 Unity 的 ECS 迁移指南。需要进行重大的架构变更。

---

### Input System — 旧版 Input 已弃用
**Versions:** Unity 6.0+

```csharp
// ❌ OLD: Input class (deprecated)
if (Input.GetKeyDown(KeyCode.Space)) { }

// ✅ NEW: Input System package
using UnityEngine.InputSystem;
if (Keyboard.current.spaceKey.wasPressedThisFrame) { }
```

**Migration:** 安装 Input System 包，用新 API 替换所有 `Input.*` 调用。

---

### URP/HDRP Renderer Feature API 变更
**Versions:** Unity 6.0+

```csharp
// ❌ OLD: ScriptableRenderPass.Execute signature
public override void Execute(ScriptableRenderContext context, ref RenderingData data)

// ✅ NEW: Uses RenderGraph API
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
```

**Migration:** 将自定义渲染通道更新为使用 RenderGraph API。

---

## MEDIUM RISK — 行为变更

### Addressables — 资源加载返回值
**Versions:** Unity 6.2+

资源加载失败现在默认抛出异常，而不是返回 null。请添加适当的异常处理，或使用 `TryLoad` 变体。

```csharp
// ❌ OLD: Silent null on failure
var handle = Addressables.LoadAssetAsync<Sprite>("key");
var sprite = handle.Result; // null if failed

// ✅ NEW: Throws on failure, use try/catch or TryLoad
try {
    var handle = Addressables.LoadAssetAsync<Sprite>("key");
    var sprite = await handle.Task;
} catch (Exception e) {
    Debug.LogError($"Failed to load: {e}");
}
```

---

### Physics — 默认求解器迭代次数变更
**Versions:** Unity 6.0+

默认求解器迭代次数已提高，以获得更好的稳定性。如果你依赖旧行为，请检查 `Physics.defaultSolverIterations`。

---

## LOW RISK — 弃用（仍可用）

### UGUI（旧版 UI）
**Status:** 已弃用但受支持
**Replacement:** UI Toolkit

UGUI 仍然可用，但新项目推荐使用 UI Toolkit。

---

### 旧版粒子系统
**Status:** 已弃用
**Replacement:** Visual Effect Graph (VFX Graph)

---

### 旧版动画系统
**Status:** 已弃用
**Replacement:** Animator Controller (Mecanim)

---

## 平台特定的破坏性变更

### WebGL
- **Unity 6.0+**：WebGPU 现在是默认选项（可回退到 WebGL 2.0）
- 更新着色器以兼容 WebGPU

### Android
- **Unity 6.0+**：最低 API 级别提升至 24（Android 7.0）

### iOS
- **Unity 6.0+**：最低部署目标提升至 iOS 13

---

## 迁移检查清单

从 2022 LTS 升级到 Unity 6.3 LTS 时：

- [ ] 审查所有 DOTS/ECS 代码（很可能需要完全重写）
- [ ] 用 Input System 包替换 `Input` 类
- [ ] 将自定义渲染通道更新为 RenderGraph API
- [ ] 为 Addressables 调用添加异常处理
- [ ] 测试物理行为（求解器迭代次数已变更）
- [ ] 考虑将新 UI 从 UGUI 迁移到 UI Toolkit
- [ ] 更新 WebGL 着色器以支持 WebGPU
- [ ] 核实最低平台版本（Android/iOS）

---

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/upgrade-guide.html
