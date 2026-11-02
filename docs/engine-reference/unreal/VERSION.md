# Unreal Engine — 版本参考资料

| 字段 | 值 |
|-------|-------|
| **Engine Version** | Unreal Engine 5.8 |
| **Installed at pin time** | NOT DETERMINED — `/setup-engine` §3 会探测已安装的编辑器，并把结果记录在此处。 |
| **Release Date** | 2026 年 6 月（5.8.0）；最新热修复 5.8.3，2026 年 9 月 |
| **Project Pinned** | 2026-10-17 |
| **Last Docs Verified** | 2026-10-17（发布节奏、5.8 发布说明，以及本目录中记录的 5.8 变更）；2026-02-13（目录其余部分，依据 5.7 编写） |
| **LLM Knowledge Cutoff** | 2025 年 5 月 |

## 知识缺口警告

LLM 的训练数据大致覆盖到 Unreal Engine 5.3 左右。5.4 到 5.8 版本引入了模型并不知晓的重大变更（5.4 和 5.5 虽早于截止时间，但并未被可靠覆盖）。在建议任何 Unreal API 调用之前，务必对照本目录进行交叉核实。

## 已安装版本缺口警告

上一条警告是单向的——它描述的是**模型**所知少于本次固定版本的情况。反向缺口同样真实存在，而且 `/setup-engine` §3 会刻意制造它（“固定较新的版本，之后再升级”）：本参考资料可能**超前于已安装的编辑器**，此时 agent（代理）正确引用它反而会产出在本地无法编译的 API。**在信任任何带版本限定的结论之前，先检查上方的 `Installed at pin time`** —— `NOT DETERMINED` 意味着缺口未知，而不是不存在。

## 截止时间之后的版本时间线

| 版本 | 发布时间 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 5.6 | 2025 年 6 月 | MEDIUM | 60 Hz 的大型开放世界（Hardware Ray Tracing Lumen 性能、Fast Geometry Streaming 插件，Experimental）、引擎内置 MetaHuman Creator、编辑器内动画与绑定工具 |
| 5.7 | 2025 年 11 月 | HIGH | PCG 达到生产可用、Substrate 达到生产可用（新项目默认开启）、MegaLights Beta、编辑器内 AI Assistant（Experimental） |
| 5.8 | 2026 年 6 月 | HIGH | MegaLights 达到生产可用、Iris 复制达到生产可用、Mesh Terrain（Experimental）、Lumen Lite（Beta）、Enhanced Input 与 Common UI 统一、MCP Server 插件（Experimental）、最低要求 C++20、Windows 默认音频后端为 WASAPI、移动端默认多趟延迟渲染 |

## 截止时间之前的 Unreal Engine 5 版本

这两个版本早于 2025 年 5 月的截止时间，因此不属于截止时间之后的版本。上方的知识缺口警告对它们同样适用：在对照本目录核实之前，应将其 API 视为未经确认。

| 版本 | 发布时间 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 5.4 | 2024 年 4 月 | HIGH | Motion Matching 达到生产可用、Choosers、动画创作（Modular Control Rig、Sequencer 重构）、Nanite Tessellation（Experimental）、Motion Design 模式 |
| 5.5 | 2024 年 11 月 | HIGH | 引入 MegaLights、Substrate 进入 Beta、Sequencer 动画创作、移动游戏开发、多项功能达到生产可用 |

发布日期已于 2026-10-17 对照 Epic 的发布公告帖核实：
5.4（2024 年 4 月 23 日）https://forums.unrealengine.com/t/unreal-engine-5-4-released/1817064，
5.5（2024 年 11 月 12 日）https://forums.unrealengine.com/t/unreal-engine-5-5-released/2117936，
5.6（2025 年 6 月 3 日）https://forums.unrealengine.com/t/unreal-engine-5-6-released/2538952，
5.7（2025 年 11 月 12 日）https://forums.unrealengine.com/t/unreal-engine-5-7-released/2673913，
5.8（2026 年 6 月 17 日）https://forums.unrealengine.com/t/unreal-engine-5-8-released/2729274。
热修复 5.8.1（2026 年 7 月 28 日）、5.8.2（2026 年 8 月 25 日）与 5.8.3（2026 年 9 月 22 日）：
https://forums.unrealengine.com/t/5-8-3-hotfix-released/2833315。关键主题来自同一批帖子以及 5.7 和 5.8 发布说明（见下方“已核实来源”）。

## 从 UE 5.3 到 UE 5.8 的重大变更

### 破坏性变更
- **Substrate 材质系统**：新的材质框架（取代旧版材质）；5.7+ 创建的新项目会自动启用
- **PCG（Procedural Content Generation，程序化内容生成）**：达到生产可用，API 有重大变更
- **MegaLights**：面向大量投射阴影的动态光源的新光照系统；5.8 达到生产可用
- **动画创作**：新的绑定与动画工具
- **最低要求 C++20（5.8）**：`CppStandardVersion.Cpp14` 和 `Cpp17` 已废弃，不再参与编译
- **5.8 API 移除**：5.0-5.6 中已弃用的动画、Control Rig 和 Live Link 符号被移除；PhysicsMover 从 Mover 中移除，改用 ChaosMover —— 详见 `breaking-changes.md`

### 新功能（截止时间之后）
- **MegaLights**：大规模动态光照（5.8 达到生产可用）
- **Substrate Materials**：生产可用的模块化材质系统（5.7）
- **PCG Framework**：程序化世界生成（5.7 达到生产可用）
- **Iris**：复制系统，5.8 达到生产可用
- **Lumen Lite（5.8，Beta）**：中等质量 GI 设置，当前世代掌机上的默认项
- **Mesh Terrain（5.8，Experimental）**：基于网格的地形，超越高度场景观
- **Enhanced Virtual Production**：MetaHuman 集成，更深入的虚拟制片工作流
- **动画改进**：更好的绑定、混合与程序化动画
- **AI Assistant（5.7）**：编辑器内 AI 助手（Experimental）
- **MCP Server（5.8）**：让 agentic AI 系统连接 Unreal Editor 的编辑器插件（Experimental）

### 已弃用的系统
- **旧版材质系统**：新项目请迁移到 Substrate
- **旧 PCG API**：使用新的生产可用 PCG API（5.7+）
- **Raw Input 插件（5.8）**：已弃用，改用 Game Input for Windows 插件
- **`UE_LOG`（5.8）**：仍受支持；Epic 表示它“最终会被弃用”，并建议使用 `UE_LOGF`

## 已核实来源

- 官方文档：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-documentation?application_version=5.8
- UE 5.8 发布说明：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8
- UE 5.8 发布帖：https://forums.unrealengine.com/t/unreal-engine-5-8-released/2729274
- UE 5.8.3 热修复：https://forums.unrealengine.com/t/5-8-3-hotfix-released/2833315
- UE 5.7 发布说明：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- 5.7 新特性：https://dev.epicgames.com/documentation/en-us/unreal-engine/whats-new
- UE 5.7 公告：https://www.unrealengine.com/en-US/news/unreal-engine-5-7-is-now-available
- UE 5.5 博客：https://www.unrealengine.com/en-US/blog/unreal-engine-5-5-is-now-available
- 迁移指南：https://dev.epicgames.com/documentation/en-us/unreal-engine/upgrading-projects-to-newer-versions-of-unreal-engine
- 引擎源码，于 2026-10-17 从 UE 5.8.1 安装中读取：`Engine/Source/Programs/UnrealBuildTool/System/CppCompileEnvironment.cs`（C++ 标准）、`Engine/Source/Runtime/RenderCore/Private/RenderUtils.cpp`（Substrate 默认值）
