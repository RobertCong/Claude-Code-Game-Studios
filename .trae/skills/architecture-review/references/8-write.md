# /architecture-review — Phase 8: 写入并更新可追溯性索引

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 8: 写入并更新可追溯性索引

**本文件包含：**

- 回执最后采集
- RTM 输出（仅 rtm 模式）
- TR 注册表更新
- 反思日志更新
- 会话状态更新

使用 `AskUserQuestion` 获取写入批准：
- "评审完成。你想写入什么？"
  - [A] Write all three files — review report (`docs/architecture/architecture-review-[date].md`), traceability index (`docs/architecture/requirements-traceability.md`), TR registry (`docs/architecture/tr-registry.yaml`)
  - [B] Write review report only — `docs/architecture/architecture-review-[date].md`
  - [C] Don't write anything yet — I need to review the findings first

**`single-gdd` 运行只看到一个系统**，因此在该模式下 [A] 会写入评审报告，以及另外
两个文件中仅属于该系统的部分。请在选项中说明这一点："…update [system]'s rows in the
traceability index and its TR registry entries"。在 `requirements-traceability.md` 中，
替换该系统的矩阵行并重新计算 Coverage Summary，其他所有系统的行保持原样。若索引尚不
存在，只写入报告和注册表，并说明完整评审会创建索引。在 TR 注册表中，只追加、更新和
弃用该系统的条目：另一个系统的 GDD 未被读取，因此绝不提议弃用它的条目。

当 Phase 4 发现 🔴 冲突且 `docs/consistency-failures.md` 存在时，也在选项 [A] 中点名
该文件 —— "…and append [N] conflict entr(y/ies) to
`docs/consistency-failures.md`"。只有 [A] 会向那里追加（见"反思日志更新"）；[B]
只写报告，不写其他内容。

### 回执最后采集

在 TR 注册表更新和 `consistency-failures.md` 条目写入之后，再写评审报告，并在
那一刻采集其回执行 —— 绝不要取自 Phase 7 草稿。这两个文件都是评审输入：在本次运行
编辑它们之前采集的回执记录的是旧内容，而下一次运行会把本次运行自己的编辑读作
`CHANGED`。

```
Bash: bash .claude/scripts/review-receipts.sh hash docs/architecture/adr-*.md design/gdd/*.md docs/architecture/tr-registry.yaml docs/architecture/architecture.md docs/engine-reference/[engine]/*.md docs/engine-reference/[engine]/modules/*.md project.yaml .claude/docs/technical-preferences.md docs/consistency-failures.md .claude/skills/architecture-review/SKILL.md .claude/skills/architecture-review/references/*.md
```

它与 Phase 1a 的检查是同一列表，`[engine]` 也以同样方式填入。
不存在的可选输入会打印 `not stamped, no such file` 并被略去；这是预期行为。将戳记行
粘贴到报告头部下方，即 Phase 7 模板所示的位置。

### RTM 输出（仅 rtm 模式）

对于 `rtm` 模式，使用 `AskUserQuestion`：
- "我可以写入完整的 Requirements Traceability Matrix 吗？"
  - [A] Yes — write to `docs/architecture/requirements-traceability.md`
  - [B] Not yet — show me the full RTM data first, then ask again

RTM 文件格式：

```markdown
# Requirements Traceability Matrix (RTM)

> Last Updated: [date]
> Mode: /architecture-review rtm
> Coverage: [N]% full chain complete (GDD → ADR → Story → Test)

## How to read this matrix

| Column | Meaning |
|--------|---------|
| TR-ID | Stable requirement ID from tr-registry.yaml |
| GDD | Source design document |
| ADR | Architectural decision governing implementation |
| Story | Story file that implements this requirement |
| Test File | Automated test file path |
| Test Status | COVERED / MISSING / NONE / NO STORY |

## Full Traceability Matrix

| TR-ID | GDD | Requirement | ADR | Story | Test File | Status |
|-------|-----|-------------|-----|-------|-----------|--------|
[Full matrix rows from Phase 3b]

## Coverage Summary

| Status | Count | % |
|--------|-------|---|
| COVERED — full chain complete | [N] | [%] |
| MISSING test — story exists, no test | [N] | [%] |
| NO STORY — ADR exists, not yet implemented | [N] | [%] |
| NO ADR — architectural gap | [N] | [%] |
| **Total requirements** | **[N]** | **100%** |

## Uncovered Requirements (Priority Fix List)

Requirements where the full chain is broken, prioritised by layer:

### Foundation layer gaps
[list with suggested action per gap]

### Core layer gaps
[list]

### Feature / Presentation layer gaps
[list — lower priority]

## History

| Date | Full Chain % | Notes |
|------|-------------|-------|
| [date] | [%] | Initial RTM |
```

### TR 注册表更新

还要询问："我可以用本次评审产生的新需求 ID 更新
`docs/architecture/tr-registry.yaml` 吗？"

若同意，先重新读取当前的 `docs/architecture/tr-registry.yaml`：
本次评审在开始时读过它，而自那以后其他技能或会话可能已修改过它。基于这次最新读取
构建更新，绝不要基于早先的副本，并保留其中已有的每个条目。然后：
- **追加**本次评审之前注册表中不存在的任何新 TR-ID
- **更新**任何 GDD 措辞发生变化的条目的 `requirement` 文本和 `revised` 日期
  （ID 保持不变）
- **标记** `status: deprecated`，针对任何 GDD 需求已不存在的注册表条目
  （标记弃用前先与用户确认；在 `single-gdd` 模式下，仅限被评审系统的条目）
- **标记** `status: "superseded-by: TR-[system]-NNN"`，针对需求被拆分或替换的条目，
  并点名新的 TR-ID。保留引号：不加引号时，第二个冒号会使文件成为无效 YAML
- **绝不**重新编号或删除现有条目
- 更新顶部的 `last_updated` 和 `version` 字段

写入后，运行 `bash .claude/scripts/registry.sh validate`，并在继续之前修复所有关于
本次写入新增或修改条目的行（DUPLICATE、STATUS 或 LAYOUT 行，或其点名的路径的
PATH_MISSING 行）；关于其他条目的行请告知用户，而不是未经请求就去修复。如果脚本
缺失或没有输出，说明注册表检查未运行，然后对照文件头部的规则重新阅读你写入的条目。

这确保所有未来的用户故事文件都能引用稳定的 TR-ID，并在每一次后续架构评审中持续有效。

### 反思日志更新

当用户选择 Phase 8 的 [A]（即点名了此文件的选项）时，在写入评审报告之前（其回执
最后采集），将 Phase 4 发现的任何 🔴 CONFLICT 条目追加到
`docs/consistency-failures.md`（若文件存在）：

```markdown
### [YYYY-MM-DD] — /architecture-review — 🔴 CONFLICT
**Domain**: Architecture / [specific domain e.g. State Ownership, Performance]
**Documents involved**: [ADR-NNNN] vs [ADR-MMMM]
**What happened**: [specific conflict — what each ADR claims]
**Resolution**: [how it was or should be resolved]
**Pattern**: [generalised lesson for future ADR authors in this domain]
```

只追加 CONFLICT 条目 —— 不要记录 GAP 条目（在架构完成之前，缺失 ADR 是预期的）。
若文件不存在则不要创建 —— 只在它已存在时追加。

### 会话状态更新

写入所有已批准文件后，静默追加到
`production/session-state/active.md`：

    ## Session Extract — /architecture-review [date]
    - Verdict: [PASS / NOT ASSESSED / CONCERNS / FAIL]
    - Requirements: [N] total — [X] covered, [Y] partial, [Z] gaps
    - New TR-IDs registered: [N, or "None"]
    - GDD revision flags: [comma-separated GDD names, or "None"]
    - Top ADR gaps: [top 3 gap titles from the report, or "None"]
    - Report: docs/architecture/architecture-review-[date].md

如果 `active.md` 不存在，用此块作为初始内容创建它。
在对话中确认："Session state updated."

可追溯性索引 —— 写入 `docs/architecture/requirements-traceability.md`，即
`/propagate-design-change` 和预制作质量闸门读取的路径；`rtm` 模式随后用用户故事和
测试列扩展同一文件 —— 使用以下格式：

```markdown
# Architecture Traceability Index
Last Updated: [date]
Engine: [name + version]

## Coverage Summary
- Total requirements: [N]
- Covered: [X] ([%])
- Partial: [Y]
- Gaps: [Z]

## Full Matrix
[Complete traceability matrix from Phase 3]

## Known Gaps
[All ❌ items with suggested ADRs]

## Superseded Requirements
[Requirements whose GDD was changed after the ADR was written]
```

---
