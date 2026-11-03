# /review-all-gdds — Phase 2: 跨 GDD 一致性

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 2: 跨 GDD 一致性

**本文件包含：**

- 2a：依赖双向性
- 2b：规则矛盾
- 2c：过期引用
- 2d：数据与调参旋钮归属冲突
- 2e：公式兼容性
- 2f：验收标准交叉校验

逐一处理每一对和每一组 GDD，找出矛盾与缺口。

### 2a：依赖双向性

对每个 GDD 的 Dependencies 章节，检查每个列出的依赖是否互为对应：
- 如果 GDD-A 列出"依赖 GDD-B"，检查 GDD-B 是否将 GDD-A 列为被依赖方
- 如果 GDD-A 列出"被 GDD-C 依赖"，检查 GDD-C 是否将 GDD-A 列为依赖
- 将任何单向依赖标记为一致性问题

```
⚠️  Dependency Asymmetry
[system-a].md lists: Depends On → [system-b].md
[system-b].md does NOT list [system-a].md as a dependent
→ One of these documents has a stale dependency section
```

### 2b：规则矛盾

对于任何 GDD 中定义的每条游戏规则、机制或约束，检查是否有其他 GDD 针对同一情形定义了相矛盾的规则：

需扫描的类别：
- **下限/上限规则**：是否有某个 GDD 为某项输出定义了最小值？是否有另一个 GDD 说其他系统可以绕过该下限？这两者相互矛盾。
- **资源归属**：如果两个 GDD 都定义了共享资源如何累积或消耗，它们是否一致？
- **状态转换**：如果 GDD-A 描述了角色死亡时会发生什么，GDD-B 对同一事件的描述是否一致？
- **时序**：如果 GDD-A 说"X 在同一帧发生"，GDD-B 是否假设它是异步发生的？
- **叠加规则**：如果 GDD-A 说状态效果可以叠加，GDD-B 是否假设它们不能？

```
🔴 Rule Contradiction
[system-a].md: "Minimum [output] after reduction is [floor_value]"
[system-b].md: "[mechanic] bypasses [system-a]'s rules and can reduce [output] to 0"
→ These rules directly contradict. Which GDD is authoritative?
```

### 2c：过期引用

**从 GDD 的 `## Cross-References` 表开始（如果它有的话）。** 该表是文档自己对所依赖内容的声明 — `templates/guidance/game-design-document-guide.md` 告知作者它在此处会接受机器校验，且每当 Dependencies 指明另一个 GDD 时 `/design-system` 都要求该表。对每一行，确认 `Target GDD` 存在，且 `Specific Element Referenced` 在该 GDD 中仍以该名称存在，并确认所声明的 `Nature` 仍然准确。

表不存在，或仍保留模板的方括号示例，这本身就可报告：说明该 GDD 未声明任何交叉引用，且下方仅执行了正文扫描。不要把缺失的表视为"没有依赖" — 它更常见地意味着该章节从未编写。

**然后无论如何都扫描正文**，无论有无表：声明式的表能捕捉作者记得的内容，而下方的扫描能捕捉他们没记得的内容。

对于每个跨文档引用（GDD-A 提到来自 GDD-B 的某个机制、数值或系统名称），验证被引用元素在 GDD-B 中是否仍以相同名称和行为存在：

- 如果 GDD-A 说"战斗系统的连击倍率会输入到得分中"，检查战斗 GDD 是否实际定义了会输出到得分的连击倍率
- 如果 GDD-A 引用"[system].md 中定义的成长曲线"，检查 [system].md 是否实际具有该曲线，而不是另一种成长模型
- 如果 GDD-A 编写早于 GDD-B，并假设了某个机制，而 GDD-B 后来设计得不同，则将 GDD-A 标记为包含过期引用。严重程度：引用一个**不存在**的机制或公式属于 **Blocking** — 架构会继承一条没人定义过的规则；引用一个存在但设计不同的机制属于 **Warning**，除非该差异改变了引用方 GDD 所依赖的某条规则（此时为 Blocking）
- 如果**目标 GDD 尚未编写**（`design/gdd/` 中没有文件）：当 `systems-index.md` 列出了该系统（例如 `Status: Not Started`）时，属于 **Warning** — 这是对计划中工作的依赖，待该 GDD 编写时再复查；当该系统既没有 GDD 也没有 systems-index 条目时，属于 **Blocking** — 永远不会有人定义它

```
🔴 Stale Reference
inventory.md (written first): "Item weight uses the encumbrance formula
  from movement.md"
movement.md (written later): Defines no encumbrance formula — uses a flat
  carry limit instead
→ inventory.md references a formula that doesn't exist — Blocking
```

### 2d：数据与调参旋钮归属冲突

两个 GDD 不应同时声称拥有同一份数据或同一个调参旋钮。扫描所有 GDD 的 Tuning Knobs 章节并标记重复项：

```
⚠️  Ownership Conflict
[system-a].md Tuning Knobs: "[multiplier_name] — controls [output] scaling"
[system-b].md Tuning Knobs: "[multiplier_name] — scales [output] with [factor]"
→ Two GDDs define multipliers on the same output. Which owns the final value?
  This will produce either a double-application bug or a design conflict.
```

### 2e：公式兼容性

对于公式彼此相连的 GDD（一个的输出作为另一个的输入），检查上游公式的输出范围是否落在下游公式的预期输入范围内：

- 如果 [system-a].md 输出的值在 [min]–[max] 之间，而 [system-b].md 被设计为接收 [min2]–[max2] 之间的值，这种不匹配是有意为之吗？
- 如果经济 GDD 期望资源获取落在范围 X，而成长 GDD 以范围 Y 生成资源，那么经济系统会变得无关紧要或不可达 — 这是有意设计的吗？

将不兼容标记为 CONCERNS（需要设计判断，不一定错误）：

```
⚠️  Formula Range Mismatch
[system-a].md: Max [output] = [value_a] (at max [condition])
[system-b].md: Base [input] = [value_b], max [input] = [value_c]
→ Late-[stage] [scenario] can resolve in a single [event].
  Is this intentional? If not, either [system-a]'s ceiling or [system-b]'s ceiling needs adjustment.
```

### 2f：验收标准交叉校验

扫描所有 GDD 的 Acceptance Criteria 章节以寻找矛盾：

- GDD-A 标准："玩家不能因单次攻击死亡"
- GDD-B 标准："首领攻击造成玩家最大生命值 150% 的伤害"
这些验收标准无法同时通过。

---
