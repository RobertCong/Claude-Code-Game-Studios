# /architecture-decision — 第 5 步：生成 ADR

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## 5. 生成 ADR

**本文件包含：**

- ADR 模板
- 5.5 引擎专家验证
- 5.6 技术总监战略评审，以及评审模式检查
- 5.7 GDD 同步检查：找到、未找到、无法检查
- 写入批准
- 更新架构注册表，以及注册表追加逻辑

遵循以下格式：

```markdown
# ADR-[NNNN]: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date
[Date of decision]

## Last Verified
[YYYY-MM-DD — when this ADR was last confirmed accurate against the current
engine version and design. Update this date when you re-read and confirm it is
still correct, even if nothing changed.]

## Decision Makers
[Who was involved in this decision]

## Summary
[2 sentences: what problem this ADR solves, and what was decided. Written for
tiered context loading — a skill scanning 20 ADRs uses this to decide whether to
read the full decision. Be specific: name the system, the problem, and the
chosen approach.]

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | [e.g. Godot 4.7] |
| **Domain** | [Physics / Rendering / UI / Audio / Navigation / Animation / Networking / Core / Input] |
| **Layer** | [Foundation / Core / Feature / Presentation] |
| **Knowledge Risk** | [LOW / MEDIUM / HIGH — from VERSION.md] |
| **References Consulted** | [List engine-reference docs read, e.g. `docs/engine-reference/godot/modules/physics.md`] |
| **Post-Cutoff APIs Used** | [Any APIs from post-LLM-cutoff versions this decision depends on, or "None"] |
| **Verification Required** | [Specific behaviours to test before shipping, or "None"] |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN (must be Accepted before this can be implemented), or "None"] |
| **Enables** | [ADR-NNNN (this ADR unlocks that decision), or "None"] |
| **Blocks** | [Epic/Story name — cannot start until this ADR is Accepted, or "None"] |
| **Ordering Note** | [Any sequencing constraint that isn't captured above] |

## Context

### Problem Statement
[What problem are we solving? Why does this decision need to be made now?]

### Constraints
- [Technical constraints]
- [Timeline constraints]
- [Resource constraints]
- [Compatibility requirements]

### Requirements
- [Must support X]
- [Must perform within Y budget]
- [Must integrate with Z]

## Decision

[The specific technical decision made, described in enough detail for someone
to implement it.]

### Architecture Diagram
[ASCII diagram or description of the system architecture this creates]

### Key Interfaces
[API contracts or interface definitions this decision creates]

### Implementation Guidelines
[Specific guidance for the programmer implementing this decision — the rules a
`/create-control-manifest` or `/dev-story` run should follow. State mandates as
"must / must never" so they extract cleanly.]

## Alternatives Considered

### Alternative 1: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Rejection Reason**: [Why this was not chosen]

### Alternative 2: [Name]
- **Description**: [How this would work]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Rejection Reason**: [Why this was not chosen]

## Consequences

### Positive
- [Good outcomes of this decision]

### Negative
- [Trade-offs and costs accepted]

## Risks
- [Things that could go wrong]
- [Mitigation for each risk]

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| [system-name].md | [specific rule, formula, or performance constraint from that GDD] | [how this decision satisfies it] |

## Performance Implications
- **CPU**: [Expected impact]
- **Memory**: [Expected impact]
- **Load Time**: [Expected impact]
- **Network**: [Expected impact, if applicable]

## Migration Plan
[If this changes existing code, how do we get from here to there?]

## Validation Criteria
[How will we know this decision was correct? What metrics or tests?]

## Related
- [Links to related ADRs — note if supersedes, contradicts, or depends on]
- [Links to related design documents]
```

**始终写入 Layer 行。** 没有 Layer 行的 ADR 无论在哪里读取都会被算作关键
（Foundation），因此在 `standard` 下其建议项会变成
阻塞项。该值是 ADR 自身的层级，即它必须在构建中多早存在：
`docs/architecture/architecture.md` 的层级映射为此决策所治理的系统
指定的层级。如果没有层级映射，或其没有该系统的条目，询问
用户，并以四个值作为选项。绝不要从引用该 ADR 的史诗中取它，
也绝不重用 `Domain` 值（模板在 Engine Compatibility 下方的说明解释了原因）。

5.5. **引擎专家验证** —— 在保存之前，通过 `Agent` 生成**主引擎专家**来验证起草的 ADR：
   - 解析主专家：由 `project.yaml` 中的 `engine.name` 推导 `<engine>-specialist`（Godot→`godot-specialist`，Unity→`unity-specialist`，Unreal→`unreal-specialist`）；如果 `engine.name` 缺失或为空，读取 `.claude/docs/technical-preferences.md` 中 `## Engine Specialists` 章节的 Primary 行
   - 如果未配置引擎（两个来源都未产出引擎），跳过此步，**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 一项跳过却不作声明的检查与一项通过的检查无法区分；读者无法知道从未寻求过引擎指导。
   - 生成 `subagent_type: [primary specialist]`，传入：ADR 的 Engine Compatibility 章节、Decision 章节、Key Interfaces，以及引擎参考文档路径。请他们：
     1. 确认所提议的方法对于锁定版本的引擎是地道的
     2. 标出任何已弃用或在训练截止后发生变更的 API 或模式
     3. 识别当前 ADR 草案中未捕获的引擎专属风险或陷阱
   - 如果专家识别出**阻塞问题**（错误的 API、已弃用的方法、引擎版本不兼容）：相应地修订 Decision 和 Engine Compatibility 章节，然后在继续前与用户确认更改
   - 如果专家只发现**次要说明**：将它们纳入 ADR 的 Risks 小节

**评审模式检查** —— 在生成 TD-ADR 之前应用：
- `solo` → 跳过。注明："TD-ADR skipped — Solo mode." 进入第 5.7 步（GDD 同步检查）。
- `lean` → 跳过（不是 PHASE-GATE）。注明："TD-ADR skipped — Lean mode." 进入第 5.7 步（GDD 同步检查）。
- `full` → 照常生成。

5.6. **技术总监战略评审** —— 在引擎专家验证之后，使用质量闸门 **TD-ADR**（`.claude/docs/director-gates/td-adr.md`）通过 `Agent` 生成 `technical-director`：
   - 传入：ADR 文件路径（或草案内容）、引擎版本、领域、同一领域中的任何现有 ADR
   - TD 验证架构一致性（此决策是否与整个系统一致？）——区别于引擎专家的 API 级检查
   - 遇到 CONCERNS 时：逐字向用户展示，并使用 `director-gates.md` 中的标准选项询问——`Revise flagged items` / `Accept and proceed` / `Discuss further`。仅在 `Revise flagged items` 时修订被标出的 Decision 或 Alternatives 章节。
   - 遇到 REJECT 时：逐字展示阻塞项，并在继续前修订 Decision 或 Alternatives 章节。
   - 修订后的草案仍会通过下面的写入批准到达用户；在此之前不会写入任何内容。`NOT ASSESSED` 回答不是批准——要指明缺失的输入（`director-gates.md`）。

5.7. **GDD 同步检查** —— 在呈现写入批准之前，扫描 "GDD Requirements Addressed" 章节中引用的所有 GDD，
   检查其与 ADR 的 Key Interfaces 和 Decision 章节是否存在命名不一致
   （重命名的信号、API 方法或数据类型）。如果发现任何不一致，在写入批准之前
   立即将其作为**醒目的警告块**呈现——而不是脚注：

```
⚠️ GDD SYNC REQUIRED
[gdd-filename].md uses names this ADR has renamed:
  [old_name] → [new_name_from_adr]
  [old_name_2] → [new_name_2_from_adr]
The GDD must be updated before or alongside writing this ADR to prevent
developers reading the GDD from implementing the wrong interface.
```

**此检查有三种结果，而不是两种。** 上面两种是 "找到" 和 "未找到"；第三种是**无法检查**，
它绝不能走静默分支、渲染得像一个干净结果。

- **未找到** —— 打印一行，不要沉默：
  `GDD sync: checked [N] referenced GDD(s), no naming inconsistencies.`
  静默通过无法与从未运行的检查区分，而这一项
  防止开发者从过时 GDD 实现错误接口。
- **无法检查** —— ADR 没有 `GDD Requirements Addressed` 章节、
  未点名任何 GDD，或点名的 GDD 在磁盘上不存在。打印：
  `GDD sync: NOT ASSESSED — [which reason, and which files]`
  **不要**把没有引用任何 GDD 的 ADR 当作其 GDD 一致的 ADR。
  什么都没比较。
- 只有警告块本身是条件性的；检查始终报告。

5. **写入批准** —— 使用 `AskUserQuestion`：

如果发现了 GDD 同步问题：
- "ADR 草案已完成。你希望如何继续？"
  - [A] 同一次操作中写入 ADR + 更新 GDD
  - [B] 只写入 ADR —— 我手动更新 GDD
  - [C] 还不是 —— 我需要进一步审阅

如果没有 GDD 同步问题：
- "ADR 草案已完成。可以写入吗？"
  - [A] 将 ADR 写入 `docs/architecture/adr-[NNNN]-[slug].md`
  - [B] 还不是 —— 我需要进一步审阅

如果对任一写入选项回答是，则写入文件，必要时创建目录。
对于带 GDD 更新的选项 [A]：还要更新 GDD 文件以使用新名称。

6. **更新架构注册表**

扫描已写入的 ADR，找出应注册的新架构立场：
- 它声称拥有的状态
- 它定义的接口契约（信号签名、方法 API）
- 它声称的性能预算
- 它明确做出的 API 选择
- 它禁止的模式（Consequences → Negative 或显式的 "do not use X"）

呈现候选项：
```
Registry candidates from this ADR:
  NEW state ownership:      player_stamina → stamina-system
  NEW interface contract:   stamina_depleted signal
  NEW performance budget:   stamina-system: 0.5ms/frame
  NEW forbidden pattern:    polling stamina each frame (use signal instead)
  EXISTING (referenced_by update only): player_health → already registered ✅
```

**注册表追加逻辑**：写入 `docs/registry/architecture.yaml` 时，不要假设章节为空。该文件可能已包含本会话中先前 ADR 写入的条目。每次 Edit 调用之前：
1. 读取 `docs/registry/architecture.yaml` 的当前状态
2. 找到正确的章节（state_ownership、interfaces、forbidden_patterns、api_decisions）
3. 如果该章节仍为空列表（`state_ownership: []`），将 `[]` 替换为第一个条目：键单独占一行，条目在其下方按文件注释示例的格式缩进两个空格。在 `[]` 之后追加条目会使文件成为无效 YAML。否则，将新条目追加到该章节最后一个现有条目之后
4. 如果章节已有条目，使用最后一个条目的结尾内容作为 `old_string` 锚点，并在其后追加新条目

**BLOCKING —— 未经用户明确批准，不要写入 `docs/registry/architecture.yaml`。**

使用 `AskUserQuestion` 询问：
- "May I update `docs/registry/architecture.yaml` with these [N] new stances?"
  - 选项："Yes — update the registry"、"Not yet — I want to review the candidates"、"Skip registry update"

仅在用户选择是时才继续。若是：追加新条目。绝不修改现有条目——如果某条立场
正在变更，将旧条目设为 `status: "superseded_by: ADR-[NNNN]"` 并添加新条目。保留引号：
不加引号时，第二个冒号会使文件成为无效 YAML。

写入后，运行 `bash .claude/scripts/registry.sh validate`，并在继续之前修复所有关于本次写入新增
或变更条目的行（DUPLICATE、STATUS 或 LAYOUT 行，UNQUOTED 行（为其点名的值加引号），或其所点名路径的 PATH_MISSING 行）；
对于涉及其他条目的行，向用户点名说明，而不是未经请求就去修复。如果脚本缺失或不打印任何内容，
说明注册表检查未运行，然后对照文件头部的规则重新读取你写入的条目。

---
