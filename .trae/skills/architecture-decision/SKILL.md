---
name: architecture-decision
description: "创建记录技术决策的 ADR：背景、考虑过的替代方案、后果。"
argument-hint: "[title | retrofit <path> | accept <ADR-id>] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density,team.size`

以上命令的输出即解析结果——按原样使用；`--review` 会覆盖 `review_mode`。若无输出块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

# 架构决策

当此技能被调用时：

## 0. 解析参数 — 检测改造 / 接受模式

完整的检查模式见 `.trae/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md` —— 被生成的 agent 会读取自己的闸门文件；不要在父会话中读取它。

每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅询问重大事项 · 自主模式记录并继续；
`automation_always_ask` 类别始终提示）。

**`team.size`**：由哪些 agent 来验证此 ADR（与 review_mode/workflow 正交）。
- **`individual`**（默认）：`technical-director`（TD-ADR）+ 引擎专家。
- **`small`** 与 **`studio`**：同样是这两个。此技能在任何规模下都不会生成引擎
  子专家，也不会生成对抗性评审者。

**`docs.density`** —— 它控制 ADR 的散文段落*深度*，而不控制骨架输出哪些段落
（那是固定的）。`modes.rigor` 会连同 `workflow` 一起设置它；单独调整 ADR 详略时
可显式设置 `docs.density`：
`terse`（默认，通过 `rigor: minimal`）= 决策 + 以要点列出的替代方案，每条一行理由；
`balanced`（`rigor: standard`）= 每段一段话，附简要理由；`thorough` =
完整散文，在 Decision、Alternatives 和 Consequences 中写入取舍与完整理由。
将它应用于散文段落；Engine Compatibility、ADR Dependencies 和 GDD Requirements
三张表格是结构性的，在任何密度下都保持完整。

**`workflow`**（见 `.trae/docs/workflow-modes.md`）：
- `full` —— 必需 ADR 列表中的所有 ADR 都必须完成。
- `standard` —— 仅关键 ADR（Foundation 层系统）。
- `minimal` —— 非必需。仍可自愿运行。

**如果参数以 `retrofit` 开头并跟一个文件路径**

**现在读取 `references/0-retrofit.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

**如果参数以 `accept` 开头并跟一个 ADR id**

**现在读取 `references/0-accept.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

如果不在改造或接受模式，继续下面的第 1 步（正常撰写 ADR）。

**无参数保护**：如果未提供参数（标题为空），在运行
Phase 0 之前先询问：

> "What technical decision are you documenting? Please provide a short title
> (e.g., `event-system-architecture`, `physics-engine-choice`)."

将用户的回答作为标题，然后继续第 1 步。

---

## 1. 加载引擎上下文（始终第一步）

**现在读取 `references/1-engine-context.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## 2. 确定下一个 ADR 编号

扫描 `docs/architecture/` 中现有的 ADR，找出下一个编号。

---

## 3. 收集上下文

**现在读取 `references/3-gather-context.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## 4. 协作式引导决策

**现在读取 `references/4-decide.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## 5. 生成 ADR

**现在读取 `references/5-generate.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## 6. 收尾：后续步骤

ADR 写入完成后（以及注册表可选更新后），用 `AskUserQuestion` 收尾。

生成控件之前：
1. 按章节读取 `docs/architecture/architecture.md` 的 `## Required ADRs` 章节，并列出 `docs/architecture/adr-*.md`：required ADR 若没有对应文件，就仍算未撰写。如果没有 `architecture.md`，则查找 technical-preferences.md 或 systems-index.md 中标记为前提的 ADR
2. 检查所有前提 ADR 现在是否都已撰写。若是，加入一个 "Start writing GDDs" 选项。
3. 将所有剩余的优先 ADR 列为单独选项——不只是接下来一两个。

控件格式：
```
ADR-[NNNN] written and registry updated. What would you like to do next?
[1] Write [next-priority-adr-name] — [brief description from prerequisites list]
[2] Write [another-priority-adr] — [brief description]  (include ALL remaining ones)
[N] Start writing GDDs — run `/design-system [first-undesigned-system]` (only show if all prerequisite ADRs are written)
[N+1] Stop here for this session
```

如果没有剩余的优先 ADR，也没有未设计的 GDD 系统，只提供 "Stop here"，并建议在新会话中运行 `/architecture-review`。

**务必在收尾输出中包含这段固定通知（不要省略）：**

> 要对照你的 GDD 验证 ADR 覆盖率，请打开一个 **全新的 Trae 会话**
> 并运行 `/architecture-review`。
>
> **绝不要在 `/architecture-decision` 的同一会话中运行 `/architecture-review`。**
> 评审 agent 必须独立于撰写上下文，才能给出无偏的
> 评估。在此处运行会使评审无效。

**不要在这里解除用户故事的阻塞。** 此 ADR 是 `Proposed` —— 第 5 步保证了这一点，
而一个*因等待此决策*而被阻塞的用户故事，仍在等待它。在撰写时解除阻塞，
恰好在保护机制变得相关的那一刻将其破坏：流水线看起来在流动，实际却运行在
无人接受的决策之上。

相反，告诉用户现在有什么在等待接受：

> "ADR-NNNN 已撰写，状态为 `Proposed`。[N] 个用户故事仍因它而 `Blocked`。
> 决策确定后运行 `/architecture-decision accept ADR-NNNN` ——
> 那才是把它们变为 `Ready` 的动作。"

按路径列出生效受阻的用户故事，让保持 Proposed 的代价可见。
（接受会在许多技能中强制执行后果，而权威来源只在少数几处记录，
因此二者之间的路径必须保持明确。）