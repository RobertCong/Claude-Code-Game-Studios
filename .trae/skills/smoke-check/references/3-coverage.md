# /smoke-check — Phase 3: 检查测试覆盖率

> 属于 `/smoke-check`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 3: 检查测试覆盖率

按以下优先级顺序获取用户故事列表：
1. Phase 1 中找到的 QA 计划（其 Test Summary 表列出了每个用户故事预期的测试文件路径）
2. 来自 `production/sprints/` 的当前冲刺计划（最近修改的文件）
3. 如果传入了 `quick` 参数，则完全跳过本阶段并注明：
   "Coverage scan skipped — run `/smoke-check sprint` for full coverage analysis."

对范围内的每个用户故事：

1. 从用户故事的文件路径中提取系统 slug
   （例如 `production/epics/combat/story-001.md` → `combat`）
2. 在 `tests/unit/[system]/` 和 `tests/integration/[system]/` 中 glob 文件名包含该用户故事 slug 或密切相关术语的文件
3. 检查用户故事文件本身是否有 `Test file:` 头部字段或 "Test Evidence" 章节

为每个用户故事分配覆盖率状态：

| Status | 含义 |
|--------|---------|
| **COVERED** | 找到了与该用户故事的系统与范围匹配的测试文件 |
| **MANUAL** | 用户故事类型为 Visual/Feel 或 UI；找到了测试证据文档 |
| **MISSING** | Logic 或 Integration 用户故事但没有匹配的测试文件 |
| **EXPECTED** | Config/Data 用户故事 — 不需要测试文件；抽查即可 |
| **UNKNOWN** | 用户故事文件缺失或无法读取 |

MISSING 条目是建议性缺口。它们不会导致 FAIL 结论，但必须在报告中显著呈现，并且必须在 `/story-done` 能完全关闭那些用户故事之前得到解决。

---
