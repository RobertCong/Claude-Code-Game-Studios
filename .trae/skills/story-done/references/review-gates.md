# Phase 6: review 模式为 full 时的评审闸门

仅当 `review_gate` 行显示 `skill-gates=run` 时读取。在 Phase 7 报告之前运行两个闸门。每个代理读取各自的闸门文件；不要在此处读取它。

## QL-TEST-COVERAGE

在 `qa.level: minimal` 下跳过它（注明 `QL-TEST-COVERAGE skipped — qa.level minimal`），对 Config/Data 用户故事也跳过（没有代码测试）。

将评审交给 `qa-lead` 代理，闸门为 **QL-TEST-COVERAGE**。简报：

- **目标：** 判断用户故事的测试是否覆盖了所规定的内容，而不仅仅是文件是否存在。
- **提供给它：** 用户故事路径与类型；Phase 4 找到的测试文件（确切路径，或"none found"）；用户故事的 `## QA Test Cases` 和 `## Acceptance Criteria`；该系统 GDD 的验收标准和边界情况，或"no GDD for this system"（在 `workflow: minimal` 下，用户故事自己的标准即为规格）。
- **返回：** ADEQUATE、GAPS、INADEQUATE，或指出缺失输入的 NOT ASSESSED，并列出缺口。
- **边界：** 不写入任何文件。

根据结论采取行动：

- **ADEQUATE：** 继续。
- **GAPS：** ADVISORY — "QA lead found coverage gaps: [list]. The story can close; address them in a follow-up story."
- **INADEQUATE：** BLOCKING — "critical logic is untested: [list]."
- **NOT ASSESSED：** 绝不视为 ADEQUATE。补充输入后再次运行，或将其带入结论，此时用户故事最多停留在 NOT ASSESSED。

## LP-CODE-REVIEW

尚无实现文件：跳过它，注明 `LP-CODE-REVIEW skipped — no implementation files found`，Reviewed by 为 `self, no independent review`。

将评审交给 `lead-programmer` 代理，闸门为 **LP-CODE-REVIEW**。简报：

- **目标：** 对照用户故事的 GDD 章节和所管辖的 ADR 评审其实现。
- **提供给它：** 实现文件路径、用户故事路径、GDD 路径与章节、ADR 路径。它按章节读取 GDD 和 ADR，绝不整篇读取。
- **返回：** APPROVE、CONCERNS、REJECT，或指出缺失输入的 NOT ASSESSED。
- **边界：** 不编辑任何文件。

根据结论采取行动：

- **APPROVE：** Reviewed by 为 `lead-programmer`。
- **CONCERNS：** 询问："The lead programmer raised concerns. How do you want to go on?" 选项：Revise the flagged issues / Accept and go on / Discuss further。
- **REJECT：** 在问题修复之前不给出 COMPLETE 结论。
- **NOT ASSESSED：** 绝不视为 APPROVE。补充输入后再次运行，或将其带入结论，此时用户故事最多停留在 NOT ASSESSED。
