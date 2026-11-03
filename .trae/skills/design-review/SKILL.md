---
name: design-review
description: "评审一份设计文档的完整性、内部一致性、可实施性与设计标准。在交付给程序员之前使用。"
argument-hint: "[path-to-design-doc] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,system_overrides`

上一步命令的输出已解析 — 直接使用；`--review` 覆盖 `review_mode`。`--depth` 是同一标志
在 1.1 之前的名称：将 `--depth <mode>` 完全按
`--review <mode>` 处理，并说明一次它已更名。两者同时给出时，`--review`
优先，`--depth` 被忽略 — 明确说明这一点。若无解析块 → 使用
`.trae/docs/config-resolution.md` 中的默认值。

# 设计评审


## Phase 0: 解析参数


完整检查模式见 `.trae/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md` — 被派生的代理读取自己的闸门文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅重大决策 · 自主模式记录并继续；
`automation_always_ask` 类别始终提示）。

**`workflow`** 用于受评审的 GDD — 如果配置块为 `<system>` 列出了
`system_overrides` 行则使用该行，否则使用项目值。验证范围随级别而定：
- `full` — 验证全部 8 个小节；任何缺失小节都会阻止批准。
- `standard` — 5 个必需小节（Overview、Detailed Rules、Edge Cases、
  Dependencies、Acceptance Criteria）缺失即阻止；Formulas 仅当
  系统定义了数值规则（比率、曲线、阈值、成本 — 类别只是提示，
  不是判断依据）时阻止；Player Fantasy 与
  Tuning Knobs 为建议性（警告，绝不阻止），除非 `workflow_overrides`
  要求它们。
- `minimal` — 不预期存在 GDD；如果存在，则以建议性方式验证 5 个标准
  小节。

解析出的模式控制本次评审的彻底程度：

- **`full`**：完整评审 — 所有阶段 + 专家代理委派（Phase 3b）
- **`lean`**：所有阶段，无专家代理 — 更快，单会话分析
- **`solo`**：仅 Phase 1-4，无委派，无 Phase 5 下一步提示 — 从其他技能内部调用时使用

---

## Phase 1: 加载文档

**先做新鲜度检查 — 对未变更文档重新评审会花费全价，并复现相同的结论。** 运行：

```
Bash: bash .trae/scripts/review-receipts.sh check "design/gdd/reviews/[doc-name]-review-log.md" "[target-doc-path]" "design/registry/entities.yaml" ".trae/skills/design-review/SKILL.md"
```

注册表被纳入检查，是因为本次评审会查阅它获取跨文档事实 — 一份未变更的
GDD 对照**已变更**的注册表评审，可能得出不同结论，因此只有当
**每一行**都显示 `UNCHANGED` 时跳过才安全（从未存在过的注册表不会
出现在输出中，也不会阻止跳过）。本技能文件被纳入，是因为技能变更后
评审方式会不同。检查还会比较日志标记的每个其他文件 — 早前评审读取的
相关 GDD、概念或简报以及叙事文件 — 对不再存在的文件打印 `GONE:`。

然后读取最新条目的 `Review mode:` 行。只有当该次评审的模式与当前解析出的
模式相同或更深（`full` > `lean` > `solo`），且其工作流相同或更深
（`full` > `standard` > `minimal`）时，该次评审才**覆盖**本次运行。
没有该行的条目写于该行存在之前，不覆盖任何内容。

- **全部 `UNCHANGED`** 且日志最新条目带有结论 — 呈现该结论：
  *“本文档与 [date] 的上次评审（[mode] 评审，结论：[verdict]）逐字节一致。”*
  如果该结论为 APPROVED 且该次评审覆盖本次运行，通过 `AskUserQuestion` 提供：
  `[A] Use the prior verdict (Recommended)` / `[B] Re-review anyway` —
  `guided` 采用 [A] 并注明；`autonomous` 通过
  `log_decision` 记录并使用先前结论。如果结论为 APPROVED，但本次要求的
  评审比已记录的更深，请说明 — *“那次是工作流 [tier] 下的 [mode] 评审；
  本次运行要求 [tier] 下的 [mode]。”* —
  并提供 `[A] Re-review at [mode] (Recommended)` / `[B] Use the prior
  [mode] verdict`；`guided` 与 `autonomous` 重新评审（`autonomous` 通过
  `log_decision` 记录）。如果结论为 NEEDS REVISION 或
  MAJOR REVISION NEEDED，请直说：文档自评审失败以来并未改变 —
  先前的发现仍然成立；下一步是修订文档，而不是重新评审。可提议展示
  日志中的先前发现。
- **目标文档与本技能文件 `UNCHANGED`，只有注册表或
  另一份被标记的跨文档文件为 `CHANGED`、`NEW` 或 `GONE`** — 先前
  结论成立，但跨文档事实除外：重新对照已变更文件核实文档取值并
  重新给出结论；如果出现冲突或该次评审不覆盖本次运行，
  则升级为完整重新评审。
- **目标文档或本技能文件为 `CHANGED` 或 `NEW`，或 `RECEIPT: NONE`** —
  继续执行下方的完整评审。**不要提供跳过阅读或重新分析未变更小节的
  部分/增量重新评审。** 按小节限定的重新评审会遗漏完整评审能发现的缺陷，
  且节省极少甚至毫无节省。
  “自上次评审以来未变更”只意味着与当时评审的内容逐字节一致 — 它并不说明
  那次评审本身是否完整，而且即使指示要全面扫描，注意力也会收窄到
  被标记的变更上。

完整阅读目标设计文档。此步骤需要整份 GDD：按其标题分段阅读
（用 Grep 工具查找：模式 `^#`，内容模式），因为超过 40 KB 的整文件
Read 会被拒绝。阅读 AGENTS.md 以了解项目上下文和标准。

**对于跨文档事实，优先使用注册表而非同级 GDD。** 如果
`design/registry/entities.yaml` 存在**且列出了本系统的条目**，
对其执行 grep — 这些是本 GDD 不得违背的既定事实，它们
替代阅读同级 GDD 来重新发现这些事实：
```
Grep pattern="source: design/gdd/[system].md" path="design/registry/entities.yaml" output_mode="content" -A 6
Grep pattern="design/gdd/[system].md" path="design/registry/entities.yaml" output_mode="content" -B 8
```
第一条查找本系统**拥有**的条目 — `-A 6` 上下文包含它们的
`referenced_by:` 块。第二条查找**引用**本系统的条目 —
`referenced_by:` 是块序列（键与其路径位于不同行），因此用 `-B 8`
上下文匹配路径，以看到拥有该条目的条目，而不是 `referenced_by.*name`
单行式（后者永远无法匹配块形式）。

**如果 `design/registry/entities.yaml` 不存在，或未列出本系统的任何条目** —
该文件以空存根形式提供，因此在 `/design-system` 填充它之前这是默认情况 —
退回到阅读目标文档在依赖小节中列出的相关 GDD。将阅读范围限制在
这些文档内，而不是一切“隐含”内容。不要对 `design/gdd/` 全部执行 glob 读取。

**依赖图验证：** 对依赖小节中列出的每个系统，使用 Glob 检查其 GDD 文件是否存在于 `design/gdd/`。标记任何尚不存在的系统 — 这些是下游作者会遇到的失效引用。

**世界观/叙事一致性：** 如果 `design/gdd/game-concept.md`（或在 `rigor: minimal` 下的单页简报 `design/game-brief.md`）或 `design/narrative/` 中的任何文件存在，请阅读。记录本 GDD 中任何与既定世界规则、基调或设计支柱相矛盾的机制选择。在 Phase 3b 中将该上下文传递给 `game-designer`。

**先前评审检查：** 检查 `design/gdd/reviews/[doc-name]-review-log.md` 是否存在。如果存在，读取最近条目 — 记录给出的结论以及列出的阻塞项。本次会话是一次重新评审；追踪先前条目是否已解决。

---

## Phase 2: 完整性检查

**Step 2a — 确定性地收集小节存在情况（不读取文档）：**

```
Bash: bash .trae/scripts/gdd-structure-check.sh [target-doc-path]
```

它会打印 `PRESENT:` 列表，并在适用时打印 `ABSENT:` 列表和
`PLACEHOLDER:` 列表（存在但仅包含 `[To be designed]` 的小节：尚未
撰写，因此在清单中将其视为缺失）。它只报告**存在情况**，
不做 REQUIRED/ADVISORY 判断 — 那是 Step 2b 的工作。
它已将 `## Detailed Design` 视为满足 `Detailed Rules`
要求，因此不要将其标记为缺失。

**Step 2b — 应用级别。** 使用 Step 2a 的列表，对照下方的
设计文档标准清单进行评估。**按解析出的工作流级别（Phase 0）
将每个小节标记为 REQUIRED 或 ADVISORY。** 缺失的 REQUIRED 小节
会阻止批准；缺失的 ADVISORY 小节作为建议呈现，但不阻止。

报告为 PRESENT 的小节如果只是一个空标题，仍可能无法通过评审 —
抽查结论实际依赖的任何小节。

- [ ] 具有 Overview 小节（一段式摘要）— 所有级别均 REQUIRED
- [ ] 具有 Player Fantasy 小节（预期感受）— `full` 下 REQUIRED；`standard` 下 ADVISORY
- [ ] 具有 Detailed Rules 小节（明确无歧义的机制）— `full`/`standard` 下 REQUIRED。GDD 模板将该小节标题定为 `## Detailed Design`（它包含 Core Rules / States / Interactions 子标题）；**任一**标题都应视为满足该要求 — 当存在 `## Detailed Design` 小节时，不要将“Detailed Rules”标记为缺失。
- [ ] 具有 Formulas 小节（所有数学均以变量定义）— `full` 下 REQUIRED；在 `standard` 下，只要系统定义了数值规则（比率、曲线、阈值、成本、伤害、掉落权重）就 REQUIRED，否则 ADVISORY。系统的 `Category` 只是提示，不是判断依据 — 不要仅凭类别标记就通过此项
- [ ] 具有 Edge Cases 小节（异常情况已处理）— `full`/`standard` 下 REQUIRED
- [ ] 具有 Dependencies 小节（列出其他系统）— `full`/`standard` 下 REQUIRED
- [ ] 具有 Tuning Knobs 小节（识别可配置值）— `full` 下 REQUIRED；`standard` 下 ADVISORY，除非 `workflow_overrides.tuning_knobs`
- [ ] 具有 Acceptance Criteria 小节（可测试的成功条件）— `full`/`standard` 下 REQUIRED

---

## Phase 3: 一致性与可实施性

**内部一致性：**
- 公式产生的数值是否与所描述的行为相符？
- 边界情况是否与主要规则相矛盾？
- 依赖是否双向（另一个系统是否知道本系统）？

**可实施性：**
- 规则是否足够精确，让程序员无需猜测即可实现？
- 是否存在任何细节缺失的“一笔带过”小节？
- 是否考虑了性能影响？
- 每条验收标准是否都能独立测试？标记每一条不能独立测试的标准，
  并引用原文 — “feels balanced”、“works correctly”、“performs well” 不是
  标准 — 并给出可量化的改写。在 `full` 模式下 `qa-lead` 也会检查它们
  （Phase 3b）；在 `lean` 和 `solo` 下没有专家运行，因此本主评审检查
  是唯一的检查。

**跨系统一致性：**
- 这是否与任何现有机制冲突？
- 这是否会与其他系统产生非预期的交互？
- 这是否与游戏既定的基调和支柱一致？

**注册表取值，无论 GDD 在何处陈述它们。** 一个在表格、
目录条目或变体说明中重述的数值，与在 Detailed Rules 中重述的数值一样
确定地违背注册表，而按小节阅读使这些正文容易被略过。列出
注册表的条目名称（`grep -E '^  - name:' design/registry/entities.yaml`），
然后对整个目标文档一次性搜索所有这些名称及其携带的数值
键，不区分大小写，将每个 `_` 写作 `[_ ]`，使 `goblin_scout`
也能匹配 “Goblin scouts”：

```
grep -n -i -E 'goblin[_ ]scout|iron[_ ]sword|health|value[_ ]gold' [target-doc-path]
```

无论这些行位于哪个小节，都对照注册表检查它打印的每一行。
任何给条目赋予不同数值的行，即使只是一个房间、变体、关卡
或例外，也违背拥有该条目的 GDD：将其列在“实现前必须解决”
（Required Before Implementation）下，并附上行号、本文档的取值与注册表的
取值。如果注册表没有条目，就对相关 GDD 定义的实体和取值
运行同样的搜索。

---

## Phase 3b: 对抗性专家评审（仅 full 模式）

**在 `lean` 或 `solo` 模式下跳过此阶段。**

**此阶段在 full 模式下为强制要求。** 不要跳过。

**派发任何代理之前**，打印此提示：
> “完整评审：正在并行派发专家代理。这通常需要 8–15 分钟。使用 `--review lean` 可获得更快的单会话分析。”

### Step 1 — 识别 GDD 涉及的所有领域

使用**在 Phase 1 中已加载的** GDD — 不要重新阅读 — 识别其中存在的每个领域。一份 GDD 可以同时涉及多个领域 — 要全面。常见信号：

| 如果 GDD 包含…… | 派发这些代理 |
|------------------------|-------------------|
| 成本、价格、掉落、奖励、经济 | `economy-designer` |
| 战斗属性、伤害、生命值、DPS | `game-designer`、`systems-designer` |
| AI 行为、寻路、目标选择 | `ai-programmer` |
| 关卡布局、生成、波次结构 | `level-designer` |
| 玩家成长、XP、解锁 | `economy-designer`、`game-designer` |
| UI、HUD、菜单、面向玩家的显示 | `ux-designer`、`ui-programmer` |
| 对话、任务、故事、世界观 | `narrative-director` |
| 动画、手感、时机、打击感（juice） | `gameplay-programmer` |
| 多人、同步、复制 | `network-programmer` |
| 音频提示、音乐触发 | `audio-director` |
| 性能、绘制调用、内存 | `performance-analyst` |
| 引擎特定的模式或 API | 主引擎专家（来自 `engine.name` 的 `<engine>-specialist` — Godot→`godot-specialist`，Unity→`unity-specialist`，Unreal→`unreal-specialist`；退化到 `technical-preferences.md` 中 `## Engine Specialists` 的 Primary 行） |
| 验收标准、测试覆盖 | `qa-lead` |
| 数据模式、资源结构 | `systems-designer` |
| 任何玩法系统 | `game-designer`（始终） |

对所有描述玩法机制或面向玩家规则的 GDD，派发 `game-designer`。
对所有包含公式或系统交互规则的 GDD，派发 `systems-designer`。
这些是最常见的基线 — 但对纯 UI 规格、音频规格或世界观文档并非必需。使用上方的领域表确定哪些专家真正相关。

### Step 2 — 并行派发所有相关专家

**关键：本技能中的 `Agent` 会派发一个子代理（SUBAGENT）— 一个拥有自己
上下文窗口的独立 Trae 会话。它不是任务追踪。不要在内部模拟专家
视角。不要自己推演领域观点。你**必须**发出
实际的 `Agent` 调用。模拟的评审不是专家评审。**

同时发出所有 `Agent` 调用。不要一次只派发一个。

**以对抗性方式提示每位专家：**
> “以下是 [system] 的 GDD 以及主评审截至目前的结构性发现。
> 你的工作不是验证这个设计 — 你的工作是找出问题。
> 用你的领域专长挑战这些设计选择。哪里有问题、
> 规格不足、可能引发问题，或完全缺失？
> 要具体且批判。欢迎与主评审意见不同。
> 按小节阅读 GDD：用 Grep 工具（模式 `^#`，
> 内容模式）查找标题，然后用 offset 和 limit 阅读那些范围。”

**按代理类型的附加说明：**

- **`game-designer`**：将你的评审锚定到本 GDD Section B 中陈述的 Player Fantasy。这个设计是否真正实现了该幻想？玩家是否会感受到预期体验？标记任何为可实施性服务却破坏所述感受的规则。

- **`systems-designer`**：对 GDD 中的每个公式，代入边界值（最小和最大合理输入）。报告是否有任何输出退化 — 负值、除以零、无穷大，或极端情况下的无意义结果。

- **`qa-lead`**：评审每条验收标准。标记任何无法独立测试的标准 — 诸如 “feels balanced”、“works correctly”、“performs well” 之类不是 AC。为任何未通过此测试的标准提出具体的改写建议。

### Step 3 — 资深主管评审

所有专家回复后，派发 `creative-director` 作为**资深评审人**：
- 提供：GDD、所有专家发现、他们之间的任何分歧
- 询问：“综合这些发现。最重要的问题是什么？你同意专家的意见吗？你对这个设计的总体结论是什么 — APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED？”
- creative-director 的综合意见成为 Phase 4 中的**最终结论**，使用本技能的结论用语 — 绝不要使用总监闸门用词，如 READY 或 REJECT。

### Step 4 — 呈现分歧

如果专家之间或与 creative-director 意见不一，不要悄悄选择一种观点。在 Phase 4 中明确呈现分歧，以便用户裁决。

用来源标记每项发现：`[game-designer]`、`[economy-designer]`、`[creative-director]` 等。

---

## Phase 4: 输出评审

```
## Design Review: [Document Title]
Specialists consulted: [list agents spawned]
Re-review: [Yes — prior verdict was X on YYYY-MM-DD / No — first review]

### Completeness: [X/N sections present, where N is the count REQUIRED at this project's `modes.workflow`]
[List only sections missing that are REQUIRED at this tier. Mark ADVISORY gaps
separately as "advisory at `standard`" — do not list them as missing.]

> **N is not 8 unless `workflow: full`.** The tier table earlier in this skill is
> authoritative: 8 required at `full`, 5 at `standard` (+ Formulas when the system
> defines numeric rules), 0 at `minimal`. Do not hardcode `/8` here: reporting a
> `standard` project as "5/8 missing Player Fantasy, Formulas, Tuning Knobs"
> warns about three sections that project's own configuration says it does not
> need, which trains the reader to ignore the review.

### Dependency Graph
[List each declared dependency and whether its GDD file exists on disk]
- ✓ enemy-definition-data.md — exists
- ✗ loot-system.md — NOT FOUND (file does not exist yet)

### Registry Values
[The whole-document search from Phase 3: the terms searched, how many lines it
printed, and each conflict with its line number. With nothing to search, say so:
"No registry entries or related-GDD values: values not cross-checked."]

### Required Before Implementation
[Numbered list — blocking issues only. Each item tagged with source agent.]

### Recommended Revisions
[Numbered list — important but not blocking. Source-tagged.]

### Specialist Disagreements
[Any cases where agents disagreed with each other or with the main review.
Present both sides — do not silently resolve.]

### Nice-to-Have
[Minor improvements, low priority.]

### Senior Verdict [creative-director]
[Creative director's synthesis and overall assessment.]

### Scope Signal
Estimate implementation scope based on: dependency count, formula count,
systems touched, and whether new ADRs are required.
- **S** — single system, no formulas, no new ADRs, <3 dependencies
- **M** — moderate complexity, 1-2 formulas, 3-6 dependencies
- **L** — multi-system integration, 3+ formulas, may require new ADR
- **XL** — cross-cutting concern, 5+ dependencies, multiple new ADRs likely
Label clearly: "Rough scope signal: M (producer should verify before sprint planning)"

### Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED / NOT ASSESSED]

> **`NOT ASSESSED` when the review could not actually be performed.**
> The other three verdicts are all claims about the design's quality, so each one
> asserts that the document was read and judged. Use `NOT ASSESSED` instead when
> the target document is absent, unreadable, or empty of the sections being
> reviewed, or when a document it depends on is missing so the criteria cannot be
> applied. **Name what was unavailable and which skill produces it.**
>
> `APPROVED` is the dangerous default here: a review that could not find its
> input has not approved anything, and this verdict is consumed downstream as a
> sign-off. `NOT ASSESSED` outranks `APPROVED` in any aggregate — it does not
> outrank the two revision verdicts, because a known problem is more actionable
> than an unknown one.
```

本技能是只读的 — Phase 4 期间不写入任何文件。

---

## Phase 5: 后续步骤

对所有收尾交互使用 `AskUserQuestion`。绝不要使用纯文本。

**第一个组件 — 接下来做什么：**

如果结论为 APPROVED（首次通过，无需修订），直接进入系统索引组件、评审日志组件，然后进入最终收尾组件。不要显示单独的“接下来做什么”组件 — 最终收尾组件涵盖后续步骤。

如果结论为 NOT ASSESSED，则没有评审任何内容：不提供追踪更新，直接
进入最终收尾组件，并先列出能产出缺失输入的技能（例如对不存在的 GDD
使用 `/design-system [system]`）。

如果结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED，根据发现构建选项：
- `[A] Revise the GDD now — address blocking items together`
- `[B] Stop here — revise in a separate session`
- `[C] Accept as-is and move on` — 仅当所有发现都为建议性
  （Required Before Implementation 为空）时才包含。存在任何阻塞项时，只提供
  [A] 和 [B]。

**如果用户选择 [A] — 立即修订：**

处理所有阻塞项，仅在无法仅凭 GDD 和现有文档解决时询问设计决策。在做出任何编辑之前，将所有设计决策问题归入一个多标签 `AskUserQuestion` — 不要在修订过程中为每个阻塞项单独打断。

所有修订完成后，显示摘要表（阻塞项 → 已应用的修复），并使用 `AskUserQuestion` 显示**修订后的收尾组件**：

- 提示：“修订完成 — 已解决 [N] 个阻塞项。下一步做什么？”
- 注明当前上下文使用量：如果上下文超过约 50%，添加：“（建议：重新评审前执行 /clear — 本次会话已使用 X% 上下文。完整重新评审会运行 5 个代理，需要干净的上下文。）”
- 选项：
  - `[A] Re-review in a new session — run /design-review [doc-path] after /clear`
  - `[B] Accept revisions for now — mark In Review in the systems index; a re-review decides Approved`
  - `[C] Move to next system — /design-system [next-system] (#N in design order)`
  - `[D] Stop here`

在协作和引导模式下，绝不要以纯文本结束修订流程 —
始终用此组件收尾。在自主模式下，总结结果并通过 `log_decision` 记录。

**第二个组件 — 追踪记录（合并，用于 APPROVED 路径）：**

当结论为 APPROVED 时，使用单个 `AskUserQuestion` 并设置 `multiSelect: true`，将两项追踪更新批量处理：
- 提示：“结论：APPROVED。我现在可以更新追踪记录。选择你希望我完成的项：”
- 选项：
  - `Update systems-index.md status to 'Approved' for [system]`
  - `Append approval entry to design/gdd/reviews/[doc-name]-review-log.md`

如果选择了评审日志选项，按下方相同格式追加。在显示最终收尾组件之前，执行两个已选操作。

当结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED 时，像之前一样使用单独的组件：

使用第二个 `AskUserQuestion`：
- 提示：“我可以更新 `design/gdd/systems-index.md`，将 [system] 标记为 [Needs Revision / In Review] 吗？” — 修订尚未完成时使用 `Needs Revision`（即该确切字符串），修订已应用且等待重新评审后使用 `In Review`。此提示绝不提供 `Approved`：修订结论不是批准。
- 选项：`[A] Yes — update it` / `[B] No — leave it as-is`

使用第三个 `AskUserQuestion`：
- 提示：“我可以将本次评审摘要追加到 `design/gdd/reviews/[doc-name]-review-log.md` 吗？这会创建修订历史，以便将来的重新评审追踪变更内容。”
- 选项：`[A] Yes — append to review log` / `[B] No — skip`

如果回答是，按以下格式追加条目：
```
## Review — [YYYY-MM-DD] — Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
Review mode: [full / lean / solo] · Workflow: [full / standard / minimal]
Scope signal: [S/M/L/XL]
Specialists: [list]
Blocking items: [count] | Recommended: [count]
Summary: [2-3 sentence summary of key findings from creative-director verdict]
Prior verdict resolved: [Yes / No / First review]
Findings:
- [BLOCKING] [section]: [one-line finding]
- [RECOMMENDED] [section]: [one-line finding]
[output of: Bash: bash .trae/scripts/review-receipts.sh hash "[target-doc-path]" "design/registry/entities.yaml" ".trae/skills/design-review/SKILL.md" [every other file this review read for cross-document facts: the related GDDs in design/gdd/, design/gdd/game-concept.md or design/game-brief.md, the design/narrative/ files] — a file that does not exist prints `not stamped, no such file` and is left out]
```

发现规则：每项发现一行，以其所在小节命名；
当结论没有发现时写 `- none`。这是供人类阅读修订历史的文档，
不是本技能回读的机制。

哈希行是 Phase 1 在下次运行时读取的回执，用于检测
逐字节一致的重新评审 — 这是唯一真正安全的跳过形式，
因为输入可证明相同，而不只是被认为已被先前评审充分覆盖。
为评审读取过的每个文件盖章：Phase 1 的检查会在下次运行时比较每个已盖章文件，
无论它是否点名。无论结论如何都始终包含它 —
一份先前评审 FAILED 的未变更文档，正是跳过冗余重新评审节省最多的情况
（先前发现逐字成立）。

---

**最终收尾组件 — 始终在所有文件写入完成后显示：**

系统索引和评审日志组件回答完毕后，检查项目状态并显示一个最终的 `AskUserQuestion`：

在构建选项之前，阅读：
- `design/gdd/systems-index.md` — 查找任何 Status 为 In Review 或 Needs Revision 的系统（本次刚评审的系统除外）。按小节阅读：用 Grep 工具（模式 `^#`，内容模式）查找标题，然后用 offset 和 limit 阅读那些范围。
- 统计 `design/gdd/` 中的 `.md` 文件（排除 game-concept.md、systems-index.md），以判断是否值得提供 `/review-all-gdds`（≥2 个 GDD）
- 按设计顺序查找下一个 Status 为 Not Started 的系统

动态构建选项列表 — 只包含真正可行的下一步：
- `[_] Run /design-review [other-gdd-path] — [system name] is still [In Review / Needs Revision]`（如果另一个 GDD 需要评审则包含）
- `[_] Run /consistency-check — verify this GDD's values don't conflict with existing GDDs`（如果存在 ≥1 个其他 GDD 则始终包含）
- `[_] Run /review-all-gdds — holistic design-theory review across all designed systems`（如果存在 ≥2 个 GDD 则包含）
- `[_] Run /design-system [next-system] — next in design order`（始终包含，写出实际系统名）
- `[_] Stop here`

只为被包含的选项分配字母 A、B、C……。将最能推进流水线的选项标记为 `(recommended)`。

在协作和引导模式下，文件写入后绝不要以纯文本结束技能 —
始终用此组件收尾。在自主模式下，打印下一步并通过 `log_decision` 记录。