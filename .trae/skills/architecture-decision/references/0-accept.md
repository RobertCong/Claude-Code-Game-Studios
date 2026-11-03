# /architecture-decision — 接受模式

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

**如果参数以 `accept` 开头并跟一个 ADR id**

（例如 `/architecture-decision accept ADR-0005`）：

进入**接受模式**。这是框架中*唯一*能把 ADR 从 `Proposed` 变为 `Accepted` 的路径。
撰写始终产生 `Proposed`（第 5 步），而
`/create-control-manifest`、`/create-epics`、`/create-stories` 和 `/gate-check`
都要求 `Accepted` —— 因此若没有此模式，ADR 会进入一个永远无法离开的状态。

1. **将 id 解析为文件，然后读取它。** 用 Glob 匹配给定编号的
   `docs/architecture/adr-NNNN-*.md`。如果**没有**文件匹配，
   或**多于一个**匹配，则停下并说明是哪种——不要挑一个。如果文件
   没有 `## Status` 章节，停下并说明；缺失 Status 正是改造模式的用途。
2. **检查当前状态。** 如果已经是 `Accepted`，说明并停止。
   如果是 `Deprecated` 或 `Superseded`，拒绝：复活一个已被取代的决策
   是一项新的 ADR，而不是编辑状态。
3. **先检查其依赖。** 读取 `## ADR Dependencies`。

   **如果该章节缺失、为空或写着 `UNKNOWN`，不要把它读作
   "无依赖"——拒绝并说明属于哪种：**
   > "ADR-0005 的依赖章节 [缺失 / 为 UNKNOWN]，因此我无法判断
   > 此决策依赖什么。空依赖列表和未检查的依赖列表在这里看起来
   > 完全一样，而其中只有一种可以安全接受。运行
   > `/architecture-decision retrofit <path>` 来建立它。"

   对默认空字段做依赖检查，正是此质量闸门要防止的空转通过
   形态——该检查不会检查任何内容却报告干净。

   如果它依赖任何本身不是 `Accepted` 的 ADR，**拒绝并点名它们**：
   > "ADR-0005 依赖 ADR-0002，而后者仍为 Proposed。请先接受 ADR-0002
   > ——建立在未被接受决策之上的已接受决策不是决策，
   > 而是换了个标签的延迟。"
   这与 `/architecture-review` 已标出的依赖规则相同；在这里它是
   强制执行，而不是报告。
4. **始终与用户确认。** 根据 `CONTRACT.md`，接受权威是
   **用户，或在用户明确确认下的 `technical-director` —— 没有其他 agent，
   也绝不由本技能自行决定。** 使用 `AskUserQuestion`：
   - 提示："接受 ADR-NNNN —— [标题]？这正是解除依赖它的用户故事与
     史诗阻塞的动作。"
   - 选项：`[A] 是 —— 接受` / `[B] 还不是 —— 保持 Proposed`
   **此提示无论 `modes.automation` 如何都会触发，包括 `autonomous`。**
   接受是整个架构流水线所依据的闸门决策；它不是
   可以推断的步骤。
5. **在第 4 步的提示之前，找到这次接受将解除阻塞的用户故事。** 用 Grep
   在每个用户故事中查找 Blocked Status 行 ——
   `Grep pattern="Status\**:\**\s*Blocked" path="production/epics" glob="**/story-*.md" output_mode="files_with_matches"`，
   它匹配 `> **Status**: Blocked`（`/create-stories` 写入的形式）、
   `**Status:** Blocked` 和 `Status: Blocked` —— 并保留那些以
   此 ADR 的 id 作为阻塞原因的文件。这种配对就是 "blocked
   pending this ADR" 的含义——因无关原因阻塞的用户故事不会
   点名它。排除只把此 ADR 作为后继指向对象提及的用户故事
   （`point the story at ADR-NNNN`，即对 `Deprecated` 或
   `Superseded` ADR 的说明）：它仍受旧 ADR 管辖，接受
   后继者不会重新指向它。
   > **用户故事只存在于 `production/epics/` 之下。** 平铺的顶层用户故事
   > 目录并不存在，也没有技能会创建它——绝不要写入或匹配
   > `production/epics/` 之外的路径。`/dev-story` 按*文件
   > 路径*匹配条目，因此记录在其他路径下的用户故事会静默匹配失败，
   > 永远不会被拾取。

   把计数传入第 4 步的提示，使其读作 *"3 个用户故事将变为 Ready"*
   而不是笼统的说法：**用户被要求授权一项效果，就应当
   看到该效果。** 如果没有匹配项，说 "没有用户故事在等待此决策"——这是
   有用的信息，而不是应省略的空结果。
6. 确认后，用 `Edit` 把 `## Status` 行改为 `Accepted`。保留已有的
   `## Date` 不动：它记录 ADR 的撰写时间，`/create-stories`
   会用它（或 `## Last Verified`）标注用户故事，因此在接受时重写它
   会让所有针对 Proposed ADR 起草的用户故事在
   `/dev-story` 看来都过时了。**如果该章节缺失，则添加它**，使用今天的日期——改造
   模式已经负责这种形态，接受不能因为模板早于该字段而失败。
7. 然后，把第 5 步找到的每个用户故事从 `Blocked` 设为 `Ready`。解除阻塞是
   接受的后果，绝不是撰写的后果——见下面第 6 步的说明。
8. 报告变更内容：ADR（以及其 `## Date`，若新增了的话），以及每个
   变为 Ready 的用户故事。
