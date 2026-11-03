# Economy Model: [System Name]

*Created: [Date]*
*Owner: economy-designer*
*Status: [Draft / Balanced / Live]*

---

## Overview

[该经济模型涵盖哪些资源、货币与兑换系统？
它激励哪些玩家行为？]

---

## Currencies

| Currency | Type | Earn Rate | Sink Rate | Cap | Notes |
| ---- | ---- | ---- | ---- | ---- | ---- |
| [Gold] | Soft | [per hour] | [per hour] | [max or none] | [交易主货币] |
| [Gems] | Premium | [per day F2P] | [varies] | [max] | [付费货币，可购买获得] |
| [XP] | Progression | [per action] | [level-up cost] | [none] | [不可交易] |

### Currency Rules
- [规则 1 —— 例如 "Soft currency has no cap but inflation is controlled via sinks"]
- [规则 2 —— 例如 "Premium currency cannot be converted back to real money"]
- [规则 3]

---

## Sources (Faucets)

| Source | Currency | Amount | Frequency | Conditions |
| ---- | ---- | ---- | ---- | ---- |
| [Quest completion] | Gold | [50-200] | [per quest] | [随任务难度缩放] |
| [Enemy drops] | Gold | [1-10] | [per kill] | [受幸运属性修正] |
| [Daily login] | Gems | [5] | [daily] | [连续登录奖励：每连续一天 +1] |
| [Achievement] | XP | [100-500] | [one-time] | [按成就等级] |

---

## Sinks (Drains)

| Sink | Currency | Cost | Frequency | Purpose |
| ---- | ---- | ---- | ---- | ---- |
| [Equipment purchase] | Gold | [100-5000] | [as needed] | [战力成长] |
| [Repair costs] | Gold | [10-100] | [per death] | [死亡惩罚，金币消耗] |
| [Cosmetic shop] | Gems | [50-500] | [optional] | [外观，付费消耗点] |
| [Respec] | Gold | [1000] | [rare] | [构筑试验成本] |

---

## Balance Targets

| Metric | Target | Rationale |
| ---- | ---- | ---- |
| Time to first meaningful purchase | [X minutes] | [玩家应尽早感受到消费能力] |
| Hourly gold earn rate (mid-game) | [X gold/hr] | [基于单次游玩时长与购买节奏] |
| Days to max level (F2P) | [X days] | [足以维持留存，又不至于漫长到令人沮丧] |
| Sink-to-source ratio | [0.7-0.9] | [略有盈余，让玩家感觉富有] |
| Premium currency F2P earn rate | [X/week] | [每月足以买点东西，但买不全] |

---

## Progression Curves

### Level XP Requirements
| Level | XP Required | Cumulative XP | Estimated Time |
| ---- | ---- | ---- | ---- |
| 1→2 | [100] | [100] | [10 min] |
| 5→6 | [500] | [1,500] | [2 hrs] |
| 10→11 | [1,500] | [7,500] | [8 hrs] |
| 20→21 | [5,000] | [50,000] | [40 hrs] |

*Formula*: `XP(n) = [formula, e.g., 100 * n^1.5]`

### Item Price Scaling
*Formula*: `Price(tier) = [formula, e.g., base_price * 2^(tier-1)]`

---

## Loot Tables

### [Drop Source Name]
| Item | Rarity | Drop Rate | Pity Timer | Notes |
| ---- | ---- | ---- | ---- | ---- |
| [Common item] | Common | [60%] | [N/A] | [始终有用，不会让人失望] |
| [Uncommon item] | Uncommon | [25%] | [N/A] | [可感知的提升] |
| [Rare item] | Rare | [12%] | [10 drops] | [令人兴奋，可定义构筑] |
| [Legendary item] | Legendary | [3%] | [30 drops] | [改变玩法，值得庆祝的时刻] |

### Pity System
[描述保底系统如何运作，以避免极端连续的坏运气。]

---

## Economy Health Metrics

| Metric | Healthy Range | Warning Threshold | Action if Breached |
| ---- | ---- | ---- | ---- |
| Average player gold | [X-Y at level Z] | [>Y or <X] | [调整产出/消耗] |
| Gold Gini coefficient | [<0.4] | [>0.5] | [财富过于集中] |
| % players hitting currency cap | [<5%] | [>10%] | [提高上限或增加消耗点] |
| Premium conversion rate | [2-5%] | [<1% or >10%] | [重新平衡 F2P 获取速度] |
| Average time between purchases | [X minutes] | [>Y minutes] | [没有值得购买的东西] |

---

## Ethical Guardrails

- [不付费获胜：付费货币不能购买玩法上的战力优势]
- [所有随机掉落均设保底：在 X 次尝试内必定获得]
- [向玩家展示透明的掉落概率]
- [未成年账号消费限额]
- [核心物品不制造人为稀缺压力（FOMO 倒计时）]

---

## Simulation Results

[如有经济模拟结果，请附上：玩家财富随时间的分布、
消耗点有效性、通胀率等。]

---

## Dependencies

- Depends on: [combat balance, quest design, crafting system]
- Affects: [difficulty curve, player retention, monetization]
- Must coordinate with: `game-designer`, `live-ops-designer`, `analytics-engineer`
