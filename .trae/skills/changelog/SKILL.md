---
name: changelog
description: "从 git 提交与冲刺数据自动生成变更日志。提供内部版本与面向玩家的版本。"
argument-hint: "[version|sprint-number]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

# 变更日志

## 最近历史

最近提交：

**运行并读取输出：** `git log --oneline -30 2>/dev/null || true`

最近标签（最新在前）：

**运行并读取输出：** `git tag --list --sort=-v:refname 2>/dev/null | head -5`

## 来源校验 —— 在信任上述历史之前

**上面的提交可能不属于本游戏。** 本技能要求你先运行上面的命令，再读取其输出 —— 这项检查决定的是该输出是否可用，而不是它是否被获取。

1. 阅读上一步命令输出的提交主题。**如果没有 —— 日志为空或 git 不可用 —— 跳过此项检查**：没有
   可分类的内容，Phase 1 的无历史分支就是正确的停止点。
2. **逐一分类**为 **Game**（机制、内容、平衡性、美术、音频、UI，或其中某处的缺陷）、
   **Framework / maintenance**（主题涉及技能、钩子、agent、测试计划、CI 或框架自身文档），
   或 **Unclear** —— 并把 Unclear 按 Framework 处理。
3. 根据计数决定：
   - **至少有一个 Game 提交** → 只用这些提交继续，并说明你从多少条中用了多少条。
   - **零个 Game 提交** → 停止，使用下面的消息。

> **按单个提交过滤；包含维护工作的仓库并不是错误的仓库。**
> 在这个框架上的每个项目都会累积触及钩子、CI 和技能的提交 —— 游戏仓库*就是*框架仓库，
> 所以因为这类提交而停止几乎会在每个真实项目上触发。真正的危害在于这些提交被写成发布
> 文案，而排除它们恰好能防止这一点。
>
> 此规则有意与 `/patch-notes` 保持一致 —— 两者为不同受众读取同一段历史，它们不能对
> "这是谁的历史"产生分歧。要改就一起改。

真正的错误历史信号与此不同：Game 提交点名的产品，`design/` 与代码根目录（`src/`、`Assets/`
或 `Source/`）从未提及。如果看到这种情况，停止。

如果该范围内**没有**任何提交属于本游戏，说明并停止：

> "此仓库的 git 历史似乎不属于 [game]：最近 [N] 条提交中有 0 条是 Game 提交。这些最近的
> 提交描述的是 [它们实际描述的内容]。我无法据此生成变更日志 —— 请指引我到正确的历史，
> 或直接提供变更清单。"

Verdict：**BLOCKED** —— 就此停止，不生成变更日志。

**为什么这是硬性停止而非警告。** 框架内部的提交一旦被渲染为玩家文案，读起来就像真实变更：
一个会话钩子超时，会在一个**没有存档系统**的游戏里变成*"修复了上次会话进度可能在启动时
丢失的问题"*。这种文案流畅、可信，却完全虚假。读者无法分辨；只有这项检查能分辨。

**不要把这层前言的存在当作证据。** 注入的输出只意味着命令运行过，绝不意味着其主题是你的
游戏。

---

两个块都由上一步命令解析。把它们作为 Phase 2 的起点，而不是重新运行相同的命令。

---

## Phase 1: 解析参数

读取参数中的目标版本或冲刺编号。若给出的是版本，使用对应的 git 标签。若给出的是冲刺编号，
使用该冲刺的日期范围。

验证仓库已初始化：运行 `git rev-parse --is-inside-work-tree` 确认 git 可用。若不是 git 仓库，
告知用户并优雅中止。

**如果没有可读取的历史** —— 不是 git 仓库，或尚无任何提交：

> "未找到 git 历史。变更日志由提交构建而成 —— 请先提交工作，或直接提供变更清单。"

Verdict：**BLOCKED** —— 就此停止，不生成变更日志。

---

## Phase 2: 收集变更数据

读取自上一个标签或发布以来的 git 日志：

```
git log --oneline [last-tag]..HEAD
```

如果不存在任何标签，显式限定范围 —— `git log --oneline -n 100`。不要退回到完整日志：在一个
成熟仓库上，那是一份只覆盖单次发布的变更日志要面对数千行内容，而其中最旧的条目相关性最低。
如果 100 条提交回溯得不够远，如实说明并请求一个起始引用，而不是盲目扩大范围。

从 `production/sprints/` 读取相关期间的冲刺报告，以了解计划中的工作与变更背后的背景。

从 `design/gdd/` 读取本期间所实现任何新功能的已完成设计文档。按章节读取：用 Grep 工具
（pattern `^#`，content 模式）找出需要的标题，再用 offset 与 limit 读取那些范围。

---

## Phase 3: 变更分类

把每项变更归入以下类别之一：

- **新功能**：全新的玩法系统、模式或内容
- **改进**：对现有功能的增强、用户体验改进、性能提升
- **缺陷修复**：对异常行为的修正
- **平衡性变更**：玩法数值、难度、经济系统的调整
- **技术债 / 重构**：对游戏代码的重构与清理，玩家看不到任何变化 —— 即声称重构、清理或整理，
  且没有点名任何修复、功能或调整的提交。仅写入内部变更日志；绝不进入面向玩家的版本
- **已知问题**：团队已了解但尚未解决的问题
- **杂项**：不符合上述类别的变更，或提交信息过于模糊、无法有把握分类的提交

对每个提交，检查其信息是否包含任务 ID 或用户故事引用（例如 `[STORY-123]`、`TR-`、`#NNN`
或类似形式）。统计不含任何任务引用的提交数量，并在 Phase 4 的指标（Metrics）章节中写明：
`Commits without task reference: [N]`。

---

## Phase 4: 生成内部变更日志

```markdown
# Internal Changelog: [Version]
Date: [Date]
Sprint(s): [Sprint numbers covered]
Commits: [Count] ([first-hash]..[last-hash])

## New Features
- [Feature Name] -- [Technical description, affected systems]
  - Commits: [hash1], [hash2]
  - Owner: [who implemented it]
  - Design doc: [link if applicable]

## Improvements
- [Improvement] -- [What changed technically and why]
  - Commits: [hashes]
  - Owner: [who]

## Bug Fixes
- [BUG-ID] [Description of bug and root cause]
  - Fix: [What was changed]
  - Commits: [hashes]
  - Owner: [who]

## Balance Changes
- [What was tuned] -- [Old value -> New value] -- [Design intent]
  - Owner: [who]

## Technical Debt / Refactoring
- [What was cleaned up and why]
  - Commits: [hashes]

## Miscellaneous
- [Change that didn't fit other categories, or vague commit message]
  - Commits: [hashes]

## Known Issues
- [Issue description] -- [Severity] -- [ETA for fix if known]

## Metrics
- Total commits: [N]
- Files changed: [N]
- Lines added: [N]
- Lines removed: [N]
- Commits without task reference: [N]
```

---

## Phase 5: 生成面向玩家的变更日志

```markdown
# What is New in [Version]

## New Features
- **[Feature Name]**: [Player-friendly description of what they can now do
  and why it is exciting. Focus on the experience, not the implementation.]

## Improvements
- **[What improved]**: [How this makes the game better for the player.
  Be specific but avoid jargon.]

## Bug Fixes
- Fixed an issue where [describe what the player experienced, not what was
  wrong in the code]
- Fixed [player-visible symptom]

## Balance Changes
- [What changed in player-understandable terms and the design intent.
  Example: "Healing potions now restore 50 HP (up from 30) -- we felt
  players needed more recovery options in late-game encounters."]

## Known Issues
- We are aware of [issue description in player terms] and are working on a
  fix. [Workaround if one exists.]

---
Thank you for playing! Your feedback helps us make the game better.
Report issues at [link].
```

---

## Phase 6: 输出

向用户输出两份变更日志。内部变更日志是主要工作文档。面向玩家的变更日志在评审后即可用于
社区发布。

---

## Phase 7: 询问是否写入文件

展示变更日志后，询问用户：

> "我可以把这份变更日志写入 `docs/CHANGELOG.md` 吗？
> [A] 是，追加此条目（若文件已存在，推荐此选项）
> [B] 是，完全覆盖该文件
> [C] 否 —— 我自己手动复制"

- 询问前先检查 `docs/CHANGELOG.md` 是否存在。若存在，把推荐项默认为 **[A] 追加**。
- 若用户选择 [A]：把新的内部变更日志条目追加到现有文件的顶部（最新条目在前）。
- 若用户选择 [B]：用新变更日志覆盖该文件。
- 若用户选择 [C]：就此停止，不写入。

写入成功后：Verdict：**CHANGELOG WRITTEN** —— 变更日志已保存至 `docs/CHANGELOG.md`。
若用户拒绝：Verdict：**COMPLETE** —— 变更日志已生成。

---

## Phase 7: 后续步骤

- 使用 `/patch-notes [version]` 生成经过排版、可保存用于公开发布的版本。
- 在对外发布变更日志前，使用 `/release-checklist`。

### 指南

- 绝不在面向玩家的变更日志中暴露内部代码引用、文件路径或开发者姓名
- 把相关变更归组，而不是逐条列出单个提交
- 如果提交信息含义不清，检查相关文件与冲刺数据以获取背景
- 平衡性变更应始终包含设计理由，而不仅是数字
- 已知问题应当诚实 —— 玩家欣赏透明
- 如果 git 历史杂乱（合并提交、回滚、fixup 提交），整理叙事，而不是逐条照抄每个提交