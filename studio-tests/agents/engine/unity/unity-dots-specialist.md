# Agent Test Spec: unity-dots-specialist

## Agent Summary
领域：ECS 架构（IComponentData、ISystem、SystemAPI）、Jobs 系统（IJob、IJobEntity、Burst）、Burst 编译器约束、DOTS 玩法系统以及混合渲染器（hybrid renderer）。
不负责：MonoBehaviour 玩法代码（gameplay-programmer）、UI 实现（unity-ui-specialist）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 ECS / Jobs / Burst / IComponentData）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声明对 MonoBehaviour 玩法或 UI 系统的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "把玩家移动系统转换为 ECS。"
**Expected behavior:**
- 生成：
  - `PlayerMovementData : IComponentData` 结构体，包含 velocity、speed 和 input vector 字段
  - `PlayerMovementSystem : ISystem`，其 `OnUpdate()` 使用 `SystemAPI.Query<>` 或 `IJobEntity`
  - 通过 `Baker<T>` 子类从 authoring MonoBehaviour 烘焙玩家的初始状态（`docs/engine-reference/unity/plugins/dots-entities.md` 中的模式）
- 使用 `RefRW<LocalTransform>` 更新位置（而非已弃用的 `Translation`）
- 将 job 标记为 `[BurstCompile]`，并说明为兼容 Burst 必须为非托管（unmanaged）的内容
- 每个系统只承担一项职责：移动系统从某个组件（例如 `PlayerInputData`）读取输入，由独立的输入系统写入，而非自己轮询输入，并在创建或变更该输入侧之前先行询问

### Case 2: MonoBehaviour 反向建议
**Input:** "玩家移动就用 MonoBehaviour 吧 — 更简单。"
**Expected behavior:**
- 认可简单性论点
- 解释 DOTS 的取舍：前期搭建更多，但 ECS/Burst 方案能提供项目 ADR 或需求中记录的性能特性
- 若项目已确定采用 DOTS，则不实现 MonoBehaviour 版本
- 若无此承诺，将 MonoBehaviour-vs-DOTS 决定交由 `unity-specialist`（其指定的整体 Unity 架构联系人），并以 `technical-director` 作为未解决技术冲突的上报对象
- 不单方面做 MonoBehaviour 与 DOTS 的决定

### Case 3: Burst 不兼容的托管内存
**Input:** "这个 Burst job 访问一个 `List<EnemyData>` 来查找最近的敌人。"
**Expected behavior:**
- 标记 `List<T>` 为与 Burst 编译不兼容的托管类型
- 不批准该带托管内存访问的 Burst job
- 提供正确替代方案：视用例使用 `NativeArray<EnemyData>`、`NativeList<EnemyData>` 或 `NativeHashMap<>`
- 说明原生容器必须释放，分配器按生命周期选择（帧作用域用 `Allocator.TempJob`，长生命周期用 `Allocator.Persistent`），并在大小已知时预分配容量
- 使用非托管原生容器生成修正后的 job

### Case 4: 混合访问 — DOTS 系统需要 MonoBehaviour 数据
**Input:** "DOTS 移动系统需要读取由 MonoBehaviour CameraController 管理的相机 transform。"
**Expected behavior:**
- 识别这是混合访问场景
- 不把 `Transform` 或 MonoBehaviour 本身放进组件 — 组件不持有对托管对象的引用
- 将相机数据以非托管值（`Unity.Mathematics` 类型）放在 `IComponentData` 中跨越边界，在 MonoBehaviour 侧一个明确的交接点写入，由系统读取 — 而不是逐实体去取
- 不在 Burst job 内部访问 MonoBehaviour — 将 Burst 代码中的托管访问标记为编译错误

### Case 5: 上下文校验 — 性能目标
**Input:** 上下文中的技术偏好：60fps 目标，每帧 CPU 脚本预算最多 2ms。请求："为 10,000 个敌人实体设计 ECS chunk 布局。"
**Expected behavior:**
- 在设计理由中明确引用 2ms CPU 预算
- 为缓存效率设计 `IComponentData` chunk 布局：
  - 按系统访问模式而非游戏概念拆分组件 — 不设"上帝组件"（god component）
  - 保持热组件小，将罕用数据放在独立组件中
  - 使用 tag 组件做过滤，避免会碎片化 archetype 的 `ISharedComponentData`，对可切换状态使用 `IEnableableComponent` 而非结构性变更
- 说明如何验证预算 — Entities Profiler 的系统耗时与逐 archetype 内存 — 而不是把未测量的耗时当作事实呈现
- 不设计会明显超出所述 2ms 预算却未加标记的布局

---

## Protocol Compliance

- [ ] 保持在声明的领域内（ECS、Jobs、Burst、DOTS 玩法系统）
- [ ] 将纯 MonoBehaviour 玩法重定向到 gameplay-programmer
- [ ] 返回结构化输出（IComponentData 结构体、ISystem 实现、`Baker<T>` authoring 类）
- [ ] 将 Burst job 中的托管内存访问标记为编译错误，并提供非托管替代方案
- [ ] 当 DOTS 系统需要与 MonoBehaviour 系统交互时，提供混合访问模式
- [ ] 依据所提供的性能预算设计 chunk 布局，并说明验证它们的性能分析步骤
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- ECS 转换（Case 1）必须包含使用 ECS 测试框架（`World`、`EntityManager`）的单元测试，位于 `Assets/Tests/EditMode/` 下
- Burst 不兼容（Case 3）属于安全关键项 — 代理必须在代码写出之前捕获该问题
- chunk 布局（Case 5）验证代理依据所述预算设计，并说明将如何测量，而不是断言未测量的数字
