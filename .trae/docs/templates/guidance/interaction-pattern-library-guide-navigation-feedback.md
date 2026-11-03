> interaction-pattern-library.md 的编写指导。只加载当前正在编写的部分所对应的内容——不要一次读整个文件。

> 覆盖内容：**Navigation Patterns**（Screen Push / Pop / Replace、Focus Management、Escape / Cancel）与 **Feedback and Loading Patterns**（Loading State、Empty State、Error State）——完整参考规格。

## Navigation Patterns

---

#### Screen Push / Pop / Replace

**Category**: Navigation
**Status**: Draft

这三种模式定义了屏幕如何进入与退出导航栈。

| Pattern | Trigger | Animation | Stack Behavior | Focus Behavior |
|---------|---------|-----------|---------------|----------------|
| Push | 深入一层导航（打开子菜单、打开详情视图） | 新屏幕从右侧滑入。上一屏幕向左滑动并变暗。 | 上一屏幕保留在栈中 | 焦点移至新屏幕上的第一个可交互元素 |
| Pop (Back) | 返回按钮 / Escape / B / Circle | 当前屏幕向右滑出。上一屏幕从左侧滑入并变亮。 | 当前屏幕从栈中移除 | 焦点回到触发 Push 的那个元素 |
| Replace | 导航到同级屏幕（非子级、非父级）。加载屏幕。 | 当前屏幕淡出，新屏幕淡入。无方向倾向。 | 当前屏幕移除，新屏幕加入。 | 焦点移至新屏幕上的第一个可交互元素 |

**Animation durations**: Push/Pop：250ms ease-in-out。Replace：200ms 淡出 + 200ms 淡入。

**Motion reduction**: 所有滑动动画改为淡入淡出。时长缩短至 100ms。

**Implementation Notes**: [Godot：实现为管理 `Control` 场景栈的 `ScreenManager`
单例。`push(screen_scene)` 实例化并播放入场动画。`pop()` 播放退场动画并释放。
`replace(screen_scene)` 调用 pop 再 push，但不保留中间栈状态。每个屏幕使用
`CanvasLayer` 来隔离输入处理。在 push 之前保存"返回焦点"元素引用，以便 pop 时恢复。]

---

#### Focus Management

**Category**: Navigation
**Status**: Draft

> 焦点管理是游戏 UI 中最常见的键盘与手柄无障碍失败点。这些规则必须被一致地
> 实现。玩家绝不应处于这样的状态：看不到哪个元素获得焦点，或按下 Tab/方向键
> 却没有任何可见结果。

| Rule | Description |
|------|-------------|
| Screen open | 焦点放在最合乎逻辑的可交互元素上——通常是 Primary 按钮、第一项列表项，或若该屏幕此前访问过则放在上次获得焦点的元素上。绝不放在非交互元素上。 |
| Screen close / pop | 焦点回到触发导航的那个元素（打开该屏幕的按钮、被选中的列表项）。如果该元素已不存在，焦点移到其之前最近的可交互元素。 |
| Modal open | 焦点被限制在模态框内。见 Modal Dialog 模式。 |
| Modal close | 焦点回到触发模态框的那个元素。 |
| Element disabled | 如果获得焦点的元素变为禁用，焦点移到 tab 顺序中下一个可用的可交互元素。 |
| Element destroyed | 如果获得焦点的元素从场景中移除，焦点移到 tab 顺序中其之前最近的元素。 |
| Screen without interactive elements | 焦点管理为空操作。确保返回/取消输入仍然有效。 |
| Tab key (keyboard) | 按文档顺序（从左到右、从上到下）在可交互元素间向前移动焦点。Shift+Tab 向后移动。 |
| D-pad (gamepad) | 按所按下的空间方向移动焦点。手柄优先使用空间导航而非严格的 tab 顺序。绝不要在互不相关的区域之间循环焦点（例如 Tab 栏与内容区应是各自独立的导航区域）。 |
| Focus is always visible | 当元素通过键盘或手柄获得焦点时，焦点环或等效的焦点指示必须始终可见。绝不要隐藏焦点指示。 |

---

#### Escape / Cancel

**Category**: Navigation
**Status**: Draft

> "返回"操作是所有菜单系统中使用最多的导航输入。它必须在每个屏幕上保持一致，
> 没有例外。

| Platform | Input | Behavior |
|----------|-------|---------|
| PC (keyboard) | Escape | 关闭最顶层的模态框 / 在栈中返回上一屏幕 / 若已在根屏幕（主菜单），打开"退出？"确认 |
| PC (gamepad) | B（Xbox 布局）/ Circle（PS 布局） | 与 Escape 相同 |
| Xbox | B 键 | 与 Escape 相同 |
| PlayStation | Circle 键 | 与 Escape 相同 |
| Nintendo Switch | B 键 | 与 Escape 相同（注意：任天堂在某些第一方作品中用 B 表示确认——请核实本次发布所对应的平台惯例并记录决策） |

**Rules**: 该输入绝不可被重定义为"返回/取消"以外的用途。如果某个屏幕没有返回
操作（例如游戏已暂停，玩家必须做出选择），Escape 不做任何事，或显示"你必须做出
选择"的消息——它不会导航离开。每个屏幕都必须在其 UX 规格中明确定义 Escape 行为。

---

## Feedback and Loading Patterns

---

#### Loading State

**Category**: Feedback
**Status**: Draft

| Scope | Pattern | Notes |
|-------|---------|-------|
| Full screen (initial load) | 带游戏美术的全屏加载界面、进度条（尽可能使用确定性进度）、提示文本（可选）。 | 绝不要使用空的黑色屏幕。给玩家一些可读或可看的内容。 |
| Full screen (level transition) | 淡出至黑、加载屏幕、从黑淡入新场景。 | 淡出能消除上一场景消失时的突兀切换。 |
| Component / inline | 用加载指示器或骨架占位替换正在加载的组件。内容加载完成后组件不得发生布局位移。 | 对于布局密集的内容，骨架占位（近似内容形状的灰色方块）比加载指示器更好——它能防止加载时的布局位移。 |
| Background / async | 除非操作超过 2 秒，否则不显示视觉指示。超过 2 秒后，显示一个小型加载指示器或浮动提示。 | 对于 2 秒内完成的操作不要显示加载指示——指示器一闪而过比等待更具干扰性。 |

**Accessibility**: 加载状态必须向屏幕阅读器播报："[Context] loading, please wait."
加载完成必须播报："[Context] loaded." 对于全屏加载，确保加载屏幕本身对屏幕阅读器
可导航——提示文本与任何 UI 元素都必须暴露出来。

---

#### Empty State

**Category**: Feedback
**Status**: Draft

> 空状态始终是游戏 UI 中设计最不足的部分。它们决定了玩家是觉得"这里是我存放
> 物品的地方"，还是觉得"为什么这里什么都没有？是不是出问题了？"每一个空列表与
> 空网格都必须有设计好的空状态。空状态不是错误——它是起点。

| Location | Empty State Content | Notes |
|----------|--------------------|----|
| Inventory (no items) | 图标（细淡、较大、居中）。消息："Your inventory is empty." 副消息："Items you find on your journey will appear here." | 不要说"No items found"——"found"暗示搜索失败。 |
| Quest Log (no active quests) | 图标。消息："No active quests." 副消息："Talk to characters marked with [quest marker icon] to start a quest." | 给玩家一个明确的操作。 |
| Achievements (none earned) | 图标。消息："No achievements yet." 提示成就列表："Try [Action] to earn your first achievement." | 游戏化的激励，而不只是空无一物。 |
| Search results (no matches) | 图标。消息："No results for '[search term]'." 副消息："Try a different search or [browse all]." | 把搜索词回显给玩家。给出一个替代操作。 |

**Rule**: 每个空状态都必须包含图标、消息，以及副消息或操作按钮之一。没有任何说明
的空白容器永远不可接受。

---

#### Error State

**Category**: Feedback
**Status**: Draft

| Error Type | Pattern | Tone |
|-----------|---------|------|
| Input validation (form field) | 字段下方的内联错误消息。消息左侧有错误图标。字段使用红色边框（配图标以保证色盲安全）。 | 中性且具体——"Username must be 3-20 characters." 而不是"Invalid input." |
| Operation failed (save error, network error) | 非关键失败使用浮动提示。关键失败（存档文件无法写入）使用模态对话框。 | 平静且可操作——"Save failed. Check storage space." 而不是"FATAL ERROR." |
| System error (crash, data corruption) | 全屏错误界面，包含错误代码、恢复选项（"Restart Game"、"Load last save"）与支持联系方式。 | 令人安心——承认问题，赋予玩家主动权。绝不责怪玩家。 |
| Soft error (action cannot be performed) | 浮动提示或内联消息。 | 说明原因——"Not enough gold" 而不是"Action unavailable." |

**Principle**: 错误消息永远不是玩家的错。它们是游戏在告诉玩家发生了什么、下一步
该怎么做。从所有错误消息中删除"invalid"一词——用具体说明替代。

---
