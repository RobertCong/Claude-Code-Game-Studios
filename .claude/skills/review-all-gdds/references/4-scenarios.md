# /review-all-gdds — Phase 4: 跨系统场景走查

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 4: 跨系统场景走查

从玩家视角走查游戏，找出只在多个系统交互边界上才会出现的问题 — 这些问题是对单个 GDD 做静态分析无法浮现的。

### 4a：识别关键的多系统时刻

扫描所有 GDD，识别 3–5 个最重要的、面向玩家的、多个系统同时激活的时刻。特别关注：

- **战斗 + 经济重叠**：击杀掉落资源的敌人、战斗中花费资源、死亡/重生与经济状态交互
- **成长 + 难度重叠**：战斗中途触发升级、能力解锁改变战斗可行性、成长里程碑处的难度缩放
- **叙事 + 玩法重叠**：对话选择锁定/解锁机制、故事节点打断资源循环、任务完成触发系统状态变化
- **3+ 系统链**：任何玩家动作触发系统 A，A 又输入系统 B，B 又触发系统 C（这些是风险最高的交互路径）

在继续之前，用一行描述列出每个识别出的场景。

### 4b：走查每个场景

对每个场景，显式地步进整个序列：

1. **触发** — 是什么玩家动作或游戏事件启动了它？
2. **激活顺序** — 哪些系统激活，按什么顺序？
3. **数据流** — 每个系统输出什么，该输出是否是链条中下一个系统的有效输入？
4. **玩家体验** — 每一步玩家看到、听到或感受到什么？
5. **失败模式** — 是否存在以下任何情况？
   - **竞态条件**：两个系统同时试图修改同一状态
   - **反馈循环**：系统 A 放大系统 B，系统 B 又反过来放大系统 A，
     且没有上限或阻尼
   - **状态转换断裂**：某个系统假定了前一个系统可能已经改变的状态
     （例如，在可能导致死亡的战斗步骤之后仍假定"玩家还活着"）
   - **相互矛盾的信息**：玩家从两个对同一事件做出反应的系统收到冲突的反馈
     （例如，"成功"音效 + "失败"UI）
   - **复合难度尖峰**：两个系统在同一成长点同时向上缩放，
     成倍放大了预期的难度提升
   - **奖励冲突**：两个系统对同一触发都给予奖励，合起来超过了预期值（重复领取）
   - **未定义行为**：GDD 未规定在此组合状态下会发生什么
     （两个系统的规则都未覆盖）

```
Example walkthrough:
Scenario: Player kills elite enemy at level-up threshold during active quest

Trigger: Player lands killing blow on elite enemy
→ combat.md: awards kill XP (100 pts)
→ progression.md: XP total crosses level threshold → triggers level-up
  Output: new level, stat increases, ability unlock popup
→ quest.md: kill-count criterion met → triggers quest completion event
  Output: quest reward XP (500 pts), completion fanfare
→ progression.md (again): quest XP added → triggers SECOND level-up in same frame
  ⚠️  Data flow issue: quest.md awards XP without checking if a level-up
  is already in progress. progression.md has no guard against concurrent
  level-up events. Undefined behavior: does the player level up once or twice?
  Does the ability popup fire twice? Does the second level use the updated or
  pre-update stat baseline?
```

### 4c：标记场景问题

对走查中发现的每个问题，按严重程度分类：

- **BLOCKER**：未定义行为、状态转换断裂，或相互矛盾的玩家信息 —
  该场景中的体验是断裂或不连贯的
- **WARNING**：复合尖峰、无上限的反馈循环、奖励冲突 —
  体验可以运行但产生了非预期的结果
- **INFO**：轻微的时序歧义或信息重叠 — 值得注意，
  但不太可能造成玩家可见的问题

将所有发现添加到输出报告中的**"Cross-System Scenario Issues"**之下。
每个发现必须引用：场景名称、涉及的具体系统、问题发生的步骤，以及失败模式的性质。

---
