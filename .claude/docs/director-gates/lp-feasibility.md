> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# LP-FEASIBILITY — 主程序实现可行性

Agent：`lead-programmer` | 模型层级：session（继承——Tier 2 主管，在需要领域专家给出可行性签署时调用）

**触发时机**：总体架构文档编写完成后（`/create-architecture` Phase 7b），或
提出新的架构模式时

**需传入的上下文**：
- 架构文档路径
- 技术需求基线摘要
- 带状态的 ADR 清单

**提示词**：
> "审查这份架构的实现可行性。指出：(a) 在既定引擎与语言下难以实现或无法实现的
> 决策；(b) 缺失的接口定义，即程序员将不得不自行发明的部分；(c) 会造成可避免的
> 技术债、或与标准 [engine] 惯用法相矛盾的模式。返回 FEASIBLE、CONCERNS [清单]，
> 或 INFEASIBLE [使这份架构按原样无法实现的阻塞项]。"

**结论**：FEASIBLE / CONCERNS / INFEASIBLE
