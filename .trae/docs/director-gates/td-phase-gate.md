> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-PHASE-GATE — 阶段转换时的技术就绪度

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：在 `/gate-check` 中且 `modes.workflow` 为 `standard` 或 `full` 时——评审小组按工作流收窄；与小组其余成员并行发起（PR-PHASE-GATE，`full` 时另加 CD-PHASE-GATE 和 AD-PHASE-GATE）

**需传入的上下文**：
- 目标阶段名称与解析出的 `workflow` 层级
- 在解析层级下目标闸门必需与推荐的产出物（来自 `/gate-check` 已加载的闸门文件）
- 架构文档路径（如存在）
- 引擎参考资料路径
- ADR 清单

**提示词**：
> "从技术方向角度审查当前项目状态相对于[目标阶段]闸门的就绪度，以本闸门在该层级
> 所要求的内容（即提供给你的必需产出物清单）为判据，而非以更后阶段的需要为判据。
> 本阶段所需的技术基础是否就位且健全——进入 Systems Design 时，概念在所选引擎上
> 是否可行；进入 Technical Setup 时，系统索引与 GDD 是否足以据以设计架构；进入
> Pre-Production 时，架构是否健全、Foundation 层决策是否完整到可以开始实现；进入
> Production 或更后阶段时，架构在构建中是否站得住？高风险引擎领域是否已处理到本
> 阶段要求的深度？性能预算在本阶段要求之处是否现实并有文档记录？
> 必需产出物被标为 "none" 算作一项发现；标为 "not expected before [phase]" 或
> "not required at `workflow: [tier]`" 则不算发现。
> 返回 READY、CONCERNS [清单]，或 NOT READY [阻塞项]。"

**结论**：READY / CONCERNS / NOT READY
