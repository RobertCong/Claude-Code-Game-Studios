# Vertical Slice Report: [Concept Name]

> **Date**: [YYYY-MM-DD]
> **Slice Duration**: [N days]
> **Target Scope**: 3–5 分钟精修、连续的玩法
> **Source GDD**: design/gdd/game-concept.md（或 design/game-brief.md）

---

## Validation Question

[本次构建要证明的完整游戏循环问题——既关乎体验也关乎可行性：
「一名玩家从零开始，在没有开发者引导的情况下，能否在 [N] 分钟内体验到
[核心幻想]，以及我们能否在 [X] 天内以有代表性的质量构建出这样一个循环？」]

---

## Scope Built

[已实现的系统、美术质量水平、有意省略的内容。]

**Systems included:**
- [System 1]
- [System 2]
- [...]

**Art/audio quality level:** [Placeholder / Representative / Near-shipping]
**Shortcuts taken deliberately:** [List]
**What was cut from original scope:** [List]

---

## Build Velocity Log

[逐日记录已完成的内容。这是你真实的产能数据——请在冲刺规划中使用它。]

| Day | Completed |
|-----|-----------|
| Day 1 | [构建了什么] |
| Day 2 | [构建了什么] |
| Day 3 | [构建了什么] |
| ... | ... |

**Total elapsed:** [N days] 用于 [范围摘要]
**Velocity estimate:** [每等效范围单位 N 小时——例如「每个战斗遭遇 1 天，每个 UI 界面 0.5 天」]

---

## Playtest Results

| Attribute | Value |
|-----------|-------|
| Total sessions | [N] |
| Internal testers | [N] |
| External testers | [N——未见过本游戏的人，如可获得] |
| Avg session length | [N 分钟（目标：[N] 分钟）] |
| Time to first meaningful action | [N 秒（目标：[N] 秒）] |

---

## Observations

[来自试玩测试会话的具体、非主观的观察。必要时引用测试者原话。]

**Where testers succeeded without guidance:**
- [...]

**Where testers were confused or stuck:**
- [...]

**Emotional reactions observed:**
- [...]

---

## Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Time to first meaningful action | [N sec] | [N sec] |
| Session length | [N min] | [N min] |
| Critical fun blockers found | 0 | [N] |
| Pipeline blockers found | 0 | [N] |
| Architecture surprises | 0 | [N] |

**Feel assessment:** [具体——如「战斗反馈薄弱；命中时没有打击音效」，而非「感觉粗糙」]

---

## Recommendation: [PROCEED / PIVOT / KILL / NOT ASSESSED — the slice was built but nobody has played it]

[一段带证据的文字——直接呼应验证问题。是否有玩家在目标时间内、在没有开发者
引导的情况下体验到了核心幻想？团队能否按预计进度以这一质量水平构建？]

**Creative Director review (CD-PLAYTEST):** [APPROVE / CONCERNS / REJECT / NOT ASSESSED——总监的理由；或「not run——[review mode]」]

---

## If Proceeding

**Production requirements**（从切片到生产必须改变的内容）：
- [例如「用可发布的资源替换占位美术」]
- [例如「战斗系统还需要 2 种武器类型」]

**Architecture adjustments needed:**
- [需要更新或创建的 ADR]

**Sprint velocity estimate based on slice data:**
- [例如「每种敌人 1 天，每个关卡区段 2 天，每个 UI 界面 0.5 天」]

**Scope adjustments from original design:**
- [切片揭示了真实生产范围是怎样的]

**Performance targets:** [Confirmed / Revised——如已修订，列出变更]

**Playtest note:** 在运行 `/gate-check production` 之前，运行 `/playtest-report`
来整理更多会话数据。

**Next steps:**
1. `/create-epics layer:foundation`——规划 Foundation 层史诗
2. `/create-epics layer:core`——规划 Core 层史诗
3. `/create-stories [epic-slug]`——把每个史诗拆成用户故事
4. `/sprint-plan`——在估算中使用本报告中的产能数据
5. `/gate-check production`——正式推进到 Production

---

## If Not Assessed

[切片已构建，但没有人完整游玩过，因此尚无证据支持 PROCEED、PIVOT 或 KILL。]

**Next step:** 在无引导的情况下游玩切片（至少记录一次会话），然后重新运行
`/vertical-slice`——它会从 `production/session-state/active.md` 中的检查点恢复。

---

## If Pivoting

[哪些 GDD 需要修订以及为什么——具体说明观察到的失败模式。]

**Systems requiring GDD revision:** [List]
**Architecture decisions to revisit:** [List——使用 `/architecture-decision` 更新]
**Core loop change needed:** [具体要改什么]

**Next steps:**
1. `/design-system [mechanic]`——修订受影响的 GDD
2. `/architecture-decision [decision]`——处理架构问题
3. `/vertical-slice`——修订后重新验证

---

## If Killing

[为什么完整游戏循环在这一质量水平下无法成立。具体是什么妨碍了玩家体验
核心幻想。接下来该做什么。]

**Next step:** 用 `/brainstorm` 探索新方向，或用 `/prototype [new-concept]`
在投入另一个垂直切片之前低成本地测试一个不同概念。

---

## Lessons Learned

- **以接近生产质量构建打破了哪些假设？**
  [...]

- **流水线或架构中有什么让我们意外？**
  [...]

- **如果再跑一次，我们会怎样调整切片范围？**
  [...]

---

> *垂直切片代码位置：`prototypes/[concept-name]-vertical-slice/`*
> *此代码仅为参考资料。生产实现需从头编写。*
> *切勿把此代码引入或重构进生产。*
