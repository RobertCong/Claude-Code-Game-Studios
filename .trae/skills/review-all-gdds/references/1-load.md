# /review-all-gdds — Phase 1: 加载全部内容

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 1: 加载全部内容

**本文件包含：**

- Phase 1a — L0：摘要扫描（快速、低 token）
- Phase 1b — 注册表预加载（快速基线）
- Phase 1c — L1/L2：章节加载

### Phase 1a — L0：摘要扫描（快速、低 token）

在读取任何完整文档之前，先用 Grep 从所有 GDD 文件中提取 `## Summary` 章节：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 5
```

**在缺少 Summary 时按开放处理（fail open）。** 确定分母：用 glob 匹配 `design/gdd/*.md` 并计数为 **N**。匹配数少于 N 意味着这些 GDD 早于 `## Summary` 的引入 — 绝不要把缺失的 Summary 视为系统不在范围内。零匹配意味着"还没有任何 GDD 带有 Summary"，而不是"没有可评审的内容"。本评审是整体性的，无论如何都会加载其范围内的 GDD（见 Phase 1c）；Summary 扫描只构建清单并缩小 `since-last-review` 的范围，绝不缩小评审集合。

向用户展示一份清单：
```
Found [N] GDDs. Summaries:
  • combat.md — [summary text]
  • inventory.md — [summary text]
  ...
```

对于 `since-last-review` 模式，以确定性的方式计算范围，而不是靠推理 git 历史：

```
Bash: bash .trae/scripts/review-scope.sh
```

它会打印 `PRIOR_REVIEW:`、一个 `CHANGED:` 列表，以及每个被修改 GDD 所声明依赖的 `DEPS ...:` 列表。将这些列表作为范围 — 依赖行已经是"Key deps"的展开，无需再跑一遍。如果 `PRIOR_REVIEW: NONE`，则需要进行完整评审；回退到 `full` 模式。

在进行任何完整读取之前，基于摘要向用户展示哪些 GDD 在范围内。只对 `CHANGED` 集合以及 `DEPS` 行中列出的 GDD 继续执行 L1。

### Phase 1b — 注册表预加载（快速基线）

在完整读取任何 GDD 之前，检查是否存在实体注册表：

```
Read path="design/registry/entities.yaml"
```

如果注册表存在且有条目，将其用作**预构建的冲突基线**：已知实体、物品、公式和常量及其权威值和来源 GDD。在 Phase 2 中，先在 GDD 中 grep 已注册的名称 — 这比在还不知道要找什么的情况下完整读取所有 GDD 更快。

如果注册表为空或不存在：不使用它继续。在报告中注明：
"实体注册表为空 — 一致性检查仅依赖完整读取 GDD。在本次评审之后运行 `/consistency-check` 以填充注册表。"

### Phase 1c — L1/L2：章节加载

完整读取（体量小，且每一部分都会用到）：

1. `design/gdd/game-concept.md` — 游戏愿景、核心循环、MVP 定义（或在 `rigor: minimal` 下替代它的单页简报 `design/game-brief.md` — 提案、核心循环、MVP 清单）
2. `design/gdd/game-pillars.md`（若存在）— 设计支柱与反支柱
3. `design/gdd/systems-index.md` — 权威系统列表、层级、依赖、状态

按章节读取每个文档：用 Grep 工具查找标题（pattern `^#`，content 模式），再用 offset 和 limit 读取这些范围。完整读取一个文档也是以同样方式按范围读取，因为超过 40 KB 的整文件 Read 会被拒绝。

然后，对**每个范围内的系统 GDD**，只加载本次评审实际消费的章节 — **不是整个文件**：

```
Grep pattern="^## (Dependencies|Detailed Rules|Detailed Design|Formulas|Tuning Knobs|Acceptance Criteria|Player Fantasy)" glob="design/gdd/*.md" output_mode="content" -A 40
```

这份列表不是猜测 — 它正是下文并行执行契约已经列举的并集：Phase 2 需要 Dependencies、Detailed Design/Rules、Formulas、Tuning Knobs 和 Acceptance Criteria；Phase 3 需要 Player Fantasy 以及成长/奖励结构。Overview 是本技能已在 Phase 1a 中扫描过的 Summary 所复述的叙述内容，Edge Cases 在此处不服务于任何检查清单条目（`/design-review` 负责单个 GDD 的完整性）。加载它们会把内容塞进三个上下文窗口 — 本窗口和两个子代理的窗口 — 而没有任何检查清单条目会读取这些内容。

接受 `## Detailed Rules` **或** `## Detailed Design` 中的任意一个；设计标准与 GDD 模板对该名称不一致，但它们指的是同一章节。

**当被扫描的章节交叉引用了自身之外的材料，或某个 GDD 匹配到零个章节时，升级为完整读取该 GDD** — 那个 GDD 早于模板，那里的零匹配意味着"无结构"，而不是"空"。绝不能让零匹配悄悄丢弃一个系统：扫描只缩小*读取*范围，绝不缩小*评审集合*。

报告："Loaded [N] system GDDs covering [M] systems. Pillars: [list]. Anti-pillars: [list]."

如果存在的系统 GDD 少于 2 个（按现有文件计数；空文件在 Phase 5 的 NOT ASSESSED 下处理，不在此处），则停止：
> "Cross-GDD review requires at least 2 system GDDs. Write more GDDs first,
> then re-run `/review-all-gdds`."

---
