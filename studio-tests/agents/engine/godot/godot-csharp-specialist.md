# Agent Test Spec: godot-csharp-specialist

## Agent Summary
领域：Godot 4 中的 C# 模式、应用于 Godot 的 .NET 惯用法、`[Export]` 特性用法、信号委托以及 async/await 模式。
不负责：GDScript 代码（gdscript-specialist）、GDExtension C/C++ 绑定（gdextension-specialist）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Godot 4 中的 C# / .NET 模式 / 信号委托）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声明对 GDScript 或 GDExtension 代码的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "为敌人生命值创建一个导出属性，并带校验，将其钳制在 1 到 1000 之间。"
**Expected behavior:**
- 生成带 `[Export]` 特性的 C# 属性
- 使用后备字段配合属性 getter/setter，在 setter 中对取值进行钳制
- 不使用未经校验的裸 `[Export]` 公共字段
- 遵循 Godot 4 C# 命名约定（属性用 PascalCase，字段为私有并带下划线前缀）
- 按编码规范为属性添加 XML 文档注释

### Case 2: 领域外请求 — 正确重定向
**Input:** "用 GDScript 重写这套敌人生命值系统。"
**Expected behavior:**
- 不生成 GDScript 代码
- 明确说明 GDScript 编写属于 `godot-gdscript-specialist`
- 将请求重定向到 `godot-gdscript-specialist`
- 它提供的任何交接内容只描述现有 C# 系统的 API（其信号与公共方法），供 godot-gdscript-specialist 移植 — 其中不含任何 GDScript

### Case 3: 异步信号等待
**Input:** "使用 C# async 等待动画播放完毕，再切换游戏状态。"
**Expected behavior:**
- 生成正确的 `async Task` 模式，使用 `ToSignal()` 等待 Godot 信号
- 使用 `await ToSignal(animationPlayer, AnimationPlayer.SignalName.AnimationFinished)`
- 不使用 `Thread.Sleep()` 或 `Task.Delay()` 作为轮询替代方案
- 说明调用方法必须为 `async`，并且即发即忘的 `async void` 仅在事件处理器中可接受
- 在 `await` 之后、切换状态之前检查 `IsInstanceValid(this)` — 节点可能在等待期间已被释放
- 若动画可能永远不结束（被中断、被替换），将其作为未明确的边界情况提出交由用户决定；它添加的任何超时都使用 `GetTree().CreateTimer()`，绝不使用 `Task.Delay()`

### Case 4: 线程模型冲突
**Input:** "这段 C# 代码从后台 Task 线程访问 Godot Node 来更新其位置。"
**Expected behavior:**
- 将其标记为竞态条件风险：Godot 节点不是线程安全的，只能从主线程访问
- 不批准也不实现多线程访问节点的模式
- 提供正确模式：使用 `CallDeferred()`、`Callable.From().CallDeferred()`，或通过线程安全队列编组回主线程
- 解释为何代码能编译却不安全：`Task` 主体运行在 .NET 线程池线程上，C# 中没有任何机制阻止它触碰 Node — 主线程规则属于 Godot 的场景树

### Case 5: 上下文校验 — Godot 4.7 API 正确性
**Input:** 引擎版本上下文：Godot 4.7。请求："使用新的类型化信号委托模式连接一个信号。"
**Expected behavior:**
- 使用 Godot 4 C# 引入的类型化委托模式生成 C# 信号连接（对类型化信号使用 `+=` 运算符）
- 检查 4.7 上下文，确认信号委托 API 在 4.4、4.5、4.6 或 4.7 中无破坏性变更
- 不使用旧的基于字符串的 `Connect("signal_name", callable)` 模式（在 Godot 4 C# 中已弃用）
- 生成的代码与 VERSION.md 中记录的项目锁定版本 4.7 兼容

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Godot 4 中的 C# — 模式、导出、信号、async）
- [ ] 将 GDScript 请求重定向到 godot-gdscript-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回遵循 Godot 4 约定的 C# 代码（而非 Unity MonoBehaviour 模式）
- [ ] 将多线程访问 Godot 节点标记为不安全，并提供正确模式
- [ ] 使用类型化信号委托 — 而非已弃用的基于字符串的 Connect() 调用
- [ ] 在生成代码前检查引擎版本参考资料中的 API 变更
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 带校验的导出属性（Case 1）应有单元测试验证钳制行为
- 线程冲突（Case 4）属于安全关键项：代理必须无需提示即可识别并修复
- 异步信号（Case 3）验证代理在 Godot 单线程约束下正确应用 .NET 惯用法
