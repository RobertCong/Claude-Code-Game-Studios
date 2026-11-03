---
name: project-stage-detect
description: "分析项目状态、检测阶段、识别缺口并推荐后续步骤。回答'我们开发到哪一步了？'"
argument-hint: "[optional: role filter like 'programmer' or 'designer']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/project-stage-detect/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/artifact-check.sh), Bash(bash ".claude/scripts/artifact-check.sh"), Bash(bash ./.claude/scripts/artifact-check.sh), Bash(bash .claude/scripts/artifact-check.sh *), Bash(bash ".claude/scripts/artifact-check.sh" *), Bash(bash ./.claude/scripts/artifact-check.sh *)
model: haiku
# Read-only diagnostic skill — no specialist agent delegation needed
---

# 项目阶段检测（Project Stage Detection）

本技能扫描你的项目，以确定其当前开发阶段、产出物完整度以及需要关注的缺口。它在以下情况特别有用：
- 从既有项目开始
- 上手一个代码库
- 在里程碑前检查缺少什么
- 理解"我们在哪？"

---

## 工作流（Workflow）

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys workflow,automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅大项询问 · 自主模式记录后继续；
`automation_always_ask` 类别始终提示）。

已在上方解析——直接使用。若无输出块 → 使用
`.claude/docs/config-resolution.md` 中的默认值。

> **解析层级——不要假设它。** 层级决定了什么才算缺口：
> 在 `full` 下每份缺失文档都算；在 `minimal` 下都不算，
> 因为"一份简报加一个引擎"就是正常状态，代码才是预期的下一步。猜高了会告诉一个 Game Jam 项目它缺少 GDD、美术圣经
> 和 ADR——这正是 `modes.rigor` 存在要防止的"流程与我的项目不匹配"体验。

**`workflow`**（按 `.claude/docs/workflow-modes.md`）。层级决定哪些缺失文档算作缺口（step 3）——低于 `full` 时，可选文档不被标记。

### 1. 扫描关键目录

**先做确定性的一遍——一次调用即可回答所有已编目产出物"存在什么"：**

```
Bash: bash .claude/scripts/artifact-check.sh
```

严格按所写运行——从项目根目录、相对路径、无参数、无 `cd`、无 `2>&1`。本技能的权限授予匹配该形式；其他形式会要求用户批准。

不带 `--phase` 时它会报告所有阶段，因此单次调用即可覆盖整个项目：每个步骤输出 `PRESENT` / `ABSENT` / `SHORT`（带 `count=` 与 `min=`）/ `PATTERN_MISS` / `NO_CHECK`。用它替代下面对每个产出物的手工 glob，并将其 `NO_CHECK` 总数视为存在性检查所能告诉你的诚实边界。

它只报告观察结果——本技能仍需判断这些观察意味着什么阶段，而层级仍决定哪些缺失算缺口（见下方的 workflow 层级说明）。

然后分析脚本无法做到的部分：内容质量、它不跟踪的计数，以及需要判断的取舍。

**设计文档**（`design/`）：
- 统计 `design/gdd/*.md` 中的 GDD 文件
- 检查 game-concept.md（或在 `minimal` 下为 `design/game-brief.md`）、game-pillars.md、systems-index.md
- 若存在 systems-index.md，统计系统总数与已设计系统数
- 分析完整度（Overview、Detailed Design、Edge Cases 等）。按章节读取 GDD：
  用 Grep 工具查找需要的标题（pattern `^#`，content
  模式），再用 offset 与 limit 读取相应范围。
- 统计 `design/narrative/` 中的叙事文档数
- 统计 `design/levels/` 中的关卡设计数

**源代码**（代码根——Godot 为 `src/`，Unity 为 `Assets/`，Unreal 为 `Source/`；按 `.claude/docs/code-root-resolution.md` 解析）：
- 统计源文件（与语言无关）
- 识别主要系统（含 5 个以上文件的目录）
- 检查 core/、gameplay/、ai/、networking/、ui/ 目录
- 估算代码行数（大致规模）
- 代码根未解析意味着以上都未运行：报告
  `NOT ASSESSED — code root unresolved`，绝不报告零个源文件——零文件
  读起来像全新项目，而没有计数就无法判定阶段表中的源文件行

**制作产出物**（`production/`）：
- 检查活跃冲刺计划。在 `workflow: minimal` 下没有冲刺：
  改为通过简报的构建顺序读取用户故事文件的进度，且
  绝不把缺失的冲刺计划、里程碑或路线图报告为缺口
- 查找里程碑定义
- 查找路线图文档

**原型**（`prototypes/`）：
- 统计原型目录数
- 检查 README（有文档 vs 无文档）
- 评估原型是已归档还是活跃

**架构文档**（`docs/architecture/`）：
- 统计 ADR（架构决策记录）数
- 检查概述/索引文档

**测试**（`tests/`）：
- 统计测试文件
- 估算测试覆盖率（粗略启发式）

### 2. 判定项目阶段

基于扫描到的产出物判定阶段。先检查 `project.yaml` 中的 `project.stage`（若存在）；否则检查 `production/stage.txt`（旧版回退）——两者任一都是来自 `/gate-check` 的显式覆盖。否则，使用以下启发式自动检测（从最先进阶段往回检查）：

> **即使已配置阶段，也始终运行启发式——然后做比较。**
> 配置值是阶段*是什么*的权威；它不是"产出物支持该阶段"的证据。两者都报告，当它们不一致时明确说明：
>
> > "配置阶段：**Release**。观察到的产出物表明为
> > **Pre-Production**（2 个源文件、0 条 ADR、无架构文档、无史诗）。
> > 两者不一致——配置阶段可能已过期，或者工作存在于
> > 本仓库之外。"
>
> 读取配置再把它读回来不是检测。本技能自己的描述承诺 "analyze project state, detect stage"，而一个无法与其输入相矛盾的阶段检测器，恰恰是它绝不能成为的东西——
> 否则它会为一个产出物符合自身 Pre-Production 行（低四个阶段）的项目报告 `Release`，且一言不发。
>
> **不一致会使 Stage Confidence 为 CONCERNS**（step 4）——按定义即信号模糊——无论产出物多完整。唯一例外：在
> `workflow: minimal` 下没有东西运行 `/gate-check`，因此配置阶段停留在 `/start` 设定之处。此时报告观察到的阶段，并说明配置阶段在该层级不会推进；这种滞后是预期的，不是不一致。

| 阶段 | 指标 |
|-------|-----------|
| **Concept** | 没有游戏概念文档，处于头脑风暴阶段 |
| **Systems Design** | 游戏概念已存在，系统索引缺失或不完整 |
| **Technical Setup** | 系统索引已存在，引擎尚未配置 |
| **Pre-Production** | 引擎已配置，代码根少于 10 个源文件 |
| **Production** | 代码根有 10 个以上源文件，开发活跃 |
| **Polish** | 仅显式设置（由 `/gate-check` 的 Production → Polish 闸门设置） |
| **Release** | 仅显式设置（由 `/gate-check` 的 Polish → Release 闸门设置） |

### 3. 协作式缺口识别

**按解析出的工作流层级呈现缺口：**
- **`full`** —— 将每种缺失文档类型（GDD、美术圣经、UX 规格、ADR）都标记为缺口。
- **`standard`** —— 仅标记必需文档：已构建系统缺失的 GDD，以及缺失的关键（Foundation 层）ADR。除非存在视觉资源用户故事，否则不要标记缺失的美术圣经；也不要标记非核心 UX 规格。
- **`minimal`** —— 存在 `design/game-brief.md` + 引擎即为正常状态。不要将缺失的 GDD、美术圣经、UX 规格、ADR、史诗或冲刺计划标记为缺口：简报的构建顺序就是计划，预期的下一步是代码。

**不要**只是罗列缺失文件。而应**提出澄清性问题**（仅针对上方层级指示要呈现的缺口）：

- "我看到战斗代码（`<code root>/gameplay/combat/`），但没有 `design/gdd/combat-system.md`。这是先做的原型，还是我们应该反向补文档？"
- "你有 15 条 ADR，但没有架构概述。需要我创建一份来帮助新贡献者吗？"
- （仅 `standard`/`full`）"我看到 `<code root>/` 下有 [N] 个系统，但 `docs/architecture/` 中没有 ADR。那些决策记录在别处了吗，还是我们应该用 `/architecture-decision` 写下关键的那些？"
- （仅 `standard`/`full`）"`production/` 中没有冲刺计划。你们是在别处跟踪工作吗（Jira、Trello 等）？"
- "我找到了游戏概念，但没有系统索引。你是否已将概念分解为各个系统，还是我们应该运行 `/map-systems`？"
- "原型目录有 3 个项目没有 README。这些是实验，还是需要文档？"

### 4. 生成阶段报告

使用模板：`.claude/docs/templates/project-stage-report.md`

**报告结构**：
```markdown
# Project Stage Analysis

**Date**: [date]
**Stage**: [Concept/Systems Design/Technical Setup/Pre-Production/Production/Polish/Release]
**Stage Confidence**: [PASS — clearly detected / CONCERNS — ambiguous signals / NOT ASSESSED — a check the stage depends on did not run / FAIL — critical gaps block progress]

## Completeness Overview
- Design: [X%] ([N] docs, [gaps])
- Code: [X%] ([N] files, [systems])
- Architecture: [X%] ([N] ADRs, [gaps])
- Production: [X%] ([status] — at `minimal`: stories complete in the brief's build order, never "no sprint plan")
- Tests: [X%] ([coverage estimate])

## Gaps Identified
1. [Gap description + clarifying question]
2. [Gap description + clarifying question]

## Recommended Next Steps
[Priority-ordered list based on stage and role]
```

**Stage Confidence——按首个匹配：** 若关键缺口阻碍进展则为 **FAIL**；否则若已收集的信号模糊则为 **CONCERNS**——它们符合多个阶段，或配置阶段与观察阶段不一致（step 2）；否则若阶段所依赖的某项检查未运行则为 **NOT ASSESSED**——点名该项（代码根未解析，包括存在两个候选根，会使源文件计数、进而使阶段表的 Production 行无法判定）；否则为 **PASS**。NOT ASSESSED 优先于 PASS——无人能检查的阶段不是清晰检测到的阶段——且低于 CONCERNS 与 FAIL，因此已知问题绝不会被它掩盖。

### 5. 按角色筛选推荐（可选）

若用户提供了角色参数（例如 `/project-stage-detect programmer`）：

**Programmer（程序员）**：
- 关注架构文档、测试覆盖率、缺失的 ADR
- 代码与文档之间的缺口

**Designer（设计师）**：
- 关注 GDD 完整度、缺失的设计章节
- 原型文档

**Producer（制作人）**：
- 关注冲刺计划、里程碑跟踪、路线图
- 跨团队协作文档

**General（通用，无角色）**：
- 所有缺口的整体视图
- 跨领域的最高优先级项

### 6. 写入前请求批准

**协作协议**：
```
I've analyzed your project. Here's what I found:

[Show summary]

Gaps identified:
1. [Gap 1 + question]
2. [Gap 2 + question]

Recommended next steps:
- [Priority 1]
- [Priority 2]
- [Priority 3]

May I write the full stage analysis to production/project-stage-report.md?
```

创建文件前等待用户批准。

---

## 使用示例（Example Usage）

```bash
# General project analysis
/project-stage-detect

# Programmer-focused analysis
/project-stage-detect programmer

# Designer-focused analysis
/project-stage-detect designer
```

---

## 后续操作（Follow-Up Actions）

生成报告后，建议相关的后续步骤——**仅针对解析出的工作流层级所呈现的缺口**（step 3）。在 `standard`/`minimal` 下，不要建议撰写可选文档（例如在 `minimal` 下不要为缺失的 GDD 建议 `/reverse-document`，那里代码才是预期的下一步）：

- **在 `minimal` 下没有 `design/game-brief.md`？** → 当代码根已经承载游戏时（10 个或更多源文件），运行 `/reverse-document design <code root>`：它从已构建内容写出简报。代码很少或没有代码时，运行 `/brainstorm`。
- **概念存在但没有系统索引？** → `/map-systems` 用于分解为系统
- **缺少设计文档？** → `/reverse-document design <code root>/[system]`
- **缺少架构文档？** → `/architecture-decision` 或 `/reverse-document architecture`
- **原型需要文档？** → `/reverse-document concept prototypes/[name]`
- **没有冲刺计划？** → `/sprint-plan`（`rigor: minimal` 下不适用，那里简报的构建顺序就是计划）
- **临近里程碑？** → `/milestone-review`

---

## 协作协议（Collaborative Protocol）

本技能遵循协作式设计原则：

1. **先提问**：询问缺口，不要假设
2. **呈现选项**："我应该创建 X，还是它在别处已有跟踪？"
3. **用户决定**：等待指示
4. **展示草稿**：显示报告摘要
5. **取得批准**："我可以写入 production/project-stage-report.md 吗？"

**绝不**静默写入文件。**始终**展示发现结果，并在创建产出物前询问。
