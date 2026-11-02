---
name: onboard
description: "面向新贡献者或 agent 的上手引导文档 — 项目状态、约定以及与指定角色相关的优先事项。"
argument-hint: "[role|area]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/onboard/../../hooks/yaml-helper.sh" resolve_config *)
model: haiku
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 每次都询问 · guided 仅重要事项 · autonomous 记录并继续；
`automation_always_ask` 类别始终询问）。

# 上手引导

## 输入不足 — 在产出任何报告前先检查这一点

**如果本技能所需的输入不存在，答案就是"无法运行" —
而不是一份填写完整的报告。** 先检查，检查不通过就停止。

1. 列出本技能读取的输入（数据文件、既有报告、分析器输出、
   测试结果、注册表、源代码）。
2. 对每一项记录 `FOUND` 或 `ABSENT` — 而不是"假定存在"。
3. 如果某个章节所需的任一输入为 ABSENT，该章节即为
   **`NOT ASSESSED — NO DATA`**。不要估计它，不要从相邻产出物推断它，
   也不要把必须填写的单元格留给下一个读模板的人去填。
4. 如果**每一项**必需输入均为 ABSENT，停止并以
   **`NOT ASSESSED — NO DATA`** 作为整体结论，说明缺失了什么以及
   由哪个技能产出它。

**`NOT ASSESSED` 的结论是一种成功。** 在没有数据时，这是对
"数据说明了什么？"这一问题正确而有用的回答。这样做所避免的失败模式
很具体：一份报告的结论枚举中若没有"无法运行"状态，就会产出
**虚假的干净通过** — 例如在既无资源又无标准的项目上返回 COMPLIANT 的资源审计，
或在零分析器数据、从未设定预算的情况下报告"相对于 16.67ms 预算有 >99% 余量"的性能分析。

**证据的缺失永远不是缺失的证据。** 一次因为无文件可扫描而找不到匹配的扫描，
并没有验证任何东西。要说明发生的是这两种情况中的哪一种 —
读者无法从一个绿色的结果中分辨出来。

---

## Phase 1: 加载项目上下文

读取 CLAUDE.md 以了解项目概览和标准。

如果指定了具体角色，读取 `.claude/agents/` 中相关的 agent 定义。

`CLAUDE.md` 和 `.claude/agents/` 随框架一同提供 — 没有技能创建它们。如果其中任何一个缺失，报告它是在安装中缺失的。

---

## Phase 2: 扫描相关领域

- 程序员：扫描代码根目录（按 `.claude/docs/code-root-resolution.md` 解析）以了解架构、模式、关键文件。代码根未解析意味着扫描没有运行：由它提供输入的章节应读作 `NOT ASSESSED — code root unresolved`，绝不要猜测为 `src/`
- 设计师：扫描 `design/` 中现有的设计文档
- 叙事：扫描 `design/narrative/` 中的世界观构建和故事文档
- QA：扫描 `tests/` 中现有的测试覆盖（`/test-setup` 会创建它）
- 制作：扫描 `production/` 中的当前冲刺和里程碑
- **未给出角色或领域**：做一次总体介绍 — 列出 `design/`、
  `docs/architecture/`、`production/` 和代码根目录的顶层内容，读取
  `production/session-state/active.md`（如果存在），并说明指定角色会让下一轮更有针对性（例如 `/onboard programmer`）

读取近期变更（如有 git log）以了解当前进展势头。

---

## Phase 3: 生成上手引导文档

```markdown
# Onboarding: [Role/Area]

## Project Summary
[2-3 sentence summary of what this game is and its current state]

## Your Role
[What this role does on this project, key responsibilities, who you report to]

## Project Architecture
[Relevant architectural overview for this role]

### Key Directories
| Directory | Contents | Your Interaction |
|-----------|----------|-----------------|

### Key Files
| File | Purpose | Read Priority |
|------|---------|--------------|

## Current Standards and Conventions
[Summary of conventions relevant to this role from CLAUDE.md and agent definition]

## Current State of Your Area
[What has been built, what is in progress, what is planned next. Name what
Phase 2 found by path — for a designer, each existing GDD and design doc — or
say it found none]

## Current Sprint Context
[What the team is working on now and what is expected of this role]

## Key Dependencies
[What other roles/systems this role interacts with most]

## Common Pitfalls
[Things that trip up new contributors in this area]

## First Tasks
[Suggested first tasks to get oriented and productive]

1. [Read these documents first]
2. [Review this code/content]
3. [Start with this small task]

## Questions to Ask
[Questions the new contributor should ask to get fully oriented]
```

---

## Phase 4: 保存文档

将上手引导文档展示给用户。

询问："我可以把它写入 `production/onboarding/onboard-[role]-[date].md` 吗？"

如果同意，写入文件，必要时创建目录。

---

## Phase 5: 后续步骤

结论：**COMPLETE** — 已生成上手引导文档。

- 在新贡献者的首次会话之前，把上手引导文档分享给他们。
- 运行 `/sprint-status` 向新贡献者展示当前进度。
- 如果贡献者需要关于接下来做什么的指导，运行 `/help`。
