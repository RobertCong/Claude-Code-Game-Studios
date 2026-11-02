# Agent Test Spec: gameplay-programmer

## Agent Summary
领域：游戏机制代码、玩家系统、战斗实现与交互功能。
不负责：UI 实现（ui-programmer）、AI 行为树（ai-programmer）、引擎/渲染系统（engine-programmer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及游戏机制 / 玩家系统）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep —— 排除仅编排代理需要的工具
- [ ] 模型档位为 `inherit` — frontmatter `model:` 的值恰为 `inherit`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UI、AI 行为或引擎/渲染代码拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “实现一套近战连招系统：三次连续轻攻击链接为一段终结技。”
**Expected behavior:**
- 产出遵循项目语言（GDScript/C#）和编码规范的代码或代码骨架
- 将连招建模为带显式转换表的状态机，并让输入窗口检查与终结技触发保持为逻辑，使单元测试无需运行完整游戏即可驱动（逻辑与表现分离）
- 如果上下文中提供了相关 GDD 章节，则引用它
- 不实现 UI 反馈或敌人反应：改为发出事件/信号，而不是引用 UI 代码，把 UI 侧留给 `ui-programmer`，敌人反应留给 `ai-programmer`
- 按编码规范包含所有公开方法的文档注释

### Case 2: 域外请求 — 正确重定向
**Input:** “构建主菜单界面，包含暂停与设置面板。”
**Expected behavior:**
- 不产出菜单实现代码
- 明确说明这超出其领域
- 将请求重定向给 `ui-programmer`
- 其提供的任何部分都是菜单所消费的玩法到 UI 事件契约中的玩法侧（例如暂停状态事件），并与 `ui-programmer` 商定——绝不含菜单代码

### Case 3: 领域边界 — 线程问题上报
**Input:** “连招系统导致帧卡顿；你能加入线程来分散输入处理吗？”
**Expected behavior:**
- 不擅自实现线程或异步系统
- 将线程关注项上报给 `engine-programmer`，清晰描述热路径
- 其提供的任何临时措施都保持单线程（其负责的连招代码中每帧工作量更少），并在任何代码改动前先提案获批
- 记录该升级事项，让 lead-programmer 知晓

### Case 4: 与已接受 ADR 的冲突
**Input:** “把伤害计算改为直接使用浮点累加，而不是 ADR-003 中的定点公式。”
**Expected behavior:**
- 识别拟议变更违反 ADR-003（Accepted 状态）
- 不静默实现该违规
- 将冲突上报给 `lead-programmer`，附 ADR 引用并描述取舍
- 只有在 ADR-003 通过 `/architecture-decision` 被新 ADR 取代后才实现变更——只有用户，或经用户确认的 technical-director 才能将其转为 Accepted——绝不单凭原始请求，也不单凭 lead-programmer 的批准

### Case 5: 上下文传递 — 按 GDD 规格实现
**Input:** 上下文中提供“PlayerCombat”的 GDD。请求：“实现战斗 GDD 中的体力消耗公式。”
**Expected behavior:**
- 读取所提供 GDD 的公式部分
- 按原文实现精确公式——不发明新变量或调整系数
- 将体力消耗做成数据驱动值（外部配置），而非硬编码常量
- 记录 GDD 边界情况章节中的任何边界情况，并在代码中处理

---

## Protocol Compliance

- [ ] 保持在声明的领域内（机制、玩家系统、战斗）
- [ ] 将域外请求重定向给正确的代理（ui-programmer、ai-programmer、engine-programmer）
- [ ] 返回结构化发现（代码骨架、方法签名、内联注释），而非自由形式的意见
- [ ] 未经 lead-programmer 批准不修改引擎级系统，也不编写网络代码（委派给 network-programmer）
- [ ] 标记 ADR 违规，而不是静默覆盖
- [ ] 使玩法数值数据驱动，绝不硬编码
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 连招系统测试（Case 1）应通过 `tests/unit/gameplay/` 中的单元测试验证
- 线程升级（Case 3）验证代理不会越界进入引擎领域
- ADR 冲突（Case 4）确认代理尊重架构治理流程
- Case 1 与 Case 5 共同验证代理按规格实现，而不是即兴发挥
