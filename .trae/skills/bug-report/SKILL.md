---
name: bug-report
description: "根据描述生成结构化缺陷报告，或分析代码中的潜在缺陷。包含复现步骤与严重程度。"
argument-hint: "[description] | analyze [path-to-file] | verify [BUG-ID] | close [BUG-ID]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

# 缺陷报告

**仅生成草稿。** 本技能把报告写入 `production/qa/bugs/`。当原因出在引擎、插件或第三方
代码中时，在 **Notes** 下为他们的缺陷跟踪器添加一份草稿，并就此停止：绝不在他们的仓库中
提交、创建或评论 issue 或 pull request。由用户自行提交。

## Phase 1: 解析参数

根据参数确定模式：

- 无关键字 → **描述模式**：根据提供的描述生成结构化缺陷报告
- `analyze [path]` → **分析模式**：读取目标文件并识别潜在缺陷
- `verify [BUG-ID]` → **验证模式**：确认所报告的修复确实解决了该缺陷
- `close [BUG-ID]` → **关闭模式**：把已验证的缺陷标记为已关闭，并附上解决记录

如果没有提供参数，先向用户询问缺陷描述再继续。

---

## Phase 2A: 描述模式

1. **解析描述**，提取关键信息：什么坏了、何时发生、如何复现，以及预期行为是什么。

2. **搜索代码库**，用 Grep/Glob 查找相关文件，补充背景（受影响的系统、可能的文件）。

3. **起草缺陷报告**：

```markdown
# Bug Report

## Summary
**Title**: [Concise, descriptive title]
**ID**: BUG-[NNNN]
**Severity**: [S1-Critical / S2-High / S3-Medium / S4-Low]
**Priority**: [P1-Fix this sprint / P2-Fix soon / P3-Backlog / P4-Won't fix]
**Status**: Open
**Reported**: [Date]
**Reporter**: [the reporter's name as the user gives it, else `—`; never an email address or account ID taken from the session]

## Classification
- **Category**: [Gameplay / UI / Audio / Visual / Performance / Crash / Network]
- **System**: [Which game system is affected — when the bug spans systems, the one whose code must change; the others go under Related systems]
- **Frequency**: [Always / Often (>50%) / Sometimes (10-50%) / Rare (<10%)]
- **Regression**: [Yes/No/Unknown -- was this working before?]

## Environment
- **Build**: [Version or commit hash]
- **Platform**: [OS, hardware if relevant]
- **Scene/Level**: [Where in the game]
- **Game State**: [Relevant state -- inventory, quest progress, etc.]

## Reproduction Steps
**Preconditions**: [Required state before starting]

1. [Exact step 1]
2. [Exact step 2]
3. [Exact step 3]

**Expected Result**: [What should happen]
**Actual Result**: [What actually happens]

## Technical Context
- **Likely affected files**: [List of files based on codebase search]
- **Related systems**: [What other systems might be involved]
- **Possible root cause**: [If identifiable from the description]

## Evidence
- **Logs**: [Relevant log output if available]
- **Visual**: [Description of visual evidence]

## Related Issues
- [Links to related bugs or design documents]

## Notes
[Any additional context or observations]
```

**Severity** 与 **Priority** 标签使用 `/bug-triage` 的 S、P 编号与名称，后者会从本文件中
解析出它们。`P4-Won't fix` 对应它的 `P4 — Won't fix / Deferred`（一种已接受的风险），而
不是愿望清单。如果你改动任一等级阶梯，也要同步修改 `.trae/skills/bug-triage/SKILL.md`。

---

## Phase 2B: 分析模式

1. **读取**参数中指定的**目标文件**。

2. **识别潜在缺陷**：空引用、差一错误（off-by-one）、竞态条件、未处理的边界情况、资源泄漏、
   错误的状态转换。

3. **对每个潜在缺陷**，使用上面的模板生成一份缺陷报告，并填入可能的触发场景与建议修复。

---

## Phase 2C: 验证模式

**按编号查找缺陷文件**，此处与关闭模式均如此：Glob `production/qa/bugs/BUG-*.md`，取编号
与 `[BUG-ID]` 匹配的文件，无论其补零位数如何 —— 一个较旧的三位数文件即使带 slug，也按
其编号查找。若无匹配，停止："`production/qa/bugs/` 中没有缺陷 [BUG-ID]。"Verdict：**BLOCKED**
—— 不存在该缺陷。

读取该文件。提取复现步骤与预期结果。

1. **重新执行复现步骤** —— 使用 Grep/Glob 检查根因代码路径是否仍按所述存在。若修复已移除或
   改变了它，记录该变化。
2. **运行相关测试** —— 如果缺陷所属系统在引擎测试根目录（`tests/` Godot，`Assets/Tests/`
   Unity，`Source/<Module>/Private/Tests/` Unreal —— 见 `.trae/docs/directory-structure.md`）
   中有测试文件，则通过 Bash 用 `project.yaml` 中的 `commands.test` 运行它；在运行器允许的
   情况下缩小到受影响的套件 —— 绝不要凭记忆编写运行器命令行，那会丢掉引擎所需的标志
   （gdUnit4 缺少 `--remote-debug tcp://127.0.0.1:0` 会挂起）—— 并报告通过/失败。
   `commands.test` 未设置 → 没有测试运行：指出未设置的键，继续第 3 步。
3. **检查回归** —— 在代码库中 grep 引发该缺陷的模式是否出现新的实例。
4. **人工验证** —— 当没有相关测试运行（没有测试覆盖该缺陷 —— 在 `qa.level` 豁免测试时这是
   常态 —— `commands.test` 未设置，或运行未完成），或缺陷类别为 Visual 或 UI（其外观没有
   自动化测试会检查）时，通过 `AskUserQuestion` 询问："你是否在带修复的构建上执行了
   [bug file] 中的复现步骤？是哪个构建？" ——
   `[No longer occurs]` / `[Still occurs]` / `[Not played yet]`。
   按用户给出的内容记录回答与构建；代码路径的变化绝不能当作他们的回答。
   **作为子 agent 运行？** `qa-lead` 会预加载本技能，而子 agent 没有 `AskUserQuestion`。
   在回复末尾以简短列表给出该问题及其三个选项，暂时不要给出结论：调用你的人会去询问用户，
   结论等待回答。

产出一项验证结论：

- **VERIFIED FIXED** —— 该缺陷在所有适用的检查下都已消失：任何相关测试都运行并通过，且
  在第 4 步被问到的场合，用户对某个具名构建回答了 `[No longer occurs]`。若未运行测试，
  那次试玩本身就是验证 —— 属于人工验证，如实记录为 `[user], manual, build [X]`。仅凭代码
  路径发生变化绝不算通过
- **STILL PRESENT** —— 相关测试在缺陷场景下失败，或用户回答了 `[Still occurs]`；修复未能
  解决该问题
- **CANNOT VERIFY** —— 第 4 步被回答为 `[Not played yet]`：指出缺失或无法运行的内容（没有
  相关测试、`commands.test` 未设置、运行未完成、Visual 或 UI 缺陷），并说明执行复现步骤即可
  定论 —— 试玩后再次运行 `/bug-report verify [BUG-ID]`

询问："我可以更新 `production/qa/bugs/[bug file]`，把 Status 设为 Verified Fixed / Still
Present / Cannot Verify 吗？" —— 指明上方找到的文件，无论其补零位数或 slug 如何。随 Status
一起，在其下写入一行 `**Verified by**:`：`[test file(s)] — ran and passed`，或人工验证时写
`[user], manual, build [X]`。

若为 STILL PRESENT：重新打开该缺陷，把 Status 设回 Open，并建议重新运行 `/hotfix [BUG-ID]`。

---

## Phase 2D: 关闭模式

读取缺陷文件，按验证模式中的方式根据编号查找。关闭前确认 Status 为 `Verified Fixed`。若
状态为其他值，停止："缺陷 [ID] 必须为 Verified Fixed 才能关闭。请先运行 `/bug-report verify [BUG-ID]`。"

展示下面的关闭记录与 Status 变更，然后询问："我可以更新 `production/qa/bugs/[bug file]`，
将其标记为 Closed 吗？"在得到肯定答复前不写入任何内容；若为否，停止 —— 该缺陷保持
Verified Fixed。

若同意，把关闭记录追加到缺陷文件：

```markdown
## Closure Record
**Closed**: [date]
**Resolution**: Fixed — [one-line description of what was changed]
**Fix commit / PR**: [if known]
**Verified by**: [the verify record's `**Verified by**:` line — the test that ran and passed, or "[user], manual, build [X]"]
**Closed by**: [user]
**Regression test**: [test file path, or "Manual verification" when verify recorded a manual play]
**Status**: Closed
```

然后更新顶层的 `**Status**:` 字段为 `**Status**: Closed`。

关闭后，检查 `production/qa/bug-triage-*.md` —— 如果该缺陷出现在某个未关闭的缺陷分诊报告中，
提示："缺陷 [ID] 在分诊报告中被引用。运行 `/bug-triage` 刷新未关闭缺陷计数。"

---

## Phase 3: 保存报告

向用户展示已完成的缺陷报告。

**先分配 ID** 再询问：Glob `production/qa/bugs/BUG-*.md`，取最大编号加 1，补零到四位
（无文件时为 `BUG-0001`）。一次运行中生成多份报告（分析模式）时，从该编号起连续分配，
每份一个 —— 绝不复用同一 ID。

询问："我可以把它写入 `production/qa/bugs/BUG-[NNNN].md` 吗？"若有多份报告，只问一次并
列出每个文件："我可以把这些写入 `production/qa/bugs/BUG-[NNNN].md`、`production/qa/bugs/BUG-[NNNN+1].md`、…… 吗？"

若同意，写入文件，必要时创建目录。Verdict：**COMPLETE** —— 缺陷报告已归档。

若不同意，就此停止。Verdict：**BLOCKED** —— 用户拒绝写入。

---

## Phase 4: 后续步骤

保存后，根据模式给出建议：

**归档之后（描述/分析模式）：**
- 运行 `/bug-triage`，与现有未关闭缺陷一起排定优先级
- 若为 S1 或 S2：运行 `/hotfix [BUG-ID]` 进入紧急修复工作流

**修复缺陷之后（开发者确认修复已合入）：**
- 运行 `/bug-report verify [BUG-ID]` —— 在关闭前确认修复确实有效
- 未经验证绝不把缺陷标记为已关闭 —— 无法通过验证的修复仍然算 Open

**验证返回 CANNOT VERIFY 之后：**
- 在带修复的构建上执行复现步骤，然后再次运行 `/bug-report verify [BUG-ID]` 并回答其问题

**验证返回 VERIFIED FIXED 之后：**
- 运行 `/bug-report close [BUG-ID]` —— 写入关闭记录并更新状态
- 运行 `/bug-triage` 刷新未关闭缺陷计数，并将其从活动列表中移除