---
name: architecture-review
description: "将 GDD 需求映射到 ADR 的可追溯性矩阵。发现缺口、跨 ADR 冲突与引擎兼容性问题。PASS/CONCERNS/NOT ASSESSED/FAIL。"
argument-hint: "[focus: full | coverage | consistency | engine | rtm | single-gdd path/to/gdd.md]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow`

# 架构评审

架构评审验证整套架构决策是否覆盖了所有游戏设计需求、是否内部一致，以及是否正确针对项目锁定的引擎版本。它是技术搭建（Technical Setup）与预制作（Pre-Production）之间的质量闸门（gate）。

**参数模式：**
- **无参数 / `full`**：完整评审 —— 所有阶段
- **`coverage`**：仅可追溯性 —— 哪些 GDD 需求没有对应的 ADR
- **`consistency`**：仅跨 ADR 冲突检测
- **`engine`**：仅引擎兼容性审计
- **`single-gdd [path]`**：评审某一个特定 GDD 的架构覆盖情况
- **`rtm`**：需求可追溯性矩阵（Requirements Traceability Matrix，RTM）—— 在标准矩阵基础上扩展，纳入用户故事文件路径与测试文件路径；输出 `docs/architecture/requirements-traceability.md`，包含完整的 GDD 需求 → ADR → 用户故事 → 测试链路。在用户故事与测试都已存在时，于制作（Production）阶段使用。

---

每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 始终询问 · guided 仅关键项询问 · autonomous 记录并继续；
`automation_always_ask` 类别的项目始终提示）。

**`workflow`**（见 `.trae/docs/workflow-modes.md`）：
- `full` —— 跨所有 GDD 与所有 ADR 的完整可追溯性矩阵。
- `standard` —— 缩小范围：仅架构文档 + 关键 ADR。
- `minimal` —— 不适用（不要求架构文档）。

## Phase 1: 加载全部内容

**现在读取 `references/1-load.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 2: 从每个 GDD 提取技术需求

**现在读取 `references/2-extract-requirements.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 3: 构建可追溯性矩阵

**现在读取 `references/3-traceability.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 4: 跨 ADR 冲突检测

**现在读取 `references/4-conflicts.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 5: 引擎兼容性交叉检查

**现在读取 `references/5-engine.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 6: 架构文档覆盖情况

**现在读取 `references/6-document-coverage.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 7: 输出评审报告

**现在读取 `references/7-report.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 8: 写入并更新可追溯性索引

**现在读取 `references/8-write.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## Phase 9: 交接

**现在读取 `references/9-handoff.md` 并照其执行** —— 本阶段的步骤写在该文件中，不在此处。如果对话在本阶段期间被压缩或恢复，请重新读取该文件。

## 错误恢复协议

**首先验证产出物。** 如果返回契约中指明了路径，在把该阶段视为完成之前先检查
路径是否存在 —— **一个指明了却不在磁盘上的产出物就是失败的阶段，无论回复读起来
多么流畅。** 一个 agent 可能耗尽整个阶段、返回一段看似合理的开场白却什么都没写，
这既不是 BLOCKED、也不是错误、也不是"未能完成"，因此下面的触发条件永远不会触发。
请指明未满足的契约并要求它继续；上下文通常还在。

如果任何被派生的 agent 返回 BLOCKED、报错或未能完成：**立即上报，不要越过它阻塞的
依赖继续推进，并且始终产出部分报告**（此处的重试范围 = 更少的 GDD / 单系统）。完整流程：
`.trae/docs/error-recovery-protocol.md`。

---

## 协作协议

**适用于 `collaborative` 模式（默认）。** 关于 `guided` 与 `autonomous` 模式，见
`.trae/docs/automation-modes.md` —— 以下规则说明的是协作模式的要求，而非通用行为。

1. **静默读取** —— 不要为每次文件读取做旁白说明
2. **展示矩阵** —— 在任何写入审批之前先呈现完整的可追溯性矩阵；让用户看到当前状态
3. **不要猜测** —— 如果某项需求含义模糊，就问："[X] 是技术需求还是设计偏好？"
4. **先草稿后审批** —— 始终在请求审批之前，把将要写入的内容（报告、更新后的 ADR
   章节、systems-index 行）以行内方式展示在对话中。绝不要请求写入用户尚未看到的内容。
5. **写入审批使用 `AskUserQuestion`** —— 纯文本"可以吗？"不够。使用带标签选项
   [A]/[B]/[C] 的结构化工具，让用户可以在"现在写入"、"先展示完整草稿"和"暂不"之间
   选择。多文件变更集必须列出每个文件及其改动内容，然后用分组选项一次性询问 ——
   而不是每个文件单独问一次纯文本问题。
6. **非阻塞** —— 结论仅供参考；即使用户有 CONCERNS 甚至 FAIL 的发现，也由用户决定
   是否继续