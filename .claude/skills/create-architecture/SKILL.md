---
name: create-architecture
description: "在编写代码之前撰写架构蓝图。对照锁定的引擎验证决策，标出知识缺口。"
argument-hint: "[focus-area: full | layers | data-flow | api-boundaries | adr-audit] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, Bash(bash "*/.claude/skills/create-architecture/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/registry.sh *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density`

以上为已解析结果——按原样使用；`--review` 会覆盖 `review_mode`。若无输出块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

# 创建架构

此技能生成 `docs/architecture/architecture.md` —— 主架构
文档，它将所有已批准的 GDD 转化为具体的技术蓝图。
它位于设计与实现之间，必须在冲刺规划开始之前存在。

**区别于 `/architecture-decision`**：ADR 记录单个点状决策。
此技能创建为 ADR 提供上下文的整体系统蓝图。

完整的检查模式见 `.claude/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.claude/docs/director-gates/[gate-id].md` —— 被生成的 agent 会读取自己的闸门文件；不要在父会话中读取它。

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（协作模式总是询问 · 引导模式仅询问重大事项 · 自主模式记录并继续；
`automation_always_ask` 类别始终提示）。

**`docs.density`** —— 它控制每个章节的*深度*，而 `workflow` 控制存在哪些章节。`modes.rigor` 会同时设置两者；显式设置
`docs.density` 可单独调整深度：`terse`（默认，通过 `rigor: minimal`）= 层级图 + 决策要点，
不写长文；`balanced` = 图表 + 对层级选择的段落解释
（`rigor: standard`）；`thorough` = 完整散文，每层包含理由、取舍和
考虑过的替代方案。将它应用于你撰写的每个章节。

**`workflow`**（见 `.claude/docs/workflow-modes.md`）：
- `full` —— 完整架构：所有层级、模块归属、数据流、API
  边界、完整 ADR 审计。
- `standard` —— 简化：仅系统层级图 + 关键 ADR 列表。
- `minimal` —— 非必需。仍可自愿运行。

**参数模式：**
- **无参数 / `full`**：完整引导式走查 —— 所有章节，从头到尾
- **`layers`**：仅聚焦系统层级图
- **`data-flow`**：仅聚焦模块之间的数据流
- **`api-boundaries`**：仅聚焦 API 边界定义
- **`adr-audit`**：仅审计现有 ADR 的引擎兼容性缺口

---

## Phase 0: 加载全部上下文

**现在读取 `references/0-load-context.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 1: 系统层级映射

**现在读取 `references/1-layers.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 2: 模块归属映射

**现在读取 `references/2-module-ownership.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 3: 数据流

**现在读取 `references/3-data-flow.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 4: API 边界

**现在读取 `references/4-api-boundaries.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 5: ADR 审计 + 可追溯性检查

**现在读取 `references/5-adr-audit.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 6: 缺失 ADR 列表

**现在读取 `references/6-missing-adrs.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 7: 写入主架构文档

**现在读取 `references/7-write.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## Phase 8: 交接

**现在读取 `references/8-handoff.md` 并遵循它** —— 此阶段的步骤在该文件中，不在这里。如果对话在此阶段被压缩或恢复，请重新读取它。

## 协作协议

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 和
`autonomous` 模式，见 `.claude/docs/automation-modes.md` —— 下述规则
描述的是协作模式的要求，不是通用行为。

此技能在每个阶段都遵循协作式设计原则：

1. **静默加载上下文** —— 不要叙述文件读取过程
2. **呈现发现** —— 展示知识缺口清单与层级提案
3. **决策前先询问** —— 为每个架构选择呈现选项
4. **批准前先起草** —— 在请求写入之前内联展示内容。
   绝不要为用户尚未看过的章节请求批准。
5. **使用 `AskUserQuestion` 进行写入批准** —— 纯文本 "May I?" 不够。
   使用带标签选项 [A]/[B]/[C] 的结构化工具（立即写入 /
   先展示完整草案 / 还不是）。对于多文件变更集，列出每个文件
   及其变更，然后一次性分组询问 —— 而不是逐文件单独发送纯文本询问。
6. **每次写入都在所有章节批准后进行** —— 文档只在 Phase 7 写入一次；
   Phase 7b 的第 4 步只在自身询问后更新其 Document Status。在推进过程中
   将每个已批准章节的决策记录到
   `production/session-state/active.md`，这样崩溃不会丢失任何决策。
   Phase 7b 强制进行的修订也以同样方式写入 —— 在其重新起草的章节被批准后
   只写一次 —— 而更新（Phase 0e）只写入它选定的章节。

绝不在没有用户输入的情况下做出有约束力的架构决策。如果用户
不确定，在请其决定之前呈现 2-4 个带优缺点的选项。

---

## 建议的后续步骤

- 对 Phase 6 中列出的每个必需 ADR 运行 `/architecture-decision [title]` —— 先做 Foundation 层 ADR
- 运行 `/architecture-review` —— 根据刚写入的 ADR 引导建立需求可追溯性矩阵与 TR 注册表，并赋予每个临时 TR-ID 永久 ID。Pre-Production 质量闸门之前必需。
- 运行 `/test-setup` 以搭建 `tests/unit/`、`tests/integration/`、CI 工作流和一个示例测试（gate-check 必需）
- 运行 `/ux-design` 以初始化 `design/ux/interaction-patterns.md` 和 `design/accessibility-requirements.md`（gate-check 必需）
- 必需 ADR 写完后运行 `/create-control-manifest`，生成层级规则清单
- 当所有必需 ADR、`/test-setup` 和 `/ux-design` 都完成后，运行 `/gate-check pre-production`
