> interaction-pattern-library.md 的编写指导。只加载当前正在编写的部分所对应的内容——不要一次读整个文件。

> 覆盖内容：**Game-Specific UI Patterns**——Inventory Slot、Ability / Skill Icon、Health / Resource Bar、Dialogue Box、Context Action Prompt、Damage Number 的完整参考规格。

## Game-Specific UI Patterns

---

#### Inventory Slot

**Category**: Game-Specific
**Status**: Draft
**When to Use**: 物品栏网格中的每一个物品容器。空格子、已填充格子、已装备格子、
锁定格子。格子是框架；物品图标是内容。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Empty | 细淡的格子边框，无内容。与 disabled 不同。空格子是可交互的（可以接收物品）。 | 避免让空格子完全不可见——玩家会搞不清网格的尺寸 |
| Populated | 物品图标占格子面积的 80%。右下角显示堆叠数量（如适用）。品质边框（色盲安全——图标 + 颜色）。已装备角标（右上角，如已装备）。 | |
| Focused | 焦点环。300ms 后出现提示框。 | |
| Selected | 边框加粗或使用对比色。适用于支持多选的情况。 | |
| Drag source | 格子变暗，拖拽残影跟随指针。 | 完整拖拽规格见 Grid Item |
| Locked | 锁形图标覆盖。不可交互。可在锁后以 50% 不透明度显示物品。 | 用于锁定的配装槽位、DLC 内容等 |
| Highlighted | 边框发光动画（脉动）。用于与任务相关的物品或新获得的物品。 | 尊重减少动态效果设置——用静态角标替代脉动 |
| Cooldown overlay | 从 12 点方向顺时针的径向填充遮罩，随冷却结束而消退。 | 仅在格子代表带冷却的主动物品时适用 |

**Accessibility**: 堆叠数量与品质等级必须有文本或图标替代颜色编码。提示框是主要的
无障碍机制——确保可通过键盘与屏幕阅读器访问。锁定的格子必须向屏幕阅读器播报
"locked"。

**Implementation Notes**: [Godot：自定义 `Control` 节点。品质边框通过基于稀有度切换
的 `StyleBoxFlat` 实现——不要用 `modulate` 颜色表示品质，因为它会影响图标颜色。
拖放通过重写 `get_drag_data()` 与 `can_drop_data()` / `drop_data()` 实现。]

---

#### Ability / Skill Icon

**Category**: Game-Specific
**Status**: Draft
**When to Use**: HUD 技能栏中的技能按钮、技能树节点，以及任何需要显示技能可用
状态的场景。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Available | 图标完全不透明。下方显示按键绑定标签。 | |
| On cooldown | 从 12 点方向顺时针消退的径向遮罩。剩余时间 > 2 秒时在中央以数字显示。 | |
| Charges remaining | 图标下方的充能点数指示（例如 3 个实心圆 = 3 层充能）。为屏幕阅读器提供数字替代。 | |
| Out of resource | 图标去饱和至约 20%。边框变暗。按键绑定标签变暗。与冷却不同——这是资源受限，而非时间受限。 | |
| Locked / not unlocked | 仅显示图标剪影（不可见完整美术）。锁形角标。可在提示框中显示解锁条件。 | |
| Active / channeling | 边框脉动。径向填充显示剩余引导持续时间。 | |
| Just activated | 短暂缩放至 0.9x 后弹回 1.0x（过冲到 1.05x）。 | 示例：Guild Wars 2 与 Path of Exile 都在技能使用时采用按下-回弹动画来确认激活。尊重减少动态效果设置。 |

**Accessibility**: 所有冷却/充能信息都必须有数值形式（屏幕阅读器无法解析径向遮罩）。
冷却计时数字满足了这一点。技能名称与描述必须通过提示框暴露给屏幕阅读器。

**Implementation Notes**: [Godot：自定义 `TextureButton` 子类，配以叠加的 `Control`
节点实现冷却径向与充能点。冷却径向可用 `ColorRect` 上的自定义着色器旋转遮罩——
若引擎支持，也可用样式化为圆形的 `ProgressBar` 实现。请对照
engine-reference/godot/ 核实 Godot 4.7 对该模式的着色器支持情况。]

---

#### Health / Resource Bar

**Category**: Game-Specific
**Status**: Draft
**When to Use**: HUD 中任何代表关键玩家资源、连续变化的数值。生命、法力、耐力、
护盾、燃料。

**States and behaviors**:

| Event | Visual | Audio | Duration |
|-------|--------|-------|---------|
| Value decrease (damage) | 填充收缩。填充上短暂闪现"受击特效"（白色或红色闪烁）。残影条停留在原数值，并在 0.5 秒内逐渐下降至新数值（"伤害指示"）。 | [受击音效——随伤害量变化] | 立即下降，残影条 500ms 消退 |
| Value increase (heal) | 填充增长。短暂的治疗色闪光（绿色——用图标/辉光作为色盲安全的后备）。 | [治疗音效] | 300ms 缓入 |
| Below 25% threshold | 填充颜色变为警告状态。边框脉动（或在减少动态效果模式下显示静态角标）。可选：心跳音频提示（若音频是唯一信号，须配以视觉）。 | [低生命音效——循环播放直到回到阈值以上] | 持续 |
| At zero | 条清空。可选：条短暂抖动。触发死亡/耗尽事件。 | [死亡/耗尽音效] | 200ms 抖动 |
| Maximum | 填充为 100%，短暂发光。 | — | 200ms |
| Overflow (shield) | 在自然填充区域之外出现一段独立条，使用护盾颜色。 | [获得护盾音效] | 200ms |

**Accessibility**: 当前数值必须以数字形式可获取（提示框或常驻显示，或两者兼有）。
颜色编码的阈值状态必须有非颜色后备（图标、闪烁或音画警告）。25% 的警告状态必须有
独立于颜色变化的视觉信号。

**Implementation Notes**: [Godot：用两个重叠的 `ProgressBar` 节点实现残影条效果——
后条保留原数值（通过 Tween 消退），前条保留当前数值（即时更新）。阈值状态触发前条
的 `StyleBoxFlat` 切换。残影条 Tween 时长可作为设计师参数调节。]

---

#### Dialogue Box

**Category**: Game-Specific
**Status**: Draft
**When to Use**: 非玩家角色（NPC）对话、有配音的叙事对白、通过角色传达的教程文本。
所有有说话人的对话。

**Structure**: 说话人肖像或姓名标签（框体顶部或左侧）。对白文本正文。继续/推进提示
（右下角）。可选：全部跳过按钮、配音指示、字幕指示。

**States and behaviors**:

| State | Visual | Input | Response | Duration |
|-------|--------|-------|----------|---------|
| Line entering | 文本逐字显现（打字机效果）。或者：若设置了无障碍选项，文本以全速淡入。 | — | — | 速度：可在无障碍设置中配置 |
| Revealing | 文本正在动画显现。继续提示隐藏，或以缓慢的不透明度脉动。 | [任意推进输入] | 立即跳到当前行结尾（显示整行，停止打字机效果） | 即时 |
| Line complete | 显示完整行。继续提示可见并播放动画。 | — | — | — |
| Advancing to next line | 继续提示隐藏。文本淡出或擦除。新行开始。 | [任意推进输入]——Enter / A / Cross / Space / 鼠标点击 | 推进 | 100ms 过渡 |
| Choices appearing | 对白文本下方出现选项按钮。继续提示隐藏。导航焦点移至第一个选项。 | 方向键 / 键盘选择，Enter / A / Cross 确认 | 选择选项 | 150ms 进入动画 |
| Closing | 框体淡出 | 推进最后一行 | 将控制权交还玩家 | 200ms |
| Skipping all (if supported) | 简短的确认提示："Skip dialogue?" | 专用跳过按钮 | 跳至对话后状态 | — |

**Accessibility**: 所有有配音的对白默认始终开启字幕。打字机动画速度是用户设置项
（见 accessibility-requirements.md）。对话框不得自动推进——节奏必须由玩家掌控。
说话人姓名始终显示。所有选项按钮都必须可用键盘与手柄导航。选项必须对屏幕阅读器
可访问，并播报其位置。

**Implementation Notes**: [Godot：使用启用 `bbcode_enabled` 的 `RichTextLabel`
进行格式化。打字机效果通过 `Timer` 动画化 `visible_characters` 属性实现。将推进
输入绑定到某个函数，该函数要么跳过打字机效果（设 `visible_characters = -1`），
要么推进对话状态。说话人姓名显示在框体上方或旁边的独立 `Label` 中。对话数据从
JSON 或专用对话格式加载（例如适用于 Godot 的 Dialogic、Yarn Spinner）。]

---

#### Context Action Prompt

**Category**: Game-Specific
**Status**: Draft
**When to Use**: 在可交互游戏对象附近出现的提示，说明玩家可以做什么。"Press [A] to
open chest."（"按 [A] 打开箱子。"）"Hold [E] to pick up."（"按住 [E] 拾取。"）
玩家进入交互区域时出现，离开时消失。

**States**:

| State | Visual | Notes |
|-------|--------|-------|
| Appearing | 淡入，并从对象锚点上升 8px。 | 尊重减少动态效果设置——仅淡入，不上升 |
| Idle | 符合平台规范的按键图标 + 动作标签。图标匹配当前输入方式（玩家切换时更新）。 | 始终显示符合平台规范的图标——不要为所有平台硬编码"Press A" |
| Holding (for hold inputs) | 按键图标上的径向填充显示按住进度。标签改为进行时动词（"Opening..."）。 | |
| Cannot interact (blocked) | 图标变暗。若原因已知则显示原因（"Too heavy"、"Need key"）。 | 可选——仅当原因对玩家有意义时才显示受阻状态 |
| Disappearing | 淡出。 | 玩家离开交互区域时触发 |

**Accessibility**: 按键图标必须配有文本标签——不要只依赖图标（部分玩家使用自定义
按键标签或图标非标准的自适应控制器）。提示的放置位置不得与角色生命值或关键 HUD
信息重叠。

**Implementation Notes**: [Godot：作为可交互对象的 `Node3D` 子节点（2D 中为 `Node2D`
子节点）挂载。3D 游戏使用 `BillboardMesh` 或带 UI 场景的 `SubViewport`——这样无需
代码即可让提示始终面向镜头。根据 `Input.get_joy_name()` 或通过 `InputEventKey` 与
`InputEventJoypadButton` 检测键盘，来更新按键图标贴图。按住进度通过
`AnimationPlayer` 或在径向遮罩着色器上的 `Tween` 实现。]

---

#### Damage Number

**Category**: Game-Specific
**Status**: Draft
**When to Use**: 战斗参与者上方漂浮的反馈数字。普通伤害、暴击伤害、治疗、未命中。

**Variants**:

| Variant | Visual | Notes |
|---------|--------|-------|
| Normal damage | 白色数字，常规字重，中等字号。 | |
| Critical hit | 更大字号（1.5x），粗体，橙色或黄色——需验证色盲安全。出现时有短暂缩放冲击（1.3x → 1.0x）。 | 示例：Path of Exile 与 Diablo IV 都用缩放弹跳表现暴击，使其仅凭大小、不依赖颜色就能立即识别。 |
| Healing | 绿色（需验证色盲安全——用 + 前缀与向上轨迹作为非颜色后备）。 | |
| Miss / Evade | "MISS" 文本，灰色，斜体。以较小字号漂浮。 | |
| Status damage (DoT) | 较小字号，颜色与状态效果对应。 | |

**Behavior**: 数字在 1.0 秒内从命中位置向上漂浮。数字在最后 0.4 秒内从 100% 淡至
0%。快速连续命中产生的多个数字会在水平方向错开以避免重叠。屏幕上同时显示的伤害
数字上限：[按游戏定义——通常每个角色 8-12 个]。

**Accessibility**: 伤害数字纯属补充反馈——它们绝不能成为理解战斗状态的唯一途径。
生命条才是权威来源。提供完全关闭伤害数字的选项（部分玩家觉得它们在视觉上过于
杂乱）。关闭后，游戏必须仍然完全可玩。

**Implementation Notes**: [Godot：通过对象池回收的 `Label3D`（3D 游戏）或 `Label`
（2D 游戏）实例池。每个实例在生成时被赋予随机的微小水平偏移（±20px）以减少重叠。
漂浮动画通过 `position.y` 与 `modulate.a` 上的 `Tween` 实现。暴击缩放弹跳通过
在缩放上使用 `EASE_OUT` 的 Tween 后接线性回稳实现。]

---
