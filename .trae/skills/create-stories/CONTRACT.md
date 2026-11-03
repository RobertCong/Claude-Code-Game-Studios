# /create-stories — 交接契约

## 在流水线中的角色
通过把 GDD 验收标准追溯经 ADR 决策和清单规则，将单个史诗分解为可实现的
故事文件——位于 `/create-epics` 与 `/story-readiness` + `/dev-story` 之间。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `production/epics/[epic-slug]/EPIC.md` | `Layer:`、`GDD:` 路径、`Architecture Module:`、`## Governing ADRs` 表、带 TR-ID 的 `## GDD Requirements` 表 | 是 |
| `design/gdd/[filename].md` | 该系统层级所需的章节（`full` 下全部 8 个；`standard` 下 5 个必需 + 条件性的 Formulas），尤其是 `## Acceptance Criteria`、`## Formulas`、`## Edge Cases` | 是 |
| `docs/architecture/adr-NNNN-[slug].md`（所有治理 ADR） | `## Status`、`## Summary`、`## Decision`（含 `### Implementation Guidelines`）、`## Engine Compatibility`、`## Last Verified` / `## Date`、`**Depends On**` 行（通过 `adr-status.sh` 读取） | 是 |
| `docs/architecture/control-manifest.md` | 层规则（必需模式、禁止模式、护栏）、头部中的 `Manifest Version:` 日期 | 是 |
| `docs/architecture/tr-registry.yaml` | 史诗所属系统的所有 TR-ID，具有稳定的 `id` 值 | 是 |

> **层级（Tier）。** 上面的行是 `standard`/`full` 的输入。在 `workflow: minimal` 下，
> 唯一输入是 `design/game-brief.md`：技能会自己从简报写入
> `production/epics/<slug>/EPIC.md`（或使用那里已存在的，
> 绝不重写它），无需运行 `/create-epics`，
> 也不读取任何 GDD、ADR、控制清单或 TR 注册表。每个故事追溯到
> `Brief MVP feature N` 而不是 TR-ID，其 ADR 行读作
> `N/A (minimal — no ADRs)`（SKILL.md，Phase 2 的 `minimal` 分支和
> Phase 7 的 `minimal` 字段映射）。

### 前置条件
- `/create-epics` 已运行，且目标 `EPIC.md` 具有 `Status: Ready`
- EPIC.md 包含已填充的 `## GDD Requirements` 表（非空）
- EPIC.md 中列出的所有治理 ADR 都存在为文件
- 基础史诗的故事在核心史诗开始之前创建；核心先于功能；功能先于表现

## 产生的输出

### 写入的文件
| 文件 | 保证的字段 / 章节 | 备注 |
|------|------------------------------|-------|
| `production/epics/[epic-slug]/story-NNN-[slug].md` | `Epic:`、`Status:`、`Layer:`、`Type:`、`Manifest Version:`、`## Context`（GDD 路径 + `TR-[system]-NNN` + ADR 引用 + ADR Decision Summary + Engine/Risk + Engine Notes + Control Manifest Rules）、`## Acceptance Criteria`、`## Implementation Notes`、`## Out of Scope`、`## Files`、`## Test Evidence`、`## Dependencies` | 每个故事创建一个 |
| `production/epics/[epic-slug]/EPIC.md` | `## Stories` 表替换“Not yet created”占位符 | 就地更新；回访时只为新故事追加行。在 `minimal` 下当尚不存在时，技能从简报创建它，需在写入询问点明它之后 |
| `production/epics/index.md` | 史诗的 `Stories` 列设为 `[N] stories` | 仅当索引存在时；否则本次运行打印 `Epics index not updated: production/epics/index.md absent` |

### 输出保证
- 每个故事文件的 `## Context` 章节都包含 `TR-[system]-NNN` 引用（若注册表无匹配，则为 `TR-[system]-???` 加警告）——在 `minimal` 下为 `Brief MVP feature N`
- 每个故事文件都包含引用至少一个 ADR 的 `ADR Governing Implementation:` 行，或显式的 `ADR: N/A — [reason]` 行
- 每个故事文件都有 `Status:` 字段——要么 `Ready`，要么 `Blocked`（如果治理 ADR 为 `Proposed`、`Deprecated` 或 `Superseded`，或其依赖的 ADR 不是 `Accepted`）
- 每个故事文件都有 `Type:` 字段——以下之一：Logic、Integration、Visual/Feel、UI、Config/Data
- 每个故事文件都有 `Manifest Version:` 字段，与写入时 `docs/architecture/control-manifest.md` 头部日期一致——在 `minimal` 下为 `N/A (minimal — no control manifest)`
- 每个故事文件都有 `## Test Evidence` 章节，说明其类型预期的证据位置
- 每个故事文件都有 `## Acceptance Criteria` 章节，至少包含一条从 GDD 复制的复选框项——在 `minimal` 下源自 `design/game-brief.md`（其 Player goal & fail state 以及故事实现的 MVP 功能）
- 每个故事文件都有 `## Dependencies` 章节，按路径点名它需要的每个故事（可以说“None”，但绝不被省略）
- 每个故事文件都有 `## Files` 章节，列出计划创建或更改的代码和测试文件；`/dev-story` 用其变更的文件替换该列表，`/story-done` 依据它检查范围
- EPIC.md 的 `## Stories` 表更新为每个故事一行，包括 `#`、`Story` 标题、`Type`、`Status` 和 `ADR`
- ADR 为 `Proposed` 的故事具有 `Status: Blocked` 和注释：`BLOCKED: ADR-NNNN is Proposed — accept it with /architecture-decision accept ADR-NNNN once decided`；`Deprecated` 或 `Superseded` 的 ADR 以同样方式阻塞，并点明其后继者
- 每个故事文件都有 `Engine` 和 `Risk` 字段。`Risk` 取自 `docs/engine-reference/<engine>/VERSION.md`；当该文件缺失或未分配等级时，`Risk` 为 **`NOT ASSESSED (no VERSION.md risk rating)`**——绝不是猜测的等级
- **`NOT ASSESSED` 是 `Risk` 字段可发出的值**，下游读者必须处理它。`/dev-story` 在决定是否把工作交给引擎专家时将其视为 HIGH：未知风险不是低风险

## 不可变性规则
- 读取但**不**修改：史诗的 GDD、所有 ADR 文件、`docs/architecture/tr-registry.yaml`、`docs/architecture/control-manifest.md`
- 修改：`production/epics/[epic-slug]/story-NNN-[slug].md`（创建）、`production/epics/[epic-slug]/EPIC.md`（仅更新 Stories 章节；在 `minimal` 下当尚不存在时创建）、`production/epics/index.md`（史诗的行，当索引存在时）——全部在一次点明它们的写入询问之后

## 硬性约束（绝不违反）
- 绝不开始实现——本技能止于故事文件层面
- 绝不编造验收标准——所有标准必须来自 GDD（在 `minimal` 下来自 `design/game-brief.md`）
- 绝不编造实现笔记——所有指导必须来自被引用的 ADR
- 绝不未先展示完整故事列表以供批准就写入故事文件
- 如果故事的治理 ADR 具有 `Status: Proposed`、`Deprecated` 或 `Superseded`，绝不把故事标记为 `Status: Ready`
- 绝不省略 `Manifest Version:` 字段——下游就绪检查依赖它
- 绝不重复使用史诗目录中已存在的故事编号（NNN）

## 下游技能期望
**下一个技能：** /story-readiness（然后 /dev-story）

它会读取：
- 每个 `story-NNN-[slug].md` 文件——具体为：`Status:`、`Type:`、`Manifest Version:`（头部）、`TR-[system]-NNN`（在 `## Context` 中）、`ADR Governing Implementation:` 行、`## Acceptance Criteria` 章节、`## Test Evidence` 章节、`## Dependencies` 章节
- `docs/architecture/control-manifest.md`——以将其 `Manifest Version:` 与故事内嵌的版本比较
- 被引用的 ADR 文件——以验证其 `Status:` 字段仍为 `Accepted`

它假定：
- 故事头部中的 `Manifest Version:` 是可与管理清单当前 `Manifest Version:` 日期比较的日期字符串
- `TR-[system]-NNN` ID 在 `docs/architecture/tr-registry.yaml` 中可解析
- `ADR Governing Implementation:` 中点名的 ADR 作为文件存在于 `docs/architecture/`（模式：`adr-NNNN-[slug].md`）
- `Status: Ready` 意味着故事是分配候选（不是 Draft，也不是进行中）
- `## Acceptance Criteria` 包含可直接测试的复选框项
- `## Test Evidence` 指定了存储证据的确切文件路径或证据文档路径

## 已知脆弱点
- 如果故事文件格式（头部字段名、章节名、复选框语法）发生变化，`/story-readiness` 会静默跳过它无法解析的字段检查——本应失败的故事可能通过就绪检查
- 如果 `control-manifest.md` 在故事编写后以新的 `Manifest Version:` 日期重新生成，所有现有故事都会显示过时的清单版本并无法通过就绪清单检查——史诗中的每个故事都需要更新其 `Manifest Version:`
- 如果治理 ADR 在故事编写后被重新编号或其文件被重命名，故事文件中的 `ADR Governing Implementation:` 引用会指向缺失文件，`/story-readiness` 会阻塞这些故事
- 如果 `tr-registry.yaml` 弃用或取代了已嵌入故事文件的 TR-ID，`/story-readiness` 会把这些故事标记为 NEEDS WORK
- EPIC.md Stories 表的更新是追加式的：回访时只为新故事追加行，因此手动编辑删除了故事编号的表可能产生重复行
