# [System Name] — Design Document

---
**Status**: Reverse-Documented
**Source**: `[path to implementation code]`
**Date**: [YYYY-MM-DD]
**Verified By**: [User name or "pending review"]
**Implementation Status**: [Fully implemented | Partially implemented | Needs extension]
---

> **⚠️ Reverse-Documentation Notice**
>
> 本设计文档是在实现已经存在**之后**创建的。它基于代码分析与用户沟通，
> 记录了当前行为并澄清了设计意图。在实现不完整或逆向分析期间设计意图
> 不明确的部分，相应章节可能并不完备。

---

## Summary

[2–3 句话：这个系统是什么、它为玩家做什么、为什么存在
—— 由代码推断而来；标注 `[inferred — confirm]`]

---

## 1. Overview

**Purpose**：[这个系统解决什么问题？]

**Scope**：[该系统包含/不包含哪些内容？]

**Current Implementation**：[简要描述代码中已有的实现]

**Design Intent**（澄清后）：
- [意图 1 —— 该功能为何存在]
- [意图 2 —— 它创造了怎样的玩家体验]
- [意图 3 —— 它如何融入整体游戏支柱]

---

## 2. Player Fantasy

[玩家使用该系统时应当**感受**到什么。代码不会记录这一点：
从上面的玩家可感知效果推断，然后与设计师**确认**，在确认之前
标注 `[inferred — confirm]`。]

---

## 3. Detailed Design

### 3.1 Core Mechanics

[按已实现的方式描述机制，并清晰组织]

**[Mechanic 1 Name]**：
- **Description**：[它做什么]
- **Implementation**：[它在代码中如何运作]
- **Design Rationale**：[它为何存在 —— 来自用户说明]
- **Player-Facing**：[玩家如何体验它]

**[Mechanic 2 Name]**：
- **Description**：[它做什么]
- **Implementation**：[它如何运作]
- **Design Rationale**：[它为何存在]
- **Player-Facing**：[玩家体验]

### 3.2 State and Data

**Data Structures**（来自代码）：
- [数据结构 1]：`[fields/properties]`
- [数据结构 2]：`[fields/properties]`

**State Machines**（如适用）：
```
[State diagram or list of states and transitions]
```

**Persistence**：
- Saved: [哪些内容写入玩家存档]
- Not saved: [哪些仅限本局或会重新计算]

### 3.3 Integration Points

**Dependencies**（本系统依赖的系统）：
- [System 1]：[它提供什么]
- [System 2]：[它提供什么]

**Dependents**（依赖本系统的系统）：
- [System 3]：[它如何使用本系统]
- [System 4]：[它如何使用本系统]

**API Surface**（公开接口）：
- [Method/Function 1]：[用途]
- [Method/Function 2]：[用途]

---

## 4. Formulas

**Formulas Discovered in Code**：

| Formula | Expression | Purpose | Verified? |
|---------|-----------|---------|-----------|
| [Formula 1] | `[mathematical expression]` | [计算什么] | ✅ / ⚠️ needs tuning |
| [Formula 2] | `[expression]` | [用途] | ✅ / ⚠️ needs tuning |

**Clarifications**：
- [Formula X]：原为 [value/approach]，用户澄清意图是 [corrected intent]
- [Formula Y]：实现为 [X]，但应为 [Y] —— 已标记待更新

---

## 5. Edge Cases

**Handled in Code**：
- ✅ [边界情况 1]：[如何处理]
- ✅ [边界情况 2]：[如何处理]

**Not Yet Handled**（分析期间发现）：
- ⚠️ [边界情况 3]：[会发生什么？需要实现]
- ⚠️ [边界情况 4]：[会发生什么？需要实现]

**Unclear**（需要用户澄清）：
- ❓ [边界情况 5]：[应当发生什么？待决定]

---

## 6. Dependencies

**Technical Dependencies**：
- [依赖 1]：[为何需要]
- [依赖 2]：[为何需要]

**Design Dependencies**（其他设计文档）：
- [System X Design]：[它们如何相互作用]
- [System Y Design]：[它们如何相互作用]

**Content Dependencies**：
- [资源类型]：[需要什么]
- [数据文件]：[所需的配置/平衡性数据]

---

## 7. Tuning Knobs

**Current Values**（按当前实现）：

| Parameter | Current Value | Rationale | Needs Tuning? |
|-----------|--------------|-----------|---------------|
| [Param 1] | [value] | [为何取此值] | ✅ / ⚠️ / ❌ |
| [Param 2] | [value] | [为何取此值] | ✅ / ⚠️ / ❌ |

**Balance Concerns Identified**：
- ⚠️ [关注项 1]：[问题是什么，建议如何修复]
- ⚠️ [关注项 2]：[问题是什么，建议如何修复]

**Recommended Balance Pass**：
- 对 [specific aspect] 运行 `/balance-check`
- 针对 [specific scenario] 进行试玩测试

---

## 8. Acceptance Criteria

**What Exists**（已实现）：
- ✅ [标准 1]
- ✅ [标准 2]
- ⚠️ [标准 3] —— 部分实现

**What's Missing**（尚未实现）：
- ❌ [标准 4] —— 已标记为后续工作
- ❌ [标准 5] —— 已标记为后续工作

**Definition of Done**（该系统何时算"完成"？）：
- [ ] [需求 1]
- [ ] [需求 2]
- [ ] [需求 3]

---

## Open Questions and Follow-Up Work

### Questions Needing User Decision
1. **[Question 1]**：[需要决定什么？]
   - Option A: [方案 A]
   - Option B: [方案 B]

2. **[Question 2]**：[需要决定什么？]

### Flagged Follow-Up Work
- [ ] **Update [Formula X]**：按用户说明从指数改为线性
- [ ] **Implement [Edge Case Y]**：处理当前代码未覆盖的场景
- [ ] **Create ADR**：记录为何选择 [architectural decision]
- [ ] **Balance pass**：对成长曲线运行 `/balance-check`
- [ ] **Extend design doc**：当 [related feature] 实现后，更新本文档

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | Initial reverse-documentation from `[source path]` |
| [Date] | [User] | Clarified design intent, corrected [X] |

---

**Next Steps**：
1. [基于已发现缺口的第一优先级任务]
2. [第二优先级任务]
3. [第三优先级任务]

**Related Skills**：
- `/balance-check` —— 验证公式与成长曲线
- `/architecture-decision` —— 记录技术决策
- `/code-review` —— 确保代码与澄清后的设计一致

---

*本文档由 `/reverse-document design [path]` 生成*
