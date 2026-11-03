---
name: start
description: "引导首次使用的用户完成上手，并为其选择合适的工作流。当用户是新手、刚克隆或安装本工作室、还没有想法或引擎、询问从何处开始，或想引入现有游戏时使用。"
argument-hint: "[no arguments]"
user-invocable: true
---

# 引导式上手

新用户的入口。它假定用户没有游戏想法、没有引擎、也没有经验：它读取
项目，询问用户从何处开始，展示它对项目的假设，并
指出唯一的下一个步骤。它自己从不执行该步骤。

它把这些设置写入 `project.yaml`，全部通过辅助脚本完成，且仅在用户明确同意之后：
`project.stage`（及其旧版镜像 `production/stage.txt`）、`modes.rigor` 和
`modes.automation`。它从不写入 `modes.review_mode` 或 `production/review-mode.txt`，也不写
严谨度所前置的其他任何开关（`modes.workflow`、`docs.density`、`qa.level`、
`modes.story_granularity`、`team.size`）：写入的值会固定该开关，覆盖严谨度展开的结果，
而镜像文件的优先级更高。

用提问工具提问。若没有该工具，把选项编号列出并结束你的回合等待。问题
是回复中的最后一项：其后不跟任何路径、说明或建议。被跳过或关闭的
问题不算回答：用纯文本再问一次。

Phase 2、4 和 5 中的问题会塑造项目，因此在所有自动化模式下都会提问。
引擎不属于其中之一：它由 `/setup-engine` 选择。Phase 6 的最后一个问题遵循
`project.yaml` 中已有的 `modes.automation`，依据 `.trae/docs/automation-modes.md`；
若未设置，则直接询问。

## Phase 1: 读取项目

运行 `bash .trae/scripts/project-state.sh` 并保留其各行。暂时不要展示；它们用于在
Phase 2 中核对用户的回答。

| 行 | 用途 |
|---|---|
| `engine`、`code_root`、`source_files` | 是否已设置引擎，以及有多少代码。`source_files` 为 `unknown` 意味着找不到代码根：要说明这一点，绝不要说"没有代码" |
| `concept` | `design/gdd/game-concept.md` 或 `design/game-brief.md` 是否存在 |
| `gdd_files`、`adr` | 磁盘上的设计文档和架构决策（它们决定 Phase 4 中的阶段） |
| `prototype`、`sprint`、`milestone`、`story` | 其他现有工作 |
| `origin_url` | 包含 `donchitos/claude-code-game-studios`，不区分大小写匹配：克隆仍指向模板仓库，因此推送或拉取请求会发到那里。位于其他所有者名下的 fork 属于用户自己 |
| `stage` | 已记录的阶段（如果有） |

忽略 `phase_inferred`：它根据文件数量猜测，而有代码但没有设计
文档的项目并不处于 Production。如果辅助脚本失败，说明这一点，并手工读取同样的
事实（`project.yaml` 中的引擎、两个概念文件、代码根中的文件、`design/gdd/`）。

辅助脚本不报告严谨度或自动化。如果 `project.yaml` 存在，读取它，并记下
`modes.rigor` 和 `modes.automation` 是否已设置：已设置的值保留，其对应问题
不再询问（Phase 4 和 5）。

**回访用户**（已设置引擎且 `concept` 存在）：不要问任何问题。说明引擎、找到的
概念或简报，以及评审模式：如果设置了 `modes.review_mode` 就用它，否则用
`modes.rigor` 所隐含的那个（`minimal` → `solo`，`standard` → `lean`，`full` → `full`）。建议用 `/help` 了解下一步，
如果适用就加上模板远程仓库的提示，然后停止。

## Phase 2: 询问用户处于什么起点

用提问工具询问："欢迎！你的游戏目前处于什么起点？"选项：
- `A) No idea yet`：还没有游戏概念；先探索并找到要做的东西。
- `B) Vague idea`：一个主题、感觉或类型（"带点太空元素的"、"一款温馨的种田游戏"）。
- `C) Clear concept`：核心想法和类型已知，但还没有写下来。
- `D) Existing work`：设计文档、原型、代码或计划已经存在。

等待回答。如果回答与 Phase 1 矛盾，说明一次你的发现并再次询问：在
空项目上选 D（"这看起来像是一个全新的模板；A 或 B 是否更合适？"），或者在磁盘上已有代码时选 A（"我在 `[code_root]` 中发现了代码；你是指 D 吗？"）。
如果没有选项合适，让用户描述其情况并据此路由。

## Phase 3: 路由

只指出紧接着的下一步。完整路径要等到 Phase 6、严谨度确定之后。

- **A，没有想法：** 从零开始完全没问题。`/brainstorm open` 自由探索；`/brainstorm
  [hint]` 从某个词或主题开始。下一步：`/brainstorm open`，或者如果你想到了
  提示词就用它。把它描述为"把没有想法变成一份成文的设计，下一步据此展开"；这份设计
  有多长取决于严谨度，所以留到 Phase 6 再说。
- **B，模糊想法：** 请用户用几句话说明想法，照原样接受，并指出
  `/brainstorm [their words]`。
- **C，清晰概念：** 请用户用一句话给出概念（类型和核心机制），以纯
  文本形式。然后询问："你希望如何推进？"选项：`Formalize it first`（`/brainstorm
  [concept]` 把它写下来）/ `Jump straight in`（现在运行 `/setup-engine`，之后再写设计）。
  下一步由他们选择。
- **D，现有工作：** 说明 Phase 1 的发现（"`[code_root]` 下有 N 个源文件，N 份设计
  文档，引擎 [X / 未设置]"）。下一步：若未设置引擎且仅有
  一个概念，则运行 `/setup-engine`；否则运行 `/project-stage-detect`。

然后说："我马上就会把完整路径列出来。"

## Phase 4: 展示你的假设，然后保存

计算两个值。

**阶段（Stage）。** 路径 A、B 和 C：`Concept`。路径 D，依据 Phase 1 的各行：

| 磁盘上的情况 | 阶段 |
|---|---|
| 没有引擎，或除了一个概念之外别无他物（`gdd_files` 为 0） | `Concept` |
| `gdd_files` 为 1 或更多，`adr` 为 0 | `Systems Design` |
| `adr` 为 1 或更多 | `Technical Setup` |

**严谨度（Rigor）。** 如果 `project.yaml` 中已设置 `modes.rigor`，保留它并说明。否则根据
用户在 Phase 2 和 3 中的表述，使用
`.trae/docs/settings-guidance.md` §3 中的信号来推断：

| 用户的表述中提到 | 严谨度 |
|---|---|
| 开放世界、RPG、模拟、沙盒、派系、制作、经济、MMO、多人、大量系统 | `full` |
| 发布、商业、Steam、一个清晰的核心循环 | `standard` |
| game jam、周末、原型、第一款游戏、小型、只是试试 | `minimal` |
| 以上都不是，或还没有想法 | `minimal`（默认） |

路径 B 的提示词也是一种描述："某种开放世界生存模拟"属于 `full`。

展示卡片：

```
What I'll set up
  Stage:  [stage]  ([why, from what was found or picked])
  Rigor:  [value]  ([why, in the user's words] | already set)
          minimal: short brief, coarse stories, tests optional; about 4 steps to code
          standard: about 8 design documents before code; standard QA evidence
          full: everything in standard plus validation builds; evidence everywhere
  /settings changes either of these any time.
```

然后用提问工具询问："要把这些保存到 `project.yaml`（并把阶段保存到
`production/stage.txt`）吗？"选项：`Save them` / `Don't save`。不要就严谨度
本身提问：卡片已展示它，`/settings` 可以更改它。

- **保存：** 运行 `bash .trae/scripts/set-stage.sh "[stage]"`，然后，仅当严谨度此前
  未设置时，运行 `bash .trae/scripts/config-set.sh modes.rigor [value]`。检查回读的行
  是否匹配。说："已保存。严谨度 `[value]` 会设定另外六项设置；`/settings` 会显示它们并更改
  其中任意一项。"
- **不保存**，或任何不是明确同意的回答：什么都不写，本次运行保留这些值，
  并说明它们未被保存。

如果辅助脚本以非零状态退出，展示其输出，说明哪项设置未被写入，并继续使用
本次运行的值。

## Phase 5: 询问确认的程度

如果 `modes.automation` 已设置，说"自动化为 `[value]`"并继续。否则询问：
"最后一个问题：在工作过程中，我应该在多大程度上向你确认？"选项：
- `Guided (Recommended)`：我决定小事，遇到大事仍会停下来（范围变更、
  删除、schema 变更）。
- `Collaborative`：每个重要步骤之前我都会询问，写入之前会展示草稿。
- `Autonomous`：我继续推进并记录决策，只在始终询问的类别上停下。最快，
  消耗 token 最多。

映射：`Guided` → `guided`，`Collaborative` → `collaborative`，`Autonomous` → `autonomous`。
选择即是写入的同意：除非 Phase 4 的保存被拒绝（那就说明未保存），
否则运行 `bash .trae/scripts/config-set.sh modes.automation [value]`。

## Phase 6: 展示路径

说："以下是你在严谨度 `[value]` 下的路径。任何技能在任何严谨度下仍然可以运行；严谨度改变的是
要求，而不是允许的范围。"

路径从 Phase 3 指出的步骤开始。当那是 `/brainstorm` 时（路径 A 和 B，以及 C 的
`Formalize it first`），先列 `/brainstorm`，再列 `/setup-engine`：两者各自独立运行。

**`minimal`：4 步到可运行代码**
1. `/setup-engine`：选择并配置引擎
2. `/brainstorm`：编写单页的 `design/game-brief.md`
3. `/create-stories`：把简报中的 MVP 列表转成用户故事（无需史诗或冲刺计划）
4. `/dev-story`：第一行游戏代码

**`standard`**
- 概念：`/setup-engine` → `/brainstorm` → `/prototype` → `/art-bible` → `/gate-check`
- 系统设计：`/map-systems` → `/design-system`（每个系统一次）→ `/review-all-gdds` →
  `/gate-check`
- 架构：`/create-architecture` → `/architecture-decision`（每个决策一次）→
  `/create-control-manifest` → `/architecture-review` → `/test-setup` → `/ux-design`
  （无障碍与交互模式）→ `/gate-check`
- 预制作：`/ux-design`（HUD 和关键界面）→ `/create-epics` → `/create-stories` →
  `/sprint-plan` → `/gate-check`
- 制作：`/dev-story`

每次 `/gate-check` 会把项目推进一个阶段，且只有通过时才会推进。

**`full`：** `standard` 中的所有内容，外加预制作中的 `/vertical-slice` 和 `/playtest-report`，
以及每份 GDD 之后的 `/design-review`。

**带现有工作的路径 D**（阶段为 `Systems Design` 或更晚，或磁盘上已有代码）改为使用以下内容。
只打印适用的步骤，简报部分只打印适用的那一个来源。在 `minimal` 下：
1. `/project-stage-detect`：项目处于什么阶段以及缺少什么
2. `/adopt`：现有文件是否为技能所读取的格式
3. `/setup-engine`：仅在未设置引擎时；如果 `engine` 已指定引擎则省略
4. 简报，仅在 `concept` 缺失时：当代码根中有 10 个或更多源文件时用
   `/reverse-document design [code_root]`（它从游戏本身写出简报），然后就完全不要提及
   `/brainstorm`；仅在少于 10 个文件时使用 `/brainstorm`

在 `standard` 和 `full` 下，执行步骤 1 到 3，然后是 `/design-system retrofit [path]`、
`/architecture-decision retrofit [path]`、`/architecture-review` 和 `/gate-check`。

把 `minimal` 呈现为有文档记载的基线，而不是次要模式，并只说明一次它的取舍：没有 GDD，
因此设计问题会在代码中显现出来。

如果 `origin_url` 指向模板仓库，补充："你克隆的 `origin` 仍指向
CCGS 模板仓库，因此推送或拉取请求会发到那里。准备好后，运行
`git remote rename origin template`，然后运行 `git remote add origin <your repo URL>`。`UPGRADING.md`
会从 `template` 拉取更新；跳过它自己的 `git remote add template` 步骤，因为该远程现在
已存在。"建议它；不要运行它。

询问："你想从 [第一步] 开始吗？"选项：`Yes, start with [first step]` /
`Something else first`。无论哪个回答都进入 Phase 7，绝不执行该步骤。

## Phase 7: 交接

只用一行回复："Type `[skill]` to begin." 不要启动该技能，也不要为此调用
技能工具，即使已经得到同意：由用户自己输入。如果他们选择了其他内容，就以同样
方式指出对应的技能。

结论：**COMPLETE**，用户已完成上手引导并交接。如果用户在 Phase 7 之前停止，
说明哪些设置已保存、哪些未保存。