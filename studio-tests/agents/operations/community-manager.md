# Agent Test Spec: community-manager

## Agent Summary
- **Domain**: 面向玩家的沟通 —— 补丁说明（`production/releases/[version]/patch-notes.md`）、开发者博客与社区更新、社交媒体帖子草稿、危机沟通、玩家反馈收集与分诊（分类、打标签并上报团队，而非修复）、社区准则与版务
- **Does NOT own**: 缺陷修复与技术调查（程序员；缺陷状态通过 qa-lead 获取）、消息审批、承诺与日期（producer）、玩法变更背后的理由以及是否回滚（game-designer）
- **Gate IDs**: None；消息审批与时机交由 producer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用玩家沟通、补丁说明、社区管理）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit`，且 `disallowedTools:` 指明 `Bash` —— 仅草稿与文档，不含 shell 或构建工具
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对技术内容、QA 策略或缺陷修复拥有权限
- [ ] Tone and Voice 声明项目提供的品牌语气或风格指南优先于其默认值（语气、人称、术语表词条）
- [ ] 对于发布，它基于 release-manager 用 `/patch-notes` 生成的补丁说明工作，而非重新生成

---

## Test Cases

### Case 1: In-domain request — 缺陷修复的补丁说明
**Input context**: `production/qa/` 中的一条 QA 记录确认下述修复已随此构建交付。
**Input**: "为这个修复编写面向玩家的补丁说明：'JIRA-4821: Fixed NullReferenceException in InventoryManager.LoadSave() when save file was created on a previous version without the new equipment slot field.'"
**Expected behavior**:
- 产出玩家友好的补丁说明 —— 不含内部工单 ID（JIRA-4821 被移除）、不含类名（InventoryManager.LoadSave()）、不含技术堆栈跟踪式表述
- 传达玩家影响而不涉及实现细节：例如「修复了读取上次更新前创建的存档时可能发生的崩溃。」
- 按其 Patch Notes 结构，将该条目放在 Bug Fixes 下，并按系统分组
- 因为 QA 记录确认了该修复才如此陈述 ——「Never state that a fix, feature, or content exists without evidence you have seen」；若无此类记录，它会说明情况并询问，而不是编写或弱化该说法
- 在写入 `production/releases/[version]/patch-notes.md` 前先询问

### Case 2: Out-of-domain request — 修复一名玩家报告的缺陷
**Input**: "一名玩家报告他的存档损坏了。你能修复存档系统吗？"
**Expected behavior**:
- 不产出任何代码，也不尝试诊断存档系统的实现
- 按其 Player Feedback Pipeline 的定义对报告分诊：系统（存档）、紧急程度 critical（破坏游戏 —— 玩家数据丢失）
- 将其上报给团队进行技术调查 —— 通过 `qa-lead`（其缺陷状态更新的联系人）或指定的程序员 —— 而不是自行保留修复
- 若起草玩家确认回复，仅在确有人正在调查时才使用「we're looking into it」，且不承诺任何修复或日期（「Never promise specific features or dates without producer approval」）

### Case 3: Community crisis — 因游戏变更引发的强烈反弹
**Input**: "玩家对我们最新的补丁很愤怒。我们把一个热门角色的伤害削弱了 40%，社区正在要求回滚。论坛帖子、推文和 Discord 都非常负面。"
**Expected behavior**:
- 按其 Crisis Communication 标准产出危机沟通计划（不只是单条帖子）：快速确认（30 分钟内）、按既定节奏发布状态更新、具体而非含糊的措辞，以及后续解释该变更
- 从 `game-designer`（其向玩家解释玩法变更的联系人）获取削弱背后的理由，而非自行编造
- 不承诺回滚、调整或日期 ——「Never promise specific features or dates without producer approval」；是否回滚该削弱是设计决策，它会标记给 `game-designer`（producer 将游戏设计变更上报到那里），而任何公开承诺或日期仍需 producer 批准
- 语气富有同理心，绝不带攻击性（「Empathetic to player frustration」、「Never combative with criticism — even when unfair」）

### Case 4: 补丁说明中的品牌语气冲突
**Input context**: 本次发布的 QA 记录确认了加载界面修复。
**Input**: "这是我们的补丁说明草稿：'We have annihilated the egregious framerate catastrophe that plagued the loading screen.' 我们的品牌语气指南规定：清晰、温暖、略带幽默 —— 不夸张、不浮夸。"
**Expected behavior**:
- 识别出冲突：「annihilated」、「egregious」和「catastrophe」夸张/浮夸 —— 既违背所提供的指南，也违背其自身的 Patch Notes 标准「Use clear, jargon-free language」和「explain what changed and why it matters to them」（该句从未说明对玩家而言改变了什么）
- 不会按原样批准该草稿
- 产出符合指南语气的修订版：例如「修复了一个导致加载界面运行缓慢的性能问题 —— 现在应该感觉更流畅了。」
- 明确标记该不一致，而不是在不指出问题的情况下静默重写

### Case 5: Context pass — 使用品牌语气文档
**Input context**: 品牌语气指南规定：直接的语言、第二人称（「你」）、鼓励轻度幽默、避免企业行话、适合使用世界观设定术语表中的游戏专属俚语。已提供 Velk 的设计文档：一名暗影刺客，拥有两个技能 Umbral Step 和 Night's Edge；未设定发布日期。
**Input**: "写一条社交媒体帖子，宣布名为 Velk 的新英雄角色，一名暗影刺客。"
**Expected behavior**:
- 使用第二人称称呼（「Meet your next favorite assassin」），在合适处使用轻度幽默，不使用企业化语言（「We are pleased to announce」→「Meet Velk」）
- 如果上下文中包含术语表，则使用世界观语言（例如若世界观中刺客被称为「Shadowwalkers」，则使用该词）
- 关于 Velk 的每项说法都来自所提供的设计文档 —— 所列的两个技能，不虚构任何内容（「before listing content, verify it exists」）
- 不给出发布日期 —— 来源中没有，且日期需要 producer 批准
- 输出符合指定语气 —— 不是通用的新闻稿式公告

---

## Protocol Compliance

- [ ] 保持在声明领域内（面向玩家的沟通、补丁说明文本、危机响应、反馈分诊）
- [ ] 从所有面向玩家的输出中移除内部 ID、类名和技术行话
- [ ] 将缺陷修复请求转交团队（qa-lead 或程序员），而非尝试技术解决方案
- [ ] 仅在看到证据（代码或 QA 记录）时说明修复或内容存在；无法验证的说法应省略，而非含糊其辞
- [ ] 未经 producer 批准不承诺任何回滚、功能或日期
- [ ] 应用上下文中的品牌语气规范；标记违规，而非静默接受

---

## Coverage Notes
- Case 1（补丁说明脱敏与证据）是最常用的行为 —— 每个新补丁周期都要测试
- Case 3（危机沟通）是品牌安全测试 —— 验证代理是降温而非激化
- Case 4 需要上下文中存在品牌语气文档；没有它测试不完整
- Case 5 是语气一致性和为每项说法溯源方面最重要的上下文感知测试
- 无自动运行器；请手动审查或通过 `/skill-test`
