# /create-architecture — Phase 5: ADR 审计与可追溯性检查

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 5: ADR 审计 + 可追溯性检查

对照 Phase 1-4 中构建的架构**以及** Phase 0b 的技术需求基线，
审查 Phase 0c 中的所有现有 ADR。

### ADR 质量检查

对每个 ADR：
- [ ] 它是否有 Engine Compatibility 章节？
- [ ] 是否记录了引擎版本？
- [ ] 是否标出了截止后 API？
- [ ] 它是否有 "GDD Requirements Addressed" 章节？
- [ ] 它是否与本次会话所做的层级/归属决策冲突？
- [ ] 它对于锁定的引擎版本是否仍然有效？

| ADR | 引擎兼容 | 版本 | GDD 链接 | 冲突 | 有效 |
|-----|--------------|---------|-------------|-----------|-------|
| ADR-0001: [标题] | ✅/❌ | ✅/❌ | ✅/❌ | 无/[冲突] | ✅/⚠️ |

### 可追溯性覆盖率检查

将技术需求基线中的每条需求映射到现有 ADR。
对每条需求，检查是否有任何 ADR 的 "GDD Requirements Addressed" 章节
或决策文本覆盖它：

| 需求 ID | 需求 | ADR 覆盖 | 状态 |
|--------|-------------|--------------|--------|
| TR-combat-001 | 逐帧命中框检测 | ADR-0003 | ✅ |
| TR-combat-002 | 连招状态机 | — | ❌ GAP |

计数：X 条已覆盖，Y 个缺口。每个缺口都会成为一项**必需的新 ADR**。

### 必需的新 ADR

列出本次架构会话（Phase 1-4）中做出、但尚无对应 ADR 的所有决策，
**再加上**所有未覆盖的技术需求。
按层分组 —— Foundation 优先：

**Foundation 层（任何编码之前必须创建）：**
- `/architecture-decision [title]` → 覆盖：TR-[id]、TR-[id]

**Core 层：**
- `/architecture-decision [title]` → 覆盖：TR-[id]

---
