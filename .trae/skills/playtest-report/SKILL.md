---
name: playtest-report
description: "结构化的试玩测试报告模板，或把现有的试玩测试记录整理成结构化反馈。"
argument-hint: "[new|analyze path-to-notes] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/playtest-report/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation`

以上为解析结果——直接使用；`--review` 会覆盖本次运行的 `review_mode`。若无
解析块，则采用 `.claude/docs/config-resolution.md` 中的默认值。

# 试玩测试报告



## Phase 1: 解析参数


完整的检查模式见 `.claude/docs/director-gates.md`。各闸门定义位于 `.claude/docs/director-gates/[gate-id].md`——派生出的代理会读取自己的闸门文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（collaborative 始终询问 · guided 仅重要事项 · autonomous 记录并继续；
`automation_always_ask` 类别始终提示）。

确定模式：

- `new` → 生成一份空白的试玩测试报告模板。此模式在
  Phase 2A 之后结束：空白模板没有可分流、评审或保存的内容。
- `analyze [path]` → 读取原始记录，并用结构化发现填充模板
- 无参数 → 通过 `AskUserQuestion` 询问：`[A] 新建空白模板` /
  `[B] 分析记录——我来提供路径`

---

## Phase 2A: 新建模板模式

生成此模板并输出给用户：

```markdown
# Playtest Report

## Session Info
- **Date**: [Date]
- **Build**: [Version/Commit]
- **Duration**: [Time played]
- **Tester**: [Name/ID]
- **Platform**: [PC/Console/Mobile]
- **Input Method**: [KB+M / Gamepad / Touch]
- **Session Type**: [First time / Returning / Targeted test]

## Test Focus
[What specific features or flows were being tested]

## First Impressions (First 5 minutes)
- **Understood the goal?** [Yes/No/Partially]
- **Understood the controls?** [Yes/No/Partially]
- **Emotional response**: [Engaged/Confused/Bored/Frustrated/Excited]
- **Notes**: [Observations]

## Gameplay Flow
### What worked well
- [Observation 1]

### Pain points
- [Issue 1 -- Severity: High/Medium/Low]

### Confusion points
- [Where the player was confused and why]

### Moments of delight
- [What surprised or pleased the player]

## Bugs Encountered
| # | Description | Severity | Reproducible |
|---|-------------|----------|-------------|

## Feature-Specific Feedback
### [Feature 1]
- **Understood purpose?** [Yes/No]
- **Found engaging?** [Yes/No]
- **Suggestions**: [Tester suggestions]

## Quantitative Data (if available)
- **Deaths**: [Count and locations]
- **Time per area**: [Breakdown]
- **Items used**: [What and when]
- **Features discovered vs missed**: [List]

## Overall Assessment
- **Would play again?** [Yes/No/Maybe]
- **Difficulty**: [Too Easy / Just Right / Too Hard]
- **Pacing**: [Too Slow / Good / Too Fast]
- **Session length preference**: [Shorter / Good / Longer]

## Top 3 Priorities from this session
1. [Most important finding]
2. [Second priority]
3. [Third priority]
```

在 `new` 模式下，在此停止并给出：结论：**COMPLETE**——已输出空白模板；未保存任何内容。

---

## Phase 2B: 分析模式

读取所提供路径下的原始记录。与现有设计文档交叉对照，按章节阅读：用 Grep 工具（模式 `^#`，content 模式）找到所需标题，再用 offset 和 limit 读取相应区间。用结构化发现填充上面的模板。标记任何与设计意图冲突的试玩测试观察。

描述缺陷的观察——崩溃、帧率下降、软锁，或任何明显“坏掉”而非“玩起来不佳”的问题——应放入 **Bugs Encountered**
表格，而不是 Gameplay Flow → Pain points，并在 Phase 3 作为缺陷分流。
Pain points 用于描述游戏玩起来的感觉。

---

## Phase 3: 行动分流

把所有发现归入四类：

- **需要设计变更**——趣味性问题、玩家困惑、损坏的机制、与 GDD 预期体验冲突的观察
- **平衡性调整**——数值感觉不对、难度过于陡峭或过于平缓
- **缺陷报告**——可复现的明确实现缺陷
- **打磨项**——不阻塞进度，但属于留待后续处理的摩擦或手感问题

呈现归类后的清单，然后分流：

- **设计变更：**“对受影响的设计文档运行 `/propagate-design-change [path]`，在改动前找出下游影响。”
- **平衡性调整：**“运行 `/balance-check [system]`，在调整数值前确认完整的平衡性全貌。”
- **缺陷：**“使用 `/bug-report` 正式跟踪这些问题。”
- **打磨项：**“当团队进入该阶段时，加入 `production/` 中的打磨待办清单。”

---

## Phase 3b: 创意总监的玩家体验评审

**评审模式检查**——在派生 CD-PLAYTEST 之前应用：
- `solo` → 跳过。注明：“已跳过 CD-PLAYTEST——Solo 模式。”继续到 Phase 4（保存报告）。
- `lean` → 跳过（非 PHASE-GATE）。注明：“已跳过 CD-PLAYTEST——Lean 模式。”继续到 Phase 4（保存报告）。
- `full` → 照常派生。

完成发现归类后，通过 `Agent` 使用闸门 **CD-PLAYTEST**（`.claude/docs/director-gates/cd-playtest.md`）派生 `creative-director`。

传入：结构化报告内容、游戏支柱与核心幻想（来自
`design/gdd/game-concept.md`）、正在检验的具体假设。**如果
`game-concept.md` 不存在**——这在 `minimal` 下是预期情况，此时
`design/game-brief.md` 取而代之——简述中没有支柱：改为传入它的一句话
提案（pitch）及其“面向谁 / 他们感受什么”一行，并说明这些内容
代替支柱。如果两份文档都不存在，在提示中说明：
*“没有可用的游戏支柱——仅依据假设进行评估。”* 对支柱闭口不谈的总监闸门
会自行编造支柱。

在保存报告前呈现创意总监的评估。如果为 CONCERNS 或 REJECT，在报告中加入 `## Creative Director Assessment` 一节，记录结论与反馈。如果为 APPROVE，在报告中注明已批准。如果为 NOT ASSESSED（总监缺少某项输入——见 `.claude/docs/director-gates.md`），加入同样的一节并指出缺失的内容；这不等于批准。

---

## Phase 4: 保存报告

询问：“我可以把这份试玩测试报告写入 `production/qa/playtests/playtest-[date]-[tester].md` 吗？”

如果同意，则写入文件，必要时创建目录。

---

## Phase 5: 下一步

结论：**COMPLETE**——已生成试玩测试报告。

- 先处理优先级最高的发现类别。
- 处理完设计变更后：对更新后的 GDD 重新运行 `/design-review`。
- 修复缺陷后：重新运行 `/bug-triage` 以更新优先级。
