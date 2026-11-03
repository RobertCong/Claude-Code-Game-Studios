---
name: help
description: "我接下来该做什么？在卡住或不知道做什么时使用。"
argument-hint: "[optional: what you just finished, e.g. 'finished design-review' or 'stuck on ADRs']"
user-invocable: true
---

# 工作室帮助 — 我接下来该做什么？

本技能是只读的 — 它报告发现，但不写任何文件。

本技能会精确判断你处于游戏开发流水线的哪个位置，并
告诉你接下来该做什么。它是**轻量级**的 — 不是完整审计。如需完整的
缺口分析，请使用 `/project-stage-detect`。

## 实时项目状态

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys project.stage,workflow`

这些内容应在上一步命令的输出中。请直接使用：

- 配置块中的 **`project.stage`** 是步骤 2 的权威阶段
  — 它已经应用了 `project.yaml` → `production/stage.txt` 的回退，
  并保留含空格的值（`Systems Design`）。
- 配置块中的 **`workflow`** 是步骤 2 和 5 的层级 — 不要重新读取它。
- 如果没有渲染出配置块，说明 shell 预处理被禁用；回退到
  `.trae/docs/config-resolution.md` 中的默认值。

---

## 步骤 1：读取目录

读取 `.trae/docs/workflow-catalog.yaml`。这是所有
阶段、各阶段的步骤（按顺序）、每个步骤是必需还是可选，以及
表示完成的产出物 glob 的权威列表。

---

## 步骤 1b：查找不在目录中的技能

读取目录之后，Glob `.trae/skills/*/SKILL.md` 以获取已安装技能的完整
列表。对每个文件，从其 frontmatter 中提取 `name:` 字段。

与目录中的 `command:` 值进行比较。任何技能的名称
未作为目录命令出现，即为**未编目技能** — 它仍然可用，但不属于
由阶段质量闸门控制的工作流。

为步骤 7 的输出收集这些技能 — 将它们作为页脚块展示：

```
### Also installed (not in workflow)
- `/skill-name` — [description from SKILL.md frontmatter]
- `/skill-name` — [description]
```

只有在至少存在一个未编目技能时才展示此块。根据用户当前阶段
限制为最相关的 10 个（制作阶段的 QA 技能、制作/打磨阶段的团队
技能等）。

---

## 步骤 2：判定当前阶段

**首先，取用上面配置块中的 `workflow`。** 如果它是 `minimal`，说明
项目处于 minimal 路径，而非阶段阶梯：跳过本步骤的其余部分，
读取会话上下文（**步骤 3**），然后转到 **步骤 4m**。在该层级下，
不要映射 `project.stage` — minimal 路径上没有任何步骤运行 `/gate-check`，因此
无论项目推进到哪一步，阶段都读作 Concept，而走一遍 Concept 阶段会把一个已经有
用户故事的项目送回概念文档、美术圣经和系统地图。

否则，按以下顺序检查：

1. **取用上面配置块中的 `project.stage`** — 它已经解析完成。将其值映射到目录中的阶段键：
   - "Concept" → `concept`
   - "Systems Design" → `systems-design`
   - "Technical Setup" → `technical-setup`
   - "Pre-Production" → `pre-production`
   - "Production" → `production`
   - "Polish" → `polish`
   - "Release" → `release`

2. **如果两者都未设置**，根据产出物推断阶段（最靠前的匹配胜出）：
   - 代码根中有 10 个以上源文件 → `production`
   - `production/epics/**/story-*.md` 存在 → `pre-production`
   - `docs/architecture/adr-*.md` 存在 → `technical-setup`
   - `design/gdd/systems-index.md` 存在 → `systems-design`
   - `design/gdd/game-concept.md`（或 `design/game-brief.md`）存在 → `concept`
   - 都没有 → `concept`（全新项目）

3. **`workflow`** 已在本步骤开头取得（依据
   `.trae/docs/workflow-modes.md`）。它控制可选的文档是否作为
   后续步骤呈现（步骤 5）。

---

## 步骤 3：读取会话上下文

读取 `production/session-state/active.md`（如果存在）— 但只读其中的 STATUS
和 CHECKPOINT 块（schema：`.trae/docs/templates/session-state.md`）；它们下方的
叙述可能很长。找到标记
（`Grep pattern="<!-- /?(STATUS|CHECKPOINT) -->" path="production/session-state/active.md" output_mode="content" -n`）
并从第一个读到最后一个。没有标记的文件早于该 schema：改为读取其
最后一个 `## Session Extract` 块。提取：
- 最近处理了什么
- 任何进行中的任务或未决问题
- STATUS 块中的当前史诗/功能/任务（如果存在）

这告诉你用户刚刚完成了什么或卡在何处 — 用它来个性化
输出。它在所有层级都会运行：在 `minimal` 下，它是步骤 4m 所依赖的
检查点的唯一读取来源（某个检查点写着 "Next step: /story-done" 意味着
工作已写完）。从此处开始，`minimal` 转到 **步骤 4m**，而不是步骤 4。

---

## 步骤 4：检查当前阶段的步骤完成情况

对当前阶段中的每个步骤（来自目录）：

### 基于产出物的检查

**以确定性的方式解析这些 — 一次调用，而不是每个步骤做一次 glob：**

```
Bash: bash .trae/scripts/artifact-check.sh --phase [current-phase]
```

严格按写法运行，此处及下文皆然：从项目根目录，使用
相对路径 — 不要绝对路径，不要 `cd`，不要 `2>&1`。本技能的权限
授予与该形式匹配；任何其他形式都需要用户批准。

它会针对工作树评估目录中的每个 `glob`、`pattern`、`min_count` 和 `any_of`，
并为每个步骤报告一行。映射其状态：

| status | 报告为 |
|---|---|
| `PRESENT` | **Complete** |
| `ABSENT` | **Incomplete** |
| `SHORT` | **Incomplete** — 说明差多少（会给出 `count=`/`min=`） |
| `PATTERN_MISS` | **Incomplete** — 文件存在但缺少其标记；要说明这一点，因为"缺失"会让用户去重建一个他们已有的文件 |
| `NO_CHECK` | 如果该步骤带有 `note=` 则为 **MANUAL**，否则为 **UNKNOWN** — 完成情况无法追踪（例如可重复的实施工作） |

不要用 Glob/Grep 重新推导其中任何内容。尤其是 `any_of`，它是一个
**备选项**列表 — 匹配一个就足够 — 手工评估会有误判为
"未完成"的风险：`engine-setup` 由 `project.yaml` 中的 `engine.name`
**或** `.trae/docs/technical-preferences.md` 中旧版的 `Engine:` 行满足，
脚本会报告匹配的是哪个备选项（`alt=`/`match=`）。

**`NO_CHECK` 绝不意味着已完成。** 脚本会在各行之前打印 `NO_CHECK:` 总数；
如果某个阶段的大部分都是 NO_CHECK，要明确说明，而不是暗示该阶段
接近完成。

### 特殊情况：制作阶段 — 读取 `sprint-status.yaml`

当当前阶段为 `production` 时，在做任何基于 glob 的用户故事检查之前，
先检查 `production/sprint-status.yaml`。如果存在，直接读取它：

- `status: in-progress` 的用户故事 → 作为"当前活跃"呈现
- `status: ready-for-dev` 的用户故事 → 作为"接下来"呈现
- `status: done` 的用户故事 → 计为已完成
- `status: blocked` 的用户故事 → 连同 `blocker` 字段作为阻塞项呈现

这样无需扫描 markdown 即可获得每个用户故事的精确状态。对 `implement` 和 `story-done` 步骤
跳过 glob 产出物检查 — YAML 才是权威。

### 特殊情况：`repeatable: true`（非制作阶段）

对于制作阶段之外的可重复步骤（例如"System GDDs"），产出物
检查告诉你的是*是否*做过任何工作，而不是是否已完成。
用不同方式标注它们 — 展示已检测到的内容，然后注明它可能仍在进行中。

---

## 步骤 4m：Minimal 路径（仅 `workflow: minimal`）

在 `minimal` 下，路线是目录的 `paths.minimal`，而不是某个阶段：引擎 →
`design/game-brief.md` → 用户故事 → `/dev-story` ↔ `/story-done`。用
一次调用解析它：

```
Bash: bash .trae/scripts/artifact-check.sh --path minimal
```

完全按步骤 4 的方式映射状态。`implement` 和 `story-done` 按设计就是
`NO_CHECK` — 下面的用户故事状态行就是它们的检查。下一步是以下第一个适用的：

1. `engine-setup` 不是 PRESENT → `/setup-engine`
2. `game-brief` 不是 PRESENT → 当代码根中已经有游戏时（10 个或更多源文件，
   即步骤 2 用于判断 `production` 的测试），使用 `/reverse-document design [code root]`：
   在 `minimal` 下它会根据已构建的内容写出 `design/game-brief.md`。否则使用 `/brainstorm`
   （在 `minimal` 下它会写出单页简报），而在已构建的游戏上这会开始一个新想法。
3. `create-stories` 不是 PRESENT → 不带参数的 `/create-stories`（在
   `minimal` 下它会直接从简报的 MVP 列表构建用户故事）
4. 用户故事已存在 → 你读取本技能之前，以下列表已由 `.trae/scripts/story-status.sh`
   打印：每个未完成的用户故事一行，**已按路线顺序排列** — 先是 `IN_REVIEW`，
   再是 `IN_PROGRESS`，再是按构建顺序的 `TODO`（`Ready` 或 `Not Started` 的用户故事）—
   然后是 `BLOCKED`、`OTHER`、`NO_STATUS` 以及 `COMPLETE` 计数：

   **运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../scripts/story-status.sh"`

   **下一个就是第一条 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO`
   行上的用户故事。** 列表已是最新；不要再次运行脚本，也不要
   重新读取或重新排序用户故事文件：
   `In Review` 的用户故事会先于 `In Progress` 的继续推进而被关闭 — 其
   工作已写完，`/story-done` 很快。
   - `IN_REVIEW` → 其工作已写完，等待关闭：
     `/story-done [path]`
   - `IN_PROGRESS` → 它**尚未**完成 — 无论代码或提交看起来如何，
     只有 `/story-done` 才能让用户故事变为 Complete。仅当用户、`active.md` 或 git log
     表明其实施已写完时，才推荐 `/story-done [path]`；否则用 `/dev-story [path]` 继续
   - `TODO` → `/dev-story [path]`
   - `BLOCKED` 的用户故事 → 指出它及其阻塞项；它永远不是"下一个"
   - **没有 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO` 行，但仍有 `BLOCKED`、`OTHER` 或
     `NO_STATUS` 行** → 接下来无法构建任何内容，而构建
     顺序**尚未**完成。按原样指出每个用户故事及其状态，
     以及被阻塞用户故事的阻塞项（从该用户故事的文件中读取）。
     下一个就是清除其中第一个：解决其阻塞项，或为
     `OTHER` 或 `NO_STATUS` 的用户故事补上路线会读取的 `Status:` 行（能构建时
     为 `Ready`）
   - **所有用户故事均为 `Complete`（或 `Done`）** → 简报的构建顺序已完成。
     说明这一点，并提供三种继续方式：试玩构建；用 `/create-stories`
     从简报中添加下一批用户故事；或者，如果游戏已超出一页
     简报，用 `/settings` 提高 `modes.rigor`。

**在 `minimal` 下，绝不要把以下任何内容呈现为必需或阻塞项：** 游戏概念文档、
美术圣经、系统地图、GDD、`/create-epics`、冲刺计划、
`/gate-check`，或冲刺收尾（`/smoke-check`、`/team-qa`、
`/retrospective`）。简报取代设计文档，其构建顺序
取代冲刺计划（`.trae/docs/workflow-modes.md` — `minimal` 基线）。
如果用户要求，它们仍然都能运行；只有当用户的问题涉及某项时才提及它。

然后跳过步骤 5 和 8，并按步骤 7 中的 `minimal` 形态呈现。

---

## 步骤 5：定位并识别后续步骤

根据完成数据，判定：

1. **最后一个确认完成的步骤** — 最靠后的已完成必需步骤
2. **当前阻塞项** — 第一个未完成的*必需*步骤（这就是
   用户接下来必须做的事）
3. **可选机会** — 未完成的*可选*步骤，可以在阻塞项之前或
   与之并行完成。**按工作流层级呈现**：在
   `full` 下，列出全部；在 `standard` 下，仅当某份可选文档是当前系统/阶段
   所必需时才列出（不要把真正可选的文档标记为
   缺口）。在 `minimal` 下本步骤不运行 — 由步骤 4m 取代
4. **即将到来的必需步骤** — 当前阻塞项之后的必需步骤
   （显示为"即将到来"，以便用户提前规划）

如果用户提供了参数（例如 "just finished design-review"），即使产出物检查
含糊，也用它来推进到他们所命名的步骤之后。

---

## 步骤 6：检查进行中的工作

如果 `active.md` 显示有活跃任务或史诗：
- 在顶部显著展示："看起来你之前在处理 [X]"
- 建议继续它，或确认它是否已完成

---

## 步骤 7：呈现输出

保持**简短直接**。这是一次快速定位，不是报告。

```
## Where You Are: [Phase Label]

**In progress:** [from active.md, if any]

### ✓ Done
- [completed step name]
- [completed step name]

### → Next up (REQUIRED)
**[Step name]** — [description]
Command: `[/command]`

### ~ Also available (OPTIONAL)
- **[Step name]** — [description] → `/command`
- **[Step name]** — [description] → `/command`

### Coming up after that
- [Next required step name] (`/command`)
- [Next required step name] (`/command`)

---
Approaching **[next phase]** gate → run `/gate-check` when ready.
```

**在 `minimal` 下**改用此形态 — 没有阶段标签，没有质量闸门行。`N`
只统计状态行为 `Complete` 或 `Done` 的用户故事，且只有这些
归入 ✓ Done。`N` 和 `M` 是 `COMPLETE` 行上的两个数字；它
不列出任何已完成的用户故事，因此 ✓ Done 给出的是数量，而不是标题：

```
## Where You Are: Minimal path — [N] of [M] stories complete

**In progress:** [from active.md, if any]

### ✓ Done
- Engine: [engine] · Game brief · [N] stories

### → Next up
**[Story NNN: title]** — [what it delivers]
Command: `/story-done [story-path]` for an In Review story, or an In Progress one whose work is written; otherwise `/dev-story [story-path]`

### Coming up after that
- [the next Ready stories in build order, at most 3]
```

**格式规则：**
- `✓` 表示确认完成
- `→` 表示当前必需的下一步（只有一个 — 第一个阻塞项）
- `~` 表示当前可用的可选步骤
- 命令以内联反引号代码形式展示
- 如果某个步骤没有命令（例如 "Implement Stories"），说明该怎么做，而不是展示斜杠命令
- 对于 MANUAL 步骤，询问用户："我无法判断 [step] 是否完成 — 它已经完成了吗？"

结论：**COMPLETE** — 已识别后续步骤。

---

## 步骤 8：质量闸门警告（如果接近）

在 `minimal` 下跳过本步骤 — minimal 路径没有阶段质量闸门。

在当前阶段的步骤之后，检查用户是否可能接近某个质量闸门：
- 如果当前阶段的所有必需步骤都已完成（或接近完成），
  添加："你已接近 **[Current] → [Next]** 质量闸门。准备好后运行 `/gate-check`。"
- 如果还剩多个必需步骤，跳过质量闸门警告 — 它还不相关。

---

## 步骤 9：升级路径

在给出建议之后，如果用户似乎卡住或困惑，添加：

```
---
Need more detail?
- `/project-stage-detect` — full gap analysis with all missing artifacts listed
- `/gate-check` — formal readiness check for your next phase
- `/start` — re-orient from scratch
- `/settings` — if the process feels mismatched to your project, adjust
  `modes.rigor`. Apply the change-triggers in
  `.trae/docs/settings-guidance.md § 4`: a **lower** tier when the user sounds
  overwhelmed by process (and rigor isn't already `minimal`), or a **higher** tier
  when the project has outgrown it (many systems, or in Production on
  `workflow: minimal`)
```

仅当用户的输入暗示困惑时才展示（例如 "I don't know"、"stuck"、
"lost"、"not sure"）。不要在简单的"接下来做什么？"查询中展示。仅当
`settings-guidance.md § 4` 的触发条件确实成立时才展示 `/settings` 严谨度那一行 — 用户听起来
不堪重负（且严谨度还不是 `minimal`），或项目已超出其层级 — 而不是在每次困惑的
查询中都展示。在 `minimal` 下，省略 `/gate-check` 那一行：minimal 路径没有阶段质量闸门（步骤 4m）。

---

## 协作协议

- **绝不自动运行下一个技能。** 推荐它，让用户自行调用。
- **询问 MANUAL 步骤**，而不是假定完成或未完成。
- **匹配用户的语气** — 如果他们听起来很紧张（"我完全迷失了"），要
  给予安抚，并给出一个行动，而不是六条列表。
- **一个主要建议** — 用户离开时应确切知道接下来要做的一件事。
  可选步骤和"即将到来"是次要上下文。