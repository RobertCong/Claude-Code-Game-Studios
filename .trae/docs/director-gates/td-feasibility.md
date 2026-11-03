> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-FEASIBILITY — 技术可行性评估

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：在范围/可行性评估中识别出最大技术风险之后
（头脑风暴 Phase 6，或任何带有技术未知项的早期概念）

**需传入的上下文**：
- 概念的核心循环描述
- 目标平台
- 引擎选择（或 "undecided"）
- 已识别技术风险清单

**提示词**：
> "审查这款面向 [platform]、使用 [engine 或 'undecided engine'] 的 [genre] 游戏
> 的技术风险。标出任何可能使该概念按所述方式失效的 HIGH 风险项，任何与引擎相关、
> 并应影响引擎选择的风险，以及单人开发者常低估的任何风险。返回 VIABLE（风险可控）、
> CONCERNS [含缓解建议的清单]，或 HIGH RISK [需要修订概念或范围的阻塞项]。"

**结论**：VIABLE / CONCERNS / HIGH RISK
