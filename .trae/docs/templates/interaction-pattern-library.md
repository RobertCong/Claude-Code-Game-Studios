# Interaction Pattern Library

> 编写指引：.trae/docs/templates/guidance/interaction-pattern-library-guide.md（编写时按章节加载——不要整体通读）。

> **Status**: [In Design | Stable | Under Revision]
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Version**: [1.0]
> **Engine**: [Godot 4.7 / Unity 6 / Unreal Engine 5]
> **UI Framework**: [Godot Control nodes / Unity UI Toolkit / Unreal UMG]
> **Related Documents**:
> - `design/art/art-bible.md` — 视觉标准（颜色、字体排印、图标体系）
> - `design/accessibility-requirements.md` — 每个功能的无障碍承诺
> - `design/ux/[screen].md` — 引用各模式的单屏规格
>
> **Template**: Interaction Pattern Library

> **Why this document exists**: 每个 UI 界面规格都应该能够直接说
> "使用 Button (Primary) 模式"，而不必从头重新规定悬停状态、
> 按下动画、焦点行为、键盘处理和屏幕阅读器
> 播报。本库是可复用交互行为的唯一事实来源。
> 当界面规格引用某个模式名称时，程序员到这里查阅。
> 当行为发生变化时，在这里修改，并适用于所有地方。
>
> 这是一份活文档。模式随新界面的设计而添加——
> 设计新交互前务必先在这里检查。如果需要新模式，
> 在编写第一个使用它的界面规格之前，先添加到这里（或向 ux-designer 提议）。
>
> **Status definitions**:
> - **Draft**: 交互已规定，但尚未实现或验证
> - **Stable**: 已在至少一个已发布的界面中实现、测试并验证
> - **Deprecated**: 正在逐步淘汰——现有用法将被迁移，不要在新界面中使用

---

## Overview

[To be designed]

### How to Use This Library

**If you are designing a screen**: 在发明新交互之前，先浏览下方的 Pattern Catalog Index。
当标准模式适用时，在界面规格中按名称引用它（例如："确认按钮使用 Button (Primary) 模式"）。
当没有现有模式适用时，提议新模式——在引入它的界面规格之前或同时记录在这里。

**If you are implementing a screen**: 当界面规格说"使用 [PatternName] 模式"时，
在本文档中找到它，获取完整规格。实现说明部分包含引擎特定的指引。
无障碍部分包含不可协商的要求。

**If you are reviewing a screen spec**: 验证所有可交互元素都引用了本库中的模式，
或包含自己的完整交互规格。"标准按钮"或"通常的做法"不是有效的引用。

**If you are updating a pattern**: 修改 Stable 模式会影响使用它的每个界面。
修改前，审计所有用法（在界面规格中搜索该模式名称）、确定影响、
获得 ux-designer 的批准，并在任何实现变更之前或同时更新本文档。

---

## Pattern Catalog

[To be designed]

### Pattern Catalog Index

> 每当有新模式加入本文档，就在此添加一行。
> "Used In" 列是用法审计追踪——当新界面采用该模式时更新它。

| Pattern Name | Category | Description | Used In (Screens) | Status |
|-------------|----------|-------------|------------------|--------|
| Button (Primary) | Input | 主行动号召。视觉权重高。每屏至多一个。 | [主菜单、暂停菜单、设置] | Draft |
| Button (Secondary) | Input | 备选操作或取消。视觉权重低于 Primary。 | [所有模态对话框、设置界面] | Draft |
| Button (Destructive) | Input | 不可逆操作。执行前需要确认。 | [删除存档、重置设置] | Draft |
| Toggle | Input | 二元开/关状态选择。 | [无障碍设置、音频设置] | Draft |
| Slider | Input | 连续值选择。 | [音量控制、亮度、文本大小] | Draft |
| Dropdown / Select | Input | 从离散选项列表中选择。 | [分辨率、语言、按键绑定] | Draft |
| List Item | Layout / Input | 垂直可滚动列表中的可选行。 | [成就、任务日志、设置列表] | Draft |
| Grid Item | Layout / Input | 二维网格中的可选单元格。 | [物品栏、技能选择、物品商店] | Draft |
| Modal Dialog | Feedback / Layout | 需要玩家明确决策的阻塞式覆盖层。 | [确认对话框、错误提示] | Draft |
| Confirmation Dialog | Feedback / Layout | 用于破坏性操作确认的专用模态框。 | [删除存档、离开对局、重置] | Draft |
| Toast / Notification | Feedback | 屏幕角落的非阻塞临时消息。 | [成就解锁、自动保存通知] | Draft |
| Tooltip | Feedback | 悬停或聚焦时的上下文信息。 | [物品栏物品、技能描述、设置] | Draft |
| Progress Bar | Feedback / Layout | 线性进度指示器。 | [加载界面、经验条、任务进度] | Draft |
| Input Field | Input | 文本输入控件。 | [玩家名称、搜索、按键绑定录入] | Draft |
| Tab Bar | Navigation | 单屏内的选项卡式分区导航。 | [角色面板、设置、制作] | Draft |
| Scroll Container | Layout | 带可见滚动指示器的可滚动内容区域。 | [物品栏、背景故事条目、制作人员名单] | Draft |
| Inventory Slot | Game-Specific | 物品栏网格中的物品容器（空、已填充、已装备、锁定）。 | [物品栏界面、装备界面] | Draft |
| Ability / Skill Icon | Game-Specific | 带冷却、充能和锁定状态的技能按钮。 | [HUD 技能栏、技能树] | Draft |
| Health / Resource Bar | Game-Specific | 带阈值状态和受击闪烁的数值条。 | [HUD] | Draft |
| Minimap | Game-Specific | 带玩家标记和兴趣点的概览地图。 | [HUD] | Draft |
| Quest / Objective Tracker | Game-Specific | 显示距离与完成状态的活动目标。 | [HUD] | Draft |
| Dialogue Box | Game-Specific | 带说话人识别的 NPC 对话 UI。 | [所有对话序列] | Draft |
| Context Action Prompt | Game-Specific | 可交互物体旁的上下文"按 X 以 [操作]"提示。 | [世界交互] | Draft |
| Damage Number | Game-Specific | 浮动战斗反馈数字。 | [战斗 HUD] | Draft |
| Status Effect Icon | Game-Specific | 带持续时间的增益/减益指示器。 | [HUD 状态栏、敌人生命显示] | Draft |
| Notification Banner | Game-Specific | 成就、升级、获得物品通知。 | [全局覆盖层] | Draft |
| Screen Push | Navigation | 带方向动画的前进导航。 | [所有菜单导航] | Draft |
| Screen Pop (Back) | Navigation | 带反向动画的返回导航。 | [所有菜单导航] | Draft |
| Screen Replace | Navigation | 替换当前界面而不堆叠历史。 | [主菜单到加载界面] | Draft |
| Modal Open / Close | Navigation | 使背景界面变暗的覆盖层。 | [所有模态对话框] | Draft |
| Tab Switch | Navigation | 同一界面内选项卡之间的内容切换。 | [所有选项卡式界面] | Draft |
| Focus Management | Navigation | 界面打开、关闭或变化时焦点去向的规则。 | [所有界面] | Draft |
| Escape / Cancel | Navigation | 跨平台和输入方式的通用返回行为。 | [所有界面] | Draft |
| Loading State | Feedback | 界面和组件如何表示正在加载。 | [所有加载状态] | Draft |
| Empty State | Feedback | 空列表和空网格如何呈现。 | [空物品栏、无任务、无存档] | Draft |
| Error State | Feedback | 错误如何传达。 | [保存失败、网络错误、无效输入] | Draft |
| Success Confirmation | Feedback | 已完成操作如何确认。 | [设置已保存、物品已制作、任务已交付] | Draft |
| Optimistic UI | Feedback | 在系统确认前先显示假定成功。 | [如果存在在线功能] | Draft |

---

## Patterns

[各模式条目在定义后添加于此]

### Standard Control Patterns

> 本节中每个模式的完整参考规格（带时长/音频值的状态表、无障碍要求、
> 实现说明）位于 `.trae/docs/templates/guidance/interaction-pattern-library-guide-standard-controls.md`——
> 只加载当前正在规定的模式。

---

#### Button (Primary)

**Category**: Input
**Status**: Draft
**When to Use**: [界面上最重要的单一操作——同屏至多可见一个]
**When NOT to Use**: [备选/次要操作；破坏性操作；任何不是界面主要意图的内容]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Default / Hovered / Focused / Pressed / Disabled / Loading] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [键盘、手柄、屏幕阅读器、色盲和触摸目标要求]

**Implementation Notes**: [引擎特定指引]

---

#### Button (Secondary)

**Category**: Input
**Status**: Draft
**When to Use**: [备选或取消操作——视觉权重低于 Primary]
**When NOT to Use**: [破坏性操作；界面上最重要的操作]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [与 Button (Primary) 相同基线；注意对话框中的取消输入映射]

**Implementation Notes**: [引擎特定指引；Primary/Secondary 位置保持一致]

---

#### Button (Destructive)

**Category**: Input
**Status**: Draft
**When to Use**: [会造成玩家数据或进度丢失的不可逆操作]
**When NOT to Use**: [可以撤销或仅有一定后果的操作]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

> **Critical rule**: Button (Destructive) 绝不直接执行其操作。
> 它始终触发 Confirmation Dialog。没有例外。

**Accessibility**: [屏幕阅读器必须播报其破坏性质]

**Implementation Notes**: [引擎特定指引]

---

#### Toggle

**Category**: Input
**Status**: Draft
**When to Use**: [当前状态必须一眼可见的二元开/关设置]
**When NOT to Use**: [多于两个选项；一次性操作；需要解释的选择]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [激活输入、屏幕阅读器开关角色/状态规则、状态标签要求]

**Implementation Notes**: [引擎特定指引；减弱动态效果时的行为]

---

#### Slider

**Category**: Input
**Status**: Draft
**When to Use**: [范围和相对位置重要的连续值选择]
**When NOT to Use**: [精确数值录入；短离散列表；二元状态]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [键盘步进/大步进/最小最大值输入、屏幕阅读器数值播报、数值显示要求]

**Implementation Notes**: [引擎特定指引]

---

#### Dropdown / Select

**Category**: Input
**Status**: Draft
**When to Use**: [从 3-15 个选项的离散列表中选择；静止时只显示当前选择]
**When NOT to Use**: [二元选择；超过约 15 个选项；需要对比选项时]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [列表导航、combobox 角色、展开/收起播报、定位规则]

**Implementation Notes**: [引擎特定指引]

---

#### List Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**: [垂直可滚动列表中的可选行]
**When NOT to Use**: [二维网格；不可选择的内容行]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [State] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [焦点循环规则、listitem 角色与位置播报、最小行高]

**Implementation Notes**: [引擎特定指引；聚焦时滚动到可见区域]

---

#### Grid Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**: [二维网格中的可选单元格]
**When NOT to Use**: [单列内容；不可选择的展示单元格]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Empty / Populated / Hovered / Focused / Selected / Pressed / Locked / Drag source / Drop target] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [网格尺寸与行/列位置播报、键盘可到达的工具提示]

**Implementation Notes**: [引擎特定指引；自定义方向键单元格导航]

---

#### Modal Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: [必须先解决才能继续的决策或确认]
**When NOT to Use**: [非阻塞通知；可以等待的信息；应允许在其后方继续游玩的对话框]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Opening / Active / Dismissing (confirmed) / Dismissing (cancelled) / Cannot dismiss] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

> **Focus trap rule**: 模态对话框打开期间，焦点导航必须只在对话框内循环，
> 关闭时焦点必须返回触发元素。

**Accessibility**: [对话框角色与必需标题、Escape/Enter 映射、减弱动态效果时的覆盖行为]

**Implementation Notes**: [引擎特定指引]

---

#### Confirmation Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: [确认破坏性操作——始终由 Button (Destructive) 触发]
**When NOT to Use**: [非破坏性确认；超过两个操作的对话框]

> **Label rule**: 确认按钮必须标注具体操作，
> 而不是通用的"确定"或"是"。

**Structure**:
- Title: [简短、描述动作]
- Body: [一句话说明后果]
- Confirm button: [Button (Primary)——标注具体操作]
- Cancel button: [Button (Secondary)——"取消"]
- Default focus: [取消——更安全的默认值]

**Accessibility**: [继承 Modal Dialog；alert-dialog 播报；默认焦点必须位于取消]

**Implementation Notes**: [引擎特定指引]

---

#### Toast / Notification

**Category**: Feedback
**Status**: Draft
**When to Use**: [不需要玩家决策的简短非阻塞信息]
**When NOT to Use**: [决策；需要采取行动的错误；玩家绝不能错过的关键信息]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Entering / Displayed / Auto-dismiss / Manual dismiss / Queue overflow] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [无需焦点即可播报、减弱动态效果时的回退、最短自动关闭时间、绝不作为可操作信息的唯一渠道]

**Implementation Notes**: [引擎特定指引；队列管理和层级排序]

---

#### Tooltip

**Category**: Feedback
**Status**: Draft
**When to Use**: [补充可见标签的上下文信息]
**When NOT to Use**: [完成操作所必需的信息；没有悬停的纯触摸平台]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Hidden / Hover trigger / Focus trigger / Appearing / Displayed / Hiding] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [无需悬停即可访问内容、必需的显示延迟、对比度要求]

**Implementation Notes**: [引擎特定指引；屏幕边缘重新定位]

---

#### Progress Bar

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: [朝明确终点的线性进度]
**When NOT to Use**: [径向进度；快速波动的数值；没有终点的数值]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Default / Value increasing / At maximum / At zero / Indeterminate] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [progressbar 角色、数值 + 百分比播报、数值标签要求、减弱动态效果时的覆盖行为]

**Implementation Notes**: [引擎特定指引；不确定模式的实现]

---

#### Input Field

**Category**: Input
**Status**: Draft
**When to Use**: [文本录入——玩家名称、搜索、精确数值、按键绑定捕获]
**When NOT to Use**: [从已知选项中选择；以主机为主且虚拟键盘会增加摩擦的流程]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Default / Hovered / Focused / Typing / Value present / Limit reached / Clear / Validation error / Validated / Disabled] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [标准编辑快捷键、textbox 角色、可见标签要求（占位符不是标签）]

**Implementation Notes**: [引擎特定指引；虚拟键盘处理]

---

#### Tab Bar

**Category**: Navigation
**Status**: Draft
**When to Use**: [将单屏内容划分为离散分区，一次只显示一个——最多 5-6 个选项卡]
**When NOT to Use**: [超过 6 个选项卡；需要同时可见的内容；界面之间的导航]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Inactive / Active / Hovered / Focused / Activated / Shoulder-button switch] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [ARIA tab panel 模式（tab/tablist/tabpanel）、活动选项卡的区分不能只靠颜色]

**Implementation Notes**: [引擎特定指引；肩键快捷切换处理]

---

#### Scroll Container

**Category**: Layout
**Status**: Draft
**When to Use**: [内容超出容器可见区域]
**When NOT to Use**: [更适合分页的内容；没有加载/结束状态的无限滚动]

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| [Content fits / Scrollable / Scrolling / Scrollbar drag / Keyboard scroll / Gamepad scroll / Boundary / Focus follows scroll] | [视觉处理] | [输入触发] | [响应] | [时长 + 缓动] | [声音类别] |

**Accessibility**: [自动滚动以保持聚焦项可见、滚动位置播报、滚动条作为必需指示器]

**Implementation Notes**: [引擎特定指引；焦点变化时确保可见]

---

### Game-Specific UI Patterns

> 本节中每个模式的完整参考规格位于
> `.trae/docs/templates/guidance/interaction-pattern-library-guide-game-specific.md`——
> 只加载当前正在规定的模式。

---

#### Inventory Slot

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [物品栏网格中的每个物品容器——空、已填充、已装备、锁定]

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| [Empty / Populated / Focused / Selected / Drag source / Locked / Highlighted / Cooldown overlay] | [视觉处理] | [行为备注] |

**Accessibility**: [堆叠数量和品质等级的非颜色替代方案；键盘可到达的工具提示；锁定状态播报]

**Implementation Notes**: [引擎特定指引]

---

#### Ability / Skill Icon

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [HUD 技能栏按钮、技能树节点、任何显示可用状态的能力]

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| [Available / On cooldown / Charges remaining / Out of resource / Locked / Active / Just activated] | [视觉处理] | [行为备注] |

**Accessibility**: [冷却/充能信息的数值替代方案；名称和描述暴露给屏幕阅读器]

**Implementation Notes**: [引擎特定指引]

---

#### Health / Resource Bar

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [HUD 中任何持续变化的关键玩家资源]

**States and behaviors**:

| Event | Visual | Audio | Duration |
|-------|--------|-------|---------|
| [Decrease / Increase / Below threshold / At zero / Maximum / Overflow] | [视觉处理] | [声音类别] | [时长] |

**Accessibility**: [数值访问；阈值状态的非颜色备份]

**Implementation Notes**: [引擎特定指引；残影条技术]

---

#### Dialogue Box

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [所有有说话人的对话——NPC 对话、配音叙事、角色讲述的教程文本]

**Structure**: [说话人识别、对话正文、推进提示、可选的跳过/语音/字幕指示器]

**States and behaviors**:

| State | Visual | Input | Response | Duration |
|-------|--------|-------|----------|---------|
| [Line entering / Revealing / Line complete / Advancing / Choices appearing / Closing / Skipping all] | [视觉处理] | [输入触发] | [响应] | [时长] |

**Accessibility**: [字幕默认开启、打字机速度可配置、不自动推进、选项可导航并播报位置]

**Implementation Notes**: [引擎特定指引；对话数据格式]

---

#### Context Action Prompt

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [可交互物体旁指示玩家可以做什么的提示]

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| [Appearing / Idle / Holding / Cannot interact / Disappearing] | [视觉处理] | [行为备注] |

**Accessibility**: [按键图标旁提供文本标签；定位不得与关键 HUD 重叠]

**Implementation Notes**: [引擎特定指引；感知输入方式的图标切换]

---

#### Damage Number

**Category**: Game-Specific
**Status**: Draft
**When to Use**: [战斗参与者上方的浮动反馈数字]

**Variants**:

| Variant | Visual | Notes |
|---------|--------|-------|
| [Normal / Critical / Healing / Miss / Status damage] | [视觉处理] | [行为备注] |

**Behavior**: [浮动轨迹、淡出时机、重叠错位、同时显示的最大数量]

**Accessibility**: [仅作为补充反馈；可禁用；禁用后游戏仍可完整游玩]

**Implementation Notes**: [引擎特定指引；对象池]

---

### Navigation Patterns

> 本节及下一节的完整参考规格位于
> `.trae/docs/templates/guidance/interaction-pattern-library-guide-navigation-feedback.md`——
> 只加载当前正在规定的模式。

---

#### Screen Push / Pop / Replace

**Category**: Navigation
**Status**: Draft

这三个模式定义界面如何进入和退出导航堆栈。

| Pattern | Trigger | Animation | Stack Behavior | Focus Behavior |
|---------|---------|-----------|---------------|----------------|
| [Push / Pop / Replace] | [触发] | [动画] | [堆栈行为] | [焦点行为] |

**Animation durations**: [Push/Pop 与 Replace 的时长 + 缓动]

**Motion reduction**: [回退行为]

**Implementation Notes**: [引擎特定指引；界面堆栈管理器与返回焦点存储]

---

#### Focus Management

**Category**: Navigation
**Status**: Draft

> 焦点管理是游戏 UI 中最常见的键盘和手柄无障碍失败点。
> 这些规则必须一致地实现。

| Rule | Description |
|------|-------------|
| [Screen open / close, modal open / close, element disabled / destroyed, Tab order, D-pad spatial navigation, focus visibility] | [规则描述] |

---

#### Escape / Cancel

**Category**: Navigation
**Status**: Draft

> "返回"操作是所有菜单系统中使用最多的导航输入。
> 它必须在每个界面中保持一致，没有例外。

| Platform | Input | Behavior |
|----------|-------|---------|
| [Platform] | [Input] | [Behavior] |

**Rules**: [永远不要覆盖"返回/取消"；每个界面都在其 UX 规格中明确定义 Escape 行为]

---

### Feedback and Loading Patterns

---

#### Loading State

**Category**: Feedback
**Status**: Draft

| Scope | Pattern | Notes |
|-------|---------|-------|
| [Full screen (initial) / Full screen (transition) / Component inline / Background async] | [Pattern] | [Notes] |

**Accessibility**: [屏幕阅读器播报加载中/加载完成；加载界面可导航]

---

#### Empty State

**Category**: Feedback
**Status**: Draft

> 每个空列表和空网格都必须有设计好的空状态。空状态
> 不是错误——它是起点。

| Location | Empty State Content | Notes |
|----------|--------------------|----|
| [Location] | [图标 + 消息 + 子消息或操作] | [Notes] |

**Rule**: 每个空状态都必须包含图标、消息，以及子消息或操作按钮之一。

---

#### Error State

**Category**: Feedback
**Status**: Draft

| Error Type | Pattern | Tone |
|-----------|---------|------|
| [Input validation / Operation failed / System error / Soft error] | [Pattern] | [语气指引] |

**Principle**: 错误消息永远不是玩家的错。它们告诉玩家发生了什么以及接下来该怎么做。

---

## Animation Standards

> 这些时长值适用于本库中的所有模式。当某个模式说
> "150ms ease-out"时，缓动函数在这里定义。时长的一致性
> 让 UI 感觉像一套统一设计的系统，而不是一堆
> 各自为政的决定。

| Animation Type | Duration (ms) | Easing Function | Notes |
|---------------|--------------|----------------|-------|
| Button hover / focus enter | 80 | ease-out | 快——灵敏，不拖沓 |
| Button hover / focus exit | 60 | ease-in | 退出略快于进入 |
| Button press scale down | 60 | ease-in | 即时反馈 |
| Button press scale up (release) | 80 | ease-out | 略带弹性的感觉 |
| Screen push (enter) | 250 | ease-in-out | 界面从右侧滑入 |
| Screen pop (exit) | 250 | ease-in-out | 界面向右侧滑出 |
| Modal open | 200 | ease-out | 从中心展开 |
| Modal close | 150 | ease-in | 收起速度快于打开 |
| Toast enter | 200 | ease-out | 从屏幕边缘滑入 |
| Toast exit | 200 | ease-in | |
| Tab switch | 150 | ease-in-out | 内容交叉淡入或滑动 |
| Tooltip appear | 120 | ease-out | 延迟 300-400ms 后出现 |
| Tooltip disappear | 80 | ease-in | |
| Progress bar fill | 300 | ease-out | 数值变化平滑动画 |
| Value flash (damage, gain) | 100ms on + 100ms off | linear | 短暂、吸引注意 |
| Dialogue text reveal (per character) | 30ms per character | linear | 可在无障碍设置中配置 |
| HUD damage flash | 80 | linear | 白色或红色覆盖，即时 |

**Motion reduction overrides**: 启用减弱动态效果模式时（见 accessibility-requirements.md），所有滑动和缩放动画都替换为淡入淡出。淡入淡出时长减少 50%。循环动画（不确定进度旋转器、脉冲指示器）替换为静态等效物。

---

## Sound Standards

> 每个交互事件都应有音频反馈。声音是主要反馈
> 渠道，而不是装饰。这里定义的声音是事件类别——
> 具体音频资源在 `design/audio/sound-bible.md` 中定义（或
> `design/gdd/sound-bible.md`，早期版本放在那里）。此表将
> 交互事件映射到声音类别，使声音设计师和 UI 程序员
> 使用同一套词汇。

| Interaction Event | Sound Category | Notes |
|------------------|---------------|-------|
| Button hover / focus | UI Hover | 细微、短促（< 80ms），在快速导航时不令人疲劳。Hades 使用非常安静的高频咔哒声，在快速导航时融入背景。 |
| Button (Primary) confirm | UI Confirm — Primary | 比次要确认略更突出。"对，开始吧"的声音。 |
| Button (Secondary) cancel / back | UI Cancel | 音高略微下行。"返回"的声音。Mass Effect 使用干净、独特的嗖声表示返回导航。 |
| Button (Destructive) — opening confirmation | UI Warning | 与标准确认不同。简短、吸引注意的声音。 |
| Confirmation dialog — confirm destructive | UI Confirm — Destructive | 终局感，略带分量。操作正在被执行。 |
| Toggle ON | UI Toggle On | 简短、灵敏、略明亮。Celeste 的无障碍开关有令人满足的开启咔哒声。 |
| Toggle OFF | UI Toggle Off | 同一咔哒声系，略平淡。 |
| Slider adjust | UI Slider | 拖动时细微的连续声音。方向键每步一次咔哒。绝不令人疲劳。 |
| Dropdown open | UI Expand | 简短、有方向感（展开的感觉）。 |
| Dropdown close / select | UI Select | 确认感。 |
| Tab switch | UI Tab | 水平移动感。与垂直导航区分。 |
| Modal open | UI Modal Open | 比标准导航更突出——吸引注意。 |
| Modal close (cancel) | UI Modal Close | 返回上一上下文。 |
| Toast — informational | UI Notification | 背景级，不打扰。 |
| Toast — achievement | UI Achievement | 庆祝感但不过长。玩家应感到被奖励，而不是被打断。 |
| Toast — warning | UI Warning — Toast | 与错误区分。警觉，但不惊恐。 |
| Error state | UI Error | 友好但清晰。不是刺耳的蜂鸣器。Dark Souls 对失败操作使用细微的沉闷撞击声——传达"不行"，但不刺耳。 |
| Success confirmation | UI Success | 干净且令人满足。 |
| Ability activate | Gameplay — Ability Activate | 世界内的感觉，与纯 UI 区分。属于游戏手感，而非菜单手感。 |
| Damage received | Gameplay — Damage | 完整规格见 sound-bible.md。 |
| Item pickup | Gameplay — Item Acquire | 简短、有奖励感。 |
| Level up / rank up | Gameplay — Progression | 庆祝感，突出程度恰当。 |
| Dialogue advance | UI Dialogue | 细微，若打字机效果启用则与之节奏匹配。 |

---

## Gaps & Patterns Needed

[To be designed]

---

## Open Questions

[To be designed]

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [引擎的无障碍节点系统是否支持在不需要焦点的情况下为 toast 通知提供屏幕阅读器播报？对照 engine-reference/godot/ 验证 Godot 4.7。] | [ux-designer] | [首个菜单实现之前] | [Unresolved] |
| [Nintendo Switch 版本在平台上正确的确认/取消按键映射是什么？任天堂第一方惯例与 Xbox/PlayStation 不同。] | [producer] | [平台认证提交之前] | [Unresolved] |
| [伤害数字应作为 Label3D 节点池化，还是在 SubViewport 中渲染？与技术总监协调验证性能预算。] | [lead-programmer, ux-designer] | [战斗 HUD 实现之前] | [Unresolved] |
| [同时显示的 toast 通知数量达到多少时，队列会在视觉上变得不堪重负？需要试玩测试。] | [ux-designer] | [首次试玩测试会话] | [Unresolved] |
| [添加问题] | [Owner] | [Deadline] | [Resolution] |
