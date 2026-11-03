> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# PR-PHASE-GATE — 阶段转换时的制作就绪度

Agent：`producer` | 模型层级：session（继承） | 领域：范围、时间线、依赖、制作风险

**触发时机**：每次 `/gate-check` 总监评审小组都会触发——producer 在每一种 `modes.workflow` 下都在小组中；与小组其余成员并行发起（`minimal` 时单独，`standard` 时与 TD-PHASE-GATE，`full` 时与 TD-PHASE-GATE、CD-PHASE-GATE 和 AD-PHASE-GATE）

**需传入的上下文**：
- 目标阶段名称与解析出的 `workflow` 层级
- 在解析层级下目标闸门必需与推荐的产出物（来自 `/gate-check` 已加载的闸门文件）
- 现存的冲刺与里程碑产出物——在 `minimal` 下，`design/game-brief.md` 中的 Build order 即为计划（该层级没有冲刺计划）
- 团队规模（`team.size`）与冲刺产能（来自当前冲刺计划，如存在）
- 当前被阻塞的用户故事数量

**提示词**：
> "从制作角度审查当前项目状态相对于[目标阶段]闸门的就绪度，以本闸门在该层级
> 所要求的内容（即提供给你的必需产出物清单）为判据。范围相对于既定时间线与团队
> 规模是否现实？[目标阶段]的工作是否已规划到本闸门要求的深度——从 Production
> 闸门起，`standard`/`full` 需冲刺计划，`minimal` 需简报中的 Build order；在该
> 闸门之前，不要求冲刺计划——其依赖排序是否能让团队按序执行？有哪些里程碑或
> 进度风险可能打乱[目标阶段]的启动（即其前两个冲刺，在该层级按冲刺规划的范围内）？
> 必需产出物被标为 "none" 算作一项发现；标为 "not expected before [phase]" 或
> "not required at `workflow: [tier]`" 则不算发现。
> 返回 READY、CONCERNS [清单]，或 NOT READY [阻塞项]。"

**结论**：READY / CONCERNS / NOT READY
