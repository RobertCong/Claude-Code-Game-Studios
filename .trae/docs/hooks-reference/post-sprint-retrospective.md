# 钩子：post-sprint-retrospective

## Trigger（触发时机）

在每个冲刺结束时手动触发（通常由 producer
代理或人类开发者调用）。

## Purpose（目的）

通过分析冲刺数据自动生成回顾起点：
计划了什么与完成了什么、速率变化、缺陷趋势和常见
阻塞项。这不是 git 钩子，而是通过
`producer` 代理调用的工作流钩子。

## Implementation（实现）

这是一个工作流钩子，不是 git 钩子。通过运行以下命令调用：

```
@producer Generate sprint retrospective for Sprint [N]
```

producer 代理应当：

1. **读取冲刺计划**，来自 `production/sprints/sprint-[N].md`
2. **计算指标**：
   - 计划任务数与完成任务数
   - 计划故事点与完成故事点（如使用）
   - 上一冲刺结转的事项
   - 冲刺中期新增的任务
   - 平均任务完成时间
3. **分析模式**：
   - 最常见的阻塞项
   - 哪个代理/领域有最多未完成的工作
   - 哪些估算最不准确
4. **生成回顾**：

```markdown
# Sprint [N] Retrospective

## Metrics
| Metric | Value |
|--------|-------|
| Tasks Planned | [N] |
| Tasks Completed | [N] |
| Completion Rate | [X%] |
| Carryover from Previous | [N] |
| New Tasks Added | [N] |
| Bugs Found | [N] |
| Bugs Fixed | [N] |

## Velocity Trend
[Sprint N-2]: [X] | [Sprint N-1]: [Y] | [Sprint N]: [Z]
Trend: [Improving / Stable / Declining]

## What Went Well
- [Automatically detected: tasks completed ahead of estimate]
- [Facilitator adds team observations]

## What Went Poorly
- [Automatically detected: tasks that were carried over or cut]
- [Automatically detected: areas with significant estimate overruns]
- [Facilitator adds team observations]

## Blockers
| Blocker | Frequency | Resolution Time | Prevention |
|---------|-----------|----------------|-----------|

## Action Items for Next Sprint
| # | Action | Owner | Priority |
|---|--------|-------|----------|

## Estimation Accuracy
| Area | Avg Planned | Avg Actual | Accuracy |
|------|------------|-----------|----------|
```

5. **保存**到 `production/sprints/sprint-[N]-retro.md`
