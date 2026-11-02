# Agent Test Spec: ui-programmer

## Agent Summary
领域：菜单界面、平视显示（HUD）、物品栏界面、对话框、UI 框架代码与数据绑定。
不负责：UX 流程与交互设计（包括 UI 动画时机）（ux-designer）、视觉风格方向（art-director）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及菜单 / HUD / UI 框架 / 数据绑定）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型档位为 `inherit` — frontmatter `model:` 的值恰为 `inherit`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UX 流程设计或视觉美术方向拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** `design/ux/inventory-flow.md` 的 UX 规格定义了五种槽位状态：default、hover、selected、empty-slot、locked-slot。请求：“依据 `design/ux/inventory-flow.md` 的 UX 规格实现物品栏界面。”
**Expected behavior:**
- 在产出任何代码前读取 UX 规格
- 使用项目配置的 UI 框架实现（UI Toolkit、UGUI、UMG 或 Godot Control 节点）
- 实现规格定义的每个状态（default、hover、selected、empty-slot、locked-slot）——不遗漏，不虚构
- 通过项目的数据模型将物品栏数据绑定到 UI 元素，而非硬编码值
- 按编码规范包含公开 UI API 的文档注释

### Case 2: 域外请求 — 正确重定向
**Input:** “设计物品栏交互流程——当玩家装备、丢弃或组合物品时会发生什么。”
**Expected behavior:**
- 不产出交互流程设计或用户流程图
- 明确说明 UX 流程设计属于 `ux-designer`
- 将请求重定向给 `ux-designer`
- 指出一旦流程规格就绪，它可以实现

### Case 3: 自定义动画协作
**Input:** “物品栏中的物品选中时需要一个自定义弹跳动画。”
**Expected behavior:**
- 认识到弹跳的手感（时长、缓动曲线、过冲）属于 UI 交互与视觉设计，它负责实现但不负责设计
- 先检查其正在实现的 UX 规格中是否有这些数值；若缺失则不虚构
- 向规格所有者——交互时机问 `ux-designer`，视觉风格问 `art-director`——询问缺失值
- 数值提供后，将动画绑定到选中状态，可跳过并尊重玩家的动态偏好（motion preference）

### Case 4: UX 规格含糊 — 反馈回去
**Input:** UX 规格写明“选中时显示物品详情”，但未定义选中空槽位时会发生什么。
**Expected behavior:**
- 识别规格中的歧义（空槽选中状态未定义）
- 不为未定义状态做任意实现决策
- 将歧义反馈给 `ux-designer`，附具体问题：“当选中空的物品栏槽位时，详情面板应显示什么？”
- 其提供的任何选项（例如隐藏面板 / 显示占位符）都作为问题的一部分交给 ux-designer——在得到答复前不实现任何一项

### Case 5: 上下文传递 — 引擎 UI 工具包
**Input:** 上下文中提供引擎信息：项目使用 Godot 4.6 与 Control 节点 UI。请求：“为物品栏实现一个可滚动的物品列表。”
**Expected behavior:**
- 使用 Godot 的 `ScrollContainer` + `VBoxContainer` + `ItemList`（或等价）模式，而非 Canvas 或 UGUI
- 不为 Godot 项目产出 Unity UGUI 或 Unreal UMG 代码
- 在使用具体 API 前检查引擎版本参考（4.6）中 4.4/4.5 起 Control 节点 API 的任何变更
- 产出与项目配置语言一致的 GDScript 或 C# 代码

---

## Protocol Compliance

- [ ] 保持在声明的领域内（菜单、HUD、UI 框架、数据绑定）
- [ ] 将 UX 流程设计重定向给 ux-designer
- [ ] 从 ux-designer / art-director 的规格中获取动画时机与缓动，而不是自行发明，并使每个动画可跳过且感知动态偏好
- [ ] 将含糊的 UX 规格反馈给 ux-designer，而不是做任意实现决策
- [ ] 返回结构化输出（实现代码、数据绑定模式、UI 状态的状态机）
- [ ] 为项目使用正确的引擎 UI 工具包——绝不使用跨引擎代码
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 物品栏实现（Case 1）应在 `production/qa/evidence/` 中保留每个涉及界面的截图
- 动画协作（Case 3）确认代理不会在没有规格的情况下虚构手感参数
- 含糊规格（Case 4）验证代理将规格缺口路由回编写代理，而不是猜测
