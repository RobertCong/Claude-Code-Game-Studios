# Agent Test Spec: live-ops-designer

## Agent Summary
- **Domain**: 上线后内容策略、季节性活动（设计与结构）、战斗通行证设计、内容节奏规划、玩家留存机制设计、长线服务功能路线图、商业化伦理政策
- **Does NOT own**: 经济数值 —— 货币、消耗、价格与奖励价值（economy-designer）、分析埋点实现（analytics-engineer）、活动内的叙事内容（writer）、代码实现
- **Gate IDs**: None；将掠夺性商业化及活动与成长冲突上报给 creative-director

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用长线运营、季节性活动、战斗通行证、留存）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit`，且 `disallowedTools:` 指明 `Bash` —— 仅设计文档，不含 shell、代码或分析工具
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对经济数值、分析流水线或叙事方向拥有权限

---

## Test Cases

### Case 1: In-domain request — 夏季活动设计
**Input**: "为我们的游戏设计一个夏季活动。它应持续 3 周，并给玩家每天登录的理由。"
**Expected behavior**:
- 起草前先提出澄清问题，并给出 2-4 个选项及推荐（Question-First Workflow）
- 活动简报包含其 Event Design 所要求的每个字段：开始日期、结束日期、机制、奖励、成功标准 —— 以及活动出问题时的兜底方案（禁用、延期、补偿）
- 包含每日登录留存钩子（例如每日挑战、连续登录、限时奖励）—— 即请求中「每天登录的理由」—— 分布在完整 3 周内，而非集中在前几天（例如每周里程碑，或其 Weekly 节奏层级所列的每周挑战）
- 指明奖励类别（外观、功能、货币），但不分配具体奖励价值或货币数量 —— 这些留给 economy-designer（「exact values assigned by economy-designer」）
- 将简报写入 `design/live-ops/events/` 前先询问

### Case 2: Out-of-domain request — 奖励价值计算
**Input**: "这个活动应该发放多少高级货币？每个外观奖励品阶的公平价值是多少？"
**Expected behavior**:
- 不产出货币数量或奖励估值
- 说明奖励价值与货币数量由 economy-designer 分配，它的部分是定义存在哪些奖励以及它们如何组织
- 提出产出奖励结构（品阶、解锁门槛、稀有度分布、奖励类别），以便 economy-designer 有具体的对象可以估值

### Case 3: Domain boundary — 掠夺性商业化顾虑
**Input**: "我们把战斗通行证设计成：玩家需要在通行证价格之外额外花费高级货币，才能在赛季内完成所有层级。"
**Expected behavior**:
- 将该设计标记为掠夺性 —— 付费完成式门控在其 Escalation Paths 中被点名
- 不会在未标记的情况下产出那种要求玩家购买战斗通行证后还需额外付费的设计（「do NOT implement it silently」）
- 在标记之外至少提供一个合规选项（Question-First 第 2 步给出 2-4 个选项）：购买者以合理的每日节奏游玩即可完成的通行证，使用其 Battle Pass Design 所要求的追赶机制
- 在 `design/live-ops/ethics-policy.md` 中记录该顾虑（写入前先询问），并上报 creative-director，以就是否继续、修改或阻止该设计作出有约束力的裁定
- 不完全拒绝继续 —— 提供合乎伦理的替代方案并等待指示

### Case 4: Conflict — 活动排期与主游戏成长节奏
**Input**: "我们想在赛季第 3-5 周举办双倍 XP 活动，但我们的成长设计师说那正是玩家应该进入中期难度曲线的时候。"
**Expected behavior**:
- 识别冲突：在中期难度曲线期间举办双倍 XP 活动会压缩预期的成长节奏
- 不会单方面移动或取消任一要素
- 上报 creative-director：迫使玩家偏离既定成长曲线的长线运营排期，正是其 Escalation Paths 所称的「Cross-domain design conflict」
- 呈现双方立场 —— 活动的留存价值与预期的成长体验 —— 让 creative-director 裁决；它提出的任何解决方案（调整活动时机、将加成限制在非核心成长）都作为选项提供给总监，而非直接实施

### Case 5: Context pass — 针对玩家留存流失进行设计
**Input context**: 分析显示第 7 天玩家流失率为 40%，归因于玩家完成了教程但找不到可追求的中期目标。
**Input**: "设计一个长线运营功能来解决第 7 天的流失。"
**Expected behavior**:
- 针对数据所指的第 7 天人群进行设计 —— 而非通用留存功能 —— 并且不重新索要已给出的流失数据
- 功能在第 7 天或之前可见并生效，并提供缺失的中期目标（一条可见的成长轨道，奖励分布延伸到第 7 天之后）
- 对照其 Retention Mechanics 已跟踪的 D7 留存点定义成功（并用 D14 确认效果持续），而非通用参与指标
- 当数据指向第 7 天时，不为第 1 天留存或第 30 天商业化设计功能
- 将具体奖励价值留给 economy-designer

---

## Protocol Compliance

- [ ] 保持在声明领域内（活动结构、内容节奏、留存设计、战斗通行证设计）
- [ ] 将奖励价值和经济数值请求重定向到 economy-designer
- [ ] 标记掠夺性商业化模式，提供合规选项，并上报 creative-director，而非静默实施
- [ ] 将活动/核心成长冲突上报 creative-director，而非单方面解决
- [ ] 使用所提供的留存数据定位特定玩家群体，而非通用的参与策略

---

## Coverage Notes
- Case 3（商业化伦理）是品牌安全测试 —— 此处失败可能导致有害的长线运营设计上线
- Case 4（上报行为）是协调测试 —— 验证代理确实上报，而非独立决定
- Case 5 是最重要的上下文感知测试；代理必须针对具体流失点，而非通用方案
- 无自动运行器；请手动审查或通过 `/skill-test`
