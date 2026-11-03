---
name: sprint-status
description: "快速、简洁的冲刺快照——燃尽情况与新兴风险，用于态势感知。回答'冲刺进展如何？'"
argument-hint: "[sprint-number or blank for current]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys story_granularity,workflow`



# 冲刺状态（Sprint Status）

这是一次快速的态势感知检查，不是冲刺评审。它读取当前冲刺计划与用户故事文件，扫描状态标记，并生成一份不超过 30 行的简洁快照。详细冲刺管理请使用
`/sprint-plan update` 或 `/milestone-review`。

**本技能是只读的。** 它从不提出变更、从不请求写入文件，且最多给出一个具体建议。

**`story_granularity`** —— 它决定燃尽读数的粒度：`coarse` 下为**功能级**块（默认，经由 `rigor: minimal`），`balanced`（`rigor: standard`）下为**任务级**，`fine` 下为**验收标准（AC）级**。

---

## 1. 找到冲刺

**参数：** `$ARGUMENTS`（为空 = 使用当前冲刺）

- 若给出参数（例如 `/sprint-status 3`），在
  `production/sprints/` 中搜索匹配 `sprint-003.md`、`sprint-03.md`、`sprint-3.md`
  或类似命名的文件（`/sprint-plan` 写三位数字）。报告找到的是哪个文件。
- 若未给出参数，在
  `production/sprints/` 中找到最近修改的文件，将其视为当前冲刺。
- 若 `production/sprints/` 不存在或为空：
  - **在 `workflow: minimal` 下按设计没有冲刺**——简报的
    构建顺序就是计划，用户故事文件承载它。改为报告该构建顺序的进度，然后停止：
    1. 下方列表由 `.trae/scripts/story-status.sh` 在你读取本技能之前打印：每个未完成用户故事一行，已按路线的顺序排列（先是 `IN_REVIEW`，再是 `IN_PROGRESS`，然后是 `TODO`——即 `Ready` 或 `Not Started` 的用户故事——按构建顺序），随后是 `BLOCKED`、`OTHER`、
       `NO_STATUS` 以及 `COMPLETE` 计数：

       **运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../scripts/story-status.sh"`

    2. 在 15 行以内打印：`Build order: [N] of [M] stories complete`，取自 `COMPLETE` 行（只计 `Complete` 与 `Done` 的用户故事——`In Review` 不算完成），然后输出 **Next**：第一个 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO` 行上的用户故事。列表已是
       最新的；不要再次运行脚本，也不要重新排序用户故事文件——`In Review` 的用户故事要先关闭，之后 `In Progress` 的那个才继续：它的工作已经写好了。推荐
       `IN_REVIEW` 用 `/story-done [path]`，`IN_PROGRESS` 或 `TODO` 用 `/dev-story [path]`。对每个 `BLOCKED` 用户故事连同其阻塞项一起点名；它
       永远不是 Next。
    3. 所有用户故事均为 `Complete`（或 `Done`）→ 输出 "构建顺序已完成：[M] 个用户故事中
       完成 [M] 个。" 提供三种后续方式：试玩构建；用 `/create-stories` 按简报添加后续用户故事；或运行 `/settings` 提高
       `modes.rigor`，前提是游戏已超出一页简报的规模。
    4. `STORIES none` —— 完全没有用户故事文件 → 输出 "还没有用户故事。运行
       `/create-stories` 将简报的构建顺序转换为用户故事。"
    5. 没有 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO` 行，但 `COMPLETE` 行
       少于总数——每个未完成的用户故事都是 `BLOCKED`、`OTHER`
       （如 `Draft`）或 `NO_STATUS`。此时**没有 Next**，且构建
       顺序**并未**完成：绝不要说已完成。打印 `Build order` 行，
       然后对每个 `BLOCKED` 用户故事连同其阻塞项点名——读取其用户故事
       文件，通常是 `BLOCKED:` 注释——并对其他每个用户故事按其书写状态点名。推荐一个步骤：第一个阻塞项需要什么，否则就
       完成第一个 `Draft` 或无状态用户故事并将其 Status 设为 `Ready`。
  - **在 `standard` 或 `full` 下**，报告："未找到冲刺文件。请用 `/sprint-plan new`
    启动一个冲刺。" 然后停止。

完整读取冲刺文件。提取：
- 冲刺编号与目标
- 开始日期与结束日期
- 所有用户故事或任务条目，含其优先级（Must Have / Should Have /
  Nice to Have）、负责人与估算

---

## 2. 计算剩余天数

使用今天的日期与冲刺文件中的结束日期，计算：
- 冲刺总天数（结束减开始）
- 已用天数
- 剩余天数
- 已消耗时间百分比

若冲刺文件未包含明确日期，注明"未找到冲刺日期——
已跳过燃尽评估。"

---

## 3. 扫描用户故事状态

**首先：检查 `production/sprint-status.yaml`。**

若存在，直接读取它——它是权威的事实来源。
提取每个用户故事的 `status`，以及设置时的 `priority`、`owner` 与 `blocker`——它们填充状态表的各列。无需 markdown 扫描。
使用其 `sprint`、`goal`、`start`、`end` 字段，而不是重新解析冲刺计划。

**若 `sprint-status.yaml` 不存在**（旧版冲刺或首次设置），
回退到 markdown 扫描：

1. 若条目引用了用户故事文件路径，检查该文件是否存在。
   读取该文件并扫描状态标记：DONE、COMPLETE、IN PROGRESS、
   BLOCKED、NOT STARTED（不区分大小写）。
2. 若条目没有文件路径（冲刺计划中的内联任务），扫描
   冲刺计划本身，查找该条目旁的状态标记。
3. 若未找到状态标记，归类为 NOT STARTED。
4. 若引用了文件但文件不存在，归类为 MISSING 并注明。

使用回退方式时，在输出底部添加一条注释：
"⚠ 未找到 `sprint-status.yaml` —— 状态由 markdown 推断。运行 `/sprint-plan update` 生成一个。"

可选（仅快速检查——不要做深度扫描）：在代码根中 grep 与用户故事的
系统 slug 匹配的目录或文件名，以查找实现证据。这只是线索，不是确定的状​​态。

### 陈旧用户故事检测

收集完所有用户故事的状态后，检查每个 IN PROGRESS 用户故事是否陈旧：

- 用**对整组用户故事的一次 grep，而不是逐个读取**来解析日期
  ——日期只有一行，为找它而打开每个进行中的用户故事
  正是这项检查的全部成本：
  ```
  Grep pattern="\*{0,2}(Last Updated|Updated|last-updated|updated_at)\*{0,2}[[:space:]]*:" glob="production/epics/**/story-*.md" output_mode="content"
  ```
  该单一模式接受所有字段名变体。未匹配到的用户故事
  **没有日期**，这与陈旧不同——将其报告为"从未打戳"，不要为它计算年龄。

> **`\*{0,2}` 包装正是它能起作用的原因。** `/create-stories` 输出
> `> **Last Updated**: …`，因此要求单词后紧跟 `:` 的模式
> 匹配不到任何用户故事。再加上正上方的"未匹配 = 从未打戳"规则，
> 这种失败是静默的：每个进行中的用户故事都报告为从未打戳，陈旧用户故事检测永不触发。不要使用裸的 `Updated:`
> 锚点。
- 使用今天的日期计算自该日期以来的天数。
- 若日期早于 4 天前，将该用户故事标记为 **STALE**。（4 天阈值计入了周末——周五最后动过的用户故事要到周三才会显得陈旧。）
- 若在用户故事文件中未找到日期字段，注明 "no timestamp — cannot check staleness."
- 若用户故事没有引用的文件（内联任务），注明 "inline task — cannot check staleness."

STALE 用户故事会包含在输出表中，并汇总到 "Attention Needed"
章节（见 Phase 5 输出格式）。

**陈旧用户故事升级**：若有任何 IN PROGRESS 用户故事被标记为 STALE（4 天以上无进展），燃尽结论
至少升级为 **At Risk**——即使完成百分比处于正常的
On Track 区间。记录该升级原因："At Risk — [S] stale story(ies): [title]
([D] days)[, …]" —— [S] 是 STALE 用户故事的数量，每个都带自己的 [D]，
即自其自身 Last Updated 日期以来的天数（不是最老的年龄，也不是平均值）。

---

## 4. 燃尽评估

计算：
- 已完成任务（DONE 或 COMPLETE）
- 进行中任务（IN PROGRESS）
- 阻塞任务（BLOCKED）
- 未开始任务（NOT STARTED 或 MISSING）
- 完成百分比：(complete / total) * 100

通过比较完成百分比与时间消耗百分比来评估燃尽：

- **On Track**：完成百分比在时间消耗百分比的 10 个百分点以内或更超前
- **At Risk**：完成百分比落后时间消耗百分比 10-25 个百分点
- **Behind**：完成百分比落后时间消耗百分比超过 25 个百分点

若日期不可用，跳过燃尽评估并报告 "On Track /
At Risk / Behind：未知 —— 未找到冲刺日期。"

---

## 5. 输出

保持输出简洁。用户故事状态表是必需的——不要截断它。总行数控制在 50 行以内；若没有值得注意的内容，省略 Emerging Risks 章节。使用此格式：

```markdown
## Sprint [N] Status — [Today's Date]
**Sprint Goal**: [from sprint plan]
**Days Remaining**: [N] of [total] ([% time consumed])

### Progress: [complete/total] tasks ([%])

| Story / Task         | Priority   | Status      | Owner   | Blocker        |
|----------------------|------------|-------------|---------|----------------|
| [title]              | Must Have  | DONE        | [owner] |                |
| [title]              | Must Have  | IN PROGRESS | [owner] |                |
| [title]              | Must Have  | BLOCKED     | [owner] | [brief reason] |
| [title]              | Should Have| NOT STARTED | [owner] |                |

### Attention Needed
| Story / Task         | Status      | Last Updated   | Days Stale | Note           |
|----------------------|-------------|----------------|------------|----------------|
| [title]              | IN PROGRESS | [date or N/A]  | [N days]   | [STALE / no timestamp — cannot check staleness / inline task — cannot check staleness] |

*(Omit this section entirely if no IN PROGRESS stories are stale or have timestamp concerns.)*

### Burndown: [On Track / At Risk / Behind]
[1-2 sentences. If behind: which Must Haves are at risk. If on track: confirm
and note any Should Haves the team could pull.]

### Must-Haves at Risk
[List any Must Have stories that are BLOCKED or NOT STARTED with less than
40% of sprint time remaining. If none, write "None."]

### Emerging Risks
[Any risks visible from the story scan: missing files, cascading blockers,
stories with no owner. If none, write "None identified."]

### Recommendation
[One concrete action, or "Sprint is on track — no action needed."]
```

---

## 6. 快速升级规则

在输出前应用这些规则，若触发则将标记放在输出**顶部**（状态表之上）：

**Critical 标记**——若有 Must Have 用户故事为 BLOCKED 或 NOT STARTED 且
剩余冲刺时间不足 40%：

```
SPRINT AT RISK: [N] Must Have stories are not complete with [X]% of sprint
time remaining. Recommend replanning with `/sprint-plan update`.
```

**Completion 标记**——若所有 Must Have 用户故事均为 DONE：

```
All Must Haves complete. Team can pull from Should Have backlog.
```

**Missing stories 标记**——若有任何引用的用户故事文件不存在：

```
NOTE: [N] story files referenced in the sprint plan are missing.
Run `/story-readiness sprint` to validate story file coverage.
```

---

## 协作协议（Collaborative Protocol）

本技能是只读的。它报告磁盘文件中的观察事实。

- 它不更新冲刺计划
- 它不改变用户故事状态
- 它不提出范围裁剪（那是 `/sprint-plan update`）
- 每次运行最多给出一个建议

关于某个用户故事的更多细节，用户可以直接读取用户故事文件，
或运行 `/story-readiness [path]`。

冲刺重新规划请使用 `/sprint-plan update`。
冲刺结束回顾请使用 `/retrospective`。