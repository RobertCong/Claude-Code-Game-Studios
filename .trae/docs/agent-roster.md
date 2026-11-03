# Agent Roster

以下 agent 均可使用。每个 agent 在 `.claude/agents/` 中都有专属定义文件。请使用最适合当前任务的 agent。当任务跨越多个领域时，负责协调的 agent（通常是 `producer` 或领域主管）应把工作委派给专家。

这里的每个 agent 都是 `model: inherit` —— 全部 49 个都在会话所用模型上运行，没有一个固定指定模型。这一点不同于发行版本集：后者把三个固定为 `opus`、十六个固定为 `sonnet`；`model-tiers.md` 记录了有哪些变动以及为何重要。

## Tier 1 -- 领导层 agent
| Agent | 领域 | 使用时机 |
|-------|--------|-------------|
| `creative-director` | 高层愿景 | 重大创意决策、游戏支柱冲突、基调与方向 |
| `technical-director` | 技术愿景 | 架构决策、技术栈选择、性能策略 |
| `producer` | 生产管理 | 冲刺规划、里程碑跟踪、风险管理、协调 |

## Tier 2 -- 部门主管 agent
| Agent | 领域 | 使用时机 |
|-------|--------|-------------|
| `game-designer` | 游戏设计 | 机制、系统、进度、经济、平衡 |
| `lead-programmer` | 代码架构 | 系统设计、代码评审、API 设计、重构 |
| `art-director` | 视觉方向 | 风格指南、美术圣经、资源标准、UI/UX 方向 |
| `audio-director` | 音频方向 | 音乐方向、声音调色板、音频实现策略 |
| `narrative-director` | 故事与写作 | 故事弧线、世界构建、角色设计、对话策略 |
| `qa-lead` | 质量保证（QA） | 测试策略、缺陷分类、发布就绪、回归规划 |
| `release-manager` | 发布流水线 | 构建管理、版本管理、变更日志、部署、回滚 |
| `localization-lead` | 国际化 | 字符串外置、翻译流水线、语言区域测试 |

## Tier 3 -- 专家 agent
| Agent | 领域 | 使用时机 |
|-------|--------|-------------|
| `systems-designer` | 系统设计 | 具体机制实现、公式设计、循环 |
| `level-designer` | 关卡设计 | 关卡布局、节奏、遭遇设计、动线 |
| `economy-designer` | 经济/平衡 | 资源经济、战利品表、进度曲线 |
| `gameplay-programmer` | 玩法代码 | 功能实现、玩法系统代码 |
| `engine-programmer` | 引擎系统 | 核心引擎、渲染、物理、内存管理 |
| `ai-programmer` | AI 系统 | 行为树、寻路、NPC 逻辑、状态机 |
| `network-programmer` | 网络 | 网络代码、复制、延迟补偿、匹配 |
| `tools-programmer` | 开发工具 | 编辑器扩展、流水线工具、调试实用程序 |
| `ui-programmer` | UI 实现 | UI 框架、界面、控件、数据绑定 |
| `technical-artist` | 技术美术 | 着色器、VFX、优化、美术流水线工具 |
| `sound-designer` | 音效设计 | SFX 设计文档、音频事件列表、混音说明 |
| `writer` | 对话/背景故事 | 对话撰写、背景故事条目、物品描述 |
| `world-builder` | 世界/背景故事设计 | 世界规则、阵营设计、历史、地理 |
| `qa-tester` | 测试执行 | 编写测试用例、缺陷报告、测试清单 |
| `performance-analyst` | 性能 | 性能分析、优化建议、内存分析 |
| `devops-engineer` | 构建/部署 | CI/CD、构建脚本、版本控制工作流 |
| `analytics-engineer` | 遥测 | 事件跟踪、仪表盘、A/B 测试设计 |
| `ux-designer` | UX 流程 | 用户流程、线框图、无障碍、输入处理 |
| `prototyper` | 快速原型 | 一次性原型、机制测试、可行性验证 |
| `security-engineer` | 安全 | 反作弊、漏洞防护、存档加密、网络安全 |
| `accessibility-specialist` | 无障碍 | WCAG 合规、色盲模式、按键重映射、文本缩放 |
| `live-ops-designer` | 长线运营（Live Ops） | 赛季、活动、战斗通行证、留存、实时经济 |
| `community-manager` | 社区 | 补丁说明、玩家反馈、危机公关、社区健康 |

## 引擎专属 agent（使用与你引擎匹配的那一组）

### 引擎主管

| Agent | 引擎 | 使用时机 |
| ---- | ---- | ---- |
| `unreal-specialist` | Unreal Engine 5 | Blueprint 与 C++ 的取舍、GAS 概览、UE 子系统、Unreal 优化 |
| `unity-specialist` | Unity | MonoBehaviour 与 DOTS 的取舍、Addressables、URP/HDRP、Unity 优化 |
| `godot-specialist` | Godot 4 | GDScript 模式、节点/场景架构、信号、Godot 优化 |

### Unreal Engine 子专家

| Agent | 子系统 | 使用时机 |
| ---- | ---- | ---- |
| `ue-gas-specialist` | Gameplay Ability System | 技能、玩法效果、属性集、标签、预测 |
| `ue-blueprint-specialist` | Blueprint 架构 | BP/C++ 边界、图表标准、命名、BP 优化 |
| `ue-replication-specialist` | 网络/复制 | 属性复制、RPC、预测、相关性、带宽 |
| `ue-umg-specialist` | UMG/CommonUI | 控件层级、数据绑定、CommonUI 输入、UI 性能 |

### Unity 子专家

| Agent | 子系统 | 使用时机 |
| ---- | ---- | ---- |
| `unity-dots-specialist` | DOTS/ECS | 实体组件系统、Jobs、Burst 编译器、混合渲染器 |
| `unity-shader-specialist` | 着色器/VFX | Shader Graph、VFX Graph、URP/HDRP 定制、后处理 |
| `unity-addressables-specialist` | 资源管理 | Addressable 分组、异步加载、内存、内容分发 |
| `unity-ui-specialist` | UI Toolkit/UGUI | UI Toolkit、UXML/USS、UGUI Canvas、数据绑定、跨平台输入 |

### Godot 子专家

| Agent | 子系统 | 使用时机 |
| ---- | ---- | ---- |
| `godot-gdscript-specialist` | GDScript | 静态类型、设计模式、信号、协程、GDScript 性能 |
| `godot-csharp-specialist` | C# / .NET | .NET 模式、[Signal] 委托、异步、可空类型、类型安全的节点访问 |
| `godot-shader-specialist` | 着色器/渲染 | Godot 着色语言、可视化着色器、粒子、后处理 |
| `godot-gdextension-specialist` | GDExtension | C++/Rust 绑定、原生性能、自定义节点、构建系统 |
