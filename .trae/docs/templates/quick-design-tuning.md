# Quick Design Spec: [Title]

**Type**: Tuning
**System**: [系统名称]
**GDD Reference**: `design/gdd/[filename].md` — Tuning Knobs section
**Date**: [today]

## Change

| Parameter | Old Value | New Value | Rationale |
|-----------|-----------|-----------|-----------|
| [param]   | [old]     | [new]     | [原因]     |

## Tuning Knob Mapping

映射到 GDD Tuning Knob：[旋钮名称及其记录的取值范围]。
新值 [在记录范围内 / 处于范围边缘 / 超出记录范围]。
[若超出：解释为何应扩展该范围。]

## Acceptance Criteria

- [ ] [Parameter] 从 `assets/data/[file]` 读取 [new value]
- [ ] 在 [特定情境] 中可观察到行为差异
- [ ] [相关行为] 无回归
