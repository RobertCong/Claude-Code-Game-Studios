> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# CD-PHASE-GATE — 阶段转换时的创意就绪度

Agent：`creative-director` | 模型层级：session（继承） | 领域：愿景、支柱、玩家体验

**触发时机**：在 `/gate-check` 中且 `modes.workflow` 为 `full` 时——评审小组按工作流收窄，只有 full 小组才包含 creative-director；与 TD-PHASE-GATE、PR-PHASE-GATE 和 AD-PHASE-GATE 并行发起

**需传入的上下文**：
- 目标阶段名称与解析出的 `workflow` 层级
- 在解析层级下目标闸门必需与推荐的产出物（来自 `/gate-check` 已加载的闸门文件）
- 现存所有产出物的列表（文件路径）
- 游戏支柱与核心幻想

**提示词**：
> "从创意方向角度审查当前项目状态相对于[目标阶段]闸门的就绪度，以本闸门在该层级
> 所要求的内容（即提供给你的必需产出物清单）为判据。游戏支柱是否在本阶段要求的
> 设计产出物中得到了忠实体现？当前状态是否守住了核心幻想？迄今已有的 GDD、
> 架构或构建中的设计决策，是否有任何一项损害了预期的玩家体验？
> 必需产出物被标为 "none" 算作一项发现；标为 "not expected before [phase]" 或
> "not required at `workflow: [tier]`" 则不算发现。
> 返回 READY、CONCERNS [清单]，或 NOT READY [阻塞项]。"

**结论**：READY / CONCERNS / NOT READY
