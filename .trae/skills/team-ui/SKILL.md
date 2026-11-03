---
name: team-ui
description: "编排 UI 团队走完 UX 流水线——撰写、视觉设计、实现、评审、打磨。使用 /ux-design、/ux-review 和工作室模板。"
argument-hint: "[UI feature description] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate, Bash(bash "*/.claude/skills/team-ui/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---
# Team UI

如果没有提供参数，输出用法指引并退出，不派生任何代理，也不读取任何设计文件：
> 用法：`/team-ui [UI feature description] [--review full|lean|solo]`——描述要构建的屏幕或 UI 功能（例如 `inventory screen`、`main menu`、`combat HUD`）。此处不要使用 `AskUserQuestion`；直接输出指引。

当调用本技能时，通过结构化流水线编排 UI 团队。

**决策点：** 在每个阶段转换处，使用 `AskUserQuestion` 把子代理的提议
作为可选项呈现给用户。在对话中写出代理的完整分析，然后用简洁标签
捕获决策。在 `collaborative` 模式下，用户必须批准后才能进入下一阶段。
在 `guided` 模式下，流水线自动推进，除非某阶段处于 BLOCKED；
在 `autonomous` 模式下，它端到端运行，并通过 `log_decision` 记录每个阶段的结果。
属于 `automation_always_ask` 类别（`is_always_ask_category` 辅助函数）的决策
无论模式如何都始终询问。参见
`.claude/docs/automation-modes.md`。

## Phase 0: 解析配置

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size`

上面已解析——按原样使用；`--review` 会覆盖 `review_mode`。没有配置块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

`review_mode` 设定总监闸门的深度，而本流水线没有总监闸门：
无论 `review_mode` 为何，下面没有任何阶段会派生 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义于下文的 `team.size`），
在这些决策点上工作的代理是团队成员，而不是总监闸门。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，见上面的决策点说明和
`.claude/docs/automation-modes.md`。

**`team.size`**：哪些代理处于活动状态（与 review_mode 的闸门深度和工作流文档正交）。
- **`individual`**（默认）：`ui-programmer` + `ux-designer`。其他代理通过这两个代理咨询，不单独派生。
- **`small`**：+ `accessibility-specialist` + `art-director`。
- **`studio`**：+ 引擎 UI 专家 + 一轮对抗性评审：Phase 4 的评审者会被告知“你的职责不是确认它符合规格——而是找出它在哪里不符合”，且报告中会说明该轮评审已运行。
在 `individual` 下需要的非核心代理，会通过最近的活动核心代理路由，并附带一条信息性说明。**“阶段闸门”指本流水线自身列出的、以 `AskUserQuestion` 决策点结束的任何阶段**——上文决策点中的某次转换，或下文流水线中写入的某个 **Gate** 步骤——**无论 `automation` 模式为何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否为闸门，因此下文的有界例外条件（3）在每种模式下都对其成立。被限定为“仅阶段闸门”的代理只会在这些点被派生，不会在其他点被派生。这种活动集范围界定贯穿下文整个流水线：任何提到活动集之外代理的阶段，都会通过最近的核心代理路由，而不是派生该代理。

**在 Step 1 之前宣布活动集——绝不能让这种收窄是静默的。**
在派生任何东西之前，用一行说明本次运行实际会派生哪些代理，
以及下文流水线提到但在解析出的 `team.size` 下**不会**派生的代理。例如：

> `Active set (team.size: <resolved>): <the agents listed for that size above>.`
> `Not spawned this run: <every other agent this pipeline names> — consulted`
> `through <nearest active core agent>. Raise team.size (or modes.rigor) to widen.`

直接根据正上方的 `team.size` 列表和本文件自身流水线提到的代理来填写——
不要照抄示例。两个集合因编排器而异。

下文流水线读起来像多代理扇出，而在默认发布配置下它
就是一两个代理——`team-release` 提到十个却只运行一个，`team-narrative`
在五个阶段提到六个却只运行 `writer`。**这种收窄是正确的**：
`team.size` 以严谨度为前缀，而狭窄的默认值是 token 杠杆。
如果不说明这一点，读者就无法
区分一次正确收窄的运行和一条损坏的流水线，而且上文按代理
“通过最近的核心代理路由并附带信息性说明”的规则在路由时触发，从不说明整个运行的形态。

这与本文件其他地方关于跳过检查报告的是同一条规则：**一条被强制执行却从未被暴露的约束，
对阅读输出的人来说，与一条从未被执行的约束是无法区分的。**

## 团队构成
- **ux-designer**——用户流程、线框图、无障碍、输入处理
- **ui-programmer**——UI 框架、屏幕、控件、数据绑定、实现
- **art-director**——视觉风格、布局打磨、与美术圣经的一致性
- **引擎 UI 专家**——对照引擎特定的最佳实践验证 UI 实现模式（来自 `project.yaml` 的 `specialists.ui`；若缺失，则取 `.claude/docs/technical-preferences.md` 中 `## Engine Specialists` 的 UI Specialist 行）
- **accessibility-specialist**——在 Phase 4 审计无障碍合规性

> **`specialists.ui: null` 表示未设置。** 将其视为缺失并跳过引擎
> UI 专家；绝不要把 `null` 作为代理名称派生。只要设置了其中任一成员，
> v1.0 迁移就会写入整个 `specialists` 块，因此这里的 `null` 是
> 普通情况——而配置读取器会把它返回为非空字符串 `"null"`。

**本流水线使用的模板：**
- `ux-spec.md`——标准屏幕/流程 UX 规格
- `hud-design.md`——HUD 专用 UX 规格
- `interaction-pattern-library.md`——可复用的交互模式
- `accessibility-requirements.md`——已承诺的无障碍等级与要求

## 如何委派

使用 `Agent` 工具把每个团队成员作为子代理派生：
- `subagent_type: ux-designer`——用户流程、线框图、无障碍、输入处理
- `subagent_type: ui-programmer`——UI 框架、屏幕、控件、数据绑定
- `subagent_type: art-director`——视觉风格、布局打磨、美术圣经一致性
- `subagent_type: [UI engine specialist]`——引擎特定的 UI 模式验证（例如 unity-ui-specialist、ue-umg-specialist、godot-specialist）
- `subagent_type: accessibility-specialist`——无障碍合规性审计

**给每个代理做简报——不要倾倒上下文。** 把共享输入**只读一次**，并内联传递一份提炼过的简报：每个代理真正需要的那几行，绝不要为你已读过的文档传文件路径（拿到路径的代理会重新读取整个文件）。只为你没读过、且只有该代理需要的文档传路径。

**每个代理提示词都以返回契约结尾：**“Write your full output to `[path]`——这个指定路径就是下文有界例外下的写入授权，因此请直接写入，无需再单独请求批准。只返回 (1) 写入的路径，(2) 不超过 5 条要点的决策摘要，(3) 任何 BLOCKED/CONCERNS 项，每项一行。不要复述你读过的文档。”没有它，代理会把读到的一切都倒回本会话。**实现文件是例外：**编写代码或资源的代理先返回它将创建或更改的文件，并且只有在您请求过一次该集合、用户同意后，其返回契约才会列出这些文件（File Write Protocol）——是那个回答，而不是有界例外，授权这些写入。

**用真实路径替换 `[path]`。** 工作产出物放在
`production/ui/[feature-name]/` 下，即 Phase 1b 的 `design/ux/[feature-name].md`
所用的 slug。每个代理一个文件，因此并行的 Phase 4 评审绝不会共用同一个：

| 阶段 / 代理 | 写入到 |
|---|---|
| 2 art-director | `production/ui/[feature-name]/visual-design.md` |
| 3 引擎 UI 专家 | `production/ui/[feature-name]/engine-notes.md` |
| 3 ui-programmer | 代码根——即那次实现请求列出的文件（File Write Protocol），在有界例外之外 |
| 4 ux-designer、art-director、accessibility-specialist | `production/ui/[feature-name]/review-[agent].md`，各一个 |

UX 规格本身（Phase 1b）以及任何模式库更新都在 `design/` 下，
在有界例外之外：`/ux-design` 或代理会在写入前询问。

> **为什么这并不违反协作协议。** `CLAUDE.md` 要求代理在 Write/Edit 之前询问“May I write this to [filepath]?”。此处派生的子代理**不经**询问就写入，这是有意为之的有界例外，而不是疏忽——这与已经为 `consistency-check` 追加到 `active.md` 所做的决定相同。例外只在以下三点全部成立时才适用：(1) 路径是**你**在提示词中指定的，因此用户在批准该阶段时也批准了目标位置；(2) 它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；(3) 产生它的阶段本身在流水线推进前受 `AskUserQuestion` 闸门约束。三点之外，代理必须询问。**不要通过按子代理逐个询问来“修复”这一点**——每个代理每阶段的提示词会让编排器无法使用，这正是例外存在的原因。

在流水线允许的地方并行启动独立代理（例如 Phase 4 的评审代理可以同时运行）。

## 流水线

### Phase 1a: 上下文收集

在设计任何东西之前，先读取并综合。按章节读取每份 GDD：用 Grep 工具
（模式 `^#`，内容模式）找到你需要的标题，再用 offset 和 limit
读取相应范围。
- `design/gdd/game-concept.md`——平台目标与目标受众（或在
  `rigor: minimal` 时代替它的一页简报 `design/game-brief.md`——
  其“Who it's for”那一行给出受众；它不指明平台）
- `design/player-journey.md`——玩家到达此屏幕时的状态与情境
- 所有与本功能相关的 GDD UI Requirements 章节
- `design/ux/interaction-patterns.md`——可复用（而非重新发明）的现有模式
- `design/accessibility-requirements.md`——已承诺的无障碍等级（Basic、Standard、Comprehensive 或 Exemplary）

**在设计任何东西之前，报告上述每份文档的状态。** Phase 1a
读取五项输入，其中任何一项都可能缺失。逐项列出为
存在或 ABSENT。

**`design/accessibility-requirements.md` 是绝不能静默放过的那个。**
它承载已承诺的无障碍等级，**Phase 3 依此实现**，
**Phase 4 依此设置闸门**（“对照已承诺的无障碍
等级验证合规性……将任何违规标记为阻塞项”）。如果文件缺失就没有等级，
于是该闸门没有标准，会在什么都没检查的情况下通过——一个由缺失标准构成的闸门，
与永远无法失败的断言是同一种形态。当它缺失时：
- 在此说明，并向前传递：**Phase 4 必须报告
  `Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md absent)`
  并且绝不能报告无障碍闸门已通过。**
- ux-designer 要说明他们按哪个等级设计，作为明确的
  假设，以便后来的读者能看到它是假设的而非承诺的。
- 建议运行 `/ux-design accessibility` 来确立等级。

缺少概念文档（既无 `design/gdd/game-concept.md` 也无
`design/game-brief.md`）、`design/player-journey.md` 或 `design/ux/hud.md`
不会阻塞，但要在传给 ux-designer 的简报中点名每一个缺失项，
让他们设计时知道自己缺少什么上下文，而不是去推断。

**如果 `design/ux/interaction-patterns.md` 不存在**，立即暴露该缺口：
> “interaction-patterns.md 不存在——没有可复用的现有模式。”

然后用 `AskUserQuestion` 提供选项：
- (a) 先运行 `/ux-design patterns` 建立模式库，然后继续
- (b) 不使用模式库继续——ui-programmer 将把所有创建的模式都视为新模式，并在完成时把每一个添加到新建的 `design/ux/interaction-patterns.md` 中

不要仅凭功能名称或 GDD 发明或假设模式。如果用户选择 (b)，在 Phase 3 中明确指示 ui-programmer 把所有模式都视为新模式，并在实现完成时把它们记录到 `design/ux/interaction-patterns.md`。在最终总结报告中注明模式库状态（已创建 / 缺失 / 已更新）。

为 ux-designer 把上下文总结成一份简报：玩家在做什么、他们需要什么、适用哪些约束，以及哪些现有模式相关。

### Phase 1b: UX 规格撰写

调用 `/ux-design [feature name]` 技能，或直接委派给 ux-designer，按照 `ux-spec.md` 模板产出 `design/ux/[feature-name].md`。

如果要设计 HUD，使用 `hud-design.md` 模板而不是 `ux-spec.md`。

> **特殊情况说明：**
> - 专门设计 HUD 时，调用 `/ux-design`，参数为 `argument: hud`（例如 `/ux-design hud`）。
> - 对于交互模式库，在项目开始时运行一次 `/ux-design patterns`，并在后续阶段引入新模式时随时更新。

输出：`design/ux/[feature-name].md`，所有必需的规格章节均已填写。

### Phase 1c: UX 评审

规格完成后，调用 `/ux-review design/ux/[feature-name].md`。

**闸门**：在判定为 APPROVED 之前，不得进入 Phase 2。如果判定是 NEEDS REVISION，ux-designer 必须在同一份规格中解决被标记的问题——规格会被保留并修订，绝不丢弃——然后重新运行评审。用户可以明确接受 NEEDS REVISION 的风险并继续，但这必须是有意识的决定——在询问是否继续之前，通过 `AskUserQuestion` 呈现具体关注项。

**NOT ASSESSED** 判定以同样的方式阻塞，用户也可以以同样的方式覆盖它。它的修复是补充输入，而不是修订：呈现 `/ux-review` 无法评估的维度以及每个维度缺失的输入（例如未承诺等级时的 `/ux-design accessibility`）。在没有该输入的情况下重新运行评审会返回同样的判定，因此应主动提议先产出该输入。

当用户越过 NEEDS REVISION 或 NOT ASSESSED 继续时，最终报告要记录这次覆盖：判定、仍悬而未决的关注项或未评估维度，以及用户选择继续。

### Phase 2: 视觉设计

委派给 **art-director**：
- 评审完整的 UX 规格（流程、线框图、交互模式、无障碍说明）——不只是线框图图片
- 应用美术圣经中的视觉处理：颜色、字体排印、间距、动画风格
- 检查视觉设计是否保持无障碍合规性：验证颜色对比度，并确认颜色绝不是唯一的状态指示（形状、文本或图标必须强化它）
- 明确美术流水线所需的全部资源要求：指定尺寸的图标、背景纹理、字体、装饰元素——附精确尺寸和格式要求
- 确保与已实现的现有 UI 屏幕保持一致
- 输出：带风格说明和资源清单的视觉设计规格

### Phase 3: 实现

在实现开始前，派生**引擎 UI 专家**（来自 `project.yaml` 的 `specialists.ui`；若缺失，则取 `.claude/docs/technical-preferences.md` 中 `## Engine Specialists` 的 UI Specialist 行），对照 UX 规格和视觉设计规格评审引擎特定的实现指导：
- 此屏幕应使用哪个引擎 UI 框架？（例如 Unity 中的 UI Toolkit 与 UGUI、Godot 中的 Control 节点与 CanvasLayer、Unreal 中的 UMG 与 CommonUI）
- 对于提议的布局或交互模式，有哪些引擎特定的坑？
- 该引擎推荐的控件/节点结构是什么？
- 输出：在 ui-programmer 开始前交接给其的引擎 UI 实现说明

如果没有配置引擎，跳过此步骤。**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 一个什么都不说的跳过检查，与一个通过的检查无法区分；读者无法判断从未寻求过引擎指导。

委派给 **ui-programmer**：
- 按照 UX 规格和视觉设计规格实现 UI
- **使用 `design/ux/interaction-patterns.md` 中的模式**——不要重新发明已经指定的模式。如果某个模式几乎适用但需要修改，注明偏离并标记给 ux-designer 评审。
- **UI 绝不拥有或修改游戏状态**——仅展示；为所有玩家操作发出事件
- 所有文本都通过本地化系统——不硬编码面向玩家的字符串
- 同时支持两种输入方式（键盘/鼠标和手柄）
- 按照 `design/accessibility-requirements.md` 中承诺的等级实现无障碍功能
- 接好到游戏状态的数据绑定
- **如果在实现期间创建了任何新的交互模式**（即模式库中尚不存在的东西），在标记实现完成之前把它添加到 `design/ux/interaction-patterns.md`
- 输出：已实现的 UI 功能

### Phase 4: 评审（并行）

并行委派：
- **ux-designer**：验证实现是否符合线框图和交互规格。测试纯键盘和纯手柄导航。检查无障碍功能是否正常工作。
- **art-director**：验证与美术圣经的视觉一致性。至少在最小和最大支持分辨率下检查。
- **accessibility-specialist**：对照 `design/accessibility-requirements.md` 中记录的已承诺无障碍等级验证合规性。将任何违规标记为阻塞项。**如果该文件缺失，就没有已承诺的等级，因此该闸门没有标准：报告 `Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md absent)`，并且不要报告闸门已通过**。向前传承 Phase 1a 记录为假设的等级，并明确说明它是假设的。

三条评审流都必须在进入 Phase 5 之前报告。

### Phase 5: 打磨

- 处理所有评审反馈
- 验证动画可跳过，并尊重玩家的减少动态效果偏好
- 确认 UI 音效通过音频事件系统触发（无直接音频调用）
- 在所有支持的分辨率和宽高比下测试
- **验证 `design/ux/interaction-patterns.md` 是最新的**——如果本功能实现期间引入了任何新模式，确认它们已添加到模式库
- **确认所有 HUD 元素遵守 `design/ux/hud.md` 中定义的视觉预算**（元素数量、屏幕区域分配、最大不透明度值）

## 快速参考——何时使用哪个技能

- `/ux-design`——从头为屏幕、流程或 HUD 撰写新的 UX 规格
- `/ux-review`——在实现前验证已完成的 UX 规格
- `/team-ui [feature]`——从概念到打磨的完整流水线（内部调用 `/ux-design` 和 `/ux-review`）
- `/quick-design`——不需要完整新 UX 规格的小型 UI 改动

## 错误恢复协议

**首先，验证产出物。** 如果返回契约指定了路径，在把该阶段视为完成之前
检查该路径是否存在——**一个不在磁盘上的命名产出物就是失败的阶段，无论回复读起来多么流畅。**
代理可能耗掉整个阶段，什么都没写却返回一段看似合理的开场白，
这既不是 BLOCKED，也不是错误，也不是“无法完成”，因此下面的触发器
永远不会触发。点名未满足的契约来恢复它；上下文通常还在。

如果任何派生的代理返回 BLOCKED、报错或无法完成：**立即暴露它，不要越过它所阻塞的依赖继续推进，并且始终产出部分报告。** 被跳过的代理，其章节应保持为一个具名缺口——绝不要用你自己的内容去填充。完整流程：`.claude/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（用户故事未找到、GDD 缺失）→ 重定向到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围太大 → 通过 `/create-stories` 拆成两个用户故事
- ADR 与用户故事之间的指令冲突 → 暴露冲突，不要猜测

## 文件写入协议

所有文件写入（UX 规格、交互模式库更新、实现文件）都
委派给子代理和子技能。两者遵循**不同的**规则：

- **通过 `Agent` 派生的子代理**（例如 `ui-programmer`）遵循上文“为什么这并不违反协作协议”中记录的**有界例外**——路径是你指定的，产出物是 `production/`、`docs/` 或 `tests/` 下的新东西，且该阶段受 `AskUserQuestion` 闸门约束。在这些边界内，子代理**不会**每次写入都提示；在边界之外，它必须询问。
  **实现文件**（ui-programmer 在代码根下的代码）在这些边界之外：
  ui-programmer 返回它将创建或更改的文件，您为这个集合询问一次，它在你同意后写入。
- **子技能**（`/ux-design`）不是子代理，例外不适用于它们。它们遵循正常的协作协议，并在写入前询问。

本编排器不直接写文件。

## 输出

一份总结报告，涵盖：UX 规格状态、UX 评审判定、视觉设计状态、实现状态、无障碍合规性、输入方式支持、交互模式库更新状态，以及任何未决问题。

判定：**COMPLETE**——UI 功能通过完整流水线交付（UX 规格 → 视觉 → 实现 → 评审 → 打磨）。

如果无障碍闸门（无已承诺等级）或引擎验证（未配置引擎）为 NOT ASSESSED，
判定要点名每一项——绝不给出单纯的 COMPLETE：

判定：**COMPLETE — [accessibility | engine validation] NOT ASSESSED ([reason])**——UI 功能已交付；所点名的那项检查无法运行。

判定：**BLOCKED**——流水线已停止；在停下之前暴露阻塞项及其阶段。

## 后续步骤

- 如果最终规格尚未获批准，对其运行 `/ux-review`。
- 在关闭用户故事之前，对 UI 实现运行 `/code-review`。
- 如果需要视觉或音频打磨轮次，运行 `/team-polish`。
