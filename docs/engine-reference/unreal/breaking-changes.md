# Unreal Engine 5.8 — 破坏性变更

**最后核实：** 2026-10-17（UE 5.8 Changes、Substrate/MegaLights 版本、平台特定项、迁移检查清单）；2026-02-13（文件其余部分，依据 5.7 编写）

本文档记录 Unreal Engine 5.3（模型训练数据大概覆盖的版本）与 Unreal Engine 5.8（当前版本）之间的破坏性 API 变更与行为差异，按风险等级组织。5.8 新增的变更排在最前，位于 **UE 5.8 Changes** 之下。

## UE 5.8 Changes

内容来源于 UE 5.8 发布说明（Upgrade Notes 与 API Change 条目）以及 5.8 引擎源码；来源列于本文件末尾。

### HIGH RISK — 会破坏现有代码

| 变更 | 破坏点 | 应对方式 |
|--------|-------------|---------|
| **最低要求 C++20** | 设置为 `CppStandard = CppStandardVersion.Cpp17`（或 `Cpp14`）的 target：两者均已废弃，“不再允许，代码无法使用此版本编译” | 移除该覆盖，或设为 `CppStandardVersion.Default`（= `Cpp20`） |
| **PhysicsMover 从 Mover 中移除** | Mover 插件中使用不受支持的 PhysicsMover / NetworkPhysicsLiaison 代码的部分 | 使用 ChaosMover 插件（“PhysicsMover 的每一项功能都有等价实现”） |
| **已弃用的动画符号被移除** | Animation、Control Rig、Persona 和 Live Link 中 5.0-5.6 的非反射 `UE_DEPRECATED` 项（例如接收 FSmartName 的构造函数、`UMotionWarpingComponent::GetCharacterOwner`） | 改用其弃用提示中指定的替代项；`GetCharacterOwner` → `GetOwnerAdapter()->GetActor()` / `GetActorOwner()` |
| **`LexToString(bool)` 不再捕获其他类型** | 仅能隐式转换为 `bool` 的类型，现在在 `LexToString` 中编译失败 | 添加显式转换，或为该类型提供真正的 `LexToString` 重载 |
| **MetaSound 节点元数据** | `FNodeClassMetadata::DefaultInterface` 现在接收 `FClassInterface` 而非 `FVertexInterface`；`IDataTypeRegistry` 中已弃用的输入/输出节点辅助函数被移除 | 更新自定义 MetaSound 节点类 |
| **Slate 窗口类型** | `EWindowType::GameWindow` | 改用 `EWindowType::Normal`；依赖 `SlateRHIRender` 的模块可能还需要 `SlateBaseRenderer` |
| **`FSharedEventRef` 重置模式** | 此前无论构造函数参数如何都使用 `EEventMode::AutoReset`；现在会遵循 `ManualReset` | 检查传入 `ManualReset` 的调用点 |

### MEDIUM RISK — 行为变更

- **Windows 音频后端**：默认值从 XAudio2 切换为 WASAPI（Xbox 上同样使用）；XAudio2 仍可作为选择性回退方案。Epic 表示：“开发者侧无需做任何更改。”
- **移动端渲染器**：多趟延迟渲染（multi-pass deferred）成为各移动平台的默认路径；前向渲染（forward rendering）需选择性开启。带 'Use Half Precision' 覆盖的材质会恢复为 Default（记录在消息日志中）。
- **Zen 烘焙输出**：Zenserver 作为 Cooked Output Store（烘焙输出存储）默认开启；已有项目若曾禁用 Zen 存储，则在项目设置中启用之前保持关闭。`AllowRemoteNetworkService` 变为 `RemoteNetworkService`（取值为 `None` / `Unsecured` / `GeneratedStaticKey`，而非 true/false）。
- **Lumen**：高度雾（height fog）现在默认应用到反射光线命中上（`r.Lumen.HeightFog 1`）。
- **音频声部上限**：`au.EnableRelativeRenderCostVoiceLimit` 默认开启，因此在相同声部数量下可能播放更少的声音；请重新审视声部数量调优。
- **Enhanced Input 修复（由 CVar 控制）**：刷新时会忽略按住的按键（`EnhancedInput.IgnoreHeldKeysOnFlush`，默认 true），触摸 bool 动作键得到修正（`EnhancedInput.CorrectTouchBoolActionKeys`，默认开启）。这两个 CVar “将在未来版本中移除”。
- **蓝图局部变量**：与成员变量同名的函数局部变量可能继承错误的默认值；请重命名这类局部变量。

---

## HIGH RISK — 会破坏现有代码

### Substrate 材质系统（5.7 达到生产可用）
**版本：** UE 5.5（Beta）、5.7（生产可用；新项目自动启用）

Substrate 以模块化、物理精确的框架取代旧版材质系统。

```cpp
// ❌ OLD: Legacy material nodes (still work but deprecated)
// Standard material graph with Base Color, Metallic, Roughness, etc.

// ✅ NEW: Substrate material layers
// Use Substrate nodes: Substrate Slab, Substrate Blend, etc.
// Modular material authoring with true physical accuracy
```

**迁移：** 5.7+ 创建的新项目默认开启 Substrate。已有项目保持原有设置：在 `Project Settings > Engine > Rendering > Substrate > Substrate materials` 中启用（`r.Substrate`，需要重启编辑器），并使用 Substrate 节点重建材质。

---

### PCG（Procedural Content Generation）API 大改
**版本：** UE 5.7（生产可用）

PCG 框架达到生产可用状态，API 有重大变更。

```cpp
// ❌ OLD: Experimental PCG API (pre-5.7)
// Old node types, unstable API

// ✅ NEW: Production PCG API (5.7+)
// Use FPCGContext, IPCGElement, new node types
// Stable API, production-ready workflow
```

**迁移：** 遵循 5.7 文档中的 PCG 迁移指南。实验性 PCG 代码预计需要大幅重构。

---

### MegaLights 渲染系统
**版本：** UE 5.5（引入）、5.7（Beta）、5.8（生产可用）

面向大量投射阴影的动态光源的新光照系统。

```cpp
// ❌ OLD: Limited dynamic lights (clustered forward shading)
// Max ~100-200 dynamic lights before performance degrades

// ✅ NEW: MegaLights (5.5+, production-ready in 5.8)
// Many shadow-casting lights at a consistent, low GPU cost
// Enable: Project Settings > Engine > Rendering > Direct Lighting > MegaLights
//   (r.MegaLights.EnableForProject, default 0)
```

**迁移：** 无需更改代码，但光照行为可能有所不同。启用后请测试场景。

---

## MEDIUM RISK — 行为变更

### Enhanced Input 系统（现为默认）
**版本：** UE 5.1+（推荐）、5.7（默认）

Enhanced Input 现已成为默认输入系统。

```cpp
// ❌ OLD: Legacy input bindings (deprecated)
InputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

// ✅ NEW: Enhanced Input
SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
}
```

**迁移：** 用 Enhanced Input 动作替换旧版输入绑定。

---

### Nanite 默认启用
**版本：** UE 5.0+（可选）、5.7（推荐）

Nanite 虚拟化几何体现在是静态网格体的推荐工作流。

```cpp
// Enable Nanite on static mesh:
// Static Mesh Editor > Details > Nanite Settings > Enable Nanite Support
```

**迁移：** 将高面数网格体转换为 Nanite。在目标平台上测试性能。

---

## LOW RISK — 弃用项（仍可用）

### 旧版材质系统
**Status:** 已弃用但仍受支持
**Replacement:** Substrate 材质系统

旧版材质仍可使用，但新项目推荐使用 Substrate。

---

### 旧式 World Partition（UE4 风格）
**Status:** 已弃用
**Replacement:** World Partition（UE5+）

大型世界请使用 UE5 的 World Partition 系统。

---

## 平台特定的破坏性变更

UE 5.8 的工具链与 SDK 要求来自 5.8 发布说明中的
*Platform SDK Upgrades* 表格。

### Windows
- **UE 5.8**：最低要求 Visual Studio 2022 v17.14 或更新版本；推荐 Visual Studio 2026（最低 MSVC 14.38，推荐 14.50）
- **UE 5.8**：最低 Windows SDK 10.0.22621.0，默认 10.0.26100.0；最低 LLVM Clang 18.1.8
- **UE 5.7**：DirectX 12 现为默认（旧版本为 DX11）
- 更新着色器以兼容 DX12

### macOS
- **UE 5.5+**：需要 Metal 3（最低 macOS 13）
- **UE 5.8**：最低操作系统 macOS Sonoma 14.0；最低 Xcode 15.2，推荐 15.4 或更新版本（macOS 目标）

### Linux
- **UE 5.8**：推荐 Ubuntu 22.04、Rocky Linux 8 或 Red Hat Linux 8 及更新版本；编译器 clang 20.1.8

### Mobile
- **UE 5.8**：Android 最低安装 SDK 级别 26（Android 8.0+）；NDK r27c；编译 UE 的最低 SDK 为 34，推荐 35；Gradle 8.7、AGP 8.5.2
- **UE 5.8**：iOS / iPadOS / tvOS SDK 17 或更新；最低 Xcode 26.0，推荐 26.1.1（iOS 目标）
- **UE 5.8**：iOS Shader Model 6 为 Experimental

---

## 迁移检查清单

从 UE 5.3 升级到 UE 5.8 时：

- [ ] 移除所有 `CppStandardVersion.Cpp17` / `Cpp14` 覆盖（5.8 要求 C++20）
- [ ] 安装 5.8 工具链（Windows 上 Visual Studio 2022 17.14+ 或 2026；iOS 上 Xcode 26）
- [ ] 将 PhysicsMover 的使用迁移到 ChaosMover
- [ ] 重新构建并修复对 5.8 中已移除的弃用 API 的调用（见 **UE 5.8 Changes**）
- [ ] 审查 Substrate 材质（若已准备好切换新系统，则进行转换）
- [ ] 审计 PCG 使用情况（若使用实验性版本，则更新到生产 API）
- [ ] 测试 MegaLights 性能（启用并做基准测试）
- [ ] 将旧版输入迁移到 Enhanced Input
- [ ] 将高面数网格体转换为 Nanite
- [ ] 更新着色器以适配 DX12（Windows）或 Metal 3（macOS）
- [ ] 核实最低平台版本（5.8：Android 安装 SDK 26 / Android 8.0，iOS SDK 17，macOS Sonoma 14）
- [ ] 在目标硬件上测试 Lumen 和 Nanite 性能

---

**Sources:**
- UE 5.8 release notes（Upgrade Notes、API Change 条目、Platform SDK Upgrades、WASAPI、Mobile Renderer、Zenserver as Cooked Output Store）：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8
- 5.8 引擎源码，于 2026-10-17 从 UE 5.8.1 安装中读取：`Engine/Source/Programs/UnrealBuildTool/System/CppCompileEnvironment.cs`（`Cpp14`/`Cpp17` 标注为 `[Obsolete("Deprecated in UE5.8 ...")]`，`Minimum = Cpp20`）；`Engine/Source/Runtime/RenderCore/Private/RenderUtils.cpp`（新项目与已有项目的 Substrate 默认值）；`Engine/Source/Runtime/Engine/Classes/Engine/RendererSettings.h` 与 `Engine/Source/Runtime/Renderer/Private/MegaLights/MegaLights.cpp`（MegaLights 设置及默认值）
- 5.5 中的 Substrate Beta、5.7 中的 MegaLights Beta：https://forums.unrealengine.com/t/unreal-engine-5-5-released/2117936 , https://forums.unrealengine.com/t/unreal-engine-5-7-released/2673913
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
