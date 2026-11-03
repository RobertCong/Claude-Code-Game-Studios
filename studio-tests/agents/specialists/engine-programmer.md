# Agent Test Spec: engine-programmer

## Agent Summary
领域：渲染管线、物理集成、内存管理、资源加载与核心引擎框架。
不负责：玩法机制（gameplay-programmer）、构建基础设施（devops-engineer）、编辑器/调试工具 UI（tools-programmer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及渲染 / 内存 / 引擎核心）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对玩法机制或工具 UI 拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “为投射物实现自定义对象池，以避免逐帧分配。”
**Expected behavior:**
- 产出引擎级对象池实现，带有 acquire/release 接口
- 池按投射物对象类型定型，使用预分配的固定大小存储
- 提供线程安全说明（或明确标注为仅单线程并给出理由）
- 按编码规范包含针对公开 API 的文档注释
- 输出与项目配置的引擎和语言兼容

### Case 2: 域外请求 — 正确重定向
**Input:** “给玩家控制器添加蹬墙跳能力。”
**Expected behavior:**
- 不产出蹬墙跳玩法代码
- 明确说明玩法功能属于 `gameplay-programmer`
- 将请求重定向给 `gameplay-programmer`
- 如果它提供该能力可调用的引擎级查询（例如墙壁接触与表面法线），该 API 不依赖玩法代码（严格依赖方向）

### Case 3: 内存泄漏诊断
**Input:** “每次关卡加载内存占用增加约 50MB 且从不释放。我们怀疑是资源加载系统。”
**Expected behavior:**
- 在改动代码前通过测量诊断：内存基线、重复加载/卸载循环、记录数据（改动前后进行性能剖析）
- 审计其负责的资源加载/缓存与对象生命周期代码，查找从未释放的引用，指出可能原因（孤立的资源句柄、循环引用、从不驱逐的缓存）
- 针对已识别的泄漏模式产出具体修复
- 提供验证修复的测试（加载前内存基线，卸载后测量，确认回到基线）

### Case 4: 跨域协作 — 共享系统优化
**Input:** “我需要优化物理 broadphase，但玩法系统与物理查询 API 紧密耦合。”
**Expected behavior:**
- 不擅自更改物理查询 API 表面（会破坏 gameplay-programmer 的代码）
- 与 `lead-programmer` 协作安全规划变更
- 提出迁移路径：新优化 API 与旧 API 并存，并设弃用期
- 在继续前记录协作要求

### Case 5: 上下文传递 — 检查引擎版本参考
**Input:** 上下文中提供引擎版本参考（Godot 4.6）。请求：“为项目设置默认物理引擎。”
**Expected behavior:**
- 读取引擎版本参考并注意 Godot 4.6 变更：Jolt 物理现为默认
- 产出考虑 Jolt 成为默认这一变更的配置指导（4.6 迁移说明）
- 标记 `docs/engine-reference/godot/modules/physics.md` 记录的 GodotPhysics3D→Jolt 差异——HingeJoint3D 的 `damp` 在 Jolt 下不受支持、碰撞边距行为可能不同、Jolt 会在运行时对不支持的属性发出警告——并说明现有项目保留其当前引擎设置；说明参考资料未列出其他 API 差异，而不是自行虚构
- 不建议已弃用或 4.6 之前的物理设置步骤，除非注明其适用于旧版本

---

## Protocol Compliance

- [ ] 保持在声明的领域内（渲染、物理、内存、资源加载、核心框架）
- [ ] 将玩法功能请求重定向给 gameplay-programmer，将构建基础设施变更重定向给 devops-engineer
- [ ] 返回结构化发现（实现代码、诊断步骤、迁移计划）
- [ ] 在更改共享 API 表面之前与 lead-programmer 协作
- [ ] 在建议引擎特定 API 之前检查引擎版本参考
- [ ] 为修复提供测试证据（内存前后、性能测量）
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 对象池（Case 1）必须在 `tests/unit/engine/` 中包含单元测试
- 内存泄漏诊断（Case 3）应在 `production/qa/evidence/` 中产出证据文件
- 引擎版本检查（Case 5）确认代理将 VERSION.md 视为权威，而非 LLM 训练数据
