---
name: scope-check
description: "范围蔓延检查——对比当前范围与原始计划。标记新增内容、量化膨胀、建议削减。『有范围蔓延吗？』"
argument-hint: "[feature-name or sprint-N]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash(git log *)
model: haiku
---

# 范围检查

本技能是只读的——只报告发现，不写入任何文件。

对比原始计划范围与当前状态，以发现、量化并分诊
范围蔓延。

**参数：** `$ARGUMENTS`——整个字符串：功能名称（可能包含多个词）、冲刺编号或里程碑名称。

---

## Phase 1: 找到原始计划

定位与给定参数对应的基线范围文档：

- **功能名称** → 读取 `design/gdd/[feature].md` 或 `design/` 中的匹配文件
- **冲刺编号**（例如 `sprint-3`）→ 读取 `production/sprints/sprint-003.md`（`/sprint-plan` 写入的名称）或类似文件
- **里程碑** → 读取 `production/milestones/[name].md`

如果找不到文档，请报告缺失的文件并停止。没有可供对比的基线时，
不要继续。按章节阅读 GDD：用 Grep 工具（模式 `^#`，content 模式）
找到所需标题，再用 offset 和 limit 读取相应区间。

---

## Phase 2: 读取当前状态

检查实际已实现或正在进行的内容：

- 扫描代码库中与该功能/冲刺相关的文件
- 读取 git 日志中与该工作相关的提交（`git log --oneline --since=[start-date]`）
- 检查 TODO/FIXME 注释，它们可能表明尚未完成的范围新增
- 如果功能正处于冲刺中，检查当前冲刺计划

---

## Phase 3: 对比原始范围与当前范围

生成对比报告：

```markdown
## Scope Check: [Feature/Sprint Name]
Generated: [Date]

### Original Scope
[List of items from the original plan]

### Current Scope
[List of items currently implemented or in progress]

> **If Phase 4 will return NOT ASSESSED, do not render the numeric block below.**
> Replace the counts and the Bloat Score with
> `[Baseline | Current state] unusable — see verdict` (whichever side could not
> be read) and give the reason. A rendered
> `Original items: 0 / Net scope change: 0%` one section above a NOT ASSESSED
> verdict re-creates the exact "0% reads as on track" hazard Phase 4 exists to
> kill, one phase earlier — and readers trust a number over a caveat.

### Scope Additions (not in original plan)
| Addition | Source | When | Justified? | Effort |
|----------|--------|------|------------|--------|
| [item] | [commit/person] | [date] | [Yes/No/Unclear] | [S/M/L] |

### Scope Removals (in original but dropped)
| Removed Item | Reason | Impact |
|-------------|--------|--------|
| [item] | [why removed] | [what's affected] |

### Bloat Score
- Original items: [N]
- Current items: [N]
- Items added: [N] (+[X]%)
- Items removed: [N]
- Net scope change: [+/-N] ([X]%)

### Risk Assessment
- **Schedule Risk**: [Low/Medium/High] — [explanation]
- **Quality Risk**: [Low/Medium/High] — [explanation]
- **Integration Risk**: [Low/Medium/High] — [explanation]

### Recommendations
1. **Cut**: [Items that should be removed to stay on schedule]
2. **Defer**: [Items that can move to a future sprint/version]
3. **Keep**: [Additions that are genuinely necessary]
4. **Flag**: [Items that need a decision from producer/creative-director]
```

---

## Phase 4: 结论

根据净范围变化给出规范结论：

| 净变化 | 结论 | 含义 |
|-----------|---------|---------|
| ≤10% | **PASS** | 在轨——处于可接受的波动范围内 |
| >10–25% | **CONCERNS** | 轻微蔓延——可通过针对性削减控制 |
| >25–50% | **FAIL** | 显著蔓延——必须削减或正式延长工期 |
| >50% | **FAIL** | 失控——停止、重新规划、上报制作人 |

**在套用该表之前，先确认百分比是有意义的。** 出现以下任一情况时，
改为输出 **NOT ASSESSED**——绝不给计算出的百分比：

- **基线文档存在但没有列举任何范围项**（全是标题、
  占位符或 `[TO BE CONFIGURED]`）。Phase 1 在文件*缺失*时停止；
  这里是文件存在但为空的情况，也是更危险的一种，
  因为零个条目会产生 0% 的净变化，渲染为 **PASS——在轨**。
  什么都没比较，也谈不上在轨。
- **当前状态无法确定**——没有相关源文件、窗口期内没有提交、
  没有正在进行的内容可读。用真实基线对比无法读取的现状
  不是 0% 变化，也不是当前条目为零时计算出的 −100%——
  两种结果在表里都读作 PASS。
- 分母因任何其他原因会为零。没有基线条目时算出的百分比
  不是一个小数字；它根本不是一个数字。

`NOT ASSESSED` **高于 PASS**（从未发生的比较并不能证明
范围在轨）且**低于 CONCERNS 和 FAIL**（已测量的蔓延比无法测量的基线
更可行动）。

醒目地输出结论：

```
**Scope Verdict: [PASS / CONCERNS / NOT ASSESSED / FAIL]**
Net change: [+X%] — [On Track / Minor Creep / Significant Creep / Out of Control]
           [or: NOT ASSESSED — [which side could not be read, and why]]
```

---

## Phase 5: 下一步

呈现报告后，提供具体的后续行动：

- **PASS** → 无需行动。建议在下一个里程碑前重新运行。
- **NOT ASSESSED** → 说明哪一侧不可读，以及怎样才能修复（填充
  基线文档，或把技能指向工作实际所在的位置）。
  不要针对相同输入提供重跑——它只会给出同样的
  非答案。
- **CONCERNS** → 提议找出 2–3 个削减收益最好的新增项。引用 `/sprint-plan update` 来正式重新划定范围（如果项目没有冲刺计划，例如默认的 minimal 工作流，则通过编辑简报的构建顺序来重新划定范围）。
- **FAIL** → 建议上报制作人。引用 `/sprint-plan update` 重新规划（如果项目没有冲刺计划，例如默认的 minimal 工作流，则编辑简报的构建顺序），或用 `/estimate` 重新设定时间线基线。

除 NOT ASSESSED 外，每个结论都以这句话结尾：
> “在完成削减后再次运行 `/scope-check [name]`，以确认结论有所改善。”

（NOT ASSESSED 以上面所说“怎样才可评估”结尾——针对
相同输入重跑只会重复这个非答案。）

---

### 规则

- 范围蔓延是指只新增却没有相应的削减或工期延长
- 并非所有新增都是坏事——有些是被发现的需求。但必须承认并计入
- 建议削减时，优先保留核心玩家体验，而非锦上添花的内容
- 始终量化范围变化——“感觉变大了”不可行动，“+35% 条目”才可行动
