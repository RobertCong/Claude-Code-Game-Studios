# Technical Design: [System Name]

## Document Status
- **Version**: 1.0
- **Last Updated**: [Date]
- **Author**: [Agent/Person]
- **Reviewer**: lead-programmer
- **Related ADR**: [ADR-XXXX if applicable]
- **Related Design Doc**: [实现本文档所依据的游戏设计文档链接]

## Engine API Surface

| Field | Value |
|-------|-------|
| **Engine** | [例如 Godot 4.7 / Unity 6 / Unreal Engine 5.8] |
| **APIs Depended On** | [使用的具体类/方法/节点，固定版本——例如 `CharacterBody3D.move_and_slide() (Godot 4.x)`] |
| **References Consulted** | [撰写前阅读的引擎参考资料——例如 `docs/engine-reference/godot/modules/physics.md`] |
| **Post-Cutoff Features Used** | [超出 LLM 训练截止时间的引擎版本功能，或 "None"] |
| **Unverified Assumptions** | [已假设但尚未针对目标版本测试的 API 行为，或 "None"] |
| **Engine Upgrade Risk** | [LOW / MEDIUM / HIGH——若引擎版本变化，此设计有多脆弱？] |

> **Rule**：如果列出了任何 **Unverified Assumptions**，在那些假设于实际引擎
> 环境中得到验证之前，本文档不能标记为 Accepted。

## Overview
[用 2-3 句话概述该系统的功能及存在原因]

## Requirements
### Functional Requirements
- [FR-1]：[描述]
- [FR-2]：[描述]

### Non-Functional Requirements
- **Performance**: [预算——例如「每帧 < 1ms」]
- **Memory**: [预算——例如「峰值 < 50MB」]
- **Scalability**: [限制——例如「支持最多 1000 个实体」]
- **Thread Safety**: [要求]

## Architecture

### System Diagram
```
[ASCII diagram showing components and data flow]
```

### Component Breakdown
| Component | Responsibility | Owns |
| --------- | -------------- | ---- |
| [Name] | [它做什么] | [它拥有什么数据] |

### Public API
```
[Interface/API definition in pseudocode or target language]
```

### Data Structures
```
[Key data structures with field descriptions]
```

### Data Flow
[逐步说明：在典型的一帧中数据如何流经系统]

## Implementation Plan

### Phase 1: [Core Functionality]
- [ ] [Task 1]
- [ ] [Task 2]

### Phase 2: [Extended Features]
- [ ] [Task 3]
- [ ] [Task 4]

### Phase 3: [Optimization/Polish]
- [ ] [Task 5]

## Dependencies
| Depends On | For What |
| ---------- | -------- |
| [System] | [原因] |

| Depended On By | For What |
| -------------- | -------- |
| [System] | [原因] |

## Testing Strategy
- **Unit Tests**: [在单元层面测试什么]
- **Integration Tests**: [所需的跨系统测试]
- **Performance Tests**: [要创建的基准]
- **Edge Cases**: [要测试的具体场景]

## Known Limitations
[此设计有意不支持什么，以及为什么]

## Future Considerations
[如果需求演变可能需要改变什么——但现在不要为此构建]
