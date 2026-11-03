---
name: vertical-slice
description: "预制作阶段验证——端到端构建，以确认在全力投入制作（Production）之前整条循环是可达的。在游戏设计文档（GDD）、架构、UX 规格之后使用。"
argument-hint: "[--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow`

上一步命令的输出已解析——按原样使用；`--review` 会覆盖本次运行的 `review_mode`。没有配置块 → 使用 `.trae/docs/config-resolution.md` 中的默认值。

# 垂直切片


## 目的

**垂直切片**回答的是与概念原型不同的问题：
*“我们能否按计划以制作级品质构建出这条完整的游戏循环？”*

**默认用法**——在预制作（Pre-Production）后期运行，此时 GDD、架构和 UX 规格均已完成。它是一次接近制作级品质的构建，用于演示一个完整的
[开始 → 挑战 → 解决]循环。

**转向之后？** 如果早先垂直切片给出的 PIVOT 判定让你回头修订 GDD 和架构，
那么在修订完成后再次运行本技能以重新验证。它可以按需运行任意多次，
直到得出 PROCEED 或 KILL 判定。

它验证：

1. 流水线（团队是否真的能产出这种品质的内容？）
2. 执行可行性（架构决策对这款游戏是否正确？）
3. 趣味存续（概念原型中的乐趣能否在完整设计中存活下来？）
4. **速度**（这花了多长时间？那就是你真实的生产速率估计。）

**在项目更早阶段？** 如果你还没写 GDD，想验证核心创意是否值得设计，
请改运行 `/prototype`（概念原型）。

---

## Phase 1: 解析评审模式并加载上下文


完整的检查模式见 `.trae/docs/director-gates.md`。各质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md`——被派生的代理会读取自己的闸门文件；不要在本父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式始终询问 · 引导模式仅询问重大决策 · 自主模式记录并继续；
`automation_always_ask` 类别始终询问）。

读取以下文件以理解完整的设计意图。按章节读取每份 GDD、ADR
和控制清单：先用 Grep 工具（模式 `^#`，内容模式）找到你需要的标题，
再用 offset 和 limit 读取相应范围。
- `AGENTS.md`——技术栈与引擎
- `design/gdd/game-concept.md`——核心幻想与游戏支柱（或在
  `rigor: minimal` 时代替它的一页简报 `design/game-brief.md`——
  即提案、核心循环和“他们的感受”那一行；它没有支柱）
- `design/gdd/systems-index.md`——MVP 系统及其优先级
- `docs/architecture/architecture.md`——分层结构
- `docs/architecture/control-manifest.md`——实现的技术规则
- 被切片系统的关键 GDD

---

## Phase 2: 定义切片范围与验证问题

在构建之前，先定义**可证伪的验证问题**：

> *“一名玩家从零开始，能否在 [N] 分钟内、在没有任何开发者引导的情况下体验到
> [game-concept.md 或 game-brief.md 中的核心幻想]——而我们能否在 [X] 天内
> 以代表性品质构建出一个这样的循环？”*

两部分都重要：玩家体验和构建可行性。

**范围纪律：**
- 纳入所有核心循环系统（最低要求）。如果某个系统是完成一个
  [开始 → 挑战 → 解决]循环所必需的，它就必须在切片内。
- **目标范围：3–5 分钟打磨过的、连续可玩的玩法。** 这是
  行业标准的垂直切片时长——长到足以展示机制与调性，短到能以代表性品质完成构建。
  如果你的切片通关时间会超过 5 分钟，就削减内容，而不是降低品质。
- **先削减范围，再考虑削减品质。** 一个看起来完全不像目标游戏的低品质切片
  无法验证生产可行性。
- 如果范围感觉大到无法在 1–3 周内构建，那么切片范围就是错的——
  问题不是太大难以构建，而是切片试图一次证明太多东西。

**范围蔓延警告：** 垂直切片是预制作阶段中范围蔓延风险最高的时刻。
功能感觉“就差一点”，很容易想再加“就一个系统”。要抵制。削减，而不是扩展。

在构建前向用户展示范围并获得确认。

---

## Phase 3: 规划构建

用要点定义：
- 实现的系统（正在演练哪些 GDD 章节）
- 完整的游戏循环周期（严格为 [开始] → [挑战] → [解决]）
- 美术与音频品质水平（占位素材可接受，代表性素材更佳）
- 验证问题具体、可衡量的成功标准
- 硬性时间限制：[X] 天。若超出，说明范围有误——停下来重新评估。

在构建前请用户确认范围。在该确认中点明检查点文件：
“我可以把这份计划记录到 `production/session-state/active.md` 吗？”

确认后，向 `production/session-state/active.md` 写入会话检查点
（若 `production/session-state/` 不存在则创建）。内容包括：概念名称、
验证问题、范围内的系统、美术品质水平，以及当前阶段（“Phase
4 — 实现”）。每个构建日结束时更新此文件，记录已完成的内容。
如果会话在切片中途结束，这是主要的恢复机制——
跨越数周的引擎构建会横跨多个会话。

---

## Phase 4: 实现

询问：“我可以在
`prototypes/[concept-name]-vertical-slice/` 创建垂直切片目录并开始实现吗？”

如果同意，创建该目录。每个文件都必须以如下内容开头：

```
[comment] VERTICAL SLICE - NOT FOR PRODUCTION
[comment] Validation Question: [What this build is proving]
[comment] Date: [Current date]
```

用每个文件自身的注释语法书写 `[comment]`——GDScript（`.gd`）和
Python 中用 `#`，C#、C++ 和 JavaScript 中用 `//`，Lua 中用 `--`，HTML 和
Markdown 中用 `<!-- … -->`。用其他语言语法写的头部是解析错误，而不是标签。
无法容纳注释的文件（JSON、引擎生成的场景和项目
文件）除外。

**品质标准**——高于概念原型，但未达完整制作级：
- 遵循 `docs/architecture/control-manifest.md` 中的架构分层
- 命名约定——来自 `project.yaml` 的 `naming.*`；任何缺失或为空键（包括
  `project.yaml` 没有 `naming` 块的情况），来自 `.trae/docs/technical-preferences.md`
- 没有硬编码的玩法数值——使用常量或配置文件
- 关键路径上有基本的错误处理
- 占位美术可接受；代表性美术更佳

**多轮循环：** 写完初始文件后，请用户运行构建
并报告他们的观察结果。反复迭代，直到完整游戏循环周期
可演示。每一轮：
1. 用户运行 → 报告错误或观察结果
2. 代理修复错误或调整系统
3. 重复，直到完整的[开始 → 挑战 → 解决]循环可玩

**沉没成本检查点（计划时间线的第 3 天）：** 如果完整游戏循环周期
仍不可演示，停下来重新评估。要么范围太大，要么某个
架构假设是错的。明确暴露该阻塞项，而不是
继续迭代。

一旦循环可演示，至少进行 1 次试玩测试会话。

**试玩测试技巧：** 如果你能找任何没看过这游戏的人来玩——
朋友、家人、线上社群——在旁边安静观看，不做任何解释。
不要引导他们。他们的困惑揭示了游戏自身没能传达的东西。
这比自我测试能提供好得多的信号。

**没有外部测试者？** 在团队内部轮换：开发者 A 构建了
系统 X，所以开发者 A 是系统 Y 的天真测试者。即便是两人团队也能
有效轮换。独自一人？离开 2-3 天，然后以新玩家的身份通关——
你不会有完美的第一印象信号，但能抓到关键的阻塞项。也可以试试“静默走查”：
一次性玩完自己的切片，不中途停下来修任何东西，并记录你每一次犹豫的瞬间。

**想要更丰富的观察数据？** 请测试者边玩边**出声思考**——
实时叙述他们在做什么以及为什么。“我想搞清楚怎么攻击……我按了 E……没反应……
是要点击吗？”这能在困惑发生的瞬间而非事后浮现出来。最适合上手引导和 UI
清晰度验证。静默观察仍然更适合手感测试；出声思考会略微改变体验，
但能产生细致得多的 UX 数据。

**异步远程选项：** 录制一段 Loom 或 OBS 会话——把构建交给某人，
请他们录制屏幕 + 音频，然后把视频发给你。你无需同步安排就能获得
真实的第一印象数据。跨时区也能用。

**在 AI、NPC 或复杂系统行为完全实现之前就要测试？** 使用
**绿野仙踪（Wizard of Oz）**技巧：一个人正常游玩，另一个人暗中
实时控制 NPC 或系统行为。玩家相信它是自动化的。
这能在实现完成之前验证 AI 或经济系统的*设计意图*——
并准确揭示系统必须产出哪些行为才感觉正确。
对于 AI 系统在范围内但尚未打磨到可无引导测试程度的垂直切片尤其有用。

---

## Phase 5: 试玩测试复盘

循环已可演示。在撰写报告之前，先收集来自实际游玩的
结构化观察。不要跳到生成报告——报告的质量取决于你在此处
捕获的观察。

原样说出：
> “请从头开始完整地玩一遍[开始 → 挑战 → 解决]循环，
> 就像一名对构建方式一无所知的新玩家。不要跳关
> 或使用开发者捷径。完成整个循环后回来——
> 或者在你遇到卡住的地方时回来。”

用户返回后，**一次一个**地问以下问题：

1. **循环完成：**
   > “你是否在没有我任何引导、也没有对该构建任何先前了解的情况下，
   > 自己完成了整个[开始 → 挑战 → 解决]循环？”

2. **时间检查：**
   > “到达第一个有意义的动作——你第一次感觉
   > 自己真的在玩这个游戏的时刻——花了多长时间？”

3. **核心幻想：**
   > “这个游戏本应让你感到 [game-concept.md 或 game-brief.md 中的核心幻想]。
   > 它做到了吗？请诚实回答——不要‘有点’，而是具体说你感受到了什么、什么时候感受到的。”

4. **阻塞项：**
   > “什么阻止了你、让你困惑，或把你拉出了体验？有没有
   > 你不确定该做什么，或某处出故障的时刻？”

5. **流水线检查：**
   > “作为开发者——而不是玩家——你觉得以这种品质扩展到完整游戏
   > 是可实现的吗？构建耗时上有哪些让你意外的地方？”

6. **结论：**
   > “PROCEED、PIVOT 还是 KILL——以及具体原因。”

如果任何回答含糊，就问：“你能告诉我那发生的具体时刻吗？”
精确的观察才能充实报告。含糊的观察只会产生一份无用的报告。

**当某个验证项为 NO 时，PROCEED 不可用。** `/gate-check production`
会让任何垂直切片验证项为 NO 的已构建切片 FAIL——玩家在无开发者引导的情况下
走通循环（问题 1）、在前 2 分钟内学会该做什么（问题 2——更长即为 no）、
核心机制感觉良好（问题 3）、没有关键的乐趣阻塞性缺陷（问题 4）。若其中任何
答案是否，判定就是 PIVOT 或 KILL——由用户选择——报告中要点名那个 NO。

**NOT ASSESSED 是第四种判定。** 当还没有人从头开始玩过完整
循环——用户本次会话无法游玩，或在结束前停下——验证就没有运行，
判定为 **NOT ASSESSED**，并给出原因。它排在 PROCEED 之上、PIVOT 和 KILL 之下：
一个未玩过的切片还没有挣得 PROCEED，而一个已知失败的切片比一个人人都没玩过的
切片更可操作。它绝不会被记录为 PROCEED。

---

## Phase 6: 生成垂直切片报告


在整个构建过程中跟踪速度。记录：
- 第 1 天：构建了什么
- 第 2 天：构建了什么
- 等等。

这是你所能拥有的关于自己生产速率最诚实的数据。不要
跳过。它直接输入到冲刺规划中（在 `workflow: minimal` 下，该层级没有
冲刺，则输入到简报的构建顺序中）。

阅读 `.trae/docs/templates/vertical-slice-report.md` 获取报告结构。
如果找不到该模板文件，使用以下后备结构：
- `## Vertical Slice Report — [Game Title] — [Date]`
- `### Executive Summary`（PROCEED / PIVOT / KILL / NOT ASSESSED 判定 + 2 句话的理由）
- `### Core Loop Validation`（测试了什么、什么通过、什么失败）
- `### Feel Assessment`（动画、操控、反馈——主观记录）
- `### Technical Findings`（性能、引擎问题、架构风险）
- `### Velocity Log`（逐日的实际进展——不要跳过）
- `### Lessons Learned`（通过以接近制作级品质构建而打破的假设；
  流水线或架构上让我们意外的地方；下次我们会
  如何调整切片范围）
- `### Recommended Next Steps`

根据本次会话中观察到和构建出的内容填写每一节。
速度日志必须反映实际的逐日进展，而不是估计——这是
你所能拥有的最诚实的生产速率数据。用真实的观察替换所有占位
文本。建议应承载 Phase 5 的判定，包括
NOT ASSESSED，并附原因。

询问：“我可以把这份报告写入
`prototypes/[concept-name]-vertical-slice/REPORT.md`，并把其行添加到
`prototypes/index.md` 吗？”

如果同意，写入该文件。然后更新 `prototypes/index.md`（若不存在则创建）——
向垂直切片表格追加一行：概念名称、日期、判定，
以及指向 REPORT.md 的链接。注明这是首次运行的切片还是 PIVOT
之后的重跑。本报告中的速度日志是项目中最有价值的数据之一——
把它与冲刺估算交叉参照。

---

## Phase 7: 创意总监评审

**评审模式检查：**
- `solo` → 跳过。注明：“CD-PLAYTEST 已跳过——Solo 模式。”
- `lean` → 跳过（不是 PHASE-GATE）。注明：“CD-PLAYTEST 已跳过——Lean 模式。”
- `full` → 通过 `Agent` 派生 `creative-director`，使用闸门 **CD-PLAYTEST**
  （`.trae/docs/director-gates/cd-playtest.md`）——除非该切片的判定是
  NOT ASSESSED：没有通关就没有可评审的内容，因此注明
  “CD-PLAYTEST 已跳过——该切片尚未被游玩。”

传入：完整的 REPORT.md 内容、验证问题、游戏支柱和核心
幻想（来自 `design/gdd/game-concept.md`，或在 `rigor: minimal` 下来自
`design/game-brief.md` 的提案和“他们的感受”那一行）。

创意总监依据游戏的创意愿景和支柱评估垂直切片结果，
并返回该闸门的判定之一——APPROVE、
CONCERNS 或 REJECT。将其应用到建议上：

- **APPROVE** → 建议成立。
- **CONCERNS** → 在建议旁展示关注项，然后用
  `AskUserQuestion`：`Revise the recommendation` / `Accept with noted concerns` /
  `Discuss further`。由用户决定；总监不做决定。
- **REJECT**（核心幻想不存在）→ PROCEED 建议不能
  成立。使用 `AskUserQuestion` 请用户选择 `PIVOT` 或 `KILL`，并针对该选择运行
  Phase 8。PIVOT 或 KILL 建议成立。
- **NOT ASSESSED** [missing input] → 总监未做判断，因此它既不
  支持也不推翻建议（`.trae/docs/director-gates.md`）：点明
  缺失了什么，然后补充并重新运行闸门，或者记录
  `CD-PLAYTEST: NOT ASSESSED — [input]` 到报告中。

当总监返回 CONCERNS、REJECT 或 NOT ASSESSED 时，询问“我可以更新
`prototypes/[concept-name]-vertical-slice/REPORT.md` 以及它在
`prototypes/index.md` 中的行吗？”，然后在 REPORT.md 中记录总监的判定和原因，
并在两者中记录最终建议（若其发生变化）。

---

## Phase 8: 总结与后续步骤

输出一份总结：验证问题、速度数据以及最终建议。
链接到 `prototypes/[concept-name]-vertical-slice/REPORT.md`。

**如果是 PROCEED：**
你的垂直切片验证了完整的游戏循环。项目已准备好进入
制作阶段。

在 `workflow: minimal` 下：`/create-stories`（从简报开始），然后对
第一个用户故事运行 `/dev-story`——本清单其余部分是 `standard`/`full` 路径。

推荐的后续步骤（`standard`/`full`）：
- `/create-epics layer:foundation`——规划 Foundation 层史诗（epic）
- `/create-epics layer:core`——规划 Core 层史诗
- `/create-stories [epic-slug]`——把每个史诗拆解为可实现的用户故事
- `/sprint-plan`——使用切片的速率数据规划第一个冲刺
- `/gate-check production`——正式将阶段推进到制作

**试玩测试说明：** `/gate-check` 会查找有记录的试玩测试证据。
至少需要 1 次有记录的会话，其 REPORT.md 显示 PROCEED，才能通过
闸门。更多会话能提供更可靠的信号——在让整个团队投入制作之前建议 3 次以上，
但这并非硬性闸门。

**如果是 PIVOT：**

在回到 GDD 修订之前，先捕获结转说明。问以下
两个问题（纯文本，一次一个）：

1. “在这个品质水平上，哪些系统或机制是有效的，应在修订后的设计中保留？”
2. “具体是什么失败了——核心循环、架构、流水线，还是乐趣？”

询问：“我可以把它写入 `prototypes/[concept-name]-vertical-slice/PIVOT-NOTE.md` 吗？”

如果同意，写入该文件，包含：哪些有效、哪些失败、需要
修订的具体系统或架构决策，以及下一个切片应换一种方式证明什么。
当下一次在 PIVOT 之后运行 `/vertical-slice` 时，检查
`prototypes/` 目录中是否有 `PIVOT-NOTE.md`——用它来构建新的验证
问题并指导范围决策。

- 用 `/design-system [mechanic]` 修订受影响的 GDD
- 通过 `/architecture-decision` 处理架构问题
- 然后重新运行 `/vertical-slice` 验证修订后的方向

**如果是 KILL：**

在放弃该概念之前，确认判定是可靠的：

- [ ] 即便是经验丰富的玩家，完整游戏循环耗时也 >5 分钟？
- [ ] 在任何试玩测试会话中都未观察到情绪高点（愉悦、惊喜、满足）？
- [ ] 在 2 次以上切片尝试后，50%+ 的测试者在同一点困惑或卡住？
- [ ] 架构问题需要重建已构建内容中超过 50% 的部分？
- [ ] 这是同一概念的第 3 次垂直切片尝试？

如果勾选 2 项以上 → KILL 判定是可靠的。如果勾选 0–1 项 → 一次有针对性的 PIVOT 可能挽救该概念。

**在 `prototypes/GRAVEYARD.md` 中记录这次终止**（若不存在则创建）。
询问：“我可以把它追加到 `prototypes/GRAVEYARD.md` 吗？”如果同意，添加一条记录：

```
## [Concept Name] Vertical Slice — YYYY-MM-DD
- **Kill reason:** [what specifically prevented the player from experiencing the core fantasy]
- **What worked at slice quality:** [systems or mechanics that held up]
- **What failed:** [core loop issue, architecture decision, or pipeline blocker]
- **Next time:** [one specific change for the next time a similar concept is attempted]
```

- 带着所学回到 `/brainstorm`
- 或者运行 `/prototype [new-concept]` 先低成本地测试一个新方向

**如果是 NOT ASSESSED：**

切片已构建但未验证。说明适用的是哪种原因，然后完成
Phase 5 的通关和复盘——`production/session-state/active.md`
检查点就是恢复的位置——并且，在询问之后，用判定更新 REPORT.md 及其
`prototypes/index.md` 中的行。不要把切片拿去
`/gate-check production`，仿佛它已经通过：NOT ASSESSED 不是 PROCEED。

---

### 重要约束

- 垂直切片代码绝不能重构进生产——它仅供参考
- 生产代码绝不能从 `prototypes/` 导入
- 如果建议是 PROCEED，生产实现应从头编写，
  仅把切片作为设计参考
- 可以接受削减范围；不可以削减品质——低品质切片证明不了任何东西
- 总工作量：1–3 周。如果更长，说明范围太大——削减切片，而不是品质。
- 第 3 天沉没成本规则：如果到那时完整游戏循环周期仍不可演示，
  停下来并暴露阻塞项
- **联网/多人游戏：** 本地垂直切片无法验证联网机制的
  手感。延迟会从根本上改变战斗、移动和
  预测的手感——在 0ms 本地测试的手感，到 80ms
  网络延迟下会完全不同。切片可以验证游戏循环有趣且完整；
  它无法验证联网机制在真实条件下手感良好。网络手感需要真实
  对端或模拟延迟。