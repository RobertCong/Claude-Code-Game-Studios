> 小节撰写指导，由 `/ux-design` 仅在当前活动模式下加载。
> 绝不要加载另外两个文件 — 每次调用只适用一种模式。

# 小节撰写指导 — 交互模式库模式


模式库撰写是增量式、清单驱动的，而不是线性的。

#### Phase 1: 编目现有模式

对 `design/ux/*.md` 执行 Glob（排除 `interaction-patterns.md`），并阅读每份规格的
组件清单（Component Inventory）与交互映射（Interaction Map）小节。提取其中使用的
每一个交互模式。

呈现提取出的列表：“基于现有 UX 规格，以下模式已经在游戏中使用：”
- [Pattern name]：用于 [screen]、[screen]
- [etc.]

询问：“有没有你知道存在、但尚未出现在现有规格中的模式？现在列出任何
额外的模式。”

---

#### Phase 2: 形式化每个模式

对每个模式（现有的或新的），记录：

```markdown
### [Pattern Name]

**Category**: Navigation / Input / Feedback / Data Display / Modal / Overlay / [other]
**Used In**: [list of screens]

**Description**: [One paragraph explaining what this pattern is and when to use it]

**Specification**:
- [Component behavior]
- [Input mapping]
- [Visual/audio feedback]
- [Accessibility requirements for this pattern]

**When to Use**: [Conditions where this pattern is appropriate]
**When NOT to Use**: [Conditions where another pattern is more appropriate]

**Reference**: [Screenshot path or ASCII example, if available]
```

按组处理模式。使用 `AskUserQuestion`：
- “你希望如何逐一处理这些模式？”
- 选项：“先从现有规格起草第一批（更快）”、“逐个定义（更多控制）”、“从最常用的模式开始”

---

#### Phase 3: 识别缺口

在编目已知模式之后，询问：
- “是否计划了某些屏幕或交互，需要本库中尚不存在的模式？”
- “现有规格中是否有任何模式彼此不一致，应当合并整理？”

在“缺口”小节中记录这些缺口，以便后续跟进。
