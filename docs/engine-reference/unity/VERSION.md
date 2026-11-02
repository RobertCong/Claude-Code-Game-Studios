# Unity 引擎 — 版本参考

| Field | Value |
|-------|-------|
| **Engine Version** | Unity 6.3 LTS |
| **Installed at pin time** | NOT DETERMINED — `/setup-engine` §3 会探测已安装的编辑器，并把结果记录在这里。 |
| **Release Date** | 2025 年 12 月 |
| **Latest editor on the pinned line** | 6000.3.26f1（2026 年 10 月 8 日） |
| **Project Pinned** | 2026-02-13 |
| **Last Docs Verified** | 2026-10-17（发布时间线、更新的版本、最新 6.3 LTS 编辑器）；2026-02-13（目录其余部分） |
| **LLM Knowledge Cutoff** | 2025 年 5 月 |

## 知识缺口警告

LLM 的训练数据大概只覆盖到 Unity 约 2022 LTS（2022.3）。整个 Unity 6
发布系列（原 Unity 2023 Tech Stream）引入了模型**并不知晓**的重大变更。在建议任何
Unity API 调用之前，务必对照本目录交叉核实。

## 已安装版本缺口警告

上面的警告是单向的——它针对的是**模型**所掌握的知识少于本固定版本。反向缺口同样真实存在，且是
`/setup-engine` §3 刻意制造的（“固定较新的版本，之后再升级”）：本参考可能**领先于
已安装的编辑器**，而 agent 若正确地引用它，就会产出本地无法编译的 API。**在信任任何
带版本限定的论断之前，请先检查上面的 `Installed at pin time`**——`NOT DETERMINED`
意味着缺口未知，而不是不存在。

## 截止时间之后的版本时间线

| 版本 | 发布 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 6.2 | 2025 年 8 月 | MEDIUM | 受支持的 Update 版本：编辑器内 Unity AI（beta）、Mesh LOD、UI Toolkit 的 World Space UI、Graph Toolkit、Android XR 手部网格 |
| 6.3 LTS | 2025 年 12 月 | HIGH | 6.0 以来的首个 LTS（两年支持期）：Platform Toolkit、Nintendo Switch 2 支持、Android XR、桌面屏幕阅读器支持、Shader Build Settings |

## 固定版本之后发布的更新版本（6.4 至 6.7）

**固定版本不变：仍是 Unity 6.3 LTS，即最新的 LTS。**这些是其在之后发布的
受支持 Update 版本。本目录中没有其他内容覆盖它们的 API，因此任何 6.4+ API 在对照
Unity 对应版本的文档核查之前，都应视为未确认。6.0 LTS 的支持将于 2026 年 10 月结束。

| 版本 | 发布 | 状态（2026-10-17） | 关键主题 |
|---------|---------|---------------------|-----------|
| 6.4 | 2026 年 3 月 | 已停止支持（EOL） | ECS（Entities、Collections、Mathematics、Entities Graphics）作为 Core 包发布，Project Auditor 内置于编辑器，Windows 上的 DirectStorage，`EntityId` 取代 `InstanceID`，URP Compatibility Mode 移除并改用 Render Graph |
| 6.5 | 2026 年 6 月 | 已停止支持（EOL） | 实体统一（`InstanceID` 到 `EntityId`）、面向 CoreCLR 编辑器的 Editor Lifecycle API、2D（自定义光照与阴影、`RenderSprite` API、Physics Core 2D）、移动端逐瓦片后处理、Built-In Render Pipeline 弃用 |
| 6.6 | 2026 年 9 月 | 支持至 6.7 发布 | Unity 6 系列最后一个受支持版本：新项目默认 Play Mode 跳过域重载（domain reload）、Content Directories、Build Analysis 窗口、WebGPU 成为可用的生产级 Web 选项 |
| 6.7 | Beta | 未发布 | 6000.7.0b1 于 2026 年 9 月 17 日发布，最新 6000.7.0b5 于 2026 年 10 月 15 日发布；Unity 的 6.6 公告称其为 6.7 LTS |

日期与状态于 2026-10-17 核实：6.4（2026 年 3 月 17 日宣布；编辑器
6000.4.0f1 于 3 月 18 日）https://discussions.unity.com/t/unity-6-4-is-now-available/1713245
以及 https://docs.unity.com/en-us/engine/6000.6/manual/whats-new/unity64；6.5
（2026 年 6 月 15 日）https://discussions.unity.com/t/unity-6-5-is-now-available/1723176
以及 https://docs.unity.com/en-us/engine/6000.5/manual/whats-new/unity65；6.6
（编辑器 6000.6.0f1 于 8 月 31 日发布，9 月 1 日宣布，2026 年 10 月 15 日最新为 6000.6.6f1）
https://discussions.unity.com/t/unity-6-6-is-now-available/1735357。6.4 与
6.5 的帖子带有横幅“This supported release has reached end of life”
（6.4 指向 6.5 或以上，6.5 指向 6.6 或以上）；6.6 的帖子称其受支持
“until the next release - in this case 6.7 - arrives”，并且
“brings you one step closer to the 6.7 LTS”。编辑器版本与发布日期
来自 Unity 的发布 API
https://services.api.unity.com/unity/editor/release/v1/releases（6.3 LTS 首个
编辑器 6000.3.0f1 于 2025 年 12 月 3 日；最新 6000.3.26f1 于 2026 年 10 月 8 日）。升级
固定版本是等 6.7 LTS 发布并由 `/setup-engine` 重新固定时再决定的事；在此之前
新项目仍停留在 6.3 LTS。

## 截止时间之前的 Unity 6 版本

以下两个版本早于 2025 年 5 月的截止时间，因此不属于截止后版本。上面的知识
缺口警告对它们同样适用：在对照本目录核查之前，应将其 API 视为未确认。

| 版本 | 发布 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 6.0 LTS | 2024 年 10 月 | HIGH | Unity 6 发布：GPU Resident Drawer、URP 的 Render Graph、多人游戏工作流、移动端 Web、新的 Update 版本类型 |
| 6.1 | 2025 年 4 月 | MEDIUM | 首个受支持的 Update 版本：URP Deferred+ 路径、Variable Rate Shading、Project Auditor、Unity Web 的 WebGPU、可折叠/大屏 Android |

发布日期于 2026-10-17 对照 Unity 公告核实：6.0
（2024 年 10 月 17 日）https://unity.com/blog/introducing-unity-6-launch，6.1
（2025 年 4 月 24 日）https://unity.com/blog/unity-6-1-is-now-available，6.2
（2025 年 8 月 12 日）https://discussions.unity.com/t/6-2-is-now-available/1677060，
6.3 LTS（2025 年 12 月 4 日）https://unity.com/blog/unity-6-3-lts-is-now-available。
支持窗口：https://unity.com/releases/unity-6/support（6.0 LTS 支持至
2026 年 10 月，6.3 LTS 支持至 2027 年 12 月）。

## 从 2022 LTS 到 Unity 6.3 LTS 的重大变更

### 破坏性变更
- **Entities/DOTS**：Entities 1.0+ 中 API 大改，ECS 模式完全重新设计
- **Input System**：旧版 Input Manager 弃用，新的 Input System 成为默认
- **Rendering**：URP/HDRP 大幅升级，SRP Batcher 改进
- **Addressables**：资源管理工作流变化
- **Scripting**：支持 C# 9，新的 API 模式

### 新功能（截止时间之后）
- **DOTS**：可用于生产的实体组件系统（Entities 1.3+）
- **Graphics**：增强的 URP/HDRP 管线、GPU Resident Drawer
- **Multiplayer**：Netcode for GameObjects 改进
- **UI Toolkit**：运行时光 UI 可用于生产（新项目取代 UGUI）
- **Async Asset Loading**：Addressables 性能改进
- **Web**：WebGPU 支持

### 已弃用的系统
- **Legacy Input Manager**：使用新的 Input System 包
- **Legacy Particle System**：使用 Visual Effect Graph
- **UGUI**：仍然受支持，但新项目推荐 UI Toolkit
- **Old ECS (GameObjectEntity)**：由现代 DOTS/Entities 取代

## 已核实的来源

- 官方文档：https://docs.unity3d.com/6000.0/Documentation/Manual/index.html
- Unity 6 发布页：https://unity.com/releases/unity-6
- Unity 6.0 发布公告：https://unity.com/blog/introducing-unity-6-launch
- Unity 6.1 公告：https://unity.com/blog/unity-6-1-is-now-available
- Unity 6.2 公告：https://discussions.unity.com/t/6-2-is-now-available/1677060
- Unity 6.3 LTS 公告：https://unity.com/blog/unity-6-3-lts-is-now-available
- 迁移指南：https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- Unity 6 支持：https://unity.com/releases/unity-6/support
- Unity 6.4 公告：https://discussions.unity.com/t/unity-6-4-is-now-available/1713245
- Unity 6.5 公告：https://discussions.unity.com/t/unity-6-5-is-now-available/1723176
- Unity 6.6 公告：https://discussions.unity.com/t/unity-6-6-is-now-available/1735357
- 编辑器发布 API：https://services.api.unity.com/unity/editor/release/v1/releases
- C# API 参考：https://docs.unity3d.com/6000.0/Documentation/ScriptReference/index.html
