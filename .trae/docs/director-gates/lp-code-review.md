> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# LP-CODE-REVIEW — 主程序代码评审

Agent：`lead-programmer` | 模型层级：session（继承）

**触发时机**：开发用户故事实现完成后（`/dev-story`、`/story-done`），或作为
`/code-review` 的一部分

**需传入的上下文**：
- 实现文件路径
- 用户故事文件路径（用于验收标准）
- 相关 GDD 章节
- 管辖本系统的 ADR

**提示词**：
> "对照用户故事验收标准与管辖 ADR 审查这份实现。代码是否符合架构边界定义？是否
> 存在违反编码规范或违禁模式之处？公共 API 是否可测试且有文档？对照 GDD 规则是否
> 存在任何正确性问题？返回 APPROVE、CONCERNS [具体问题]，或 REJECT [必须修订后
> 才能合并]。"

**结论**：APPROVE / CONCERNS / REJECT
