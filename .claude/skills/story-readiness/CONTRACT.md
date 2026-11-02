# /story-readiness — 交接契约

## 在流水线中的角色
验证故事文件是否包含开发者开始实现所需的一切，并产生 READY / NEEDS WORK / BLOCKED / NOT ASSESSED 结论——位于
`/create-stories` 与 `/dev-story` 之间，作为编写任何代码之前的阻塞性闸门。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `production/epics/[epic-slug]/story-NNN-[slug].md` | 所有头部字段（`Status:`、`Layer:`、`Type:`、`Manifest Version:`）、`## Context`（GDD 路径、TR-ID、ADR 引用、Engine Notes、Control Manifest Rules）、`## Acceptance Criteria`、`## Test Evidence`、`## Dependencies`、`## Out of Scope` | 是 |
| `docs/architecture/control-manifest.md` | 头部中的 `Manifest Version:` 日期、层规则 | 是（若存在） |
| `docs/architecture/tr-registry.yaml` | 每个 TR 条目的 `id`、`status` 字段 | 是（若存在） |
| `docs/architecture/adr-NNNN-[slug].md`（故事中引用的所有 ADR） | `## Status`、`**Layer**` 行（通过 `adr-status.sh` 读取） | 是 |
| `production/sprint-status.yaml` | `file:` 条目（用于 `sprint` 范围，通过 `story-facts.sh --sprint` 读取） | 是（若存在） |

> **层级（Tier）。** 清单、TR 注册表和 ADR 行是
> `standard`/`full` 输入。在 `workflow: minimal` 下该技能不在路径上
> （`/dev-story` 直接跟在 `/create-stories` 之后）；若仍运行，它只检查
> 验收标准和范围，并将 Architecture Completeness 视为 N/A，
> 但被引用 ADR 规则除外：故事引用且缺失、
> `Proposed`、`Deprecated` 或 `Superseded` 的 ADR 在每个层级都构成阻塞（SKILL.md，Design
> Completeness 上方的层级说明）。

### 前置条件
- 被验证的故事文件由 `/create-stories` 生成（或遵循相同格式）
- 对于 `sprint` 范围：`production/sprint-status.yaml` 存在，并在其 `file:` 条目中列出故事路径
- 对于 `all` 范围：`production/epics/` 目录存在且包含故事文件

## 产生的输出

### 写入的文件
无。本技能严格只读，在任何情况下都不产生文件修改。

### 输出保证
- 为每个被评估的故事文件产生 READY、NEEDS WORK、BLOCKED 或 NOT ASSESSED 结论。`NOT ASSESSED` 不是 `BLOCKED` 的同义词：BLOCKED 点名一个真实、可列出的障碍，而 NOT ASSESSED 表示故事根本无法被评估。空范围产生 `NOT ASSESSED — no stories in scope`，绝不在空列表上给出 `Ready: 0 / Needs Work: 0 / Blocked: 0` 汇总
- 每个非 READY 结论都包含具体缺口列表，并为每个失败的检查清单项附修复说明
- 每个 BLOCKED 结论都点名具体阻塞项（缺失的依赖故事路径、Proposed 的 ADR ID，或未解决的设计问题标记）
- 对于 `sprint` 范围：如果任何 Must Have 故事不是 READY（NEEDS WORK、BLOCKED 或 NOT ASSESSED），会在开头加上冲刺级升级警告
- 本技能提出在对话中起草缺失章节，但绝不写入或编辑文件

## 不可变性规则
- 读取但**不**修改：故事文件、`docs/architecture/control-manifest.md`、`docs/architecture/tr-registry.yaml`、所有 ADR 文件、冲刺文件、任何被引用的资源文件（仅检查存在性）
- 修改：无

## 硬性约束（绝不违反）
- 在任何情况下都不写入或编辑文件
- 绝不把修正直接起草进文件——只在对话中提供草稿
- 如果故事的治理 ADR 具有 `Status: Proposed`、`Deprecated` 或 `Superseded`，在任何层级都不把故事标记为 READY
- 如果依赖故事文件缺失或具有 `Status: Draft`，绝不把故事标记为 READY
- 绝不按故事重新读取 ADR 状态——一次 `adr-status.sh` 调用服务整个运行
- 如果 `control-manifest.md` 不存在，绝不因缺少 `Manifest Version:` 而惩罚故事
- 如果 `tr-registry.yaml` 不存在，绝不因缺少 TR-ID 而惩罚故事

## 下游技能期望
**下一个技能：** /dev-story

它将按如下方式依赖本技能的结论：
- 如果结论为 READY：`/dev-story` 以故事文件为事实来源继续实现
- 如果结论为 NEEDS WORK、BLOCKED 或 NOT ASSESSED：在故事被修正（对于 NOT ASSESSED，则是使其可读）并重新验证之前，不得运行 `/dev-story`——没人能评估的故事不能算已证明就绪
- `/dev-story` 读取本技能验证的相同故事字段——READY 结论隐含保证这些字段存在、可解析且内部一致：
  - `Type:` 字段设为有效的故事类型
  - `## Acceptance Criteria` 包含具体、可测试的复选框项，至少达到项目 `story_granularity` 下该故事类型的最低数量（coarse 3/2/1，balanced 2/2/1，fine 1）
  - `## Test Evidence` 指定具体的证据路径
  - 治理 ADR 存在且具有 `Status: Accepted`
  - `Manifest Version:` 与当前控制清单匹配
  - `## Context` 中的 `TR-ID` 存在，并能在 `docs/architecture/tr-registry.yaml` 中解析（当注册表存在时）
  - `## Dependencies` 章节存在（可以说“None”）
  - `## Out of Scope` 章节存在（检查存在性；`/dev-story` 用它来强制实现边界）

## 已知脆弱点
- 如果 `control-manifest.md` 以新的 `Manifest Version:` 日期重新生成，每个内嵌旧日期的故事都会无法通过清单版本检查——在故事再次通过就绪检查之前，需要对所有故事的 `Manifest Version:` 字段做批量更新
- 如果 ADR 在故事按 ID 引用它之后被静默重命名或移动，ADR 文件存在性检查会阻塞这些故事，即使决策内容未变
- 清单版本比较是字符串日期匹配，不是语义版本比较——如果日期格式改变（例如从 `2026-01-15` 变为 `Jan 15 2026`），无论实际是否为最新，所有故事都会无法通过检查
- 资源存在性检查匹配路径——在 Windows 上，路径分隔符不匹配（`\` 与 `/`）可能导致漏检，从而错误地把资源标记为缺失
- 如果注册表不存在，TR-ID 状态检查会自动通过，这意味着在 TR 追踪引入之前编写的故事将始终通过此检查，即使它们包含无效或占位 ID，如 `TR-[system]-???`
- 对于 `sprint` 范围，本技能依赖冲刺文件格式来提取故事路径；如果冲刺文件格式改变，故事路径可能无法解析；此时运行会报告 `NOT ASSESSED — no stories in scope`，而不是干净摘要
