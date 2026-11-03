# Agent Test Spec: localization-lead

## Agent Summary
- **Domain**: 国际化（i18n）架构、字符串提取工作流、区域设置测试方法论、翻译流水线设计（提取 → 翻译 → 导入）、字符串键与上下文标准、区域特定格式规则（复数、RTL、日期/数字格式）、字体与字符集、术语表与翻译记忆库
- **Does NOT own**: 游戏叙事内容与对话撰写（writer）、翻译工作本身（译者）、UI 设计决策（ux-designer）、游戏设计决策（game-designer）、支持哪些语言（producer）；它与 ui-programmer 协调文本渲染和 RTL 支持，与 tools-programmer 协调提取自动化
- **Gate IDs**: None；排期、语言支持范围与预算向 producer 汇报

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 i18n、字符串提取、区域流水线、本地化）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit, Bash` —— Bash 用于字符串提取工具；撰写翻译和叙事内容由正文的「What This Agent Must NOT Do」清单排除，而非工具清单
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对叙事内容、游戏代码实现或翻译质量拥有权限

---

## Test Cases

### Case 1: In-domain request — Unity 项目的字符串提取流水线
**Input**: "为我们的 Unity 游戏搭建字符串提取流水线。我们需要把所有可本地化字符串整理成译者可用的格式。"
**Expected behavior**:
- 列出其 String Extraction Workflow 定义的工作流：字符串通过本地化 API 进入（绝不使用原始文本），落到基础区域文件并带上下文注释，提取工具收集新增和修改的字符串，连同上下文、截图和字符限制交给译者，然后回到区域文件中
- 将提取范围限定为来自代码、UI 和内容的面向玩家文本 ——「Ensure no hardcoded strings reach production」
- 指定结构化的区域文件（JSON、CSV 或适合项目的格式），每个系统或功能区域每种语言一个文件（`locales/en/ui_menu.json` 模式）
- 使用描述上下文的层级点号键（`menu.settings.audio.volume_label`）—— 而非位置或索引式键 —— 每个键都带上下文注释，说明出现位置、字符限制和变量
- 指明由 `tools-programmer` 负责提取自动化、`ui-programmer` 负责文本渲染（Delegation Map），并在写入任何流水线文档前先询问

### Case 2: Out-of-domain request — 翻译游戏对话
**Input**: "把下面这段英文对话翻译成法语：'Well met, traveler. The road ahead is treacherous.'"
**Expected behavior**:
- 不产出法语翻译
- 说明它负责流水线、质量标准和流程，而翻译本身由人类译者或经批准的供应商完成（其「Write actual translations」禁止项）
- 可选地说明译者需要哪些信息：上下文（谁对谁说话、游戏类型/语气）、字符限制（若有）、术语表词条（例如「traveler」是否有游戏专属译法）

### Case 3: Domain boundary — 俄语区域缺少复数形式
**Input**: "我们的俄语区域文件中，物品数量字符串只有单数形式。俄语需要多种复数形式（1 个物品、2-4 个物品、5+ 个物品使用不同形式）。"
**Expected behavior**:
- 将其识别为区域特定的复数形式缺口：CLDR/Unicode 复数规则给俄语四个类别 —— one、few、many 和 other（`other` 覆盖小数数量，且 ICU MessageFormat 在每个复数消息中都要求它）—— 因此单一字符串不够
- 将其标记为本地化质量缺陷，而非轻微的样式问题 —— 错误的复数形式在语法上是错的，且玩家可见
- 建议按其 Pluralization 标准命名的修复：通过 ICU MessageFormat（或等价方案）使用该语言的复数类别实现复数规则，并提醒译者俄语字符串需要所有复数形式
- 将其视为流水线范围的修复 —— 所有受支持区域中的数量字符串都改用 ICU 复数规则 —— 而非仅针对俄语的补丁（波兰语、捷克语和阿拉伯语有同样问题）
- 不建议用数字阈值变通方案替代规范的复数规则

### Case 4: 两个系统之间的字符串键命名冲突
**Input**: "我们的 UI 系统使用 'button_confirm' 和 'button_cancel' 这样的键。我们的对话系统对相同概念使用 'confirm' 和 'cancel'。译者不知道该用哪个。"
**Expected behavior**:
- 识别冲突：两个系统对语义相同的字符串使用不同的键命名约定，造成重复翻译工作和译者困惑
- 按其层级点号命名标准产出命名约定解决方案（例如 `ui.button.confirm`、`ui.button.cancel`）—— 所有系统对共享概念使用同一个键
- 建议共享 UI 基础项（Confirm、Cancel、Back、OK）在共享命名空间中使用单一规范键，由两个系统共同引用，并将这些术语记录到术语表
- 规划键变更以确保不出问题：两个系统中的每个引用都迁移到新键，没有查找仍指向已退役的键（其 Key naming convention 规则及 Fallback chains：「never display raw keys to players」），现有翻译通过翻译记忆库延续，且两个系统中的代码变更在实施前与各自负责人协调
- 不建议为同一概念维护两个独立的键

### Case 5: Context pass — 流水线适配 RTL 语言
**Input context**: 目标区域包括英语（en）、法语（fr）、德语（de）、阿拉伯语（ar）和希伯来语（he）。
**Input**: "为这个项目设计本地化流水线。"
**Expected behavior**:
- 识别阿拉伯语和希伯来语为 RTL 语言 —— 明确将其列为流水线要求
- 设计流水线时纳入其 RTL 要求：镜像 UI 布局、同一字符串中的双向文本、RTL 文本中的数字保持 LTR、翻转方向性 UI，以及由母语 RTL 使用者测试 —— 并与 `ui-programmer` 协调 RTL 渲染
- 当指定了 RTL 区域时，不会设计只考虑 LTR 语言的流水线
- 涵盖阿拉伯语/希伯来语字体需求（RTL 字形整形、连字、上下文形式），以及每个区域通过 ICU MessageFormat 处理的复数规则
- 包含全部五个区域：回退链，以及其 Locale-Specific Testing Requirements（日期、数字、货币、时间、排序、输入、文本渲染）应用到每种语言，而不只是默认语言（en）

---

## Protocol Compliance

- [ ] 保持在声明领域内（流水线、提取、字符串质量、区域格式、i18n 架构）
- [ ] 不产出翻译 —— 将翻译工作重定向到人类译者/供应商
- [ ] 将区域特定缺口（复数形式、RTL）标记为需要流水线变更的质量缺陷
- [ ] 冲突出现时产出统一的键命名约定，并完成迁移使没有查找留在已退役的键上 —— 不接受双重约定
- [ ] 将所提供的所有目标区域（包括 RTL 语言）纳入流水线设计

---

## Coverage Notes
- Case 3（复数形式）和 Case 5（RTL）是区域正确性测试 —— 这些影响非英语市场的交付质量
- Case 4（键命名冲突）是流水线卫生测试 —— 重复键会导致持续的译者困惑和成本
- Case 5 要求目标区域列表在上下文中；若未提供，代理应询问而非自行选择 —— 支持哪些语言是 producer 的决定
- 无自动运行器；请手动审查或通过 `/skill-test`
