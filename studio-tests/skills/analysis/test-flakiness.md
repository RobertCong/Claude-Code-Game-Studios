# Skill Test Spec: /test-flakiness

## Skill Summary

`/test-flakiness` 从多次 CI 或本地测试运行的结果中发现不稳定（flaky）测试。它接受日志路径、`scan`（所有可用的结果文件——`reports/` 中或保存到 `test-results/` 的 gdUnit4 JUnit XML、`test-results/` 中来自 Unity 的 NUnit XML、`Saved/Logs/` 中的 Unreal 自动化日志），或 `registry`（针对已在 `tests/regression-suite.md` 隔离区章节中的测试提供修复指引）。没有结果数据时，它列出三种获取数据的方式并停下来询问。它构建跨运行的逐测试历史，按失败率对既有通过又有失败的每个测试分类——>25% 为 High（立即隔离），5–25% 为 Moderate（直接修复，暂不隔离），1–5% 为 Low（监控）——并根据其原因表点名可能原因和修复方向，使用 Grep 检索测试文件。运行次数少于 3 次时，无论失败率如何，每个发现项都是「suspected」而不是「confirmed」，且不隔离任何测试；摘要表的 Confidence 列会说明是哪一种。它分别询问「May I update the quarantine section of `tests/regression-suite.md`…?」和「May I write a full flakiness report to `production/qa/flakiness-report-[date].md`?」，追加隔离条目而不移除现有条目，且从不删除测试文件。不调用任何总监质量闸门。结论：COMPLETE（已写入报告）或 BLOCKED（用户拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具有必需的前置元数据（frontmatter）字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED，以及不稳定层级 High / Moderate / Low
- [ ] 包含针对 `tests/regression-suite.md` 和 `production/qa/flakiness-report-[date].md` 的「May I」写入措辞
- [ ] 具有下一步交接（Section 7：添加跳过标注、在发布质量闸门之前安排修复）

---

## Director Gate Checks

无。不稳定检测是建议性质量技能；不调用任何质量闸门（gate）。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 从 JUnit 历史发现 High 不稳定，经批准后隔离

**Fixture:**
- `project.yaml`：`engine.name: godot`；`modes.automation` 未设置（collaborative）
- `test-results/` 存放 6 个 gdUnit4 JUnit XML 文件，来自同一提交的 6 次运行
- `test_loot_drop_rolls_rare_item` 在 6 次运行中的 2 次失败（33%）；其他 40 个测试在全部 6 次中通过
- `tests/unit/loot/loot_drop_test.gd` 调用 `randf()` 且未设种子
- `tests/regression-suite.md` 有一个 Quarantined Tests 表，包含 1 条现有条目

**Input:** `/test-flakiness scan`

**Expected behavior:**
1. 技能在 `test-results/` 中找到 XML 文件，并解析 `<testcase name=` 和 `<failure` / `<error` 条目
2. 技能构建 `test_id → [run1 … run6]`，发现一个测试同时有两种结果
3. 6 次运行中 33% 高于 25% → **High** 不稳定，Confidence 为 confirmed → 立即隔离
4. 对 `loot_drop_test.gd` 的 Grep 找到 `randf` → 可能原因为 Random seed；修复方向：传入显式种子
5. 隔离建议点名 gdUnit4 的 GDScript 跳过参数（`_do_skip := true`、`_skip_reason := "flaky: ..."`）作为跳过方式
6. 摘要显示分析运行次数 6、跟踪测试数 41、该不稳定测试的失败率为 33%，以及 40 个结果一致的测试
7. 技能询问「May I update the quarantine section of `tests/regression-suite.md` with the flaky tests found?」，并另外询问「May I write a full flakiness report to `production/qa/flakiness-report-[date].md`?」
8. 批准后，新条目用 `Edit` 追加；现有条目保留
9. Verdict: **COMPLETE** — flakiness report written

**Assertions:**
- [ ] `test-results/` 中的 JUnit XML 结果按测试跨全部 6 次运行解析
- [ ] 该不稳定测试被点名并给出失败率，Confidence 为 confirmed，分类为 High → 隔离
- [ ] 点名的跳过机制是 gdUnit4 的 `_do_skip` / `_skip_reason` 参数对，而不是臆造的标志
- [ ] 可能原因为 Random seed，修复方向为显式种子
- [ ] 两次写入分别询问，且各自先于实际发生
- [ ] 隔离条目被追加，现有条目未被移除
- [ ] 结论为 COMPLETE

---

### Case 2: 中等不稳定 — 直接修复，不隔离

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `test-results/` 存放 20 个 JUnit XML 文件，来自同一提交的 20 次运行
- `test_physics_bounce_height_matches_spec` 在 20 次运行中的 3 次失败（15%）
- 该测试断言 `bounce_height == 0.5`

**Input:** `/test-flakiness scan`

**Expected behavior:**
1. 技能计算失败率为 15% → **Moderate** 不稳定
2. 对测试文件的 Grep 发现浮点相等比较 → 可能原因为 Floating point
3. 建议：「This test is intermittently unreliable… Do not quarantine yet — fix the test directly」，修复方向为 epsilon 比较（`is_equal_approx`）

**Assertions:**
- [ ] 15% 的失败率被分类为 Moderate
- [ ] 建议为直接修复，而不是隔离
- [ ] 原因为 Floating point，且修复点名 `is_equal_approx` 之类的 epsilon 比较

---

### Case 3: 无结果数据 — 列出选项并停止

**Fixture:**
- 没有 `test-results/` 目录、没有 `.github/` 目录、没有 `Saved/Logs/`
- 未给出日志路径

**Input:** `/test-flakiness scan`

**Expected behavior:**
1. 技能未找到任何 CI 或本地结果数据
2. 技能打印「No CI log data found…」并给出三个选项：至少运行测试套件 3 次并收集日志；将 CI 日志保存到 `test-results/`；运行 `/test-flakiness registry`
3. 技能停止并询问用户选择哪条路
4. 不产出不稳定表，也不写入任何内容

**Assertions:**
- [ ] 输出说明未找到 CI 日志数据
- [ ] 三个选项全部列出，包括 `/test-flakiness registry`
- [ ] 技能停下来询问，而不是报告干净结果
- [ ] 不写入任何文件

---

### Case 4: 运行次数过少 — 为 suspected，而非 confirmed

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `test-results/` 只有 2 个 JUnit XML 文件，来自同一提交的 2 次运行
- `test_save_roundtrip_preserves_inventory` 在 1 次运行中通过、另 1 次失败

**Input:** `/test-flakiness scan`

**Expected behavior:**
1. 技能解析两个文件，发现该测试同时有两种结果——失败率 50%
2. 运行次数少于 3 次时，发现项被标记为「suspected」而不是「confirmed」：摘要表的 Confidence 显示 suspected，且 High 层级的「立即隔离」不适用
3. 该测试不被隔离；建议在采取行动前收集更多运行数据
4. 技能询问是否有更多运行数据可用
5. Data Limitations 章节注明可用运行次数少于 5 次，因此置信度低

**Assertions:**
- [ ] 在摘要表的 Confidence 列中，该发现项被标记为 suspected，而不是 confirmed
- [ ] 50% 的失败率不触发隔离——不建议跳过，任何回归套件记录都将该测试标记为 suspected
- [ ] 技能询问是否有更多运行数据可用
- [ ] Data Limitations 说明分析的运行次数少于 5 次

---

### Case 5: 完整评审模式下的 registry 模式 — 为已知隔离测试提供指引，无质量闸门

**Fixture:**
- `project.yaml`：`modes.review_mode: full`
- `tests/regression-suite.md` 的 Quarantined Tests 表列出 `test_ai_path_recalc_avoids_blocked_tile`（原因：timing）和 `test_scene_load_spawns_player`（原因：scene not ready）

**Input:** `/test-flakiness registry`

**Expected behavior:**
1. 技能读取 `tests/regression-suite.md` 的隔离区章节
2. 对每个被隔离的测试，它从原因表给出修复指引：Timing / async → 使用显式 await 或同步，而不是基于时间的延迟；Scene/prefab load race → 在实例化后等待一帧（`await get_tree().process_frame`）
3. 无论评审模式如何，都不调用总监质量闸门
4. 现有隔离条目不被移除，技能也不删除或编辑任何测试文件

**Assertions:**
- [ ] 输入是 `tests/regression-suite.md` 的隔离区章节
- [ ] 每个被隔离的测试都得到与其原因匹配的修复方向
- [ ] 在任何评审模式下都不调用总监质量闸门
- [ ] 不删除任何隔离条目，也不删除任何测试文件

---

## Protocol Compliance

- [ ] 在分析前定位结果数据（`test-results/` XML、`Saved/Logs/` 或给定日志路径）；没有时列出三个选项并停下来询问
- [ ] 按失败率对同时有两种结果的测试分类：>25% High（隔离）、5–25% Moderate（修复，不隔离）、1–5% Low（监控）
- [ ] 从原因表点名可能原因和修复方向，使用 Grep 检索测试文件
- [ ] 仅当测试在运行之间没有代码改动却既通过又失败时，才将其计为不稳定
- [ ] 运行次数少于 3 次时，在摘要的 Confidence 列中将发现项标记为 suspected 而不是 confirmed，且不隔离任何测试
- [ ] 在更新 `tests/regression-suite.md` 之前和写入 `production/qa/flakiness-report-[date].md` 之前分别询问
- [ ] 追加隔离条目，从不移除现有条目，也从不删除测试文件
- [ ] 不调用任何总监质量闸门
- [ ] 写入时以 COMPLETE 结束，拒绝时以 BLOCKED 结束；没有结果数据时列出三个选项并停下来询问（Case 3），绝不报告干净结果

---

## Coverage Notes

- 无参数路径（CI 日志可访问时运行 `scan`，否则运行 `registry`）此处未测试。
- Unity NUnit XML 遵循与 Case 1 相同的流程，从 `<test-case` 元素及其 `result` 属性读取；未单独测试。
- Unreal 有所不同且此处未测试：其结果在 `Saved/Logs/` 中是纯文本的 `Result={Success}` / `Result={Fail}` 行（每个测试打印 `Test Completed. Result={<status>}`），且其跳过机制为 NOT SOURCEABLE，因此被隔离的 Unreal 测试会被记录，并询问用户其 CI 如何排除它。gdUnit4 的 C# 测试同样如此。
- Low 层级（1–5%）需要 20 次或更多运行才能达到，未测试。
