---
name: map-systems
description: "将概念拆解为各个系统、映射依赖关系、确定设计顺序优先级、创建系统索引。"
argument-hint: "[next | system-name] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density,project.stage`

上一步命令的输出已解析 — 直接使用；`--review` 覆盖 `review_mode`。若无解析块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

# 映射系统


当本技能被调用时：

## 解析参数

两种模式：

- **无参数**：`/map-systems` — 运行完整的拆解工作流（Phase 1-5），
  以创建或更新系统索引。
- **`next`**：`/map-systems next` — 从索引中选取优先级最高且尚未设计的系统，
  并交接给 `/design-system`（Phase 6）。


完整检查模式见 `.trae/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md` — 被派生的代理读取自己的闸门文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅重大决策 · 自主模式记录并继续；
`automation_always_ask` 类别始终提示）。在协作模式下，系统列表、
依赖、优先级和写入批准是分开的问题：
每个问题都等待其回答后，下一步才运行。

**`docs.density`** — 它控制每个小节的*深度*，而 `workflow`
控制存在哪些小节。`modes.rigor` 会同时设置两者；单独设置
`docs.density` 可仅调整深度：`terse`（默认，通过 `rigor: minimal`）= 一行式系统描述；
`balanced` = 每个系统一段简短文字 + 依赖说明（`rigor: standard`）；
`thorough` = 完整的逐系统理由说明 + 关系分析。将其应用于
你撰写的每个小节。

> **逐系统文字放在哪里。** `templates/systems-index.md` 的系统
> 枚举是一个固定列的表格，没有描述列，因此在
> `balanced` 和 `thorough` 下，这些文字应放在 `## Overview` — 在 `balanced` 下
> 每个系统一段简短文字，在 `thorough` 下再加关系分析 —
> 以及 `## Dependency Map` 的分层说明中。**不要给
> 枚举表增加列** — 它是
> `.trae/docs/templates/systems-index.md` 中的固定契约，其使用方
> （`/design-system` §6 和 §7、`/create-epics`）是针对它
> 定义的列编写的。加宽它是模式变更，不是格式选择。
>
> **使用方实际如何读取它。** 没有任何东西按位置解析此表。
> 提到 `systems-index.md` 的两个脚本
> （`gdd-structure-check.sh:51`、`review-scope.sh:40`）在 `case` 语句中**按文件名**
> 匹配它，完全不解析任何列；两个技能按名称
> 以 **`Category` 列**为键（`design-system:229`、`:780`）。因此 `Category` 是
> 绝不能重命名或删除的列，而该表保持为固定
> 契约，因为每个使用方都是针对模板定义的列集合
> 编写的。
> 在 `terse` 下，该表加上一段 `## Overview` 就是全部输出。

**`workflow`**（见 `.trae/docs/workflow-modes.md`）：
- `full` / `standard` — `/design-system` 之前的必需项（必须先映射系统，
  才能撰写逐系统 GDD）。
- `minimal` — 非必需（游戏简报取代系统索引）。仍可
  自愿运行。

---

## Phase 1: 阅读概念（必需上下文）

阅读游戏概念和任何现有设计工作。这为系统拆解提供原材料。
按小节阅读每份文档：用 Grep 工具（模式 `^#`，内容模式）
找到需要的标题，然后用 offset 和 limit 阅读那些范围。

**必需：**
- 阅读 `design/gdd/game-concept.md`（在 `minimal` 下，改为阅读
  `design/game-brief.md`）— **若两者都未找到，以清晰的提示失败**：
  > “未找到游戏概念。请先运行 `/brainstorm` 创建一个，然后回来
  > 将其拆解为系统。”

**可选（存在则阅读）：**
- 阅读 `design/gdd/game-pillars.md` — 支柱约束优先级和范围
- 阅读 `design/gdd/systems-index.md` — 若存在，从中断处**继续**
  （更新，而不是从头重建）
- Glob `design/gdd/*.md` — 检查已存在哪些系统 GDD

**如果系统索引已存在：**
- 读取它并向用户呈现当前状态
- 使用 `AskUserQuestion` 询问：
  “系统索引已存在，包含 [N] 个系统（[M] 个已设计，[K] 个未开始）。
  你希望怎么做？”
  - 选项：“用新系统更新索引”、“设计下一个未设计的系统”、
    “评审并修订优先级”

---

## Phase 2: 系统枚举（协作）

提取并识别游戏需要的所有系统。这是本技能的创意核心 —
它需要人类判断，因为概念文档很少明确枚举每个
系统。

### Step 2a: 提取显式系统

扫描游戏概念中直接提到的系统和机制：
- 核心机制小节（最明确）
- 核心循环小节（暗示哪些系统驱动每个循环层级）
- 技术考量小节（网络、程序化生成等）
- MVP 定义小节（必需功能 = 必需系统）

### Step 2b: 识别隐式系统

对每个显式系统，识别它所暗示的**隐藏系统**。游戏需要的系统
总是比概念文档提到的更多。使用此推断模式：

- “背包”暗示：物品数据库、装备槽位、重量/容量规则、
  背包 UI、存档/读档的物品序列化
- “战斗”暗示：伤害计算、生命值系统、命中检测、状态效果、
  敌人 AI、战斗 UI（生命条、伤害数字）、死亡/重生
- “开放世界”暗示：流送/分块、LOD 系统、快速旅行、地图/小地图、
  兴趣点追踪、世界状态持久化
- “多人”暗示：网络层、大厅/匹配、状态同步、
  反作弊、网络 UI（延迟、玩家列表）
- “制作”暗示：配方数据库、材料采集、制作 UI、
  成功/失败机制、配方发现/学习
- “对话”暗示：对话树系统、对话 UI、选择追踪、NPC
  状态管理、本地化钩子
- “成长”暗示：XP 系统、升级机制、技能树、解锁
  追踪、成长 UI、成长存档数据

在对话文本中解释为什么需要每个隐式系统（附示例）。

### Step 2c: 用户评审

按类别组织呈现枚举。对每个系统，显示：
- 名称
- 类别
- 简短描述（1 句话）
- 它是显式的（来自概念）还是隐式的（推断的）

然后使用 `AskUserQuestion` 捕获反馈：
- “这个列表是否缺少系统？”
- “其中是否有任何系统应合并或拆分？”
- “列表中是否有这个游戏不需要的系统？”

**在 `collaborative` 下** — 反复迭代，直到用户批准枚举。
**在 `guided` 下** — 询问一次，应用回答，然后继续；不要循环。
**在 `autonomous` 下** — 不要询问。通过 `log_decision` 记录枚举及其推断出的系统，
然后继续。

---

## Phase 3: 依赖映射（协作）

对每个系统，确定它依赖什么。如果系统在没有另一个系统先存在的情况下
无法运行，那么它“依赖”那个系统。

### Step 3a: 映射依赖

对每个系统，列出其依赖。使用这些依赖启发式规则：
- **输入/输出依赖**：系统 A 产出系统 B 需要的数据
- **结构依赖**：系统 A 提供系统 B 接入的框架
- **UI 依赖**：每个玩法系统都有对应的 UI 系统
  依赖它（但 UI 在玩法系统之后设计）

### Step 3b: 按依赖顺序排序

将系统排列成分层：
1. **基础层**：零依赖的系统（最先设计和构建）
2. **核心层**：仅依赖基础层系统的系统
3. **功能层**：依赖核心层系统的系统
4. **表现层**：包裹玩法系统的 UI 和反馈系统
5. **打磨层**：元系统、教程、分析、无障碍

### Step 3c: 检测循环依赖

检查依赖图中的循环。如果发现：
- 向用户高亮它们
- 提出解决方案（接口抽象、同步设计、通过在两个系统之间
  定义契约来打破循环）

### Step 3d: 呈现给用户

以分层列表显示依赖图。高亮：
- 任何循环依赖
- 任何“瓶颈”系统（许多其他系统依赖它们 — 这些是高风险）
- 任何没有依赖方的系统（叶节点 — 风险较低，可以较晚设计）

使用 `AskUserQuestion` 询问：“这个依赖排序看起来正确吗？有没有
我遗漏的依赖，或应该移除的依赖？”

**评审模式检查** — 在派发 TD-SYSTEM-BOUNDARY 之前应用：
- `solo` → 跳过。注明：“TD-SYSTEM-BOUNDARY 已跳过 — Solo 模式。” 继续优先级分配。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“TD-SYSTEM-BOUNDARY 已跳过 — Lean 模式。” 继续优先级分配。
- `full` → 照常派发。

**依赖映射获得批准后，在进入优先级分配之前，通过 `Agent` 使用闸门 TD-SYSTEM-BOUNDARY（`.trae/docs/director-gates/td-system-boundary.md`）派发 `technical-director`。**

传递：依赖图（每个系统 → 它依赖什么）、分层分配、瓶颈系统，以及任何循环依赖及其提议的解决方案。

呈现评估结果。如果为 REJECT，与用户修订系统边界，展示修订后的依赖图，
然后才进入优先级分配。如果为 CONCERNS，在系统索引中内联注明并继续。如果为 NOT ASSESSED [missing input]，它不是 APPROVE：指出缺失了什么，然后补充并重新运行闸门，或在索引草稿中注明 `TD-SYSTEM-BOUNDARY: NOT ASSESSED — [input]` 后继续。

---

## Phase 4: 优先级分配（协作）

根据每个系统需要用于哪个里程碑，将其分配到优先级层级。

### Step 4a: 基于概念自动分配

使用这些启发式规则进行初始分配：
- **MVP**：概念中“MVP 必需”小节提到的系统，加上它们的
  基础层依赖
- **垂直切片**：在一个区域内提供完整体验所需的系统
- **Alpha**：所有剩余玩法系统
- **完整愿景**：打磨、元系统和锦上添花的系统

### Step 4b: 用户评审

以表格呈现优先级分配。对每个层级，解释系统
为何被放在那里。

使用 `AskUserQuestion` 询问：“这些优先级分配是否符合你的愿景？
哪些系统应提高或降低优先级？”

在对话中解释理由：“我将 [system] 放在 MVP，因为核心循环
需要它 — 没有 [system]，30 秒循环无法运行。”

**如何表述理由** — 这决定你*说什么*，不是你
写入的列。两个表格都没有 `Why` 列：系统枚举表是
`# / Name / Category / Priority / Status / Design Doc / Depends On`，推荐设计顺序是
`Order / System / Priority / Layer / Agent(s) /
Est. Effort`。理由存在于上方对话中，以及对于用户在
会话结束后仍应看到的任何内容，存在于索引的 `## Overview`
段落中。不要为此发明一个列。

将技术必要性与玩家体验理由混合起来。纯技术性
论证 — “伤害系统需要伤害数学” — 当系统直接塑造玩家感受时，
其本身并不充分。好的理由会同时指出两者，并引用它所服务的支柱：
- “核心循环所需 — 没有它，玩家的主要选择就没有
  后果（支柱 [N]：[pillar name]）”
- “这是 [system] 的身份得以确立之处 — 这里的属性定义
  正是让它与 [the sibling system] 感觉不同的原因”
- “后续每一项经济决策的基础 — 玩家必须先理解
  成本，建立在它之上的任何选择才有意义”

> **用*本项目*的内容填充方括号。** 方括号槽位不是
> 装饰。从另一个游戏的示例中复制的理由会带入那个
> 游戏的词汇，而不是本项目的。

**评审模式检查** — 在派发 PR-SCOPE 之前应用：
- `solo` → 跳过。注明：“PR-SCOPE 已跳过 — Solo 模式。” 继续 Step 4c。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“PR-SCOPE 已跳过 — Lean 模式。” 继续 Step 4c。
- `full` → 照常派发。

**优先级获得批准后，在写入索引之前，通过 `Agent` 使用闸门 PR-SCOPE（`.trae/docs/director-gates/pr-scope.md`）派发 `producer`。**

从索引传递闸门字段：完整愿景范围（索引中的每个系统）、MVP 定义（MVP 层级的系统）、范围层级（每个里程碑层级的系统数量，附估算实现体量 — 系统数量 × 平均复杂度）、所述项目时间线作为时间线估算，以及团队规模。

呈现评估结果。PR-SCOPE 回答 REALISTIC / OPTIMISTIC / UNREALISTIC。
如果为 UNREALISTIC，提议在写入索引之前修订优先级层级
分配。如果为 OPTIMISTIC，展示制作人建议的调整，并询问是否在写入前
将它们应用到层级；如果用户拒绝，记录它们并
继续。如果为 NOT ASSESSED [missing input] — 通常是团队规模或时间线 —
它不是 REALISTIC：指出缺失了什么，然后补充并重新运行闸门，或在索引草稿中
注明 `PR-SCOPE: NOT ASSESSED — [input]` 后继续。

### Step 4c: 确定设计顺序

结合依赖排序 + 优先级层级，得出最终设计顺序：
1. MVP 基础层系统优先
2. MVP 核心层系统第二
3. MVP 功能层系统第三
4. 垂直切片的 Foundation/Core 系统
5. ……以此类推

这是团队撰写 GDD 应遵循的顺序。

---

## Phase 5: 创建系统索引（写入）

### Step 5a: 起草文档

使用 `.trae/docs/templates/systems-index.md` 中的模板，用 Phase 2-4 的所有数据
填充系统索引：
- 填充枚举表
- 填充依赖图
- 填充推荐设计顺序
- 填充高风险系统
- 填充进度追踪器（所有系统初始为“Not Started”，除非 GDD 已存在）

### Step 5b: 批准

呈现文档摘要：
- 按类别统计的系统总数
- MVP 系统数量
- 设计顺序中的前 3 个系统
- 任何高风险项

**在 `automation: collaborative` 下** — 询问：“我可以将系统索引写入
`design/gdd/systems-index.md` 吗？” 等待批准。仅
在回答“是”后写入文件。

**在 `automation: guided` 下** — **新**索引会收到同样的“我可以写入……吗？”
问题，因为 `.trae/docs/automation-modes.md` 规定 `guided` 对新文件询问
“我可以写入吗？”。当索引已存在时，呈现上方摘要，
说明目标位置（`design/gdd/systems-index.md`），并在不等待
明确“是”的情况下写入更新。之后说明你写了什么。

**评审模式检查** — 在派发 CD-SYSTEMS 之前应用：
- `solo` → 跳过。注明：“CD-SYSTEMS 已跳过 — Solo 模式。” 继续 Step 5c。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“CD-SYSTEMS 已跳过 — Lean 模式。” 继续 Step 5c。
- `full` → 照常派发。

**系统索引写入后，通过 `Agent` 使用闸门 CD-SYSTEMS（`.trae/docs/director-gates/cd-systems.md`）派发 `creative-director`。**

传递：系统索引路径；游戏支柱和核心幻想 — 来自 `design/gdd/game-concept.md`，或在 `minimal` 下来自 `design/game-brief.md` 的提案和“他们感受如何”一行（该文件没有支柱）；每个层级（MVP / Vertical Slice / Alpha / Full Vision）的优先级分配；以及依赖图中的高风险和瓶颈系统。

呈现评估结果。如果为 REJECT，在 GDD 撰写开始前与用户修订系统集合。如果为 CONCERNS，展示它们并使用 `AskUserQuestion`：`Revise the system set` / `Accept — record them in the index` / `Discuss further`。选择 *Revise* 时，与用户返工受影响的系统，并在重写索引前再次询问。选择 *Accept* 时 — 该选项已命名了编辑，因此选择它就是请求 — 在系统索引中将其记录为一条 `> **Creative Director Note**`，
放置在 **`## Priority Tiers` 表格正下方**，注明每条
关注项适用的层级 — 例如 `> **Creative Director Note** (MVP): …`。
`templates/systems-index.md` 有一个 Priority Tiers *定义表*，而不是
每个层级一个小节，因此没有“层级小节顶部”可写入 — 不要
引导写入者去那里。如果为 NOT ASSESSED [missing input]，它不是 APPROVE
（`.trae/docs/director-gates.md`）：指出缺失了什么，然后补充并
重新运行闸门，或在同一位置记录 `> **Creative Director Note**:
CD-SYSTEMS NOT ASSESSED — [input]` 之前先询问。

### Step 5c: 更新会话状态

写入之后，如果 `production/session-state/active.md` 不存在则创建它，然后用以下内容更新：
- 任务：系统拆解
- 状态：系统索引已创建
- 文件：design/gdd/systems-index.md
- 下一步：设计各个系统 GDD

**Verdict: COMPLETE** — 系统索引已写入 `design/gdd/systems-index.md`。
如果用户拒绝：**Verdict: BLOCKED** — 用户未批准写入。

---

## Phase 6: 设计各个系统（交接给 /design-system）

进入此阶段的条件：
- 用户在创建索引后回答“是”要设计系统
- 用户调用 `/map-systems [system-name]`
- 用户调用 `/map-systems next`

### Step 6a: 选择系统

- 如果提供了系统名称，在系统索引中找到它
- 如果使用了 `next`，选取优先级最高且尚未设计的系统（按设计顺序）
- 如果用户刚完成索引，询问：
  “你希望现在开始设计各个系统吗？设计顺序中的第一个系统是
  [name]。还是希望先停在这里，稍后再回来？”

使用 `AskUserQuestion` 询问：“现在开始设计 [system-name]、选择另一个
系统，还是停在这里？”

### Step 6b: 交接给 /design-system

选定系统后，调用 `/design-system [system-name]` 技能。

`/design-system` 技能处理完整的 GDD 撰写流程：
- 从游戏概念、系统索引和依赖 GDD 收集上下文
- 立即创建文件骨架
- 逐一走完全部 8 个必需小节（协作式、增量式）
- 交叉引用现有文档以防止矛盾
- 路由到专家代理获取领域专长
- 每个小节一经批准即写入文件
- 完成时运行 `/design-review`
- 更新系统索引

**不要在此重复 /design-system 工作流。** 本技能拥有系统
*索引*；`/design-system` 拥有各个系统的 *GDD*。

### Step 6c: 循环或停止

`/design-system` 完成后，使用 `AskUserQuestion`：
- “继续到下一个系统（[next system name]）？”
- “选择另一个系统？”
- “本次会话到此为止？”

如果继续，返回 Step 6a。

---

## Phase 7: 提出后续步骤

系统索引创建后（或设计了一些系统后），使用 `AskUserQuestion` 呈现后续操作：

- “系统索引已写入。你希望接下来做什么？”
  - [A] 开始设计 GDD — 运行 `/design-system [first-system-in-order]`
  - [B] 运行 `/gate-check systems-design` — Concept → Systems Design 闸门；仅在 `project.stage` 仍为 Concept 时提供
  - [C] 运行 `/gate-check technical-setup` — Systems Design → Technical Setup 闸门，一旦 MVP 系统有了 GDD
  - [D] 本次会话到此为止

**值得了解闸门检查选项（[C]）**：`/gate-check technical-setup` 检查 Systems Design 阶段的必需产出物是否存在，并在你投入架构之前运行阶段闸门总监。CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 是本技能自己的闸门 — 它们在 `full` 评审模式下于此处运行，而不是在 `/gate-check` 中。

任何单个 GDD 完成后：
- “在新的会话中运行 `/design-review design/gdd/[system].md` 以验证质量”
- “当所有 MVP GDD 完成后，运行 `/gate-check technical-setup`”

---

## 协作协议

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 和
`autonomous` 模式，见 `.trae/docs/automation-modes.md` — 以下规则
描述协作模式的要求，而非普遍行为。

本技能在每个阶段都遵循协作设计原则：

1. **提问 -> 选项 -> 决策 -> 草稿 -> 批准**，每一步都如此
2. **AskUserQuestion** 在每个决策点（解释 -> 捕获模式）：
   - Phase 2：“缺少系统？合并还是拆分？”
   - Phase 3：“依赖排序正确吗？”
   - Phase 4：“优先级分配符合你的愿景吗？”
   - Phase 5：“我可以写入系统索引吗？”
   - Phase 6：“开始设计、选择另一个，还是停止？”然后交接给 `/design-system`
3. **每次写入文件前**询问“我可以写入 [filepath] 吗？”
4. **增量写入**：每设计完一个系统后更新系统索引
5. **交接**：单个 GDD 的撰写由 `/design-system` 拥有，它处理
   增量式小节写入、交叉引用、设计评审和索引更新
6. **会话状态更新**：在每个里程碑后（索引已创建、系统已设计、优先级已变更）
   写入 `production/session-state/active.md`

**绝不**自动生成完整系统列表并在未经评审的情况下写入。
**绝不**在未经用户确认的情况下开始设计系统。
**始终**展示枚举、依赖和优先级供用户验证。

## 上下文窗口意识

如果上下文在任何时候达到或超过 70%，追加此提示：

> **上下文接近上限（≥70%）。** 系统索引已保存到
> `design/gdd/systems-index.md`。打开新的 Trae 会话以继续
> 设计各个 GDD — 运行 `/map-systems next` 从中断处继续。

---

## 推荐的后续步骤

- 运行 `/design-system [first-system-in-order]` 撰写第一个 GDD（使用索引中的设计顺序）
- 运行 `/map-systems next` 始终自动选取优先级最高且尚未设计的系统
- 每个 GDD 撰写完成后，在新的会话中运行 `/design-review design/gdd/[system].md`
- 当所有 MVP GDD 都已撰写并评审后，运行 `/gate-check technical-setup`