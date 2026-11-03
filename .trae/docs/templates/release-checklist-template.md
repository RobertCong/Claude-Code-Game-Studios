## Release Checklist: [Version] -- [Platform]
Generated: [Date]

### Codebase Health
- Scanned: [N] 个源文件（或 `NOT ASSESSED — [reason]`，按 Phase 3）
- TODO count: [N]（[数量多时列出前 5 项]）
- FIXME count: [N]（[全部列出——这些是潜在阻塞项]）
- HACK count: [N]（[全部列出——这些需要评审]）

### Build Verification
- [ ] 在所有目标平台上干净构建成功
- [ ] 无编译器警告（零警告策略）
- [ ] 所有资源均已包含并正确加载
- [ ] 构建体积处于预算内（[目标体积]）
- [ ] 构建版本号已正确设置（[version]）
- [ ] 构建可从已打标签的提交复现

### Quality Gates
- 未关闭缺陷（`production/qa/bugs/`）：[N] S1，[N] S2，[N] S3——或 `NOT ASSESSED — no bug records`
- [ ] 零个未关闭的 S1（Critical）缺陷
- [ ] 零个未关闭的 S2（High）缺陷，无例外——此行仅在 `workflow: full` 下适用；在 `standard`/`minimal` 下，未关闭的 S2 缺陷作为风险写入 Rationale
- [ ] 零个未关闭的 S3（Medium）缺陷，无例外——此行仅在 `workflow: full` 下适用；在 `standard`/`minimal` 下，未关闭的 S3 缺陷作为风险写入 Rationale
- [ ] 所有关键路径功能已测试并经 QA 签核
- [ ] 性能处于预算内：
  - [ ] 在最低配置硬件上达到目标帧率
  - [ ] 内存占用处于预算内
  - [ ] 加载时间处于预算内
  - [ ] 长时间游玩会话中无内存泄漏
- [ ] 与上一构建相比无回归
- [ ] 浸泡测试通过（连续游玩 4 小时以上）

> 发布闸门（`/gate-check release`）在 `workflow: full` 下会阻止任何未关闭的
> S1–S3 缺陷，无例外；在 `standard` 和 `minimal` 下仅阻止未关闭的 S1，未关闭的
> S2 或 S3 是需记录在 Rationale 中的风险。

### Content Complete
- [ ] 所有占位资源已替换为最终版本
- [ ] 内容文件中的所有 TODO/FIXME 已解决或有记录
- [ ] 所有面向玩家的文本已校对
- [ ] 所有文本已就绪本地化（无硬编码字符串）
- [ ] 音频混音已定稿并批准
- [ ] 制作人员名单完整且准确

[Platform Requirements: 平台参数指定的每个设备对应一个条目块（`pc`、`console`、`mobile`；`all` 表示三者全部），从 `release-platform-requirements.md` 复制]

[Certification: 本项目 `platform.cert_tier` 对应的唯一条目块，从 `certification-none.md`、`certification-itch.md`、`certification-steam.md` 或 `certification-console.md` 复制；无法确定层级时使用 `certification-unknown.md`]

### Store / Distribution
- [ ] 商店页面元数据完整且已校对
  - [ ] 简短描述
  - [ ] 详细描述
  - [ ] 功能列表
  - [ ] 系统需求（PC）
- [ ] 截图是最新的且符合各平台分辨率要求
- [ ] 预告片是最新的
- [ ] 主视觉和胶囊图是最新的
- [ ] 年龄分级已获取并配置：
  - [ ] ESRB
  - [ ] PEGI
  - [ ] 其他要求的地区分级
- [ ] 法律声明、EULA 和隐私政策已就位
- [ ] 第三方许可署名完整
- [ ] 已为所有区域配置定价

### Launch Readiness
- [ ] 分析 / 遥测已验证并正在接收数据
- [ ] 崩溃报告已配置且仪表盘可访问
- [ ] 首日补丁已准备并测试（如需要）
- [ ] 已排定前 72 小时的值班团队表
- [ ] 社区上线公告已起草
- [ ] 媒体/意见领袖密钥已准备分发
- [ ] 支持团队已了解已知问题和 FAQ
- [ ] 回滚方案已记录（如上线后发现关键问题）

### Go / No-Go: [READY / NOT ASSESSED / NOT READY]

首个匹配项生效：若任何阻塞项失败则为 **NOT READY**；否则若任何章节或条目
结果为 `NOT ASSESSED`（逐一列出）则为 **NOT ASSESSED**；否则为 **READY**。
NOT ASSESSED 的优先级高于 READY——未评估的章节不算通过的章节——且低于
NOT READY，因此已知的阻塞项绝不会被它掩盖。

**Rationale:**
[就绪度评估摘要。列出上线前必须解决的所有阻塞项。若为 NOT READY，列出需要
解决的具体条目及预计解决时间。]

**Sign-offs Required:**
- [ ] QA Lead
- [ ] Technical Director
- [ ] Producer
- [ ] Creative Director
