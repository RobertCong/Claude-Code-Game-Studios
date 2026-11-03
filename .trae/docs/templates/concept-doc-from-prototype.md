# [Prototype Name] — Concept Document

---
**Status**: Reverse-Documented from Prototype
**Prototype Path**: `prototypes/[name]/`
**Date**: [YYYY-MM-DD]
**Creator**: [User name]
**Outcome**: [Success | Partial Success | Failed | Needs More Testing]
---

> **⚠️ Reverse-Documentation Notice**
>
> 本概念文档是在原型构建**之后**创建的。它记录了通过原型探索发现的核心机制、
> 经验教训与设计洞察。这是对实验性工作的正式化，而非预先规划的设计。

---

## 1. Prototype Overview

**Original Hypothesis**：
[这个原型在验证什么问题或想法？]

**Approach**：
[原型是如何构建的？快速粗糙？聚焦单一机制？]

**Duration**：
- Time spent: [X hours/days]
- Complexity: [Throwaway | Could be production-ready | Needs full rewrite]

**Outcome**（澄清后）：
- ✅ **Validated**：[哪些做法有效、应当继续推进]
- ⚠️ **Needs Work**：[哪些显现出潜力但需要打磨]
- ❌ **Invalidated**：[哪些行不通、应当放弃]

---

## 2. Core Mechanic

**What the Prototype Does**：
[描述被制作成原型的机制或系统]

**How It Feels**（用户反馈）：
- [感受 1 —— 例如 "Satisfying"、"Clunky"、"Too complex"]
- [感受 2 —— 例如 "Intuitive"、"Confusing"、"Needs tutorial"]
- [感受 3 —— 例如 "Fun"、"Boring"、"Has potential"]

**Player Fantasy**：
[该机制创造了怎样的幻想或体验？]

**Core Loop**（如适用）：
```
[Action 1] → [Result 1] → [Action 2] → [Result 2] → [Repeat or Conclude]
```

**Emergent Behaviors**（非预期但有趣）：
- [行为 1]：[玩家做出了哪些计划之外的行为]
- [行为 2]：[意料之外的策略或交互]

---

## 3. What Worked

### Mechanic Successes

✅ **[Success 1]**：[哪些地方效果好]
- **Why**：[成功的原因]
- **Keep for Production**：[是否应保留到正式制作？]

✅ **[Success 2]**：[哪些地方效果好]
- **Why**：[成功的原因]
- **Keep for Production**：[是否应保留到正式制作？]

### Technical Successes

✅ **[Technical win 1]**：[哪种技术方案有效]
- **Lesson**：[我们学到了什么]
- **Reusable**：[这段代码/方案能否用于正式制作？]

✅ **[Technical win 2]**：[哪些做法有效]
- **Lesson**：[我们学到了什么]

---

## 4. What Didn't Work

### Mechanic Failures

❌ **[Failure 1]**：[哪些地方行不通]
- **Why**：[根本原因]
- **Could It Be Fixed**：[是可挽救的，还是存在根本缺陷？]

❌ **[Failure 2]**：[哪些地方行不通]
- **Why**：[根本原因]
- **Could It Be Fixed**：[是/否 + 如何修复]

### Technical Failures

❌ **[Technical issue 1]**：[是什么造成了问题]
- **Lesson**：[正式制作中应避免什么]

❌ **[Technical issue 2]**：[是什么造成了问题]
- **Lesson**：[应避免什么]

---

## 5. What Needs Refinement

⚠️ **[Element 1]**：[哪些显现出潜力但需要改进]
- **Issue**：[目前存在的问题]
- **Path Forward**：[如何改进]
- **Effort**：[Small | Medium | Large refactor]

⚠️ **[Element 2]**：[哪些需要打磨]
- **Issue**：[当前问题]
- **Path Forward**：[改进方案]
- **Effort**：[工作量估计]

---

## 6. Key Learnings

### Design Insights

💡 **[Insight 1]**：[我们在游戏设计上学到了什么]
- **Implication**：[这如何影响后续工作]

💡 **[Insight 2]**：[设计经验]
- **Implication**：[对 GDD 或其他系统的影响]

### Technical Insights

💡 **[Insight 3]**：[技术经验]
- **Implication**：[架构或实现方面的指导]

💡 **[Insight 4]**：[技术经验]
- **Implication**：[未来的技术决策]

### Player Psychology Insights

💡 **[Insight 5]**：[我们在玩家行为上学到了什么]
- **Implication**：[这如何影响设计理念]

---

## 7. Production Readiness Assessment

**Should This Become a Full Feature?**: [Yes | No | Needs More Testing | Pivot to Different Approach]

**If Yes — Production Requirements**：
- [ ] [需求 1 —— 例如 "Rewrite for performance"]
- [ ] [需求 2 —— 例如 "Add proper UI"]
- [ ] [需求 3 —— 例如 "Design 10 more variations"]
- [ ] [需求 4 —— 例如 "Integrate with progression system"]

**Estimated Production Effort**: [Small | Medium | Large]
- Prototype reusability: [X%] of code can be kept
- From-scratch effort: [X hours/days to production-ready]

**If No — Why Not?**：
- [原因 1 —— 例如 "Fun but doesn't fit game pillars"]
- [原因 2 —— 例如 "Too complex for target audience"]
- [原因 3 —— 例如 "Technically infeasible at scale"]

**If Pivot — Suggested Direction**：
- [备选方案 1]
- [备选方案 2]

---

## 8. Design Pillars Alignment

**How This Relates to Game Pillars**（如果已定义游戏支柱）：

| Pillar | Alignment | Notes |
|--------|-----------|-------|
| [Pillar 1] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [说明] |
| [Pillar 2] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [说明] |
| [Pillar 3] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [说明] |

**Overall Pillar Fit**：[这是否属于本游戏？]

---

## 9. Next Steps

### Immediate (If Moving Forward)
1. **[Task 1]**：[例如 "Create full design doc for this system"]
2. **[Task 2]**：[例如 "Write ADR for technical approach"]
3. **[Task 3]**：[例如 "Add to backlog for Sprint X"]

### Before Production (If Needs More Work)
1. **[Task 1]**：[例如 "Build second prototype testing X variation"]
2. **[Task 2]**：[例如 "Playtest with 5+ people"]
3. **[Task 3]**：[例如 "Investigate technical feasibility of Y"]

### If Abandoning
1. **[Task 1]**：[例如 "Archive prototype with this document"]
2. **[Task 2]**：[例如 "Extract reusable code/learnings"]
3. **[Task 3]**：[例如 "Update game pillars if this changed thinking"]

---

## 10. Technical Notes

**Prototype Implementation**：
- Language/Engine: [使用了什么]
- Architecture: [如何组织结构]
- Shortcuts taken: [哪些地方是临时凑合或一次性的]

**Reusable Code**（如有）：
- `[file/path 1]`：[它做什么，可复用性如何]
- `[file/path 2]`：[它做什么，可复用性如何]

**Technical Debt**（若进入正式制作）：
- [技术债 1]：[哪些需要重写]
- [技术债 2]：[哪些需要正规实现]

---

## 11. Playtest Feedback

*（如果原型经过试玩测试）*

**Testers**: [N people, [internal/external]]

**Positive Feedback**：
- "[Quote 1]" —— [测试者姓名/角色]
- "[Quote 2]" —— [测试者姓名/角色]

**Negative Feedback**：
- "[Quote 1]" —— [测试者姓名/角色]
- "[Quote 2]" —— [测试者姓名/角色]

**Suggestions**：
- "[Suggestion 1]" —— [测试者姓名]
- "[Suggestion 2]" —— [测试者姓名]

**Themes**：
- [主题 1]：[多位测试者一致认同的内容]
- [主题 2]：[共同反馈]

---

## 12. Related Work

**Inspired By**（影响了本原型的游戏/机制）：
- [Game 1]：[哪种机制或感受]
- [Game 2]：[借鉴或改造了什么]

**Differs From**（本原型的独特或不同之处）：
- [差异 1]
- [差异 2]

**Integrates With**（现有游戏系统）：
- [System 1]：[它们将如何衔接]
- [System 2]：[它们将如何衔接]

---

## 13. Open Questions

**Design Questions**：
1. **[Question 1]**：[设计上还有哪些未决定？]
2. **[Question 2]**：[哪些需要试玩测试或迭代？]

**Technical Questions**：
3. **[Question 3]**：[还有哪些技术未知项？]
4. **[Question 4]**：[哪些需要可行性验证？]

---

## 14. Appendix: Prototype Assets

**Code**：
- Location: `prototypes/[name]/src/`
- Status: [Archival | Partial reuse | Full reuse]

**Art/Audio**（如有）：
- Location: `prototypes/[name]/assets/`
- Status: [Placeholder | Production-ready | Needs replacement]

**Documentation**：
- README: [Exists | Missing]
- Build instructions: [Exists | Missing]

---

## Version History

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | Initial concept doc from prototype analysis |
| [Date] | [User] | Clarified outcomes, added playtest feedback |

---

**Final Recommendation**: [GO | NO-GO | PIVOT]

**Rationale**：[用 1-2 句话说明原因]

---

*本概念文档由 `/reverse-document concept prototypes/[name]` 生成*
