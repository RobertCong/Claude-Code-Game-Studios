# /adopt — Phase 5: 呈现摘要并询问是否写入

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 5: 呈现摘要并询问是否写入

在写入前呈现一份精简摘要：

```
## Adoption Audit Summary
Phase detected: [phase]
Engine: [configured / NOT CONFIGURED]
GDDs audited: [N] ([X] fully compliant, [Y] with gaps)
ADRs audited: [N] ([X] fully compliant, [Y] with gaps)
Stories audited: [N]

Gap counts:
  BLOCKING: [N] — template skills will malfunction without these fixes
  HIGH:     [N] — unsafe to run /create-stories or /story-readiness
  MEDIUM:   [N] — quality degradation
  LOW:      [N] — optional improvements

Estimated remediation: [X blocking items × ~Y min each = roughly Z hours]
```

在询问是否写入之前，展示一份**缺口预览**：
- 将每个 BLOCKING 缺口列为一行要点，描述实际问题
  （例如 `systems-index.md: 3 rows have parenthetical status values`、
  `adr-0002.md: missing ## Status section`）。不显示数量 — 展示实际条目。
- HIGH / MEDIUM / LOW 仅显示数量（例如 `HIGH: 4, MEDIUM: 2, LOW: 1`）。

这能让用户在决定写入文件之前有足够的上下文来判断范围。

如果 Phase 1 检测到先前的采纳计划，添加一条说明：
> “已有一份计划位于 `docs/adoption-plan-[prior-date].md`。新计划将
> 反映当前项目状态 — 它不会与先前的运行做差异比较。”

使用 `AskUserQuestion`：
- “准备好写入迁移计划了吗？”
  - “是 — 写入 `docs/adoption-plan-[date].md`”
  - “先给我看完整计划预览（暂不写入）”
  - “取消 — 我自行处理迁移”

如果用户选择“先给我看完整计划预览”，以围栏 markdown 代码块
输出完整计划。然后用同样的三个选项再次询问。

---
