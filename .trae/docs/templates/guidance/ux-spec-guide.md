> ux-spec.md 的撰写指导。只加载当前正在撰写的章节所对应的部分——不要一次性加载整个文件。

# UX Specification Template — Authoring Guidance

指导内容按模板章节编号组织。撰写项目 UX 规格的某个章节时，只阅读下面该章节的指导。

---

## Section 1 — Purpose & Player Need

> **Why this section exists**: 每个屏幕都必须从玩家视角证明其存在的理由。从开发者视角设计的屏幕（“显示存档数据”）会产生杂乱、令人困惑的界面。从玩家视角设计的屏幕（“让玩家在放下手柄之前确信自己的进度是安全的”）会产生有目的、平静的界面。在触碰任何布局决策之前先写这一节——它是评估后续每一个选择的过滤器。

**Authoring the player need**:

[一段话。说出真实的人类需求，而不是系统功能。考虑：玩家打开这个屏幕时会说自己想要什么？如果它不能正常工作，什么会让他们沮丧？那种沮丧描述的就是需求。

示例——差：“显示玩家当前的物品和装备。”
示例——好：“让玩家理解自己携带了什么，并快速决定带什么进入下一次遭遇，同时不破坏他们对游戏世界的心智模型。物品栏是玩家在动作时刻之间的规划工具。”]

**Authoring the player goal**:

[一句话。足够具体，以至于你能为它写出验收标准。
示例：“在三次按键内找到他们要找的物品，并在不导航到单独屏幕的情况下装备它。”]

**Authoring the game goal**:

[一句话。这是系统需要从这次交互中得到的东西。示例：“记录玩家的装备选择，并在下一次遭遇加载之前将其传递给战斗系统。”这一节可以防止那些看起来不错、却无法服务于其所处系统的 UI。]

---

## Section 2 — Player Context on Arrival

> **Why this section exists**: 屏幕不是孤立存在的。在战斗中途打开物品栏的玩家，与清空地牢后打开它的玩家，处于完全不同的认知和情绪状态。同样的信息架构在一种情境下可能显得压抑般复杂，在另一种情境下却显得简单幼稚。记录情境，使设计决策——先显示什么、隐藏什么、对什么做动画、简化什么——都校准到真正来到这个屏幕的玩家，而不是一个抽象用户。

**Worked example answers for the context table**:

| Question | Answer |
|----------|--------|
| What was the player just doing? | [例如：刚完成一场战斗遭遇 / 从探索中按下 Esc / 触发了剧情过场] |
| What is their emotional state? | [例如：高度紧张——刚刚死里逃生 / 平静——在目标之间探索] |
| What cognitive load are they carrying? | [例如：高——正在主动追踪敌人位置 / 低——没有主动威胁] |
| What information do they already have? | [例如：他们知道自己刚捡到一件物品，但还没看到它的属性] |
| What are they most likely trying to do? | [例如：查看新物品是否比当前武器更好——主要使用场景] |
| What are they likely afraid of? | [例如：错过什么、犯下不可逆的错误、忘记自己刚才在哪] |

**Authoring the emotional design target**:

[一句话，描述玩家在使用这个屏幕时应有的感受。
示例：“自信且掌控——玩家应感觉自己拥有完整的信息，并对自己的选择拥有完全的权威，结果没有任何模糊之处。”]

---

## Section 3 — Navigation Position

> **Why this section exists**: 一个不知道自己在导航层级中处于何处的屏幕，就无法定义它的进入/退出过渡、返回按钮行为，或它与游戏暂停状态的关系。导航位置也能尽早暴露架构问题——如果这个屏幕可以从八个不同位置到达，那就是一个复杂度警示，应在设计中解决，而不是留到实现阶段。

**Worked example — reachability table**:

| Entry Point | Triggered By | Notes |
|-------------|-------------|-------|
| [例如：主菜单 → Play] | [玩家选择 "New Game"] | [主要入口] |
| [例如：暂停菜单 → Resume] | [玩家在任意玩法状态下按 Start] | [次要入口] |
| [例如：游戏事件] | [教程系统仅在首次时强制打开] | [系统入口——玩家关闭时不得报错] |

---

## Section 4 — Entry & Exit Points

> **Why this section exists**: 进入和退出定义了屏幕与导航系统其余部分的契约。每个入口都必须有对应的出口。未定义的过渡会变成缺陷——玩家发现自己卡住，或者游戏状态变得不一致。在实现开始之前完整填写这张表。空单元格是设计工作尚未完成的信号。

**Worked example — entry table**:

| Trigger | Source Screen / State | Transition Type | Data Passed In | Notes |
|---------|----------------------|-----------------|----------------|-------|
| [例如：玩家按下物品栏按钮] | [玩法 / 探索状态] | [叠加层推入——游戏暂停] | [当前玩家装备配置、物品栏内容] | [可在任何非战斗状态使用] |
| [例如：接受物品拾取提示] | [玩法 / 物品拾取对话框] | [用完整物品栏替换对话框] | [新获得的物品预高亮] | [打开时应对新物品做视觉区分] |
| [例如：任务系统引导玩家前往物品栏] | [玩法 / 任务更新通知] | [叠加层推入] | [用于高亮的任务相关物品 ID] | [屏幕应深链到相关物品] |

**Worked example — exit table**:

| Exit Action | Destination | Transition Type | Data Returned / Saved | Notes |
|-------------|------------|-----------------|----------------------|-------|
| [例如：玩家关闭物品栏（Back/B/Esc）] | [上一状态——探索] | [叠加层弹出——游戏继续] | [提交更新后的装备配置] | [必须在过渡开始前提交更改] |
| [例如：玩家在物品上选择 "Equip"] | [同一屏幕，更新后的状态] | [原地状态变化] | [触发装备变更事件] | [不导航，只刷新状态] |
| [例如：玩家从物品栏快捷键导航到地图] | [地图屏幕] | [替换] | [无数据] | [玩家返回时会保留物品栏状态] |

---

## Section 5 — Layout Specification

> **Why this section exists**: 布局规格是 UX 设计与 UI 程序之间的交接产出物。它不需要像素级精确——它需要传达层级（什么是重要的）、邻近关系（什么属于一起）和比例（什么大什么小）。ASCII 线框图无需设计软件即可实现这一点。阅读这一节的程序员应能在不猜测的情况下构建正确的结构。阅读它的美术应知道视觉重量应集中在哪里。
>
> 以一种标准分辨率绘制布局（例如 1920x1080）。另外单独说明其他分辨率的适配。

**Worked example — wireframe (5.1)**:

```
Example:
┌──────────────────────────────────────────────┐
│  [← Back]        INVENTORY         [Options] │  ← HEADER ZONE
├──────────────────────────────────────────────┤
│ ┌──────────────┐  ┌─────────────────────────┐│
│ │ CATEGORY NAV │  │  ITEM DETAIL PANEL      ││  ← CONTENT ZONE
│ │  ● Weapons   │  │  Item Name              ││
│ │    Armor     │  │  {item icon}            ││
│ │    Consumable│  │  Stats comparison       ││
│ │    Key Items │  │  Description text...    ││
│ ├──────────────┤  └─────────────────────────┘│
│ │ ITEM GRID    │                             │
│ │ {□}{□}{□}{□} │                             │
│ │ {□}{□}{□}{□} │                             │
│ │ ...          │                             │
│ └──────────────┘                             │
├──────────────────────────────────────────────┤
│   [Equip]     [Drop]     [Compare]  [Close]  │  ← ACTION BAR
└──────────────────────────────────────────────┘
```

**Worked example — layout zones table (5.2)**:

| Zone Name | Description | Approximate Size | Scrollable? | Overflow Behavior |
|-----------|-------------|-----------------|-------------|-------------------|
| [例如：页眉区] | [顶部栏：导航、屏幕标题、全局操作] | [全宽，约 10% 高度] | [否] | [用省略号截断过长的屏幕名称] |
| [例如：分类导航] | [左侧面板：物品分类标签页] | [约 25% 宽度，约 75% 高度] | [是——分类超出面板时垂直滚动] | [列表底部出现滚动指示器] |
| [例如：物品网格] | [中部：所选分类的物品图标网格] | [约 45% 宽度，约 75% 高度] | [是——垂直滚动] | [基于分页：4x4 网格，溢出时进入下一页] |
| [例如：详情面板] | [右侧：所选物品的属性和描述] | [约 30% 宽度，约 75% 高度] | [是——长描述时垂直滚动] | [底部淡出，滚动显露] |
| [例如：操作栏] | [底部：所选物品的情境相关操作] | [全宽，约 15% 高度] | [否] | [低于 4 个操作时折叠为仅图标] |

**Worked example — component inventory table (5.3)**:

| Component Name | Type | Zone | Purpose | Required? | Reuses Existing Component? |
|----------------|------|------|---------|-----------|---------------------------|
| [例如：返回按钮] | [Button] | [页眉] | [返回上一屏幕] | [是] | [是——标准 NavButton 组件] |
| [例如：屏幕标题标签] | [Text] | [页眉] | [显示 "INVENTORY" 或情境名称] | [是] | [是——ScreenTitle 组件] |
| [例如：分类标签页] | [Toggle Button] | [分类导航] | [按分类筛选物品网格] | [是] | [否——需要新组件] |
| [例如：物品槽位] | [Icon + Frame] | [物品网格] | [表示一个物品栏槽位，空或已填充] | [是] | [否——新组件] |
| [例如：物品名称标签] | [Text] | [详情面板] | [显示所选物品的名称] | [是] | [是——BodyText 组件] |
| [例如：属性对比行] | [Compound — label + value + delta] | [详情面板] | [显示属性值与当前装备的对比] | [是] | [否——新组件] |
| [例如：装备按钮] | [Primary Button] | [操作栏] | [将所选物品装备到合适的槽位] | [是] | [是——PrimaryAction 组件] |
| [例如：空状态消息] | [Text + Icon] | [物品网格] | [分类中没有物品时显示] | [是] | [是——EmptyState 组件] |

**Worked example — primary focus element on open**: [例如：物品网格中的第一个物品——或者，如果是深链进入，则是高亮的物品。如果网格为空，焦点落在第一个分类标签页上。]

---

## Section 6 — States & Variants

> **Why this section exists**: 屏幕不是一张静态图片——它是一组状态，每个状态都必须在视觉上正确、在行为上正确。只在“顺利路径”状态下设计的屏幕，发布时会带来损坏的空状态、不可见的加载指示器，以及数据缺失时的崩溃。在实现之前记录每个状态。状态表也是 QA 的测试矩阵。

**Worked example table**:

| State Name | Trigger | What Changes Visually | What Changes Behaviorally | Notes |
|------------|---------|----------------------|--------------------------|-------|
| [加载中] | [屏幕正在打开，数据尚不可用] | [物品网格显示骨架/微光占位符；操作栏按钮禁用] | [除关闭外无法进行任何交互] | [正常情况下不应可见超过 500ms；若超过，调查数据获取性能] |
| [空——分类中无物品] | [玩家切换到一个零物品的分类] | [物品网格替换为 EmptyState 组件：图标 + "Nothing here yet."] | [操作栏不显示物品操作；Drop/Equip/Compare 全部隐藏] | [不要显示禁用按钮——移除它们。没有工具提示的禁用按钮会让人困惑。] |
| [已填充——有物品] | [分类中至少有一个物品] | [物品网格填满物品槽位；第一个槽位自动聚焦] | [所选物品的所有物品操作可用] | [默认且最常见状态] |
| [物品已选中] | [玩家导航到一个物品槽位] | [详情面板填充；所选槽位有聚焦环；操作栏更新为该物品的有效操作] | [根据物品类型启用 Equip/Drop/Compare] | [若物品已装备，则 Equip 禁用——改为显示 "Equipped" 徽章] |
| [等待确认——丢弃] | [玩家选择 Drop 操作] | [确认对话框叠加在屏幕上] | [所有背景交互暂停，直到对话框解决] | [使用模态确认，而非行内切换。物品丢弃后无法恢复。] |
| [错误——数据加载失败] | [无法获取物品栏数据] | [物品网格显示错误状态：图标 + "Couldn't load items." + Retry 按钮] | [仅 Retry 和 Close 可用] | [记录错误；不要向玩家暴露技术细节] |
| [物品新获得] | [从物品拾取深链打开屏幕] | [新获得的物品有 "New" 徽章；详情面板预填充该物品] | [与物品已选中相同，但保留徽章直到玩家导航离开] | [徽章会保留，直到玩家手动从该槽位导航离开一次] |

---

## Section 7 — Interaction Map

> **Why this section exists**: 这一节是每个输入在此屏幕上的作用的唯一事实来源。它迫使设计师推敲每种输入方式（鼠标、键盘、手柄、触控）和每个交互状态（悬停、聚焦、按下、禁用）。这张表中的空白就是等待发生的缺陷。交互图也是无障碍审计的输入——如果某个操作只能通过鼠标到达，它就会在键盘和手柄两列上失败。

**Worked example — navigation inputs (7.1)**:

| Input | Platform | Action | Visual Response | Audio Cue | Notes |
|-------|----------|--------|-----------------|-----------|-------|
| [方向键 / D-Pad] | [全部] | [在活动区域内移动焦点] | [聚焦环移动到相邻元素] | [柔和的导航滴答声] | [在区域边缘循环；不要仅靠方向键跨越区域] |
| [Tab / R1] | [KB / Gamepad] | [将焦点移动到下一个区域（Category → Grid → Detail → Action Bar）] | [聚焦环跳到下一个区域的第一个元素] | [独特的区域切换音] | [Shift+Tab / L1 反向移动] |
| [鼠标悬停] | [PC] | [在可交互元素上显示悬停状态] | [高亮 / 下划线 / 颜色变化] | [无] | [悬停不会移动焦点——只有点击会] |
| [鼠标点击] | [PC] | [选择并聚焦被点击的元素] | [按下状态闪烁，然后选中/聚焦] | [柔和点击声] | [右键打开上下文菜单（若适用）；否则无操作] |
| [触屏轻点] | [移动端] | [用一个手势完成选择和激活] | [按下波纹] | [柔和点击声] | [低风险操作将轻点视为点击 + 确认；破坏性操作需要显式确认] |

**Worked example — action inputs (7.2)**:

| Input | Platform | Context (What must be focused) | Action | Response | Animation | Audio Cue | Notes |
|-------|----------|-------------------------------|--------|----------|-----------|-----------|-------|
| [Enter / A 按钮 / 左键点击] | [全部] | [物品槽位已聚焦] | [选择物品 → 填充详情面板] | [详情面板滑入或原地更新] | [面板淡入/滑入，120ms] | [柔和选择音] | [若物品已选中：无操作] |
| [Enter / A 按钮] | [全部] | [装备按钮已聚焦] | [装备所选物品] | [按钮播放按下动画；物品徽章更新为 "Equipped"；之前装备的物品失去徽章] | [徽章切换，80ms] | [装备成功音效] | [向物品栏系统触发 EquipItem 事件] |
| [三角 / Y 按钮 / 右键] | [全部] | [物品槽位已聚焦] | [打开物品上下文菜单] | [上下文菜单出现在物品槽位旁] | [弹出层，80ms] | [菜单打开音效] | [上下文菜单包含：Equip、Drop、Inspect、Compare] |
| [方块 / X 按钮] | [Gamepad] | [物品槽位已聚焦] | [不打开详情快速装备] | [装备动画在槽位上就地播放] | [槽位闪烁，80ms] | [装备成功音效] | [便捷快捷键；不改变屏幕状态] |
| [Esc / B 按钮 / Back] | [全部] | [任意，屏幕层级] | [关闭屏幕并返回上一状态] | [屏幕退出过渡播放] | [滑出，200ms] | [返回/关闭音] | [关闭前提交所有更改。不丢弃——物品栏不是草稿。] |
| [F / L2] | [KB / Gamepad] | [任意] | [切换筛选面板] | [排序/筛选叠加层打开] | [从右侧滑入，200ms] | [面板打开音] | [若分类中无物品，筛选禁用] |

**Worked example — state-specific behaviors (7.3)**:

| State | Input Restriction | Reason |
|-------|------------------|--------|
| [加载中] | [所有物品和操作输入禁用] | [没有可操作的数据；防止竞态条件] |
| [确认对话框打开] | [仅 Confirm 和 Cancel 输入有效] | [模态——背景被锁定] |
| [错误状态] | [仅 Retry 和 Close 有效] | [没有可导航的数据] |

---

## Section 8 — Data Requirements

> **Why this section exists**: UI 与游戏状态之间的分离是游戏 UI 系统中最重要的架构边界。UI 读取数据，但不拥有数据。UI 触发事件，但不直接写入状态。这一节准确定义此屏幕需要显示哪些数据、数据来自哪里、更新频率如何。在实现之前填写这张表可防止两种常见失败模式：(1) UI 开发者伸手去碰他们不该碰的系统；(2) 系统在 UI 完成一半时才发现自己需要暴露数据。

**Worked example table**:

| Data Element | Source System | Update Frequency | Who Owns It | Format | Null / Missing Handling |
|--------------|--------------|-----------------|-------------|--------|------------------------|
| [例如：物品列表] | [Inventory System] | [屏幕打开时；InventoryChanged 事件时] | [InventorySystem] | [ItemData 结构体数组：id、name、icon_path、category、stats、is_equipped] | [空数组 → 显示空状态。绝不为 null——系统必须返回数组。] |
| [例如：已装备配置] | [Equipment System] | [屏幕打开时；EquipmentChanged 事件时] | [EquipmentSystem] | [Dict，映射 slot_id → item_id] | [未装备槽位的值为 null——UI 显示空槽位图标] |
| [例如：物品属性对比] | [Stats System] | [物品选择变化时] | [StatsSystem] | [Dict，映射 stat_name → {current, new, delta}] | [若未选中物品，详情面板显示占位符。属性系统必须妥善处理这种情况。] |
| [例如：玩家货币] | [Economy System] | [仅在屏幕打开时——物品栏不显示实时货币] | [EconomySystem] | [Int——金币] | [若此游戏模式未启用货币系统，则完全隐藏货币行] |
| [例如：新获得物品标记] | [Inventory System] | [屏幕打开时] | [InventorySystem] | [标记为新物品的 item_ids 数组] | [若为空数组，不显示徽章] |

---

## Section 9 — Events Fired

> **Why this section exists**: 这是 UI/系统边界的另一半。Section 8 定义 UI 读取什么，这一节定义 UI 向游戏回传什么。在设计阶段指定事件，可防止 UI 程序员编写游戏逻辑，也防止游戏程序员被 UI 的行为所意外。每个破坏性或改变状态的玩家操作都必须出现在这张表中。

**Worked example table**:

| Player Action | Event Fired | Payload | Receiver System | Notes |
|---------------|-------------|---------|-----------------|-------|
| [玩家装备一件物品] | [EquipItemRequested] | [{item_id: string, target_slot: string}] | [Equipment System] | [Equipment System 验证操作，成功时触发 EquipmentChanged；UI 监听 EquipmentChanged 以更新显示] |
| [玩家丢弃一件物品] | [DropItemRequested] | [{item_id: string, quantity: int}] | [Inventory System] | [仅在玩家确认丢弃对话框后触发。Inventory System 移除物品并触发 InventoryChanged。] |
| [玩家打开物品对比] | [ItemCompareOpened] | [{item_a_id: string, item_b_id: string}] | [Analytics System] | [不改游戏状态——仅分析事件。对比视图纯属本地 UI 状态。] |
| [玩家关闭屏幕] | [InventoryScreenClosed] | [{session_duration_ms: int}] | [Analytics System] | [每次关闭都会触发，无论原因。用于参与度指标。] |
| [玩家在分类间导航] | [InventoryCategoryChanged] | [{category: string}] | [Analytics System] | [仅分析。不改变游戏状态。] |

---

## Section 10 — Transitions & Animations

> **Why this section exists**: 过渡不是装饰——它们传达层级和因果关系。从右侧滑入的屏幕暗示玩家向前移动了。淡入的屏幕暗示情境中断。不一致的过渡会让导航感觉坏了，即使它在技术上正确。这一节确保过渡被有意指定，而不是留给开发者自行决定，并且无障碍设置（减少动态效果）从一开始就被纳入规划。

**Worked example table**:

| Transition | Trigger | Direction / Type | Duration (ms) | Easing | Interruptible? | Skipped by Reduced Motion? |
|------------|---------|-----------------|--------------|--------|----------------|---------------------------|
| [屏幕进入] | [屏幕被推入栈] | [从右侧滑入] | [250] | [Ease out cubic] | [否——必须在交互启用前完成] | [是——0ms 瞬间出现] |
| [屏幕退出——返回] | [玩家按下 Back] | [向右滑出] | [200] | [Ease in cubic] | [否] | [是——瞬间消失] |
| [屏幕退出——前进] | [玩家导航到子屏幕] | [向左滑出] | [200] | [Ease in cubic] | [否] | [是——瞬间] |
| [详情面板更新] | [玩家选择新物品] | [交叉淡入内容] | [120] | [Linear] | [是——若玩家快速导航，前一个动画取消] | [是——瞬间切换] |
| [加载中 → 已填充] | [加载后数据到达] | [骨架微光淡出，内容淡入] | [180] | [Ease out] | [否] | [是——瞬间显示] |
| [操作栏按钮按下] | [玩家激活按钮] | [按下时缩小到 95%，松开时恢复] | [60 下 / 60 上] | [Ease out / ease in] | [是——若提前松开，恢复正常] | [否——这是触觉反馈，不是装饰性动态效果] |
| [确认对话框打开] | [玩家发起破坏性操作] | [背景变暗至 60% 不透明度；对话框从 95% 放大] | [150] | [Ease out] | [否] | [是——瞬间出现，无缩放] |
| [新物品徽章出现] | [屏幕打开时带有新获得的物品] | [徽章从 0% 弹到 110% 再到 100% 缩放] | [共 200] | [Ease out back] | [否] | [是——在 100% 缩放下瞬间出现] |

---

## Section 11 — Input Method Completeness Checklist

> **Why this section exists**: 输入完整性不是可选项——它是主机平台的认证要求，也是多个市场无障碍法律的风险领域。在把规格标记为 Approved 之前填写此清单。任何未勾选的项目都会阻塞实现开始。

---

## Section 12 — Accessibility

> **Why this section exists**: 无障碍要求必须在设计阶段指定，因为事后改造代价高昂，且往往在架构上不切实际。这一节记录此屏幕专属的要求。项目级标准位于 `design/accessibility-requirements.md`——在填写这一节前查阅它，以免重复或违背项目级承诺。

**Worked example — text contrast table**:

| Text Element | Background Context | Required Ratio | Current Ratio | Pass? |
|--------------|-------------------|---------------|---------------|-------|
| [例如：详情面板中的物品名称] | [深色面板背景 ~#1a1a1a] | [4.5:1（WCAG AA 正文）] | [TBD——实现时验证] | [ ] |
| [例如：分类标签页标签——未激活] | [中灰色标签页背景] | [4.5:1] | [TBD] | [ ] |
| [例如：分类标签页标签——激活] | [强调色背景] | [4.5:1] | [TBD] | [ ] |
| [例如：操作按钮标签] | [按钮颜色（随状态变化）] | [4.5:1] | [TBD] | [ ] |
| [例如：属性对比差值（正值）] | [详情面板] | [4.5:1——不要只依赖绿色] | [TBD] | [ ] |

**Worked example — colorblind mitigations table**:

| Element | Colorblind Risk | Mitigation |
|---------|----------------|------------|
| [例如：属性差值指示器（红/绿表示更差/更好）] | [红绿色盲（Deuteranopia）——最常见的形式] | [除颜色外，添加箭头图标（↑ / ↓）和 +/- 前缀。颜色是冗余指示，而非唯一指示。] |
| [例如：物品稀有度颜色编码（灰/绿/蓝/紫/橙）] | [多种类型——稀有度颜色是行业常见缺陷] | [在图标下方添加稀有度名称文本标签。颜色仅为补充。] |

**Worked example — focus order**:

[例如，
1. 返回按钮（页眉）
2. 选项按钮（页眉）
3. 分类标签页 1——Weapons
4. 分类标签页 2——Armor
5. 分类标签页 3——Consumables
6. 分类标签页 4——Key Items
7. 物品槽位 [0,0]
8. 物品槽位 [0,1] ...（网格从左到右、从上到下遍历）
9. 最后一个物品槽位
10. 装备按钮（操作栏）
11. 丢弃按钮（操作栏）
12. 对比按钮（操作栏）
13. 关闭按钮（操作栏）
→ 循环回到返回按钮

焦点不会进入详情面板——它是由物品焦点驱动的显示面板，不能独立导航。]

**Worked example — screen reader announcements table**:

| State Change | Announcement Text | Announcement Timing |
|--------------|------------------|---------------------|
| [屏幕打开] | ["Inventory screen. [N] items. [Active category] selected."] | [屏幕焦点稳定时] |
| [玩家聚焦物品槽位] | ["[Item name]. [Category]. [Rarity]. [Key stats summary]. [Equipped / Not equipped]."] | [焦点到达时] |
| [玩家装备物品] | ["[Item name] equipped to [slot name]."] | [EquipmentChanged 事件确认后] |
| [玩家丢弃物品] | ["[Item name] dropped."] | [InventoryChanged 事件确认后] |
| [分类变化] | ["[Category name]. [N] items."] | [分类标签页聚焦时] |
| [显示空状态] | ["No items in [category name]."] | [空状态渲染时] |

**Authoring the cognitive load assessment**:

[估算玩家在使用此屏幕时同时追踪的信息流数量。对于此屏幕：(1) 物品网格位置，(2) 物品详情属性，(3) 用于对比的当前装备配置，(4) 可用操作，(5) 物品分类。这是 5 条并发信息流——在标准的 7±2 限制内，但处于较高端。缓解措施：详情面板在导航时自动更新，玩家无需手动获取物品信息。通过自动呈现属性对比，减少需要主动做出的决策。]

---

## Section 13 — Localization Considerations

> **Why this section exists**: 未考虑本地化而构建的 UI 在首次翻译时就会损坏。德语文本通常比英语长 30–40%。阿拉伯语和希伯来语需要从右到左的镜像布局。日语和中文文本可能明显短于英语，产生尴尬的空白。这些问题规划起来成本很低，而在布局构建并发布后再修复则代价高昂。每个文本元素都应有明确的字符上限和溢出处理方案。

**Worked example table**:

| Text Element | English Baseline Length | Max Characters | Expansion Budget | RTL Behavior | Overflow Behavior | Risk |
|--------------|------------------------|----------------|-----------------|--------------|-------------------|------|
| [例如：屏幕标题 "INVENTORY"] | [9 字符] | [16 字符] | [78%] | [镜像到右侧，或居中——可接受] | [用省略号截断——标题不是关键内容] | [低] |
| [例如：物品名称] | [平均约 15 字符，最长约 35 字符 "Enchanted Dragon Scale Gauntlets"] | [50 字符] | [43%] | [RTL 布局中右对齐] | [用工具提示截断，悬停/聚焦时显示全名] | [中——长奇幻物品名很常见] |
| [例如：物品描述] | [约 80–120 字符] | [200 字符] | [67%] | [右对齐，正常换行] | [在详情面板内滚动——不截断] | [低——面板可滚动] |
| [例如：操作按钮 "Equip"] | [5 字符] | [14 字符] | [180%] | [按钮布局镜像；文本右对齐] | [字体缩小到最低 90%，然后截断] | [中——德语 "Ausrüsten" 为 9 字符] |
| [例如：分类标签页 "Consumables"] | [11 字符] | [18 字符] | [64%] | [镜像标签页位置] | [缩写："Consum."——在 loc 文件中按语言定义缩写] | [高——本地化标签页过长是已知问题] |

---

## Section 14 — Acceptance Criteria

> **Why this section exists**: 验收标准是“完成”的契约式定义。没有它们，实现何时完成由开发者说了算。有了它们，实现何时完成由 QA 测试员能否验证此列表上的每一项来决定。编写测试员能独立验证的标准，无需询问设计师意图是什么。每条标准都应是二元的——通过或不通过，而非主观判断。

**Worked example criteria (inventory screen)** — 注意每一条都是屏幕专属且可独立验证的：

- [ ] 在物品间导航不会产生可察觉的掉帧（保持目标帧率 ±5fps）
- [ ] 所有状态（Loading、Empty、Populated、Error、Confirmation）均正确渲染
- [ ] 所有物品槽位填充时，物品网格滚动流畅且不掉帧
- [ ] 屏幕关闭并重新打开后，物品栏更改正确持久化
- [ ] 屏幕打开期间能处理其他系统触发的 InventoryChanged 事件而不崩溃
- [ ] 属性对比不仅依靠颜色作为唯一区分手段
- [ ] 屏幕阅读器在聚焦时播报物品名称和关键属性（用平台屏幕阅读器验证）

---

## Section 15 — Open Questions

**Worked example questions**:

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [例如：物品对比应自动进行（始终显示已装备属性），还是由玩家触发（按 Compare）？] | [ux-designer] | [Sprint 4, Day 3] | [待定] |
| [例如：物品网格中是否支持控制器光标（自由瞄准），还是仅用方向键的网格导航？] | [lead-programmer + ux-designer] | [Sprint 4, Day 3] | [待定——取决于 ADR-0015 输入模型决策] |
| [例如：游戏的物品丢弃策略是什么——永久丢失还是掉落到世界？] | [systems-designer] | [需要更新 GDD] | [阻塞于物品栏 GDD 的边缘情况章节] |
| [例如：物品栏最大容量——网格有硬性上限还是无限滚动？] | [economy-designer] | [Sprint 3, Day 5] | [待定] |
