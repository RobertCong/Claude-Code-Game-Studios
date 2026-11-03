# Skill Test Spec: /test-evidence-review

## Skill Summary

`/test-evidence-review` 评审用户故事背后的测试文件和证据文档的**质量**——`/smoke-check` 负责覆盖存在性和通过情况。它接受一个范围：单个用户故事路径、`sprint`（`production/sprints/` 中最近的计划），或系统名（`production/epics/[system]/story-*.md`）；不带参数时会询问选择哪个。如果解析出的范围中用户故事数为零，则以 `NOT ASSESSED — no stories in scope` 停止，并路由到创建用户故事的技能。对于每个用户故事，它用有针对性的 grep 收集 Story Type、证据路径和验收标准，定位证据（`tests/unit/[system]/`、`tests/integration/[system]/`、`production/qa/evidence/`、`production/qa/smoke-*.md`），并评审自动化测试的断言数量、边界情况、命名和公式可追溯性，以及人工证据的标准关联、签署、保留的截图和时效性。它以与 `/story-done` 相同的方式解析 `qa.level` 和 `testing.strict`：在 `qa.level: minimal` 下，没有测试证据的 Logic、Integration 或 Config/Data 用户故事为 `WAIVED (qa.level: minimal)`，而不是 MISSING，且确实存在的测试中的缺口为 ADVISORY；Visual/Feel 和 UI 证据永远不会被豁免；否则每个缺口按 `testing.strict.<type>` 取其用户故事类型的质量闸门级别（未设置 → 使用适用于所有类型的纯布尔 `testing.strict` 旧值；再否则使用 `coding-standards.md` 默认值）。每个用户故事得到 ADEQUATE、INCOMPLETE、MISSING、NOT ASSESSED 或 WAIVED；整体结论是存在的最差项，其中 NOT ASSESSED 仅优先于 ADEQUATE，且 WAIVED 低于 ADEQUATE。报告在对话中呈现，技能将「May I write this test evidence review to `production/qa/evidence-review-[date].md`?」作为可选步骤询问。它从不修改测试文件或证据文档，也不调用任何总监质量闸门。运行以 COMPLETE 结束，或在发现 BLOCKING 项时以 CONCERNS 结束。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含结论关键词：ADEQUATE、INCOMPLETE、MISSING、NOT ASSESSED，以及运行级 COMPLETE / CONCERNS
- [ ] 包含针对可选的 `production/qa/evidence-review-[date].md` 的「May I write」措辞
- [ ] 具有下一步交接（Section 7：`/story-done` 之前的 BLOCKING 项、`/test-helpers`、签署路由）
- [ ] `resolve_config` 注入点名 `qa.level` 和 `testing.strict`，且技能说明 `WAIVED (qa.level: minimal)` 结果和按类型的 `testing.strict.<type>` 质量闸门级别

---

## Director Gate Checks

无。测试证据评审是建议性质量技能；不调用任何质量闸门（gate）。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 单个 Logic 用户故事，测试扎实

**Fixture:**
- `project.yaml`：`engine.name: godot`，因此单元测试根为 `tests/unit/`；`modes.automation` 未设置（collaborative）
- `production/epics/combat/story-001-damage-calc.md`（slug 为 `damage-calc`）：`## Test Evidence` 给出 Story Type 为 Logic 和路径 `tests/unit/combat/damage-calc_test.gd`；`## Acceptance Criteria` 包含「damage is never below 1」和「critical hits multiply damage by 2.0」
- `tests/unit/combat/damage-calc_test.gd` 以 `# Story: production/epics/combat/story-001-damage-calc.md` 开头，有 4 个测试函数、每个 3 条以上断言，命名为 `test_damage_calc_zero_armor_returns_base_damage` 和 `test_damage_calc_max_crit_doubles_damage` 之类，并在注释中引用 GDD 的 `damage_formula`

**Input:** `/test-evidence-review production/epics/combat/story-001-damage-calc.md`

**Expected behavior:**
1. 单用户故事模式：技能读取该用户故事的 Test Evidence 和 Acceptance Criteria
2. Section 3 在 `tests/unit/combat/` 下找到测试文件
3. Section 4：断言覆盖率正常（每个函数 3 条以上）；「zero」和「max」用例覆盖数值标准；名称遵循 `test_[scenario]_[expected]`；公式被引用
4. 用户故事结论：**ADEQUATE**；整体结论 ADEQUATE；0 个 BLOCKING 项
5. 报告在对话中呈现，随后技能将「May I write this test evidence review to `production/qa/evidence-review-[date].md`?」作为可选步骤询问
6. Verdict: **COMPLETE**

**Assertions:**
- [ ] 对于该 Logic 用户故事，测试文件在 `tests/unit/combat/` 下被定位
- [ ] 断言覆盖率、边界情况、命名和公式可追溯性都分别报告
- [ ] 用户故事结论为 ADEQUATE
- [ ] 报告在可选的「May I write」提示之前展示
- [ ] 运行以 COMPLETE 结束

---

### Case 2: 空转且单薄的测试 — INCOMPLETE，含一个 BLOCKING 项

**Fixture:**
- `project.yaml`：`engine.name: godot`、`modes.rigor: standard`（因此 `qa.level: standard`——要求测试）；没有 `testing.strict` 块
- `production/epics/combat/story-002-crit-roll.md`（slug 为 `crit-roll`）：Story Type 为 Logic
- `tests/unit/combat/crit-roll_test.gd` 有 `func test_1()`（无断言）和 `func test_crit_roll_applies_multiplier()`（一条断言）

**Input:** `/test-evidence-review production/epics/combat/story-002-crit-roll.md`

**Expected behavior:**
1. 技能找到测试文件并统计每个函数的断言数
2. `test_1` 有 0 条断言 → 标记为 BLOCKING（空转通过，什么也没证明）；`test_1` 还被标记为通用命名问题
3. 只有一条断言的函数被指出可能过于单薄
4. 用户故事结论：**INCOMPLETE**
5. 后续事项：「These must be resolved before `/story-done` can mark the story Complete…」和「Consider running `/test-helpers [system]`…」
6. 由于发现 BLOCKING 项，运行以 **CONCERNS** 结束

**Assertions:**
- [ ] 零断言的测试函数被标记为 BLOCKING
- [ ] `test_1` 被标记为命名问题
- [ ] 用户故事结论为 INCOMPLETE，而不是 ADEQUATE
- [ ] 输出说明 BLOCKING 项必须在 `/story-done` 之前解决，并建议运行 `/test-helpers`
- [ ] 运行以 CONCERNS 结束
- [ ] 测试文件未被修改
- [ ] 变体——`project.yaml` 中设置 `testing.strict.logic: false` 时，零断言发现项为 ADVISORY，用户故事仍为 INCOMPLETE，且运行以 COMPLETE 结束

---

### Case 3: minimal 工作流下的空冲刺范围 — NOT ASSESSED，而不是干净报告

**Fixture:**
- `project.yaml`：`modes.rigor: minimal`（解析出的配置块显示 `workflow: minimal`）
- `production/sprints/` 不存在

**Input:** `/test-evidence-review sprint`

**Expected behavior:**
1. 冲刺模式未找到冲刺计划，因此范围中的用户故事数为零
2. 技能停止并报告 `NOT ASSESSED — no stories in scope`，点名冲刺范围和为空的 `production/sprints/` 路径
3. 由于工作流为 minimal（无冲刺），它路由到 `/test-evidence-review [epic-slug]`，而不是 `/sprint-plan new`
4. 技能不继续到 Section 3；不渲染摘要表，也不渲染「BLOCKING items: 0」行

**Assertions:**
- [ ] 结论为 NOT ASSESSED — no stories in scope
- [ ] 输出点名搜索了哪个范围以及哪个路径为空
- [ ] 在 minimal 工作流下路由为 `/test-evidence-review [epic-slug]`，而不是 `/sprint-plan new`
- [ ] 不产出显示「BLOCKING items: 0 / ADVISORY items: 0」的空报告

---

### Case 4: 用户故事类型未知 — 逐用户故事 NOT ASSESSED 抬升整体结论

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `production/epics/combat/` 包含 `story-001-damage-calc.md`（Logic，测试同 Case 1）和 `story-003-hit-feedback.md`，后者的 `## Test Evidence` 章节未给出 Story Type，也未给出证据路径
- 完整通读 `story-003-hit-feedback.md` 也无法确定类型

**Input:** `/test-evidence-review combat`

**Expected behavior:**
1. 系统模式对 `production/epics/combat/story-*.md` 执行 glob，找到两个用户故事
2. `story-001-damage-calc` 为 ADEQUATE
3. `story-003-hit-feedback` 为 **NOT ASSESSED**，并说明原因：无法确定用户故事类型，因此所需证据未知
4. 它不被报告为 MISSING
5. 整体结论：**NOT ASSESSED**——它优先于 ADEQUATE

**Assertions:**
- [ ] 未标类型的用户故事为 NOT ASSESSED，而不是 MISSING
- [ ] 为该用户故事说明 NOT ASSESSED 的原因（类型无法确定）
- [ ] 整体结论为 NOT ASSESSED，而不是 ADEQUATE
- [ ] 已标类型的用户故事仍被评审并报告为 ADEQUATE

---

### Case 5: 无保留截图的 Visual/Feel 证据，完整评审模式 — 无质量闸门

**Fixture:**
- `project.yaml`：`engine.name: godot`、`modes.review_mode: full`
- `production/epics/combat/story-004-hit-flash.md`（slug 为 `hit-flash`）：Story Type 为 Visual/Feel
- `production/qa/evidence/hit-flash-evidence.md` 引用每条验收标准，所有签署均已填写，日期晚于冲刺开始
- `production/qa/evidence/` 中不存在该用户故事的任何 `*.png`、`*.jpg` 或 `*.gif`

**Input:** `/test-evidence-review production/epics/combat/story-004-hit-flash.md`

**Expected behavior:**
1. Section 3 找到 `production/qa/evidence/hit-flash-evidence.md`
2. Section 5：标准关联和签署完整，但该用户故事没有保留任何图像
3. 文档描述了视觉检查却没有证据 → 用户故事结论 **INCOMPLETE**，标记为 BLOCKING
4. 无论评审模式如何，都不调用总监质量闸门
5. 证据文档未被编辑
6. 运行以 **CONCERNS** 结束

**Assertions:**
- [ ] 没有保留图像的 Visual/Feel 证据文档为 INCOMPLETE，即使签署完整
- [ ] 缺失的截图被列为 BLOCKING 问题
- [ ] 在任何评审模式下都不调用总监质量闸门
- [ ] 证据文档未被修改

---

### Case 6: 由其截图关闭的 UI 用户故事 — 无需签署

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `production/epics/ui/story-007-inventory-screen.md`（slug 为 `inventory-screen`）：Story Type 为 UI；其
  `## Test Evidence` 点名 `production/qa/evidence/inventory-screen-populated.png` 和
  `production/qa/evidence/inventory-screen-empty.png`——它所涉及的每种界面状态各一张
- 两张图片都存在，且日期晚于冲刺开始
- 不存在 `inventory-screen-evidence.md`、签署记录或走查日志

**Input:** `/test-evidence-review production/epics/ui/story-007-inventory-screen.md`

**Expected behavior:**
1. Section 3 在搜索前使用用户故事所述的两个路径
2. Section 5：UI 用户故事由其涉及的每个界面所保留的截图来关闭
3. 用户故事结论 **ADEQUATE**；运行以 **COMPLETE** 结束

**Assertions:**
- [ ] 先检查用户故事所述的证据路径，且两张图片都被找到
- [ ] 缺少签署不会使用户故事变为 INCOMPLETE——UI 用户故事不需要签署
- [ ] 不要求走查日志
- [ ] 用户故事结论为 ADEQUATE

---

### Case 7: Unity Logic 用户故事 — 证据位于所述引擎路径

**Fixture:**
- `project.yaml`：`engine.name: unity`
- `production/epics/inventory/story-003-stack-merge.md`：Story Type 为 Logic；其
  `## Test Evidence` 点名 `Assets/Tests/EditMode/InventoryTests.cs`
- 该文件存在，每条验收标准一个 `[Test]`（共 4 个），每个有 3 条或更多 `Assert.That` 调用，命名采用 `[Scenario]_[Expected]` 形式（`MergeStacks_FullStack_SpillsToNewSlot`），并覆盖空栈和最大栈用例
- 背包 GDD 没有 Formulas 章节，因此公式可追溯性不适用
- 任何地方都不存在名为 `stack-merge_test.*` 的文件，`tests/unit/` 也不存在

**Input:** `/test-evidence-review production/epics/inventory/story-003-stack-merge.md`

**Expected behavior:**
1. Section 3 在 `Assets/Tests/EditMode/` 下所述的路径找到测试
2. Section 4 评审其断言；用户故事结论 **ADEQUATE**

**Assertions:**
- [ ] 测试在所所述的 Unity 路径下被找到——用户故事不被报告为 MISSING
- [ ] 评审不要求 `[story-slug]_test.*` 命名或 `tests/unit/` 位置

---

### Case 8: Logic 用户故事无测试 — MISSING，且优先于 NOT ASSESSED

**Fixture:**
- `project.yaml`：`engine.name: godot`、`modes.rigor: standard`（因此 `qa.level: standard`——Logic 用户故事必须有测试）
- `production/epics/combat/` 包含 `story-003-hit-feedback.md`（未标 Story Type，同 Case 4）和 `story-005-knockback.md`：Story Type 为 Logic，未给出证据路径
- 不存在针对它的测试：`tests/unit/combat/` 不存在，也没有其他测试文件点名 slug `knockback` 或引用该用户故事

**Input:** `/test-evidence-review combat`

**Expected behavior:**
1. `story-005-knockback` 是 Logic 用户故事，因此需要单元测试；搜索单元测试根目录未找到
2. `story-005-knockback` 为 **MISSING**——评审已运行且什么也没找到——该缺口为 BLOCKING 项
3. `story-003-hit-feedback` 为 **NOT ASSESSED**（其类型无法确定），而不是 MISSING
4. 整体结论：**MISSING**——已知缺陷优先于无法评估的用户故事
5. 由于发现 BLOCKING 项，运行以 **CONCERNS** 结束

**Assertions:**
- [ ] 没有测试文件的 Logic 用户故事为 MISSING，而不是 NOT ASSESSED
- [ ] 未标类型的用户故事为 NOT ASSESSED，而不是 MISSING——两者被区分开
- [ ] 整体结论为 MISSING，而不是 NOT ASSESSED
- [ ] 缺失的测试被列为 BLOCKING，且运行以 CONCERNS 结束

---

### Case 9: `qa.level: minimal` — 无测试的 Logic 用户故事为 WAIVED；UI 截屏则不是

**Fixture:**
- `project.yaml`：`engine.name: godot`，没有 `modes` 块（因此 `qa.level: minimal`——测试被豁免）
- `production/epics/combat/` 包含 `story-005-knockback.md`（Logic，任何地方都没有测试，同 Case 8）和 `story-008-pause-menu.md`（UI，`production/qa/evidence/` 中没有为其保留图像）

**Input:** `/test-evidence-review combat`

**Expected behavior:**
1. `story-005-knockback` 为 **WAIVED (qa.level: minimal)**——而不是 MISSING——且不产生 BLOCKING 项
2. `story-008-pause-menu` 为 **MISSING** 且 BLOCKING——UI 用户故事所需的保留截图永远不会被豁免
3. 整体结论：**MISSING**；报告头部显示 `qa.level: minimal`
4. 仅因该 UI 用户故事，运行以 **CONCERNS** 结束
5. 变体——没有该 UI 用户故事时，整体结论为 **WAIVED**，BLOCKING 项为 0，运行以 **COMPLETE** 结束

**Assertions:**
- [ ] 无测试的 Logic 用户故事为 WAIVED (qa.level: minimal)，而不是 MISSING，也不列为 BLOCKING
- [ ] 无截图的 UI 用户故事在 `qa.level: minimal` 下仍为 MISSING 且 BLOCKING
- [ ] 被豁免的用户故事在报告中被点名说明已豁免，而不是从报告中删除
- [ ] 变体：全部豁免的范围显示 WAIVED，且没有「must be resolved before `/story-done`」提示

---

## Protocol Compliance

- [ ] 用有针对性的 `## Test Evidence` / `## Acceptance Criteria` grep 收集 Story Type、证据路径和验收标准，仅在用户故事的 Test Evidence 章节缺失或含糊时才完整通读
- [ ] 空范围以 `NOT ASSESSED — no stories in scope` 停止，点名该范围并路由到后续步骤
- [ ] 每个用户故事得到 ADEQUATE、INCOMPLETE、MISSING 或 NOT ASSESSED，且 NOT ASSESSED 的用户故事说明其原因
- [ ] 整体结论为最差的用户故事结论；NOT ASSESSED 优先于 ADEQUATE，但不优先于 INCOMPLETE 或 MISSING；WAIVED 低于 ADEQUATE
- [ ] 在 `qa.level: minimal` 下，没有测试证据的 Logic、Integration 或 Config/Data 用户故事为 WAIVED，绝不是 MISSING 或 BLOCKING；Visual/Feel 和 UI 证据永远不会被豁免
- [ ] 按用户故事类型的 BLOCKING 与 ADVISORY 来自解析出的配置块中的 `testing.strict.<type>`，回退到适用于所有类型的纯布尔 `testing.strict` 旧值，再回退到 `coding-standards.md` 默认值
- [ ] 在针对 `production/qa/evidence-review-[date].md` 的可选「May I write」之前呈现报告
- [ ] 不修改测试文件或证据文档
- [ ] 不调用任何总监质量闸门
- [ ] 以 COMPLETE 结束，或在发现 BLOCKING 项时以 CONCERNS 结束——但空范围除外，它在任何报告之前以 `NOT ASSESSED — no stories in scope` 停止（Case 3）

---

## Coverage Notes

- Integration 用户故事（`production/qa/playtests/` 中的试玩测试记录）和 Config/Data 用户故事（`production/qa/smoke-*.md`）此处未测试。
- 无参数路径（技能询问要评审哪个范围）未测试。
- POTENTIALLY STALE 时效性标记未单独测试。
