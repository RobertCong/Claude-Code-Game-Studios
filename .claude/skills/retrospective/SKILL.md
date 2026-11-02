---
name: retrospective
description: "基于已完成工作、速度和阻塞项生成冲刺或里程碑回顾。为下一个迭代提供可执行的洞察。"
argument-hint: "[sprint-N|milestone-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(bash "*/.claude/skills/retrospective/../../hooks/yaml-helper.sh" resolve_config *), Bash(git log *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level`

# 回顾（Retrospective）



每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅大项询问 · 自主模式记录后继续；
`automation_always_ask` 类别始终提示）。

## 输入不足——产出任何报告前先检查

**如果本技能需要的输入不存在，答案就是"无法运行"——而不是一份填好的报告。** 先检查，检查失败就停止。

1. 列出本技能读取的输入（数据文件、既有报告、性能分析输出、
   测试结果、注册表、源代码）。
2. 对每项记录 `FOUND` 或 `ABSENT`——而不是"假定存在"。
3. 若某章节所需的任一输入为 ABSENT，该章节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻产出物推断，也不要留下一个强制单元格让模板的下一位读者去填。
4. 若**所有**必需输入均为 ABSENT，则停止，并将
   **`NOT ASSESSED — NO DATA`** 作为整体结论输出，说明缺少什么以及由哪个技能产出。

**`NOT ASSESSED` 的结论是一种成功。** 当没有数据时，这是对"数据说明了什么？"的正确且有价值的回答。它防止的失败模式很具体：一个结论枚举中没有"无法运行"状态的报告，会产生**虚假的干净通过**——例如对没有资源也没有标准的项目返回 COMPLIANT 的资源审计，或对 16.67ms 预算报告">99% 余量"却零性能分析数据、预算从未设置。

**证据的缺失从来不是缺失的证据。** 一次扫描因为没有文件可扫而未找到任何匹配，并不代表验证了什么。要说明属于哪种情况——读者无法从一个绿色的结果中分辨。

---

## Phase 1: 解析参数

确定这是冲刺回顾（`sprint-N`）还是里程碑回顾（`milestone-name`）。

---

## Phase 1b: 检查已有回顾

在加载任何数据之前，先 glob 查找已有回顾文件：

- 冲刺回顾：`production/retrospectives/retro-[sprint-slug]-*.md`
  （同时检查备用位置 `production/sprints/sprint-[N]-retrospective.md`）
- 里程碑回顾：`production/retrospectives/retro-[milestone-name]-*.md`

若找到匹配文件，使用 `AskUserQuestion`：
- 提示："已找到一份现有回顾：[filename]。你想如何处理？"
- 选项：
  - `[A] 更新现有回顾 —— 加载它，并用新数据添加/修订各章节`
  - `[B] 重新开始 —— 生成一份新回顾（归档旧的那份）`

若选 [A]：读取已有文件并沿用其内容，用新数据修订各章节。
若选 [B]：以空白状态继续 Phase 2。写入新文件之前，将已有文件重命名为带 `-archived-[date]` 后缀的名字。该重命名同样是一次写入：它在 Phase 5 发生，且只在该处的询问（其中会点名它）获批之后执行。

---

## Phase 2: 加载冲刺或里程碑数据

从相应位置读取冲刺或里程碑计划：

- 冲刺计划：`production/sprints/`
- 里程碑定义：`production/milestones/`

**同时检查 `production/sprint-status.yaml`**：若存在，与冲刺计划一并读取。它是用户故事实际完成状态（status: done、完成日期、阻塞项）的权威来源。在 Phase 3 中将其作为完成度指标的主要来源。仅在 yaml 不存在时回退到 markdown 扫描。注意 yaml 与冲刺计划之间的差异（例如 yaml 中有而计划中没有的用户故事，或反之）。

**若文件不存在或为空**，输出：

> "未找到 [sprint/milestone] 的冲刺数据。运行 `/sprint-plan new` 创建一个
> 冲刺（`/sprint-status` 只会读取冲刺），或手动提供冲刺详情。"

在 `workflow: minimal`（已在上方解析）下没有冲刺：改为提供回顾迄今已关闭用户故事的选项（`production/epics/*/story-*.md` 且 `Status: Complete`）。
在 `qa.level: minimal`（已在上方解析）下测试被豁免，因此一个未附测试就关闭的用户故事不算发现项；但一个未附保留截图的视觉/手感或 UI 用户故事仍算。

然后使用 `AskUserQuestion` 呈现这些选项（[C] 仅在 `workflow: minimal` 下）：

- **[A] 手动提供数据** —— 请用户粘贴或描述冲刺
  任务、日期与结果；将其作为回顾的事实来源。
- **[B] 停止** —— 中止技能。结论：**BLOCKED** —— 无冲刺数据可用。
- **[C] 回顾已关闭的用户故事** —— 使用
  `Status: Complete` 的用户故事作为已完成工作的记录。

若用户选 [A]，收集数据并使用其提供的内容继续 Phase 3。
若用户选 [B]，在此停止。
若用户选 [C]，读取这些用户故事并继续 Phase 3。需要冲刺数据的章节（计划 vs 实际、速度、结转、估算准确性）为 `NOT ASSESSED — NO DATA`。

提取：计划任务、估算工作量、负责人与目标。

对冲刺周期运行 git log，以了解实际提交了什么以及何时提交。使用 Bash 工具（Windows 上使用 Git Bash——`2>/dev/null` 是 bash 语法，不是 PowerShell）：

```
Bash: git log --oneline --since="4 weeks ago" 2>/dev/null || git log --oneline -20
```

若从冲刺计划中已知冲刺时长，相应调整 `--since` 日期。

---

## Phase 3: 分析完成情况与趋势

通过对比计划与实际交付物，扫描已完成与未完成的任务。检查：

- 按计划完成的任务
- 完成但偏离计划的任务
- 结转的任务（未完成）
- 冲刺中期新增的任务（计划外工作）
- 被移除或缩减范围的任务

`production/sprint-status.yaml` 中每个 `status: blocked` 的用户故事都归入
Blockers Encountered，以其 `blocker` 字段作为 Blocker，并在 Action Items for Next Iteration 中生成一个行动项。

扫描代码库中的 TODO/FIXME 趋势：

- 统计当前 TODO/FIXME/HACK 注释
- 如可用，与之前冲刺的计数对比（查看既往回顾）
- 记录技术债是在增长还是缩减

读取 `production/retrospectives/` 中的既往回顾（若有）以检查：

- 之前的行动项是否已处理？
- 是否反复出现同样的问题？
- 速度趋势如何？

若没有更早的冲刺或回顾，Velocity Trend 只保留当前冲刺那一行并读作
`NOT ASSESSED — NO DATA`，Previous Action Items Follow-Up 就是那一行——不编造更早的行，不留空表。

---

## Phase 4: 生成回顾

```markdown
## Retrospective: [Sprint N / Milestone Name]
Period: [Start Date] -- [End Date]
Generated: [Date]

### Metrics

| Metric | Planned | Actual | Delta |
|--------|---------|--------|-------|
| Tasks | [X] | [Y] | [+/- Z] |
| Completion Rate | -- | [Z%] | -- |
| Story Points / Effort Days | [X] | [Y] | [+/- Z] |
| Bugs Found | -- | [N] | -- |
| Bugs Fixed | -- | [N] | -- |
| Unplanned Tasks Added | -- | [N] | -- |
| Commits | -- | [N] | -- |

### Velocity Trend

| Sprint | Planned | Completed | Rate |
|--------|---------|-----------|------|
| [N-2] | [X] | [Y] | [Z%] |
| [N-1] | [X] | [Y] | [Z%] |
| [N] (current) | [X] | [Y] | [Z%] |

**Trend**: [Increasing / Stable / Decreasing — or `NOT ASSESSED — NO DATA` with no earlier sprint to compare]
[One sentence explaining the trend]

### What Went Well
- [Observation backed by specific data or examples]
- [Another positive observation]
- [Recognize specific contributions or decisions that paid off]

### What Went Poorly
- [Specific issue with measurable impact -- e.g., "Feature X took 5 days
  instead of estimated 2, blocking tasks Y and Z"]
- [Another issue with impact]
- [Do not assign blame -- focus on systemic causes]

### Blockers Encountered

| Blocker | Duration | Resolution | Prevention |
|---------|----------|------------|------------|
| [What blocked progress] | [How long] | [How it was resolved] | [How to prevent recurrence] |

### Estimation Accuracy

| Task | Estimated | Actual | Variance | Likely Cause |
|------|-----------|--------|----------|--------------|
| [Most overestimated task] | [X] | [Y] | [+Z] | [Why] |
| [Most underestimated task] | [X] | [Y] | [-Z] | [Why] |

**Overall estimation accuracy**: [X%] of tasks within +/- 20% of estimate

[Analysis: Are we consistently over- or under-estimating? For which types of
tasks? What adjustment should we apply?]

### Carryover Analysis

| Task | Original Sprint | Times Carried | Reason | Action |
|------|----------------|---------------|--------|--------|
| [Task that was not completed] | [Sprint N-X] | [N] | [Why] | [Complete / Descope / Redesign] |

### Technical Debt Status
- Current TODO count: [N] (previous: [N])
- Current FIXME count: [N] (previous: [N])
- Current HACK count: [N] (previous: [N])
- Trend: [Growing / Stable / Shrinking]
- [Note any areas of concern]

### Previous Action Items Follow-Up

| Action Item (from Sprint N-1) | Status | Notes |
|-------------------------------|--------|-------|
| [Previous action] | [Done / In Progress / Not Started] | [Context] |

### Action Items for Next Iteration

| # | Action | Owner | Priority | Deadline |
|---|--------|-------|----------|----------|
| 1 | [Specific, measurable action] | [Who] | [High/Med/Low] | [When] |
| 2 | [Another action] | [Who] | [Priority] | [When] |

### Process Improvements
- [Specific change to how we work, with expected benefit]
- [Another improvement -- keep it to 2-3 actionable items, not a wish list]

### Summary
[2-3 sentence overall assessment: Was this a good sprint/milestone? What is
the single most important thing to change going forward?]
```

---

## Phase 5: 保存回顾

向用户展示回顾与主要发现（完成率、速度趋势、最大阻塞项、最重要的行动项）。

询问："我可以把它写入 `production/retrospectives/retro-sprint-[N]-[date].md` 吗？"（里程碑回顾则为 `production/retrospectives/retro-[milestone-name]-[date].md`）

在 Phase 1b 选择 Start fresh 之后，同一询问还会点名重命名："……并将
`[old file]` 重命名为 `[old file name]-archived-[date].md`？" 若选是，先重命名，再写入；若选否，两者都不发生。

若选是，写入文件，必要时创建 `production/retrospectives/` 目录。结论：**COMPLETE** —— 回顾已保存。

若选否，在此停止。结论：**BLOCKED** —— 用户拒绝写入。

---

## Phase 6: 后续步骤

在 `workflow: minimal`（已在上方解析）下没有冲刺，跳过此问题：
指向回顾文件，并说明其行动项进入简报的构建顺序。

否则，使用 `AskUserQuestion`：
- 提示："回顾已完成。行动项与速度数据已就绪。你希望现在带着这些数据开始冲刺规划吗？"
- 选项：
  - `[A] 是 —— 打开冲刺规划，预先填入回顾行动项与速度变化`
  - `[B] 否 —— 我准备好时会手动参考回顾文件`

若用户选 [A]：继续调用 `/sprint-plan new`，传入回顾文件路径以及行动项与速度变化的摘要，以便冲刺规划器参考。

- 若这是里程碑回顾，运行 `/gate-check` 以正式评估下一阶段的准备情况。

### 指南（Guidelines）

- 诚实且具体。含糊的回顾（"沟通可以更好"）会产生含糊的改进。使用数据与示例。
- 关注系统性问题，而非个人追责。
- 行动项限制在 3-5 个。再多会分散焦点。
- 每个行动项必须有负责人与截止日期。
- 检查之前的行动项是否已完成。反复出现未处理的项是流程异味。
- 若这是里程碑回顾，还要评估里程碑目标是否达成，以及这对整体项目时间线意味着什么。
