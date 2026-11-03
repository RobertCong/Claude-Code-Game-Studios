---
name: create-epics
description: "把游戏设计文档（GDD）和架构转化为史诗（epic），每个架构模块一个。当用户想把游戏拆分为史诗，或在编写用户故事前规划工作时使用。不用于把一个史诗拆成用户故事。"
argument-hint: "[system-name | layer: foundation|core|feature|presentation | all] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation,workflow,docs.density,engine_values,system_overrides`

上一步命令的输出已解析——按原样使用；`--review` 会覆盖 `review_mode`。没有配置块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

用提问工具询问。没有提问工具时，把选项编号列出并结束本轮
以等待回答。被跳过或关闭的问题不算回答：用纯文本再问一次。

# 创建史诗

史诗（epic）是围绕一个架构模块的有界工作：**构建什么**，
以及哪些决策支配它。如何构建属于用户故事的范畴。随着开发
到达每一层，每层运行一次：在 Core 接近完成之前编写的 Feature 史诗，
描述的将是一个届时已经改变的设计。

**写入：** 每个史诗的 `production/epics/[epic-slug]/EPIC.md` 及其在
`production/epics/index.md` 中的行，各自在单独确认后进行。
**下一步：** 每个史诗运行 `/create-stories [epic-slug]`。本技能绝不编写用户故事。

询问遵循 `.trae/docs/automation-modes.md`（协作模式始终询问，引导模式
对重大选择询问，自主模式记录并继续；`automation_always_ask`
类别始终询问）。

清单（复制它并随进度勾选）：

```
- [ ] Phase 1: scope and tier
- [ ] Phase 2: inputs loaded and reported
- [ ] Phase 3: each epic shown, "Shall I create Epic: …?" asked one at a time
- [ ] Phase 4: producer review run, or its skip noted
- [ ] Phase 5: each EPIC.md and index row written after its own yes
- [ ] Phase 6: closing block printed
```

## Phase 1: 范围与层级

技能名称之后输入的文本，去除任何 `--review <mode>` 对：

- `all`：按层顺序的所有系统。
- `layer: foundation`（或 `core`、`feature`、`presentation`）：仅该层。
- 一个系统名称：仅该系统。
- 什么都没有：当请求自身的措辞点名了某一层或系统（“foundation
  and core”）时，使用该措辞；否则询问“你想为哪个层级或系统创建史诗？”

**层级。** 项目的 `workflow` 值设定什么是必需的（Phase 2）。每个
在范围内系统自身的 GDD 门槛来自其 `system_overrides` 行（如果有）。

**在 `minimal` 下，先告诉用户：** 该层级此步骤是可选的，因为
`/create-stories` 会自行从 `design/game-brief.md` 构建史诗。然后在他们
要求创建史诗时继续。

## Phase 2: 加载输入

### `minimal`：简报

读取 `design/game-brief.md`。没有则：停下，“没有 `design/game-brief.md`——请先运行 `/start`
或 `/brainstorm`。”绝不要索取 GDD、系统索引、架构
文档、ADR、TR 注册表或控制清单，也绝不要把用户先送去
`/design-system`、`/map-systems` 或 `/create-architecture`：该层级
按设计就没有这些东西。

先逐字报告：

```
Loaded: design/game-brief.md · engine [name version from the engine_values line]
At minimal this step is optional: /create-stories builds the epic from the brief by itself.
```

史诗来自简报的 MVP 功能列表，按其 **Build order**。简短
简报就是一个史诗，slug 取自简报的工作标题（即没有输入任何内容时
`/create-stories` 使用的 slug）。当用户要求把工作分组时，为一起交付的每组
MVP 功能创建一个史诗。每个史诗都要点明其 slug，因为
`/create-stories` 需要输入它。

### `standard` 和 `full`：设计与架构

1. **系统 GDD。** `bash .trae/scripts/gdd-structure-check.sh` 列出每个
   系统 GDD；游戏概念、系统索引、支柱、交叉评审和其他
   非系统文档已为你排除。它们的数量为 **N**。N 为 0：停下，
   “在 `design/gdd/` 中未找到系统 GDD——请先运行 `/design-system`。”
2. **范围内的内容。** 每份 GDD 的 `## Summary` 快速参考给出其层级和
   优先级。没有 Summary 的 GDD（较老的 GDD 早于它）从
   `design/gdd/systems-index.md` 取层级。绝不要把缺失的 `## Summary` 当作缺失的系统：
   它绝不会让某个系统掉出范围。
3. **架构。** 两个层级都要求 `docs/architecture/architecture.md`：
   缺失则停下，提示
   “没有 `docs/architecture/architecture.md`——请先运行 `/create-architecture`。”绝不要凭空发明模块边界。
4. **仅对范围内系统**，按章节读取，绝不整份读取：
   - 每份 GDD 的 Overview 和 Acceptance Criteria
     （`bash .trae/scripts/md-section.sh extract design/gdd/<file>.md "Overview"`）；
   - `bash .trae/scripts/adr-status.sh` 获取每个 ADR 的状态、层级和缺失
     章节；然后读取覆盖范围内系统的 ADR 的 GDD Requirements Addressed、Decision 和 Engine
     Compatibility 章节；
   - `docs/architecture/tr-registry.yaml`：其中 `system:` 为
     范围内系统的条目；
   - 控制清单的 `Manifest Version` 行（在 `standard` 下存在则读取，
     在 `full` 下必需）；
   - `docs/engine-reference/<engine>/VERSION.md`，获取引擎的风险等级。

在定义任何东西之前报告，并反映真实状态：

```
Loaded: [N] system GDDs, [n] in scope ([names]) · [M] ADRs ([A] Accepted, [P] Proposed) · manifest v[date | absent] · engine [name version from the engine_values line]
```

在 `full` 下，每个范围内 GDD 都需要全部 8 个章节和 Approved 状态，且 TR
注册表和控制清单是必需的。在 `standard` 下，GDD 需要其 5 个
必需章节，且只预期关键（Foundation 层）ADR。

## Phase 3: 逐个定义史诗，一次询问一个

按层处理：Foundation，然后 Core、Feature、Presentation；层内按
系统索引顺序（在 `minimal` 下，按简报的 Build order）。对每个系统，其
模块来自 `architecture.md`（在 `minimal` 下，为简报的功能组）。

**需求覆盖**（`minimal` 下不适用）。系统的每个 TR-ID 是：

- **已覆盖**：当有 **Accepted** ADR 处理它时；
- **未追踪**：否则。唯一 ADR 为 `Proposed`（或任何其他
  状态）的需求是未追踪的，绝不是已覆盖：其行读作 `❌ No ADR (ADR-NNNN Proposed)`，
  因此 `/create-stories` 仍能看到该 ADR 并阻塞其用户故事。

未追踪需求列在 **Untraced Requirements** 下。下文的 ⚠️ 警告
在 `full` 下针对每个未追踪需求，在 `standard` 下仅针对未追踪的
Foundation 层需求；`standard` 下任何其他未追踪需求作为信息列出，不带警告。

```
## Epic: [System Name]
**Layer**: [Foundation | Core | Feature | Presentation]
**GDD**: design/gdd/[file].md   (at minimal: design/game-brief.md, MVP features [list])
**Architecture Module**: [module]
**Governing ADRs**: [Accepted ADRs, or "none"]
**Engine Risk**: [LOW | MEDIUM | HIGH — the highest among governing ADRs, else VERSION.md's]
**Requirements covered by Accepted ADRs**: [n / total]
**Untraced Requirements**: [TR-IDs with why, or "None"]
```

警告在适用时：“⚠️ [system] 中有 [N] 个需求没有 Accepted ADR。
它们的用户故事将在没有支配 ADR 的情况下编写，或因 Proposed ADR 而阻塞。
如果它们需要决策，请先运行 `/architecture-decision`，或者继续并接受
该缺口。”

然后，**仅针对这个史诗**询问：“我可以创建史诗：[name] 吗？”选项：Yes,
create it / Skip this epic / Pause — I need to write ADRs first。在此回答之后
才展示并询问下一个史诗。绝不要把多个史诗合并进一个问题。

一个“是”只覆盖它所回答的那个史诗，且仅此一个，即便措辞是针对所有
（“all of it”“go ahead with everything”）：史诗是见即批准。
展示下一个史诗的区块并再次询问，直到范围内每个史诗都已展示并
得到回答。

## Phase 4: 制作人评审

阅读上面的 `review_gate` 行。`skill-gates=skip`（solo 或 lean）：无代理；在回复和收尾块中注明
`PR-EPIC skipped — [Solo | Lean] mode`。
`skill-gates=run`：阅读 `references/pr-epic-gate.md` 和
`.trae/docs/director-gates.md`，并在现在运行它——在范围内每个史诗都已
定义之后、任何写入之前。跳过时，不要加载它。

## Phase 5: 编写每个史诗

对用户说“是”的每个史诗，按顺序：

**已有 `EPIC.md`：** 绝不覆盖它。询问“已存在 [name] 的 EPIC.md。
原地更新它，还是跳过？”选项：Update in place / Skip this epic。
更新只编辑本技能拥有的内容（除 Stories、
Overview、Governing ADRs、GDD Requirements、Definition of Done 之外的头部字段），并让
`**Stories**` 行和任何 `## Stories` 表格保持原样：`/create-stories` 写了
它们，重置它们会使已有用户故事成为孤儿。

**新建：** 询问“我可以写入 `production/epics/[epic-slug]/EPIC.md` 并把其行添加到
`production/epics/index.md`[, 若不存在则创建它]吗？”这是它自己的询问，每个史诗一次，在
Phase 3 的“是”之后：那个“是”批准的是史诗，而不是写入。只在对它的明确
“是”后写入。在写入之前，运行 `bash .trae/scripts/write-guard.sh overwrite
production/epics/[epic-slug]/EPIC.md`。它总是打印一行 `checked`；返回
`OVERWRITE` 行意味着文件毕竟存在，因此什么都不要写，改为询问
更新问题。

`docs.density` 设定 Overview 的深度（`terse` 为要点，`balanced` 为短
段落，`thorough` 为带 ADR 理由和风险的完整散文）；每个密度下表格都保持
完整。

```markdown
# Epic: [System Name]

> **Layer**: [Foundation | Core | Feature | Presentation]
> **GDD**: design/gdd/[file].md
> **Architecture Module**: [module]
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories [epic-slug]`

## Overview

[What this epic implements, from the GDD Overview and the module's responsibilities]

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|------------------|-------------|
| ADR-NNNN: [title] | [one line] | LOW/MEDIUM/HIGH |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-[system]-001 | [requirement text from the registry] | ADR-NNNN ✅ |
| TR-[system]-002 | [requirement text] | ❌ No ADR (ADR-NNNN Proposed) |

## Definition of Done

- Every story implemented, reviewed and closed with `/story-done`
- Every acceptance criterion of design/gdd/[file].md verified
- Logic and Integration stories have passing tests in the test root
- Visual/Feel and UI stories have retained screenshots in `production/qa/evidence/`
  (a lead sign-off too for Visual/Feel)
```

在 `minimal` 下，GDD 行写明 `design/game-brief.md`，省略 Governing ADRs 和 GDD
Requirements 表格，并用一个 **Scope** 列表按 Build order 承载史诗的 MVP
功能。

**`production/epics/index.md`：** 每个史诗一行。已有行的史诗
保留它：原地更新，绝不添加第二行，绝不重置其 Stories 单元格。

```markdown
# Epics Index

Last Updated: [date]
Engine: [name version]

| Epic | Layer | System | GDD | Stories | Status |
|------|-------|--------|-----|---------|--------|
| [name] | [layer] | [system] | [file] | Not yet created | Ready |
```

## Phase 6: 收尾

在 `standard` 和 `full` 下，一旦 Foundation 和 Core 史诗存在，添加：“Foundation 和
Core 史诗是 Pre-Production → Production 闸门所需要的。`/gate-check
production` 检查就绪情况。”绝不在 `minimal` 下添加。

每个史诗的内容都来自 GDD、ADR 和架构文档（`minimal` 下为
简报）；没有任何内容是凭空发明的。

**本次运行的最后一条回复以这个块结尾**（如果你之前展示过它，重复一次）：

```
Verdict: COMPLETE — [N] epics written: [slugs]
Review: [PR-EPIC skipped — Solo mode | skipped — Lean mode | its verdict]
Index: production/epics/index.md [created | updated]
Next step: /create-stories [first-epic-slug]
```

当用户跳过或拒绝了每一个史诗时：`Verdict: BLOCKED — no epic written
([why])`。未找到范围内系统时：`Verdict: BLOCKED — no eligible systems in
[scope]`。