# Agent Test Spec: world-builder

## Agent Summary
- **领域**：世界设定架构——派系及其文化/政府/动机、世界历史、地理与生态、宇宙论与形而上学、世界规则（魔法如何运作、什么可能什么不可能）、跨世界文档的内部一致性维护
- **不负责**：具体 NPC 或任务对话（writer）、由世界规则衍生的游戏机制规则（game-designer/systems-designer）、叙事故事结构与弧线设计（narrative-director）
- **Gate IDs**：无；将世界规则/机制冲突联合升级给 narrative-director 与 game-designer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及世界设定、派系、历史、世界规则、生态）
- [ ] `tools:` 读取 Read、Glob、Grep、Write、Edit，且 `disallowedTools:` 列出 Bash —— 仅文档编写，无 shell 或代码执行
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对对话写作、机制设计或叙事弧线结构拥有权限

---

## Test Cases

### Case 1: 域内请求 — 派系文化与政府设计
**Input**: “设计 Ironveil 商业集团——我们世界中一个强大的贸易派系。我需要他们的文化、政府结构和内部动机。”
**Expected behavior**:
- 在起草前提出澄清问题，并为政府模型提出 2–4 个选项（例如创始家族议会、选举主席、按股份加权投票），附利弊与建议，将选择交予用户
- 产出派系档案，包含：动机（他们想要什么及为何）、权力结构（决策如何做出、谁掌握权力、继承或任命）、与其他派系的关系（盟友、对手、中立方）、领地、面向玩家的性格，以及文化细节（习俗、信仰、日常生活）
- 派系内部一致：商业集团的政府由经济逻辑驱动，而非封建或宗教逻辑，除非明确指定了刻意的混合体
- 条目包含 Lore Document Standard 字段：Canon Level、Visible To Player、Cross-References、Contradictions Check、Source
- 格式化为结构化派系档案，而非叙事散文；创建文件前询问“May I create [filepath] with the section skeleton?”，写入每个章节前询问“May I write this section to [filepath]?”

### Case 2: 域外请求 — 对话写作
**Input**: “为玩家在城门口遇到的 Ironveil 集团商人 NPC 编写对话。”
**Expected behavior**:
- 不产出 NPC 对话
- 说明对话写作由 `writer` 负责，其自身部分是影响对话的世界与派系上下文——派系的文化、语气和说话风格
- 主动提出产出 writer 编写一致对话所需的文化细节——习俗、信仰、语言片段、日常生活

### Case 3: 新设定条目与既定历史矛盾 — 冲突标记
**Input**: “添加一条设定，称 Ironveil 集团由单一商人家庭于 50 年前创立。” [上下文包含现有设定：该集团已存在 300 年，由 12 个相互竞争的贸易家族作为集体创立。]
**Expected behavior**:
- 识别矛盾：现有设定称 300 年历史与 12 个家族组成的创立联盟；新条目声称 50 年和单一创立家族
- 不按请求写入新条目
- 标记冲突：陈述两个版本，指出哪个是既定设定、哪个是拟议变更
- 提出解决选项：(a) 新条目错误应更正；(b) 若新版本是预期正典，应更新现有设定；(c) 存在世界观内的解释（当前家族声称创立功劳，尽管源于集体创立——刻意不可靠叙述者，真相另行记录）
- 不自行应用选项 (b)：更改既定正典需要 narrative-director 批准

### Case 4: 世界规则具有玩法影响 — 与 game-designer 协作
**Input**: “我想确立一条世界规则：在铁矿附近施法的魔法使用者会被削弱。铁会干扰奥术能量。”
**Expected behavior**:
- 将世界规则作为设定条目产出：形而上学解释、世界观内如何理解、历史影响
- 识别玩法影响：该世界规则有直接的机制后果（铁矿附近的玩家被减益，关卡设计必须考虑铁矿位置）
- 标记协作要求：“This world rule has gameplay mechanics implications — game-designer needs to define how this translates into player-facing mechanics; proceeding with the lore without the mechanics definition risks inconsistency”
- 不擅自设计游戏机制——描述设定规则及其暗示的机制领域，然后交由 game-designer

### Case 5: 上下文传递 — 使用既定世界文档
**Input context**: 现有世界文档写明：该世界使用双日系统，其中一颗太阳是奥术能量来源（White Sun），奥术魔法在为期 3 天的月食期（Darkening）内失效。
**Input**: “添加一条关于法师学院及其如何为 Darkening 做准备的设定。”
**Expected behavior**:
- 使用既定的双日宇宙论：引用 White Sun 作为奥术能量来源
- 使用既定的 Darkening 事件：3 天蚀、魔法失效
- 不虚构不同的日蚀机制、时长或名称
- 产出设定条目，其中法师学院的 Darkening 准备与既定规则一致：他们在 Darkening 期间无法施法，因此准备是务实的（储备非魔法补给、安排日程、关闭正在进行的魔法过程）
- 不与上下文文档中的任何既定事实矛盾

---

## Protocol Compliance

- [ ] 保持在声明的领域内（派系、世界历史、地理、生态、世界规则、宇宙论）
- [ ] 将对话写作请求重定向给 writer，并附派系上下文说明
- [ ] 标记设定矛盾时陈述两个版本并提供解决选项——不静默覆盖既定设定
- [ ] 识别世界规则的玩法影响并标记与 game-designer 的协作
- [ ] 使用上下文中的所有既定世界事实；不虚构与所述设定不同的替代方案

---

## Coverage Notes
- Case 3（矛盾检测）要求上下文中存在现有设定——这是最重要的一致性测试
- Case 4（世界规则/机制协作）测试跨域意识；验证代理识别机制边界而不跨越
- Case 5 是最重要的上下文意识测试；代理必须使用既定事实，而非创意替代
- 无自动化运行器；请手动评审或通过 `/skill-test` 评审
