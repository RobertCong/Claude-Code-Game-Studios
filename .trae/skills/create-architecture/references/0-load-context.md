# /create-architecture — Phase 0: 加载全部上下文

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 0: 加载全部上下文

**本文件包含：**

- 0a. 引擎上下文（关键）
- 0b. 设计上下文 + 技术需求提取
- 0c. 现有架构决策
- 0d. 生成知识缺口清单
- 0e. 现有架构文档

在做任何其他事情之前，按以下顺序加载完整的项目上下文：

### 0a. 引擎上下文（关键）

完整读取四份项目级引擎文档 —— 它们都很小，且每份的每个部分都会被用到：

1. `docs/engine-reference/[engine]/VERSION.md`
   → 提取：引擎名称、版本、LLM 截止日期、截止后风险等级
2. `docs/engine-reference/[engine]/breaking-changes.md`
   → 提取：所有 HIGH 和 MEDIUM 风险变更
3. `docs/engine-reference/[engine]/deprecated-apis.md`
   → 提取：应避免的 API
4. `docs/engine-reference/[engine]/current-best-practices.md`
   → 提取：与训练数据不同的截止后最佳实践

然后**只读取此游戏实际使用的领域对应的模块文档** ——
而不是整个 `modules/` 目录：

5. `docs/engine-reference/[engine]/modules/` —— 用 glob 确认存在哪些文件，
   然后与 `design/gdd/systems-index.md` 中出现的领域进行匹配
   （与 ADR 模板相同的领域词汇：Physics、Rendering、UI、
   Audio、Navigation、Animation、Networking、Core、Input）。读取匹配的
   模块；跳过其余部分。
   → 提取：每个领域的当前 API 模式

   没有多人系统的游戏无需为撰写架构而加载网络模块，
   而加载它的成本与有该系统的游戏相同。
   **如果领域匹配存在歧义，就读取该模块** —— 在这里漏掉一条引擎
   约束，代价远高于一次冗余读取，因为此阶段正是这些约束
   被固化进架构的地方。

如果未配置引擎，停下并提示：
> "未配置引擎。请先运行 `/setup-engine`。在不知道目标引擎和版本的情况下，
> 无法撰写架构。"

### 0b. 设计上下文 + 技术需求提取

加载已批准的设计文档，并从每份文档中提取技术需求。
按章节读取每一份：用 Grep 工具找到你需要的标题（pattern
`^#`，content 模式），再用 offset 和 limit 读取这些范围。

1. `design/gdd/game-concept.md` —— 游戏支柱、类型、核心循环
2. `design/gdd/systems-index.md` —— 所有系统、依赖、优先级层级

**在读取任一份之前先检查二者都存在。二者在此都不是可选的，且二者
都需要缺失分支** —— §0a 会因未配置引擎而停止，这两份同样重要：

- **`systems-index.md` 缺失** —— 停下：
  > "未找到系统索引。请先运行 `/map-systems`。在没有它的情况下撰写的架构，
  > 会为无人映射过的系统编造层级，而下游的每个 ADR、史诗和
  > 用户故事都会继承这套编造。"
  在 `minimal` 下索引不是必需的（SKILL.md 中的 `workflow` 列表）—— 说明这一点，并改为
  从简报继续。
- **`game-concept.md` 缺失** —— 在 `standard`/`full` 下，停下并指向
  `/brainstorm`。在 `minimal` 下，改为读取 `design/game-brief.md`；如果它
  也缺失，停下 —— 没有可用于架构的设计记录。
- **任一存在但为空或仍是模板占位符** —— 按缺失处理。
  存在但为空，是最像"存在"的情况。

不要基于部分读取继续、事后再记一笔。此阶段正是设计假设
被固化进 ADR 的地方，而在此做出的假设会被下游所有内容
重新推导，而不是被重新检查。
3. 项目配置 —— 来自 `project.yaml` 的 `naming.*` 和 `performance.*`（任何
   缺失或为空的键，回退到 `.claude/docs/technical-preferences.md`）；
   允许的库和禁止的模式来自
   `.claude/docs/technical-preferences.md`（尚未迁移到 project.yaml）
4. **`design/gdd/` 中的每个 GDD** —— 从承载技术需求的章节中提取
   技术需求，**而不是从整个文件**。先确定分母
   （glob `design/gdd/*.md`，计数 **N**），然后：
   ```
   Grep pattern="^## (Detailed Rules|Detailed Design|Formulas|Dependencies|Tuning Knobs|Acceptance Criteria)" glob="design/gdd/*.md" output_mode="content" -A 40
   ```
   Overview 和 Player Fantasy 是叙事性的，不隐含任何架构；
   被扫描的集合才是规则、数值和跨系统契约所在之处。接受
   `## Detailed Rules` 或 `## Detailed Design` 任一种 —— 设计标准
   与 GDD 模板对此名称不一致，但它们指同一章节。

   当一个 GDD 匹配**零**个章节时（它早于模板 ——
   零匹配意味着"非结构化"，绝不是"无需求"），或当被扫描的
   章节引用了自身之外的材料时，完整读取该 GDD。**绝不要把缺失章节当作
   缺失需求**：报告任何没有贡献的 GDD，而不是
   让它从下面的基线中静默消失。

   对每一项，提取：
   - 游戏规则隐含的数据结构
   - 陈述或隐含的性能约束
   - 系统所需的引擎能力
   - 跨系统通信模式（谁与谁通信、如何通信）
   - 必须持久化的状态（存档/读档影响）
   - 线程或时序要求

构建一份**技术需求基线（Technical Requirements Baseline）** —— 跨所有 GDD 提取的
全部需求的平铺列表，编号为 `TR-[system]-[NNN]`，即 TR 注册表的
ID 格式。这是架构必须覆盖的完整集合。

**ID 来自 TR 注册表，而不是重新计数。** 用户故事和 ADR
会引用 TR-ID，`/architecture-review` 会在
`docs/architecture/tr-registry.yaml` 中保持其永久性。在重跑时从 001 开始编号的基线
会给某条需求分配与用户故事已引用不同的 ID。因此，在编号之前：

- **注册表存在且有条目：** 读取 `docs/architecture/tr-registry.yaml`。
  与同一系统的 `active` 条目匹配的需求（意图相同，
  措辞可能不同）保留该条目的 ID。跳过 `deprecated` 和
  `superseded-by` 条目；它们是因故退役的。其他所有需求
  都是**临时的**：从 `bash .claude/scripts/registry.sh next-id tr
  <system>` 开始编号，这样它不会重用已注册或已退役的 ID，并标记为
  `(provisional)`。`/architecture-review` 会注册它并赋予永久 ID。
- **注册表缺失，或 `requirements: []`：** 每个 ID 都是临时的。在
  基线的标题行中说明这一点，以免有人把它们当作永久 ID 引用。

将其呈现为：

```
## Technical Requirements Baseline
Extracted from [N] GDDs | [X] total requirements | [R] registered, [P] provisional
(TR registry: [read, E entries | absent | empty])

| Req ID | GDD | System | Requirement | Domain |
|--------|-----|--------|-------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox detection per-frame | Physics |
| TR-combat-002 | combat.md | Combat | Combo state machine | Core |
| TR-inventory-001 (provisional) | inventory.md | Inventory | Item persistence | Save/Load |
```

此基线会输入到后续每个阶段。到本次会话结束时，不应有任何 GDD 需求
缺少支撑它的架构决策。

### 0c. 现有架构决策

为了解**已经决定了什么以及属于哪个领域**，扫描 ADR
头部 —— 不要为生成一份编号和领域列表而完整读取每个 ADR：
```
Grep pattern="^## (Status|Summary)" glob="docs/architecture/adr-*.md" output_mode="content" -A 4
Grep pattern="\*\*Domain\*\*" glob="docs/architecture/adr-*.md" output_mode="content"
```
`## Summary`（两句式的"是什么与为什么"）加上 `## Status` 和 Engine
Compatibility 的 `Domain` 字段，恰好就是"决定了什么及其领域"。列出
扫描找到的 ADR、其状态和领域。只有本次会话的新决策会与某个
具体 ADR 冲突、且你需要其推理时，才完整读取该 ADR —— 而不是为了构建清单。按章节读取它：
用 Grep 工具找到标题（pattern `^#`，content 模式），再用 offset 和 limit
读取这些范围。

### 0d. 生成知识缺口清单

在继续之前，显示结构化摘要：

```
## Engine Knowledge Gap Inventory
Engine: [name + version]
LLM Training Covers: up to approximately [version]
Post-Cutoff Versions: [list]

### HIGH RISK Domains (must verify against engine reference before deciding)
- [Domain]: [Key changes]

### MEDIUM RISK Domains (verify key APIs)
- [Domain]: [Key changes]

### LOW RISK Domains (in training data, likely reliable)
- [Domain]: [no significant post-cutoff changes]

### Systems from GDD that touch HIGH/MEDIUM risk domains:
- [GDD system name] → [domain] → [risk level]
```

使用 `AskUserQuestion`：
- 提示："一个或多个引擎领域为 HIGH RISK —— LLM 在这些领域的知识可能不可靠。这些领域的架构建议在付诸行动前应与引擎文档交叉核对。你希望如何继续？"
- 选项：
  - `[A] 继续 —— 在输出中全程标出 HIGH RISK 领域`
  - `[B] 让我先查阅引擎参考 —— 在此暂停`
  - `[C] 告诉我哪些领域是 HIGH RISK 以及原因`

### 0e. 现有架构文档

Glob `docs/architecture/architecture.md`。如果存在，本次运行会更新它 ——
绝不未经询问就替换它。读取其 `## Document Status` 块和 `##`
标题，然后使用 `AskUserQuestion`：
- 提示："架构文档已存在（v[N]，[最后更新日期]）。本次运行应做什么？"
- 选项：`[A] 原地更新选定章节` / `[B] 重写整个文档 —— 替换现有文件` / `[C] 停止`

选择 `[A]` 时，询问哪些章节。Phase 1–6 只撰写这些章节，并说明跳过了哪些；
Phase 7 只替换这些章节，并将 `Version` 提升为 N+1，
其余每个章节保持原样。`[B]` 运行完整走查，且
Phase 7 的询问会说明它将替换现有文件。

聚焦领域参数（`layers`、`data-flow`、`api-boundaries`、`adr-audit`）
就是选中某一章节的 `[A]`：它只运行其对应阶段（1、3、4 或 5），
并由 Phase 7 写入该章节。Phase 7b 仍会针对更新后的文档运行 ——
更新会像初稿一样被评审，采用会评审的评审模式。若没有现有文档，
就没有可更新的内容 —— 说明这一点，并改为提供完整走查。

---
