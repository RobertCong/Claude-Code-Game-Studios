# Agent Test Spec: godot-gdscript-specialist

## Agent Summary
领域：GDScript 静态类型、GDScript 设计模式、信号架构、协程/await 模式以及 GDScript 性能。
不负责：着色器代码（godot-shader-specialist）、GDExtension 绑定（godot-gdextension-specialist）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 GDScript / 静态类型 / 信号 / 协程）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声明对着色器代码或 GDExtension 的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "检查这个 GDScript 文件的类型标注覆盖率。"
**Expected behavior:**
- 读取所提供的 GDScript 文件
- 标记出每个缺少静态类型标注的变量、参数与返回类型
- 生成逐行的具体发现列表：`var speed = 5.0` → `var speed: float = 5.0`
- 说明 Godot 4 中静态类型在性能和工具链方面的收益
- 不擅自重写整个文件 — 而是生成发现列表供开发者自行应用

### Case 2: 领域外请求 — 正确重定向
**Input:** "写一个顶点着色器，在世界空间中扭曲网格。"
**Expected behavior:**
- 不在 GDScript 中、也不在 Godot 着色语言中生成着色器代码
- 明确说明着色器编写属于 `godot-shader-specialist`
- 将请求重定向到 `godot-shader-specialist`
- 它提供的任何帮助都停留在其重定向说明中声明拥有的脚本侧（`set_shader_parameter()`、材质赋值）— 不编写任何着色器代码

### Case 3: 使用协程的异步加载
**Input:** "异步加载一个场景，等它完成后再生成。"
**Expected behavior:**
- 为 Godot 4 生成 `await` + `ResourceLoader.load_threaded_request` 模式
- 全程使用静态类型（`var scene: PackedScene`）
- 用 `ResourceLoader.load_threaded_get_status()` 处理完成检查，在轮询之间 await 而不是阻塞帧
- 在 await 之后、生成之前检查 `is_instance_valid(self)` — 节点可能在场景加载期间已被释放
- 说明加载失败的错误处理
- 不使用已弃用的 Godot 3 `yield()` 语法

### Case 4: 性能问题 — 类型化数组建议
**Input:** "实体更新循环很慢；它每帧遍历一个含 1,000 个节点的无类型 Array。"
**Expected behavior:**
- 指出无类型 `Array` 会放弃 GDScript 编译器的优化
- 建议改为类型化数组（`Array[Node]` 或具体类型），以便编译器使用类型化代码路径
- 将类型化数组重构作为立即修复方案生成
- 说明若性能分析仍显示该循环是瓶颈，下一步是按 GDScript/GDExtension 边界，与 godot-gdextension-specialist 一起把热路径迁移到 GDExtension（C++/Rust）
- 在没有性能分析证据的情况下，不建议把循环或代码库移出 GDScript

### Case 5: 上下文校验 — Godot 4.6 与截止后特性
**Input:** 提供的引擎版本上下文：Godot 4.6。请求："使用 @abstract 为所有敌人类型创建一个抽象基类。"
**Expected behavior:**
- 识别出 `@abstract` 是 Godot 4.5+ 特性（截止后）
- 在输出中说明：该特性在 4.5 引入，已对照 `docs/engine-reference/godot/breaking-changes.md`（4.4 → 4.5 表格）确认
- 按参考资料（`current-best-practices.md`）而非训练数据，生成在类及其抽象方法上使用 `@abstract` 的 GDScript 类
- 指出 `VERSION.md` 将 `Installed at pin time` 记录为 NOT DETERMINED — 已安装编辑器必须为 4.5 或更高版本，`@abstract` 才能解析
- 对抽象类中所有方法签名使用静态类型

---

## Protocol Compliance

- [ ] 保持在声明的领域内（GDScript — 类型、模式、信号、协程、性能）
- [ ] 将着色器请求重定向到 godot-shader-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回带完整静态类型的结构化 GDScript 输出
- [ ] 仅使用 Godot 4 API — 不使用已弃用的 Godot 3 模式（yield、基于字符串的 connect 等）
- [ ] 标记 4.4 及之后的特性（4.4 恰在截止前；4.5、4.6、4.7 在截止后），并将其标注为需要查阅文档核实
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 类型标注检查（Case 1）的输出适合作为代码评审检查清单
- 异步加载（Case 3）应生成可用 `tests/unit/` 中单元测试验证的可测试代码
- 截止后的 @abstract（Case 5）确认代理会标记版本不确定性，而不是悄悄使用未经验证的 API
