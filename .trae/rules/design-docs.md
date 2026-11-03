---
alwaysApply: false
globs: design/gdd/**
---

# 设计文档规则

- GDD 的 8 个章节是：Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria
- **需要多少个章节取决于 `modes.workflow`** —— `full` 需要全部 8 个；`standard` 需要 5 个（当系统**定义了数值规则**时再加 Formulas：速率、曲线、阈值、成本、伤害、掉落权重——任何平衡性调整会调整的东西）；`minimal` 不需要（此时的设计记录是 `design/game-brief.md`）。在把某章节标记为缺失前先解析层级；见 `.trae/docs/workflow-modes.md`
- **Formulas 的判定标准是系统定义了什么，而不是它叫什么。** 系统在 `systems-index.md` 中的 `Category` 只是提示——`Gameplay`、`Economy` 和 `Progression` 几乎总符合——绝不是判定依据。不要用类别标记来决定是否要求 Formulas：`/map-systems` 写入的类别（`Core · Gameplay · Progression · Economy · Persistence · UI · Audio · Narrative · Meta`）不包含 `combat` 或 `AI`，而它们是 `Gameplay` *内部*的示例系统。每一处陈述此规则的地方都必须陈述同一个判定标准。
- **章节名别名**：GDD 模板和 `/design-system` 把这一章节写作 `## Detailed Design`；设计标准称其为 **Detailed Rules**。它们是同一个必需章节——两种标题都接受，且绝不要把其中一个改写成另一个。
- Formulas 必须包含变量定义、预期取值范围和示例计算
- Edge Cases 必须明确说明会发生什么，而不只是「优雅处理」
- Dependencies 必须是双向的——如果系统 A 依赖 B，B 的文档必须提到 A
- Tuning Knobs 必须指定安全范围以及它们影响哪个玩法方面
- Acceptance Criteria 必须可测试——QA 测试人员必须能够验证通过/失败
- 不许含糊其辞：「系统应该感觉良好」不是有效的规格说明
- 平衡数值必须链接到其来源公式或理由
- 设计文档必须增量编写：先创建骨架，然后在每个章节之间获得用户批准后逐节填写。每批准一个章节就立即写入文件，以固化决策并管理上下文
