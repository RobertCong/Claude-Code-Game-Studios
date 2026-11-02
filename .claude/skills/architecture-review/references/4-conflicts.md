# /architecture-review — Phase 4: 跨 ADR 冲突检测

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 4: 跨 ADR 冲突检测

把每个 ADR 与其他每个 ADR 进行比较，以检测矛盾。当以下情况出现时，即存在冲突：

- **数据所有权冲突**：两个 ADR 都声称独占拥有同一数据
- **集成契约冲突**：ADR-A 假设系统 X 拥有接口 Y，但 ADR-B 以不同的接口定义系统 X
- **性能预算冲突**：ADR-A 为物理分配 N ms，ADR-B 为 AI 分配 N ms，二者合计超出总帧预算
- **依赖环**：ADR-A 说系统 X 在 Y 之前初始化；ADR-B 说 Y 在 X 之前初始化
- **架构模式冲突**：ADR-A 对某子系统采用事件驱动通信；ADR-B 对同一子系统采用直接函数调用
- **状态管理冲突**：两个 ADR 对同一游戏状态定义权威（例如 Combat ADR 与 Character ADR
  都声称拥有生命值）

对发现的每个冲突：

```
## Conflict: [ADR-NNNN] vs [ADR-MMMM]
Type: [Data ownership / Integration / Performance / Dependency / Pattern / State]
ADR-NNNN claims: [...]
ADR-MMMM claims: [...]
Impact: [What breaks if both are implemented as written]
Resolution options:
  1. [Option A]
  2. [Option B]
```

### ADR 依赖排序

冲突检测之后，分析所有 ADR 之间的依赖图。

**以确定性的方式构建图 —— 不要手动追踪：**

```
Bash: bash .claude/scripts/adr-dep-graph.sh
```

它收集每条 `Depends On` 边，找出环与顺序，并输出
`ADRS:` / `EDGES:` / `NO_DEPS_SECTION:` / `UNFILLED_DEPS:` / `CYCLE:` /
`BLOCKED_BY_CYCLE:` / `ORDER:`。一个模型在十几个 ADR 之间追踪 A→B→C→A 最终会漏掉
一条边；算法不会。它报告的是观察结果，而非结论 —— 由你套用下面的含义。

**`NO_DEPS_SECTION` 与 `UNFILLED_DEPS` 是关键项**：它们使"没有环，因为图是干净的"
与"没有环，因为一半 ADR 未声明依赖，或把模板的占位符留在了行里"变得可区分。把第二种
情况报告为结构性缺口，绝不要报告为干净的图，并把每个 `UNFILLED_DEPS` ADR 指名为未填写：
它依赖什么未知，而不是没有依赖。

然后进行解读：

1. **拓扑排序**：按输出的 `ORDER:` 行 —— 无依赖的 ADR 排在前（Foundation），依赖
   它们的 ADR 排在其后，依此类推。不要手动重新排序。处于 `NO_DEPS_SECTION` 或
   `UNFILLED_DEPS` 中的 ADR 会像不依赖任何东西一样留在其中：请标注出来。
2. **标记未解决的依赖**：把 `EDGES:` 列表与 Phase 1b 中已扫描的 `## Status` 值
   交叉检查。如果 ADR-A 依赖的 ADR 仍为 `Proposed` 或不存在，则标记出来：
   ```
   ⚠️  ADR-0005 depends on ADR-0002 — but ADR-0002 is still Proposed.
       ADR-0005 cannot be safely implemented until ADR-0002 is Accepted.
   ```
3. **环检测**：脚本输出的每一条 `CYCLE:` 行都是一个
   `DEPENDENCY CYCLE` —— 逐一报告，附上其行中显示的边（其中一条就是要切断的边）。
   一个 `BLOCKED_BY_CYCLE:` ADR 不在任何环上：它在等待某个环被解开，因此把它列为
   被阻塞，绝不要列为环的一部分，也绝不要建议切断它自己的边。不要手动重新推导它们：
   ```
   🔴 DEPENDENCY CYCLE: ADR-0003 → ADR-0006 → ADR-0003
      This cycle must be broken before either can be implemented.
   ```
4. **输出建议的实施顺序**：
   ```
   ### Recommended ADR Implementation Order (topologically sorted)
   Foundation (no dependencies):
     1. ADR-0001: [title]
     2. ADR-0003: [title]
   Depends on Foundation:
     3. ADR-0002: [title] (requires ADR-0001)
     4. ADR-0005: [title] (requires ADR-0003)
   Feature layer:
     5. ADR-0004: [title] (requires ADR-0002, ADR-0005)
   ```

---
