# /create-epics —— 交接契约

## 在流水线中的角色
把已批准的 GDD 和架构文档转化为每个架构模块一个 EPIC.md 文件，
定义范围、ADR 治理、引擎风险和需求可追溯性——处在架构评审与用户故事拆解之间。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `design/gdd/systems-index.md` | 系统列表、层分配、优先级顺序 | 是 |
| `design/gdd/[system].md` | `## Summary`、`## Acceptance Criteria`、`## Overview`（全部 8 个必需章节） | 是 |
| `docs/architecture/architecture.md` | 模块归属、API 边界 | 是 |
| `docs/architecture/adr-NNNN-[slug].md`（所有支配 ADR） | `Status:`、`GDD Requirements Addressed`、`Decision`、`Engine Compatibility` | 是 |
| `docs/architecture/control-manifest.md` | 头部中的 `Manifest Version:` 日期 | 是 |
| `docs/architecture/tr-registry.yaml` | 带 `id`、`system`、需求文本的 TR-ID | 是 |
| `docs/engine-reference/[engine]/VERSION.md` | 引擎名称、版本、风险等级 | 是 |

> **层级。** 上面的行和下面的前置条件是 `full` 输入。
> SKILL.md 按 `workflow` 放宽它们：在 `standard` 下，GDD 需要 5 个必需
> 章节（+ 条件性的 Formulas），只预期并追踪关键（Foundation 层）ADR，
> 控制清单存在则读取，不是必需。
> 在 `minimal` 下，技能是可选的且不在路径上（`/create-stories`
> 自行合成史诗），并且它会先说明这一点；如果运行，它跳过 GDD 和
> 架构读取，只读 `design/game-brief.md`（若缺失则停止），
> 其顺序取自简报的 Build order 而不是
> `systems-index.md`，且不需要任何 GDD、ADR、架构文档、TR 注册表
> 或控制清单。简短简报就是一个史诗，slug 取自简报的工作
> 标题，即没有输入任何内容时 `/create-stories` 使用的 slug；要求把工作分组的用户
> 会为每组 MVP 功能得到一个史诗。

### 前置条件
- `/create-control-manifest` 已运行且 `docs/architecture/control-manifest.md` 已存在
- `/architecture-review` 已通过（至少 Foundation 和 Core ADR 为 Accepted）
- 所有范围内 GDD 在 `systems-index.md` 中的状态为 `Approved` 或 `Designed`
- 目标层的 GDD 稳定——在 Core 接近完成之前不要为 Feature 层运行

## 产出的内容

### 写入的文件
| 文件 | 保证的字段 / 章节 | 说明 |
|------|------------------------------|-------|
| `production/epics/[epic-slug]/EPIC.md` | `Layer`、`GDD` 路径、`Architecture Module`、`Status: Ready`、`## Governing ADRs` 表格、带 TR-ID 和 ADR 覆盖的 `## GDD Requirements` 表格、`## Definition of Done`、`## Overview` | 每个已批准史诗创建一个 |
| `production/epics/index.md` | `Epic`、`Layer`、`System`、`GDD`、`Stories`、`Status` 列 | 创建，或每个新史诗添加一行；已有史诗的行被原地更新并保留其 `Stories` 值 |

### 输出保证
- 每个 EPIC.md 都包含 `## Governing ADRs` 表格，且至少有一行（若无一适用，则有记录的说明）
- 每个 EPIC.md 都包含 `## GDD Requirements` 表格，其中每行都有一个 `TR-ID` 和一个 `ADR Coverage` 单元格：`ADR-NNNN ✅`（一个 Accepted ADR）、`❌ No ADR`，或当其唯一处理该需求的 ADR 不是 Accepted 时的 `❌ No ADR (ADR-NNNN Proposed)`，以便 `/create-stories` 仍能看到该 ADR 并阻塞其用户故事
- EPIC.md 头部中的 `GDD:` 字段是指向源 GDD 的有效相对路径
- `Layer:` 字段是以下之一：Foundation、Core、Feature、Presentation
- `Status:` 字段设为 `Ready`
- 新史诗的 `Stories:` 字段读作 `Not yet created — run /create-stories [epic-slug]`；已存在的 EPIC.md 在（更新或跳过询问后）被原地更新，并保留其 `Stories:` 行和 `## Stories` 表格
- 未追踪需求（没有 Accepted ADR 的 TR-ID）在 GDD Requirements 表格中用 `❌ No ADR` 标记，并列在 Untraced Requirements 下；⚠️ 警告在 `full` 下针对每一项触发，在 `standard` 下仅针对 Foundation 层项触发
- `production/epics/index.md` 为本次运行编写的每个史诗都有一条记录
- 无法判断史诗的 PR-EPIC 评审（没有里程碑时间线或团队产能）报告为 `PR-EPIC: NOT ASSESSED — [input]`，绝不读作 REALISTIC

## 不可变性规则
- 读取但不修改：`design/gdd/systems-index.md`、所有 GDD 文件、`docs/architecture/architecture.md`、`docs/architecture/adr-NNNN-[slug].md` 模式中的所有 ADR 文件、`docs/architecture/control-manifest.md`、`docs/architecture/tr-registry.yaml`、`docs/engine-reference/[engine]/VERSION.md`
- 修改：`production/epics/[epic-slug]/EPIC.md`（创建，或原地更新并保留其 Stories 表格）、`production/epics/index.md`（创建或更新）

## 硬性约束（绝不违反）
- 绝不创建用户故事文件——本技能止步于史诗层
- 绝不发明并非源自 GDD、ADR 或架构文档的内容
- 绝不在写入前跳过按史诗的批准提示
- 绝不在先向用户展示史诗定义之前写入 EPIC.md
- 绝不覆盖已有 EPIC.md 或重置其 `## Stories` 表格——原地更新它，或跳过它。`write-guard.sh overwrite` 在每次新写入前运行，并在文件存在时阻止写入
- 除非某 ADR 的 `Status:` 为 `Accepted`，绝不把 TR-ID 标记为由该 ADR 覆盖
- 绝不为依赖层尚未大体完成的层创建史诗

## 下游技能期望
**下一个技能：** /create-stories

它将读取：
- `production/epics/[epic-slug]/EPIC.md`——具体为：`Layer:`、`GDD:` 路径、`Architecture Module:`、完整的 `## Governing ADRs` 表格（ADR ID 和摘要），以及完整的 `## GDD Requirements` 表格（TR-ID 和 ADR 覆盖状态）
- `production/epics/index.md`——在未给参数时枚举可用的史诗

它假设：
- EPIC.md 中的 `GDD:` 路径解析为可读文件
- `## Governing ADRs` 中列出的每个 ADR 都作为文件存在，且状态为 `Accepted`
- `## GDD Requirements` 中的 TR-ID 与 `docs/architecture/tr-registry.yaml` 中的条目匹配
- 目录名中使用的史诗 slug 与 `index.md` 中引用的 slug 匹配
- `Status: Ready` 本身并不意味着不存在用户故事——原地更新的 EPIC.md 保留其用户故事；读取其 `Stories:` 行

## 已知脆弱点
- 如果 EPIC.md 模板结构发生变化（章节名称、头部字段名、表格列顺序），`/create-stories` 会静默解析失败治理数据，并可能产出不完整或错误的用户故事
- 如果在 EPIC.md 文件写入后 `tr-registry.yaml` 被重新生成并重新编号 ID，已有 EPIC.md 文件中的 TR-ID 会过时，并误导 `/create-stories`
- 如果在史诗写入后某个 ADR 被追溯地从 `Accepted` 改为 `Proposed`，EPIC.md 仍会把它显示为支配项。`/create-stories` 用 `adr-status.sh` 读取每个具名 ADR 的当前状态并阻塞用户故事，但史诗的覆盖列会保持过时，直到 `/create-epics` 原地更新该史诗
- 如果在史诗创建后 `systems-index.md` 的层分配发生变化，已有 EPIC.md 文件中的 `Layer:` 字段将不正确，`/create-stories` 会使用错误的层上下文
- `production/epics/index.md` 的行按 slug 与史诗匹配——slug 发生变化的史诗会得到新行，而旧行会留在原处
