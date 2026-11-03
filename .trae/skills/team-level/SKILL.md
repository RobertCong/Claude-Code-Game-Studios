---
name: team-level
description: "编排关卡团队 — level-designer、narrative-director、world-builder、art-director、systems-designer、qa-tester — 完成完整区域创建。"
argument-hint: "[level name or area to design] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate, Bash(bash "*/.claude/skills/team-level/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

# 关卡团队

如果未提供参数，输出用法说明并在不派出任何 agent、不读取任何设计文件的情况下退出：
> 用法：`/team-level [level name or area to design] [--review full|lean|solo]` — 指定要设计的关卡或区域（例如 `forest temple`、`tutorial village`、`final boss arena`）。此处不要使用 `AskUserQuestion`；直接输出说明。

当本技能被调用时：

**决策点：** 在每个步骤转换处，使用 `AskUserQuestion` 将
子代理的提案作为可选选项呈现给用户。在对话中写下 agent 的
完整分析，然后用简洁的标签捕获决策。
在 `collaborative` 模式下，用户必须批准后才能进入下一步。
在 `guided` 模式下，流水线自动推进，除非某步骤为 BLOCKED；
在 `autonomous` 模式下，流水线端到端运行，并通过
`log_decision` 记录每个步骤的结果。`automation_always_ask` 类别中的决策
（`is_always_ask_category` 辅助函数）无论模式如何都会始终提示。参见
`.claude/docs/automation-modes.md`。

## Phase 0: 解析配置

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size`

已在上面解析——按原样使用；`--review` 覆盖 `review_mode`。无输出块时 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

`review_mode` 设定总监闸门深度，而本流水线没有总监闸门：
在任何 `review_mode` 下，下面的阶段都不会派出 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义在下面的 `team.size` 下），
在这些决策点上工作的 agent 是团队成员，而不是总监闸门。

`automation` 驱动上面的决策点说明。关于每种模式如何改变流水线行为，
参见上面的决策点说明和 `.claude/docs/automation-modes.md`。

**`team.size`**：哪些 agent 处于活动状态（与 review_mode 闸门深度和 workflow 文档正交）。
- **`individual`**（默认）：仅 `level-designer`。其他 agent 通过 level-designer 咨询，不单独派出。
- **`small`**：+ `systems-designer` + `art-director` + `qa-tester`。
- **`studio`**：+ `narrative-director` + `world-builder` + `accessibility-specialist`（如下文所述的完整流水线）。
在 `individual` 下需要非核心 agent 时，通过最近的活动核心 agent 路由，并附加信息性说明。**“阶段闸门”指任何以本流水线自身列出的 `AskUserQuestion` 决策点结束的阶段**——上述决策点中的转换，或下面流水线中写入的 **Gate** 步骤——**无论 `automation` 模式如何。** `guided` 和 `autonomous` 改变的是闸门如何通过（自动推进，或用 `log_decision` 记录），而不是它是否是闸门，因此下面的有界例外条件（3）在任何模式下都对其成立。仅限“阶段闸门”的 agent 只在这些点被派出，不在其他点派出。此活动集作用域适用于下面整个流水线：任何点名活动集之外 agent 的阶段，都通过最近的核心 agent 路由，而不是派出该 agent。

**在 Step 1 之前宣布活动集——绝不要让收缩悄无声息。**
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

1. **读取参数**以获取目标关卡或区域（例如 `tutorial`、
   `forest dungeon`、`hub town`、`final boss arena`）。

2. **收集上下文**（按章节阅读每份设计文档：用 Grep 工具以 `^#` 模式
   在 content 模式下找到所需标题，并用 offset 和 limit 读取
   相应范围）：
   - 如果存在，读取 `design/gdd/game-concept.md` 中的游戏概念——或
     `design/game-brief.md`，即在 `rigor: minimal` 下替代它的一页简报
   - 读取 `design/gdd/game-pillars.md` 中的游戏支柱
   - 读取 `design/levels/` 中现有的关卡文档
   - 读取 `design/narrative/` 中相关的叙事文档
   - 读取该区域所属地区/阵营的世界构建文档

## 如何委派

使用 `Agent` 工具将每个团队成员作为子代理派出：
- `subagent_type: narrative-director` — 叙事目的、角色、情感弧线
- `subagent_type: world-builder` — 世界观上下文、环境叙事、世界规则
- `subagent_type: level-designer` — 空间布局、节奏、遭遇、导航
- `subagent_type: systems-designer` — 敌人组合、战利品表、难度平衡性
- `subagent_type: art-director` — 视觉主题、色彩调色板、光照、资源需求
- `subagent_type: accessibility-specialist` — 导航清晰度、色盲安全性、认知负荷
- `subagent_type: qa-tester` — 测试用例、边界测试、试玩测试清单

**给每个 agent 写简报——不要倾倒上下文。** 只读取一次共享输入，并以内联方式传递提炼后的简报：每个 agent 实际需要的那几行，绝不要为你已经读过的文档传文件路径（拿到路径的 agent 会重新读取整个文件）。只为你尚未读过且只有该 agent 需要的文档传递路径。

**每个 agent 提示都以返回契约结尾：**“Write your full output to `[path]` ——该指定路径即为你在下文有界例外下的写入授权，因此无需单独的审批提示即可写入。只返回（1）写入的路径，（2）不超过 5 条要点的决策摘要，（3）任何 BLOCKED/CONCERNS 项，每项一行。不要复述你读过的文档。”没有它，agent 会把它读过的一切都返回本会话中。

**用真实路径替换 `[path]`。** 工作产出物放在
`production/levels/[level-name]/` 下，按下面“保存到”步骤的 slug 规则命名。
每个 agent 一个文件，因此并行步骤永远不会共享同一个文件：

| 步骤 / agent | 写入到 |
|---|---|
| 1 narrative-director | `production/levels/[level-name]/narrative.md` |
| 1 world-builder | `production/levels/[level-name]/lore.md` |
| 1 art-director | `production/levels/[level-name]/visual-direction.md` |
| 2 level-designer | `production/levels/[level-name]/layout.md` |
| 3 systems-designer | `production/levels/[level-name]/systems.md` |
| 4 art-director | `production/levels/[level-name]/production-concepts.md` |
| 4 accessibility-specialist | `production/levels/[level-name]/accessibility.md` |
| 5 qa-tester | `production/qa/test-cases/[level-name]-cases.md` — 测试用例、边界情况、试玩测试清单、验收标准 |

这些是工作草稿；持久记录是你根据它们编译的关卡设计文档
（`design/levels/[level-name].md`）。

> **为什么这不违反协作协议。** `CLAUDE.md` 要求 agent 在 Write/Edit 之前询问“May I write this to [filepath]?”。此处派出的子代理**不询问**即可写入，这是刻意的有界例外，而不是疏忽——与 `consistency-check` 追加到 `active.md` 时已做出的相同决定。该例外仅在以下三项全部成立时适用：（1）路径是**你**在提示中命名的，因此用户在批准该阶段时已批准目标；（2）它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；（3）产生它的阶段本身在流水线推进前由 `AskUserQuestion` 把关。超出这三项，agent 必须询问。**不要通过按子代理逐个询问来“修复”这一点**——每个阶段每个 agent 一个提示会让编排器无法使用，这正是该例外存在的原因。

3. **编排关卡设计团队**，按顺序：

### Step 1: 叙事 + 视觉方向（narrative-director + world-builder + art-director，并行）

同时派出全部三个 agent——在等待任何结果之前发出全部三个 `Agent` 调用。

派出 `narrative-director` agent 以：
- 定义此区域的叙事目的（这里发生哪些故事节拍？）
- 识别关键角色、对话触发器和世界观元素
- 指定情感弧线（玩家进入时、进行中、离开时分别应有怎样的感受？）

派出 `world-builder` agent 以：
- 为该区域提供世界观上下文（历史、阵营存在、生态）
- 定义环境叙事机会
- 指定任何会影响此区域玩法的世界规则

派出 `art-director` agent 以：
- 确立此区域的视觉主题目标——这些是布局的输入，而不是布局的输出
- 定义此区域的色温和光照氛围（与相邻区域有何不同？）
- 指定形状语言方向（棱角分明的堡垒？有机的洞穴？衰败的宏伟？）
- 命名将引导玩家定位的主要视觉地标
- 如果存在，读取 `design/art/art-bible.md`——将所有方向锚定在既定美术圣经中。按章节阅读：用 Grep 工具（pattern `^#`，content 模式）找到所需标题，再用 offset 和 limit 读取相应范围。

**Step 1 中 art-director 的视觉目标必须作为明确约束传递给 Step 2 的 level-designer。** 布局决策发生在视觉方向之内，而不是之前。

**Gate**：使用 `AskUserQuestion` 呈现全部三个 Step 1 输出（叙事简报、世界观基础、视觉方向目标），并在进入 Step 2 前确认。

### Step 2: 布局与遭遇设计（level-designer）
以完整的 Step 1 输出作为上下文派出 `level-designer` agent：
- 叙事简报（来自 narrative-director）
- 世界观基础（来自 world-builder）
- **视觉方向目标（来自 art-director）**——布局必须在这些目标之内运作，而不是与它们矛盾

level-designer 应：
- 设计空间布局（关键路径、可选路径、秘密）——确保主要路线与 Step 1 的视觉地标目标一致
- 定义节奏曲线（紧张峰值、休息区、探索区）——与 narrative-director 的情感弧线协调
- 按难度递进放置遭遇
- 设计环境谜题或导航挑战
- 定义用于寻路的路标点和地标——这些必须与 art-director 指定的视觉地标匹配
- 指定入口/出口点以及与相邻区域的连接

**相邻区域依赖检查**：布局产出后，在 `design/levels/` 中检查 level-designer 引用的每个相邻区域。如果任何被引用区域的 `.md` 文件不存在，暴露该缺口：
> “关卡将 [area-name] 引用为相邻区域，但 `design/levels/[area-name].md` 不存在。”

使用 `AskUserQuestion` 并给出选项：
- (a) 以占位引用继续——在关卡文档中将该连接标记为 UNRESOLVED，并在摘要报告的跨关卡开放依赖章节中列出
- (b) 暂停并先运行 `/team-level [area-name]` 以建立该区域

不要为缺失的相邻区域编造内容。

**Gate**：使用 `AskUserQuestion` 呈现 Step 2 布局（包括任何未解决的相邻区域依赖），并在进入 Step 3 前确认。

### Step 3: 系统集成（systems-designer）
派出 `systems-designer` agent 以：
- 指定敌人组合和遭遇公式
- 定义战利品表和奖励放置
- 相对于预期玩家等级/装备平衡难度
- 设计任何区域特定的机制或环境危险
- 指定资源分布（生命拾取物、存档点、商店）

**Gate**：使用 `AskUserQuestion` 呈现 Step 3 输出，并在进入 Step 4 前确认。

### Step 4: 制作概念 + 无障碍（art-director + accessibility-specialist，并行）

**注意**：art-director 的方向性环节（视觉主题、色彩目标、氛围）发生在 Step 1。本环节是位置特定的制作概念——在最终布局给定的情况下，每个具体空间看起来是什么样？

以 Step 2 的最终布局派出 `art-director` agent：
- 为关键空间（入口、关键遭遇区、地标、出口）产出位置特定的概念规格
- 指定哪些美术资源为此区域独有，哪些来自全局池共享
- 为每个关键空间定义视线和光照设置（这些现在由布局决定，而不是方向性的）
- 指定此区域布局特有的 VFX 需求（天气体积、粒子、大气效果）
- 标记任何布局与 Step 1 目标产生视觉方向冲突的位置——将这些作为制作风险暴露

并行派出 `accessibility-specialist` agent 以：
- 审查关卡布局的导航清晰度（玩家能否在不只依赖颜色的情况下定位自己？）
- 检查关键路径路标是否在颜色之外还使用形状/图标/声音线索
- 审查任何谜题机制的认知负荷——标记任何需要同时保持超过 3 个状态的内容
- 检查关键玩法区域对色盲玩家是否有足够的对比度
- 输出：带严重程度（BLOCKING / RECOMMENDED / NICE TO HAVE）的无障碍关注项列表

在继续之前等待两个 agent 都返回。

**Gate**：使用 `AskUserQuestion` 呈现两个 Step 4 结果。如果 accessibility-specialist 返回任何 BLOCKING 关注项，突出显示它们并提供：
- (a) 返回 level-designer 和 art-director，在 Step 5 之前重新设计被标记的元素
- (b) 将其记录为已知的无障碍缺口，并在最终报告中明确记录该关注项后继续到 Step 5

在用户确认任何 BLOCKING 无障碍关注项之前，不要继续到 Step 5。

### Step 5: QA 规划（qa-tester）
派出 `qa-tester` agent 以：
- 为关键路径编写测试用例
- 识别边界和边缘情况（流程中断、软锁）
- 为该区域创建试玩测试清单
- 定义关卡完成的验收标准

4. **编译关卡设计文档**，将所有团队输出合并为
   关卡设计模板格式。

编排器已经持有每个子代理的输出——**自行编译文档；
不要重新派出 `level-designer` 并原样重发所有输出。** 第二次派出会支付
一个新 agent 的开销，加上对编排器已持有的上下文的完整重传，
只为移动它已经持有的文本。编译为关卡设计模板格式后，
直接通过 `AskUserQuestion` 询问用户：“我可以把编译后的关卡设计写入
`design/levels/[level-name].md` 吗？”获批后写入。

5. **保存到** `design/levels/[level-name].md`，在获得该批准之后。
   `[level-name]` 是作为 slug 的参数——小写，空格 → 连字符
   （`forest dungeon` → `forest-dungeon.md`）——相邻区域检查中的 `[area-name]`
   也按同样方式 slug 化。

6. **输出摘要**，包含：区域概述、遭遇数量、估算资源
   列表、叙事节拍、任何跨团队依赖或开放问题、开放的
   跨关卡依赖（被引用但尚未设计的相邻区域，每项
   标记为 UNRESOLVED），以及带解决状态的无障碍关注项。

## 文件写入协议

每个 agent 的产出物（叙事文档、测试清单）由产生它们的
子代理写入，遵循上文“为什么这不违反协作协议”中记录的**有界例外**——
路径是你命名的，产出物是 `production/`、`docs/` 或 `tests/` 下的新文件，
且该阶段由 `AskUserQuestion` 把关。子代理在这些边界内**不会**逐次
写入提示；超出边界则必须询问。**唯一的例外是最终
编译的关卡设计文档**：编排器已经持有每个输入，因此它在自己的
“May I write …?”提示（Step 4）之后自行编译并写入该文件——
仅仅为了写入编排器已经持有的文本而重新派出 agent 纯属额外开销。

结论（Verdict）：**COMPLETE** — 关卡设计文档已产出，所有团队输出已编译。
结论（Verdict）：**BLOCKED** — 一个或多个 agent 阻塞，或有 agent 被跳过（`.claude/docs/error-recovery-protocol.md` 第 5 步）；已产生部分报告并列出未解决项。

## 后续步骤

- 运行 `/design-review design/levels/[level-name].md` 以验证完成的关卡设计文档。
- 设计获批后运行 `/dev-story` 以实现关卡内容。
- 运行 `/qa-plan` 以为此关卡生成 QA 测试计划。

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
