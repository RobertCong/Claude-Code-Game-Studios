# /adopt — Phase 3: 对缺口进行分类并排定优先级

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 3: 对缺口进行分类并排定优先级

将所有审计中发现的每个缺口归入四个严重程度层级：

**BLOCKING** — 会让模板技能*现在就*静默产生错误结果。
示例：ADR 缺少 Status 字段、systems-index 中带括号的状态值、
存在 ADR 但引擎未配置。

**HIGH** — 会导致生成缺少安全检查的用户故事，或
基础设施引导会失败。
示例：ADR 缺少 Engine Compatibility、GDD 缺少 Acceptance Criteria
（无法据此生成用户故事）、tr-registry.yaml 缺失。

**MEDIUM** — 会降低质量和流水线追踪能力，但不破坏功能。
示例：GDD 缺少 Tuning Knobs 或 Formulas 章节、用户故事缺少 TR-ID、
sprint-status.yaml 缺失。

**LOW** — 事后改进项，值得做但不紧急。
示例：用户故事缺少 Manifest Version 标记、GDD 缺少 Open Questions 章节。

按层级统计总数。如果 BLOCKING 和 HIGH 缺口均为零：报告项目
已兼容模板，仅剩建议性改进。

---
