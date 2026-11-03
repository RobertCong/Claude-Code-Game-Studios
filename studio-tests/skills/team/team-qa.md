# Skill Test Spec: /team-qa

## Skill Summary

通过 6 阶段的结构化测试周期编排 QA 团队。协调
qa-lead（策略、冒烟检查评估、签核报告）与 qa-tester（测试用例
编写、缺陷报告编写）。Phase 1 加载范围（冲刺文件、`feature:` 形式，或
从会话状态推断）与项目阶段；Phase 2 对用户故事分类，并
从最新的 `production/qa/smoke-*.md` 报告中取得冒烟检查结论
（不存在任何报告时为 UNKNOWN；报告如此声明时为 NOT ASSESSED —— 两者都带警告继续
并排除 APPROVED；FAIL 则中止周期）；在 `qa.level:
minimal`（测试被豁免）下，一个 Logic、Integration 或 Config/Data 类型的用户故事
若无测试则为 WAIVED，其证据是手工 QA 中的验收标准
逐条走查；Phase 3 在询问之后编写 QA 计划；Phase 4 为每个手工 QA 用户故事
以指定输出路径启动 qa-tester ——
在 `team.size: studio` 下每个用户故事一个并行进程，低于该规模则一个进程
覆盖整组；Phase 5 走查手工 QA、提交缺陷、让测试者保留截图，
并在询问之后编写证据产出物；Phase 6 产出一份签核报告，
范围内每个用户故事各占一行，并给出 NOT ASSESSED / APPROVED / APPROVED WITH
CONDITIONS / NOT APPROVED 结论。Phase 0 解析 `team.size`，技能在 Phase 1 之前
宣布活动集。编排器层面的结论为 COMPLETE 或 BLOCKED。

---

## Static Assertions (Structural)

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少包含 2 个 Phase 标题（Phase 1 至 Phase 6）
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含签核结论关键词：NOT ASSESSED、APPROVED、APPROVED WITH CONDITIONS、NOT APPROVED
- [ ] 对编排器的每一次写入都包含 "May I write" 表述：QA 计划（Phase 3）、证据产出物（Phase 5）与签核报告（Phase 6）
- [ ] 具备 Error Recovery Protocol 章节
- [ ] 在阶段转换处使用 `AskUserQuestion`，以在继续之前获取用户批准
- [ ] Phase 2 从最近的 `production/qa/smoke-*.md` 报告取得冒烟结论，且 FAIL 会在 Phase 3 之前中止周期
- [ ] Phase 4 为每个 qa-tester 指定输出路径：`production/qa/test-cases/[story-slug]-cases.md`
- [ ] 缺陷报告写入 `production/qa/bugs/`，命名 `BUG-[NNNN].md` —— 沿用 `/bug-report` 的编号，以便 `/bug-report verify` 能找到它们
- [ ] 通过的 Visual/Feel 与 UI 用户故事，会对每个涉及的界面或效果保留截图，存放于 `production/qa/evidence/[story-slug]/` 并经磁盘确认，同时在 `production/qa/evidence/[story-slug]-evidence.md` 产出一份引用它的证据产出物 —— 截图即可关闭一个 UI 用户故事；Visual/Feel 用户故事还需主管签核
- [ ] 后续步骤指导随结论而不同（NOT ASSESSED / APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED）
- [ ] Phase 0 解析 `team.size`，且技能要求在 Phase 1 之前有一行活动集公告
- [ ] Phase 0 解析 `qa.level`；在 `minimal` 下，一个 Logic、Integration 或 Config/Data 用户故事若无测试，则在 Phase 4–5 中走查其验收标准 —— 测试为 WAIVED，绝不计为缺失证据
- [ ] Phase 2 的冒烟结论列表包含 NOT ASSESSED，其处理与 UNKNOWN 一样带警告继续，并使签核为 NOT ASSESSED
- [ ] Phase 1 从 `production/qa/bugs/` 读取范围内的未关闭缺陷（除 `Closed` 或 `Verified Fixed` 外均为未关闭），并将其传入 Phase 2 与 Phase 6 的简报
- [ ] Phase 6 的简报携带证据与结论规则，且不指明任何结论；编排器在写入之前依据规则核对 qa-lead 的结论
- [ ] Phase 4 在 `team.size: studio` 下为每个用户故事并行启动一个 qa-tester；在 `small` 与 `individual` 下，一个 qa-tester 进程覆盖整组
- [ ] Phase 6 的签核为范围内的每个用户故事都给出 Test Coverage Summary 行 —— 包括 BLOCKED 与未执行的用户故事 —— 且其模板展示一行 BLOCKED

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与
`modes.automation: collaborative`，且不含 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 顺利路径 —— 所有用户故事通过手工 QA，结论 APPROVED

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `production/sprints/sprint-03.md` 列出 4 个用户故事，其故事文件均存在
- 用户故事类型混杂：1 个 Logic（其单元测试存在且通过）、1 个 Integration（无自动化测试）、2 个 Visual/Feel
- 所有用户故事都已填写验收标准
- 最近的 `production/qa/smoke-[date].md` 报告结论为 PASS
- `production/qa/bugs/` 中没有任何缺陷

**Input:** `/team-qa sprint-03`

**Expected behavior:**
1. 在任何启动之前，用一行宣布 `team.size: small` 的活动集
2. Phase 1：Glob 匹配 `production/sprints/sprint-*.md`，匹配到编号 3（`sprint-03.md`）并读取它；从 `project.yaml`（回退为 `production/stage.txt`）读取 `project.stage`；读取范围内的未关闭缺陷（文件中没有）；报告 "QA cycle starting for sprint-03. Found 4 stories. Open bugs in scope: none on file. Current stage: [stage]. Ready to begin QA strategy?"
3. Phase 2：通过 Agent 启动 `qa-lead`；在策略表中对全部 4 个用户故事分类；读取冒烟报告并记录 `Smoke Check: PASS — source: production/qa/smoke-[date].md`，不重新访谈用户；呈现策略；`AskUserQuestion` "QA Strategy Review"：用户选择 "Looks good — proceed to test plan"
4. Phase 3：产出 QA 计划（范围、分类表、自动化/手工范围、进入与退出标准）；询问 "May I write the QA plan to `production/qa/qa-plan-sprint-03-[date].md`?"；批准后写入
5. Phase 4：通过 Agent 为 Integration 与两个 Visual/Feel 用户故事启动一个 `qa-tester`（按用户故事并行启动属于 `studio` 形态），其提示词为每个用户故事指定 `production/qa/test-cases/[story-slug]-cases.md`；测试用例按用户故事分组呈现；每组 `AskUserQuestion`；用户批准
6. Phase 5：每个用户故事一次 `AskUserQuestion`（PASS / PASS WITH NOTES / FAIL / BLOCKED）；用户全部标记为 PASS；对每个 Visual/Feel 用户故事，测试者将截图保存到 `production/qa/evidence/[story-slug]/`，编排器确认其已在磁盘上；在询问 "May I write the evidence for [story titles] to `production/qa/evidence/`?" 之后，写入 `production/qa/evidence/[story-slug]-evidence.md`，引用这些截图，签核行保持未勾选，除非在本次会话中已签核；结果摘要："Stories PASS: 4, PASS WITH NOTES: 0, FAIL: 0, BLOCKED: 0"
7. Phase 6：通过 Agent 启动 `qa-lead` 产出签核报告；每个用户故事都有已执行的证据；未提交缺陷；结论：APPROVED；询问 "May I write this QA sign-off report to `production/qa/qa-signoff-sprint-03-[date].md`?"；批准后写入
8. 结论：COMPLETE —— QA 周期完成

**Assertions:**
- [ ] 指明 `team.size: small` 的活动集行出现在第一个代理启动之前
- [ ] Phase 1 正确计数并报告 4 个用户故事及当前阶段
- [ ] Phase 2 的策略表以正确类型对全部 4 个用户故事分类
- [ ] 冒烟检查结论取自现有的 `production/qa/smoke-*.md` 报告，并展示其来源
- [ ] QA 计划仅在 "May I write?" 批准之后写入
- [ ] Phase 4 在 `team.size: small` 下只启动一个 qa-tester，其提示词为每个用户故事指明 `production/qa/test-cases/` 路径
- [ ] 每个通过的 Visual/Feel 用户故事在 `production/qa/evidence/[story-slug]/` 下都有保留截图，其证据产出物引用该截图，且仅在 "May I write" 询问之后写入
- [ ] 签核报告包含 Test Coverage Summary 表与结论：APPROVED
- [ ] 签核报告仅在 "May I write?" 批准之后写入
- [ ] 最终输出中出现结论：COMPLETE
- [ ] 下一步："Run `/gate-check` to validate advancement."

---

### Case 2: 冒烟检查失败 —— QA 周期在 Phase 2 中止

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `production/sprints/sprint-04.md` 列出 3 个用户故事
- 最近的 `production/qa/smoke-[date].md` 报告结论为 FAIL，列出 2 项失败（构建启动后不稳定、核心导航损坏）

**Input:** `/team-qa sprint-04`

**Expected behavior:**
1. Phase 1 正常完成
2. Phase 2：通过 Agent 启动 `qa-lead`；qa-lead 读取冒烟报告并记录 `Smoke Check: FAIL`，突出列出两项失败
3. 呈现 `AskUserQuestion` "QA Strategy Review"，其中包含选项 "Smoke check failed — fix issues and re-run /team-qa"
4. 技能不进入 Phase 3：它展示冒烟报告中的失败并停止 —— 用户必须修复它们，重新运行 `/smoke-check sprint`，然后再重新运行 `/team-qa`
5. 不产出 QA 计划、测试用例、手工 QA 或签核报告；给出部分报告
6. 结论：BLOCKED —— 冒烟检查失败

**Assertions:**
- [ ] 冒烟检查结论来自 `production/qa/smoke-*.md` 报告 —— qa-lead 不重新推导，也不重新访谈用户
- [ ] 冒烟检查 FAIL 在 Phase 2 中止流水线 —— Phase 3、4、5、6 不被执行
- [ ] 失败清单明确展示给用户（不是含糊概括）
- [ ] 技能将 `/smoke-check sprint` 与重新运行 `/team-qa` 作为补救步骤推荐
- [ ] 不写入也不提议任何 QA 计划或 QA 签核报告
- [ ] 编排器结论为 BLOCKED，而非 COMPLETE

---

### Case 3: 发现缺陷 —— Visual/Feel 用户故事手工 QA 失败，提交缺陷报告

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `production/sprints/sprint-05.md` 列出 2 个用户故事：1 个 Logic（其自动化测试通过）、1 个 Visual/Feel
- 最近的 `production/qa/smoke-[date].md` 报告结论为 PASS
- 该 Visual/Feel 用户故事的动画时序明显错误（验收标准未满足）
- `production/qa/bugs/` 已包含 `BUG-0001.md` 与 `BUG-0002.md`

**Input:** `/team-qa sprint-05`

**Expected behavior:**
1. Phase 1–4 正常完成；为该 Visual/Feel 用户故事编写测试用例
2. Phase 5：用户将该 Visual/Feel 用户故事标记为 FAIL；`AskUserQuestion` 收集失败描述："Animation plays at 2x speed — jitter visible on every loop"
3. Phase 5：通过 Agent 启动 `qa-tester`，在 `production/qa/bugs/BUG-0003.md` 编写正式缺陷报告；报告包含严重程度字段
4. 结果摘要："Stories PASS: 1, PASS WITH NOTES: 0, FAIL: 1 — bugs filed: BUG-0003, BLOCKED: 0"
5. Phase 6：启动 `qa-lead` 产出签核报告；每个用户故事都有已执行的证据；Bugs Found 表列出 BUG-0003 及其用户故事、严重程度与状态 Open；结论：NOT APPROVED（某个用户故事 FAIL 且没有记录在案的变通方案）
6. 提议写入签核报告；批准后写入
7. 下一步："Resolve S1/S2 bugs and re-run `/team-qa` or targeted manual QA before advancing."

**Assertions:**
- [ ] Phase 5 中的 FAIL 结果会在编写缺陷报告之前触发 `AskUserQuestion` 收集失败描述
- [ ] `qa-tester` 通过 Agent 启动来编写缺陷报告 —— 编排器不直接编写
- [ ] 缺陷报告遵循 `/bug-report` 的命名：`production/qa/bugs/` 中的 `BUG-[NNNN].md`
- [ ] 该 ID 为现有最高编号加一，零填充至四位（BUG-0003）
- [ ] Phase 6 签核报告的 Bugs Found 表包含缺陷 ID、用户故事名称、严重程度与状态
- [ ] 签核报告中的结论为 NOT APPROVED
- [ ] 下一步明确提到重新运行 `/team-qa`
- [ ] 编排器仍给出结论：COMPLETE（QA 周期已完成 —— 签核结论是 NOT APPROVED，但技能完成了其流水线）

---

### Case 4: 无参数 —— 技能推断活动冲刺或询问用户

**Fixture（变体 A —— 存在状态文件）:**
- `production/session-state/active.md` 存在，并包含对 `sprint-06` 的引用
- `production/sprint-status.yaml` 存在，并标识 `sprint-06` 为活动冲刺
- `production/sprints/sprint-06.md` 存在

**Fixture（变体 B —— 无冲刺，如 `rigor: minimal` 时）:**
- `production/session-state/active.md` 不存在
- `production/sprint-status.yaml` 不存在
- 不存在任何冲刺文件；`production/epics/` 下存在史诗

**Input:** `/team-qa`（无参数）

**Expected behavior（变体 A）:**
1. Phase 1：未提供参数；读取 `production/session-state/active.md` 与 `production/sprint-status.yaml`
2. 检测到 `sprint-06` 为活动冲刺
3. 按输入为 `/team-qa sprint-06` 的方式继续；Phase 1 的报告行点名它："QA cycle starting for sprint-06. Found [N] stories. Open bugs in scope: [N or none on file]. Current stage: [stage]. Ready to begin QA strategy?"

**Expected behavior（变体 B）:**
1. Phase 1：未提供参数；尝试读取两个状态文件 —— 都缺失；不存在任何冲刺
2. 询问用户要覆盖哪个史诗，然后将本次运行范围设为 `feature: [epic-slug]` —— 不虚构冲刺

**Assertions:**
- [ ] 未提供参数时，技能不会默认使用硬编码的冲刺名
- [ ] 在询问用户之前，技能同时读取 `production/session-state/active.md` 与 `production/sprint-status.yaml`（变体 A）
- [ ] 无法推断冲刺时，技能询问要覆盖哪个史诗并使用 `feature: [epic-slug]` 形式，而非猜测（变体 B）
- [ ] 被推断的冲刺在 Phase 2 开始之前的 Phase 1 报告行中被点名（变体 A）
- [ ] 状态文件缺失时技能不会报错 —— 它回退到询问（变体 B）

---

### Case 5: 混合结果 —— 部分 PASS，一个带 S1 缺陷的 FAIL，一个 BLOCKED

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `production/sprints/sprint-07.md` 列出 4 个用户故事
- 最近的 `production/qa/smoke-[date].md` 报告结论为 PASS
- 用户故事 A（Logic）：自动化测试通过 —— PASS
- 用户故事 B（UI）：手工 QA —— PASS WITH NOTES（轻微文字溢出）
- 用户故事 C（Visual/Feel）：手工 QA —— FAIL；测试者发现技能激活时的 S1 崩溃
- 用户故事 D（Integration）：无法测试 —— BLOCKED（依赖系统尚未实现）
- `production/qa/bugs/` 为空

**Input:** `/team-qa sprint-07`

**Expected behavior:**
1. Phase 1–4 继续；Phase 4 的测试用例覆盖用户故事 B、C、D
2. Phase 5：用户故事 A 依据其自动化测试为 PASS；用户将用户故事 B 标记为 PASS WITH NOTES；用户故事 C：FAIL；用户故事 D：BLOCKED
3. 用户故事 B（UI）对每个涉及的界面保留截图，由测试者保存到 `production/qa/evidence/[story-slug]/` 并经磁盘确认；其证据产出物 `production/qa/evidence/[story-slug]-evidence.md` 引用它们，且仅在 "May I write" 询问之后写入
4. 用户故事 C FAIL 后：收集失败描述；启动 qa-tester 编写缺陷报告 `BUG-0001.md`，严重程度 S1
5. 呈现结果摘要："Stories PASS: 1, PASS WITH NOTES: 1, FAIL: 1 — bugs filed: BUG-0001, BLOCKED: 1"
6. Phase 6：qa-lead 产出覆盖全部 4 个用户故事的签核报告；BUG-0001 列为 S1/Open；用户故事 D 列为 BLOCKED，无已执行证据；结论：NOT APPROVED —— 未关闭的 S1 是已知失败并如实报告，不会因用户故事 D 未执行而被降级为 NOT ASSESSED
7. 签核报告在 "May I write?" 批准之后写入
8. 下一步："Resolve S1/S2 bugs and re-run `/team-qa` or targeted manual QA before advancing."

**Assertions:**
- [ ] 全部 4 个用户故事都出现在 Phase 6 签核报告的 Test Coverage Summary 表中 —— 无一被静默省略
- [ ] 用户故事 D（BLOCKED）在报告中以 BLOCKED 状态列出，并说明其缺少已执行证据，而非被静默丢弃
- [ ] S1 缺陷导致结论为 NOT APPROVED，无论其他用户故事是否通过，也无论用户故事 D 是否未执行
- [ ] PASS WITH NOTES 的用户故事不会降级为 FAIL —— 它们单独跟踪
- [ ] 用户故事 B 的证据是其保留截图 —— UI 用户故事无需主管签核即可关闭
- [ ] Bugs Found 表中 BUG-0001 的严重程度列为 S1
- [ ] 部分结果得到保留 —— 即便存在失败与阻塞，仍会产出签核报告
- [ ] 编排器给出结论：COMPLETE（流水线已完成）；签核结论为 NOT APPROVED

---

### Case 6: `qa.level: minimal` —— 无测试的 Logic 用户故事以其验收标准走查作为证据

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`qa.level: minimal (rigor:minimal)`
- 没有冲刺文件，也没有 `production/sprint-status.yaml`；`production/epics/combat/` 下有 2 个用户故事文件，均为 `In Review`：story-001（Logic，任何位置都没有测试文件）与 story-002（UI）
- 最近的 `production/qa/smoke-[date].md` 报告结论为 PASS（其自动化行 WAIVED）
- `production/qa/bugs/` 中没有任何缺陷

**Input:** `/team-qa feature: combat`

**Expected behavior:**
1. Phase 2：qa-lead 的策略表将 story-001 的 Automated Required 标为 `WAIVED` —— 在 `qa.level: minimal` 下测试被豁免 —— 并将其纳入手工 QA；它不会被标记为缺少测试证据，也不会被标记为阻塞项
2. Phase 3：QA 计划不列出任何自动化测试要求；其进入标准从用户故事文件（功能范围）读取用户故事状态，而非从 `production/sprint-status.yaml` 读取
3. Phase 4：为两个用户故事编写测试用例 —— story-001 的用例走查其验收标准
4. Phase 5：测试者对两者都回答 PASS；保存 story-002 的保留截图并经磁盘确认
5. Phase 6：Test Coverage Summary 在 Auto Test 一栏将 story-001 显示为 `WAIVED (qa.level: minimal)`，并记录其标准已走查；每个用户故事都有已执行证据，故结论为 APPROVED

**Assertions:**
- [ ] story-001 从不会被报告为缺少测试，其验收标准走查即为已执行证据
- [ ] 签核结论为 APPROVED，而非 NOT ASSESSED
- [ ] UI 用户故事仍需要其保留截图 —— `qa.level: minimal` 豁免的是测试，不是外观
- [ ] `feature:` 范围内的进入标准读取用户故事文件的 Status，而非 `production/sprint-status.yaml`
- [ ] 没有任何后续步骤要求用户编写 Logic 测试

---

### Case 7: 冒烟报告为 NOT ASSESSED —— 带警告继续，签核为 NOT ASSESSED

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`qa.level: standard`
- `production/sprints/sprint-008.md` 列出 2 个用户故事：1 个 Logic（其单元测试存在且通过）与 1 个 Visual/Feel
- 最近的 `production/qa/smoke-[date].md` 报告结论为 NOT ASSESSED —— Batch 3 被提议但跳过
- `production/qa/bugs/` 中没有任何缺陷

**Input:** `/team-qa sprint-8`

**Expected behavior:**
1. Phase 1 按编号匹配到 `sprint-008.md`
2. Phase 2：记录 `Smoke Check: NOT ASSESSED — Batch 3 skipped — source: production/qa/smoke-[date].md`，并警告上一次冒烟检查无法评估它，建议重新运行 `/smoke-check sprint`；周期继续
3. Phase 3–5 运行；两个用户故事均 PASS，Visual/Feel 用户故事的证据被保留
4. Phase 6：每个用户故事都有已执行证据，但冒烟检查为 NOT ASSESSED，因此签核结论为 **NOT ASSESSED** —— 绝不是 APPROVED

**Assertions:**
- [ ] NOT ASSESSED 冒烟结论取自报告并展示其来源 —— 不被误读为 PASS 或 UNKNOWN
- [ ] 在 NOT ASSESSED 下周期不会在 Phase 2 中止（只有 FAIL 才会中止）
- [ ] 即便每个用户故事都通过，签核结论仍为 NOT ASSESSED
- [ ] 后续步骤要求在 `/team-qa` 之前重新运行 `/smoke-check`

---

### Case 8: 文件中已有未关闭的 S1 —— 签核前已知，且简报不指明结论

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`qa.level: standard`
- `production/sprints/sprint-009.md` 列出 Combat 系统中的 2 个用户故事：1 个 Logic（其单元测试通过）与 1 个 UI
- `production/qa/bugs/BUG-0004.md`：System Combat、`**Severity**: S1-Critical`、`**Status**: Open` —— 在本次周期之前提交；`BUG-0002.md`（Combat，S2）的 `**Status**: Closed`
- 最近的 `production/qa/smoke-[date].md` 报告结论为 PASS

**Input:** `/team-qa sprint-9`

**Expected behavior:**
1. Phase 1 检索缺陷文件并报告 "Open bugs in scope: 1 — S1: 1"；已关闭的 BUG-0002 不计入
2. Phase 2 给 qa-lead 的简报携带 BUG-0004，策略将其列在 **Open bugs in scope** 下作为已知失败
3. Phase 3–5 运行；两个用户故事均 PASS，UI 用户故事的截图被保留
4. Phase 6 的简报传入策略、冒烟结论、两个用户故事的结果、BUG-0004 与结论规则 —— 它不指明任何结论，不预填 `### Verdict:` 行，也不说明由哪个事实决定结论
5. qa-lead 返回 NOT APPROVED（范围内存在未关闭的 S1 缺陷）；Bugs Found 表列出 BUG-0004；编排器依据规则核对该结论，然后请求写入

**Assertions:**
- [ ] BUG-0004 在 Phase 1 即已知，并出现在 Phase 2 策略中 —— 不是到签核时才首次发现，也绝不会被漏掉
- [ ] 即便每个用户故事都通过，签核结论仍为 NOT APPROVED —— 绝不是 NOT ASSESSED 或 APPROVED
- [ ] Phase 6 的简报不指明结论，也不指明决定性事实；qa-lead 依据规则得出 NOT APPROVED
- [ ] 已关闭的缺陷不计为未关闭

---

### Case 9: `review_mode` 不门控任何内容 —— full、lean 与 solo 下的同一周期

**Fixture:**
- `project.yaml`：`team.size: small`（已固定：qa-lead 与 qa-tester 均活动），
  `qa.level: standard`（已固定：Logic 用户故事的自动化测试即其证据）；
  未设置 `modes.review_mode`，因此每次运行的 `--review` 值决定
- `production/sprints/sprint-04.md` 列出 2 个用户故事：1 个 Logic（其单元测试通过）
  与 1 个 UI（截图保留）；验收标准已填写
- 最近的 `production/qa/smoke-[date].md` 结论为 PASS；文件中无缺陷
- 运行 A：`/team-qa sprint-04 --review full`。运行 B：`--review lean`。运行 C：`--review solo`。
  每次运行中测试者都将两个用户故事标记为 PASS

**Expected behavior:**
1. 每次运行都以相同的活动集行开始
2. 每次运行都为策略（Phase 2）与签核（Phase 6）启动 `qa-lead`，
   为测试用例（Phase 4）启动 `qa-tester` —— 团队成员，而非总监闸门
3. 任何运行在任何阶段都不启动 CD-、TD-、PR- 或 AD-PHASE-GATE："no phase below
   spawns CD-, TD-, PR- or AD-PHASE-GATE, at any `review_mode`"
4. 策略询问、QA 计划询问、证据询问与签核询问，以及
   APPROVED 结论，在三次运行中完全相同

**Assertions:**
- [ ] 运行 A（`full`）、运行 B（`lean`）与运行 C（`solo`）中都不启动任何总监闸门
- [ ] 三次运行中启动的代理、执行的阶段与发起的询问完全一致
- [ ] 签核结论仅由证据与结论规则决定 —— 三次运行均为相同的 APPROVED；`--review full` 不增加评审者，`--review solo` 也不减少
- [ ] 给 qa-lead 的 Phase 6 简报在三次运行中相同，且不指明结论

---

## Protocol Compliance

- [ ] 手工 QA 结果仅按测试者所给的内容记录 —— 绝不代为填写；未作答的用户故事保持未执行
- [ ] 在 Phase 6 中 qa-lead 返回签核文本而不写文件；编排器在询问之后写入
- [ ] Phase 5 中提交的缺陷严格使用 `/bug-report` 的 Severity 与 Priority 标签
- [ ] 在默认的 `team.size: individual` 下，运行以活动集行开始，点名 qa-tester 为常驻活动代理，并说明 qa-lead 仅在阶段闸门处启动（即流水线所列的决策点，无论 `automation` 模式如何） —— 这一切发生在任何代理启动之前
- [ ] 在 Phase 2（策略评审）、Phase 4（按组批准测试用例）与 Phase 5（逐用户故事的手工 QA 结果与失败描述）使用 `AskUserQuestion`
- [ ] Phase 2 的冒烟检查是硬性闸门：FAIL 在 Phase 3 之前中止流水线
- [ ] 当不存在 `production/qa/smoke-*.md` 报告时，冒烟状态为 UNKNOWN，展示警告 "No smoke check report found. Recommend running `/smoke-check sprint` before QA. Proceeding with caution."，并继续周期
- [ ] 结论为 NOT ASSESSED 的冒烟报告会连同未运行的内容一同呈现，周期按 UNKNOWN 的方式继续
- [ ] 在没有冒烟报告（UNKNOWN）或其结论为 NOT ASSESSED 时，即便每个用户故事都通过，签核结论仍为 NOT ASSESSED —— 绝不是 APPROVED 或 APPROVED WITH CONDITIONS —— 除非未关闭的 S1/S2 缺陷，或无记录在案变通方案的 FAIL，使其变为 NOT APPROVED
- [ ] 编排器的每一次写入之前都询问 "May I write?"：QA 计划（Phase 3）、各组证据产出物（Phase 5）与签核报告（Phase 6）
- [ ] 缺陷报告始终由 `qa-tester` 通过 Agent 编写 —— 编排器不直接编写
- [ ] 每个 Phase 4 qa-tester 提示词都指明每个用户故事的输出路径；按用户故事并行启动仅在 `team.size: studio` 下发生
- [ ] 证据产出物绝不会为本次会话中未发生的签核预勾选签核行
- [ ] 错误恢复：任何 BLOCKED 代理都会立即通过 AskUserQuestion 选项呈现
- [ ] 始终产出部分报告 —— 不会因某个用户故事失败或阻塞而丢弃已有工作
- [ ] 文件中已有的未关闭缺陷在 Phase 1 读取，并进入两个 qa-lead 简报；任何给 qa-lead 的简报都不指明签核结论
- [ ] 签核结论规则被严格执行：任何未关闭的 S1/S2 缺陷 = NOT APPROVED；APPROVED 与 APPROVED WITH CONDITIONS 要求范围内每个用户故事都有已执行证据
- [ ] 编排器层面的结论：COMPLETE 与签核报告的结论相互区分

---

## Coverage Notes

- "APPROVED WITH CONDITIONS" 结论路径（S3/S4 缺陷、每个用户故事均已执行的 PASS WITH NOTES）没有专门用例；如果没有未关闭的 S1/S2 缺陷且用户故事 D 已执行，Case 5 的用户故事 B 会产生该结论。
- 无已知失败的 NOT ASSESSED 结论已针对 NOT ASSESSED 冒烟报告覆盖（Case 7）；一个用户故事 BLOCKED 其余 PASS，或完全没有冒烟报告，没有专门用例 —— 冒烟 UNKNOWN 规则在 Protocol Compliance 中作了断言。
- `studio` 形态（每个用户故事一个 qa-tester，并行）在结构上作了断言，但没有用例；Case 1、3、5 在 `small` 下运行。
- `feature: [system-name]` 参数形式由 Case 6 检验 —— 它沿用与冲刺形式相同的 Phase 1 逻辑，使用 glob 而非冲刺文件。Case 4 变体 B 检验史诗回退。
- 自动化测试通过的 Logic 用户故事无需手工 QA —— 这由 Case 5（用户故事 A）隐式验证，其中 Logic 用户故事没有手工 QA 阶段。
- 最终阶段之后向 `production/session-state/active.md` 追加会话状态这一行为未作断言。
