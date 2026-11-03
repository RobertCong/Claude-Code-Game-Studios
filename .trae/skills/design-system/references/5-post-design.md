# /design-system — Phase 5: 设计后校验

> 属于 `/design-system` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## 5. 设计后校验

**本文件包含：**

- 5-pre：撰写 Summary
- 5a：自检
- 5a-bis：创意总监支柱评审
- 5b：更新实体注册表
- 5c：提供设计评审
- 5d：更新系统索引
- 5e：更新会话状态
- 5f：建议下一步

所有章节都写完之后：

### 5-pre：撰写 Summary

现在撰写 `## Summary` 及其 `> **Quick reference**` 行 —— 在设计存在之后写，这样摘要
提炼的是真实内容而非意图。此步骤在**每个层级**都运行，包括 `standard` 和自愿撰写的
`minimal` GDD：有了 Summary，后续技能才能扫描 20 份 GDD 并决定哪份需要完整阅读
（`/create-epics`、`/architecture-review`、`/review-all-gdds` 都会 grep 它），
因此没有它的 GDD 会静默地迫使这些消费方回到完整读取。

- **Summary 正文**：2–3 句话 —— 这个系统是什么、它为玩家做什么、它为何存在于
  这款游戏中。不要术语堆砌；没读过这份 GDD 的读者应能判断它是否与自己的任务相关。
- **Quick reference**：`Layer` 与 `Priority` 取自系统索引
  （`design/gdd/systems-index.md`）；`Key deps` 取自刚写完的 Dependencies 章节
  （系统名称，或 `None`）。

替换骨架中的 `[To be designed]` Summary 占位符。然后像其他任何章节一样应用章节循环的
Write 步骤。

### 5a：自检

从文件中回读完整的 GDD（而非从对话记忆 —— 文件才是唯一事实来源）。此步骤需要整份
GDD：按其标题分段读取（用 Grep 工具找到：模式 `^#`，内容模式），因为超过 40 KB 的
整文件 Read 会被拒绝。验证：
- `## Summary` 及其 Quick reference 已填充（不是占位符）
- **本系统生效层级所要求**的每个章节都有真实内容
  （不是占位符）—— §1：`full` 下 8 个，`standard` 下 5 个 + 条件性 Formulas，
  自愿 `minimal` 下 5 个。不要对照固定的 8 个来验证：在 `full` 以下，那样会把一个
  撰写正确的 GDD 报告为不完整
- Formulas 引用了已定义的变量
- Edge Cases 有解决方案
- Dependencies 列出了接口
- Acceptance Criteria 可测试

### 5a-bis：创意总监支柱评审

**评审模式检查** —— 在派生 CD-GDD-ALIGN 之前应用：
- `solo` → 跳过。注明："CD-GDD-ALIGN skipped — Solo mode."。继续到 Step 5b。
- `lean` → 跳过（不是 PHASE-GATE）。注明："CD-GDD-ALIGN skipped — Lean mode."。继续到 Step 5b。
- `full` → 照常派生。

在最终确定 GDD 之前，通过 `Agent` 使用质量闸门 **CD-GDD-ALIGN**（`.claude/docs/director-gates/cd-gdd-align.md`）派生 `creative-director`。

传入：已完成的 GDD 文件路径、游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`；若两者都没有，则用提案和 `design/game-brief.md` 中 "what they feel" 那一行）、MDA 美学目标，以及 GDD 的 Player Fantasy 章节 —— 或者，若本层级未撰写该章节，则说明这一点。

按 `director-gates.md` 中的标准规则处理结论。
对于 `Revise flagged items`，或为了处理 REJECT，每个被标记章节重新运行其章节循环 ——
其专家按该章节的评审模式检查所述进行咨询 —— 并在写入它的 Edit 之前，通过其
"Approve the [Section Name] section?" 控件重新批准；然后记录 `REVISED [date]`。
`NOT ASSESSED` 回答永远不是批准：点名缺失的输入，然后补充它并重新运行闸门，或记录
`NOT ASSESSED`。
解决后，在 GDD 的 Status 头部记录结论：
`> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]`

---

### 5b：更新实体注册表

扫描已完成的 GDD，找出应登记的跨系统事实：
- 带属性或掉落物的具名实体（敌人、NPC、首领）
- 带数值、权重或类别的具名物品
- 带已定义变量与输出范围的具名公式
- 在不止一处按值引用的具名常量

**首先检查注册表是否存在** —— §2a 是*"若存在"*时才读取它，而此步骤需要同样的
守卫。在 `standard` 及以下层级，该文件常常不存在，而对缺失路径的 grep 不会返回任何
内容，这与"尚无候选被登记"无法区分：

- **不存在** —— 说明这一点，并询问是否创建它：
  *"`design/registry/entities.yaml` 不存在。我可以用这 [N] 个条目创建它吗？"*
  若用户拒绝，跳过 5b 并说明注册表未被写入 —— 不要把跳过当作干净
  通过。
- **存在但为空** —— 所有列表都是 `[]`，或者唯一的匹配都在注释块内。把它视为存在，
  登记候选项，但要说明你发现的状态：*"注册表存在且为空 —— 全部 [N] 个条目都是新条目。"*
  随附模板的注释带有完整成形的示例，引用了 `design/gdd/inventory.md`，
  数值看起来很真实（`base_inventory_slots: 20`、`gold_carry_limit: 9999`），
  因此 §2a 的注册表 grep 在一个空注册表上会返回**注释行** —— 而 §2d 随后会把这些
  虚构的数字作为*"这些值已锁定。"*呈现给用户。只在活动的
  `entities:`/`items:`/`formulas:`/`constants:` 键下匹配条目，绝不要匹配注释示例。
- **存在** —— 对每个候选检查它是否已登记：

```
Grep pattern="  - name: [candidate_name]" path="design/registry/entities.yaml"
```

呈现摘要：
```
Registry candidates from this GDD:
  NEW (not yet registered):
    - [entity_name] [entity]: [attribute]=[value], [attribute]=[value]
    - [item_name] [item]: [attribute]=[value], [attribute]=[value]
    - [formula_name] [formula]: variables=[list], output=[min–max]
  ALREADY REGISTERED (referenced_by will be updated):
    - [constant_name] [constant]: value=[N] ← matches registry ✅
```

询问："我可以用这 [N] 个新条目更新 `design/registry/entities.yaml`，并更新现有条目的
`referenced_by` 吗？"（如果文件此前不存在且用户同意创建，措辞应为*创建*而非*更新*，
并且没有需要合并的 `referenced_by` 数组。）

若同意：追加新条目并更新 `referenced_by` 数组。未经先将其作为冲突暴露，绝不要修改
现有的 `value` / 属性字段。

写入后，运行 `bash .claude/scripts/registry.sh validate`，并在继续之前修复所有关于
本次写入新增或修改条目的行（DUPLICATE、STATUS 或 LAYOUT 行，或其点名的路径的
PATH_MISSING 行）；关于其他条目的行请告知用户，而不是未经请求就去修复。如果脚本
缺失或没有输出，说明注册表检查未运行，然后对照文件头部的规则重新阅读你写入的条目。

### 5c：提供设计评审

呈现完成摘要：

> **GDD Complete: [System Name]**
> - 已撰写章节：[list]
> - 临时假设：[list any assumptions about undesigned dependencies]
> - 发现的跨系统冲突：[list or "none"]

> **要校验此 GDD，请打开一个新的 Claude Code 会话并运行：**
> `/design-review design/gdd/[system-name].md`
>
> **绝不要在同一个会话中运行 `/design-review` 和 `/design-system`。** 评审
> 代理必须独立于撰写上下文。在此处运行它会继承完整的设计历史，使独立批评变得不可能。

**绝不要提议内联运行 `/design-review`。** 始终引导用户打开新窗口。

### 5d：更新系统索引

在 GDD 完成之后（并可选完成评审后）：

**首先检查系统索引是否存在。** §2a 在 `minimal` 下跳过它，因为该层级从不写入该文件，
而此步骤需要与 §5b 相同的守卫。这在带有 `system_overrides` 提升的 `minimal` 项目上
最为重要 —— 那里生效层级是 `standard` 或 `full`，而 §5 中没有其他内容提示该文件可能
缺失。

- **不存在** —— 用一行说明（*"本工作流层级下没有 `design/gdd/systems-index.md`；无需更新"*）并跳到 §5e。**不要**提议创建一个：
  该文件由 `/map-systems` 负责，在此处写一个占位版本会变成一个只列出一个系统的
  系统索引。
- **存在** —— 继续：

- 按章节读取系统索引：用 Grep 工具找出需要的标题（模式 `^#`，内容模式），
  再用 offset 和 limit 读取相应范围
- 更新目标系统的行：
  - 若已运行设计评审且结论为 APPROVED：Status → "Approved"
  - 若已运行设计评审且结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED：Status → "Needs Revision"（精确使用该字符串 —— `/design-review` 只在修订被应用后才设置 "In Review"）
  - 若跳过了设计评审：Status → "Designed"（待评审）
  - 若用户选择 "I'll review it myself first"：Status → "Designed"
  - Design Doc：链接到 `design/gdd/[system-name].md`
- 更新 Progress Tracker 计数

询问："我可以更新 `design/gdd/systems-index.md` 处的系统索引吗？"

### 5e：更新会话状态

用以下内容更新 `production/session-state/active.md`：
- Task: [system-name] GDD
- Status: Complete（若运行了设计评审则为 In Review）
- File: design/gdd/[system-name].md
- Sections: [按名称列出实际撰写的章节] —— **绝不用固定
  数量**；§5a 禁止对照 `/8` 验证，同样的理由也适用于记录它。在 `full` 以下，撰写
  正确的 GDD 少于 8 个章节，而把 "All 8 written" 写入会话状态会让下一位读者认为
  一份完整的 GDD 是不完整的
- Next: [suggest next system from design order]

### 5f：建议下一步

使用 `AskUserQuestion`：
- "接下来做什么？"
  - 选项：
    - "运行 `/consistency-check` —— 验证本 GDD 的值不与现有 GDD 冲突（建议在设计下一个系统之前运行）"
    - "设计下一个系统（[next-in-order]）" —— 若仍有未设计的系统
    - "修复评审发现的问题" —— 若设计评审标出了问题
    - "本次会话到此为止"
    - "运行 `/gate-check`" —— 若已设计了足够的 MVP 系统

---
