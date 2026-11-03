---
name: regression-suite
description: "将测试覆盖率映射到 GDD 关键路径，找出缺少回归测试的已修复缺陷，标记新功能带来的覆盖率漂移。"
argument-hint: "[update | audit | report]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(bash "*/.claude/skills/regression-suite/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level,system_overrides`

已在上方解析 —— 直接使用。若无输出块 → 使用
`.claude/docs/config-resolution.md` 中的默认值。


# 回归套件（Regression Suite）

本技能确保每一次缺陷修复都有对应的测试作为支撑——该测试本应能捕获最初的缺陷——并确保随着游戏演进，回归套件保持最新。它还会检测：新增功能是否缺少相应的回归覆盖。

回归套件并不是一个新的测试类别——它是**一份经过策展的清单，列出 `tests/` 中已有测试**，这些测试共同覆盖了游戏的关键路径与已知故障点。本技能负责维护该清单。

**输出：** `tests/regression-suite.md`

**何时运行：**
- 修复缺陷后（确认已编写回归测试，或识别缺口）
- 阶段质量闸门（gate）之前——在 `qa.level: full` 下，`/gate-check` 要求存在回归套件
- 作为冲刺收尾的一部分，用于检测覆盖率漂移

---

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅大项询问 · 自主模式记录后继续；
`automation_always_ask` 类别始终提示）。

**工作流层级**：`modes.workflow` 按上方解析结果——除非显式设置，否则由 `modes.rigor` 提供——详见 `.claude/docs/workflow-modes.md`；在 `audit` 模式下，每读取一份 GDD 时都应考虑按系统查看 `workflow_overrides.system_overrides.<system>`。它决定是映射 GDD 关键路径，还是仅做冒烟级覆盖——见 Step 2c。

**`qa.level`**：决定是否生成套件。在 `minimal` 下，回归套件**不生成**（报告该情况并停止）；在 `standard` 下，于 Polish 阶段入口生成；在 `full` 下，于 Production 阶段入口生成。这是与 `workflow` 不同的维度。

## 1. 解析参数

**早期 `qa.level` 守卫（已在上方解析）：** 若 `qa.level: minimal`，回归套件**不生成**——报告"在 qa.level minimal 下不生成回归套件"，并在所有模式（`update` / `audit` / `report`）下**在此停止，先于任何扫描**。这是 `qa.level` 维度；它与 Step 2c 中 `workflow` 层级的 `minimal` 分支不同（后者只改变关键路径的*来源*，不改变套件*是否*运行）。不要因为 `qa.level` 而进入 Step 2c 的 `minimal` 分支。本次停止的结论为 **NOT ASSESSED**（Section 7）——该层级不要求测试，且未扫描任何内容。

**模式：**
- `/regression-suite update` —— 扫描本冲刺新的缺陷修复，检查是否存在回归测试；将新测试加入套件清单
- `/regression-suite audit` —— 对所有 GDD 关键路径与现有测试覆盖做全量审计；标记没有回归测试的路径
- `/regression-suite report` —— 只读状态报告（不写入）；适合冲刺评审
- 无参数 —— 若明确有活跃冲刺（存在冲刺计划且包含进行中的用户故事），运行 `update`。若不明确或未检测到活跃冲刺，使用 `AskUserQuestion`：
  - 提示："未指定子命令。你想运行哪个模式？"
  - 选项：
    - `[A] update —— 扫描本冲刺新的缺陷修复并补上缺失的回归测试`
    - `[B] audit —— 对所有 GDD 关键路径与现有测试覆盖做全量审计`
    - `[C] report —— 只读状态报告（不写入）`

---

## 2. 加载上下文

### Step 2a —— 加载现有回归套件

若存在 `tests/regression-suite.md` 则读取。提取：
- 已登记的回归测试总数
- 最后更新日期
- 任何标记为 `STALE` 或 `QUARANTINED` 的测试

若不存在：记录"未找到回归套件——将创建一个。"

### Step 2b —— 加载测试清单

Glob 所有测试文件：
```
tests/unit/**/*_test.*
tests/integration/**/*_test.*
tests/regression/**/*
```

对每个文件，记录其所属系统（依据目录路径）与文件名。
除非需要进行名称到测试的映射，否则不要读取测试文件内容。

### Step 2c —— 加载 GDD 关键路径

针对 `audit` 模式：读取 `design/gdd/systems-index.md` 获取所有系统，然后按各系统的工作流层级（已在上方解析）限定扫描范围：
- **`full`** —— 读取 GDD，并从所有章节映射关键路径。
- **`standard`** —— 同上，但仅从必需章节（验收标准、边界情况，以及系统定义数值规则的公式）映射。通过 `system_overrides` 固定为更高层级的系统，按其更高层级映射。
- **`minimal`** —— **跳过 GDD 关键路径扫描**。改为读取 `production/qa/smoke-*.md` 中最新的冒烟检查报告，并将其覆盖的关键路径作为回归范围（Step 3 将覆盖率映射到这些冒烟路径，而非 GDD 验收标准）。若不存在冒烟报告，则停止，结论为：**NOT ASSESSED — no smoke report to take critical paths from**——在 minimal 下若没有冒烟报告，就没有关键路径来源；请先运行 `/smoke-check`。

（层级仅影响 `audit` 模式；`update` 与 `report` 模式与层级无关。）

按章节读取每份 GDD：用 Grep 工具查找需要的标题（pattern `^#`，content 模式），再用 offset 与 limit 读取相应范围。在 `full` 下即所有章节，需分段读取，因为整文件 Read 超过 40 KB 会被拒绝。

对每个在范围内的 MVP 层级系统的 GDD，提取：
- 验收标准（定义关键路径）
- 公式章节（公式必须有回归测试）
- 边界情况章节（已知边界情况应有回归测试）

针对 `update` 模式：跳过全量 GDD 扫描。改为读取当前冲刺计划与用户故事文件，找出本冲刺 Status: Complete 的用户故事。

### Step 2d —— 加载已关闭缺陷

Glob `production/qa/bugs/*.md`，筛选含 `Status: Closed` 或 `Status: Fixed` 字段的缺陷。记录：
- 缺陷所属的用户故事或系统
- 修复描述中是否提到回归测试

---

## 3. 映射覆盖率——关键路径

仅针对 `audit` 模式。（在 `minimal` 下，关键路径来自 Step 2c 识别的冒烟检查报告，而非 GDD 验收标准——将覆盖率映射到这些冒烟路径，并跳过下面的 GDD 标准循环。）

对每条 GDD 验收标准，判断是否存在测试：

1. 在 `tests/unit/[system]/` 与 `tests/integration/[system]/` 中 Grep 与该标准关键名词/动词相关的文件名与函数名
2. 分配覆盖状态：

| 状态 | 含义 |
|--------|---------|
| **COVERED** | 存在针对该标准逻辑的测试文件 |
| **PARTIAL** | 存在测试但未覆盖所有情况（例如仅覆盖正常路径） |
| **MISSING** | 未找到该关键路径的测试 |
| **EXEMPT** | 视觉/手感（Visual/Feel）或 UI 标准——按设计不可自动化 |

3. 将对应公式或状态机的 MISSING 项升级为 **HIGH PRIORITY** 缺口——这些是最可能的回归来源。

---

## 4. 映射覆盖率——已修复缺陷

对每个已关闭缺陷：

1. 从缺陷元数据中提取系统 slug
2. 在 `tests/unit/[system]/` 与 `tests/integration/[system]/` 中 Grep 引用该缺陷 ID 或特定故障场景的测试
3. 分配：
   - **HAS REGRESSION TEST** —— 找到可捕获该缺陷的测试
   - **MISSING REGRESSION TEST** —— 缺陷已修复，但没有测试防止其复发

对 MISSING REGRESSION TEST 项：
- 将其标记为回归缺口
- 建议测试文件路径：`tests/unit/[system]/[bug-slug]_regression_test.[ext]`
- 注明："没有这个测试，该缺陷可能在未来的冲刺中悄悄重现。"

---

## 5. 检测覆盖率漂移

当游戏在增长而回归套件没有同步增长时，就会发生覆盖率漂移。

检查漂移指标：
- 本冲刺完成的用户故事在 `tests/` 中没有对应的测试文件
- 自上次回归套件更新以来，`systems-index.md` 中新增了系统
- 自回归套件上次更新以来，GDD 章节被新增或修订
  （如可用，用 Grep 查看 GDD 文件的修改提示，或询问用户）
- `tests/regression-suite.md` 的最后更新日期与当前日期相比——若差距 > 2 个冲刺，标记为可能过期

---

## 6. 生成报告与套件清单

### 报告格式（对话中）

```
## Regression Suite Status

**Mode**: [update | audit | report]
**Existing registered tests**: [N]
**Test files scanned**: [N]

### Critical Path Coverage (audit mode only)
| System | Total ACs | Covered | Partial | Missing | Exempt |
|--------|-----------|---------|---------|---------|--------|
| [name] | [N] | [N] | [N] | [N] | [N] |

**Coverage rate (non-exempt)**: [N]%

### Bug Regression Coverage
| Bug ID | System | Severity | Has Regression Test? |
|--------|--------|----------|----------------------|
| BUG-NNNN | [system] | S[N] | YES / NO ⚠ |

**Bugs without regression tests**: [N]

### Coverage Drift Indicators
[List new systems or stories with no test coverage, or "None detected."]

### Recommended New Regression Tests
| Priority | System | Suggested Test File | Covers |
|----------|--------|---------------------|--------|
| HIGH | [system] | `tests/unit/[system]/[slug]_regression_test.[ext]` | BUG-NNNN / AC-[N] |
| MEDIUM | [system] | `tests/unit/[system]/[slug]_test.[ext]` | [criterion] |
```

### 套件清单格式（`tests/regression-suite.md`）

> **计算覆盖率之前，先检查分母。** 若 GDD glob 返回**零条关键路径**，或测试 glob 返回**零个测试文件**，不要输出百分比——报告
> `Coverage: NOT ASSESSED — [no GDDs found | no test files found]`，并说明哪一侧为空，以及由哪个技能产出（GDD 由 `/map-systems` 与
> `/design-system` 产出，测试脚手架由 `/test-setup` 产出）。
>
> 用空分母计算出的百分比不是低分；它根本不是一个数字。`0%` 读起来像"测过了，很糟"，`100%` 读起来像"测过了，完美"——两者都是对一次从未发生的比较所作的主张。这与 `/scope-check` 用同样措辞设下的 Phase 4 守卫是同一种缺陷：
> *"a percentage computed from no baseline items is not a small number; it is not
> a number."*

清单是一份策展索引——不是测试本身，而是一份登记表，说明发布前哪些测试应当始终通过：

```markdown
# Regression Suite Manifest

> Last Updated: [date]
> Total registered tests: [N]
> Coverage: [N]% of GDD critical paths

## How to run

[Engine-specific command to run all regression tests]

## Registered Regression Tests

### [System Name]

| Test File | Test Function (if known) | Covers | Added |
|-----------|--------------------------|--------|-------|
| `tests/unit/[system]/[file]_test.[ext]` | `test_[scenario]` | AC-N / BUG-NNNN | [date] |

## Known Gaps

Tests that should exist but don't yet:

| Priority | System | Suggested Path | Covers | Reason Not Yet Written |
|----------|--------|----------------|--------|------------------------|
| HIGH | [system] | `tests/unit/[system]/[path]` | BUG-NNNN | Bug fixed without test |

## Quarantined Tests

Tests that are flaky or disabled (do not run in CI):

| Test File | Function | Reason | Quarantined Since |
|-----------|----------|--------|-------------------|
| (none) | | | |
```

---

## 7. 写入输出

在 `update` 或 `audit` 模式下，询问："我可以把当前的回归套件清单写入/更新到
`tests/regression-suite.md` 吗？"

针对 `update` 模式：追加新条目；绝不删除已有条目
（使用 `Edit` 做定点插入）。
针对 `audit` 模式：用更新后的覆盖率数据重写完整清单。
针对 `report` 模式：不写入任何内容。

写入后（若已批准）：

- 对每个 HIGH 优先级缺口："考虑在下一个冲刺前创建缺失的回归测试。
  运行 `/test-helpers` 生成测试文件脚手架。"
- 若缺陷回归缺口 > 0："这些缺陷在没有回归测试的情况下可能悄悄重现。
  下一个冲刺应包含一个编写缺失测试的用户故事。"
- 若检测到覆盖率漂移："回归套件可能正在漂移。考虑
  在下一个冲刺边界运行 `/regression-suite audit`。"

在 `workflow: minimal` 下（没有冲刺），把上述三行中的"下一个冲刺"改为"下一个用户故事"。

结论，按首个匹配：
- **NOT ASSESSED** —— Section 1 中 `qa.level: minimal` 的停止："在 qa.level
  minimal 下不生成回归套件"。该层级不要求测试；未扫描或写入任何内容。
- **NOT ASSESSED** —— 上文的 `minimal` 停止：没有冒烟报告可作为关键路径来源；指出 `/smoke-check` 为修复方式。
- **NOT ASSESSED** —— 覆盖率为 `Coverage: NOT ASSESSED — [reason]`（无 GDD 或无
  测试文件）；说明原因。绝不在未计算的覆盖率数字上报告 COMPLETE。
- **BLOCKED** —— `update` 或 `audit` 模式且用户拒绝写入。
- **COMPLETE** —— `update` / `audit`：回归套件已更新；`report`：已展示覆盖率
  报告（report 模式不写入任何内容）。

---

## 协作协议（Collaborative Protocol）

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 与
`autonomous` 模式，参见 `.claude/docs/automation-modes.md`——以下规则描述的是协作模式的要求，而非普适行为。

- **未经用户明确批准，绝不从清单中删除已有回归测试**——删除一个刻意编写的测试，本身就是一种回归风险
- **缺口是建议性的，不是阻塞性的**——清晰呈现，但不阻止其他工作推进（除 `qa.level: full` 下阶段质量闸门（gate）要求回归套件外）
- **隔离（Quarantine）不是删除**——间歇性失败的测试应被隔离（在清单中注明），但不应删除；它们应由
  `/test-flakiness` 修复
- **写入前先询问**——创建或更新清单前始终确认
