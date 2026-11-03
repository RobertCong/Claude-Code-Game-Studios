> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-CHANGE-IMPACT — 设计变更影响评审

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：设计变更影响报告生成之后
（`/propagate-design-change` Phase 6），在解决工作流开始之前

**需传入的上下文**：
- Phase 6 的完整设计变更影响报告——变更摘要、每个受影响 ADR 及其
  Still Valid / Needs Review / Likely Superseded 分类，以及建议采取的行动

**提示词**：
> "在任何 ADR 被修订之前，审查这份设计变更影响评估。影响分类是否正确——特别是，
> 是否有 ADR 被分类得过轻（在变更实际已与其假设相矛盾时仍标为 Still Valid）？
> 建议采取的行动在架构上是否健全？是否遗漏了对其他 ADR 或系统的连锁影响——
> 即依赖那些已被标记项的其他决策？返回 APPROVE、CONCERNS [需要重新审视的具体
> ADR 或建议]，或 REJECT [必须在解决工作开始前重新分析该评估——说明遗漏了什么]。"

**结论**：APPROVE / CONCERNS / REJECT
