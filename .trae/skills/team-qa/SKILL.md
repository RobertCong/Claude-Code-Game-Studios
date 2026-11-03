---
name: team-qa
description: "编排 QA 团队完成完整测试周期 — qa-lead 制定策略与测试计划，qa-tester 编写用例、执行、签署验收。"
argument-hint: "[sprint | feature: system-name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/team-qa/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

# Team QA

当本技能被调用时，通过结构化的测试周期编排 QA 团队。

**决策点：** 在每个阶段转换处，使用 `AskUserQuestion` 把子 agent 的提案
作为可选项呈现给用户。在对话中写出 agent 的完整分析，
然后用简洁标签记录决策。
在 `collaborative` 模式下，用户必须批准后才能进入下一阶段。
在 `guided` 模式下，流水线自动推进，除非某阶段为 BLOCKED；
在 `autonomous` 模式下，端到端运行，通过
`log_decision` 记录每个阶段的结果。`automation_always_ask` 类别
（`is_always_ask_category` 辅助函数）中的决策无论何种模式
始终提示。参见
`.claude/docs/automation-modes.md`。

## Phase 0: 解析配置

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,team.size,qa.level`

上文已解析 — 直接使用；`--review` 覆盖 `review_mode`。无配置块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

`qa.level` 决定 Logic、Integration 或 Config/Data 用户故事需要什么证据：
在 `standard` 和 `full` 下是其自动化测试；在 `minimal` 下测试被豁免
（`.claude/docs/coding-standards.md`），则由 Phase 5 的验收标准走查作为证据 —
此时没有测试的用户故事记为 WAIVED，而不是缺少证据。UI 和
Visual/Feel 截图在每个层级都是必需的。

`review_mode` 设定总监闸门深度，而本流水线没有总监闸门：
在任意 `review_mode` 下，下方没有任何阶段会派生 CD-、TD-、PR- 或 AD-PHASE-GATE。
它的阶段闸门是流水线自身的决策点（定义在下方
`team.size` 之下），在这些决策点工作的 agent 是团队成员，而非总监闸门。

`automation` 驱动上方的决策点说明。关于每种模式如何改变流水线行为，
参见上方的决策点说明以及
`.claude/docs/automation-modes.md`。

**`team.size`**：哪些 agent 处于活动状态（与 review_mode 闸门深度和工作流文档正交）。
- **`individual`**（默认）：仅 `qa-tester`；`qa-lead` 仅在阶段闸门处被调用。
- **`small`**：`qa-lead` + `qa-tester` 流水线（如文档所述）。
- **`studio`**：`qa-lead` + 每个用户故事派生一个 `qa-tester` + 签署验收。
在 `individual` 下需要某个非核心 agent 时，经由最近的活动核心 agent 路由，并附一条信息性说明。**“阶段闸门”指本流水线自身列出的、以 `AskUserQuestion` 决策点结尾的任何阶段** — 可以是上方决策点中的转换，也可以是下方流水线中写入的 **Gate** 步骤 — **无论 `automation` 模式为何**：在 `guided` 或 `autonomous` 下，即使该问题被跳过或记录，该阶段仍是闸门。并非每个阶段都是闸门。严格按测试判断：如果下方阶段没有列出决策点，它就不是闸门，被限制为“仅阶段闸门”的 agent 不会为它派生。这种活动集范围界定适用于下方整个流水线：任何指定了活动集之外 agent 的阶段，都经由最近的核心 agent 路由，而不是派生该 agent。

**在 Phase 1 之前宣布活动集 — 绝不让这种收缩悄无声息地发生。**
在派生任何东西之前，用一行说明本次运行实际会派生哪些
agent，以及下方流水线指定但**不会**在解析出的
`team.size` 下派生的 agent。例如：

> `Active set (team.size: <resolved>): <the agents listed for that size above>.`
> `Not spawned this run: <every other agent this pipeline names> — consulted`
> `through <nearest active core agent>. Raise team.size (or modes.rigor) to widen.`

根据紧邻上方的 `team.size` 列表和本文件自身流水线所指名的
agent 来填写 — 而不是照抄示例。两个集合因编排器而异。
解析出的规模仅在阶段闸门派生的 agent（`individual` 下的 `qa-lead`）
会带该限定词进入活动集 — 它会被派生，而不是经由另一个 agent 咨询。

下方流水线读起来像是多 agent 扇出，但在随附默认值下
它是一个或两个 agent — `team-release` 指名十个而只运行一个，`team-narrative`
指名六个、跨越五个阶段，却只运行 `writer` 一个。**这种收缩是正确的**：
`team.size` 由 rigor 前置，窄默认值就是 token 杠杆。
若不说明这一点，读者就无法区分正确收缩的运行与
损坏的流水线，而且上方那条每个 agent “经由最近的核心 agent 路由并附信息性说明”的规则
在路由时触发，却从不说明整次运行的形态。

这与本文件中其他位置关于跳过检查的报告规则相同：**一项被执行但从未
呈现的约束，对阅读输出的人而言，与从未执行的约束无法区分。**

## 团队构成

- **qa-lead** — QA 策略、测试计划生成、用户故事分类、签署报告
- **qa-tester** — 测试用例编写、缺陷报告编写、手动 QA 文档

## 如何委派

使用 `Agent` 工具将每个团队成员作为子 agent 派生：
- `subagent_type: qa-lead` — 策略、规划、分类、签署
- `subagent_type: qa-tester` — 测试用例编写和缺陷报告编写

**为每个 agent 提供简报 — 不要倾倒上下文。** 只读取共享输入**一次**，并以内联方式传递提炼后的简报：只给每个 agent 真正需要的行，绝不给你已经读过的文档传文件路径（接到路径的 agent 会重新读取整个文件）。只为你尚未读过且只有该 agent 需要的文档传路径。

**在每个 agent 提示的末尾加上返回契约：** “Write your full output to `[path]` — 这个被指定的路径就是下方有界例外中的写入授权，因此无需单独的批准提示即可写入。只返回 (1) 已写入的路径，(2) 决策要点 ≤5 条的摘要，(3) 任何 BLOCKED/CONCERNS 条目，每条一行。不要复述你读过的文档。” 没有它，agent 会把它读过的一切都回传到本会话。

> **为什么这不违反协作协议。** `CLAUDE.md` 要求 agent 在 Write/Edit 前询问“May I write this to [filepath]？”。此处派生的子 agent **无需**询问即可写入，这是有意为之的有界例外，而非疏漏 — 与 `consistency-check` 追加到 `active.md` 时已做出的相同决定。仅当以下三点全部成立时，该例外才成立：(1) 路径是**你**在提示中指定的，因此用户批准阶段时已批准了目标位置；(2) 它是 `production/`、`docs/` 或 `tests/` 下的新产出物，绝不是对现有源码或配置的编辑；(3) 产出它的阶段是上文定义的阶段闸门 — 流水线列出的、在推进前以 `AskUserQuestion` 结尾的阶段，无论自动化模式为何。这三点之外，agent 必须询问。**不要通过逐个询问子 agent 来“修复”这一点** — 每个阶段每个 agent 一次提示会让编排器无法使用，这正是该例外存在的原因。

在 `team.size: studio` 下，Phase 4 为每个用户故事并行派生一个 qa-tester；低于该规模时，一次派生覆盖整组。

## 流水线

### Phase 1: 加载上下文

在做任何其他事情之前，收集完整范围：

1. 根据参数确定当前冲刺或功能范围：
   - 如果参数是冲刺标识符（例如 `sprint-03`）：Glob `production/sprints/sprint-*.md` 并按冲刺编号匹配 — `sprint-3`、`sprint-03` 和 `sprint-003` 都指冲刺 3（`/sprint-plan` 写入 `sprint-NNN.md`）。读取匹配的文件。若匹配多个，使用最近修改的那个。
   - 如果参数是 `feature: [system-name]`：glob 标记为该系统的用户故事文件
   - 若无参数：读取 `production/session-state/active.md` 和 `production/sprint-status.yaml`（若存在）以推断活动冲刺。若没有冲刺 — 在 `rigor: minimal` 下没有冲刺 — 询问要覆盖哪个史诗，并使用 `feature: [epic-slug]`；不要凭空编造冲刺

2. 从 `project.yaml` 读取 `project.stage`（回退到 `production/stage.txt`）以确认当前项目阶段。

3. **读取范围内的未关闭缺陷** — 在 QA 发现新缺陷之前，读取已归档的缺陷：像 `/bug-triage` 那样，grep `production/qa/bugs/*.md` 中的 `**Severity**`、`**Status**` 和 `**System**` 行。除非 Status 为 `Closed` 或 `Verified Fixed`，否则缺陷处于未关闭状态；当其 System 属于范围内用户故事所属的系统，或它指明了范围内的用户故事时，该缺陷在范围内 — 不确定时就列出来。这些会作为 **范围内的未关闭缺陷** 写入 Phase 2 和 Phase 6 的简报：这里已有未关闭的 S1 或 S2，无论 QA 发现什么，都会让签署结果为 NOT APPROVED（Phase 6）。没有缺陷文件 → “范围内的未关闭缺陷：无已归档。”

4. 统计找到的用户故事数并向用户报告：
   > “正在为 [sprint/feature] 启动 QA 周期。找到 [N] 个用户故事。范围内的未关闭缺陷：[N — S1: n, S2: n, 或 无已归档]。当前阶段：[stage]。准备好开始 QA 策略了吗？”

### Phase 2: QA 策略（qa-lead）

通过 `Agent` 派生 `qa-lead`，审查所有范围内的用户故事并产出 QA 策略。

把 Phase 1 的 **范围内的未关闭缺陷**（ID、严重程度、用户故事或系统）传给 qa-lead，然后提示它：
- 读取每个用户故事文件
- 按类型分类每个用户故事：**Logic** / **Integration** / **Visual/Feel** / **UI** / **Config/Data**
- 确定哪些用户故事需要自动化测试证据、哪些需要手动 QA — 在 `qa.level: minimal` 下无需测试：没有测试的 Logic、Integration 或 Config/Data 用户故事在 Automated Required 下读作 `WAIVED`，并在手动 QA 中走查其验收标准
- 标记任何缺少验收标准或缺少测试证据、会阻塞 QA 的用户故事
- 估算手动 QA 工作量（需要的测试会话数）
- **在评估冒烟状态之前，检查是否已有冒烟检查报告**：Glob `production/qa/smoke-*.md` 并读取最近修改的文件（若找到）。若报告存在，直接使用其结论和发现 — 不要重新询问用户。若不存在报告，注明：“未找到先前的冒烟检查报告 — 继续之前请运行 `/smoke-check sprint`。” 并将冒烟检查状态设为 UNKNOWN（为继续执行的目的，视为 PASS WITH WARNINGS）。产出冒烟检查结论：**PASS** / **PASS WITH WARNINGS [list]** / **NOT ASSESSED [what did not run]** / **FAIL [list of failures]** / **UNKNOWN (no report found)**
- 产出策略摘要表和冒烟检查结果：

  | 用户故事 | 类型 | 需要自动化测试 | 需要手动 QA | 阻塞项？ |
  |-------|------|--------------------|-----------------|----------|

  **冒烟检查**：[PASS / PASS WITH WARNINGS / NOT ASSESSED / FAIL / UNKNOWN] — [来源：`production/qa/smoke-[date].md` 或 “no report found”] — [若非 PASS 的详情]

  **范围内的未关闭缺陷**：[BUG-ID — S[n] — 用户故事或系统，每行一个；或 “none on file”] — 未关闭的 S1 或 S2 在此列出，作为已知失败

如果冒烟检查结果为 **FAIL**，qa-lead 必须显著列出这些失败。冒烟检查失败时，QA 不能通过策略阶段。

向用户呈现 qa-lead 的完整策略，然后使用 `AskUserQuestion`：

```
question: "QA Strategy Review"
options:
  - "Looks good — proceed to test plan"
  - "Adjust story types before proceeding"
  - "Skip blocked stories and proceed with the rest"
  - "Smoke check failed — fix issues and re-run /team-qa"
  - "Cancel — resolve blockers first"
```

若冒烟检查 **FAIL**：不要进入 Phase 3。呈现冒烟检查报告中的失败并停止。用户必须修复它们，重新运行 `/smoke-check sprint`，然后重新运行 `/team-qa`。
若冒烟检查 **UNKNOWN**：给出警告 — “未找到冒烟检查报告。建议在 QA 之前运行 `/smoke-check sprint`。谨慎推进。”
若冒烟检查 **NOT ASSESSED**：说明报告指出什么未能运行 — “上次冒烟检查无法评估 [what did not run]。建议在可以运行时重新运行 `/smoke-check sprint`。谨慎推进。” — 并按 UNKNOWN 的情况继续；签署不能基于它成为 APPROVED（Phase 6）。
若冒烟检查 **PASS WITH WARNINGS**：将警告记入签署报告并继续。
若存在阻塞项：明确列出它们。用户可以选择跳过被阻塞的用户故事或取消周期。

### Phase 3: 测试计划生成

使用 Phase 2 的策略，产出一份结构化的测试计划文档。

测试计划应涵盖：
- **范围（Scope）**：冲刺/功能名称、用户故事数量、日期
- **用户故事分类表**：来自 Phase 2 策略
- **自动化测试需求**：哪些用户故事需要测试文件、预期的 `tests/` 路径（在 `qa.level: minimal` 下为无：改为在手动 QA 范围下列出被豁免的用户故事）
- **手动 QA 范围**：哪些用户故事需要手动走查以及要验证什么
- **范围外（Out of Scope）**：本周期明确不测试什么以及为什么
- **准入标准（Entry Criteria）**：QA 开始前必须满足什么。始终包含：(1) 在 `production/qa/smoke-*.md` 存在 PASS 或 PASS WITH WARNINGS 报告，(2) 构建稳定（启动不崩溃），(3) 在冲刺范围内，所有 Must Have 用户故事在 `production/sprint-status.yaml` 中为 `in-progress`、`review` 或 `done`；在 `feature:` 范围内，每个范围内用户故事文件的 Status 为 In Progress、In Review 或 Complete。除此之外还要添加任何冲刺特有的标准。
- **退出标准（Exit Criteria）**：什么构成已完成的 QA 周期（所有用户故事 PASS，或 FAIL 且已归档缺陷）

询问：“May I write the QA plan to `production/qa/qa-plan-[sprint]-[date].md`?”

仅在收到批准后写入。

### Phase 4: 测试用例编写（qa-tester）

> **冒烟检查**作为 Phase 2（QA 策略）的一部分执行。若冒烟检查在 Phase 2 返回 FAIL，周期已在那里停止。本阶段仅在 Phase 2 冒烟检查为 PASS、PASS WITH WARNINGS、NOT ASSESSED 或 UNKNOWN 时运行。

对每个需要手动 QA 的用户故事（Visual/Feel、UI、无自动化测试的 Integration — 以及在 `qa.level: minimal` 下测试被豁免时，每个无测试的 Logic、Integration 和 Config/Data 用户故事：其用例走查其验收标准）：

通过 `Agent` 派生 `qa-tester` — 在 `team.size: studio` 下每个用户故事一个、并行；在 `small` 和 `individual` 下一次派生覆盖整组 — 为每个用户故事提供：
- 用户故事文件路径
- 该用户故事在 QA 计划中的相关章节
- 被测系统的 GDD 验收标准（若可用）
- 编写覆盖所有验收标准的详细测试用例的说明
- **输出路径：`production/qa/test-cases/[story-slug]-cases.md`。** 在提示中
  明确指定它，每个用户故事一个。

> **为什么路径在这里写明，而不是留给编排器。** 上述有界写入例外仅在
> “路径是**你**在提示中指定的”时才成立。本阶段*并行*派生 agent，
> 因此正是未指定目标位置造成最大损害的地方：每个 agent 自行
> 即兴发挥，两次运行就会把同一产出物归档到两个地方。本阶段在
> 直到两个 agent 都需要有地方放输出之前，读起来都是正确的。

每套测试用例应包含：
- **前置条件**：测试开始前所需的游戏状态
- **步骤**：带编号、无歧义的操作
- **预期结果**：应该发生什么
- **实际结果**：留空供测试者填写的字段
- **通过/失败**：留空的字段

在执行之前，将测试用例呈现给用户审查。按用户故事分组。

对每组用户故事使用 `AskUserQuestion`（每次批量 3-4 个）：

```
question: "Test cases ready for [Story Group]. Review before manual QA begins?"
options:
  - "Approved — begin manual QA for these stories"
  - "Revise test cases for [story name]"
  - "Skip manual QA for [story name] — not ready"
```

### Phase 5: 手动 QA 执行

走查已批准手动 QA 列表中的每个用户故事。

将用户故事分批为 3-4 个一组，并对每组使用 `AskUserQuestion`。**等待
测试者的回答**，只记录他们所说的内容：测试者未给出的结果绝不替他们填写。
无人回答的用户故事保持未执行，这会让签署成为 NOT ASSESSED — 除非
他们明说，否则不是 BLOCKED。

```
question: "Manual QA — [Story Title]\n[brief description of what to test]"
options:
  - "PASS — all acceptance criteria verified"
  - "PASS WITH NOTES — minor issues found (describe after)"
  - "FAIL — criteria not met (describe after)"
  - "BLOCKED — cannot test yet (reason)"
```

每次 FAIL 结果之后：使用 `AskUserQuestion` 收集失败描述，然后通过 `Agent` 派生 `qa-tester`，按 `/bug-report` 的格式在 `production/qa/bugs/` 中编写正式缺陷报告 — 其 Severity 和 Priority 标签完全按照该模板所列（`S2-High`、`P1-Fix this sprint`、…），因为 `/bug-triage` 会解析它们。

**在 Visual/Feel 或 UI 用户故事的每次 PASS 或 PASS WITH NOTES 之后，把其
证据记录到 `production/qa/evidence/`。** 保留的截图就是
证据：请测试者把该用户故事涉及的每个界面或效果各保存一张，
放在 `production/qa/evidence/[story-slug]/` 下，并确认它已在磁盘上 —
`/story-done` 检查保留的图片，而不仅仅是文字说明。UI 用户故事
由这些截图关闭；Visual/Feel 用户故事还需要主管签署。
然后每组用户故事询问一次：“May I write the evidence for [story titles] to
`production/qa/evidence/`?”，并根据
`.claude/docs/templates/test-evidence.md` 写入证据产出物
`production/qa/evidence/[story-slug]-evidence.md`，完整保留签署表
并引用截图。若未保存任何截图，则在
Phase 5 摘要中指明该用户故事缺少保留证据，而不是写一份暗示
已有证据的文档。

> **这不是可选的记账工作 — 它是下一个技能据以设闸的产出物。**
> `/story-done` 会为 Visual/Feel 和 UI 用户故事 glob `production/qa/evidence/`
> 并读取签署表；`/story-readiness`、
> `/test-evidence-review` 和 `gate-release` 读取同一目录。写到别处，
> 用户故事可能在这里通过完整的 QA 周期，随后却被
> `/story-done` 告知不存在视觉证据。Visual/Feel 和 UI 闸门默认是
> **BLOCKING**，因此那会形成死锁 — QA 通过了，用户故事却无法
> 关闭。只有在 `testing.strict.ui` 或
> `.visual` 被显式设为 `false` 时，这才只是一个令人困惑的标记。
>
> 除非签署确实在本会话中发生，否则把签署行保持**未勾选**。
> 预先勾选批准的证据文件比没有更糟：它把缺失的签名
> 变成了已记录的签名。

缺陷报告命名：`BUG-[NNNN].md`，按 `/bug-report` 的编号方式编号 —
`production/qa/bugs/` 中的最高 ID 加一，零填充为四位 — 以便
`/bug-report verify` 和 `close` 能按 ID 找到它。

收集所有结果后，汇总：
- PASS 的用户故事：[count]
- PASS WITH NOTES 的用户故事：[count]
- FAIL 的用户故事：[count] — 已归档缺陷：[IDs]
- BLOCKED 的用户故事：[count]

### Phase 6: QA 签署报告

通过 `Agent` 派生 `qa-lead`，使用 Phase 2–5 的所有结果起草签署报告。**这里的返回契约是回复中的报告文本，而非文件：** 编排器会在本阶段末尾询问后写入签署，因此 qa-lead 不写任何文件。

**向 qa-lead 简报证据和下方的结论规则 — 绝不要给结论。** 逐字传入策略表、冒烟检查结论及其来源、每个用户故事的结果、Phase 5 归档的缺陷以及 Phase 1 的 **范围内的未关闭缺陷**，还有下方的结论规则。不要指明结论、不要预填 `### Verdict:` 行，也不要说明哪个事实决定了它：由 qa-lead 把规则应用到证据上。然后在询问是否写入之前，用同样的规则核对其结论；若不一致，展示两者并询问 — 绝不悄悄替换为你自己的结论。

签署报告格式：

```markdown
## QA Sign-Off Report: [Sprint/Feature]
**Date**: [date]

### Test Coverage Summary
| Story | Type | Auto Test | Manual QA | Result |
|-------|------|-----------|-----------|--------|
| [title] | Logic | PASS | — | PASS |
| [title] | Logic | WAIVED (qa.level: minimal) | PASS — criteria walked | PASS |
| [title] | Visual | — | PASS | PASS |
| [title] | Integration | — | BLOCKED | BLOCKED — [reason]; no executed evidence |

### Bugs Found
| ID | Story | Severity | Status |
|----|-------|----------|--------|
| BUG-0001 | [story] | S2 | Open |

[every open bug in scope — those Phase 1 found on file and those filed in Phase 5]

### Verdict: NOT ASSESSED / APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED

**Conditions** (if any): [list what must be fixed before the build advances]

### Next Step
[guidance based on verdict]
```

**范围内的每个用户故事都会获得一行 Test Coverage Summary** — 包括 BLOCKED 和
未执行的用户故事，原因写在 Result 中 — 这样从未运行的
用户故事就不会从报告中消失。

结论规则：

**顺序。** 先检查 **NOT APPROVED**：范围内任何未关闭的 S1/S2 缺陷 — 既包括已归档的（Phase 1），也包括 Phase 5 新归档的 — 或某个用户故事在没有记录变通方案的情况下
FAIL，都会使结论成为 NOT APPROVED，无论其他什么未执行 — 已知失败优先于未知，把它降级为
NOT ASSESSED 只会将其掩埋（`.claude/rules/skill-authoring.md`，义务 1）。

**然后是前提条件。** APPROVED 和 APPROVED WITH CONDITIONS 都要求
**范围内每个用户故事都产出了已执行的证据** — 运行过的测试，或
走查过的手动用例。在 `qa.level: minimal` 下，Logic、Integration 或
Config/Data 用户故事的验收标准走查就是其已执行证据：其测试
是 WAIVED，而非缺失。若任何用户故事为 BLOCKED、未执行或没有
证据，结论为 **NOT ASSESSED**，而非任何一种 APPROVED。Phase 2 中为
UNKNOWN（未找到报告）或 NOT ASSESSED 的冒烟检查也会使其成为
NOT ASSESSED：构建的健康状况从未被检查。

- **NOT ASSESSED — NO EVIDENCE**：一个或多个用户故事未产出已执行的
  证据（BLOCKED、在 `qa.level` 为 standard/full 时未编写测试、用例未
  走查，或冒烟检查为 FAIL / UNKNOWN / NOT ASSESSED）。这**不是**通过，
  也**不是**失败；它意味着 QA 并未发生。说明是哪些用户故事以及为什么。
- **APPROVED**：所有用户故事 PASS 或 PASS WITH NOTES；没有未关闭的 S1/S2 缺陷
- **APPROVED WITH CONDITIONS**：有未关闭的 S3/S4 缺陷，或已记录 PASS WITH NOTES 的问题；没有 S1/S2 缺陷
- **NOT APPROVED**：有任何未关闭的 S1/S2 缺陷；或有用户故事在没有记录变通方案的情况下 FAIL

> **为什么存在这个前提条件。** 其下的三条规则假定
> 每个用户故事都会归结为 PASS 或 FAIL。一个什么都没执行的冲刺
> 不会触发任何 NOT APPROVED 条件，并**空洞地满足“没有未关闭的 S1/S2
> 缺陷”** — 因为零个已执行测试意味着零个观察到的失败。按字面
> 理解，且没有这个前提条件，规则会让一个完全未测试的
> 构建达到 APPROVED — 一位凭意图想给出 NOT APPROVED 的 `qa-lead` 会发现
> 规则的文字并不支持它。签署主张的是已
> 验证的质量；没有这个前提条件，规则无法
> 区分“验证良好”与“从未查看”。

按结论给出下一步指导：
- NOT ASSESSED：“QA 未运行至完成。产出缺失的证据 — 编写 Logic 测试（在 `qa.level` 为 standard/full 时）或走查被豁免用户故事的验收标准（在 `minimal` 时），走查手动用例，运行 `/smoke-check` — 然后重新运行 `/team-qa`。不要基于此结论推进构建。”
- APPROVED：“构建已准备好进入下一阶段。运行 `/gate-check` 验证推进。”
- APPROVED WITH CONDITIONS：“在推进前解决条件项。S3/S4 缺陷可推迟到打磨阶段。”
- NOT APPROVED：“在推进前解决 S1/S2 缺陷，并重新运行 `/team-qa` 或针对性的手动 QA。”

询问：“May I write this QA sign-off report to `production/qa/qa-signoff-[sprint]-[date].md`?”

仅在收到批准后写入。

## 错误恢复协议

**首先，验证产出物。** 如果返回契约指明了路径，在将该阶段视为完成之前检查
路径是否存在 — **指定的产出物不在磁盘上，就是失败的阶段，无论回复读起来多么流畅。**
agent 可能耗尽整个阶段并返回一段看似合理的前言，却什么都没写，这
既不是 BLOCKED，也不是错误，更不是“无法完成”，因此下方的触发条件
永远不会被触发。指出未满足的契约并让它继续；上下文
通常仍在那里。

如果任何派生的 agent 返回 BLOCKED、报错或无法完成：**立即
呈现它，不要越过它阻塞的依赖，并始终产出
部分报告。** 完整流程：`.claude/docs/error-recovery-protocol.md`。

常见阻塞项：
- 输入文件缺失（未找到用户故事、GDD 缺失）→ 重定向到创建它的技能
- ADR 状态为 Proposed → 不要实现；一旦决定，用 `/architecture-decision accept ADR-NNNN` 接受它
- 范围过大 → 通过 `/create-stories` 拆分为两个用户故事
- ADR 与用户故事之间的指令冲突 → 呈现冲突，不要猜测

## 输出

一份涵盖以下内容的摘要：范围内的用户故事、冒烟检查结果、手动 QA 结果、归档的缺陷（含 ID 和严重程度），以及最终的 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED / NOT ASSESSED 结论。

Verdict: **COMPLETE** — QA 周期已完成。
Verdict: **BLOCKED** — 冒烟检查失败或严重阻塞项阻止周期完成；已产出部分报告。

## 会话状态更新

在最后一个阶段完成后（签署报告已写入或达到 BLOCKED 结论），静默追加到 `production/session-state/active.md`：

```
<!-- QA RUN: [date] | Sprint: [sprint identifier or "ad-hoc"] | Verdict: [APPROVED/APPROVED WITH CONDITIONS/NOT APPROVED/NOT ASSESSED/BLOCKED] | Report: production/qa/qa-signoff-[sprint]-[date].md -->
```
