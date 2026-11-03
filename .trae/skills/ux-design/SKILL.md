---
name: ux-design
description: "为屏幕、流程或 HUD 逐节撰写 UX 规格。读取玩家旅程以提供上下文；也涵盖项目级无障碍要求。"
argument-hint: "[screen/flow name] or 'hud' or 'patterns' or 'accessibility'"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,docs.density`

已在上一步解析 — 直接使用。若没有配置块 → 使用
`.trae/docs/config-resolution.md` 中的默认值。

# UX 设计

当此技能被调用时：

每一次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅主要节点询问 · autonomous 记录并继续；
`automation_always_ask` 类别的提问始终弹出）。

**撰写指导**：下面的骨架是自包含的 — 直接依据它们撰写。当某个小节需要更深入的说明（示例、模式目录、
无障碍标准）时，对应的指南可以提供：

| 产出 | 指南 |
|---|---|
| UX 规格 | `.trae/docs/templates/guidance/ux-spec-guide.md` |
| HUD 设计 | `.trae/docs/templates/guidance/hud-design-guide.md` |
| 交互模式 | `.trae/docs/templates/guidance/interaction-pattern-library-guide.md`（会路由到三个主题文件） |
| 无障碍要求 | `.trae/docs/templates/guidance/accessibility-requirements-guide.md` |

**按小节加载指南，绝不要整份加载** — 每份指南都按小节组织，模板中的指引会指出需要阅读的确切小节。

**`workflow`**（见 `.trae/docs/workflow-modes.md`）：
- `full` — 每个屏幕都需要一份 UX 规格。
- `standard` — 仅核心屏幕（主菜单、HUD、主游玩循环）。
- `minimal` — 不要求。也可主动运行。

**`docs.density`** — 它控制每个小节的*深度*，而 `workflow` 控制哪些屏幕需要编写规格。`modes.rigor` 会同时设置两者；若只想单独调整深度，可显式设置
`docs.density`：`terse`（默认，通过 `rigor: minimal`）= 线框图描述 +
交互要点；`balanced` = 线框图 + 流程的段落式描述
（`rigor: standard`）；`thorough` = 完整散文，包括用户研究摘要和
备选流程考量。把它应用到你撰写的每个小节。

## 1. 解析参数并确定模式

根据参数存在四种撰写模式：

| 参数 | 模式 | 输出文件 |
|----------|------|-------------|
| `hud` | HUD 设计 | `design/ux/hud.md` |
| `patterns` | 交互模式库 | `design/ux/interaction-patterns.md` |
| `accessibility` | 项目级无障碍要求 | `design/accessibility-requirements.md` |
| 任何其他值（例如 `main-menu`、`inventory`） | 某个屏幕或流程的 UX 规格 | `design/ux/[argument].md` |
| 无参数 | 询问用户 | （见下文） |

> **`accessibility` 是唯一会写入 `design/ux/` 之外的模式。** 它的
> 输出是各屏幕规格所参照的项目级标准，而不是针对单一屏幕的规格
> — `.trae/docs/workflow-catalog.yaml`、Pre-Production 与
> Polish 质量闸门（gate），以及 `/architecture-review` 都会按该确切路径检查
> `design/accessibility-requirements.md`。不要把它“整理”到
> `design/ux/` 下：上述每一项检查都会因此不再匹配，而且
> Technical Setup → Pre-Production 质量闸门将变得无法通过。

**如果未提供参数**，不要失败 — 改为询问。使用 `AskUserQuestion`：
- “我们今天要设计什么？”
  - 选项：“某个具体的屏幕或流程（我来命名）”、“游戏 HUD”、“交互模式库”、“项目级无障碍要求”、“我不确定 —— 帮我一起梳理”

如果用户选择“我来命名”或输入某个屏幕名称，将其规范化为 kebab-case
作为文件名（例如 “Main Menu” 变为 `main-menu`）。

---

## 2. 收集上下文（读取阶段）

**现在阅读 `references/2-gather-context.md` 并按其执行** — 这一阶段的步骤在该文件中，不在这里。如果本阶段对话被压缩或恢复过，请重新阅读它。

## 3. 创建文件骨架

**现在阅读 `references/3-file-skeleton.md` 并按其执行** — 这一阶段的步骤在该文件中，不在这里。如果本阶段对话被压缩或恢复过，请重新阅读它。

## 4. 逐节撰写

**现在阅读 `references/4-authoring.md` 并按其执行** — 这一阶段的步骤在该文件中，不在这里。如果本阶段对话被压缩或恢复过，请重新阅读它。

### 小节指导 — 只读取当前模式对应的那一个文件

各模式的小节撰写指导存放于各自的文件中。**当你进入
Phase 4 时，只读取与第 1 节中确定的模式相匹配的那个文件；绝不要加载
另外两个。**

| 模式 | 指导文件 |
|------|---------------|
| UX 规格（屏幕或流程） | `references/sections-ux-spec.md` |
| HUD 设计 | `references/sections-hud.md` |
| 交互模式库 | `references/sections-patterns.md` |
| 无障碍要求 | `.trae/docs/templates/guidance/accessibility-requirements-guide.md` |

> 无障碍指导位于 `templates/guidance/` 而不是本技能的 `references/`，
> 因为它所记录的模板
> （`.trae/docs/templates/accessibility-requirements.md`）也被
> `/ux-review` 以及各质量闸门文件使用。规则相同：只加载覆盖你正在撰写的那个小节的部分，
> 绝不要加载整个文件。

将 `docs.density`（第 1 节）应用到该文件要求你撰写的任何内容上 — 它
控制每个小节的深度，而不是存在哪些小节。

## 5. 交叉参照检查

**现在阅读 `references/5-crossref-handoff.md` 并按其执行** — 这一阶段的步骤在该文件中，不在这里。如果本阶段对话被压缩或恢复过，请重新阅读它。

## 7. 恢复与续写

如果会话被中断（压缩、崩溃、新会话）：

1. 读取 `production/session-state/active.md` — 它记录了当前屏幕
   以及哪些小节已完成。
2. 读取 `design/ux/[filename].md` — 含有真实内容的小节已完成；
   仍为 `[To be designed]` 的小节还需要处理。
3. 从下一个未完成的小节继续 — 无需重新讨论已完成的小节。

这就是增量写入重要性的原因：每个已批准的小节都能在任何中断后保留下来。

---

## 8. 专家代理路由

此技能使用 `ux-designer` 作为主代理（在 frontmatter 中设置）。对于
特定子主题，可能需要额外的上下文或协调：

| 主题 | 协调对象 |
|-------|----------------|
| 视觉美学、色彩、布局感受 | `art-director` — UX 规格定义分区；美术定义它们的外观 |
| 实现可行性（引擎约束） | `ui-programmer` — 在最终确定组件清单之前 |
| 玩法数据需求 | `game-designer` — 当数据归属不明确时 |
| UI 中可见的叙事/背景设定 | `narrative-director` — 用于风味文本、物品名称、背景设定面板 |
| 无障碍等级决策 | 由本会话记录（`/ux-design accessibility`；由用户选择等级），依据 `accessibility-specialist` 定义并审核的标准 — 当某项要求的判定标准不明确时咨询它 |

通过 `Agent` 工具委派给其他代理时：
- 提供：屏幕名称、游戏概念摘要、需要专家输入的具体问题
- 代理将分析结果返回本会话
- 本会话向用户展示代理的输出
- 由用户做决定；由本会话写入文件
- 代理**不**直接写文件 — 本会话负责所有文件写入

---

## 协作协议

**在 `collaborative` 模式（默认）下适用。** 对于 `guided` 与 `autonomous` 模式，
见 `.trae/docs/automation-modes.md` 中的各模式规则 — 下面的步骤
描述的是 collaborative 模式的要求，而非普遍适用的行为。

此技能在每一步都遵循协作设计原则：

1. 每个小节都遵循 **提问 -> 选项 -> 决策 -> 草稿 -> 批准**
2. 在每个决策点使用 **AskUserQuestion**（解释 -> 捕获 模式）：
   - Phase 2：“准备好开始了吗，还是需要更多上下文？”
   - Phase 3：“我可以创建骨架吗？”
   - Phase 4（每个小节）：设计问题、方案选项、草稿批准
   - Phase 5：“要运行交叉参照检查吗？接下来做什么？”
3. 在创建骨架之前以及每次写入小节之前，询问 **“我可以写入 [filepath] 吗？”**
4. **增量写入**：每个小节在批准后立即写入文件
5. **会话状态更新**：每次写入小节之后

**美学上的尊重**：当布局或视觉选择归结为个人品味时，
展示选项并询问。不要因为某个布局是“标准做法”就选择它 — 始终
确认。用户才是创意总监。

**冲突显性化**：当 GDD 要求与可用的屏幕空间发生
冲突时，显性呈现冲突并提供解决选项。绝不要悄悄舍弃某项要求。
绝不要在未提示的情况下悄悄扩展布局。

**绝不**自动生成完整规格并把它当作既成事实呈现。
**绝不**在未获用户批准的情况下写入任何小节。
**绝不**在未提示冲突的情况下违背已有的、已批准的 UX 规格。
**始终**展示决策的来源（GDD 要求、玩家旅程、用户选择）。

结论：**COMPLETE** — UX 规格已逐节完成撰写并获得批准。

---

## 推荐后续步骤

- 运行 `/ux-review [filename]`，在规格进入实现流水线之前进行验证
- 运行 `/ux-design [next-screen]`，继续设计剩余的屏幕或流程
- 当所有关键屏幕的 UX 规格都已批准后，运行 `/gate-check production`