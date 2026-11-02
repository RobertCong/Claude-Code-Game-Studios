# /architecture-decision — 第 4 步：协作式引导决策

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## 4. 协作式引导决策

在询问任何问题之前，先根据已收集的上下文（已读取的 GDD、已加载的引擎参考、已扫描的现有 ADR）
推导出技能的最佳推测。然后用 `AskUserQuestion` 呈现一个**确认/调整**提示——而不是开放式问题。

**先推导假设：**
- **问题**：从标题 + GDD 上下文推断需要做出什么决策
- **替代方案**：根据引擎参考 + GDD 需求提出 2-3 个具体选项
- **依赖**：扫描现有 ADR 中的上游依赖。**如果扫描
  无定论，呈现 `UNKNOWN — scan inconclusive, please confirm`，绝不要
  用 `None`。** 二者不可互换：`None` 断言没有任何上游内容
  约束此决策，而用户确认一个预填列表时无法区分
  断言与猜测。此字段是承重的——`/architecture-review`
  标出未被接受的依赖，`/dev-story` 读取它，而 Phase 0 中的接受路径
  **会拒绝接受依赖本身未处于 Accepted 状态的 ADR**。一个默认设为空的依赖列表
  会让该检查通过，却什么都没检查。`UNKNOWN` 必须在确认/调整
  提示期间解决；它是一种提示状态，绝不是写入文件的值
- **GDD 链接**：提取标题直接关联的 GDD 系统
- **状态**：新 ADR 始终为 `Proposed` —— 绝不要询问用户状态是什么

**假设选项的范围**：假设只覆盖：问题框定、替代方案、上游依赖、GDD 链接和状态。模式设计问题（例如 "生成时机应如何工作？"、"数据应内联还是外部？"）不是假设——它们是设计决策，属于假设确认后的单独步骤。不要将模式设计问题纳入假设的 AskUserQuestion 控件。

**假设确认后**，如果 ADR 涉及模式或数据设计选择，在起草前使用一个单独的多选项卡 `AskUserQuestion` 逐一独立询问每个设计问题。

**用 `AskUserQuestion` 呈现假设：**

```
Here's what I'm assuming before drafting:

Problem: [one-sentence problem statement derived from context]
Alternatives I'll consider:
  A) [option derived from engine reference]
  B) [option derived from GDD requirements]
  C) [option from common patterns]
GDD systems driving this: [list derived from context]
Dependencies: [upstream ADRs if any, otherwise "None"]
Status: Proposed

[A] Proceed — draft with these assumptions
[B] Change the alternatives list
[C] Adjust the GDD linkage
[D] Add a performance budget constraint
[E] Something else needs changing first
```

在用户确认假设或给出修正之前，不要生成 ADR。

**在引擎专家与 TD 评审返回后**（第 5.5/5.6 步），如果仍有未解决的
决策，将每个决策作为单独的 `AskUserQuestion` 呈现，把提议选项作为可选项
外加一个自由文本兜底出口：

```
Decision: [specific unresolved point]
[A] [option from specialist review]
[B] [alternative option]
[C] Different approach — I'll describe it
```

**ADR Dependencies** —— 从现有 ADR 推导，然后确认：
- 此决策是否依赖任何尚未 Accepted 的其他 ADR？
- 它是否解锁或解除任何其他 ADR 或史诗的阻塞？
- 它是否阻塞任何特定史诗启动？

将回答记录在 **ADR Dependencies** 章节中。如果无约束适用，每个字段都写 "None"。

---
