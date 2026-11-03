---
name: create-control-manifest
description: "根据已接受的 ADR，按系统构建一份简短的必做与禁做编码规则清单。当用户想要面向程序员的规则或基于 ADR 的速查表，或在 ADR 变更后需要重新生成时使用。"
argument-hint: "[update — regenerate from current ADRs] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/create-control-manifest/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/adr-status.sh*), Bash(bash .claude/scripts/md-section.sh *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation`

已在上方解析——直接使用；`--review` 在本次运行中覆盖 `review_mode`。若无
输出块 → 使用 `.claude/docs/config-resolution.md` 中的默认值。

用问题工具提问。若没有该工具，则列出编号选项并结束本轮等待。跳过或忽略的问题不算回答：用纯文本再问一次。

# 创建控制清单（Create Control Manifest）

控制清单（control manifest）是给程序员的扁平规则表：按架构层列出该做什么、绝不该做什么，内容取自已接受的 ADR（架构决策记录）、项目的技术偏好以及引擎参考文档。ADR 说明*为什么*；清单说明*做什么*。

**写入：** `docs/architecture/control-manifest.md`，在用户同意之后。
**时机：** 在 `/architecture-review` 通过且 ADR 已被接受之后。每当有 ADR 被接受或修订时重新运行。

询问遵循 `.claude/docs/automation-modes.md`（协作模式总是询问，引导模式仅重大选择询问，自主模式记录后继续；`automation_always_ask` 类别始终询问）。

## Phase 1: 加载输入

### ADR

`bash .claude/scripts/adr-status.sh` 一次读取所有 `docs/architecture/adr-*.md`：先输出计数（`adrs`，然后是 `accepted`、`proposed`、`deprecated`、`superseded`、`unfilled`、`other`、`no_status`），然后每条 ADR 一行，含其状态与层。先确定分母：在读取任何 ADR 之前，依据计数做决定：

| 计数 | 含义 | 行动 |
|---|---|---|
| `adrs 0` | 没有 ADR。 | "未找到 ADR —— 在构建控制清单前请运行 `/architecture-decision`。" 停止。 |
| `accepted` ≥ 1 | 正常。 | Accepted 行构成集合 **A**。在 Phase 4 预览中逐一点名其他每条 ADR 及其状态：用户是在知道清单遗漏了什么的情况下批准清单的。 |
| `accepted 0`，部分带状态 | 没有 Accepted 的 ADR。 | "找到 [N] 条 ADR，均未被接受。基于 Proposed ADR 构建的清单会写入可能仍会变化的决策。" 询问是继续使用 Proposed 的 ADR 还是停止。**绝不要静默写入空清单。** |
| 每条 ADR 都是 `no_status` | **ADR 格式错误，而不是 Accepted 集合为空。** | "找到 [N] 条 ADR，均没有 `## Status` 章节，因此无法判断是否被接受。请对每一条运行 `/architecture-decision retrofit [file]`。" 停止。绝不要把它们当作 Accepted。 |

上述每个停止都以 `Verdict: BLOCKED — [the reason]` 结束。记录每条规则来源 ADR 的编号与标题。

### 项目配置

- `naming.*` 与 `performance.*` 取自 `project.yaml`；对任何缺失或为空的键，
  取自 `.claude/docs/technical-preferences.md`。
- 已批准的库与禁止的模式取自
  `.claude/docs/technical-preferences.md`（尚未迁移到 `project.yaml`）。

### 引擎参考

- `docs/engine-reference/[engine]/VERSION.md` 用于获取引擎与版本。
- `docs/engine-reference/[engine]/deprecated-apis.md`：这些成为禁止使用的 API。
- `docs/engine-reference/[engine]/current-best-practices.md`（若存在）。

### 已存在的内容

`docs/architecture/control-manifest.md` 存在：本次运行会重新生成它；在 Phase 5 写入（会替换它）之前先读取它。`production/epics/*/EPIC.md` 存在：说明存在史诗（epic）。Phase 6 依据两者选择下一步。

报告："已加载 [N] 条 Accepted ADR 中的 [A] 条，引擎：[name + version]。"

## Phase 2: 从每条 ADR 提取规则

对 **A** 中的每条 ADR，只读取四个章节，绝不读整个文件：

```
bash .claude/scripts/md-section.sh extract docs/architecture/[adr-file].md "Decision"
```

对 `Alternatives Considered`、`Performance Implications` 与 `Engine
Compatibility` 同样处理。Context、Consequences、Migration Plan 与 Validation Criteria 说明为何做出决定；清单记录该做什么。某条 ADR 缺少某章节：为该 ADR 记下这一点并继续。A 中**每条** ADR 都缺少的某章节：报告"没有任何 Accepted ADR 包含 `[section]` 章节——清单的 [category] 规则将为空。请确认这是有意为之。" 仅当某章节指向自身之外时（"subject to the constraints in Context"），才读取四个章节之外的内容，且只读那一个章节。

从每条 ADR 中提取：

- **必需模式（Required patterns）**（Decision）：每个 "must"、"should"、"required to"、"always"，以及它所要求的每种模式或做法，包括其中的任何 `### Implementation Guidelines` 子标题。绝不要只查找该子标题：许多 ADR 直接在 Decision 下陈述其要求，仅扫描该子标题会得到空章节。
- **禁止做法（Forbidden approaches）**（Alternatives Considered）：每个被否决的备选方案，以其被否决的原因作为规则（"never use X because Y"），以及任何被点名的反模式。
- **性能护栏（Performance guardrails）**（Performance Implications）：预算（"max N ms per frame for this system"）与内存限制。
- **引擎 API 约束（Engine API constraints）**（Engine Compatibility）：需要验证的截止版本之后（post-cutoff）的 API、与模型假设不同的行为、在固定版本中已变更的字段或方法。

**层（Layer）。** 每条规则归入其所治理系统所在的层，若 ADR 有 `layer` 列则以其为准：

- **Foundation：** 场景管理、事件架构、存档/读档、引擎启动
- **Core：** 核心玩法循环、主要玩家系统、物理与碰撞
- **Feature：** 次要系统与机制、AI
- **Presentation：** 渲染、音频、UI、VFX、着色器

跨层的 ADR 将其规则放入每一层。

## Phase 3: 添加全局规则

适用于所有层的规则，每条都带来源（`project.yaml` 键、`technical-preferences.md`，或引擎参考文件），与层规则一样：

- **命名（Naming）** 取自 `naming.*`：类、变量、信号与事件、文件、常量。
- **性能预算（Performance budgets）** 取自 `performance.*`：目标帧率、帧预算、绘制调用、内存上限。
- **禁止的 API（Forbidden APIs）** 取自 `deprecated-apis.md`，**仅限适用于本项目所构建内容的部分。** 绝不要整表照抄：其中 `GodotPhysics3D → Jolt Physics 3D` 一行仅适用于 3D，2D 项目不使用该引擎。当你无法判断某条目是否适用时（2D 还是 3D、项目可能不包含的模块），限定规则范围（"when using 3D physics: …"）或将其略去并列为未决项。`/create-stories` 会读取此文件，而不适用的规则是没人会读的规则。
- **必需模式（Required patterns）** 取自 `current-best-practices.md`（若存在）。
- **禁止模式（Forbidden patterns）** 取自 `technical-preferences.md`，照原文复制。

## Phase 4: 展示摘要，然后评审

```
## Control Manifest Preview
Engine: [name + version]
ADRs covered: [ADR numbers]
ADRs left out: [ADR-NNNN ([status]), … — every ADR not in A, or "None"]
Rules extracted:
  - Foundation layer: [N] required, [M] forbidden, [P] guardrails
  - Core layer: [N] required, [M] forbidden, [P] guardrails
  - Feature layer: …
  - Presentation layer: …
  - Global: [N] naming conventions, [M] forbidden APIs, [P] approved libraries
Unresolved: [engine entries left out because whether they apply is unclear, or "None"]
```

询问："这份规则摘要看起来完整吗？" 选项：是 —— 评审并写入 /
添加规则 —— 我还有要补充的 / 移除规则 —— 有些应当删掉 / 停止 ——
我需要先审阅这些 ADR。

**技术评审。** 读取上方的 `review_gate` 行。`skill-gates=skip`
（solo 或 lean）：不调用代理；注明 `TD-MANIFEST skipped — [Solo | Lean] mode`。
`skill-gates=run`：将评审交给 `technical-director` 代理，闸门（gate）为
**TD-MANIFEST**（`.claude/docs/director-gates/td-manifest.md`；该代理会自行读取）。简报：

- **目标：** 在规则被写入之前检查已提取的规则。
- **提供：** 上方的预览（含完整规则列表）、所覆盖的 ADR、引擎版本，以及取自技术偏好或引擎参考的规则。
- **检查：** 每条强制性的 ADR 模式都被捕获且表述准确；禁止做法完整且归属正确；没有规则缺少来源 ADR 或偏好文档；护栏与 ADR 的约束一致。
- **返回：** APPROVE、CONCERNS、REJECT，或 NOT ASSESSED 并点名缺失的输入。
- **边界：** 它不写入任何文件。

依据结论行动：

- **APPROVE：** 进入 Phase 5。
- **CONCERNS：** 询问："技术总监提出了关注项。你想如何继续？" 选项：修订被标记的规则 / 接受并继续 / 进一步讨论。
- **REJECT：** 不写入任何内容；修正被标记的规则并再次展示摘要。
- **NOT ASSESSED：** 这不是批准（`.claude/docs/director-gates.md`）。说明缺少什么，然后补齐并再次运行评审；或者，当用户选择在不补齐的情况下继续时，进入 Phase 5 并在回复与最终结论行中写明 `TD-MANIFEST: NOT ASSESSED —
  [input]`。

## Phase 5: 写入控制清单

询问："我可以把控制清单写入 `docs/architecture/control-manifest.md` 吗？"
选项：是，写入 / 先给我看完整草稿，然后再问一次 / 还不行 ——
我想做更多修改。仅在明确同意后写入。

```markdown
# Control Manifest

> **Engine**: [name + version]
> **Last Updated**: [date]
> **Manifest Version**: [date]
> **ADRs Covered**: [ADR-NNNN, ADR-MMMM, ...]
> **Status**: Active — regenerate with `/create-control-manifest update` when ADRs change

`Manifest Version` is the date this manifest was generated. Stories embed it when
they are written, and `/story-readiness` compares a story's version with this one
to find stories written against old rules. It always equals `Last Updated`: the
same date, for different readers.

This manifest is a programmer's quick reference taken from the Accepted ADRs, the
technical preferences and the engine reference docs. For the reason behind a rule,
read its ADR.

---

## Foundation Layer Rules

*Applies to: scene management, event architecture, save/load, engine start-up*

### Required Patterns
- **[rule]** — source: [ADR-NNNN]

### Forbidden Approaches
- **Never [anti-pattern]** — [brief reason] — source: [ADR-NNNN]

### Performance Guardrails
- **[system]**: max [N]ms/frame — source: [ADR-NNNN]

---

## Core Layer Rules

*Applies to: core gameplay loop, main player systems, physics, collision*

### Required Patterns
...

### Forbidden Approaches
...

### Performance Guardrails
...

---

## Feature Layer Rules

*Applies to: secondary mechanics, AI systems, secondary features*

### Required Patterns
...

### Forbidden Approaches
...

---

## Presentation Layer Rules

*Applies to: rendering, audio, UI, VFX, shaders, animations*

### Required Patterns
...

### Forbidden Approaches
...

---

## Global Rules (All Layers)

### Naming Conventions
| Element | Convention | Example | Source |
|---------|-----------|---------|--------|
| Classes | [convention] | [example] | [`naming.classes` in project.yaml, or technical-preferences.md] |
| Variables | [convention] | [example] | [`naming.variables` in project.yaml, or technical-preferences.md] |
| Signals/Events | [convention] | [example] | [`naming.signals` in project.yaml, or technical-preferences.md] |
| Files | [convention] | [example] | [`naming.files` in project.yaml, or technical-preferences.md] |
| Constants | [convention] | [example] | [`naming.constants` in project.yaml, or technical-preferences.md] |

### Performance Budgets
| Target | Value | Source |
|--------|-------|--------|
| Framerate | [value] | [`performance.target_framerate` in project.yaml, or technical-preferences.md] |
| Frame budget | [value] | [`performance.frame_budget_ms` in project.yaml, or technical-preferences.md] |
| Draw calls | [value] | [`performance.draw_call_limit` in project.yaml, or technical-preferences.md] |
| Memory ceiling | [value] | [`performance.memory_ceiling_mb` in project.yaml, or technical-preferences.md] |

### Approved Libraries / Addons
- [library] — approved for [purpose] — source: technical-preferences.md

### Forbidden APIs ([engine version])
These APIs are deprecated or unverified for [engine + version]:
- `[api name]` — deprecated since [version] / unverified post-cutoff
- Source: `docs/engine-reference/[engine]/deprecated-apis.md`

### Cross-Cutting Constraints
- [constraint that applies in every layer] — source: [ADR-NNNN, preference key or engine-reference file]
```

## Phase 6: 后续步骤

- 尚无史诗（epic）："运行 `/create-epics layer: foundation`，然后运行 `/create-stories
  [epic-slug]`：用户故事会嵌入此清单的规则与版本。"
- 一次重新生成："已更新。把变更的规则告知团队，尤其是任何
  新的 Forbidden 条目。"

每条规则都可追溯到某条 ADR、某项技术偏好或某份引擎参考文档；没有一条是编造的，也没有一条被改述到改变其含义。写入后以 `Verdict: COMPLETE — control manifest written` 结束，被拒绝时以 `Verdict:
BLOCKED — user declined the write` 结束。
