# /architecture-review — Phase 6: 架构文档覆盖率

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 6: 架构文档覆盖率

**如果 `docs/architecture/architecture.md` 不存在，请在报告中说明** ——
`Architecture document coverage: NOT ASSESSED — no docs/architecture/architecture.md`
—— 并按下面的触发条件列表把它带入 Phase 7 的结论。静默地不产出任何 Phase 6 发现，
读起来就像架构文档已被检查且一切正常，而这与实际情况正好相反。

如果它存在，对照 GDD 验证它：

- `systems-index.md` 中的每个系统是否都出现在架构分层中？
- 数据流章节是否覆盖 GDD 中定义的所有跨系统通信？
- API 边界是否支持 GDD 中的所有集成需求？
- 架构文档中是否有系统没有对应的 GDD
  （孤立架构）？

---
