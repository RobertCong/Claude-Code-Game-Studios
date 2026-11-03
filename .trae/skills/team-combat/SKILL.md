---
name: team-combat
description: "编排战斗团队 — game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、qa-tester — 从设计到实现与验证。"
argument-hint: "[combat feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate, Bash(bash "*/.claude/skills/team-combat/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---
# 战斗团队

**参数检查：** 如果未提供战斗功能描述，输出：
> “用法：`/team-combat [combat feature description] [--review full|lean|solo]` — 请提供要设计和实现的战斗功能描述（例如 `melee parry system`、`ranged weapon spread`）。”
然后立即停止，不派出任何子代理，也不读取任何文件。

当本技能以有效参数被调用时，通过结构化流水线编排战斗团队。

**决策点：** 在每个阶段转换处，使用 `AskUserQuestion` 将
子代理的提案作为可选选项呈现给用户。在对话中写下 agent 的
完整分析，然后用简洁的标签捕获决策。
在 `collaborative` 模式下，用户必须批准后才能进入下一阶段。
在 `guided` 模式下，流水线自动推进，除非某阶段为 BLOCKED；
在 `autonomous` 模式下，流水线端到端运行，并通过
`log_decision` 记录每个阶段的结果。`automation_always_ask` 类别中的决策
（`is_always_ask_category` 辅助函数）无论模式如何都会始终提示。参见
`.claude/docs/automation-modes.md`。

## Phase 0: 解析配置

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size,workflow`

已在上面解析——按原样使用；`--review` 覆盖 `review_mode`。无输出块时 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

`review_mode` 设定总监闸门深度，而本流水线没有总监闸门：
在任何 `review_mode` 下，下面的阶段都不会派出 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义在下面的 `team.size` 下），
在这些决策点上工作的 agent 是团队成员，而不是总监闸门。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，
参见上面的决策点说明和 `.claude/docs/automation-modes.md`。

`workflow` 像 `/design-system` 那样设定 Phase 1 设计文档的规模：
`full` 时为 `## Summary` 加上全部 8 个章节；`standard` 时为 Overview、Detailed
Design、Edge Cases、Dependencies 和 Acceptance Criteria，以及当机制定义了数值规则时的
Formulas（战斗机制几乎总是如此）；`minimal` 时游戏简报就是设计记录，
GDD 是可选的——起草那五个章节，并告知用户在此工作流级别它是可选的。

**`team.size`**：哪些 agent 处于活动状态（与 review_mode 闸门深度和 workflow 文档正交）。
- **`individual`**（默认）：由 `gameplay-programmer` 运行流水线；仅当功能涉及 AI 工作时才升级 `ai-programmer`。其他团队组成 agent 通过 gameplay-programmer 咨询，不单独派出。
- **`small`**：如下文所述的完整团队组成流水线。
- **`studio`**：完整流水线 + 引擎子专家 + 对抗性评审环节。*引擎子专家*：主引擎专家的提示说明，它可以把部分评审交给其 `tools:` 授权中命名的子专家（例如 `ue-gas-specialist` 负责能力）；在 `studio` 以下，它独自作答。*对抗性评审环节*：Phase 5 的 qa-tester 被告知“你的工作不是确认它能用——而是找出它是如何坏掉的”，并且报告中说明该环节已运行。
在 `individual` 下需要非核心 agent 时，通过最近的活动核心 agent 路由，并附加信息性说明。**“阶段闸门”指任何以本流水线自身列出的 `AskUserQuestion` 决策点结束的阶段**——上述决策点中的转换，或下面流水线中写入的 **Gate** 步骤——**无论 `automation` 模式如何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否是闸门，因此下面的有界例外条件（3）在任何模式下都对其成立。仅限“阶段闸门”的 agent 只在这些点被派出，不在其他点派出。此活动集作用域适用于下面整个流水线：任何点名活动集之外 agent 的阶段，都通过最近的核心 agent 路由，而不是派出该 agent。

**在 Phase 1 之前宣布活动集——绝不要让收缩悄无声息。**
在派出任何东西之前，用一行说明本次运行实际会派出哪些 agent，
以及下面流水线点名但在解析后的 `team.size` 下**不会**派出的 agent。例如：

> `Active set (team.size: <resolved>): <the agents listed for that size above>.`
> `Not spawned this run: <every other agent this pipeline names> — consulted`
> `through <nearest active core agent>. Raise team.size (or modes.rigor) to widen.`

根据正上方的 `team.size` 列表和本文件自身流水线点名的 agent 来填充它——
不要照抄示例。两个集合因编排器而异。

下面的流水线读起来像是多 agent 扇出，而在交付的默认值下
它是一到两个 agent——`team-release` 点名十个却只运行一个，`team-narrative`
跨五个阶段点名六个却只运行 `writer`。**这种收缩是正确的**：
`team.size` 由 rigor 前置，且窄默认值是 token 杠杆。
如果不说明这一点，读者就无法
区分正确收缩的运行和损坏的流水线，而且上面每条 agent 的
“通过最近核心 agent 路由并附加信息性说明”规则会在路由时触发，
却从不说明整个运行的形态。

这与本文件其他地方的跳过检查报告规则相同：**一个被强制执行却从不显现的约束，
对阅读输出的人而言，与一个从未被强制执行的约束无法区分。**

## 团队组成
- **game-designer** — 设计机制，定义公式和边界情况
- **gameplay-programmer** — 实现核心玩法代码
- **ai-programmer** — 实现该功能的 NPC/敌人 AI 行为
- **technical-artist** — 创建 VFX、着色器效果和视觉反馈
- **sound-designer** — 定义音频事件、打击音效和环境战斗音频
- **engine specialist**（主）— 验证架构和实现模式符合该引擎的惯用做法（主专家是来自 `engine.name` 的 `<engine>-specialist`——Godot→`godot-specialist`，Unity→`unity-specialist`，Unreal→`unreal-specialist`；回退到 `technical-preferences.md` 中 `## Engine Specialists` 的 Primary 行）
- **qa-tester** — 编写测试用例并验证实现

## 如何委派

使用 `Agent` 工具将每个团队成员作为子代理派出：
- `subagent_type: game-designer` — 设计机制，定义公式和边界情况
- `subagent_type: gameplay-programmer` — 实现核心玩法代码
- `subagent_type: ai-programmer` — 实现 NPC/敌人 AI 行为
- `subagent_type: technical-artist` — 创建 VFX、着色器效果、视觉反馈
- `subagent_type: sound-designer` — 定义音频事件、打击音效、环境音频
- `subagent_type: [primary engine specialist]` — 针对架构和实现的引擎惯用做法验证
- `subagent_type: qa-tester` — 编写测试用例并验证实现

**给每个 agent 写简报——不要倾倒上下文。** 只读取一次共享输入，并以内联方式传递提炼后的简报：每个 agent 实际需要的那几行，绝不要为你已经读过的文档传文件路径（拿到路径的 agent 会重新读取整个文件）。只为你尚未读过且只有该 agent 需要的文档传递路径。

**每个 agent 提示都以返回契约结尾：**“Write your full output to `[path]` ——该指定路径即为你在下文有界例外下的写入授权，因此无需单独的审批提示即可写入。只返回（1）写入的路径，（2）不超过 5 条要点的决策摘要，（3）任何 BLOCKED/CONCERNS 项，每项一行。不要复述你读过的文档。”没有它，agent 会把它读过的一切都返回本会话中。**实现文件是例外：** 编写代码或资源的 agent 先返回它将创建或更改的文件，其返回契约只有在你就整个集合询问过一次且用户同意后才点名这些文件（文件写入协议）——是该答复，而不是有界例外，授权这些写入。

**用真实路径替换 `[path]`。** 每个产出产出物的阶段都会
点名一个路径；大多数路径由已经读取它们的技能固定：

| 阶段 / agent | 写入到 | 目标由谁固定 |
|---|---|---|
| 1 game-designer（草稿） | `production/combat/[feature]-gdd-draft.md` | 本技能——你写入最终的 `design/gdd/[feature].md`（Phase 1） |
| 2 gameplay-programmer | `docs/architecture/[feature]-sketch.md` | 见下文说明 |
| 2 engine specialist | `docs/architecture/[feature]-engine-notes.md` | 见下文说明 |
| 3 gameplay-programmer、ai-programmer、technical-artist | 代码根目录和 `assets/`——Phase 3 审批列出的文件 | 在有界例外之外：就整个集合询问一次（文件写入协议） |
| 3 sound-designer | `production/combat/[feature]-audio-events.md` | 本技能 |
| 5 qa-tester（测试用例） | `production/qa/test-cases/[feature]-cases.md` | `/team-qa` Phase 4 |
| 5 qa-tester（缺陷） | `production/qa/bugs/BUG-[NNNN].md` | `/team-qa` Phase 5 |

Phase 6 是口头状态报告，不是产出物——没有路径，也不需要路径。

> **上面每个阶段都刻意点名了一个具体目标。** 下文的错误恢复协议说
> “一个已命名但不在磁盘上的产出物就是失败的阶段”——当没有命名路径时，
> 该检查无法运行。
>
> **两个 `docs/architecture/` 条目是判断取舍，而不是惯例。**
> 该目录存放 ADR（`adr-NNNN-*.md`）；草图是 ADR 的前身，而不是
> ADR 本身，而且**仓库中没有任何东西读取这两个文件**。在报告时说明这一点，
> 以便草图被理解为记录，而不是后续闸门的输入。

> **为什么这不违反协作协议。** `CLAUDE.md` 要求 agent 在 Write/Edit 之前询问“May I write this to [filepath]?”。此处派出的子代理**不询问**即可写入，这是刻意的有界例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已做出的相同决定。该例外仅在以下三项全部成立时适用：（1）路径是**你**在提示中命名的，因此用户在批准该阶段时已批准目标；（2）它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；（3）产生它的阶段本身在流水线推进前由 `AskUserQuestion` 把关。超出这三项，agent 必须询问。**不要通过按子代理逐个询问来“修复”这一点**——每个阶段每个 agent 一个提示会让编排器无法使用，这正是该例外存在的原因。

在流水线允许的情况下并行启动独立 agent（例如 Phase 3 的 agent 可以同时运行）。

## 流水线

### Phase 1: 设计
委派给 **game-designer**：
- 根据 `.claude/docs/templates/game-design-document.md` 创建或更新 `design/gdd/[feature].md` 的设计文档，包含 `## Summary` 和 `workflow` 要求的章节（Phase 0）——在 `full` 下：机制概述、玩家幻想、详细规则、带变量定义的公式、边界情况、依赖、带安全范围的调参旋钮，以及验收标准
- 输出：完成的设计文档，草稿写入 `production/combat/[feature]-gdd-draft.md`

`design/` 在上述有界写入例外之外，因此由 game-designer
起草，而由**你**写入 GDD——这是 `/team-level` 和
`/team-narrative` 使用的模式。在 Phase 1 决策点，呈现草稿并通过
`AskUserQuestion` 询问：“我可以把设计文档写入
`design/gdd/[feature].md` 吗？”获批后写入；在该答复之前，`design/` 下不会写入任何内容。

### Phase 2: 架构
委派给 **gameplay-programmer**（如果涉及 AI，则加上 **ai-programmer**）：
- 审查设计文档，按章节阅读：用 Grep 工具（pattern `^#`，content 模式）找到所需标题，再用 offset 和 limit 读取相应范围
- 设计代码架构：类结构、接口、数据流
- 识别与现有系统的集成点
- 输出：包含文件列表和接口定义的架构草图

然后派出**主引擎专家**以验证所提议的架构：
- 类/节点/组件结构是否符合所固定引擎的惯用做法？（例如 Godot 节点层级、Unity 的 MonoBehaviour 与 DOTS、Unreal 的 Actor/Component 设计）
- 是否有应使用引擎原生系统而非自定义实现的地方？
- 是否有提议的 API 在所固定的引擎版本中已弃用或发生变更？
- 输出：引擎架构说明——在 Phase 3 开始前并入架构

如果未配置引擎，跳过专家派出。**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 一个什么都不说的跳过检查，与一个通过的检查无法区分。

使用 `AskUserQuestion`：
- 提示：“架构草图已完成。批准以继续进行并行实现。”
- 选项：
  - `[A] Proceed — spawn implementation agents (gameplay-programmer, ai-programmer, technical-artist, sound-designer)`
  - `[B] Revise the architecture first — I'll describe what needs to change`
  - `[C] Stop here — I'll continue later`

仅当用户选择 [A] 时才派出实现 agent。（在 `guided`/`autonomous`
模式下，此架构闸门是正常的阶段转换——除非架构草图返回 BLOCKED，
否则继续到实现；在 autonomous 模式下通过 `log_decision` 记录该
决策。该闸门不是发布关键或不可逆的决策，因此遵循标准流水线规则。）

### Phase 3: 实现（尽可能并行）
并行委派：
- **gameplay-programmer**：实现核心战斗机制代码
- **ai-programmer**：实现 AI 行为（如果功能涉及 NPC 反应）
- **technical-artist**：创建 VFX 和着色器效果
- **sound-designer**：定义音频事件列表和混音说明，草稿写入 `production/combat/[feature]-audio-events.md`

代码、VFX 和着色器工作在有界写入例外之外：这些 agent 各自
先返回它将创建或更改的文件，你就整个集合询问一次，
然后它们才在同意后写入（文件写入协议）。

### Phase 4: 集成
- 将玩法代码、AI、VFX 和音频连接起来
- 确保所有调参旋钮都暴露并数据驱动
- 验证功能与现有战斗系统协同工作

**Gate**：使用 `AskUserQuestion` 呈现集成结果，并在进入 Phase 5 前确认。

### Phase 5: 验证
委派给 **qa-tester**：
- 根据验收标准编写测试用例
- 测试设计中记录的所有边界情况
- 验证性能影响在预算之内
- 为发现的任何问题提交缺陷报告

### Phase 6: 签字确认
- 收集所有团队成员的结果
- 报告功能状态：COMPLETE / NEEDS WORK / BLOCKED
- 列出任何未解决的问题及其指定负责人

## 错误恢复协议

**首先，验证产出物。** 如果返回契约点名了路径，在将该阶段视为完成之前检查该路径是否存在——**一个已命名但不在磁盘上的产出物就是失败的阶段，无论回复读起来多么流畅。** 一个 agent 可能烧掉整个阶段，返回一段看似合理的前言却什么都没写，这既不是 BLOCKED，也不是错误，也不是“无法完成”，因此下面的触发器永远不会触发。以未满足的契约名义恢复它；上下文通常还在。

如果任何派出的 agent 返回 BLOCKED、错误或无法完成：**立即暴露它，不要越过它阻塞的依赖继续推进，并且始终产生部分报告。** 被跳过 agent 的章节保持为已命名的缺口——绝不要用你自己的内容填充它。完整流程见：`.claude/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（未找到用户故事、缺少 GDD）→ 重定向到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围太大 → 通过 `/create-stories` 拆分为两个用户故事
- ADR 与用户故事之间存在冲突指令 → 暴露冲突，不要猜测

## 文件写入协议

所有文件写入（设计草稿、实现文件、测试用例）都委派给通过 `Agent` 派出的子代理，遵循两条规则：

- **草稿、草图和 QA 产出物**——路径表中 `production/`、`docs/` 或 `tests/` 下的目标——遵循上文“为什么这不违反协作协议”中记录的**有界例外**：路径是你命名的，产出物是新的，且该阶段由 `AskUserQuestion` 把关。子代理写入它们时无需逐次写入提示。
- **实现文件**——Phase 3 的代码、VFX 和着色器文件，以及任何 Phase 4 集成编辑，位于代码根目录和 `assets/` 下——在该例外之外，正如各 agent 自己的文件所述。每个实现 agent 先返回它将创建或更改的文件，并各附一行摘要；就整个集合询问一次（“May I have [agents] write these [N] files?”），并让它们仅在同意后写入。对现有文件的编辑始终在该列表中，绝不会由 Phase 3 之前的闸门隐含。

**唯一的例外是设计文档**：编排器在它自己的“May I write …?”提示（Phase 1）之后，根据 game-designer 的草稿自行写入 `design/gdd/[feature].md`。它不写入任何其他文件。

## 输出

一份摘要报告，涵盖：设计完成状态、每个团队成员的实现状态、测试结果以及任何未解决问题。

结论（Verdict）：**COMPLETE** — 战斗功能已设计、实现并验证。

如果引擎验证被跳过（Phase 2，未配置引擎），结论
要说明这一点——绝不要只写 COMPLETE：

结论（Verdict）：**COMPLETE — engine validation NOT ASSESSED ([reason])** — 战斗功能已设计、实现并验证；引擎专家从未审查架构。

结论（Verdict）：**NEEDS WORK** — 每个阶段都运行了，但 Phase 5 验证留下了未解决的失败或未修复缺陷；报告会列出每项及其负责人。

结论（Verdict）：**BLOCKED** — 一个或多个阶段无法完成，或有 agent 被跳过（`.claude/docs/error-recovery-protocol.md` 第 5 步）；已产生部分报告并列出未解决项。

## 后续步骤

- 在关闭用户故事之前，对已实现的战斗代码运行 `/code-review`。
- 运行 `/balance-check` 以验证战斗公式和调参数值。
- 如果需要 VFX、音频或性能打磨，运行 `/team-polish`。
