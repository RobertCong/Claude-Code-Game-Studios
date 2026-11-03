# /setup-engine — 第 12 节：输出摘要

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 12. 输出摘要

设置完成后，输出：

```
Engine Setup Complete
=====================
Engine:          [name] [version]
Language:        [GDScript | C# | GDScript + C# | C# | C++ + Blueprint | Blueprint + C++]
Knowledge Risk:  [LOW/MEDIUM/HIGH]
Reference Docs:  [created/skipped]
AGENTS.md:       [updated]
Tech Prefs:      [created/updated]
project.yaml:    [created/updated]
Agent Config:    [verified]

Next Steps:
1. Review docs/engine-reference/<engine>/VERSION.md
```

然后打印**一份** Next Steps 列表，与解析出的 `workflow` 层级匹配：

**`minimal` — 精简的 4 步基础流程（你正处于第 1 步）：**
```
2. Run /brainstorm to produce your one-page design/game-brief.md (the lean-tier design artifact)
3. Run /create-stories to turn the brief's MVP list into stories
4. Run /dev-story — first line of game code
```
（在 `minimal` 层级没有 `/map-systems`、`/design-system`、`/prototype` 或
`/sprint-plan` — 简报取代 GDD，其构建顺序就是计划。）

**`standard` / `full` — 完整流水线：**
```
2. [If from /brainstorm] Run /map-systems to decompose your concept into individual systems
3. [If from /brainstorm] Run /design-system to author per-system GDDs (guided, section-by-section)
4. [If from /brainstorm] Run /prototype [core-mechanic] to validate the core idea before writing GDDs
5. [If fresh start] Run /brainstorm to discover your game concept
6. Create your first milestone: /sprint-plan new
```

---

结论：**COMPLETE** — 引擎已配置，参考资料已填充。
