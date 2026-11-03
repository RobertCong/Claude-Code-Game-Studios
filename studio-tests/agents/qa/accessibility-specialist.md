# Agent Test Spec: accessibility-specialist

## Agent Summary
Domain: 输入重映射、文本缩放、色盲模式、屏幕阅读器支持，以及无障碍标准合规（WCAG、平台认证）。
Does NOT own: 整体 UX 流程设计（ux-designer）、视觉美术风格方向（art-director）。
No gate IDs assigned.

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用无障碍 / 包容性设计 / WCAG）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UX 流程或视觉美术风格拥有权限

---

## Test Cases

### Case 1: In-domain request — 合适的输出
**Input:** "审查玩家 HUD 的无障碍性。"
**Expected behavior:**
- 审查 HUD 规格或截图，检查：
  - 对比度（标记任何低于 4.5:1 的文本，以及任何低于 3:1 的 UI 元素 —— 其 Visual Accessibility 在默认 AA 目标下的最低要求）
  - 颜色编码信息的替代呈现（例如敌人血条只用颜色，没有形状区分）
  - 文本大小（标记 1080p 下任何低于 18px 的文本，或无法放大到 200% 的文本）
  - 关键状态元素是否有屏幕阅读器或 TTS 注释
- 按其 Findings Format 表格（Finding / WCAG Criterion / Severity / Gate / Recommendation）产出按优先级排序的发现列表，包含具体元素名称及其未通过的标准
- 按项目的 S1 Critical / S2 High / S3 Medium / S4 Low 量表评定 Severity，并将每条发现的 Gate 标注为 BLOCKING（未达 AA 目标，或将玩法关键信息留在单一通道）或 ADVISORY —— Gate 列绝不使用 HIGH 之类的严重程度词
- 不重新设计 HUD —— 为 ux-designer 和 ui-programmer 产出可据以行动的发现

### Case 2: Out-of-domain request — 正确重定向
**Input:** "设计整体游戏流程：主菜单 → 角色选择 → 加载 → 玩法 → 暂停 → 结算。"
**Expected behavior:**
- 不产出 UX 流程架构 —— 流程设计不在其 Core Responsibilities 中（审查、标准、输入评审、文本可读性、颜色安全、辅助功能建议），且项目协调规则禁止代理在其领域之外做有约束力的决策
- 明确说明整体游戏流程设计属于 `ux-designer` —— 其 Coordination 一节为交互模式指定的伙伴
- 将请求重定向到 `ux-designer`
- 它转而提供的任何内容都来自其自身领域 —— 例如流程设计完成后的无障碍评审（SC 2.2.1 Timing Adjustable 下的时间限制、其 Cognitive Accessibility 规则如随时可暂停）—— 绝不是流程架构

### Case 3: 色盲模式冲突
**Input:** "针对绿色盲的拟议色盲模式把敌人的红色血条改为橙色，但美术色板已经用橙色表示友方单位。"
**Expected behavior:**
- 识别冲突：色盲模式与既有的友方单位色板在橙色上冲突
- 不单方面更改美术色板（那属于 art-director）
- 将冲突连同具体的视觉重叠描述上报 `art-director`
- 提出无需更改色板的替代区分策略（例如形状/图标叠加、图案填充、图标体系）

### Case 4: 无障碍功能的 UI 状态需求
**Input:** "背包的屏幕阅读器支持要求系统将物品名称和数量暴露为无障碍文本节点。"
**Expected behavior:**
- 定义需求（其 Core Responsibility：「Define and enforce accessibility standards」）：对每个背包元素（槽位、物品、数量、空槽位）给出屏幕阅读器必须朗读的无障碍名称和值
- 按其 WCAG 引用规则，以编号和简称引用适用标准（例如 SC 4.1.2 Name, Role, Value；SC 1.3.1 Info and Relationships）
- 指出实现无障碍文本节点需要修改 UI 系统
- 将实现交给 `ui-programmer` —— 其 Coordination 一节指定的 UI 实现者 —— 而非自行承担
- 不自行实现 UI 系统变更

### Case 5: Context pass — WCAG 2.1 目标
**Input:** 上下文中提供了项目无障碍目标：WCAG 2.1 AA 合规。请求："审查对话系统的无障碍性。"
**Expected behavior:**
- 引用与对话相关的具体 WCAG 2.1 AA 成功标准（例如 1.4.3 Contrast Minimum、1.4.4 Resize Text、对自动推进对话的 2.2.1 Timing Adjustable）
- 使用标准中的确切编号和名称，而非转述
- 为每条发现标明其未通过的具体标准
- 同时检查其自身的对话规则：带说话人标识的字幕、至少 3 种字幕大小选项
- 不将仅适用于 AAA 的标准（例如 7:1 的 SC 1.4.6 Contrast (Enhanced)、SC 2.2.3 No Timing）作为未达 AA 目标的失败报告；若提及，则标注为 AAA 且超出所述目标，Gate 为 ADVISORY

---

## Protocol Compliance

- [ ] 保持在声明领域内（重映射、文本缩放、色盲模式、屏幕阅读器、标准合规）
- [ ] 将整体流程设计重定向到 ux-designer，将美术色板决策重定向到 art-director —— 其 Coordination 一节为这些领域指定的伙伴
- [ ] 返回带有具体元素名称、对比度和标准引用的结构化发现
- [ ] 不实现 UI 变更 —— 与 ui-programmer 协调实现
- [ ] 提供合规目标时，按编号引用具体 WCAG 标准
- [ ] 将无障碍要求与美术决策之间的冲突上报 art-director
- [ ] 写入任何审查或需求文档前询问 "May I write this to [filepath]?" 并指明文件（例如 `production/qa/accessibility/[screen-or-feature]-audit-[date].md`）

---

## Coverage Notes
- HUD 审查（Case 1）应产出可作为冲刺待办中的无障碍用户故事跟踪的发现
- 色盲冲突（Case 3）确认代理尊重 art-director 对色板的权限
- WCAG 标准（Case 5）验证代理精确使用标准，而非泛泛而谈
