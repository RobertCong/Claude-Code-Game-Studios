# Skill Test Spec: /propagate-design-change

## Skill Summary

`/propagate-design-change` 处理 GDD 修订向架构的级联传播。
给定一个变更后的 GDD 路径，它向 git 询问变更内容（`git diff HEAD`，然后是上一次
提交），总结变更的小节，检查实体注册表以确定需要复查的下游 GDD，然后找出所有
引用该 GDD 的 ADR —— 扫描 `## GDD Requirements Addressed` 表，并对 GDD 的
basename 做一次散文文本（prose）grep —— 且只读取该受影响集合。每个受影响的 ADR
被分类为 Still Valid / Needs Review / Likely Superseded，并在采取任何操作之前
显示完整的 Design Change Impact Report。

在 `full` 评审模式下，TD-CHANGE-IMPACT 质量闸门（technical-director）在解决
之前评审该报告；在 `lean`/`solo` 下则跳过并附注说明。随后用户逐 ADR 决定
（Mark Superseded / Update in place / Keep as-is / Skip），且每个文件变更 ——
ADR 状态行、可追溯性索引、
`docs/architecture/change-impact-[date]-[system].md` 报告 —— 都有各自的询问。
级联范围遵循变更系统的工作流层级（`full` 为所有 ADR；`standard` 为关键 ADR
加上引用该 GDD 的 ADR；`minimal` 不适用）。
结论：COMPLETE（已保存影响报告）或 BLOCKED（用户拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 对它变更的每个文件都包含 "May I" 写入前询问用语
- [ ] 结尾有下一步交接（`/architecture-decision`、`/architecture-review`）
- [ ] 说明在任何变更之前先显示影响报告
- [ ] 说明质量闸门 TD-CHANGE-IMPACT：full 下运行，lean/solo 下跳过

---

## Director Gate Checks

一个质量闸门：**TD-CHANGE-IMPACT**（`technical-director`，
`.claude/docs/director-gates/td-change-impact.md`），在呈现 Design Change
Impact Report 之后、逐 ADR 解决流程之前派发。

- `full` → 派发，携带完整影响报告（变更摘要、分类、建议操作）
- `lean` → 跳过；输出注明 "TD-CHANGE-IMPACT skipped — Lean mode."
- `solo` → 跳过；输出注明 "TD-CHANGE-IMPACT skipped — Solo mode."

结论处理：APPROVE → 解决流程；CONCERNS → `AskUserQuestion` 提供
`Revise the impact assessment` / `Accept with noted concerns` / `Discuss further`；
REJECT → 不进入解决流程；先重新分析影响；NOT ASSESSED [missing input] →
绝不当作 APPROVE 读取：补齐输入并重新运行质量闸门，或者继续运行并在报告和
结论行中注明 `TD-CHANGE-IMPACT: NOT ASSESSED — [input]`。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— GDD 公式变更影响两个引用 ADR 中的一个

**Fixture:**
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: lean`
- `design/gdd/combat.md` 在其 Formulas 小节中有一处未提交的伤害公式修改
- `docs/architecture/` 有 4 份 ADR；ADR-0003 和 ADR-0005 在
  `## GDD Requirements Addressed` 中列出 `combat.md`；ADR-0003 的决策假设了旧
  公式，ADR-0005 的决策不依赖它
- `docs/architecture/requirements-traceability.md` 存在

**Input:** `/propagate-design-change design/gdd/combat.md`

**Expected behavior:**
1. 校验文件存在；运行 `git diff HEAD -- design/gdd/combat.md`，并从
   差异块（hunk）中推导出变更的小节
2. 打印 Change Summary（已变更 / 未变更的小节、关键变更）
3. Glob 所有 ADR（N = 4），grep 需求表和 `combat` basename，并报告
   "Loaded 4 ADRs by scan. 2 reference combat.md (…)"
4. 读取 ADR-0003 和 ADR-0005（先用 `wc -c` 检查大小），将 ADR-0003 分类为
   Needs Review 或 Likely Superseded，ADR-0005 为 Still Valid
5. 呈现 Design Change Impact Report
6. 注明 "TD-CHANGE-IMPACT skipped — Lean mode."
7. 询问 "ADR-0003 ([title]) — [status]. What would you like to do?"，提供四个
   选项；不对 ADR-0005 发起解决询问
8. 询问 "May I update the traceability index?" 和 "May I write the change impact
   report to `docs/architecture/change-impact-[date]-combat.md`?"
9. 结论：COMPLETE —— 已保存变更影响报告

**Assertions:**
- [ ] 变更内容取自 `git diff`，而非完整读取两份文档
- [ ] 只有 2 份引用 ADR 被完整读取；另外 2 份不被描述为“已核实未受影响”
- [ ] 在任何解决询问或写入之前完整显示影响报告
- [ ] 对每个 Needs Review / Likely Superseded ADR 逐一发起解决询问，一次一个
- [ ] 每个文件变更（ADR 状态、可追溯性索引、影响报告）都有各自的询问
- [ ] 出现 "TD-CHANGE-IMPACT skipped — Lean mode."
- [ ] 写入影响报告后结论为 COMPLETE

---

### Case 2: 零匹配 —— "no impact" 与 "cannot trace"

**Fixture (tables present):**
- `project.yaml`：`modes.workflow: full`
- `design/gdd/combat.md` 有一处未提交的修改
- 3 份 ADR，每份都有 `## GDD Requirements Addressed` 小节，但表中和散文文本里
  都未提及 `combat.md`

**Input (both fixtures):** `/propagate-design-change design/gdd/combat.md`

**Expected behavior (tables present):**
1. 两次扫描都返回 0，N = 3
2. 针对 `## GDD Requirements Addressed` 的有匹配文件检查为非空
3. 报告 "No ADR references combat.md — no architecture impact."

**Fixture (tables absent):**
- 同样的 GDD 修改；3 份 ADR，均不含 `## GDD Requirements Addressed` 小节，
  也均未提及 `combat.md`

**Expected behavior (tables absent):**
1. 两次扫描都返回 0，N = 3；小节检查也为空
2. 报告 "3 ADRs found, none contains a 'GDD Requirements Addressed' section —
   traceability cannot be computed (a `gate-pre-production` blocker). Run
   `/architecture-decision retrofit [adr]`."

**Assertions:**
- [ ] 表格存在时，打印 "no architecture impact" 消息
- [ ] 表格缺失时，技能不报告 "no impact" —— 而是报告可追溯性无法计算，并点名 `/architecture-decision retrofit [adr]`，即该技能可解析的形式
- [ ] 两种 fixture 下都不发生逐 ADR 解决询问，也不编辑 ADR
- [ ] 未找到引用时，技能不报错、不崩溃

---

### Case 3: 边界情况 —— 有历史的 GDD 上差异为空

**Fixture:**
- `project.yaml`：`modes.workflow: full`
- `design/gdd/combat.md` 已提交，没有未提交的变更，且上一次提交未触及它

**Input:** `/propagate-design-change design/gdd/combat.md`

**Expected behavior:**
1. `git diff HEAD -- design/gdd/combat.md` 为空
2. `git diff HEAD~1 HEAD -- design/gdd/combat.md` 也为空
3. 报告 "no uncommitted or last-commit changes to `design/gdd/combat.md`"，并
   询问要传播哪个修订版本
4. 不报告 "no impact"，也不在选择修订版本之前扫描 ADR

**Assertions:**
- [ ] 两次 diff 都尝试，先工作区，再上一次提交
- [ ] 打印 "no uncommitted or last-commit changes" 报告
- [ ] 询问用户要传播哪个修订版本
- [ ] 空差异不被报告为 "no impact"

---

### Case 4: 边界情况 —— 未提供参数

**Fixture:**
- `design/gdd/` 中存在多个 GDD

**Input:** `/propagate-design-change`（无参数）

**Expected behavior:**
1. 技能检测到未提供参数
2. 技能报错："Usage: `/propagate-design-change design/gdd/[system].md`
   Provide the path to the GDD that was changed."
3. 不执行任何 diff、扫描或分析

**Assertions:**
- [ ] 未提供参数时，技能输出用法消息
- [ ] 用法示例显示 `design/gdd/[system].md` 路径格式
- [ ] 没有目标 GDD 时不执行任何 `git diff` 或 ADR 扫描
- [ ] 技能不会在没有用户输入的情况下静默选择一个 GDD

---

### Case 5: 总监质量闸门 —— full 模式下 TD-CHANGE-IMPACT 返回 CONCERNS

**Fixture:**
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: full`
- 一处 GDD 修改，使得一个引用 ADR 被分类为 Needs Review
- TD-CHANGE-IMPACT 返回 CONCERNS：第二份 ADR 被分类过低

**Input:** `/propagate-design-change design/gdd/[system].md`

**Expected behavior:**
1. 呈现 Design Change Impact Report
2. 通过 `Agent` 以质量闸门 TD-CHANGE-IMPACT 派发 `technical-director`，传入
   完整报告
3. 呈现 CONCERNS，点名被标记的 ADR
4. `AskUserQuestion`：`Revise the impact assessment` / `Accept with noted concerns`
   / `Discuss further`
5. 逐 ADR 解决流程仅在该答复之后开始

**Assertions:**
- [ ] TD-CHANGE-IMPACT 在显示影响报告之后、任何解决询问之前派发
- [ ] 质量闸门接收完整报告（变更摘要、分类、建议操作）
- [ ] CONCERNS 点名被标记的 ADR，并提供全部三个选项
- [ ] 在 CONCERNS 得到答复之前，不写入任何 ADR、可追溯性文件或报告文件
- [ ] `full` 模式下不出现 "TD-CHANGE-IMPACT skipped" 提示

---

### Case 6: 工作流层级 —— `minimal` 在级联前停止；`standard` 收窄范围

**Fixture (minimal):**
- `project.yaml` 未设置任何 `modes` 键 —— `modes.rigor` 默认为 `minimal`，因此
  工作流解析为 `minimal`
- `design/gdd/loot.md` 有一处未提交的修改

**Fixture (standard):**
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: solo`
- `design/gdd/loot.md` 有一处未提交的修改
- 4 份 ADR，按其 Engine Compatibility 的 `Layer`：ADR-0001（Foundation，事件总线，
  未提及 `loot.md`）、ADR-0002（Foundation，存档系统，在
  `## GDD Requirements Addressed` 中列出 `loot.md`）、ADR-0006（Feature，战利品表，
  仅在散文文本中提及 `loot.md`）、ADR-0007（Feature，敌人 AI，未提及）

**Input (both fixtures):** `/propagate-design-change design/gdd/loot.md`

**Expected behavior (minimal):**
1. diff 和 Change Summary 照常运行
2. 在 ADR 步骤："No ADR cascade at minimal workflow — design change recorded;
   no architecture impact analysis."，技能停止

**Expected behavior (standard):**
1. 范围内集合为 Foundation ADR 加上任何引用 `loot.md` 的 ADR：
   ADR-0001、ADR-0002 和 ADR-0006，因此 N = 3；ADR-0007 不在范围内
2. 报告 "Loaded 3 ADRs by scan. 2 reference loot.md (1 via requirements table,
   1 via prose reference only)."
3. 只完整读取 ADR-0002 和 ADR-0006；注明 "TD-CHANGE-IMPACT skipped — Solo mode."

**Assertions:**
- [ ] Minimal：不 Glob 也不读取任何 ADR，不派发或注明任何闸门，也不发起写入询问
- [ ] Standard：ADR-0007 不被计入或读取，且它和 ADR-0001 都不被描述为“已核实未受影响”
- [ ] Standard：ADR-0006 中仅散文文本的引用被 basename grep 捕获
- [ ] Standard：Foundation ADR 从 `**Layer**` 行找到（`Grep pattern="\*\*Layer\*\*" glob="docs/architecture/adr-*.md"`），而非从标题猜测
- [ ] 变体 —— ADR-0007 没有 `**Layer**` 行：它被视为关键（存疑时按关键处理）并加入范围内集合，因此 N = 4

---

## Protocol Compliance

- [ ] 在产出影响报告之前对 GDD 做 diff 并扫描 ADR
- [ ] 在任何解决询问之前完整显示影响报告
- [ ] 逐 ADR 询问解决方案 —— 绝不对整个集合只做一次决定
- [ ] 每个文件变更之前询问 "May I"；ADR 内容绝不被删除，只标记为 Superseded
- [ ] TD-CHANGE-IMPACT 在 `full` 下运行，在 `lean`/`solo` 下跳过并附具名说明
- [ ] 以与解决方案匹配的后续操作结尾（Superseded ADR 用 `/architecture-decision`，大量受影响时用 `/architecture-review`）

---

## Coverage Notes

- 在 `standard` 项目上通过 `system_overrides` 固定为 `minimal` 的系统
  （其变更为 N/A）未提供独立 fixture；Case 6 通过项目默认值达到 `minimal`。
- 通过 `design/registry/entities.yaml` 产生的下游 GDD 影响未单独做
  fixture 测试。
- 没有 git 历史的 GDD（"appears to be a new GDD, not a revision"）以及
  不存在的路径未单独测试。
- TD-CHANGE-IMPACT 的 APPROVE、REJECT 和 NOT ASSESSED 路径未单独测试。
- 用户故事和史诗不在本技能范围内 —— 它只向 ADR 和可追溯性索引级联。
