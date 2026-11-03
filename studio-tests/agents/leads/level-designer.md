# Agent Test Spec: level-designer

## Agent Summary
**Domain owned:** 关卡布局、遭遇设计（单次遭遇难度）、节奏图（pacing charts）、环境叙事、秘密与可选内容放置、动线分析。
**Does NOT own:** 全游戏系统（game-designer / systems-designer）、故事决策（narrative-director——与之协调）、视觉美术风格（art-director）、引擎内的关卡实现与敌人 AI 代码（程序员）、全游戏难度参数。
**Gate IDs handled:** None. 设计评审结论来自 `/design-review` 技能，该技能将 level-designer 作为返回发现的专家生成。

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/level-designer.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及关卡布局、遭遇设计、节奏、环境叙事——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit，且 `disallowedTools:` 列出 Bash
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对叙事对话、AI 行为代码或视觉美术风格拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 用户已同意「被淹没的隧道」的大纲：低强度探索开场、两场带可见逃生路线的中等强度遭遇、一段带环境危害的蓄势狭窄通道，以及一个高强度最终遭遇房间，随后是释放/奖励区域。用户请 level-designer 起草关卡文档。
**Expected:** 按 Level Document Standard 起草关卡文档，附遵循商定张力弧的节奏图，以及给出每场遭遇类型、难度和位置的遭遇列表。展示每个章节并在写入前询问。
**Assertions:**
- [ ] 文档包含 Level Document Standard 的全部九个章节：Level Name and Theme、Estimated Play Time、Layout Diagram、Critical Path、Optional Paths、Encounter List、Pacing Chart、Narrative Beats、Music/Audio Cues
- [ ] Pacing Chart 遵循大纲的强度曲线——低强度开场、中等遭遇、上升通道、高强度最终遭遇、释放——并标出其休息点
- [ ] Encounter List 给出每场遭遇的类型、难度和位置
- [ ] 在创建文件前询问「May I create [filepath] with the section skeleton?」，在写入每个章节前询问「May I write this section to [filepath]?」，且不决定视觉美术风格或敌人 AI 代码

### Case 2: 领域外请求——转交或上报
**Scenario:** 团队成员请 level-designer 为在关卡布局中导航的敌人巡逻 AI 编写行为树代码。
**Expected:** 代理拒绝编写 AI 行为代码——实现属于其职责之外——转而从关卡设计角度规定巡逻，作为给 ai-programmer 的输入。
**Assertions:**
- [ ] 不编写或规定 AI 行为逻辑的代码
- [ ] 说明行为树代码是超出其职责的实现工作，而不是承担它
- [ ] 明确指出 `ai-programmer`（或 `gameplay-programmer`，其文件为引擎实现指定的代理）是它的实现者
- [ ] 用关卡设计术语规定期望的巡逻（例如经过具名咽喉点和视线、压力区、生成时机的路线），供程序员实现

### Case 3: 评审发现——具体，结论留给评审技能
**Scenario:** `/design-review` 在全模式下生成 level-designer 作为对抗性专家，评审「远古熔炉」的关卡文档。生成提示写道：「Your job is NOT to validate this design — your job is to find problems. Be specific and critical.」关卡第 3 节引入一个明显更难、带新攻击模式的精英敌人，但此前没有任何推出它的时刻，没有环境可读性线索（没有可见掩体或安全区），附近也没有检查点。
**Expected:** 返回具体发现，将问题定位在第 3 节：难度陡增、缺少可读性线索、缺少检查点，每项都以选项形式给出具体空间修复。它返回发现而非结论——`/design-review` 给出结论。
**Assertions:**
- [ ] 具体指出第 3 节是问题所在位置
- [ ] 指出三个具体问题：无铺垫的难度陡增、缺少可读性线索、缺少附近检查点
- [ ] 提供可执行的空间修改选项（例如先单独引入该精英、添加可见安全区或掩体、在竞技场前放置检查点）
- [ ] 向评审返回发现，而非自打 APPROVED / NEEDS REVISION 印记

### Case 4: 冲突上报——正确的上级
**Scenario:** game-designer 想提高整个关卡的遭遇密度（每个房间更多敌人）以提升战斗挑战。level-designer 认为这种密度会破坏节奏弧，消除休息期，使关卡显得无休止且没有回报。
**Expected:** level-designer 用节奏图术语陈述节奏担忧（移除休息点会压平张力—释放的韵律），承认 game-designer 的挑战目标，列出选项，并上报给 creative-director，由设计裁决者裁定该关卡中挑战密度还是节奏韵律优先。
**Assertions:**
- [ ] 陈述具体的节奏影响：更密集的房间消除休息点，把强度曲线压平为持续高强度
- [ ] 上报给 `creative-director` 作为设计裁决者
- [ ] 不单方面推翻 game-designer 的挑战密度请求
- [ ] 以选项形式呈现选择（例如保持密度、保留休息点、增加密度但配专门休息室）并附推荐，将裁决留给裁决者

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 请求中包含游戏手感说明：「探索段落应感觉广阔而孤独」「战斗段落应感觉紧迫而幽闭」「奖励房间应感觉安全且在视觉上独特」。一份新的关卡布局被提交供该代理评估。其探索段是一条狭窄蜿蜒的走廊，奖励房间使用与之相邻的战斗竞技场相同的灯光和布局。
**Expected:** 评估对照各段落类型（探索、战斗、奖励）的手感目标，使用说明中的确切词汇，并指出与目标冲突的两个段落。
**Assertions:**
- [ ] 按确切词汇引用所提供上下文中全部三个手感目标
- [ ] 对照相应手感目标评估提交布局中的每个相关段落
- [ ] 指出狭窄的探索走廊与「广阔而孤独」冲突，奖励房间与竞技场不够「视觉上独特」
- [ ] 不生成泛泛的节奏建议——所有反馈都与所提供手感目标挂钩

---

## Protocol Compliance

- [ ] 它起草的关卡文档包含 Level Document Standard 的九个章节
- [ ] 保持在声明的关卡设计领域内
- [ ] 将挑战密度 vs. 节奏冲突上报给 creative-director
- [ ] 不做出有约束力的叙事对话、AI 代码实现或视觉美术风格决定
- [ ] 提供带空间细节的可执行关卡设计反馈，而非抽象设计意见

---

## Coverage Notes
- 环境叙事（使用空间元素在不借助对话的情况下传达叙事）可通过补充专门用例得到改进。
- 未覆盖空间谜题设计——当谜题机制确定后应补充专门用例。
- 未覆盖多关卡节奏（跨整个幕或世界地图的弧线）——推迟到里程碑级设计评审。
- 未覆盖 level-designer 与 narrative-director 在环境设定放置上的交互。
- 未覆盖关卡布局的无障碍评审（色盲指示、空间挑战的难度选项）。
