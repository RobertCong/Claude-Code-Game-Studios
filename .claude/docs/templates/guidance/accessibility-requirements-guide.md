> accessibility-requirements.md 的编写指导。只加载当前正在编写的部分所对应的内容——不要一次读整个文件。

# Accessibility Requirements Template — Authoring Guidance

指导按模板小节组织。在编写项目无障碍需求文档的某个小节时，只阅读下方该小节的
指导。功能表格本身（Visual / Motor / Cognitive / Auditory）、平台 API 表、测试计划
与外部资源仍保留在模板中——它们属于需求目录，而不是指导。

---

## Accessibility Tier Definition

> **为什么要定义分级**：无障碍不是二元的。定义四个等级能为团队提供共同的
> 词汇，迫使团队在制作初期做出明确承诺，并防止两个方向上的范围蔓延
> （"我们以后再加"和"我们必须支持一切"）。下面的等级是本项目的定义——
> 业界使用的说法相似但不完全相同。请承诺一个带有具体功能目标的等级，
> 而不只是等级名称。

**Authoring the commitment rationale**：

[写出 3-5 句话说明选择该等级的理由。不要只陈述等级——要解释推理过程。
考虑：游戏的类型是什么，它如何映射到常见的无障碍障碍（例如快节奏游戏有
运动障碍；阅读量大的游戏有视觉障碍）？目标玩家是谁，研究对该群体中残障
发生率的结论是什么？平台要求是什么（Xbox 要求 ID@Xbox 项目符合 XAG）？
团队的产能如何？降低一个等级会让玩家群体付出什么具体代价？

示例："这是一款面向 25-45 岁玩家的回合制叙事 RPG。回合制结构消除了动作游戏
中最严重的运动障碍，但阅读量大的设计造成了显著的视觉与认知障碍。Standard
等级覆盖了所有这些。没有专职的无障碍工程师就无法达成 Exemplary 等级。Xbox
ID@Xbox 项目要求符合 XAG 才能进入 Game Pass 考虑范围，Standard 等级满足这一点。
降到 Basic 会将依赖色盲模式或输入重映射的玩家排除在外，根据 AbleGamers 的数据，
这约占目标受众的 8-12%。"]

**Example in-scope / out-of-scope entries**：

明确纳入范围的功能（超出等级基线）：
- [例如："完整字幕自定义——从 Comprehensive 提升而来，因为我们的游戏对白密集，
  字幕是主要渠道"]
- [例如："手柄单手模式——我们有对战斗至关重要的长按输入"]

明确排除范围的功能：
- [例如："游戏世界（非菜单）的屏幕阅读器——需要超出当前产能的引擎改造。
  记录在 Known Intentional Limitations 中。"]

---

## Visual Accessibility

> **为什么这一节放在最前**：视觉障碍影响的是使用无障碍功能的玩家中最大的
> 群体。仅色觉缺陷就影响约 8% 的男性和 0.5% 的女性。在电视观看距离下的
> 文字可读性，常常是已发行游戏中最严重的单一无障碍失败。在实现开始前就
> 记录每一项视觉功能，因为在资源锁定之后再补做最小字号或颜色决策代价高昂。

**Worked example rows — Color-as-Only-Indicator Audit**：

| Location | Color Signal | What It Communicates | Non-Color Backup | Status |
|----------|-------------|---------------------|-----------------|--------|
| [Health bar] | [Red = low health] | [Player is near death] | [Bar also shows numeric value and flashes] | [Not Started] |
| [Minimap markers] | [Red = enemy, green = ally] | [Unit allegiance] | [Enemy markers are triangles; ally markers are circles] | [Not Started] |
| [Inventory item rarity] | [Color-coded border (grey/blue/purple/gold)] | [Item quality tier] | [Rarity name shown on hover/focus; icon star count] | [Not Started] |

---

## Motor Accessibility

> **为什么运动无障碍对游戏至关重要**：游戏比大多数软件对运动能力的要求更高。
> 一个网页表单需要精确点击；一款游戏可能要求快速同时按下多个按键组合并保持
> 特定时长。运动障碍的范围很广——从震颤（影响精确度）到偏瘫（只有一只手可用）
> 到重复性劳损（RSI，影响按住时长）。AbleGamers 的 Able Assistance 项目估计
> 美国有 3500 万玩家的残障会影响其游玩能力。如果在初期就规划，下面许多功能的
> 实现成本很低；而在上线后再添加则极其昂贵。

---

## Cognitive Accessibility

> **为什么认知无障碍常常规格不足**：认知无障碍影响患有多动症（ADHD）、
> 阅读障碍、自闭症谱系状况、获得性脑损伤与焦虑障碍的玩家——合计人群比许多
> 工作室意识到的更大。它同样有益于所有玩家在高压时刻的体验。最常见的失败是：
> 任何地方都不能暂停、教程信息只能看一次、系统要求同时追踪过多状态。Hades 和
> Celeste 等游戏已经证明，认知辅助选项（上帝模式、持续提示、延长文本显示时间）
> 不会损害不使用它们的玩家的体验。

---

## Auditory Accessibility

> **为什么即使对没有听力损失的玩家，听觉无障碍也很重要**：7% 的玩家是聋人或
> 听力不佳者。此外，很大一部分玩家经常在音频被降低或缺失的环境中游玩（通勤、
> 与他人共用住所、婴儿睡觉）。任何仅通过音频传达的玩法关键信息，即使不考虑
> 无障碍问题，也已经是设计失败。指导原则是：每一个会改变玩家下一步该做什么的
> 声音，都必须有视觉上的等效信息。

**Worked example rows — Gameplay-Critical SFX Audit**：

| Sound Effect | What It Communicates | Visual Backup | Caption Required | Status |
|-------------|---------------------|--------------|-----------------|--------|
| [Enemy attack windup sound] | [Incoming damage — player should dodge] | [Enemy animation telegraph visible from all camera angles] | [No — visual is sufficient] | [Not Started] |
| [Trap trigger click] | [Trap is about to fire] | [Not always visible depending on camera angle] | [Yes — "[CLICK]" caption with directional indicator] | [Not Started] |
| [Low health heartbeat] | [Player health critical] | [Health bar also shows critical state visually] | [No — visual is sufficient] | [Not Started] |
| [Quest completion chime] | [Objective completed] | [Quest tracker updates visually] | [No — visual is sufficient] | [Not Started] |

---

## Platform Accessibility API Integration

> **为什么需要这一节**：每个平台都提供原生无障碍 API，使用它们可以让操作系统级
> 功能（系统屏幕阅读器、显示辅助、运动无障碍服务）与你的游戏协同工作。忽视这些
> API 不会让游戏出问题，但意味着依赖操作系统级无障碍工具的玩家在游戏中无法从中
> 受益。Xbox 尤其要求符合 XAG 才能通过认证。在承诺某个等级之前先核实平台要求——
> 平台要求设定的是下限，而不是上限。

---

## Per-Feature Accessibility Matrix

> **为什么需要这张矩阵**：无障碍不是一组设置项——它是每个游戏系统的一种属性。
> 这张矩阵建立了游戏的"无障碍影响"视图：哪些系统存在哪些障碍，以及这些障碍是否
> 得到处理。当 systems-index.md 中新增一个系统时，必须在这里新增一行。如果某个
> 系统存在未处理的无障碍关注项，就不能在系统索引中标记为 Approved。

**Worked example rows**：

| System | Visual Concerns | Motor Concerns | Cognitive Concerns | Auditory Concerns | Addressed | Notes |
|--------|----------------|---------------|-------------------|------------------|-----------|-------|
| [Combat System] | [Enemy health bars are color-coded; attack animations may cause motion sickness] | [Rapid input required for combos; hold inputs for guard] | [Track enemy patterns + cooldowns + player resources simultaneously] | [Audio cues for off-screen attacks; critical damage warning sounds] | [Partial] | [Colorblind palette applied; hold-to-block toggle needed] |
| [Inventory / Equipment] | [Item rarity conveyed by border color] | [No motor concerns — turn-based] | [Item stats comparison requires reading multiple values] | [None — no critical audio in this system] | [Partial] | [Non-color rarity indicators in progress] |
| [Dialogue System] | [Subtitle display depends on contrast settings] | [No motor concerns] | [Long dialogue trees with time pressure on dialogue choices] | [All dialogue must be subtitled] | [Not Started] | [Timed dialogue choices must support extended timer option] |
| [Navigation / World Map] | [Map marker colors] | [No motor concerns] | [Quest objective clarity; waypoint visibility] | [Audio pings for objectives have no visual equivalent] | [Not Started] | |

---

## Accessibility Test Plan

> **为什么要把无障碍测试与 QA 分开**：标准 QA 测试功能是否能工作。无障碍测试
> 测试功能对于使用这些功能的玩家是否可用。这是两种不同的测试。字幕系统可以通过
> QA（它显示了文字），却在无障碍测试中失败（低视力玩家在电视距离下无法阅读）。
> 规划三种测试类型：自动化测试（对比度、字号）、内部人工测试（团队成员使用
> 无障碍模拟器模拟障碍）、用户测试（实际使用这些功能的玩家）。

---

## Known Intentional Limitations

> **为什么要记录未包含的内容**：未记录的省略会在认证阶段或社区反馈中变成意外。
> 记录一项限制及其理由，能说明这是有意选择而非疏漏。它还能明确哪些玩家未被服务
> 以及补救措施是什么。这里的每一条都是风险——请诚实评估。

**Worked example rows**：

| Feature | Tier Required | Why Not Included | Risk / Impact | Mitigation |
|---------|--------------|-----------------|--------------|------------|
| [Screen reader support for in-game world (NPCs, objects, environmental text)] | Exemplary | Engine (Godot 4.7) AccessKit integration covers menus only; extending to the game world requires a custom spatial audio description system beyond current scope | Affects blind and low-vision players who can navigate menus but cannot independently explore the game world | Ensure all critical world information is duplicated in accessible menu systems (quest log, map); evaluate for post-launch DLC |
| [Full subtitle customization (font/color/background)] | Comprehensive | Scope reduction — targeting Standard tier. Custom font rendering in Godot requires additional asset pipeline work | Affects deaf and hard-of-hearing players with specific legibility needs; particularly affects players with dyslexia who use custom fonts | Provide two preset subtitle styles (default and high-readability) as a partial mitigation; log for post-launch update |
| [Tactile/haptic alternatives for all audio cues] | Exemplary | Platform rumble API integration for non-Xbox platforms is out of scope for v1.0 | Affects deaf players relying on haptic feedback; PC players with non-Xbox controllers get no haptic response | Xbox controller haptic integration is in scope; evaluate PlayStation DualSense haptic API for a post-launch patch |

---

## Audit History

> **为什么要追踪审计历史**：无障碍不是认证一次就完事的。平台要求会变化。
> 新功能可能引入新障碍。法律标准会演进。审计历史可以体现尽职调查，并帮助
> 识别两次审计之间的回归。

**Worked example rows**：

| Date | Auditor | Type | Scope | Findings Summary | Status |
|------|---------|------|-------|-----------------|--------|
| [Date] | [Internal — ux-designer] | Internal review | [Pre-submission checklist against committed tier] | [e.g., "12 items verified, 3 open issues: subtitle contrast below target in 2 scenes, color-only indicator on minimap not resolved"] | [In Progress] |
| [Date] | [External — AbleGamers Player Panel] | User testing | [Motor accessibility — one-hand mode and timing adjustments] | [e.g., "Toggle modes functional. Timed QTE window at 3x still failed for one participant — recommend 5x option."] | [Findings addressed] |

---

## Open Questions

**Worked example questions**：

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [Does Godot 4.7 AccessKit support dynamic accessibility node updates for HUD elements, or only static menus?] | [ux-designer] | [Before Technical Setup gate] | [Unresolved — check engine-reference/godot/ docs] |
| [What is the Xbox ID@Xbox minimum XAG compliance requirement for our release window?] | [producer] | [Before Pre-Production gate] | [Unresolved] |
| [Will the dialogue system support timed choice extensions without a full architecture change?] | [lead-programmer] | [During Technical Design] | [Unresolved] |
