# HUD Design

> 编写指引：.trae/docs/templates/guidance/hud-design-guide.md（编写时按章节加载——不要整体通读）。

> **Status**: [In Design | In Review | Approved | Implemented]
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Game**: [游戏名称——每款游戏一份文档，而不是每个元素一份]
> **Platform Targets**: [来自 2h 的目标平台与输入方式]
> **Related GDDs**: [所有通过 HUD 暴露信息的系统——例如 `design/gdd/combat.md`、`design/gdd/progression.md`、`design/gdd/quests.md`]
> **Accessibility Tier**: Basic | Standard | Comprehensive | Exemplary
> **Style Reference**: [指向美术圣经的 HUD 章节（如存在）——例如 `design/art/art-bible.md § 7. UI/HUD Visual Direction`]
> **Template**: HUD Design

> **Note — Scope boundary**: 本文档规定游戏过程中覆盖在游戏世界之上的
> 所有元素——生命条、弹药计数、小地图、任务追踪器、字幕、伤害数字
> 和通知 toast。对于玩家显式导航的菜单界面、暂停菜单、物品栏和对话框，
> 请改用 `ux-spec.md`。判断标准：如果它在玩家直接控制角色时出现，
> 就属于本文档。

---

## 1. HUD Philosophy

[To be designed]

**本游戏与屏幕信息的关系是什么？**

[一段设计陈述——框架与示例见指引 Section 1]

**Visibility principle**——拿不准时，显示还是隐藏？

[模糊情况下的默认处理：HIDE / SHOW / CONTEXTUAL——见指引]

**The Rule of Necessity for this game**:

["当 ______________ 时，一个 HUD 元素才配得上它的位置。"——示例见指引]

---

## 2. Information Architecture

> 对游戏生成的每一条信息进行分类——这是游戏信息的总清单，
> 而不只是 HUD 信息。涵盖常见信息类型的完整示例见指引 Section 2。

### 2.1 Full Information Inventory

[To be designed]

[游戏生成的每一条信息，每行一条——生命值、资源、目标、计时器、状态效果、字幕等其余内容——无论 HUD 是否显示它。]

### 2.2 Categorization

[To be designed]

| Information Type | Always Show | Contextual (show when relevant) | On Demand (menu/button) | Hidden (environmental / diegetic) | Reasoning |
|-----------------|-------------|--------------------------------|------------------------|----------------------------------|-----------|
| [信息类型——例如：生命值、资源、小地图、任务目标、字幕、状态效果、计时器、经验值] | [ ] | [ ] | [ ] | [ ] | [为何采用这种呈现类别] |

---

## 3. Layout Zones

[To be designed]

### 3.1 Zone Diagram

```
[Draw your HUD layout zones. Customize this to match your game's actual layout.
 Axes represent approximate screen percentage. Adjust zone names and sizes.]

 0%                                             100%
 ┌──────────────────────────────────────────────────┐  0%
 │  [SAFE MARGIN — 10% from edge on all sides]      │
 │  ┌────────────────────────────────────────────┐  │
 │  │ [TOP-LEFT]              [TOP-CENTER]  [TOP-RIGHT] │  ~15%
 │  │  Health, resource       Quest name    Ammo, magazine │
 │  │                                              │  │
 │  │                                              │  │
 │  │               [CENTER-SCREEN]               │  │  ~50%
 │  │                Crosshair / reticle           │  │
 │  │               (minimize HUD here)            │  │
 │  │                                              │  │
 │  │                                              │  │
 │  │ [BOTTOM-LEFT]     [BOTTOM-CENTER]   [BOTTOM-RIGHT] │  ~85%
 │  │  Minimap          Subtitles          Notifications │
 │  │  Ability icons    Tutorial prompts             │  │
 │  └────────────────────────────────────────────┘  │
 │                                                  │
 └──────────────────────────────────────────────────┘  100%
```

> 区域放置规则：屏幕中央 40%（水平和垂直方向）是玩家的主要关注区域。
> 任何时刻都应尽量保持该区域干净。出现在中央区域的 HUD 元素——准星、
> 交互提示、命中标记——必须极简、高对比度且短暂。

### 3.2 Zone Specification Table

| Zone Name | Screen Position | Safe Zone Compliant | Primary Elements | Max Simultaneous Elements | Notes |
|-----------|----------------|---------------------|-----------------|--------------------------|-------|
| [区域] | [位置] | [是/否 + 边距] | [分配的元素] | [N] | [区域用途] |

**Safe zone margins by platform**:

| Platform | Top | Bottom | Left | Right | Notes |
|----------|-----|--------|------|-------|-------|
| [Platform] | [%] | [%] | [%] | [%] | [平台特定备注] |

---

## 4. HUD Element Specifications

[To be designed]

### 4.1 Element Overview Table

> 每个 HUD 元素一行。这是用于实现规划的总清单。

| Element Name | Zone | Always Visible | Visibility Trigger | Data Source | Update Frequency | Max Size (% screen W) | Min Readable Size | Overlap Priority | Accessibility Alt |
|-------------|------|---------------|-------------------|-------------|-----------------|----------------------|------------------|-----------------|------------------|
| [元素] | [区域] | [是/否] | [触发条件或 N/A] | [所属系统] | [何时更新] | [%] | [px] | [N] | [非视觉/非颜色替代方案] |

### 4.2 Element Detail Blocks

> 为上表中的每个元素编写一个详情块。每个元素复制并填写一个块。
> 已完成的生命条和小地图示例见指引 Section 4。

---

**[Element Name]**

- Visual description: [形状、填充方向、背景、颜色行为]
- Data displayed: [显示的值，包括任何数字文本标签]
- Update behavior: [动画/插值时长、大幅变化时的闪烁行为]
- Urgency states: [各阈值的视觉状态，例如 Normal / Caution / Critical / Zero]
- Interaction: [可交互或仅显示]
- Player customization: [不透明度、重新定位、大小选项]

---

**[对 Section 4.1 中的每个元素重复此块]**

---

## 5. HUD States by Gameplay Context

[To be designed]

> 为每种玩法情境定义 HUD 的转换——至少包括：
> 探索、战斗、对话/过场动画，以及暂停/菜单。涵盖九种情境的完整示例
> 见指引 Section 5。

| Context | Elements Shown | Elements Hidden | Elements Modified | Transition Into This State |
|---------|---------------|-----------------|------------------|---------------------------|
| [情境——例如：探索 / 战斗 / 对话 / 过场动画 / 菜单打开 / 死亡 / 加载 / 教程 / 首领战] | [显示] | [隐藏] | [修改] | [转场时机 + 触发] |

---

## 6. Information Hierarchy

[To be designed]

> 为每个元素分配优先级层级（MUST KEEP / SHOULD KEEP / CAN HIDE /
> ALWAYS HIDE）并说明理由。完整示例见指引 Section 6。

| Element | Priority Tier | Reasoning | What Replaces It If Hidden |
|---------|--------------|-----------|---------------------------|
| [元素] | [MUST KEEP / SHOULD KEEP / CAN HIDE / ALWAYS HIDE] | [原因] | [替代渠道或 N/A] |

---

## 7. Visual Budget

[To be designed]

> 这些数字是硬性限制，不是指导值。任何会突破限制的元素新增
> 都需要明确批准，并且必须替换或削减现有元素。预算的应用方式
> 见指引 Section 7。

| Budget Constraint | Limit | Measurement Method | Current Estimate | Status |
|------------------|-------|--------------------|-----------------|--------|
| 同时激活的 HUD 元素最大数量 | [8] | [统计任意一帧中所有可见、未淡出的元素] | [TBD——实现时验证] | [To verify] |
| HUD 占屏幕百分比上限（探索模式） | [12%] | [所有 HUD 元素的像素面积 / 屏幕总像素] | [TBD] | [To verify] |
| HUD 占屏幕百分比上限（战斗模式） | [22%] | [相同方法——战斗会增加弹药、准星、敌人血条] | [TBD] | [To verify] |
| 中央屏幕区域（屏幕宽高的 40%）占用上限 | [5%] | [此处只允许准星和交互提示] | [TBD] | [To verify] |
| 最低对比度——任意背景上的 HUD 文本 | [4.5:1 (WCAG AA)] | [对照元素将要出现的游戏世界最暗和最亮区域测量] | [TBD] | [To verify] |
| HUD 背景面板最大不透明度 | [65%] | [HUD 文本后方任何面板的不透明度——必须保留透过面板看到世界的可见性] | [TBD] | [To verify] |
| 最低支持分辨率下的最小 HUD 元素尺寸 | [图标 40px，文本 18px] | [在最低目标分辨率下测量] | [TBD] | [To verify] |

---

## 8. Feedback & Notification Systems

[To be designed]

> 每种通知类型一行。每条通知都必须定义队列/优先级行为。
> 示例表与队列规则见指引 Section 8。

| Notification Type | Trigger System | Screen Position | Duration (ms) | Animation In / Out | Max Simultaneous | Priority | Queue Behavior | Dismissible? |
|------------------|---------------|-----------------|--------------|-------------------|-----------------|----------|---------------|-------------|
| [类型] | [系统] | [区域] | [ms] | [进入/退出动画 + 时机] | [N] | [优先级] | [队列/合并/抢占行为] | [是/否] |

**Notification queue rules**:
1. [战斗感知的队列规则——战斗期间哪些优先级会被暂缓，以及队列如何清空]
2. [合并规则——相同类型的通知何时合并为一条]
3. [关键绕过规则——哪些通知永不排队、永不合并]

---

## 9. Platform Adaptation

[To be designed]

> 每个目标平台在认证前都需要进行显式的布局测试。
> 完整示例见指引 Section 9。

| Platform | Safe Zone | Resolution Range | Input Method | HUD-Specific Notes |
|----------|-----------|-----------------|-------------|-------------------|
| [Platform] | [边距] | [最小–最大分辨率] | [输入] | [平台特定的 HUD 约束] |

**HUD repositionability requirement**: 玩家必须能够通过游戏内 HUD 布局编辑器，至少重新定位以下元素（主机平台的无障碍合规要求）：
- [生命条]
- [小地图]
- [技能栏（如存在）]

重新定位会保存到玩家配置，而不是单个存档槽。跨游玩会话生效。

---

## 10. Accessibility

[To be designed]

> 仅限 HUD 特定要求——完整项目标准请参考项目的
> `design/accessibility-requirements.md`。

### 10.1 Colorblind Modes

| Element | Color-Only Information Risk | Colorblind Mode Fix |
|---------|----------------------------|---------------------|
| [元素] | [仅靠颜色承载含义的地方] | [非颜色替代方案：形状、图标、符号、文本] |

### 10.2 Text Scaling

[描述 UI 文本缩放至 150% 时会发生什么：哪些元素会重排、裁切，或因架构原因无法缩放——示例叙述见指引 Section 10]

**Text scaling test matrix**:

| Element | 100% (baseline) | 125% | 150% | Overflow behavior |
|---------|----------------|------|------|-------------------|
| [元素] | [Pass/Fail/TBD] | [Pass/Fail/TBD] | [Pass/Fail/TBD] | [溢出时如何处理] |

### 10.3 Motion Sensitivity

| Animation / Motion Element | Severity | Disabled by Reduced Motion Setting? | Replacement Behavior |
|---------------------------|----------|-------------------------------------|---------------------|
| [动画元素] | [Mild/Moderate/High] | [Yes/No/Optional] | [静态替代方案] |

### 10.4 Subtitles Specification

> 字幕是 HUD 中影响最大的无障碍功能。请以与 HUD 其余部分相同的严谨度
> 规定它们。不要把字幕行为留给实现者自行决定。

- **Default setting**: [开或关——记录本游戏的默认值及理由。行业标准是默认开启。]
- **Position**: [区域、对齐方式、与安全区边距的关系]
- **Max characters per line**: [例如 42 个字符——电视观看距离下最小文本大小的可读上限]
- **Max simultaneous lines**: [例如滚动前最多 2 行]
- **Speaker identification**: [姓名显示方式——绝不只依赖颜色]
- **Background**: [确保在任何游戏世界背景上都有足够对比度的面板处理]
- **Font size minimum**: [参考分辨率下的 px——随文本缩放设置缩放]
- **Line break behavior**: [在自然语言停顿处换行——绝不在单词中间断开]
- **Subtitle persistence**: [相对台词时长的保持时间——音频仍在播放时绝不消失]
- **Non-dialogue captions**: [环境音、音乐和音效是否配字幕，以及这些字幕出现在哪里]

### 10.5 HUD Opacity and Visibility Controls

以下玩家可调设置必须可从无障碍菜单中使用：

| Setting | Range | Default | Effect |
|---------|-------|---------|--------|
| [HUD Opacity — Global] | [0%（HUD 隐藏）到 100%] | [100%] | [同时缩放所有 HUD 元素的不透明度] |
| [HUD Text Scale] | [75% 到 150%] | [100%] | [缩放所有 HUD 文本元素；布局自适应] |
| [Damage Number Visibility] | [On / Off] | [On] | [启用或禁用所有浮动伤害数字] |
| [Minimap Visibility] | [On / Off / Compass Only] | [On] | [关闭小地图时显示罗盘条作为替代] |
| [Notification Verbosity] | [All / Important Only / Off] | [All] | [All = 所有 toast；Important Only = 任务 + 升级；Off = 无 toast] |
| [Motion Reduction] | [On / Off] | [Off] | [开启时，将所有动画 HUD 转场替换为即时状态切换] |
| [High Contrast Mode] | [On / Off] | [Off] | [对所有 HUD 元素应用高对比度视觉主题——HC 变体见美术圣经] |

---

## 11. Tuning Knobs

[To be designed]

> 在实现之前记录所有可调参数，让程序员知道哪些值需要外部化。
> 完整示例见指引 Section 11。

| Parameter | Current Value | Range | Effect of Increase | Effect of Decrease | Player Adjustable? | Notes |
|-----------|-------------|-------|-------------------|-------------------|-------------------|-------|
| [参数] | [值] | [最小–最大] | [效果] | [效果] | [是/否 + 如何暴露] | [调校备注] |

---

## 12. Acceptance Criteria

[To be designed]

> 这些标准是 HUD 的认证清单。在 HUD 能标记为 Approved 之前，
> 每一项都必须通过。QA 必须能够独立验证每一项。

**Layout & Visibility**
- [ ] 所有 HUD 元素在所有目标平台上都位于平台安全区边距之内
- [ ] 在记录的所有玩法情境中，没有两个 HUD 元素重叠
- [ ] 探索情境下 HUD 占屏幕面积小于 [12]%（在参考分辨率下测量）
- [ ] 战斗情境下 HUD 占屏幕面积小于 [22]%
- [ ] 探索过程中没有 HUD 元素占用屏幕中央 [40]%（战斗时准星除外）
- [ ] 所有 HUD 元素在所有平台的最低支持分辨率下都可见且清晰可读

**Per-Context Correctness**
- [ ] 在 Section 5 定义的每个情境中，HUD 都正确只显示规定的元素
- [ ] 情境转换（进入/退出战斗、对话、过场动画）在转场时间规格内显示正确的元素
- [ ] 首领血条在首领遭遇触发时正确出现，并在首领被击败后消失
- [ ] 死亡状态正确隐藏所有玩法 HUD 元素

**Accessibility**
- [ ] 所有 HUD 文本元素在其出现的所有背景上都满足 4.5:1 对比度（测试亮场景和暗场景）
- [ ] 没有 HUD 元素仅用颜色作为唯一区分手段（验证：从每个元素中移除颜色，确认信息仍能传达）
- [ ] 启用字幕后，所有配音台词和环境对话都有字幕
- [ ] 音频仍在播放时，字幕文本绝不消失
- [ ] Reduced Motion 设置会禁用 Section 10.3 中列出的所有 HUD 动画
- [ ] Text Scale 150% 不会导致任何 HUD 文本溢出容器或与另一元素重叠
- [ ] Section 10.5 中所有玩家可调 HUD 设置均可用，并在会话之间保持

**Notifications**
- [ ] 500ms 内触发的同类型通知合并为单条通知
- [ ] 低优先级通知在战斗期间排队（不显示），并在战斗结束后释放
- [ ] 关键警告（低生命值、危险）无论队列状态或战斗状态如何都立即出现
- [ ] 同时可见的通知 toast 不超过 [3] 条
- [ ] 关卡切换时通知队列正确清空（没有来自上一区域的过期通知）

**Platform**
- [ ] 所有元素在主机上遵守 10% 安全区边距（在真实电视上测试——不是显示器）
- [ ] HUD 在 1280x720（Steam Deck）下正确显示，没有元素被裁切或重叠
- [ ] HUD 元素可重新定位（生命值、小地图、技能栏），且重新定位设置会持久保留
- [ ] 游玩过程中手柄断开连接不会导致 HUD 状态损坏

---

## 13. Open Questions

[To be designed]

> 在此追踪未解决的设计问题。所有问题都必须在 HUD 设计文档
> 能标记为 Approved 之前解决。示例问题见指引 Section 13。

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [添加问题] | [Owner] | [Deadline] | [Resolution] |
