# /create-architecture — Phase 7 与 7b: 写入与签核

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 7: 写入主架构文档

**本文件包含：**

- Phase 7：主架构文档模板，然后是写入
- Phase 7b：技术总监签核 + 主程序员可行性评审：评审模式检查、呈现两项评估、记录签核

当所有章节都批准后，将完整文档写入
`docs/architecture/architecture.md`。

在更新场景中（Phase 0e 的 `[A]`，或某个聚焦领域参数），改为只写入选定的
章节，用 `Edit` 原地替换每个章节，并提升 `Version`；下面的
询问随后会点名这些章节和版本变更。

显示一段关于文档将包含什么（层级、模块、数据流、ADR 缺口）的摘要。然后使用 `AskUserQuestion`：
- "所有章节已批准。可以写入主架构文档吗？"
  - [A] 是 —— 现在写入 `docs/architecture/architecture.md`
  - [B] 先内联展示完整草案，然后再询问
  - [C] 还不是 —— 我还有更多变更要讨论

文档结构：

```markdown
# [Game Name] — Master Architecture

## Document Status
- Version: [N]
- Last Updated: [date]
- Engine: [name + version]
- GDDs Covered: [list]
- ADRs Referenced: [list]

## Engine Knowledge Gap Summary
[Condensed from Phase 0d inventory — HIGH/MEDIUM risk domains and their implications]

## System Layer Map
[From Phase 1]

## Module Ownership
[From Phase 2]

## Data Flow
[From Phase 3]

## API Boundaries
[From Phase 4]

## ADR Audit
[From Phase 5]

## Required ADRs
[From Phase 6]

## Architecture Principles
[3-5 key principles that govern all technical decisions for this project,
derived from the game concept, GDDs, and technical preferences]

## Open Questions
[Decisions deferred — must be resolved before the relevant layer is built]
```

---

## Phase 7b: 技术总监签核 + 主程序员可行性评审

在写入主架构文档之后，交接之前执行明确的签核。

**评审模式检查** —— 在生成任一质量闸门之前应用：
- `solo` → 两者都跳过。注明："TD-ARCHITECTURE and LP-FEASIBILITY skipped — Solo mode." 转到第 4 步，将两者记录为跳过，然后进入 Phase 8。
- `lean` → 两者都跳过（二者都不是 PHASE-GATE）。注明："TD-ARCHITECTURE and LP-FEASIBILITY skipped — Lean mode." 转到第 4 步，将两者记录为跳过，然后进入 Phase 8。
- `full` → 并行生成两者。

**第 1 步 —— 使用质量闸门 TD-ARCHITECTURE（`.trae/docs/director-gates/td-architecture.md`）通过 `Agent` 生成 `technical-director`：**

传入：架构文档路径（`docs/architecture/architecture.md`）、技术需求基线（TR-ID 与数量）、带状态的 ADR 列表，以及 Phase 0d 的引擎知识缺口清单。在等待任一结果之前，先发出此调用和第 2 步的调用。

**第 2 步 —— 使用质量闸门 LP-FEASIBILITY（`.trae/docs/director-gates/lp-feasibility.md`）通过 `Agent` 生成 `lead-programmer`：**

传入：架构文档路径、技术需求基线摘要、ADR 列表。

**第 3 步 —— 向用户呈现两项评估：**

并排展示 TD-ARCHITECTURE 结论（APPROVE / CONCERNS / REJECT）和 LP-FEASIBILITY 结论（FEASIBLE / CONCERNS / INFEASIBLE）。

使用 `AskUserQuestion` —— "技术总监和主程序员已评审架构。你希望如何继续？"
选项：`接受 —— 进入交接` / `先修订被标出的条目` / `讨论具体关注项`。
如果任一结论为 REJECT 或 INFEASIBLE，则不要提供 `接受` —— 先修订（或讨论）阻塞项。
`先修订被标出的条目` 会重新起草每个被标出的章节，并按 Phase 1–4 的方式展示以供批准；修订后的文档随后通过 Phase 7 的询问一次性写入，第 4 步记录 `REVISED after [verdict]`。
`NOT ASSESSED` 回答绝不被记录为 `APPROVE` 或 `FEASIBLE`：第 4 步会连同缺失的输入一起记录它（`director-gates.md`）。

**第 4 步 —— 在架构文档中记录签核：**

更新 Document Status 章节：
```
- TD-ARCHITECTURE: [date] — APPROVE / CONCERNS (accepted) / REVISED after CONCERNS / REVISED after REJECT / NOT ASSESSED — [missing input] / skipped — [mode] mode
- LP-FEASIBILITY: [date] — FEASIBLE / CONCERNS (accepted) / REVISED after CONCERNS / REVISED after INFEASIBLE / NOT ASSESSED — [missing input] / skipped — [mode] mode
```

内联展示提议的 Document Status 块，然后使用 `AskUserQuestion`：
- "可以将签核结果更新到 Document Status 章节吗？"
  - [A] 是 —— 应用到 `docs/architecture/architecture.md`
  - [B] 还不是 —— 我想先重新审视这些关注项

---
