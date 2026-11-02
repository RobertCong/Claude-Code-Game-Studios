# Your Path

这是你在 rigor `[value]` 下的路径。每项技能在任何 rigor 下都会运行；rigor 改变的是
什么是必需的，而不是什么是允许的。

**`minimal`：4 步到达可运行代码**
1. `/setup-engine`：选择并配置引擎
2. `/brainstorm`：撰写单页的 `design/game-brief.md`
3. `/create-stories`：将简报中的 MVP 清单转化为故事（无需 epic 或冲刺计划）
4. `/dev-story`：第一行游戏代码

**`standard`**
- Concept: `/setup-engine` → `/brainstorm` → `/prototype` → `/art-bible` → `/gate-check`
- Systems Design: `/map-systems` → `/design-system`（每个系统一次）→ `/review-all-gdds` →
  `/gate-check`
- Architecture: `/create-architecture` → `/architecture-decision`（每个决策一次）→
  `/create-control-manifest` → `/architecture-review` → `/test-setup` → `/ux-design`
  （无障碍与交互模式）→ `/gate-check`
- Pre-Production: `/ux-design`（HUD 与关键界面）→ `/create-epics` → `/create-stories` →
  `/sprint-plan` → `/gate-check`
- Production: `/dev-story`

每个 `/gate-check` 只有在通过时才会将项目推进一个阶段。

**`full`：** `standard` 中的全部内容，外加 Pre-Production 中的 `/vertical-slice` 与
`/playtest-report`，以及每份 GDD 之后的 `/design-review`。

**Path D with existing work**（阶段为 `Systems Design` 或更晚，或磁盘上已有代码）则改用以下内容。
只打印适用的步骤，简报只打印适用的那一个来源。在 `minimal` 下：
1. `/project-stage-detect`：项目处于哪个阶段以及缺什么
2. `/adopt`：现有文件是否采用技能可读取的格式
3. `/setup-engine`：仅当未设置引擎时；若 `engine` 已指明引擎则省略
4. 简报，仅当 `concept` 缺失时：当代码根目录有 10 个或以上源文件时用
   `/reverse-document design [code_root]`（它从游戏生成简报），然后完全不要提及
   `/brainstorm`；文件更少时才用 `/brainstorm`

在 `standard` 与 `full` 下，步骤 1 到 3，然后 `/design-system retrofit [path]`、
`/architecture-decision retrofit [path]`、`/architecture-review` 与 `/gate-check`。

`minimal` 是文档规定的最低限度，而不是次要模式。它的代价：没有 GDD，因此设计
问题会在代码中暴露出来。
