---
name: localize
description: "本地化流水线 — 查找硬编码字符串、提取字符串表、文化审查、VO、RTL、执行字符串冻结。"
argument-hint: "[scan|extract|validate|status|brief|cultural-review|vo-pipeline|rtl-check|freeze|qa]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`



# 本地化流水线

本地化不仅仅是翻译——它是让游戏在每种语言和地区都显得自然的完整过程。糟糕的本地化会破坏沉浸感、让玩家困惑，并阻碍平台认证。本技能涵盖从字符串提取、文化审查、VO 录制、RTL 布局测试到本地化 QA 签字的完整流水线。

**模式：**
- `scan` — 查找硬编码字符串和本地化反模式（只读）
- `extract` — 提取字符串并生成可供翻译的表格
- `validate` — 检查翻译的完整性、占位符和长度
- `status` — 所有语言地区的覆盖率矩阵
- `brief` — 为外部团队生成译者上下文简报文档
- `cultural-review` — 标记文化敏感内容、符号、颜色和习语
- `vo-pipeline` — 管理配音本地化：脚本、录制规格、集成
- `rtl-check` — 校验 RTL 语言布局、镜像和字体支持
- `freeze` — 执行字符串冻结；在翻译开始前锁定源字符串
- `qa` — 在发布前运行完整的本地化 QA 循环

如果未提供子命令，输出用法并停止。结论（Verdict）：**FAIL** — 缺少必需的子命令。

---

每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大问题 · autonomous 记录日志后继续；
`automation_always_ask` 类别总是提示）。

## Phase 2A: 扫描模式

在**代码根目录**（按 `.trae/docs/code-root-resolution.md` 解析）中搜索硬编码的面向用户的字符串。**如果代码根目录无法解析，报告 `NOT ASSESSED — code root unresolved`，而不是零命中。** 从无法解析的根目录得出零命中会被读作“没有需要本地化的内容”，而这正是本检查要防范的失败情形：

- 用户界面（UI）代码中未包裹在本地化函数（`tr()`、`Tr()`、`NSLocalizedString`、`GetText` 等）中的字符串字面量
- 本应参数化的拼接字符串
- 使用位置占位符（`%s`、`%d`）而非具名占位符（`{playerName}`）的字符串
- 混合了语言环境敏感数据（数字、日期、货币）却未使用语言环境感知格式化的格式字符串

搜索本地化反模式：

- 未使用语言环境感知函数的日期/时间格式化
- 未考虑语言环境的数字格式化（`1,000` 与 `1.000`）
- 嵌入图像或纹理中的文本（标记 `assets/` 中相关的资源文件）
- 假定从左到右文本方向的字符串（位置布局、字符串拼接顺序）
- 固化在字符串逻辑中的性别/复数假设（必须使用复数形式或性别标记）
- 硬编码标点（例如 `"You won!"`——感叹号风格因语言地区而异）

报告所有发现，附上文件路径和行号。此模式为只读——不会写入任何文件。

---

## Phase 2B: 提取模式

- 扫描所有源文件中的本地化字符串引用
- 与 `assets/data/strings/` 中现有的字符串表比对
- 为尚未建键的字符串生成新条目
- 按如下约定建议键名：`[category].[subcategory].[description]`
  - 示例：`ui.hud.health_label`、`dialogue.npc.merchant.greeting`、`menu.main.play_button`
- 每个新条目都必须包含一个 `context` 字段——一条译者注释，说明：
  - 它出现在哪里（哪个屏幕、哪个场景）
  - 最大字符长度
  - 任何占位符的含义（`{playerName}` = 玩家选择的显示名称）
  - 如适用，说明性别/复数上下文

输出要添加到字符串表的新字符串差异（diff）。

将差异呈现给用户。询问：“我可以把这些新条目写入 `assets/data/strings/strings-en.json` 吗？”

如果同意，只写入差异（新条目），而不是完整替换。结论（Verdict）：**COMPLETE** — 字符串已提取并写入。

---

## Phase 2C: 校验模式

读取 `assets/data/strings/` 中的所有字符串表文件。对每个语言地区，检查：

- **完整性** — 键存在于源（en）中，但该语言地区没有翻译
- **占位符不匹配** — 源中有 `{name}`，但翻译遗漏了它或额外添加了占位符
- **字符串长度违规** — 翻译超出源 `context` 字段中记录的字符限制
- **复数形式数量** — 语言地区要求 N 种复数形式，而翻译提供得更少
- **孤立键** — 翻译存在，但代码根目录中没有任何地方引用该键
- **过时翻译** — 翻译写入后源字符串发生了变更（标记为需重新翻译）
- **编码** — 存在非 ASCII 字符，且字体图集支持它们（不确定时标记）

按语言地区和严重程度分组报告校验结果。此模式为只读——不会写入任何文件。

---

## Phase 2D: 状态模式

- 统计源表中的可本地化字符串总数
- 按语言地区统计：已翻译、未翻译、过时（翻译后源发生变更）
- 生成覆盖率矩阵：

```markdown
## Localization Status
Generated: [Date]
String freeze: [Active / Not yet called / Lifted]

| Locale | Total | Translated | Missing | Stale | Coverage |
|--------|-------|-----------|---------|-------|----------|
| en (source) | [N] | [N] | [N] | [N] | [N]% |
| [locale] | [N] | [N] | [N] | [N] | [X]% |

> **Every cell above is a count you must take from the string table — including
> the source row.** Do not pre-fill the source locale as `100%`: that asserts a
> result before counting, and on a project with no `assets/data/strings/` it
> produces a coverage report for a table that does not exist. If the string table
> is absent, the whole status output is
> **`NOT ASSESSED — no string table found`**, not a matrix of zeros with a
> confident source row.

### Issues
- [N] hardcoded strings found in source code (run /localize scan)
- [N] strings exceeding character limits
- [N] placeholder mismatches
- [N] orphaned keys
- [N] strings added after freeze was called (freeze violations)
```

此模式为只读——不会写入任何文件。

---

## Phase 2E: 简报模式

生成一份译者上下文简报文档。该文档与字符串表导出一起发送给外部翻译团队或本地化供应商。

读取：
- `design/gdd/` — 提取游戏类型、基调、设定、角色名称。按章节阅读
  GDD：用 Grep 工具（pattern `^#`，content 模式）找到所需标题，
  再用 offset 和 limit 读取相应范围。
- `assets/data/strings/strings-en.json` — 源字符串表
- `design/narrative/` 中任何现有的世界观或叙事文档

生成 `production/localization/translator-brief-[locale]-[date].md`：

```markdown
# Translator Brief — [Game Name] — [Locale]

## Game Overview
[2-3 paragraph summary of the game, genre, tone, and audience]

## Tone and Voice
- **Overall tone**: [e.g., "Darkly comic, not slapstick — think Terry Pratchett, not Looney Tunes"]
- **Player address**: [e.g., "Second person, informal. Never formal 'vous' — always 'tu' for French"]
- **Profanity policy**: [e.g., "Mild — PG-13 equivalent. Match intensity to source, do not soften or escalate"]
- **Humour**: [e.g., "Wordplay exists — if a pun cannot translate, invent an equivalent local joke; do not translate literally"]

## Character Glossary
| Name | Role | Personality | Notes |
|------|------|-------------|-------|
| [Name] | [Role] | [Personality] | [Do not translate / transliterate as X] |

## World Glossary
| Term | Meaning | Notes |
|------|---------|-------|
| [Term] | [What it means] | [Keep in English / translate as X] |

## Do Not Translate List
The following must appear verbatim in all locales:
- [Game name]
- [UI terms that match in-engine labels]
- [Brand or trademark names]

## Placeholder Reference
| Placeholder | What it represents | Example |
|-------------|-------------------|---------|
| `{playerName}` | Player's chosen display name | "Shadowblade" |
| `{count}` | Integer quantity | "3" |

## Character Limits
Tight UI fields with hard limits are marked in the string table `context` field.
Where no limit is stated, target ±30% of the English length as a guideline.

## Contact
Direct questions to: [placeholder for user/team contact]
Delivery format: JSON, same schema as strings-en.json
```

询问：“我可以把这份译者简报写入 `production/localization/translator-brief-[locale]-[date].md` 吗？”

---

## Phase 2F: 文化审查模式

通过 `Agent` 派出 `localization-lead`。要求他们在目标语言地区范围内审查以下内容的文化敏感性（从 `assets/data/strings/` 和 `assets/` 读取）：

### 需要审查的内容领域

**符号和手势**
- 竖大拇指、OK 手势、V 字手势——含义因地区而异
- 美术、用户界面（UI）或音频中的宗教或精神符号
- 国旗、地图表示、争议领土

**颜色**
- 白色（在某些亚洲文化中表示哀悼）、绿色（在某些地区有政治联想）、红色（幸运与危险）
- 与当地文化联想冲突的警报/警告颜色

**数字**
- 4（在日语/中文中代表死亡）、13、666——标记其在用户界面（UI）中的使用（房间号、物品数量、价格）

**幽默和习语**
- 在其他语言地区会被翻译成冒犯性内容的习语
- 在某些市场（尤其是日本、德国、中东）不合适的厕所/身体幽默
- 围绕特定地区文化敏感话题的黑色幽默

**暴力和内容分级**
- 在 DE（德国）、AU（澳大利亚）、CN（中国）或 AE（阿联酋）需要变更分级的内容
- 血液颜色、血腥程度、药物引用——如需要，全部标记为地区特定资源变体

**名称和表现**
- 在目标语言地区具有冒犯性、亵渎性或负面含义的角色名称
- 对国籍、宗教或族群的刻板印象式表现

将发现以表格形式呈现：

| 发现 | 受影响的语言地区 | 严重程度 | 建议措施 |
|---------|--------------------|----------|--------------------|
| [描述] | [Locale] | [BLOCKING / ADVISORY / NOTE] | [修改 / 标记待审 / 接受] |

BLOCKING = 在该语言地区发布前必须修复。ADVISORY = 建议修改。NOTE = 仅供参考。

询问：“我可以把这份文化审查报告写入 `production/localization/cultural-review-[date].md` 吗？”

---

## Phase 2G: VO 流水线模式

管理配音本地化流程。根据参数确定子任务：

- `vo-pipeline scan` — 识别所有需要 VO 录制的对话台词
- `vo-pipeline script` — 生成带导演注释的录制脚本
- `vo-pipeline validate` — 检查所有已录制的 VO 文件是否存在且命名正确
- `vo-pipeline integrate` — 验证 VO 文件在代码/资源中被正确引用

### VO 流水线：扫描

读取 `assets/data/strings/` 和 `design/narrative/`。识别：
- 所有对话台词（键匹配 `dialogue.*`）及其源文本
- 已录制的台词（`assets/audio/vo/` 中存在音频文件）
- 尚未录制的台词

输出录制清单：

```
## VO Recording Manifest — [Date]

| Key | Character | Source Line | Status |
|-----|-----------|-------------|--------|
| dialogue.npc.merchant.greeting | Merchant | "Welcome, traveller." | Recorded |
| dialogue.npc.merchant.haggle | Merchant | "That's my final offer." | Needs recording |
```

### VO 流水线：脚本

为每个角色生成录制脚本文档，按场景分组。包括：

- 角色名称和简要性格说明
- 完整对话台词，并为不寻常的专有名词提供发音指南
- 每句台词的情绪/导演注释（`[Warm, welcoming]`、`[Annoyed, clipped]`）
- 任何作为对话回应的台词（提供上下文：“Player just said X”）

询问：“我可以把 VO 录制脚本写入 `production/localization/vo-scripts-[locale]-[date].md` 吗？”

### VO 流水线：校验

用 Glob 查找 `assets/audio/vo/[locale]/` 中的所有 `.wav`/`.ogg` 文件。与 VO 清单交叉比对。报告：
- 缺失文件（脚本中有台词，但没有音频文件）
- 多余文件（存在音频文件，但没有匹配的字符串键）
- 命名约定违规

### VO 流水线：集成

在代码根目录中 Grep 查找 VO 音频引用。验证每个引用的路径都存在于 `assets/audio/vo/[locale]/`。报告断开的引用。

---

## Phase 2H: RTL 检查模式

从右到左的语言（阿拉伯语、希伯来语、波斯语、乌尔都语）需要布局镜像，
而不仅仅是翻译文本。此模式校验实现情况。

确定引擎：从 `project.yaml` 读取 `engine.name`；如果该键缺失或为空（包括 `project.yaml` 没有 `engine:` 块的情况），则回退到 `.trae/docs/technical-preferences.md`。然后检查：

**布局镜像**
- 引擎中是否启用了 RTL 布局？（Godot：`Control.layout_direction`，Unity：`RTL Support` 包，Unreal：文本方向标志）
- 所有用户界面（UI）容器是否都设置为自动镜像，还是位置被硬编码？
- 进度条、生命条和方向指示器是否正确地镜像？

**文本渲染**
- 是否加载了支持阿拉伯语/希伯来语字符集的字体？
- 阿拉伯语文本是否以正确的连字（连写文字）渲染？
- 在需要的地方，数字是否显示为东部阿拉伯数字？

**字符串组装**
- 是否存在假定从左到右阅读顺序的字符串拼接？
- 当句子结构被反转时，句子中的 `{placeholder}` 位置是否仍然正确？

**资源审查**
- 是否有带方向箭头或不对称设计的用户界面（UI）图标需要镜像变体？
- 是否存在需要 RTL 版本的图文合一资源？

要检查的 Grep 模式：
- 场景/预制体文件中的引擎特定 RTL 标志
- 任何 `HBoxContainer`、`LinearLayout`、`HorizontalBox` 节点——验证 layout_direction 设置
- 对话或用户界面（UI）代码附近使用 `+` 的字符串拼接

报告发现。标记 BLOCKING 问题（不修复则内容无法阅读）与 ADVISORY（外观改进）。

询问：“我可以把这份 RTL 检查报告写入 `production/localization/rtl-check-[date].md` 吗？”

---

## Phase 2I: 冻结模式

字符串冻结会锁定源（英文）字符串表，使翻译工作可以在源不发生变化的情况下进行。

### freeze 调用

检查 `production/localization/freeze-status.md` 中的当前冻结状态（如果存在）。

如果已冻结：
> “字符串冻结当前处于 ACTIVE 状态（调用于 [date]）。自冻结以来已新增或修改了 [N] 个字符串。这些是冻结违规——需要重新翻译或经批准的冻结解除。”

如果未冻结，呈现冻结前检查清单：

```
Pre-Freeze Checklist
[ ] All planned UI screens are implemented
[ ] All dialogue lines are final (no further narrative revisions planned)
[ ] All system strings (error messages, tutorial text) are complete
[ ] /localize scan shows zero hardcoded strings
[ ] /localize validate shows no placeholder mismatches in source (en)
[ ] Marketing strings (store description, achievements) are final
```

使用 `AskUserQuestion`：
- 提示：“现在调用字符串冻结吗？这会写入 `production/localization/freeze-status.md`（Status: ACTIVE）并锁定源表。”
- 选项：`[A] Yes — call string freeze now` / `[B] No — I still have strings to add`

如果选 [A]：写入 `production/localization/freeze-status.md`：

```markdown
# String Freeze Status

**Status**: ACTIVE
**Called**: [date]
**Called by**: [user]
**Total strings at freeze**: [N]

## Post-Freeze Changes
[Any strings added or modified after freeze are listed here automatically by /localize extract]
```

### freeze lift

如果参数包含 `lift`：询问“我可以把 `freeze-status.md` 更新为 LIFTED 吗？”，然后将其 Status 设为 `LIFTED` 并记录原因和日期。警告：“解除冻结需要重新翻译所有已修改的字符串。请通知翻译团队。”

### freeze check（自动集成到 extract）

当 `extract` 模式发现新增或修改的字符串，且 `freeze-status.md` 显示 Status: ACTIVE 时——在 extract 自己的“我可以写入吗”问题中点名 `freeze-status.md`，在获批后把新键追加到其 `## Post-Freeze Changes`，并警告：
> “⚠️ 字符串冻结处于活动状态。已新增/修改 [N] 个字符串。这些是冻结违规。在继续之前请通知你的本地化供应商。”

---

## Phase 2J: QA 模式

本地化 QA 是一个专门的检查环节，在翻译交付之后、任何语言地区发布之前运行。它不同于 `/localize validate`（后者检查完整性）——这是基于结构化试玩的质量检查。

通过 `Agent` 派出 `localization-lead`，并提供：
- 要 QA 的目标语言地区
- 游戏中所有屏幕/流程的列表（来自 `design/gdd/` 或 `/content-audit` 输出）
- 当前的 `/localize validate` 报告
- 文化审查报告（如果存在）

要求 localization-lead 制定一份 QA 计划，涵盖：

1. **功能字符串检查** — 每个字符串在游戏中显示时都没有截断、占位符错误或编码损坏
2. **用户界面（UI）溢出检查** — 超出用户界面（UI）边界的翻译字符串（即使未超出字符限制，某些语言也会膨胀）
3. **上下文准确性** — 在游戏内抽查 10% 的字符串，检查翻译准确性和措辞是否自然
4. **文化审查项** — 验证文化审查中的所有 BLOCKING 项都已解决
5. **VO 同步检查** — 如果存在 VO，验证翻译后的口型同步或字幕时间是否可以接受
6. **平台认证要求** — 检查平台特定的本地化要求（年龄分级文本、法律声明、ESRB/PEGI/CERO 文本）

按语言地区输出 QA 结论：

```
## Localization QA Verdict — [Locale]

**Status**: PASS / PASS WITH CONDITIONS / NOT ASSESSED / FAIL
**Reviewed by**: localization-lead
**Date**: [date]

### Findings
| ID | Area | Description | Severity | Status |
|----|------|-------------|----------|--------|
| LOC-001 | UI Overflow | "Settings" button text overflows on [Screen] | BLOCKING | Open |
| LOC-002 | Translation | [Key] translation is literal — sounds unnatural | ADVISORY | Open |

### Conditions (if PASS WITH CONDITIONS)
- [Condition 1 — must resolve before ship]

### Sign-Off
[ ] All BLOCKING findings resolved
[ ] Producer approves shipping [Locale]
```

优先匹配：如果有任何 BLOCKING 发现未解决，则为 **FAIL**；否则，如果某项检查无法运行，则为 **NOT ASSESSED**——这些检查基于试玩，因此没有任何人在游戏内玩过的语言地区（或其翻译尚未交付的语言地区）仅凭字符串表无法通过；请点名每项未运行的检查；否则，如果仍有条件未满足，则为 **PASS WITH CONDITIONS**；否则为 **PASS**。NOT ASSESSED 的优先级高于两个通过值——未被试玩过的语言地区尚未通过——且低于 FAIL，因此未解决的 BLOCKING 发现永远不会被其掩盖。

询问：“我可以把这份本地化 QA 报告写入 `production/localization/loc-qa-[locale]-[date].md` 吗？”

**质量闸门（gate）集成**：在 `workflow: full` 下，Polish → Release 质量闸门要求每个要发布的已翻译语言地区都获得 PASS 或 PASS WITH CONDITIONS 结论（在 `standard` 下为推荐，在 `minimal` 下不要求）。FAIL 仅阻止该语言地区的发布——其他语言地区如果通过 QA 仍可继续。NOT ASSESSED 的语言地区尚未通过：其 QA 未运行。

---

## Phase 3: 规则与后续步骤

### 规则
- 英文（en）始终是源语言地区
- 每个字符串表条目都必须包含 `context` 字段，附译者注释、字符限制和占位符含义
- 绝不要直接修改翻译文件——生成差异供审查
- 字符限制必须按用户界面（UI）元素定义，并在 validate 模式中强制执行
- 必须先将字符串发送给译者之前调用字符串冻结——绝不要翻译移动目标
- RTL 支持必须从一开始就设计好——事后改造 RTL 布局成本高昂
- 对于游戏将进行商业销售的任何语言地区，都必须进行文化审查
- VO 脚本必须包含导演注释——原始对话台词会产生平淡的录音

### 推荐工作流

```
/localize scan            → find hardcoded strings
/localize extract         → build string table
/localize freeze          → lock source before sending to translators
/localize brief           → generate translator briefing document
[Send to translators]
/localize validate        → check returned translations
/localize cultural-review → flag culturally sensitive content
/localize rtl-check       → if shipping Arabic / Hebrew / Persian
/localize vo-pipeline     → if shipping dubbed VO
/localize qa              → full localization QA pass
```

在 `qa` 为你发布的每个已翻译语言地区返回 PASS 或 PASS WITH CONDITIONS 后，在运行 `/gate-check release` 时附上 QA 报告路径。