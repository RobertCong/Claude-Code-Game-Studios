---
name: team-audio
description: "编排音频团队——audio-director、sound-designer、technical-artist、gameplay-programmer——从方向到实现。"
argument-hint: "[feature or area to design audio for] [--review full|lean|solo]"
user-invocable: true
---

# 音频团队（Team Audio）

如果未提供参数，输出用法说明并退出，不生成任何代理（agent）：
> 用法：`/team-audio [feature or area to design audio for] [--review full|lean|solo]` —— 指定要为其设计音频的功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）。此处不要使用 `AskUserQuestion`；直接输出说明。

当本技能带参数被调用时，通过结构化流水线编排音频团队。

**决策点：** 在每个步骤切换处，使用 `AskUserQuestion` 把子代理（subagent）的提案
作为可选项呈现给用户。在对话中写出该代理的完整分析，然后用简洁标签
记录决定。在 `collaborative` 模式下，用户必须先批准才能进入下一步。
在 `guided` 模式下，除非某步骤为 BLOCKED，流水线会自动推进；
在 `autonomous` 模式下，它端到端运行，并通过
`log_decision` 记录每个步骤的结果。`automation_always_ask` 类别中的决策
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

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，参见上面的决策点说明和
`.trae/docs/automation-modes.md`。

**`team.size`**：哪些代理处于活动状态（与 review_mode 的闸门深度和工作流文档相互正交）。
- **`individual`**（默认）：仅 `sound-designer`。其他代理通过 sound-designer 咨询，不单独生成。
- **`small`**：+ `audio-director` + `technical-artist` + `gameplay-programmer`。
- **`studio`**：+ `accessibility-specialist` + 主要引擎专家（即文档中的完整流水线）。
在 `individual` 下需要非核心代理时，通过最近的活动核心代理转达并附上说明性备注。**"阶段闸门"指任何以本流水线自身列出的 `AskUserQuestion` 决策点结尾的阶段**——上面决策点所述的切换，或下面流水线中写明的 **Gate** 步骤——**无论 `automation` 模式为何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否算闸门，因此下面的受限例外条件（3）在每种模式下都成立。被限定为"仅在阶段闸门"的代理只在那些点被生成。此活动集限定贯穿下面的整条流水线：任何点名了活动集之外代理的阶段，都通过最近的核心代理转达，而不是生成该代理。

**在 Step 1 之前宣告活动集——绝不要让收缩悄无声息。**
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

1. **读取参数**以获取目标功能或区域（例如 `combat`、
   `main menu`、`forest biome`、`boss encounter`）。

2. **收集上下文**：
   - 按节读取 `design/gdd/` 中与该功能相关的设计文档：用 Grep 工具（模式 `^#`，content 模式）找到需要的
     标题，再用 offset 和 limit Read
     这些区段
   - 如果存在，读取 `design/audio/sound-bible.md` 中的声音圣经。如果只有
     `design/gdd/sound-bible.md` 存在（较早版本放在那里），读取它
     并建议移动到 `design/audio/`——在 `design/gdd/` 中 GDD 检查
     会把每个文件都算作系统 GDD。如果两者都不存在，
     用一行说明——"`design/audio/sound-bible.md` 处没有声音圣经
     ；音频方向仅从 GDD 起步"——好让该缺口在输出中可见。
     把缺口传递下去：在 audio-director 的 Step 1 简报中说明这一点，并在
     后续步骤中建议创建声音圣经。
   - 读取 `assets/audio/` 中现有的音频资源列表
   - 读取该区域任何已有的音效设计文档

## 如何委派

使用 `Agent` 工具把每位团队成员生成为子代理：
- 委派给 `audio-director` 子代理 —— 声音识别、情感基调、音频调色板
- 委派给 `sound-designer` 子代理 —— SFX 规格、音频事件、混音分组
- 委派给 `accessibility-specialist` 子代理 —— 关键音频的视觉替代与字幕、听觉敏感度
- 委派给 `technical-artist` 子代理 —— 音频中间件、总线结构、内存预算
- 委派给 `[primary engine specialist]` 子代理 —— 校验引擎的音频集成模式
- 委派给 `gameplay-programmer` 子代理 —— 音频管理器、玩法触发器、自适应音乐

**为每个代理写简报——不要倾倒上下文。** 把共享输入**只读一次**，并以内联方式传递提炼后的简报：只给每个代理真正需要的那些行，绝不要把你已经读过的文档以文件路径形式发给它（拿到路径的代理会重新读取整个文件）。只有当你未读过、且只有该代理需要的文档，才传路径。

**为每个代理提示词加上返回契约：** "Write your full output to `[path]` — that named path is your write authorisation under the bounded exception below, so write it without a separate approval prompt. Return **only** (1) the path written, (2) a ≤5-bullet summary of decisions, (3) any BLOCKED/CONCERNS items, one line each. Do not restate the documents you read." 没有它，代理会把读到的所有内容都返回本会话。**实现文件是例外：** 写代码或资源的代理先返回它将创建或修改的文件，而你只在先询问过一次清单、且用户同意之后（文件写入协议），才在它的返回契约中点名这些文件——授权这些写入的是那个答复，而不是受限例外。

**用真实路径替换 `[path]`。** 工作产出物放在
`production/audio/[feature]/` 下，其中 `[feature]` 是参数转换成的 slug——
小写、空格 → 连字符（`boss encounter` → `boss-encounter`），与
"保存到"步骤使用同一个 slug。每个代理一个文件，所以并行步骤绝不会共用一个文件：

| 步骤 / 代理 | 写入到 |
|---|---|
| 1 audio-director | `production/audio/[feature]/direction.md` |
| 2 sound-designer | `production/audio/[feature]/sfx-spec.md` |
| 2 accessibility-specialist | `production/audio/[feature]/accessibility.md` |
| 3 technical-artist | `production/audio/[feature]/integration-plan.md` |
| 3 engine specialist | `production/audio/[feature]/engine-notes.md` |
| 4 gameplay-programmer | 代码根与引擎的测试根——即那次实现请求所列的文件（文件写入协议），在受限例外之外 |

这些是工作草稿；持久记录是你由它们汇编而成的音频设计文档。

> **为什么这不算违反协作协议。** `AGENTS.md` 要求代理在 Write/Edit 之前询问"我可以把它写入 [filepath] 吗？"。在这里生成的子代理写入时**不**询问，这是有意为之的受限例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已有的处理相同。该例外仅在以下三者同时成立时才适用：（1）路径是**你**在提示词中点名的，因此用户在批准该阶段时已批准了目标位置；（2）它是位于 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的修改；（3）产生它的阶段本身在流水线推进之前由 `AskUserQuestion` 把关。超出这三条，代理必须询问。**不要通过逐个子代理询问来"修复"这件事**——每个代理每个阶段都提示一次会让编排器无法使用，这正是该例外存在的原因。

3. **按顺序编排音频团队**：

### Step 1: 音频方向（audio-director）
生成 `audio-director` 代理来：
- 为该功能/区域定义声音识别
- 指定情感基调与音频调色板
- 设定音乐方向（自适应层、分轨（stem）、过渡）
- 定义音频优先级与混音目标
- 建立任何自适应音频规则（战斗强度、探索、紧张感）

### Step 2: 音效设计与音频无障碍（并行）
生成 `sound-designer` 代理来：
- 为每个音频事件创建详细的 SFX 规格
- 定义声音类别（环境、UI、玩法、音乐、对话）
- 指定每种声音的参数（音量范围、音高变化、衰减）
- 规划带触发条件的音频事件列表
- 定义混音分组与闪避（ducking）规则

并行生成 `accessibility-specialist` 代理来：
- 识别哪些音频事件承载关键玩法信息（受到伤害、附近有敌人、目标完成），并需要为听障玩家提供视觉替代
- 指定字幕要求：哪些音频事件需要字幕、文本格式、屏幕停留时长
- 检查没有任何玩法状态仅通过音频传达（全部必须有视觉后备）
- 审查音频事件列表，找出可能给听觉敏感玩家带来问题的条目（高频警报、突然的巨响）
- 输出：整合进音频事件规格的音频无障碍需求清单

没有任何视觉提示或字幕的玩法关键音频事件在报告中标记为
**BLOCKING**，而不是建议性事项。Step 3 在该问题被用户解决、
或用户在 Step 2 决策点明确接受之前不会开始；该决策点提供修复方案（视觉提示、字幕或触感后备）和一个停止选项；被接受的缺口会列在摘要的开放问题中。

### Step 3: 技术实现（并行）
生成 `technical-artist` 代理来：
- 设计音频中间件集成（Wwise/FMOD/原生）
- 定义音频总线结构与路由
- 按平台指定音频资源的内存预算
- 规划流式加载与预加载的资源策略
- 设计任何音频响应式视觉效果

并行生成**主要引擎专家**（由 `engine.name` 推导出 `<engine>-specialist` —— Godot→`godot-specialist`、Unity→`unity-specialist`、Unreal→`unreal-specialist`；回退到 `.trae/docs/technical-preferences.md` 中 `## Engine Specialists` 的 Primary 行）来校验集成方案：
- 提议的音频中间件集成对该引擎是否地道？（例如 Godot 内置的 AudioStreamPlayer 对比 FMOD、Unity 的 Audio Mixer 对比 Wwise、Unreal 的 MetaSounds 对比 FMOD）
- 是否有应当使用的引擎特定音频节点/组件模式？
- 固定引擎版本中是否有已知的音频系统变更会影响集成计划？
- 输出：引擎音频集成说明，用于与 technical-artist 的计划合并

如果未配置引擎，跳过专家生成。**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 一项什么都不说的跳过检查，与一项通过了的检查无从区分；读者无法知道从未寻求过引擎指导。

### Step 4: 代码集成（gameplay-programmer）
生成 `gameplay-programmer` 代理来：
- 实现音频管理器系统或评审现有实现
- 把音频事件接到玩法触发器上
- 实现自适应音乐系统（若已指定）
- 设置音频遮挡/混响区域
- 为音频事件触发器编写单元测试

4. **汇编音频设计文档**，合并全部团队输出。

5. **保存到** `design/audio/audio-[feature].md` —— **但要先询问。** `design/` 不在受限写入例外覆盖的三个目录之内
   （`production/`、`docs/`、`tests/`），因此拿到这个路径的子代理必须
   提示确认。不要
   通过扩大例外来解决。改为遵循 `team-level` 使用的同一模式：
   **你**已经持有每个子代理的输出，所以自己汇编
   文档，并通过 `AskUserQuestion` 直接询问——"我可以把音频设计写入
   `design/audio/audio-[feature].md` 吗？"——然后在批准后写入。子代理的工作产出物留在 `production/` 下，例外覆盖到那里。

   注意：如果 `design/audio/` 不存在，写入文件会创建它。

6. **输出摘要**，包含：音频事件数量、预估资源数量、
   实现任务，以及团队成员之间的任何开放问题。

结论：**COMPLETE** —— 已产出音频设计文档，团队流水线完成。

如果引擎校验被跳过（未配置引擎），结论要说明这一点——绝不给出朴素的 COMPLETE：

结论：**COMPLETE — engine validation NOT ASSESSED ([reason])** —— 已产出音频设计文档；引擎专家从未评审过集成计划。

如果流水线因依赖未解决而停止（例如关键无障碍缺口，或用户未解决缺失的 GDD）：

结论：**BLOCKED** —— [reason]

## 文件写入协议

逐代理产出物（SFX 规格、集成计划）由产出它们的子代理写入，
适用上面"Why this does not violate the Collaboration Protocol"中记录的**受限例外**——路径是你点名的，产出物是 `production/`、`docs/` 或 `tests/` 下的新文件，且该阶段由 `AskUserQuestion` 把关。在这些边界内，子代理**不会**每次写入都提示；
超出边界则必须询问。**实现文件**——gameplay-programmer 的音频
集成代码、代码根或 `assets/` 下的任何内容——在这些边界之外：代理返回它将创建或修改的文件，你一次性询问该
清单，它在得到 yes 后写入。**唯一的例外是最终汇编的音频设计
文档**：编排器已持有所有输入，所以它在自己的"我可以写入……吗？"提示之后
（上面的"保存到"步骤）自行汇编并写入 `design/audio/audio-[feature].md`。

## 后续步骤

- 在实现开始之前与 audio-director 一起评审音频设计文档。
- 设计获批后，使用 `/dev-story` 实现音频管理器与事件系统。
- 音频资源创建后运行 `/asset-audit`，校验命名与格式合规性。
- 如果之前没有声音圣经，在下一轮音频工作之前创建一个：请
  `audio-director` 代理依据 `.trae/docs/templates/sound-bible.md` 起草 `design/audio/sound-bible.md`，
  从本次运行 Step 1 的方向开始（在 `design/` 下写入前它会先询问）。

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