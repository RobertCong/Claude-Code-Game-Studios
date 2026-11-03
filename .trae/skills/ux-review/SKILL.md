---
name: ux-review
description: "验证 UX 规格、HUD 设计或模式库 — 无障碍、GDD 一致性、就绪度。APPROVED / NOT ASSESSED / NEEDS REVISION / MAJOR REVISION NEEDED。"
argument-hint: "[file-path or 'all' or 'hud' or 'patterns']"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys workflow`

上一步命令的输出已解析 — 直接使用。若无解析块 → 使用
`.trae/docs/config-resolution.md` 中的默认值。

# UX 评审

## 概述

在 UX 设计文档进入实现流水线之前对其进行验证。
在 `/team-ui` 流水线中充当 UX 设计与视觉设计/实现之间的质量闸门（gate）。

**运行本技能的场景：**
- 用 `/ux-design` 完成 UX 规格之后
- 交付给 `ui-programmer` 或 `art-director` 之前
- Pre-Production 到 Production 的质量闸门（gate）检查之前（该检查要求关键屏幕
  已有通过评审的 UX 规格）
- UX 规格经过重大修订之后

**结论级别：**
- **APPROVED** — 规格完整、一致且可实施
- **NOT ASSESSED** — 一个或多个评审维度没有可对照的标准，
  或规格无法读取；指出是哪些
- **NEEDS REVISION** — 发现具体缺口；交付前修复，但不需要完整重新设计
- **MAJOR REVISION NEEDED** — 在范围、玩家需求或完整性方面存在根本问题；
  需要大幅返工

**`NOT ASSESSED` 高于 APPROVED，低于两个修订结论。** 一次无法评估某个
维度的评审，并未证明规格可实施；但有人发现的缺口比无人能寻找的缺口
更具可操作性，因此它不能取代后者。当规格文件无法读取、当某个清单维度
没有可对照的事实来源，或当无障碍级别未承诺时（见下文），输出它。

---

## Phase 1: 解析参数

- **具体文件路径**（例如 `/ux-review design/ux/inventory.md`）：验证
  该文档
- **`all`**：查找 `design/ux/` 中的所有文件并逐一验证
- **`hud`**：专门验证 `design/ux/hud.md`
- **`patterns`**：专门验证 `design/ux/interaction-patterns.md`
- **无参数**：询问用户要验证哪份规格

对于 `all`，先输出摘要表（file | verdict | primary issue），然后
逐个输出完整详情。

**文件使用哪份清单**（一个文件路径，或 `all` 下的每个文件）：其
`> **Template**:` 头行，由 `/ux-design` 写入 — `UX Spec` → Phase 3A，
`HUD Design` → 3B，`Interaction Pattern Library` → 3C。没有该行的文件
按名称分类 — `hud.md` → 3B，`interaction-patterns.md` → 3C，其他任何文件
→ 3A — 报告需说明它假定了哪份清单及原因。

---

## Phase 2: 加载交叉引用上下文

在验证任何规格之前，加载：

1. **输入与平台配置**：从 `project.yaml` 读取 `platform` 块
   （`platform.targets`、`platform.primary_input`、`platform.gamepad_support`、
   `platform.touch_support`）；如果 `project.yaml` 没有 `platform` 块，则
   退回到 `.trae/docs/technical-preferences.md` 的 `## Input & Platform` 小节。对于支持的输入
   方式集合：从 `project.yaml` 读取时，推导它 — 如果
   `targets` 中有 `PC` 或 `Web`，则为键盘/鼠标；如果 `gamepad_support` 为 Full 或
   Partial，则为手柄；如果 `touch_support` 为 Full 或 Partial，则为触摸；
   再加上 `primary_input`。
   退回到 `technical-preferences.md` 时，改用其明确的 Input
   Methods 字段。这是 Phase 3A 中输入方式覆盖检查的
   权威来源 — 不是规格自身的头行。如果两个来源都
   未配置，退回到规格头行。
2. `design/accessibility-requirements.md` 中承诺的无障碍级别
   （如果存在）
3. 位于 `design/ux/interaction-patterns.md` 的交互模式库（如果
   存在）
4. 规格头行中引用的 GDD（阅读其 UI 要求小节：
   用 Grep 工具（模式 `^#`，内容模式）查找标题，然后用 offset 和 limit
   阅读那些范围）
5. 位于 `design/player-journey.md` 的玩家旅程图（如果存在），用于
   到访情境验证

---

## Phase 3A: UX 规格验证清单

对照基于 `ux-spec.md` 的文档运行所有检查。

### 完整性（必需小节）

- [ ] 存在文档头，包含 Status、Author、Platform Target
- [ ] Purpose & Player Need — 有玩家视角的需求陈述（而非
  开发者视角）
- [ ] Player Context on Arrival — 描述玩家状态和先前活动
- [ ] Navigation Position — 显示屏幕在层级中的位置
- [ ] Entry & Exit Points — 记录所有进入来源和退出目的地
- [ ] Layout Specification — 定义了区域，存在组件清单表
- [ ] States & Variants — 至少记录：加载、空/有数据、错误
  状态
- [ ] Interaction Map — 覆盖所有目标输入方式（检查头行中的
  平台目标）
- [ ] Data Requirements — 每个显示的数据元素都有来源系统和所有者
- [ ] Events Fired — 每个玩家操作都有对应事件或空
  说明
- [ ] Transitions & Animations — 至少指定了进入/退出转场
- [ ] Input Method Completeness Checklist — Platform Target 行中的每种输入方式
  各有一个块；任何未勾选条目都列在待解决问题下
- [ ] Accessibility Requirements — 存在屏幕级要求
- [ ] Localization Considerations — 文本元素的最大字符数
- [ ] Acceptance Criteria — 至少 5 条具体可测试的标准

### 质量检查

**玩家需求清晰度**
- [ ] 目的从玩家视角撰写，而不是系统/开发者视角
- [ ] 玩家到达时的目标明确无歧义（“玩家到达时想要 ___”）
- [ ] 玩家到达时的情境具体（不只是“他们打开了
  背包”）

**状态完整性**
- [ ] 记录了错误状态（不只是正常路径）
- [ ] 记录了空状态（无数据场景）
- [ ] 如果屏幕异步获取数据，记录了加载状态
- [ ] 任何带计时器或自动消失的状态都记录了持续时间

**输入方式覆盖**
- [ ] 如果平台包含 PC：完整指定了仅键盘导航
- [ ] 如果平台包含主机/手柄：记录了方向键导航和面键
  映射
- [ ] 没有交互要求在手柄上实现类似鼠标的精度
- [ ] 定义了焦点顺序（键盘的 Tab 顺序，手柄的方向键顺序）

**数据架构**
- [ ] 没有任何数据元素将“UI”列为所有者（UI 不得拥有游戏状态）
- [ ] 所有实时数据都指定了更新频率（不只是“实时” —
  什么触发了更新？）
- [ ] 所有数据元素都指定了空值处理（数据不可用时显示
  什么？）

**无障碍**
- [ ] 达到或超过了 `accessibility-requirements.md` 中的无障碍级别
- [ ] 如果为 Basic 级别：没有仅依赖颜色的信息指示器
- [ ] 如果为 Standard 级别及以上：记录了焦点顺序，指定了文本对比度
- [ ] 如果为 Comprehensive 级别及以上：关键状态变更的屏幕阅读器播报
- [ ] 色盲检查：任何颜色编码元素都有非颜色替代方案

**GDD 一致性**
- [ ] 头行中引用的每条 GDD UI 要求都在本规格中得到处理
- [ ] 没有 UI 元素在没有对应 GDD
  要求的情况下显示或修改游戏状态
- [ ] 本规格没有遗漏任何 GDD UI 要求（交叉核对引用的
  GDD 小节）

**模式库一致性**
- [ ] 所有可交互组件都引用了模式库（或注明它们是
  新模式）
- [ ] 如果模式已在模式库中存在，没有从头重新指定其行为
- [ ] 本规格中发明的任何新模式都已标记，以便加入
  模式库

**本地化**
- [ ] 所有文本密集元素都有字符数限制警告
- [ ] 任何对布局至关重要的文本都已标记，以适应 40% 的文本膨胀

**验收标准质量**
- [ ] 标准足够具体，供未看过设计文档的 QA 测试人员使用
- [ ] 存在性能标准（屏幕在 Xms 内打开）
- [ ] 存在分辨率标准
- [ ] 没有标准需要阅读另一份文档才能评估

---

## Phase 3B: HUD 验证清单

对照基于 `hud-design.md` 的文档运行所有检查。

### 完整性

- [ ] 定义了 HUD 理念
- [ ] 信息架构表覆盖 GDD 中所有带 UI 要求的系统
- [ ] 定义了布局区域，并为所有目标平台设定了安全区边距
- [ ] 每个 HUD 元素都有完整规格（区域、可见性触发条件、数据
  来源、优先级）
- [ ] 按玩法情境划分的 HUD 状态至少覆盖：探索、战斗、
  对话/过场动画、暂停
- [ ] 信息层级为每个 HUD 元素给出优先级层级（MUST KEEP /
  SHOULD KEEP / CAN HIDE / ALWAYS HIDE）
- [ ] 定义了视觉预算（最大同时元素数、最大屏幕占比 %）
- [ ] 平台适配覆盖所有目标平台
- [ ] 存在针对玩家可调元素的可调参数
- [ ] 验收标准 — 至少 5 条具体可测试的标准

### 质量检查

- [ ] 没有 HUD 元素覆盖中央游玩区域而没有隐藏它的可见性
  规则
- [ ] 任何 GDD 中存在的每条信息要么在 HUD 中，要么被
  显式归类为“隐藏/按需”
- [ ] 所有颜色编码的 HUD 元素都有色盲变体
- [ ] 反馈与通知部分中的 HUD 元素定义了排队/优先级
  行为
- [ ] 视觉预算合规：同时元素总数在预算之内

### GDD 一致性

- [ ] `design/gdd/systems-index.md` 中所有 UI 类别的系统都在
  HUD 中有体现（或有正当理由的缺失）

---

## Phase 3C: 模式库验证清单

- [ ] 模式目录索引是最新的（与文档中的实际模式一致）
- [ ] 指定了所有标准控件模式：按钮变体、切换、滑块、
  下拉、列表、网格、模态框、对话框、Toast、工具提示、进度条、
  输入字段、标签栏、滚动
- [ ] 当前 UX 规格所需的所有游戏特定模式都存在
- [ ] 每个模式都有：何时使用、何时不使用、完整状态规格、
  无障碍规格、实现说明
- [ ] 存在动画标准表
- [ ] 存在音效标准表
- [ ] 模式之间没有冲突行为（例如，“返回”行为在所有
  导航模式中保持一致）

---

## Phase 4: 输出结论

```markdown
## UX Review: [Document Name]
**Date**: [date]
**Reviewer**: ux-review skill
**Document**: [file path]
**Checklist**: [3A / 3B / 3C — from its Template line, or assumed from the file name]
**Platform Target**: [from header]
**Accessibility Tier**: [from header or accessibility-requirements.md]

### Completeness: [X/Y sections present]
- [x] Purpose & Player Need
- [ ] States & Variants — MISSING: error state not documented

### Quality Issues: [N found]
1. **[Issue title]** [BLOCKING / ADVISORY]
   - What's wrong: [specific description]
   - Where: [section name]
   - Fix: [specific action to take]

### GDD Alignment: [ALIGNED / GAPS FOUND]
- GDD [name] UI Requirements — [X/Y requirements covered]
- Missing: [list any uncovered GDD requirements]

### Accessibility: [COMPLIANT / GAPS / NON-COMPLIANT / NOT ASSESSED]
- Target tier: [tier]
- [list specific accessibility findings]

> **If `design/accessibility-requirements.md` is absent there is no committed
> tier, so this dimension has no criterion.** Report
> `Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md absent)`
> and do NOT report it as COMPLIANT — a gate compared against an absent standard
> passes the way an assertion that can never fail passes. The same rule lives in
> `/team-ui` Phase 4 and is mirrored here so the two cannot drift. If the spec's own
> header states a tier, carry it forward as an **assumption** and say plainly that
> it was assumed rather than committed. Recommend `/ux-design accessibility` to
> establish the tier.

### Pattern Library: [CONSISTENT / INCONSISTENCIES FOUND / N/A]
- [findings]

> **For a HUD design there is no Pattern Library checklist to run it against (Phase 3B has none), so Pattern Library is N/A, excluded from the dimension count.**
> Report `Pattern Library: N/A — no pattern library checklist for this document
> type`.
>
> For a UX spec, this dimension does have a checklist — it is checked against
> `design/ux/interaction-patterns.md`. If that file is absent: N/A only where
> the workflow tier does not require the library (`minimal`) — report
> `Pattern Library: N/A — interaction pattern library not required at this
> tier`. At any tier that requires or recommends it (`standard`, `full`), report
> `Pattern Library: NOT ASSESSED — design/ux/interaction-patterns.md not found`
> instead: the library is missing, not out of scope, and NOT ASSESSED counts it
> against the verdict as the unresolved item it is.

### Verdict: APPROVED / NOT ASSESSED / NEEDS REVISION / MAJOR REVISION NEEDED
**Blocking issues**: [N] — must be resolved before implementation
**Advisory issues**: [N] — recommended but not blocking
**Dimensions not assessed**: [N] — [name each, and what would make it checkable]

[For APPROVED]: This spec is ready for handoff to `/team-ui` Phase 2
(Visual Design).

[For NOT ASSESSED]: [N] of the four review dimensions could not be evaluated:
[name them]. The spec may well be sound — this review cannot say either way for
those dimensions. [For each: the one input that would make it checkable.]
Handoff to `/team-ui` is not recommended on this result.

[For NEEDS REVISION]: Address the [N] blocking issues above, then re-run
`/ux-review`.

[For MAJOR REVISION NEEDED]: The spec has fundamental gaps in [areas].
Recommend returning to `/ux-design` to rework [sections].
```

---

## Phase 5: 协作协议

本技能是只读的 — 它从不编辑或写入文件。它只报告发现。

给出结论之后：
- 对于 **APPROVED**：建议运行 `/team-ui` 开始实现协调
- 对于 **NOT ASSESSED**：按维度指出缺失的输入，并提议帮助
  产出它（对未承诺的级别使用 `/ux-design accessibility`，对缺失的 UI 要求
  使用 GDD 路径）。不要在相同的缺失输入上重新运行评审并报告不同的结论 —
  只有新的输入才能改变该结论
- 对于 **NEEDS REVISION**：提议帮助修复具体缺口（“你希望我
  帮忙起草缺失的错误状态吗？”）— 但不要自动修复；等待用户
  指示
- 对于 **MAJOR REVISION NEEDED**：建议回到 `/ux-design`，并指出
  需要返工的具体小节

绝不要阻止用户继续 — 结论是建议性的。记录风险，
呈现发现，让用户决定是否在存在顾虑的情况下继续。选择继续使用
NEEDS REVISION 规格的用户，自行承担已记录的风险。