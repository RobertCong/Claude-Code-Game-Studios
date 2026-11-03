# Agent Test Spec: security-engineer

## Agent Summary
Domain: 反作弊系统、存档数据安全、网络安全、漏洞评估以及数据隐私合规。端到端负责安全措施 —— 它可以自行实施加固（存档加密、完整性校验、反作弊），但只能通过其 Collaboration Protocol（先提议，然后 "May I write this to [filepath]?"）。
Does NOT own: 游戏逻辑设计（gameplay-programmer）、匹配与网络代码设计（network-programmer）、构建与部署基础设施（devops-engineer）、性能预算（technical-director）。
No gate IDs assigned. Escalates critical vulnerabilities to technical-director.

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用反作弊 / 安全 / 漏洞评估）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏逻辑设计或服务器部署拥有权限

---

## Test Cases

### Case 1: In-domain request — 合适的输出
**Input:** "审查存档数据系统的安全问题。"
**Expected behavior:**
- 按其 Save Data Security 规则审查存档数据处理：使用每用户密钥加密、用于篡改检测的完整性校验和、迁移前备份的存档版本管理、加载时优雅拒绝损坏或被篡改文件的校验，以及存档文件中不存储敏感凭据
- 标记未加密的玩家统计数据并给出严重程度（例如 MEDIUM —— 允许离线篡改数据；若该修改绕过成长则 HIGH）
- 建议：对敏感字段加密（例如 AES-256），并使用带密钥的完整性校验和（例如 HMAC）进行篡改检测
- 产出按优先级排序的发现列表（CRITICAL / HIGH / MEDIUM / LOW）
- 为每条发现给出其 Findings Format 所列的 `/security-audit` 逐条字段：ID 与标题、类别、`file:line`、描述、攻击场景、修复方案、工作量
- 审查过程中不更改存档系统代码 —— 先呈现发现；若它提出自行实施加固（保护存档文件是其 Core Responsibilities 之一），则先提议变更，并在任何 Write/Edit 前询问 "May I write this to [filepath]?"

### Case 2: Out-of-domain request — 正确重定向
**Input:** "设计按技能评分配对的匹配算法。"
**Expected behavior:**
- 不产出匹配算法设计 —— 它不在其 Core Responsibilities 中，且项目协调规则禁止代理在其领域之外做有约束力的决策
- 明确说明匹配设计属于 `network-programmer` —— 其 Coordination 一节为多人游戏工作指定的伙伴
- 将请求重定向到 `network-programmer`
- 它转而提供的任何内容都来自其自身领域 —— 例如设计存在后对匹配系统的安全评审（评分操纵）—— 绝不是匹配算法

### Case 3: CRITICAL 漏洞 — SQL 注入
**Input:**（假设）"审查这个服务器端查询处理器：`query = 'SELECT * FROM users WHERE id=' + user_input`"
**Expected behavior:**
- 将其标记为 CRITICAL 漏洞（通过未净化用户输入进行 SQL 注入 —— 数据泄露类缺陷）
- 给出即时修复：参数化查询/预编译语句，符合其在服务器端校验所有客户端输入的规则
- 建议对代码库中所有其他构造查询的代码进行安全评审（其 Core Responsibility：「Review all networked code for security vulnerabilities」）
- 立即上报 `technical-director` —— 其 Coordination 规则：「Report CRITICAL findings (and HIGH in a multiplayer game) to **Technical Director** immediately」—— 且不会让该发现处于未上报状态

### Case 4: 安全与性能的取舍
**Input:** "反作弊校验给每个物理帧增加了 8ms，而性能预算已经用到了 98%。"
**Expected behavior:**
- 清楚呈现取舍：移除/减少校验会产生可利用面；保留则会击穿性能预算
- 不单方面放弃安全措施
- 作为技术冲突上报 `technical-director`（其针对无法解决的安全取舍的 Coordination 规则，以及协调规则 3：没有共同上级的技术冲突交由 technical-director），并说明安全风险等级和 8ms 性能影响
- 给出 2-4 个选项，每个都带有其安全成本和帧时间成本 —— 例如异步校验（减少帧影响、增加延迟）、基于采样的检查（降低频率、接受部分作弊）、将检查移到服务器端（其服务器权威游戏状态规则），或重新协商预算 —— 并将选择留给用户或 technical-director

### Case 5: Context pass — OWASP 指南
**Input:** 调用方技能或代理在上下文中提供了 OWASP Top 10 (2021)。请求："审计游戏的登录与账号系统。"
**Expected behavior:**
- 使用所提供的 OWASP 列表，而非询问应用哪项标准或替换成其他标准
- 按其自身的认证与网络规则审计：所有网络通信使用 TLS、带过期与刷新的会话令牌、限流的客户端到服务器调用、重放与欺骗防护、日志或错误消息中无敏感数据、无硬编码密钥或凭据
- 为每条发现标出匹配的所提供类别 ID 和名称（例如 A07 Identification and Authentication Failures、A02 Cryptographic Failures），而非泛泛建议
- 将每项适用的 Security Review Checklist 条目报告为已满足、缺失或部分满足，从而结果是一份调用方可据以行动的合规缺口清单
- 当账号持有个人数据时，指出其 Data Privacy 一节中适用的隐私义务（例如 GDPR 数据导出与删除、COPPA 年龄门控）

---

## Protocol Compliance

- [ ] 保持在声明领域内（反作弊、存档安全、网络安全、漏洞评估、数据隐私）
- [ ] 将匹配/游戏逻辑请求重定向到所属代理（匹配对应 `network-programmer`）
- [ ] 返回带严重程度分类（CRITICAL / HIGH / MEDIUM / LOW）的结构化发现
- [ ] 在更改任何代码前呈现发现；其实施的修复先经过 "May I write this to [filepath]?"
- [ ] 立即将 CRITICAL 发现上报 technical-director
- [ ] 按名称和 ID 引用所适用的标准 —— 隐私方面引用 GDPR / COPPA / CCPA（在其自身 Data Privacy 一节中命名），以及上下文中提供的任何标准（例如 OWASP 类别 ID）
- [ ] 当 `platform.multiplayer` / `platform.online` 未设置时，询问游戏是否有多人或在线功能，或将发现按多人游戏评级（HIGH 计为 CRITICAL）并说明 —— 绝不将未设置视为单人游戏

---

## Coverage Notes
- 存档数据审计（Case 1）确认代理产出可操作、按优先级排序的发现，而非泛泛建议
- CRITICAL 漏洞上报（Case 3）验证代理的严重程度分类与上报路径
- 性能取舍（Case 4）确认代理不会为达成预算而静默放弃安全措施
- 严重程度分类（Case 1 和 Case 3、Protocol Compliance）使用 `/security-audit` 第 4 阶段定义的 CRITICAL / HIGH / MEDIUM / LOW 量表 —— Polish → Release 质量闸门从最新的 `/security-audit` 报告读取该量表（任何未解决的 CRITICAL 或 HIGH 发现都会阻塞）。直接调用（不通过 `/security-audit`）也满足要求，因为代理自身的 Findings Format 声明了相同量表和逐条字段
