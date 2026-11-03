# /architecture-decision — 交接契约

## 在流水线中的角色
通过引导一次协作式设计会话、交叉参考引擎参考资料库与既有架构立场，并把完全结构化的 ADR 文件写入 `docs/architecture/`（状态为 `Proposed`），来撰写一份新的架构决策记录（ADR）。它的 `accept` 模式是通往 `Accepted` 的唯一路径，而接受正是解除依赖该决策的用户故事与史诗（epic）阻塞的动作。

本次运行中的两项检查会输出 `NOT ASSESSED`，而不是静默通过，
所得 ADR 的读者应当预期到它们：**引擎验证**（当未配置引擎时——`engine.name` 未设置且无遗留回退），以及 **GDD 同步**（当所引用的设计文档无法读取时）。一项跳过却不作声明的检查，与一项通过的检查无法区分。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `docs/engine-reference/[engine]/VERSION.md` | 引擎名称 + 版本、LLM 知识截止日期、各领域在截止后的风险等级 | 是 |
| `docs/engine-reference/[engine]/modules/[domain].md` | 领域专属 API 参考（若决策所属领域存在则读取） | 是 |
| `docs/engine-reference/[engine]/breaking-changes.md` | 相关领域中截止后的破坏性变更 | 是 |
| `docs/engine-reference/[engine]/deprecated-apis.md` | 新 ADR 中不得引用的 API | 是 |
| `docs/registry/architecture.yaml` | 所有既有架构立场（状态归属、接口契约、禁止模式、性能预算）——设计开始前检查冲突 | 是 |
| `docs/architecture/`（现有 ADR） | 扫描以确定下一个顺序 ADR 编号 | 是 |
| `design/gdd/[system].md`（与决策相关的 GDD） | 促使该决策的具体规则、公式、性能约束或集成点 | 是 |
| `project.yaml` | `engine.name` —— 推导出用于验证（第 5.5 步）要生成的 primary specialist（`<engine>-specialist`） | 是 |
| `.claude/docs/technical-preferences.md` | `Engine Specialists` 章节——遗留回退，仅当 `project.yaml` 中 `engine.name` 缺失或为空时使用 | 是——仅当 `engine.name` 缺失时才需要 |

### 前置条件
- 必须已配置引擎（`docs/engine-reference/[engine]/VERSION.md` 必须存在）——若未配置，技能会提示先运行 `/setup-engine`
- 在 Phase 0 继续之前，用户必须提供决策的标题或主题（如果未给出参数，技能会询问）
- 如果处于**改造模式**（`retrofit [path]` 参数），目标 ADR 文件必须已存在于磁盘上
- 与 `docs/registry/architecture.yaml` 中已注册架构立场的任何冲突，都必须在起草 ADR 之前解决或被明确接受为例外（第 3a 步是 BLOCKING 质量闸门）

## 产生的输出

### 写入的文件
| 文件 | 保证包含的字段 / 章节 | 备注 |
|------|------------------------------|-------|
| `docs/architecture/adr-NNNN-[slug].md` | `## Status`、`## Date`、`## Engine Compatibility`（表格：引擎、领域、知识风险、截止后 API、需要验证）、`## ADR Dependencies`（表格：depends-on、enables、blocks、ordering note）、`## Context`（问题陈述、约束、需求）、`## Decision`（+ 架构图 + 关键接口）、`## Alternatives Considered`、`## Consequences`（正面、负面）、`## Risks`、`## GDD Requirements Addressed`（表格）、`## Performance Implications`、`## Migration Plan`、`## Validation Criteria`、`## Related` | 在用户批准后创建（"May I write this ADR to docs/architecture/adr-NNNN-[slug].md?"） |
| `docs/registry/architecture.yaml` | 从 ADR 推导出的新立场条目（状态归属、接口契约、性能预算、禁止模式）；若被覆盖，现有条目标记为 `status: superseded_by` | 在用户另行批准后追加（"May I update docs/registry/architecture.yaml with these N new stances?"） |

### 输出保证
- ADR 编号是 `docs/architecture/` 中现有 `adr-NNNN-*` 文件名最大值之后的下一个顺序整数
- `## Status` 始终存在。撰写写入 `Proposed`；改造写入用户给出的状态，但 `Accepted` 回答会被写为 `Proposed` 并交给接受模式处理。只有接受模式在其依赖检查与用户确认之后才写入 `Accepted`
- `## Engine Compatibility` 始终使用来自引擎参考文档的已验证数据填充——当领域带有 MEDIUM 或 HIGH 风险时，绝不只依赖训练数据
- `## GDD Requirements Addressed` 始终存在（若无 GDD 促使该决策，则记录该决策将约束或启用哪些 GDD）
- `## ADR Dependencies` 始终存在（若无顺序约束，各字段填 "None"）
- 如果配置了引擎专家，则在写入文件之前运行引擎专家验证（第 5.5 步）；专家发现的阻塞问题会导致 Decision 章节在保存前被修订

## 不可变性规则
- 读取但不修改：`docs/architecture/` 中所有现有 ADR 文件（包括改造模式——现有章节绝不被触碰）、`design/gdd/` 中所有 GDD 文件、`docs/engine-reference/**`、`project.yaml`、`.claude/docs/technical-preferences.md`（遗留回退）
- 修改：`docs/architecture/adr-NNNN-[slug].md`（创建新文件；或在改造模式中追加缺失章节）、`docs/registry/architecture.yaml`（仅追加；现有条目获得 `status: superseded_by` 标注，绝不删除或重写）
- 改造模式下：只追加缺失的章节——绝不修改目标 ADR 文件中已存在的任何章节

## 硬性约束（绝不违反）
- 绝不在没有用户明确确认的情况下设置 `Status: Accepted`——创建时的默认值始终是 `Status: Proposed`
- **接受路径：`/architecture-decision accept ADR-NNNN`** —— 唯一会设置 `Accepted` 的路径。当某个依赖仍为 Proposed 时它会拒绝，并且无论 `modes.automation` 如何都会提示确认。改造模式中对已生效决策给出的 `Accepted` 回答，会被写为 `Proposed` 并交给此路径处理。若没有这条路径，接受的后果会由十个技能强制执行、按下述权威归属，却无人能够触达。
- **接受权威：用户，或在用户明确确认下的 `technical-director` —— 没有其他 agent，也不能由此技能自行决定。** 在此记录是因为每个消费方都会强制执行接受的后果，而若无此行，就没有任何地方说明谁可以产生接受。这收窄了*谁*可以设置该字段；它并不放宽上述确认规则。
- 绝不分配已在使用中的 ADR 编号——始终先扫描 `docs/architecture/` 并使用下一个顺序编号
- 若存在冲突，绝不越过架构立场冲突检查（第 3a 步）——要暴露冲突并要求解决或明确确认例外后才能起草
- 绝不在 Decision 或 Key Interfaces 章节引用 `docs/engine-reference/[engine]/deprecated-apis.md` 中列出的 API
- 绝不不问就写 ADR 文件："May I write this ADR to docs/architecture/adr-NNNN-[slug].md?"
- 绝不未经另行询问就写入 `docs/registry/architecture.yaml`："May I update docs/registry/architecture.yaml with these N new stances?"
- 改造模式下：绝不修改任何现有章节——只追加缺失章节

## 下游技能期望
**后续技能：** `/create-epics`、`/create-stories`、`/dev-story`、`/architecture-review`

### `/create-epics` 读取 ADR 时期望：
- `## Status` 字段——值必须为 `Accepted`，史诗才能引用它
- `## GDD Requirements Addressed` 表格——用于将史诗链接到 GDD 可追溯性
- `## Engine Compatibility` 章节——在 Technical Setup → Pre-Production 质量闸门期间检查

### `/create-stories` 读取 ADR 时期望：
- `### Implementation Guidelines`（位于 `## Decision` 之下）——程序员 agent 遵循的具体 "must / must never" 模式；ADR 模板包含此小节
- `## ADR Dependencies` 表格——引用了仍为 `Proposed` 的 `Depends On` ADR 的用户故事会被自动设为 `Status: Blocked`

### `/dev-story` 读取 ADR 时期望：
- `## Decision`（全文，逐字——不要摘要）
- `### Implementation Guidelines`（位于 `## Decision` 之下，逐字）
- `## Engine Compatibility`（截止后 API 风险、需要验证）
- `## ADR Dependencies`（用于检测此 ADR 的依赖是否未解决）

### `/architecture-review` 读取 ADR 时期望：
- 所有必需章节均存在（它会标出缺口）
- 已设置 `## Status`（覆盖率矩阵需要）
- `## Engine Compatibility` 已标注正确的引擎版本

## 已知薄弱点
- 如果 ADR 编号扫描漏掉某个文件（例如 `docs/architecture/` 子目录中的文件，或命名模式非标准的文件），就可能分配重复编号——所有 ADR 文件必须位于 `docs/architecture/` 顶层并遵循 `adr-NNNN-[slug].md` 命名约定
- 只有当 `production/epics/` 下的用户故事文件包含 `/create-stories` 会写入的任一形式（`> **Status**: Blocked`、`**Status:** Blocked`、`Status: Blocked`）的 Blocked Status 行，并且包含此 ADR 的 id 时，接受模式才会把用户故事从 `Blocked` 移到 `Ready`。一个因等待此 ADR 而阻塞却从不写明其 id 的用户故事不会被找到，且会一直保持 `Blocked`，直到被手工更新
- `## GDD Requirements Addressed` 表格根据用户在协作会话中告诉技能的信息填充；如果用户不知道哪些 GDD 促使了该决策，此表格可能不完整——`/create-epics` 和 `/gate-check` 都依赖此链接实现可追溯性
- 只有**两个**来源都未设置时，才会跳过引擎专家验证（第 5.5 步）——`project.yaml` 中 `engine.name` 缺失或为空，**并且** `.claude/docs/technical-preferences.md` 仍为 `[TO BE CONFIGURED]`。仅通过 `project.yaml` 配置的项目**确实**会获得专家验证。当两者都未设置时，截止后引擎 API 风险不会在 ADR 写入前被捕获
- `docs/registry/architecture.yaml` 按设计仅可追加；如果某条立场条目永久失效（未被其他 ADR 取代），必须手动删除——没有清理机制
- 改造模式下，如果现有 ADR 的章节存在但为空（例如 `## Status` 标题没有值），技能会将该章节视为存在且不会填充——空的 Status 对 `/story-readiness` 等下游技能实际上不可见
