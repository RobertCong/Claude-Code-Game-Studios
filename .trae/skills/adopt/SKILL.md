---
name: adopt
description: "棕地（brownfield）审计 — 现有产出物真的可用吗？带编号的迁移计划。与 /project-stage-detect 不同，检查的是合规性而非存在性。"
argument-hint: "[focus: full | gdds | adrs | stories | infra]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,automation_always_ask,workflow`

上一步命令的输出已解析 — 直接使用。`/adopt` 在报告和写入迁移状态时还会直接检查 `project.yaml`
与旧版配置文件；这种原始检查是有意为之，且与上文的解析值相互独立。

# Adopt — 棕地模板采纳

本技能审计现有项目的产出物是否符合模板技能流水线的**格式合规性**，
然后生成一份按优先级排序的迁移计划。

**这不是 `/project-stage-detect`。**
`/project-stage-detect` 回答：*已有什么？*
`/adopt` 回答：*已有的东西真的能与模板的技能配合工作吗？*

一个项目可以拥有 GDD、ADR 和用户故事 — 但如果这些产出物的内部格式有误，
每一个对格式敏感的技能仍会静默失败或产生错误结果。

**输出：** `docs/adoption-plan-[date].md` — 一份持久化、可勾选的迁移计划。

**参数模式：**

**审计模式：** `$ARGUMENTS`（留空 = `full`）

- **无参数 / `full`**：完整审计 — 所有产出物类型
- **`gdds`**：仅 GDD 格式合规性
- **`adrs`**：仅 ADR 格式合规性
- **`stories`**：仅用户故事格式合规性
- **`infra`**：仅基础设施产出物缺口（注册表、清单、sprint-status、stage.txt）

---

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 始终询问 · guided 仅重大事项 · autonomous 记录并继续；
`automation_always_ask` 类别始终提示）。

**`workflow`**（依据 `.trae/docs/workflow-modes.md`）。它限定 Phase 2 审计与
Phase 3 严重程度：`full` 按完整结构审计所有文档类型；`standard` 仅审计
必需的文档/章节（可选章节仅供参考，不算缺口）；
`minimal` 是一次 `design/game-brief.md` 格式检查 — 不预期存在 GDD/ADR/UX。参见 Phase 2。

## Phase 1: 检测项目状态

**现在读取 `references/1-detect.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 2: 格式审计

**现在读取 `references/2-format-audit.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 3: 对缺口进行分类并排定优先级

**现在读取 `references/3-classify.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 4: 构建迁移计划

**现在读取 `references/4-migration-plan.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 5: 呈现摘要并询问是否写入

**现在读取 `references/5-summary.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 6: 写入采纳计划

**现在读取 `references/6-write.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 7: 提供首个行动

**现在读取 `references/7-first-action.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## 协作协议

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 和
`autonomous` 模式，参见 `.trae/docs/automation-modes.md` — 以下规则
描述的是协作模式的要求，而非普遍行为。

1. **静默读取** — 在呈现任何内容之前完成完整审计
2. **先展示摘要** — 在询问是否写入之前让用户看到范围
3. **写入前询问** — 创建采纳计划文件前始终确认
4. **建议而不强加** — 计划仅供参考；由用户决定修复什么以及何时修复
5. **一次只做一件事** — 交接计划后，只提供一个具体的下一步，
   而不是同时列出六件要做的事
6. **绝不重新生成已有产出物** — 只填补现有内容的缺口；
   不要重写已有内容的 GDD、ADR 或用户故事