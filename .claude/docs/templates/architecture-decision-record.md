# ADR-[NNNN]: [Title]

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

> **谁可以将状态改为 `Accepted`：用户本人，或在用户明确确认后的 `technical-director`。
> 其他任何代理都不可以，任何技能也不得自行修改。**
> 在此写明的原因：引用 `Proposed` 状态 ADR 的用户故事会被置为 `Blocked`，
> 而史诗要求 ADR 为 `Accepted`，因此该字段需要有明确的责任人。
> `coordination-rules.md` 本就把技术冲突上报给 `technical-director`，
> 而 ADR 正是把该决策固化下来的形式。
>
> 这并**不**放松既有规则——没有用户明确确认，绝不设置 `Status: Accepted`；
> 它只是收窄了"确认之后由哪个代理来设置"。代理若认为某个 ADR 已就绪，
> 应当说明并上报，而不是直接编辑该字段。

## Date

[决策日期]

## Last Verified

[YYYY-MM-DD —— 本 ADR 最后一次确认与当前引擎版本和设计一致的时间。
当你重新阅读并确认它仍然正确时更新此日期，即使内容没有任何变化。]

## Decision Makers

[参与该决策的人员]

## Summary

[2 句话：本 ADR 解决了什么问题，以及最终决定了什么。为分层上下文加载而写——
扫描 20 份 ADR 的技能会用它判断是否需要读完整决策。要具体：点名系统、问题和所选方案。]

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | [e.g. Godot 4.7] |
| **Domain** | [Physics / Rendering / UI / Audio / Navigation / Animation / Networking / Core / Input] |
| **Layer** | [Foundation / Core / Feature / Presentation] |
| **Knowledge Risk** | [LOW / MEDIUM / HIGH — from VERSION.md] |
| **References Consulted** | [列出已阅读的引擎参考资料文档，例如 `docs/engine-reference/godot/modules/physics.md`] |
| **Post-Cutoff APIs Used** | [本决策依赖的、出自 LLM 训练截止后版本的 API；没有则写 "None"] |
| **Verification Required** | [上线前需要测试的具体行为；没有则写 "None"] |

> **Note**：若 Knowledge Risk 为 MEDIUM 或 HIGH，项目升级引擎版本时必须重新验证本 ADR。
> 将其标记为 "Superseded"，并编写新的 ADR。

> **`Layer` 指的是 ADR 自身的层级，而不是引用它的史诗的层级——它与 `Domain`
> 是两套不同的分类。** 多个位置会依据 ADR 是否为*关键（Foundation 层）*来分支：
> `/create-stories`、`/create-epics`、`/architecture-decision`、`/story-readiness`、
> `/propagate-design-change` 以及 `gate-pre-production.md`；缺失该行会被视为关键。
> 在 `standard` 档位下，`/create-stories` 遇到缺失的关键 ADR 会**停止**，
> 对非关键 ADR 只**警告**，因此这一行决定了运行是否中断。不要从引用它的史诗
> 推断层级：Foundation 层的 ADR 常被 Core 层的史诗引用，那样会得出错误答案。
>
> 这套词汇就是史诗和用户故事已经在用的 `Foundation / Core / Feature / Presentation`——
> 不要发明第五个值，也不要在此复用 `Domain` 的值。`Domain` 表示*它触及引擎的哪个部分*；
> `Layer` 表示*它必须在构建的哪个阶段早期存在*。

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN（必须先为 Accepted 才能实现本 ADR），或 "None"] |
| **Enables** | [ADR-NNNN（本 ADR 解锁了该决策），或 "None"] |
| **Blocks** | [史诗/用户故事名称——在本 ADR 为 Accepted 之前无法开始，或 "None"] |
| **Ordering Note** | [上面未涵盖的任何排序约束] |

## Context

### Problem Statement
[我们要解决什么问题？为什么这个决策必须现在做出？]

### Current State
[系统目前如何运作？当前做法有什么问题？]

### Constraints
- [技术约束]
- [时间约束]
- [资源约束]
- [兼容性要求]

### Requirements
- [必须支持 X]
- [必须在 Y 预算内运行]
- [必须与 Z 集成]

## Decision

[所做出的具体技术决策，描述详细到他人可以据此实现。]

### Architecture Diagram
[本决策所产生的系统架构的 ASCII 图或描述]

### Key Interfaces
[本决策产生的 API 契约或接口定义]

### Implementation Guidelines
[给实现该决策的程序员的具体指导——`/create-control-manifest` 或 `/dev-story`
运行时应遵循的规则。用"必须 / 绝不可"陈述强制要求，以便能被清晰提取。]

## Alternatives Considered

### Alternative 1: [Name]
- **Description**: [该方案会如何运作]
- **Pros**: [优点]
- **Cons**: [缺点]
- **Estimated Effort**: [与所选方案相比的相对工作量]
- **Rejection Reason**: [为何未被选中]

### Alternative 2: [Name]
- **Description**: [该方案会如何运作]
- **Pros**: [优点]
- **Cons**: [缺点]
- **Estimated Effort**: [与所选方案相比的相对工作量]
- **Rejection Reason**: [为何未被选中]

## Consequences

### Positive
- [该决策带来的良好结果]

### Negative
- [已接受的取舍与代价]

### Neutral
- [无所谓好坏、只是有所不同的变化]

## Risks
- [可能出错的地方]
- [每个风险的缓解措施]

## GDD Requirements Addressed

<!-- 本节为必填。每份 ADR 都必须追溯到至少一条 GDD 需求，
     或明确说明它是无 GDD 依赖的基础性决策。可追溯性由 /architecture-review 审计。 -->

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| [system-name].md | [该 GDD 中的具体规则、公式或性能约束] | [本决策如何满足它] |

> 如果这是一项没有直接 GDD 依赖的基础性决策，请写：
> "Foundational — no GDD requirement. Enables: [列出本决策解锁或约束的 GDD 系统]"

## Performance Implications
- **CPU**: [预期影响]
- **Memory**: [预期影响]
- **Load Time**: [预期影响]
- **Network**: [预期影响（如适用）]

## Migration Plan
[如果这会改动现有代码，我们如何从现状走到目标状态？]

**Rollback plan**: [如果该决策被证明是错的，如何回滚]

## Validation Criteria
[我们如何知道这个决策是正确的？用哪些指标或测试？]

## Related
- [相关 ADR 的链接——注明是取代、冲突还是依赖]
- [相关设计文档的链接]
- [实现后相关代码文件的链接]
