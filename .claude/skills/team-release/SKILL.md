---
name: team-release
description: "编排发布团队——release-manager、qa-lead、devops-engineer、producer——执行从候选版本到部署的发布流程。"
argument-hint: "[version number or 'next'] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate, Bash(bash "*/.claude/skills/team-release/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---
# Team Release

**参数检查：** 如果没有提供版本号：
1. 读取 `production/session-state/active.md` 和 `production/milestones/` 中最近的文件（如果它们存在）以推断目标版本。
2. 如果找到版本：报告“未提供版本参数——已从里程碑数据推断出 [version]。继续。”然后用 `AskUserQuestion` 确认：“正在发布 [version]。这是正确的吗？”
3. 如果无法发现版本：使用 `AskUserQuestion` 询问“应发布哪个版本号？（例如 v1.0.0）”并等待用户输入后再继续。不要默认使用硬编码的版本字符串。

当调用本技能时，通过结构化流水线编排发布团队。

**决策点：** 在每个阶段转换处，使用 `AskUserQuestion` 把子代理的提议
作为可选项呈现给用户。在对话中写出代理的完整分析，然后用简洁标签
捕获决策。在 `collaborative` 模式下，用户必须批准后才能进入下一阶段。
在 `guided` 模式下，流水线自动推进，除非某阶段处于 BLOCKED；
在 `autonomous` 模式下，它端到端运行，并通过 `log_decision` 记录每个阶段的结果。
属于 `automation_always_ask` 类别（`is_always_ask_category` 辅助函数）的决策
无论模式如何都始终询问。参见
`.claude/docs/automation-modes.md`。

## Phase 0: 解析配置

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size,workflow,project.stage`

上面已解析——按原样使用；`--review` 会覆盖 `review_mode`。没有配置块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

**阶段检查——在派生任何东西之前。** 本技能执行发布，而
`/gate-check release` 是必须先通过的就绪闸门；只有其 PASS
才会把 `project.stage` 设为 `Release`。如果解析出的 `project.stage` 是其他值——
`Polish`、更早的阶段，或未设置——在 Phase 1 之前停下，不派生
任何东西：

> “发布就绪闸门尚未通过（project.stage: [stage]）——请先运行
> `/gate-check release`。”

然后用 `AskUserQuestion` 询问，**在每种 `automation` 模式下**——覆盖绝不
代用户做出：`[A] Stop — I'll run /gate-check release (recommended)`
/ `[B] Proceed anyway — override the stage check`。选 `[A]` 则结束运行：判定
**BLOCKED**——发布闸门未通过。选 `[B]` 则（以纯文本）询问原因，然后
把覆盖记录为 `Stage override: project.stage was [stage] — release gate not
passed; the user chose to proceed: [reason]`，写入 Phase 1 简报、
go/no-go 记录（`go-no-go-[version].md`）和最终报告。覆盖绝不
改变阶段本身。

`review_mode` 设定总监闸门的深度，而本流水线没有总监闸门：
无论 `review_mode` 为何，下面没有任何阶段会派生 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义于下文的 `team.size`），
在这些决策点上工作的代理是团队成员，而不是总监闸门。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，见上面的决策点说明和
`.claude/docs/automation-modes.md`。

**`team.size`**：哪些代理处于活动状态（与 review_mode 的闸门深度和工作流文档正交）。
- **`individual`**（默认）：仅 `release-manager`。其他代理通过 release-manager 咨询，不单独派生。
- **`small`**：+ `producer` + `devops-engineer` + `qa-lead` + `community-manager`。
- **`studio`**：+ `security-engineer` + `analytics-engineer` + `localization-lead` + `performance-analyst`，以及游戏为多人时的 `network-programmer`（即文档所述的完整流水线）。
在 `individual` 下需要的非核心代理，会通过最近的活动核心代理路由，并附带一条信息性说明。**“阶段闸门”指本流水线自身列出的、以 `AskUserQuestion` 决策点结束的任何阶段**——上文决策点中的某次转换、阶段检查，或 Phase 6 的部署问题——**无论 `automation` 模式为何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否为闸门，因此下文的有界例外条件（3）在每种模式下都对其成立。被限定为“仅阶段闸门”的代理只会在这些点被派生，不会在其他点被派生。这种活动集范围界定贯穿下文整个流水线：任何提到活动集之外代理的阶段，都会通过最近的核心代理路由，而不是派生该代理。

**在 Phase 1 之前宣布活动集——绝不能让这种收窄是静默的。**
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
- **release-manager**——发布标签、版本管理、变更日志、补丁说明、部署
- **qa-lead**——测试签核、回归套件、发布质量闸门
- **devops-engineer**——构建流水线、产出物、部署自动化
- **security-engineer**——发布前安全审计（如果游戏有在线/多人功能或玩家数据，则调用）
- **network-programmer**——网络代码稳定性签核（如果游戏有多人功能，则调用）
- **analytics-engineer**——验证遥测事件正确触发、仪表盘在线
- **localization-lead**——验证每个随包发布的字符串都已翻译
- **performance-analyst**——对照性能目标对发布构建进行基准测试
- **community-manager**——发布公告和面向玩家的消息，依据补丁说明撰写
- **producer**——go/no-go 决策、利益相关方沟通、排期

## 如何委派

使用 `Agent` 工具把每个团队成员作为子代理派生：
- `subagent_type: release-manager`——发布标签、版本管理、变更日志、补丁说明、部署
- `subagent_type: qa-lead`——测试签核、回归套件、发布质量闸门
- `subagent_type: devops-engineer`——构建流水线、产出物、部署自动化
- `subagent_type: security-engineer`——在线/多人/数据功能的安全审计
- `subagent_type: analytics-engineer`——遥测事件验证与仪表盘就绪情况
- `subagent_type: community-manager`——发布沟通，依据补丁说明撰写
- `subagent_type: producer`——go/no-go 决策、利益相关方沟通
- `subagent_type: network-programmer`——网络代码稳定性签核（如果游戏有多人功能，则调用）
- `subagent_type: localization-lead`——翻译完整性签核（Phase 4）
- `subagent_type: performance-analyst`——对照目标的性能基准（Phase 4）

**给每个代理做简报——不要倾倒上下文。** 把共享输入**只读一次**，并内联传递一份提炼过的简报：每个代理真正需要的那几行，绝不要为你已读过的文档传文件路径（拿到路径的代理会重新读取整个文件）。只为你没读过、且只有该代理需要的文档传路径。

**每个代理提示词都以返回契约结尾：**“Write your full output to `[path]`——这个指定路径就是下文有界例外下的写入授权，因此请直接写入，无需再单独请求批准。只返回 (1) 写入的路径，(2) 不超过 5 条要点的决策摘要，(3) 任何 BLOCKED/CONCERNS 项，每项一行。不要复述你读过的文档。”没有它，代理会把读到的一切都倒回本会话。

**用真实路径替换 `[path]`。** 每个代理一个文件，放在
`production/releases/` 下，除了两个家目录固定在别处的。活动
代理代替活动集之外的代理时，写入那个代理的文件：

| 阶段 / 代理 | 写入到 | 目标位置由谁固定 |
|---|---|---|
| 1 producer | `production/releases/release-plan-[version].md` | 本技能 |
| 2 release-manager | `production/releases/release-checklist-[version].md` | `/release-checklist` |
| 3 qa-lead | `production/releases/qa-gate-[version].md` | 本技能 |
| 3 devops-engineer | `production/releases/build-[version].md` | 本技能 |
| 3 security-engineer | `production/releases/security-signoff-[version].md` | 本技能 |
| 3 network-programmer | `production/releases/netcode-signoff-[version].md` | 本技能 |
| 4 localization-lead | `production/releases/localization-signoff-[version].md` | 本技能 |
| 4 performance-analyst | `production/releases/performance-signoff-[version].md` | 本技能 |
| 4 analytics-engineer | `production/releases/analytics-signoff-[version].md` | 本技能 |
| 5 go/no-go | `production/releases/go-no-go-[version].md` | 本技能 |
| 6 release-manager | `docs/patch-notes/[version].md` | `/patch-notes` |
| 6 community-manager | `production/releases/announcement-[version].md` | 本技能 |
| 7 release-manager | `production/releases/release-report-[version].md` | 本技能 |

> **这十三个输出中的每一个都需要明确的目标位置。**
> `production/releases/` 是 `/release-checklist` 已经在写的地方，
> `docs/patch-notes/[version].md` 是 `/patch-notes` 已经在写的地方，因此
> 无论由哪个技能产生，发布记录都会落在同一个位置。
>
> **每个代理一个独立文件，而不是一条追加记录。** Phase 3 和 Phase 4
> 并行派生代理；两个代理追加同一个文件会产生竞争，输家的
> 章节会静默消失。

> **为什么这并不违反协作协议。** `CLAUDE.md` 要求代理在 Write/Edit 之前询问“May I write this to [filepath]?”。此处派生的子代理**不经**询问就写入，这是有意为之的有界例外，而不是疏忽——这与已经为 `consistency-check` 追加到 `active.md` 所做的决定相同。例外只在以下三点全部成立时才适用：(1) 路径是**你**在提示词中指定的，因此用户在批准该阶段时也批准了目标位置；(2) 它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；(3) 产生它的阶段本身在流水线推进前受 `AskUserQuestion` 闸门约束。三点之外，代理必须询问。**不要通过按子代理逐个询问来“修复”这一点**——每个代理每阶段的提示词会让编排器无法使用，这正是例外存在的原因。

在流水线允许的地方并行启动独立代理（例如 Phase 3 的代理可以同时运行）。

## 流水线

### Phase 1: 发布规划
委派给 **producer**：
- 确认所有里程碑验收标准均已满足
- 识别本次发布中推迟的任何范围项
- 设定目标发布日期并告知团队
- 输出：带范围确认的发布授权

### Phase 2: 候选版本
委派给 **release-manager**：
- 在 `main` 上所有相关文件中提升版本号；携带该版本提升的提交即为候选版本。开发基于主干——发布是 `main` 上的标签（在 Phase 6 应用），而不是分支
- 确认 Polish 阶段的发布检查清单（`/release-checklist`，在 `/gate-check release` 之前运行）已为该候选版本完成；只有在不存在时才现在运行它
- 只有本次发布需要稳定化（冻结、平台认证）时，才从候选版本切出 `release/[version]` 分支——只在其中做缺陷修复，并且每项修复也要落到 `main`
- 输出：候选版本提交（如果切了分支，还包括 `release/*` 分支）和检查清单

### Phase 3: 质量闸门（并行）
并行委派：
- **qa-lead**：执行完整回归测试套件。测试所有关键路径。验证不存在该 `workflow` 下 `/gate-check release` 会阻塞的严重级别的未决缺陷：每个层级都看 S1，`full` 下还看 S2 和 S3。对质量签核。
- **devops-engineer**：为所有目标平台构建发布产出物。验证构建干净且可复现。在 CI 中运行自动化测试。
- **security-engineer** *（如果游戏有在线功能、多人或玩家数据）*：进行发布前安全审计。评审认证、反作弊、数据隐私合规。对安全态势签核。
- **network-programmer** *（如果游戏有多人功能）*：对网络代码稳定性签核。验证延迟补偿、重连处理和负载下的带宽占用。

当任一代理位于活动集时，根据 `project.yaml` 中的 `platform.online` 和 `platform.multiplayer`，以及游戏是否存储玩家数据，决定其条件。缺失的键不等于 `false`：询问用户，而不是假设是离线游戏。因这些理由被跳过的代理要在 Phase 3 输出中点名说明——例如 `security-engineer: not spawned — platform.online: false, platform.multiplayer: false, no player data`。

### Phase 4: 本地化、性能与分析
委派（如果资源允许，可与 Phase 3 并行运行）：
- 验证所有字符串都已翻译（如果可用，委派给 **localization-lead**）
- 对照目标运行性能基准（如果可用，委派给 **performance-analyst**）
- **analytics-engineer**：验证所有遥测事件在发布构建上正确触发。确认仪表盘正在接收数据。检查关键漏斗（上手引导、进度推进、商业化（如适用））是否已埋点。
- 输出：本地化、性能和分析签核——每个代理一个文件（见上表）

### Phase 5: Go/No-Go
在委派之前，获取 **technical-director** 的发布签核。producer
无法派生代理，因此由编排器执行：仅在
`review_mode: full` 下派生 `technical-director`——这是总监评审，不是 PHASE-GATE，因此 `lean`
和 `solo` 跳过它。请求对候选版本的技术状态给出 GO、CONCERNS 或 NO-GO，
或给出 NOT ASSESSED 并点名它无法读取的内容。当它未被派生时，
go/no-go 记录写 `technical-director sign-off: not run
(review_mode: <mode>)`，而不是把它列为已给出；NOT ASSESSED 的回答
按原样记录，绝不计为签核。

委派给 **producer**，传入目前收集到的每一项签核：
- 收集以下来源的签核：qa-lead、release-manager、devops-engineer、security-engineer（若在 Phase 3 派生）、network-programmer（若在 Phase 3 派生），以及 technical-director（若在上文派生）
- 如果有阶段检查覆盖，将其作为 `Stage override:` 行带入 go/no-go 记录
- 评估任何未决问题——它们是阻塞性的，还是可以发布？
- 做出 go/no-go 决定
- 输出：带理由的发布决策

**如果 producer 宣布 NO-GO：**
- 立即暴露该决定：“PRODUCER: NO-GO — [理由，例如 Phase 3 发现 S1 缺陷]。”
- 使用 `AskUserQuestion` 提供选项：
  - 修复阻塞项并重新运行受影响的阶段
  - 把发布推迟到更晚的日期
  - 以书面理由覆盖 NO-GO（用户必须提供书面说明）
- **完全跳过 Phase 6**——不要打标签、部署到预发布环境、部署到生产，或派生 community-manager。
- 产出部分报告，总结 Phase 1–5、跳过了什么（Phase 6）以及为什么。
- 判定：**BLOCKED**——发布未部署。

用户选择“以书面理由覆盖 NO-GO”后：
- 询问（纯文本，不用组件）：“请描述覆盖 NO-GO 判定的理由。它将嵌入发布记录。”
- 等待用户写出理由。
- 在 Phase 6 之前把理由文本嵌入部分批准记录：追加一个“⚠️ Override Justification: [用户的文本]”字段。
- 只有之后才进入 Phase 6。

### Phase 6: 部署（如果 GO）

**无论 `modes.automation` 为何——包括 `autonomous` 模式——本阶段
始终需要用户明确批准。** 生产部署不可逆且高风险；
它**不**属于可配置的 `automation_always_ask` 类别，因此本技能
无条件守护它。在打标签或部署之前，使用 `AskUserQuestion`：
- 提示：“Producer 判定为 GO。执行 Phase 6——打标签、部署到预发布环境、
  部署到生产环境？”
- 选项：`[A] Yes, deploy` / `[B] Staging only — hold production` / `[C] Stop here`

只有在明确批准后，才委派给 **release-manager** + **devops-engineer**：
- 在版本控制中为发布打标签
- 定稿 Polish 阶段起草的变更日志（`/changelog`），加入自闸门以来的变更
- 部署到预发布环境进行最终冒烟测试
- 部署到生产环境（仅当用户在上文批准了生产）
- 人工团队动作：发布后 48 小时内监控仪表盘和错误率。在 48 小时节点用 `/retrospective` 安排一次后续回顾。

在部署的同时，委派给 **release-manager**：
- 用 `/patch-notes [version]` 定稿 Polish 阶段起草的补丁说明——release-manager 携带该技能及其 `git log` 步骤所需的 Bash 访问权限；`community-manager` 两者都没有

然后把那些补丁说明交给 **community-manager**：
- 准备发布公告（商店页面更新、社交媒体、社区帖）
- 如果有任何 S3+ 问题随包发布，起草已知问题帖
- 输出：所有面向玩家的发布沟通内容，可在部署确认后发布

### Phase 7: 发布后
- **release-manager**：生成发布报告（发布了什么、推迟了什么、指标）
- **producer**：更新里程碑跟踪，向利益相关方沟通
- **qa-lead**：监控传入的缺陷报告，关注回归问题
- **community-manager**：发布所有面向玩家的沟通内容，监控社区情绪
- **analytics-engineer**：确认在线仪表盘健康；如果有任何关键事件缺失则告警
- 保持 Phase 6 的 48 小时监控窗口：发布后 48 小时内观察缺陷、仪表盘和社区情绪（release-manager 自己的观察持续到其 72 小时报告）
- 如果发生问题，安排发布后回顾

## 错误恢复协议

**首先，验证产出物。** 如果返回契约指定了路径，在把该阶段视为完成之前
检查该路径是否存在——**一个不在磁盘上的命名产出物就是失败的阶段，无论回复读起来多么流畅。**
代理可能耗掉整个阶段，什么都没写却返回一段看似合理的开场白，
这既不是 BLOCKED，也不是错误，也不是“无法完成”，因此下面的触发器
永远不会触发。点名未满足的契约来恢复它；上下文通常还在。

如果任何派生的代理返回 BLOCKED、报错或无法完成：**立即暴露它，不要越过它所阻塞的依赖继续推进，并且始终产出部分报告。** 完整流程：`.claude/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（用户故事未找到、GDD 缺失）→ 重定向到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围太大 → 通过 `/create-stories` 拆成两个用户故事
- ADR 与用户故事之间的指令冲突 → 暴露冲突，不要猜测

## 文件写入协议

所有文件写入（发布检查清单、变更日志、补丁说明、部署脚本）都
委派给子代理和子技能。两者遵循**不同的**规则，而这一
区别在这里比流水线中任何其他地方都更重要：

- **通过 `Agent` 派生的子代理**遵循上文“为什么这并不违反协作协议”中记录的
  **有界例外**——路径是你指定的，产出物是 `production/`、`docs/` 或 `tests/` 下的新东西，且该阶段
  受 `AskUserQuestion` 闸门约束。在这些边界内，子代理**不会**每次写入都提示；
  在边界之外，它必须询问。
- **子技能**不是子代理，例外不适用于它们。它们
  遵循正常的协作协议，并在写入前询问。

本编排器不直接写文件。此处没有任何内容授权
面向外部或不可逆的动作——标签、推送、构建和商店页面变更
无论适用上述哪条规则都需要明确确认。

## 输出

一份总结报告，涵盖：发布版本、范围、质量闸门结果、go/no-go 决策、部署状态和监控计划。

判定：**COMPLETE**——发布已执行并部署。
判定：**BLOCKED**——发布已停止；阶段检查阻止了它、go/no-go 为 NO，或有硬性阻塞项未解决。

## 后续步骤

- 发布后监控仪表盘 48 小时。
- 如果发布期间发生重大问题，运行 `/retrospective`。
- 除非阶段检查被覆盖，`project.stage` 读取为 `Release`：`/gate-check release` 是 Polish → Release 的就绪闸门，在本技能之前运行。覆盖之后阶段仍读取其原值。只有 `/gate-check` 会改变 `project.stage`（在 PASS，或用户接受了其风险的 CONCERNS 时），因此本技能绝不写入它或 `production/stage.txt`。`Release` 是 `project.stage` 枚举中的终端阶段——不存在发布后阶段值。在发布报告中记录长线运营/发布后状态，而不是记录到 `project.stage`。
