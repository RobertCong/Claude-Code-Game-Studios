# /review-all-gdds — Phase 6: 编写报告并标记 GDD

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 6: 编写报告并标记 GDD

使用 `AskUserQuestion` 请求写入权限：
- 提示："May I write this review to `design/gdd/gdd-cross-review-[date].md`?"
- 选项：`[A] Yes — write the report` / `[B] No — skip`

> **此处的 `[date]` 指 ISO 8601 — `YYYY-MM-DD`，例如
> `gdd-cross-review-2026-08-19.md`。这不是风格偏好。**
> `.claude/scripts/review-scope.sh` 用 `sort | tail -1` 选取上一次评审，
> 因此只有 ISO 日期下字典序才等于时间序。
> 若写成 `aug-19-2026` 或 `19-08-2026`，选中的基准文件就是错的，
> 变更集合会基于它计算，而自真正上一次评审以来被修改的 GDD
> 会悄悄逃过下一次评审。这正是该脚本顶部记录的三处修复
> 所要防止的静默逃逸失效。

如果有任何 GDD 被标记为需要修订，使用第二次 `AskUserQuestion`：
- 提示："Should I update the systems index to mark these GDDs as needing revision? ([list of flagged GDDs])"
- 选项：`[A] Yes — update systems index` / `[B] No — leave as-is`
- 若选是：把 systems-index.md 中每个被标记 GDD 的 Status 字段更新为 "Needs Revision"。
  （不要给状态值追加括号说明 — 其他技能按精确字符串匹配 "Needs Revision"，
  括号说明会破坏该匹配。）

### 会话状态更新

在编写报告（以及若获批准则更新系统索引）之后，静默追加到 `production/session-state/active.md`：

    ## Session Extract — /review-all-gdds [date]
    - Verdict: [PASS / NOT ASSESSED / CONCERNS / FAIL]
    - GDDs reviewed: [N of M present]
    - Phases not run: [names, or "None"]
    - Flagged for revision: [comma-separated list, or "None"]
    - Blocking issues: [N — brief one-line descriptions, or "None"]
    - Recommended next: [the Phase 7 handoff action, condensed to one line]
    - Report: design/gdd/gdd-cross-review-[date].md   ← only if user approved the write
    - Report: (not written — user declined at [date])  ← only if user declined the write

根据用户对 Phase 6 写入权限组件的回应，使用相应的那一行。

如果 `active.md` 不存在，则以该块作为初始内容创建它。在对话中确认："Session state updated."

---
