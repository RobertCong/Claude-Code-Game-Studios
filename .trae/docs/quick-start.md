# Game Studio Agent Architecture —— 快速入门指南

## 这是什么？

这是一套用于游戏开发的完整 Trae agent 架构。它把 49 个专业 AI agent 组织成一套模拟真实游戏开发团队的 studio 层级，配有明确的职责、委派规则和协调协议。它包含针对 Godot、Unity 和 Unreal 的引擎专家 agent —— 每个引擎都有面向主要引擎子系统的专属子专家。所有设计 agent 和模板都建立在成熟的游戏设计理论之上（MDA Framework、Self-Determination Theory、Flow State、Bartle Player Types）。请使用与你项目匹配的引擎集。

## 默认路径：Rigor Minimal

`modes.rigor` 默认为 `minimal`（`/start` 会根据你的描述推断它，并在保存前展示；`/settings` 可随时更改）。在 `minimal` 下，通向代码的路径有四步：

1. `/setup-engine` —— 配置引擎
2. `/brainstorm` —— 写入单页的 `design/game-brief.md`，以取代概念文档、系统分解和逐系统 GDD
3. `/create-stories` —— 把简报（brief）中的 MVP 清单转为 `production/epics/<slug>/` 下的故事；简报的构建顺序就是计划，因此没有 `/create-epics` 或 `/sprint-plan`
4. `/dev-story` 然后 `/story-done`，逐故事推进 —— `/story-done` 会指出下一个故事，`/help` 也知道这条路线

`minimal` 下不会运行任何 `/gate-check`，因此 `project.stage` 会停留在 Concept。每个技能在任何层级都仍可运行。代价是：没有 GDD 能在写代码前发现设计问题。当游戏超出简报的承载范围时，用 `/settings` 提高严谨度；`standard` 和 `full` 是更长的流水线，见[新项目的第一步](#first-steps-for-a-new-project)。

## 如何使用

### 1. 理解层级结构

agent 分为三个层级：

- **Tier 1 —— 总监**，负责高层决策（他们在 Opus 上运行）
  - `creative-director` —— 愿景与创意冲突解决
  - `technical-director` —— 架构与技术决策
  - `producer` —— 排期、协调与风险管理

- **Tier 2 —— 部门主管**，各自拥有自己的领域
  - `game-designer`、`lead-programmer`、`art-director`、`audio-director`、
    `narrative-director`、`qa-lead`、`release-manager`、`localization-lead`

- **Tier 3 —— 专家**，在自己的领域内执行
  - 设计师、程序员、美术、编剧、测试、工程师

层级代表角色的资历。大多数 agent 在你的会话模型上运行；agent 文件自己的 `model:` 行会说明哪些不是（`.trae/docs/model-tiers.md`）。

### 2. 为任务选择合适的 agent

问问自己：「在真实的工作室里，这会由哪个部门处理？」

| 我需要…… | 使用这个 agent |
|-------------|---------------|
| 设计一个新机制 | `game-designer` |
| 编写战斗代码 | `gameplay-programmer` |
| 创建着色器 | `technical-artist` |
| 编写对话 | `writer` |
| 规划下一个冲刺 | `producer` |
| 评审代码质量 | `lead-programmer` |
| 编写测试用例 | `qa-tester` |
| 设计一个关卡 | `level-designer` |
| 修复性能问题 | `performance-analyst` |
| 搭建 CI/CD | `devops-engineer` |
| 设计战利品表 | `economy-designer` |
| 解决创意冲突 | `creative-director` |
| 做出架构决策 | `technical-director` |
| 管理一次发布 | `release-manager` |
| 为翻译准备字符串 | `localization-lead` |
| 快速测试一个机制想法 | `prototyper` |
| 审查代码中的安全问题 | `security-engineer` |
| 检查无障碍合规性 | `accessibility-specialist` |
| 获取 Unreal Engine 建议 | `unreal-specialist` |
| 获取 Unity 建议 | `unity-specialist` |
| 获取 Godot 建议 | `godot-specialist` |
| 设计 GAS 技能/效果 | `ue-gas-specialist` |
| 定义 BP/C++ 边界 | `ue-blueprint-specialist` |
| 实现 UE 复制 | `ue-replication-specialist` |
| 构建 UMG/CommonUI 控件 | `ue-umg-specialist` |
| 设计 DOTS/ECS 架构 | `unity-dots-specialist` |
| 编写 Unity 着色器/VFX | `unity-shader-specialist` |
| 管理 Addressable 资源 | `unity-addressables-specialist` |
| 构建 UI Toolkit/UGUI 界面 | `unity-ui-specialist` |
| 编写地道的 GDScript | `godot-gdscript-specialist` |
| 编写 Godot C# 代码 | `godot-csharp-specialist` |
| 创建 Godot 着色器 | `godot-shader-specialist` |
| 构建 GDExtension 模块 | `godot-gdextension-specialist` |
| 规划线上活动与赛季 | `live-ops-designer` |
| 为玩家编写补丁说明 | `community-manager` |
| 头脑风暴一个新的游戏创意 | 使用 `/brainstorm` 技能 |

### 3. 使用技能处理常见任务

| 命令 | 作用 |
|---------|-------------|
| `/start` | 首次上手引导 —— 询问你当前所处的位置，并引导你走向正确的工作流 |
| `/help` | 上下文感知的「我接下来该做什么？」—— 读取你当前的阶段与产出物 |
| `/project-stage-detect` | 分析项目状态，检测阶段，识别缺口 |
| `/setup-engine` | 配置引擎 + 版本，填充参考资料文档 |
| `/adopt` | 面向既有项目的棕地审计与迁移计划 |
| `/brainstorm` | 从零开始引导式游戏概念构思 |
| `/map-systems` | 把概念分解为系统，梳理依赖关系，指导逐系统 GDD |
| `/design-system` | 为单个游戏系统提供引导式、逐章节的 GDD 撰写 |
| `/quick-design` | 面向小改动的轻量规格 —— 调优、微调、小幅新增 |
| `/review-all-gdds` | 跨 GDD 一致性与游戏设计理论评审 |
| `/propagate-design-change` | 找出受 GDD 变更影响的 ADR 和故事 |
| `/art-bible` | 引导式、逐章节的美术圣经撰写 —— 在资源生产前建立视觉识别规格 |
| `/asset-spec` | 从 GDD 或角色档案生成逐资源的视觉规格与 AI 生成提示词 |
| `/ux-design` | 撰写 UX 规格（界面/流程、HUD、交互模式） |
| `/ux-review` | 验证 UX 规格的无障碍性与 GDD 一致性 |
| `/create-architecture` | 游戏的主架构文档 |
| `/architecture-decision` | 创建一份 ADR |
| `/architecture-review` | 校验所有 ADR、依赖排序、GDD 可追溯性 —— 把索引写入 `docs/architecture/requirements-traceability.md` |
| `/create-control-manifest` | 从已接受的 ADR 生成扁平化程序员规则表 |
| `/create-epics` | 把 GDD + ADR 转化为史诗（epic）（每个架构模块一个） |
| `/create-stories` | 把单个史诗拆分为可实现的故事文件 |
| `/dev-story` | 阅读一个故事并实现它 —— 路由到正确的程序员 agent |
| `/sprint-plan` | 创建或更新冲刺计划 |
| `/sprint-status` | 快速 30 行冲刺快照 |
| `/story-readiness` | 在领取前校验故事是否已具备实现条件 |
| `/story-done` | 故事完成时的收尾评审 —— 验证验收标准 |
| `/estimate` | 产出结构化工作量估算 |
| `/design-review` | 评审一份设计文档 |
| `/code-review` | 评审代码的质量与架构 |
| `/balance-check` | 分析游戏平衡性数据 |
| `/asset-audit` | 审计资源的合规性 |
| `/content-audit` | GDD 指定内容与已实现内容的对比 —— 找出缺口 |
| `/scope-check` | 检测相对于计划的范畴蔓延 |
| `/perf-profile` | 性能分析与瓶颈定位 |
| `/tech-debt` | 扫描、跟踪并优先排序技术债 |
| `/gate-check` | 校验阶段就绪度（PASS/CONCERNS/NOT ASSESSED/FAIL） |
| `/consistency-check` | 扫描所有 GDD 的跨文档不一致（冲突的数值、名称、规则） |
| `/security-audit` | 审计安全漏洞：存档篡改、作弊途径、网络漏洞利用、数据暴露 |
| `/reverse-document` | 从既有代码生成设计/架构文档 |
| `/milestone-review` | 评审里程碑进展 |
| `/retrospective` | 运行冲刺/里程碑复盘 |
| `/bug-report` | 结构化的缺陷报告创建 |
| `/playtest-report` | 创建或分析试玩测试反馈 |
| `/onboard` | 为某个角色生成上手引导文档 |
| `/release-checklist` | 校验发布前检查清单 |
| `/launch-checklist` | 完整的上线就绪校验 |
| `/changelog` | 从 git 历史生成变更日志 |
| `/patch-notes` | 生成面向玩家的补丁说明 |
| `/hotfix` | 带审计追踪的紧急修复 |
| `/day-one-patch` | 为黄金母盘（gold master）之后发现的已知问题准备聚焦的首日补丁 |
| `/prototype` | 概念原型 —— 在编写 GDD 之前验证核心想法（Phase 1） |
| `/vertical-slice` | 生产级端到端构建 —— 验证完整游戏循环（Phase 4） |
| `/localize` | 本地化扫描、提取、校验 |
| `/team-combat` | 编排完整的战斗团队流水线 |
| `/team-narrative` | 编排完整的叙事团队流水线 |
| `/team-ui` | 编排完整的 UI 团队流水线 |
| `/team-release` | 编排完整的发布团队流水线 |
| `/team-polish` | 编排完整的打磨团队流水线 |
| `/team-audio` | 编排完整的音频团队流水线 |
| `/team-level` | 编排完整的关卡创建流水线 |
| `/team-live-ops` | 为赛季、活动和发布后内容编排长线运营团队 |
| `/team-qa` | 编排完整的 QA 团队周期 —— 测试计划、测试用例、冒烟检查、签核 |
| `/qa-plan` | 为冲刺或功能生成 QA 测试计划 |
| `/bug-triage` | 重新排定未修复缺陷的优先级、指派到冲刺、揭示系统性问题趋势 |
| `/smoke-check` | 在 QA 交接前运行关键路径冒烟测试闸门（PASS/FAIL） |
| `/soak-test` | 为长时间游戏会话生成浸泡测试方案 |
| `/regression-suite` | 将覆盖率映射到 GDD 关键路径，标记缺口，维护回归套件 |
| `/test-setup` | 为项目所用引擎搭建测试框架 + CI 流水线（运行一次） |
| `/test-helpers` | 生成引擎特定的测试辅助库和工厂函数 |
| `/test-flakiness` | 从 CI 历史检测不稳定测试，标记为隔离或修复 |
| `/test-evidence-review` | 对测试文件与人工证据进行质量评审 —— ADEQUATE/INCOMPLETE/MISSING |
| `/skill-test` | 校验技能文件的合规性与正确性（static / spec / audit） |
| `/skill-improve` | 用「测试-修复-复测」循环改进技能 —— 诊断、提出修复、重写、验证 |

### 4. 为新文档使用模板

模板位于 `.trae/docs/templates/`：

- `game-design-document.md` —— 用于新机制与系统
- `architecture-decision-record.md` —— 用于技术决策
- `architecture-traceability.md` —— 从 GDD 需求到 ADR 再到故事索引的示例布局（`/architecture-review` 会把自有的索引写入 `docs/architecture/requirements-traceability.md`）
- `risk-register-entry.md` —— 用于新风险
- `narrative-character-sheet.md` —— 用于新角色
- `test-plan.md` —— 用于功能测试计划
- `sprint-plan.md` —— 用于冲刺规划
- `milestone-definition.md` —— 用于新里程碑
- `level-design-document.md` —— 用于新关卡
- `game-pillars.md` —— 用于核心设计支柱
- `art-bible.md` —— 用于视觉风格参考
- `technical-design-document.md` —— 用于逐系统技术设计
- `post-mortem.md` —— 用于项目/里程碑复盘
- `sound-bible.md` —— 用于音频风格参考
- `release-checklist-template.md` —— 用于平台发布检查清单
- `changelog-template.md` —— 用于面向玩家的补丁说明
- `release-notes.md` —— 用于面向玩家的发布说明
- `incident-response.md` —— 用于线上事故响应手册
- `game-concept.md` —— 用于初始游戏概念（MDA、SDT、Flow、Bartle）
- `game-brief.md` —— 用于在 `rigor: minimal` 下取代概念文档的单页简报
- `pitch-document.md` —— 用于向利益相关方推介游戏
- `economy-model.md` —— 用于虚拟经济设计（汇/源模型）
- `faction-design.md` —— 用于阵营身份、背景故事和玩法角色
- `systems-index.md` —— 用于系统分解与依赖映射
- `project-stage-report.md` —— 用于项目阶段检测输出
- `design-doc-from-implementation.md` —— 用于把既有代码反向记录为 GDD
- `architecture-doc-from-code.md` —— 用于把代码反向记录为架构文档
- `concept-doc-from-prototype.md` —— 用于把原型反向记录为概念文档
- `ux-spec.md` —— 用于逐界面的 UX 规格（布局区域、状态、事件）
- `hud-design.md` —— 用于整个游戏的 HUD 理念、区域和元素规格
- `accessibility-requirements.md` —— 用于项目级无障碍层级与功能矩阵
- `interaction-pattern-library.md` —— 用于标准 UI 控件和游戏特定模式
- `player-journey.md` —— 用于 6 阶段情感弧线与按时间尺度的留存钩子
- `difficulty-curve.md` —— 用于难度维度、上手引导坡道和跨系统交互
- `test-evidence.md` —— 用于记录人工测试证据（截图、走查笔记）的模板

### 5. 遵循协调规则

1. 工作沿层级向下流动：总监 -> 主管 -> 专家
2. 冲突沿层级向上升级
3. 跨部门工作由 `producer` 协调
4. 未经委派，agent 不修改其领域之外的文件
5. 所有决策都要记录

## 新项目的第一步

**不知道从哪里开始？** 运行 `/start`。它会询问你当前所处的位置，并把你引导到正确的工作流。它不对你的游戏、引擎或经验水平做任何假设。

下面的路径走的是 `standard`/`full` 流水线。在 `rigor: minimal`（默认值）下，请改走[默认路径](#the-default-path-rigor-minimal)。

如果你已经知道自己需要什么，可以直接跳到相关路径：

### Path A：「我完全不知道要做什么」

1. **运行 `/start`**（或 `/brainstorm open`）—— 引导式创意探索：
   什么让你兴奋、你玩过什么、你的约束条件
   - 生成 3 个概念，帮助你选择其中一个，定义核心循环与支柱
   - 产出一份游戏概念文档并推荐引擎
2. **搭建引擎** —— 运行 `/setup-engine`（使用头脑风暴给出的推荐）
   - 配置 AGENTS.md，检测知识缺口，填充参考资料文档
   - 把引擎、命名约定和性能预算写入 `project.yaml`（事实来源），并镜像到 `.trae/docs/technical-preferences.md`
   - 如果引擎版本比 LLM 的训练数据更新，它会从网络获取当前文档，以便 agent 建议正确的 API
3. **验证概念** —— 运行 `/design-review design/gdd/game-concept.md`
   （或 `design/game-brief.md`，如果 `/brainstorm` 写入了单页简报）
4. **为机制做原型** —— 运行 `/prototype [core-mechanic]`（最多 1 天），在编写 GDD 之前验证核心想法是否有趣
5. **分解为系统** —— 运行 `/map-systems` 梳理所有系统与依赖
6. **设计每个系统** —— 运行 `/design-system [system-name]`（或 `/map-systems next`），按依赖顺序撰写 GDD，并以原型发现为依据
7. **规划第一个冲刺** —— 在架构和 `/vertical-slice` 之后，运行 `/sprint-plan new`
8. 开始构建

### Path B：「我知道我想做什么」

如果你已经有游戏概念和引擎选择：

1. **搭建引擎** —— 运行 `/setup-engine [engine] [version]`（例如 `/setup-engine godot 4.7`）—— 也会创建技术偏好
2. **编写游戏支柱** —— 委派给 `creative-director`
3. **分解为系统** —— 运行 `/map-systems` 枚举系统与依赖
4. **设计每个系统** —— 运行 `/design-system [system-name]`，按依赖顺序撰写 GDD
5. **创建初始 ADR** —— 运行 `/architecture-decision`
6. **在 `production/milestones/` 中创建第一个里程碑**
7. **规划第一个冲刺** —— 运行 `/sprint-plan new`
8. 开始构建

### Path C：「我知道游戏是什么，但不知道用哪个引擎」

如果你有概念但不知道哪个引擎合适：

1. **运行 `/setup-engine`**，不带参数 —— 它会询问你游戏的需求（2D/3D、平台、团队规模、语言偏好），并根据你的回答推荐引擎
2. 从第 2 步开始遵循 Path B

### Path D：「我已有一个现成项目」

如果你已有设计文档、原型或代码：

1. **运行 `/start`**（或 `/project-stage-detect`）—— 分析现有内容，识别缺口，并建议下一步
2. **如果有既有的 GDD、ADR 或故事，运行 `/adopt`** —— 审计内部格式合规性，并构建编号迁移计划，在不覆盖你现有工作的前提下填补缺口
3. **按需配置引擎** —— 如果尚未配置，运行 `/setup-engine`
4. **校验阶段就绪度** —— 运行 `/gate-check` 查看你当前所处的位置
5. **规划下一个冲刺** —— 运行 `/sprint-plan new`

## 文件结构参考

```
AGENTS.md                          -- Master config (read this first, ~80 lines)
project.yaml                       -- Machine-readable project config (engine, modes, stage) — source of truth
.trae/
  hooks.json                       -- Trae hooks (version 1) and project safety wiring
  agents/                          -- 49 agent definitions (YAML frontmatter)
  skills/                          -- 74 skill definitions (YAML frontmatter)
  hooks/                           -- 20 hook scripts (.sh, wired by hooks.json) + helpers
  rules/                           -- 14 path-specific rule files (globs)
  docs/
    quick-start.md                 -- This file
    technical-preferences.md       -- Legacy fallback for project.yaml config (mirror; see project.yaml at repo root)
    coding-standards.md            -- Coding and design doc standards
    coordination-rules.md          -- Agent coordination rules
    context-management.md          -- Context budgets and compaction instructions
    directory-structure.md         -- Project directory layout
    workflow-catalog.yaml          -- 7-phase pipeline definition (read by /help)
    setup-requirements.md          -- System prerequisites (Git Bash, jq, Python)
    settings-local-template.md     -- Personal settings.local.json guide
    CLAUDE-local-template.md       -- Personal CLAUDE.local.md guide (gitignored overrides)
    templates/                     -- 62 document templates (+ per-section guidance)
```
