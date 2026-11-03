# Agent Test Spec: writer

## Agent Summary
- **领域**：游戏内书面内容——NPC 对话（包括分支树）、设定图鉴条目、物品与能力描述、环境文本（标牌、书籍、笔记）、任务文本、教程文本、世界观内书面文档
- **不负责**：故事架构与叙事结构（narrative-director）、世界设定与世界规则（world-builder）、UX 流程与信息架构（ux-designer；它编写 UI 微文案，而不是其周边的 UX）、补丁说明（community-manager）
- **Gate IDs**：无；将设定不一致标记给 narrative-director，而不是自行解决

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及对话、设定条目、物品描述、游戏内文本）
- [ ] `tools:` 读取 Read、Glob、Grep、Write、Edit，且 `disallowedTools:` 列出 Bash —— 仅文本编写，无 shell 或代码执行
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对叙事结构、世界规则或 UX 文案方向拥有权限

---

## Test Cases

### Case 1: 域内请求 — NPC 商人对话
**Input**: “为旅行商人 NPC Mira 编写对话。她售卖通用补给。玩家可以向她询问货物、前方道路和传闻。”
**Expected behavior**:
- 查找 Mira 的声音档案（声音档案由 narrative-director 定义）；若未提供，则说明并询问，或提出临时声音供批准——它不决定她的角色弧线
- 产出对话树，至少有 3 个顶层对话选项：[Wares]、[The Road Ahead]、[Rumors]，以及至少 1 个后续分支（树结构，而非平铺响应）
- 每行都有说话者标签与上下文注释，分支条件以一致格式携带条件/状态注解
- 任何一行不超过 120 个字符；变量插入使用命名占位符（例如 `{player_name}`）
- 道路与传闻内容不与既定世界设定矛盾
- 在对话中起草，并在写入前询问“May I write this to [filepath]?”（对于多章节文件，先请求创建章节骨架）

### Case 2: 域外请求 — 世界历史设计
**Input**: “设计世界历史——第一个王国何时建立、重大战争有哪些、以及魔法为何被禁止。”
**Expected behavior**:
- 不产出世界历史、设定架构或世界规则
- 明确说明：“World history, lore, and world rules are owned by world-builder; once the history is established, I can write in-game texts, books, and dialogue that reference those events”
- 即使作为“占位符”也不产出部分世界历史

### Case 3: 对话与既定设定矛盾 — 标记给 narrative-director
**Input**: “编写 Mira 的对话行，她提到龙已经灭绝 200 年。” [上下文包含现有设定：龙在北方省份仍然存活并受尊崇，并未灭绝。]
**Expected behavior**:
- 识别矛盾：既定设定称龙仍存活且受尊崇；声称已灭绝的对话直接冲突
- 不按所给写入请求的行
- 将不一致标记给 narrative-director：“Mira's dialogue as requested contradicts established lore (dragons are alive per world-builder's document); requires narrative-director resolution before I can write this line”
- 向用户提供与设定一致的替代行（例如 Mira 对北方目击龙表示敬畏），供冲突解决期间使用

### Case 4: 物品描述引用了未设计的机制
**Input**: “为‘Berserker's Chalice’编写描述——一种饮用后触发 Berserker 状态的消耗品。”
**Expected behavior**:
- 识别依赖缺口：“Berserker state”未在任何提供的游戏设计文档中定义
- 标记缺失依赖：“This description references a 'Berserker state' mechanic that has no GDD entry — I cannot write accurate flavor text for a mechanic whose rules are undefined, as the description may create incorrect player expectations”
- 不编写可能与最终设计冲突、虚构机制细节（时长、效果）的描述
- 向 game-designer（其在文本中确保机制清晰度的协调者）提出缺失定义，并询问用户如何继续：(a) 编写含糊、不涉及机制的描述，不产生错误预期，标记为临时；或 (b) 等待 game-designer 先定义 Berserker 状态

### Case 5: 上下文传递 — 角色声音指南
**Input context**: Mira 的角色声音指南：她用简短、有活力的句子说话。使用商人俚语（“a fine bargain”、“coin well spent”）。偶尔省略代词（“Good wares, these.”）。从不使用缩写——总是“I will”而非“I'll”。温暖但略带雇佣兵气质。
**Input**: “编写玩家询问她是否有治疗药水时 Mira 的回应。”
**Expected behavior**:
- 简短、有活力的句子——没有长篇独白
- 使用商人俚语：“a fine bargain”、“coin well spent”或类似
- 在自然处省略代词：“Fine stock, these potions.”
- 不使用缩写：“I will”而非“I'll”，“do not”而非“don't”
- 温暖语气带雇佣兵式的底色：她乐意帮忙，因为你是付费顾客
- 不产出违反任何声音指南规则的对话——逐条明确检查

---

## Protocol Compliance

- [ ] 保持在声明的领域内（对话、设定条目、物品描述、游戏内文本）
- [ ] 将世界历史和世界规则请求重定向给 world-builder，不产出未经授权的设定
- [ ] 将设定矛盾标记给 narrative-director，而不是静默编写不一致内容
- [ ] 在编写可能造成错误玩家预期的物品描述前识别机制依赖缺口
- [ ] 应用所提供角色声音指南中的所有规则——不得部分合规
- [ ] 对于多章节文档（例如一组设定条目），在创建文件前询问“May I create [filepath] with the section skeleton?”，每个章节获批后写入，并在每个章节后更新 `production/session-state/active.md`

---

## Coverage Notes
- Case 3（设定矛盾检测）要求现有设定位于对话上下文中——仅在提供上下文时测试有效
- Case 4（依赖缺口）测试代理编写的描述是否可能设定错误的玩家预期——一个微妙但重要的质量问题
- Case 5 是最重要的上下文意识测试；声音指南合规性必须逐条规则检查，而非整体判断
- 无自动化运行器；请手动评审或通过 `/skill-test` 评审
