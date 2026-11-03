# Agent Test Spec: release-manager

## Agent Summary
- **Domain**: 发布流水线（Build → Test → Cert → Submit → Verify → Launch）、按 `platform.cert_tier` 划分的平台认证清单、商店提交与商店页面管理、年龄分级、语义化版本号与发布标签、发布日协调、发布后监控
- **Does NOT own**: 游戏设计、功能与范围决策（producer）、QA 测试策略与测试用例设计（qa-lead）、构建流水线与 CI/CD（devops-engineer）、营销文案（community-manager）
- **Gate IDs**: None；由 `/team-release` 为发布候选与 Go/No-Go 签署启动。其阻塞性输出是预加载的 `/release-checklist` 给出的 `NOT READY` Go/No-Go 结论，并上报 producer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用发布流水线、认证、商店提交）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit, Bash` —— Bash 用于发布打标签（「Version tags must be applied to the git repository at every release point」）
- [ ] `skills:` 预加载 `release-checklist`、`changelog` 和 `patch-notes`
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对 QA 策略、游戏设计或构建基础设施拥有权限
- [ ] 其下一步提议会自行运行 `/patch-notes [version]`，并将结果交给 community-manager 用于公告 —— 绝不会给 community-manager 一份简报让它来写补丁说明
- [ ] 流水线的 Test 步骤采用发布质量闸门（gate）的档位：`workflow: full` 时需 QA 签署（`standard` 时建议），任何档位都不得有未解决的 S1，`full` 档位还不得有未解决的 S2 或 S3

---

## Test Cases

### Case 1: In-domain request — 主机提交的认证清单
**Input context**: `project.yaml` 设置 `platform.cert_tier: console`；游戏在 Nintendo Switch 上发行。
**Input**: "为我们的 Nintendo Switch 提交生成认证清单。"
**Expected behavior**:
- 输出其预加载的 `/release-checklist` 为 `cert_tier: console` 定义的 console 认证块 —— TRC/TCR/Lotcheck 要求清单、第一方提交、成就/奖杯集成、家长控制、存档数据规则（损坏、存储已满、用户切换）、年龄分级 —— 加上主机设备要求（手柄提示、挂起/恢复、用户切换、连接中断、存储已满）
- 逐项跟踪每个要求，状态为 pass / fail / not-applicable（Platform Certification Requirements）
- 不输出任何 itch.io 或 Steamworks 认证行 —— 认证块遵循 `cert_tier`，而非请求中指定的平台
- 以 `/release-checklist` 的三个词作为 Go / No-Go 行结尾（READY / NOT ASSESSED / NOT READY，以首个匹配为准）—— 此处为 NOT ASSESSED 或 NOT READY，绝不为 READY，因为测试夹具未提供构建或测试证据 —— 并在写入前询问「May I write this to `production/releases/release-checklist-[version].md`?」

### Case 2: Out-of-domain request — 设计测试用例
**Input**: "为我们的存档系统编写测试用例，确保它能通过认证。"
**Expected behavior**:
- 不产出测试用例规格
- 将测试设计转交 `qa-lead`，其 Delegation Map 将质量闸门、测试结果和发布就绪签署指定给它
- 提供它确实负责的内容：测试必须覆盖的存档数据认证要求（console 块的「Save-data rules compliant (corruption, full storage, user switching)」），作为给 qa-lead 的输入

### Case 3: Domain boundary — 年龄分级拒绝阻塞发布
**Input**: "我们的构建被 ESRB 拒绝了。拒绝理由指出内容未反映在我们的分级提交中：调试输出中一个隐藏的脏话字符串出现在了截图里。"
**Expected behavior**:
- 将该拒绝视为阻塞：流水线在失败步骤暂停，直到问题解决（「No step may be skipped. If a step fails, the pipeline halts and the issue is resolved before proceeding」）
- 将 Go / No-Go 结论返回为 NOT READY，将该分级问题列为阻塞项并附预计解决时间（`/release-checklist` Go / No-Go 理由）
- 指出所需行动：移除所有包含该内容的调试输出，然后重新提交分级问卷，并跟踪新证书的接收（Store Page Management：年龄分级）
- 不淡化该问题，也不提议绕过它发布 —— 分级拒绝是阻塞事件，而非建议性提示
- 向 producer 报告延期对发布日期的影响，它向 producer 汇报排期

### Case 4: 版本号冲突 — 热修复与发布分支
**Input**: "我们的发布分支在 v1.2.0。一个热修复直接在 main 上应用并打了 v1.2.1 标签。现在发布分支也有需要作为 v1.2.1 交付的变更，但它们是不同的变更。"
**Expected behavior**:
- 识别冲突：两个不同的变更集被分配了同一版本号
- 用语义化版本解决：`v1.2.1` 保留给已打该标签的构建，而发布分支的变更作为修复，使用下一个 PATCH（`v1.2.2`）—— 这是其 Version Numbering 对两个变更集争用一个版本号的规则
- 不接受一个版本号命名两个不同构建的状态 ——「an applied tag is never moved or reused」，内部构建通过 `MAJOR.MINOR.PATCH.BUILD` 保持可区分
- 与 `lead-programmer` 协调热修复分支一侧，其 Delegation Map 将热修复分支管理指定给它

### Case 5: Context pass — 发布日期约束与认证前置时间
**Input context**: 目标发布日期为 2026-06-01。当前日期为 2026-04-06。Nintendo Lotcheck 通常需要 4-6 周。
**Input**: "鉴于我们的时间线，认证清单上应优先处理什么？"
**Expected behavior**:
- 基于所提供日期和前置时间工作，而非占位值：距发布 8 周，因此首次 Lotcheck 提交应在 2026-04-20（若需 6 周）到 2026-05-04（若需 4 周）之间 —— 再加上任何重新提交
- 保持流水线顺序与每个步骤 —— Build → Test → Cert → Submit → Verify → Launch，「No step may be skipped」—— 并从发布日期倒推排期，而非为适应时间压缩或删减步骤
- 至少规划一轮认证迭代（Cert 即「Submit to platform certification, track feedback, iterate」），并标记一次拒绝就会耗尽剩余缓冲
- 给出建议顺序，但将排期决定交给 `producer` —— 它向 producer 汇报排期与优先级，而削减范围是 producer 的决定（「Decide what features to include or exclude (escalate to producer)」）

---

## Protocol Compliance

- [ ] 保持在声明领域内（发布流水线、认证清单、版本号、商店提交）
- [ ] 将测试用例设计请求转交 qa-lead，且不产出测试规格
- [ ] 认证或分级失败时返回 NOT READY 并暂停流水线 —— 不降级为建议性提示
- [ ] 应用语义化版本，绝不让一个版本号命名两个构建
- [ ] 按 `platform.cert_tier` 划定认证范围，并从所提供日期排期，不跳过流水线步骤

---

## Coverage Notes
- Case 3（分级拒绝时 NOT READY）是最关键的测试 —— 该代理的主要安全输出是阻止不良发布
- Case 1 假设 `platform.cert_tier: console`；若该键未设置，预期输出是询问哪些平台在范围内，或「NOT ASSESSED — cert tier unknown」，绝不是列出每条认证轨道
- Case 5 需要当前日期和发布日期上下文；验证代理使用实际日期，而非占位估算
- 认证要求会随时间变化 —— 若代理产出可能过时的具体要求 ID，请标记
- 无自动运行器；请手动审查或通过 `/skill-test`
