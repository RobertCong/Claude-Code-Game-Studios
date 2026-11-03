---
name: reverse-document
description: "从现有实现反向生成缺失的设计或架构文档 —— 从代码和原型倒推。"
argument-hint: "<type> <path> (e.g., 'design src/gameplay/combat' or 'architecture Assets/Scripts/Core')"
user-invocable: true
# Read-only diagnostic skill — no specialist agent delegation needed
---

# 反向文档

本技能分析现有实现（代码、原型、系统）并生成
相应的设计或架构文档。使用场景：
- 你在没有先写设计文档的情况下构建了某个功能
- 你接手了一个没有文档的代码库
- 你制作了某个机制的雏形，需要将其正式化
- 你需要记录现有代码背后的"为什么"

---

## 工作流

## Phase 1: 解析参数

**格式**：`/reverse-document <type> <path>`

**类型选项**：
- `design` → 生成游戏设计文档（GDD 节）
- `architecture` → 生成架构决策记录（ADR）
- `concept` → 从原型生成概念文档

**路径**：要分析的目录或文件，位于代码根目录下 —— Godot 为 `src/`，
Unity 为 `Assets/`，Unreal 为 `Source/<Module>/`（`.trae/docs/code-root-resolution.md`）
- `src/gameplay/combat/` → 所有战斗相关代码（Godot）
- `Assets/Scripts/Core/EventSystem.cs` → 特定文件（Unity）
- `Source/MyGame/Private/AI/` → 模块文件夹（Unreal）
- `prototypes/stealth-mech/` → 原型目录

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys workflow,system_overrides,automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

已在上一步解析 —— 直接使用。无解析块 → 使用
`.trae/docs/config-resolution.md` 中的默认值。

**解析目标系统的工作流层级**：将 `<path>` 映射到系统
名称，然后如果上面的块列出了该系统，则使用该系统的 `system_overrides` 行，
否则使用项目的 `workflow` 值。它决定生成多少文档 ——
见 Phase 5。每个层级的语义见
`.trae/docs/workflow-modes.md`。

> **要解析层级 —— 不要假设它。** `workflow-modes.md` 定义了每个层级
> *意味着什么*，但它无法说明*本项目*设定的是什么；要从
> 上面的块中获取。这里的后果很大 —— 在 `full` 下本技能
> 会写出 8 节 GDD，而在 `minimal` 下写的是一页简报，因此错误的层级
> 会完全产出错误的产物。

**示例**：
```bash
/reverse-document design src/gameplay/magic-system
/reverse-document architecture Source/MyGame/Private/EntityComponent
/reverse-document concept prototypes/vehicle-combat
```

## Phase 2: 分析实现

**阅读并理解代码/原型**：

**对于设计文档（GDD）：**
- 识别机制、规则、公式
- 提取玩法数值（伤害、冷却、范围）
- 查找状态机、能力系统、进度体系
- 检测代码中处理的边界用例
- 映射依赖关系（哪些系统相互交互？）

**对于架构文档（ADR）：**
- 识别模式（ECS、单例、观察者等）
- 理解技术决策（线程、序列化等）
- 映射依赖与耦合
- 评估性能特征
- 查找约束与取舍

**对于概念文档（原型分析）：**
- 识别核心机制
- 提取涌现的玩法模式
- 记录哪些有效、哪些无效
- 找出技术可行性方面的洞见
- 记录玩家幻想 / 手感

## Phase 3: 提出澄清问题

**不要**只是描述代码。要**询问**意图：

**设计问题**：
- "我看到一个在[活动]期间消耗的[资源]系统。这是为了：
  - 节奏控制（防止滥用）？
  - 资源管理（策略深度）？
  - 还是其他目的？"
- "[机制]似乎是核心。它是核心支柱，还是辅助功能？"
- "[数值]随[因子]指数缩放。是有意设计，还是需要重新平衡？"

**架构问题**：
- "你使用了服务定位器模式。选择它是为了：
  - 可测试性（Mock 依赖）？
  - 解耦（减少硬引用）？
  - 还是从现有代码继承而来？"
- "我看到的是手动内存管理而非智能指针。是性能要求，还是历史遗留？"

**概念问题**：
- "原型强调潜行而非战斗。这是预期的支柱吗？"
- "玩家似乎在利用抓钩加速。这是特性还是缺陷？"

## Phase 3b: 充分性检查 —— 这里有足够的内容可记录吗？

**在 Phase 4 之前运行此检查，若不通过则在此停止。** 本技能从实现中
推断设计，因此当实现很单薄时，就没有可推断的
*来源* —— 而下面的模板会欣然接受编造的内容，因为它的每个节
都是必填的。

统计 Phase 2 实际找到了什么：

| 信号 | 计入标准 |
|---|---|
| 机制 | 具有可观察规则的具名行为 —— 不是桩，不是空类 |
| 公式 | 从输入计算玩法数值的表达式 |
| 数值 | 有使用点的调参常量 |

**如果三项计数都为零，或目标路径的非样板代码少于约 20 行，
停止并说明：**

> "`[path]` 不包含足够的实现可供反向文档化。
> 找到：[N] 个机制，[N] 个公式，[N] 个调参数值。
> 反向文档化从行为推断设计；没有可读的行为，
> 我产出的任何内容都会是披着设计文档格式的臆造。
> 如果设计只存在于你的头脑中，`/design-system [name]` 才是
> 捕获它的技能 —— 它通过询问而非推断。"

**不要靠填充其余部分来处理部分计数。** 一个有
两个机制但没有公式的路径，得到的文档会有两个机制和一条明确的
`FORMULAS DISCOVERED: none found in the source` —— 见 Phase 4。

## Phase 4: 呈现发现

起草之前，展示你发现了什么：

```
I've analyzed [path]/. Here's what I found:

MECHANICS IMPLEMENTED:
- [mechanic-a] with [property] (e.g. timing windows, cooldowns)
- [mechanic-b] (e.g. interaction between two states)
- [resource] system (depletes on [action], regens on [condition])
- [state] system (builds up, triggers [effect])

FORMULAS DISCOVERED:
- [Output] = [formula using discovered variables]
- [Secondary output] = [formula]

UNCLEAR INTENT AREAS:
1. [Resource] system — pacing or resource management?
2. [Mechanic] — core pillar or supporting feature?
3. [Value] scaling — intentional design or needs tuning?

Before I draft the design doc, could you clarify these points?
```

> **上方的每一节都可能为空，而为空的节必须说明这一点。** 在该标题下写
> `none found in the source` —— 绝不省略标题（那会
> 读作"没有查找过"），也绝不根据这类系统通常有什么来填充它。
> 方括号中的行是*形状*，不是配额：一个只有一个
> 机制的来源产出一行，而不是四行。
>
> 这一点在这里比在报告中更重要，因为本技能的输出不是
> 报告 —— 而是**设计文档**，`/design-review`、`/create-epics` 和
> `/create-stories` 会将其读作已撰写意图的陈述。GDD 中一个编造的
> 公式不会停留在文档错误；它会变成一项需求，
> 然后变成一个用户故事，然后变成为满足它而编写的代码。

等待用户澄清意图后再起草。

**如果用户没有回答 `UNCLEAR INTENT AREAS` 中的问题，也不要照样起草
已解决的版本。** 这些问题之所以存在，是因为**代码无法告诉你
为什么** —— 它记录构建了什么，从不记录意图是什么，而二者之间的差距
正是设计文档的全部内容。未回答的项会原样带入草稿作为开放问题，
在文档中标记为
`INTENT UNKNOWN — inferred from implementation, not confirmed`。把推断的
意图当作已确定的意图来呈现，正是本技能最典型的失败模式。

## Phase 5: 使用模板起草文档

根据类型使用相应模板：

| 类型 | 模板 | 输出路径 |
|------|----------|-------------|
| `design` | `templates/design-doc-from-implementation.md` | `design/gdd/[system-name].md` |
| `architecture` | `templates/architecture-doc-from-code.md` | `docs/architecture/[decision-name].md` |
| `concept` | `templates/concept-doc-from-prototype.md` | `prototypes/[name]/CONCEPT.md` 或 `design/concepts/[name].md` |

**`design` 输出随工作流层级变化**（在 Phase 1 解析）：
- **`full`** —— 生成完整的 8 节 GDD。
- **`standard`** —— 生成 5 节 GDD（Overview、Detailed Design、Edge Cases、
  Dependencies、Acceptance Criteria；当恢复出的系统定义了
  数值规则时 + Formulas）。跳过 Player Fantasy 和 Tuning Knobs。
- **`minimal`** —— 生成一页格式的**游戏简报**
  （`.trae/docs/templates/game-brief.md`），而不是 GDD。对于整个游戏
  （路径就是代码根目录本身）写 `design/game-brief.md`；对于单个
  反向工程的系统写
  `design/[system-name]-brief.md`。

（`architecture` 和 `concept` 输出与层级无关。）

**草稿结构**：
- 记录**存在什么**（机制、模式、实现）
- 记录**为什么存在**（与用户澄清的意图）
- 识别**缺失什么**（未处理的边界用例、设计缺口）
- 标记**后续工作**（平衡性调参、缺失功能）

### 标记来源 —— 必填，位于本技能写出的每份文档顶部

这里产出的文档会以相同的路径、相同的格式，落在一名
设计师手写文档所在的位置，而**每个下游消费者都一视同仁地看待二者**。
`/design-review` 检查它的完整性，`/create-epics`
从它派生史诗，`/create-stories` 将其行转化为验收
标准。没有任何环节会问它来自哪里。

这一差异不是表面的：亲手撰写的 GDD 陈述**意图**，而这一份
陈述**观察到的行为加推断**。当二者不一致时，第一种情况下需要更改的是代码，
第二种情况下是文档 —— 而读者无法分辨自己手中是哪一种，
除非文档自己说明。

在标题正下方输出：

```markdown
> **Reverse-documented from implementation** — generated by `/reverse-document`
> from `[path]` on `[date]`, at commit `[short-sha]`.
> This records what the code **does**; intent marked `INTENT UNKNOWN` below was
> inferred, not confirmed by the author. Where this document and the code
> disagree, do not assume the document is the requirement.
```

修订时保留该横幅。如果人类之后确认了意图并采纳
该文档为已撰写的设计，移除它是他们的明确行为 —— 而不是
下一次编辑的副作用。

## Phase 6: 展示草稿并请求批准

**协作协议**：
```
I've drafted the [system-name] design doc based on your code and clarifications.

[Show key sections: Overview, Mechanics, Formulas, Design Intent]

ADDITIONS I MADE:
- Documented [mechanic] as "[intent]" per your clarification
- Added edge cases not in code (e.g., what if [resource] hits 0 mid-[action]?)
- Flagged balance concern: [scaling type] scaling at [boundary condition]

SECTIONS MARKED AS INCOMPLETE:
- "[System] interaction with [other-system]" (not fully implemented yet)
- "[Variant or feature]" (only [subset] implemented so far)

May I write this to [output path]?
```

在提示中使用层级正确的输出路径：`full`/`standard` GDD 用
`design/gdd/[system-name].md`，而 `minimal` 简报用 `design/[system-name]-brief.md`。

**在 `collaborative` 下** —— 等待批准；用户可能在写入前
请求更改。**在 `guided` 下** —— 这是一个*新*文件，因此 `automation-modes.md:81`
仍会询问它（"May I write?" 仅对新文件询问）；如果目标
已存在，展示差异并继续，无需等待明确的
"yes"。**在 `autonomous` 下** —— 直接写入并记录决策。

## Phase 7: 写入带元数据的文档

获得批准后，写入带有特殊标记的文件：

```markdown
---
status: reverse-documented
source: [path/]
date: [today]
verified-by: [User name]
---

# [System Name] Design

> **Note**: This document was reverse-engineered from the existing implementation.
> It captures current behavior and clarified design intent. Some sections may be
> incomplete where implementation is partial or intent was unclear.

[Rest of document...]
```

## Phase 8: 标记后续工作

写入之后，建议后续步骤：

```
✅ Written to design/gdd/combat-system.md

FOLLOW-UP RECOMMENDED:
1. Run /balance-check on combat formulas (exponential scaling concern)
2. Create ADR for stamina system architecture decision
3. Implement missing edge cases:
   - Stamina depletion mid-combo behavior
   - Stagger state during dodge
4. Extend design doc when weapon variety is implemented

Would you like me to tackle any of these now?
```

---

## 模板选择逻辑

| 如果分析的是…… | 使用模板…… | 原因…… |
|----------------|-----------------|------------|
| `<code root>/gameplay/*` | design-doc-from-implementation.md | 玩法机制 → GDD |
| `<code root>/core/*`, `<code root>/ai/*` | architecture-doc-from-code.md | 核心系统 → ADR |
| `prototypes/*` | concept-doc-from-prototype.md | 实验 → 概念文档 |
| `<code root>/networking/*` | architecture-doc-from-code.md | 技术系统 → ADR |
| `<code root>/ui/*` | design-doc-from-implementation.md | UI/UX → 设计规格 |

---

## 示例会话：反向文档化一个系统

```
User: /reverse-document design <code root>/gameplay/[system]

Agent: I'll analyze your [system] implementation to create a design doc.
       [Reads code, discovers mechanics, formulas]

Agent: I've analyzed <code root>/gameplay/[system]/. Here's what I found:
       [Shows mechanics, formulas, unclear areas]

       Before drafting, could you clarify:
       1. [Resource] system intent?
       2. Is [mechanic] a core pillar?
       3. [Value] scaling — intentional or needs tuning?

User: 1. [Resource] is for pacing, prevent [unwanted behavior]
      2. [Mechanic] is core — I want [design intent]
      3. Yeah, exponential is too much, should be linear

Agent: Perfect, that clarifies the vision. Let me draft the design doc.
       [Shows draft with clarified intent]

       May I write this to design/gdd/[system-name].md?

User: Yes, write it.

Agent: ✅ Written to design/gdd/[system-name].md
       ✅ Marked as [REVERSE-DOCUMENTED]
       ✅ Flagged [value] scaling for rebalancing

       Next steps:
       - Update [formula] to [corrected scaling]
       - Run /balance-check to validate [curve]
       - Document [mechanic] as core pillar in game-pillars.md
```

---

## 协作协议

本技能遵循协作式设计原则：

1. **先分析**：阅读代码，理解实现
2. **询问意图**：问"为什么"，而不仅是"是什么"
3. **呈现发现**：展示发现，突出不清楚的地方
4. **用户澄清**：区分意图与偶然
5. **起草文档**：基于现实 + 意图创建文档
6. **展示草稿**：显示关键节，解释补充内容
7. **获得批准**："May I write to [filepath]?" 若批准：结论：**COMPLETE** —— 文档已生成。若拒绝：结论：**BLOCKED** —— 用户拒绝写入。
8. **标记后续**：建议相关工作，不要自动执行

**绝不假设意图。记录"为什么"之前始终询问。**