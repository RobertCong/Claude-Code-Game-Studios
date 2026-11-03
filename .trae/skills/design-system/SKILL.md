---
name: design-system
description: "针对单个系统逐节撰写 GDD（游戏设计文档）——逐一走完每个必需章节，并交叉引用依赖关系。"
argument-hint: "<system-name> [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density,system_overrides`

以上命令的输出已解析完成——直接使用；`--review` 会覆盖 `review_mode`。若没有配置块 → 使用 `.trae/docs/config-resolution.md` 中的默认值。

# Design System（设计系统）

当此技能被调用时：

## 1. 解析参数并校验

**立即阅读 `references/1-parse-arguments.md` 并按其执行**——本阶段的步骤在该文件中，而不在此处。如果对话在本阶段被压缩或恢复，请重新阅读该文件。

## 2. 收集上下文（读取阶段）

**立即阅读 `references/2-gather-context.md` 并按其执行**——本阶段的步骤在该文件中，而不在此处。如果对话在本阶段被压缩或恢复，请重新阅读该文件。

## 3. 创建文件骨架

**立即阅读 `references/3-file-skeleton.md` 并按其执行**——本阶段的步骤在该文件中，而不在此处。如果对话在本阶段被压缩或恢复，请重新阅读该文件。

## 4. 逐节设计

**立即阅读 `references/4-section-design.md` 并按其执行**——本阶段的步骤在该文件中，而不在此处。如果对话在本阶段被压缩或恢复，请重新阅读该文件。

## 5. 设计后校验

**立即阅读 `references/5-post-design.md` 并按其执行**——本阶段的步骤在该文件中，而不在此处。如果对话在本阶段被压缩或恢复，请重新阅读该文件。

## 6. 专家 agent 路由

此技能将领域专业知识委托给专家 agent。由主会话编排整体流程；agent 提供专家内容。

**此处的行比九个 `Category` 值划分得更细，这是有意为之**——适合战斗的专家并不适合寻路，而两者都属于 `Gameplay`。分两步解析：先从 `systems-index.md` 取得该系统的 `Category`，再在对应类别下选择与该系统实际行为相匹配的行。每个类别至少有一行，因此不会有遗漏。

| `Category` | 从以下行中选择 |
|---|---|
| `Gameplay` | 战斗/伤害/生命值 · AI/寻路/行为 · 动画/角色移动 · 角色系统 · 相机/输入/操控 |
| `Core` | 基础/基础设施 · 相机/输入/操控 |
| `Persistence` | 基础/基础设施 |
| `Economy` | 经济/战利品/制作 |
| `Progression` | 成长/经验值/技能 |
| `UI` | UI 系统 · 视觉特效（当该系统属于 HUD 邻近的 VFX 时） |
| `Audio` | 音频系统 |
| `Narrative` | 对话/任务/世界观 |
| `Meta` | 基础/基础设施（分析、教程管线）· UI 系统（无障碍选项界面） |

如果两行都适用，则生成两者 Primary agent 的并集，并说明原因。

| 系统类型 | Primary Agent | Supporting Agent(s) |
|----------------|---------------|---------------------|
| **基础/基础设施**（事件总线、存档/加载、场景管理、服务定位器） | `systems-designer` | `gameplay-programmer`（可行性）、`engine-programmer`（引擎集成） |
| 战斗、伤害、生命值 | `game-designer` | `systems-designer`（公式）、`ai-programmer`（敌人 AI）、`art-director`（受击反馈视觉方向、VFX 意图） |
| 经济、战利品、制作 | `economy-designer` | `systems-designer`（曲线）、`game-designer`（循环） |
| 成长、经验值、技能 | `game-designer` | `systems-designer`（曲线）、`economy-designer`（消耗端） |
| 对话、任务、世界观 | `game-designer` | `narrative-director`（故事）、`writer`（内容）、`art-director`（角色视觉档案、过场动画基调） |
| UI 系统（HUD、菜单） | `game-designer` | `ux-designer`（流程）、`ui-programmer`（可行性）、`art-director`（视觉风格方向）、`technical-artist`（渲染/着色器约束） |
| 音频系统 | `game-designer` | `audio-director`（方向）、`sound-designer`（规格） |
| AI、寻路、行为 | `game-designer` | `ai-programmer`（实现）、`systems-designer`（评分） |
| 关卡/世界系统 | `game-designer` | `level-designer`（空间）、`world-builder`（世界观） |
| 相机、输入、操控 | `game-designer` | `ux-designer`（手感）、`gameplay-programmer`（可行性） |
| 动画、角色移动 | `game-designer` | `art-director`（动画风格、姿态语言）、`technical-artist`（骨骼/混合约束）、`gameplay-programmer`（手感） |
| 视觉特效、粒子、着色器 | `game-designer` | `art-director`（VFX 视觉方向）、`technical-artist`（性能预算、着色器复杂度）、`systems-designer`（触发/状态集成） |
| 角色系统（属性、原型） | `game-designer` | `art-director`（角色视觉原型）、`narrative-director`（角色弧线一致性）、`systems-designer`（属性公式） |

**通过 `Agent` 工具委派时**：
- 提供：系统名称、游戏概念摘要、依赖 GDD 摘录、当前正在处理的具体章节，以及需要专家输入的问题
- agent 将分析/提案返回给主会话
- 主会话通过 `AskUserQuestion` 将 agent 的输出呈现给用户
- 由用户决定；主会话写入文件
- agent **不**直接写文件——所有文件写入均由主会话负责

---

## 7. 恢复与续接

如果会话被中断（压缩、崩溃、新会话）：

1. 读取 `production/session-state/active.md`——其中记录了当前系统以及哪些章节已完成
2. 读取 `design/gdd/[system-name].md`——有实际内容的章节即已完成；含 `[To be designed]` 的章节仍需要处理。按章节读取：用 Grep 工具查找标题（模式 `^#`，content 模式），再用 offset 和 limit 读取对应范围。
3. 从下一个未完成的章节继续——无需重新讨论已完成的章节

这就是增量写入的意义所在：每个已批准的章节都能在任何中断中保留下来。

---

## 协作协议

**在 `collaborative` 模式下（默认）。** 对于 `guided` 和 `autonomous` 模式，请参阅 `.trae/docs/automation-modes.md` 中各模式的规则——下文的“绝不”描述的是 collaborative 模式的要求，而非普遍适用的规则。

此技能在每一步都遵循协作式设计原则：

1. **每个章节都遵循 提问 -> 选项 -> 决定 -> 草稿 -> 批准**
2. **在每个决策点使用 AskUserQuestion**（先解释 -> 再采集模式）：
   - Phase 2：“可以开始了吗，还是需要更多上下文？”
   - Phase 3：“我可以创建骨架吗？”
   - Phase 4（每个章节）：设计问题、方案选项、草稿批准
   - Phase 5：“我可以更新实体注册表吗？可以更新系统索引吗？接下来做什么？”——**而不是**“要运行设计评审吗？”：§5c 禁止内联提供 `/design-review`，因为评审 agent 不得继承本会话的设计历史。Phase 5c 只呈现交接，绝不主动询问。
3. **在创建骨架前、以及每次写入章节前，询问“我可以写入 [filepath] 吗？”**
4. **增量写入**：每个章节在批准后立即写入文件
5. **会话状态更新**：每次章节写入后
6. **交叉引用**：每个章节都检查现有 GDD 是否存在冲突
7. **专家路由**：复杂章节获取专家 agent 输入，并呈现给用户决策——绝不静默写入

**绝不**自动生成完整 GDD 并把它当作既成事实呈现。
**绝不**在未经用户批准的情况下写入章节。
**绝不**与已批准的现有 GDD 相矛盾而不标记冲突。
**始终**说明决策的来源（依赖 GDD、游戏支柱、用户选择）。

## 上下文窗口感知

这是一个长时间运行的技能。每写完一个章节后，检查状态栏显示的上下文占用是否达到或超过 70%。若达到，请在回复后追加以下提示：

> **上下文正接近上限（≥70%）。** 你的进度已保存——所有已批准的章节都已写入 `design/gdd/[system-name].md`。准备好继续时，请打开一个新的 Trae 会话并运行 `/design-system [system-name]`——它会检测哪些章节已完成，并从下一个章节继续。

---

## 推荐的后续步骤

- 在**新会话**中运行 `/design-review design/gdd/[system-name].md`，以独立验证已完成的 GDD
- 运行 `/consistency-check` 以确认此 GDD 的数值与其他 GDD 不冲突
- 运行 `/map-systems next` 以转向下一个优先级最高且尚未设计的系统
- 当所有 MVP GDD 都已撰写并评审完成后，运行 `/gate-check technical-setup`