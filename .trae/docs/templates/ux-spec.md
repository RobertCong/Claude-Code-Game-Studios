# UX Spec: [Screen/Flow Name]

> 编写指导：.trae/docs/templates/guidance/ux-spec-guide.md（按小节加载，不要整份通读）。

> **Status**: [In Design | In Review | Approved | Implemented]
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Journey Phase(s)**: [from context]
> **Screen / Flow Name**: [代码与工单中使用的短标识，例如 `InventoryScreen`、`NewGameFlow`]
> **Platform Target**: [来自 2h 的目标平台与输入方式]
> **Related GDDs**: [指向生成本 UI 需求的 GDD 小节链接，例如 `design/gdd/inventory.md § UI Requirements`]
> **Related ADRs**: [约束此界面的架构决策，例如 `ADR-0012: UI Framework Selection`]
> **Related UX Specs**: [同级与父级界面，例如 `pause-menu.md`、`settings.md`]
> **Accessibility Tier**: Basic | Standard | Comprehensive | Exemplary
> **Template**: UX Spec

> **Note — Scope boundary**：本模板覆盖独立界面与流程（菜单、对话框、
> 背包、设置、过场动画 UI 等）。对于在游玩过程中持续存在的常驻游戏内浮层，
> 请改用 `hud-design.md`。如果某个界面是混合形态（例如覆盖在游戏世界之上的
> 暂停菜单），请把它当作界面规格来处理，并在 Navigation Position 中说明其覆盖关系。

---

## 1. Purpose & Player Need

[To be designed]

**这个界面服务的是玩家的什么需求？**

[一段话——从玩家视角出发的真实人类需求，而不是系统功能。好/坏示例见指导文档第 1 节。]

**玩家目标**（玩家想要完成什么）：

[一句话，要具体到可以据此写出验收标准。]

**游戏目标**（游戏需要传达或捕获什么）：

[一句话——系统需要从这次交互中得到什么。]

---

## 2. Player Context on Arrival

[To be designed]

| Question | Answer |
|----------|--------|
| 玩家刚刚在做什么？ | [此前的活动 / 触发状态] |
| 他们的情绪状态如何？ | [紧张 / 平静 / 急迫] |
| 他们承载着怎样的认知负荷？ | [高 / 低 + 他们正在关注什么] |
| 他们已经掌握了哪些信息？ | [进入时已知的上下文] |
| 他们最可能想做什么？ | [主要用例] |
| 他们可能担心什么？ | [需要针对性设计规避的风险与焦虑] |

**这个界面的情感设计目标**：

[一句话描述玩家在使用此界面时应当有的感受。]

---

## 3. Navigation Position

[To be designed]

**界面层级**（用缩进表示父子关系）：

```
[Root — e.g., Main Menu]
  └── [Parent Screen — e.g., Settings]
        └── [This Screen — e.g., Audio Settings]
              ├── [Child Screen — e.g., Advanced Audio Options]
              └── [Child Screen — e.g., Speaker Test Dialog]
```

**模态行为**：[Modal（阻挡其后方的一切，需要显式关闭）| Non-modal（后方游戏继续运行）| Overlay（渲染在游戏世界之上，游戏暂停）| Overlay-live（渲染在游戏世界之上，游戏继续运行）]

> 如果这个界面是模态的：请记录关闭行为。可以按 Back/B 关闭吗？按 Escape 能关闭吗？
> 点击界面外部能关闭吗？它究竟能否被关闭，还是必须由玩家完成？
> 不可关闭的模态窗口摩擦很大——请为其正当性给出理由。

**可达性——所有入口**：

| Entry Point | Triggered By | Notes |
|-------------|-------------|-------|
| [Entry point] | [Trigger] | [Notes] |

---

## 4. Entry & Exit Points

[To be designed]

> 每个入口都必须有对应的出口。空单元格意味着设计工作尚未完成。
> 完整示例见指导文档第 4 节。

**入口表**：

| Trigger | Source Screen / State | Transition Type | Data Passed In | Notes |
|---------|----------------------|-----------------|----------------|-------|
| [Trigger] | [Source] | [Transition] | [Data in] | [Notes] |

**出口表**：

| Exit Action | Destination | Transition Type | Data Returned / Saved | Notes |
|-------------|------------|-----------------|----------------------|-------|
| [Exit action] | [Destination] | [Transition] | [Data out / committed] | [Notes] |

---

## 5. Layout Specification

### 5.1 ASCII Wireframe

[To be designed]

```
[Draw the screen layout using ASCII art. Suggested characters:
 ┌ ┐ └ ┘ │ ─    for borders
 ╔ ╗ ╚ ╝ ║ ═    for emphasized/modal borders
 [ ]              for interactive elements (buttons, inputs)
 { }              for content areas (lists, grids, images)
 ...              for scrollable content
 ●                for the focused element on open

See guide Section 5 for a completed example wireframe.]
```

### 5.2 Layout Zones

[To be designed]

| Zone Name | Description | Approximate Size | Scrollable? | Overflow Behavior |
|-----------|-------------|-----------------|-------------|-------------------|
| [Zone] | [内容与用途] | [% width x % height] | [Yes/No] | [溢出处理方式] |

### 5.3 Component Inventory

[To be designed]

> 列出此界面上的每一个独立 UI 组件。这张表会驱动实现任务清单——
> 每一行都会变成一个需要新建或复用的组件。

| Component Name | Type | Zone | Purpose | Required? | Reuses Existing Component? |
|----------------|------|------|---------|-----------|---------------------------|
| [Component] | [Type] | [Zone] | [Purpose] | [Yes/No] | [Yes — pattern/component name, or No — new] |

**打开时的主焦点元素**：[界面打开时获得焦点的元素，包括深链接与空状态情形]

### 5.4 Information Hierarchy

[To be designed]

[玩家在这个界面上必须先看到什么、其次看到什么、以及什么可以藏在
标签页、滚动区或按钮之后——按此顺序，并说明每一项的理由。]

---

## 6. States & Variants

[To be designed]

> 在实现之前记录每一种状态——至少包括：加载、空、有内容、错误。
> 状态表同时也是 QA 的测试矩阵。完整示例见指导文档第 6 节。

| State Name | Trigger | What Changes Visually | What Changes Behaviorally | Notes |
|------------|---------|----------------------|--------------------------|-------|
| [Loading / Empty / Populated / Selected / Confirmation / Error / other] | [Trigger] | [视觉变化] | [行为变化] | [Notes] |

---

## 7. Interaction Map

[To be designed]

> 覆盖目标平台上的每一种输入方式（鼠标、键盘、手柄、触屏）。
> 这张表里的缺口就是等着发生的缺陷。见指导文档第 7 节。

### 7.1 Navigation Inputs

| Input | Platform | Action | Visual Response | Audio Cue | Notes |
|-------|----------|--------|-----------------|-----------|-------|
| [Input] | [Platform] | [Action] | [视觉反馈] | [音频] | [Notes] |

### 7.2 Action Inputs

| Input | Platform | Context (What must be focused) | Action | Response | Animation | Audio Cue | Notes |
|-------|----------|-------------------------------|--------|----------|-----------|-----------|-------|
| [Input] | [Platform] | [焦点上下文] | [Action] | [Response] | [动画 + 时长] | [音频] | [Notes] |

### 7.3 State-Specific Behaviors

| State | Input Restriction | Reason |
|-------|------------------|--------|
| [State] | [哪些输入被禁用] | [为什么] |

---

## 8. Data Requirements

[To be designed]

> UI 只读取数据，不拥有数据。UI 只触发事件，不直接写入状态。
> 每一个展示的数据元素都需要有来源系统与归属方。
> 完整示例见指导文档第 8 节。

| Data Element | Source System | Update Frequency | Who Owns It | Format | Null / Missing Handling |
|--------------|--------------|-----------------|-------------|--------|------------------------|
| [Data element] | [System] | [何时更新——具体的触发时机，而不是"实时"] | [归属系统——绝不是 UI] | [类型/结构] | [数据不可用时显示什么] |

> **Rule**：此界面绝不能直接写入上表列出的任何系统。所有玩家操作都触发事件
> （见第 9 节）。各系统自行更新数据并通知 UI。

---

## 9. Events Fired

[To be designed]

> 每一个具有破坏性或会改变状态的玩家操作都必须出现在这张表中。
> 完整示例见指导文档第 9 节。

| Player Action | Event Fired | Payload | Receiver System | Notes |
|---------------|-------------|---------|-----------------|-------|
| [Action] | [EventName] | [{fields}] | [System] | [校验/响应流程，或"仅遥测"] |

---

## 10. Transitions & Animations

[To be designed]

> 至少说明界面的进入与退出转场，以及各自在减弱动效模式下的行为。
> 完整示例见指导文档第 10 节。

| Transition | Trigger | Direction / Type | Duration (ms) | Easing | Interruptible? | Skipped by Reduced Motion? |
|------------|---------|-----------------|--------------|--------|----------------|---------------------------|
| [Screen enter / exit / in-screen transition] | [Trigger] | [Type] | [ms] | [Easing] | [Yes/No] | [Yes/No + fallback] |

---

## 11. Input Method Completeness Checklist

[To be designed]

> 在把规格标记为 Approved 之前完成这份清单。任何未勾选项
> 都会阻止实现启动。

**Keyboard**
- [ ] 所有交互元素仅用 Tab 与方向键即可到达
- [ ] Tab 顺序遵循视觉阅读顺序（每个区域内从左到右、从上到下）
- [ ] 鼠标能完成的每个操作，键盘同样能完成
- [ ] 焦点始终可见（不存在焦点环消失的元素）
- [ ] 界面打开期间焦点不会逸出界面（模态窗口需做焦点陷阱）
- [ ] Esc 键可关闭或取消（且不会在界面内退出游戏）

**Gamepad**
- [ ] 所有交互元素都可用 D-Pad 与左摇杆到达
- [ ] 面键映射有记录，且符合平台惯例（见第 7.2 节）
- [ ] 没有任何操作需要 D-Pad 无法复现的摇杆精度
- [ ] 如使用扳机键与肩键快捷键，已记录
- [ ] 界面打开期间手柄断连能被优雅处理

**Mouse**
- [ ] 所有交互元素都定义了悬停状态
- [ ] 可点击的命中区域至少为 32x32px（推荐 44x44px）
- [ ] 右键行为已定义（上下文菜单或无操作——不能是未定义）
- [ ] 所有可滚动区域都定义了滚轮行为

**Touch（如适用）**
- [ ] 所有触控目标至少为 44x44px
- [ ] 滑动手势不会与系统级滑动导航冲突
- [ ] 在竖屏下所有操作都可单手完成
- [ ] 如使用长按，已定义其行为

---

## 12. Accessibility

[To be designed]

> 项目级标准位于 `design/accessibility-requirements.md`——填写本节前请先查阅，
> 以免与项目级承诺重复或冲突。
>
> 本项目中的无障碍层级：
> - Basic：WCAG 2.1 AA 文字对比度、可键盘导航、无仅靠动效传达的信息
> - Standard：Basic + 屏幕阅读器支持、色盲安全、焦点管理
> - Comprehensive：Standard + 减弱动效支持、文字缩放、高对比度模式
> - Exemplary：Comprehensive + 认知负荷管理、AAA 等效、已认证

**此界面的文字对比度要求**：

| Text Element | Background Context | Required Ratio | Current Ratio | Pass? |
|--------------|-------------------|---------------|---------------|-------|
| [Text element] | [Background] | [Ratio — 4.5:1 WCAG AA baseline] | [TBD] | [ ] |

**色盲不安全的元素及其缓解措施**：

| Element | Colorblind Risk | Mitigation |
|---------|----------------|------------|
| [Element] | [风险类型] | [不依赖颜色的冗余指示] |

**焦点顺序**（Tab 键顺序，带编号）：

[覆盖每一个交互元素的编号焦点序列，包括循环行为，以及焦点不会进入的任何面板——示例见指导文档第 12 节]

**关键状态变化的屏幕阅读器播报**：

| State Change | Announcement Text | Announcement Timing |
|--------------|------------------|---------------------|
| [State change] | ["Announcement"] | [何时触发] |

**认知负荷评估**：

[统计玩家在此界面上同时关注的信息流数量；对照 7±2 上限，并说明缓解措施——示例见指导文档第 12 节]

---

## 13. Localization Considerations

[To be designed]

**此界面的通用规则**：
- 所有文字元素必须能承受相对英文基线至少 40% 的膨胀
- RTL 布局（阿拉伯语、希伯来语）：需要镜像布局——记录哪些元素镜像、哪些不镜像
- CJK 语言（日语、韩语、中文）：文字可能短 20-30%——验证布局在文字较少时不会显得破损
- 不要在图片中使用文字——所有文字都必须来自本地化字符串

| Text Element | English Baseline Length | Max Characters | Expansion Budget | RTL Behavior | Overflow Behavior | Risk |
|--------------|------------------------|----------------|-----------------|--------------|-------------------|------|
| [Text element] | [chars] | [max chars] | [%] | [镜像/对齐行为] | [截断/滚动/缩放策略] | [Low/Medium/High] |

---

## 14. Acceptance Criteria

[To be designed]

> 编写 QA 测试员可以独立验证的标准，无需再向设计者询问其含义。
> 每条标准都应是二元的——通过或不通过，而非主观判断。

**Performance**
- [ ] 在最低配置硬件上，界面在触发后 [200]ms 内打开（首帧可见）
- [ ] 在最低配置硬件上，界面在触发后 [500]ms 内完全可交互（所有数据加载完毕）
- [ ] 元素间导航不会产生可感知的掉帧（保持目标帧率 ±5fps）

**Layout & Rendering**
- [ ] 界面在最低支持分辨率 [specify] 下正确显示（无重叠、无裁切、无溢出）
- [ ] 界面在最高支持分辨率 [specify] 下正确显示
- [ ] 若目标平台为 PC，界面在 4:3、16:9、16:10 与 21:9 宽高比下均正确显示
- [ ] 英文在定义的最大字符范围内无文字溢出或截断
- [ ] 在译文最长的语言中无文字溢出或截断 [specify — typically German]
- [ ] 第 6 节记录的所有状态均正确渲染
- [ ] 可滚动区域在内容填满时滚动流畅、无掉帧

**Input**
- [ ] 所有交互元素都可用键盘仅通过 Tab 与方向键到达
- [ ] 所有交互元素都可用手柄仅通过 D-Pad 与面键到达
- [ ] 所有交互元素都可用鼠标到达，无需键盘
- [ ] 没有任何操作需要第 7 节未记录的组合输入
- [ ] 键盘与手柄导航时焦点始终可见
- [ ] 界面打开期间焦点不会逸出界面

**Events & Data**
- [ ] 第 9 节的所有事件在所有退出路径上都以正确负载触发（用调试日志验证）
- [ ] 界面不会直接写入任何游戏系统（验证：没有直接的状态变更调用）
- [ ] 在此界面上所做的更改在关闭并重新打开后能正确保留
- [ ] 界面打开期间能处理其他系统触发的数据变更事件，且不会崩溃

**Accessibility**
- [ ] 所有文字都满足第 12 节规定的最低对比度
- [ ] 没有任何信息仅靠颜色作为唯一区分手段
- [ ] 屏幕阅读器会播报记录在案的状态变化（用平台屏幕阅读器验证）
- [ ] 减弱动效设置下转场为瞬时完成（无动画转场）
- [ ] 高对比度模式（如适用于该无障碍层级）渲染时无视觉破损

**Localization**
- [ ] 在任何支持的语言下，没有文字元素溢出其容器
- [ ] RTL 布局正确渲染（如果 RTL 是目标语言）
- [ ] 所有文字元素都由本地化字符串驱动——没有硬编码的显示文字

---

## 15. Open Questions

[To be designed]

> 在此跟踪未解决的设计问题。每个问题都应有明确的负责人
> 与截止时间。一份 Approved 状态的规格必须没有未决问题——要么给出决定，
> 要么明确记录延后处理的理由。

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [Add question] | [Owner] | [Deadline] | [Resolution] |
