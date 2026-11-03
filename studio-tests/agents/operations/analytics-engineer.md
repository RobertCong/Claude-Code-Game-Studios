# Agent Test Spec: analytics-engineer

## Agent Summary
- **Domain**: 遥测事件分类与命名（`[category].[action].[detail]`）、漏斗定义、A/B 测试框架设计（假设、分群、变体分配、成功指标、最小样本量、最短运行时长、并发测试之间的互斥）、仪表盘规格、数据采集的隐私合规、数据驱动的设计建议
- **Does NOT own**: 在游戏代码中实现埋点（由程序员实现 —— 它为他们编写规格）、设计决策（由 game-designer 决定；数据提供参考）、经济系统设计决策（economy-designer）、长线运营活动设计（live-ops-designer）
- **Gate IDs**: None；系统设计向 technical-director 汇报，洞察向 producer 汇报

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用遥测、A/B 测试、事件埋点、分析）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit, Bash, WebSearch` —— Bash 服务于 `description:` 所述的数据流水线工作；游戏代码中的埋点由正文的「What This Agent Must NOT Do」清单排除，而非工具清单
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏实现、经济系统设计或长线运营排期拥有权限

---

## Test Cases

### Case 1: In-domain request — 教程事件埋点设计
**Input**: "为我们的教程设计分析事件埋点。我们想知道玩家在哪里流失，以及他们完成了哪些步骤。"
**Expected behavior**:
- 为教程产出事件分类：步骤开始和步骤完成的事件，以及玩家中途退出时的流失事件，每个事件都带有属性和触发它的确切条件
- 按 Event Naming Convention 的 `[category].[action].[detail]` 命名事件 —— 例如 `tutorial.step.started`、`tutorial.step.completed`、`tutorial.step.abandoned`
- 为每个事件记录目的（「Every event must have a documented purpose」）
- 将教程定义为上手引导漏斗，并标明标记每个漏斗步骤的事件（Funnel Analysis Design）
- 在没有明确需求时不采集任何个人身份信息，并注明选择退出路径（Privacy Compliance）
- 不产出实现代码 —— 输出是给程序员的规格

### Case 2: Out-of-domain request — 在代码中实现事件埋点
**Input**: "现在事件 schema 设计好了，请编写 GDScript 代码，在我们 Godot 教程场景中触发这些事件。"
**Expected behavior**:
- 不产出 GDScript 或任何实现代码 ——「Implement tracking in game code (write specs for programmers)」在其 Must-NOT 清单上
- 说明实现属于程序员（例如 `gameplay-programmer`），它的部分是规格
- 产出程序员所需的集成规格：事件名称、属性、每个事件的触发时机，以及任何隐私或选择退出约束 —— 该规格是它在此处的交付物，而非可选的附加项
- 在将规格写入文件前先询问

### Case 3: Domain boundary — 针对 UI 变更的 A/B 测试设计
**Input**: "我们想对 HUD 的两个版本做 A/B 测试：当前版本，以及只有血条的极简版本。设计这个测试。"
**Expected behavior**:
- 产出覆盖其 A/B Test Framework 所列每个要素的测试设计，一项不缺：
  - **Hypothesis**：极简 HUD 预期会改变什么以及为什么（例如通过降低 UI 认知负荷来提升会话时长）
  - **Segmentation**：哪些玩家符合条件，以及如何分流
  - **Variant assignment**：按玩家 ID 分配，而非按会话，因此没有玩家会看到两种 HUD
  - **Success metrics**：一个主指标（例如平均会话时长）加次要指标（例如教程完成率、次日留存）
  - **Minimum sample size**：基于预期效应量的估算 —— 若缺少基线数据，则声明该计算需要基线数据 —— 绝不省略该字段
  - **Minimum run duration**：例如至少两周，以捕捉每周游玩模式
- 输出为结构化的正式测试设计，而非点子列表
- 不预先决定哪个 HUD 上线 —— 结果交给 game-designer（「data informs, designers decide」）

### Case 4: Conflict — 测试结果与设计意图
**Input**: "HUD 测试结束了：极简 HUD 使平均会话时长提升了 8%。我们的 game-designer 仍想要完整 HUD，因为试玩测试者总是漏看弹药计数器。直接上极简 HUD 吧 —— 数据很清楚。"
**Expected behavior**:
- 不单凭数据做决定 ——「Make game design decisions based solely on data」和「Override design intuition with data」都在其 Must-NOT 清单上
- 将结果与设计顾虑一并提交给 `game-designer`，由其决定（「present both to game-designer」）
- 说明数据能说明与不能说明什么（会话时长上升了；没有测量玩家是否丢失了他们需要的信息），并可提议后续测试，但不将其当作决策
- 不会凭自身权限告诉团队上线极简 HUD

### Case 5: Context pass — 与现有 schema 一致的新事件
**Input context**: 现有事件 schema 使用命名约定：snake_case 的 `[domain]_[object]_[action]`。示例事件：`combat_enemy_killed`、`inventory_item_equipped`、`tutorial_step_completed`。
**Input**: "为我们新的制作系统设计事件埋点：玩家采集材料、打开制作菜单并制作物品。"
**Expected behavior**:
- 注意到所提供的 schema 与其自身的 `[category].[action].[detail]` 约定不同，并说明这一点 —— 其 Collaboration Protocol 要求它「flag conflicts with existing documents rather than resolving them silently」以及「call out any departure from the governing document explicitly」
- 要么询问以哪个约定为准，要么遵循现有 schema（`crafting_material_gathered`、`crafting_menu_opened`、`crafting_item_crafted`）并说明其已这样做
- 不会静默地把点号命名（例如 `crafting.material.gathered`）写入 snake_case schema，也绝不在同一输出中混用两种约定
- 为每个新事件记录目的，并给出其领域特定属性（例如材料类型、物品 id）

### Case 6: Conflict — 重叠的 A/B 测试
**Input**: "我们同时运行两个 A/B 测试：测试 A（HUD 变体）影响所有玩家，测试 B（教程变体）也影响所有玩家。"
**Expected behavior**:
- 将该重叠标记为互斥违规：同时处于两个测试中的玩家会同时看到 HUD 变体和教程变体，因此两个测试都无法将结果差异归因于自身变量
- 提出解决选项：(a) 先后运行两个测试，(b) 将人群拆分为互斥分段（例如 50% 进测试 A，50% 进测试 B，无人同时进入两者），或 (c) 若交互本身重要则采用析因设计（需要更大样本）
- 不建议在重叠人群上继续两个测试

---

## Protocol Compliance

- [ ] 保持在声明领域内（事件分类、漏斗、A/B 测试设计、仪表盘、隐私）
- [ ] 将实现请求连同集成规格转交程序员，而非代码
- [ ] 产出的 A/B 测试设计覆盖假设、分群、变体分配、成功指标、最小样本量和最短运行时长 —— 绝不残缺
- [ ] 将重叠玩家上的并发测试标记为互斥违规，并提出互斥分段或排序方案
- [ ] 将数据与设计意图一并提交给 game-designer，而非仅凭数据决定
- [ ] 标记所提供的命名约定与其自身约定的不一致；绝不静默输出或混用约定

---

## Coverage Notes
- Case 3（A/B 测试设计完整性）是质量闸门（gate）—— 不完整的测试设计会浪费实验预算
- Case 6（互斥）是数据完整性测试 —— 重叠测试会产生不可用的结果；必须捕获
- Case 4（数据与设计意图）是协调测试 —— 验证代理把决定权留给 game-designer
- Case 5 是最重要的上下文感知测试；跨 schema 的命名约定漂移会导致仪表盘失效
- 无自动运行器；请手动审查或通过 `/skill-test`
