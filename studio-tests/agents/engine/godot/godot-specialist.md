# Agent Test Spec: godot-specialist

## Agent Summary
领域：Godot 专属模式、节点/场景架构、信号、资源，以及 GDScript vs C# vs GDExtension 的选择。
不负责：特定语言中的实际代码编写（委托给各语言子专家）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Godot 架构 / 节点模式 / 引擎选型）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 `inherit` — frontmatter `model:` 的内容恰好为 `inherit`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义引用 `docs/engine-reference/godot/VERSION.md` 作为权威 API 来源

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "在 Godot 中，什么时候该用信号，什么时候该用直接方法调用？"
**Expected behavior:**
- 生成带理由的模式决策指南：
  - 信号：解耦通信、父节点无需知晓子节点、事件驱动的 UI 更新、一对多通知
  - 直接调用：紧耦合系统且调用方需要返回值，或性能关键的热路径
- 用具体的 Godot 案例说明两侧（例如子节点生命值组件发出类型化的 `health_changed` 信号，由其父节点或 HUD 监听；父节点调用其拥有的子节点上的方法）
- 不为两种模式都生成原始代码 — 实现细节指向 gdscript-specialist 或 csharp-specialist
- 说明 "call down, signal up"（向下调用、向上发信号）约定：子节点不直接调用父节点的方法 — 而是发出信号 — 从而使每个场景保持自包含，不对父节点产生隐式依赖

### Case 2: 错误引擎重定向
**Input:** "写一个在 Start() 时运行并订阅 UnityEvent 的 MonoBehaviour。"
**Expected behavior:**
- 不生成 Unity MonoBehaviour 代码
- 明确指出这是 Unity 模式，不是 Godot 模式
- 将概念映射到 Godot：用 `_ready()` 代替 `Start()`，用在 `_ready()` 中连接的类型化 Godot `signal` 代替 UnityEvent
- 以项目锁定的引擎为依据作答（`docs/engine-reference/godot/VERSION.md`，Godot 4.7），而不是询问项目使用哪个引擎
- 将实际节点脚本转交给 godot-gdscript-specialist 或 godot-csharp-specialist，而非自己编写
- 变体：当 `project.yaml` 中 `engine.name: Unity` 时，说明自己不是该项目的正确专家，而不是映射概念

### Case 3: 截止后 API 风险
**Input:** "使用新的 Godot 4.5 @abstract 注解定义一个抽象基类。"
**Expected behavior:**
- 识别出 `@abstract` 是截止后特性（在 Godot 4.5 引入，晚于 LLM 知识截止点）
- 标记版本风险：LLM 对该注解的知识可能不完整或错误，因此以参考资料为准
- 在作答前对照版本参考资料确认该特性 — `docs/engine-reference/godot/breaking-changes.md` 在其 4.4 → 4.5 表格中列出了 `@abstract` 装饰器
- 标记已安装版本的缺口：`VERSION.md` 将 `Installed at pin time` 记录为 NOT DETERMINED，因此必须先确认已安装编辑器为 4.5 或更高版本，`@abstract` 代码才能解析
- 将类的编写转交给 godot-gdscript-specialist，而非自己编写该类

### Case 4: 热路径的语言选择
**Input:** "物理查询循环每帧对 500 个对象运行。我们应该用 GDScript 还是 C#？"
**Expected behavior:**
- 提供平衡的分析：
  - GDScript：更简单、团队熟悉，但在紧凑循环中较慢
  - C#：在 CPU 密集型循环中更快，需要 .NET 运行时，团队需具备 C# 知识
- 不单方面做最终决定 — 呈现取舍交由用户决定
- 指出将 C#/.NET（或 GDExtension 模块）引入项目是重大技术选择，需要 `technical-director` 签字批准，而非它独自决定
- 说明 GDExtension（C++）是极端性能场景下的第三种选择，并建议在 C# 不足时上报

### Case 5: 上下文校验 — 引擎版本 4.6
**Input:** 提供的引擎版本上下文：Godot 4.6，Jolt 为默认物理引擎。请求："为玩家角色设置 RigidBody3D。"
**Expected behavior:**
- 读取 4.6 上下文与物理模块参考资料（`docs/engine-reference/godot/modules/physics.md`），而非仅依赖 LLM 训练数据
- 说明参考资料记载的内容：Jolt 是新项目的默认 3D 引擎，但现有项目保留其设置 — 因此在假定使用 Jolt 前先检查 Project Settings → Physics → 3D → Physics Engine
- 沿用资料中记录的、适用的 Jolt 差异：碰撞边距（collision margin）行为可能不同，且 Jolt 会对其不支持的属性发出运行时警告（例如 HingeJoint3D 的 `damp`）
- 不杜撰 GodotPhysics 与 Jolt 之间 RigidBody3D 的属性变化 — 参考资料未记录任何变化，并会如实说明

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Godot 架构决策、节点/场景模式、语言选择）
- [ ] 将语言相关实现重定向到 godot-gdscript-specialist 或 godot-csharp-specialist
- [ ] 返回结构化发现（决策树、带理由的模式建议）
- [ ] 将 `docs/engine-reference/godot/VERSION.md` 视为优先于 LLM 训练数据的权威来源
- [ ] 标记 4.4 及之后的 API 使用（4.4 恰在截止前；4.5、4.6、4.7 在截止后）并附核实要求
- [ ] 将语言选择决定留给用户，并将新语言或运行时的采用上报给 technical-director
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 信号 vs 直接调用指南（Case 1）应写入 `docs/architecture/` 作为可复用的模式文档
- 截止后标记（Case 3）确认代理不会自信地使用无法验证的 API
- 引擎版本用例（Case 5）验证代理应用版本参考资料中的迁移说明，而非假设
