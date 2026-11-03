---
name: qa-plan
description: "针对一个冲刺的 QA 测试计划——按 Logic/Integration/Visual/UI 对用户故事分类，覆盖自动化测试、手工用例、冒烟测试范围。"
argument-hint: "[sprint | feature: system-name | story: path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash "*/.claude/skills/qa-plan/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level,system_overrides`

以上已解析——直接使用。无配置块 → 使用
`.claude/docs/config-resolution.md` 中的默认值。


# QA 计划

本技能为一次冲刺（sprint）、一个功能或单个用户故事生成结构化的 QA 计划。
它读取所有范围内的用户故事文件及其引用的 GDD，按测试类型对每个用户故事
分类，并产出一份计划，明确告诉开发者哪些要自动化、哪些要手工验证、
冒烟测试（smoke test）范围是什么，以及何时引入试玩测试者。

在冲刺开始之前运行本技能，好让团队提前知道需要哪些测试工作。
在实现之后才写的测试计划是事后复盘，而不是计划。

**输出：** `production/qa/qa-plan-[sprint-slug]-[date].md`

---

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（collaborative 每次必问 · guided 仅重大事项 · autonomous 记录日志并继续；
`automation_always_ask` 类别始终提示）。

**工作流层级（Workflow tier）**：每读到一个 GDD 的系统时按该系统的配置解析（依据
`.claude/docs/workflow-modes.md`）：如果配置块列出了该项，则用 `workflow_overrides.system_overrides.<system>`，
否则用项目值。它决定测试计划从多少个 GDD 章节中挖掘——见 Phase 2。

**`qa.level`**：在 `minimal` 下，只产出最小化的冒烟
计划——去掉"需要自动化测试"的行和测试文件的 DoD；在 `standard` 下，
按用户故事类型产出完整计划；在 `full` 下，还要增加按系统的覆盖率目标。
它与 `workflow` 是不同的维度（后者决定挖掘多少个 GDD 章节）。
任何层级都不删除 Visual/Feel 和 UI 截图的条目——在
`minimal` 下测试被豁免，但外观不是（`.claude/docs/coding-standards.md`）。

## Phase 1: 解析范围

**参数：** `$ARGUMENTS`（留空 = 通过 AskUserQuestion 询问用户）

根据参数确定范围：

- **`sprint`** —— 读取 `production/sprints/` 中最近的文件，提取
  其中引用的每一个用户故事文件路径。如果 `production/sprint-status.yaml` 存在，
  就以它作为主要用户故事列表，并从冲刺计划回退获取用户故事
  元数据。
- **`feature: [system-name]`** —— glob `production/epics/*/story-*.md`，筛选出
  文件路径或标题包含该系统名的用户故事。同时检查该系统目录下的
  史诗（epic）索引文件（`EPIC.md`）。
- **`story: [path]`** —— 校验该路径存在，并加载那一个文件。
- **无参数** —— 使用 `AskUserQuestion`：
  - "这份 QA 计划的范围是什么？"
  - 选项："当前冲刺"、"特定功能（输入系统名）"、
    "特定用户故事（输入路径）"、"完整史诗"

确定范围后，报告："正在为 [scope] 中的 [N] 个用户故事构建 QA 计划。"

如果引用了某个用户故事文件路径但文件不存在，将其标记为
MISSING 并继续处理其余用户故事。不要因为一个文件缺失就使整个计划
失败。

> **如果解析出的范围包含零个用户故事，停止——不要构建计划。**
> 报告 `NOT ASSESSED — no stories in scope`，说明搜索的是哪个范围
> 以及哪条路径为空，并进行路由：
> - `production/sprints/` 中没有任何文件 → "未找到冲刺计划。运行 `/sprint-plan new`。"
>   在 `workflow: minimal` 下按设计没有冲刺——改为路由到
>   `/qa-plan feature: [epic-slug]` 或 `/qa-plan story: [path]`。
> - 存在冲刺计划但未引用任何用户故事 → "冲刺计划 `[path]` 未列出任何
>   用户故事。运行 `/create-stories [epic-slug]`。"
> - `feature:`/`story:` 范围没有匹配到任何内容 → 指出返回为空的 glob。
>
> **N=0 的守卫是强制性的。** 没有它，空范围会报告"正在为 0 个用户故事构建 QA
> 计划"并继续进入 Phase 4，产出一份表格为空的计划文档——而**零个用户故事的 QA 计划
> 看起来与已完成的 QA 计划一模一样。** 本技能是向手工 QA 交接的
> 质量闸门（gate），因此这里的假性通过会把一个什么都没测的计划当作依据，
> 把一个构建送去 QA。
>
> 本块顶部的规则依然成立：多个文件中缺一个属于
> MISSING 并继续。这里说的是另一种情况：根本不存在"多个"。

---

## Phase 2: 加载输入

先确立分母——glob 范围内的用户故事文件并计数 **N**——
然后用**针对性的章节 grep，而不是完整读取每个用户故事**来收集下面的字段。
QA 计划需要每个用户故事的类型和验收标准；它不需要实现说明、范围外
边界或 ADR 理由，而为了读到两个章节就把 N 个用户故事整篇读完，正是本阶段
成本所在：

```
Grep pattern="^## Acceptance Criteria" glob="production/epics/**/story-*.md" output_mode="content" -A 15
Grep pattern="^> \*\*(Type|Status|Estimate)\*\*" glob="production/epics/**/story-*.md" output_mode="content"
Grep pattern="^## (Context|Dependencies)" glob="production/epics/**/story-*.md" output_mode="content" -A 8
```

（在 `sprint` 模式下把 glob 限定为冲刺计划中的用户故事路径。）由此得到：

- **用户故事标题**和用户故事 ID —— 来自文件名和路径；完全不需要读取
- **Story Type** 字段 —— 来自 header grep（例如 `Type: Logic`）
- **验收标准** —— 完整的有序/无序列表，来自第一个 grep
- **GDD / ADR 引用**和**依赖** —— 来自 `## Context` grep
- **估算** —— 来自 header grep（若存在）
- **实现文件**和**引擎说明** —— 仅对测试计划确实依赖它们的用户故事才需要；
  单独完整读取这些用户故事

**绝不要把缺失的章节当作缺失的用户故事。** 如果某个用户故事没有匹配到任何
`## Acceptance Criteria`，就单独完整读取它并说明——没有可测试标准的
用户故事本身就是一项 QA 发现，而不是可以跳过的用户故事。

读取用户故事后，一次性加载支撑上下文（不要每个用户故事都加载）：

- `design/gdd/systems-index.md` —— 用于了解系统优先级以及哪些
  GDD 已批准
- 对全部用户故事中引用的每一份不同 GDD：按该系统的工作流层级（上文已解析）挖掘测试素材——在 `full` 下挖掘全部 8 个章节；在
  `standard` 下挖掘所需章节中与测试相关的子集
  （**Acceptance Criteria** 和 **Edge Cases** 始终包含，另外对任何定义了数值规则的系统再加 **Formulas**）；在 `minimal` 下**仅挖掘 Acceptance
  Criteria**。不要加载完整的 GDD
  文本。用 Grep 工具（模式 `^#`，content 模式）找到章节标题，再用 offset 和 limit Read
  这些区段。这些章节包含可测试的需求、需要验证的
  数学计算，以及测试必须覆盖的边界条件。如果缺少 Edge Cases 章节（或
  在 minimal 下本就不期望出现），按 GDD 记录："未找到 Edge Cases 章节——边界用例
  覆盖将仅从验收标准推断。"
- `docs/architecture/control-manifest.md` —— 扫描自动化测试应防范的
  禁用模式（如果该文件存在）

如果某个用户故事没有引用任何 GDD，把它记为缺口，但不要因此阻塞计划。
该用户故事将仅依据验收标准进行分类。

---

## Phase 3: 分类每个用户故事

对每个用户故事，指定一个 Story Type：

- **如果用户故事的 header 中已有 `Type:` 字段**：按原样接受。不要重新分类，也不要对照下面的标准做校验——Type 是 lead-programmer 在创建用户故事时设定的，具有权威性。按原样记录。
- **如果缺少 `Type:` 字段**：依据下面的表格从验收标准推断类型，并在报告中说明该类型是推断出来的（而非声明的）。将其标记为缺口——在实现开始之前，应当明确声明该用户故事的 Type。

| Story Type | 分类指标 |
|---|---|
| **Logic** | 验收标准涉及计算、公式、数值阈值、状态转换、AI 决策、数据校验、buff/debuff 叠加、经济交易，或任何可测试的计算 |
| **Integration** | 标准涉及两个或更多系统交互、信号或事件跨系统边界传递、存档/读档往返、网络同步或持久化 |
| **Visual/Feel** | 标准涉及动画行为、VFX、着色器（shader）输出、"手感灵敏"、感知时机、屏幕震动、粒子效果、音频同步或视觉反馈质量 |
| **UI** | 标准涉及菜单、HUD 元素、按钮、界面、对话框、背包面板、工具提示，或任何面向玩家的界面元素 |
| **Config/Data** | 变更仅限于平衡性调参值、数据文件或配置——不涉及新的代码逻辑 |

**混合型用户故事**（例如同时新增公式和 UI 显示的用户故事）：
按承载最高实现风险的验收标准指定主要类型，并注明次要类型。
Logic+Integration 或 Visual+UI 的组合最为常见。

完成全部用户故事分类后，在进入 Phase 4 之前在对话中产出一张分类摘要表。
这让用户清楚了解测试将如何分配。

---

## Phase 4: 生成测试计划

组装完整的 QA 计划文档。使用以下结构：

````markdown
# QA Plan: [Sprint/Feature Name]
**Date**: [date]
**Generated by**: /qa-plan
**Scope**: [N stories across [N systems]]
**Engine**: [engine name — `engine.name` from project.yaml if present and non-empty, else the Engine field from .claude/docs/technical-preferences.md, else "Not configured"]
**Sprint File**: [path to sprint plan if applicable]

---

## Test Summary

| Story | Type | Automated Test Required | Manual Verification Required |
|-------|------|------------------------|------------------------------|
| [story title] | Logic | Unit test — `tests/unit/[system]/` | None |
| [story title] | Integration | Integration test — `tests/integration/[system]/` | Smoke check |
| [story title] | Visual/Feel | None (not automatable) | Screenshot + lead sign-off |
| [story title] | UI | None (verified by its screenshots) | Retained screenshot of each screen touched |
| [story title] | Config/Data | Data validation test | Spot-check in-game values |

---

## Automated Tests Required

*(At `qa.level: minimal`, omit this entire section and blank the Test Summary's
"Automated Test Required" column — automated tests are not required there; list
manual/smoke verification only.)*

### [Story Title] — [Type]
**Test file path**: `tests/[unit|integration]/[system]/[story-slug]_test.[ext]`
**What to test**:
- [Specific formula or rule from the GDD Formulas section]
- [Each named state transition or decision branch]
- [Each side effect that should or should not occur]

**Edge cases to cover**:
- Zero/minimum input values (e.g., 0 damage, empty inventory)
- Maximum/boundary input values (e.g., max level, stat cap)
- Invalid or null input (e.g., missing target, dead entity)
- [Any edge case explicitly called out in the GDD Edge Cases section]

**Estimated test count**: ~[N] unit tests

[If no GDD formula reference was found for this story, note:]
*No formula found in referenced GDD — test cases must be derived from acceptance
criteria directly. Review the GDD Formulas section before writing tests.*

---

## Manual QA Checklist

### [Story Title] — [Type]
**Verification method**: [Screenshot + designer sign-off | Playtest session |
Manual step-through | Comparison against reference footage]
**Who must sign off**: [designer / lead-programmer / qa-lead / art-director]
**Evidence to capture**: [screenshot of X | video clip of Y | written playtest
notes | side-by-side comparison]

Checklist:
- [ ] [Specific observable condition — concrete and falsifiable]
- [ ] [Another condition]
- [ ] [Every acceptance criterion translated into a manual check item]

*If any criterion uses subjective language ("feels", "looks", "seems"), it must
be supplemented with a specific benchmark or a playtest protocol note.*

---

## Smoke Test Scope

Critical paths to verify before any QA hand-off for this sprint:

1. Game launches to main menu without crash
2. New game / new session can be started
3. [Primary mechanic introduced or changed this sprint]
4. [Any system with a regression risk from this sprint's changes]
5. Save / load cycle completes without data loss (if save system exists)
6. Performance is within budget on target hardware (no new frame spikes)

*Smoke tests are verified by the developer via `/smoke-check`. Reference this
list when running that skill.*

---

## Playtest Requirements

| Story | Playtest Goal | Min Sessions | Target Player Type |
|-------|--------------|--------------|-------------------|
| [story] | [What question must the session answer?] | [N] | [new player / experienced] |

**Sign-off requirement**: Playtest notes must be written with `/playtest-report` to
`production/qa/playtests/` (naming the story) and reviewed by
the [designer / qa-lead] before the story can be marked COMPLETE.

If no stories require playtest validation: *No playtest sessions required for
this sprint.*

---

## Definition of Done — This Sprint

A story is DONE when ALL of the following are true (at `qa.level: minimal`, drop
the test-file and smoke rows below — tests are waived there; the screenshot and
sign-off rows stay at every level, because the look is not):

- [ ] All acceptance criteria verified — via automated test result OR documented
      manual evidence (screenshot, video, or playtest notes with sign-off)
- [ ] Test file exists at the specified path for all Logic and Integration stories *(qa.level standard/full)*
- [ ] Retained screenshot of each screen touched, in `production/qa/evidence/`, for all Visual/Feel and UI stories *(every qa.level)*
- [ ] Signed-off evidence doc at `production/qa/evidence/[story-slug]-evidence.md` for all Visual/Feel stories *(every qa.level)*
- [ ] Smoke check passes (run `/smoke-check sprint` before QA hand-off) *(qa.level standard/full)*
- [ ] No regressions introduced
- [ ] Code reviewed (via `/code-review` or documented peer review)
- [ ] Story file updated to `Status: Complete` (via `/story-done`)
````

生成内容时，使用 Phase 2 中提取的真实用户故事标题、GDD 公式文本和
验收标准。不要使用占位文本——每一条测试条目都应反映这些具体用户故事的真实需求。

---

## Phase 5: 写入输出

在对话中展示完整计划（如果计划非常长则展示摘要），
然后用 `AskUserQuestion` 一起问两个问题：

```
question: "Ready to write the QA plan. Choose output options:"
multiSelect: true
options:
  - "Write QA plan to production/qa/qa-plan-[sprint-slug]-[date].md"
  - "Also back-fill test case specs into each story file's ## QA Test Cases section (Recommended — enables /dev-story and /code-review traceability)"
```

如果选择了 "Write QA plan"：按生成内容原样写入计划文件——不要截断。

如果选择了 "Also back-fill story files"：对范围内每个 Logic 和 Integration 用户故事，编辑其路径下的用户故事文件。找到 `## QA Test Cases` 章节，用 Phase 4 为该用户故事生成的测试用例规格替换其内容。如果用户故事没有 `## QA Test Cases` 章节，就在 `## Test Evidence` 之前追加。对 Visual/Feel 和 UI 用户故事，写入手工验证步骤而不是测试规格。

写入之后：

"QA 计划已写入 `production/qa/qa-plan-[sprint-slug]-[date].md`。

后续步骤：
- 在冲刺实现开始之前把这份计划分享给团队
- 所有冲刺用户故事实现完成后，运行 `/smoke-check sprint` 把关 QA 交接——不是现在，只在实现完成之后
- 对 Logic/Integration 用户故事，在把用户故事标记完成之前，
  在列出的路径创建测试文件——`/story-done` 会检查它们"

静默追加到 `production/session-state/active.md`（如果文件不存在则创建）：

```
<!-- QA-PLAN: [date] | System: [system/sprint identifier] | Plan written: production/qa/qa-plan-[identifier]-[date].md -->
```

以结论收尾：**COMPLETE** —— 已写入 QA 计划（如果写入被拒绝，则为 **COMPLETE** ——
QA 计划已展示、未写入）。唯一其他结果就是 Phase 1 中的
`NOT ASSESSED — no stories in scope` 路径。

---

## 协作协议

**适用于 `collaborative` 模式（默认）。** 关于 `guided` 和
`autonomous` 模式，见 `.claude/docs/automation-modes.md` ——下面的规则描述的是协作模式的要求，而不是普遍行为。

- **绝不在未询问的情况下写入计划** —— Phase 5 要求明确批准。
- **保守分类**：当用户故事在 Logic 和
  Integration 之间有歧义时，归类为 Integration——它同时需要单元测试和
  集成测试。
- **不要臆造测试用例**超出验收标准和 GDD 公式所支持的
  范围。如果 GDD 中缺少某个公式，标记出来而不是猜测。
- **试玩测试要求是建议性的**：对边界性的 Visual/Feel 用户故事，由用户决定
  是否值得进行试玩测试。标记情况；不要强制。
- 未提供参数时，使用 `AskUserQuestion` 进行范围选择。
  保持其他所有阶段非交互——呈现发现，然后只问一次以
  批准写入。
