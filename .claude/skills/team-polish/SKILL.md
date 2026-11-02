---
name: team-polish
description: "编排打磨团队 — performance-analyst、technical-artist、sound-designer、qa-tester — 优化并加固某个功能或区域。"
argument-hint: "[feature or area to polish] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate, Bash(bash "*/.claude/skills/team-polish/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---
# 打磨团队

如果未提供参数，输出用法说明并在不派出任何 agent 的情况下退出：
> 用法：`/team-polish [feature or area to polish] [--review full|lean|solo]` — 指定要打磨的功能或区域（例如 `combat`、`main menu`、`inventory system`、`level-1`）。此处不要使用 `AskUserQuestion`；直接输出说明。

当本技能带参数被调用时，通过结构化流水线编排打磨团队。

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

**`team.size`**：哪些 agent 处于活动状态（与 review_mode 闸门深度和 workflow 文档正交）。
- **`individual`**（默认）：`performance-analyst` + `technical-artist`。其他 agent 通过这两个咨询，不单独派出。没有程序员处于活动状态，因此优化列表中的程序员项不会在本次运行中实现——报告会说明该列表已交给 `/dev-story`（Phase 2）。
- **`small`**：+ `sound-designer` + `qa-tester` + `engine-programmer`，以及当 Phase 1 将某个原因追溯到内容创作工具时的 `tools-programmer`（如下文所述的完整流水线）。
- **`studio`**：`small` 集合，包含 `engine-programmer`，+ 一个对抗性评审环节：Phase 5 的 qa-tester 被告知“你的工作不是确认它能保持——而是找出它是如何坏掉的”，并且报告中说明该环节已运行。本流水线没有可扩展的引擎专家；引擎层面工作仍归 `engine-programmer`。
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
- **performance-analyst** — 性能分析、内存分析、帧预算和优化列表——它不编写游戏代码
- **engine-programmer** — 实现优化列表中的引擎层面项：渲染流水线、内存、资源加载、热路径（当 performance-analyst 识别出底层根因时调用）
- **technical-artist** — VFX 打磨、着色器优化、视觉质量
- **sound-designer** — 音频打磨、混音、环境层、反馈音效
- **tools-programmer** — 内容流水线工具验证、编辑器工具稳定性、自动化修复（Phase 2，当 Phase 1 将原因追溯到内容创作工具时）
- **qa-tester** — 边界情况测试、回归测试、浸泡测试

## 如何委派

使用 `Agent` 工具将每个团队成员作为子代理派出：
- `subagent_type: performance-analyst` — 性能分析、内存分析、优化列表
- `subagent_type: engine-programmer` — 来自优化列表的引擎层面修复：渲染、内存、资源加载
- `subagent_type: technical-artist` — VFX 打磨、着色器优化、视觉质量
- `subagent_type: sound-designer` — 音频打磨、混音、环境层
- `subagent_type: tools-programmer` — 来自优化列表的内容流水线和编辑器工具修复
- `subagent_type: qa-tester` — 边界情况测试、回归测试、浸泡测试

**给每个 agent 写简报——不要倾倒上下文。** 只读取一次共享输入，并以内联方式传递提炼后的简报：每个 agent 实际需要的那几行，绝不要为你已经读过的文档传文件路径（拿到路径的 agent 会重新读取整个文件）。只为你尚未读过且只有该 agent 需要的文档传递路径。

**每个 agent 提示都以返回契约结尾：**“Write your full output to `[path]` ——该指定路径即为你在下文有界例外下的写入授权，因此无需单独的审批提示即可写入。只返回（1）写入的路径，（2）不超过 5 条要点的决策摘要，（3）任何 BLOCKED/CONCERNS 项，每项一行。不要复述你读过的文档。”没有它，agent 会把它读过的一切都返回本会话中。**实现文件是例外：** 编写代码或资源的 agent 先返回它将创建或更改的文件，其返回契约只有在你就整个集合询问过一次且用户同意后才点名这些文件（文件写入协议）——是该答复，而不是有界例外，授权这些写入。

**用真实路径替换 `[path]`——本技能的目标是
`production/polish/`。** 按 agent 命名，每个 agent 一个文件：

| Agent | 写入到 |
|---|---|
| performance-analyst | `production/polish/[area]-report-[date].md` |
| technical-artist | `production/polish/[area]-render-notes-[date].md` |
| engine-programmer | `production/polish/[area]-engine-fixes-[date].md` |
| tools-programmer | `production/polish/[area]-tool-fixes-[date].md` |
| sound-designer | `production/polish/[area]-audio-notes-[date].md` |
| qa-tester | `production/polish/[area]-verification-[date].md` |

> **为什么是 `production/` 而不是 `docs/`。** 这些是带日期的单次运行
> 测量结果，与 `production/qa/smoke-[date].md` 形态相同——而不是像
> `docs/architecture/` 那样的持久规格。将它们与其他时间点过程产出物
> 放在一起，才能让后续比较成为可能。
>
> 上面的 `[path]` 契约有一个前提：路径是*你*命名的，因此
> 这里必须说明具体目标，否则每次运行都会自创一个。与
> `/team-qa` 和 `/team-narrative`（其目标由消费方固定）不同，
> 此位置在仓库中没有读取者，是刻意选择的。
> **目前没有任何东西读取 `production/polish/`**——在报告时说明这一点，以便用户
> 知道报告是记录，而不是后续闸门的输入。

> **为什么这不违反协作协议。** `CLAUDE.md` 要求 agent 在 Write/Edit 之前询问“May I write this to [filepath]?”。此处派出的子代理**不询问**即可写入，这是刻意的有界例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已做出的相同决定。该例外仅在以下三项全部成立时适用：（1）路径是**你**在提示中命名的，因此用户在批准该阶段时已批准目标；（2）它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；（3）产生它的阶段本身在流水线推进前由 `AskUserQuestion` 把关。超出这三项，agent 必须询问。**不要通过按子代理逐个询问来“修复”这一点**——每个阶段每个 agent 一个提示会让编排器无法使用，这正是该例外存在的原因。

在流水线允许的情况下并行启动独立 agent（例如 Phase 3 和 Phase 4 可以同时运行）。

## 流水线

### Phase 1: 评估
委派给 **performance-analyst**：
- 使用 `/perf-profile` 分析目标功能/区域
- 识别性能瓶颈和帧预算违规
- 测量内存使用并检查泄漏
- 对照目标硬件规格进行基准测试
- 输出：带优先级 **优化列表** 的性能报告——对每一项给出变更、相对预算的预期收益，以及其负责人（渲染侧变更归 technical-artist，引擎系统和热路径归 engine-programmer，内容创作工具归 tools-programmer，否则归拥有该系统的程序员）

### Phase 2: 优化
performance-analyst 不编写游戏代码（“建议并分配”，见其 agent 文件），
因此 Phase 2 通过活动集中的负责人实现其 Phase 1 列表：
- **engine-programmer** — 仅当 Phase 1 识别出引擎层面根因（渲染流水线、资源加载、内存分配器、核心循环中的热路径）时派出：实现这些项，修复分配压力，验证玩法行为不变。输出：带前后指标和性能分析器验证的引擎层面修复
- **tools-programmer** — 仅当 Phase 1 将原因追溯到内容创作工具时：修复该工具。输出：带前后指标的工具修复
- **technical-artist** — 渲染侧项（绘制调用、过度绘制、粒子、着色器、LOD）并入其 Phase 3 简报

Phase 2–4 中的每个实现 agent 先返回它将创建或更改的文件，
并且你在任何文件被编辑之前就整个 Phase 2–4 集合询问一次（文件
写入协议）。

**负责人不在活动集中的项不会在本次运行中实现。**
在 `team.size: individual` 下，这就是所有程序员项，因为没有程序员
处于活动状态；在任何规模下，都包括由本流水线未点名的程序员所拥有的项
（例如玩法脚本热点的 gameplay-programmer）。报告
在“Optimisation list handed to `/dev-story`: `production/polish/[area]-report-[date].md`”
下列出这些项及其负责人。
它们所瞄准的、超出预算的指标在 Phase 6 仍是已知问题。

### Phase 3: 视觉打磨（与 Phase 2 并行）
委派给 **technical-artist**：
- 审查 VFX 的质量以及与美术圣经的一致性
- 优化粒子系统和着色器效果
- 在适当的地方添加屏幕震动、摄像机效果和视觉爽感
- 确保效果在较低设置下也能优雅降级
- 输出：打磨后的视觉效果

### Phase 4: 音频打磨（与 Phase 2 并行）
委派给 **sound-designer**：
- 审查音频事件的完整性（是否有任何动作缺少声音反馈？）
- 检查音频混音电平——相对于混音，没有任何内容过响或过轻
- 添加环境音频层以营造氛围
- 验证音频在空间定位下正确播放
- 输出：音频打磨列表和混音说明

### Phase 5: 加固
委派给 **qa-tester**：
- 测试所有边界情况：边界条件、快速输入、异常序列
- 浸泡测试：长时间运行该功能，检查是否退化
- 压力测试：最大实体数、最坏情况场景
- 回归测试：验证打磨变更没有破坏现有功能——按名称检查每个 Phase 2–4 变更，包括引擎层面修复
- 在最低规格硬件上测试（如果可用）
- 输出：带任何遗留问题的测试结果

### Phase 6: 签字确认
- 收集所有团队成员的结果
- 将性能指标与预算进行比较
- 报告：READY FOR RELEASE / NOT ASSESSED / NEEDS MORE WORK
- 列出每个遗留问题及其严重程度（S1–S4）、可测量差距（例如“9 ms 对 6 ms 预算——超出 3 ms”），以及建议；回归问题还要点名被破坏的行为和导致它的打磨变更

**NOT ASSESSED 的优先级高于 READY FOR RELEASE，低于 NEEDS MORE WORK。** 一个已知
问题——指标超预算、未解决的回归——会使其成为 NEEDS MORE
WORK，无论其他还有什么未检查。否则，如果范围内的任何部分无法
检查，结果为 NOT ASSESSED，绝不是 READY FOR RELEASE，且报告
点名每个缺口：
- 没有已承诺预算的指标。`performance.target_framerate`、
  `performance.frame_budget_ms`、`performance.draw_call_limit` 和
  `performance.memory_ceiling_mb` 没有默认值，`/perf-profile` 会将
  未设置的值报告为 NOT ASSESSED——没有比较对象，因此没有满足任何预算。
- 未运行的阶段：BLOCKED、被跳过，或其 agent 在活动集之外。
  在 `team.size: individual` 下，sound-designer 的音频打磨和 qa-tester 的
  加固仅通过活动 agent 咨询，不会运行，且 Phase 2 的
  程序员项交给 `/dev-story` 而不是实现。

## 错误恢复协议

**首先，验证产出物。** 如果返回契约点名了路径，在将该阶段视为完成之前
检查该路径是否存在——**一个已命名但不在磁盘上的产出物就是失败的阶段，
无论回复读起来多么流畅。** 一个 agent 可能烧掉整个阶段，返回一段看似合理的前言
却什么都没写，这既不是 BLOCKED，也不是错误，也不是“无法完成”，因此下面的触发器
永远不会触发。以未满足的契约名义恢复它；上下文通常还在。

如果任何派出的 agent 返回 BLOCKED、错误或无法完成：**立即暴露它，不要越过它阻塞的依赖继续推进，并且始终产生部分报告。** 被跳过 agent 的章节保持为已命名的缺口——绝不要用你自己的内容填充它。完整流程见：`.claude/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（未找到用户故事、缺少 GDD）→ 重定向到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围太大 → 通过 `/create-stories` 拆分为两个用户故事
- ADR 与用户故事之间存在冲突指令 → 暴露冲突，不要猜测

## 文件写入协议

所有文件写入（性能报告、测试结果、证据文档）都委派给通过 `Agent` 派出的
子代理。这些写入遵循上文“为什么这不违反协作协议”中记录的
**有界例外**——路径是你命名的，产出物是 `production/`、`docs/` 或
`tests/` 下的新文件，且该阶段由 `AskUserQuestion` 把关。子代理
在这些边界内**不会**逐次写入提示；超出边界则必须询问。Phase 2–4 的
优化和打磨变更会编辑现有代码、着色器、音频或资源，因此
它们在这些边界之外：每个实现 agent 返回它将创建或更改的文件，
你就整个 Phase 2–4 集合询问一次（“May I have [agents]
change these [N] files?”），且每个 agent 仅在同意后编辑——对整个集合询问一次，
而不是每个阶段一次。此编排器不直接写入文件。

## 输出

一份摘要报告，涵盖：性能前后指标、视觉打磨变更、音频打磨变更、测试结果、任何交给 `/dev-story` 的优化列表，以及发布就绪评估。

## 后续步骤

- 如果为 READY FOR RELEASE：运行 `/release-checklist` 进行最终的发布前验证。
- 如果为 NEEDS MORE WORK：在 `/sprint-plan update` 中安排遗留问题（在 `workflow: minimal` 下没有冲刺，将它们加入简报的构建顺序），修复后重新运行 `/team-polish`。
- 如果为 NOT ASSESSED：补上缺失的内容——在 `project.yaml`（`/settings`）中提交未设置的 `performance.*` 预算，或运行未运行的阶段（提高 `team.size`）——然后重新运行 `/team-polish`。不要将该区域视为可发布。
- 如果报告将优化列表交给了 `/dev-story`：在那里实现这些项，然后重新运行 `/team-polish` 以测量收益。
- 在交接给发布之前运行 `/gate-check` 以获得正式阶段闸门结论。
