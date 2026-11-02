# Skill Test Spec: /[skill-name]

## Skill Summary

[用一段话描述该技能做什么、接受哪些输入、产出什么输出。]

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] Frontmatter 包含所有必填字段（`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`）
- [ ] 找到 2 个及以上 phase 标题
- [ ] 包含该技能的结论关键词——即 `/skill-test static` 检查项 3 所接受的任意一种（gate 或 review 结论、go/no-go 结论，或严重程度等级），并在任何依赖该结论之处加上 `NOT ASSESSED`；若该技能输出的是产出物而非判断，则无需任何结论词
- [ ] 若 `allowed-tools` 包含 Write/Edit：存在 `"May I write"` 表述
- [ ] 结尾存在下一步交接章节

---

## Director Gate Checks

[描述该技能会触发哪些总监质量闸门（如有），以及在何种评审模式条件下触发。]

- **Full mode**: [触发的闸门——例如 CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE]
- **Lean mode**: [仅 phase 闸门——对 `/gate-check` 而言，即由 `modes.workflow` 设定的闸门组合（`minimal` 时仅 PR，`standard` 时 TD + PR，`full` 时全部四个）；其他技能跳过其非 phase 闸门，每一处均标注 `[GATE-ID] skipped — Lean mode`]
- **Solo mode**: [不触发任何闸门——技能在没有总监评审的情况下运行；每次跳过均有标注，例如 `[GATE-ID] skipped — Solo mode`]
- **N/A**: [若该技能从不触发闸门，说明原因]

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且不含
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — [brief name]

**Fixture**（假定的项目状态）：
- [文件/条件 1]
- [文件/条件 2]

**Expected behavior**：
1. [步骤 1]
2. [步骤 2]
3. [步骤 3]

**Assertions**：
- [ ] [断言 1]
- [ ] [断言 2]
- [ ] [断言 3]

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 2: Failure / Blocked — [brief name]

**Fixture**：
- [缺失或无效的条件]

**Expected behavior**：
1. [技能检测到问题]
2. [技能报告 FAIL/BLOCKED]
3. [技能不继续执行]

**Assertions**：
- [ ] 技能在产出产出物之前停止，并报告 BLOCKED 或 NOT ASSESSED，同时指明缺失的输入
- [ ] 显示正确的错误/阻塞消息
- [ ] 未经用户批准不写入任何文件

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 3: Mode Variant — [brief name]

**Fixture**：
- [标准项目状态]
- [设置特定的模式或标志]

**Expected behavior**：
1. [因模式不同，行为与 happy path 不同]

**Assertions**：
- [ ] [模式相关的断言]
- [ ] [输出与 Case 1 正确地区分]

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 4: Edge Case — [brief name]

**Fixture**：
- [非常规或边界条件]

**Expected behavior**：
1. [技能优雅处理]

**Assertions**：
- [ ] [边缘情况处理不崩溃、无静默失败]
- [ ] [正确的输出或消息]

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 5: Director Gate — [brief name]

**Fixture**：
- [会触发闸门检查的项目状态]
- Review mode: [full | lean | solo]

**Expected behavior**：
1. [闸门根据模式触发/不触发]
2. [正确地派生或跳过总监代理]

**Assertions**：
- [ ] Full mode 下：[具体闸门被派生]
- [ ] Lean mode 下：[仅 phase 闸门，宽度由 `modes.workflow` 设定——或每个闸门均跳过并标注 `[GATE-ID] skipped — Lean mode`]
- [ ] Solo mode 下：不派生任何总监闸门，且输出逐项指明每次跳过
- [ ] 技能不会在 CONCERNS、FAIL 或 NOT ASSESSED 结论之后自动推进

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 6: Could Not Assess — [brief name]

**Fixture**：
- [技能所需的某项输入缺失、不可读、为空或仅含占位符——或某项必须运行的检查无法运行]

**Expected behavior**：
1. [技能检测到其部分范围无法评估]
2. [技能报告 NOT ASSESSED，指明无法评估的内容及原因]
3. [技能不将未知情况判定为通过]

**Assertions**：
- [ ] 结论为 NOT ASSESSED——绝不用通过值——并指明缺失或不可读的输入
- [ ] 同时发现的失败仍按失败结论处理（NOT ASSESSED 高于通过值，低于失败值）
- [ ] 无法运行的检查在输出中被点名，而非被静默省略

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

## Protocol Compliance

- [ ] 在任何文件写入前使用 `"May I write"`（或本身为只读并跳过此项）
- [ ] 在请求批准前向用户呈现发现/草稿
- [ ] 以建议的下一步或后续行动结尾
- [ ] 未经用户批准不自动创建文件

---

## Coverage Notes

[覆盖率方面的任何缺口、已知但未测试的边缘情况，或需要实际运行技能才能验证的
条件。]
