# Skill Test Spec: /retrospective

## Skill Summary

`/retrospective` 生成冲刺或里程碑回顾。在加载任何数据之前，它检查 `production/retrospectives/` 中是否已有回顾，并提供更新它或重新开始（归档旧文件）的选项。它读取 `production/sprints/` 中的冲刺计划（或里程碑定义），在 `production/sprint-status.yaml` 存在时把它作为完成情况的主要来源，为冲刺期间运行 `git log`，统计 TODO/FIXME/HACK 标记，并读取先前回顾以跟进其行动项。输出涵盖 Metrics、Velocity Trend、What Went Well、What Went Poorly、Blockers Encountered、Estimation Accuracy、Carryover Analysis、Technical Debt Status、Previous Action Items Follow-Up、Action Items for Next Iteration、Process Improvements 和一个 Summary；若某小节的输入缺失，该小节读作 `NOT ASSESSED — NO DATA`，且 yaml 中每个 `blocked` 用户故事都是一个带行动项的 Blocker。当不存在冲刺数据时，它提供手动输入或停止——并且在 `workflow: minimal` 下，提供查看已关闭用户故事的选项。不使用任何总监闸门——回顾是团队自我反思的产出物。技能询问“May I write this to `production/retrospectives/retro-sprint-[N]-[date].md`?”（在 Start fresh 之后还指名归档重命名），之后提供开始 `/sprint-plan new` 的选项。结论：COMPLETE（回顾已保存）或 BLOCKED（用户在无数据提示处停止或拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 措辞（技能会写入回顾文档）
- [ ] 具有下一步交接（提供开始 `/sprint-plan new`；里程碑回顾之后为 `/gate-check`）

---

## Director Gate Checks

无。回顾是团队自我反思文档，不调用任何闸门。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 结果有喜有忧的冲刺

**Fixture:**
- `production/sprints/sprint-005.md` 存在，含 6 个用户故事；`production/sprints/` 中没有更早的冲刺计划
- `production/sprint-status.yaml` 覆盖冲刺 5：4 个用户故事为 `done`，1 个为 `blocked`（`blocker: "Waiting on the save-format decision"`），1 个仍为 `backlog`
- `project.yaml` 设置 `modes.workflow: standard`
- `production/retrospectives/` 中完全没有回顾

**Input:** `/retrospective sprint-005`

**Expected behavior:**
1. 技能对 `production/retrospectives/retro-sprint-005-*.md` 做 glob——无匹配
2. 技能读取冲刺计划和 `production/sprint-status.yaml`，把 yaml 作为完成情况的主要来源（6 个中完成 4 个）
3. 技能为冲刺期间运行 `git log` 并统计 TODO/FIXME/HACK 标记
4. 技能按其模板生成回顾。由于没有更早的冲刺或回顾，Velocity Trend 和 Previous Action Items Follow-Up 读作 `NOT ASSESSED — NO DATA`，并指名缺失了什么
5. 技能展示回顾及主要发现（完成率、速度趋势——报告为未评估、最大阻塞项、最重要的行动项）
6. 技能询问“May I write this to `production/retrospectives/retro-sprint-005-[today's date].md`?”
7. 用户批准；文件被写入；结论 COMPLETE
8. 技能询问是否现在开始冲刺规划（`/sprint-plan new`）

**Assertions:**
- [ ] 回顾包含 What Went Well、What Went Poorly 和 Action Items for Next Iteration 小节
- [ ] 完成指标来自 `production/sprint-status.yaml`（6 个中完成 4 个），而非扫描 markdown
- [ ] 受阻的用户故事出现在 Blockers Encountered 下，其 Blocker 为 "Waiting on the save-format decision"，并有一个行动项针对它
- [ ] Velocity Trend 读作 `NOT ASSESSED — NO DATA`——不会仅凭单个冲刺臆造 Increasing / Stable / Decreasing 趋势或更早冲刺的行
- [ ] Previous Action Items Follow-Up 读作 `NOT ASSESSED — NO DATA`（没有更早的回顾），而非空表
- [ ] “May I write”提示指名 `production/retrospectives/retro-sprint-005-[today's date].md`，并在写入之前出现
- [ ] 写入后结论为 COMPLETE，随后提供开始 `/sprint-plan new` 的选项

---

### Case 2: 无冲刺数据 —— 手动输入回退

**Fixture:**
- 用户调用 `/retrospective sprint-009`
- `production/sprints/sprint-009.md` 不存在，且 `production/sprint-status.yaml` 中没有冲刺 9
- `project.yaml` 设置 `modes.workflow: standard`
- 不存在 sprint-009 的回顾

**Input:** `/retrospective sprint-009`

**Expected behavior:**
1. 技能找不到 sprint-009 的冲刺计划
2. 技能输出“No sprint data found for sprint-009 …”
3. 技能通过 `AskUserQuestion` 询问：[A] 手动提供数据、[B] 停止
4. 用户选择 [A]，并描述冲刺的任务、日期和结果
5. 技能把该输入作为事实来源，并将其格式化进回顾结构
6. 技能询问“May I write”，并在批准后写入文档

**Assertions:**
- [ ] 冲刺文件缺失时技能不崩溃，也不产出空文档，并说明未找到 sprint-009 的冲刺数据
- [ ] `AskUserQuestion` 提供 [A] 手动提供数据和 [B] 停止——不提供 [C] 查看已关闭用户故事，该选项仅在 `workflow: minimal` 下提供
- [ ] 手动输入被格式化进回顾结构（What Went Well / What Went Poorly / Action Items for Next Iteration）
- [ ] 文件写入之前仍出现“May I write”提示

---

### Case 3: 存在先前回顾 —— 更新现有或重新开始

**Fixture:**
- `production/retrospectives/retro-sprint-005-[earlier date].md` 已存在且有内容
- `production/sprints/sprint-005.md` 存在
- 用户重新运行 `/retrospective sprint-005`，并在被询问时选择 [B] Start fresh

**Input:** `/retrospective sprint-005`

**Expected behavior:**
1. 在加载任何冲刺数据之前，技能对 `production/retrospectives/retro-sprint-005-*.md` 做 glob，并找到已存在的文件
2. 技能通过 `AskUserQuestion` 询问：“An existing retrospective was found: [filename]. How do you want to proceed?”，选项为 [A] Update existing 和 [B] Start fresh (archive the old one)
3. 用户选择 [B]；技能从空白开始编译——旧文件此时尚未被触碰
4. 技能询问“May I write this to `production/retrospectives/retro-sprint-005-[today's date].md`?”，且同一询问会指名把旧文件重命名为其 `-archived-[date]` 名称
5. 用户批准；技能先重命名旧文件，再写入新文件；结论 COMPLETE

**Assertions:**
- [ ] 技能在加载冲刺数据之前检查是否存在已有回顾
- [ ] 向用户提供 Update existing 或 Start fresh——旧文件绝不会被悄悄覆盖
- [ ] 在“May I write”提示获批准之前不重命名旧文件，且该提示同时指名新的带日期路径 `retro-sprint-005-[today's date].md` 和重命名操作
- [ ] 批准后，旧文件以 `-archived-[date]` 名称保留，不被删除或覆盖
- [ ] 写入后结论为 COMPLETE

---

### Case 4: 边界情况 —— 先前回顾中有未解决的行动项

**Fixture:**
- `production/retrospectives/retro-sprint-004-[date].md` 存在，含 2 个标记为 `[ ]`（未完成）的行动项
- `production/sprints/sprint-005.md` 存在；不存在 sprint-005 的回顾
- 用户运行 `/retrospective sprint-005`

**Input:** `/retrospective sprint-005`

**Expected behavior:**
1. 技能读取 `production/retrospectives/` 中的先前回顾
2. 技能检查 sprint-004 的行动项是否得到处理——有 2 个未处理
3. 新回顾的“Previous Action Items Follow-Up”表列出这两个事项，状态非 Done
4. 跟进表与“Action Items for Next Iteration”分开

**Assertions:**
- [ ] 技能读取 `production/retrospectives/` 中的先前回顾以检查其行动项
- [ ] 两个未解决的事项都出现在“Previous Action Items Follow-Up”表中
- [ ] 它们的 Status 为 Not Started 或 In Progress——而非 Done
- [ ] 跟进表与新生成的“Action Items for Next Iteration”彼此独立

---

### Case 5: 闸门合规 —— 任何模式下都不调用闸门

**Fixture:**
- `production/sprints/sprint-005.md` 存在，含已完成的用户故事
- `project.yaml` 设置 `modes.review_mode: full`

**Input:** `/retrospective sprint-005`

**Expected behavior:**
1. 技能编译回顾
2. 不调用总监闸门（回顾是团队自我反思，而非交付闸门）
3. 技能向用户请求批准，并在确认后写入文件
4. 结论为 COMPLETE

**Assertions:**
- [ ] 无论评审模式如何，都不调用总监闸门
- [ ] 输出不含任何闸门调用或闸门结果标记
- [ ] 技能从编译直接进入“May I write”提示
- [ ] `review_mode` 不在技能解析的键之列（它解析 `automation`、`workflow`、`qa.level`）

---

### Case 6: 最小工作流 —— 查看已关闭的用户故事

**Fixture:**
- `project.yaml` 既未设置 `modes.rigor` 也未设置 `modes.workflow`，因此注入块读作 `workflow: minimal (rigor:minimal)`
- `production/sprints/`、`production/milestones/` 和 `production/retrospectives/` 不存在
- `production/epics/core/` 下有 3 个用户故事为 `Status: Complete`；1 个为 `Status: In Progress`

**Input:** `/retrospective sprint-001`

**Expected behavior:**
1. 技能找不到 sprint-001 的回顾，也找不到冲刺数据
2. 在 `workflow: minimal` 下，技能通过 `AskUserQuestion` 提供三个选项：[A] 手动提供数据、[B] 停止、[C] 查看已关闭的用户故事
3. 用户选择 [C]；技能读取 3 个 `Complete` 用户故事并继续到 Phase 3
4. 回顾覆盖这 3 个用户故事；需要冲刺数据的小节（计划 vs 实际、速度、结转、估算准确度）读作 `NOT ASSESSED — NO DATA`
5. 技能询问“May I write this to `production/retrospectives/retro-sprint-001-[today's date].md`?”；用户批准；结论 COMPLETE
6. Phase 6 跳过开始冲刺规划的问题：技能指向回顾文件，并说明其行动项进入简报的构建顺序

**Assertions:**
- [ ] 无数据提示在 [A] 和 [B] 之外还提供 [C] 查看已关闭的用户故事
- [ ] 选择 [C] 后从 `Complete` 用户故事继续到 Phase 3——运行不会以 BLOCKED 停止
- [ ] `In Progress` 用户故事不被报告为已完成的工作
- [ ] 需要冲刺数据的小节读作 `NOT ASSESSED — NO DATA`，而非臆造数字
- [ ] “May I write”在写入之前出现，写入后结论为 COMPLETE
- [ ] 写入后不提供开始 `/sprint-plan new` 的选项——技能指名回顾文件，并说明行动项进入简报的构建顺序

---

## Protocol Compliance

- [ ] 在加载冲刺数据之前检查是否存在已有回顾
- [ ] 输入缺失的小节读作 `NOT ASSESSED — NO DATA`——绝不用估算值或空表替代
- [ ] 在询问是否写入之前始终展示回顾及其主要发现
- [ ] 写入回顾文件之前始终询问“May I write”
- [ ] 不调用任何总监闸门
- [ ] 写入后结论为 COMPLETE；用户在无数据提示处停止或拒绝写入时为 BLOCKED
- [ ] 检查先前回顾中是否有未解决的行动项
- [ ] 仅当工作流包含冲刺时才在结尾提供 `/sprint-plan new`；在 `minimal` 下则改为把行动项指向简报的构建顺序

---

## Coverage Notes

- 里程碑回顾（`retro-[milestone-name]-[date].md`，随后接 `/gate-check`）不在此单独测试。
- 无数据提示处的 [B] 停止选择以及拒绝写入（两者结论均为 BLOCKED）未测试。
