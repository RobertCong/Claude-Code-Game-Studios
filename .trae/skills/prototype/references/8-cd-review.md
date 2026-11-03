# /prototype — Phase 8: 创意总监评审

> `/prototype` 的一部分。`SKILL.md` 规定了何时阅读本文件；它已解析的设置以及
> 其后续标题下的规则在这里同样适用。

## Phase 8: 创意总监评审

**评审模式检查：**
- `solo` → 跳过。注明：“CD-PLAYTEST skipped — Solo mode.”
- `lean` → 跳过。注明：“CD-PLAYTEST skipped — Lean mode.”
- `full` → 如果 `design/gdd/game-concept.md` 存在且已定义游戏支柱，
  或 `design/game-brief.md` 存在（`rigor: minimal` 简报没有支柱——由它的
  提案和“他们感受如何”那一行代替），则通过 `Agent` 使用 **CD-PLAYTEST** 闸门
  生成 `creative-director`。如果两者都不可用，注明：
  “CD-PLAYTEST skipped — game pillars not yet defined at concept prototype stage.”

传入：完整的 REPORT.md 内容、原始假设，以及来自 `design/gdd/game-concept.md`
的游戏支柱 / 核心幻想（或来自 `design/game-brief.md` 的简报提案和“他们感受如何”
那一行）。按节读取概念：用 Grep 工具（pattern `^#`，content 模式）找到你需要的
标题，然后用 offset 和 limit 读取对应范围。

创意总监根据游戏创意愿景评估结果，并返回该闸门的某种结论——APPROVE、CONCERNS 或
REJECT——或在无法判断时返回 NOT ASSESSED。将它应用到建议上：

- **APPROVE** → 建议维持不变。
- **CONCERNS** → 在建议旁边展示关注项，然后使用
  `AskUserQuestion`：`Revise the recommendation` / `Accept with noted concerns` /
  `Discuss further`。由用户决定；总监不决定。
- **REJECT**（核心幻想不存在）→ PROCEED 建议无法维持。使用 `AskUserQuestion`
  请用户选择 `PIVOT` 或 `KILL`，并针对该选择运行 Phase 9。PIVOT 或 KILL 建议维持。
- **NOT ASSESSED**（总监缺少某项输入——`.claude/docs/director-gates.md`）
  → 不是批准。指出缺失了什么；补充它并重新运行闸门，或
  把该评审记录为 NOT ASSESSED，让用户决定该建议是否在未评审的情况下维持。

当总监返回 CONCERNS、REJECT 或 NOT ASSESSED 时，询问“我可以更新
`prototypes/[concept-name]-concept/REPORT.md` 及其 `prototypes/index.md`
行吗？”，然后在 REPORT.md 中记录总监的结论与理由，如果最终建议发生了变化，
则在两处都记录最终建议。

---
