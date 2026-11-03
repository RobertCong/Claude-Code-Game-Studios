# /ux-design — 第 2 与 2b 节：收集上下文与改造检测

> 属于 `/ux-design` 的一部分。`SKILL.md` 指明了何时阅读本文件；它
> 解析出的设置以及其后各标题下的规则在此仍然适用。

## 2. 收集上下文（读取阶段）

**本文件包含：**

- 2a：必读项
- 2b：玩家旅程
- 2c：GDD UI 要求
- 2d：现有 UX 规格
- 2e：交互模式库
- 2f：美术圣经
- 2g：无障碍要求
- 2h：输入方式（来自项目配置）
- 2i：呈现上下文摘要

在向用户提出任何问题**之前**，先阅读所有相关上下文。本技能的价值
来自“带着信息到达”。按小节读取每份 GDD 与美术圣经：用 Grep 工具
（模式 `^#`，内容模式）找到需要的标题，再用 offset 和 limit 读取这些
区段。

### 2a：必读项

- **游戏概念**：读取 `design/gdd/game-concept.md` — 或者 `design/game-brief.md`，
  即在 `rigor: minimal` 时替代它的一页式简报 — 若两者都不存在，警告：
  > “未找到游戏概念。请先运行 `/brainstorm`，在设计 UX 之前确立
  > 游戏的基础。”
  > 如果用户要求，仍可继续。

### 2b：玩家旅程

如果 `design/player-journey.md` 存在，读取它。对每个相关小节，提取：
- 这个屏幕出现在哪个（些）旅程阶段？
- 玩家到达此屏幕时的情绪状态是什么？
- 这个屏幕在旅程中满足玩家的什么需求？
- 这个屏幕承载了（旅程地图中的）哪些关键时刻？

如果玩家旅程文件不存在，记录这一缺口并继续：
> “未在 `design/player-journey.md` 找到玩家旅程地图。没有它进行设计
> 意味着我们将对玩家上下文做出假设。建议在本规格起草后
> 进行一次玩家旅程会话。”

同时添加到 UX 规格的 Open Questions 小节：
> “玩家旅程地图尚未创建。请依据 `.claude/docs/templates/player-journey.md` 的模板撰写它，以便为这个屏幕确立玩家上下文。”

> **不要告诉用户去“运行 `/ux-design` Phase 2b”来创建它。** Phase 2b
> 就是这一步 — *读取*该文件的那一步。那种补救是循环的：它
> 把用户送回刚刚报告缺口的检查。没有任何技能会写入
> `design/player-journey.md`；它是依据模板手工撰写的。

### 2c：GDD UI 要求

Glob `design/gdd/*.md`，并搜索 `UI Requirements` 小节。读取任何其
UI 要求小节按名称或类别引用此屏幕的 GDD。

这些 GDD UI 要求是本规格的**需求输入**。把它们收集为一份
本规格必须满足的约束清单。

如果设计 HUD，你需要**每一个**系统的 UI 要求 — HUD 会聚合它们。
用一次扫描收集，而不是逐个打开 GDD：

```
Grep pattern="^#+ .*UI Requirements" glob="design/gdd/*.md" output_mode="content" -A 20
```

先确定分母（glob `design/gdd/*.md`，计数为 **N**），再核对匹配数
是否与之一致。只统计系统 GDD：`game-concept.md`、
`systems-index.md`、`game-pillars.md`、`gameplay-tags.md`、`entity-registry.md`、
`fixture-swap-ledger.md`、`sound-bible.md` 以及任何 `gdd-cross-review-*.md` 也
存放在那里，但它们不是系统，没有可聚合的 UI。
**一份没有 UI Requirements 小节的 GDD 并不等于
没有 UI 需求的 GDD** — 它可能早于该小节出现。列出未匹配的 GDD，
并在将其排除出 HUD 需求集之前与用户确认它们确实没有界面；
HUD 悄悄遗漏某个系统的读数，正是这种聚合机制存在要防止的
失败。

### 2d：现有 UX 规格

Glob `design/ux/*.md`，记下哪些屏幕已有规格。对于将链接到当前屏幕
或从当前屏幕链接出去的屏幕，读取它们的导航/流程小节，
找出本规格必须匹配的进入点与退出点。

### 2e：交互模式库

如果 `design/ux/interaction-patterns.md` 存在，读取模式目录索引
（模式名称及其一句话描述的列表）。不要读取完整的
模式细节 — 只看目录。这会告诉你已存在哪些模式，
以便你引用它们而不是重新发明。

### 2f：美术圣经

检查是否存在 `design/art/art-bible.md`。如果找到，读取视觉方向
小节。UX 布局必须与已经确立的美学承诺保持一致。

### 2g：无障碍要求

检查是否存在 `design/accessibility-requirements.md`。如果找到，读取它。规格
必须满足其中承诺的无障碍等级。

### 2h：输入方式（来自项目配置）

读取 `project.yaml` 中的 `platform` 块；如果 `project.yaml` 没有
`platform` 块，则回退到
`.claude/docs/technical-preferences.md` 的 `## Input & Platform` 小节。保存这些值供
整个技能使用 — 它们驱动交互映射，并为无障碍
要求提供依据：

- **Primary Input** — `platform.primary_input` — 本游戏的主导输入
- **Gamepad Support** — `platform.gamepad_support` — Full / Partial / None
- **Touch Support** — `platform.touch_support` — Full / Partial / None
- **Target Platforms** — `platform.targets` — 用于安全区与宽高比决策
- **Input Methods** — 受支持方法的集合。从
  `project.yaml` 读取时，按如下方式推导：若 `targets` 中包含 `PC` 或 `Web`，则有
  keyboard/mouse；若游戏手柄支持为 Full/Partial，则有
  gamepad；若触控支持为
  Full/Partial，则有 touch；再加上主输入。回退到
  `technical-preferences.md` 时，使用其显式的 Input Methods 字段。

如果两个来源都未配置，询问一次：
> “输入方式尚未配置。本游戏的目标平台是什么？”
> 选项：“仅 Keyboard/Mouse”、“仅 Gamepad”、“两者（PC + Console）”、“Touch（mobile）”、“以上全部”
>
> （运行 `/setup-engine` 可永久保存，以免再次询问。）

在本次会话余下时间里保存该答案。**不要**按小节
或按屏幕重复询问。

### 2i：呈现上下文摘要

在进行任何设计工作之前，向用户呈现一份简要摘要：

> **正在设计：[Screen/Flow Name]**
> - 模式：[UX 规格 / HUD 设计 / 模式库]
> - 旅程阶段：[来自 player-journey.md，或“未知 — 无旅程地图”]
> - 为本规格提供输入的 GDD 要求：[数量与名称，或“未找到”]
> - 已有规格的关联屏幕：[列表，或“暂无”]
> - 可用已知模式：[数量，或“尚无模式库”]
> - 无障碍等级：[来自要求文档，或“尚未定义”]
> - 输入方式：[从 `project.yaml` 的 platform 块推导，或“已在上方询问”]

然后询问：“在我们开始之前还有什么需要我阅读的吗，还是现在就开始？”

---

## 2b. 改造模式检测

在创建骨架之前，检查目标输出文件是否已存在。

Glob 第 1 阶段解析出的输出路径 — `design/ux/[filename].md`，或在
`accessibility` 模式下的 `design/accessibility-requirements.md`。

**如果文件已存在 — 改造模式：**
- 完整读取该文件
- 对每个预期小节，检查其正文是否含有真实内容（不只是 `[To be designed]` 占位符），还是为空/占位符
- 向用户呈现小节状态摘要：

> “在 `design/ux/[filename].md` 找到了现有 UX 规格。以下是已完成的部分：
>
> | 小节 | Status |
> |---------|--------|
> | 目的与玩家需求 | [Complete / Empty / Placeholder] |
> | 玩家到达时的上下文 | ... |
> | 导航位置 | ... |
> | 进入点与退出点 | ... |
> | 布局规格 | ... |
> | 状态与变体 | ... |
> | 交互映射 | ... |
> | 数据需求 | ... |
> | 触发事件 | ... |
> | 过渡与动画 | ... |
> | 输入方式完整性清单 | ... |
> | 无障碍 | ... |
> | 本地化考量 | ... |
> | 验收标准 | ... |
> | 待决问题 | ... |
>
> （各行是当前模式下骨架自身的 `##` 标题 — 上面的列表是
> UX 规格模式；HUD 与无障碍模式则列出它们各自骨架的标题。）
>
> 我将只处理 [N] 个未完成的小节 — 现有内容不会被覆盖。”

- 跳过第 3 节（骨架创建）— 文件已存在
- 在 Phase 4（小节撰写）中，只处理 Status 为 Empty 或 Placeholder 的小节
- 使用 `Edit` 原地填充占位符，而不是创建新骨架

**如果文件不存在 — 全新撰写模式：**
照常进入 Phase 3（创建文件骨架）。

---
