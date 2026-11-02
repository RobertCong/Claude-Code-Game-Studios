# ADR: [Decision Name]

---
**Status**: Reverse-Documented
**Source**: `[path to implementation code]`
**Date**: [YYYY-MM-DD]
**Decision Makers**: [用户名，或 "inferred from code"]
**Implementation Status**: [Deployed | Partial | Planned]
---

> **⚠️ Reverse-Documentation Notice**
>
> 本架构决策记录是在实现**已经存在之后**才创建的。它记录了当前的实现方式，
> 以及基于代码分析和用户沟通澄清出的决策理由。部分背景可能是重构出来的，
> 而非当时同步记录。

---

## Context

**Problem Statement**: [该实现解决了什么问题？]

**Background** (inferred from code):
- [背景 1——为什么这个问题需要解决]
- [背景 2——当时的约束条件]
- [背景 3——当时可能考虑过的备选方案]

**System Scope**: [这会影响代码库的哪些部分？]

**Stakeholders**:
- [Role 1]: [其关注点或需求]
- [Role 2]: [其关注点或需求]

---

## Decision

**Approach Taken** (as implemented):

[描述代码中采用的架构方案]

**Key Implementation Details**:
- [细节 1]：[它如何运作]
- [细节 2]：[采用的设计模式或结构]
- [细节 3]：[值得注意的设计选择]

**Clarified Rationale** (from user):
- [理由 1——为什么选择该方案]
- [理由 2——它解决了什么问题]
- [理由 3——它带来了什么好处]

**Code Locations**:
- `[file/path 1]`: [其中有什么]
- `[file/path 2]`: [其中有什么]

---

## Alternatives Considered

*（这些可能来自推断，或已与用户澄清）*

### Alternative 1: [Approach Name]

**Description**: [该备选方案原本会是什么样]

**Pros**:
- ✅ [优点 1]
- ✅ [优点 2]

**Cons**:
- ❌ [缺点 1]
- ❌ [缺点 2]

**Why Not Chosen**: [理由——来自用户澄清或推断]

### Alternative 2: [Approach Name]

**Description**: [该备选方案原本会是什么样]

**Pros**:
- ✅ [优点 1]
- ✅ [优点 2]

**Cons**:
- ❌ [缺点 1]
- ❌ [缺点 2]

**Why Not Chosen**: [理由]

### Alternative 3: [Status Quo / No Change]

**Description**: [“什么都不做”意味着什么]

**Why Not Acceptable**: [为什么这个问题必须解决]

---

## Consequences

### Positive Consequences (Benefits Realized)

✅ **[Benefit 1]**: [该实现如何带来这一收益]

✅ **[Benefit 2]**: [影响]

✅ **[Benefit 3]**: [影响]

### Negative Consequences (Trade-offs Accepted)

⚠️ **[Trade-off 1]**: [牺牲了什么，或什么变得更困难]

⚠️ **[Trade-off 2]**: [限制或代价]

⚠️ **[Trade-off 3]**: [复杂度或维护负担]

### Neutral Consequences (Observations)

ℹ️ **[Observation 1]**: [涌现出来的特性或副作用]

ℹ️ **[Observation 2]**: [意料之外的结果]

---

## Implementation Notes

**Patterns Used**:
- [模式 1]：[用在哪里、为什么]
- [模式 2]：[用在哪里、为什么]

**Dependencies Introduced**:
- [依赖 1]：[为什么需要]
- [依赖 2]：[为什么需要]

**Performance Characteristics**:
- Time complexity: [O(n) 等]
- Space complexity: [内存占用]
- Bottlenecks: [已知的性能问题]

**Thread Safety**:
- [线程安全方案——单线程、互斥锁保护、无锁等]

**Testing Strategy**:
- [如何测试——单元测试、集成测试等]
- Coverage: [预估或实测值]

---

## Validation

**How We Know This Works**:
- ✅ [证据 1——例如"在生产环境运行 6 个月无问题"]
- ✅ [证据 2——例如"在 60 FPS 下处理 1 万个实体"]
- ⚠️ [证据 3——例如"可用，但需要监控"]

**Known Issues** (discovered during analysis):
- ⚠️ [Issue 1]: [问题及可能的修复方式]
- ⚠️ [Issue 2]: [问题及可能的修复方式]

**Risks**:
- [风险 1]：[如果发生 X 可能出现的问题]
- [风险 2]：[可扩展性方面的担忧]

---

## Open Questions

**Unresolved During Reverse-Documentation**:
1. **[Question 1]**: [决策或实现中不清楚的地方是什么？]
   - Needs clarification from: [谁]
   - Impact if unresolved: [后果]

2. **[Question 2]**: [为了后续工作需要决定什么？]

---

## Follow-Up Work

**Immediate**:
- [ ] [任务 1——例如"补充缺失的单元测试"]
- [ ] [任务 2——例如"记录边界情况的处理方式"]

**Short-Term**:
- [ ] [任务 3——例如"重构 X 以提升清晰度"]
- [ ] [任务 4——例如"增加性能监控"]

**Long-Term**:
- [ ] [任务 5——例如"当 Y 可用时重新审视该决策"]

---

## Related Decisions

**Depends On** (ADRs this builds upon):
- [ADR-XXX]: [相关决策]

**Influences** (ADRs affected by this):
- [ADR-YYY]: [它如何产生影响]

**Supersedes**:
- [ADR-ZZZ]: [它所替代的旧决策（如有）]

**Superseded By**:
- [None yet | ADR-WWW（若该决策日后被取代）]

---

## References

**Code Locations**:
- `[path/file 1]`: [主要实现]
- `[path/file 2]`: [相关代码]

**External Resources**:
- [Article/Book]: [相关的模式或技术参考]
- [Documentation]: [参考过的引擎或库文档]

**Design Documents**:
- [GDD Section]: [如果它实现了某个设计]

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | 基于 `[source path]` 的初始逆向文档 |
| [Date] | [User] | 澄清了 [X] 的决策理由 |

---

## Status Legend

- **Proposed**: 讨论中，尚未实现
- **Accepted**: 已决策，实现进行中
- **Deprecated**: 不再推荐，但代码中可能仍然存在
- **Superseded**: 已被另一项决策取代
- **Reverse-Documented**: 实现完成之后才创建（即本文档）

---

**Current Status**: **Reverse-Documented**

---

*本 ADR 由 `/reverse-document architecture [path]` 生成*

---

## Appendix: Code Snippets

**Key Implementation Pattern**:

```[language]
[Code snippet showing the core pattern or decision]
```

**Rationale**: [为什么这段代码结构体现了该决策]

**Alternative Approach** (not chosen):

```[language]
[Code snippet showing what the alternative would look like]
```

**Why Not**: [为什么更倾向于已实现的方案]
