# Agent Teams（实验性 —— 需主动启用）

> 按需查阅的参考资料。v1.1 中已从 `coordination-rules.md`（一个始终加载的
> CLAUDE.md 导入文件）中降级移出 —— 在真正考虑组建团队时阅读本文件，
> 而不是每一轮都读。

多个独立的 Claude Code *会话*同时运行，通过共享任务列表进行协调。每个会话都有自己的上下文窗口和 token 预算。需要设置 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 环境变量。

## 何时使用 agent teams

- 工作跨越多个子系统，且不会触碰相同的文件
- 每条工作流耗时超过 30 分钟，且能从真正的并行中获益
- 资深 agent（technical-director、producer）需要协调 3 个以上同时处理不同史诗（epic）的专家会话

## 何时不要使用 agent teams

- 一个会话的输出是另一个会话的输入（改用顺序执行的子 agent）
- 任务能装进单个会话的上下文（改用子 agent）
- 在意成本 —— 每个团队成员都会独立消耗 token

## 当前状态

通过 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 主动启用。采用后请在此处记录首次使用情况。
