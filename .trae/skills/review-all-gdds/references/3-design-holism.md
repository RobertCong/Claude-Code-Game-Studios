# /review-all-gdds — Phase 3: 游戏设计整体性

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 3: 游戏设计整体性

**本文件包含：**

- 3a：成长循环竞争
- 3b：玩家注意力预算
- 3c：主导策略检测
- 3d：经济循环分析
- 3e：难度曲线一致性
- 3f：支柱对齐
- 3g：玩家幻想一致性

以游戏设计理论与玩家心理学的视角，将所有 GDD 放在一起评审。这些问题单个 GDD 评审无法捕捉，因为它们需要同时看到所有系统。

### 3a：成长循环竞争

游戏应当有一个玩家认为就是"游戏意义所在"的主导成长循环，并由支撑循环为其供血。当多个系统同等地竞争主要成长驱动力时，玩家就不知道这游戏到底在讲什么。

扫描所有 GDD，找出具备以下特征的系统：
- 奖励玩家的主要资源（经验值、等级、威望、解锁）
- 自我描述为"核心"或"主要"循环
- 与其他做同样事情的系统具有相当的深度与时间投入

```
⚠️  Competing Progression Loops
combat.md: Awards XP, unlocks abilities, is described as "the core loop"
crafting.md: Awards XP, unlocks recipes, is described as "the primary activity"
exploration.md: Awards XP, unlocks map areas, described as "the main driver"
→ Three systems all claim to be the primary progression loop and all award
  the same primary currency. Players will optimise one and ignore the others.
  Consider: one primary loop with the others as support systems.
```

### 3b：玩家注意力预算

统计在典型游戏时段中，有多少系统同时需要玩家主动关注。每个被主动管理的系统都会消耗注意力：

- 主动 = 玩家在游玩过程中必须经常就该系统做出决策
- 被动 = 系统自动运行，玩家看到结果但不管理它

超过 3-4 个同时活跃的系统会让大多数玩家产生认知过载。呈现该计数，并在超过 4 个并发活跃系统时标记：

```
⚠️  Cognitive Load Risk
Simultaneously active systems during [core loop moment]:
  1. [system-a].md — [decision type] (active)
  2. [system-b].md — [resource management] (active)
  3. [system-c].md — [tracking] (active)
  4. [system-d].md — [item/action use] (active)
  5. [system-e].md — [cooldown/timer management] (active)
  6. [system-f].md — [coordination decisions] (active)
→ 6 simultaneously active systems during the core loop.
  Research suggests 3-4 is the comfortable limit for most players.
  Consider: which of these can be made passive or simplified?
```

### 3c：主导策略检测

主导策略会让其他策略变得无关紧要 — 玩家一旦发现它就会只用它，并觉得游戏其余部分很无聊。寻找：

- **资源垄断**：某种策略获取资源的速度显著快于所有其他策略
- **无风险的力量**：既高回报又低风险的策略（如果存在高风险策略，它们需要按比例更高的回报）
- **没有取舍**：某个选项在所有维度上都优于其他所有选项
- **显而易见的唯一最优路**：如果任何成长选择都"显然正确"，那其他选择就不是真正的选择

```
⚠️  Potential Dominant Strategy
combat.md: Ranged attacks deal 80% of melee damage with no risk
combat.md: Melee attacks deal 100% damage but require close range
→ Unless melee has a significant compensating advantage (AOE, stagger,
  resource regeneration), ranged is dominant — higher safety, only 20% less
  damage. Consider what melee offers that ranged cannot.
```

### 3d：经济循环分析

识别所有 GDD 中的所有资源（金币、经验值、制作材料、体力、生命值、法力等）。对每种资源，梳理其**来源**（玩家如何获得）和**消耗**（玩家如何花费）。

标记危险的经济状况：

| 状况 | 迹象 | 风险 |
|-----------|------|------|
| **无限来源，无消耗** | 资源无限累积 | 后期变得毫无难度 |
| **有消耗，无来源** | 资源耗尽至零 | 系统变得不可用 |
| **来源 >> 消耗** | 盈余不断累积 | 资源变得毫无意义 |
| **消耗 >> 来源** | 持续稀缺 | 挫败感与卡门槛 |
| **正反馈循环** | 资源越多 → 越容易获取更多 | 赢家通吃，滚雪球 |
| **没有追赶机制** | 落后会加速差距 | 不可挽回的状态 |

```
🔴 Economic Imbalance: Unbounded Positive Feedback
gold economy:
  Sources: monster drops (scales with player power), merchant selling (unlimited)
  Sinks: equipment purchase (one-time), ability upgrades (finite count)
→ After equipment and abilities are purchased, gold has no sink.
  Infinite surplus. Gold becomes meaningless mid-game.
  Add ongoing gold sinks (upkeep, consumables, cosmetics, gambling).
```

### 3e：难度曲线一致性

当多个系统随玩家成长而缩放时，它们必须以兼容的方向和兼容的速率缩放。不匹配的缩放曲线会制造意外的难度尖峰或使内容变得无足轻重。

对于每个随时间缩放的系统，提取：
- 缩放什么（敌人生命值、玩家伤害、资源成本、区域大小）
- 如何缩放（线性、指数、阶梯式）
- 何时缩放（等级、时间、区域）

比较所有缩放曲线。标记不匹配：

```
⚠️  Difficulty Curve Mismatch
combat.md: Enemy health scales exponentially with area (×2 per area)
progression.md: Player damage scales linearly with level (+10% per level)
→ By area 5, enemies have 32× base health; player deals ~1.5× base damage.
  The gap widens indefinitely. Late areas will become inaccessibly difficult
  unless the curves are reconciled.
```

### 3f：支柱对齐

每个系统都应明确服务于至少一个设计支柱。不服务于任何支柱的系统是"设计层面的范围蔓延" — 它存在于游戏中，但不服务于游戏试图成为的样子。

对每个 GDD 系统，检查其 Player Fantasy 章节与设计支柱是否对齐。标记任何所述幻想无法映射到任何支柱的系统：

```
⚠️  Pillar Drift
fishing-system.md: Player Fantasy — "peaceful, meditative activity"
Pillars: "Brutal Combat", "Tense Survival", "Emergent Stories"
→ The fishing system serves none of the three pillars. Either add a pillar
  that covers it, redesign it to serve an existing pillar, or cut it.
```

同时检查反支柱 — 标记任何做了反支柱明确声明游戏**不会**做的事的系统：

```
🔴 Anti-Pillar Violation
Anti-Pillar: "We will NOT have linear story progression — player defines their path"
main-quest.md: Defines a 12-chapter linear story with mandatory sequence
→ This system directly violates the defined anti-pillar.
```

### 3g：玩家幻想一致性

所有系统之间的玩家幻想应当相互兼容 — 它们应强化一个一致的玩家身份，即玩家在这个游戏中**是**什么。相互冲突的玩家幻想会造成身份混乱。

```
⚠️  Player Fantasy Conflict
combat.md: "You are a ruthless, precise warrior — every kill is earned"
dialogue.md: "You are a charismatic diplomat — violence is always avoidable"
exploration.md: "You are a reckless adventurer — diving in without a plan"
→ Three systems present incompatible identities. Players will feel the game
  doesn't know what it wants them to be. Consider: do these fantasies serve
  the same core identity from different angles, or do they genuinely conflict?
```

---
