> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。


# 质量闸门：Polish → Release


**必需产出物：**
- [ ] 里程碑计划中的所有功能都已实现
- [ ] 内容完整（设计文档中引用的所有关卡、资源、对白都存在）
- [ ] 本地化字符串已外置（代码根中没有面向玩家的硬编码文本）
- [ ] QA 测试计划存在（`production/qa/` 中的 `/qa-plan` 输出）
- [ ] QA 签核报告存在（`/team-qa` 输出——APPROVED 或 APPROVED WITH CONDITIONS）
- [ ] 所有 Must Have 用户故事的测试证据都存在（Logic/Integration：测试文件通过；UI：每个触及界面的留存截图；Visual/Feel：留存截图加主管签核——两者都放在 `production/qa/evidence/`，任何 `qa.level` 都不豁免）
- [ ] 冒烟检查在发布候选构建上干净通过（PASS 结论）——一次完整运行，而不是标记为 `(quick — …)` 的 `quick` 运行
- [ ] 相对上一冲刺没有测试回归（测试套件完全通过）
- [ ] 平衡性数据已经过评审（已运行 `/balance-check`）
- [ ] 发布清单已完成（已运行 `/release-checklist`）
- [ ] 商店元数据已准备（若适用）
- [ ] 变更日志 / 补丁说明已起草

**质量检查：**
- [ ] 完整 QA 通过已由 `qa-lead` 签核
- [ ] 所有测试通过
- [ ] 在所有目标平台上都达到性能目标
- [ ] 没有已知的未关闭 S1 Critical、S2 High 或 S3 Medium 缺陷
- [ ] 最新一份 **Scope** 为 `full` 的 `production/security/security-audit-*.md` 中没有未关闭的 CRITICAL 或 HIGH 发现项，并已按之后任何 `quick` 报告更新（即 `/security-audit` 在修复后规定要做的重跑）。之后一份 `network`、`save` 或 `input` 报告会加入其未关闭发现项，但绝不会清除它未扫描的类别——任何未关闭的 CRITICAL 或 HIGH 发现项都意味着未准备好（阻塞项）。没有全范围审计报告意味着该检查无法运行：此项为 NOT ASSESSED，绝不算通过。若某份报告的发布建议本身为 NOT ASSESSED，此项也变为 NOT ASSESSED
- [ ] 无障碍基础已覆盖（重映射、文本缩放，若适用）
- [ ] 所有目标语言的本地化已验证——每个要发布的已翻译语言区域都有 `/localize qa` 结论 PASS 或 PASS WITH CONDITIONS（`production/localization/loc-qa-[locale]-[date].md`）。FAIL 会阻止该语言区域发布；其他语言区域仍可发布。没有 QA 报告、或 QA 报告为 NOT ASSESSED（没人玩过）的语言区域尚未验证：此项为 NOT ASSESSED，绝不算通过。源语言区域（`en`，依据 `/localize`）不是目标语言，不需要 `/localize qa` 报告；只发布源语言区域的游戏把此项标记为 N/A 并说明
- [ ] 法律要求已满足（EULA、隐私政策、年龄分级，若适用）
- [ ] 构建可干净编译并打包

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的
削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的
机制。

- **`full`** —— 所有功能 + 内容完整 + 本地化 + QA 签核 + 冒烟（PASS）+ 无未关闭 S1–S3 缺陷全部必需
- **`standard`** —— 内容完整性审计 + QA 签核 + 本地化 → 推荐；**所有功能 + 冒烟 + 无未关闭 S1 Critical 缺陷**必需；未关闭的 S2 High 与 S3 Medium 缺陷 → 推荐
- **`minimal`** —— 只要求**冒烟 + 无未关闭 S1 Critical 缺陷**；其余一切**取消**
