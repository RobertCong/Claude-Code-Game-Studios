# /prototype — Phase 2: 加载概念上下文

> `/prototype` 的一部分。`SKILL.md` 规定了何时阅读本文件；它已解析的设置以及
> 其后续标题下的规则在这里同样适用。

## Phase 2: 加载概念上下文

如果存在 `design/gdd/game-concept.md`——或在 `rigor: minimal` 下替代它的一页式简报
`design/game-brief.md`——就读它。按节阅读：用 Grep 工具（pattern `^#`，content
模式）找到你需要的标题，然后用 offset 和 limit 读取对应范围。提取：
- 核心幻想（玩家应该感受到什么）
- 核心循环（正在被测试的即时操作）

确定所使用的引擎与语言：从 `project.yaml` 读取 `engine.name` 和
`engine.language`。对于每个字段，如果键缺失或为空（包括 `project.yaml` 中没有
`engine:` 块的情况），回退到 `CLAUDE.md` 和 `.claude/docs/technical-preferences.md`。
将 `[TO BE CONFIGURED]` 值视为未设置。

---
