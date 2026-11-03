# Agent Test Spec: unity-ui-specialist

## Agent Summary
领域：Unity UI Toolkit（UXML/USS）、UGUI（Canvas）、数据绑定、运行时 UI 性能以及 UI 输入事件处理。
不负责：UX 流程设计（ux-designer）、视觉美术风格（art-director）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 UI Toolkit / UGUI / Canvas / 数据绑定）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声明对 UX 流程设计或视觉美术方向的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "使用 Unity UI Toolkit 实现一个背包 UI 界面。"
**Expected behavior:**
- 生成定义背包面板结构的 UXML 文档（ListView、物品模板、详情面板）
- 为背包布局与物品状态（默认、悬停、选中）生成 USS 样式
- 提供通过运行时绑定系统把背包数据模型绑定到 UI 的 C# 代码：实现 `INotifyBindablePropertyChanged` 的 ViewModel，UI 通过绑定读取，绝不写入游戏状态
- 对可滚动物品列表使用带 `makeItem` / `bindItem` 回调的 `ListView`
- 不生成 UX 流程设计 — 而是依据提供的规格实现

### Case 2: 领域外重定向
**Input:** "设计背包的 UX 流程 — 玩家装备与丢弃物品时分别会发生什么。"
**Expected behavior:**
- 不生成 UX 流程设计
- 明确说明交互流程设计属于 `ux-designer`
- 将请求重定向到 `ux-designer`
- 说明它将实现 ux-designer 指定的任何流程

### Case 3: UI Toolkit 动态列表数据绑定
**Input:** "背包列表需要随着物品被加入或移出玩家背包实时更新。"
**Expected behavior:**
- 在背包的后备集合上生成 `ListView` 模式，通过 `makeItem` / `bindItem` 虚拟化，从而仅存在可见行
- 由背包的变更事件驱动刷新（游戏状态 → ViewModel → 绑定），而非逐帧轮询
- 不通过逐元素查询可视化树来刷新列表 — 将逐帧可视化树查询标记为反模式，并改为缓存引用
- 不在每次变更时创建和销毁行元素 — 通过虚拟化列表复用行

### Case 4: Canvas 性能 — 过度绘制
**Input:** "主菜单 canvas 触发了 GPU 过度绘制（overdraw）警告；有很多重叠面板。"
**Expected behavior:**
- 在改动结构前先用性能分析工具确认热点（Frame Debugger、Profiler 的 UI 模块）
- 推荐其有文档记录的 Canvas 改进措施：
  - 每个逻辑 UI 层一个 Canvas，将频繁变化的内容与静态内容放在不同 Canvas 上
  - 使用显式的 `Canvas.sortingOrder` 而非依赖层级顺序
  - 共享 sprite 图集以便面板合批，并在非交互元素上禁用 Raycast Target
  - 使用 `CanvasGroup` 淡出或隐藏一组元素，而非逐个更改 Image 的 alpha
- 说明按其自身选型规则，屏幕空间菜单属于 UI Toolkit 范畴（引擎参考资料也将 UGUI Canvas 标记为对新项目已被取代），将其作为选项提供，而非单方面重写

### Case 5: 上下文校验 — Unity 版本
**Input:** 项目上下文：Unity 2022.3 LTS。请求："用数据绑定实现设置面板。"
**Expected behavior:**
- 将所述版本与锁定 Unity 6.3 LTS 的 `docs/engine-reference/unity/VERSION.md` 对照，并在选择绑定 API 前询问实际安装的是哪个编辑器版本
- 不凭记忆断言哪个 Unity 版本引入了运行时数据绑定 — 引擎参考资料未记录该信息，因此该说法被标记为未核实
- 在确认该 API 在 2022.3 编辑器中可用之前，不为其输出运行时绑定系统（`INotifyBindablePropertyChanged`）
- 无论如何都保留其模式中与版本无关的部分：UI 读取状态，用户操作派发命令，面板绝不直接写入游戏状态

---

## Protocol Compliance

- [ ] 保持在声明的领域内（UI Toolkit、UGUI、数据绑定、UI 性能）
- [ ] 将 UX 流程设计重定向到 ux-designer
- [ ] 返回结构化输出（UXML、USS、C# 绑定代码）
- [ ] 在使用依赖版本的 UI API 前，将项目 Unity 版本与 `docs/engine-reference/unity/VERSION.md` 对照，并在所述版本与锁定版本不一致时询问
- [ ] 将 Canvas 过度绘制标记为性能反模式，并提供具体改进措施（按层与更新频率拆分 Canvas、图集化、关闭 Raycast Target）
- [ ] 用其有文档记录的机制隐藏元素 — UI Toolkit 中用 `VisualElement.visible = false`，UGUI 中用 `CanvasGroup` — 绝不通过把每个元素的 alpha 设为 0 来隐藏
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 背包 UI（Case 1）应在 `production/qa/evidence/` 中保留涉及到的每个界面的截图
- 动态列表绑定（Case 3）应有集成测试或自动化交互测试
- Canvas 过度绘制（Case 4）验证代理掌握正确的 Unity UI 性能模式
