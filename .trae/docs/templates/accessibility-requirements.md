# Accessibility Requirements

> 编写指引：.trae/docs/templates/guidance/accessibility-requirements-guide.md（编写时按章节加载——不要整体通读）。

> **Status**: [In Design | Committed | Audited | Certified]
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Accessibility Tier Target**: [Basic / Standard / Comprehensive / Exemplary]
> **Platform(s)**: [PC / Xbox / PlayStation 5 / Nintendo Switch / iOS / Android]
> **External Standards Targeted**:
> - WCAG 2.1 Level [A / AA / AAA]
> - AbleGamers CVAA Guidelines
> - Xbox Accessibility Guidelines (XAG) [Yes / No / Partial]
> - PlayStation Accessibility (Sony Guidelines) [Yes / No / Partial]
> - Apple / Google Accessibility Guidelines [Yes / No / N/A — mobile only]
> **Accessibility Consultant**: [姓名与机构，或 "None engaged"]
> **Linked Documents**: `design/gdd/systems-index.md`, `design/ux/interaction-patterns.md`
> **Template**: Accessibility Requirements

> **Why this document exists**: 逐屏的无障碍标注应该放在 UX 规格中。
> 本文档记录项目级的无障碍承诺、覆盖所有系统的功能矩阵、测试计划
> 以及审计历史。它在技术搭建阶段由 UX 设计师通过
> `/ux-design accessibility` 一次性创建——你负责选择层级，对照
> accessibility-specialist 设定并审计的标准——之后随着功能新增
> 和审计完成而更新。如果某项功能与这里做出的承诺冲突，
> 以本文档为准——修改功能，而不是修改承诺，
> 除非制作人批准正式修订。
>
> **When to update**: 每次 `/gate-check` 通过之后、任何无障碍
> 审计之后，以及每当有新游戏系统加入 `systems-index.md` 时。

---

## Accessibility Tier Definition

[To be designed]

### Tier Definitions

| Tier | Core Commitment | Typical Effort |
|------|----------------|----------------|
| **Basic** | 面向玩家的关键文本在标准分辨率下可读。没有任何功能仅依赖颜色区分。音乐、音效和语音拥有各自独立的音量控制。游戏可在不存在光敏性癫痫风险的情况下通关。 | 低——主要是设计层面的约束 |
| **Standard** | 包含 Basic 的全部内容，外加：所有平台上的完整输入重映射、带说话人识别的字幕、可调文本大小、至少一种色盲模式，以及不存在无法延长或无法切换的限时输入。 | 中——需要专门的实现工作 |
| **Comprehensive** | 包含 Standard 的全部内容，外加：菜单的屏幕阅读器支持、单声道音频选项、难度辅助模式、HUD 元素重新定位、减弱动态效果模式，以及为所有玩法关键音频提供视觉指示。 | 高——需要平台 API 集成和大量 UI 架构工作 |
| **Exemplary** | 包含 Comprehensive 的全部内容，外加：完整的字幕自定义（字体、大小、颜色、背景、位置）、高对比度模式、认知负荷辅助工具、所有纯音频提示的触觉替代方案，以及外部第三方无障碍审计。 | 极高——需要专门的无障碍预算和专家咨询 |

### This Project's Commitment

**Target Tier**: [Basic / Standard / Comprehensive / Exemplary]

**Rationale**: [用 3-5 句话说明选择该层级的理由——类型门槛、目标受众、平台要求、团队产能、降低一个层级的代价。推理清单与完整示例见指引。]

**Features explicitly in scope (beyond tier baseline)**:
- [高于层级基线的功能 + 原因]

**Features explicitly out of scope**:
- [排除在外的功能 + 原因——也必须出现在 Known Intentional Limitations 中]

---

## Visual Accessibility

[To be designed]

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| 最小文本大小——菜单 UI | Standard | 所有菜单界面 | Not Started | 1080p 下最小 24px。在 4K 下按比例缩放。参考：WCAG 2.1 SC 1.4.4 要求文本可缩放至 200% 且不丢失内容。 |
| 最小文本大小——字幕 | Standard | 所有配音/带字幕内容 | Not Started | 1080p 下最小 32px。约束条件是玩家在 3 米外观看电视。 |
| 最小文本大小——HUD | Standard | 游戏内 HUD | Not Started | 关键信息（生命值、弹药、目标）最小 20px。非关键 HUD 元素可以更小。 |
| 文本对比度——背景上的 UI 文本 | Standard | 所有 UI 文本 | Not Started | 正文最低 4.5:1 对比度（WCAG AA）。大号文本（18px 以上或 14px 粗体）为 3:1。在最终颜色值上用自动对比度检查器测试。 |
| 文本对比度——字幕 | Standard | 字幕显示 | Not Started | 字幕最低 7:1 对比度（WCAG AAA）——玩家阅读速度快，且无法控制背景。默认使用投影或完全不透明背景框。 |
| 色盲模式——红色盲（Protanopia） | Standard | 所有颜色编码玩法 | Not Started | 红绿色盲——影响约 6% 的男性。主要关注点：生命条、敌人指示、地图标记。将红色信号改为橙色/黄色；将绿色信号改为青绿色。 |
| 色盲模式——绿色盲（Deuteranopia） | Standard | 所有颜色编码玩法 | Not Started | 绿红色盲——影响约 1% 的男性。实际影响与红色盲相似。通常同一套调色板调整可同时覆盖两者。用 Coblis 或 Colour Blindness Simulator 验证。 |
| 色盲模式——蓝色盲（Tritanopia） | Standard | 所有颜色编码玩法 | Not Started | 蓝黄色盲——更为罕见（约 0.001%）。将蓝色 UI 元素改为紫色；将黄色改为橙色。 |
| 仅靠颜色作为指示的审计 | Basic | 所有 UI 与玩法 | Not Started | 在下表中列出每一处颜色是唯一区分手段的地方。每个此类位置在发布前都必须有非颜色备份（图标、形状、图案、文本标签）。 |
| UI 缩放 | Standard | 所有 UI 元素 | Not Started | 范围：75% 到 150%。默认：100%。缩放不得破坏布局——在最小和最大设置下测试所有界面。HUD 缩放应独立于菜单缩放。 |
| 高对比度模式 | Comprehensive | 菜单（最低要求）；HUD（优先） | Not Started | 将所有半透明背景替换为完全不透明。将中间调 UI 颜色替换为黑/白/系统高对比度颜色。所有可交互元素加描边。 |
| 亮度/伽马控制 | Basic | 全局 | Not Started | 在图形设置中提供。包含一张参考校准图（在正确校准下刚好可见的渐变或符号）。范围：相对默认值 -50% 到 +50%。 |
| 屏幕闪烁/频闪警告 | Basic | 所有过场动画、VFX | Not Started | （1）启动前显示带光敏性癫痫提示的警告画面。（2）按 Harding FPA 标准审计所有高频闪烁 VFX（超过亮度阈值时每秒闪烁不超过 3 次）。（3）可选：闪烁减弱模式，将闪烁幅度降低 80%。 |
| 动态/动画减弱模式 | Standard | 所有 UI 转场、镜头抖动、VFX | Not Started | 减弱或消除：屏幕抖动、镜头晃动、动态模糊、菜单中的视差滚动、循环背景动画。无法完全消除：玩家移动动画（会破坏可读性）。在无障碍设置中提供开关。 |
| 字幕——开/关 | Basic | 所有配音内容 | Not Started | 默认：关闭（行业标准——许多玩家更喜欢沉浸感）。首次启动时醒目地提供该选项。 |
| 字幕——说话人识别 | Standard | 所有配音内容 | Not Started | 在对话行之前显示说话人姓名。仅当各说话人的颜色差异不只是色相时才按说话人着色（需测试色盲兼容性）。 |
| 字幕——样式自定义 | Comprehensive | 字幕显示 | Not Started | 字体大小（至少 4 档）、背景不透明度（0–100%）、文本颜色（白色/黄色/自定义）、位置（底部/顶部/跟随玩家）。 |
| 字幕——音效说明 | Comprehensive | 玩法关键音效 | Not Started | 哪些音效符合条件见 Auditory Accessibility 章节。格式：方括号内的 [声音描述]，与对话区分开。 |

### Color-as-Only-Indicator Audit

> 填写每一处当前仅靠颜色作为唯一区分手段的玩法或 UI 元素。发布前逐项解决。
> 已解决的条目具备非颜色备份，并在上述三种色盲模式下均有效。示例行见指引。

| Location | Color Signal | What It Communicates | Non-Color Backup | Status |
|----------|-------------|---------------------|-----------------|--------|
| [为每个颜色编码元素添加一行] | | | | |

---

## Motor Accessibility

[To be designed]

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| 完整输入重映射 | Standard | 所有玩法输入、所有平台 | Not Started | 默认绑定的每个输入都必须可重新绑定。重映射独立适用于键盘、鼠标、手柄及任何支持的外设。不得同时将两个操作绑定到同一输入（冲突时警告）。将重映射持久化到玩家配置。 |
| 输入方式切换 | Standard | PC | Not Started | 玩家必须能随时在键盘/鼠标与手柄之间切换，无需重启。UI 必须动态更新提示（为当前输入方式显示正确的按键图标）。 |
| 单手模式 | [Tier] | [指出哪些功能需要双手同时操作] | Not Started | 审计每个多输入操作。对每一项：能否单手完成？如果不能，提供切换替代方案或按住切换版本。在此说明哪些功能有单手路径、哪些没有。 |
| 按住操作替代方案 | Standard | 所有按住输入 | Not Started | 每个"按住 [按键] 以 [操作]"都必须提供切换替代方案。切换模式：第一次按下激活，第二次按下取消。示例："按住冲刺"变为可选的"切换冲刺"模式。在此列出游戏中所有按住输入。 |
| 快速连按替代方案 | Standard | 任何连打/快速输入序列 | Not Started | 任何要求持续每秒超过 3 次的输入都必须提供单次按下切换替代方案。示例：Hades 的"按住连续冲刺"优雅地解决了这个问题。 |
| 输入时机调整 | Standard | QTE、限时按键、节奏输入 | Not Started | 在无障碍设置中提供时机窗口倍率。最低范围：0.5x 到 3.0x。默认：1.0x。在 3.0x 下，500ms 的窗口变为 1500ms。记录游戏中的每个限时输入，并在所有倍率值下测试。 |
| 瞄准辅助 | Standard | 所有远程战斗/瞄准 | Not Started | 不只是开/关——提供精细控制：辅助强度（0–100%）、辅助半径、瞄准吸附（snap-to-target）和瞄准减速（接近目标时减速）作为独立滑块。默认值应调校得有帮助而不突兀。 |
| 自动冲刺/移动辅助 | Standard | 移动系统 | Not Started | "按住冲刺"切换（上文已述）。此外：自动奔跑选项（按住方向后，玩家无需继续输入即可前进）。说明正常玩法中任何需要持续按住的移动输入。 |
| 平台跳跃/穿越辅助 | [Tier] | [如果游戏包含平台跳跃] | Not Started | 评估自动抓取（宽松的边缘检测）、土狼时间延长和跳跃高度调整是否适合本游戏的设计。若平台跳跃不是游戏系统，标记为 N/A。 |
| HUD 元素重新定位 | Comprehensive | 所有 HUD 元素 | Not Started | 允许玩家将生命条、小地图和任务追踪器移动到偏好的屏幕位置。这对使用头部追踪或眼动追踪硬件的玩家尤其重要，因为他们周边视野的覆盖可能减少。 |

---

## Cognitive Accessibility

[To be designed]

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| 难度选项 | Standard | 所有玩法难度参数 | Not Started | 尽可能提供独立的精细滑块（造成的伤害、受到的伤害、敌人侵略性、敌人速度），而不是单一的 Easy/Normal/Hard 标签。记录哪些参数可调、哪些固定。固定参数需要设计理由。 |
| 随处暂停 | Basic | 所有玩法状态 | Not Started | 玩家必须能在任何玩法状态下暂停，包括过场动画、对话和教程序列。记录当前禁止暂停的任何状态及其设计理由。任何限制都是风险。 |
| 教程持久性 | Standard | 所有教程与帮助文本 | Not Started | 关闭教程提示后，玩家必须能从菜单的帮助区重新调出。不要指望玩家在首次遇到时就吸收教程——AbleGamers 研究显示许多玩家会条件反射地关闭提示。 |
| 任务/目标清晰度 | Standard | 任务与目标系统 | Not Started | 在玩法过程中，当前活动目标必须始终能在 2 次按键内访问。按需显示完整目标文本，而不只是截断的标记。避免需要推断的目标（"调查北部区域"——具体在哪里？）。 |
| 纯音频信息的视觉指示 | Standard | 所有携带玩法信息的音效 | Not Started | 审计每个传达玩法关键状态的音效。对每个音效：是否有视觉等效物？方向性音频（屏幕外敌人）需要屏幕边缘指示器。关键警告（首领阶段转换、陷阱触发）需要视觉提示。完整列表见 Auditory Accessibility。 |
| UI 阅读时间 | Standard | 所有自动关闭的对话框 | Not Started | 任何包含可操作信息的对话框、通知或工具提示都不得在少于 5 秒内自动关闭。首选：完全不自动关闭——要求玩家确认。在此记录每个自动关闭元素及其当前时长。 |
| 认知负荷文档 | Comprehensive | 每个游戏系统 | Not Started | 对 systems-index.md 中的每个系统，记录它要求玩家同时追踪的事物最大数量。标记任何超过 4 的系统。这不是硬性规则，而是评审触发点——高认知负荷系统需要补偿性的 UI 清晰度。参见下方的 Per-Feature Accessibility Matrix。 |
| 导航辅助 | Standard | 世界导航 | Not Started | 快速旅行（前往已访问地点）、当前目标的路标系统、可选目标指示器始终可见。说明其中哪些适用于本游戏设计、哪些被有意省略。 |

---

## Auditory Accessibility

[To be designed]

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| 所有口头对话的字幕 | Basic | 所有配音内容 | Not Started | 100% 覆盖——无例外。包括旁白、引擎内对话、从远处听到的无线电/环境对话。对照配音时间测试字幕同步。 |
| 玩法关键音效的隐藏字幕 | Comprehensive | 已识别的音效列表（见下） | Not Started | 并非所有音效都需要字幕——只有那些传达玩家无法通过视觉推断的状态的音效。见下方的音效审计表。 |
| 单声道音频选项 | Comprehensive | 全局音频输出 | Not Started | 将立体声/空间音频折叠为单声道。保持声道之间的音量平衡，而不是简单相加使两侧达到满音量。对单侧耳聋的玩家至关重要。 |
| 独立音量控制 | Basic | 音乐/SFX/语音/UI 音频总线 | Not Started | 至少四个独立滑块。持久化到玩家配置。范围：0–100%，默认 80%。在主设置和暂停菜单中都提供。 |
| 方向性音频的视觉呈现 | Comprehensive | 所有屏幕外威胁与音频事件 | Not Started | 指向音频来源的屏幕边缘指示器。不透明度随音频音量缩放（越近越不透明）。两种变体：威胁指示器（红色）和信息指示器（中性色）。示例：The Last of Us Part II 使用屏幕边缘指示器表示屏幕外敌人的位置。 |
| 助听器兼容模式 | Standard | 高频音频提示 | Not Started | 审计所有音频提示的频率范围。任何仅通过高频声音（4kHz 以上）传达关键信息的提示都必须有低频或视觉等效物。助听器通常会过滤高频。 |

### Gameplay-Critical SFX Audit

> 识别每一个传达玩家需要据此行动的状态的音效。
> 下表中的每个条目都需要确认过的视觉备份或字幕。
> 示例行见指引。

| Sound Effect | What It Communicates | Visual Backup | Caption Required | Status |
|-------------|---------------------|--------------|-----------------|--------|
| [添加每个会改变玩家行为的音效] | | | | |

---

## Platform Accessibility API Integration

[To be designed]

| Platform | API / Standard | Features Planned | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| Xbox (GDK) | Xbox Game Core Accessibility / XAG | [通过 Xbox Ease of Access 进行输入重映射、高对比度支持、菜单的讲述人集成] | Not Started | 若希望进入 ID@Xbox Game Pass，必须符合 XAG。在 https://docs.microsoft.com/gaming/accessibility/guidelines 查看 XAG 清单 |
| PlayStation 5 | Sony Accessibility Guidelines / AccessibilityNode API | [菜单的屏幕阅读器直通、单声道音频、高对比度] | Not Started | 如果游戏在 UI 元素上暴露 AccessibilityNode 数据，PS5 原生支持系统级音频描述和单声道音频。 |
| Steam (PC) | Steam Accessibility Features / SDL | [通过 Steam Input 进行手柄输入重映射、字幕支持] | Not Started | Steam Input 允许系统级重映射，独立于游戏内重映射。键盘/鼠标仍需要游戏内重映射。 |
| iOS | UIAccessibility / VoiceOver | [如果计划推出移动版，则为菜单提供 VoiceOver 支持] | N/A | 仅当移动版发布在范围内时才需要。 |
| Android | AccessibilityService / TalkBack | [如果计划推出移动版，则为菜单提供 TalkBack 支持] | N/A | 仅当移动版发布在范围内时才需要。 |
| PC (Screen Reader) | JAWS / NVDA / Windows Narrator | [菜单导航播报] | Not Started | 要求 UI 元素通过平台 UI 层暴露无障碍名称和角色。Godot 4.5+ 的 AccessKit 集成覆盖了受支持的控件类型。对照 engine-reference/godot/ 文档验证。 |

---

## Per-Feature Accessibility Matrix

[To be designed]

> 当有新系统加入 systems-index.md 时，必须在此添加一行。如果某个系统
> 存在未解决的无障碍问题，它不能在系统索引中标记为 Approved。
> 示例行见指引。

| System | Visual Concerns | Motor Concerns | Cognitive Concerns | Auditory Concerns | Addressed | Notes |
|--------|----------------|---------------|-------------------|------------------|-----------|-------|
| [从 systems-index.md 添加系统] | | | | | | |

---

## Accessibility Test Plan

[To be designed]

| Feature | Test Method | Test Cases | Pass Criteria | Responsible | Status |
|---------|------------|------------|--------------|-------------|--------|
| 文本对比度 | 自动——对所有 UI 截图使用对比度分析工具 | 所有游戏状态下的所有文本/背景组合 | 所有正文 ≥ 4.5:1；所有大号文本 ≥ 3:1；字幕背景 ≥ 7:1 | ux-designer | Not Started |
| 色盲模式 | 手动——在启用各模式的情况下，对所有游戏截图使用 Coblis 模拟器 | 各模式下的探索、战斗、物品栏玩法截图 | 任何模式下都不丢失必要信息；玩家无需依靠颜色区分即可完成所有目标 | ux-designer | Not Started |
| 输入重映射 | 手动——将所有输入重映射为非默认绑定，完成教程和第一关 | 所有默认输入重新绑定；玩法功能正常；不可能出现绑定冲突 | 重映射后所有操作均可访问；冲突预防有效；绑定在重启后保持 | qa-tester | Not Started |
| 字幕准确性 | 手动——对照配音脚本核对，检查所有台词 | 所有配音内容；字幕时间；说话人识别 | 100% 的配音台词有字幕；所有多角色场景均标明说话人；台词结束后字幕显示不超过 3 秒 | qa-tester | Not Started |
| 按住输入切换 | 手动——启用所有切换替代方案，完成所有战斗和穿越序列 | 切换模式下的所有按住输入 | 所有按住操作在切换模式下均可完成；启用切换后不存在需要持续按住的玩法状态 | qa-tester | Not Started |
| 减弱动态模式 | 手动——启用该模式，浏览所有菜单并完成游戏第一小时 | 所有菜单转场；所有 HUD 动画；所有镜头抖动事件 | 菜单中无循环动画；镜头抖动不超过阈值；所有屏幕转场为交叉淡入或硬切 | ux-designer | Not Started |
| 平台屏幕阅读器（菜单） | 手动——启用操作系统屏幕阅读器，浏览所有菜单 | 主菜单、设置、暂停菜单、物品栏、地图 | 所有可交互菜单元素均有屏幕阅读器播报；导航顺序合乎逻辑；没有键盘/方向键无法到达的元素 | ux-designer | Not Started |
| 用户测试——色盲 | 与色盲参与者进行用户测试 | 在每种色盲模式下进行完整游戏会话 | 参与者无需请求颜色澄清即可完成所有内容；没有导致会话中断的困惑 | producer | Not Started |
| 用户测试——运动障碍 | 与使用单手或自适应控制器的参与者进行用户测试 | 在启用切换和延长时机模式的情况下进行完整游戏会话 | 参与者在与非残障玩家完成时间的容差范围内完成所有 MVP 内容 | producer | Not Started |

---

## Known Intentional Limitations

[To be designed]

> 这里的每一条都是风险——请诚实地评估。示例行见指引。

| Feature | Tier Required | Why Not Included | Risk / Impact | Mitigation |
|---------|--------------|-----------------|--------------|------------|
| [添加任何有意排除的无障碍功能] | | | | |

---

## Audit History

[To be designed]

> 示例行见指引。

| Date | Auditor | Type | Scope | Findings Summary | Status |
|------|---------|------|-------|-----------------|--------|
| [为每次审计添加一行] | | | | | |

---

## External Resources

[To be designed]

| Resource | URL | Relevance |
|----------|-----|-----------|
| WCAG 2.1 (Web Content Accessibility Guidelines) | https://www.w3.org/TR/WCAG21/ | 基础性无障碍标准——对比度、文本大小、输入要求 |
| Game Accessibility Guidelines | https://gameaccessibilityguidelines.com | 按类别和成本组织的全面游戏专用清单 |
| AbleGamers Player Panel | https://ablegamers.org/player-panel/ | 与残障玩家进行用户测试和咨询的服务 |
| Xbox Accessibility Guidelines (XAG) | https://docs.microsoft.com/gaming/accessibility/guidelines | Xbox 认证的必读材料；结构良好的功能清单 |
| PlayStation Accessibility Guidelines | https://www.playstation.com/en-us/accessibility/ | Sony 平台要求；也包含写得不错的设计指引 |
| Colour Blindness Simulator (Coblis) | https://www.color-blindness.com/coblis-color-blindness-simulator/ | 免费工具，可在截图上模拟色盲模式 |
| Accessible Games Database | https://accessible.games | 无障碍游戏设计决策的研究与案例 |
| CVAA (21st Century Communications and Video Accessibility Act) | https://www.fcc.gov/consumers/guides/21st-century-communications-and-video-accessibility-act-cvaa | 美国对含通信功能（语音聊天、消息）游戏的法律要求 |

---

## Open Questions

[To be designed]

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [添加问题] | [Owner] | [Deadline] | [Resolution] |
