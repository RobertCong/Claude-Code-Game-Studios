---
name: skill-improve
description: "通过测试—修复—复测循环改进技能 —— 静态检查、定向修复、按分数变化决定保留或回退。"
argument-hint: "[skill-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/skill-improve/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

# 技能改进

对单个技能运行一个改进循环：
测试 → 修复 → 复测 → 保留或回退。

其分数来自 `/skill-test` 的静态检查与类别检查，这些检查是读取技能而非运行技能：分数更高
意味着技能写得更好，而不是它表现更好的证明。要检查行为，请在改动前后用真实请求运行该技能。

---

## Phase 1: 解析参数

从第一个参数读取技能名称。若缺失，输出用法并停止：

```
Usage: /skill-improve [skill-name]
Example: /skill-improve tech-debt
```

验证 `.claude/skills/[name]/SKILL.md` 存在。若不存在，停止并提示：
"未找到技能 '[name]'。"

Glob `CCGS Skill Testing Framework/catalog.yaml`。当它存在时，先说明这一点：
"`CCGS Skill Testing Framework/` 在 1.2.0 中已更名为 `studio-tests/`，本技能只读取
`studio-tests/`。请把你写在那里的任何规格文件移过去；UPGRADING.md（v1.1.3 → v1.2.0，
`studio-tests/`）说明了做法。"然后继续。

---

## Phase 2: 基线测试

运行 `/skill-test static [name]` 并记录基线分数：
- FAIL 数量
- WARN 数量
- 具体哪些检查失败（Check 1–7）

向用户显示：
```
Static baseline:   [N] failures, [M] warnings
Failing: Check 4 (no ask-before-write), Check 5 (no handoff)
```

如果静态结果为 **NOT ASSESSED**（技能文件无法读取或解析），停止并连同原因一起报告：没有
可改进的分数，而一个没人能读取的文件给出 0 个 FAIL 并不算干净的结果。

如果基线为 0 个 FAIL、0 个 WARN，记录该情况并继续到 Phase 2b。

### Phase 2b: 类别基线

在 `studio-tests/catalog.yaml` 中查找该技能的 `category:` 字段。

如果未找到 `category:` 字段，显示：
"类别：尚未分配 —— 跳过类别检查。"
并跳到 Phase 3。

如果找到类别，运行 `/skill-test category [name]` 并记录类别基线：
- FAIL 数量
- WARN 数量
- 具体哪些类别评分指标失败

向用户显示：
```
Category baseline: [N] failures, [M] warnings  ([category] rubric)
```

类别结果为 **NOT ASSESSED**（skill-test 无法找到或应用的评分章节）时，连同其原因一起报告，
这不等于零：类别维度因此会从下面的"已通过"中排除。

如果静态与类别基线**都**是 0 个 FAIL、0 个 WARN —— 且两者都不是 NOT ASSESSED —— 停止：
"此技能已通过所有静态检查与类别检查。无需改进。"

---

## Phase 3: 诊断

读取完整技能：`.claude/skills/[name]/SKILL.md`，以及其 `references/` 文件夹中的每个文件
（若有）—— 最长的技能会把每个阶段的内容放在那里。指明每个缺口位于哪个文件。

对每个失败或警告的**静态**检查，识别确切的缺口：

- **Check 1 失败** → 缺少哪个 frontmatter 字段
- **Check 2 失败** → 找到多少个阶段，对照最低要求
- **Check 3 失败** → 技能正文中任何地方都没有结论关键字
- **Check 4 失败** → allowed-tools 中有 Write 或 Edit，但没有写入前询问的措辞
- **Check 5 警告** → 末尾没有后续操作或下一步章节
- **Check 6 警告** → 设置了 `context: fork`，但找到的阶段少于 5 个
- **Check 7 警告** → argument-hint 为空，或与已记录的模式不符

对每个失败或警告的**类别**检查（若 Phase 2b 中已分配类别），识别技能文本中的确切缺口。
例如：
- 如果 G2 失败（闸门模式、总监小组宽度）：技能正文没有依据 `modes.workflow` 确定
  PHASE-GATE 小组的规模（`minimal` 下为 PR，`standard` 下为 TD + PR，`full` 下为全部 4 个）
- 如果 A2 失败（创作类，缺少逐章节的"我可以写入吗"）：技能只在末尾询问一次，而不是在每次
  章节写入之前
- 如果 T3 失败（团队类，未呈现 BLOCKED）：技能没有因 agent 被阻塞而停止相关工作

在提出任何改动之前，向用户展示完整的合并诊断。

---

## Phase 4: 提出修复

为每个失败与警告编写针对性修复。用清晰标记的修改前/后区块展示拟议改动。只改失败的部分 ——
不要重写已通过的章节。在带有 `references/` 文件夹的技能中，对某个阶段步骤的修复写入该阶段的
`references/` 文件，而不是放回 `SKILL.md`；下面的问题随后要指出修复改动的每个文件。

询问："我可以把这个改进版本写入 `.claude/skills/[name]/SKILL.md` 吗？"

若用户回答否，就此停止。

---

## Phase 5: 写入并复测

记录修复所改动的每个文件的当前内容 —— 精确文本，保留在本对话中 —— 以便 Phase 6 恢复。

把改进后的技能写入 `.claude/skills/[name]/SKILL.md`，以及修复所改动的每个 `references/`
文件。

重新运行 `/skill-test static [name]` 并记录新的静态分数 —— 以该次运行测得的为准，绝不依据
编辑内容自行宣称。
如果分配了类别，还要重新运行 `/skill-test category [name]` 并记录新的类别分数。

显示对比：
```
Static:   Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings
Category: Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings  (if applicable)
Combined: [before] → [after] (improved / no change / worse)
```

`[before]` 与 `[after]` 是 Phase 6 的合并计数 —— 失败数加警告数，两个维度都算 ——
例如 `Combined: 3 → 0 (improved)`。

---

## Phase 6: 结论

统计合并后的失败总数：静态 FAIL + 类别 FAIL + 静态 WARN + 类别 WARN。
**返回 NOT ASSESSED 的复测**（例如编辑破坏了 frontmatter，导致文件无法再解析）绝不是改进，
无论其计数如何：走下面的"未改进"分支。

**如果合并分数改善（合并失败数低于基线）：**
报告："分数已改善。改动已保留。"
展示各维度修复内容的摘要。

**如果合并分数相同或更差：**
报告："合并分数未改善。"
展示改动内容以及它可能为何没有帮助。
询问："我可以把 `.claude/skills/[name]/SKILL.md` 恢复到此轮运行前的内容吗？"
—— 并指明 Phase 5 写入的每个文件。
若同意：用 Write 把 Phase 5 记录的内容写回每个文件；若不同意，保持文件为写入后的状态。绝不要
对它执行 `git checkout` —— 那会返回最后一次*已提交*的版本，并丢弃本次运行之前尚未提交的任何
编辑。

---

## Phase 7: 后续步骤

- 运行 `/skill-test static all` 找出下一个存在失败的技能。
- 运行 `/skill-improve [next-name]` 在另一个技能上继续循环。
- 运行 `/skill-test audit` 查看整体覆盖率进展。
