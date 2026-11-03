# Claude Code Game Studios -- 完整工作流指南

> **如何借助 Agent 架构（Agent Architecture）从零开始做出一款已发布的游戏。**
>
> 本指南将带你走过游戏开发的每个阶段，使用 49 个 agent 的体系、
> 74 个技能和 13 个自动化钩子（hook）。前提是你已安装 Trae CN，
> 并在项目根目录下工作。
>
> 流水线共 7 个阶段。在 `rigor: standard` 和 `full` 下，每个阶段都有一个
> 正式的质量闸门（`/gate-check`），必须通过才能继续。在
> `rigor: minimal`（默认值）下，不要求任何闸门；参见
> [默认路径](#the-default-path-rigor-minimal)。权威的
> 阶段顺序定义在 `.trae/docs/workflow-catalog.yaml` 中，由 `/help` 读取。

---

## 目录

1. [快速开始](#quick-start)
2. [默认路径：Minimal 严格度](#the-default-path-rigor-minimal)
3. [Phase 1：概念](#phase-1-concept)
4. [Phase 2：系统设计](#phase-2-systems-design)
5. [Phase 3：技术搭建](#phase-3-technical-setup)
6. [Phase 4：预制作](#phase-4-pre-production)
7. [Phase 5：制作](#phase-5-production)
8. [Phase 6：打磨](#phase-6-polish)
9. [Phase 7：发布](#phase-7-release)
10. [横切关注点](#cross-cutting-concerns)
11. [附录 A：Agent 快速参考](#appendix-a-agent-quick-reference)
12. [附录 B：斜杠命令快速参考](#appendix-b-slash-command-quick-reference)
13. [附录 C：常见工作流](#appendix-c-common-workflows)

---

<a id="quick-start"></a>
## 快速开始

### 你需要什么

在开始之前，请确保你具备：

- 已安装并可用的 **Trae CN**
- **Git**（Windows 上为 Git Bash，Mac/Linux 上为标准终端）
- **jq**（可选但推荐 -- 若缺失，钩子会回退到 `grep`）
- **Python 3**（必需 -- 每个技能和钩子都通过它读取 `project.yaml`；没有它，每项设置都会静默回退到默认值）

### Step 1：克隆并打开

```bash
git clone <repo-url> my-game
cd my-game
```

### Step 2：运行 /start

如果这是你的第一次会话：

```
/start
```

这套引导式上手流程会询问你所处的状态，并将你路由到正确的阶段：

- **Path A** -- 尚无想法：路由到 `/brainstorm`
- **Path B** -- 想法模糊：带上种子（seed）路由到 `/brainstorm`
- **Path C** -- 概念清晰：路由到 `/brainstorm` 把它写下来，或
  直接进入 `/setup-engine`
- **Path D** -- 已有工作：当未设置引擎且内容不超过一个概念时，路由到
  `/setup-engine`；否则路由到 `/project-stage-detect`，
  再用 `/adopt` 进行存量项目（brownfield）迁移

### Step 3：验证钩子正常工作

在 Trae 中打开一个新会话。你应当看到 `session-start.sh` 钩子的输出：

```
=== Claude Code Game Studios -- Session Context (Trae) ===
Branch: main
Recent commits:
  abc1234 Initial commit
===================================
```

如果看到这些内容，说明钩子工作正常。如果没有，请检查
`.trae/hooks.json`，确认钩子路径与你的操作系统匹配，并在 Trae 的
**设置 > Hooks** 中确认项目 Hook 已启用。

### Step 4：随时寻求帮助

在任何时候，运行：

```
/help
```

它会从 `project.yaml` 的 `project.stage` 读取你当前所处的阶段（回退到
`production/stage.txt`）-- 在 `rigor: minimal` 下阶段永不推进，此时它改为
遵循 minimal 路线 -- 检查哪些产出物存在，并明确告诉你下一步该做什么。
它会区分必需的后续步骤与可选的后续机会。

### Step 5：创建目录结构

目录按需创建。系统期望如下布局：

```
src/                  # Game source code (Godot; Unity: Assets/, Unreal: Source/<Module>/)
  core/               # Engine/framework code
  gameplay/           # Gameplay systems
  ai/                 # AI systems
  networking/         # Multiplayer code
  ui/                 # UI code
  tools/              # Dev tools
assets/               # Game assets
  art/                # Sprites, models, textures
  audio/              # Music, SFX
  vfx/                # Particle effects
  shaders/            # Shader files
  data/               # JSON config/balance data
design/               # Design documents
  gdd/                # Game design documents
  narrative/          # Story, lore, dialogue
  levels/             # Level design documents
  balance/            # Balance spreadsheets and data
  ux/                 # UX specifications
docs/                 # Technical documentation
  architecture/       # Architecture Decision Records
  api/                # API documentation
  postmortems/        # Post-mortems
tests/                # Test suites
prototypes/           # Throwaway prototypes
production/           # Sprint plans, milestones, releases
  sprints/
  milestones/
  releases/
  epics/              # Epic and story files (from /create-epics + /create-stories)
  playtests/          # Playtest reports
  session-state/      # Ephemeral session state (gitignored)
  session-logs/       # Session audit trail (gitignored)
```

> **提示：** 你不需要在第一天就备齐这些目录。随着进入需要它们的阶段，
> 再创建相应目录。重要的是：创建时遵循这套结构，因为**规则系统**会依据
> 文件路径执行标准。`src/gameplay/` 中的代码应用 gameplay 规则，
> `src/ai/` 中的代码应用 AI 规则，依此类推 —— Unity 和 Unreal 的
> `Gameplay/` 与 `AI/` 文件夹中的 C# 和 C++ 代码同样如此。

---

<a id="the-default-path-rigor-minimal"></a>
## 默认路径：Minimal 严格度

`modes.rigor` 默认为 `minimal`（`/start` 会根据你的描述推断档位，并在保存前
展示；`/settings` 可随时更改）。在 `minimal` 下，通往代码的路径只有四步：

1. `/setup-engine` -- 配置引擎
2. `/brainstorm` -- 写出一页纸的 `design/game-brief.md`，它取代
   完整的概念文档、系统拆解以及各系统的 GDD
3. `/create-stories` -- 将简报中的 MVP 清单和构建顺序转化为用户故事，
   放在 `production/epics/<slug>/` 下。不用 `/create-epics`，不用
   `/sprint-plan`：简报的构建顺序就是计划
4. 逐个用户故事执行 `/dev-story`，然后 `/story-done`。`/story-done` 会指出
   下一个用户故事，`/help` 也认识这条路线

这条路径上不会运行 `/gate-check`，因此 `project.stage` 停留在 Concept --
这是预期行为。任何档位下每个技能仍可运行；严格度改变的是
要求什么，而不是允许什么。

代价是：没有 GDD 在问题进入代码之前发现设计问题。
当游戏超出一页纸简报的承载能力时 -- 多个相互影响的系统、由他人实现的设计、
一个团队，或固定的发布日期 -- 用 `/settings` 提高严格度。已有文件保持原位，
`/help` 会显示新档位接下来要求什么。

本指南的其余部分描述的是 `standard`/`full` 流水线。

---

<a id="phase-1-concept"></a>
## Phase 1: 概念

### 本阶段会发生什么

你从「没有想法」或「想法模糊」出发，得到一份结构化的游戏概念文档，
其中定义了游戏支柱和玩家旅程。在这里你要弄清楚自己**做什么**以及**为什么**做。

### Phase 1 流水线

```
/brainstorm  -->  game-concept.md  -->  /design-review  -->  /setup-engine
     |                                        |                    |
     v                                        v                    v
  10 concepts     Concept doc with       Validation          Engine pinned in
  MDA analysis    pillars, MDA,          of concept          project.yaml
  Player motiv.   core loop, USP         document
                                                                   |
                                                                   v
                                                             /prototype
                                                       (concept prototype — 1 day max)
                                                        PROCEED ↓     PIVOT → /brainstorm
                                                                   |
                                                                   v (PROCEED)
                                                             /map-systems
                                                                   |
                                                                   v
                                                            systems-index.md
                                                            (all systems, deps,
                                                             priority tiers)
```

### Step 1.1：使用 /brainstorm 进行头脑风暴

这是你的起点。运行头脑风暴技能：

```
/brainstorm
```

或者带上类型提示：

```
/brainstorm roguelike deckbuilder
```

**会发生什么：** brainstorm 技能会引导你走完一个 6 阶段的协作式
构思流程，采用专业工作室的方法：

1. 询问你的兴趣、主题和约束
2. 生成 10 个概念种子，并做 MDA（Mechanics、Dynamics、Aesthetics）分析
3. 你挑选 2-3 个最喜欢的进行深入分析
4. 执行玩家动机映射和目标受众定位
5. 你选择胜出的概念
6. 将其正式化为 `design/gdd/game-concept.md`

概念文档包含：

- 电梯陈述（一句话）
- 核心幻想（玩家想象自己正在做什么）
- MDA 拆解
- 目标受众（Bartle 类型、人群画像）
- 核心循环图
- 独特卖点
- 可比作品及差异化
- 游戏支柱（3-5 个不可妥协的设计价值）
- 反支柱（游戏有意避免的东西）

### Step 1.2：评审概念（可选但推荐）

```
/design-review design/gdd/game-concept.md
```

在继续之前验证结构与完整性。

### Step 1.3：选择引擎

```
/setup-engine
```

或指定某个引擎：

```
/setup-engine godot 4.7
```

**/setup-engine 会做什么：**

- 将引擎、语言、专人（specialist）、命名约定和性能预算写入
  `project.yaml`（唯一事实来源），并同步到
  `.trae/docs/technical-preferences.md`（人类可读的旧版回退文件）
- 检测知识缺口（引擎版本比 LLM 训练数据更新），并建议交叉核对
  `docs/engine-reference/`
- 在 `docs/engine-reference/` 中创建版本锁定的参考文档

**为什么重要：** 设定引擎之后，系统就知道该使用哪些引擎专家 agent。如果选择
Godot，`godot-specialist`、`godot-gdscript-specialist` 和
`godot-shader-specialist` 等 agent 就会成为你的首选专家。

### Step 1.4：将概念拆解为系统

在编写各个 GDD 之前，先枚举游戏需要的所有系统：

```
/map-systems
```

这会创建 `design/gdd/systems-index.md` -- 一份总跟踪文档，它会：

- 列出游戏需要的每个系统（战斗、移动、UI 等）
- 映射系统之间的依赖
- 分配优先级层级（MVP、Vertical Slice、Alpha、Full Vision）
- 确定设计顺序（Foundation > Core > Feature > Presentation > Polish）

这一步是进入 Phase 2 之前的**必需**步骤。来自 155 份游戏
复盘（postmortem）的研究表明，跳过系统枚举会在制作阶段多付出 5-10 倍的代价。

### Step 1.5：美术圣经

```
/art-bible
```

编写 `design/art/art-bible.md`，即所有资源都要遵循的视觉识别规范。
在概念获批后运行一次；`/art-bible` 建议在 `/map-systems`（Step 1.4）之前完成。
第 1–4 节是 `/gate-check pre-production` 之前所需，9 节全部是
`/gate-check production` 之前所需。在 `standard` 下，仅当游戏包含视觉资源
用户故事时才必需；在 `minimal` 下为可选。

### Phase 1 闸门

```
/gate-check systems-design
```

**通过要求：**

- 内容完整的 `design/gdd/game-concept.md`，包含游戏支柱和一个视觉识别
  锚点（Visual Identity Anchor）章节（在 `minimal` 下：内容完整的 `design/game-brief.md`）
- 推荐：一份概念原型，其 REPORT.md 结论为 PROCEED

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-systems-design.md` 包含完整
检查清单以及每个档位删减的内容。

**结论：** PASS / CONCERNS / NOT ASSESSED / FAIL。PASS 会推进阶段。
在 CONCERNS 下，只有你明确接受风险（且风险被记录）时才会推进；
FAIL 永不推进。NOT ASSESSED 意味着某项必需内容无法被检查。

---

<a id="phase-2-systems-design"></a>
## Phase 2: 系统设计

### 本阶段会发生什么

你要创建所有定义游戏如何运作的设计文档。此时还不写代码 -- 这是纯设计。
系统索引中识别出的每个系统都会有一份自己的 GDD，逐节编写、单独评审，
然后对所有 GDD 进行交叉一致性检查。

### Phase 2 流水线

```
/map-systems next  -->  /design-system  -->  /design-review
       |                     |                     |
       v                     v                     v
  Picks next system    Section-by-section     Validates 8
  from systems-index   GDD authoring          required sections
                       (incremental writes)   APPROVED/NEEDS REVISION
       |
       |  (repeat for each MVP system)
       v
/review-all-gdds
       |
       v
  Cross-GDD consistency + design theory review
  PASS / CONCERNS / NOT ASSESSED / FAIL
```

### Step 2.1：编写系统 GDD

按依赖顺序，使用引导式工作流设计每个系统：

```
/map-systems next
```

它会挑选优先级最高且尚未设计的系统，并交接给
`/design-system`，由后者引导你逐节创建其 GDD。

你也可以直接设计某个特定系统：

```
/design-system combat-system
```

**/design-system 会做什么：**

1. 读取你的游戏概念、系统索引，以及任何上游/下游 GDD
2. 运行技术可行性预检（领域映射 + 可行性简报）
3. 逐一引导你完成 8 个必需 GDD 章节
4. 每个章节遵循：Context > Questions > Options > Decision > Draft > Approval > Write
5. 每个章节获批后立即写入文件（可抵御崩溃）
6. 标记与现有已批准 GDD 的冲突
7. 按类别路由到专家 agent（数学交给 systems-designer，
   经济交给 economy-designer，故事系统交给 narrative-director）

**8 个必需 GDD 章节：**

| # | 章节 | 这里写什么 |
|---|---------|---------------|
| 1 | **Overview** | 对该系统的一段式概述 |
| 2 | **Player Fantasy** | 玩家使用该系统时想象/感受到什么 |
| 3 | **Detailed Rules** | 无歧义的机制规则 |
| 4 | **Formulas** | 每项计算，含变量定义与取值范围 |
| 5 | **Edge Cases** | 怪异情况下会发生什么？明确给出结论。 |
| 6 | **Dependencies** | 它与哪些其他系统相连（双向） |
| 7 | **Tuning Knobs** | 设计师可安全更改哪些数值，及其安全范围 |
| 8 | **Acceptance Criteria** | 如何测试它有效？具体、可度量。 |

另加一个 **Game Feel** 章节：手感参考、输入响应（毫秒/帧）、
动画手感目标（起手/持续/收招）、打击瞬间、重量感轮廓。

### Step 2.2：评审每份 GDD

在开始下一个系统之前，验证当前系统：

```
/design-review design/gdd/combat-system.md
```

检查你的 `modes.workflow` 档位所要求的章节（`full` 下全部 8 节，`standard`
下 5 节）是否完整、公式是否清晰、边界情况是否解决、
依赖是否双向、验收标准是否可测试。

**结论：** APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED / NOT ASSESSED。
只有 APPROVED 的 GDD 才应继续推进。

### Step 2.3：无需完整 GDD 的小改动

对于调优改动、小增补或微调，不值得写完整 GDD：

```
/quick-design "add 10% damage bonus for flanking attacks"
```

这会在 `design/quick-specs/` 中创建一份轻量规格，而不是完整的
8 节 GDD。用于调优、数值改动和小增补。

### Step 2.4：GDD 交叉一致性评审

在所有 MVP 系统 GDD 各自获批后：

```
/review-all-gdds
```

它会同时读取所有 GDD，并运行两个分析阶段：

**Phase 1 -- GDD 间一致性：**
- 依赖双向性（A 引用 B，B 是否引用 A？）
- 系统之间的规则矛盾
- 对已重命名或已移除系统的过时引用
- 归属冲突（两个系统声称同一职责）
- 公式取值范围兼容性（系统 A 的输出是否适配系统 B 的输入？）
- 验收标准交叉核对

**Phase 2 -- 设计理论（游戏设计整体性）：**
- 相互竞争的成长循环（两个系统是否争夺同一奖励空间？）
- 认知负荷（同时存在超过 4 个活跃系统？）
- 支配性策略（某种做法让其他所有做法都失去意义）
- 经济循环分析（来源与消耗是否平衡？）
- 跨系统的难度曲线一致性
- 游戏支柱契合度与反支柱违规
- 玩家幻想连贯性

**输出：** `design/gdd/gdd-cross-review-[date].md`，含结论。

### Step 2.5：叙事设计（如适用）

如果你的游戏包含故事、世界观或对话，此时就要构建它：

1. **世界构建** -- 使用 `world-builder` 定义阵营、历史、
   地理和你世界的规则
2. **故事结构** -- 使用 `narrative-director` 设计故事弧线、
   角色弧线和叙事节拍
3. **角色卡** -- 使用 `narrative-character-sheet.md` 模板

### Phase 2 闸门

```
/gate-check technical-setup
```

**通过要求：**

- `design/gdd/systems-index.md` 至少列出 MVP 系统，并映射其
  依赖
- 每个 MVP 系统都有一份 GDD，且都通过 `/design-review`（没有
  MAJOR REVISION NEEDED）
- 一份来自 `/review-all-gdds` 的 GDD 交叉评审报告，结论不是 FAIL，
  也不是 NOT ASSESSED（后者意味着 GDD 无法比较）

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-technical-setup.md` 包含完整
检查清单以及每个档位删减的内容。

---

<a id="phase-3-technical-setup"></a>
## Phase 3: 技术搭建

### 本阶段会发生什么

你做出关键技术决策，将其记录为架构决策记录（ADR），通过评审加以验证，
并产出一份控制清单，为程序员提供平实、可执行的规则。你还会建立 UX 基础。

### Phase 3 流水线

```
/create-architecture  -->  /architecture-decision (x N)  -->  /architecture-review
        |                          |                                   |
        v                          v                                   v
  Master architecture       Per-decision ADRs              Validates completeness,
  document covering         in docs/architecture/          dependency ordering,
  all systems               adr-*.md                       engine compatibility
                                                                      |
                                                                      v
                                                         /create-control-manifest
                                                                      |
                                                                      v
                                                         Flat programmer rules
                                                         docs/architecture/
                                                         control-manifest.md
        Also in this phase:
        -------------------
        /ux-design  -->  /ux-review
        Accessibility requirements doc  (/ux-design accessibility)
        Interaction pattern library     (/ux-design patterns)
        /test-setup  -->  test framework + CI workflow
```

### Step 3.1：主架构文档

```
/create-architecture
```

在 `docs/architecture/architecture.md` 中创建总体架构文档，
覆盖系统边界、数据流和集成点。

### Step 3.2：架构决策记录（ADR）

针对每一项重要的技术决策：

```
/architecture-decision "State Machine vs Behavior Tree for NPC AI"
```

**会发生什么：** 该技能引导你创建一份 ADR，包含：
- 上下文与决策驱动因素
- 所有选项及其优缺点和引擎兼容性
- 所选选项及其理由
- 后果（正面、负面、风险）
- 依赖（Depends On、Enables、Blocks、Ordering Note）
- 所满足的 GDD 需求（通过 TR-ID 链接）

ADR 会经历一个生命周期：Proposed > Accepted > Superseded/Deprecated。

闸门检查之前**至少需要 3 份 Foundation 层 ADR**。

**改造现有 ADR：** 如果你已有来自存量项目的 ADR：

```
/architecture-decision retrofit docs/architecture/adr-005.md
```

它会检测缺失哪些模板章节，并只补充这些章节，绝不覆盖已有内容。

### Step 3.3：架构评审

```
/architecture-review
```

一并验证所有 ADR：
- ADR 依赖的拓扑排序（检测循环）
- 引擎兼容性验证
- GDD 修订标记（根据 ADR 选择，标出需要更新的 GDD 章节）
- TR-ID 注册表维护（`docs/architecture/tr-registry.yaml`）

### Step 3.4：控制清单

```
/create-control-manifest
```

汇总所有 Accepted 状态的 ADR，产出一份平实的程序员规则表：

```
docs/architecture/control-manifest.md
```

其中包含按代码层组织的必需模式（Required patterns）、禁止模式（Forbidden patterns）
和护栏（Guardrails）。之后创建的用户故事会嵌入清单版本日期，以便发现过期。

### Step 3.5：无障碍需求

使用模板创建 `design/accessibility-requirements.md`。确定一个
档位（Basic / Standard / Comprehensive / Exemplary），并填写 4 轴功能
矩阵（视觉、运动、认知、听觉）。

这份文档在 Phase 3 中是必需的，因为 UX 规格（在 Phase 4 编写）
会引用该档位 —— 它是设计前提，而不是 UX 交付物。
`/ux-design accessibility` 负责编写它；`/ux-design patterns` 启动
交互模式库（`design/ux/interaction-patterns.md`），同一闸门也会检查它。

### Step 3.6：测试框架

```
/test-setup
```

搭建引擎的测试根目录、`.github/workflows/tests.yml` 和一个示例
测试；预制作闸门会检查它们。一旦有系统可测，就可以接着使用 `/test-helpers`。

### Phase 3 闸门

```
/gate-check pre-production
```

**通过要求：**

- 引擎已配置，`project.yaml` 已填充（引擎、命名、性能），
  且引擎参考文档已就位
- 美术圣经第 1–4 节（`design/art/art-bible.md`）
- `docs/architecture/architecture.md`、至少 3 份覆盖 Foundation 层
  系统的 ADR、一份 `/architecture-review` 报告，以及
  `docs/architecture/requirements-traceability.md`
- 引擎测试根目录中的测试框架、`.github/workflows/tests.yml`
  和一个示例测试（`/test-setup`）
- `design/accessibility-requirements.md` 和 `design/ux/interaction-patterns.md`
  （`/ux-design accessibility`、`/ux-design patterns`）

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-pre-production.md` 包含完整
检查清单以及每个档位删减的内容。

---

<a id="phase-4-pre-production"></a>
## Phase 4: 预制作

### 本阶段会发生什么

你为关键界面创建 UX 规格，为高风险机制制作原型，将设计文档转化为
可实现的用户故事，规划第一个冲刺，并构建一个能证明核心循环有趣的
垂直切片（Vertical Slice）。

### Phase 4 流水线

```
/ux-design  -->  /vertical-slice  -->  /create-epics  -->  /create-stories  -->  /sprint-plan
    |                   |                   |                   |                       |
    v                   v                   v                   v                       v
  UX specs       Production-quality   Epic files in       Story files in          First sprint with
  design/ux/     end-to-end build     production/         production/             prioritized stories
                 in prototypes/       epics/*/EPIC.md     epics/*/story-*.md      production/sprints/
                 PROCEED/PIVOT/KILL   (one per module)    (one per behaviour)     sprint-*.md
    |                                                          |
    v                                                          v
 /ux-review                                             /story-readiness
 (validates specs                                       (validates each story
  before epics)                                          before pickup)
                                                               |
                                                               v
                                                           /dev-story
                                                         (implements the story,
                                                          routes to right agent)
```

### Step 4.1：关键界面的 UX 规格

在编写史诗（epic）之前，先创建 UX 规格，让用户故事作者知道有哪些界面，
以及它们必须支持哪些玩家交互。

**UX 规格：**

```
/ux-design main-menu
/ux-design core-gameplay-hud
```

三种模式：界面/流程、HUD 和交互模式。输出写入
`design/ux/`。每份规格包含：玩家需求、布局区域、状态、
交互映射、数据需求、触发事件、无障碍、本地化。

它会读取你的 `accessibility-requirements.md`（在 Phase 3 编写）和
`project.yaml` 中的输入方式配置（`platform.*` 块，回退到
`technical-preferences.md`），以驱动无障碍与输入覆盖检查 ——
无需按界面重复指定。

> **提示：** `/design-system` 会为每个有 UI 需求的系统发出 📌 UX 标记。
> 用这些标记作为清单，确认哪些界面需要规格。

**交互模式库：**

```
/ux-design patterns
```

在 Phase 3 启动（预制作闸门会检查它）；随着关键界面增添模式，
在此处扩展它。`design/ux/interaction-patterns.md` 收录 16 种标准
控件以及游戏专属模式（背包格、技能图标、HUD 条、
对话框等），并附带动画与音效标准。

**UX 评审：**

```
/ux-review all
```

验证 UX 规格是否符合 GDD 和无障碍档位要求。
产出 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 结论。

### Step 4.2：构建垂直切片

垂直切片是制作级的证明：在正式投入完整制作之前，
你能够端到端地构建出完整的游戏循环。

```
/vertical-slice
```

**它证明什么：** 一名玩家能否在没有任何开发者引导的情况下，从零开始，
在几分钟内体验到核心幻想？

**它构建什么：** 一个接近制作质量的可玩构建，覆盖至少
一个完整的 [开始 → 挑战 → 解决] 循环。使用真实架构
分层、真实命名约定、没有硬编码值 —— 但不使用最终美术或
音频。它不是概念原型那样的丢弃品；它展示制作
流水线的可行性。

**关于概念原型的说明：** 如果你在 Phase 1（Concept）运行了 `/prototype`，
你已经验证了核心想法有趣。垂直切片现在验证
你能正确地把它做出来。它们回答的是不同问题。如果你跳过了
概念原型，那么在投入完整切片之前先跑一个原型是合理的时机。

**结论：** 垂直切片会产出 PROCEED / PIVOT / KILL 结论，或
在无人完整玩通时给出 NOT ASSESSED。
- **PROCEED** → 进入 Step 4.3（史诗与用户故事）
- **PIVOT** → 用 `/design-system [mechanic]` 修订受影响的 GDD，然后重新运行 `/vertical-slice`
- **KILL** → 带着所学回到 `/brainstorm`

### Step 4.3：从设计产出物创建史诗与用户故事

```
/create-epics layer: foundation
/create-stories [epic-slug]   # repeat for each epic
/create-epics layer: core
/create-stories [epic-slug]   # repeat for each core epic
```

`/create-epics` 读取你的 GDD、ADR 和架构来定义史诗范围 ——
每个架构模块一个史诗。然后 `/create-stories` 将每个史诗拆分为
可实现的用户故事文件，放在 `production/epics/[slug]/` 下。每个用户故事嵌入：
- GDD 需求引用（TR-ID，而非引用原文 -- 保持最新）
- ADR 引用（仅来自 Accepted ADR；Proposed ADR 会导致 `Status: Blocked`）
- 控制清单版本日期（用于发现过期）
- 引擎专属实现说明
- 来自 GDD 的验收标准

用户故事存在后，运行 `/dev-story [story-path]` 实现其中一个 ——
它会自动路由到正确的程序员 agent。

### Step 4.4：领取前验证用户故事

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

检查：设计完整性、架构覆盖、范围清晰度、完成定义（Definition
of Done）。结论：READY / NEEDS WORK / BLOCKED / NOT ASSESSED。

### Step 4.5：工作量估算

```
/estimate production/epics/combat/story-combat-damage-calc.md
```

提供工作量估算与风险评估。

### Step 4.6：规划第一个冲刺

```
/sprint-plan new
```

**会发生什么：** `producer` agent 协作进行冲刺规划：
- 询问冲刺目标与可用时间
- 将目标拆分为 Must Have / Should Have / Nice to Have 任务
- 识别风险与阻塞项
- 创建 `production/sprints/sprint-001.md`
- 填充 `production/sprint-status.yaml`（机器可读的用户故事跟踪）

### Step 4.7：垂直切片（推荐）

在进入制作阶段之前，构建并试玩一个垂直切片：

- 一个完整的端到端核心循环，可从开始玩到结束
- 具有代表性的品质（不要把一切都做成占位内容）
- 在至少 1 次有记录的会话中进行无引导试玩（推荐 3 次以上）
- 撰写试玩报告（`/playtest-report`）

`/gate-check production` 将其视为推荐而非阻塞项：跳过切片为
CONCERNS，无人玩过的切片为 NOT ASSESSED，而构建完成但
损坏或不好玩则为 FAIL。在 `workflow: minimal` 下，切片相关条目
被删减：闸门改为询问当前构建的核心循环是否有趣，
是否能端到端运行。

### Phase 4 闸门

```
/gate-check production
```

**通过要求：**

- `production/sprints/` 中有一份首个冲刺计划，且 Foundation 与 Core 史诗
  及其用户故事位于 `production/epics/` 下
- 完整的美术圣经（全部 9 节）及其 AD-ART-BIBLE 签核
  已记录
- 每份 MVP GDD 完整、主架构文档就绪、Foundation 与 Core
  ADR 为 `Accepted`，且控制清单就绪
- 关键界面（主菜单、HUD、暂停菜单）的 UX 规格通过
  `/ux-review`
- 推荐而非阻塞：垂直切片已构建，并在至少一次有记录的
  会话中试玩。跳过 → CONCERNS；构建了但损坏或不好玩 → FAIL；
  构建了但尚未试玩 → NOT ASSESSED

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-production.md` 包含完整
检查清单以及每个档位删减的内容。

---

<a id="phase-5-production"></a>
## Phase 5: 制作

### 本阶段会发生什么

这是核心制作循环。你以冲刺为单位（通常 1-2 周）工作，逐个用户故事实现
功能，跟踪进度，并通过结构化的完成评审关闭用户故事。该阶段会反复进行，
直到游戏内容完整。

### Phase 5 流水线（每个冲刺）

```
/sprint-plan new  -->  /story-readiness  -->  implement  -->  /story-done
       |                     |                    |                |
       v                     v                    v                v
  Sprint created       Story validated      Code written     8-phase review:
  sprint-status.yaml   READY verdict        Tests pass       verify criteria,
  populated                                                  check deviations,
                                                             update story status
       |
       |  (repeat per story until sprint complete)
       v
  /sprint-status  (quick 30-line snapshot anytime)
  /scope-check    (if scope is growing)
  /retrospective  (at sprint end)
```

### Step 5.1：用户故事生命周期

制作阶段围绕**用户故事生命周期**展开：

```
/story-readiness  -->  implement  -->  /story-done  -->  next story
```

**1. 用户故事就绪检查：** 领取用户故事之前，先验证它：

```
/story-readiness production/epics/combat/story-combat-damage-calc.md
```

它会检查设计完整性、架构覆盖、ADR 状态（若 ADR 仍为 Proposed 则阻塞）、
控制清单版本（若过期则警告）和范围清晰度。结论：READY / NEEDS WORK /
BLOCKED / NOT ASSESSED。

**2. 实现：** 与合适的 agent 协作：

- `gameplay-programmer` 负责玩法系统
- `engine-programmer` 负责核心引擎工作
- `ai-programmer` 负责 AI 行为
- `network-programmer` 负责多人
- `ui-programmer` 负责 UI 代码
- `tools-programmer` 负责开发工具

所有 agent 都遵循协作协议：读取设计文档、提出澄清问题、给出架构选项、
获得你的批准，然后才实现。

**3. 用户故事完成：** 当用户故事完成后：

```
/story-done production/epics/combat/story-combat-damage-calc.md
```

它会运行 8 阶段完成评审：
1. 找到并读取用户故事文件
2. 加载引用的 GDD、ADR 和控制清单
3. 验证验收标准（可自动检查、手动、延期）
4. 检查 GDD/ADR 偏离（BLOCKING / ADVISORY / OUT OF SCOPE）
5. 提示进行代码评审
6. 生成完成报告（COMPLETE / COMPLETE WITH NOTES / BLOCKED）
7. 将用户故事 `Status: Complete` 更新，并附完成说明
8. 呈现下一个就绪的用户故事

评审过程中发现的技术债会记录到 `docs/tech-debt-register.md`。

### Step 5.2：冲刺跟踪

随时检查进度：

```
/sprint-status
```

从 `production/sprint-status.yaml` 读取，生成 30 行的快速快照。

如果范围在增长：

```
/scope-check production/sprints/sprint-003.md
```

它将当前范围与原始计划对比，标记范围增长，
并建议削减。

### Step 5.3：内容跟踪

```
/content-audit
```

将 GDD 规定的内容与已实现内容进行对比。尽早发现
内容缺口。

### Step 5.4：设计变更传播

当用户故事创建之后 GDD 发生变更：

```
/propagate-design-change design/gdd/combat-system.md
```

对 GDD 做 git diff，找出受影响的 ADR，生成影响报告，并
引导你完成 Superseded/更新/保留的决策。

### Step 5.5：多系统功能（团队编排）

对于跨多个领域的功能，使用团队技能：

```
/team-combat "healing ability with HoT and cleanse"
/team-narrative "Act 2 story content"
/team-ui "inventory screen redesign"
/team-level "forest dungeon level"
/team-audio "combat audio pass"
```

每个团队技能协调一个 6 阶段协作工作流：
1. **设计** -- game-designer 提问并给出选项
2. **架构** -- lead-programmer 提出代码结构
3. **并行实现** -- 专家同时工作
4. **集成** -- gameplay-programmer 将一切串联起来
5. **验证** -- qa-tester 对照验收标准运行测试
6. **报告** -- 协调者总结状态

编排是自动化的，但**决策点始终由你掌握**。

### Step 5.6：冲刺评审与下一个冲刺

冲刺结束时：

```
/retrospective
```

分析计划与实际、速率（velocity）、阻塞项和可执行的改进。

然后规划下一个冲刺：

```
/sprint-plan new
```

### Step 5.7：里程碑评审

在里程碑检查点：

```
/milestone-review "alpha"
```

产出功能完整度、质量指标、风险评估和 go/no-go
建议。

### Phase 5 闸门

```
/gate-check polish
```

**通过要求：**

- 每个核心 GDD 机制都已实现，且主要玩法路径可端到端
  游玩
- 引擎测试根目录中的测试覆盖 Logic 和 Integration 用户故事，
  并且全部通过
- `production/qa/` 中有一份结论为 PASS 或 PASS WITH WARNINGS 的冒烟检查报告
- 一次 `/team-qa` 签核（APPROVED 或 APPROVED WITH CONDITIONS）
- 至少 3 次有记录的试玩会话（新玩家、中期游戏、难度
  曲线），且趣味性假设得到验证或修订
- 没有未解决的 S1 Critical 缺陷，性能在预算之内

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-polish.md` 包含完整
检查清单以及每个档位删减的内容。

---

<a id="phase-6-polish"></a>
## Phase 6: 打磨

### 本阶段会发生什么

你的游戏功能已经完整。现在要把它做好。本阶段聚焦于
性能、平衡性、无障碍、音频、视觉打磨和试玩测试。

### Phase 6 流水线

```
/perf-profile  -->  /balance-check  -->  /asset-audit  -->  /playtest-report (x3)
       |                  |                    |                    |
       v                  v                    v                    v
  Profile CPU/GPU    Analyze formulas     Verify naming,      Cover: new player,
  memory, optimize   and data for         formats, sizes      mid-game, difficulty
  bottlenecks        broken progressions                      curve

  /tech-debt  -->  /team-polish
       |                |
       v                v
  Track and        Coordinated pass:
  prioritize       performance + art +
  debt items       audio + UX + QA

  /security-audit  -->  /localize qa  -->  /release-checklist  -->  /changelog
                        (per language)                           + /patch-notes
  Release readiness: the Polish -> Release gate checks all four.
```

### Step 6.1：性能剖析

```
/perf-profile
```

引导你进行结构化的性能剖析：
- 确定目标（FPS、内存、平台）
- 按影响程度排列瓶颈
- 生成可执行的优化任务，附带代码位置和预期收益

### Step 6.2：平衡性分析

```
/balance-check assets/data/combat_damage.json
```

分析平衡性数据中的统计离群值、断裂的成长曲线、
退化策略和经济失衡。

### Step 6.3：资源审计

```
/asset-audit
```

验证所有资源的命名约定、文件格式标准和体积
预算。

### Step 6.4：试玩测试（必需：3 次会话）

```
/playtest-report
```

生成结构化的试玩报告。需要三次会话，覆盖：
- 新玩家体验
- 中期游戏系统
- 难度曲线

### Step 6.5：技术债评估

```
/tech-debt
```

扫描 TODO/FIXME/HACK 注释、代码重复、过于复杂的函数、
缺失的测试和过时的依赖。每项都会被分类并排定优先级。

### Step 6.6：协同打磨轮次

```
/team-polish "combat system"
```

并行协调 4 位专家：
1. 性能优化（performance-analyst 列出优化项；由当前活跃的
   programmer 实现 —— 在 `team.size: individual` 下无人活跃时，
   该清单交给 `/dev-story`）
2. 视觉打磨（technical-artist）
3. 音频打磨（sound-designer）
4. 手感/爽感（gameplay-programmer + technical-artist）

你设定优先级；团队在每一步都经你批准后执行。

### Step 6.7：本地化与无障碍

```
/localize scan
```

扫描硬编码字符串、会破坏翻译的字符串拼接、未考虑文本
膨胀的文本，以及缺失的语言文件。

无障碍会对照 Phase 3 无障碍需求文档中承诺的档位进行
审计。

### Step 6.8：安全审计

```
/security-audit
```

在 `standard` 和 `full` 下是发布闸门的必需项：最新报告必须
没有未解决的 CRITICAL 或 HIGH 发现。若报告的建议为 NOT
ASSESSED，则闸门的安全条目也为 NOT ASSESSED。

### Step 6.9：本地化 QA

```
/localize qa
```

为你发布的每一种语言运行。在 `full` 下，发布闸门要求每种语言
都通过（或 PASS WITH CONDITIONS）；无人检查过的语言为 NOT ASSESSED。

### Step 6.10：发布检查清单

```
/release-checklist all
```

参数是平台范围（`pc`、`console`、`mobile` 或 `all`），而不是
版本号。

生成全面的发布前检查清单，覆盖：
- 构建验证（所有平台都能编译并运行）
- 认证要求（平台专属）
- 商店元数据（描述、截图、预告片）
- 法律合规（EULA、隐私政策、分级）
- 存档兼容性
- 分析（Analytics）验证

### Step 6.11：变更日志与补丁说明

```
/patch-notes v1.0.0
```

根据 git 历史和冲刺数据生成对玩家友好的补丁说明。
将开发者语言转换为玩家语言。

```
/changelog v1.0.0
```

生成内部变更日志（更技术化，面向团队）。

发布闸门要求变更日志或补丁说明已有草稿，所以现在就写；
一旦发布状态为 GO，`/team-release` 会发布它们。

### Phase 6 闸门

```
/gate-check release
```

**通过要求：**

- 每个里程碑功能都已实现，内容完整
- 一份 QA 测试计划和一次 QA 签核，以及每个 Must Have 用户故事的测试
  证据（UI：保留截图；视觉/手感：截图外加主管签核）
- 发布候选版本通过冒烟检查，且测试套件通过
- 已运行 `/balance-check`，发布检查清单已完成，且变更日志或
  补丁说明已有草稿
- 没有未解决的 S1–S3 缺陷，最新的 `/security-audit` 没有未解决的 CRITICAL 或
  HIGH 发现，且你发布的每种语言都通过 `/localize qa`

这是 `full` 的清单。`standard` 和 `minimal` 会删减条目；闸门自身的
文件 `.trae/skills/gate-check/references/gate-release.md` 包含完整
检查清单以及每个档位删减的内容。

---

<a id="phase-7-release"></a>
## Phase 7: 发布

### 本阶段会发生什么

你的游戏已经打磨完毕、测试完成、准备就绪。现在把它发布出去。

### Phase 7 流水线

```
/launch-checklist  -->  /team-release
        |                      |
        v                      v
  Full cross-department    Coordinate:
  validation (Go/No-Go     build, QA sign-off,
  per department)          deployment, launch

  The release checklist, security audit and patch notes are done in Polish,
  before /gate-check release.   Also: /hotfix, /day-one-patch
```

### Step 7.1：上线就绪检查（完整验证）

```
/launch-checklist
```

完整的跨部门验证：

| 部门 | 检查内容 |
|-----------|---------------|
| **Engineering** | 构建稳定性、崩溃率、内存泄漏、加载时间 |
| **Design** | 功能完整度、教程流程、难度曲线 |
| **Art** | 资源质量、缺失贴图、LOD 层级 |
| **Audio** | 缺失音效、混音电平、空间音频 |
| **QA** | 按严重程度统计的未解决缺陷数、回归套件通过率 |
| **Narrative** | 对话完整度、世界观一致性、拼写错误 |
| **Localization** | 所有字符串已翻译、无截断、语言环境测试 |
| **Accessibility** | 合规检查清单、辅助功能测试 |
| **Store** | 元数据完整、截图已批准、定价已设置 |
| **Marketing** | 媒体资料包就绪、上线预告片、社交媒体已排期 |
| **Community** | 补丁说明草稿、FAQ 已准备、支持渠道就绪 |
| **Infrastructure** | 服务器已扩容、CDN 已配置、监控已启用 |
| **Legal** | EULA 已定稿、隐私政策、COPPA/GDPR 合规 |

任何文件都无法确定的事项 —— EULA、定价、值班表 —— 会按章节各问一次：
是、否、尚未或 N/A。回答「否」或「尚未」即为未通过项。
总体状态为 READY、CONDITIONAL（仅剩有临时方案或已被接受风险的条目）、
NOT ASSESSED（仍有事项未确认）或 NOT
READY（某个阻塞项未通过）。

### Step 7.2：协调发布

```
/team-release
```

协调 release-manager、QA 和 DevOps，完成：
1. 发布前验证
2. 构建管理
3. 最终 QA 签核
4. 部署准备
5. Go/No-Go 决策

### Step 7.3：发布

当你推送到 `main` 或 `release/*` 分支时，`validate-push` 钩子会发出警告。
这是有意为之 —— 发布推送应当深思熟虑：

```bash
git tag v1.0.0
git push origin main --tags
```

### Step 7.4：发布之后

针对生产环境严重缺陷的**热修复工作流**：

```
/hotfix "Players losing save data when inventory exceeds 99 items"
```

绕过正常的冲刺流程，但保留完整的审计轨迹：
1. 创建热修复分支
2. 实现修复
3. 确保修复被回填到 `main`（主干）
4. 记录事故

上线稳定后的**复盘（post-mortem）**：

```
Ask the agent to create a post-mortem using the template at
.trae/docs/templates/post-mortem.md
```

---

<a id="cross-cutting-concerns"></a>
## 横切关注点

这些主题贯穿所有阶段。

### 总监评审模式

总监闸门（Director gates）是专家 agent，会在关键工作流步骤评审你的工作。
**默认情况下不会运行任何总监闸门。** `modes.review_mode` 跟随 `modes.rigor`，
而默认严格度 `rigor: minimal` 对应 `solo`。

| 模式 | 运行内容 | 默认对应 | 最适合 |
|------|-----------|-------------------|----------|
| `full` | 每一步都运行全部总监闸门 | `rigor: full` | 工作室级项目、学习本系统 |
| `lean` | 仅在阶段转换（`/gate-check`）时运行总监 | `rigor: standard` | 有经验的开发者 |
| `solo` | 不进行总监评审 | `rigor: minimal` | 单人项目、Game Jam、原型 |

**更改方式：** 用 `/settings modes.review_mode=lean`（写入 `project.yaml`；
显式值优先于严格度），或用 `/settings --local modes.review_mode=full`
仅对你的机器生效。`/start` 不会设置它。

**单次运行临时覆盖**（不更改你的设置）：

```
/brainstorm space horror --review full
/architecture-decision --review solo
```

`--review` 标志适用于所有使用闸门的技能。以下设置中第一个有值的生效：
该标志、`project.local.yaml`、`project.yaml`、旧版的
`production/review-mode.txt`，然后是严格度默认值。旧版本遗留的
`review-mode.txt` 仍会覆盖严格度 —— 如果模式出乎意料，请删除它。

完整的闸门定义和检查模式：`.trae/docs/director-gates.md`

---

### 协作协议

这个系统是**用户驱动的协作式**，而非自主式。

**模式：** Question > Options > Decision > Draft > Approval

每一次 agent 交互都遵循这个模式：
1. Agent 提出澄清问题
2. Agent 给出 2-4 个选项，附取舍与理由
3. 你做决定
4. Agent 根据你的决定起草
5. 你评审并完善
6. Agent 在写入前询问「May I write this to [filepath]?」

完整协议及示例见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

### AskUserQuestion 工具

Agent 使用 `AskUserQuestion` 工具进行结构化的选项呈现。
模式是先解释后采集（Explain then Capture）：先在对话文本中给出完整分析，
然后用干净的 UI 选择器做决定。用于设计选择、
架构决策和策略性问题。不要用于开放式
探索问题或简单的是/否确认。

### Agent 协调（3 层层级）

```
Tier 1 (Directors):    creative-director, technical-director, producer
                                          |
Tier 2 (Leads):        game-designer, lead-programmer, art-director,
                       audio-director, narrative-director, qa-lead,
                       release-manager, localization-lead
                                          |
Tier 3 (Specialists):  gameplay-programmer, engine-programmer,
                       ai-programmer, network-programmer, ui-programmer,
                       tools-programmer, systems-designer, level-designer,
                       economy-designer, world-builder, writer,
                       technical-artist, sound-designer, ux-designer,
                       qa-tester, performance-analyst, devops-engineer,
                       analytics-engineer, accessibility-specialist,
                       live-ops-designer, prototyper, security-engineer,
                       community-manager, godot-specialist,
                       godot-gdscript-specialist, godot-shader-specialist,
                       godot-csharp-specialist, godot-gdextension-specialist,
                       unity-specialist, unity-dots-specialist,
                       unity-shader-specialist, unity-addressables-specialist,
                       unity-ui-specialist, unreal-specialist,
                       ue-blueprint-specialist, ue-gas-specialist,
                       ue-replication-specialist, ue-umg-specialist
```

**协调规则：**
- 垂直委派：总监 > 主管 > 专家。复杂决策绝不
  跳层。
- 水平咨询：同一层的 agent 可以相互咨询，但
  不得在其领域之外做出有约束力的决定。
- 冲突解决：设计冲突交给 `creative-director`。技术
  冲突交给 `technical-director`。范围冲突交给 `producer`。
- 不得单方面进行跨领域变更。

### 自动化钩子（安全网）

系统有 15 个自动运行的钩子：

| 钩子 | 触发时机 | 作用 |
|------|---------|-------------|
| `session-start.sh` | 会话开始 | 显示分支、最近提交，检测 active.md 以便恢复 |
| `detect-gaps.sh` | 会话开始 | 检测全新项目（无引擎、无概念）并建议运行 `/start` |
| `pre-compact.sh` | 压缩（compaction）之前 | 记录压缩事件（其输出不会到达 Claude） |
| `notify.sh` | 权限提示，或空闲约一分钟 | 通过 PowerShell 显示 Windows 通知弹窗 |
| `validate-commit.sh` | 提交之前 | 检查设计文档章节、有效 JSON、硬编码值、TODO 格式 |
| `validate-push.sh` | 推送、打标签、合并或部署之前 | 对推送到 main、master 或 release/*，以及 `git tag`、`git merge`、`gh release`、`butler push` 和 `steamcmd +run_app_build` 发出警告 |
| `validate-read.sh` | 读取文件之前 | 拒绝整文件读取超过 40 KB 的设计文档，并改用其标题作答 |
| `validate-write.sh` | 写入文件之前 | 当写入会违反技能所述的规则时发出警告（绝不阻塞） |
| `validate-registry.sh` | 写入实体或 TR-ID 注册表之前 | 当条目将被删除或重新编号，或状态不在表头列表中时发出警告 |
| `validate-assets.sh` | 写入文件之后 | 检查数据文件 JSON，以及 Godot `assets/` 中的资源命名 |
| `validate-skill-change.sh` | 技能文件被写入 | 建议在 `.trae/skills/` 变更后运行 `/skill-test` |
| `log-agent.sh` | Agent 启动 | 记录 agent 调用，形成审计轨迹 |
| `log-agent-stop.sh` | Agent 停止 | 补全 agent 审计轨迹（启动 + 停止） |
| `validate-agent-artifact.sh` | Agent 停止 | 当子 agent 停止却未写入其简报指定的文件时发出警告 |
| `session-stop.sh` | **每次响应结束时** | 在后台记录会话日志并统计子 agent 派生数量。尽管名字如此，它每次响应触发一次，而不是每次会话一次。 |

### 上下文韧性

**会话状态文件：** `production/session-state/active.md` 是一份持续的
检查点。在每个重要里程碑之后更新它。任何中断
（压缩、崩溃、`/clear`）之后，先读这个文件。

**增量写入：** 创建多章节文档时，在每个章节获批后
立即写入文件。这样已完成的章节可以在崩溃和上下文压缩后
存活。关于已写入章节的先前讨论可以安全地压缩掉。

**自动恢复：** `session-start.sh` 钩子会自动检测并预览
`active.md`，并在每次压缩后再次运行，因此当对话被摘要时，
检查点会重新出现。

**冲刺状态跟踪：** `production/sprint-status.yaml` 是
机器可读的用户故事跟踪器。由 `/sprint-plan`（初始化）和
`/story-done`（状态更新）写入。由 `/sprint-status`、`/help` 和
`/story-done`（下一个用户故事）读取。消除了脆弱的 markdown 扫描。

### 存量项目采纳

对于已有部分产出物的现有项目：

```
/adopt
```

或定向采纳：

```
/adopt gdds
/adopt adrs
/adopt stories
/adopt infra
```

它会审计现有产出物的**格式**（而非是否存在），将缺口分类
为 BLOCKING/HIGH/MEDIUM/LOW，构建有序的迁移计划，并写入
`docs/adoption-plan-[date].md`。核心原则：迁移而非替换（MIGRATION not REPLACEMENT）--
它绝不重新生成已有工作，只填补缺口。

各技能也支持改造模式：

```
/design-system retrofit design/gdd/combat-system.md
/architecture-decision retrofit docs/architecture/adr-005.md
```

它们检测哪些章节已存在、哪些缺失，并只填补缺口。

### 闸门系统

阶段闸门是正式的检查点。运行 `/gate-check` 时传入你即将进入的阶段：

```
/gate-check systems-design       # Concept -> Systems Design
/gate-check technical-setup      # Systems Design -> Technical Setup
/gate-check pre-production       # Technical Setup -> Pre-Production
/gate-check production           # Pre-Production -> Production
/gate-check polish               # Production -> Polish
/gate-check release              # Polish -> Release
```

**结论：**
- **PASS** -- 所有要求均已满足，进入下一阶段
- **CONCERNS** -- 发现风险；只有你明确接受风险（且接受的风险被记录）
  阶段才会推进
- **NOT ASSESSED** -- 某项必需内容无法检查；报告会指出
  它，补充后重新运行
- **FAIL** -- 要求未满足，以具体的整改事项阻止推进

当闸门通过 —— 或你接受 CONCERNS 结论的风险 —— `project.yaml` 中的
`project.stage` 会被更新（仅此时；FAIL 永不推进） —— 并同步到
`production/stage.txt`。在 `standard` 和 `full` 下，阶段驱动
状态行和 `/help`；在 `minimal` 下，它们改为跟随简报和用户故事。

### 逆向文档

对于存在代码但没有设计文档的情况（存量项目采纳之后很常见）：

```
/reverse-document design src/gameplay/combat/
```

读取现有代码，并据此生成 GDD 格式的设计文档。

---

<a id="appendix-a-agent-quick-reference"></a>
## Appendix A: Agent 快速参考

### 「我需要做 X -- 该用哪个 agent？」

| 我需要…… | Agent | 层级 |
|-------------|-------|------|
| 想出一个游戏点子 | `/brainstorm` 技能 | -- |
| 设计一个游戏机制 | `game-designer` | 2 |
| 设计具体公式/数值 | `systems-designer` | 3 |
| 设计一个游戏关卡 | `level-designer` | 3 |
| 设计战利品表 / 经济 | `economy-designer` | 3 |
| 构建世界世界观 | `world-builder` | 3 |
| 撰写对话 | `writer` | 3 |
| 规划故事 | `narrative-director` | 2 |
| 规划一个冲刺 | `producer` | 1 |
| 做创意决策 | `creative-director` | 1 |
| 做技术决策 | `technical-director` | 1 |
| 实现玩法代码 | `gameplay-programmer` | 3 |
| 实现核心引擎系统 | `engine-programmer` | 3 |
| 实现 AI 行为 | `ai-programmer` | 3 |
| 实现多人 | `network-programmer` | 3 |
| 实现 UI | `ui-programmer` | 3 |
| 构建开发工具 | `tools-programmer` | 3 |
| 评审代码架构 | `lead-programmer` | 2 |
| 创建着色器 / 视觉特效 | `technical-artist` | 3 |
| 定义视觉风格 | `art-director` | 2 |
| 定义音频风格 | `audio-director` | 2 |
| 设计音效 | `sound-designer` | 3 |
| 设计 UX 流程 | `ux-designer` | 3 |
| 编写测试用例 | `qa-tester` | 3 |
| 规划测试策略 | `qa-lead` | 2 |
| 剖析性能 | `performance-analyst` | 3 |
| 搭建 CI/CD | `devops-engineer` | 3 |
| 设计分析 | `analytics-engineer` | 3 |
| 检查无障碍 | `accessibility-specialist` | 3 |
| 规划长线运营 | `live-ops-designer` | 3 |
| 管理发布 | `release-manager` | 2 |
| 管理本地化 | `localization-lead` | 2 |
| 快速制作原型 | `prototyper` | 3 |
| 审计安全 | `security-engineer` | 3 |
| 与玩家沟通 | `community-manager` | 3 |
| Godot 专属帮助 | `godot-specialist` | 3 |
| GDScript 专属帮助 | `godot-gdscript-specialist` | 3 |
| Godot 着色器帮助 | `godot-shader-specialist` | 3 |
| GDExtension 模块 | `godot-gdextension-specialist` | 3 |
| Unity 专属帮助 | `unity-specialist` | 3 |
| Unity DOTS/ECS | `unity-dots-specialist` | 3 |
| Unity 着色器/视觉特效 | `unity-shader-specialist` | 3 |
| Unity Addressables | `unity-addressables-specialist` | 3 |
| Unity UI Toolkit | `unity-ui-specialist` | 3 |
| Unreal 专属帮助 | `unreal-specialist` | 3 |
| Unreal GAS | `ue-gas-specialist` | 3 |
| Unreal 蓝图 | `ue-blueprint-specialist` | 3 |
| Unreal 复制（replication） | `ue-replication-specialist` | 3 |
| Unreal UMG/CommonUI | `ue-umg-specialist` | 3 |

### Agent 层级

```
                    creative-director / technical-director / producer
                                         |
          ---------------------------------------------------------------
          |            |           |           |          |        |       |
    game-designer  lead-prog  art-dir  audio-dir  narr-dir  qa-lead  release-mgr
          |            |           |           |          |        |        |
     specialists  programmers  tech-art  snd-design  writer   qa-tester  devops
     (systems,    (gameplay,             (sound)     (world-  (perf,     (analytics,
      economy,     engine,                           builder)  access.)   security)
      level)       ai, net,
                   ui, tools)
```

**升级规则：** 如果两个 agent 意见不一致，就往上走。设计冲突交给
`creative-director`。技术冲突交给 `technical-director`。范围
冲突交给 `producer`。

---

<a id="appendix-b-slash-command-quick-reference"></a>
## Appendix B: 斜杠命令快速参考

### 按类别划分的全部 74 个命令

#### 上手与导航（7）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/start` | 引导式上手，路由到正确的工作流 | 任意（首次会话） |
| `/help` | 上下文感知的「我下一步做什么？」 | 任意 |
| `/project-stage-detect` | 完整项目审计，判断当前阶段 | 任意 |
| `/setup-engine` | 配置引擎、锁定版本、设置偏好 | 1 |
| `/adopt` | 存量项目审计与迁移计划 | 任意（现有项目） |
| `/settings` | 查看或更改项目配置（严格度、评审模式……） | 任意 |
| `/skill-improve` | 通过测试-修复-重测循环改进技能 | 任意 |

#### 游戏设计（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/brainstorm` | 协作式构思，含 MDA 分析 | 1 |
| `/map-systems` | 将概念拆解为系统索引 | 1-2 |
| `/design-system` | 引导式逐节 GDD 编写 | 2 |
| `/quick-design` | 小改动的轻量规格 | 2+ |
| `/review-all-gdds` | GDD 交叉一致性与设计理论评审 | 2 |
| `/propagate-design-change` | 找出受 GDD 变更影响的 ADR/用户故事 | 5 |

#### UX 与界面（2）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/ux-design` | 编写 UX 规格（界面/流程、HUD、模式） | 3-4 |
| `/ux-review` | 验证 UX 规格的无障碍与 GDD 契合度 | 4 |

#### 架构（4）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/create-architecture` | 主架构文档 | 3 |
| `/architecture-decision` | 创建或改造 ADR | 3 |
| `/architecture-review` | 验证所有 ADR、依赖顺序 | 3 |
| `/create-control-manifest` | 从 Accepted ADR 生成平实的程序员规则 | 3 |

#### 用户故事与冲刺（8）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/create-epics` | 将 GDD + ADR 转化为史诗（每个模块一个） | 4 |
| `/create-stories` | 将单个史诗拆分为用户故事文件 | 4 |
| `/dev-story` | 实现一个用户故事 —— 路由到正确的程序员 agent | 5 |
| `/sprint-plan` | 创建或管理冲刺计划 | 4-5 |
| `/sprint-status` | 30 行的快速冲刺快照 | 5 |
| `/story-readiness` | 验证用户故事是否已可实施 | 4-5 |
| `/story-done` | 8 阶段用户故事完成评审 | 5 |
| `/estimate` | 工作量估算与风险评估 | 4-5 |

#### 评审与分析（13）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/design-review` | 对照 8 节标准验证 GDD | 1-2 |
| `/code-review` | 架构级代码评审 | 5+ |
| `/balance-check` | 游戏平衡性公式分析 | 5-6 |
| `/asset-audit` | 资源命名、格式、体积验证 | 6 |
| `/asset-spec` | 逐资源的视觉规格与 AI 生成提示词 | 5-6 |
| `/content-audit` | GDD 规定内容 vs. 已实现内容 | 5 |
| `/consistency-check` | 跨 GDD 的实体与公式不一致扫描 | 2+ |
| `/scope-check` | 范围蔓延检测 | 5 |
| `/perf-profile` | 性能剖析工作流 | 6 |
| `/tech-debt` | 技术债扫描与优先级排序 | 6 |
| `/gate-check` | 正式阶段闸门，结论为 PASS/CONCERNS/NOT ASSESSED/FAIL | 所有阶段转换 |
| `/reverse-document` | 从现有代码生成设计文档 | 任意 |
| `/security-audit` | 安全漏洞审计（存档、网络、输入） | 6 |

#### QA 与测试（9）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/qa-plan` | 为冲刺或功能生成 QA 测试计划 | 5 |
| `/smoke-check` | QA 交接前的关键路径冒烟测试闸门 | 5-6 |
| `/soak-test` | 长时间游玩的浸泡测试协议 | 6 |
| `/regression-suite` | 映射测试覆盖率，找出缺少回归测试的已修复缺陷 | 5-6 |
| `/test-setup` | 搭建测试框架和 CI/CD 流水线 | 3 |
| `/test-helpers` | 生成引擎专属的测试辅助库 | 3-5 |
| `/test-evidence-review` | 测试文件与手动证据的质量评审 | 5 |
| `/test-flakiness` | 从 CI 日志检测非确定性测试 | 5-6 |
| `/skill-test` | 验证技能文件的结构与行为正确性 | 任意 |

#### 制作管理（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/milestone-review` | 里程碑进度与 go/no-go | 5 |
| `/retrospective` | 冲刺回顾分析 | 5 |
| `/bug-report` | 结构化缺陷报告创建 | 5+ |
| `/bug-triage` | 重新评估未解决缺陷的优先级、严重程度和负责人 | 5+ |
| `/playtest-report` | 结构化的试玩会话报告 | 4-6 |
| `/onboard` | 让新团队成员上手 | 任意 |

#### 发布（6）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/release-checklist` | 发布前验证 | 6 |
| `/launch-checklist` | 完整的跨部门上线就绪检查 | 7 |
| `/changelog` | 自动生成内部变更日志 | 6 |
| `/patch-notes` | 面向玩家的补丁说明 | 6 |
| `/hotfix` | 紧急修复工作流 | 7+ |
| `/day-one-patch` | 针对黄金母版（gold master）后发现的问题的范围化补丁 | 7+ |

#### 创意（4）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/prototype` | 概念原型 —— 在写 GDD 之前验证核心想法 | 1 |
| `/art-bible` | 引导式美术圣经编写 —— 视觉识别规格 | 1-4 |
| `/vertical-slice` | 制作阶段之前的制作级端到端构建 | 4 |
| `/localize` | 字符串提取与验证 | 6-7 |

#### 团队编排（9）

| 命令 | 用途 | 阶段 |
|---------|---------|-------|
| `/team-combat` | 战斗功能：从设计到实现 | 5 |
| `/team-narrative` | 叙事内容：从结构到对话 | 5 |
| `/team-ui` | UI 功能：从 UX 规格到打磨后的实现 | 5 |
| `/team-level` | 关卡：从布局到布置完成的遭遇 | 5 |
| `/team-audio` | 音频：从方向到实现的事件 | 5-6 |
| `/team-polish` | 协同打磨：性能 + 美术 + 音频 + QA | 6 |
| `/team-release` | 发布协调：构建 + QA + 部署 | 7 |
| `/team-live-ops` | 长线运营规划：季节性活动、战斗通行证、留存 | 7+ |
| `/team-qa` | 完整 QA 循环：策略、执行、覆盖率、签核 | 6-7 |

---

<a id="appendix-c-common-workflows"></a>
## Appendix C: 常见工作流

### 工作流 1：「我刚起步，还没有游戏点子」

```
1. /start (routes you based on where you are)
2. /brainstorm (collaborative ideation, pick a concept)
3. /setup-engine (pin engine and version)
4. /design-review on concept doc (optional, recommended)
5. /map-systems (decompose concept into systems with deps and priorities)
6. /gate-check systems-design (verify you're ready for Systems Design)
7. /design-system per system (guided GDD authoring)
```

### 工作流 2：「我有设计，想开始写代码」

```
1. /design-review on each GDD (make sure they're solid)
2. /review-all-gdds (cross-GDD consistency)
3. /gate-check technical-setup
4. /create-architecture + /architecture-decision (per major decision)
5. /architecture-review
6. /create-control-manifest
7. /art-bible (sections 1–4 now) + /test-setup + /ux-design accessibility + /ux-design patterns
8. /gate-check pre-production
9. /ux-design per key screen + /ux-review
10. /vertical-slice (recommended before committing to epics)
11. /create-epics layer: foundation + /create-stories [slug] (define epics, break into stories)
12. /sprint-plan new
13. /gate-check production
14. /story-readiness -> implement -> /story-done (story lifecycle)
```

### 工作流 3：「我在制作中途需要添加一个复杂功能」

```
1. /design-system or /quick-design (depending on scope)
2. /design-review to validate
3. /propagate-design-change if modifying existing GDDs
4. /estimate for effort and risk
5. /team-combat, /team-narrative, /team-ui, etc. (appropriate team skill)
6. /story-done when complete
7. /balance-check if it affects game balance
```

### 工作流 4：「生产环境出了问题」

```
1. /hotfix "description of the issue"
2. Fix is implemented on hotfix branch
3. /code-review the fix
4. Run tests
5. /release-checklist for hotfix build
6. Deploy and backport
```

### 工作流 5：「我有一个现有项目，想用这套系统」

```
1. /start (choose Path D -- existing work)
2. /project-stage-detect (determines current phase)
3. /adopt (audits existing artifacts, builds migration plan)
4. /design-system retrofit [path] (fill GDD gaps)
5. /architecture-decision retrofit [path] (fill ADR gaps)
6. /gate-check at appropriate transition
```

### 工作流 6：「开始一个新冲刺」

```
1. /retrospective (review last sprint)
2. /sprint-plan new (create next sprint)
3. /scope-check (ensure scope is manageable)
4. /story-readiness per story before pickup
5. Implement stories
6. /story-done per completed story
7. /sprint-status for quick progress checks
```

### 工作流 7：「发布游戏」

```
1. /tech-debt (decide what's acceptable at launch)
2. /security-audit (the release gate reads the newest report)
3. /localize qa for every language you ship
4. /release-checklist all
5. /changelog and /patch-notes (drafts; /team-release finalizes them)
6. /gate-check release (verify Polish is complete and the game is ready to release)
7. /launch-checklist (full cross-department validation)
8. /team-release (coordinate the release)
9. Ship!
10. /hotfix if anything breaks post-launch
11. Post-mortem after launch stabilizes
```

### 工作流 8：「我迷路了 / 不知道该做什么」

```
1. /help (reads your phase, checks artifacts, tells you what's next)
2. If /help doesn't help: /project-stage-detect (full audit)
3. If stage seems wrong: /gate-check at the transition you think you're at
```

---

## 充分利用本系统的技巧

1. **始终先设计，再实现。** Agent 体系建立在一个前提之上：
   写代码之前已有设计文档。
   Agent 会不断引用 GDD。

2. **跨领域功能使用团队技能。** 不要试图自己手动
   协调 4 个 agent —— 让 `/team-combat`、`/team-narrative`
   等来处理编排。

3. **信任规则系统。** 当规则在你的代码中标记了某些东西，就修复
   它。这些规则编码了来之不易的游戏开发智慧（数据驱动的值、
   delta time、无障碍等）。

4. **主动压缩上下文。** 上下文使用率达到约 65-70% 时，压缩或 `/clear`。
   你在 `active.md` 中的检查点会存活下来，之后 `session-start.sh` 会再次
   显示它。不要等到触及上限
   才行动。

5. **使用正确层级的 agent。** 不要让 `creative-director` 写着色器。
   不要让 `qa-tester` 做设计决策。层级
   的存在有其原因。

6. **不确定时运行 /help。** 它会读取你项目的实际状态，并告诉你
   最重要的下一步。

7. **把设计交给程序员之前先运行 `/design-review`。** 这样能
   尽早发现不完整的规格，节省返工。

8. **每个重要功能之后运行 `/code-review`。** 在架构问题
   蔓延之前发现它们。

9. **先为高风险机制制作原型。** 一天的原型制作可以为一个行不通的
   机制节省一周的制作时间。

10. **让冲刺计划保持诚实。** 定期使用 `/scope-check`。范围
    蔓延是独立游戏的头号杀手。

11. **用 ADR 记录决策。** 未来的你会感谢现在的你
    记录了*为什么*要那样构建。

12. **严格遵守用户故事生命周期。** 领取前 `/story-readiness`，
    完成后 `/story-done`。这样能尽早发现偏离，并让
    流水线保持诚实。

13. **尽早且频繁地写入文件。** 增量式章节写入意味着你的
    设计决策能在崩溃和压缩后存活。文件才是记忆，
    而不是对话。
