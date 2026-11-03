# Systems Index: [Game Title]

> **Status**: [Draft / Under Review / Approved]
> **Created**: [Date]
> **Last Updated**: [Date]
> **Source Concept**: design/gdd/game-concept.md（或 design/game-brief.md）

---

## Overview

[一段话说明游戏的机制范围。本游戏需要哪些类型的系统？呼应核心循环和游戏
支柱。这应帮助任何团队成员理解需要设计和构建内容的「大图景」。]

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | [例如 Player Controller] | Core | MVP | [Not Started / In Design / In Review / Approved / Implemented] | [design/gdd/player-controller.md 或 "—"] | [例如 Input System, Physics] |
| 2 | [例如 Camera System] | Core | MVP | Not Started | — | Player Controller |

[为每个识别出的系统添加一行。使用下方定义的类别和优先级层级。对推断出的
系统（概念文档中未明确列出），在系统名称后标注「(inferred)」。]

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | 所有内容都依赖的基础系统 | Player controller, input, physics, camera, scene management, state machine |
| **Gameplay** | 让游戏变得有趣的系统 | Combat, AI, stealth, movement abilities, interaction |
| **Progression** | 玩家如何随时间成长 | XP/leveling, skill trees, unlocks, achievements, reputation |
| **Economy** | 资源的产生与消耗 | Currency, loot, crafting, shops, item database, drop tables |
| **Persistence** | 存档状态与连续性 | Save/load, settings, cloud sync, profile management |
| **UI** | 面向玩家的信息展示 | HUD, menus, inventory screen, dialogue UI, map, notifications |
| **Audio** | 音效与音乐系统 | Music manager, SFX bus, ambient audio, adaptive music, voice |
| **Narrative** | 剧情与对话的呈现 | Dialogue system, quest tracking, cutscenes, journal, lore entries |
| **Meta** | 核心游戏循环之外的系统 | Analytics, tutorials/onboarding, accessibility options, photo mode |

[并非每款游戏都需要每个类别。删除不适用的类别。如有需要可添加自定义类别。]

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | 核心循环运行所必需。没有这些，就无法测试「是否有趣？」 | First playable prototype | Design FIRST |
| **Vertical Slice** | 一个完整、精修区域所必需。展示完整体验。 | Vertical slice / demo | Design SECOND |
| **Alpha** | 所有功能以粗略形式存在。机制范围完整，占位内容可以接受。 | Alpha milestone | Design THIRD |
| **Full Vision** | 打磨、边缘情况、锦上添花的内容，以及内容完整的功能。 | Beta / Release | Design as needed |

---

## Dependency Map

[按依赖顺序排列系统——从上到下设计与构建。顶部的系统是基础；底部的系统是
封装层。]

### Foundation Layer (no dependencies)

1. [System]——[一句话说明为什么这是基础]

### Core Layer (depends on foundation)

1. [System]——depends on: [list]

### Feature Layer (depends on core)

1. [System]——depends on: [list]

### Presentation Layer (depends on features)

1. [System]——depends on: [list]

### Polish Layer (depends on everything)

1. [System]——depends on: [list]

---

## Recommended Design Order

[结合依赖排序与优先级层级。按此顺序设计这些系统。每个系统的 GDD 应在开始
下一个之前完成并评审，不过同一层级中的独立系统可以并行设计。]

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | [第一个要设计的系统] | MVP | Foundation | game-designer | [S/M/L] |
| 2 | [第二个系统] | MVP | Foundation | game-designer | [S/M/L] |

[工作量估算：S = 1 次会话，M = 2-3 次会话，L = 4 次以上会话。
一次「会话」指一次产出一份完整 GDD 的聚焦设计对话。]

---

## Circular Dependencies

[列出分析中发现的所有循环依赖链。这些需要特别的架构关注——要么用接口打破
循环，要么同时设计这些系统。]

- [None found] 或
- [System A <-> System B：循环关系的描述及拟议解决方案]

---

## High-Risk Systems

[技术上未经验证、设计不确定或范围危险的系统。无论优先级层级如何，这些都应
尽早制作原型。]

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| [System] | [Technical / Design / Scope] | [可能出现什么问题] | [原型、研究或范围兜底] |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | [N] |
| Design docs started | [N] |
| Design docs reviewed | [N] |
| Design docs approved | [N] |
| MVP systems designed | [N/total MVP] |
| Vertical Slice systems designed | [N/total VS] |

---

## Next Steps

- [ ] 评审并批准这份系统清单
- [ ] 优先设计 MVP 层级系统（使用 `/design-system [system-name]`）
- [ ] 对每份完成的 GDD 运行 `/design-review`
- [ ] MVP 系统设计完成后运行 `/gate-check technical-setup`
- [ ] 在承诺进入 Production 之前，用 `/vertical-slice` 验证最高风险系统
