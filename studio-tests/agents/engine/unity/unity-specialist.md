# Agent Test Spec: unity-specialist

## Agent Summary
领域：Unity 专属架构模式、MonoBehaviour vs DOTS 决策，以及子系统选型（Addressables、New Input System、UI Toolkit、Cinemachine 等）。
不负责：语言层面的深度细节（委托给 unity-dots-specialist、unity-ui-specialist 等）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Unity 模式 / MonoBehaviour / 子系统选型）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义认可子专家路由表（DOTS、UI、Shader、Addressables）

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "存储敌人配置数据，我应该用 MonoBehaviour 还是 ScriptableObject？"
**Expected behavior:**
- 生成模式决策树，涵盖：
  - MonoBehaviour：用于运行时行为，需要挂载到 GameObject，具有 Update() 生命周期
  - ScriptableObject：用于纯数据/配置，以资源形式存在，可跨实例共享，无场景依赖
- 对敌人配置数据推荐 ScriptableObject（无状态、可复用、设计师友好）
- 说明 MonoBehaviour 可在运行时引用该 ScriptableObject
- 给出 ScriptableObject 类定义的具体示例（不生成完整代码 — 实现细节指向 engine-programmer 或 gameplay-programmer）

### Case 2: 错误引擎重定向
**Input:** "为这个敌人系统搭建一套带信号的 Node 场景树。"
**Expected behavior:**
- 不生成 Godot Node/signal 代码
- 指出节点树与信号是 Godot 概念
- 从 `project.yaml` 中的 `engine.name` 确认项目引擎，而不是猜测；若不是 Unity，说明自己不是该项目的正确专家，而不是做概念转译
- 若 `engine.name` 未设置，说明未配置引擎并询问项目使用哪个引擎 — 不假定是 Unity
- 在 Unity 项目中映射概念：节点树 → 由组合式 MonoBehaviour 构成的 GameObject 层级；信号 → C# 事件或 UnityEvent（与其自身"使用事件而非 `SendMessage()` / `Find()`"的规则一致）
- 不把请求交给 Godot 专家 — 其代理授权仅覆盖四个 Unity 子专家

### Case 3: Unity 版本 API 标记
**Input:** "使用新的 Unity 6 GPU resident drawer 进行批量渲染。"
**Expected behavior:**
- 在作答前检查 `docs/engine-reference/unity/VERSION.md` 与 `docs/engine-reference/unity/modules/rendering.md`，而非训练数据（版本文件将 Unity 6 置于模型知识截止点之后）
- 说明参考资料记载的内容：GPU Resident Drawer 是 Unity 6+ 特性，在 URP Asset 中启用（Rendering > GPU Resident Drawer），因此需要 SRP 项目
- 标记已安装版本的缺口：当版本文件中的 `Installed at pin time` 未确定时，在推荐该特性前先询问已安装的编辑器版本
- 不因参考资料锁定 Unity 6 就假定已安装编辑器是 Unity 6
- 提出对 URP Asset 的修改并在编辑前询问；将超出该设置范围的渲染管线定制转交给 `unity-shader-specialist`

### Case 4: DOTS vs. MonoBehaviour 冲突
**Input:** "战斗系统用 MonoBehaviour 做状态管理，但我们想加入基于 DOTS 的弹射物系统。二者能共存吗？"
**Expected behavior:**
- 识别这是混合架构场景
- 按 `docs/engine-reference/unity/plugins/dots-entities.md` 的记载，在架构层面解释共存机制：authoring MonoBehaviour 由 `Baker<T>` 烘焙为实体，弹射物数据保存在 `IComponentData` 中，由 `ISystem` 处理
- 说明混合两种模式的性能与复杂度取舍
- 建议将架构决策上报给 `lead-programmer` 或 `technical-director`
- 将 DOTS 侧实现细节交由 `unity-dots-specialist`

### Case 5: 上下文校验 — Unity 版本
**Input:** 提供的项目上下文：Unity 6.3 LTS，目标输入为键鼠与手柄。请求："为本项目配置新的 Input System。"
**Expected behavior:**
- 应用 `docs/engine-reference/unity/modules/input.md` 中的 Unity 6.3 LTS 上下文：安装 Input System 包（`com.unity.inputsystem`），并将 Active Input Handling 设为新输入系统
- 不生成旧版 Input Manager 代码（`Input.GetKeyDown()`、`Input.GetAxis()`）— 引擎参考资料将这些列为已弃用
- 在 `.inputactions` 资源中定义动作，使用 Player Input 组件或生成的 C# 类，并优先使用动作回调（`performed`、`canceled`）而非在 `Update()` 中轮询
- 设置键鼠与手柄控制方案，并支持自动切换
- 将 UI 导航与输入提示相关工作转交给 `unity-ui-specialist`
- 将添加该包视为需要 `technical-director` 签字批准的依赖决策，并在写入任何设置或资源前询问

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Unity 架构决策、模式选型、子系统路由）
- [ ] 将 Godot 模式视为错误引擎：检查 `engine.name`，以 Unity 等效方案作答，绝不输出 Godot 代码
- [ ] 将 DOTS 实现重定向到 unity-dots-specialist
- [ ] 将 UI 实现重定向到 unity-ui-specialist
- [ ] 在建议受版本限制的 API 前检查 `docs/engine-reference/unity/`（锁定版本与 `Installed at pin time`），并在未记录时确认已安装版本
- [ ] 返回结构化的模式决策指南，而非自由形式的观点

---

## Coverage Notes
- MonoBehaviour vs. ScriptableObject（Case 1）若形成项目级决策，应记录为 ADR
- 版本标记（Case 3）确认代理检查锁定版本与已安装的 Unity 版本，而不是假定为最新版
- DOTS 混合（Case 4）验证代理会上报架构冲突，而不是单方面解决
