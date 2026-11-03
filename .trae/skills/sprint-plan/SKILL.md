---
name: sprint-plan
description: "基于当前里程碑、已完成工作和可用产能，制定新的或更新的冲刺计划。"
argument-hint: "[new|update|status] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,story_granularity,workflow`

已在上一步解析——按原样使用；`--review` 覆盖 `review_mode`。无输出块时 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

# 冲刺计划


## 现有冲刺

**运行并读取输出：** `ls production/sprints/ 2>/dev/null || echo "(no production/sprints/ directory yet)"`

在本技能运行前已解析——用它来在 Phase 1 中识别上一个冲刺，
而不是重新执行 glob。

---

## Phase 0: 解析参数

提取模式参数（`new`、`update` 或 `status`）。

完整检查模式见 `.trae/docs/director-gates.md`。单个质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md`——被派出的 agent 读取自己的 gate 文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大问题 · autonomous 记录日志后继续；
`automation_always_ask` 类别总是提示）。

**`story_granularity`** — 它设定每个冲刺分配多少个
用户故事，并按速度缩放：`coarse` 时 **2–4** 个（默认值，通过 `rigor: minimal`），
`balanced` 时 **6–10** 个（`rigor: standard`），`fine` 时 **15–25** 个。小于范围的
就绪待办事项会被整体规划——绝不用编造的用户故事来填充。

**评审模式检查**（在质量闸门运行之前）：
- 使用上一步命令输出中的评审模式（`--review` 会为此
  次运行覆盖它）——不要重新解析，也不要询问。未配置时，
  它跟随 `modes.rigor`：`minimal` 时为 `solo`，`standard` 时为 `lean`。
- **绝不要写入评审模式**——不要写入 `project.yaml`，也不要写入
  `production/review-mode.txt`。`modes.review_mode` 是 `modes.rigor`
  所前置的旋钮之一：在 `project.yaml` 中固定它会遮蔽 rigor
  展开，而遗留文件位于该展开*之上*，因此任一写入
  都会永久冻结总监评审深度。`--review` 可覆盖一次性需求。如果
  用户希望持久使用不同深度，指引他们修改
  `modes.rigor`（`/settings modes.rigor=<minimal|standard|full>`），或
  有意用 `/settings --local modes.review_mode=<full|lean|solo>` 固定它
  （在 `project.local.yaml` 中的个人覆盖）。

---

## Phase 1: 收集上下文

1. **读取当前里程碑**，从 `production/milestones/` **如果它存在**。
   没有技能写入该目录——它是根据
   `.trae/docs/templates/milestone-definition.md` 手工编写的。在大多数项目中
   它不存在，这是正常状态，而不是缺失：注明“未定义里程碑——仅基于
   用户故事待办事项进行规划”并继续。绝不要因此阻塞
   冲刺规划，也绝不要从冲刺文件推断里程碑。

2. **读取上一个冲刺**（如果有），从 `production/sprints/` 中，
   以了解速度和结转。在 `new` 模式下：
   - 新冲刺的编号 `[N]` 是现有冲刺列表中最高
     `sprint-NNN.md` 的编号加一（没有则为 `001`）。它就是
     计划标题、其 QA 计划路径和写入请求中的 `[N]`。
   - 上一个冲刺中所有状态不是 `Complete` 的用户故事——以
     `production/sprint-status.yaml` 中的状态为准，否则以其用户故事文件的 Status 行为准——
     进入结转表，附上原因和新估算。它只出现在那里，
     绝不再作为新的必须拥有 / 应该有 / 最好有工作出现。

3. **找到要规划的用户故事**——这才是实际的待办事项，也是本阶段
   不可或缺的唯一输入：
   ```
   Glob production/epics/**/story-*.md
   Grep pattern="^> \*\*Status\*\*" glob="production/epics/**/story-*.md" output_mode="content"
   ```
   用户故事位于 `production/epics/[epic-slug]/story-NNN-[slug].md`——这正是
   `/create-stories` 写入它们、`/dev-story` 查找它们的位置。基于标记为
   `Ready` 的用户故事进行规划。使用 grep 而不是逐个读取：在此阶段，
   你需要的是状态和标题，而不是正文。

   如果 glob 返回空：“在 `production/epics/` 下未找到用户故事。请先运行
   `/create-stories`（在 `standard`/`full` 下，在此之前运行 `/create-epics`）。”
   不要继续编造工作项——引用不存在用户故事的冲刺计划
   无法实施。结论（Verdict）：**BLOCKED** — 没有可规划的用户故事。

4. **扫描设计文档**，在 `design/gdd/` 中查找这些用户故事所实现功能的
   额外上下文。按章节阅读每份文档：用 Grep 工具（pattern `^#`，content 模式）
   找到所需标题，再用 offset 和 limit 读取相应范围。在 `workflow: minimal` 下
   没有按系统的 GDD——改用 `design/game-brief.md`，且不要将
   缺失的 GDD 视为缺失的工作。（注意：`/sprint-plan` 在
   `minimal` 下是**可选的**——简报的构建顺序本身就是计划。）

5. **检查风险登记册**，在 `production/risk-register/` **如果它存在**。
   与上面的里程碑一样，没有技能写入它——条目是根据
   `.trae/docs/templates/risk-register-entry.md` 手工编写的。如果该目录
   不存在，说明一次（“无风险登记册——仅基于冲刺
   内容评估风险”），而不是静默跳过风险评估。

---

## Phase 2: 生成输出

对于 `new`：

**生成一份冲刺计划**，遵循以下格式并呈现给用户。先不要请求写入——
质量闸门阶段先运行，并可能在写入文件前要求修订：制作人可行性闸门
（Phase 4，仅在 `full` 评审模式下派出——在 `lean`/`solo` 中跳过）和
QA 计划检查（Phase 5，所有模式）。

```markdown
# Sprint [N] — [Start Date] to [End Date]

## Sprint Goal
[One sentence describing what this sprint achieves toward the milestone]

## Goal Prerequisites
| Needed to show the goal | Status |
|-------------------------|--------|

## Capacity
- Total days: [X]
- Buffer (20%): [Y days reserved for unplanned work]
- Available: [Z days]

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

## Carryover from Previous Sprint
| Task | Reason | New Estimate |
|------|--------|-------------|

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|

## Dependencies on External Factors
- [List any external dependencies]

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-[sprint-slug]-[date].md`, from `/qa-plan sprint`)
- [ ] All Logic/Integration stories have passing unit/integration tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] QA sign-off report: APPROVED or APPROVED WITH CONDITIONS (`/team-qa sprint`)
- [ ] No S1 or S2 bugs in delivered features
- [ ] Design documents updated for any deviations
- [ ] Code reviewed and merged
```

### 检查目标的先决条件

在呈现 `new` 计划之前，检查其目标能否在冲刺结束时
展示为可运行状态。一个目标可能需要没有任何用户故事构建的东西：
试玩测试需要有一个可运行的场景。此检查只报告，绝不阻塞。它不增加问题，
也不增加自己的用户故事。

1. **确定目标。** 有里程碑目标时引用它；否则，
   根据所选用户故事写一句话。
2. **列出展示它所需的东西。** 玩家能看到或能玩到的目标（可玩的
   循环、端到端可用的功能、试玩测试）需要其运行的场景或关卡
   以及启动它的设置：`project.godot` 中的 `run/main_scene`，
   Unity 的 `ProjectSettings/EditorBuildSettings.asset` 中的场景列表，或
   Unreal 的 `Config/DefaultEngine.ini` 中的 `GameDefaultMap`。添加任何被选中用户故事的
   验收标准、备注或依赖所命名、且没有任何被选中用户故事
   创建的文件、场景或系统。没有可运行或展示内容的目标（仅逻辑
   和测试）不需要任何先决条件。
3. **逐项检查。** 当它存在于项目中，或某个被选中的用户故事会构建它时，
   即视为已覆盖。通过引擎的场景文件（`project.yaml` 中的 `engine.name`）
   查找场景：Godot 用 `*.tscn`，Unity 用 `Assets/**/*.unity`，
   Unreal 用 `Content/**/*.umap`。其他任何东西按用户故事使用的路径或名称查找。
   未设置引擎时，仅按名称检查，并说明场景搜索未运行。
4. **填写目标先决条件章节**：每项需求标注 `exists`、
   `built by [story ID]` 或 **missing**，或单行“None: the goal has
   nothing to run or show”。将每个缺失项复制到风险中。呈现计划时，
   点名每个缺失项以及用户可用的三种修复方式：引入
   构建它的就绪用户故事（点名它，并说明这会让冲刺超出
   其 `story_granularity` 范围，还是需要它所依赖的用户故事），先用
   `/create-stories` 为它写一个用户故事，或改写目标，只承诺
   冲刺能展示的内容。把它们作为计划的一部分给出，
   而不是作为问题：写入请求仍是唯一的问题，想修复的用户
   在回复它时说明。**报告缺口；不要解决它。** 缺失的先决条件
   在本计划中保持缺失，无论它看起来多小（一个
   平坦的测试关卡、一个输入映射）：不为它规划任务，也不把它的任何工作
   放进被选中的用户故事，连设置都不行。它的工作首先需要一个用户故事，
   那是 `/create-stories` 的职责。绝不要添加待办事项中不存在的
   用户故事，也绝不要扩大被选中的用户故事或编辑用户故事文件来
   覆盖缺口。

对于 `update`：

**更新现有冲刺计划**：

1. 从 `production/sprints/` 读取最近的冲刺计划。
2. 呈现当前用户故事列表及其在 `production/sprint-status.yaml` 中的当前状态。
3. 询问用户要更改什么：添加、移除、重新排序或重新估算用户故事。使用 `AskUserQuestion` 收集更改。
4. 应用更改，并重新呈现完整修订计划以供审查。如果
   目标或必须拥有的用户故事发生了变化，先再次检查目标的先决条件。
5. 对修订后的计划重新运行制作人可行性闸门（Phase 4）。
6. 一起写入更新后的 markdown 计划和 yaml（与 `new` 模式相同的审批）。

注意：`update` 模式不会重置用户故事状态。已标记为 `in-progress` 或 `done` 的用户故事保持其状态。只有 `backlog` 和 `ready-for-dev` 用户故事可以自由移除或重新排序。

对于 `status`：

**生成状态报告**：

```markdown
# Sprint [N] Status -- [Date]

## Progress: [X/Y tasks complete] ([Z%])

### Completed
| Task | Completed By | Notes |
|------|-------------|-------|

### In Progress
| Task | Owner | % Done | Blockers |
|------|-------|--------|----------|

### Not Started
| Task | Owner | At Risk? | Notes |
|------|-------|----------|-------|

### Blocked
| Task | Blocker | Owner of Blocker | ETA |
|------|---------|-----------------|-----|

## Burndown Assessment
[On track / Behind / Ahead]
[If behind: What is being cut or deferred]

## Emerging Risks
- [Any new risks identified this sprint]
```

---

## Phase 3: 准备冲刺状态文件

生成新的冲刺计划后，还要准备 `production/sprint-status.yaml` 的内容。
这是用户故事状态的机器可读事实来源——由
`/sprint-status`、`/story-done` 和 `/help` 读取，无需解析 markdown。

**先不要写入 yaml**——在上下文中保留它。制作人可行性闸门（Phase 4，仅 `full` 评审模式）可能修订用户故事列表；QA 计划检查（Phase 5）在所有模式下运行。两个文件在 Phase 5 之后以单次写入审批一起写入。

格式：

```yaml
# Auto-generated by /sprint-plan. Updated by /story-done and /dev-story.
# DO NOT edit manually — use /story-done to update story status.
#
# Status value mapping (yaml ↔ story file Status field):
#   backlog        ↔  Not Started
#   ready-for-dev  ↔  Ready
#   in-progress    ↔  In Progress
#   review         ↔  In Review
#   done           ↔  Complete
#   blocked        ↔  Blocked

sprint: [N]
goal: "[sprint goal]"
start: "[YYYY-MM-DD]"
end: "[YYYY-MM-DD]"
generated: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"

stories:
  - id: "[epic-story, e.g. 1-1]"
    name: "[story name]"
    file: "[production/epics/[epic-slug]/story-NNN-[slug].md]"   # the real path, verbatim from the Glob above
    priority: must-have        # must-have | should-have | nice-to-have
    status: ready-for-dev      # backlog | ready-for-dev | in-progress | review | done | blocked
    owner: ""
    estimate_days: 0
    blocker: ""
    completed: ""
```

从冲刺计划的任务表初始化每个用户故事：
- 必须拥有任务 → `priority: must-have`、`status: ready-for-dev`
- 应该有任务 → `priority: should-have`、`status: backlog`
- 最好有任务 → `priority: nice-to-have`、`status: backlog`
- 结转行 → 该用户故事之前的 `priority`，以及它当前拥有的 `status`

对于 `update`：读取现有的 `sprint-status.yaml`，沿用未变更用户故事的状态，
添加新用户故事，移除被丢弃的用户故事。

---

## Phase 4: 制作人可行性闸门

**评审模式检查**——在派出 PR-SPRINT 之前应用：
- `solo` → 跳过。注明：“PR-SPRINT 已跳过——Solo 模式。”继续到 Phase 5（QA 计划闸门）。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“PR-SPRINT 已跳过——Lean 模式。”继续到 Phase 5（QA 计划闸门）。
- `full` → 照常派出。

在最终确定冲刺计划之前，通过 `Agent` 使用质量闸门 **PR-SPRINT**（`.trae/docs/director-gates/pr-sprint.md`）派出 `producer`。

传递：拟议的用户故事列表（标题、估算、依赖）、团队总产能（小时/天）、上一个冲刺的任何结转、里程碑约束和截止日期，以及任何缺失的目标先决条件。

呈现制作人的评估。

如果为 UNREALISTIC：修订用户故事选择（将用户故事推迟到应该有或最好有），重新呈现更新后的计划，然后继续到 Phase 5。

如果为 NOT ASSESSED：点名缺失的输入——它不是 REALISTIC。提供该输入并重新运行 PR-SPRINT，或在计划的头部（`.trae/docs/director-gates.md`）中为 PR-SPRINT 记录 `NOT ASSESSED — [missing input]` 并继续到 Phase 5，在写入请求时重复说明。

如果为 CONCERNS，使用 `AskUserQuestion`：
- 提示：“制作人认为此冲刺计划存在关注项。你希望如何继续？”
- 选项：
  - `[A] Proceed as planned — I accept the risk`
  - `[B] Adjust scope — defer some Should Have stories`
  - `[C] Extend the sprint timeline`

如果选 [A]：继续到 Phase 5。
如果选 [B]：修订用户故事列表，重新呈现更新后的计划，然后继续到 Phase 5。
如果选 [C]：调整冲刺日期和产能，重新呈现更新后的计划，然后继续到 Phase 5。

处理完制作人的结论后，继续到 Phase 5。写入发生在其末尾，
因此你批准的文件已经包含 Phase 5 添加的所有内容。

---

## Phase 5: QA 计划闸门

在结束冲刺计划之前，检查此冲刺是否存在 QA 计划。

使用 `Glob` 查找 `production/qa/qa-plan-*.md`——`/qa-plan` 写入 `qa-plan-[sprint-slug]-[date].md`——并保留一个名称或内容引用此冲刺编号的文件。

**如果找到 QA 计划**：在冲刺计划输出中注明——“QA Plan: `[path]`”——然后继续。

**如果不存在 QA 计划**：不要静默继续。明确暴露这一点：

> “此冲刺没有 QA 计划。没有 QA 计划的冲刺计划意味着测试需求未定义——开发者不会知道从 QA 角度看什么算‘完成’，而且没有它冲刺无法通过 Production → Polish 质量闸门。
>
> 现在、在任何实现开始之前运行 `/qa-plan sprint`。它只需一次会话，并产出每个用户故事所需的测试用例需求。”

使用 `AskUserQuestion`：
- 提示：“未找到此冲刺的 QA 计划。你希望如何继续？”
- 选项：
  - `[A] Run /qa-plan sprint now — I'll do that before starting implementation (Recommended)`
  - `[B] Skip for now — I understand QA sign-off will be blocked at the Production → Polish gate`

在下面的写入请求之前等待此答案——这是两个独立的问题。
这里的答案永远不是写入批准，即使是“yes, go ahead”或“once the plan is written”：
接下来提问写入问题，并且只有在对它回答 yes 后才写入。

如果选 [A]：在计划中注明“QA plan: run `/qa-plan sprint` before implementation begins.”
如果选 [B]：在冲刺计划文档中添加警告块：

```markdown
> ⚠️ **No QA Plan**: This sprint was started without a QA plan. Run `/qa-plan sprint`
> before the last story is implemented. The Production → Polish gate requires a QA
> sign-off report, which requires a QA plan.
```

### 写入计划

询问：“我可以把冲刺计划写入 `production/sprints/sprint-NNN.md`（`[N]` 补零到三位数）和
`production/sprint-status.yaml` 吗？”即使较早的答案听起来像 yes，也要问。如果同意，写入两个文件（按需
创建目录）。结论（Verdict）：**COMPLETE** — 冲刺计划和状态文件已创建。如果拒绝：
结论（Verdict）：**BLOCKED** — 用户拒绝写入。

写入后，添加：

> **范围检查：** 如果此冲刺包含超出原始史诗（epic）范围添加的用户故事，运行 `/scope-check [epic]` 以在实现开始前检测范围蔓延。

如果用户在 Phase 5 选择了 `Run /qa-plan sprint now`，以“冲刺计划已写入。接下来运行 `/qa-plan sprint`——然后开始实现。”结束。

---

## Phase 6: 后续步骤

在冲刺计划写入且 QA 计划状态解决后：

- `/qa-plan sprint` — **在实现开始前必需** — 为每个用户故事定义测试用例，使开发者依据 QA 规格实现，而不是白手起家
- `/story-readiness [story-file]` — 在开始用户故事之前验证其已就绪
- `/dev-story [story-file]` — 开始实现第一个用户故事
- `/sprint-status` — 在冲刺中期检查进度
- `/scope-check [epic]` — 在实现开始前验证没有范围蔓延

**评审模式配置：** 所有总监闸门（制作人可行性、QA 评审、代码评审）都遵循项目评审模式，在本技能顶部的块中解析（`--review` 标志 → `project.local.yaml` → `project.yaml` 中的 `modes.review_mode` → `production/review-mode.txt` → `modes.rigor` 展开，在 standard rigor 下产生 `lean`，在 minimal 下产生 `solo`）。本技能从不询问或写入它；Phase 0 说明了希望使用不同深度的用户应指向何处。该模式是以下之一：
- `lean` — 跳过非阶段闸门的总监闸门（即 `rigor: standard` 的值）
- `full` — 以派生子代理的方式运行所有总监闸门
- `solo` — 无条件跳过所有闸门派出（单开发者，无评审）

`project.yaml` 中的 `modes.review_mode` 是主要来源；`production/review-mode.txt` 是遗留回退。两者都会在启动时被 `/sprint-plan`、`/story-readiness`、`/story-done` 以及其他使用闸门的技能读取。