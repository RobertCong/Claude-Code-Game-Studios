# Phase 8: 存在冲刺计划时的下一个用户故事

仅当 `production/sprints/` 中有冲刺计划时读取。

1. 读取 `production/sprints/` 中最新的冲刺计划。
2. 找出处于 Ready 或 Not Started、未等待未完成用户故事、且位于 Must Have 或 Should Have 层级的用户故事。

```
### Next Up
The following stories are ready to pick up:
1. [Story name] — [one line] — Est: [estimate]
2. [Story name] — [one line] — Est: [estimate]

Run `/story-readiness [path]` to confirm a story is ready before starting.
```

**所有 Must Have 用户故事均为 Complete 或 Blocked：** 打印收尾序列。

```
### Sprint Close-Out Sequence
All Must Have stories are complete. QA sign-off is required before advancing.
1. `/smoke-check sprint` — the critical path still works end to end
2. `/team-qa sprint` — test case execution, bug triage, sign-off report
3. `/retrospective` — what went well, what didn't, action items
4. `/gate-check` — only when advancing a stage, after `/team-qa` returns
   APPROVED or APPROVED WITH CONDITIONS
5. `/sprint-plan new` — the next sprint
```

仍有未启动的 Should Have 用户故事：在序列旁列出它们，以便用户现在关闭冲刺或拉入更多工作。

**没有用户故事就绪、Must Have 用户故事仍在 In Progress：**"No more stories ready to start — [N] Must Have stories still in progress. Finish those before the sprint close-out."

检查点的 **Next step** 指明向用户展示的同一用户故事或步骤。
