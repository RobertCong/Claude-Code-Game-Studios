> game-design-document.md 的编写指导。只加载当前正在编写的部分所对应的内容——不要一次读整个文件。

# Game Design Document Template — Authoring Guidance

模板是每个 GDD 的起点骨架：在撰写之前，每个小节都保留 `[To be designed]`，因此
仍保留该占位符的小节读起来就是尚未撰写。本指南说明每个小节写好后应包含什么，
以及应使用哪些表格与列。指南按模板的小节标题组织；在编写某个小节时，只阅读下方
该小节的指导。

---

## Header

- **Status**：以下之一——`In Design`（骨架的默认值）、`Designed`、
  `In Review`、`Needs Revision`、`Approved`、`Implemented`。
- **Author**：撰写它的 agent 或个人。
- **Last Updated**：最后一次编辑的日期。
- **Last Verified**：本文档最后一次对照当前设计确认准确的时间。
- **Implements Pillar**：该系统所支持的游戏支柱。

---

## Summary

2–3 句话：这个系统是什么、它为玩家做什么、以及它为何存在于这款游戏中。为分层
上下文加载而写——一个扫描 20 份 GDD 的技能会用这一节来决定是否继续读下去。
不要使用术语。

保留其下方的 **Quick reference** 行并填写完整：系统的层级、优先级与关键依赖。

---

## Overview

用一段话向对项目一无所知的人解释这个机制。它是什么、玩家做什么、以及它为何存在？

---

## Player Fantasy

玩家在接触这个机制时应当感受到什么？它所服务的是哪种情感幻想或力量幻想？
这一节指导下方所有的细节决策。

---

## Detailed Design

### Core Rules

精确、无歧义的规则。程序员应当能够不问任何问题就实现这一节。顺序流程使用编号
规则，属性使用项目符号。

### States and Transitions

如果该系统有状态（例如武器状态、状态效果、阶段），记录每一个状态以及状态之间
每一种有效的转换。

| State | Entry Condition | Exit Condition | Behavior |
|-------|----------------|----------------|----------|

### Interactions with Other Systems

该系统如何与战斗交互？物品栏？进度？UI？对每一种交互，明确接口：什么数据流入、
什么流出，以及谁负责什么。

---

## Formulas

该系统使用的每一个数学公式。对每个公式：

### [Formula Name]

```
result = base_value * (1 + modifier_sum) * scaling_factor
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_value | float | 1-100 | data file | 应用修正值之前的基础数值 |
| modifier_sum | float | -0.9 to 5.0 | calculated | 所有生效修正值之和 |
| scaling_factor | float | 0.5-2.0 | data file | 基于等级的缩放系数 |

**Expected output range**: [min] 到 [max]
**Edge case**: 当 modifier_sum < -0.9 时，钳制为 -0.9 以防止出现负值。

---

## Edge Cases

明确记录在异常情况下会发生什么。每个边界情况都应有清晰的解决方式。

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| [如果 X 为零会怎样？] | [会发生这种情况] | [基于这个原因] |
| [如果两个效果同时触发会怎样？] | [优先级规则] | [设计理由] |

---

## Dependencies

列出该机制依赖的、或依赖该机制的每一个系统。

| System | Direction | Nature of Dependency |
|--------|-----------|---------------------|
| [Combat] | 本系统依赖 Combat | 需要伤害计算结果 |
| [Inventory] | Inventory 依赖本系统 | 提供物品效果数据 |

---

## Tuning Knobs

每一个为平衡性而应可调节的数值。包含当前值、安全范围，以及达到极值时的表现。

| Parameter | Current Value | Safe Range | Effect of Increase | Effect of Decrease |
|-----------|--------------|------------|-------------------|-------------------|

---

## Visual/Audio Requirements

该机制需要哪些视觉与音频反馈？

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|----------------|---------------|----------|

---

## Game Feel

> **为什么这一节要与 Visual/Audio Requirements 分开存在**：Visual/Audio
> Requirements 记录的是有哪些反馈事件（事件到资源的映射表）。Game Feel 记录的是
> 操作该机制时的感觉——交互的响应性、重量感、干脆度与动觉品质。这些是时序、帧数据
> 与控制物理感受的设计目标。游戏手感必须在设计阶段明确，因为它决定了动画预算、
> 输入处理架构与判定框时序。实现之后再补做手感目标代价高昂，且常常需要根本性重做。

用以下六个部分撰写这一节。

### Feel Reference

点明一款具体游戏、机制或时刻，它捕捉了目标手感。要精确——引用确切机制，而不只是
游戏名。解释你要借鉴的是哪种品质。可选地给出一个反向参考（这不应该是什么感觉）。

> 示例："Should feel like Dark Souls weapon swings — weighty, committed, and
> telegraphed, but satisfying on contact. NOT floaty like early Halo melee."

### Input Responsiveness

每个动作从玩家输入到可见/可听响应之间可接受的最大延迟。

| Action | Max Input-to-Response Latency (ms) | Frame Budget (at 60fps) | Notes |
|--------|-----------------------------------|------------------------|-------|
| [Primary action] | [e.g., 50ms] | [e.g., 3 frames] | |
| [Secondary action] | | | |

### Animation Feel Targets

该机制中每个动画的帧数据目标。Startup = 动作产生任何效果之前的起手帧。Active =
动作"正在发生"的帧（判定框生效、技能释放等）。Recovery = 动作结算后的硬直/易受攻击帧。

| Animation | Startup Frames | Active Frames | Recovery Frames | Feel Goal | Notes |
|-----------|---------------|--------------|----------------|-----------|-------|
| [e.g., Light attack] | | | | [e.g., Snappy, low commitment] | |
| [e.g., Heavy attack] | | | | [e.g., Weighty, high commitment] | |

### Impact Moments

定义该机制的标点——让动作显得有分量的反馈强度峰值时刻。每一个高风险事件都应至少
有一条记录。

| Impact Type | Duration (ms) | Effect Description | Configurable? |
|-------------|--------------|-------------------|---------------|
| Hit-stop (freeze frames) | [e.g., 80ms] | [接触时冻结双方物体] | Yes |
| Screen shake | [e.g., 150ms] | [有方向、逐渐衰减] | Yes |
| Camera impact | | | |
| Controller rumble | | | |
| Time-scale slowdown | | | |

### Weight and Responsiveness Profile

用简短散文描述整体手感目标。回答以下问题：

- **Weight**：感觉沉重而审慎，还是轻快而灵敏？
- **Player control**：玩家在每一刻感到多大程度的掌控？
  （高掌控 = 可在动作中途修正方向；低掌控 = 硬直、基于动量）
- **Snap quality**：感觉干脆而二元，还是平滑而连续？
- **Acceleration model**：移动/动作是瞬间启动（街机手感），还是从零逐渐加速
  （模拟手感）？减速同理。
- **Failure texture**：当玩家犯错时，机制感觉公平还是惩罚性过重？玩家对失败原因的
  理解是什么？

### Feel Acceptance Criteria

具体的、可测试的标准，试玩测试者无需测量工具即可验证。这些是陈述得足够精确、
能获得一致结论的主观目标。

- [ ] [例如："战斗感觉有冲击力——试玩者会主动提及重量感"]
- [ ] [例如："没有评审者使用'飘''滑'或'无响应'这些词"]
- [ ] [例如："在目标 60fps 帧率下输入延迟不可察觉"]
- [ ] [例如："命中定格读起来是令人满足的，而不是卡顿或掉帧"]

---

## UI Requirements

哪些信息需要展示给玩家，以及何时展示？

| Information | Display Location | Update Frequency | Condition |
|-------------|-----------------|-----------------|-----------|

---

## Cross-References

声明对另一份 GDD 中特定机制、数值或规则的每一处显式依赖。`/review-all-gdds`
的 Phase 2c 会读取此表——它用可验证的声明替换隐含的行文引用。如果你在文档任何
地方引用了另一个系统的行为，它必须出现在这里。

| This Document References | Target GDD | Specific Element Referenced | Nature |
|--------------------------|-----------|----------------------------|--------|
| [e.g., "combo multiplier feeds score"] | `design/gdd/score.md` | `combo_multiplier` output value | Data dependency |
| [e.g., "death triggers respawn"] | `design/gdd/respawn.md` | Death state transition | State trigger |
| [e.g., "stamina gates dodge"] | `design/gdd/stamina.md` | Stamina depletion rule | Rule dependency |

> **关于"Nature"的说明**：使用以下之一——`Data dependency`（我们消费其输出）、
> `State trigger`（其状态变化触发我们的行为）、`Rule dependency`
> （我们的规则假设其规则同样成立）、`Ownership handoff`（我们将某个值的所有权
> 移交给他们）。

---

## Acceptance Criteria

用于确认该机制按设计工作的可测试标准。

- [ ] [标准 1：具体、可度量、可测试]
- [ ] [标准 2]
- [ ] [标准 3]
- [ ] Performance: 系统更新在 [X]ms 内完成
- [ ] 实现中无硬编码数值

---

## Open Questions

任何尚未决定的事项。每个问题都应有负责人与截止日期。

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
