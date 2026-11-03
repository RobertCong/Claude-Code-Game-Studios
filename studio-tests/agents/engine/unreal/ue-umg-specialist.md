# Agent Test Spec: ue-umg-specialist

## Agent Summary
- **Domain**: UMG 控件层级设计、数据绑定模式、CommonUI 输入路由与输入动作数据、控件样式（WidgetStyle 资源）、UI 优化（控件池化、ListView、失效缓存/invalidation）
- **Does NOT own**: UX 流程与屏幕导航设计（ux-designer）、玩法逻辑（gameplay-programmer）、后端数据源（游戏代码）、服务器通信
- **Gate IDs**: None；UX 流程决策交由 ux-designer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 UMG、控件层级、CommonUI）
- [ ] `tools:` 为 Read、Glob、Grep、Write、Edit、Bash —— 无 `Agent` 工具
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UX 流程、导航架构或玩法数据逻辑拥有权限

---

## Test Cases

### Case 1: In-domain request — 带数据绑定的背包控件
**Input**: "创建一个背包控件，显示物品槽位网格。每个槽位应显示物品图标、数量和稀有度颜色。背包变化时需要更新。"
**Expected behavior**:
- 产出 UMG 控件结构：父控件 WBP_Inventory 包含 UniformGridPanel 或 TileView，每个物品有一个子控件 WBP_InventorySlot
- 描述数据绑定方案：要么由 Inventory Component 上的 Event Dispatcher 触发刷新，要么用 TileView 并传入基于 UObject 的物品数据（而非原始 struct）；它指明条目控件的列表条目接口（`IUserObjectListEntry`），并标记为未经 `docs/engine-reference/unreal/` 验证，因为该目录未记录它
- 指明稀有度颜色的驱动方式：WidgetStyle 资源或数据表查找，而非硬编码颜色值
- 输出包含控件层级、绑定模式和刷新触发机制

### Case 2: Out-of-domain request — UX 流程设计
**Input**: "为我们背包系统设计完整的导航流程 —— 玩家如何打开它、切换到角色属性、退出到暂停菜单。"
**Expected behavior**:
- 不产出导航流程或屏幕转场架构
- 指明 ux-designer（其交互设计的协调伙伴）为流程负责人，并表示一旦流程确定，可在其分层架构（Menu Layer、`UCommonActivatableWidgetStack`）上构建屏幕
- 在没有 UX 规格的情况下不做 UX 决策（返回按钮行为、转场动画、模态还是全屏）—— 而是索要规格，或将其列为待定问题

### Case 3: Domain boundary — CommonUI 输入动作不匹配
**Input**: "我们的背包控件不响应手柄 Back 按钮。我们使用的是 CommonUI。"
**Expected behavior**:
- 找出可能原因：控件的 Back 绑定未指向项目 `CommonInputActionDataBase` 数据表的 Back 行，或控件不是其堆栈上已激活、已聚焦的屏幕
- 解释 CommonUI 输入路由模型：屏幕派生自 `UCommonActivatableWidget` 并将 UI 动作绑定到数据表行；只有已聚焦、已激活的控件会消费输入，未聚焦控件会忽略输入
- 给出修复：检查 Back 绑定的数据表行，并确认控件已被推入其 activatable-widget 堆栈（并在其上处于激活状态）
- 将其与硬件输入绑定问题区分开（那属于 Enhanced Input 范畴）

### Case 4: Widget 性能问题 — 每帧大量控件实例
**Input**: "我们的排行榜控件一次创建 500 个单独的 WBP_LeaderboardRow 实例。打开排行榜时游戏卡顿 300ms。"
**Expected behavior**:
- 找出根因：单帧内 500 次控件实例化导致构建卡顿
- 建议改用带虚拟化的 ListView 或 TileView —— 只构建可见行
- 解释 ListView 的数据要求：每行的数据是基于 UObject 的条目对象，而非原始 struct；它指明行控件的列表条目接口（`IUserObjectListEntry`），并标记为未经 `docs/engine-reference/unreal/` 验证
- 如果 ListView 不合适，建议池化：预先实例化固定数量的行，并用新数据回收复用
- 输出是带有具体 UMG 组件的明确建议，而非含糊的「优化一下」

### Case 5: Context pass — CommonUI 已完成配置
**Input context**: 项目使用 CommonUI；其 `CommonInputActionDataBase` 数据表定义了这些输入动作行：Confirm、Back、Pause、Secondary。
**Input**: "为背包控件添加一个与 CommonUI 兼容的「排序背包」按钮。"
**Expected behavior**:
- 使用现有的 Secondary 行（或如果该屏幕上 Secondary 已被占用，则建议新增一个 Sort 行）
- 不会在不说明必须将其作为一行添加到项目 CommonUI 输入动作数据表的情况下，凭空发明新的输入动作
- 按钮使用 `UCommonButtonBase` 和 CommonUI 的输入路由 —— 而不是非 CommonUI 的绑定（例如 Event Graph 中的原始按键，或 `APlayerController::InputComponent`）
- 在建议中明确引用所提供的动作行

---

## Protocol Compliance

- [ ] 保持在声明领域内（UMG 结构、数据绑定、CommonUI、控件性能）
- [ ] 将 UX 流程和导航设计请求重定向到 ux-designer，自身不做任何有约束力的 UX 决策
- [ ] 返回结构化发现（控件层级 + 绑定模式），而非自由发挥意见
- [ ] 使用上下文中现有的 CommonUI 输入动作行；不凭空发明新行，除非标记它们必须加入数据表
- [ ] 对大型集合，优先建议虚拟化列表（ListView/TileView），而非控件池化
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件

---

## Coverage Notes
- Case 3（CommonUI 输入路由）要求项目已配置 CommonUI；若项目不使用 CommonUI，则跳过该测试
- Case 4（性能）是高影响失败模式 —— 300ms 卡顿会阻塞交付；优先测试该用例
- Case 5 是 UI 流水线一致性方面最重要的上下文感知测试
- 无自动运行器；请手动审查或通过 `/skill-test`
