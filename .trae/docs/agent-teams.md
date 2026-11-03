# Agent Teams（Trae 说明）

> 按需查阅的参考资料。v1.1 中已从 `coordination-rules.md`（一个始终加载的
> AGENTS.md 导入文件）中降级移出 —— 在真正考虑组建团队时阅读本文件，
> 而不是每一轮都读。

## Trae 没有 Claude Code 的 Agent Teams

Trae 不支持 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`，也没有“多个独立会话共享
任务列表”的机制。可用的并行方式是 **子代理（Subagent）**：

- 内置 Agent 可以在一次会话中派生多个子代理，每个子代理有独立上下文。
- 子代理由 `description` 匹配调度，不能强制按名字调用。
- 多个子代理可以处理不同文件/子系统，但它们的结果回到同一个主会话。

## 何时使用子代理

- 工作跨越多个子系统，且不会触碰相同的文件
- 单个子任务需要大量检索、分析或推理，但最终只需要返回结果
- 资深 agent（technical-director、producer）需要把不同领域的评审分派出去

## 何时不要使用子代理

- 一个子任务的输出是另一个子任务的输入（改用顺序执行）
- 任务能装进单个会话的上下文（直接在主会话完成）
- 在意成本 —— 每个子代理都会独立消耗 token

## 当前状态

Trae 子代理已在 `.trae/agents/` 中配置 49 个角色。需要在 Trae 设置中打开
**Beta > Subagents > 启用 Subagents 目录**。团队编排技能（`team-*`）会把子代理
分派写成描述式指令；实际调度由内置 Agent 决定。
