# Agent Test Spec: ai-programmer

## Agent Summary
领域：NPC 行为、状态机、寻路、感知系统与 AI 决策。
不负责：玩家机制（gameplay-programmer）、渲染或引擎内部实现（engine-programmer）、敌人行为设计（game-designer）、导航网格（navmesh）制作工具（tools-programmer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及 NPC 行为 / AI 系统）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对玩家机制或引擎渲染拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “为守卫 NPC 实现一套巡逻与警戒行为树：在路径点之间巡逻，在 10 个单位内发现玩家，然后进入警戒状态并追击。”
**Expected behavior:**
- 产出一份行为树规格（节点：Selector、Sequence、Leaf 动作）以及相应的代码骨架
- 清晰命名状态：Patrol、Alert、Pursue
- 将感知/检测检查作为条件节点使用，而不是内联在移动代码中
- 路径点由数据驱动（作为资源或 export 传入），而非硬编码坐标
- 输出中包含针对公开 API 的文档注释

### Case 2: 域外请求 — 正确重定向
**Input:** “做一个编辑器工具，让关卡设计师可以绘制导航网格区域并烘焙。”
**Expected behavior:**
- 不构建导航网格制作工具
- 明确说明这超出其领域（导航网格制作工具属于 tools-programmer）
- 将请求重定向给 `tools-programmer`
- 其向工具负责人提供的任何输入，都是自身寻路对烘焙后导航网格的需求（代理半径、区域成本、动态障碍物支持）——而不是工具本身

### Case 3: 跨域协作 — 关卡约束
**Input:** “为仓库关卡设计寻路，但该关卡有狭窄走廊会让导航网格混乱。”
**Expected behavior:**
- 不擅自修改关卡布局或导航网格资源
- 与 `level-designer` 协作，澄清导航网格需求和走廊尺寸
- 提出以关卡几何为条件的寻路方案（例如调校代理半径的导航网格、流场）
- 记录假设并清晰标记阻塞项

### Case 4: 自身领域内的性能工作 — 自定义数据结构
**Input:** “寻路优先队列是瓶颈；为了性能我需要一个自定义二叉堆实现。”
**Expected behavior:**
- 将堆视为自身工作：“实现并优化寻路”是其关键职责，优先队列属于寻路代码的一部分——不会把堆交给 engine-programmer
- 提出该堆方案（接口、预期操作及其成本），在编写前先征求同意
- 将寻路更新控制在每帧 2ms 的 AI 预算内
- 仅当修复需要改动核心引擎系统（其“不得”条款）时才涉及 `engine-programmer`，而不是为堆本身

### Case 5: 上下文传递 — 依据关卡布局与遭遇规格实现
**Input:** 上下文中提供：一份关卡布局文档（来自 level-designer），标出巡逻路径点 A–D 和两个咽喉点——(12, 0) 处的门口和 (40, 5) 处的桥；以及一份遭遇规格（来自 game-designer），写明“受到警戒时，守卫撤回最近的咽喉点并坚守”。请求：“实现该关卡守卫的巡逻与警戒响应。”
**Expected behavior:**
- 引用所提供布局中的具体路径点和咽喉点坐标
- 严格按照遭遇规格所述实现警戒转换（撤回最近的咽喉点并坚守）——不自行设计威胁响应
- 将路径点和咽喉点保存在数据中，而不是硬编码坐标
- 不虚构文档未给出的几何或行为；当文档留下未决情形（例如两个咽喉点距离相同时），向规格负责人提问而不是自行决定

---

## Protocol Compliance

- [ ] 保持在声明的领域内（NPC 行为、寻路、感知、状态机）
- [ ] 将域外请求重定向给正确的代理（导航网格制作工具交给 tools-programmer，核心引擎系统交给 engine-programmer，敌人行为设计交给 game-designer）
- [ ] 返回结构化发现（行为树规格、状态机图、代码骨架）
- [ ] 未经明确委派，不修改玩家机制文件
- [ ] 自行完成寻路性能工作（包括数据结构），仅在改动核心引擎系统时涉及 engine-programmer
- [ ] 使用数据驱动的 NPC 配置（路径点、检测半径），而非硬编码值
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 行为树输出（Case 1）应通过 `tests/unit/ai/` 中的单元测试验证
- 关卡布局上下文（Case 5）验证代理是依据所提供文档实现，而不是虚构几何或自行设计敌人行为
- 寻路性能（Case 4）确认代理将工作保持在其关键职责分配范围内，仅在核心引擎改动时才涉及 engine-programmer
