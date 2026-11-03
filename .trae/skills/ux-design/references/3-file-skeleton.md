# /ux-design — 第 3 节：创建文件骨架

> 属于 `/ux-design` 的一部分。`SKILL.md` 指明了何时阅读本文件；它
> 解析出的设置以及其后各标题下的规则在此仍然适用。

## 3. 创建文件骨架

**本文件包含：**

- UX 规格（屏幕或流程）的骨架
- HUD 设计的骨架
- 交互模式库的骨架
- 无障碍要求的骨架

一旦用户确认，**立即**创建带有空小节标题的输出文件。这样可以确保
增量写入有目标，工作成果也能在中断后保留下来。

询问：“我可以在 `design/ux/[filename].md` 创建骨架文件吗？” — 但在
`accessibility` 模式下例外，那里路径是 `design/accessibility-requirements.md`
（见第 1 节的模式表；它有意不放在 `design/ux/` 下）。

---

### UX 规格（屏幕或流程）的骨架

```markdown
# UX Spec: [Screen/Flow Name]

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Journey Phase(s)**: [from context]
> **Platform Target**: [target platforms and input methods from 2h]
> **Template**: UX Spec

---

## Purpose & Player Need

[To be designed]

---

## Player Context on Arrival

[To be designed]

---

## Navigation Position

[To be designed]

---

## Entry & Exit Points

[To be designed]

---

## Layout Specification

### ASCII Wireframe

[To be designed]

### Layout Zones

[To be designed]

### Component Inventory

[To be designed]

### Information Hierarchy

[To be designed]

---

## States & Variants

[To be designed]

---

## Interaction Map

[To be designed]

---

## Data Requirements

[To be designed]

---

## Events Fired

[To be designed]

---

## Transitions & Animations

[To be designed]

---

## Input Method Completeness Checklist

[To be designed]

---

## Accessibility

[To be designed]

---

## Localization Considerations

[To be designed]

---

## Acceptance Criteria

[To be designed]

---

## Open Questions

[To be designed]
```

---

### HUD 设计的骨架

```markdown
# HUD Design

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Platform Targets**: [target platforms and input methods from 2h]
> **Template**: HUD Design

---

## HUD Philosophy

[To be designed]

---

## Information Architecture

### Full Information Inventory

[To be designed]

### Categorization

[To be designed]

---

## Layout Zones

[To be designed]

---

## HUD Element Specifications

[To be designed]

---

## HUD States by Gameplay Context

[To be designed]

---

## Information Hierarchy

[To be designed]

---

## Visual Budget

[To be designed]

---

## Feedback & Notification Systems

[To be designed]

---

## Platform Adaptation

[To be designed]

---

## Accessibility

[To be designed]

---

## Tuning Knobs

[To be designed]

---

## Acceptance Criteria

[To be designed]

---

## Open Questions

[To be designed]
```

---

### 交互模式库的骨架

```markdown
# Interaction Pattern Library

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Template**: Interaction Pattern Library

---

## Overview

[To be designed]

---

## Pattern Catalog

[To be designed]

---

## Patterns

[Individual pattern entries added here as they are defined]

---

## Gaps & Patterns Needed

[To be designed]

---

## Open Questions

[To be designed]
```

---

### 无障碍要求的骨架

小节列表与 `.claude/docs/templates/accessibility-requirements.md` 保持一致 — 如果
模板增加或删除了某个小节，这个骨架会跟随它，而不是反过来。

```markdown
# Accessibility Requirements

> **Status**: In Design
> **Author**: [user + ux-designer]
> **Last Updated**: [today's date]
> **Template**: Accessibility Requirements

## Accessibility Tier Definition

[To be designed]

---

## Visual Accessibility

[To be designed]

---

## Motor Accessibility

[To be designed]

---

## Cognitive Accessibility

[To be designed]

---

## Auditory Accessibility

[To be designed]

---

## Platform Accessibility API Integration

[To be designed]

---

## Per-Feature Accessibility Matrix

[To be designed]

---

## Accessibility Test Plan

[To be designed]

---

## Known Intentional Limitations

[To be designed]

---

## Audit History

[To be designed]

---

## External Resources

[To be designed]

---

## Open Questions

[To be designed]
```

> **等级承诺是受质量闸门约束的部分。** `gate-pre-production.md` 要求
> 该文件存在*且已承诺无障碍等级*，而
> `gate-production.md` 会检查该等级是否在每个关键屏幕规格中得到落实。
> 若骨架的 Tier Definition 仍是 `[To be designed]`，它能满足
> glob，却无法通过质量闸门 — 请先撰写该小节。

---

写出骨架之后，用以下内容更新 `production/session-state/active.md`：
- 任务：设计 [screen/flow name] 的 UX 规格
- 当前小节：开始（骨架已创建）
- 文件：design/ux/[filename].md（或在 `accessibility` 模式下为 `design/accessibility-requirements.md`）

---
