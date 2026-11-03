# /adopt — Phase 1: 检测项目状态

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 1: 检测项目状态

在读取前输出一行：`"Scanning project artifacts..."` — 这用于确认
技能正在静默读取阶段运行。

然后在呈现其他任何内容之前静默读取。

### 存在性检查
- `project.yaml` 中的 `project.stage`（回退到 `production/stage.txt`）— 若任一存在，则使用该值（权威阶段）
- `design/gdd/game-concept.md`（或在 minimal 层级下 `design/game-brief.md`）— 概念是否存在？
- `design/gdd/systems-index.md` — 系统索引是否存在？
- 统计 GDD 文件数：`design/gdd/*.md`（排除 game-concept.md 和 systems-index.md）
- 统计 ADR 文件数：`docs/architecture/adr-*.md`
- 统计用户故事文件数：`production/epics/**/*.md`（排除 EPIC.md）
- `project.yaml`（`engine.name`）/ `.trae/docs/technical-preferences.md` — 引擎是否已配置？
- `docs/engine-reference/` — 是否存在引擎参考文档？
- Glob `docs/adoption-plan-*.md` — 如有任何既有计划，记下最近一份的文件名

### 推断阶段（若无 project.stage / stage.txt）
使用与 `/project-stage-detect` 相同的启发式规则：
- 代码根目录中有 10 个以上源文件 → Production
- `production/epics/` 中存在用户故事 → Pre-Production
- 存在 ADR → Technical Setup
- 存在 systems-index.md → Systems Design
- 存在 game-concept.md（或 `design/game-brief.md`）→ Concept
- 什么都没有 → Fresh（不是棕地项目 — 建议运行 `/start`）

如果项目看起来是全新的（完全没有产出物），使用 `AskUserQuestion`：
- “这看起来是一个全新项目 — 未找到任何现有产出物。`/adopt` 适用于
  有工作要迁移的项目。你想怎么做？”
  - “运行 `/start` — 开始引导式首次上手”
  - “我的产出物在非标准位置 — 帮我找到它们”
  - “取消”

`/start` 和取消会结束本技能：说明是哪一项，然后停止。

**如果他们选择“帮我找到它们”**，先搜索，再询问其他任何内容：

1. 搜索他们指定的文件夹（若指定了）；否则搜索整个
   项目，跳过 `.trae/`、`.git/`、`docs/engine-reference/`、
   `studio-tests/`、`node_modules/` 以及引擎的构建和
   缓存文件夹。
2. 在其中 Glob `**/*.md`，然后对匹配结果 Grep 各产出物
   所带的标题：GDD 有 `## Overview` 与 `## Detailed Rules` 或
   `## Detailed Design`；ADR 有 `## Status` 与 `## Decision`；用户故事
   有 `## Acceptance Criteria` 与一行 `Status`；概念文档
   有 `## Elevator Pitch` 或 `## Game Pillars`；简报有 `## Core loop` 与
   `## MVP`。
3. 按类型分组展示找到的内容，并标明每个技能读取它时
   使用的位置：GDD → `design/gdd/[name].md`；ADR →
   `docs/architecture/adr-NNNN-[name].md`；用户故事 →
   `production/epics/[epic]/story-NNN-[name].md`；概念 →
   `design/gdd/game-concept.md`；简报 → `design/game-brief.md`。如果什么都
   没有匹配，如实说明，列出搜索过的文件夹和标题，并提供 `/start`。
4. 移动任何东西之前先询问 — 移动会把文件从旧路径带走，
   因此这是一个 `file_deletions` 决策：“我可以把这些 [N] 个文件移动到
   标准文件夹吗？” — `[A] Move them all` / `[B] Let me pick which` /
   `[C] Don't move them — I'll do it myself`。在 git 仓库中用 `git mv` 移动
   （文件历史会随之保留），否则用普通 `mv`。绝不覆盖
   目标位置已存在的文件：指出冲突并跳过该文件。
   文件只移动，绝不编辑。
5. 移动完成后，从头重新运行 Phase 1，这样审计就会读取
   其他所有技能将会读取的文件位置。若选 [C]，则把应做的移动以列表形式打印出来并停止。

报告：“检测到的阶段：[phase]。发现：[N] 份 GDD、[M] 份 ADR、[P] 个用户故事。”

---
