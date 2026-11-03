# Story [NNN]: [title]

> **Epic**: [epic name]
> **Status**: [Ready | Blocked — BLOCKED: <reason>]
> **Layer**: [Foundation / Core / Feature / Presentation]
> **Type**: [Logic | Integration | Visual/Feel | UI | Config/Data]
> **Estimate**: [S | M | L，或小时数——由 /create-stories 提出]
> **Manifest Version**: [control-manifest.md 头部的日期]
> **Last Updated**: [实现开始时由 /dev-story 设置]

## Context

**GDD**: `design/gdd/[filename].md`
**Requirement**: `TR-[system]-NNN`
*（需求文本位于 `docs/architecture/tr-registry.yaml`——评审时重新读取）*

**ADR Governing Implementation**: [ADR-NNNN: title]
**ADR Decision Summary**: [用 1-2 句话概述该 ADR 的决定]
**ADR Version**: [该 ADR 的 `## Last Verified` 日期，否则其 `## Date`，否则 `unversioned`]

**Engine**: [name + version] | **Risk**: [LOW / MEDIUM / HIGH]
**Engine Notes**: [来自 ADR 的 Engine Compatibility 章节——训练截止后的 API、需要验证]

**Control Manifest Rules (this layer)**:
- Required: [相关的必需模式]
- Forbidden: [相关的禁止模式]
- Guardrail: [相关的性能护栏]

---

## Acceptance Criteria

*来自 GDD `design/gdd/[filename].md`，按本用户故事裁切：*

- [ ] [验收标准 1——直接来自 GDD]
- [ ] [验收标准 2]
- [ ] [性能验收标准（如适用）]

---

## Implementation Notes

*源自 ADR-NNNN 的 Implementation Guidelines：*

[来自 ADR 的具体、可操作指导。不要以改变含义的方式转述。这是程序员阅读的
内容，用来代替阅读 ADR。]

---

## Out of Scope

*由相邻用户故事处理——不要在此实现：*

- [Story NNN+1]：[它处理什么]

---

## Files

*本用户故事创建或修改的代码和测试文件。`/create-stories` 列出计划中的文件；
`/dev-story` 用实际改动的文件替换列表；`/story-done` 依据它检查范围。*

- [代码根目录下的路径]
- [测试路径]

---

## QA Test Cases

*由 qa-lead 在创建用户故事时编写。开发者依照这些用例实现——实现期间不要
自行发明新测试用例。（在跳过 QL-STORY-READY 闸门的层级——`minimal`，或
`lean`/`solo` 评审模式——不存在 qa-lead 规格，本节写为：N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.）*

**[For Logic / Integration stories — automated test specs]:**

- **AC-1**: [验收标准原文]
  - Given: [前置条件]
  - When: [动作]
  - Then: [断言]
  - Edge cases: [边界值 / 失败状态]

**[For Visual/Feel / UI stories — manual verification steps]:**

- **AC-1**: [验收标准原文]
  - Setup: [如何到达该状态]
  - Verify: [要观察什么]
  - Pass condition: [明确的通过描述]

---

## Test Evidence

*由 `qa.level` 约束：在 `qa.level: minimal` 下测试被**豁免**（仅作建议，绝非「必须存在并通过」），但 Visual/Feel 或 UI 用户故事的保留截图不豁免。*

**Story Type**: [type]
**Required evidence**:
- Logic: `tests/unit/[system]/[story-slug]_test.[ext]`——必须存在并通过（`/story-done` 检查它是否存在；通过/失败由之后的 `/gate-check` 和 `/smoke-check` 判定）
- Integration: `tests/integration/[system]/[story-slug]_test.[ext]` 或试玩测试文档
- Visual/Feel: `production/qa/evidence/` 中的保留截图 + `production/qa/evidence/[story-slug]-evidence.md` 中的签核
- UI: `production/qa/evidence/` 中保留每个触及界面的截图
- Config/Data: 冒烟检查通过（`production/qa/smoke-*.md`）

**Status**: [ ] 尚未创建

---

## Dependencies

- Depends on: [每个必须先行 DONE 的用户故事的路径，例如 `production/epics/<epic>/story-001-<slug>.md`，或 "None"]
- Unlocks: [本用户故事解锁的每个用户故事的路径，或 "None"]
