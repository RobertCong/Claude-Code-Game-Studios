# /design-system — Phase 4: 逐章节设计

> 属于 `/design-system` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## 4. 逐章节设计

**本文件包含：**

- 章节循环
- 按章节的专项指导
- Section A: Overview（概述）
- Section B: Player Fantasy（玩家幻想）
- Section C: Detailed Design（详细设计：Core Rules、States、Interactions）
- Section D: Formulas（公式）
- Section E: Edge Cases（边界情况）
- Section F: Dependencies（依赖）
- Section G: Tuning Knobs（可调参数）
- Section H: Acceptance Criteria（验收标准）
- 可选章节：Visual/Audio、Game Feel、UI Requirements、Cross-References、Open Questions

**只撰写解析出的层级所要求的章节**（§1）。在 `standard` 下，行走流程覆盖 A（Overview）、
C（Detailed Design）、E（Edge Cases）、F（Dependencies）、H（Acceptance Criteria）——
当系统定义数值规则时再加 D（Formulas）（见 §1；类别只是提示，不是判断依据）；
跳过 B（Player Fantasy）和 G（Tuning Knobs），除非 `workflow_overrides.tuning_knobs: true`
强制包含 G。在 `full` 下，走完全部八个（A–H）。在 `minimal` 下，GDD 是可选的 ——
若自愿撰写，则走标准集合。任何 `system_overrides.<system>` 层级都已在 §1 中并入
解析出的层级。

按顺序走过每个必需章节。对**每个章节**，遵循以下循环：

### 章节循环

```
Context  ->  Questions  ->  Options  ->  Decision  ->  Draft  ->  Approval  ->  Write
```

1. **上下文（Context）**：说明本章节需要包含什么，并暴露依赖 GDD 中约束它的任何
   相关决策。

2. **问题（Questions）**：提出本章节特有的澄清问题。约束性问题使用
   `AskUserQuestion`，开放式探索使用对话文本。

3. **选项（Options）**：若本章节涉及设计选择（而不只是记录成文），提出 2-4 种方案
   并说明优劣。在对话文本中解释理由，然后使用 `AskUserQuestion` 记录决策。

4. **决策（Decision）**：用户选择某个方案或给出自定义方向。

5. **草稿（Draft）**：在对话文本中写出章节内容以供审阅。标记关于尚未设计依赖的
   任何临时假设。

6. **批准（Approval）**：依据解析出的 `modes.automation` 模式
   （`.trae/docs/automation-modes.md`）：

   **在 `collaborative` 模式下**：紧接草稿之后 —— 在同一个响应中 —— 使用
   `AskUserQuestion`。**绝不使用纯文本。绝不跳过这一步。**
   - 提示："批准 [Section Name] 章节吗？"
   - 选项：`[A] Approve — write it to file` / `[B] Make changes — describe what to fix` / `[C] Start over`

   **草稿与批准控件必须在同一个响应中一起出现。如果只有草稿而没有控件，用户会
   停在一个空提示符前、无路可走 —— 这在协作模式下属于协议违规。**

   **在 `guided` 模式下**：草稿之后立即写入章节，并用一行简要说明决定了什么。
   跳过逐章节控件；适用多章节撰写规则（不做逐章节确认）。

   **在 `autonomous` 模式下**：直接写入章节，并调用
   `log_decision`，参数为 `Decision point: Approve [Section Name] section`、
   `Chosen: [A] Approve`、`Category: minor`。

7. **写入（Write）**：使用 Edit 工具用已批准的内容替换占位符。
   **关键**：务必在 `old_string` 中包含章节标题以确保唯一性 —— 绝不要只匹配
   `[To be designed]`，因为多个章节使用同一占位符，而 Edit 工具要求唯一匹配。
   使用以下模式：
   ```
   old_string: "## [Section Name]\n\n[To be designed]"
   new_string: "## [Section Name]\n\n[approved content]"
   ```
   确认写入。

8. **注册表冲突检查（Registry conflict check）**（仅 Sections C 与 D —— Detailed Design 与 Formulas）：
   写入之后，扫描章节内容中出现在注册表里的实体名、物品名、公式名和数值常量。
   对每个匹配：
   - 将刚写入的值与注册表条目比较。
   - 若不同：**在开始下一章节之前立即暴露冲突**。不要静默继续。
     > "Registry conflict: [name] is registered in [source GDD] as [registry_value].
     > This section just wrote [new_value]. Which is correct?"
   - 若是新值（不在注册表中）：将其标记为注册表登记的候选
     （将在 Phase 5 中处理）。

写入每个章节后，用已完成的章节名更新 `production/session-state/active.md`。
使用 Glob 检查文件是否存在 —— 若不存在用 Write 创建，若存在用 Edit 更新。

### 按章节的专项指导

每个章节都有独特的设计考量，可能受益于专家代理：

**每次跳过的派生都会被公告。** 当某章节下方的评审模式检查跳过其专家时 —— 在
`lean` 和 `solo` 下都是如此 —— 请打印该章节的说明及其运行模式，例如
"`creative-director` not consulted — Lean mode. Review manually before production."
任何未咨询专家而撰写的章节，无论被哪种模式跳过，都必须在输出中说明。

---

### Section A: Overview（概述）

**目标**：让一个陌生人读一段就能理解。

**在构建控件之前先推导推荐选项**：从系统索引读取系统的类别与层级（Phase 2 已在
上下文中），然后确定每个标签页的推荐选项：
- **"Framing" 标签页**：依据 `Category` 列（`Core · Gameplay · Progression · Economy · Persistence · UI · Audio · Narrative · Meta`）。面向玩家的 —— `Gameplay`、`UI`、`Audio`、`Narrative` → 推荐 `[C] Both`。内部的 —— `Core`、`Persistence`、`Meta` → 推荐 `[A]`。混合的 —— `Economy`、`Progression` → `[C] Both`。**当 Layer 与 Category 冲突时的取舍**（`Foundation` 层的 `Gameplay` 系统是常见情形）：**以 Category 为准** —— Framing 描述的是本章节*关于什么*，而面向玩家的系统无论位于依赖图的何处都保持面向玩家。
- **"ADR ref" 标签页**：Glob `docs/architecture/adr-*.md`，并在任何 ADR 的 GDD Requirements 章节中 grep 系统名称。若找到匹配的 ADR → 推荐 `[A] Yes — cite the ADR`。若未找到 → 推荐 `[B] No`。
- **"Fantasy" 标签页**：Foundation/Infrastructure 层 → 推荐 `[B] No`。其他所有类别 → 推荐 `[A] Yes`。

在每个标签页相应选项文本后追加 `(Recommended)`。

**框架性问题（在起草之前询问）**：使用带多标签页控件的 `AskUserQuestion`：
- 标签页 "Framing" —— "概览应如何框定这个系统？" 选项：`[A] As a data/infrastructure layer (technical framing)` / `[B] Through its player-facing effect (design framing)` / `[C] Both — describe the data layer and its player impact`
- 标签页 "ADR ref" —— "概览是否应引用该系统现有的 ADR？" 选项：`[A] Yes — cite the ADR for implementation details` / `[B] No — keep the GDD at pure design level`
- 标签页 "Fantasy" —— "这个系统是否有值得陈述的玩家幻想？" 选项：`[A] Yes — players feel it directly` / `[B] No — pure infrastructure, players feel what it enables`

用这些答案来塑造草稿。**在 `collaborative` 模式下，不要自己回答这些问题并自动
起草** —— 控件必须出现。在 `guided` 和 `autonomous` 下，这是次要的框架决策：
选择上面推导出的推荐选项，用一行说明，然后继续（这正是预先推导推荐的全部意义）。
这适用于本次章节行走中每个"在起草之前询问"的控件，而不仅是这一个。

**要问的问题**：
- 用一句话说，这个系统是什么？
- 玩家如何与它交互？（主动/被动/自动）
- 这个系统为何存在 —— 没有它游戏会失去什么？

**交叉引用**：检查描述是否与系统索引对它的描述一致。标出差异。

**设计与实现的边界**：概览问题必须停留在行为层面 —— 系统*做什么*，而不是
*如何构建*。如果在撰写 Overview 期间出现实现问题（例如"这应该用 Autoload 单例
还是信号总线？"），记为"→ 成为一条 ADR"然后继续。实现模式属于
`/architecture-decision`，而不属于 GDD。GDD 描述行为；ADR 描述为实现它所采用的
技术方案。

---

### Section B: Player Fantasy（玩家幻想）

**目标**：情感目标 —— 玩家应该*感受到*什么。

**在构建控件之前先推导推荐选项**：从 Phase 2 上下文读取系统的类别与层级：
依据 `Category` 列（`Core · Gameplay · Progression · Economy · Persistence · UI · Audio · Narrative · Meta`）：
- 面向玩家的 —— `Gameplay`、`UI`、`Audio`、`Narrative` → 推荐 `[A] Direct`
- 内部的 —— `Core`、`Persistence`、`Meta` → 推荐 `[B] Indirect`
- 混合的 —— `Economy`、`Progression` → 推荐 `[C] Both`

**当 Layer 与 Category 冲突时，以 Category 为准** —— 与上文 Framing 标签页相同的
取舍规则。

在相应选项文本后追加 `(Recommended)`。

**框架性问题（在起草之前询问）**：使用 `AskUserQuestion`：
- 提示："这个系统是玩家直接参与的东西，还是他们间接体验的基础设施？"
- 选项：`[A] Direct — player actively uses or feels this system` / `[B] Indirect — player experiences the effects, not the system` / `[C] Both — has a direct interaction layer and infrastructure beneath it`

用答案恰当地框定 Player Fantasy 章节。不要假定答案。

**要问的问题**：
- 这个系统服务于什么情感或力量幻想？
- 哪些参考游戏精准呈现了这种感觉？具体是什么创造了它？
- 这是"你乐于参与的系统"还是"你不会注意到的基础设施"？

**交叉引用**：必须与游戏支柱一致。如果该系统服务于某个支柱，请引用相关支柱文本。

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加说明："`creative-director` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非这是实施风险高的章节（仅 Sections D 与 H）。其他章节不咨询代理直接起草。
- `full` → 按下文所述派生。

**代理委派（强制）**：在给出框架性答案之后、起草之前，通过 `Agent` 派生
`creative-director`：
- 提供：系统名称、框架性答案（direct/indirect/both）、游戏支柱、用户提到的任何参考游戏、游戏概念摘要
- 询问："为这个系统塑造 Player Fantasy。它应服务于什么情感或力量幻想？我们应锚定哪个玩家时刻？什么样的语气与语言契合游戏已确立的感觉？要具体 —— 给我 2-3 个候选框定。"
- 收集 creative-director 的框定，并将它们与草稿一起呈现给用户。

**不要在没有首先咨询 `creative-director` 的情况下起草 Section B。** 框架性答案
告诉我们这是*哪种*幻想；creative-director 塑造*如何描述它* —— 语气、语言、要锚定
的具体玩家时刻。

---

### Section C: Detailed Design（详细设计：Core Rules、States、Interactions）

**目标**：一份程序员无需提问即可实现的无歧义规格。

这通常是最大的章节。把它拆成子章节：

1. **Core Rules**：基础机制。顺序流程使用编号规则，属性使用要点。
2. **States and Transitions**：若系统有状态，绘制每个状态和每个有效转换。使用表格。
3. **Interactions with Other Systems**：对每个依赖（上游与下游），说明流入什么数据、
   流出什么数据，以及谁拥有该接口。

**要问的问题**：
- 带我逐步走过这个系统的一次典型使用
- 玩家面临哪些决策点？
- 玩家不能做什么？（约束与能力同等重要）

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加点名说明："`[the Section 6 routing table's Primary and Supporting Agents for this category]` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非这是实施风险高的章节（仅 Sections D 与 H）。其他章节不咨询代理直接起草。
- `full` → 按下文所述派生。

**代理委派（强制）**：在起草 Section C 之前，通过 `Agent` 并行派生专家代理：
- 在路由表中查找系统类别（本技能的 Section 6）
- 派生该类别列出的 Primary Agent 与 Supporting Agent(s)
- 向每个代理提供：系统名称、游戏概念摘要、支柱集合、依赖 GDD 摘录、正在处理的特定章节
- 在起草之前收集它们的发现
- 通过 `AskUserQuestion` 向用户暴露代理之间的任何分歧
- 仅在收到专家输入后才起草

**不要在没有首先咨询相应专家的情况下起草 Section C。** 由 `systems-designer`
审阅规则与机制，能发现主会话无法发现的设计缺口。

**交叉引用**：对列出的每个交互，核实它与依赖 GDD 的规定一致。如果某个依赖定义了
一个值或公式，而本系统期望不同的内容，标出该冲突。

---

### Section D: Formulas（公式）

**目标**：每个数学公式，都定义变量、指定范围并注明边界情况。

**完成度引导 —— 每个公式都必须以这个确切结构开头：**

```
The [formula_name] formula is defined as:

`[formula_name] = [expression]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| [name] | float/int | [min–max] | data file / calculated / constant | [what it represents] |

**Output Range:** [min] to [max] under normal play; [behaviour at extremes]
**Example:** [worked example with real numbers]
```

不要写 `[Formula TBD]`，也不要用行文描述公式而不给变量表。没有定义变量的公式
只能靠猜测来实现。

> **这些列与 `templates/guidance/game-design-document-guide.md` 完全一致；不要
> 重命名它们。** `Source` 列把编码规范规则*"gameplay values must be data-driven
> (external config), never hardcoded"* 带入设计文档 —— 标记为 `data file` 的变量是
> 可调参数，标记为 `constant` 的是刻意例外，而在 `Symbol` 列下这种区别是看不见的。
> 若有帮助，就把符号放在表达式本身中。

**要问的问题**：
- 这个系统执行哪些核心计算？
- 缩放应该是线性的、对数的，还是分段的？
- 在前期/中期/后期，输出范围应该是什么？

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加说明："`systems-designer` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非这是实施风险高的章节（仅 Sections D 与 H）。其他章节不咨询代理直接起草。
- `full` → 按下文所述派生。

**代理委派（强制）**：在提出任何公式或平衡性数值之前，通过 `Agent` 并行派生专家代理：
- **始终派生 `systems-designer`**：提供 Section C 中的 Core Rules、用户的调优目标、依赖 GDD 中的平衡性上下文。请他们提出带变量表与输出范围的公式。
- **对于经济/成本系统，还要派生 `economy-designer`**：提供放置成本、升级成本意图和进度目标。请他们验证成本曲线与比率。
- 通过 `AskUserQuestion` 将专家的提议呈现给用户审阅
- 用户做决定；主会话写入文件
- **不要在没有专家输入的情况下编造公式值或平衡性数字。** 没有平衡性设计专长的用户无法评估原始数字 —— 他们需要专家的推理。

**交叉引用**：如果某个依赖 GDD 定义的公式输出会流入本系统，请显式引用它。
不要重新发明 —— 去连接。

---

### Section E: Edge Cases（边界情况）

**目标**：显式处理异常情形，使它们不会变成缺陷。

**完成度引导 —— 每个边界情况都按以下格式撰写：**
- **If [condition]**：[exact outcome]。[rationale if non-obvious]

示例（术语按游戏领域调整）：
- **If [resource] reaches 0 while [protective condition] is active**：保持最小值直到条件结束，然后施加后果。
- **If two [triggers/events] fire simultaneously**：按 [defined priority order] 解决；平局使用 [defined tiebreak rule]。

不要写诸如"适当处理"之类含糊的条目 —— 每条都必须指明确切条件和确切解决方案。
没有解决方案的边界情况是一个未决的设计问题，而不是规格。

**要问的问题**：
- 当值为零时会发生什么？达到最大值时？超出范围时？
- 当两条规则同时适用时会发生什么？
- 如果玩家发现了意外的交互会发生什么？（识别退化策略）

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加说明："`systems-designer` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非这是实施风险高的章节（仅 Sections D 与 H）。其他章节不咨询代理直接起草。
- `full` → 按下文所述派生。

**代理委派（强制）**：在最终确定边界情况之前，通过 `Agent` 派生 `systems-designer`。提供：已完成的 Sections C 与 D，并请他们从公式与规则空间中识别主会话可能遗漏的边界情况。对于叙事系统，还要派生 `narrative-director`。呈现他们的发现，并询问用户要纳入哪些。

**交叉引用**：对照依赖 GDD 检查边界情况。如果某个依赖定义了本系统可能违反的
下限、上限或解决规则，标出它。

---

### Section F: Dependencies（依赖）

**目标**：标明每个系统连接及其方向与性质。

本章节在上下文收集阶段已部分预填。呈现来自系统索引的已知依赖，并询问：
- 有没有我遗漏的依赖？
- 对每个依赖，具体的数据接口是什么？
- 哪些依赖是硬依赖（没有它系统无法运作），哪些是软依赖
  （有它会增强，但没有也能工作）？

**交叉引用**：本章节必须双向一致。如果本系统列出"依赖 Combat"，那么 Combat GDD
应列出"被 [this system] 依赖"。标出任何单向依赖以便更正。

---

### Section G: Tuning Knobs（可调参数）

**目标**：每个设计师可调整的值，及其安全范围和极端行为。

**要问的问题**：
- 哪些值应让设计师无需改代码即可调整？
- 对每个可调参数，设得太高会坏什么？太低会坏什么？
- 哪些可调参数相互影响？（改变 A 会让 B 失去意义）

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。从 Section D 的变量表自行推导可调参数。添加说明："`systems-designer` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非 Section D 定义的公式中可调参数相互影响（改变一个会让另一个失效）。
- `full` → 按下文所述委派。

**代理委派**：如果公式复杂，委派给 `systems-designer` 从公式变量推导可调参数。

> 此委派点名 `systems-designer`，而 Section D 的守卫已经告诉 `solo` 运行要跳过
> 同一代理。没有上面的守卫，`solo` 会为公式跳过专家，随后又为从这些相同公式推导出
> 的可调参数去咨询它。

**交叉引用**：如果依赖 GDD 列出了影响本系统的可调参数，请在此引用它们。不要创建
重复的可调参数 —— 指向唯一事实来源。

---

### Section H: Acceptance Criteria（验收标准）

**目标**：可测试的条件，用以证明系统按设计工作。

**完成度引导 —— 每条标准都按 Given-When-Then 格式撰写：**
- **GIVEN** [initial state], **WHEN** [action or trigger], **THEN** [measurable outcome]

示例（术语按游戏领域调整）：
- **GIVEN** [initial state], **WHEN** [player action or system trigger], **THEN** [specific measurable outcome].
- **GIVEN** [a constraint is active], **WHEN** [player attempts an action], **THEN** [feedback shown and action result].

至少包含：Section C 中每条核心规则一条标准，Section D 中每个公式一条标准。
不要写"系统按设计工作" —— 每条标准都必须能由 QA 测试人员在不阅读 GDD 的情况下
独立验证。

> **当 Section D 未被撰写时**（本层级下 Formulas 为可选，因为系统不定义数值规则），
> 没有公式需要覆盖，标准只来自 Section C —— 用一行说明这一点，而不是静默地少写
> 标准。**如果 Section D 被跳过，但 Section C 陈述了某个数量** —— 速率、阈值、
> 成本或曲线 —— 那就是 §1 的测试在事后被满足：停下来，告诉用户本系统需要 Formulas，
> 并在最终确定标准之前撰写它。标准无法验证 GDD 从未定义的数字。
>
> **该升级仅在 `standard` 下适用。** 它重新运行 §1 的*条件性* Formulas 测试，而
> §1 在 `minimal` 下直接禁用了该条件性 —— *"the conditional Formulas rule does NOT
> re-apply at minimal"*。在 `minimal` 下，Section C 中出现数量是预期的，且**不会**
> 把 Formulas 拉回来：将值内联写在 Core Rules 中，使其保持可实现，然后继续。
> 在 `full` 下，Section D 无条件必需，因此不会出现该情形。若不在这个范围内理解，
> 这两条规则对所有定义了速率的 `minimal` 系统都会互相矛盾 —— 而那是大多数系统。

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加说明："`qa-lead` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非这是实施风险高的章节（仅 Sections D 与 H）。其他章节不咨询代理直接起草。
- `full` → 按下文所述派生。

**代理委派（强制）**：在最终确定验收标准之前，通过 `Agent` 派生 `qa-lead`。提供：已完成的 GDD Sections C、D、E，并请他们验证标准可独立测试且覆盖所有核心规则与公式。向用户暴露任何缺口或不可测试的标准。

**要问的问题**：
- 证明它能工作的最小测试集是什么？
- 这个系统获得多少性能预算？（帧时间、内存）
- QA 测试人员会先检查什么？

**交叉引用**：纳入验证跨系统交互可工作的标准，而不只是孤立地验证本系统。

---

### 可选章节：Visual/Audio、Game Feel、UI Requirements、Cross-References、Open Questions

这五个是模板章节，**不**在 §1 的八个之列。它们在此处受管辖，而不是由层级管辖：
§1 的按层级列表决定*必需*集合，本块独立决定其余部分。因此在这里添加章节绝不会
改变某一层级的章节数量。

Visual/Audio 与 Game Feel 对某些类别是**必需**的 —— 并非可选。在询问之前先确定
要求级别：

**依据 `systems-index.md` 的 `Category` 列** —— `templates/systems-index.md` 定义的
九个值。这九个值每一个都在下面恰好出现一次，因此没有任何一个会漏掉：

**Visual/Audio 对以下类别是必需（强制 —— 不提供跳过选项）：**
- `Gameplay` —— 战斗、AI、潜行、移动、交互：玩家看到其结算的一切
- `UI` —— HUD、菜单、背包界面、对话 UI
- `Narrative` —— 对话、任务、过场动画、背景故事呈现
- `Audio` —— 按定义

> **`Gameplay` 属于这个列表。** 它是 `/map-systems` 分配给战斗、AI 和移动的类别 ——
> 多数动作游戏中最大的桶。

对于必需的系统：**在起草本章节之前，通过 `Agent` 派生 `art-director`**。提供：系统名称、游戏概念、游戏支柱、美术圣经第 1–4 节（若存在）。请他们说明：(1) 本系统事件所需的 VFX 与视觉反馈要求，(2) 任何动画或视觉风格约束，(3) 美术圣经中哪些原则最直接适用于本系统。呈现他们的输出；**不要**把视觉系统章节留作 `[To be designed]`。

**评审模式检查**（在派生之前应用）：
- `solo` → 跳过此代理派生。不咨询专家直接起草章节。添加说明："`art-director` not consulted — Solo mode. Review manually before production."
- `lean` → 跳过，除非本系统的视觉反馈是其核心（某个 `Gameplay` 或 `UI` 系统，玩家靠读取其事件来游玩）。否则不咨询代理直接起草。
- `full` → 按上文所述派生。

> 即使上面的派生被表述为强制（*"do NOT leave this section as `[To be designed]`"*），
> 本块仍然适用。`director-gates.md` 的*"solo → no director gates anywhere"* 管的是
> 总监**质量闸门**，而不是专家派生，因此它不能决定此处是否派生 —— 本块才能。

**Game Feel 对 `Gameplay` 和 `UI` 是必需（强制 —— 不提供跳过选项）** —— 这些类别
的系统由玩家直接操作，其中响应性、重量感和干脆感是设计目标而非打磨项。对其余七个
类别它是可选的。模板的指南本身就论证了这一点：手感*"drives animation budgets,
input handling architecture, and hitbox timing. Retrofitting feel targets after
implementation is expensive."*

**当 Dependencies 章节提及另一个 GDD 时，Cross-References 就是必需的。** 该规则
是推导出来的，而不是按类别设定的：如果本文档在任何地方引用了另一个系统的机制、
值或规则，该引用就属于这张表。当 Dependencies 未提及任何内容时，写
*"None — this system references no other GDD"*，而不是留下占位符。
`/review-all-gdds` Phase 2c 会在该表存在时读取它。

对于其余五个类别 —— `Core`、`Progression`、`Economy`、`Persistence`、`Meta` ——
Visual/Audio 是可选的：在必需章节之后提供可选章节。

> **在 `minimal` 下，不强制任何东西。** §1 说自愿撰写的 `minimal` GDD 是
> *"exactly the 5 standard sections"*，这与把 Visual/Audio 或 Game Feel 设为强制的
> 类别规则相矛盾。§1 优先：在 `minimal` 下两者都降为可选，整组章节都走下面的控件。

使用 `AskUserQuestion`：
- "本工作流层级要求的章节已完成。你还想定义其余模板章节中的哪些？"
  - 选项："All of them", "Just Cross-References and open questions", "Skip — I'll add these later"
  - 问题中只列出仍然未决的章节：Visual/Audio、Game
    Feel、UI Requirements、Cross-References、Open Questions，**减去**本系统类别或
    依赖已在上文使其必需的任何章节。向用户提供跳过某个规则刚刚设为必需的章节，
    正是必需章节被跳过的原因。
  - **推荐选项**：当系统有任何依赖、UI 界面或面向玩家的反馈时选 "All of them"；
    否则选 "Just Cross-References and open questions"。`autonomous` 需要一个已标记
    的推荐项来作出选择：没有它，无人值守运行就无从选择，会跳过。

  此处**不要**陈述章节数量。必需集合因层级而异
  （§1：`full` 下 8 个，`standard` 下 5 个 + 条件性 Formulas，自愿 `minimal` 下
  5 个），因此在 `full` 以下的每次运行中，"8 required sections are complete" 这类
  固定说法都是错的 —— 它会告诉 `standard` 层级的用户存在 8 个章节，而实际只撰写了
  6 个。

对于 **Visual/Audio**（非必需系统）：若需要细节，与 `art-director` 和
`audio-director` 协调。在 GDD 阶段，通常一段简短说明就足够。

> **Asset Spec 标记**：当 Visual/Audio 章节写入了真实内容后，输出此提示：
> "📌 **Asset Spec** —— Visual/Audio 需求已定义。美术圣经批准后，运行 `/asset-spec system:[system-name]`，从本章节生成逐资源的视觉描述、尺寸和生成提示词。"

对于 **UI Requirements**：复杂 UI 系统与 `ux-designer` 协调。
写完本章节后，检查它是否包含真实内容（而不只是 `[To be designed]` 或一句说明本系统
没有 UI 的注记）。如果确实有真实 UI 需求，立即输出此标记：

> **📌 UX Flag — [System Name]**：本系统有 UI 需求。在 Phase 4
> （预制作）中，在编写史诗**之前**，运行 `/ux-design` 为每个界面或
> 本系统贡献的 HUD 元素创建 UX 规格。引用 UI 的用户故事应引用
> `design/ux/[screen].md`，而不是直接引用 GDD。
>
> 如果你更新系统索引，请在本系统的索引条目中注明这一点。

对于 **Open Questions**：记录设计过程中出现但未完全解决的任何事项。每个问题都应
有负责人和目标解决日期。

---
