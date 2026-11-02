> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-ADR — 架构决策评审

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：单份 ADR 编写完成后（`/architecture-decision`），在其被标记为
Accepted 之前

**需传入的上下文**：
- ADR 文件路径
- 引擎版本与该领域的知识缺口风险等级
- 相关 ADR（如有）

**提示词**：
> "审查这份架构决策记录（ADR）。它是否有清晰的问题陈述与理由？被否决的备选方案
> 是否得到了真正的考虑？Consequences 章节是否如实承认了取舍？引擎版本是否已标注？
> 截止日期之后的 API 风险是否已标出？是否链接到它所覆盖的 GDD 需求？返回 APPROVE、
> CONCERNS [具体缺口]，或 REJECT [决策规定不足，或做出了不健全的技术假设]。"

**结论**：APPROVE / CONCERNS / REJECT
