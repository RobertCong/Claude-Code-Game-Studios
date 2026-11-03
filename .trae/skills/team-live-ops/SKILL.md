---
name: team-live-ops
description: "编排长线运营（Live Ops）团队——live-ops-designer、economy-designer、analytics-engineer、community-manager、writer——负责一个赛季或运营活动。"
argument-hint: "[season name or event description] [--review full|lean|solo]"
user-invocable: true
---
# 长线运营团队（Team Live Ops）

**参数检查：** 如果未提供赛季名称或活动描述，输出：
> "用法：`/team-live-ops [season name or event description] [--review full|lean|solo]` —— 请提供要规划的赛季或运营活动的名称或描述。"
然后立即停止，不生成任何子代理，也不读取任何文件。

当本技能带有效参数被调用时，通过结构化的规划流水线编排长线运营团队。

**决策点：** 在每个阶段切换处，使用 `AskUserQuestion`
把子代理的提案作为可选项呈现给用户。在对话中写出该代理的
完整分析，然后用简洁标签记录决定。
在 `collaborative` 模式下，用户必须先批准才能进入下一阶段。
在 `guided` 模式下，除非某阶段为 BLOCKED，流水线会自动推进；
在 `autonomous` 模式下，它端到端运行，并通过
`log_decision` 记录每个阶段的结果。`automation_always_ask` 类别中的决策
（`is_always_ask_category` 辅助函数）无论何种模式都会始终提示。参见
`.trae/docs/automation-modes.md`。

## Phase 0: 解析配置

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size,workflow`

以上命令的输出已解析——直接使用；`--review` 覆盖 `review_mode`。无配置块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

`review_mode` 设定总监闸门（director gate）的深度，而本流水线没有总监闸门：
无论 `review_mode` 为何，下面的任何阶段都不会生成 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义在下面的 `team.size` 之下），
而在这些点上工作的代理是团队成员，不是总监闸门。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，参见上面的决策点说明和
`.trae/docs/automation-modes.md`。

**`team.size`**：哪些代理处于活动状态（与 review_mode 的闸门深度和工作流文档相互正交）。
- **`individual`**（默认）：`live-ops-designer` + `economy-designer`。其他代理通过这两者咨询，不单独生成。
- **`small`**：+ `analytics-engineer` + `community-manager`。
- **`studio`**：+ `writer` + `narrative-director`（即文档中的完整流水线）。
在 `individual` 下需要非核心代理时，通过最近的活动核心代理转达并附上说明性备注。**"阶段闸门"指任何以本流水线自身列出的 `AskUserQuestion` 决策点结尾的阶段**——上面决策点所述的切换，或下面流水线中写明的 **Gate** 步骤——**无论 `automation` 模式为何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否算闸门，因此下面的受限例外条件（3）在每种模式下都成立。被限定为"仅在阶段闸门"的代理只在那些点被生成。此活动集限定贯穿下面的整条流水线：任何点名了活动集之外代理的阶段，都通过最近的核心代理转达，而不是生成该代理。

**在 Phase 1 之前宣告活动集——绝不要让收缩悄无声息。**
在生成任何东西之前，用一行说明本次运行实际会生成哪些代理，以及下面流水线点名、
但在解析出的 `team.size` 下**不会**生成的代理。例如：

> `Active set (team.size: <resolved>): <the agents listed for that size above>.`
> `Not spawned this run: <every other agent this pipeline names> — consulted`
> `through <nearest active core agent>. Raise team.size (or modes.rigor) to widen.`

从正上方的 `team.size` 列表和本文件自身流水线点名的代理来填写它——不要照抄示例。
两个集合因编排器而异。

下面的流水线读起来像是多代理扇出，但在出厂默认值下它只有
一两个代理——`team-release` 点名十个却只运行一个，`team-narrative`
在五个阶段中点名六个却只运行 `writer`。**收缩是正确的**：
`team.size` 以严谨度打头，而狭窄的默认值是节省 token 的杠杆。
如果不说明这一点，读者就无法
区分一次正确收缩的运行和一条损坏的流水线，而上面那条逐代理的
"通过最近的核心代理转达并附上说明性备注"规则只在路由时触发，从不说明整次运行的形状。

这与本文件他处跳过检查的上报规则相同：**一条被强制执行但从未呈现的约束，
在阅读输出的人看来，与一条从未被执行的约束无从区分。**

## 团队组成
- **live-ops-designer** —— 赛季结构、活动节奏、留存机制、战斗通行证（battle pass）
- **economy-designer** —— 运营经济平衡、商店轮换内容与价格（节奏由 live-ops-designer 设定）、货币定价、保底计时器
- **analytics-engineer** —— 成功指标、A/B 测试设计、事件追踪、仪表盘规格
- **community-manager** —— 面向玩家的公告、活动描述、赛季化消息
- **narrative-director** —— 赛季叙事主题、故事弧线、世界事件框架
- **writer** —— 活动描述、奖励物品名称、赛季风味文本、公告文案

## 如何委派

使用 `Agent` 工具把每位团队成员生成为子代理：
- 委派给 `live-ops-designer` 子代理 —— 赛季/活动结构与留存机制
- 委派给 `economy-designer` 子代理 —— 运营经济平衡与奖励定价
- 委派给 `analytics-engineer` 子代理 —— 成功指标、A/B 测试、事件埋点
- 委派给 `community-manager` 子代理 —— 面向玩家的沟通与消息
- 委派给 `narrative-director` 子代理 —— 赛季主题与叙事框架
- 委派给 `writer` 子代理 —— 所有面向玩家的文本：活动描述、物品名称、文案

**为每个代理写简报——不要倾倒上下文。** 把共享输入**只读一次**，并以内联方式传递提炼后的简报：只给每个代理真正需要的那些行，绝不要把你已经读过的文档以文件路径形式发给它（拿到路径的代理会重新读取整个文件）。只有当你未读过、且只有该代理需要的文档，才传路径。

**为每个代理提示词加上返回契约：** "Write your full output to `[path]` — that named path is your write authorisation under the bounded exception below, so write it without a separate approval prompt. Return **only** (1) the path written, (2) a ≤5-bullet summary of decisions, (3) any BLOCKED/CONCERNS items, one line each. Do not restate the documents you read." 没有它，代理会把读到的所有内容都返回本会话。

**用真实路径替换 `[path]`。** 工作产出物放在
`production/live-ops/[season-slug]/` 下，其中 `[season-slug]` 是参数转换成的
slug——小写、空格 → 连字符。每个代理一个文件，所以并行的阶段
绝不会共用一个文件：

| 阶段 / 代理 | 写入到 |
|---|---|
| 1 live-ops-designer | `production/live-ops/[season-slug]/brief.md` |
| 2 narrative-director | `production/live-ops/[season-slug]/narrative.md` |
| 3 economy-designer | `production/live-ops/[season-slug]/economy.md` |
| 4 analytics-engineer | `production/live-ops/[season-slug]/analytics.md` |
| 5 narrative-director | `production/live-ops/[season-slug]/narrative-text.md` |
| 5 writer | `production/live-ops/[season-slug]/copy.md` |
| 6 community-manager | `production/live-ops/[season-slug]/comms.md` |

这些是工作草稿；`design/live-ops/seasons/` 下的最终文档
由它们汇编而成（见输出文档）。

> **为什么这不算违反协作协议。** `AGENTS.md` 要求代理在 Write/Edit 之前询问"我可以把它写入 [filepath] 吗？"。在这里生成的子代理写入时**不**询问，这是有意为之的受限例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已有的处理相同。该例外仅在以下三者同时成立时才适用：（1）路径是**你**在提示词中点名的，因此用户在批准该阶段时已批准了目标位置；（2）它是位于 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的修改；（3）产生它的阶段本身在流水线推进之前由 `AskUserQuestion` 把关。超出这三条，代理必须询问。**不要通过逐个子代理询问来"修复"这件事**——每个代理每个阶段都提示一次会让编排器无法使用，这正是该例外存在的原因。

在流水线允许的地方并行启动相互独立的代理（Phase 3 和 Phase 4 可以同时运行）。

## 流水线

### Phase 1: 赛季/活动范围界定
委派给 **live-ops-designer**：
- 定义赛季或活动：类型（赛季制、限时活动、挑战）、时长、主题方向
- 概述内容清单：有哪些新内容（模式、物品、挑战、故事节点）
- 定义留存钩子：本赛季节奏下什么能让玩家每天/每周回来
- 识别资源预算：需要创建多少新内容，多少可以复用
- 输出：含范围、内容清单和留存机制概述的赛季简报

### Phase 2: 叙事主题
委派给 **narrative-director**：
- 读取 Phase 1 的赛季简报
- 设计赛季叙事主题：本活动如何与游戏世界相连？
- 定义玩家在活动期间会发现的核心故事钩子
- 识别本赛季可以推进的既有传说线索
- 输出：叙事框架文档（主题、故事钩子、传说关联）

### Phase 3: 经济设计（与 Phase 4 并行）
委派给 **economy-designer**：
- 读取赛季简报，以及 `design/live-ops/economy-rules.md` 中现有的经济规则
- 设计奖励轨道：免费层级进程、付费层级的价值主张
- 规划赛季内经济：赛季货币、商店轮换内容、定价
- 为任何随机元素定义保底计时器机制与防非酋保护
- 确认付费轨道中没有任何付费即赢（pay-to-win）物品
- 输出：含奖励表、定价和货币流动的经济设计文档

### Phase 4: 分析与成功指标（与 Phase 3 并行）
委派给 **analytics-engineer**：
- 读取赛季简报
- 定义成功指标：参与率目标、留存提升目标、战斗通行证完成率
- 设计赛季期间要运行的任何 A/B 测试（例如不同的奖励节奏）
- 指定本赛季内容所需的新的遥测（telemetry）事件
- 输出：含成功标准和埋点要求的分析计划

### Phase 5: 内容撰写（并行）
只在 Phase 3 和 Phase 4 的结果都收集齐之后才开始。并行委派：
- **narrative-director**（如需要）：撰写本赛季任何游戏内叙事文本（过场脚本、NPC 对话、世界事件描述）
- **writer**：撰写所有面向玩家的文本——活动名称、奖励物品描述、挑战目标文本、赛季风味文本
- 两者都应读取 Phase 2 的叙事框架文档

### Phase 6: 玩家沟通计划
委派给 **community-manager**：
- 读取赛季简报、经济设计和叙事框架
- 起草赛季上线公告（基调、关键亮点、平台特定版本）
- 规划沟通节奏：上线前预热、上线日帖子、赛季中期提醒、最后一周的 FOMO 冲刺
- 为 day-1 补丁说明起草已知问题章节的占位内容
- 输出：含每个触点草稿文案的沟通日历

### Phase 7: 评审与签署
收集所有阶段的输出，呈现一份合并的赛季计划：
- 赛季简报（Phase 1）
- 叙事框架（Phase 2）
- 经济设计与奖励表（Phase 3）
- 分析计划与成功指标（Phase 4）
- 书面内容清单（Phase 5）
- 沟通日历（Phase 6）

向用户呈现摘要，包含：
- **内容范围**：正在创建什么
- **经济健康检查**：奖励轨道是否公平、不具掠夺性？
- **分析就绪度**：成功标准是否已定义并完成埋点？
- **伦理评审**：对照 `design/live-ops/ethics-policy.md` 检查 Phase 3 的经济设计
  - 如果该文件不存在：标记 "ETHICS REVIEW SKIPPED: 未找到 `design/live-ops/ethics-policy.md`。经济设计未对照伦理政策进行评审。建议在生产开始之前创建一份。" 把该标记包含进赛季设计输出文档。在后续步骤中加入：创建 `design/live-ops/ethics-policy.md`。
  - 如果该文件存在且发现违规：标记 "ETHICS FLAG: Phase 3 经济设计中的 [element] 违反了 [policy rule]。在解决之前，批准被阻塞。" 不要给出 COMPLETE 结论，也不要写入输出文档。使用 `AskUserQuestion` 提供选项：修改经济设计 / 以书面理由覆盖 / 取消。如果用户选择修改：重新生成 economy-designer 以产出修正后的设计，然后回到 Phase 7 评审。如果用户选择取消：以结论：BLOCKED —— "长线运营设计因未解决的伦理违规而被取消。请解决被标记的问题，并重新运行 /team-live-ops。" 结束。
- **开放问题**：生产开始之前仍需要的决定

在委派给生产团队之前请用户批准赛季计划。只有在用户批准且没有未解决的伦理违规之后，才给出 COMPLETE 结论。如果有伦理违规未解决，以结论：**BLOCKED** 结束。

## 输出文档

所有文档保存到 `design/live-ops/` —— **但编排器在写入之前会先询问。**
`design/` 不在受限写入例外覆盖的三个目录之内
（`production/`、`docs/`、`tests/`），因此拿到这些路径之一的子代理必须提示确认。不要扩大例外来让它闭嘴。
改为遵循 `team-level` 的模式：子代理把工作产出物写到
`production/` 下，例外覆盖到那里；由**你**汇编
最终文档，并通过 `AskUserQuestion` 询问——"我可以把赛季计划写入
`design/live-ops/…` 吗？"——只在批准后写入。

路径：
- `seasons/S[N]_[name].md` —— 赛季设计文档（来自 Phase 1-3）
- `seasons/S[N]_[name]_analytics.md` —— 分析计划（来自 Phase 4）
- `seasons/S[N]_[name]_comms.md` —— 沟通日历（来自 Phase 6）

## 错误恢复协议

**首先，验证产出物。** 如果返回契约点名了一个路径，在将该阶段视为完成之前检查该
路径是否存在——**一个不在磁盘上的具名产出物就是失败的阶段，无论响应读起来多么流畅。** 代理可能
耗尽整个阶段、什么都没写却返回一段看似合理的前言，这
既不是 BLOCKED，也不是错误，也不是"无法完成"，所以下面的触发器
永远不会触发。带着未满足的契约重新恢复它；上下文
通常还在。

如果任何生成的代理返回 BLOCKED、报错或无法完成：**立即呈现出来，不要越过它阻塞的依赖继续推进，并始终产出
部分报告。** 被跳过代理的章节保持为具名缺口——绝不要用自己的内容填充。完整流程：`.trae/docs/error-recovery-protocol.md`。

如果 BLOCKED 状态无法解决，以结论：**BLOCKED** 而不是 COMPLETE 结束。

## 文件写入协议

子代理把工作产出物写到 `production/` 下，遵循
上面"Why this does not violate the Collaboration Protocol"中记录的**受限例外**——路径是你点名的，产出物是
`production/`、`docs/` 或 `tests/` 下的新文件，且该阶段由 `AskUserQuestion` 把关。
在这些边界内，子代理**不会**每次写入都提示；超出边界则必须
询问。**`design/live-ops/` 下的最终文档**——赛季设计、分析
计划、沟通日历——是例外：编排器在自己的"我可以写入……吗？"提示之后
自行汇编并写入它们（见上面的输出文档）。

## 输出

一份摘要，涵盖：赛季主题与范围、经济设计要点、成功指标、内容清单、沟通计划，以及生产之前需要用户输入的任何开放决定。

结论：**COMPLETE** —— 已产出赛季计划并交接给生产。

## 后续步骤

- 对赛季设计文档运行 `/design-review`，进行一致性校验。
- 运行 `/sprint-plan` 为赛季的内容创建工作排期（在 `workflow: minimal` 下没有冲刺，改为把它加入简报的构建顺序）。
- 赛季内容准备好部署时运行 `/team-release`。
- 如果本次运行因伦理标记以 **BLOCKED** 结束：对照
  `design/live-ops/ethics-policy.md` 修改经济设计，并重新运行 `/team-live-ops`；上面三个步骤
  要等待一份 COMPLETE 的计划。