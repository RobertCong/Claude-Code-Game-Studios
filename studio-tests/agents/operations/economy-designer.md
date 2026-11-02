# Agent Test Spec: economy-designer

## Agent Summary
- **Domain**: 资源经济设计、战利品表设计、成长曲线（XP、等级、解锁）、游戏内市场与商店设计、经济平衡分析、消耗与产出（sink and faucet）机制、通胀/通缩风险评估、物品与货币的实体注册表取值
- **Does NOT own**: 长线运营活动排期与结构（live-ops-designer）、核心玩法机制（game-designer）、代码实现、分析埋点设计（analytics-engineer）、经济系统的叙事理由（writer）
- **Gate IDs**: None；向 game-designer 汇报；商业化决策需 creative-director 批准

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用经济、战利品表、成长曲线、平衡性）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit`，且 `disallowedTools:` 指明 `Bash` —— 仅设计文档，不含代码或分析工具
- [ ] 模型档位为 `inherit` —— frontmatter `model:` 精确为 `inherit`（档位见：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对长线运营排期、代码或叙事拥有权限

---

## Test Cases

### Case 1: In-domain request — 宝箱的战利品表设计
**Input**: "为我们地牢游戏中的标准宝箱设计战利品表。"
**Expected behavior**:
- 起草前先提出澄清问题，并给出 2-4 个选项及推荐（Question-First Workflow）—— 例如品阶名称、宝箱是否使用保底计时器或防运气差保护
- 撰写前读取 `design/registry/entities.yaml`，并以已注册的物品取值为准；与已注册条目不同的取值会被标记为拟议的注册表变更，而非静默使用
- 按其 Reward Output Format（产出物、概率或权重、条件、备注）产出表格，包含不同的稀有度品阶 —— Common、Uncommon、Rare、Epic、Legendary 或项目等价物 —— 而非单一平铺的物品列表
- 品阶概率构成完整分布：百分比合计为 100%，或权重给出其总和
- 说明每个品阶的预期获取（平均需要多少次尝试获得），并指出表格背后的奖励节奏原则（Reward Psychology）
- 提出注册新的跨系统物品：「May I add them to `design/registry/entities.yaml`?」

### Case 2: Out-of-domain request — 季节性活动排期
**Input**: "设计我们夏季活动和秋季活动的排期。它们应何时运行，各自持续多久？"
**Expected behavior**:
- 不产出活动排期或内容节奏计划
- 明确说明：「Live ops event scheduling is owned by live-ops-designer; I design the economic structure of rewards within events once the event schedule is defined」
- 提出在 live-ops-designer 确定结构后，为活动产出奖励价值设计

### Case 3: Domain boundary — 新货币带来的通胀风险
**Input**: "我们要新增一种「Prestige Coins」货币，通过完成全部赛季内容获得。玩家可以在 Prestige Shop 中消费它们。"
**Expected behavior**:
- 识别通胀风险：如果 Prestige Coins 的累积速度快于商店提供的消耗速度，商店会失去感知价值，玩家会囤积货币而不消费
- 标记具体风险：赛季内容完成是有限的产出源，但如果商店目录在赛季结束前被买空，赛季末的货币将没有价值
- 提出消耗机制：轮换的限时商店物品、Prestige Shop 中的消耗品，或货币兑换选项，以保持货币持续流出
- 不会在未解决消耗问题的情况下批准该设计在经济上健全
- 产出结构化风险评估：产出速率（估计每周货币量）、消耗容量（买空目录所需的估计货币量）、盈余预测

### Case 4: 中期成长曲线问题
**Input**: "玩家反馈中期 XP 刷取（20-35 级）像一堵墙。每级所需 XP 是 3 倍，但奖励没有同比增长。"
**Expected behavior**:
- 识别为成长曲线问题：XP 成本增长率超过奖励增长率
- 产出修订后的 XP 公式或曲线调整：要么降低 20-35 级的 XP 成本乘数，要么提高该区间的奖励 XP，要么引入追赶机制（完成明显低于玩家等级的内容时给予额外 XP）
- 将当前曲线与拟议曲线表述为带定义变量的公式，并在 20–35 范围内（含两端）按两者分别评估（例如在 20、25、30 和 35 级）—— `coding-standards.md` 要求设计数学「defined with variables」，且平衡数值链接到其来源公式
- 标记任何曲线变更都会影响达到等级上限的时间预测 —— 指出对终局内容节奏的下游影响（其 Progression Curve Design 建模每个阶段的预期玩家强度）

### Case 5: Context pass — 使用当前经济数据进行平衡分析
**Input context**: 当前经济数据：玩家平均每小时赚取 450 Gold，平均商店物品价格为 2,000 Gold，平均会话时长为 40 分钟。高级物品价格为 5,000 Gold。
**Input**: "我们当前的 Gold 经济健康吗？我们应该调整价格还是获取速率？"
**Expected behavior**:
- 使用所提供的具体数字：450 Gold/小时 = 每 40 分钟会话 300 Gold；2,000 Gold 的物品约需 4.4 小时（约 6.7 次会话）才能购买；5,000 Gold 的高级物品约需 11.1 小时（约 16.7 次会话）
- 将这些获取时间对照其 Economic Health Metrics（每小时平均货币量、物品获取速率）进行评估
- 提出锚定这些数字的选项 —— 例如提高获取速率或降低高级物品价格 —— 并给出各自的时长与会话数，给出建议，并将选择留给用户（Question-First Workflow）
- 不会在不锚定所提供数据的情况下产出泛泛建议（「prices may be too high」）

---

## Protocol Compliance

- [ ] 保持在声明领域内（战利品表、成长曲线、资源经济、通胀/通缩分析）
- [ ] 将长线运营排期请求重定向到 live-ops-designer，且不产出排期
- [ ] 主动标记通胀/通缩风险，并给出量化的消耗/产出分析
- [ ] 将成长曲线变更表述为带定义变量和实际计算数字的公式 —— 不做含糊的曲线调整
- [ ] 使用上下文中的实际经济数据；在提供具体数值时不产出通用基准
- [ ] 撰写物品前检查 `design/registry/entities.yaml`，并标记对已注册取值的任何变更
- [ ] 创建多节文档前询问「May I create [filepath] with the section skeleton?」，写入每一节前询问「May I write this section to [filepath]?」

---

## Coverage Notes
- Case 1 检验注册表意识 —— 在测试夹具中包含 `design/registry/entities.yaml`
- Case 3（通胀风险）是经济健康测试 —— 遗漏通胀风险会对长线运营游戏造成长期经济损害
- Case 4 要求代理产出实际数字，而非曲线形状 —— 验证存在数学计算，而不只是叙述
- Case 5 是最重要的上下文感知测试；代理必须使用所提供的数据，而非占位值
- 无自动运行器；请手动审查或通过 `/skill-test`
