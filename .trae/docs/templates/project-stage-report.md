# Project Stage Analysis

**Date**: [date]
**Stage**: [Concept/Systems Design/Technical Setup/Pre-Production/Production/Polish/Release]
**Stage Confidence**: [PASS — 明确检测到 / CONCERNS — 信号不明确 / NOT ASSESSED — 阶段所依赖的检查未运行 / FAIL — 关键差距阻碍进展]
**Analysis Scope**: [完整项目 | 特定角色：programmer/designer/producer]

## Completeness Overview
- Design: [X%]（[N] 份文档，[gaps]）
- Code: [X%]（[N] 个文件，[systems]）
- Architecture: [X%]（[N] 份 ADR，[gaps]）
- Production: [X%]（[status]——在 `minimal` 下：故事按简报的构建顺序完成，绝不写「no sprint plan」）
- Tests: [X%]（[覆盖率估计]）

## Stage Classification Rationale
**Configured stage**: [`project.yaml` 中的 `project.stage`，否则 `production/stage.txt`，否则 "not set"]
**Observed stage**: [扫描到的产出物所指示的阶段]
[针对所观察阶段找到的指标。当两个阶段不一致时应说明：
配置的阶段可能已过期，或者工作存在于本仓库之外。在
`workflow: minimal` 下配置的阶段不会推进，因此这种滞后是预期之内的。]

## Gaps Identified
1. [差距描述 + 澄清问题]
2. [差距描述 + 澄清问题]

## Recommended Next Steps
[基于阶段与角色的优先级排序列表]

## Role-Specific Recommendations

[仅当给出了角色筛选时——该角色的关注领域]

## Follow-Up Skills to Run

[仅适用于项目工作流层级所暴露的差距对应的技能——例如
概念阶段尚无系统索引时用 `/map-systems`，决策未记录时用 `/architecture-decision`，
缺少制作计划时用 `/sprint-plan`（在 `rigor: minimal` 下不适用）]

## Appendix: File Counts by Directory

```
design/
  gdd/           [N] files
  narrative/     [N] files
  levels/        [N] files

[code root]/     (src/, Assets/ or Source/<Module>/)
  core/          [N] files
  gameplay/      [N] files
  ai/            [N] files
  networking/    [N] files
  ui/            [N] files

docs/
  architecture/  [N] ADRs

production/
  sprints/       [N] plans
  milestones/    [N] definitions

tests/           [N] test files
prototypes/      [N] directories
```

*由 `/project-stage-detect` 生成*
