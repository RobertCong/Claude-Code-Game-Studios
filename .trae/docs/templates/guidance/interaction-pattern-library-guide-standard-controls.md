> interaction-pattern-library.md 的撰写指导。只加载当前正在撰写的章节所对应的部分——不要一次性加载整个文件。

> 涵盖：**Standard Control Patterns**——Button（Primary/Secondary/Destructive）、Toggle、Slider、Dropdown / Select、List Item、Grid Item、Modal Dialog、Confirmation Dialog、Toast / Notification、Tooltip、Progress Bar、Input Field、Tab Bar、Scroll Container 的完整参考规格。

## Standard Control Patterns

---

#### Button (Primary)

**Category**: Input
**Status**: Draft
**When to Use**: 屏幕上最重要的单一操作。“Start Game”、“Confirm”、“Accept”、“Buy”。同一时间最多只能有一个 Primary 按钮可见。它回答了这个问题：“玩家在这里最可能想做什么？”
**When NOT to Use**: 替代性或次要操作；后果不可逆、需要先确认的破坏性操作；任何不是该屏幕主要意图的操作。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 完全不透明填充，颜色取自 art-bible 的主色。标签居中。 | — | — | — | — |
| Hovered (mouse) | 亮度 +15%，轻微缩放 1.03x，光标变为指针 | 鼠标悬停于元素上 | 从 Default 过渡 | 80ms ease-out | [UI 悬停音效——见 Sound Standards] |
| Focused (keyboard/gamepad) | 可见聚焦环（2px，偏移 3px，高对比度颜色）。亮度与 Hovered 相同。 | Tab / 方向键导航 | 从 Default 过渡 | 80ms ease-out | [UI 聚焦音效——与悬停相同] |
| Pressed | 缩放 0.97x，亮度 -10% | 点击 / Enter / A（Xbox）/ 叉（PS） | 动作在松开时触发，而非按下时。按下时缩放。 | 按下 60ms ease-in；松开 80ms ease-out | [UI 确认音效] |
| Disabled | 40% 不透明度，无指针光标，无悬停状态 | — | 无响应 | — | — |
| Loading (post-press) | 用加载指示器替换标签。按钮保持在按下时的缩放，并处于禁用状态。 | — | 防止重复提交 | 异步操作的时长 | — |

**Accessibility**:
- 键盘：Tab 聚焦，Enter 或 Space 激活。必须能通过 Tab 顺序从屏幕上的任何其他可交互元素到达。
- 手柄：用方向键或左摇杆将焦点导航到按钮。A（Xbox）/ 叉（PS）激活。屏幕打开时，焦点必须默认落在 Primary 按钮上。
- 屏幕阅读器：按钮必须暴露与可见标签一致的辅助功能名称。角色："button"。状态：禁用时为 "dimmed"。激活播报："[Label] button — [操作结果，若已知]。"
- 色盲：不要只靠颜色区分 Primary 与 Secondary。Primary 除颜色差异外，还应使用更高的视觉权重（填充 vs. 描边，或更大的尺寸）。
- 最小触控目标：44x44pt（iOS HIG）/ 48x48dp（Android）。即使 PC 端但可能支持触控，也要应用。

**Implementation Notes**:
[Godot：扩展 `Button` 控件。为自定义状态重写 `_draw()`，而不是在状态切换中途修改主题。使用 `focus_mode = FOCUS_ALL` 确保键盘可聚焦。设置 `mouse_default_cursor_shape = CURSOR_POINTING_HAND`。对于缩放动画，对按钮父级 Control 的 `scale` 属性使用 Tween——直接缩放 Button 本身可能裁切子节点。]

---

#### Button (Secondary)

**Category**: Input
**Status**: Draft
**When to Use**: 替代性或取消操作。“Back”、“Cancel”、“Skip”、“Maybe Later”。视觉权重低于 Primary——它应在视觉上后退，而不是竞争。
**When NOT to Use**: 破坏性操作（使用 Button (Destructive)）。屏幕最重要的操作（使用 Button (Primary)）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 描边样式（仅边框，填充透明），使用次要色。比 Primary 略小或权重略低。 | — | — | — | — |
| Hovered | 背景填充以 15% 不透明度出现。边框变亮。缩放 1.02x。 | 鼠标悬停 | 从 Default 过渡 | 80ms ease-out | [UI 悬停音效——比 Primary 更柔和的变体] |
| Focused | 聚焦环，规格与 Primary 相同。 | Tab / 方向键 | 从 Default 过渡 | 80ms ease-out | [UI 聚焦音效] |
| Pressed | 缩放 0.97x，填充不透明度增至 30% | 点击 / Enter / B（Xbox）/ 圆圈（PS）（聚焦状态下） | 动作在松开时触发 | 60ms ease-in | [UI 取消/返回音效] |
| Disabled | 40% 不透明度 | — | 无响应 | — | — |

**Accessibility**: 要求与 Button (Primary) 相同。辅助功能名称必须与可见标签一致。在同时有 Primary 和 Secondary 按钮的对话框中，Secondary 按钮通常还映射到平台的“取消”输入（B / 圆圈 / Escape），同时支持直接聚焦激活。

**Implementation Notes**: [与 Button (Primary) 相同。当 Primary 与 Secondary 同时出现时，确保 Secondary 的位置始终一致——横向布局中位于 Primary 的右方/下方，纵向布局中位于 Primary 下方。跨屏幕的一致性比单个屏幕的审美偏好更重要。]

---

#### Button (Destructive)

**Category**: Input
**Status**: Draft
**When to Use**: 任何不可逆、会造成玩家数据或重要进度丢失的操作：“Delete Save File”、“Reset All Settings”、“Leave Match”、“Discard Changes”。视觉处理要在玩家按下之前就传达危险。
**When NOT to Use**: 可以撤销的操作，或仅仅是有后果但可逆的操作。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 使用破坏性颜色描边或填充（通常是去饱和的红色——在 accessibility-requirements 中确认色盲兼容性）。标签可包含警告图标。 | — | — | — | — |
| Hovered / Focused | 行为与 Button (Primary) 的悬停/聚焦相同，但使用破坏性颜色 | — | — | 80ms | [UI 悬停音效] |
| Pressed (first press) | 不执行该操作。而是打开 Confirmation Dialog 模式（见下文）。按钮自身显示短暂的脉冲动画。 | 点击 / Enter | 触发 Confirmation Dialog | 100ms 脉冲 | [UI 警告音效——与标准确认音效不同] |
| — | 由 Confirmation Dialog 处理实际执行 | — | — | — | — |
| Disabled | 40% 不透明度 | — | 无响应 | — | — |

> **Critical rule**: Button (Destructive) 绝不直接执行其操作。
> 它始终触发 Confirmation Dialog。没有例外。误按的玩家必须始终多一次
> 反悔的机会。在破坏性操作上跳过确认的游戏，会产生所有 UX 缺陷类型中
> 最显眼的负面社区情绪。参见：任何游戏论坛上每一条“不小心删了存档”
> 的投诉。

**Accessibility**: 屏幕阅读器必须播报其破坏性本质："[Label] button — this action cannot be undone."。除辅助功能名称外，如可用，使用 `description` 属性添加警告文本。

**Implementation Notes**: [破坏性按钮触发一个独立的 Confirmation Dialog 场景。把操作回调传给对话框——按钮自身不持有执行逻辑。这种分离能在确认对话框出现缺陷时防止误执行。]

---

#### Toggle

**Category**: Input
**Status**: Draft
**When to Use**: 二元开关设置，两种状态同等有效，且当前状态必须一眼可见。“Subtitles: On/Off”、“Aim Assist: On/Off”、“Notifications: On/Off”。
**When NOT to Use**: 从两个以上选项中做选择（使用 Dropdown）。只发生一次、而非代表持久状态的操作（使用 Button）。切换的后果复杂到需要解释的情况（在旁边显示描述字段）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Off / Default | 轨道：柔和填充。滑块：最左位置。标签："Off" 或状态标签。 | — | — | — | — |
| Hovered | 轨道变亮 10%。光标：指针。 | 鼠标悬停 | 过渡 | 60ms | [UI 悬停音效] |
| Focused | 整个开关元素（轨道 + 滑块）周围出现聚焦环。 | Tab / 方向键 | — | 60ms | [UI 聚焦音效] |
| Pressed / Activated | 滑块滑向右侧。轨道填充变为激活色。标签变为 "On" 或激活状态标签。状态保持。 | 点击 / Enter / A / 叉 | 切换状态变化。触发 onChange 事件。持久化数值。 | 滑动 150ms ease-in-out | [Toggle ON 音效] |
| Pressed / Deactivated | 滑块滑向左侧。轨道恢复柔和填充。 | 相同输入 | 切换状态变化 | 150ms ease-in-out | [Toggle OFF 音效——与 ON 略有不同] |
| Disabled | 40% 不透明度。不可交互。当前状态仍然可见。 | — | 无响应 | — | — |

**Accessibility**:
- 键盘/手柄：Space 或 Enter 切换。避免要求用方向输入（左/右）来切换——有些用户无法预判这种行为。
- 屏幕阅读器：角色："switch"。状态："on" 或 "off"——辅助功能名称不应包含状态（屏幕阅读器会单独播报状态）。正确：辅助功能名称 "Subtitles"，状态 "on"。错误：辅助功能名称 "Subtitles On"。
- 开关标签（而不仅是滑块的可视位置）必须变化以显示当前状态，以服务于无法可靠区分左右位置的玩家。

**Implementation Notes**: [Godot：使用自定义 Control 或 CheckButton。
内置 CheckButton 提供无障碍角色，但使用复选框式视觉；
目标美术风格可能需要自定义滑动开关动画。确保在减少动态效果模式激活时
跳过滑动动画——此时直接跳到最终状态。]

---

#### Slider

**Category**: Input
**Status**: Draft
**When to Use**: 从连续范围中选择数值，近似值可接受，且范围与相对位置都很重要。音量（0–100%）、亮度、文本大小。位置的可视化本身就是有用的信息。
**When NOT to Use**: 精确数值输入（使用 Input Field）。从较短的离散列表中选择（使用 Dropdown）。二元状态（使用 Toggle）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 轨道（全宽）。填充（滑块左侧，显示当前值）。滑块（可拖动手柄）。当前值标签（轨道右侧或滑块上方）。 | — | — | — | — |
| Hovered | 滑块略微放大（1.2x）。轨道变亮。 | 鼠标悬停 | — | 60ms | — |
| Focused | 滑块上有聚焦环。轨道变亮。 | Tab / 方向键 | — | 60ms | [UI 聚焦音效] |
| Dragging (mouse) | 滑块跟随光标。填充实时更新。数值标签实时更新。 | 在滑块上点击 + 拖动 | 连续更新数值。连续触发 onChange。 | 实时 | [滑块调整音效——细微，拖动期间循环播放] |
| Keyboard / D-pad adjust | 滑块移动一步（每次按下为范围的 5%，或 1 个离散单位）。 | 聚焦时按左/右方向键或左/右方向键（D-pad） | 按步长改变数值。每步触发 onChange。 | 立即 | [滑块步进音效——每步一声] |
| Keyboard fast adjust | 更大的步长（范围的 25%）。 | 聚焦时按 Page Up / Page Down | 按大步长改变数值 | 立即 | [相同步进音效] |
| Released | 数值锁定。onChange 触发最终值。 | 松开鼠标 | — | — | — |
| Disabled | 40% 不透明度。不可交互。数值可见。 | — | 无响应 | — | — |

**Accessibility**:
- 键盘：左/右方向键小步调整。Page Up / Page Down 大步调整。Home/End 跳到最小/最大值。
- 屏幕阅读器：角色："slider"。辅助功能名称：标签（例如 "Music Volume"）。每次变化播报当前值："Music Volume, 80 percent."。首次聚焦时播报最小/最大值。
- 所有滑块都必须在可视位置旁显示数值。仅依赖轨道填充位置会排除无法感知相对位置的玩家。

**Implementation Notes**: [Godot `HSlider`：将 `step` 设为合适的增量。
重写键盘输入，通过 `_input()` 添加 Page Up/Down 支持。绑定
`value_changed` 信号以更新显示的数字标签。启用减少动态效果
模式时，确保数值标签更新是唯一反馈——不要抑制它们。
手柄滑块调整时的振动反馈是很好的无障碍增强。]

---

#### Dropdown / Select

**Category**: Input
**Status**: Draft
**When to Use**: 从 3-15 个选项的离散列表中选择，静态时只需要显示所选值。显示分辨率、语言、窗口模式、输入预设。关闭状态只显示当前选择。
**When NOT to Use**: 二元选择（使用 Toggle）。超过约 15 个选项（使用完整 List 模式或可滚动的 Select）。当比较选项与选择一个同样重要时（将选项可见地展示，例如作为水平选择器或列表）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Closed / Default | 标签（左）。当前值（右）。向下箭头图标（最右）。 | — | — | — | — |
| Hovered | 行背景以 10% 不透明度填充 | 鼠标悬停 | — | 60ms | — |
| Focused (closed) | 整行有聚焦环。 | Tab / 方向键 | — | 60ms | [UI 聚焦音效] |
| Opening | 下拉列表出现在下方（若靠近屏幕底部则出现在上方）。列表项可见。之前选中的项高亮。焦点移动到列表内选中的项。 | 点击 / Enter / A / 叉 | 打开列表 | 100ms ease-out（展开） | [UI 展开音效] |
| List item hovered/focused | 列表项高亮 | 鼠标 / 方向键 | — | 60ms | [UI 悬停音效] |
| List item selected | 列表关闭。关闭状态显示新值。触发 onChange 事件。 | 在项上点击 / Enter / A / 叉 | 选择数值，关闭列表 | 80ms ease-in（收起） | [UI 确认音效] |
| Dismissed without selecting | 列表关闭。数值不变。 | Escape / B / 圆圈 / 点击外部 | 关闭 | 80ms | [UI 取消音效] |
| Disabled | 40% 不透明度。不可交互。 | — | — | — | — |

**Accessibility**:
- 键盘：打开时用上/下方向键在列表项间导航。Enter 选择。Escape 关闭。输入某个选项的首字母可将焦点跳到第一个匹配项。
- 屏幕阅读器：角色："combobox"。辅助功能名称：字段标签。播报展开/收起状态。聚焦时播报当前值。每个列表项播报其值和位置："English, 1 of 12."。
- 下拉列表绝不能遮挡当前项或打开它的控件——这是小屏幕上的常见缺陷。

**Implementation Notes**: [Godot：使用 `Button`（关闭状态）加
`PopupMenu` 或通过动画展开的 `VBoxContainer` 进行自定义实现。原生
`OptionButton` 提供无障碍支持，但视觉自定义有限。确保弹窗在被屏幕
底部裁切时定位到控件上方。在 `_input` 检测到点击其矩形外部时关闭弹窗。]

---

#### List Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**: 垂直可滚动列表中的单个可选择行。成就、任务日志条目、设置分类、存档槽位。列表是容器；这是其中的行。
**When NOT to Use**: 项目存在于二维的网格布局（使用 Grid Item）。不可选择的内容行（移除悬停/聚焦状态和按下状态）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 全宽行。图标（可选，左侧）。主标签。次要标签 / 元数据（右侧或主标签下方）。箭头（右侧，若可进入更深层级）。 | — | — | — | — |
| Hovered | 行背景以 12% 不透明度高亮。 | 鼠标悬停 | — | 60ms | — |
| Focused | 行上有聚焦环，或行背景以 20% 不透明度显示（与平台惯例一致）。 | 方向键 / Tab | — | 60ms | [UI 聚焦音效] |
| Selected (persistent) | 行背景以 25% 不透明度显示。可显示选择指示（左边框、勾选标记）。与聚焦状态不同——一行可以被选中但不被聚焦。 | — | 渲染状态 | — | — |
| Pressed / Activated | 短暂亮度闪烁，然后导航或执行操作 | 点击 / Enter / A / 叉 | 导航或操作 | 80ms 闪烁 | [UI 确认音效] |
| Disabled | 40% 不透明度。不可交互。 | — | — | — | — |

**Accessibility**:
- 键盘/手柄：用上/下方向键在列表项间移动。列表必须处理焦点循环——到达底部应停止（不循环），除非明确设计了循环。
- 屏幕阅读器：角色："listitem"。父列表角色："list"。辅助功能名称：主标签内容。元数据（次要标签）可选地包含在描述中。播报位置："Quest Log, 3 of 12."。
- 最小行高：触控为 44pt / 48dp。对于以控制器为主的平台，56px 行更舒适。

**Implementation Notes**: [Godot：在 `ScrollContainer` 内使用 `VBoxContainer`。
每一行是自定义 `Control` 或 `PanelContainer`，并重写 `_gui_input`。
对于滚动容器内的键盘导航，需实现自定义焦点遍历——
Godot 默认的 Tab 导航不会滚动容器以保持聚焦项可见。
使用滚动容器上的 `ensure_control_visible()`。]

---

#### Grid Item

**Category**: Layout / Input
**Status**: Draft
**When to Use**: 二维网格中的可选择单元格。物品栏槽位、技能选择、制作材料选择、角色头像选择。网格是容器；这是单元格。
**When NOT to Use**: 单列内容（使用 List Item）。不可选择的展示单元格（移除交互状态）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Empty | 空槽位视觉（细微边框或虚线轮廓）。与禁用不同。 | — | — | — | — |
| Populated | 物品图标填满单元格。堆叠数量（右下，若适用）。品质指示（边框颜色或图标叠加）。 | — | — | — | — |
| Hovered | 亮度 +15%。400ms 延迟后出现工具提示。 | 鼠标悬停 | — | 60ms | — |
| Focused | 聚焦环（2px，偏移 2px）。亮度与悬停相同。400ms 延迟后出现工具提示，手柄上则立即出现。 | 方向键导航 | — | 60ms | [UI 聚焦音效] |
| Selected (persistent) | 明显的边框（更粗、对比色）。可显示选择勾选标记。 | 点击 / Enter / A / 叉 | 选择物品。可与另一个单元格的聚焦状态共存。 | 立即 | [UI 选择音效] |
| Pressed | 短暂缩放 0.95x，然后执行操作 | 双击 / Enter / A / 叉 | 操作（装备、使用、查看——由上下文定义） | 80ms | [UI 确认音效] |
| Locked | 在有内容的单元格上叠加锁图标。无悬停/聚焦状态。 | — | 无交互 | — | — |
| Drag source | 单元格变暗（50% 不透明度），光标处出现拖动预览。 | 点击 + 拖动（仅鼠标） | 开始拖动操作 | 立即 | [UI 抓取音效] |
| Drop target (valid) | 单元格变亮，显示接受颜色指示 | 物品拖到其上 | — | 60ms | — |
| Drop target (invalid) | 红色着色或抖动动画 | 物品拖到无效槽位上 | — | 60ms | [UI 错误音效] |

**Accessibility**:
- 键盘/手柄：用方向键或箭头键导航单元格。网格必须向屏幕阅读器传达其尺寸。播报行/列位置。
- 屏幕阅读器：角色："gridcell"。父角色："grid"。辅助功能名称：物品名称（空单元格为 "empty slot"）。状态：选中时为 "selected"，锁定时为 "dimmed"。位置："row 2, column 3."。
- 工具提示必须能通过键盘到达——它们必须在单元格聚焦时出现，而不仅在悬停时出现。

**Implementation Notes**: [Godot：使用固定列数的 `GridContainer`。每个
单元格是自定义 `Control`。通过重写 `_gui_input` 并根据索引和列数
计算左/右/上/下的单元格，实现自定义方向键导航。
`GridContainer` 原生不提供此功能。]

---

#### Modal Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: 玩家必须解决后才能继续的决策或确认。对话框是阻塞式的——背景内容变暗且不可交互。“Are you sure?”、“Your progress will be saved.”、错误状态。
**When NOT to Use**: 非阻塞通知（使用 Toast / Notification）。可以等玩家准备好再处理的信息（改为加入持久的帮助系统）。应当允许玩家在对话框后方继续游玩的对话框。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Opening | 背景遮罩从 0 动画到 60% 不透明度。对话框面板从 0.9 缩放到 1.0。对话框从中心进入（不从边缘进入）。 | 由代码触发 | 焦点移动到对话框内第一个可交互元素（或 Primary 按钮） | 200ms ease-out | [UI 模态窗口打开音效] |
| Active | 背景不可交互。对话框拥有全部输入焦点。玩家无法与背景交互。 | 键盘 / 手柄仅在对话框内导航 | — | — | — |
| Dismissing (confirmed) | 对话框面板缩放至 1.1 然后淡出。遮罩淡出至 0%。 | 按下 Primary 按钮 | 执行操作，将焦点返回触发元素 | 180ms | [UI 确认音效] |
| Dismissing (cancelled) | 对话框面板缩放至 0.9 然后淡出。遮罩淡出至 0%。 | Secondary 按钮 / Escape / B / 圆圈 | 不执行操作，将焦点返回触发元素 | 150ms | [UI 取消音效] |
| Cannot dismiss | 若对话框表示阻塞性错误，不提供取消路径。只提供解决方案选项。 | — | — | — | — |

> **Focus trap rule**: 模态对话框打开时，Tab 和方向键导航
> 必须只在对话框内的可交互元素之间循环。不能把焦点导航到
> 对话框之外的背景内容。这既是无障碍要求（WCAG 2.1 SC 2.1.2），
> 也是 UX 完整性要求。对话框关闭时，焦点必须返回触发它的元素，
> 而不是页面顶部。

**Accessibility**:
- 屏幕阅读器：对话框容器角色："dialog"。辅助功能名称：对话框标题（必需——每个对话框都必须有标题，即使视觉上隐藏）。打开时，屏幕阅读器播报对话框标题和第一个可聚焦元素。焦点陷阱生效。
- 键盘：Escape 键始终映射到取消/关闭操作（与 Secondary 按钮或关闭按钮相同）。Enter 始终映射到主要/确认操作。
- 减少动态效果：缩放动画替换为瞬间出现/消失。遮罩淡入保留 100ms（更快）。

**Implementation Notes**: [Godot：实现为带有较高层值（100+）的 `CanvasLayer`，
确保它渲染在所有游戏内容之上。背景遮罩是 60% 黑色不透明度的全屏
`ColorRect`。在打开动画完成后，对对话框的主按钮调用 `grab_focus()`。
重写 `_input()` 实现焦点陷阱——拦截 Tab 导航并重新导向到对话框的
可聚焦元素。]

---

#### Confirmation Dialog

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: 确认破坏性操作的具体场景。始终由 Button (Destructive) 触发。始终恰好有两个选项：确认（以具体操作命名，而不是 "OK"）和取消。
**When NOT to Use**: 非破坏性的确认。不需要决策的错误或通知。任何具有两个以上操作的对话框。

> **Label rule**: 确认按钮必须以具体操作命名，
> 而不是通用的 "OK" 或 "Yes"。用 "Delete Save File" 而非 "OK"。用 "Leave Match" 而非
> "Yes"。这能减少快速阅读对话框内容有困难的玩家的误操作。该模式
> 源自 Apple HIG，并经过数十年可用性研究验证。

**Structure**:
- 标题：简短，描述操作。用 "Delete save file?" 而非 "Are you sure?"。
- 正文：一句话说明后果。"This cannot be undone."
- 确认按钮：Button (Primary)——以具体操作命名。"Delete Save File."
- 取消按钮：Button (Secondary)——"Cancel."
- 默认焦点：Cancel（更安全的默认值——减少误触破坏性操作）。

**Accessibility**: 继承所有 Modal Dialog 无障碍要求。此外：屏幕阅读器播报 "Alert dialog, [title]" 以提示破坏性上下文。默认焦点在 Cancel 上是要求，而非偏好。

**Implementation Notes**: [Confirmation Dialog 是 Modal Dialog 的特定实例——实现为子类或参数化场景。默认焦点在 Cancel 上至关重要：在打开动画完成后，对 Cancel 按钮（而不是 Confirm 按钮）调用 `grab_focus()`。]

---

#### Toast / Notification

**Category**: Feedback
**Status**: Draft
**When to Use**: 简短、非阻塞、不需要玩家决策的信息。“Game saved.”、“Achievement unlocked.”、“Your inventory is full.”。玩家可以继续游玩；通知会自行消失。
**When NOT to Use**: 需要决策的信息（使用 Modal Dialog）。需要玩家采取行动的错误。玩家绝不能错过的关键信息。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Entering | 从屏幕边缘滑入（通常是右下角，远离主要操作区域）。不透明度从 0 淡入到 100%。 | 由代码触发 | — | 200ms ease-out | [与通知类型匹配的音效——见 Sound Standards] |
| Displayed | 完全不透明。可选：图标（左）、标题、正文文本（可选）、关闭按钮（X，可选）。 | 指针悬停暂停自动消失计时器 | 暂停自动消失 | — | — |
| Auto-dismiss | 不透明度从 100 淡出到 0%，滑出 | 计时器到期（单行默认 5 秒；两行 8 秒） | 从队列移除 | 200ms ease-in | — |
| Manual dismiss | 立即淡出并滑出 | 点击/轻点 X 按钮或在触屏上滑动 | 移除 | 150ms | [UI 取消音效，轻柔] |
| Queue overflow | 新通知提前把最旧的推出 | 前一条显示期间触发新通知 | FIFO 队列，最多 3 条同时显示 | — | — |

**Accessibility**:
- 屏幕阅读器：浮层必须无需聚焦即可被朗读。在 HTML 中，这使用 `role="status"` 或 `role="alert"`。在游戏 UI 中，这需要引擎的无障碍通知系统。在 engine-reference 文档中核实引擎支持。
- 减少动态效果：滑动动画替换为仅淡入淡出。
- 浮层绝不能成为玩家需要据此行动的信息的唯一传达渠道。如果信息需要行动，除浮层外还应使用持久的 UI 元素。
- 自动消失计时器：5 秒是最低值。认知处理有差异的玩家可能需要更多时间。考虑提供延长到 10 或 15 秒的设置。

**Implementation Notes**: [Godot：在锚定到屏幕角落的 `VBoxContainer` 中管理
`PanelContainer` 场景队列。每个浮层被实例化、加入容器，然后在计时器后自动移除。
容器应位于较高的 `CanvasLayer`（50+），但低于模态对话框（100+）。
对 `modulate.a` 和 `position.x` 使用 `Tween` 进行动画。当减少动态效果
激活时，跳过位置动画。]

---

#### Tooltip

**Category**: Feedback
**Status**: Draft
**When to Use**: 补充可见标签的情境信息。物品栏中的物品描述。角色面板上的属性解释。无障碍选项中的设置说明。玩家必须能够获取这些信息，或者在没有它的情况下继续。
**When NOT to Use**: 玩家完成某个操作必须阅读的信息——把它放进标签或正文文本，而不是工具提示。在没有悬停状态的移动端触屏上，工具提示不可发现。在纯触屏平台上，改用打开描述模态窗口的信息按钮。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Hidden | — | — | — | — | — |
| Hover trigger | — | 鼠标进入元素 | 开始 400ms 延迟计时 | — | — |
| Gamepad/keyboard trigger | — | 元素获得焦点 | 开始 300ms 延迟计时（更短，因为导航是有意的） | — | — |
| Appearing | 工具提示面板淡入并从 0.95 缩放到 1.0。定位在元素附近（优先上方，靠近屏幕边缘时调整）。 | 计时到期 | 显示工具提示 | 120ms ease-out | — |
| Displayed | 工具提示可见。标题（可选）。正文文本。最大宽度：300px。允许多行。 | — | — | — | — |
| Hiding | 工具提示淡出 | 鼠标离开元素 / 焦点移走 | 隐藏工具提示 | 80ms ease-in | — |

**Accessibility**:
- 屏幕阅读器：工具提示内容必须无需悬停即可访问。父元素的辅助功能名称应包含最关键的工具提示信息。完整工具提示文本可选地放在 `description` 属性中。元素聚焦时屏幕阅读器朗读工具提示内容。
- 延迟（300-400ms）可防止意外显示工具提示，是必需的——即时工具提示在手柄导航中很干扰。
- 工具提示文本必须满足与正文文本相同的对比度要求（最低 4.5:1）。

**Implementation Notes**: [Godot：将自定义 `TooltipControl` 场景作为
触发元素的子节点附加。用 `Timer` 节点显示/隐藏。用 `CanvasLayer`
定位工具提示，确保它出现在所有其他 UI 之上。对于屏幕边缘，检测
工具提示矩形是否超出 `get_viewport_rect()`，并将位置翻转到另一侧。]

---

#### Progress Bar

**Category**: Feedback / Layout
**Status**: Draft
**When to Use**: 朝向已定义终点的线性进度。加载界面（完成所需时间）、经验值填充到下一级、可计数的任务目标进度（“已击败 3/10 个敌人”）、下载进度。
**When NOT to Use**: 圆形或径向进度（如需要，使用单独的 Radial Progress 模式）。快速上下波动的数值（使用 Health/Resource Bar 模式）。没有已定义终点的数值。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 轨道（全宽，背景色）。填充（从左到右，数值色）。数值标签（百分比或 N/M，填充外或填充内）。 | — | — | — | — |
| Value increasing | 填充宽度动画到新值 | 数值变化 | 平滑填充动画 | 300ms ease-out | [视上下文而定——经验值获取有音效；加载没有] |
| Value at maximum | 填充达到全宽。可选：完成动画（脉冲、发光）。 | 数值达到 100% | 触发完成事件 | 200ms | [如合适，播放完成音效] |
| Value at zero | 填充隐藏（零宽度）。轨道仍可见。 | — | — | — | — |
| Indeterminate (unknown duration) | 循环动画（填充段从左到右移动，重复）。用于时长未知的加载。 | — | — | 无限循环 | — |

**Accessibility**:
- 屏幕阅读器：角色："progressbar"。辅助功能名称：正在推进什么（例如 "Experience Points"、"Loading"）。数值：当前数字值、百分比和最大值。"Experience Points, 450 of 1000, 45 percent."。在显著变化时更新（而非每个像素）。
- 不要只靠填充颜色传达数值。包含数字标签。
- 不确定进度条：播报 "Loading, in progress"——不要播报变化，因为数值未知。
- 减少动态效果：不确定动画替换为静态的“加载中”指示器。平滑填充动画替换为瞬间跳到新值。

**Implementation Notes**: [Godot：使用内置 `ProgressBar` 并自定义主题。
对于不确定模式，`ProgressBar` 在 Godot 4.x 中没有原生的不确定状态——
通过对填充元素的位置使用循环 `Tween` 实现。确保在减少动态效果模式
激活时暂停 Tween，改为显示静态指示器。]

---

#### Input Field

**Category**: Input
**Status**: Draft
**When to Use**: 文本输入。新存档的玩家名称、在列表中搜索、重新映射按键绑定（特殊情况——显示按键，而非输入的文本）、精确输入数值。
**When NOT to Use**: 从已知选项中做选择（使用 Dropdown 或 List）。在以主机为主的平台上，尽量减少文本输入——它需要虚拟键盘，摩擦很高。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | 字段边框、占位文本（标签式，柔和颜色）、空输入区域。 | — | — | — | — |
| Hovered | 边框略微变亮 | 鼠标悬停 | — | 60ms | — |
| Focused | 边框完全变亮。光标（闪烁，530ms 亮/530ms 灭）。占位文本隐藏。 | Tab / 点击 | 在主机/移动端打开虚拟键盘 | 立即 | [UI 聚焦音效] |
| Typing | 字符出现。光标前进。 | 键盘输入 | 更新字段值 | 即时 | [细微按键音效，可选] |
| Value present | 字段显示已输入的值。占位文本隐藏。若值非空，右侧出现清除按钮（X）。 | — | — | — | — |
| Character limit reached | 不再接受输入。可选：短暂抖动动画，限制指示器变色。 | 达到上限时的输入 | 拒绝更多字符 | 200ms 抖动 | [UI 错误音效，细微] |
| Clear | 字段清空。光标返回。清除按钮消失。 | 点击 X / 手柄清除输入 | 清空数值 | 立即 | [UI 取消音效，细微] |
| Validation error | 边框变为错误色（红色——确保色盲安全）。字段下方出现错误消息。 | 提交时或失焦时 | 显示错误 | 立即 | [UI 错误音效] |
| Validated / correct | 边框变为成功色（绿色——确保色盲安全）。成功图标可选。 | 验证通过时 | — | 立即 | — |
| Disabled | 40% 不透明度，不可交互。值仍可见。 | — | — | — | — |

**Accessibility**:
- 键盘：所有标准文本编辑快捷键（Home、End、Ctrl+A、Ctrl+C、Ctrl+V、Ctrl+Z）。
- 屏幕阅读器：角色："textbox"。辅助功能名称：字段标签（不是占位文本）。播报当前值。达到限制时播报字符上限。验证错误发生时立即播报。
- 不得将占位文本用作唯一标签——字段上方或旁边必须有可见标签。玩家输入时占位文本会消失，给有认知或记忆障碍的玩家造成困惑。

**Implementation Notes**: [Godot `LineEdit`：设置 `placeholder_text` 作为提示，
但始终包含一个可见的 `Label` 节点作为字段的辅助功能名称。绑定
`text_changed` 信号进行实时验证。绑定 `text_submitted` 以在 Enter 时提交表单。
在主机上，调用 `LineEdit.call("_popup_keyboard")` 或使用操作系统
虚拟键盘 API——请对照 engine-reference/godot/ 核实 Godot 4.7 主机键盘 API 的具体细节。]

---

#### Tab Bar

**Category**: Navigation
**Status**: Draft
**When to Use**: 将单个屏幕的内容划分为离散区块，同一时间只显示一个区块。角色面板标签页（Stats / Equipment / Skills）、设置标签页（Gameplay / Graphics / Audio / Accessibility）。超过 5-6 个标签页时该模式会失效，应考虑改用侧边栏导航。
**When NOT to Use**: 超过 6 个标签页。受益于同时可见的内容（改用布局模式）。不同屏幕之间的导航（使用 Screen Push）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default (inactive tab) | 标签文本。无激活指示。 | — | — | — | — |
| Active tab | 标签文本。激活指示（下划线、填充或对比背景）。内容区域显示此标签页的内容。 | — | — | — | — |
| Hovered (inactive) | 标签背景略微填充 | 鼠标悬停 | — | 60ms | — |
| Focused (keyboard/gamepad) | 标签文本上有聚焦环。 | Tab 键（在标签栏内）或标签行上的左/右方向键 | — | 60ms | [UI 聚焦音效] |
| Activated | 激活指示过渡到此标签。内容区域过渡（淡入或滑动）。 | 点击 / Enter / A / 叉 | 切换活动标签。更新内容。 | 150ms ease | [UI 标签切换音效] |
| Gamepad shoulder button | — | L1/R1（PS）或 LB/RB（Xbox） | 切换到上一个/下一个标签（平台标准惯例） | 150ms | [UI 标签切换音效] |

**Accessibility**:
- 键盘：箭头键在标签栏内切换标签（左/右）。Tab 键将焦点移入下方内容区域。这遵循 ARIA tab panel 模式。
- 屏幕阅读器：单个标签角色："tab"。容器角色："tablist"。内容区域角色："tabpanel"。活动标签状态："selected"。辅助功能名称：标签文本。tabpanel 由其对应的标签命名。
- 活动标签必须在视觉上可区分，且不能仅靠颜色（除颜色外，还应有下划线、填充图案或字重变化）。

**Implementation Notes**: [Godot：内置 `TabContainer`。如需自定义视觉
样式，用标签按钮的 `HBoxContainer` 和内容区的 `MarginContainer` 手动实现。
肩键快捷键（LB/RB）必须在屏幕的 `_input()` 重写中实现——它不在 Godot 的
标签系统中内置。检查平台惯例：Xbox 使用 LB/RB；PlayStation 使用 L1/R1；
两者是同一个物理按钮，因此单一绑定即可。]

---

#### Scroll Container

**Category**: Layout
**Status**: Draft
**When to Use**: 内容超出其容器的可见区域。物品栏列表、背景故事条目文本、制作人员名单、较长的设置列表。滚动指示器向玩家表明还有更多内容。
**When NOT to Use**: 可以改为分页的内容（对于密集列表导航，分页可能更清晰）。无限滚动（始终提供加载状态和结束状态）。

**Interaction Specification**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Content fits | 无可见滚动条（或按美术方向始终显示全长滚动条）。 | — | — | — | — |
| Scrollable | 出现滚动条（右边缘）。滚动条滑块大小代表视口与内容的比例。 | — | — | — | — |
| Scrolling (mouse) | 内容移动。滚动条滑块按比例移动。 | 鼠标滚轮 | 每格滚轮滚动 3 行（可在操作系统中配置） | 平滑 | — |
| Scrollbar drag | 内容移动。滑块跟随指针。 | 在滚动条滑块上点击 + 拖动 | 按比例滚动 | 实时 | — |
| Keyboard scroll | 每次按键内容移动一个项目高度。 | 容器聚焦且无子元素聚焦时按上/下方向键 | 滚动一个单位 | 即时 | — |
| Gamepad scroll | 内容移动以保持聚焦项在视野内。 | 用方向键导航到可见区域之外的项目 | 自动滚动以保持聚焦项可见 | 平滑 150ms | — |
| Scroll top / bottom | 内容停止。滚动条滑块到达端点。 | 到达内容边界 | 停止滚动 | — | — |
| Focus follows scroll | 子元素获得焦点时，滚动容器确保其完全可见。 | 任意子元素获得焦点 | 滚动以显露聚焦元素 | 200ms ease | — |

**Accessibility**:
- 键盘/手柄：滚动容器本身不应要求显式操作滚动条——在其内部导航列表项时，应自动滚动以保持聚焦项可见。
- 屏幕阅读器：滚动容器播报 "scrollable" 和滚动位置（"showing items 5 through 15 of 30"）。这需要引擎无障碍支持——在 engine-reference/godot/ 中核实。
- 边缘淡出（在滚动边界处淡出内容以表明还有更多内容）是有用的视觉可供性，但不得作为可见区域之外仍有内容的唯一指示。必须包含滚动条。

**Implementation Notes**: [Godot `ScrollContainer`：当容器内触发 `gui_focus_changed`
时，对聚焦的子元素调用 `ensure_control_visible()`。通过容器 `gui_focus_changed`
信号上的递归 `connect` 绑定此逻辑。对于平滑滚动动画，对 `scroll_vertical`
使用 `Tween`，而不是直接设置它。]

---
