# Agent Test Spec: ue-gas-specialist

## Agent Summary
- **Domain**: Gameplay Ability System（GAS）—— 技能（UGameplayAbility）、游戏效果（UGameplayEffect）、属性集（UAttributeSet）、游戏标签、技能任务（UAbilityTask）、技能规格（FGameplayAbilitySpec）、GAS 预测与延迟补偿
- **Does NOT own**: 技能状态的 UI 显示（ue-umg-specialist）、超出 GAS 内置预测的 GAS 数据网络复制（ue-replication-specialist）、技能反馈的美术或 VFX（technical-artist）
- **Gate IDs**: None；跨领域调用交由相应专家

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 GAS、技能、GameplayEffect、AttributeSet）
- [ ] `tools:` 为 Read、Glob、Grep、Write、Edit、Bash —— 无 `Agent` 工具
- [ ] 模型档位为 `sonnet` —— frontmatter `model:` 精确为 `sonnet`（档位见：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UI 实现或底层网络序列化拥有权限

---

## Test Cases

### Case 1: In-domain request — 带冷却的冲刺技能
**Input**: "实现一个冲刺技能，使玩家向前移动 500 单位，冷却时间 1.5 秒。"
**Expected behavior**:
- 产出 GAS AbilitySpec 结构或大纲：一个派生自项目基础技能类（而非原始 UGameplayAbility）的技能，含 ActivateAbility 逻辑、用于移动的 AbilityTask（例如 AbilityTask_ApplyRootMotionMoveToForce 或自定义 root motion），以及用于冷却的 UGameplayEffect
- 冷却 GameplayEffect 使用 Duration 策略，时长为 1.5 秒，并用一个 GameplayTag 阻止再次激活
- 标签按层级约定清晰命名（例如 Ability.Dash、Cooldown.Ability.Dash）
- 输出同时包含技能类大纲和 GameplayEffect 定义

### Case 2: Mixed-domain request — 冷却复制供给 UI
**Input**: "如何把玩家的技能冷却状态复制到所有客户端，以便 UI 正确更新？"
**Expected behavior**:
- 用 GAS 内置能力回答复制部分：冷却是一个授予冷却标签的 Duration Gameplay Effect，通过 AbilitySystemComponent 复制
- 解释三种 ASC 复制模式（Full、Mixed、Minimal）以及各自向哪些客户端传递冷却状态
- 不会为 GAS 已复制的状态编写自定义复制（RepNotify 属性或 RPC）—— 效果驱动的属性变更会自动复制，不得重复复制
- 将冷却指示器 UI 交给 ue-umg-specialist，并指明由 ue-replication-specialist 处理 ASC 内置能力之外的多玩家预测问题

### Case 3: Domain boundary — 错误的 GameplayTag 层级
**Input**: "我们有一个技能施加名为 'Stunned' 的标签，另一个技能检查 'Status.Stunned'。它们匹配不上。"
**Expected behavior**:
- 找出根因：标签名必须精确匹配，或通过 TagContainer 查询使用层级匹配
- 指出命名不一致：'Stunned' 是根级标签；'Status.Stunned' 是 'Status' 下的子标签 —— 它们是不同的标签
- 建议项目标签命名约定：所有状态效果放在 Status.* 下，所有技能放在 Ability.* 下
- 给出修复方案：要么将被施加的标签重命名为 'Status.Stunned'，要么将查询更新为匹配 'Stunned'
- 说明标签定义应放在何处（DefaultGameplayTags.ini 或 DataTable）

### Case 4: Conflict — 两个技能之间的属性集冲突
**Input**: "我们的 Shield 技能和 Armor 技能都修改 'DefenseValue' 属性。它们以非预期方式叠加 —— 两者都激活后，防御值远超上限。"
**Expected behavior**:
- 找出原因：两个不同的 Gameplay Effect 都修改 DefenseValue，且没有任何东西约束它们的合计结果
- 用其自身的 Attribute Set 规则解决：DefenseValue 获得明确的 min/max，`PreAttributeChange()` 将当前值钳制到该范围 —— 对于瞬时效果对基础值的修改，则使用 `PreAttributeBaseChange()` 或 `PostGameplayEffectExecute()`，正如所固定的 GAS 参考资料中「Clamping Attributes」所述 —— 从而使任何效果组合都无法将其推过上限
- 它提出的其他任何方案（Execution Calculation、改变两个效果的组合方式）都建立在钳制之上，而非替代钳制；它不会把叠加策略当作修复方案 —— 叠加策略管的是同一效果的重复施加，而非两个不同效果 —— 也不会把 Override 修饰符当作上限
- 不会提议移除其中一个技能作为解决方案

### Case 5: Context pass — 基于现有属性集进行设计
**Input context**: 项目已有 AttributeSet，属性为：Health、MaxHealth、Stamina、MaxStamina、Defense、AttackPower。
**Input**: "设计一个 Berserker 技能，当 Health 低于 30% 时使 AttackPower 提高 50%。"
**Expected behavior**:
- 使用现有的 Health、MaxHealth 和 AttackPower 属性 —— 不会在不说明这是对现有 AttributeSet 的变更并先行询问的情况下新增属性
- 将 +50% 实现为带 AttackPower 修饰符的 Infinite Gameplay Effect —— 绝不直接写入 AttackPower
- 响应 Health 变化（例如在 `PostGameplayEffectExecute()` 中，或使用等待事件的 Ability Task），在低于 MaxHealth 的 30% 时施加该效果，高于时移除
- 按其标准记录该效果：修改什么、叠加行为、持续时间、移除条件
- 用层级 Gameplay Tag（例如 `Effect.Buff.Berserk`）跟踪激活状态，而不是布尔值
- 引用所提供 AttributeSet 中的实际属性名（AttackPower，而非 "Damage" 或 "Strength"）

---

## Protocol Compliance

- [ ] 保持在声明领域内（GAS：技能、效果、属性、标签、技能任务）
- [ ] 将 GAS 状态复制保留在 ASC 内（不做重复复制）；将技能 UI 交给 ue-umg-specialist，将多玩家预测问题交给 ue-replication-specialist
- [ ] 返回结构化发现（技能大纲 + GameplayEffect 定义），而非含糊描述
- [ ] 主动执行标签层级命名约定
- [ ] 只使用所提供上下文中存在的属性和标签；新增前将其标记为对现有集合的变更
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件

---

## Coverage Notes
- Case 3（标签层级）是细微缺陷的常见来源；每当标签命名约定变更时都要测试
- Case 4 测试代理自身的钳制规则（`PreAttributeChange()` 对照定义的 min/max，以及瞬时效果的基础值钩子）；叠加策略和 Override 修饰符无法为两个不同效果设上限，因此只作为补充被接受
- Case 5 是最重要的上下文感知测试；未通过则意味着代理忽略了项目状态
- 无自动运行器；请手动审查或通过 `/skill-test`
