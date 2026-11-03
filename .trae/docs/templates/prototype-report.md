# Concept Prototype Report: [Concept Name]

> **Date**: [YYYY-MM-DD]
> **Prototype Path**: [HTML / Engine / Paper]
> **Concept File**: design/gdd/game-concept.md，或 design/game-brief.md（若任一存在）

---

## Hypothesis

[本原型要检验的可证伪假设：
「如果玩家 [做 X]，他们会感到 [Y]——由 [可衡量的信号 Z] 佐证。」]

---

## Riskiest Assumption Tested

[概念中被认定为最大风险的是什么，以及它是否被验证成立。]

---

## Approach

[构建了什么、花了多长时间、有意采用了哪些简化。]

**Path chosen:** [HTML / Engine / Paper]
**Reason for path:** [为何此路径适合该假设]

**Shortcuts taken (intentional):**
- [例如：硬编码数值、占位美术、无菜单等]

---

## Result

[实际发生了什么——具体观察，而非观点。尽可能直接引用
试玩者的话。]

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | [HTML / Engine / Paper] |
| Iterations to playable | [N——仅 Engine 路径；其他为 N/A] |
| Prototype duration | [例如：4 小时] |
| Playtesters | [N 内部 / N 外部] |
| Feel assessment | [具体——「200ms 时响应感觉迟滞」，而非「手感差」] |
| Hypothesis verdict | [CONFIRMED / PARTIALLY CONFIRMED / REFUTED] |

---

## Recommendation: [PROCEED / PIVOT / KILL / NOT ASSESSED — built but nobody has played it]

[用一段话说明该建议，并引用上述结果中的证据。]

---

## If Proceeding

[原型揭示了哪些应直接用于 GDD 撰写的信息：]

- **Core tuning values discovered:** [例如：「跳跃高度 3.5 个单位手感最佳」]
- **Assumptions confirmed:** [概念文档中哪些假设被证实]
- **Assumptions disproved:** [概念文档中哪些假设被证伪]
- **Emergent mechanics:** [测试中出现、值得正式化的行为]

> 注：若使用 HTML 路径且手感不确定，在确定撰写 GDD 之前，考虑先做一个
> 专门针对手感的引擎原型。

**Next steps:**
1. `/design-review design/gdd/game-concept.md`
2. `/gate-check`
3. `/map-systems`
4. `/design-system [mechanic]`（运用 Tuning Knobs 与 Formulas 小节中的经验）

---

## If Pivoting

[结果指向的替代方向——哪些地方几乎对了、需要调整什么。
要具体说明改什么，而不只是说需要改。]

**Pivot direction:** [应尝试的不同方向]
**What to keep:** [哪些有效、应保留]
**Next step:** `/prototype [revised-concept]`

---

## If Killing

[为何此概念行不通——是什么具体信号得出了这一结论。
本报告即为产出物；此概念无需进一步行动。]

**Next step:** `/brainstorm [new-direction]`

---

## Lessons Learned

- **实际动手构建后，哪些假设被推翻了？**
  [...]

- **哪些事情令我们意外，而头脑风暴时并未显现？**
  [...]

- **下次我们会用怎样不同的方式测试？**
  [...]

---

> *原型代码位置：`prototypes/[concept-name]-concept/`*
> *此代码为一次性丢弃品。绝不要重构进生产代码。*
