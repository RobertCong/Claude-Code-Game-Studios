# Phase 4: 制作人评审（PR-EPIC）

仅当 `review_gate` 行写明 `skill-gates=run`（`review_mode: full`）时才读取。
在范围内每个史诗都定义之后、任何写入之前运行一次。代理读取其
自己的闸门文件；不要在这里读取它。

把评审交给 `producer` 代理，闸门为 **PR-EPIC**。简报：

- **目标：** 判断该层的史诗结构是否现实可交付。
- **提供给它：** Phase 3 中定义的每个史诗及其范围摘要和支配
  ADR 数量、正在处理的层、里程碑时间线和团队
  产能（来自 `production/milestones/` 和 `project.yaml` 的 `team.size`，或
  “none recorded”）。
- **返回：** REALISTIC、CONCERNS、UNREALISTIC，或 NOT ASSESSED 并点名缺失的
  输入，附原因。
- **边界：** 它不写任何文件。

根据判定采取行动：

- **REALISTIC：** 进入 Phase 5。
- **CONCERNS：** 询问“制作人对史诗结构提出了关注。你希望
  如何继续？”选项：Go on as planned — I accept the concerns / Revise the
  epic boundaries / Stop — I want to rethink the scope。修订：更改史诗，
  再次展示它们，并再次运行评审。停止：`Verdict: BLOCKED — user is
  rethinking the epic scope`。
- **UNREALISTIC：** 提议拆分范围过大的史诗或合并范围过小的史诗，
  展示修订后的史诗，并在写入前再次运行评审。
- **NOT ASSESSED：** 它不是 REALISTIC。点名缺失了什么，然后补充并
  再次运行；或者，当用户选择不补充而继续时，进入 Phase 5，并在回复和收尾块中
  声明 `PR-EPIC: NOT ASSESSED — [input]`。

在评审得出结论之前不写任何史诗。
