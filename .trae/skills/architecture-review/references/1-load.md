# /architecture-review — Phase 1: 加载全部内容

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 1: 加载全部内容

**本文件包含：**

- Phase 1a — L0：摘要扫描（快速、低 token 消耗）
- Phase 1b — L1/L2：定向章节加载
- 设计文档
- 架构文档
- 引擎参考资料
- 项目标准

### Phase 1a — L0：摘要扫描（快速、低 token 消耗）

**扫描前先做新鲜度检查。** 上一份报告只有在其所依赖的任何内容都未发生变化时，才能
代表本次运行：文档、引擎参考资料、项目配置、本技能，以及产出它的评审类型。

在 `rtm` 模式下，跳过此检查并说明 —— *"Freshness check: not run — rtm
builds the matrix fresh, because stories and tests change without any review
input changing."*

否则定位最近的上一次报告 —— Glob
`docs/architecture/architecture-review-*.md` 并取最新的 —— 然后检查
**评审输入**：下方各阶段读取的、可能改变某项发现或结论的每个文件。`[engine]` 是
`project.yaml` 中 `engine.name` 的小写形式，即 Phase 5 使用的值；如果未配置引擎，
则把那两个引擎参考路径排除在外。

```
Bash: bash .trae/scripts/review-receipts.sh check "[latest-report]" docs/architecture/adr-*.md design/gdd/*.md docs/architecture/tr-registry.yaml docs/architecture/architecture.md docs/engine-reference/[engine]/*.md docs/engine-reference/[engine]/modules/*.md project.yaml .trae/docs/technical-preferences.md docs/consistency-failures.md .trae/skills/architecture-review/SKILL.md .trae/skills/architecture-review/references/*.md
```

Phase 8 会将同一份列表写入本次运行的报告；保持两处完全一致，并把任何阶段开始读取的
文件同时加入两处。该检查还会比对上一份报告打戳的所有文件（无论此处是否列出），并对
已不存在的文件打印 `GONE:`。

然后读取上一份报告的 `Mode:` 与 `Workflow:` 行。只有当它的 Mode 与本次运行的模式
相同（对 `single-gdd` 而言是同一路径）或为 `full`，且它的 Workflow 是本次运行解析出的
`workflow` 或 `full` 时，它才**覆盖**本次运行。没有这些行的报告写于它们存在之前，
不覆盖任何内容。

- **任何 `UNRESOLVED`** —— 首先检查此项；它会使下面的所有选项失效。某个 glob 没有
  匹配到任何文件，因此整个该类文档从未被检查，比对覆盖的范围比看起来要少。说明哪个
  模式返回了 unresolved，既不要依赖上一份报告，也不要据此限定重跑范围：一个空的、
  被重命名或拼错的 ADR 或 GDD 目录本身就是关于项目的一项发现。按请求运行评审；其
  结论对缺失的类别为 NOT ASSESSED（Phase 7），绝不是不产出任何报告的停止。当存在
  `UNRESOLVED` 行时，绝不要把一组 `UNCHANGED` 行读作"一切都是最新的" —— 被比对的
  集合并不是所请求的集合。
- **上一份报告不覆盖本次运行** —— 其次检查此项，无论其他行怎么说。说明原因：*"上次
  报告是 [mode] 评审，工作流为 [tier]；它不覆盖本次运行。"* 按请求运行评审。绝不
  提议依赖它或据此限定重跑范围。
- **全部 `UNCHANGED`** —— 自那份报告以来，本次评审读取的所有内容都没有变化；重跑
  只会得到相同结果。呈现上一份报告的日期、模式与结论，并通过 `AskUserQuestion`
  提供：`[A] Stand on the prior report (Recommended)` / `[B] Re-run the full
  review anyway` —— `guided` 选择 [A] 继续并记录；`autonomous` 通过 `log_decision`
  记录并依赖上一份报告。
- **仅 GDD 或 ADR 为 `CHANGED`/`NEW`** —— 指出它们，然后限定范围而非重跑全部：
  建议对变更的系统运行 `/architecture-review single-gdd [path]`。仍可按请求进行完整
  重跑，而 `NEW` 的 ADR 值得一次完整重跑。
- **其他任何内容为 `CHANGED`、`NEW` 或 `GONE`** —— 被删除的 GDD 或 ADR、TR 注册表、
  `architecture.md`、引擎参考资料、`project.yaml`、`technical-preferences.md`、
  `consistency-failures.md`，或本技能自身的文件。这些会影响每个阶段，因此建议按请求
  重跑评审，绝不要用 `single-gdd` 范围，并指出每个输入及其影响 —— 例如 *"The engine
  reference changed after the last report: its deprecated-API audit, which
  `/gate-check` reads, was made against the old one."*
- **`RECEIPT: NONE`** —— 没有上一份报告，或报告写于 receipt 存在之前。继续完整评审；
  本次运行的报告将带上第一批戳记。

在读取任何完整文档之前，使用 Grep 从所有 GDD 与 ADR 中提取 `## Summary` 章节：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 4
Grep pattern="## Summary" glob="docs/architecture/adr-*.md" output_mode="content" -A 3
```

**对缺失的 Summary 采取宽松处理。** 确立分母：glob
`design/gdd/*.md` 并计数为 **N**。匹配数少于 N 的扫描意味着那些 GDD 早于
`## Summary`（`/design-system` 会输出它，但较旧的 GDD 没有）—— 绝不要把缺失的
Summary 当作系统不在范围内。零匹配的扫描意味着"还没有 GDD 带有 Summary"，而不是
"没有可评审的内容"：对未匹配的集合进行完整读取。

对于 `single-gdd [path]` 模式：使用目标 GDD 的摘要来确定哪些 ADR 引用了同一系统
（对 ADR Grep 系统名称），然后按 Phase 1b 仅加载那些 ADR 的章节。完全跳过无关的 GDD。

对于 `engine` 模式：仅加载 ADR 章节 —— 引擎检查不需要 GDD。实践中这仅是
`## Engine Compatibility` 扫描。

对于 `coverage` 或 `full` 模式：进入 Phase 1b 处理完整的在范围内集合。
**这是章节加载，不是整文件加载** —— 原因见下，以及仍然值得升级为整份文档的少数
狭窄情形。

### Phase 1b — L1/L2：定向章节加载

加载后续阶段实际使用的章节 —— **不是整份文件**。本技能读取项目中最大的两个文档集合
（每一个 GDD *和* 每一个 ADR）；按实际规模，两者的完整加载会在 Phase 2 开始前就耗尽
上下文窗口，而且所加载的大部分内容是本技能从不使用的叙事。

**先确立分母。** Glob `design/gdd/*.md` 并计数为 **N_gdd**；
glob `docs/architecture/adr-*.md` 并计数为 **N_adr**。两者都报告。匹配数少于分母的
章节扫描意味着那些文档缺少该章节 —— **绝不要把缺失的章节当作缺失的文档。** 扫描
缩小的是*读取*集合；它从不缩小*在范围内*集合。

### 设计文档

Phase 2 提取*技术需求* —— 数据结构、性能约束、引擎能力、跨系统通信、持久化、
线程、平台需求。这些存在于一组已知章节中；Overview 与 Player Fantasy 是叙事，
不产生任何技术需求。

```
Grep pattern="^## (Detailed Rules|Detailed Design|Formulas|Dependencies|Tuning Knobs|Acceptance Criteria)" glob="design/gdd/*.md" output_mode="content" -A 40
```

接受 **`## Detailed Rules` 或 `## Detailed Design` 任一** —— 设计标准与 GDD 模板对
该名称不一致，但它们指代同一个必需章节。只有在被扫描的章节交叉引用了自身之外的
材料时，或某个 GDD 匹配到零个章节时（它早于模板 —— 整份读取并说明），才完整读取
单个 GDD。

- `design/gdd/systems-index.md` —— 系统的权威列表；整份读取（很小，且它是索引）

### 架构文档

Phase 3–5 需要可追溯性表格、决策本身、引擎主张以及依赖边 —— 不需要 Context、
Consequences、Alternatives、Migration Plan 或 Validation Criteria，它们解释的是
*为什么* 做出某项决策。

```
Grep pattern="^## (Status|Decision|GDD Requirements Addressed|Engine Compatibility|ADR Dependencies|Performance Implications)" glob="docs/architecture/adr-*.md" output_mode="content" -A 30
```

对照 **N_adr** 进行解读，并区分两种零匹配情形 —— 它们不是同一种发现：

| 结果 | 含义 | 操作 |
|---|---|---|
| N_adr 匹配 | 正常。 | 基于已扫描的章节继续。 |
| 部分 ADR 匹配，部分不匹配 | 那些 ADR 缺少章节。 | 在 Phase 7 报告中把每一个记为**结构性缺口** —— 缺失 `## GDD Requirements Addressed` 本身就是一项可追溯性发现。 |
| **0 匹配，N_adr > 0** | **格式错误的 ADR**，而不是"没有架构"。 | "[N_adr] ADRs found, none carries a scannable section — run `/architecture-decision retrofit [file]` on each." 请**不要**报告零覆盖；那会被读作设计失败，而实际上是格式失败。 |

只有在判断冲突需要其推理时（Phase 4），才升级为完整读取某个 ADR —— 这是针对单个
ADR 的决定，不是一刀切的全量加载。

- 如果存在 `docs/architecture/architecture.md`，则读取它

### 引擎参考资料
- `docs/engine-reference/[engine]/VERSION.md`
- `docs/engine-reference/[engine]/breaking-changes.md`
- `docs/engine-reference/[engine]/deprecated-apis.md`
- **只读取在范围内 ADR 实际指名的模块文档** —— 取每个 ADR 的 `References Consulted`
  与 `Post-Cutoff APIs Used` 字段的并集（上面 `## Engine Compatibility` 扫描已捕获）
  并读取那些文件。读取整个 `modules/` 目录会加载项目可能根本不使用的引擎子系统。
  如果没有 ADR 指名任何模块，则不读取任何模块并注明：Phase 5 无法交叉检查从未提出
  过的引擎主张。

### 项目标准
- `project.yaml` —— `naming.*` 与 `performance.*`；另外当这些键缺失时读取
  `.trae/docs/technical-preferences.md`，以及禁止的模式 / 允许的库

报告数量："Loaded [N] GDDs, [M] ADRs, engine: [name + version]."

**同时读取 `docs/consistency-failures.md`**（如果存在）。提取 Domain 与正在评审的
系统（Architecture、Engine，或任何被覆盖的 GDD 领域）匹配的条目。在 Phase 4 冲突
检测输出的顶部，把反复出现的模式作为"Known conflict-prone areas"注释呈现。

---
