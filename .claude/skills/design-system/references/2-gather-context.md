# /design-system — Phase 2: 收集上下文

> 属于 `/design-system` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## 2. 收集上下文（读取阶段）

**本文件包含：**

- 2a：必需读取
- 2b：依赖读取
- 2c：可选读取
- 2d：呈现上下文摘要
- 2e：技术可行性预检查

在向用户提出任何问题**之前**，先读取所有相关上下文。这是本技能相对于临时设计的
主要优势 —— 它是有备而来的。按章节读取每个 GDD 与 ADR：用 Grep 工具找出需要的
标题（模式 `^#`，内容模式），再用 offset 和 limit 读取相应范围。

### 2a：必需读取

> **在 `minimal` 下**（此层级下 design-system 为自愿使用）：读取
> `design/game-brief.md` 代替游戏概念，并**跳过系统索引读取** —— 在 `minimal` 下
> 既没有 `game-concept.md` 也没有 `systems-index.md`。
> 从简报中的相关 MVP 功能及其核心循环来撰写。
>
> **此提示依据的是项目层级，而非本系统的生效层级。**
> 当 `workflow_overrides.system_overrides` 把某个系统提升到 `minimal` 项目之上时，
> 两者就会不同 —— 这正是 `.claude/docs/settings-guidance.md` 所称该覆盖存在的理由
> （"提升一个深层系统"）。那两个文件之所以缺失，是因为*项目*是 `minimal`；把*本系统*
> 提升到 `standard` 或 `full` 并不会创建它们。因此在一个 `minimal` 项目上，
> **即使系统被覆盖也走这个分支**，并读取简报。
>
> 生效层级仍然支配所有下游内容 —— 必需章节集合（§1）、骨架（§3）、章节循环（§4）
> 以及 §5a。只有这里的必需*读取*分支遵循项目层级。
>
> **然后在这里一次性从简报推导出 `Category`、`Layer` 和 `Priority`。**
> 后续有六个步骤依赖于你刚刚跳过的系统索引 —— §2e 的引擎域、Section A 与 Section B
> 的推荐选项、Visual/Audio REQUIRED 表、§6 的专家路由，以及 §5-pre 的 Quick
> reference —— 它们都没有"索引缺失"的分支。被覆盖的系统在 `standard` 或 `full` 下
> 会走到全部六处，因此"跳过索引"会让它们完全没有输入。请改为从简报推导：
>
> - **`Category`** —— `templates/systems-index.md` 中九个之一
>   （`Core · Gameplay · Progression · Economy · Persistence · UI · Audio ·
>   Narrative · Meta`），依据简报所述系统*做什么*来选择。
> - **`Layer`** —— 若其他系统依赖它则为 `Foundation`，否则为 `Feature`。
> - **`Priority`** —— 若简报的构建顺序列出了它则为 `MVP`，否则为 `Post-MVP`。
>
> 在本次运行余下过程中携带这三项，并把它们当作索引的答案。
> 在 §5-pre 的 Quick reference 中**标记它们为推导值**（*"Category: Gameplay
> (inferred from the brief — no systems index at this tier)"*），以免后续读者把推导
> 结果误当成索引事实。**不要**为了保存它们而写一个系统索引：该文件由
> `/map-systems` 负责（§5d）。
>
> 没有这条规则，被覆盖的系统会解析为 `full`，落到下面的快速失败读取，并在第一步
> 中止，报出 *"未找到游戏概念。请先运行 `/brainstorm`"*。

- **游戏概念**：读取 `design/gdd/game-concept.md` —— 缺失则失败：
  > "未找到游戏概念。请先运行 `/brainstorm`。"
- **系统索引**：读取 `design/gdd/systems-index.md` —— 缺失则失败：
  > "未找到系统索引。请先运行 `/map-systems` 梳理你的系统。"
- **目标系统**：在索引中查找该系统。若未列出，则警告：
  > "[system-name] 不在系统索引中。你想添加它，还是
  > 将其作为索引外系统来设计？"
- **实体注册表**：若 `design/registry/entities.yaml` 存在，列出本系统拥有的条目
  以及引用它的条目，每个条目完整列出：
  ```
  bash .claude/scripts/registry.sh slice design/gdd/[system-name].md
  ```
  `referenced_by:` 是块列表（键与其路径分行存放），因此按路径 grep 只能找到那一行，
  找不到拥有它的条目；`slice` 会打印拥有它的条目，无论其列表有多长。把这些作为
  **已知事实**保存在上下文中 —— 其他 GDD 已经确立、本 GDD 不得与之矛盾的值。
- **反思日志（Reflexion log）**：若 `docs/consistency-failures.md` 存在则读取。
  提取 Domain 与本系统类别匹配的条目。这些是反复出现的冲突模式 —— 在 Phase 2d
  上下文摘要的"Past failure patterns"下列出它们，让用户知道该领域此前在哪里出过错。

### 2b：依赖读取

从系统索引中识别：
- **上游依赖**：本系统所依赖的系统（本系统必须遵守的决策）。
- **下游依赖方**：依赖本系统的系统（本系统必须满足的期望）。

对于每个存在的依赖 GDD，**只读取承载跨系统契约的那四个章节** —— 而不是整个 GDD：
```
Grep pattern="^## ([0-9]+\. )?(Dependencies|Formulas|Edge Cases|Tuning Knobs)" glob="design/gdd/[dep].md" output_mode="content" -A 20
```
- 关键接口与数据流（来自 Dependencies）
- 引用本系统输出的 Formulas
- 假定本系统行为的 Edge Cases
- 输入到本系统的 Tuning Knobs

其中大部分已在 `entities.yaml` 中（在 2a 中加载）—— 注册表的 `formula_map`/
`constant_map` 携带所拥有的值及其 `source:`。优先使用注册表；章节 grep 补足它
未持有的内容。

### 2c：可选读取

- **游戏支柱**：若 `design/gdd/game-pillars.md` 存在则读取
- **现有 GDD**：若 `design/gdd/[system-name].md` 存在则读取（续写，而不是
  从头开始）
- **相关系统**：**不要**用 glob 通读 `design/gdd/*.md` 去寻找"主题相关"的系统 ——
  对此没有确定性的替代指标，而注册表存在的意义正是替代这种读取。`entities.yaml`（2a）
  已持有相关 GDD 会提供的跨系统事实。如果已知存在特定的重叠，把它当作上面的依赖并
  用章节 grep 处理；否则依赖注册表。

### 2d：呈现上下文摘要

在开始设计工作之前，向用户呈现简要摘要：

> **正在设计：[System Name]**
> - 优先级：[from index] | 层级：[from index]
> - 依赖：[list, noting which have GDDs vs. undesigned]
> - 被依赖：[list, noting which have GDDs vs. undesigned]
> - 需要遵守的现有决策：[key constraints from dependency GDDs]
> - 支柱契合度：[which pillar(s) this system primarily serves]
> - **已知跨系统事实（来自注册表）：**
>   - [entity_name]: [attribute]=[value], [attribute]=[value] (owned by [source GDD])
>   - [item_name]: [attribute]=[value], [attribute]=[value] (owned by [source GDD])
>   - [formula_name]: variables=[list], output=[min–max] (owned by [source GDD])
>   - [constant_name]: [value] [unit] (owned by [source GDD])
>   *（这些值已被锁定 —— 如果本 GDD 需要不同的值，请在撰写之前暴露该冲突。
>   不要悄悄地使用不同的数字。）*
>
> 如果没有相关的注册表条目：省略"Known cross-system facts"部分。

如果有任何上游依赖尚未设计，则警告：
> "[dependency] 还没有 GDD。我们将需要对其接口做出假设。
> 考虑先设计它，或者我们可以定义预期契约并将其标记为临时性。"

### 2e：技术可行性预检查

在请用户开始设计之前，加载引擎上下文，并暴露任何会塑造设计的约束或知识缺口。

**第 1 步 —— 确定本系统的引擎域：**
将系统类别（来自 systems-index.md）映射到引擎域：

依据 `systems-index.md` 的 `Category` 列。`templates/systems-index.md` 定义的九个
类别都出现在这里；若某类别跨越多个引擎域，请选与实际系统行为匹配的那一行，并说明
你选了哪一行。

| `Category` | 引擎域 |
|-----------|--------------|
| `Gameplay` | 战斗 / 碰撞 / 移动用 **Physics**；AI 与寻路用 **Navigation**；无引擎界面的纯规则系统用 **Scripting** |
| `Core` | **Core** —— 场景管理、状态、资源加载；控制与按键绑定用 **Input** |
| `UI` | UI |
| `Audio` | Audio |
| `Narrative` | Scripting —— 对话、任务、过场动画 |
| `Progression` | Scripting —— 与存档相邻的规则逻辑，无专用域 |
| `Economy` | Scripting —— 数据与规则逻辑，无专用域 |
| `Persistence` | Core —— 存档/读档、设置、序列化 |
| `Meta` | Core —— 遥测、教程、无障碍基础设施 |

> Animation、Rendering 和 Networking 是没有独立类别的引擎域：需要它们的系统
> 会归为 `Gameplay` 或 `Core`。无论你从哪一行进来，都要说明你为其读取参考资料
> 的那个引擎域。

**第 2 步 —— 读取引擎上下文（如可用）：**
- 识别引擎与版本：从 `project.yaml` 读取 `engine.name` 与 `engine.version`。独立解析每个字段 —— 如果其键缺失或为空（包括 `project.yaml` 没有 `engine:` 块的情况），回退到 `.claude/docs/technical-preferences.md`（`[TO BE CONFIGURED]` 值表示未设置）
- 如果引擎已配置，读取 `docs/engine-reference/[engine]/VERSION.md`
- 若存在则读取 `docs/engine-reference/[engine]/modules/[domain].md`。
  **如果它不存在，请点名说明** —— *"no engine reference for `[domain]`
  under `docs/engine-reference/[engine]/modules/`; feasibility not checked against
  the pinned engine"* —— 并把它带入 §5-pre。此处静默跳过，与运行了可行性检查并
  未发现问题无法区分，而这正是 `.claude/rules/skill-authoring.md` 义务 3 要阻止的
  失败模式。

  > **这不是罕见分支。** 上面的域表为九个类别中的五个指定了 `Scripting` 和
  > `Core`（`Narrative`、`Progression`、`Economy` → Scripting；`Persistence`、
  > `Meta` → Core），另外 `Gameplay` 与 `Core` 下各有一个子行。Godot 参考附带的是
  > `animation, audio, input, navigation, networking, physics, rendering, ui` ——
  > **没有 `scripting.md`，也没有 `core.md`**。因此大多数非 `Gameplay` 系统每次都会
  > 落到缺失分支：每次都要报告它。
- 读取 `docs/engine-reference/[engine]/breaking-changes.md` 中与域相关的条目
- 找到与域匹配的 ADR，而不必为了解筛选字段而读完每个 ADR —— 先 grep Domain 字段，
  再只读取匹配项：
  ```
  Grep pattern="\*\*Domain\*\*" glob="docs/architecture/adr-*.md" output_mode="content"
  ```
  只读取 Domain 与本系统类别匹配的 ADR（其 `## Decision` 与 `## Engine Compatibility`
  章节）；跳过其余部分。

**第 3 步 —— 呈现可行性简报：**

如果存在引擎参考资料，在开始设计前呈现：

```
## Technical Feasibility Brief: [System Name]
Engine: [name + version]
Domain: [domain]

### Known Engine Capabilities (verified for [version])
- [capability relevant to this system]
- [capability 2]

### Engine Constraints That Will Shape This Design
- [constraint from engine-reference or existing ADR]

### Knowledge Gaps (verify before committing to these)
- [post-cutoff feature this design might rely on — mark HIGH/MEDIUM risk]

### Existing ADRs That Constrain This System
- ADR-XXXX: [decision summary] — means [implication for this GDD]
  (or "None yet")
```

如果没有引擎参考资料（引擎尚未配置），显示简短说明：
> "尚未配置引擎 —— 跳过技术可行性检查。如果还没有配置，请在进入架构阶段前
> 运行 `/setup-engine`。"

**第 4 步 —— 在继续之前询问：**

使用 `AskUserQuestion`：
- "在开始之前还有要补充的约束吗，还是带着这些已记录的约束继续？"
  - 选项："Proceed with these noted", "Add a constraint first", "I need to check the engine docs — pause here"

---

使用 `AskUserQuestion`：
- "准备好开始设计 [system-name] 了吗？"
  - 选项："Yes, let's go", "Show me more context first", "Design a dependency first"

---
