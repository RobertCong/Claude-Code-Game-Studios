# 完整概念流程（`workflow: standard` 或 `full`）

**本文件内容：** 开始 · Phase 1 创意探索 · Phase 2 概念生成 · Phase 3 核心循环 ·
Phase 4 游戏支柱与边界 · Phase 5 玩家类型 · Phase 6 范围与可行性 · Phase 7
撰写概念 · Phase 8 后续步骤

产出物是 `design/gdd/game-concept.md`，依据 SKILL.md 指定的 game-concept 模板撰写。
每个阶段都要提问；绝不静默生成整个概念。你负责引导，由用户决定。
先在回复中写出分析，然后用简短选项标签提问。

## 开始

1. 技能名之后输入的文本可能包含类型或主题提示（`roguelike`、`cozy
   farming`）。`open` 或为空：从零开始。
2. 如果 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md` 已存在，按节读取（用 Grep 工具以 content 模式、模式 `^#` 找到
   标题，然后读取这些区段）
   并在其基础上继续或扩展，而不是重新开始。

## Phase 1: 创意探索

从人开始，而不是从游戏开始。以对话方式询问：
- 游戏里某个让他们感动或兴奋的瞬间，以及是什么造就了它。
- 他们一直想在游戏里体验、却从未找到的幻想。
- 他们投入时间最多的三款游戏，以及原因。用纯文本问这一题，绝不用
  预设选项：用户必须能输入任何游戏。
- 他们喜欢或回避的类型。然后问：挑战、放松、故事还是自我表达？

然后一起问这三个问题：
- "最希望玩家获得什么样的体验？" Challenge & Mastery / Story &
  Discovery / Expression & Creativity / Relaxation & Flow
- "你现实的开发时间线是？" Weeks / Months / 1-2 years / Multi-year
- "你处在开发旅程的哪个阶段？" First game / Shipped before / Professional background

把答案汇总成 3 到 5 句话的 **创意简报（Creative Brief）**（情感目标、品味、
约束），回读给用户并确认。

## Phase 2: 概念生成

基于简报生成**三个**不同的概念，各自方向不同，使用以下方法：
- **动词优先：** 从核心动词开始（建造、战斗、探索、解谜、生存、经营）。
- **混搭：** 类型 A + 主题 B；张力就是钩子（"farming sim + cosmic horror"）。
- **体验优先（MDA 倒推）：** 从美学（sensation、fantasy、narrative、
  challenge、fellowship、discovery、expression、submission）出发，反推到机制。

每个概念包含：暂定名称 · 电梯提案（1-2 句，能通过 10 秒测试） · 核心
动词 · 核心幻想 · 独特钩子（"like X, and also Y"） · 主要 MDA 美学 · 预估范围
（小 / 中 / 大） · 为何可能成立（一句话） · 最大风险（一句话）。

展示全部三个，然后用这五个选项提出一个问题："哪个概念引起你的共鸣？
你可以选一个、组合多个元素，或要求新的方向。" `Concept 1 — [Title]` /
`Concept 2 — [Title]` / `Concept 3 — [Title]` / `Combine elements across concepts` / `Generate
fresh directions`。在任何自动化模式下都要问它：没有任何规则能替用户决定创意
方向。不要推向某个选择。

## Phase 3: 核心循环

针对选定的概念，用由该概念衍生的选项提问，每个都带一个 `I'll describe it`
选项：
1. "核心动作的主要感受是什么？"（3-4 个契合类型与基调的选项）
2. 该概念最重要的设计变量（世界反应性、节奏、能动性），作为一个问题。

然后在回复中逐一梳理：
- **30 秒循环：** 这个动作本身是否令人满足，为什么（反馈、时机、深度）？
- **5 分钟循环：** 什么把瞬间变成循环；"再来一局"从何处开始；做出的选择。
- **单次会话循环（30-120 分钟）：** 一次完整会话、它的停止点、会话之间的钩子。
- **成长循环：** 玩家如何成长、长期目标、游戏何时结束。
- **动机（自我决定理论）：** 自主性、胜任感、关联感。

## Phase 4: 游戏支柱与边界

起草 **3 到 5 个游戏支柱（pillar）**，每个都有名称、一句话定义和设计测试（"在
X 或 Y 之间纠结时，这个支柱选择 __"）。支柱之间应略有相互拉扯。添加 **3 个或更多
反支柱**："我们不会做 [thing]，因为那会损害 [pillar]。"

询问："这些支柱适合你的游戏吗？" `Lock these in` / `Rename or reframe one` /
`Swap a pillar out` / `Something else`。修改之后询问："支柱已更新。准备好锁定它们了吗？" `Lock these in` / `Revise another pillar` / `Something else`。
- `collaborative`：重复直到用户选择 `Lock these in`。
- `guided`：问一次，应用修改，然后锁定。
- `autonomous`：不问；直接锁定草稿，并连同备选方案记录决策。

**评审模式**（来自设置块或 `--review`）：
- `solo` 或 `lean`：打印这两行（带上该模式的名称），然后进入 Phase 5：
  `CD-PILLARS skipped — Solo mode.` 和 `AD-CONCEPT-VISUAL skipped — Solo mode.`
- `full`：把游戏支柱评审交给 `creative-director` 代理（闸门 CD-PILLARS；简报：带有设计测试的
  支柱、反支柱、核心幻想与钩子），把视觉评审交给
  `art-director` 代理（闸门 AD-CONCEPT-VISUAL；简报：提案、支柱、已知的目标平台、
  提到的参考游戏）。各自读取自己的闸门文件并返回结论；两者都不
  编辑文件。它们相互独立：能并行就一起发出，否则一个接一个。

拿到两份报告后，当 CD-PILLARS 返回 APPROVE 时，一起问这两个问题：
- **游戏支柱：** creative-director 的反馈。`Lock in as-is` / `Revise [pillar]` / `Discuss
  further`。
- **视觉锚点：** art-director 给出的 2-3 个命名方向，各为一个选项，外加 `Combine
  elements across directions` / `Describe my own direction`。为 STRONG 时把主导方向标记
  `(Recommended)`。为 CONCERNS 时展示其理由并提供 `Revise pillars` / `Describe my own
  direction`。

如果 CD-PILLARS 返回 CONCERNS 或 REJECT，先解决支柱问题（只问游戏支柱问题），
然后再单独问视觉锚点问题。任一闸门返回 NOT ASSESSED 都不是批准：指出
缺失的输入，补齐后重新运行该闸门；若无法做到，把 CD-PILLARS NOT ASSESSED
视为 CONCERNS，并且在 art-director 没有给出方向时只提供 `Describe my own direction`。

所选方向即 **视觉识别锚点（Visual Identity Anchor）**：它写入概念文档，并为美术
圣经播下种子。

## Phase 5: 玩家类型

使用 Bartle 类型学和 Quantic Foundry 模型：会爱上它的主要玩家
（Achievers、Explorers、Socializers、Competitors、Creators、Storytellers）、次要吸引力、
它不适合谁，以及服务同一类玩家的成功游戏。

## Phase 6: 范围与可行性

- **平台。** 询问："你们的目标平台是哪些？" `PC (Steam / Epic)` / `Mobile (iOS /
  Android)` / `Console` / `Web / Browser` / `Multiple platforms`。记录下来供 `/setup-engine` 使用。
  说明平台意味着什么，但不要推荐引擎：`/setup-engine` 会依据
  固定的引擎参考资料做出决定。
- **引擎。** 在任何自动化模式下都问，包括 `autonomous`："你已经有惯用的引擎吗？" `Godot` / `Unity` / `Unreal Engine 5` / `No preference — help me decide`。绝不要
  替用户选引擎。用户点名的引擎即记录为其偏好，不做二次揣测。无偏好时：
  "本次会话之后运行 `/setup-engine`；它会结合你的概念和平台带你走完这个选择。" 此处不要给任何推荐。
- 美术流水线及其人力投入程度；内容规模（关卡、物品、小时数）；MVP（能检验核心循环是否好玩的最小
  构建）；最大的技术、设计与市场
  风险；范围层级（完整愿景，以及时间不够时发布什么）。

**评审模式** 在 TD-FEASIBILITY 之前：`solo` 或 `lean` 打印 `TD-FEASIBILITY skipped — Solo
mode.`（或 `Lean mode`）然后进入范围层级。`full`：在技术风险之后，把
可行性评审交给 `technical-director` 代理（闸门 TD-FEASIBILITY；简报：核心循环、
平台、引擎或 "undecided"、技术风险）。展示其报告。HIGH RISK：主动提出重新审视
范围。CONCERNS：记录并继续。NOT ASSESSED：指出缺失的输入，并在概念的
风险中记录可行性为未评估，绝不要记为 VIABLE。

**评审模式** 在 PR-SCOPE 之前：`solo` 或 `lean` 打印 `PR-SCOPE skipped — Solo mode.`（或 `Lean
mode`）然后进入 Phase 7。`full`：把范围评审交给 `producer` 代理（闸门 PR-SCOPE；
简报：完整愿景、MVP、范围层级、时间线、团队规模）。它回答 REALISTIC、OPTIMISTIC 或
UNREALISTIC。UNREALISTIC：询问是调整 MVP 还是范围层级，或保持不变；由用户
决定，概念绝不因此被否决。OPTIMISTIC：展示制作人的调整并
询问是否采纳。NOT ASSESSED：索取缺失的输入（时间线、团队规模）并再次运行，
或者记录范围为未评估，绝不要记为 REALISTIC。

## Phase 7: 撰写概念

依据对话填写模板的每一节，包括 MDA 分析、动机
画像与心流设计，外加一个 **视觉识别锚点（Visual Identity Anchor）** 节：方向的名称、其
一句话视觉规则、2-3 条带设计测试的支撑原则，以及色彩哲学。

核心身份（Core Identity）表中的预估范围要与范围层级（Scope Tiers）中的完整愿景时间线一致：写
"Large (X–Y months, solo)" 或 "Large (X–Y months, team of N)"，而不是 "Large"。

单独提问："游戏概念已就绪。我可以把它写入 `design/gdd/game-concept.md` 吗？"
`Yes — write it` / `Not yet — revise a section first`。只有对该问题的明确 yes 才写入。需要修改时：
询问改哪一节（`Elevator Pitch` / `Core Fantasy & Unique Hook` /
`Pillars` / `Core Loop` / `MVP Definition` / `Scope Tiers` / `Risks` / `Something else — I'll
describe`），展示修改前后，然后询问 "准备好写入更新后的概念文档了吗？"
`Yes — write it` / `Revise another section`。
- `collaborative`：重复直到 yes。
- `guided`：问一次，应用修改并写入。
- `autonomous`：不问；直接写入并记录决策。

写入文件，按需创建文件夹。在此层级绝不写 `design/game-brief.md`。

## Phase 8: 后续步骤

按顺序列出每一步。

**设计优先**（概念已定义清楚）：
1. `/setup-engine`：配置引擎及其版本感知的参考资料
2. `/art-bible`：视觉识别，先于任何 GDD。在 `full` 下是技术设置闸门（Technical Setup gate）之前
   的必需项；在 `standard` 下仅当游戏有视觉资源用户故事时需要
3. `/design-review design/gdd/game-concept.md`：检查概念是否完整
4. `creative-director` 代理：完善游戏支柱
5. `/map-systems`：在系统索引中列出系统、它们的依赖与优先级
6. `/design-system`：为第 5 步中的每个系统写一份 GDD
7. `/create-architecture`：架构蓝图及其必需 ADR 列表
8. `/architecture-decision`：为该列表上的每个决策写一份 ADR
9. `/architecture-review`：TR 注册表与可追溯性矩阵（预生产闸门之前需要）
10. `/gate-check`：进入生产（Production）之前的阶段闸门

**原型优先**（核心机制尚未得到验证）：
1. `/setup-engine`
2. `/prototype [core mechanic]`：它好玩吗，最多一天，一次性代码
3. PROCEED：`/art-bible`，然后结合原型所学做设计优先的第 5-10 步
4. PIVOT：带上经验教训再次 `/brainstorm`
5. 完成设计与架构之后、投入冲刺（sprint）之前，运行 `/vertical-slice`

然后写一个总结：提案、游戏支柱、主要玩家类型、引擎偏好、最大风险和
文件路径。以这一行结尾 `Verdict: COMPLETE — game concept written.`

如果在 Phase 7 之前对话变得很长，说明任何尚未写入
`design/gdd/game-concept.md` 的内容只存在于这次对话中，并在开启新会话之前写好概念。
