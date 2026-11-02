# Skill Test Spec: /sprint-plan

## Skill Summary

`/sprint-plan`（`new`、`update` 或 `status`）从用户故事待办池规划冲刺。它对 `production/epics/**/story-*.md` 做 glob，grep 它们的状态行，并从标记为 `Ready` 的用户故事中规划，数量以 `story_granularity` 允许为限；它读取上一个冲刺（从注入的 Existing Sprints 列表中识别）以获取速度和结转，并在存在时读取 `production/milestones/` 中的里程碑与 GDD 作为上下文。对于 `new`，它把冲刺编号设为列表中最高的 `sprint-NNN.md` 加一，并在任何写入之前展示包含 Must Have / Should Have / Nice to Have 任务表，以及一个 Carryover from Previous Sprint 表（上一个冲刺中每个非 Complete 的用户故事，仅在该表中列出）的草稿，同时准备 `production/sprint-status.yaml`。评审模式来自注入的配置块，`--review` 可为一次运行覆盖它；技能从不询问评审模式，也从不写入 `modes.review_mode` 或 `production/review-mode.txt`。在完整评审模式下，PR-SPRINT producer 闸门评审草稿；在 lean 和 solo 模式下，闸门会被跳过并给出说明。QA 计划检查在所有模式下都会运行。技能在持久化之前询问“May I write the sprint plan to `production/sprints/sprint-NNN.md` and `production/sprint-status.yaml`?”。结论：COMPLETE（两个文件都已写入）或 BLOCKED（未找到用户故事，或拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 措辞（技能会写入冲刺文件）
- [ ] 具有下一步交接（`/qa-plan sprint`、`/story-readiness`、`/dev-story`）

---

## Director Gate Checks

| Gate ID   | Trigger condition                                  | Mode guard                |
|-----------|----------------------------------------------------|---------------------------|
| PR-SPRINT | After the draft is presented, before write approval | full only (not lean/solo) |

PR-SPRINT 结论：REALISTIC / CONCERNS / UNREALISTIC——或 NOT ASSESSED [missing input]（`.claude/docs/director-gates.md`），后者绝不被视作 REALISTIC。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— Ready 待办池生成冲刺

**Fixture:**
- 注入的 Existing Sprints 列表显示 `sprint-001.md` 和 `sprint-002.md`
- `production/milestones/milestone-02.md` 存在
- `production/epics/` 下跨 2 个史诗有 5 个用户故事为 `Status: Ready`
- `project.yaml` 设置 `modes.review_mode: full` 和 `modes.story_granularity: balanced`（每冲刺 6–10 个用户故事）
- `production/qa/qa-plan-sprint-003.md` 存在
- producer 返回 REALISTIC

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能读取里程碑和上一个冲刺（sprint-002）
2. 技能对 `production/epics/**/story-*.md` 做 glob，grep 状态行，并规划全部 5 个 `Ready` 用户故事——少于 `balanced` 所允许的数量，因此待办池就是限制
3. 技能把新冲刺编号为 003（sprint-002 是列表中最高的），并展示草稿而不询问是否写入
4. 技能以用户故事清单、产能、结转和里程碑约束生成 PR-SPRINT；展示 REALISTIC 评估
5. QA 计划检查找到 `production/qa/qa-plan-sprint-003.md` 并记录下来
6. 技能询问“May I write the sprint plan to `production/sprints/sprint-003.md` and `production/sprint-status.yaml`?”
7. 用户批准；两个文件都被写入；结论 COMPLETE

**Assertions:**
- [ ] 用户故事来自 `production/epics/**/story-*.md`，通过状态 grep 获取，且只规划 `Ready` 用户故事
- [ ] 全部 5 个 `Ready` 用户故事都被规划——`balanced` 允许 6–10 个，因此没有遗漏
- [ ] 冲刺草稿在任何写入提示或闸门调用之前展示
- [ ] PR-SPRINT 闸门在完整模式下于草稿展示后调用
- [ ] “May I write”提示同时指名 `production/sprints/sprint-003.md`（sprint-002 之后的编号）和 `production/sprint-status.yaml`
- [ ] 两个文件写入后结论为 COMPLETE

---

### Case 2: 受阻路径 —— 待办池中没有用户故事

**Fixture:**
- `production/epics/` 不含用户故事文件（`production/epics/**/story-*.md` 无匹配）
- 无 `--review` 标志，`project.yaml` 中无 `modes.review_mode`，无 `production/review-mode.txt`

**Input:** `/sprint-plan new`

**Expected behavior:**
1. Phase 0 从注入的配置块获取评审模式——若未配置任何内容，则取 `modes.rigor` 的值——且不询问评审深度问题
2. Phase 1 的 glob 返回空；技能输出“No stories found under `production/epics/`. Run `/create-stories` first (at `standard`/`full`, `/create-epics` before it).”
3. 技能停止且不臆造工作项；结论 BLOCKED
4. 不调用闸门，也不写入任何内容

**Assertions:**
- [ ] 结论为 BLOCKED
- [ ] 输出包含“No stories found under `production/epics/`”并推荐 `/create-stories`
- [ ] 不从臆造的工作项产出冲刺草稿
- [ ] 不调用 PR-SPRINT 闸门
- [ ] 不询问评审深度问题，也不发生写入——`project.yaml` 不新增 `modes.review_mode`，也不创建 `production/review-mode.txt`

---

### Case 3: 闸门返回 CONCERNS —— 冲刺超载，写入前修订

**Fixture:**
- 8 个 `Ready` 用户故事，合计估算 16 天；可用产能为 10 天
- `project.yaml` 设置 `modes.review_mode: full` 和 `modes.story_granularity: balanced`
- `production/qa/` 中存在该冲刺的 QA 计划
- producer 返回 CONCERNS：冲刺超载

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能以全部 8 个用户故事起草冲刺并展示
2. PR-SPRINT 运行；producer 返回 CONCERNS
3. 技能通过 `AskUserQuestion` 询问：“Producer flagged concerns with this sprint plan. How do you want to proceed?”，选项为 [A] 按原计划继续、[B] 调整范围、[C] 延长冲刺时间线
4. 用户选择 [B]；技能修订用户故事清单并重新展示计划
5. 技能就修订后的计划询问“May I write”；批准后写入

**Assertions:**
- [ ] PR-SPRINT 的 CONCERNS 在任何写入之前通过 `AskUserQuestion` 呈现（[A] 继续 / [B] 调整范围 / [C] 延长时限）
- [ ] 选择 [B] 后，修订后的计划在写入批准之前重新展示
- [ ] 写入的是修订后的冲刺（而非原始版本），且 `production/sprint-status.yaml` 列出修订后的用户故事
- [ ] 修订并写入后结论为 COMPLETE

---

### Case 4: Lean 模式 —— 跳过 PR-SPRINT，QA 计划检查仍运行

**Fixture:**
- `production/epics/` 下有 4 个 `Ready` 用户故事
- `project.yaml` 设置 `modes.rigor: standard` 且未固定评审模式（无 `modes.review_mode`、无 `production/review-mode.txt`、无 `--review`），因此注入块读作 `review_mode: lean (rigor:standard)`
- `production/qa/` 中不存在该冲刺的 QA 计划

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能从注入的配置块读取 `review_mode`——为 `lean`——且不询问评审深度问题
2. 技能起草冲刺并展示
3. 跳过 PR-SPRINT；输出注明“PR-SPRINT skipped — Lean mode.”
4. QA 计划检查仍运行：技能说明“This sprint has no QA plan …”，并通过 `AskUserQuestion` 提供 [A] 现在运行 /qa-plan sprint 和 [B] 暂时跳过
5. 用户选择 [A]；技能请求直接批准写入
6. 用户批准；两个文件都被写入；结论 COMPLETE

**Assertions:**
- [ ] 在 lean 模式下不调用 PR-SPRINT 闸门
- [ ] 输出包含“PR-SPRINT skipped — Lean mode.”
- [ ] QA 计划检查在 lean 模式下仍运行——缺失的 QA 计划被显式呈现并给出 [A]/[B] 选择，而非静默略过
- [ ] 写入之前仍需要用户批准（跳过闸门 ≠ 跳过批准）
- [ ] 解析出的 `lean` 被直接使用且不询问评审深度问题，写入只指名冲刺计划和 `production/sprint-status.yaml`——`project.yaml` 不新增 `modes.review_mode`，也不创建 `production/review-mode.txt`
- [ ] 写入后结论为 COMPLETE

---

### Case 5: 边界情况 —— 上一个冲刺仍有未关闭的用户故事

**Fixture:**
- 注入的 Existing Sprints 列表显示 `sprint-002.md` 为最新冲刺
- `production/sprint-status.yaml` 仍保存冲刺 2；其中 2 个用户故事不是 `done`：一个是 `in-progress`，另一个是从未开始的 `ready-for-dev`（其用户故事文件写着 `Status: Ready`）
- 另外 5 个用户故事为 `Status: Ready`
- `project.yaml` 设置 `modes.review_mode: full` 和 `modes.story_granularity: balanced`
- `production/qa/` 中存在该冲刺的 QA 计划

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能读取 sprint-002 以获取速度和结转，并把新冲刺编号为 003
2. 技能把另外 5 个 `Ready` 用户故事规划进 Must Have / Should Have / Nice to Have 表
3. sprint-002 的 2 个未完成用户故事出现在“Carryover from Previous Sprint”表中，并带有原因和新估算——未开始的那个仅出现在该表，尽管其用户故事文件写着 `Ready`
4. 结转与拟议的用户故事清单一并传给 PR-SPRINT
5. 技能询问“May I write the sprint plan to `production/sprints/sprint-003.md` and `production/sprint-status.yaml`?”，并在批准后写入；新的 yaml 在 5 个新用户故事之外列出这 2 个结转用户故事

**Assertions:**
- [ ] 技能读取上一个冲刺（sprint-002，从注入列表识别）
- [ ] 2 个未完成的用户故事出现在“Carryover from Previous Sprint”表中，带有 Reason 和 New Estimate——未被悄悄丢弃
- [ ] 未开始的 sprint-002 用户故事只出现在 Carryover 下——不再重复出现在 Must Have / Should Have / Nice to Have，尽管其状态为 `Ready`
- [ ] 结转被传给 PR-SPRINT 闸门
- [ ] 写入的 `production/sprint-status.yaml` 列出 2 个结转用户故事及其先前优先级和当前状态（`in-progress`、`ready-for-dev`）

---

### Case 6: 闸门返回 UNREALISTIC —— 写入前延期部分用户故事

**Fixture:**
- 注入的 Existing Sprints 列表显示 `sprint-002.md` 为最新冲刺
- 9 个 `Ready` 用户故事，合计估算 20 天；可用产能为 10 天
- `project.yaml` 设置 `modes.review_mode: full` 和 `modes.story_granularity: balanced`
- `production/qa/` 中存在该冲刺的 QA 计划
- producer 返回 UNREALISTIC，并指名 4 个要延期的用户故事

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能以这 9 个用户故事起草冲刺 003 并展示
2. PR-SPRINT 运行；producer 返回 UNREALISTIC
3. 技能修订选择——被指名的 4 个用户故事下移至 Should Have 或 Nice to Have——并重新展示修订后的计划
4. QA 计划检查运行，随后技能就修订后的计划询问“May I write”
5. 用户批准；两个文件都被写入；结论 COMPLETE

**Assertions:**
- [ ] UNREALISTIC 不会结束运行，且原始计划绝不会被写入——先修订选择
- [ ] 被指名的 4 个用户故事被延至 Should Have 或 Nice to Have，而非从计划中删除
- [ ] 修订后的计划在“May I write”提示之前重新展示
- [ ] 写入的 `production/sprint-status.yaml` 把延期用户故事记为 `should-have` 或 `nice-to-have`，并带 `status: backlog`
- [ ] 写入后结论为 COMPLETE

---

### Case 7: 闸门返回 NOT ASSESSED —— 无用户故事估算

**Fixture:**
- 5 个 `Ready` 用户故事，都没有填写 `Estimate`
- `project.yaml` 设置 `modes.review_mode: full` 和 `modes.story_granularity: balanced`
- `production/qa/` 中存在该冲刺的 QA 计划
- producer 返回 NOT ASSESSED——用户故事没有估算
- 被问及估算时，用户尚无估算并继续推进

**Input:** `/sprint-plan new`

**Expected behavior:**
1. 技能起草冲刺并展示；PR-SPRINT 返回 NOT ASSESSED
2. 技能指名缺失的输入（用户故事估算），并不把结果视作 REALISTIC；由于没有估算可提供，它在计划头部把 PR-SPRINT 记录为 `NOT ASSESSED — [missing input]`
3. QA 计划检查运行；“May I write”提示重申 PR-SPRINT 未评估
4. 用户批准；两个文件都被写入；结论 COMPLETE

**Assertions:**
- [ ] 缺失的输入（用户故事估算）在输出中被指名
- [ ] NOT ASSESSED 不被呈现为 REALISTIC——没有任何内容声称计划的可行性已被评审
- [ ] 针对 NOT ASSESSED 不发起 CONCERNS 选项（[A] 继续 / [B] 调整范围 / [C] 延长时限）
- [ ] 写入计划的头部把 PR-SPRINT 记录为 NOT ASSESSED 并注明缺失输入，且“May I write”提示在写入前如此说明

---

## Protocol Compliance

- [ ] 在调用 PR-SPRINT 或询问是否写入之前展示冲刺草稿
- [ ] 写入之前始终询问“May I write”，并同时指名冲刺文件和 `production/sprint-status.yaml`
- [ ] 从不询问评审深度，也从不写入 `modes.review_mode` 或 `production/review-mode.txt`——使用解析出的值（或 `--review`）
- [ ] PR-SPRINT 闸门仅在完整模式下运行
- [ ] 跳过说明出现在 lean 和 solo 模式的输出中
- [ ] QA 计划检查在每种评审模式下都运行
- [ ] 结论（COMPLETE 或 BLOCKED）在技能输出结尾清晰陈述

---

## Coverage Notes

- `update` 和 `status` 模式未测试。
- 没有里程碑文件的情况未测试；技能会注明“no milestone defined — planning against the story backlog alone”并继续，而非阻塞。
- 用户故事文件存在但没有任何标记为 `Ready` 的情况未测试。
- Solo 模式行为与 lean 等价（跳过闸门、需要用户批准），未单独测试。
- 这些用例把 `story_granularity` 固定为 `balanced`（每冲刺 6–10 个用户故事）；`coarse`（2–4）和 `fine`（15–25）的分配未测试。
