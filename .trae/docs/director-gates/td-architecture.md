> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-ARCHITECTURE — 架构签署确认

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：总体架构文档起草完成后（`/create-architecture`
Phase 7），以及任何重大架构修订之后

**需传入的上下文**：
- 架构文档路径（`docs/architecture/architecture.md`）
- 技术需求基线（TR-ID 与数量）
- 带状态的 ADR 清单
- 引擎知识缺口清单

**提示词**：
> "审查这份总体架构文档的技术健全性。检查：(1) 基线中的每项技术需求是否都有架构
> 决策覆盖？(2) 所有 HIGH 风险的引擎领域是否都被明确处理，或标为待解问题？
> (3) API 边界是否清晰、最小且可实现？(4) Foundation 层的 ADR 缺口是否在实现
> 开始前解决？返回 APPROVE、CONCERNS [清单]，或 REJECT [编码开始前必须解决的
> 阻塞项]。"

**结论**：APPROVE / CONCERNS / REJECT
