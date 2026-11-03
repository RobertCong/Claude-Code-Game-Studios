# /architecture-decision — 第 3a 与 3b 步：收集上下文

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## 3. 收集上下文

### 3a: 架构注册表检查（BLOCKING 质量闸门）—— 最先执行

读取 `docs/registry/architecture.yaml`。提取与此 ADR 的领域和决策相关的条目
（按系统名、领域关键词或涉及的状态 grep）。在读取任何现有 ADR 之前先运行此步骤——
注册表的存在正是为了让新 ADR 的作者无需打开之前的 ADR 就能了解其约束性事实
（状态归属、接口契约、禁止模式）。

在协作式设计开始**之前**，向用户展示所有相关立场，作为锁定约束：

```
## Existing Architectural Stances (must not contradict)

State Ownership:
  player_health → owned by health-system (ADR-0001)
  Interface: HealthComponent.current_health (read-only float)
  → If this ADR reads or writes player health, it must use this interface.

Interface Contracts:
  damage_delivery → signal pattern (ADR-0003)
  Signal: damage_dealt(amount, target, is_crit)
  → If this ADR delivers or receives damage events, it must use this signal.

Forbidden Patterns:
  ✗ autoload_singleton_coupling (ADR-0001)
  ✗ direct_cross_system_state_write (ADR-0000)
  → The proposed approach must not use these patterns.
```

如果用户提议的决策会与任何已注册立场矛盾，立即暴露该冲突：

> "⚠️ 冲突：此 ADR 提议 [X]，但 ADR-[NNNN] 已确立 [Y] 是
> 此用途的公认模式。不解决就继续会产生矛盾的 ADR
> 和不一致的用户故事。
> 选项：(1) 与现有立场对齐，(2) 用显式替代方案
> 取代 ADR-[NNNN]，(3) 说明为何此案例属于例外。"

在冲突解决或被明确接受为有意例外之前，不要进入第 4 步（协作式设计）。

### 3b: 现有 ADR 与相关 GDD —— 由注册表限定范围，绝无边界地读取

注册表（3a）涵盖先前决策约束了*什么*——并不总能涵盖*为什么*。如果注册表
浮现出某个直接相关的 ADR，且其推理在此重要（而不只是其陈述的事实），
就读取那个具体 ADR——绝不要用 glob 读取 `docs/architecture/` 中的每个
ADR 以期碰巧相关。按章节读取它：用 Grep 工具找到你需要的标题（pattern `^#`，content 模式），
再用 offset 和 limit 读取这些范围。

1. **先梳理其标题**（开销低）：
   ```
   Grep pattern="^## " path="docs/architecture/[adr-file].md" output_mode="content" -n
   ```
2. **约 40KB 以下**（`Bash: wc -c "docs/architecture/[adr-file].md"`）—— 一次完整
   `Read` 即可；在此大小下，每次调用的开销超过了有界读取节省的开销。
3. **约 40KB 或更大** —— 通过标题映射使用 `Read(offset, limit)` 仅
   有界读取 `## Context`、`## Decision` 和 `## Consequences`
   （承载推理而不只是事实的章节）。

按 `/design-system` 第 2b 步的方式读取 GDD：只读注册表
或 ADR 列表点名为直接相关的 GDD，且只读其 `## Dependencies`、
`## Formulas` 和 `## Edge Cases` 章节
（`Grep pattern="^## (Dependencies|Formulas|Edge Cases)" ... -A 40`）——
绝不要投机性地完整读取 `design/gdd/*.md` 去寻找任何可能相关的内容。

如果注册表已经回答了此决策所需的一切，就完全跳过 3b——大多数 ADR 都会如此。

---
