# Game Concept: [Working Title]

*Created: [Date]*
*Status: [Draft / Under Review / Approved]*

---

## Elevator Pitch

> [用 1-2 句话概括整个游戏。要有足够吸引力，让人想听更多。格式："这是一款
> [genre]，你在其中于 [setting] 中 [core action]，以达成 [goal]。"
>
> 检验：一个从未听说过这款游戏的人，能否在 10 秒内理解自己将会做什么？
> 如果不能，继续简化。]

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | [主类型 + 子类型] |
| **Platform** | [PC / Console / Mobile / Cross-platform] |
| **Target Audience** | [见下方 Player Profile 小节] |
| **Player Count** | [Single-player / Co-op / Multiplayer / MMO] |
| **Session Length** | [典型游玩时长：10 分钟 / 30 分钟 / 1 小时 / 2 小时以上] |
| **Monetization** | [Premium / F2P / Subscription / none yet] |
| **Estimated Scope** | [小型（1-3 个月）/ 中型（3-9 个月）/ 大型（9 个月以上）] |
| **Comparable Titles** | [2-3 款同领域的现有游戏] |

---

## Core Fantasy

[玩家能从这款游戏中获得怎样的力量、体验或感受？
他们在这里能做哪些在别处做不到的事？

核心幻想（core fantasy）是一种情感承诺。它不是功能清单——它回答的是
"为什么有人会选择这款游戏，而不是他们本可以做的任何其他事情？"

强核心幻想的例子：
- "你是一名孤独的幸存者，在充满敌意的荒野中重建生活"（生存）
- "你统领一个文明跨越数千年"（策略）
- "你按自己的节奏探索一个广阔而美丽的世界"（开放世界）
- "你精通精妙的战斗，战胜不可能的强敌"（类魂）]

---

## Unique Hook

[这款游戏与同类型其他作品有何不同？这是最重要的单一差异化点。

一个强钩子能通过"and also"测试："它像 [comparable game]，
而且还 [unique thing]。"如果这个"而且还"不能激起好奇，钩子就还需要打磨。

钩子应该：
- 能用一句话解释清楚
- 真正新颖（不只是现有功能的组合）
- 与核心幻想相连（而不是硬贴上的花招）
- 影响玩法，而不只是美术表现]

---

## Player Experience Analysis (MDA Framework)

MDA（Mechanics-Dynamics-Aesthetics，机制-动态-美学）框架确保我们从玩家的
情感体验出发，反向推导出创造这种体验的系统。

### Target Aesthetics (What the player FEELS)
为本游戏排列以下美学目标（1 = 首要，不相关则标 N/A）。这些目标来自
MDA 框架的 8 个美学类别：

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation**（感官愉悦） | [1-8 或 N/A] | [视觉美感、音频设计、触觉反馈] |
| **Fantasy**（虚构、角色扮演） | [Priority] | [世界、角色、玩家身份] |
| **Narrative**（戏剧性、故事弧线） | [Priority] | [情节结构、玩家驱动的故事] |
| **Challenge**（障碍挑战、精通） | [Priority] | [难度曲线、技巧上限] |
| **Fellowship**（社交连接） | [Priority] | [合作、公会、共享体验] |
| **Discovery**（探索、秘密） | [Priority] | [隐藏区域、涌现式系统、世界设定] |
| **Expression**（自我表达、创造） | [Priority] | [构筑多样性、外观、创作工具] |
| **Submission**（放松、舒适区） | [Priority] | [低压力循环、氛围化玩法] |

### Key Dynamics (Emergent player behaviors)
[我们希望从机制中涌现出哪些行为？玩家在没有被告知的情况下，会自然而然
开始做些什么？

示例："玩家会尝试各种能力组合以寻找协同效应"
示例："玩家会与社区分享自己的发现"]

### Core Mechanics (Systems we build)
[是哪 3-5 个机制系统产生了上述动态与美学？这些就是我们实际实现的
规则、动作动词与系统。]

1. [机制 1——例如："带耐力管理的实时战斗"]
2. [机制 2——例如："程序化生成的地牢，搭配手工打造的房间"]
3. [机制 3——例如："带可发现配方的制作系统"]

---

## Player Motivation Profile

理解玩家为什么玩，有助于我们做出每一个设计决策。基于
自我决定理论（Self-Determination Theory，SDT）与玩家需求满足体验
（Player Experience of Need Satisfaction，PENS）模型。

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy**（自由、有意义的选择） | [玩家如何感到自己掌控局面？] | [Core / Supporting / Minimal] |
| **Competence**（精通、技能成长） | [玩家如何感到自己技艺娴熟？] | [Core / Supporting / Minimal] |
| **Relatedness**（连接、归属感） | [玩家如何感到与他人相连？] | [Core / Supporting / Minimal] |

### Player Type Appeal (Bartle Taxonomy)

本游戏主要服务哪些玩家类型？

- [ ] **Achievers**（目标达成、收集、进度）——如何： [...]
- [ ] **Explorers**（发现、理解系统、寻找秘密）——如何： [...]
- [ ] **Socializers**（关系、合作、社区）——如何： [...]
- [ ] **Killers/Competitors**（支配、PvP、排行榜）——如何： [...]

### Flow State Design

当挑战与技能相匹配时，心流便会产生。本游戏如何维持心流？

- **Onboarding curve**：[最初的 10 分钟如何教会玩家？]
- **Difficulty scaling**：[挑战如何随玩家技能提升而增长？]
- **Feedback clarity**：[玩家如何知道自己在进步？]
- **Recovery from failure**：[他们能多快再试一次？失败是惩罚性的还是有教育意义的？]

---

## Core Loop

### Moment-to-Moment (30 seconds)
[玩家绝大部分时间在身体上做什么？这是最基础、最重复的动作。
它必须具备内在的满足感——如果 30 秒循环单独来看不好玩，
再多的进度系统也救不了这款游戏。]

### Short-Term (5-15 minutes)
[是什么目标或循环结构化了这种即时游玩？遭遇战、谜题、回合、任务。
"再来一回合"或"再跑一轮"的心理就存在于这一层。]

### Session-Level (30-120 minutes)
[一整个游玩时段是什么样子？玩家能完成什么？
它应当以一个自然的停止点收尾，同时给出回来的理由。]

### Long-Term Progression
[玩家如何在数天/数周内成长？角色进度、解锁、剧情推进、精通。
玩家在朝着什么努力？]

### Retention Hooks
[具体是什么把玩家带回来进行下一次游玩？]
- **Curiosity**：[未解答的疑问、未探索的区域、锁定的内容]
- **Investment**：[他们不想失去的进度、他们在意的角色]
- **Social**：[朋友在玩、公会义务、共同目标]
- **Mastery**：[可提升的技能、可克服的挑战、可攀登的排名]

---

## Game Pillars

设计支柱是指导每一个决策的不可协商原则。当两个设计选择发生冲突时，
支柱负责打破平局。控制在 3-5 个支柱。

真实的 AAA 例子：
- God of War："激烈的战斗"、"父子故事"、"世界探索"
- Hades："快速流畅的战斗"、"通过反复闯关带来的叙事深度"
- The Last of Us："故事至上"、"AI 同伴建立关系"、"鼓励潜行"

### Pillar 1: [Name]
[用一句话定义这条不可协商的设计原则。]

*Design test*：[这条支柱能解决的一个具体决策。"如果我们在 X 和 Y 之间
争论，这条支柱告诉我们要选择 __。"]

### Pillar 2: [Name]
[定义]

*Design test*：[它能解决的决策]

### Pillar 3: [Name]
[定义]

*Design test*：[它能解决的决策]

### Anti-Pillars (What This Game Is NOT)

反支柱同样重要——它们防止范围蔓延，并让愿景保持聚焦。每一个"不"
都在保护那个"是"。

- **NOT [thing]**：[为什么明确排除这一点，以及它会牺牲什么]
- **NOT [thing]**：[为什么]
- **NOT [thing]**：[为什么]

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| [Game 1] | [具体的机制、感受或做法] | [我们的差异点] | [它验证了我们概念的哪些方面] |
| [Game 2] | [我们学到什么] | [我们的差异点] | [验证] |
| [Game 3] | [我们学到什么] | [我们的差异点] | [验证] |

**Non-game inspirations**：[影响基调、世界或感受的电影、书籍、音乐、艺术、
现实世界体验。优秀的游戏常常从媒介之外汲取灵感。]

---

## Target Player Profile

[要具体。"玩家"不是一个目标受众。]

| Attribute | Detail |
| ---- | ---- |
| **Age range** | [例如 18-35] |
| **Gaming experience** | [Casual / Mid-core / Hardcore] |
| **Time availability** | [例如"工作日晚间 30 分钟一场，周末时间更长"] |
| **Platform preference** | [他们主要在哪儿玩] |
| **Current games they play** | [2-3 款具体作品] |
| **What they're looking for** | [这款游戏填补的未被满足的需求] |
| **What would turn them away** | [对这一受众而言的劝退点] |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | [Godot / Unity / Unreal 以及原因——考虑范围、团队专长、目标平台] |
| **Key Technical Challenges** | [这款游戏在技术上有哪些难点？] |
| **Art Style** | [像素 / 2D / 2.5D / 3D 风格化 / 3D 写实] |
| **Art Pipeline Complexity** | [低（资源商店 + 修改）/ 中（自制 2D）/ 高（自制 3D）] |
| **Audio Needs** | [极少 / 适中 / 音乐为主 / 自适应] |
| **Networking** | [None / P2P / Client-Server / Dedicated Servers] |
| **Content Volume** | [估算：X 个关卡、Y 个物品、Z 小时游玩时长] |
| **Procedural Systems** | [是否有程序化生成？范围多大？] |

---

## Risks and Open Questions

### Design Risks
[可能让游戏变得不好玩或不吸引人的因素]
- [风险 1——例如："核心循环可能无法支撑超过 30 分钟的游玩时段"]
- [风险 2——例如："主线故事结束后玩家动机不明确"]

### Technical Risks
[可能难以构建或无法构建的因素]
- [风险 1——例如："程序化生成的质量尚未得到验证"]
- [风险 2——例如："支持 100+ 玩家的联网可能需要专用基础设施"]

### Market Risks
[可能妨碍商业成功的因素]
- [风险 1——例如："该类型已被成熟竞品占满"]
- [风险 2——例如："目标受众可能过于小众，难以实现财务可持续"]

### Scope Risks
[可能拖垮时间线的因素]
- [风险 1——例如："内容量超出团队产能"]
- [风险 2——例如："功能 X 依赖我们尚未做原型验证的技术"]

### Open Questions
[在回答之前需要原型验证或调研的问题]
- [问题 1——以及我们计划如何回答它]
- [问题 2——以及哪个原型能解决它]

---

## MVP Definition

[能够验证核心假设的绝对最小版本。MVP 只回答一个问题：
"核心循环好玩吗？"]

**Core hypothesis**：[MVP 要检验的那一句陈述，例如"玩家会觉得战斗-制作循环
在 30 分钟以上的时段内仍然有吸引力"]

**Required for MVP**：
1. [必需功能 1——直接检验假设]
2. [必需功能 2]
3. [必需功能 3]

**Explicitly NOT in MVP**（推迟到后续）：
- [锦上添花但不能检验假设的功能]
- [增加范围却无法验证核心的功能]

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | [最小] | [仅核心循环] | [X 周] |
| **Vertical Slice** | [一个完整区域] | [核心 + 进度] | [X 周] |
| **Alpha** | [所有区域，占位] | [所有功能，粗糙] | [X 周] |
| **Full Vision** | [完整内容] | [所有功能，打磨完成] | [X 周] |

---

## Next Steps

- [ ] 从 creative-director 处获得概念批准
- [ ] 根据引擎选择填写 AGENTS.md 技术栈（`/setup-engine`）
- [ ] 创建游戏支柱文档（用 `/design-review` 验证）
- [ ] **为核心想法做原型**（`/prototype [core-mechanic]`）——在撰写 GDD 之前，先验证这个概念值得设计
- [ ] 若原型通过：将概念拆解为系统（`/map-systems`）
- [ ] 设计每个系统（`/design-system [system-name]`）——在 Tuning Knobs 与 Formulas 小节中运用原型经验
- [ ] 在预制作阶段构建垂直切片（`/vertical-slice`）——在投入正式制作前验证完整游戏循环
- [ ] 通过试玩测试验证核心循环（`/playtest-report`）
- [ ] 规划第一个里程碑（`/sprint-plan new`）
