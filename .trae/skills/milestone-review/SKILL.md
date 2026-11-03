---
name: milestone-review
description: "里程碑进度评审 —— 完整性、质量指标、风险、继续/停止建议。在检查点或截止日期前使用。"
argument-hint: "[milestone-name|current] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow`

以上命令的输出已解析 —— 直接使用；本次运行中 `--review` 会覆盖 `review_mode`。没有对应配置块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

# 里程碑评审



## 输入不足 —— 在产出任何报告之前先检查

**如果本技能所需的输入不存在，答案就是"无法运行" —— 而不是一份填好的报告。** 先检查，
若检查不通过就停止。

1. 列出本技能读取的输入（数据文件、既往报告、性能分析器输出、测试结果、注册表、源代码）。
2. 对每一项记录 `FOUND` 或 `ABSENT` —— 而不是"假定存在"。
3. 如果某个章节所需的任何输入为 ABSENT，该章节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻产出物推断，也不要留下一个应由
   下一位模板读者填写的必填单元格。
4. 如果**所有**必需输入都为 ABSENT，停止并把 **`NOT ASSESSED — NO DATA`** 作为整体结论
   报告，指明缺失了什么，以及由哪个技能产出它。

**`NOT ASSESSED` 的结论也是一种成功。** 在没有数据时，这是对"数据说明了什么？"这一问题
正确且有价值的回答。它防止的失败模式很具体：一个结论枚举中没有"无法运行"状态的报告会产生
**虚假的干净通过** —— 例如在没有资源、也没有标准的项目上返回 COMPLIANT 的资源审计，或在
零性能分析数据、从未设定预算的情况下报告"相对 16.67ms 预算 >99% 余量"的性能剖析。

**没有证据绝不等同于证明不存在。** 一次扫描因为没有文件可扫而找不到匹配，并没有验证任何
东西。要说明两者中发生的是哪一种 —— 读者无法从绿色结果中分辨。

---

## Phase 0: 解析参数

提取里程碑名称（`current` 或具体名称）。

完整的检查模式见 `.trae/docs/director-gates.md`。各个质量闸门的定义位于
`.trae/docs/director-gates/[gate-id].md` —— 被派生的 agent 会读取自己的闸门文件；
不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

---

## Phase 1: 加载里程碑数据

如果 `production/milestones/` 存在，从中读取里程碑定义。如果参数是 `current`，使用最近
修改的里程碑文件。

> **没有任何技能会写入 `production/milestones/`** —— 其中的定义是依据
> `.trae/docs/templates/milestone-definition.md` 手工编写的，因此多数项目并没有这些文件。
> 当该目录不存在或为空时，如实说明，并仅依据冲刺报告进行评审；不要虚构一份定义。使用
> `current` 时要小心：本技能会把自己的输出写为 `[milestone-name]-review.md`，所以"最近
> 修改"的匹配可能是上一次*评审*而非定义。选择时跳过以 `-review.md` 结尾的文件。

从 `production/sprints/` 收集本里程碑内各冲刺的冲刺报告。先确定分母（用 glob 匹配并计数
**N**），然后只扫描里程碑评审实际汇总的章节，而不是整份读取每份报告：

```
Grep pattern="^## (Sprint Goal|Capacity|Tasks|Carryover|Risks|Progress|Burndown Assessment|Emerging Risks|Definition of Done)" glob="production/sprints/sprint-*.md" output_mode="content" -A 12
```

> **这些备选标题是 `/sprint-plan` 实际输出的标题**（`## Sprint Goal`，而不是 `## Goal`）——
> 并非里程碑评审可能预期的标题。只匹配到一个真实标题的模式仍会返回非零计数，于是下面的
> 零匹配兜底出口永远不会触发，而评审只汇总了每份报告的一小部分，却报告为全覆盖。

当某份冲刺报告被扫描的章节指向其自身之外，或它一无所获时，完整读取该报告 —— 零匹配的报告
早于当前模板，必须读取，绝不可悄悄从里程碑历史中丢弃。报告任何未贡献内容的冲刺：一份悄悄
省略某个冲刺的里程碑摘要会同时低估工作量与延期。

**被阻塞的用户故事** —— Blocked 表格以及传给 PR-MILESTONE 的被阻塞用户故事计数 —— 不在
冲刺报告被扫描的章节中。到它们被记录的地方读取：`production/sprint-status.yaml` 中
`status: blocked` 的用户故事（连同其 `blocker` 字段），以及对于该冲刺之外的用户故事，
执行一次 grep：

```
Grep pattern="^> \*\*Status\*\*: Blocked|BLOCKED:" glob="production/epics/**/story-*.md" output_mode="content"
```

每个被阻塞的用户故事都放入 Blocked 表格，归在其实施该故事的史诗文件夹所对应的功能之下，
并附上其阻塞项（yaml 的 `blocker` 字段或该故事的 `BLOCKED:` 注记）。若没有用户故事文件
也没有 `sprint-status.yaml`，Blocked 表格与被阻塞用户故事计数为 `NOT ASSESSED — NO DATA`，
而不是零。

---

## Phase 2: 扫描代码库健康状况

- 扫描 `TODO`、`FIXME`、`HACK` 标记，以识别未完成的工作
- 从 `production/qa/bugs/` 按严重程度统计未关闭缺陷，用于质量指标（对 `**Severity**` 与
  `**Status**` 行做一次 grep，与 `/bug-triage` 的做法相同）；若没有缺陷文件，缺陷相关行即为
  `NOT ASSESSED — NO DATA`，而不是零
- 如果 `production/risk-register/` 存在，检查风险登记册（依据
  `.trae/docs/templates/risk-register-entry.md` 手工编写；没有技能会写入它，因此不存在
  属于常态 —— 如实记录，而不是悄悄跳过风险评估）

---

## Phase 3: 生成里程碑评审

```markdown
# Milestone Review: [Milestone Name]

## Overview
- **Target Date**: [Date]
- **Current Date**: [Today]
- **Days Remaining**: [N]
- **Sprints Completed**: [X/Y]

## Feature Completeness

### Fully Complete
Only a feature whose Status is `Complete` goes here or counts toward the completion percentage; a Deferred feature stays in its denominator, named with the milestone it moved to.

| Feature | Acceptance Criteria | Test Status |
|---------|-------------------|-------------|

### Partially Complete
| Feature | % Done | Remaining Work | Risk to Milestone |
|---------|--------|---------------|------------------|

### Blocked
A started feature whose stories are Blocked goes here, not under Partially
Complete — name the blocker, so the review says why it stalled, not only that
the count moved.

| Feature | Blocked Stories | Blocker | Next Action / Owner |
|---------|----------------|---------|---------------------|

### Not Started
| Feature | Priority | Can Cut? | Impact of Cutting |
|---------|----------|----------|------------------|

## Quality Metrics
- **Open S1 Bugs**: [N] -- [List]
- **Open S2 Bugs**: [N]
- **Open S3 Bugs**: [N]
- **Test Coverage**: [X%]
- **Performance**: [Within budget? Details]

## Code Health
- **TODO count**: [N across codebase]
- **FIXME count**: [N]
- **HACK count**: [N]
- **Technical debt items**: [List critical ones]

## Risk Assessment
| Risk | Status | Impact if Realized | Mitigation Status |
|------|--------|-------------------|------------------|

## Velocity Analysis
- **Planned vs Completed** (across all sprints): [X/Y tasks = Z%]
- **Trend**: [Improving / Stable / Declining]
- **Adjusted estimate for remaining work**: [Days needed at current velocity]

## Scope Recommendations
### Protect (Must ship with milestone)
- [Feature and why]

### At Risk (May need to cut or simplify)
- [Feature and risk]

### Cut Candidates (Can defer without compromising milestone)
- [Feature and impact of cutting]

## Go/No-Go Assessment

**Recommendation**: [NOT ASSESSED / GO / CONDITIONAL GO / NO-GO]

**Conditions** (if conditional):
- [Condition 1 that must be met]
- [Condition 2 that must be met]

**Rationale**: [Explanation of the recommendation]

## Action Items
| # | Action | Owner | Deadline |
|---|--------|-------|----------|
```

---

## Phase 3b: 制作人风险评估

**评审模式检查** —— 在派生 PR-MILESTONE 之前应用：
- `solo` → 跳过。注明："PR-MILESTONE skipped — Solo mode."在没有制作人结论的情况下呈现
  Go/No-Go 章节。
- `lean` → 跳过（不是 PHASE-GATE）。注明："PR-MILESTONE skipped — Lean mode."在没有制作人
  结论的情况下呈现 Go/No-Go 章节。
- `full` → 照常派生。

在生成 Go/No-Go 建议之前，通过 `Agent` 以质量闸门 **PR-MILESTONE** 派生 `producer`
（`.trae/docs/director-gates/pr-milestone.md`）。

传入：里程碑名称与目标日期、当前完成百分比、被阻塞用户故事计数、来自冲刺报告的速率数据
（若有）、候选裁减项清单。

在 Go/No-Go 章节中就地呈现制作人的评估。制作人的结论（ON TRACK / AT RISK / OFF TRACK）
会影响整体建议。

如果为 OFF TRACK，在生成建议之前使用 `AskUserQuestion`：
- 提示："制作人结论：OFF TRACK。里程碑已处于危险之中。本次评审将建议 NO-GO。你希望如何
  继续？"
- 选项：
  - `[A] 接受 NO-GO —— 按该建议生成完整评审`
  - `[B] 改为 CONDITIONAL GO —— 由我自己记录所接受的风险`
  - `[C] 停止 —— 我想先生成评审之前处理阻塞项`

如果为 AT RISK，使用 `AskUserQuestion`：
- 提示："制作人结论：AT RISK。里程碑可能延期。Go/No-Go 章节应如何表述？"
- 选项：
  - `[A] CONDITIONAL GO —— 在评审中包含制作人的条件`
  - `[B] NO-GO —— 条件无法按时满足`
  - `[C] GO —— 我接受风险并希望继续`

如果为 NOT ASSESSED：指出缺失的输入 —— 它不等于 ON TRACK，绝不要据此建议 GO。补齐输入并
重新运行 PR-MILESTONE，或建议 NOT ASSESSED —— 或在评审自身发现需要时给出 CONDITIONAL GO /
NO-GO（见 `.trae/docs/director-gates.md` 中的排序）。

不要针对 OFF TRACK 的结论给出 GO；只有当用户明确选择上方 [B] 时才给出 CONDITIONAL GO。

---

## Phase 4: 保存评审

向用户呈现评审。

询问："我可以把这份评审写入 `production/milestones/[milestone-name]-review.md` 吗？"

若同意，写入文件，必要时创建目录。Verdict：**COMPLETE** —— 里程碑评审已保存。

若不同意，就此停止。Verdict：**BLOCKED** —— 用户拒绝写入。

---

## Phase 5: 后续步骤

- 如果本里程碑标志着一个开发阶段的边界，运行 `/gate-check` 以获得正式的阶段质量闸门结论。
- 运行 `/sprint-plan`，根据上方的范围建议调整下一个冲刺（在 `workflow: minimal` 下没有冲刺，
  改为调整简报的构建顺序）。