# /architecture-decision — 改造模式

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

**如果参数以 `retrofit` 开头并跟一个文件路径**

（例如 `/architecture-decision retrofit docs/architecture/adr-0001-event-system.md`）：

进入**改造模式**：

1. 完整读取现有 ADR 文件。此步骤需要整个 ADR：按标题划分范围读取它
   （用 Grep 工具查找：pattern `^#`，content 模式），因为对超过 40 KB 的文件
   整文件 Read 会被拒绝。
2. 通过扫描标题识别哪些模板章节已存在：
   - `## Status` —— **缺失则 BLOCKING**：`/story-readiness` 无法检查 ADR 是否被接受
   - `## ADR Dependencies` —— 缺失则 HIGH：依赖排序会破坏
   - `## Engine Compatibility` —— 缺失则 HIGH：截止后风险未知。表格存在但
     没有 **Layer** 行同样为 HIGH：无论在哪里读取，该 ADR 都会被算作关键，
     因此在 `standard` 下其建议项会变成阻塞项
   - `## GDD Requirements Addressed` —— 缺失则 MEDIUM：丢失可追溯性
   - `## Date` —— 缺失且也没有 `## Last Verified` 时为 MEDIUM：`/create-stories`
     会用它标注用户故事，`/dev-story` 会与之比对，因此没有它，
     用户故事永远无法判断 ADR 是否变更过
3. 向用户展示：
   ```
   ## Retrofit: [ADR title]
   File: [path]

   Sections already present (will not be touched):
   ✓ Status: [current value, or "MISSING — will add"]
   ✓ [section]

   Missing sections to add:
   ✗ Status — BLOCKING (stories cannot validate ADR acceptance without this)
   ✗ ADR Dependencies — HIGH
   ✗ Engine Compatibility — HIGH
   ```
4. 询问："是否添加这 [N] 个缺失章节？我不会修改任何现有内容。"
   若否：什么都不写，并按名称报告缺失章节。
5. 若是：
   - 对于 **Status**：询问用户——"此决策当前的状态是什么？"
     选项："Proposed"、"Accepted"、"Deprecated"、"Superseded by ADR-XXXX"
     `Accepted` 回答——一个已生效的决策——不会按原样写入：
     写 `Proposed`，添加其他缺失章节，然后对此 ADR 运行
     接受模式（见下）。其依赖检查、确认和
     用户故事解除阻塞在这里同样适用；它仍是唯一设置 `Accepted` 的路径。
   - 对于 **ADR Dependencies**：询问——"此决策是否依赖其他 ADR？
     它是否启用或阻塞其他 ADR 或史诗？" 每个字段接受 "None"。
   - 对于 **Engine Compatibility**：读取引擎参考文档（与下面的第 1 步相同）
     并请用户确认领域。然后用已验证数据生成表格，
     其中包含其 Layer 行。
   - 对于存在但缺少 **Layer** 行的 Engine Compatibility 表格：按
     `references/5-generate.md` 中 "Always write the Layer row" 所述找到
     层级，并在 **Domain** 下方添加该行。只增加一行，不改动任何内容。
   - 对于 **GDD Requirements Addressed**：询问——"哪些 GDD 系统促使了此决策？
     此 ADR 解决了每个 GDD 中的哪些具体需求？"
   - 使用 Edit 工具将每个缺失章节追加到 ADR 文件。
   - 对于 **Date**（仅在没有 `## Last Verified` 时计入）：追加
     `## Date` 及今天的日期——即使它是唯一缺失的章节，即
     `/dev-story` 把你送到这里的场景——并说明它记录的是改造，
     而不是决策作出时间。
   - **绝不修改任何现有章节。** 只追加或填充缺失的章节。
6. 建议："运行 `/architecture-review`，在此 ADR 已具备 Status 和 Dependencies
   字段的情况下重新验证覆盖率。"
