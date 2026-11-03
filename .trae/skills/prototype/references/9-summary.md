# /prototype — Phase 9: 总结与后续步骤

> `/prototype` 的一部分。`SKILL.md` 规定了何时阅读本文件；它已解析的设置以及
> 其后续标题下的规则在这里同样适用。

## Phase 9: 总结与后续步骤

输出一份总结：假设、结果和最终建议。
链接到 `prototypes/[concept-name]-concept/REPORT.md`。

**如果 PROCEED：**
你的概念原型验证了核心想法。现在正式设计它，并参考
你刚刚学到的东西。

在 `workflow: minimal` 下：`/create-stories`（从简报开始），然后对第一个用户故事
运行 `/dev-story`——这个列表的其余部分是 `standard`/`full` 路径。

推荐路径（按顺序，`standard`/`full`）：
1. `/design-review design/gdd/game-concept.md` ——根据原型揭示的内容验证概念文档
2. `/gate-check` ——确认准备好进入系统设计
3. `/art-bible` ——定义视觉识别（可选，但值得在 GDD 之前完成）
4. `/map-systems` ——把概念分解为所有游戏系统
5. `/design-system [mechanic]` ——为每个 MVP 系统编写 GDD；把原型经验用于
   调参旋钮（Tuning Knobs）和公式章节
6. `/review-all-gdds` ——跨系统一致性检查

**注意：** 如果你使用了 HTML 路径且手感仍不确定，考虑在编写 GDD 之前
运行一个以手感为目标的快速引擎路径原型。

**如果 PIVOT：**

在路由到下一个原型之前，记录结转笔记。问以下
两个问题（纯文本，一次一个）：

1. “这个原型中具体哪些做法有效，应该在下一版中保留？”
2. “最需要改变的一件最重要的事是什么？”

询问：“我可以把它写到 `prototypes/[concept-name]-concept/PIVOT-NOTE.md` 吗？”

如果可以，写入文件，内容包括：原始假设、要保留什么、要改变什么，以及
下一个原型的修订假设。下一次 `/prototype` 运行会在 Phase 1 开始时读取它。

- 运行 `/prototype [revised-concept]` 测试调整后的方向
- 或者如果概念需要更根本的重新思考，运行 `/brainstorm [hint]`

**如果 KILL：**

在继续之前，运行这项检查以确认结论合理，而不是一时的挫败：

- [ ] 经过 2 次以上试玩测试后，核心机制对测试者仍不清楚？
- [ ] 在任何会话中都没有观察到“有趣时刻”（微笑、大笑，或主动重试）？
- [ ] 同一概念经历了 3 次以上 PIVOT 迭代，却没有明显改善？
- [ ] 概念只有在大量解释或开发者引导玩家时才成立？
- [ ] 构建它感觉像义务，而不是兴奋？

如果勾选 2 项以上 → KILL 结论合理。如果勾选 0–1 项 → 在杀死它之前考虑再做一次聚焦的 PIVOT。

**在 `prototypes/GRAVEYARD.md` 中记录这次杀死**（不存在则创建）。
询问：“我可以把这个概念追加到 `prototypes/GRAVEYARD.md` 吗？” 如果可以，添加一条记录：

```
## [Concept Name] — YYYY-MM-DD
- **Kill reason:** [specific blocker — not "it was boring" but "players never understood the core action"]
- **What worked:** [2-3 things worth carrying forward to future concepts]
- **What failed:** [the specific mechanic, design decision, or scope issue]
- **Next time:** [one explicit action to try differently on a similar concept]
```

这个文件的存在是为了避免在下一个概念上重犯同样的错误。

- 运行 `/brainstorm open` 或 `/brainstorm [new-hint]` 探索不同的概念
- 原型报告就是交付物——无需进一步操作

**如果 NOT ASSESSED（无人游玩）：**

目前还没有趣味证据，因此 PROCEED、PIVOT 和 KILL 都无法成立——
报告 NOT ASSESSED 并停在这里，不要猜测。

- 去玩它，然后再次运行 `/prototype [same concept]`
- 在发生试玩测试之前，报告和概念索引行都显示 NOT ASSESSED

---

---
