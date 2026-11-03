> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-ENGINE-RISK — 引擎版本风险评审

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：做出涉及截止日期之后引擎 API 的架构决策时，
或在任何引擎相关实现方案定稿之前

**需传入的上下文**：
- 正在使用的具体 API 或功能
- 引擎版本与 LLM 知识截止时间（来自 `docs/engine-reference/[engine]/VERSION.md`）
- 来自 breaking-changes 或 deprecated-apis 文档的相关摘录

**提示词**：
> "对照版本文档审查这项引擎 API 用法。该 API 是否存在于 [engine version]？自 LLM
> 知识截止以来，其签名、行为或命名空间是否发生变化？是否有已知的弃用项或截止
> 之后的替代方案？返回 APPROVE（可按所述安全使用）、CONCERNS [实现前需核实]，
> 或 REJECT [API 已变更——给出修正后的方案]。"

**结论**：APPROVE / CONCERNS / REJECT
