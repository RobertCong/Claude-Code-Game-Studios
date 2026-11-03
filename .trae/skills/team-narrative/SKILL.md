---
name: team-narrative
description: "编排叙事团队——narrative-director、writer、world-builder、level-designer——负责故事、世界传说、叙事驱动的关卡。"
argument-hint: "[narrative content description] [--review full|lean|solo]"
user-invocable: true
---
# 叙事团队（Team Narrative）

如果未提供参数，输出用法说明并退出，不生成任何代理：
> 用法：`/team-narrative [narrative content description] [--review full|lean|solo]` —— 描述要处理的故事内容、场景或叙事区域（例如 `boss encounter cutscene`、`faction intro dialogue`、`tutorial narrative`）。此处不要使用 `AskUserQuestion`；直接输出说明。

当本技能带参数被调用时，通过结构化流水线编排叙事团队。

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

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size`

以上命令的输出已解析——直接使用；`--review` 覆盖 `review_mode`。无配置块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

`review_mode` 设定总监闸门（director gate）的深度，而本流水线没有总监闸门：
无论 `review_mode` 为何，下面的任何阶段都不会生成 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义在下面的 `team.size` 之下），
而在这些点上工作的代理是团队成员，不是总监闸门。

Phase 4 的 ND-CONSISTENCY 在每种模式下都是例外：它是本流水线自身的
评审，而不是可选的总监闸门，因此 `review_mode` 永远不会跳过它（`team.size`
仍然决定由谁来执行——见 Phase 4）。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，参见上面的决策点说明和
`.trae/docs/automation-modes.md`。

**`team.size`**：哪些代理处于活动状态（与 review_mode 的闸门深度和工作流文档相互正交）。
- **`individual`**（默认）：仅 `writer`；`narrative-director` 仅在明确出现游戏支柱冲突时被调用。其他代理通过 writer 咨询，不单独生成。
- **`small`**：`narrative-director` + `writer`，当 `review_mode` 为 `full` 时再加 `localization-lead` 与 `world-builder`（在 `lean` 和 `solo` 下它们通过 writer 咨询）。
- **`studio`**：全部六个团队组成代理，无论 `review_mode` 为何（即文档中的完整流水线）。
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
- **narrative-director** —— 故事弧线、角色设计、对话策略、叙事愿景
- **writer** —— 对话撰写、传说条目、物品描述、游戏内文本
- **world-builder** —— 世界规则、阵营设计、历史、地理、环境叙事
- **art-director** —— 角色视觉设计、环境视觉叙事、过场动画/影片基调
- **level-designer** —— 服务于叙事的关卡布局、节奏、环境叙事节点
- **localization-lead** —— 本地化就绪度——标记不可本地化的字符串、文化假设和 i18n 缺口

## 如何委派

使用 `Agent` 工具把每位团队成员生成为子代理：
- 委派给 `narrative-director` 子代理 —— 故事弧线、角色设计、叙事愿景
- 委派给 `writer` 子代理 —— 对话撰写、传说条目、游戏内文本
- 委派给 `world-builder` 子代理 —— 世界规则、阵营设计、历史、地理
- 委派给 `art-director` 子代理 —— 角色视觉设定、环境视觉叙事、影片基调
- 委派给 `level-designer` 子代理 —— 服务于叙事的关卡布局、节奏
- 委派给 `localization-lead` 子代理 —— 本地化就绪度——标记不可本地化的字符串、文化假设和 i18n 缺口

**先读正典（canon）。** 在 Phase 1 之前，读取存在的共享输入——叙事圣经或基调指南、
`design/narrative/` 下的角色与阵营文件，以及世界规则。绝不要让代理凭空发明正典：
如果不存在正典，就说明这一点，并在任何起草之前询问用户。

**为每个代理写简报——不要倾倒上下文。** 把共享输入**只读一次**，并以内联方式传递提炼后的简报：只给每个代理真正需要的那些行，绝不要把你已经读过的文档以文件路径形式发给它（拿到路径的代理会重新读取整个文件）。只有当你未读过、且只有该代理需要的文档，才传路径。

**为每个代理提示词加上返回契约：** "Write your full output to `[path]` — that named path is your write authorisation under the bounded exception below, so write it without a separate approval prompt. Return **only** (1) the path written, (2) a ≤5-bullet summary of decisions, (3) any BLOCKED/CONCERNS items, one line each. Do not restate the documents you read." 没有它，代理会把读到的所有内容都返回本会话。

**用真实路径替换 `[path]`。** 代理把草稿写到
`production/narrative/[content-slug]/` 下——在下面的受限例外之内。成品文档
属于 `design/narrative/`，例外**不**覆盖那里，
所以由**你**在一次批准之后写入这些文件（见"写入成品"）：

| 代理 | 草稿写入（`[path]`） | 最终文档（由你写入） |
|---|---|---|
| narrative-director | `production/narrative/[content-slug]/brief.md` | `design/narrative/[content-slug]-brief.md` |
| world-builder | `production/narrative/[content-slug]/lore-[topic].md` | `design/narrative/lore/[topic].md` |
| writer | `production/narrative/[content-slug]/dialogue-[scene-slug].md` | `design/narrative/dialogue/[scene-slug].md` |
| art-director | `production/narrative/[content-slug]/visual-direction.md` | `design/narrative/[content-slug]-visual-direction.md` |
| level-designer | `production/narrative/[content-slug]/level-integration.md` | `design/narrative/[content-slug]-level-integration.md` |
| localization-lead | `production/narrative/[content-slug]/i18n-review.md` | 留在 `production/` —— 这是一份评审，不是设计文档 |

> **最终去向不是可以随意选择的。** `design/narrative/` 会被
> `/asset-spec`、`/design-review`、`/localize`、`/onboard`、
> `/project-stage-detect`、`/team-level` 和 `cd-narrative` 总监闸门读取。
> 写在其他任何地方的产出物对这七者都不可见。
>
> 上面的 `[path]` 契约有一个前提：路径是*你*点名的。一个只声明契约却不点名
> 具体去向的技能，会让每次运行都去自行发明一个，从而使契约失效。`/team-qa` Phase 4 出于同样的原因
> 也有同样的要求。

> **为什么这不算违反协作协议。** `AGENTS.md` 要求代理在 Write/Edit 之前询问"我可以把它写入 [filepath] 吗？"。在这里生成的子代理写入时**不**询问，这是有意为之的受限例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已有的处理相同。该例外仅在以下三者同时成立时才适用：（1）路径是**你**在提示词中点名的，因此用户在批准该阶段时已批准了目标位置；（2）它是位于 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的修改；（3）产生它的阶段本身在流水线推进之前由 `AskUserQuestion` 把关。超出这三条，代理必须询问。**不要通过逐个子代理询问来"修复"这件事**——每个代理每个阶段都提示一次会让编排器无法使用，这正是该例外存在的原因。

在流水线允许的地方并行启动相互独立的代理（例如 Phase 2 的代理可以同时运行）。

## 流水线

### Phase 1: 叙事方向
委派给 **narrative-director**：
- 定义本内容的叙事目的：它服务于哪个故事节点？
- 识别涉及的角色、他们的动机，以及这如何契合整体弧线
- 设定情感基调与节奏目标
- 指明任何传说依赖，或本内容引入的新传说
- 输出：带故事需求的叙事简报

### Phase 2: 世界基础（并行）
并行委派——在等待任何结果之前同时发出全部三个 `Agent` 调用：
- **world-builder**：为本内容相关的阵营、地点和历史创建或更新传说条目。对照现有传说交叉检查矛盾。为新条目设定正典级别。
- **writer**：使用声音档案起草角色对话。确保所有台词不超过 120 个字符、变量使用具名占位符，并且可本地化。
- **art-director**：为本内容中出现的核心角色定义角色视觉设计方向（剪影、视觉原型、辨识特征）。为每个关键空间指定环境视觉叙事元素（道具构图、灯光说明、空间布置）。为任何过场动画或脚本化序列定义基调色板与影片化方向。

**阶段闸门：** 收集全部三个 Phase 2 输出，然后在开始 Phase 3 之前应用决策点
规则——呈现传说、对话和视觉方向的摘要，并在 `collaborative` 模式下通过 `AskUserQuestion` 获取批准
（在 `guided` 下自动推进，除非某结果为 BLOCKED；在
`autonomous` 下使用 `log_decision`）。

### Phase 3: 关卡叙事整合
委派给 **level-designer**：
- 评审叙事简报与传说基础
- 在关卡中设计环境叙事元素
- 放置叙事触发器、对话区域和发现点
- 确保节奏同时服务于玩法与故事

### Phase 4: 评审与一致性
使用闸门 **ND-CONSISTENCY** 通过 `Agent` 生成 `narrative-director`
（`.trae/docs/director-gates/nd-consistency.md`）。本阶段在每种评审
模式下都会运行——它是本流水线自身的评审，而不是可选的总监闸门。传入该闸门列出的
上下文（Phase 2–3 草稿路径、叙事圣经或基调
指南、世界规则、受影响的角色与阵营档案）——此处已点名，
所以不要在本会话中读取该闸门文件——并补充：
- 确认叙事节奏与关卡设计一致
- 检查所有谜团都有写入文档的"真实答案"

按结论行动：**APPROVE** → Phase 5。**CONCERNS** → 展示所列出的
不一致之处，并通过 `AskUserQuestion` 询问是修改它们（重新生成各自负责的
代理）还是接受。**REJECT** → 不要开始 Phase 5；先修复矛盾。
**NOT ASSESSED [missing input]** → 指出缺失的输入，补齐后重新运行该闸门，
或把 `ND-CONSISTENCY: NOT ASSESSED — [input]` 带入报告的
一致性评审结果；它绝不能被读作 APPROVE（`.trae/docs/director-gates.md`）。

**在 `team.size: individual` 下**，narrative-director 不在活动集中，因此不会生成该
闸门。writer 按同样的标准检查草稿，
输出要按名称说明这一点："未运行 ND-CONSISTENCY——在 `team.size: individual` 下 narrative-director 不
活动；一致性由 writer 自检。"自检不是该闸门的结论，
报告不得把它当作结论呈现。

### Phase 5: 打磨（并行）
并行委派——在等待任何结果之前发出每一个 `Agent` 调用：
- **writer**：最终自检——确认没有台词超出对话框限制、所有文本都使用字符串键（而非原始字符串）、占位变量名保持一致
- **localization-lead**：验证 i18n 合规性——检查字符串键命名约定，标记任何带有硬编码格式、无法在翻译中存活的字符串，验证文本长度余量足以容纳会变长的语言（德语/芬兰语通常 +30%），确认文本中没有需要地区特定变体的文化假设
- **world-builder**：为所有新传说条目最终确定正典级别

### 写入成品
你持有每一份草稿。从上面的表格列出最终文档，然后通过 `AskUserQuestion`
一次性询问——"我可以把这 [N] 份叙事文档写入
`design/narrative/` 吗？"——并在批准后写入。`production/narrative/[content-slug]/` 下的草稿
保留为工作记录。

## 错误恢复协议

**首先，验证产出物。** 如果返回契约点名了一个路径，在将该阶段视为完成之前检查该
路径是否存在——**一个不在磁盘上的具名产出物就是失败的阶段，无论响应读起来多么流畅。** 代理可能
耗尽整个阶段、什么都没写却返回一段看似合理的前言，这
既不是 BLOCKED，也不是错误，也不是"无法完成"，所以下面的触发器
永远不会触发。带着未满足的契约重新恢复它；上下文
通常还在。

如果任何生成的代理返回 BLOCKED、报错或无法完成：**立即呈现出来，不要越过它阻塞的依赖继续推进，并始终产出
部分报告。** 被跳过代理的章节保持为具名缺口——绝不要用自己的内容填充。完整流程：`.trae/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（找不到用户故事、缺少 GDD）→ 引导到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围过大 → 通过 `/create-stories` 拆成两个用户故事
- ADR 与用户故事之间的指示冲突 → 呈现冲突，不要猜测

## 文件写入协议

子代理把它们各自的草稿写到你点名的 `production/narrative/[content-slug]/` 路径下，
适用上面"Why this does not violate the Collaboration Protocol"中记录的**受限例外**——路径是你点名的，产出物
是 `production/`、`docs/` 或 `tests/` 下的新文件，且该阶段由
`AskUserQuestion` 把关。在这些边界内，子代理**不会**每次写入都提示；
超出边界则必须询问。**唯一的例外是 `design/narrative/` 下的最终文档**：
你持有每一份草稿，所以在"写入成品"中那一次"我可以写入……吗？"之后由你自己写入。

## 输出

一份摘要报告，涵盖：叙事简报状态、创建/更新的传说条目、撰写的对话台词数、关卡叙事整合点、一致性评审结果，以及任何未解决的矛盾——包括用户选择不修复的任何本地化问题（按字符串键指明）。

结论：**COMPLETE** —— 已交付叙事内容。

如果 ND-CONSISTENCY 回答 NOT ASSESSED 且该结果被带入报告
（Phase 4），结论要说明这一点——绝不给出朴素的 COMPLETE：

结论：**COMPLETE — consistency NOT ASSESSED ([input])** —— 已交付叙事内容；由于缺少 [input]，一致性评审无法运行。

如果流水线因依赖未解决而停止（例如用户未解决传说矛盾或缺失的前置条件）：

结论：**BLOCKED** —— [reason]

## 后续步骤

- 对叙事文档运行 `/design-review`，进行一致性校验。
- 对话定稿后运行 `/localize extract`，提取新字符串用于翻译。
- 运行 `/dev-story`，在引擎内实现对话触发器与叙事事件。