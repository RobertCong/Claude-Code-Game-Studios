# Agent Test Spec: godot-gdextension-specialist

## Agent Summary
领域：GDExtension API、godot-cpp C++ 绑定、godot-rust 绑定、原生库集成以及原生性能优化。
不负责：GDScript 代码（gdscript-specialist）、着色器代码（godot-shader-specialist）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 GDExtension / godot-cpp / 原生绑定）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声明对 GDScript 或着色器编写的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "通过 GDExtension 把一个 C++ 刚体物理模拟库暴露给 GDScript。"
**Expected behavior:**
- 使用 godot-cpp 生成 GDExtension 绑定模式：
  - 类继承自 `godot::Object` 或合适的 Godot 基类
  - `GDCLASS` 宏注册
  - 实现 `_bind_methods()`，将物理 API 暴露给 GDScript
  - 模块入口点：`register_types.cpp` 中的 `initialize_module` 在 `MODULE_INITIALIZATION_LEVEL_SCENE` 层级用 `ClassDB::register_class<T>()` 注册该类，由清单（manifest）`entry_symbol` 所指的导出初始化函数到达
- 说明所需的 `.gdextension` 清单文件格式
- 不生成 GDScript 使用代码（那属于 gdscript-specialist）

### Case 2: 领域外重定向
**Input:** "编写调用 Case 1 中物理模拟的 GDScript。"
**Expected behavior:**
- 不生成 GDScript 代码
- 明确说明 GDScript 编写属于 `godot-gdscript-specialist`
- 重定向到 `godot-gdscript-specialist`
- 它提供的任何交接内容是该扩展的绑定 API 表面（方法名、参数与返回类型）— 而不是调用它的 GDScript

### Case 3: ABI 兼容性风险 — 次版本更新
**Input:** "我们正从 Godot 4.5 升级到 4.6。现有的 GDExtension 还能用吗？"
**Expected behavior:**
- 说明兼容性方向：为 4.5 构建的扩展应能在 4.6 中加载，反之则不行 — 因此它可能继续可用，但必须重新测试，并针对 4.6 重新构建以使用更新的 API
- 指引查阅 4.5→4.6 迁移指南中的 GDExtension API 变更
- 建议针对 4.6 的 godot-cpp 头文件重新构建，而不是把"应该能加载"当作已测试
- 说明 `.gdextension` 清单可能需要更新 `compatibility_minimum` 版本
- 将重新构建整理为清单：为每个目标平台重新构建 debug 与 release（`scons ... target=template_debug` / `template_release`，或 `cargo build` / `cargo build --release`），更新 `compatibility_minimum`，然后在发布前于 4.6 编辑器中重新测试

### Case 4: 内存管理 — Godot 对象的 RAII
**Input:** "我们应该如何管理在 C++ GDExtension 代码内部创建的 Godot 对象的生命周期？"
**Expected behavior:**
- 为 GDExtension 中的 Godot 对象生成基于 RAII 的生命周期模式：
  - 引用计数对象使用 `Ref<T>`（Ref 离开作用域时自动释放）
  - 非引用计数对象使用 `memnew()` / `memdelete()`
  - 警告：Godot 对象不要使用 `new`/`delete` — 属未定义行为
- 说明对象所有权规则：加入场景树的节点由谁负责释放
- 其具体示例（例如在 C++ 中创建的 `CollisionShape3D`）同时应用这两条规则：节点用 `memnew()` 创建，并用 `add_child()` 交给场景树，之后由场景树负责释放（不使用 `memdelete()`）；其形状资源保存在 `Ref<>` 中；`memdelete()` 只用于从未进入场景树的节点

### Case 5: 上下文校验 — Godot 4.6 GDExtension API 检查
**Input:** 引擎版本上下文：Godot 4.6（从 4.5 升级）。请求："检查 4.5 到 4.6 之间是否有 GDExtension API 发生变化。"
**Expected behavior:**
- 引用 VERSION.md 已验证来源列表中的 4.5→4.6 迁移指南
- 读取 `docs/engine-reference/godot/breaking-changes.md` 中的 4.5 → 4.6 表格，并明确说明其中没有 GDExtension 专属条目，同时提示需对照官方变更日志核实
- 仍指出所列出的、会影响原生代码的 4.6 变更：`Quaternion` 现在初始化为单位值（此前为零）
- 将 Windows 上默认使用 D3D12（4.6 变更）标记为可能与 GDExtension 渲染代码相关
- 提供升级后需核实事项的清单

---

## Protocol Compliance

- [ ] 保持在声明的领域内（GDExtension、godot-cpp、godot-rust、原生绑定）
- [ ] 将 GDScript 编写重定向到 godot-gdscript-specialist
- [ ] 将着色器编写重定向到 godot-shader-specialist
- [ ] 返回结构化输出（绑定模式、RAII 示例、ABI 检查清单）
- [ ] 说明兼容性仅向前（旧构建 → 更新的 Godot），且升级后需要重新测试 — 绝不把"应该能加载"当作已测试
- [ ] 使用 Godot 专属内存管理（`memnew`/`memdelete`、`Ref<T>`），而非原生 C++ new/delete
- [ ] 在确认兼容性前检查引擎版本参考资料中的 GDExtension API 变更
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 绑定模式（Case 1）应包含冒烟测试，验证扩展可加载且该方法可从 GDScript 调用
- ABI 风险（Case 3）是关键的升级上报路径 — 代理不得批准发布未经验证的扩展二进制文件
- 内存管理（Case 4）验证代理应用 Godot 专属模式，而非通用 C++ RAII
