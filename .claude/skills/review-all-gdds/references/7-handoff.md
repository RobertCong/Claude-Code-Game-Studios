# /review-all-gdds — Phase 7: 交接

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 7: 交接

在所有文件写入完成之后，使用 `AskUserQuestion` 提供收尾组件。

在构建选项之前，检查项目状态：
- 是否有任何 Warning 级别的项是简单的编辑（标记为 "30-second edit"、"brief addition" 或类似）？→ 提供就地快速修复选项
- 是否有任何 GDD 在"Flagged for Revision"表中？→ 为每个提供 /design-review 选项
- 读取 systems-index.md 中下一个 Status 为 `Not Started` 的系统 → 提供 /design-system 选项
- 结论是否为 PASS 或 CONCERNS，且本次评审运行了两轮？→ 提供 /gate-check 或 /create-architecture。聚焦运行（`consistency` 或 `design-theory`）只检查了一轮，因此绝不提供这两者

动态构建选项列表 — 只包含适用的选项：

**选项池：**
- `[_] Apply quick fix: [W-XX description] in [gdd-name].md — [effort estimate]`（每个简单编辑型警告一个选项；仅限 Warning 级别，不含 Blocking）
- `[_] Run /design-review [flagged-gdd-path] — address flagged warnings`（每个被标记的 GDD 一个选项，若有）
- `[_] Run /design-system [next-system] — next in design order`（始终包含，写出实际的系统名）
- `[_] Run /create-architecture — begin architecture (verdict is PASS/CONCERNS)`（仅当结论为 PASS 或 CONCERNS 且本次评审运行了两轮时包含 — 绝不在 FAIL、NOT ASSESSED 或聚焦运行时包含）
- `[_] Run /gate-check — validate Systems Design phase gate`（若本次评审运行了两轮且结论为 PASS 则包含）
- `[_] Stop here`

仅对包含的选项分配字母 A、B、C…。将最能推进流水线的选项标记为 `(recommended)`。

在 collaborative 和 guided 模式下，绝不要以纯文本结束技能 — 始终以该组件收尾。在 autonomous 模式下，打印结论和建议的下一步，然后通过 `log_decision` 记录（不提供组件）。

---
