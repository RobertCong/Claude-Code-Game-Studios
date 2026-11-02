# Unreal Engine 5.8 — 可选插件与系统

**Last verified:** 2026-10-17（5.8 状态标记、Mover、Iris、AI Assistant、MCP Server、Raw Input）；2026-02-13（文件其余部分，针对 5.7 编写）

本文档索引 Unreal Engine 5.8 中可用的**可选插件与系统**。
它们不属于核心引擎，但在特定游戏类型中经常被使用。

---

## 如何使用本指南

**✅ 有详细文档** - 参见 `plugins/` 目录中的完整指南
**🟡 仅有简要概述** - 链接到官方文档，详情请使用 WebSearch
**⚠️ 实验性** - 未来版本中可能有破坏性变更
**📦 需要插件** - 必须在 `Edit > Plugins` 中启用

### UE 5.8 安装中的状态标记

Epic 自己的 `.uplugin` 标记决定插件窗口是否将插件显示为
Beta 或 Experimental。以下内容读取自 2026-10-17 的 UE 5.8.1 安装
（`Engine/Plugins/...`）；如果下文某条状态行与本表不一致，以本表为准（即引擎的说法）。

| 插件 | `.uplugin` | 5.8 标记 |
|--------|-----------|----------|
| Gameplay Abilities | `Runtime/GameplayAbilities/GameplayAbilities.uplugin` | 无（非 Beta/Experimental） |
| CommonUI | `Runtime/CommonUI/CommonUI.uplugin` | 无 |
| PCG | `PCG/PCG.uplugin` | 无；默认启用 |
| Gameplay Cameras | `Cameras/GameplayCameras/GameplayCameras.uplugin` | Experimental；默认启用 |
| Mass Gameplay / Mass Crowd | `Runtime/MassGameplay/MassGameplay.uplugin`, `AI/MassCrowd/MassCrowd.uplugin` | Experimental（MassEntity 本身是引擎代码，`Engine/Source/Runtime/MassEntity`） |
| Niagara Fluids | `FX/NiagaraFluids/NiagaraFluids.uplugin` | Beta |
| Water | `Experimental/Water/Water.uplugin` | Experimental |
| Landmass | `Experimental/Landmass/Landmass.uplugin` | Beta |
| Chaos Destruction (Geometry Collection) | `Experimental/GeometryCollectionPlugin/GeometryCollectionPlugin.uplugin` | Beta |
| Chaos Vehicles | `Experimental/ChaosVehiclesPlugin/ChaosVehiclesPlugin.uplugin` | Experimental |
| Geometry Scripting | `Runtime/GeometryScripting/GeometryScripting.uplugin` | 无 |
| Mover / ChaosMover | `Experimental/Mover/Mover.uplugin`, `Experimental/ChaosMover/ChaosMover.uplugin` | Experimental |
| Iris | `Experimental/Iris/Iris.uplugin` | Beta（5.8 发布说明称 Iris "production-ready for licensees"） |
| Replication Graph | `Runtime/ReplicationGraph/ReplicationGraph.uplugin` | Beta（无弃用标记） |
| AI Assistant | `Experimental/AIAssistant/AIAssistant.uplugin` | Experimental |
| Raw Input | `Experimental/RawInput/RawInput.uplugin` | `"DeprecatedEngineVersion": "5.8"` |
| Game Input (Windows) | `GameInputWindows/GameInputWindows.uplugin` | Beta |
| OpenXR | `Runtime/OpenXR/OpenXR.uplugin` | 无 |
| Enhanced Input, MetaSound | `EnhancedInput/EnhancedInput.uplugin`, `Runtime/Metasound/Metasound.uplugin` | 无；默认启用 |

---

## 可用于生产的系统（有详细文档）

### ✅ Gameplay Ability System（GAS）
- **Purpose:** 模块化技能系统（技能、属性、效果、冷却、消耗）
- **When to use:** RPG、MOBA、带有技能的射击游戏，以及任何基于技能的玩法
- **Knowledge Gap:** GAS 自 UE4 起稳定，UE5 的改进发生在训练数据截止之后
- **Status:** Production-Ready
- **Plugin:** `GameplayAbilities`（内置，在 Plugins 中启用）
- **Detailed Docs:** [plugins/gameplay-ability-system.md](plugins/gameplay-ability-system.md)
- **Official:** https://docs.unrealengine.com/5.7/en-US/gameplay-ability-system-for-unreal-engine/

---

### ✅ CommonUI
- **Purpose:** 跨平台 UI 框架（自动路由手柄/鼠标/触摸输入）
- **When to use:** 多平台游戏（主机 + PC），与输入设备无关的 UI
- **Knowledge Gap:** 在 UE5+ 中可用于生产，重大改进发生在训练数据截止之后
- **Status:** Production-Ready
- **Plugin:** `CommonUI`（内置，在 Plugins 中启用）
- **Detailed Docs:** [plugins/common-ui.md](plugins/common-ui.md)
- **Official:** https://docs.unrealengine.com/5.7/en-US/commonui-plugin-for-advanced-user-interfaces-in-unreal-engine/

---

### ✅ Gameplay Camera System
- **Purpose:** 模块化摄像机管理（摄像机模式、混合、上下文感知摄像机）
- **When to use:** 需要动态摄像机行为的游戏（第三人称、瞄准、载具）
- **Knowledge Gap:** UE 5.5 新增，完全处于训练数据截止之后
- **Status:** ⚠️ Experimental (UE 5.5-5.8; still flagged Experimental in 5.8)
- **Plugin:** `GameplayCameras`（内置，在 Plugins 中启用）
- **Detailed Docs:** [plugins/gameplay-camera-system.md](plugins/gameplay-camera-system.md)
- **Official:** https://docs.unrealengine.com/5.7/en-US/gameplay-cameras-in-unreal-engine/

---

### ✅ PCG（程序化内容生成）
- **Purpose:** 基于节点的程序化世界生成（植被、道具、地形细节）
- **When to use:** 开放世界、程序化关卡、大规模环境填充
- **Knowledge Gap:** 在 UE 5.0-5.6 中为实验性，5.7 起可用于生产；5.8 增加了手动编辑、复杂属性与内嵌子图
- **Status:** Production-Ready（自 UE 5.7 起）
- **Plugin:** `PCG`（内置，在 Plugins 中启用）
- **Detailed Docs:** [plugins/pcg.md](plugins/pcg.md)
- **Official:** https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/

---

## 其他插件（简要概述）

### 🟡 Mass Entity
- **Purpose:** 面向大规模 AI/人群的高性能 ECS（10,000+ 实体）
- **When to use:** RTS、城市模拟、大规模人群、大规模 AI
- **Status:** `MassGameplay` 和 `MassCrowd` 在 5.8 中被标记为 Experimental。5.8 重构了 Mass：Mass Signals 移入核心引擎，实体可以在游戏线程之外创建，新的 MassCore 模块将核心实体系统与 MassGameplay 分离
- **Plugin:** `MassGameplay`, `MassCrowd`（MassEntity 在 5.8 中是引擎代码，不是插件）
- **Official:** https://docs.unrealengine.com/5.7/en-US/mass-entity-in-unreal-engine/

---

### 🟡 Niagara Fluids
- **Purpose:** GPU 流体模拟（烟雾、火焰、液体）
- **When to use:** 逼真的火焰/烟雾效果、水体模拟
- **Status:** Beta (5.8 flag)
- **Plugin:** `NiagaraFluids`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/niagara-fluids-in-unreal-engine/

---

### 🟡 Water Plugin
- **Purpose:** 带浮力的海洋、河流、湖泊渲染
- **When to use:** 含水体、船只、游泳的游戏
- **Status:** Experimental (5.8 flag)
- **Plugin:** `Water`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/water-system-in-unreal-engine/

---

### 🟡 Landmass Plugin
- **Purpose:** 地形雕刻与景观编辑
- **When to use:** 大规模地形修改、程序化景观
- **Status:** Beta (5.8 flag)
- **Plugin:** `Landmass`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/landmass-plugin-in-unreal-engine/

---

### 🟡 Chaos Destruction
- **Purpose:** 实时破碎与破坏
- **When to use:** 可破坏环境（墙体、建筑、物体）
- **Status:** Beta (5.8 flag on `GeometryCollectionPlugin`)
- **Plugin:** `GeometryCollectionPlugin`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/destruction-in-unreal-engine/

---

### 🟡 Chaos Vehicle
- **Purpose:** 高级载具物理（轮式载具、悬挂）
- **When to use:** 竞速游戏、载具玩法较多的场景
- **Status:** Experimental (5.8 flag; replaces PhysX Vehicles)
- **Plugin:** `ChaosVehiclesPlugin`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/chaos-vehicles-overview-in-unreal-engine/

---

### 🟡 Geometry Scripting
- **Purpose:** 运行时程序化网格生成与编辑
- **When to use:** 动态网格创建、程序化建模
- **Status:** Production-Ready (UE 5.1+)
- **Plugin:** `GeometryScripting`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/geometry-scripting-in-unreal-engine/

---

### 🟡 Motion Design Tools
- **Purpose:** 动态图形、程序化动画、关键帧动画
- **When to use:** UI 动画、程序化运动、关键帧序列
- **Status:** Experimental → Production-Ready (UE 5.4+)
- **Plugin:** `MotionDesign`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/motion-design-mode-in-unreal-engine/

---

## 实验性插件（谨慎使用）

### ⚠️ AI Assistant (UE 5.7+)
- **Purpose:** 编辑器内的 AI 指导与帮助
- **Status:** Experimental
- **Plugin:** `AIAssistant`（Experimental，在 5.8 中默认关闭）
- **Official:** 在 UE 5.7 发布说明中公布

---

### ⚠️ MCP Server (UE 5.8+)
- **Purpose:** 让代理式 AI 系统连接 Unreal Editor，以理解引擎与项目，并帮助构建资源或系统
- **Status:** Experimental
- **Official:** UE 5.8 发布说明，*MCP Server (Experimental)*

---

### ⚠️ Mover / ChaosMover
- **Purpose:** 带有回滚与预测的角色和物体移动框架
- **Status:** Experimental (5.8 flag)。5.8 继续推进「将 Mover 移出实验性状态（moving Mover out of Experimental status）的架构工作」
- **5.8 change:** PhysicsMover / NetworkPhysicsLiaison 代码已从 Mover 插件中移除；请使用 `ChaosMover`

---

### ⚠️ OpenXR (VR/AR)
- **Purpose:** 跨平台 VR/AR 支持
- **When to use:** VR/AR 游戏
- **Status:** Production-Ready for VR, Experimental for AR
- **Plugin:** `OpenXR`（内置）
- **Official:** https://docs.unrealengine.com/5.7/en-US/openxr-in-unreal-engine/

---

### ⚠️ Online Subsystem (EOS, Steam, etc.)
- **Purpose:** 平台无关的在线服务（匹配、好友、成就）
- **When to use:** 具有在线功能的多玩家游戏
- **Status:** Production-Ready
- **Plugin:** `OnlineSubsystem`, `OnlineSubsystemEOS`, `OnlineSubsystemSteam`
- **Official:** https://docs.unrealengine.com/5.7/en-US/online-subsystem-in-unreal-engine/

---

## 已弃用的插件（新项目请避免）

### ❌ PhysX Vehicles
- **Deprecated:** 请改用 Chaos Vehicles
- **Status:** 遗留，不推荐

---

### ❌ Old Replication Graph
- **Deprecated:** 已由 Iris 取代（UE 5.1+）
- **Status:** 现代网络功能请使用 Iris。注意：在 5.8 中 `ReplicationGraph` 插件带 Beta 标记且没有弃用标记，因此这是建议，而非引擎层面的弃用

---

### ❌ Raw Input
- **Deprecated:** 在 UE 5.8 中（`"DeprecatedEngineVersion": "5.8"`）
- **Status:** 请使用 Game Input for Windows 插件（`GameInputWindows`，Beta）

---

## 按需 WebSearch 策略

对于上文未列出的插件，当用户询问时请使用以下方法：

1. 用 **WebSearch** 查找最新文档：`"Unreal Engine 5.8 [plugin name]"`
2. 确认插件是否：
   - 处于训练数据截止之后（超出 2025 年 5 月的训练数据）
   - 是 Experimental 还是 Production-Ready
   - 在 UE 5.8 中仍受支持
3. 可选：将发现结果缓存到 `plugins/[plugin-name].md` 以备将来参考

---

## 快速决策指南

**我需要技能/能力/增益** → **Gameplay Ability System（GAS）**
**我需要跨平台 UI（主机 + PC）** → **CommonUI**
**我需要动态摄像机** → **Gameplay Camera System**
**我需要程序化世界** → **PCG**
**我需要大规模人群（上千个 AI）** → **Mass Entity**
**我需要可破坏环境** → **Chaos Destruction**
**我需要载具** → **Chaos Vehicles**
**我需要水/海洋** → **Water Plugin**
**我需要 VR/AR** → **OpenXR**

---

**Last Updated:** 2026-10-17
**Engine Version:** Unreal Engine 5.8
**Sources (5.8):** UE 5.8 发布说明 https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8 （Mass、Iris、Mover、MCP Server、Raw Input 升级说明）；UE 5.8.1 安装中的 `.uplugin` 文件，路径见上方的状态表
**LLM Knowledge Cutoff:** May 2025
