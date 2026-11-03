---
name: quick-design
description: "面向小改动的轻量级规格——调参调整、小型机制。直接嵌入用户故事，跳过完整 GDD。"
argument-hint: "[brief description of the change]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow`



# 快速设计（Quick Design）

这是面向不需要完整 GDD 的变更的**轻量级设计路径**。通过 `/design-system` 撰写完整 GDD 是重量级路径。对于约一周实施以内的工作——调参调整、小幅行为微调、对既有系统的小幅新增，或小到不值得完整文档的独立功能——请使用本技能。大多数微调只需数小时；一周上限是针对"新增小型系统"的限制（见下方类别）。

**输出：** `design/quick-specs/[name]-[date].md`

**何时运行：** 当某变更小到不适合 `/design-system`，但又重要到没有书面理由就不应实施时。

---

每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅大项询问 · 自主模式记录后继续；
`automation_always_ask` 类别始终提示）。

## 1. 对变更分类

首先，读取参数并确定该变更属于哪个类别：

- **Tuning（调参）** —— 修改既有系统中的数字或平衡值，不产生
  行为变化（最轻量的路径）。示例："将跳跃高度从 5 单位
  提高到 6 单位"、"将敌人巡逻速度降低 10%"。
- **Tweak（微调）** —— 对既有系统做小幅行为变更，不引入
  新状态、新分支或新系统。示例："让冲刺在第 1 帧无敌"、
  "允许连击取消进入翻滚"。
- **Addition（新增）** —— 向既有系统添加一个小型机制，可能引入
  1-2 个新状态或交互。示例："为格挡机制添加格挡判定窗口"、
  "为基础攻击添加蓄力变体"。
- **New Small System（新增小型系统）** —— 一个足够小的独立功能，没有
  既有 GDD，且实施工作约在一周以内。
  示例："成就弹窗系统"、"简单的昼夜视觉循环"。

若该变更**不符合**这些类别——它引入了具有
显著跨系统依赖的新系统、需要超过一周的
实施时间，或根本性改变了既有系统的核心规则——请停止
并改为重定向到 `/design-system`。结论：**REDIRECTED** —— 此变更请使用
`/design-system`。

若无参数，请用户描述该变更（纯文本提示），然后使用上述标准对其分类。

使用 `AskUserQuestion` 呈现推断出的分类：
- 提示："我将其归类为 **[inferred type]** —— [brief reason]。这样正确吗？"
- 选项：
  - `[A] 是 —— [inferred type] 正确`
  - `[B] Tuning —— 仅修改数字或平衡值`
  - `[C] Tweak —— 对既有系统的小幅行为变更`
  - `[D] Addition —— 向既有系统添加一个小型机制`
  - `[E] New Small System —— 独立功能，一周以内的工作量`
  - `[F] 这太大了 —— 请重定向到 /design-system`

若选 [F]：停止。结论：**REDIRECTED** —— 此变更请使用 `/design-system`。
否则：按所选类型继续。

---

## 2. 上下文扫描

在起草任何内容之前，先读取相关上下文。按章节读取 GDD 与系统
索引：用 Grep 工具查找需要的标题（pattern `^#`，
content 模式），再用 offset 与 limit 读取相应范围。

- 在 `design/gdd/` 中搜索与该变更最相关的 GDD。读取该变更
  会影响的章节。若无 GDD 覆盖该系统——通常在 `workflow: minimal` 下如此，
  那里 `design/game-brief.md` 与用户故事是设计记录——改为读取简报中相关行与该变更
  触及的用户故事，报告"没有 [system] 的 GDD —— 使用简报与 [story
  path]"，并将简报作为规格的 GDD Reference。
- 检查 `design/gdd/systems-index.md` 是否存在。若存在，读取它，
  以了解该系统在依赖图中的位置及其所属层级。若不存在，注明"未找到系统索引 —— 跳过
  依赖层级检查。"并继续。
- 检查 `design/quick-specs/` 中是否有涉及该系统的既往快速规格
  ——避免与之矛盾。
- 若这是 Tuning 变更，还要检查 `assets/data/` 中保存相关值的
  数据文件。

报告发现的内容："在 [path] 找到 GDD。相关章节：[section name]。
该系统的既往快速规格：[每个路径，以及它与本次变更是相符还是
冲突 —— 或 "none"]。" 即使既往规格与本次一致也要点名——仅说"无冲突"读起来与"无既往规格"相同。

---

## 3. 起草快速设计规格

使用与变更类别相符的规格格式。

### 针对 Tuning 变更

产出一个单独的表：

```markdown
# Quick Design Spec: [Title]

**Type**: Tuning
**System**: [System name]
**GDD Reference**: `design/gdd/[filename].md` — Tuning Knobs section
**Date**: [today]

## Change

| Parameter | Old Value | New Value | Rationale |
|-----------|-----------|-----------|-----------|
| [param]   | [old]     | [new]     | [why]     |

## Tuning Knob Mapping

Maps to GDD Tuning Knob: [knob name and its documented range].
New value is [within / at the edge of / outside] the documented range.
[If outside: explain why the range should be extended.]

## Acceptance Criteria

- [ ] [Parameter] reads [new value] from `assets/data/[file]`
- [ ] Behavior difference is observable in [specific context]
- [ ] No regression in [related behavior]
```

### 针对 Tweak 与 Addition 变更

```markdown
# Quick Design Spec: [Title]

**Type**: [Tweak / Addition]
**System**: [System name]
**GDD Reference**: `design/gdd/[filename].md`
**Date**: [today]

## Change Summary

[1-2 sentences describing what changes and why.]

## Motivation

[Why is this change needed? What player experience problem does it solve?
Reference the relevant MDA aesthetic or player feedback if applicable.]

## Design Delta

Current GDD says (quoting `design/gdd/[filename].md`, [section]):

> [exact quote of the relevant rule or description]

This spec changes that to:

[New rule or description, written with the same precision as a GDD Detailed
Rules section. A programmer should be able to implement from this text alone.]

## New Rules / Values

[Full unambiguous statement of the replacement content. If this introduces
new states, list them. If it introduces new parameters, define their ranges.]

## Affected Systems

| System | Impact | Action Required |
|--------|--------|-----------------|
| [system] | [how it is affected] | [update GDD / update data file / no action] |

## Acceptance Criteria

- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Specific, testable criterion 3]
- [ ] No regression: [the original behavior this must not break]

## GDD Update Required?

[Yes / No]
[If yes: which file, which section, and what the update should say.]
```

### 针对 New Small System 变更

使用精简的 GDD 结构。只包含直接必要的章节——除非该系统
特别需要，否则跳过 Player Fantasy、完整 Formulas 与 Edge Cases。

```markdown
# Quick Design Spec: [Title]

**Type**: New Small System
**Scope**: [1-2 sentence description of what this system does and doesn't do]
**Date**: [today]
**Estimated Implementation**: [hours]

## Overview

[One paragraph a new team member could understand. What does this system do,
when does it activate, and what does it produce?]

## Core Rules

[Unambiguous rules for the system. Use numbered lists for sequential behavior
and bullet lists for conditions. Be precise enough that a programmer can
implement without asking questions.]

## Tuning Knobs

| Knob | Default | Range | Category | Rationale |
|------|---------|-------|----------|-----------|
| [name] | [value] | [min–max] | [feel/curve/gate] | [why this default] |

All values must live in `assets/data/[appropriate-file].json`, not hardcoded.

## Acceptance Criteria

- [ ] [Functional criterion: does the right thing]
- [ ] [Functional criterion: handles the edge case]
- [ ] [Experiential criterion: feels right — what a playtest validates]
- [ ] [Regression criterion: does not break adjacent system]

## Systems Index

This system is not currently in `design/gdd/systems-index.md`.
[If it should be added: suggest which layer and priority tier.]
[If it is too small to track: state "This system is below systems-index
tracking threshold — quick spec is sufficient."]
```

---

## 4. 批准与归档

向用户完整呈现草稿。然后使用 `AskUserQuestion`：
- 提示："这是 Quick Design Spec 草稿。你想如何继续？"
- 选项：
  - `[A] 批准 —— 按所示内容写入`
  - `[B] 修订 —— 我来描述要改什么`
  - `[C] 这变得太大了 —— 改为重定向到 /design-system`

若选 [B]：收集所请求的变更，修订草稿，并重新呈现本交互控件。
若选 [C]：停止。结论：**REDIRECTED** —— 此变更请使用 `/design-system`。

若选 [A]：询问"我可以把这份 Quick Design Spec 写入
`design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md` 吗？"

文件名中使用今天的日期。标题应为变更的 kebab-case 描述
（例如 `jump-height-tuning-2026-03-10`、
`parry-window-addition-2026-03-10`）。

若同意，在 `design/quick-specs/` 目录不存在时创建它，然后
写入文件。

若需要更新 GDD（在规格中已标记），在写入快速规格后另行询问：

"此规格修改了 [System Name] 中的规则。我可以更新
`design/gdd/[filename].md` —— 具体是 [section name] 章节吗？"

询问之前展示将要改动的确切文本（旧 vs 新）。未经明确批准，不要
进行 GDD 编辑。

---

## 5. 交接

写入文件后，输出：

```
Quick Design Spec written to: design/quick-specs/[filename].md
Type: [Tuning / Tweak / Addition / New Small System]
System: [system name]
GDD update: [Required — pending approval / Applied / Not required]

Next step: This spec is ready for `/story-readiness` validation before
implementation (at `workflow: minimal`, go straight to `/dev-story`). Reference this spec in the story's GDD Reference field.
```

### 流水线说明（Pipeline Notes）

结论：**COMPLETE** —— 快速设计规格已写入并可供实施。

快速设计规格按设计**绕过** `/design-review` 与 `/review-all-gdds`。
它们适用于规模小、风险低、范围明确的变更，此时完整评审流水线的成本超过
变更本身的风险。

若以下任一情况成立，请重定向到完整流水线：
- 该变更新增的系统应纳入系统索引
- 该变更显著改变跨系统行为，或改变某系统
  与其他系统的契约
- 该变更引入了影响游戏 MDA 美学平衡的
  新玩家可见机制
- 实施很可能超过一周工作

在这些情况下："此变更已超出快速规格的范围。我建议
使用 `/design-system` 为其撰写完整 GDD。"

---

## 推荐后续步骤（Recommended Next Steps）

- 运行 `/story-readiness [story-path]` 在实施开始前验证用户故事（`rigor: minimal` 下跳过——直接 `/dev-story`）——在用户故事的 GDD Reference 字段中引用本规格
- 用户故事通过就绪检查后，运行 `/dev-story [story-path]` 实施
- 若变更比预期更大，运行 `/design-system [system-name]` 改为撰写完整 GDD