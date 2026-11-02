# Skill Test Spec: /regression-suite

## Skill Summary

`/regression-suite [update | audit | report]` 维护 `tests/regression-suite.md`，这是一份精选清单，登记用于守护关键路径和已修复缺陷的现有测试。`audit` 将每条 GDD 验收标准（按工作流层级限定范围）映射到 `tests/unit/[system]/` 和 `tests/integration/[system]/` 中的测试，标记为 COVERED / PARTIAL / MISSING / EXEMPT，并将缺失的公式或状态机标准提升为 HIGH PRIORITY。`update` 检查 `production/qa/bugs/` 中 `Status: Closed` 或 `Status: Fixed` 的缺陷是否有回归测试（HAS / MISSING REGRESSION TEST），并在不移除任何条目的情况下追加新的清单条目。`report` 为只读。所有模式都会检查覆盖率漂移。

在 `qa.level: minimal` 下，技能会在任何扫描之前停止，并输出 "Regression suite not generated at qa.level minimal"。当关键路径为零或测试文件为零时，它报告 `Coverage: NOT ASSESSED — [no GDDs found | no test files found]`，而不是给出百分比。写入前它会询问 "May I write/update `tests/regression-suite.md` with the current regression suite manifest?"。结论按首个匹配项：在 `qa.level: minimal` 停止处或覆盖率未计算时为 **NOT ASSESSED**（即使已写入，也绝不基于缺失的数字给出 COMPLETE），用户拒绝写入时为 **BLOCKED**，写入后为 **COMPLETE**——或者在只读 `report` 模式下，报告展示完毕即为 COMPLETE。`qa.level` 还决定时机——在 `standard` 下套件应在进入 Polish 阶段时完成，在 `full` 下应在进入 Production 阶段时完成——因此每个 fixture 都固定了 `project.stage`。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED、NOT ASSESSED
- [ ] 在写入 `tests/regression-suite.md` 前包含 "May I write" 用语
- [ ] 具备下一步交接（HIGH 缺口用 `/test-helpers`，发生漂移时用 `/regression-suite audit`，被隔离的测试用 `/test-flakiness`）

---

## Director Gate Checks

无。`/regression-suite` 是一个 QA 工具。它不生成任何代理（`Agent` 不在其允许工具中），且不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 审计 — 标准已映射，公式缺口提升为 HIGH

**Fixture:**
- `qa.level: standard`；工作流层级 `full`；`project.stage: Polish`
- `design/gdd/systems-index.md` 列出 `combat`；`design/gdd/combat.md` 有 4
  条验收标准：一条伤害公式、一次受击硬直状态转换、一条击退规则
  以及 HUD 伤害数字显示
- `tests/unit/combat/` 有针对受击硬直（所有用例）和击退（仅正常路径）
  的测试；没有任何测试覆盖伤害公式
- `tests/regression-suite.md` 存在

**Input:** `/regression-suite audit`

**Expected behavior:**
1. 技能读取现有清单，glob 测试清单，并读取 combat GDD 的关键路径
2. 覆盖率：受击硬直 COVERED，击退 PARTIAL，伤害公式 MISSING，HUD
   显示 EXEMPT（UI，无法自动化）
3. 缺失的伤害公式被提升为 HIGH PRIORITY 缺口，并给出建议的
   测试文件路径
4. 报告展示按系统的表格以及非豁免覆盖率
5. 技能询问 "May I write/update `tests/regression-suite.md` with the current
   regression suite manifest?"；获批后 audit 重写完整清单
6. 结论为 COMPLETE；针对 HIGH 缺口建议使用 `/test-helpers`

**Assertions:**
- [ ] 每条标准都得到 COVERED / PARTIAL / MISSING / EXEMPT 之一，且与 fixture 相符
- [ ] HUD 标准为 EXEMPT，且不计入覆盖率
- [ ] 伤害公式缺口为 HIGH PRIORITY，并带有 `tests/unit/combat/` 路径
- [ ] 只有在 "May I write/update" 询问之后才写入清单
- [ ] 结论为 COMPLETE，并建议使用 `/test-helpers`

---

### Case 2: 更新 — 已修复缺陷缺少回归测试

**Fixture:**
- `qa.level: standard`；`modes.workflow: standard`（固定：未设置时会解析为 minimal，此时下一冲刺的措辞不适用）；`project.stage: Polish`
- `production/sprints/sprint-007.md` 是当前冲刺计划；其中唯一一个
  `Status: Complete` 的用户故事是 `production/epics/inventory/story-003.md`
- `production/qa/bugs/BUG-0012.md` 的 `Status: Closed`，系统为 `inventory`
- `tests/unit/inventory/` 或 `tests/integration/inventory/` 下没有任何测试
  引用 BUG-0012 或其失败场景
- `tests/regression-suite.md` 已登记 6 个测试

**Input:** `/regression-suite update`

**Expected behavior:**
1. 技能读取冲刺计划中已完成的用户故事以及已关闭的缺陷
2. BUG-0012 为 MISSING REGRESSION TEST，建议路径为
   `tests/unit/inventory/[bug-slug]_regression_test.[ext]`，并附注
   "Without this test, this bug can silently return in a future sprint."
3. 报告展示 Bug Regression Coverage 表格，BUG-0012 标记为 NO
4. 在 "May I write/update" 询问之后，通过有针对性的 `Edit` 插入追加新条目；
   6 条现有条目保持不变
5. 技能说明下一冲刺应包含一个编写缺失测试的用户故事；
   结论为 COMPLETE

**Assertions:**
- [ ] BUG-0012 被报告为 MISSING REGRESSION TEST
- [ ] 建议路径遵循 `tests/unit/[system]/[bug-slug]_regression_test.[ext]`
- [ ] 不移除任何现有清单条目
- [ ] 由于缺陷回归缺口 > 0，出现下一冲刺用户故事的建议
- [ ] 获批后结论为 COMPLETE

---

### Case 3: qa.level minimal — 不生成套件

**Fixture:**
- `qa.level: minimal`
- 存在 GDD 和测试文件

**Input:** `/regression-suite audit`

**Expected behavior:**
1. 早期 `qa.level` 守卫在任何扫描之前触发
2. 技能报告 "Regression suite not generated at qa.level minimal" 并停止
3. 它不会落入工作流层级的 `minimal` 分支（冒烟报告范围）
4. 结论为 NOT ASSESSED——结论列表的第一条规则

**Assertions:**
- [ ] 显示 "not generated at qa.level minimal" 消息
- [ ] 不运行任何 GDD、测试或缺陷扫描
- [ ] 不因 `qa.level` 进入冒烟报告分支
- [ ] 不写入任何内容，也不出现 "May I write" 询问
- [ ] 结论为 NOT ASSESSED——不是 COMPLETE，也不是没有结论的停止

---

### Case 4: 边界情况 — 无测试文件，覆盖率为 NOT ASSESSED

**Fixture:**
- `qa.level: standard`；工作流层级 `full`；`project.stage: Polish`
- `design/gdd/` 中有带验收标准的 GDD
- `tests/unit/`、`tests/integration/` 和 `tests/regression/` 中没有任何文件
- 用户批准写入清单

**Input:** `/regression-suite audit`

**Expected behavior:**
1. 测试 glob 返回零个文件
2. 技能不给出覆盖率百分比
3. 它报告 `Coverage: NOT ASSESSED — no test files found`，指明为空的一侧
   以及负责生成测试脚手架的 `/test-setup`
4. 只有在 "May I write/update" 询问之后才写入清单
5. 结论为 NOT ASSESSED——首个匹配项，即使已经写入

**Assertions:**
- [ ] 不报告 `0%`（或任何百分比）覆盖率数字
- [ ] 覆盖率显示为 `NOT ASSESSED — no test files found`
- [ ] 指明 `/test-setup` 是负责生成的技能
- [ ] 任何清单写入仍需先进行 "May I write/update" 询问
- [ ] 结论为 NOT ASSESSED——绝不基于未计算的覆盖率数字给出 COMPLETE

---

### Case 5: 总监闸门检查 — 无；报告模式为只读

**Fixture:**
- `qa.level: standard`；`project.stage: Polish`
- 存在 `tests/regression-suite.md`、测试和已关闭缺陷
- 任意评审模式

**Input:** `/regression-suite report`

**Expected behavior:**
1. 技能在对话中生成 Regression Suite Status 报告
2. 不生成任何总监或其他代理；不出现闸门 ID
3. `report` 模式不写入任何内容，也不询问是否写入

**Assertions:**
- [ ] 未调用任何总监闸门，也不出现闸门跳过消息
- [ ] 不生成任何子代理
- [ ] 状态报告在对话中展示
- [ ] 不写入任何文件，也不出现 "May I write" 询问

---

### Case 6: 工作流 minimal 配合可写 QA 级别 — "Next story" 措辞，仅 full 下要求闸门

**Fixture:**
- `project.yaml`：`modes.workflow: minimal`（无冲刺），`qa.level: standard`（固定此项以便生成套件），`project.stage: Polish`
- 无冲刺计划；存在 `design/game-brief.md`。`production/epics/inventory/story-003.md` 的 `Status: Complete`，且 `tests/` 中没有针对 inventory 系统的测试
- `production/qa/bugs/BUG-0012.md` 的 `Status: Closed`，系统为 `inventory`；没有测试引用它
- `tests/regression-suite.md` 存在，已登记 6 个测试，且 Last Updated 日期较旧

**Input:** `/regression-suite update`

**Expected behavior:**
1. `qa.level` 守卫不触发（`standard`）；`update` 模式与层级无关，因此它会读取已完成的用户故事和已关闭缺陷
2. BUG-0012 为 MISSING REGRESSION TEST；没有测试的已完成 inventory 用户故事和过期清单被报告为覆盖率漂移
3. 在 "May I write/update" 询问和写入之后，后续行在原本会说 "next sprint" 的地方说 "next story"：缺失的测试应放入下一个用户故事，漂移提示建议在下一个用户故事边界运行 `/regression-suite audit`
4. 缺口被描述为建议性的；技能不会说 `/gate-check` 在此 `qa.level` 下需要该套件
5. 结论为 COMPLETE

**Assertions:**
- [ ] 缺陷缺口行和漂移行说 "next story"（或 "story boundary"），且不使用 "sprint" 一词来安排它们
- [ ] 当存在 HIGH 缺口时，HIGH 优先级行也说 "next story"，而不是 "next sprint"
- [ ] 缺口以建议性方式呈现；未声称 `/gate-check` 在 `qa.level: standard` 下需要该套件
- [ ] 不移除任何现有清单条目，且写入遵循 "May I write/update" 询问
- [ ] 结论为 COMPLETE

**Case 6b — `qa.level: full`：** 相同 fixture，但 `qa.level: full` 且 `project.stage: Production`。

**Assertions (6b):**
- [ ] 措辞仍为 "next story"
- [ ] 输出说明在 `qa.level: full` 下阶段闸门需要回归套件，因此那里的缺口不只是建议性的

---

## Protocol Compliance

- [ ] 在 `workflow: minimal` 下，后续行用 "next story" 代替 "next sprint"
- [ ] 在 `qa.level: minimal` 下于扫描前停止
- [ ] 当 GDD 或测试缺失时，报告 `NOT ASSESSED` 而不是百分比
- [ ] 在任何写入之前询问 "May I write/update `tests/regression-suite.md`"
- [ ] `update` 只追加；未经批准绝不移除现有清单条目
- [ ] `report` 不写入任何内容
- [ ] 结论按首个匹配项：在 `qa.level: minimal` 停止处或覆盖率未计算时（即使已写入）为 NOT ASSESSED；否则若用户拒绝写入为 BLOCKED；否则为 COMPLETE

---

## Coverage Notes

- 未测试无参数行为（冲刺明显活跃时运行 `update`，否则询问 A/B/C）。
- Case 6 覆盖了 `update` 模式下工作流 `minimal` 的措辞；在该层级下，`audit` 会对照最新的 `production/qa/smoke-*.md` 报告映射覆盖率，而不是 GDD 标准，并在不存在此类报告时停止；未单独测试。
- 覆盖率漂移检测仅通过 Case 6 中无测试的已完成用户故事和过期清单日期进行检验；新系统和 GDD 修订指标没有专门用例。
- 技能不运行测试；它按名称将标准和缺陷映射到测试文件。
