# Phase 5: QA 主管评审（QL-STORY-READY）

仅当 `review_gate` 行显示 `skill-gates=run`（`review_mode: full`）时阅读。

把评审交给 `qa-lead` agent，每个故事一次，使用闸门
**QL-STORY-READY**。该 agent 读取自己的闸门文件；不要在这里读取它。

简报：
- **目标：** 判断本故事的验收标准是否足够可测试，能够据此
  实现。
- **交给它：** 故事路径；其类型（Logic / Integration / Visual/Feel / UI /
  Config/Data），闸门据此分支；每项验收标准，逐字；它覆盖的
  需求（TR-ID 和文本）；每个依赖及其状态
  （存在、Draft、缺失）；本次运行的结论。
- **返回：** ADEQUATE、带列表的 GAPS、带列表的 INADEQUATE，或 NOT
  ASSESSED 并点名缺失的输入。
- **边界：** 它读取故事和简报点名的文件；它不编辑
  任何内容。

对其报告采取行动：

- **ADEQUATE**：故事通过。
- **GAPS**：展示缺口，然后询问：“How do you want to handle these?” 选项：
  Draft the fixes / Accept and go on / Discuss further。
- **INADEQUATE**：故事不是 READY。结论至少变为 NEEDS WORK
  （BLOCKED 保持 BLOCKED）。列出缺口，重述结论，然后询问是否
  起草修复或仍然继续。如果用户继续，结论保持不变，报告说明
  “proceeding despite QL-STORY-READY: INADEQUATE (user override)”。
  绝不允许静默变成 READY。
- **NOT ASSESSED**：闸门没有判断任何内容；绝不要把它读作 ADEQUATE。点名
  缺失的输入，并提出补充它并再次运行闸门。否则，READY
  结论会变为 NOT ASSESSED；NEEDS WORK 和 BLOCKED 保持不变。
