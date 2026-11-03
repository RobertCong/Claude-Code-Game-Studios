---
name: asset-spec
description: "基于 GDD 和角色档案生成逐资源的视觉规格以及 AI 生成提示词。请在美术圣经之后进行。"
argument-hint: "[system:<name> | level:<name> | character:<name>] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/asset-spec/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation`

# Asset Spec（资源规格）



如果没有提供参数，检查 `design/assets/entity-inventory.md` 是否存在：
- 如果存在：读取它，找到第一个状态为 “Needed” 但尚无规格文件的实体或界面，并使用 `AskUserQuestion`：
  - 提示：“下一个尚未制作规格的项目是 **[name]**。要为它生成规格吗？”
  - 选项：`[A] Yes — spec [name]` / `[B] Pick a different item` / `[C] Stop here`
- 如果没有实体清单：检查 `design/assets/asset-manifest.md`。如果清单存在，流程相同，但改为从清单读取。
- 如果两者都不存在：**启动实体与界面清单流程**（下方 Phase 0b），而不是报错失败。

---

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`（collaborative 总是询问 · guided 仅询问重大决策 · autonomous 记录并继续；`automation_always_ask` 类别始终提示）。**注意**：实际调用外部图像生成器（调用图像 API）无论 `modes.automation` 如何都会提示——这是不可逆的外部操作，会被无条件拦截，与 `external_calls` 是否列在 `automation_always_ask` 中无关。（目前此技能只输出生成提示词的*文本*；若将来接入实时生成，该防护仍然适用。）

## Phase 0b: 实体与界面清单（在无参数且无现有清单时运行）

此流程生成 `design/assets/entity-inventory.md`——即游戏在视觉上所需一切的主列表。在资源规格工作开始前运行一次。

### Step 1 — 从文档收集
并行读取所有可用的源材料，每个文档按章节读取：用 Grep 工具查找所需标题（模式 `^#`，content 模式），再用 offset 和 limit 读取对应范围。
- `design/gdd/systems-index.md`——提取其中列出的每个系统
- GDD 资源内容——**不要**完整读取每个 GDD。需要的两个章节是标准标题，命名实体则存放在注册表中：
  ```
  Grep pattern="## (Visual/Audio Requirements|UI Requirements)" glob="design/gdd/*.md" output_mode="content" -A 25
  ```
  对于命名实体（角色、敌人、建筑、物品），如果 `design/registry/entities.yaml` 存在且有条目，则读取它（`entities`/`items`）；否则在 GDD 中 grep 命名内容。仅当某个 GDD 的 Visual/Audio 章节缺失或写着 `[To be designed]` 时，才完整读取该 GDD（Phase 1 已处理该情况）。VFX 事件会出现在 Visual/Audio 的 grep 上下文中。
- `design/art/art-bible.md`——提取：任何命名的视觉类别、资源类型预期
- `design/narrative/`——若存在角色或世界实体文档则扫描（可选——非必需）

### Step 2 — 构建提议清单
将找到的所有内容按类别组织：

```
Characters / Protagonists
Enemies / Creatures
Buildings / Structures
Environment / Terrain
Items / Props
VFX / Particles
UI Screens (list each screen by name)
HUD Elements
Audio (SFX, music — descriptions only, no generation prompts)
Other
```

对于每个项目，注明其来源文档。

### Step 3 — 呈现并协作
在对话中向用户呈现完整的提议清单。然后使用 `AskUserQuestion`：
- 提示：“我在你的 GDD 和美术圣经中发现了 **[N] 个视觉实体和 [N] 个 UI 界面**。请审阅列表——有什么遗漏、什么不需要？”
- 选项：
  - `[A] Looks good — save this inventory`
  - `[B] Add items I'll describe`
  - `[C] Remove items that don't apply`
  - `[D] Both add and remove — let me edit`

如果选择 [B] 或 [D]：请用户描述额外项目。接受简短描述（“一座中世纪城堡主楼，用作关卡背景”）或详细描述——两者都可以。与用户协作处理，直到其满意。

如果选择 [C] 或 [D]：询问要移除哪些项目及原因。将它们从列表中移除。

### Step 4 — 写入清单
用户批准后，询问：“我可以将实体清单写入 `design/assets/entity-inventory.md` 吗？”

写入文件：

```markdown
# Visual Entity & Screen Inventory

> Generated: [date]
> Sources: [list of source docs read]

## Entities

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 1 | [name] | Character / Enemy / Building / Environment / Item / Other | [brief description] | [source doc] | Needed |

## UI Screens

| # | Screen Name | Description | Source | Status |
|---|-------------|-------------|--------|--------|
| 1 | Main Menu | [description] | [source] | Needed |

## HUD Elements

| # | Element | Description | Source | Status |
|---|---------|-------------|--------|--------|

## Audio

| # | Name | Type (SFX / Music / Ambient) | Description | Source | Status |
|---|------|------------------------------|-------------|--------|--------|
```

写入后，告诉用户：
> “实体清单已保存。后续步骤：
> - 对清单中的每个 UI 界面运行 `/ux-design [screen name]`
> - 对每个视觉实体运行 `/asset-spec system:[name]`、`level:[name]` 或 `character:[name]`——选择该实体所属的三种类型之一
> - 或再次运行 `/asset-spec`，逐个处理清单中的项目”

---

## Phase 0: 解析参数

提取：
- **目标类型**：`system`、`level` 或 `character`
- **目标名称**：冒号后的名称（规范化为 kebab-case）
- **评审模式**：`--review [full|lean|solo]`（若存在）

生效模式是此技能顶部通过 `resolve_config --keys review_mode` 已解析出的模式，它应用完整链条；在未设置任何值时，它遵循 `modes.rigor`——`minimal` 下为 `solo`（默认）、`standard` 下为 `lean`、`full` 下为 `full`。`--review` 参数仅覆盖本次运行。

**模式行为：**
- `full`：并行生成 `art-director` 和 `technical-artist`
- `lean`：仅生成 `art-director`——更快，跳过技术约束检查
- `solo`：不生成任何 agent——主会话仅依据美术圣经规则编写规格。适用于简单资源类别，或速度比深度更重要时。

---

## Phase 1: 收集上下文

在向用户提出任何问题**之前**，读取所有源材料。按章节读取美术圣经和 GDD：用 Grep 工具查找所需标题（模式 `^#`，content 模式），再用 offset 和 limit 读取对应范围。

### 必读内容：
- **美术圣经**：读取 `design/art/art-bible.md`——缺失则失败：
  > “未找到美术圣经。请先运行 `/art-bible`——资源规格锚定在美术圣经的视觉规则和资源标准上。”

  **例外——minimal 路径。** 如果没有美术圣经，但存在 `design/game-brief.md`（在 `rigor: minimal` 下不需要美术圣经），则不要失败：将规格锚定在简报的 **Art & audio direction** 一行，并在输出顶部说明——“锚定于简报的单行美术方向；此处没有美术圣经，因此下文的颜色、形状和资源标准规则是提议，而非约束。” 可选地提供一次 `/art-bible`。
  写入的规格遵循相同的锚点：其头部使用 `> **Art direction**: design/game-brief.md (Art & audio direction) — no art bible` 代替 `> **Art Bible**:` 行，每个资源使用 `**Brief anchor:** [the brief line applied]` 代替 **Art Bible Anchors** 块，且任何规格都不引用 Art Bible 章节或 §8 层级。
  提取：视觉识别陈述、色彩系统（语义颜色）、形状语言、资源标准（美术圣经第 8 节——尺寸、格式、多边形预算、纹理分辨率层级）。

- **项目配置**：从 `project.yaml` 读取 `performance.*` 和 `naming.*`；对于任何缺失或为空的键（包括 `project.yaml` 没有 `performance` 或 `naming` 块的情况），回退到 `.claude/docs/technical-preferences.md`。提取性能预算和命名规范。

### 源文档读取（按目标类型）：
- **system**：读取 `design/gdd/[target-name].md`。提取 **Visual/Audio Requirements** 章节。如果该章节不存在或写着 `[To be designed]`：
  > “`design/gdd/[target-name].md` 的 Visual/Audio 章节为空。可以运行 `/design-system [target-name]` 补全 GDD，或手动描述视觉需求。”
  使用 `AskUserQuestion`：`[A] Describe needs manually` / `[B] Stop — complete the GDD first`
- **level**：读取 `design/levels/[target-name].md`。提取美术需求、资源列表、VFX 需求，以及 Step 4 中 art-director 的生产概念规格。
- **character** 或 **entity**：读取 `design/narrative/characters/[target-name].md`，或在 `design/narrative/` 和 `design/assets/entity-inventory.md` 中搜索匹配条目。提取视觉描述、角色定位以及任何指定的区分特征。
  - **如果不存在源文档**：不要失败。而是使用 `AskUserQuestion`：
    - 提示：“未找到 **[name]** 的档案。请简要描述它——一两句话就够。”
    - 选项：`[A] Describe it now` / `[B] Skip this entity` / `[C] Stop here`
    - 如果选择 [A]：用户的描述即成为源文档。简短的回答会产生简洁的规格；详细的回答会产生详细的规格。接受用户提供的任何详细程度并据此工作。

### 可选读取：
- **此目标的现有规格**：如果 `design/assets/specs/[target-name]-assets.md` 存在，读取它——这是一次重新运行，Phase 2 只提议自那以后新增或变更的内容（Phase 5 会就地更新文件）。
- **现有清单**：若存在 `design/assets/asset-manifest.md` 则读取——提取此目标已制作规格的资源，以避免重复。
- **相关规格**：Glob `design/assets/specs/*.md`——扫描可能共享的资源（例如，为某个系统制作规格的通用 UI 元素也可能适用于此处）。

### 呈现上下文摘要：
> **Asset Spec: [Target Type] — [Target Name]**
> - Source doc: [path] — [N] asset types identified
> - Art bible: found — Asset Standards at Section 8
> - Existing specs for this target: [N already specced / none]
> - Shared assets found in other specs: [list or "none"]

---

## Phase 2: 资源识别

从源文档中提取提到的每种资源类型——包括明确的和隐含的。

**对于系统**：查找 VFX 事件、精灵引用、UI 元素、音频触发、粒子效果、图标需求，以及任何“视觉反馈”措辞。

**对于关卡**：查找独特的环境道具、气氛 VFX、灯光设置、环境音频、天空盒/背景，以及任何区域特定材质。

**对于角色**：查找精灵表（待机、行走、攻击、死亡）、肖像/头像、附加在技能上的 VFX、UI 表现（图标、生命条皮肤）。

将资源分组到类别中：
- **Sprite / 2D Art**——角色精灵、UI 图标、图块表
- **VFX / Particles**——命中效果、环境粒子、屏幕效果
- **Environment**——道具、图块、背景、天空盒
- **UI**——HUD 元素、菜单美术、字体（若为自定义）
- **Audio**——SFX、音乐曲目、环境循环 *(注意：音频规格仅为描述——不含生成提示词)*
- **3D Assets**——网格、材质（若引擎适用）

向用户呈现完整的已识别列表。使用 `AskUserQuestion`：
- 提示：“我为 **[target]** 识别出 [N] 个类别下的 [N] 个资源。请在制作规格前审阅：”
- 先在对话文本中展示分组列表
- 选项：`[A] Proceed — spec all of these` / `[B] Remove some assets` / `[C] Add assets I didn't catch` / `[D] Adjust categories`

在用户确认资源列表之前，不要进入 Phase 3。

---

## Phase 3: 规格生成

根据评审模式生成专家 agent。**同时发起所有 `Agent` 调用——不要等一个完成再开始下一个。**

### Full 模式——并行生成：

**`art-director`** 通过 `Agent`：
- 提供：Phase 2 的完整资源列表、美术圣经的视觉识别陈述、色彩系统、形状语言、源文档的视觉需求，以及美术圣经第 9 节中提到的任何参考游戏/美术作品
- 询问：“为此列表中的每个资源产出：(1) 一段 2–3 句的视觉描述，锚定在美术圣经的形状语言和色彩系统上——具体到两个不同的美术师会产出一致的结果；(2) 可直接用于 AI 图像工具的生成提示词（Midjourney/Stable Diffusion 风格——包含风格关键词、构图、调色板锚点、负面提示词）；(3) 哪些美术圣经规则直接支配该资源（按章节引用）。对于音频资源，描述声音特征而非生成提示词。”

**`technical-artist`** 通过 `Agent`：
- 提供：完整资源列表、美术圣经资源标准（第 8 节）、性能预算（`project.yaml` 中的 `performance.*`，否则 `technical-preferences.md`）、引擎名称与版本
- 询问：“为此列表中的每个资源指定：(1) 确切尺寸或多边形数量（与美术圣经资源标准层级匹配——不要发明新的尺寸）；(2) 文件格式和导出设置；(3) 命名规范（`project.yaml` 中的 `naming.*`，否则 `technical-preferences.md`）；(4) 该资源类型必须遵守的任何引擎特定约束；(5) 若适用，LOD 要求。标记任何美术圣经首选标准与引擎约束冲突的资源类型。”

### Lean 模式——仅生成 art-director（跳过 technical-artist）。

### Solo 模式——两者都跳过。仅依据美术圣经规则推导规格，并注明技术约束未经校验。

**在输出中、规格之前，按名称公布每个被跳过的 agent**：
“technical-artist skipped — Lean mode: technical constraints not validated.” /
“art-director and technical-artist skipped — Solo mode: specs derived in this
session; technical constraints not validated.” 未经 agent 草拟的规格，绝不能读起来像经过 agent 评审。

**在进入 Phase 4 之前收集两个响应。** 如果 art-director 与 technical-artist 之间存在任何冲突（例如，art-director 指定 4K 纹理，但 technical-artist 指出引擎预算要求 512px），请明确呈现——**不要**静默解决。

---

## Phase 4: 汇总与评审

将 agent 输出合并为每个资源的草稿规格。使用以下格式在对话文本中呈现所有规格：

```
## ASSET-[NNN] — [Asset Name]

| Field | Value |
|-------|-------|
| Category | [Sprite / VFX / Environment / UI / Audio / 3D] |
| Dimensions | [e.g. 256×256px, 4-frame sprite sheet] |
| Format | [PNG / SVG / WAV / etc.] |
| Naming | [e.g. vfx_frost_hit_01.png] |
| Polycount | [if 3D — e.g. <800 tris] |
| Texture Res | [e.g. 512px — matches Art Bible §8 Tier 2] |

**Visual Description:**
[2–3 sentences. Specific enough for two artists to produce consistent results.]

**Art Bible Anchors:**
- §3 Shape Language: [relevant rule applied]
- §4 Color System: [color role — e.g. "uses Threat Blue per semantic color rules"]

**Generation Prompt:**
[Ready-to-use prompt. Include: style keywords, composition notes, color palette anchors, lighting direction, negative prompts.]

**Status:** Needed
```

呈现所有规格后，使用 `AskUserQuestion`：
- 提示：“**[target]** 的资源规格——[N] 个资源。审阅完成了吗？”
- 选项：`[A] Approve all — write to file` / `[B] Revise a specific asset` / `[C] Regenerate with different direction`

如果选择 [B]：询问要修改哪个资源以及改什么。就地修改并重新呈现。**不要**为轻微的文字修改重新生成 agent——仅在视觉方向本身需要改变时才重新生成。

如果选择 [C]：询问要改变什么方向。用更新后的简报重新生成相关 agent。

---

## Phase 5: 写入规格文件

批准后，询问：“我可以将规格写入 `design/assets/specs/[target-name]-assets.md` 吗？”

**如果该文件已存在**（对同一目标的重新运行），就地更新——绝不要整体覆盖。保留现有的 `ASSET-NNN` 块和 ID，只应用用户批准的更改，并以全项目下一个 ID 追加新资源。展示更改内容，然后询问“我可以更新 `design/assets/specs/[target-name]-assets.md` 吗？”，而不是“我可以写入吗”。

将文件写为：

```markdown
# Asset Specs — [Target Type]: [Target Name]

> **Source**: [path to source GDD/level/character doc]
> **Art Bible**: design/art/art-bible.md
> **Generated**: [date]
> **Status**: [N] assets specced / [N] approved / [N] in production / [N] done

[all asset specs in ASSET-NNN format]
```

然后更新 `design/assets/asset-manifest.md`。如果它不存在，则创建它：

```markdown
# Asset Manifest

> Last updated: [date]

## Progress Summary

| Total | Needed | In Progress | Done | Approved |
|-------|--------|-------------|------|----------|
| [N] | [N] | [N] | [N] | [N] |

## Assets by Context

### [Target Type]: [Target Name]
| Asset ID | Name | Category | Status | Spec File |
|----------|------|----------|--------|-----------|
| ASSET-001 | [name] | [category] | Needed | design/assets/specs/[target]-assets.md |
```

如果清单已存在，则追加新的上下文块——对同一目标的重新运行时，将新行添加到其现有块中，而不是追加第二个块——并更新 Progress Summary 的计数。

询问：“我可以更新 `design/assets/asset-manifest.md` 吗？”

---

## Phase 6: 收尾

使用 `AskUserQuestion`：
- 提示：“**[target]** 的资源规格已完成。接下来做什么？”
- 选项：
  - `[A] Spec another system — /asset-spec system:[next-system]`
  - `[B] Spec a level — /asset-spec level:[level-name]`
  - `[C] Spec a character — /asset-spec character:[character-name]`
  - `[D] Run /asset-audit — validate delivered assets against specs`
  - `[E] Stop here`

---

## 资源 ID 分配

资源 ID 在整个项目中按顺序分配——而不是按上下文。分配 ID 之前先读取清单，找到当前最高的编号：

```
Grep pattern="ASSET-" path="design/assets/asset-manifest.md"
```

从 `ASSET-[highest + 1]` 开始分配新资源。这确保 ID 在整个项目中稳定且唯一。

如果尚无清单，则从 `ASSET-001` 开始。

---

## 共享资源协议

在制作资源规格之前，检查其他上下文的规格中是否已存在等价资源：

- 通用 UI 元素（生命条、分数显示）通常跨系统共享
- 通用环境道具可能出现在多个关卡中
- 角色 VFX（命中火花、死亡效果）可以复用基础规格并做颜色变体

如果找到匹配项：引用现有的 ASSET-ID，而不是创建重复项。在清单的 referenced-by 列中注明共享用法。

> “ASSET-012 (Generic Hit Spark) 已为 Combat 系统制作规格。正在为 Tower Defense 复用——将 tower-defense 添加到 referenced-by。”

---

## 错误恢复协议

如果任何生成的 agent 返回 BLOCKED 或无法完成：

1. 立即呈现：“[AgentName]: BLOCKED — [reason]”
2. 在 `lean` 模式下，或如果 `technical-artist` 阻塞：仅使用 art-director 的输出继续——注明技术约束未经校验
3. 在 `solo` 模式下，或如果 `art-director` 阻塞：依据美术圣经规则推导描述——标记为“Art director not consulted — verify against art bible before production”
4. 始终产出部分规格——绝不要因为一个 agent 阻塞而丢弃工作

---

## 协作协议

**适用于 `collaborative` 模式（默认）。** 对于 `guided` 和 `autonomous` 模式，请参阅 `.claude/docs/automation-modes.md`——下文规则描述的是 collaborative 模式的要求，而非通用行为。

每个阶段都遵循：**识别 → 确认 → 生成 → 评审 → 批准 → 写入**

- 在首先与用户确认资源列表之前，绝不制作资源规格
- 始终将规格锚定在美术圣经上——与美术圣经相矛盾的规格是错误的
- 呈现所有 agent 分歧——不要静默选择其中一个
- 仅在明确批准后才写入规格文件
- 写入规格后立即更新清单

---

## 推荐的后续步骤

- 运行 `/asset-spec [next-context]` 继续为其余系统、关卡或角色制作规格
- 运行 `/asset-audit` 对照已写入的规格验证已交付的资源，并找出差距或不匹配
