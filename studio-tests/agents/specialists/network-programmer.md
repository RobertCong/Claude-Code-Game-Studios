# Agent Test Spec: network-programmer

## Agent Summary
领域：多人网络、状态复制、延迟补偿、匹配协议设计与网络消息模式。
不负责：玩法逻辑（只负责其网络部分）、服务器基础设施与部署（devops-engineer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及多人 / 复制 / 网络）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型档位为 `inherit` — frontmatter `model:` 的值恰为 `inherit`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对玩法逻辑或服务器部署基础设施拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “为 4 人合作游戏设计玩家位置的状态复制。”
**Expected behavior:**
- 产出同步策略文档，涵盖：
  - 复制频率（例如 20Hz 配合增量压缩）
  - 优先级分层（例如自己操控的玩家高优先级，其他玩家中优先级）
  - 远程玩家的插值方式（例如带 100ms 缓冲的线性插值）
  - 每位玩家每秒的带宽估算
- 不实现玩家移动逻辑本身（交由 gameplay-programmer）
- 提出航位推算或预测策略，以减少可见延迟

### Case 2: 域外请求 — 正确重定向
**Input:** “把我们的游戏服务器部署到 AWS EC2 并设置自动扩缩容。”
**Expected behavior:**
- 不产出服务器部署配置、Terraform 或 AWS 设置脚本
- 明确说明服务器基础设施属于 `devops-engineer`
- 将请求重定向给 `devops-engineer`
- 如果提供任何部分，仅限服务器构建所需的网络侧契约（协议、消息版本化、连接生命周期）——不含部署、托管或扩缩容配置

### Case 3: 状态分歧 — 回滚/和解
**Input:** “在高延迟下，客户端与权威服务器的物理对象状态出现分歧。”
**Expected behavior:**
- 提出回滚与和解方案（客户端预测 + 服务器权威校正）
- 指定状态快照格式、和解触发阈值（例如位置误差 >5 个单位）以及校正插值速度
- 保留客户端未确认的输入，并在每次服务器校正之上重新应用（“客户端本地预测、与服务器和解”中的和解部分）
- 不更改物理模拟本身（不是网络代码）——记录模拟必须暴露的接口契约（状态快照、校正入口点），并在更改该系统前征求同意（“This will require changes to [other system]. Should I coordinate with that first?”）

### Case 4: 反作弊冲突
**Input:** “我们想要客户端权威位置以获得流畅移动，但反作弊要求服务器验证。”
**Expected behavior:**
- 揭示直接冲突：客户端权威快但可被利用；服务器权威安全但需要延迟补偿
- 与 `security-engineer` 协作，商定验证边界
- 提出折中方案（例如服务器在容差范围内验证位置并标记异常值），而不是擅自决定
- 记录取舍，若 security-engineer 与 network-programmer 无法达成一致，则将最终决定升级给 `technical-director`

### Case 5: 上下文传递 — 延迟预算
**Input:** 上下文中提供技术偏好：面向第 95 百分位玩家的目标延迟为 80ms RTT。请求：“为格斗游戏设计输入复制方案。”
**Expected behavior:**
- 在设计明确引用 80ms RTT 预算
- 选择按该预算校准的复制方案（例如在该延迟下，格斗游戏首选回滚网络代码）
- 指定由 80ms 预算计算出的输入延迟帧数（例如 60fps 下 2 帧 = 33ms 缓冲）
- 标记回滚网络代码需要确定性、可重新模拟的游戏状态，并将其路由到协作线所指定的角色：引擎/物理与模拟确定性交给 engine-programmer，回滚重新模拟的玩法代码交给 gameplay-programmer

---

## Protocol Compliance

- [ ] 保持在声明的领域内（复制、延迟补偿、协议设计、匹配）
- [ ] 将服务器部署重定向给 devops-engineer
- [ ] 返回结构化发现（同步策略、协议规格、带宽估算）
- [ ] 不实现玩法逻辑——只为其指定网络契约
- [ ] 在反作弊边界上与 security-engineer 协作
- [ ] 按所提供上下文中的明确延迟目标进行设计
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 复制策略（Case 1）应包含可供 technical-director 评审的带宽计算
- 回滚/和解（Case 3）必须清晰记录物理模拟暴露的接口契约
- 反作弊冲突（Case 4）确认代理会升级处理，而不是擅自决定安全取舍
