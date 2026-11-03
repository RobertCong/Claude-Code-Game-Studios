---
name: art-bible
description: "撰写美术圣经（Art Bible）——视觉识别是资源生产的质量闸门。请在 /map-systems 之前运行。"
argument-hint: "[--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/art-bible/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,workflow,docs.density`

以上已解析完成——直接使用；`--review` 会覆盖 `review_mode`。若没有配置块 → 使用 `.claude/docs/config-resolution.md` 中的默认值。

# Art Bible（美术圣经）


## Phase 0: 解析参数与上下文检查


完整的检查模式见 `.claude/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.claude/docs/director-gates/[gate-id].md`——被生成的 agent 会读取自己的闸门文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`（collaborative 总是询问 · guided 仅询问重大决策 · autonomous 记录并继续；`automation_always_ask` 类别始终提示）。

**`docs.density`**——它控制每个章节的*深度*，而 `workflow` 控制存在哪些章节。`modes.rigor` 会同时设置两者；若只想改变深度，请显式设置 `docs.density`：`terse`（默认值，经由 `rigor: minimal`）= 每个章节为约束 + 参考资料的项目符号列表；`balanced` = 用段落解释每项视觉选择（`rigor: standard`）；`thorough` = 完整行文，包含风格探索、参考资料以及每项选择的理由。请将其应用到你所撰写的每个章节。

**`workflow`**（见 `.claude/docs/workflow-modes.md`）：
- `full`——要求全部 9 个美术圣经章节。
- `standard`——仅当项目中存在视觉资源用户故事时才为必需；为必需时，第 1–4 节即为最低要求。`workflow_overrides.art_bible_strict: true` 会强制要求全部 9 个章节，无论层级如何。
- `minimal`——非必需。仍可自愿运行。

读取 `design/gdd/game-concept.md`——或在 `rigor: minimal` 下替代它的一页式简报 `design/game-brief.md`。按章节读取：用 Grep 工具查找所需标题（模式 `^#`，content 模式），再用 offset 和 limit 读取对应范围。如果两者都不存在，则以如下内容失败：
> “未找到游戏概念。请先运行 `/brainstorm`——美术圣经在游戏概念获得批准之后撰写。”

从 game-concept.md 中提取（若是简报：工作标题、提案、“面向谁 / 他们感受什么”一行以及“美术与音频方向”一行——简报没有游戏支柱、视觉识别锚点或平台信息）：
- 游戏标题（工作标题）
- 核心幻想与电梯陈述
- 游戏支柱（全部）
- **Visual Identity Anchor** 章节（若存在）（来自 brainstorm Phase 4 的 art-director 输出）
- 目标平台（若有注明）

**改造（retrofit）模式检测**：Glob `design/art/art-bible.md`。如果文件存在，构建状态表时**不要读取文档**——你即将只撰写*未完成*的章节，加载已完成的章节只会加载你完全不会改动的内容：

```
Grep pattern="^## " path="design/art/art-bible.md" output_mode="content" -n
Grep pattern="\[To be designed\]|\[TBD\]|\[To be written\]|^_?TODO" path="design/art/art-bible.md" output_mode="content" -n
```

- 第一个 grep 给出章节标题及其行号——相邻标题之间的间隔即为该章节的大小。
- 第二个 grep 给出占位符标记及其位置。
- 如果某个章节到下一个标题之间有实质距离，且内部没有占位符标记，则其为 **Complete**；若其范围内有标记，则为 **Placeholder**；若相邻标题紧挨着，则为 **Empty**。
- 如果两个 grep 的结果确实让某个章节难以判断，用 `Read(offset, limit)` 读取*该章节的*行范围——绝不要读取整个文件。
- 构建章节状态表：

```
Section | Status
--------|--------
1. Visual Identity Statement | [Complete / Empty / Placeholder]
2. Mood & Atmosphere | ...
3. Shape Language | ...
4. Color System | ...
5. Character Design Direction | ...
6. Environment Design Language | ...
7. UI/HUD Visual Direction | ...
8. Asset Standards | ...
9. Reference Direction | ...
```

- 将此表呈现给用户：
  > “在 `design/art/art-bible.md` 发现了现有的美术圣经。[N] 个章节已完成，[M] 个需要补充内容。我将只处理未完成的章节——现有内容不会被改动。”
- 只处理 Status 为 Empty 或 Placeholder 的章节。不要重新撰写已完成的章节。

如果文件不存在，这是一次全新的撰写会话。第一个获得批准的章节会从 `.claude/docs/templates/art-bible.md` 创建文件，该模板的九个 `## N. Name` 标题正是改造模式所读取的内容——先询问：“我可以基于美术圣经模板创建 `design/art/art-bible.md` 吗？”之后每个获得批准的章节用 `Edit` 替换其自身的 `[To be designed]` 行；保持标题与模板一致。

**章节的批准即代表其写入授权。** 每个章节都通过一次 `AskUserQuestion` 批准，其批准选项为 `[A] Lock this in and write it to design/art/art-bible.md`（第 1 节的完整选项列表见下文）。选择它即表示批准写入该章节；无论全新还是改造，没有它就不会写入任何章节。

提取性能预算与引擎信息以确定资源标准约束：从 `project.yaml` 读取 `performance.*` 和 `engine.name`；对于任何缺失或为空的键（包括 `project.yaml` 没有 `performance` 或 `engine` 块的情况），回退到 `.claude/docs/technical-preferences.md`。

---

## Phase 1: 框定

在撰写任何内容之前，先呈现会话上下文并提出两个问题：

使用 `AskUserQuestion`，包含两个标签页：
- 标签 **“范围”**—— “今天需要撰写哪些章节？”
  选项：`Full bible — all 9 sections` / `Visual identity core (sections 1–4 only)` / `Asset standards only (section 8)` / `Resume — fill in missing sections`

  **将已解析的 `workflow` 层级实际要求的选项标记为（推荐），并说明原因**——该层级已经决定了这一点，用户不应为了回答而必须了解层级表：
  - `full` → **Full bible**——此层级要求全部 9 个章节。
  - `standard` → **Visual identity core (sections 1–4 only)**——当美术圣经确实被要求时，这是文档规定的最低要求。说明：“第 1–4 节是 `standard` 所要求的；如果你需要，5–9 节也可用。”
  - `minimal` → 不需要美术圣经。在提问之前说明这一点，并将第 1–4 节作为“需要时有用”的选项提供，而不是默认 9 节。
  - `workflow_overrides.art_bible_strict: true` → 无论层级如何都选 **Full bible**。

  这是此技能中最大的成本杠杆：每个撰写的章节都会触发一次专家 agent 生成，因此在层级只要求 4 个章节时撰写 9 个，会使运行时间增加一倍以上，而产出物下游没有任何检查。

- 标签 **“参考资料”**—— “你是否有定义视觉方向的参考游戏、电影或美术作品？”
  （自由文本——让用户输入具体名称。此处不要预设选项。）

如果 game-concept.md 有 Visual Identity Anchor 章节，请注明：
> “在 brainstorm 中发现了视觉识别锚点：‘[anchor name] — [one-line rule]’。我将以此作为美术圣经的基础。”

**只撰写所选范围内的章节。** Phase 2–4 只运行该范围内的章节——对于 `Resume`，即改造表中 Empty 和 Placeholder 的行——跳过其他所有章节，以及任何因此没有剩余章节的阶段。Phase 6 会列出本次运行未撰写每个章节的原因。

---

## Phase 2: 视觉识别基础（第 1–4 节）

这四个章节定义了核心视觉语言。**所有其他章节都从它们衍生。** 在进入下一节之前，先撰写每一节并写入文件。

> **本阶段的生成策略。** 第 1 节单独委派——它是基础性的，用户需要在任何其他内容建立其上之前，先在锚点方向之间做出选择。随后第 2–4 节在**一次** `art-director` 调用中委派，而不是三次：它们是同一个 agent 接收相同的输入（视觉识别陈述 + 游戏支柱），并且氛围、形状和色彩相互依赖——美术总监会一起定义它们，而不是孤立定义。分开调用会要求 agent 在不知道它刚刚写下的形状语言的情况下推理色彩。
>
> **这并不是减少专家参与**——每个章节仍由专家撰写，这正是 `.claude/docs/effects-map.md` 关于美术圣经委派必须执行的观点。只是对同样三个章节用一次调用代替三次。逐章节的用户批准和立即写入文件保持不变。

### Section 1: Visual Identity Statement（视觉识别陈述）

**目标**：一条单行视觉规则，外加 2–3 条能解决视觉歧义的支撑原则。

如果 game-concept.md 中存在视觉锚点：呈现它并询问：
- “直接基于此锚点构建？”
- “在扩展之前先修订它？”
- “用新选项重新开始？”

**Agent 委派（强制）**：通过 `Agent` 生成 `art-director`：
- 提供：游戏概念（电梯陈述、核心幻想）、完整的游戏支柱集合、目标平台、Phase 1 框定中的任何参考游戏/美术作品、若存在的视觉锚点
- 询问：“为这款游戏草拟一份视觉识别陈述。提供：(1) 一条能解决任何视觉决策歧义的单行视觉规则；(2) 2–3 条支撑性视觉原则，每条都附带一句话的设计测试（‘当 X 有歧义时，此原则要求选择 Y’）。将所有原则直接锚定在所述游戏支柱上——每条原则都必须服务于某个具体支柱。（若来源是一页式简报，因其没有游戏支柱，则将其锚定在简报的提案和‘他们感受什么’一行上。）”

将 art-director 的草稿呈现给用户。使用 `AskUserQuestion`：
- 选项：`[A] Lock this in and write it to design/art/art-bible.md` / `[B] Revise the one-liner` / `[C] Revise a supporting principle` / `[D] Describe my own direction`

立即将获批准的章节写入文件。

### Section 2: Mood & Atmosphere（氛围与气氛）

**目标**：按游戏状态定义情绪目标——具体到灯光美术师可以直接据此工作。

对于每个主要游戏状态（例如探索、战斗、胜利、失败、菜单——根据本游戏的实际状态调整），定义：
- 主要情绪/氛围目标
- 灯光特征（一天中的时段、色温、对比度水平）
- 气氛描述词（3–5 个形容词）
- 能量水平（狂热 / 节制 / 沉思 / 等等）

**第 2–4 节的 Agent 委派——一次调用，在此处发起。** 使用已锁定的视觉识别陈述和游戏支柱集合，通过 `Agent` 生成 `art-director`，并在同一份简报中要求全部三个章节：

1. **氛围与气氛**—— “为本游戏的每个主要游戏状态定义氛围和气氛目标。要具体——‘黑暗而压抑’并不够。指明确切的情绪目标、灯光特征（暖/冷、高/低对比度、时段方向），以及至少一个承载该氛围的视觉元素。每个游戏状态在视觉上都必须与其他状态有明显区别。”
2. **形状语言**—— “为这款游戏定义形状语言。将每条形状原则与视觉识别陈述以及某个具体的游戏支柱联系起来。解释这些形状选择在情感上向玩家传达了什么。”
3. **色彩系统**—— “为这款游戏设计色彩系统。每个语义颜色分配都必须有解释——为什么这种颜色在这个世界中意味着危险/安全/奖励？找出哪些颜色组合可能会让色盲玩家无法分辨，并说明需要哪些备用提示线索。”

要求这三者**相互一致**——调色板必须服务于氛围目标和形状层级——并以三个分别标注的块返回，以便每个章节都能被单独批准和写入。

然后向用户呈现**第 2 节**，批准它，并在进入第 3 节之前立即写入文件。不要一次性呈现全部三节：批量处理在于委派，而不在于评审。

### Section 3: Shape Language（形状语言）

**目标**：使这款游戏的世界在视觉上连贯且可区分的几何词汇。

涵盖：
- 角色剪影理念（缩略图尺寸下的可读性如何？每个原型的区分特征是什么？）
- 环境几何（棱角/曲线/有机/几何——哪种占主导，为什么？）
- UI 形状语法（UI 是呼应世界美学，还是采用独立的 HUD 语言？）
- 主体形状与辅助形状（什么吸引视线，什么后退？）

**草稿来源**：第 2 节下发起的第 2–4 节委派——使用其返回的形状语言块。不要再次生成。

立即将获批准的章节写入文件。

### Section 4: Color System（色彩系统）

**目标**：一套完整、可生产的调色板系统，同时服务于美学和传达需求。

涵盖：
- 主调色板（5–7 种颜色及其角色——不只是十六进制代码，而是每种颜色在这个世界中的含义）
- 语义颜色用法（红色传达什么？金色？蓝色？白色？建立颜色词汇）
- 按生物群系或区域的色温规则（如果游戏有不同区域）
- UI 调色板（可以与世界调色板不同——请明确说明差异）
- 色盲安全：哪些语义颜色需要形状/图标/声音作为备用线索

**草稿来源**：第 2 节下发起的第 2–4 节委派——使用其返回的色彩系统块。不要再次生成。

立即将获批准的章节写入文件。

---

## Phase 3: 生产指南（第 5–8 节）

这些章节将视觉识别转化为具体的生产规则。它们应当足够具体，使外包团队无需额外简报即可遵循。

### Section 5: Character Design Direction（角色设计方向）

**第 5–6 节的 Agent 委派——一次调用，在此处发起。** 两个章节都需要**相同的 agent 和相同的输入**（`sections 1–4`），因此第二次调用只会重新发送整个视觉识别。用第 1–4 节生成一次 `art-director`，并要求两者：

1. **角色设计方向**—— “涵盖：玩家角色（如果有）的视觉原型、每种角色类型的区分特征规则（玩家如何在游戏镜头距离下一眼区分敌人/非玩家角色（NPC）/盟友？）、表情/姿态风格目标（僵硬/富有表现力/写实/夸张），以及 LOD 理念（在游戏相机距离下保留多少细节？）。”
2. **环境设计语言**—— “涵盖：建筑风格及其与世界文化/历史的关系、纹理理念（手绘 vs. PBR vs. 风格化——为什么为这款游戏做此选择？）、道具密度规则（稀疏/密集——每种区域类型的依据是什么？），以及环境叙事准则（哪些视觉细节应在没有文字的情况下讲述故事？）。”

要求角色与环境彼此**可辨识**——角色剪影必须能在同一份简报定义的环境纹理密度背景下清晰读出。返回两个分别标注的块。

先呈现**第 5 节**，批准、写入文件，然后第 6 节。

### Section 6: Environment Design Language（环境设计语言）

**草稿来源**：第 5 节下发起的第 5–6 节委派——使用其返回的环境块。不要再次生成。

将获批准的章节写入文件。

### Section 7: UI/HUD Visual Direction（UI/HUD 视觉方向）

**Agent 委派**：并行生成：
- **`art-director`**：UI 的视觉风格——叙事内（diegetic）vs. 屏幕空间 HUD、字体方向（字体个性、字重、大小层级）、图标风格（扁平/描边/插画/照片写实）、UI 元素的动画手感
- **`ux-designer`**：UX 一致性检查——视觉方向是否支持本游戏所需的交互模式？标记美术方向与可读性/无障碍需求之间的任何冲突。

收集两者。如果它们冲突（例如，art-director 想要精致的叙事内 UI，但 ux-designer 指出这会降低战斗可读性），请明确呈现冲突及双方立场。**不要**静默解决——使用 `AskUserQuestion` 让用户决定。

将获批准的章节写入文件。

### Section 8: Asset Standards（资源标准）

**Agent 委派**：并行生成：
- **`art-director`**：文件格式偏好、命名规范方向、纹理分辨率层级、LOD 级别预期、导出设置理念
- **`technical-artist`**：引擎特定的硬性约束——每种资源类别的多边形预算、纹理内存限制、材质槽数量、导入器约束、来自性能预算的任何内容（`project.yaml` 中的 `performance.*`，回退到 `.claude/docs/technical-preferences.md`）

如果任何美术偏好与技术约束冲突（例如，art-director 想要 4K 纹理，但性能预算要求移动端使用 2K），请明确呈现冲突及双方立场——理想标准和受约束标准，以及取舍。**不要**静默解决——使用 `AskUserQuestion` 让用户选择（选项：理想标准、受约束标准，或两者都记录并由逐个资源判断）。资源标准中的模糊性正是生产成本滋生的地方。

将获批准的章节写入文件。

---

## Phase 4: Reference Direction（参考资料方向，第 9 节）

**目标**：一套精心策划的参考资料集，明确每个来源要借鉴什么、要避免什么。

**Agent 委派**：使用已完成的第 1–8 节通过 `Agent` 生成 `art-director`。询问：“为本游戏编制一份参考资料方向。提供 3–5 个参考来源（游戏、电影、艺术风格或具体艺术家）。对每一个：命名它，明确说明要从中借鉴的具体视觉元素（不是‘整体美学’——而是具体技术、颜色选择或构图规则），并明确说明要避免或背离的内容（以防止出现‘试图复制 X’的观感）。参考资料应当是互补的——不应有两个参考指向完全相同的方向。”

将获批准的章节写入文件。

---

## Phase 5: 美术总监签核

**评审模式检查**——在生成 AD-ART-BIBLE 之前应用：
- `solo` → 跳过。注明：“AD-ART-BIBLE skipped — Solo mode.” 然后记录跳过（见下文）并进入 Phase 6。
- `lean` → 跳过（不是 PHASE-GATE）。注明：“AD-ART-BIBLE skipped — Lean mode.” 然后记录跳过（见下文）并进入 Phase 6。
- `full` → 照常生成。

在任一跳过情况下，询问“我可以把跳过的签核记录在 `design/art/art-bible.md` 的头部吗？”，若同意，则将头部的 `> **Art Director Sign-Off (AD-ART-BIBLE)**: [Not yet reviewed]` 替换为 `> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED [date] — [solo|lean] mode` ——质量闸门接受任一形式作为已记录的签核。

所有章节完成后（或 Phase 1 确定的范围集合完成后），使用质量闸门 **AD-ART-BIBLE**（`.claude/docs/director-gates/ad-art-bible.md`）通过 `Agent` 生成 `art-director`。

传入：美术圣经路径（`design/art/art-bible.md`）；游戏支柱与核心幻想；平台与性能约束（`project.yaml` 中的 `platform.*` 和 `performance.*`，回退到 `.claude/docs/technical-preferences.md`）；以及视觉识别锚点。如果 Phase 0 读取的是一页式简报，则将其提案和“他们感受什么”一行作为游戏支柱与幻想传入，并将其“美术与音频方向”一行作为锚点传入。

按 `director-gates.md` 中的标准规则处理结论。
在 `Revise flagged items` 时，或为处理 REJECT，该章节自己的专家——`art-director`，第 7 节加上 `ux-designer`，第 8 节加上 `technical-artist`——会重新草拟每个被标记的章节，随后像任何其他章节一样呈现、批准和写入，然后记录 `REVISED [date]`。
`NOT ASSESSED` 的答复绝不是批准：指出缺失的输入，然后补充该输入并重新运行闸门，或记录 `NOT ASSESSED`。
将结论记录在美术圣经的状态头部：
`> **Art Director Sign-Off (AD-ART-BIBLE)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]`

---

## Phase 6: 收尾

首先，列出本次运行未撰写的九个章节及原因——不在所选范围内，或已经完成——例如：*“本次运行未撰写：第 5–9 节（不在所选范围内；`standard` 要求 1–4 节）。”* 一个在第 4 节之后停止的运行，绝不能读起来像一本已完成的美术圣经。

在呈现下一步之前，检查项目状态：
- `design/gdd/systems-index.md` 是否存在？→ map-systems 已完成，跳过该选项
- 是否已配置引擎——`project.yaml` 中存在 `engine.name`，或 `.claude/docs/technical-preferences.md` 中有已配置的 Engine 字段（不是 `[TO BE CONFIGURED]`）？→ setup-engine 已完成，跳过该选项
- `design/gdd/` 中是否包含任何 `*.md` 文件？→ design-system 已运行过，跳过该选项
- `design/gdd/gdd-cross-review-*.md` 是否存在？→ review-all-gdds 已完成
- GDD 是否存在（见上方检查）？→ 包含 /consistency-check 选项

使用 `AskUserQuestion` 询问下一步。只包含根据上述状态检查确实合理的选项：

在 `workflow: minimal` 下，选项池为 `/create-stories`（尚无用户故事）或 `/dev-story [next story]`，再加上“在此停止”——下方的 GDD/架构选项池仅适用于 `standard`/`full`。

**选项池——仅在尚未完成时包含：**
- `[_] Run /map-systems — decompose the concept into systems before writing GDDs`（若 systems-index.md 存在则跳过）
- `[_] Run /setup-engine — configure the engine (asset standards may need revisiting after engine is set)`（若引擎已配置则跳过）
- `[_] Run /design-system — start the first GDD`（若已有任何 GDD 则跳过）
- `[_] Run /review-all-gdds — cross-GDD consistency check (required before Technical Setup gate)`（若 gdd-cross-review-*.md 存在则跳过）
- `[_] Run /asset-spec — generate per-asset visual specs and AI generation prompts from approved GDDs`（若存在 GDD 则包含）
- `[_] Run /consistency-check — scan existing GDDs against the art bible for visual direction conflicts`（若存在 GDD 则包含）
- `[_] Run /create-architecture — author the master architecture document (next Technical Setup step)`
- `[_] Stop here`

只为实际包含的选项分配字母 A、B、C…… 将最合乎逻辑、能推进流水线的选项标记为 `(recommended)`。

> **始终包含**（仅 `standard`/`full`）`/create-architecture` 和“在此停止”作为选项——这些在美术圣经完成后始终是有效的下一步。

---

## 协作协议

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 和 `autonomous` 模式，请参阅 `.claude/docs/automation-modes.md`——下文规则描述的是 collaborative 模式的要求，而非通用行为。

每个章节都遵循：**提问 → 选项 → 决定 → 草稿（来自 art-director agent）→ 批准 → 写入文件**

- 绝不自己草拟章节——每个章节的内容都来自相关专家。一次委派可以覆盖多个章节（第 2–4 节共用一次调用，第 5–6 节同理），但任何章节都不得由编排者依据自身判断写入，而非来自 agent。
- 每个章节在批准后立即写入文件——不要批量处理**写入或批准**。批量仅适用于委派调用；用户仍然逐章节查看、批准和确认。
- 将所有 agent 分歧呈现给用户——绝不在 art-director 与 technical-artist 之间静默解决冲突
- 美术圣经是一份约束性文档：它以视觉一致性为交换，限制未来的决策。每个章节都应让人感觉它有效地收窄了解空间。

---

## 推荐的后续步骤

美术圣经获批后：
- 运行 `/map-systems` 在撰写 GDD 之前将概念拆解为游戏系统
- 若引擎尚未配置，运行 `/setup-engine`（引擎选定后资源标准可能需要重新审视）
- 运行 `/design-system [first-system]` 开始撰写各系统的 GDD
- GDD 存在后运行 `/consistency-check`，以对照美术圣经的视觉规则进行验证
- 运行 `/create-architecture` 生成主架构文档
