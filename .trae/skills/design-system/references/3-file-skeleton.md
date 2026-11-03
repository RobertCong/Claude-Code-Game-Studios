# /design-system — Phase 3: 创建文件骨架

> 属于 `/design-system` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## 3. 创建文件骨架

**本文件包含：**

- 在解析出的层级下应搭建哪些章节
- GDD 骨架
- 写入文件，然后更新会话状态

一旦用户确认，**立即**创建带空章节标题的 GDD 文件。这确保增量写入有目标可循。

**只搭建解析出的层级所要求的章节**（§1）：在 `standard` 下，省略 Player Fantasy
和 Tuning Knobs（仅当系统不定义数值规则时省略 Formulas —— 见 §1；类别只是提示，
不是判断依据）；在 `full` 下，搭建全部 8 个。
**只跳过 §1 点名要省略的章节** —— 不要为这些章节留下空的 `[To be designed]`
占位符。模板中的其他每个章节都用其占位符搭建，包括 §4 尚未决定的章节。
这句话只管辖上述三个层级省略项（Player Fantasy、Tuning Knobs，以及无数值规则时的
Formulas），仅此而已：它不是因为某个章节看起来可选就删掉它的许可，而 §4 也无法填写
§3 从未创建的章节。

使用 `.claude/docs/templates/game-design-document.md` 中的模板结构：

```markdown
# [System Name]

> **Status**: In Design
> **Author**: [user + agents]
> **Last Updated**: [today's date]
> **Last Verified**: [today's date]
> **Implements Pillar**: [from context]

## Summary

[To be designed]

> **Quick reference** — Layer: `[Foundation | Core | Feature | Presentation]` · Priority: `[MVP | Vertical Slice | Alpha | Full Vision]` · Key deps: `[System names or "None"]`

## Overview

[To be designed]

## Player Fantasy

[To be designed]

## Detailed Design

### Core Rules

[To be designed]

### States and Transitions

[To be designed]

### Interactions with Other Systems

[To be designed]

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## Game Feel

[To be designed]

## UI Requirements

[To be designed]

## Cross-References

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
```

询问："我可以在 `design/gdd/[system-name].md` 创建骨架文件吗？"

如果用户拒绝：以下列消息停止：
> "结论：**BLOCKED** —— 拒绝创建骨架文件。没有骨架文件，设计会话无法继续，因为所有后续阶段都以它为基准。准备好创建文件时，重新运行 `/design-system [system]`。"
不要进入 Section A。

写入之后，更新 `production/session-state/active.md`：
- 使用 Glob 检查文件是否存在。
- 如果它**不存在**：使用 **Write** 工具创建它。绝不要对可能不存在的文件尝试 Edit。
- 如果它**已存在**：使用 **Edit** 工具更新相关字段。

文件内容：
- Task: Designing [system-name] GDD
- Current section: Starting (skeleton created)
- File: design/gdd/[system-name].md

---
