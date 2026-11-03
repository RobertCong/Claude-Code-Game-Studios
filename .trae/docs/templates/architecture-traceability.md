# Architecture Traceability Index

<!-- 活文档——每次评审运行后由 /architecture-review 更新。
     除非修正错误，否则请勿手动编辑。 -->

## Document Status

- **Last Updated**: [YYYY-MM-DD]
- **Engine**: [e.g. Godot 4.7]
- **GDDs Indexed**: [N]
- **ADRs Indexed**: [M]
- **Last Review**: [link to docs/architecture/architecture-review-[date].md]

## Coverage Summary

| Status | Count | Percentage |
|--------|-------|-----------|
| ✅ Covered | [X] | [%] |
| ⚠️ Partial | [Y] | [%] |
| ❌ Gap | [Z] | [%] |
| **Total** | **[N]** | |

---

## Traceability Matrix

<!-- 每行对应一条从 GDD 中提取的技术需求。
     所谓“技术需求”，是指任何隐含具体架构决策的 GDD 陈述：数据结构、性能约束、
     所需的引擎能力、跨系统通信、状态持久化。 -->

| Req ID | GDD | System | Requirement Summary | ADR(s) | Status | Notes |
|--------|-----|--------|---------------------|--------|--------|-------|
| TR-[system]-001 | [filename] | [system name] | [one-line summary] | [ADR-NNNN] | ✅ | |
| TR-[system]-002 | [filename] | [system name] | [one-line summary] | — | ❌ GAP | 需运行 `/architecture-decision [title]` |

---

## Known Gaps

没有 ADR 覆盖的需求，按层级排序（Foundation 优先）：

### Foundation Layer Gaps (BLOCKING — must resolve before coding)
- [ ] TR-[id]: [requirement] — GDD: [file] — Suggested ADR: "[title]"

### Core Layer Gaps (must resolve before relevant system is built)
- [ ] TR-[id]: [requirement] — GDD: [file] — Suggested ADR: "[title]"

### Feature Layer Gaps (should resolve before feature sprint)
- [ ] TR-[id]: [requirement] — GDD: [file] — Suggested ADR: "[title]"

### Presentation Layer Gaps (can defer to implementation)
- [ ] TR-[id]: [requirement] — GDD: [file] — Suggested ADR: "[title]"

---

## Cross-ADR Conflicts

<!-- 相互矛盾成对的 ADR。必须解决。 -->

| Conflict ID | ADR A | ADR B | Type | Status |
|-------------|-------|-------|------|--------|
| CONFLICT-001 | ADR-NNNN | ADR-MMMM | Data ownership | 🔴 Unresolved |

---

## ADR → GDD Coverage (Reverse Index)

<!-- 每一份 ADR 分别覆盖了哪些 GDD 需求？ -->

| ADR | Title | GDD Requirements Addressed | Engine Risk |
|-----|-------|---------------------------|-------------|
| ADR-0001 | [title] | TR-combat-001, TR-combat-002 | HIGH |

---

## Superseded Requirements

<!-- 编写某份 ADR 时存在于 GDD 中、但之后 GDD 已发生变更的需求。
     该 ADR 可能需要更新。 -->

| Req ID | GDD | Change | Affected ADR | Status |
|--------|-----|--------|-------------|--------|
| TR-[id] | [file] | [what changed] | ADR-NNNN | 🔴 ADR needs update |

---

## How to Use This Document

**编写新的 ADR 时**：将它加入 "ADR → GDD Coverage" 表，并在矩阵中把它满足的需求标记为 ✅。

**批准 GDD 变更时**：在矩阵中扫描来自该 GDD 的需求，检查该变更是否使任何现有 ADR 失效。
若失效，则加入 "Superseded Requirements"。

**运行 `/architecture-review` 时**：该技能会用当前状态自动更新本文档。

**质量闸门检查**：Pre-Production 闸门要求本文档存在，且 Foundation 层空缺为零。
