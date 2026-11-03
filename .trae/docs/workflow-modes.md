# 工作流模式 — 共享技能模式

本文档为每个编写、评审、闸门控制或规划项目产出物的技能定义 `modes.workflow` 和 `workflow_overrides`——即代码开始前**要求**多少设计文档。技能引用
本文档，而不是内联嵌入层级表。

**配套规格**：`.trae/docs/effects-map.md`
的 `modes.workflow` 和 `workflow_overrides` 节是行为的
事实来源。本文档是实现模式。

> **不要在技能运行期间阅读 `effects-map.md`。** 它的体积是
> AGENTS.md 每次会话加载的全部内容之和的许多倍——而且它是
> *编写和更改规格*的参考资料，不是运行时输入。
> **本文档自给自足**，足以解析层级并应用它：解析链、三个层级、要求
> 的小节以及覆盖规则都在这里。如果你遇到本文档确实未覆盖的情况，
> 只读 `effects-map.md` 中与相关配置项有关的那一节——绝不要读整个文件。

**相关共享文档**：`.trae/docs/automation-modes.md`（技能如何提示）、
`.trae/docs/director-gates.md`（生成哪些评审者）。`workflow` 与两者
正交——它控制*必须存在哪些产出物*，而不是*技能如何提示*或*谁来评审*。

---

## 如何使用本文档

编写、评审或闸门控制设计产出物的技能，在启动时解析
生效的工作流层级，然后应用该层级要求的小节 / 产出物集合。

**解析（按技能）：**

```
Resolve the workflow tier (store the result; see scope note below):
1. If the resolution is for a named system AND
   `workflow_overrides.system_overrides.<system>` is set → use that tier
2. Else read `modes.workflow` from `project.yaml` → use that value
3. Else → use the tier implied by `modes.rigor`
   (`minimal`→`minimal`, `standard`→`standard`, `full`→`full`;
    `rigor` itself defaults to `minimal`)
```

`modes.workflow` **没有终止默认值**——第 3 步是 `rigor` 展开，
而不是硬编码的 `standard`。对于未配置的项目，解析出的值相同，因此没有可观察的变化；但一个把 `standard` 硬编码为
回退值的技能会完全忽略 `rigor: minimal` 和 `rigor: full`。

### `<system>` 是什么——一处推导，处处一致

**`<system>` 是 GDD 文件名主干**：`design/gdd/forge-heat-system.md` →
`forge-heat-system`。这就是要写在
`workflow_overrides.system_overrides` 下的键，每个技能都必须以相同方式推导它。

`TR-[system]-NNN` ID 中的 `[system]` 段**是别名，不是键**。当 GDD 主干
没有结果时，可以接受它作为回退匹配，但绝不能优先于主干来推导键。

> **为何在此说明而不是按技能说明。** 阅读 *"其 `TR-[system]-NNN` ID 的
> `[system]` 段（否则用其 `design/gdd/` 路径）"*——TR-ID
> **在前**——是错误顺序。那么一个 GDD 为 `forge-heat-system.md`、
> 需求为 `TR-forge-001` 的系统就会有**两个不同的覆盖
> 键，取决于是否存在注册表条目**，而针对缺失 GDD 小节的文档化补救措施——
> "设置
> `workflow_overrides.system_overrides.forge-heat-system: full`"——会在
> `forge` 下查找，什么也找不到，然后在项目层级继续，**静默地**。
> 兜底出口会存在，却无法触达。

**不匹配任何系统的键是错误，不是空操作。** 如果
`workflow_overrides.system_overrides` 包含一个在 `design/gdd/` 中解析不出任何 GDD 主干的键，请说明——点名未匹配的键以及可用的主干。
静默忽略它会让一个毫无作用的覆盖留在原地，无人察觉。

> **在预期 GDD 已存在的地方检查——而不是由编写它们的技能检查。**
> `/gate-check` 是唯一实现位置（见
> `.trae/skills/gate-check/SKILL.md` §"Per-system overrides"），它在
> 阶段边界运行，到那时每个范围内的 GDD 都应已在磁盘上。那里出现
> 未匹配的键确实可疑。
>
> `/design-system` **创建** `design/gdd/<system>.md`，因此在其首次运行之前，
> 覆盖键*按定义*不匹配任何主干——那是健康情况，
> 不是错误。它不得把该键报告为孤立，也不得拒绝应用它指定的层级。
> 对任何其他在 GDD 存在之前运行的编写技能也是如此。在那里应用此规则
> 会恰好对它所保护的那份配置触发。

---

第 1 步（按系统覆盖）适用于针对具名系统操作的技能：
- **单系统，每次运行解析一次**：`design-system`、`design-review`、
  `dev-story`、`story-done`、`create-stories`（每次调用一个用户故事/史诗）。
- **多系统，每个条目解析一次**：`story-readiness`（按用户故事，覆盖
  `all`/`sprint` 范围）、`qa-plan` 和 `regression-suite` 审计（按 GDD/系统）。
  这些**不会**为本次运行固定单一层级——一次运行中的不同系统
  可能解析为不同层级。

项目级操作的技能（`gate-check`、`create-epics`）使用
项目级 `workflow`，并在层级表要求时考虑按系统覆盖。

> **"关键 ADR"（用于层级表）：** 管辖
> **基础层（Foundation-layer）**系统的 ADR（场景管理、事件架构、存档/读档，
> 以及类似系统——其他一切都依赖其决策的系统）。在
> `standard` 下，只有关键 ADR 是必需/阻塞的；非关键 ADR 是
> 建议性的。拿不准某个 ADR 的层级时，按关键处理（故障安全
> 方向是要求它）。

`modes.workflow` 通过 **`resolve_config --keys workflow`**（或
`resolve_setting modes.workflow`）读取，它会应用整条链，包括
`rigor` 展开。**不要**使用 `get_effective_yaml_key modes.workflow`：它
只读取两个 YAML 文件，因此在设置了 `modes.rigor` 而未设置
`modes.workflow` 的项目上，它会返回**空值**，而生效层级是 rigor
所隐含的层级。（`project.local.yaml` 不允许覆盖 workflow——按白名单它被锁定
到 `project.yaml`——因此唯一来源是 `project.yaml` 和
展开。）按系统覆盖通过
`get_yaml_key project.yaml workflow_overrides.system_overrides.<system>` 读取。

---

## 三个层级

| 层级 | Token/时间成本 | 代码前要求 | 最适合 |
|------|----------------|---------------------|----------|
| `full` | 高 | 每个系统全部 8 个 GDD 小节、完整架构、全部 ADR、美术圣经、每个屏幕的 UX 规格 | 团队、商业作品、学习完整流水线 |
| `standard` | 平衡 | 每个系统 5 个 GDD 小节、一份架构文档、关键 ADR、游戏概念、系统索引 | 已超出简报范围的项目——多个相互作用的系统，或由他人实现的设计 |
| `minimal` | 低 | 单页 `design/game-brief.md` + 引擎选择（其构建顺序字段就是计划——无需单独的冲刺计划） | **默认。** Game jam 项目、小范围、设计已在脑中 |

**默认**：`minimal`（`.trae/hooks/yaml-helper.sh` 中 `_yaml_helper_defaults` 上方的
理由说明块包含推理和顺序
约束）。**设置方式**：`/start`（通过 `modes.rigor`）、`/settings`。**锁定到
`project.yaml`**（不可本地覆盖——分歧会改变
磁盘上必须存在哪些产出物）。

> **宽松，而非限制。** `workflow` 控制什么是必需的，而不是
> 什么是允许的。任何技能都可以在任何层级运行。该设置改变的是
> `gate-check` 强制执行的内容和完整性检查验证的内容——绝不改变
> 用户可以调用的内容。

> **`minimal` 底线。** 即使在 minimal 下，引擎选择和一份填好的
> **`design/game-brief.md`** 也是代码开始前的必需项——简报的
> 构建顺序字段就是计划，因此没有单独的 `sprint-plan` 步骤。
> 其他一切都可以跳过。

> **"Game brief" 在 `minimal` 下是真实产出物：`design/game-brief.md`。**
> 当生效层级为 `minimal` 时，`/brainstorm` 会从单页模板
> （`.trae/docs/templates/game-brief.md`）写入它，
> 以替代它在
> `standard`/`full` 下写入的完整长度 `design/gdd/game-concept.md`。两者是针对不同层级的
> 不同文件：任何针对 `minimal` 设计产出物的检查、
> 闸门或 glob 都必须指向
> **`design/game-brief.md`**；`game-concept.md` 仍是 `standard`/`full`
> 概念文档。

---

## 各层级要求的 GDD 小节

8 个 GDD 小节：Overview、Player Fantasy、Detailed Rules、Formulas、
Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria。

> **小节名称别名。** "Detailed Rules" 是设计
> 标准中的规范名称，但 GDD 模板（`.trae/docs/templates/game-design-document.md`）
> 和 `/design-system` 在标题 `## Detailed Design`
> 下编写此节（带有 Core Rules / States / Interactions 子标题）。两个名称表示
> **同一个要求的小节**——任何检测或验证小节存在性的技能
> （`design-review`、`gate-check`、`adopt`、`project-stage-detect`）都必须接受
> 任一标题。当存在 `## Detailed
> Design` 时，不要认为 "Detailed Rules" 缺失。

| 层级 | 要求的 GDD 小节 |
|------|----------------------|
| `full` | 全部 8 个 |
| `standard` | **5 个必需**：Overview、Detailed Rules、Edge Cases、Dependencies、Acceptance Criteria。**有条件**：Formulas——当系统**定义数值规则**时必需（速率、曲线、阈值、成本、伤害、掉落权重——任何平衡性调整会调优的内容）；仅当系统不定义任何数值规则时才可选。`Category` 列是提示，不是判定标准。**跳过**：Player Fantasy、Tuning Knobs。 |
| `minimal` | 无——`design/game-brief.md` 替代 GDD。仍可自愿编写 GDD。 |

> **Edge Cases 在 `standard` 下是必需的**（它从可选提升而来——
> 跳过它在实现期间产生了 "如果 X 为 null 会怎样？" 的技术债）。

> **美术圣经在 `standard` 下是有条件的**——仅当项目中存在视觉资源
> 用户故事时才必需。以代码为主的项目跳过它。在 `full` 下，要求
> 全部 9 个美术圣经小节。（`workflow_overrides.art_bible_strict:
> true` 无论层级如何都强制全部 9 个。）

---

## `workflow_overrides`

此键包含两个具有**不同方向规则**的机制。请阅读你正在使用的那一个——
把它们混为一谈是已知且容易犯的错误。

```yaml
workflow_overrides:
  # --- the three boolean FLAGS: additive, stricter-only ---
  edge_cases: false          # force Edge Cases required (no-op at standard/full; relevant at minimal)
  tuning_knobs: false        # force Tuning Knobs required (relevant at standard, no-op at full)
  art_bible_strict: false    # force all 9 art bible sections regardless of asset stories

  # --- system_overrides: replaces a tier, BOTH directions ---
  system_overrides: {}       # per-system tier overrides (see below)
```

**三个布尔标志是在所选 `workflow` 层级之上累加的——
它们让要求更严格，绝不更宽松。** 每个标志都只会强制某项要求*开启*；
设置标志不能选择退出层级所施加的要求。`edge_cases`、`tuning_knobs` 或 `art_bible_strict`
没有任何值会移除任何内容。

**`system_overrides` 不是标志，也不具有累加性。** 它为一个具名系统*替换*
生效层级，且**双向**均可——见下一节。放宽型覆盖确实会放宽：在 `full` 项目上，
`system_overrides.inventory: minimal` 会把该系统的要求小节降为零。
这是有意设计（它使 "严肃项目中的一个琐碎系统" 可表达），
但这也意味着覆盖**不是**安全的空操作——不要以为仅收紧规则会保护你，
就把一个覆盖留在原地。

### 按系统覆盖

```yaml
workflow_overrides:
  system_overrides:
    combat: full              # combat GDD requires all 8 sections regardless of project workflow
    inventory: minimal        # inventory needs no GDD — the game brief covers it (minimal = no required sections)
```

`system_overrides` 是 `system_name: workflow_level` 的映射。具名系统
使用覆盖层级；所有其他系统使用项目级 `workflow`。
针对具名系统操作的技能通过上述解析链的第 1 步解析其生效层级。

---

## 生效层级解析示例

项目有 `modes.workflow: standard`、`workflow_overrides.system_overrides.combat: full`。

- `/design-system combat` → 生效层级 **full** → 要求全部 8 个小节
- `/design-system inventory` → 无覆盖 → 生效层级 **standard** → 5 个小节 + 有条件 Formulas
- `/gate-check`（Systems Design → Technical Setup）→ 在通过前要求 combat GDD 达到 8 个小节，且其他每个 MVP GDD 达到 5 个小节

---

## 各技能行为（工作摘要——运行时足够）

**编写**——根据生效层级分支要求的小节（对于
`brainstorm`，还根据生成哪种设计产出物分支——`minimal` 下为 `design/game-brief.md`，
`standard`/`full` 下为 `design/gdd/game-concept.md`）：
`brainstorm`、`design-system`、`art-bible`、`create-architecture`、`ux-design`、
`map-systems`、`architecture-decision`。

**评审/验证**——根据生效层级验证；缺失的
*必需*小节阻塞，缺失的*可选*小节警告：
`design-review`、`review-all-gdds`、`architecture-review`、`consistency-check`、
`content-audit`。

**闸门执行**——`gate-check` 按阶段、按层级使用不同的产出物清单（影响可见度最高）。每个闸门自己的清单和
层级削减位于 `.trae/skills/gate-check/references/gate-<phase>.md`，
而 `/gate-check` 只加载它正在运行的那一个闸门——那才是正确
的查阅位置，而不是 `effects-map.md`。

**规划/实现**——调整产出物前置条件：
`create-epics`、`create-stories`、`dev-story`、`story-readiness`、`story-done`、
`qa-plan`、`regression-suite`。

**支持**——调整 "缺少什么" 的预期，以免可选文档
被标记为缺口：`project-stage-detect`、`adopt`、`reverse-document`、
`propagate-design-change`、`help`。

---

## 项目中途更改工作流

当通过 `/settings` 更改 `workflow` 时，发出信息性说明：

> "Workflow changed from [old] to [new]. Run `/content-audit` to see what's now
> required or extra. No automatic migration — existing files stay in place."

不会自动删除、自动生成或阻塞任何文档。该设置只
影响向*新*执行的强制要求。

---

## 配套设置

这些是独立的设置，与 `workflow` 组合使用。以下摘要
是技能在运行时需要的内容；`effects-map.md` 为规格作者承载详尽
的按技能表，不值得为了应用某个配置项而加载。

> **以下四项都由 `modes.rigor` 前置**（`docs.density`、
> `modes.story_granularity`、`qa.level`、`team.size`——连同 `workflow` 本身，
> 以及 `modes.review_mode`，共六个前置配置项）。`/start` 中的一个问题
> 即可设置它们全部；显式设置任一项只会覆盖该项，并让
> 其余项留在 rigor 级别上。`team.size` 和 `modes.review_mode` 是
> 仍可从 `project.local.yaml` 覆盖的两项（它们是个人体验类
> 配置项，不是磁盘产出物）。

- **`docs.density`**（`terse` | `balanced` | `thorough`）——`workflow` 控制
  *存在哪些小节*；`density` 控制*每个小节深入多少*。
  `rigor` 同时设置二者；单独覆盖 `docs.density` 可获得
  `full` + `terse` = "全部 8 个小节，每个都紧凑"。
- **`modes.story_granularity`**（`coarse` | `balanced` | `fine`）——每个
  用户故事有多大，以及每个史诗/冲刺有多少个。
- **`qa.level`**（`minimal` | `standard` | `full`）——把用户故事标记为 Done
  需要什么测试证据。与 `testing.strict` 组合：
  `qa.level` = 是否要求证据；`testing.strict` = 失败是否阻塞。
- **`team.size`**（`individual` | `small` | `studio`）——默认哪些 agent 处于激活状态。
  与 workflow 不同的轴：workflow 控制*要求哪些文档*，
  team.size 控制*存在哪些 agent 来制作它们*。
