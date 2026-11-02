# Skill Test Spec: /smoke-check

## Skill Summary

`/smoke-check` 是实现与 QA 交接之间的闸门。Phase 1 运行
`project-coherence.sh`，验证**游戏测试文件**存在于
引擎的测试根或 `tests/smoke/` 下（而不仅仅是 `tests/` 存在），并
从 `project.yaml` 读取引擎（回退到 `technical-preferences.md`），
然后解析编辑器可执行文件——先取 `commands.test` 指定的，其次
`engine.path`，再次 `PATH` 上的名称——之后才报告运行器不可用。
Phase 2 在超时限制下运行 `commands.test`（或按引擎的默认命令），
并按引擎解读结果——Godot 用 gdUnit4 退出码；在 Unity 上，
`Assets/Tests/PlayMode/` 下的 Play Mode 测试会再运行一次，使用各自的结果
文件。在 `qa.level: minimal` 且无游戏测试时，自动化行被 WAIVED，
Phase 2 改为运行构建检查——若设置了 `commands.smoke`，否则
`commands.build`。Phase 3 对照 QA 计划或
冲刺用户故事扫描测试覆盖率；Phase 4 用
`AskUserQuestion` 批量确认手动冒烟检查，且 Batch 1 首先询问本次
会话是否启动过构建——"not launched" 会使手动检查为 NOT ASSESSED。报告在
明确批准后写入 `production/qa/smoke-[date].md`。

结论按首个匹配规则胜出：FAIL（测试失败、未完成的套件——超时、
编译/解析/构建错误、无结果文件——或 Batch 1/Batch 2 检查 FAILED，或构建检查失败）、
NOT ASSESSED（套件未确认 NOT RUN、无法运行或执行了零个测试的运行器、
未确认的 `PlayMode: NOT RUN`、无法执行的检查——包括本次会话未启动构建——
`UNKNOWN` 覆盖率行、跳过 Batch 3——或在 `qa.level`
`standard`/`full` 下无游戏测试；在 `minimal` 下自动化行被 WAIVED，由批次
承担结论）、PASS WITH WARNINGS（测试证据 MISSING、运行器警告
如 gdUnit4 101 的泄漏孤儿节点，或开发者确认的 NOT RUN 套件）、
PASS。NOT ASSESSED 高于两个通过值，低于 FAIL。
FAIL 是否阻塞交接取决于 `qa.level`（`minimal` 下为建议性）
与 `testing.strict.config`（未设置 → 阻塞）。

不适用任何总监闸门。本技能不调用任何总监代理。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：PASS、PASS WITH WARNINGS、NOT ASSESSED、FAIL
- [ ] 在写入报告之前包含 "May I write" 协作协议用语
- [ ] 有下一步交接（FAIL 后重新运行 `/smoke-check`；PASS 后向 qa-tester 交接 QA）

---

## Director Gate Checks

无。`/smoke-check` 是 QA 前置工具技能。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 自动化测试通过，手动项确认，PASS

**Fixture:**
- `project.yaml` 中有 `engine.name: Godot`，且 `commands.test` 设为 gdUnit4 命令
- `addons/gdUnit4/bin/GdUnitCmdTool.gd` 存在；游戏测试存在于
  `tests/unit/` 与 `tests/integration/` 下
- `production/qa/qa-plan-sprint-005.md` 存在
- 运行器以退出码 0 结束，共 12 个测试，12 个通过
- 开发者表示本次会话启动过构建，且在 Batch 1、Batch 2 或 Batch 3 中未选择任何 FAILED 条目
- 每个冲刺用户故事都是 COVERED 或 EXPECTED（无 MISSING，无 UNKNOWN）

**Input:** `/smoke-check`

**Expected behavior:**
1. Phase 1 报告环境：Godot、找到测试、QA 计划路径
2. 先运行 `godot --headless --path . --import`，再在 `timeout 900` 下运行 `commands.test`
   （`godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`）；
   报告说明运行的是 `commands.test`
3. 退出码 0 且找到测试 → 自动化测试 PASS（12/12）
4. 覆盖率扫描：所有用户故事为 COVERED 或 EXPECTED
5. 对 Batch 1、Batch 2 与 Batch 3 使用 `AskUserQuestion`——未选择任何内容
6. 报告指明其清单来源（QA 计划的 Smoke Test Scope）
7. 询问 "May I write this smoke check report to `production/qa/smoke-[date].md`?"
8. 批准后写入；交付 "Smoke check passed cleanly. The build is ready for manual QA."

**Assertions:**
- [ ] 自动化测试运行器在 Godot 导入后通过 Bash 调用
- [ ] 手动冒烟检查批次使用 `AskUserQuestion`
- [ ] 在写入报告文件之前询问 "May I write"
- [ ] 报告写入 `production/qa/smoke-[date].md`
- [ ] 结论为 PASS

---

### Case 2: 失败路径 — 自动化测试失败，阻塞性 FAIL

**Fixture:**
- 同 Case 1，但 `project.yaml` 设置 `modes.rigor: standard`（因此 `qa.level`
  解析为 `standard`），且未设置 `testing.strict`
- 运行器以退出码 100 结束：运行 10 个测试，8 个通过，2 个失败——
  `test_health_clamp_at_zero`、`test_damage_calculation_negative`

**Input:** `/smoke-check`

**Expected behavior:**
1. 技能通过 Bash 运行自动化测试；退出码 100 → FAIL
2. 记录两个失败的测试名称
3. 继续执行手动冒烟检查批次
4. 报告将自动化测试显示为 FAIL，并列出失败的测试名称
5. 请求写入报告；批准后写入
6. 闸门为阻塞（`qa.level: standard`，`testing.strict.config` 未设置 → 阻塞）
7. 交付："The smoke check failed. Do not hand off to QA until these failures
   are resolved: …"，列出每个失败，然后说明 "Fix the failures and run
   `/smoke-check` again to re-gate before QA hand-off."

**Assertions:**
- [ ] 报告中列出失败的测试名称
- [ ] 结论为 FAIL
- [ ] 阻塞消息指示开发者在 QA 交接前修复失败
- [ ] 建议修复后重新运行 `/smoke-check`

---

### Case 3: 手动确认 — MISSING 覆盖率，PASS WITH WARNINGS

**Fixture:**
- 同 Case 1：运行器以退出码 0 结束，8/8 通过
- 一个 Logic 用户故事没有匹配的测试文件（MISSING 覆盖率）；没有 UNKNOWN 行
- 开发者在 Batch 1、Batch 2 或 Batch 3 中未选择任何 FAILED 条目

**Input:** `/smoke-check`

**Expected behavior:**
1. 自动化测试 PASS
2. 覆盖率扫描发现一个 Logic 用户故事的 1 个 MISSING 条目
3. 对 Batch 1–3 使用 `AskUserQuestion`——未选择任何内容
4. 报告显示自动化测试 PASS、手动检查 PASS，并在 "Missing Test Evidence"
   下显示该 MISSING 条目及其预期测试路径
5. 结论为 PASS WITH WARNINGS；消息说明构建已可进入手动
   QA，并将该 MISSING 条目列为建议项，需在
   受影响用户故事的 `/story-done` 之前解决
6. 请求写入报告；批准后写入

**Assertions:**
- [ ] 手动冒烟检查批次使用 `AskUserQuestion`（而非内联文本提示）
- [ ] 报告中出现 MISSING 测试覆盖率条目
- [ ] 结论为 PASS WITH WARNINGS（不是 PASS，不是 FAIL）
- [ ] 建议说明必须在 `/story-done` 之前解决该 MISSING 条目
- [ ] 报告文件写入 `production/qa/smoke-[date].md`

---

### Case 4: 只有脚手架而无游戏测试 — NOT ASSESSED，然后停止

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`（因此 `qa.level` 解析为 `standard`）
- 引擎为 Godot；`tests/unit/` 与 `tests/integration/` 存在，但只包含
  `/test-setup` 创建的 `.gdignore_placeholder` 文件
- 没有 `tests/smoke/` 目录

**Input:** `/smoke-check`

**Expected behavior:**
1. Phase 1 统计游戏测试文件而非目录——找不到任何文件
2. 技能交付："Smoke check: **NOT ASSESSED — no game tests found** under
   [the test root] or `tests/smoke/`. Run `/test-setup` to scaffold the testing
   infrastructure, or point me at where tests live."
3. 技能停止——不运行自动化测试，不进行手动批次，不写报告

**Assertions:**
- [ ] `tests/` 及其子目录的存在不被视为测试已存在
- [ ] 结论为 NOT ASSESSED——技能不会在没有结论的情况下停止
- [ ] 建议将 `/test-setup` 作为补救步骤
- [ ] 不运行后续阶段，也不写入任何报告文件

---

### Case 4b: 在 `qa.level: minimal` 下无游戏测试 — WAIVED，由构建承担结论

**Fixture:**
- 未设置 `modes.rigor`（默认 `minimal`，因此 `qa.level` 解析为 `minimal`）
- 引擎为 Godot；`tests/unit/`、`tests/integration/` 或 `tests/smoke/` 下没有游戏测试文件
- `commands.smoke` 为 `godot --headless --quit-after 5`；它以退出码 0 结束且没有 `SCRIPT ERROR` 行
- 用户表示本次会话启动过构建，并确认每个 Batch 1、Batch 2 与 Batch 3 检查

**Input:** `/smoke-check`

**Expected behavior:**
1. Phase 1 找不到游戏测试文件，且在 `qa.level: minimal` 下将自动化行记录为 `WAIVED — qa.level: minimal, no game tests`
2. 跳过 Phase 2 的测试运行与 Phase 3，各附一行原因说明
3. Phase 2 的构建检查在超时限制下运行 `commands.smoke`（在 Godot 导入后）：`Build check: PASS`
4. Phase 4 运行 Batch 1–3；每个检查都通过
5. 结论：PASS——报告的 Automated Tests 状态读作 WAIVED

**Assertions:**
- [ ] 缺失的测试为 WAIVED，而非 NOT ASSESSED，因为 `qa.level` 为 `minimal`
- [ ] 被跳过的测试运行与 Phase 3 会被明确告知，而非静默
- [ ] 构建检查运行 `commands.smoke`，其结果出现在报告中
- [ ] Batch 1 与 Batch 2 仍会运行——绝不在没有它们的情况下给出 PASS
- [ ] 结论为 PASS，且报告的 Automated Tests 行读作 WAIVED
- [ ] 无法执行的 Batch 1 或 Batch 2 检查（无构建）使结论为 NOT ASSESSED，与任何层级相同
- [ ] 变体——用户回答本次会话未启动构建：不询问 Batch 2 与 Batch 3（明确说明跳过），Batch 1 的检查读作 `NOT RUN — build not launched this session`，结论为 NOT ASSESSED——绝不从空的失败列表得出 PASS
- [ ] 变体——`commands.smoke` 打印 `SCRIPT ERROR`（Godot 的启动检查对其仍退出 0）：构建检查为 FAIL，结论也为 FAIL

---

### Case 5: 总监闸门检查 — 无闸门；smoke-check 是 QA 前置工具

**Fixture:**
- 有效测试设置，自动化测试通过，手动冒烟检查已确认

**Input:** `/smoke-check`

**Expected behavior:**
1. 技能运行所有阶段并给出结论
2. 任何时刻都不派发总监代理
3. 输出中不出现闸门 ID（CD-*、TD-*、AD-*、PR-*）
4. 不调用任何 `/gate-check`

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 结论为 PASS、PASS WITH WARNINGS、NOT ASSESSED 或 FAIL——不涉及闸门结论

---

### Case 6: gdUnit4 相似情形 — 零测试下的退出码 0，以及退出码 101

**Fixture:**
- 同 Case 1，每个用户故事为 COVERED 或 EXPECTED，且在
  Batch 1、Batch 2 或 Batch 3 中未选择任何内容
- 运行 A：`tests/unit/` 下的套件未声明任何测试函数；运行器
  打印 `No test cases found` 并以退出码 0 结束
- 运行 B：运行器以退出码 101 结束——12 个测试，12 个通过，2 个孤儿节点泄漏

**Input:** `/smoke-check`

**Expected behavior:**
1. 运行 A：退出码 0 不被解读为通过——自动化测试为
   `NOT ASSESSED — no tests found`，即使每个手动检查都通过，
   结论仍为 NOT ASSESSED
2. 运行 B：101 为 PASS WITH WARNINGS，并点名孤儿节点数；没有 MISSING
   条目时，结论为 PASS WITH WARNINGS，建议列表点名
   孤儿节点

**Assertions:**
- [ ] 运行 A 的结论为 NOT ASSESSED——不是 PASS
- [ ] 运行 B 的 Status 行为 PASS WITH WARNINGS，并附孤儿节点数
- [ ] 运行 B 的结论为 PASS WITH WARNINGS——不是 PASS，也不是 FAIL

---

### Case 7: 超时 — 套件从未完成，FAIL

**Fixture:**
- 同 Case 2（`qa.level: standard`，`testing.strict` 未设置）
- 运行器挂起；`timeout 900` 以退出码 124 结束它，未打印摘要

**Input:** `/smoke-check`

**Expected behavior:**
1. 退出码 124 是闸门 FAILURE，绝非通过——运行未完成，
   也没有验证任何内容
2. Status 行读作 FAIL，并点名超时
3. 结论为 FAIL，且闸门为阻塞

**Assertions:**
- [ ] 超时为 FAIL——不是 NOT ASSESSED，也不是 NOT RUN
- [ ] 报告将超时列为原因
- [ ] 交付阻塞消息

---

### Case 8: 跳过 Batch 3 — NOT ASSESSED，而非 PASS

**Fixture:**
- 同 Case 1：运行器以退出码 0 结束，12/12 通过，没有 MISSING 或 UNKNOWN 行
- 在 Batch 3 中，开发者只选择 "Performance not checked this session"

**Input:** `/smoke-check`

**Expected behavior:**
1. Batch 1 与 Batch 2 通过
2. 被跳过的 Batch 3 条目记录为未检查——不是 FAIL
3. 结论为 NOT ASSESSED，Phase 6 消息点名未运行的性能
   检查

**Assertions:**
- [ ] 结论为 NOT ASSESSED——不是 PASS，不是 FAIL
- [ ] 报告中点名未检查的性能条目

---

### Case 9: Unity — Play Mode 作为第二次运行

**Fixture:**
- `engine.name: Unity`；`com.unity.test-framework` 在 `Packages/manifest.json` 中
- `commands.test` 是 `/setup-engine` 写入的 Edit Mode 命令
- `Assets/Tests/EditMode/` 与 `Assets/Tests/PlayMode/` 都含测试文件
- Edit Mode 以退出码 0 结束，8/8 通过；Play Mode 以退出码 2 结束，3 个中 1 个失败

**Input:** `/smoke-check`

**Expected behavior:**
1. Edit Mode 运行先删除 `test-results/editmode.xml`，然后运行
2. 由于 `commands.test` 未传 `-testPlatform PlayMode`，且
   `Assets/Tests/PlayMode/` 含测试，技能也运行 Play Mode，先删除
   再写入 `test-results/playmode.xml`
3. 报告每个平台一行 Status：`EditMode: PASS (8/8)` 与
   `PlayMode: FAIL (1 failure)`
4. 结论为 FAIL

**Assertions:**
- [ ] Play Mode 作为第二次运行执行，并使用各自的结果文件
- [ ] 每个平台各占一行报告
- [ ] Play Mode 失败使结论为 FAIL——Edit Mode 通过不能覆盖它

---

### Case 10: `quick` — 不扫描覆盖率，不执行 Batch 3

**Fixture:**
- 同 Case 1：运行器以退出码 0 结束，12/12 通过；开发者表示本次会话
  启动过构建，且在 Batch 1 或 Batch 2 中未选择任何 FAILED 条目
- 冲刺中一个 Logic 用户故事没有匹配的测试文件（若扫描会是
  MISSING）
- 冲刺计划与 QA 计划存在

**Input:** `/smoke-check quick`

**Expected behavior:**
1. Phase 1 与 Phase 2 照常运行；自动化测试 PASS（12/12）
2. 跳过 Phase 3 并说明："Coverage scan skipped — run
   `/smoke-check sprint` for full coverage analysis."
3. 仅对 Batch 1 与 Batch 2 使用 `AskUserQuestion`；不询问 Batch 3
4. 报告的 Argument 行读作 `quick`，其 Test Coverage 节以
   "Coverage: not checked (quick run) — run `/smoke-check sprint` before
   hand-off." 替代用户故事行——扫描被跳过，而非通过
5. 未扫描的 Logic 用户故事不报告为 MISSING，不为它臆造覆盖率行，
   Missing Test Evidence 读作 "Not checked (quick run)."，
   而非 "All Logic and Integration stories have test coverage."
6. 结论带标签：`PASS (quick — coverage and Batch 3 not checked)`
7. 询问 "May I write this smoke check report to `production/qa/smoke-[date].md`?"
   并在批准后写入

**Assertions:**
- [ ] Phase 3 的跳过以 "Coverage scan skipped" 说明告知，而非静默
- [ ] `quick` 下绝不询问 Batch 3；Batch 1 与 Batch 2 仍会询问
- [ ] 自动化测试运行仍会进行：`quick` 只跳过 Phase 3 与 Batch 3
- [ ] 报告显示 `Argument: quick`，且不含 COVERED / MISSING / UNKNOWN 行
- [ ] 报告在 Test Coverage 与 Missing Test Evidence 节说明覆盖率未检查，绝不声称完整覆盖
- [ ] 结论行带有 `(quick — coverage and Batch 3 not checked)` 标签
- [ ] 跳过 Batch 3 不会使结论为 NOT ASSESSED：Batch 3 未被提供，因此 "offered and skipped" 规则不触发
- [ ] 报告仍只在 "May I write" 批准后写入

---

### Case 11: `--platform` — 平台批次与逐平台结论表

**Fixture:**
- 同 Case 1：运行器以退出码 0 结束，12/12 通过；开发者表示本次会话
  启动过构建，且在 Batch 1、2 或 3 中未选择任何 FAILED 条目；
  每个用户故事为 COVERED 或 EXPECTED
- 主机批次：开发者选择 "UI outside TV safe zone / text clipped —
  FAILED"，并描述暂停菜单上被裁切的文本
- PC 与移动批次（下方变体）：未选择任何内容

**Input:** `/smoke-check sprint --platform console`

**Expected behavior:**
1. Phase 1–3 按 Case 1 运行
2. Phase 4 询问 Batch 1–3，然后询问主机批次（手柄、TV 安全区、
   键鼠回退、冷启动）；失败之后要求
   描述被裁切的内容
3. 报告有一个 Platform-Specific Results 表，含 Console 行
   （运行检查数、通过数、失败 1、Platform Verdict FAIL），且没有 PC 或 Mobile 行
4. 总体结论为 FAIL："Any platform with one or more FAIL checks
   contributes to the overall FAIL verdict"——即使自动化测试
   与 Batch 1–3 通过
5. 询问 "May I write …"；批准后写入

**Assertions:**
- [ ] 除 Batch 1–3 之外还询问主机批次
- [ ] 报告包含逐平台结论表，Console 行为 FAIL
- [ ] 总体结论为 FAIL，仅由主机检查驱动
- [ ] 不询问 PC 或移动批次，也不出现 PC 或 Mobile 行
- [ ] 用户对失败的描述记录在报告中
- [ ] 变体 `--platform all`，任何平台批次中未选择任何内容：PC、主机与移动批次都会被询问，表有三行且每行 PASS，结论为 PASS
- [ ] 变体 `quick --platform pc`：Phase 3 与 Batch 3 如 Case 10 跳过，PC 批次仍会询问，且表中有 PC 行

---

### Case 12: 阶段文件 — 每个 `references/` 文件在其阶段前读取，并在压缩后重读

**Fixture:**
- 同 Case 1（有效设置，12/12 通过，任何批次中未选择任何内容）
- 对话在 Phase 3 期间被压缩，发生在测试运行结束后、
  覆盖率扫描结果被使用之前

**Input:** `/smoke-check`

**Expected behavior:**
1. 在 Phase 1 工作前读取 `references/1-detect-setup.md`，同样地
   在调用测试运行器前读取 `references/2-run-tests.md`、
   在绘制用户故事列表前读取 `references/3-coverage.md`、
   在第一次 `AskUserQuestion` 前读取 `references/4-manual-checks.md`、
   在组装报告前读取 `references/5-report.md`、
   在询问 "May I write" 前读取 `references/6-write-gate.md`
2. 读取按阶段、按顺序发生——每个阶段的步骤来自其
   文件，而非 `SKILL.md`，后者只指明文件
3. 压缩后，在扫描继续前再次读取 `references/3-coverage.md`
   （"Read it again if the conversation was compacted or resumed
   during this phase"）；已完成阶段的文件不再重读
4. 运行按 Case 1 结束：结论 PASS，批准后写入报告

**Assertions:**
- [ ] 转录中出现六次对 `references/1-…` 至 `6-…` 的 Read 调用，每个阶段一次，按阶段顺序
- [ ] 每个文件都在其自身阶段的第一个动作之前读取（阶段 2 的运行器、阶段 3 的用户故事扫描、阶段 4 的 `AskUserQuestion`、阶段 5 的报告、阶段 6 的写入询问）
- [ ] 压缩后再次读取 `references/3-coverage.md`，在覆盖率工作继续之前
- [ ] 压缩后不重读其他任何阶段的文件
- [ ] 这些读取不改变 Case 1 的任何结果（结论 PASS）

---

## Protocol Compliance

- [ ] 所有手动冒烟检查批次（Batch 1、Batch 2、Batch 3）使用 `AskUserQuestion`，且 Batch 1 询问本次会话是否启动过构建；"not launched" 产生 NOT ASSESSED
- [ ] 在报告运行器不可用之前，依次从 `commands.test`、`engine.path`、`PATH` 解析编辑器可执行文件；无法解析的裸 `godot` 绝不被读作 "no engine installed"
- [ ] 绝不编辑 `project.yaml`：缺少标志或使用相对路径的 `commands.test` 会为本次运行调整，并告知用户
- [ ] 在询问任何手动问题之前通过 Bash 运行自动化测试
- [ ] 在创建报告文件之前询问 "May I write"——绝不在未批准时写入
- [ ] 结论词汇为 PASS / PASS WITH WARNINGS / NOT ASSESSED / FAIL——没有其他结论
- [ ] FAIL 由自动化测试失败、未完成的套件（超时、编译/解析/构建错误、无结果文件）或 Batch 1/Batch 2 的 FAIL 回答触发
- [ ] PASS WITH WARNINGS 由 MISSING 测试覆盖率、通过套件上的运行器警告（gdUnit4 101）或已确认的 NOT RUN 触发——且无关键失败
- [ ] 未确认的 NOT RUN（运行器不可用）产生 NOT ASSESSED——绝不 FAIL，绝不给通过结论
- [ ] 零测试的运行、无法运行运行器，以及未确认的 `PlayMode: NOT RUN` 产生 NOT ASSESSED
- [ ] 任何时刻都不调用总监闸门

---

## Coverage Notes

- `quick` 参数（跳过 Phase 3 覆盖率扫描与 Batch 3）是
  Case 10；`--platform` 参数（平台批次与逐平台
  结论表）是 Case 11；按阶段读取 `references/` 与
  压缩后重读是 Case 12。各平台批次的单独
  选项未逐一枚举。
- 运行器不可用路径（NOT RUN，随后 NOT ASSESSED，直到开发者
  从自己的 IDE 或 CI 确认结果）由上述协议合规
  断言覆盖。
- 在 `qa.level: minimal` 下，FAIL 为建议性且绝不阻塞交接；Case 2
  固定 `standard` 以测试阻塞路径。Unity 的 `testcasecount="0"` 与
  Unreal 的 `No automation tests matched`（→ NOT ASSESSED）遵循 Case 6 运行 A；
  未单独做 fixture 测试。
- Linux 与 macOS 的 Unreal 命令（由 `uname -s` 选择）未做
  fixture 测试。在 macOS 上，Unreal 测试在设置 `commands.test`
  之前为 NOT ASSESSED——在技能中断言，此处未给用例。
- 无法进行的 Play Mode 运行（`PlayMode: NOT RUN`，未确认 →
  NOT ASSESSED）由协议合规覆盖，而非专门用例。
