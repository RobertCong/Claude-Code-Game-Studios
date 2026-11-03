# Quick Design Spec: [Title]

**Type**: New Small System
**Scope**: [用 1-2 句话描述此系统做什么、不做什么]
**Date**: [today]
**Estimated Implementation**: [hours]

## Overview

[一段新团队成员也能看懂的话。此系统做什么、
何时激活、产出什么？]

## Core Rules

[该系统无歧义的规则。行为按顺序时用编号列表，
条件用项目符号列表。精确到程序员无需提问即可实现。]

## Tuning Knobs

| Knob | Default | Range | Category | Rationale |
|------|---------|-------|----------|-----------|
| [name] | [value] | [min–max] | [feel/curve/gate] | [为何采用此默认值] |

所有数值必须放在 `assets/data/[appropriate-file].json` 中，不得硬编码。

## Acceptance Criteria

- [ ] [功能标准：做正确的事]
- [ ] [功能标准：处理边界情况]
- [ ] [体验标准：手感正确——由试玩测试验证的内容]
- [ ] [回归标准：不破坏相邻系统]

## Systems Index

此系统目前不在 `design/gdd/systems-index.md` 中。
[若应加入：建议放在哪一层及哪个优先级档位。]
[若小到无需跟踪：写明「此系统低于 systems-index
跟踪阈值——快速规格已足够。」]
