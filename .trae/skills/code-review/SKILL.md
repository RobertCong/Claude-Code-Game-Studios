---
name: code-review
description: "架构级代码评审 —— 编码规范、SOLID、可测试性、性能关注点。"
argument-hint: "[path-to-file-or-directory]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash(git log *), Agent, AskUserQuestion, Bash(bash "*/.claude/skills/code-review/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

# 代码评审



每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

## 输入不足 —— 在产出任何报告之前先检查这一点

**如果本技能所需的输入不存在，答案就是"无法运行" ——
而不是一份填好的报告。** 先检查，若检查失败则停止。

1. 列出本技能读取的输入（数据文件、既往报告、性能剖析器输出、
   测试结果、注册表、源代码）。
2. 对每一项，记录 `FOUND` 或 `ABSENT` —— 而不是"假设存在"。
3. 如果某个节所需的任何输入为 ABSENT，该节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻
   产出物推断它，也不要留下一个强制单元格等模板的下一位读者
   填写。
4. 如果**每一项**必需输入都是 ABSENT，停止并报告
   **`NOT ASSESSED — NO DATA`** 作为整体结论，说明缺了什么、
   由哪个技能产出。

**结论为 `NOT ASSESSED` 是一种成功。** 在没有数据时，它是对
"数据说明了什么？"正确且有用的回答。这防止的失败模式很
具体：一个结论枚举中没有"无法运行"状态的报告会产生
**虚假的干净通过** —— 一个在没有资源也没有标准的项目上返回 COMPLIANT 的资源审计，
或一个在零剖析数据、从未设定预算的情况下报告"相对于
16.67ms 预算有 >99% 余量"的性能剖析。

**证据的缺失绝不是缺失的证据。** 一次因为无文件可扫描而没有
匹配的扫描，没有验证任何东西。要说明属于两种情况中的哪一种 ——
读者无法从一个绿色结果中分辨。

---

## Phase 1: 加载目标文件

完整读取目标文件。读取 CLAUDE.md 以了解项目编码规范。

---

## Phase 2: 识别引擎专家

从 `project.yaml` 读取 `specialists` 块；如果它缺失，回退到 `.claude/docs/technical-preferences.md` 的 `## Engine Specialists` 节。注意：

- **Primary** 专家 —— 由 `engine.name` 派生的 `<engine>-specialist`（Godot→`godot-specialist`，Unity→`unity-specialist`，Unreal→`unreal-specialist`）；用于架构和广泛的引擎问题
- **语言/代码专家** —— `specialists.code` —— 用于评审项目主要语言文件
- **着色器专家** —— `specialists.shader` —— 用于评审着色器文件
- **UI 专家** —— `specialists.ui` —— 用于评审 UI 代码

**值为 `null` 表示未设置 —— 将该键视为缺失并跳过其
专家。绝不要将其作为 agent 名称启动。** v1.0 迁移会为任何旧文件未指名的专家
写入 `null`，而且只要*一个*成员被设置，它就会写入整个块 —— 因此一个只配置了代码
专家的项目会带有 `shader: null` 和 `ui: null`。配置读取器会为这些返回
四字符字符串 `"null"`，它不是空串，因此会被读作
已配置。`null`、空串和缺失在这里是同一种状态。

如果未配置引擎（`project.yaml` 中没有 `engine.name`，且 `technical-preferences.md` 显示 `[TO BE CONFIGURED]` 或缺失），跳过引擎专家步骤。**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 一次什么都不说的跳过检查，与一次通过的检查无法区分；读者无法判断从未寻求过引擎指导。

---

## Phase 3: ADR 合规检查

**参数：** `/code-review [file(s)]` 可以选择性地将用户故事文件路径作为最后一个参数（例如 `/code-review Assets/Scripts/Combat/Attack.cs production/epics/combat/story-001.md`）。如果提供了用户故事路径，读取它以提取主导的 ADR 引用。

按优先级顺序搜索 ADR 引用：
1. 用户故事文件（如果作为参数提供）
2. 实现文件顶部的头部注释
3. 引用这些文件的提交信息（`git log --oneline -- [file]`）

查找类似 `ADR-NNNN` 或 `docs/architecture/adr-`（不区分大小写）的模式。

如果未找到 ADR 引用，记下："No ADR references found — ADR compliance check skipped. For full ADR compliance review, provide the story path: `/code-review [files] [story-path]`."

对每个被引用的 ADR，**只加载本次检查所需的节 —— 绝不无限制完整读取。** 一份内容充实的 ADR 会超出 25k token 的 `Read` 上限，而受限读取唯一的补救方式是分页读取剩余部分 —— 这是读取文件最昂贵的方式。使用与 `/dev-story` 和 `/create-stories` 相同的模式：

1. **映射标题**（代价低 —— 只有行号）：`Grep pattern="^## " path="[adr-file]" output_mode="content" -n`
2. **仅对 `## Decision` 和 `## Consequences` 做有界读取**，使用行号设置 `Read(offset, limit)` 范围，使其在下个标题开始处结束。如果标题映射为空（早于模板的非标准 ADR），回退到一次完整 `Read`；如果它在上限处被截断，直接 grep 决策/后果内容，而不是分页读取剩余部分。

被引用的 ADR 文件缺失或无法读取时，ADR
合规为 `NOT ASSESSED — [ADR] could not be read`：要说明是哪一个。完全没有引用是
`NO ADRS FOUND`，一个不同的结果。

从这两节中，对任何偏离进行分类：

- **ARCHITECTURAL VIOLATION**（BLOCKING）：使用了 ADR 中明确拒绝的模式
- **ADR DRIFT**（WARNING）：在没有使用禁止模式的情况下，与所选方案有实质性偏离
- **MINOR DEVIATION**（INFO）：与 ADR 指导的小差异，不影响整体架构

---

## Phase 4: 规范合规

识别系统类别（引擎、玩法、AI、网络、UI、工具）并评估：

- [ ] 公共方法和类有文档注释
- [ ] 每个方法的圈复杂度低于 10
- [ ] 没有方法超过 40 行（不含数据声明）
- [ ] 依赖被注入（游戏状态不使用静态单例）
- [ ] 配置值从数据文件加载
- [ ] 系统暴露接口（而非依赖具体类）

---

## Phase 5: 架构与 SOLID

**架构：**
- [ ] 依赖方向正确（引擎 <- 玩法，而非反向）
- [ ] 模块之间没有循环依赖
- [ ] 层次分离得当（UI 不拥有游戏状态）
- [ ] 跨系统通信使用事件/信号
- [ ] 与代码库中既定的模式一致

**SOLID：**
- [ ] 单一职责：每个类只有一个变更理由
- [ ] 开闭原则：无需修改即可扩展
- [ ] 里氏替换：子类型可替换基类型
- [ ] 接口隔离：没有臃肿接口
- [ ] 依赖倒置：依赖抽象而非具体实现

---

## Phase 6: 游戏相关关注点

- [ ] 帧率无关性（使用 delta time）
- [ ] 热路径（更新循环）中无内存分配
- [ ] 正确处理空/空状态
- [ ] 必要时保证线程安全
- [ ] 资源清理（无泄漏）

---

## Phase 7: 专家评审（并行）

通过 `Agent` 同时启动所有适用的专家 —— 不要在启动下一个之前等待前一个完成。

> **报告每一位专家的发现之前，先核实它。不要未经检查就放行
> 发现。** 对每条发现，在报告中记录：
>
> - 它所指向的**文件与行号**。
> - **证据** —— 引用的代码，或触发它的具体输入/状态。
> - **置信度** —— `VERIFIED`（你自己核实过）或 `UNVERIFIED —
>   specialist claim`（你无法核实）。
>
> 你无法核实的发现，要么报告为未核实，要么丢弃，绝不
> 仅凭自信的措辞就提升为缺陷。
>
> **为什么这是强制要求。** Agent 在推导时可靠，在诊断现有代码时
> 不可靠：关于一个短函数的**错误**断言可能流畅到足以
> 通过略读，而一个声称的缺陷在你枚举输入后可能会瓦解。没有这一步，
> 父级评审就是一个洗白通道：一个猜测以专家发现的身份进入，
> 又以已评审缺陷的身份离开。

### 引擎专家

如果配置了引擎，确定每个文件适用哪位专家并并行启动：

- 主要语言文件（`.gd`、`.cs`、`.cpp`）→ 语言/代码专家
- 着色器文件（`.gdshader`、`.hlsl`、shader graph）→ 着色器专家
- UI 屏幕/控件代码 → UI 专家
- 横切或不清楚 → Primary 专家

对于任何涉及引擎架构（场景结构、节点层级、生命周期钩子）的文件，还要启动 **Primary 专家**。

### QA 可测试性评审

对于 Logic 和 Integration 用户故事，还要通过 `Agent` 与引擎专家并行启动 `qa-tester`。传入：
- 正在评审的实现文件
- 用户故事的 `## QA Test Cases` 节（来自 qa-lead 的预写测试规格）
- 用户故事的 `## Acceptance Criteria`

要求 qa-tester 评估：
- [ ] 所有测试钩子和接口是否都已暴露（而非隐藏在 private/internal 访问之后）？
- [ ] 用户故事 `## QA Test Cases` 节中的 QA 测试用例是否映射到可测试的代码路径？
- [ ] 是否有任何验收标准在实现后无法测试（例如硬编码值、没有注入接缝）？
- [ ] 实现是否引入了现有 QA 测试用例未覆盖的任何新边界用例？
- [ ] 是否有任何应当有测试却没有的可观察副作用？

对于 Visual/Feel 和 UI 用户故事：qa-tester 评审 `## QA Test Cases` 中的手工验证步骤在按现有实现是否可达成 —— 例如，"手工检查者需要到达的状态是否真的可达？"

在产出输出前收集所有专家的发现。

---

## Phase 8: 输出评审

```
## Code Review: [File/System Name]

### Engine Specialist Findings: [N/A — no engine configured / CLEAN / ISSUES FOUND]
[Findings from engine specialist(s), or "No engine configured." if skipped]

### Testability: [N/A — no story path given / N/A — Visual/Feel or Config story / TESTABLE / GAPS / BLOCKING]
[qa-tester findings: test hooks, coverage gaps, untestable paths, new edge cases]
[If BLOCKING: implementation must expose [X] before tests in ## QA Test Cases can run]

### ADR Compliance: [NOT ASSESSED / NO ADRS FOUND / COMPLIANT / DRIFT / VIOLATION]
[List each ADR checked, result, and any deviations with severity]

### Standards Compliance: [X/6 passing]
[List failures with line references; a missing doc comment names the method or class]

### Architecture: [NOT ASSESSED / CLEAN / MINOR ISSUES / VIOLATIONS FOUND]
[List specific architectural concerns]

### SOLID: [NOT ASSESSED / COMPLIANT / ISSUES FOUND]
[List specific violations]

### Game-Specific Concerns
[List game development specific issues]

### Positive Observations
[What is done well -- always include this section]

### Required Changes
[Must-fix items before approval — ARCHITECTURAL VIOLATIONs always appear here]

### Suggestions
[Nice-to-have improvements]

### Verdict: [NOT ASSESSED / APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

选择结论，先匹配者胜：
- **CHANGES REQUIRED** —— Required Changes 下的任何内容
- **NOT ASSESSED** —— 没有可评审的内容（上面的无数据路径）、引擎
  专家评审未运行 —— 未配置引擎，或某位专家无法启动 —— 或任何报告节读作 `NOT ASSESSED`
  （ADR 合规中存在被引用却无法读取的 ADR、架构、SOLID）；
  要说明是哪一种。NOT ASSESSED 排在 CHANGES REQUIRED 之下，因为已知的
  缺陷比跳过的检查更可操作，并高于两种批准：一次
  跳过引擎检查的评审并未批准该代码。（`NO ADRS
  FOUND` 不是 NOT ASSESSED：没有 ADR 可检查时，它不会阻止
  批准。）
- **APPROVED WITH SUGGESTIONS** —— 仅有 Suggestions
- **APPROVED** —— 无必需更改也无建议

本技能是只读的 —— 不写入任何文件。

---

## Phase 9: 后续步骤

使用 `AskUserQuestion`：
- 提示："Code review complete — verdict: [NOT ASSESSED / APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]. How would you like to proceed?"（Phase 8 的结论，逐字使用）
- 选项（根据结论调整）：
  - 如果 APPROVED：
    - `[A] Run /story-done to mark the story complete`
    - `[B] Stop here`
  - 如果 APPROVED WITH SUGGESTIONS：
    - `[A] Apply the suggestions, then run /story-done`
    - `[B] Run /story-done now — suggestions noted for later`
    - `[C] Stop here`
  - 如果 CHANGES REQUIRED：
    - `[A] Fix the issues and re-run /code-review`
    - `[B] Run /story-done anyway with noted exceptions`
    - `[C] Stop here`
  - 如果 NOT ASSESSED：
    - `[A] Fix what stopped the review (point me at the code, run /setup-engine, or fix the unreadable ADR reference), then re-run /code-review`
    - `[B] Stop here`

如果发现 ARCHITECTURAL VIOLATION：
- 如果该违规与**现有 ADR** 矛盾：修复实现以符合 `docs/architecture/[adr-file].md`。如果设计确已合法变更，运行 `/architecture-decision` 正式*修订*现有 ADR —— 不要创建竞争性的 ADR。
- 如果被违反的模式**没有 ADR**：在修复代码之前运行 `/architecture-decision` 记录正确方案。
