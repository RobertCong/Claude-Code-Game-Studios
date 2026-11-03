# /adopt — Phase 7: 提供首个行动

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 7: 提供首个行动

写入计划之后，不要就此停止。挑选单个最高优先级的缺口，
并使用 `AskUserQuestion` 主动提出立即处理它。选择第一个
适用的分支：

**如果 Phase 2g 发现一个需要迁移的 v1.0 项目：** 提供该处描述的
转换器运行 — 报告试运行列出的内容并询问“我可以运行
转换器吗？它会写入 `project.yaml` 和 `production/migration-report.md`。”
其他每个修复都通过它读取配置，因此它排在最前。

**如果 systems-index.md 中存在带括号的状态值：**
使用 `AskUserQuestion`：
- “最紧急的修复是 `systems-index.md` — [N] 行带有带括号的状态
  值（例如 `Needs Revision (see notes)`），它们现在就破坏了 /gate-check、
  /create-stories 和 /architecture-review。我可以在原处修复这些。”
  - “现在修复 — 编辑 systems-index.md”
  - “我自己修复”
  - “完成 — 把计划留给我就好”

**如果 ADR 缺少 `## Status`（且没有带括号的问题）：**
使用 `AskUserQuestion`：
- “最紧急的修复是为 [N] 个 ADR 添加 `## Status`：[列出文件名]。
  没有它，/story-readiness 会静默通过所有 ADR 检查。从
  [第一个受影响的文件名] 开始吗？”
  - “是 — 现在改造 [第一个受影响的文件名]”
  - “逐个改造全部 [N] 个 ADR”
  - “我自己处理 ADR”

**如果 GDD 缺少 Acceptance Criteria（且上述没有阻塞性问题）：**
使用 `AskUserQuestion`：
- “最紧急的缺口是 [N] 份 GDD 缺少 Acceptance Criteria：
  [列出文件名]。没有它们，/create-stories 无法生成用户故事。
  从 [最高优先级的 GDD 文件名] 开始吗？”
  - “是 — 现在为 [GDD 文件名] 添加 Acceptance Criteria”
  - “逐个处理全部 [N] 份 GDD”
  - “我自己处理 GDD”

**否则，如果仍存在任何 BLOCKING 或 HIGH 缺口**（上述分支均未涉及的 —
例如缺少 TR 注册表）：
使用 `AskUserQuestion`：
- “最紧急的剩余缺口是 [计划中的第一个 BLOCKING 或 HIGH 项] —
  [用一行说明它破坏了什么]。现在开始处理吗？”
  - “是 — 开始处理 [item]”
  - “先给我看那个计划条目”
  - “完成 — 把计划留给我就好”

**如果不存在 BLOCKING 或 HIGH 缺口：**
使用 `AskUserQuestion`：
- “没有阻塞性缺口 — 这个项目已兼容模板。接下来做什么？”
  - “带我过一遍中优先级的改进项”
  - “运行 /project-stage-detect 做更全面的健康检查”
  - “完成 — 我会按自己的节奏处理计划”

> **采纳计划已保存到 `docs/adoption-plan-[date].md`。** 随时重新运行 `/adopt`，以便在你完成过程中复查剩余缺口。

---
