---
name: review-all-gdds
description: "跨 GDD 的整体评审 — 系统之间的矛盾、主导策略、经济失衡、认知过载、支柱漂移。"
argument-hint: "[focus: full | consistency | design-theory | since-last-review]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Agent, Bash(bash "*/.claude/skills/review-all-gdds/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/review-scope.sh*)
model: opus
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,system_overrides`

# 评审所有 GDD

本技能会同时读取每个系统的 GDD，并执行两项无法在单个 GDD 内独立完成的互补评审：

1. **跨 GDD 一致性** — 文档之间的矛盾、过期引用和归属冲突
2. **游戏设计整体性** — 只有把全部系统放在一起看才会浮现的问题：主导策略、崩坏的经济、认知过载、支柱漂移、相互竞争的成长循环

**这与 `/design-review` 不同**，后者评审单个 GDD 的内部完整性。本技能评审所有 GDD 之间的*关系*。

**何时运行：**
- 所有 MVP 层级的 GDD 均已单独批准之后
- 任何 GDD 在制作中期被大幅修订之后
- `/create-architecture` 开始之前（建立在彼此不一致的 GDD 之上的架构会继承这些不一致）

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`（collaborative 始终询问 · guided 仅重大事项 · autonomous 记录后继续；`automation_always_ask` 类别始终询问）。

**参数模式：**

**Focus：** `$ARGUMENTS`（留空 = `full`）

- **无参数 / `full`**：同时执行一致性和设计理论两轮评审
- **`consistency`**：仅执行跨 GDD 一致性检查（更快）
- **`design-theory`**：仅执行游戏设计整体性检查
- **`since-last-review`**：仅检查自上次评审报告以来被修改的 GDD（基于 git）

---

**`workflow`** 按 GDD 生效（依据 `.claude/docs/workflow-modes.md`）：每个 GDD 按其有效层级进行校验 — 项目值，当 `system_overrides` 中列出了某个系统的覆盖行时，该系统按该行覆盖。在 `full` 下，校验所有 GDD 的全部 8 个章节。在 `standard` 下，校验 5 个必需章节；可选章节（Player Fantasy、Tuning Knobs、条件性 Formulas）仅作为建议性提示给出。在 `minimal` 下，本技能不适用（没有 GDD）。

## Phase 1: 加载全部内容

**现在读取 `references/1-load.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

### 并行执行

Phase 2（一致性）和 Phase 3（设计理论）相互独立 — 它们读取相同的 GDD 输入，但产出各自的报告。应将两者同时作为并行的 `Agent` 子代理启动，而不是等 Phase 2 完成后再开始 Phase 3。在编写合并报告之前收集两者的结果。

两者都作为 `game-designer` 子代理启动（`subagent_type: game-designer`）— GDD 一致性与设计理论评审正是其领域。

**启动 Phase 2 和 Phase 3 代理时，始终传递：**
- 每个阶段所需的已加载 GDD **内容** — **不是文件路径**。粘贴相应章节；子代理有自己的上下文，无法重新读取 Phase 1 的结果，因此给路径会强制其完整重读（并违背下文"不要重读"的规则）。只传该阶段的切片：Phase 2（一致性）需要每个 GDD 的 Dependencies、Detailed Design/Rules、Formulas、Tuning Knobs 和 Acceptance Criteria；Phase 3（设计理论）需要 Player Fantasy、成长/奖励结构以及游戏支柱。
- 若在 Phase 1b 中加载了完整的实体注册表内容（`design/registry/entities.yaml`），则一并传入（粘贴注册表文本，而不只是文件路径）
- 分配给该代理阶段的具体检查清单条目（Phase 2 获得 2a–2f；Phase 3 获得 3a–3g）
- 引擎名称和版本 — `project.yaml` 中的 `engine.name` 和 `engine.version`，两个字段各自独立解析（若其键缺失或为空，则使用 `.claude/docs/technical-preferences.md`）— 以及 `docs/engine-reference/[engine]/VERSION.md`

不要依赖子代理自行重读这些文件 — 它有自己的上下文窗口，除非在 `Agent` 提示中显式传入，否则无法访问 Phase 1 的结果。

---

## Phase 2: 跨 GDD 一致性

**现在读取 `references/2-consistency.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 3: 游戏设计整体性

**现在读取 `references/3-design-holism.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 4: 跨系统场景走查

**现在读取 `references/4-scenarios.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 5: 输出评审报告

**现在读取 `references/5-report.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 6: 编写报告并标记 GDD

**现在读取 `references/6-write.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 7: 交接

**现在读取 `references/7-handoff.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## 错误恢复协议

**首先，验证产出物。** 如果返回契约指定了某个路径，在把该阶段视为完成之前先检查该路径是否存在 — **一个被命名却不在磁盘上的产出物就是失败的阶段，无论回复读起来多么流畅。** 代理可能烧掉一整个阶段、返回一段看似合理的开场白却什么都没写，而这种情况既不是 BLOCKED 也不是错误也不是"未能完成"，因此下面的触发条件永远不会触发。以"未满足的契约"为由恢复它；上下文通常还在。

如果任何被启动的代理返回 BLOCKED、报错或未能完成：**立即将其呈现出来，不要越过它所阻塞的依赖继续推进，并且始终产出部分报告**（此处的重试范围 = 更少的 GDD / 单系统）。完整流程：`.claude/docs/error-recovery-protocol.md`。

---

## 协作协议

**在 `collaborative` 模式（默认）下。** 关于 `guided` 和 `autonomous` 模式，见 `.claude/docs/automation-modes.md`。在 `autonomous` 模式下，PASS/CONCERNS/FAIL 结论仍会打印并记录日志 — 只是跳过收尾的交接组件。

1. **静默读取** — 在呈现任何内容之前加载所有 GDD
2. **展示全部内容** — 在请求任何操作之前，呈现完整的一致性分析与设计理论分析
3. **区分阻塞项与建议项** — 不是每个问题都需要阻塞架构；要明确哪些确实需要
4. **不做设计决策** — 指出矛盾与选项，但绝不单方面断定哪个 GDD 是"对的"
5. **写之前先问** — 在编写报告或更新系统索引之前先确认
6. **具体** — 每个问题都必须引用确切的 GDD、章节和涉及文本；不要模糊的警告
