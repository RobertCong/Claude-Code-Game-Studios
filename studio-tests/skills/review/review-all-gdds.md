# Skill Test Spec: /review-all-gdds

## Skill Summary

`/review-all-gdds` 是一个 Opus 层级技能，对 `design/gdd/` 中的系统 GDD 执行
全局性的跨 GDD 评审。加载全部内容后（Phase 1），它并行运行两轮独立评审，
均以 `game-designer` 子代理执行：Phase 2，跨 GDD 一致性（依赖双向性、规则
矛盾、过时引用、归属冲突、公式兼容性、验收标准冲突），以及 Phase 3，游戏设计
整体性（相互竞争的增长循环、注意力预算、支配性策略、经济循环、难度曲线、
游戏支柱一致性、玩家幻想一致性）。Phase 4 走查多系统场景。它产生 PASS /
NOT ASSESSED / CONCERNS / FAIL 结论，并且仅在用户批准后才写入
`design/gdd/gdd-cross-review-[YYYY-MM-DD].md` 和 systems-index 的
"Needs Revision" 状态。

每个阶段都是一个 `references/N-*.md` 文件，技能在执行该阶段之前读取它，并在
该阶段期间会话被压缩时再读一次。参数选择聚焦点：`full`（默认）、`consistency`、
`design-theory`，或 `since-last-review`（其范围取自
`.claude/scripts/review-scope.sh`）。

它在各 GDD 分别获批之后、架构工作之前被调用。它不启动任何总监闸门代理。
在 `workflow: minimal` 下它不适用（没有 GDD），因此下面每个 fixture 都设置
`modes.workflow: full`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥5 个阶段标题（复杂多阶段技能）
- [ ] 包含结论关键词：PASS、NOT ASSESSED、CONCERNS、FAIL
- [ ] `allowed-tools` 包含 Write，因此存在 "May I write" 措辞（Phase 6 报告写入）
- [ ] 结尾有下一步交接
- [ ] 记录了 Phase 2（一致性）与 Phase 3（设计理论）的并行启动

---

## Director Gate Checks

没有总监闸门 —— 此技能不启动任何总监闸门代理，也不解析评审模式。它本身就是
整体评审；其唯一的代理是用于 Phase 2 和 Phase 3 的两个 `game-designer` 子代理。

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 干净的 GDD 集合，无冲突

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 包含 `game-concept.md`、`game-pillars.md`（游戏支柱与反支柱）、
  `systems-index.md`，以及三份系统 GDD —— `combat.md`、`inventory.md`、
  `crafting.md` —— 各自含有 Phase 1c 加载的每个小节，以及一份已填写且所有行
  都可解析的 `## Cross-References` 表
- 所有 GDD 都一致：没有公式矛盾、没有相互竞争的归属、没有过时引用、依赖
  互为双向；每个系统都服务于某个游戏支柱
- 设计理论检查也不会警告任何内容：一个主增长循环、同时最多 4 个活跃系统、
  每种资源都有来源和去向、扩展曲线兼容、玩家幻想兼容

**输入：** `/review-all-gdds`

**预期行为：**
1. 技能对 `design/gdd/*.md` 执行 `## Summary` 的 grep，并展示清单（"Found [N] GDDs. Summaries: …"）
2. 技能读取实体注册表，或注明其为空并建议 `/consistency-check`
3. 技能加载评审小节并报告 "Loaded [N] system GDDs covering [M] systems. Pillars: […]. Anti-pillars: […]."
4. Phase 2 和 Phase 3 作为 `game-designer` 子代理同时启动，各自收到为其切片
   粘贴的 GDD 内容（不是文件路径）及其检查清单（2a–2f / 3a–3g）
5. Phase 4 走查 3–5 个多系统场景
6. 报告显示没有阻塞问题也没有警告；结论 PASS
7. `AskUserQuestion`："May I write this review to `design/gdd/gdd-cross-review-[date].md`?"
8. 收尾部件由项目状态构建

**断言：**
- [ ] Phase 2 和 Phase 3 并行启动（两个 `Agent` 调用都在等待任一结果前发出）
- [ ] 子代理提示带有 GDD 小节内容，而不只是文件路径
- [ ] 报告声明覆盖集：`GDDs reviewed: [N] of [M] present` 和 `Not read: none`，并列出所走查的场景
- [ ] 结论为 PASS 仅因为在三份可读 GDD 上没有阻塞问题**且没有警告** —— 单条警告就会使其成为 CONCERNS
- [ ] 报告仅在用户批准后写入，文件名采用 ISO 日期（`gdd-cross-review-YYYY-MM-DD.md`）
- [ ] 收尾部件提供 `/create-architecture` 和 `/gate-check`（PASS 时二者都允许）

---

### Case 2: 失败路径 — 两份 GDD 之间的规则冲突

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `combat.md` 定义了一个下限："Minimum damage after armour reduction is 1"
- `status-effects.md` 陈述了一个绕过它的机制："Poison ignores armour
  and can reduce damage to 0"
- 两份 GDD 在其他方面完整且有效；`game-pillars.md` 定义了游戏支柱，
  `systems-index.md` 列出了两个系统

**输入：** `/review-all-gdds`

**预期行为：**
1. Phase 2 检测到下限/上限矛盾
2. 报告打印一条 `🔴 Rule Contradiction` 条目，引用两条规则并询问哪份 GDD 具有权威
3. 该问题位于 Consistency Issues → Blocking 下；两份 GDD 都出现在 "GDDs Flagged for Revision" 中
4. 结论：FAIL，并附 "If FAIL — required actions before re-running"
5. 在报告写入问题之后，第二个 `AskUserQuestion` 提议在 `systems-index.md` 中将
   被标记的 GDD 标为 `Needs Revision`

**断言：**
- [ ] 结论为 FAIL（不是 PASS、CONCERNS 或 NOT ASSESSED）
- [ ] 冲突条目中点名两份 GDD 的文件名
- [ ] 引用了具体的冲突规则（而不是含糊的 "conflict found"）
- [ ] 该问题被归类为 Blocking（🔴），且两份 GDD 都在标记表中，Priority 为 Blocking
- [ ] 技能不判定哪份 GDD 正确，也不编辑任何一份 GDD
- [ ] 若用户批准 systems-index 更新，状态精确写为 `Needs Revision`，不带括号说明
- [ ] 收尾部件既不提供 `/create-architecture` 也不提供 `/gate-check`（结论为 FAIL）

---

### Case 3: 部分路径 — 交叉引用指向不存在的 GDD

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 `game-pillars.md`、`systems-index.md` 和两份一致的
  系统 GDD：`crafting.md` 与 `inventory.md`
- `crafting.md` 的 `## Cross-References` 表中有一行 Target GDD 为
  `system-b.md`；不存在 `design/gdd/system-b.md`
- `systems-index.md` 将 system-b 列为下一个系统，Status: Not Started
- 其他方面不会有任何警告

**输入：** `/review-all-gdds`

**预期行为：**
1. Phase 2 的过时引用检查（2c）确认每个 Cross-References 行的 Target GDD
   都存在，并发现 `system-b.md` 缺失
2. 因为 `systems-index.md` 列出了 system-b，该引用是对计划中工作的依赖：
   一条 `⚠️ Stale Reference` 警告，点名 `crafting.md` 和缺失的目标，待该 GDD
   编写时重新检查
3. 未发现其他问题；结论 CONCERNS（有警告，但无阻塞项）
4. 收尾部件包含 `/design-system system-b`（设计顺序中的下一个）

**断言：**
- [ ] 发现点名 `crafting.md` 和缺失的 `system-b.md`
- [ ] 它被报告在 Warnings（⚠️）下，而非 Blocking —— 因为系统索引将 system-b 列为计划中
- [ ] 结论为 CONCERNS —— 对计划中工作的引用不判 FAIL，也不是无条件的 PASS
- [ ] 收尾部件提供 `/design-system system-b`，并提供 `/create-architecture` 但不提供 `/gate-check`（后者要求 PASS）
- [ ] 技能不跳过也不静默忽略该缺失目标

**Case 3b — 目标两处都没有：** 同一夹具，但 `systems-index.md` 没有
system-b 的条目。永远不会有任何东西定义它。

**断言（3b）：**
- [ ] 该引用被报告为 🔴 Blocking，且 `crafting.md` 出现在 "GDDs Flagged for Revision" 中，Priority 为 Blocking
- [ ] 结论为 FAIL，且收尾部件既不提供 `/create-architecture` 也不提供 `/gate-check`

---

### Case 4: 边界情况 — 少于两份系统 GDD

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 包含 `systems-index.md` 和单份系统 GDD `combat.md`

**输入：** `/review-all-gdds`

**预期行为：**
1. 技能加载存在的内容并统计系统 GDD 数量
2. 少于 2 份 → 技能停止并提示："Cross-GDD review requires at least 2 system
   GDDs. Write more GDDs first, then re-run `/review-all-gdds`."
3. 不运行任何评审阶段，也不提供报告

**断言：**
- [ ] 技能输出 "requires at least 2 system GDDs" 停止消息
- [ ] Phase 2 和 Phase 3 子代理都不启动
- [ ] 不为该单一文档产生 PASS 结论
- [ ] 不提供报告写入，也不写入任何文件

---

### Case 5: 总监闸门 — 无论评审模式如何都不启动

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 Case 1 的集合：概念、支柱、系统索引和三份一致的系统 GDD
- 5a：`modes.review_mode: full`；5b：`modes.review_mode: solo`

**输入：** `/review-all-gdds`

**预期行为：**
1. 已解析的配置块只请求 `automation`、`workflow` 和
   `system_overrides` —— 不参考评审模式
2. 在 5a 和 5b 中，同样的两个 `game-designer` 子代理运行 Phase 2 和 Phase 3
3. 不启动任何总监闸门代理；结论照常产生

**断言：**
- [ ] 两种模式下都不启动任何总监闸门代理（CD-、TD-、PR-、AD-、LP- 前缀的闸门）
- [ ] 评审模式不改变任何事：在 `solo` 下两个 `game-designer` 子代理仍然运行
- [ ] 输出不包含 "Gate: [GATE-ID]" 或 "[GATE-ID] skipped" 条目
- [ ] 技能在两种模式下都产生结论
- [ ] 本次运行中唯一的 `Agent` 启动是 Phase 2 和 Phase 3 的 `game-designer` 子代理

---

### Case 6: NOT ASSESSED — 可读 GDD 少于两份

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 `game-pillars.md`、`systems-index.md` 和两份系统 GDD：
  完整的 `combat.md`，以及 `inventory.md` —— 后者有模板标题，但其下只有占位文本

**输入：** `/review-all-gdds`

**预期行为：**
1. 存在两份系统 GDD，因此 "requires at least 2 system GDDs" 停止不会触发
2. `inventory.md` 存在但为空 —— 无法评审 —— 因此只能比较一份 GDD，干净的结果
   只会意味着什么都没比较
3. 结论 NOT ASSESSED；"If NOT ASSESSED — what could not be reviewed, and why"
   点名 `inventory.md` 仅有占位内容，并说明跨评审需要两份可读的 GDD
4. 报告声明 `GDDs reviewed: 1 of 2 present`

**断言：**
- [ ] 结论为 NOT ASSESSED —— 尽管未发现矛盾，也不是 PASS
- [ ] 报告点名 `inventory.md` 存在但不可评审，并声明 `GDDs reviewed: 1 of 2 present`
- [ ] 完全无法读取的 GDD 会在每个结论下被列在报告的 `Not read:` 行，且与空文档一样是 NOT ASSESSED 的触发项
- [ ] 收尾部件既不提供 `/create-architecture` 也不提供 `/gate-check`

---

### Case 7: Phase 文件按需读取，压缩后再次读取

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 Case 1 的集合：概念、支柱、系统索引和三份一致的系统 GDD
- 技能文件夹含有 `references/1-load.md` 到 `references/7-handoff.md`
- 当 Phase 4（场景走查）进行中时会话被压缩，随后运行继续

**输入：** `/review-all-gdds`

**预期行为：**
1. SKILL.md 不包含阶段步骤；在 Phase 1 之前运行会读取 `references/1-load.md`，
   且在该读取之前不扫描 `## Summary` 行、不加载 GDD 小节
2. Phase 2 和 Phase 3 作为 `game-designer` 子代理并行启动，主运行在向每个子代理
   传递其检查清单（2a–2f、3a–3g）之前读取 `references/2-consistency.md` 和
   `references/3-design-holism.md`
3. `references/4-scenarios.md`、`5-report.md`、`6-write.md` 和 `7-handoff.md`
   都各自在该阶段工作前读取：场景前读第一个，结论或报告前读 `5-report.md`，
   写入问题前读 `6-write.md`，收尾部件前读 `7-handoff.md`
4. 压缩之后，运行在继续走查前再次读取 `references/4-scenarios.md`，正如技能所述：
   "Read it again if the conversation was compacted or resumed during this phase."

**断言：**
- [ ] 记录显示七个 `references/N-*.md` 文件各被读取一次，且都在该阶段工作开始前
- [ ] 任何阶段工作（摘要扫描、检查清单交接、场景、结论、写入问题、收尾部件）都不在其阶段文件被读取前发生
- [ ] 压缩之后，在走查恢复前再次读取 `references/4-scenarios.md`
- [ ] Phase 2 和 Phase 3 子代理仍并行启动，并带有来自阶段文件的检查清单条目

---

### Case 8: `since-last-review` — 范围来自脚本，而非自行对 git 推理

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 `game-pillars.md`、`systems-index.md`、一份已提交的
  `gdd-cross-review-2025-01-15.md`，以及四份系统 GDD：`combat.md`、
  `inventory.md`、`crafting.md`、`status-effects.md`
- 自该报告提交以来只有 `combat.md` 被修改；其 `## Dependencies` 小节点名
  `inventory.md`
- `crafting.md` 和 `status-effects.md` 未变，且没有变更的 GDD 点名它们
- `.claude/scripts/review-scope.sh` 打印
  `PRIOR_REVIEW: design/gdd/gdd-cross-review-2025-01-15.md`、带
  `design/gdd/combat.md` 的 `CHANGED:`，以及一行 `DEPS`：`combat.md -> inventory.md`

**输入：** `/review-all-gdds since-last-review`

**预期行为：**
1. 在清单之后，运行执行 `bash .claude/scripts/review-scope.sh`，而不是自行从
   `git log` 或 `git diff` 推算变更集
2. 范围是 `CHANGED` 集合加 `DEPS` 行列出的 GDD：`combat.md` 和 `inventory.md`；
   运行在任何完整读取之前向用户展示范围内的 GDD
3. 只有这两份 GDD 得到 Phase 1c 小节加载；`crafting.md` 和 `status-effects.md`
   不被加载，也不进行第二轮依赖扩展
4. 报告声明 `GDDs reviewed: 2 of 4 present`
5. Phase 2 和 Phase 3 照常对这两份范围内的 GDD 运行

**断言：**
- [ ] 执行 `bash .claude/scripts/review-scope.sh`，且其 `CHANGED` 和 `DEPS` 列表按打印内容作为范围使用
- [ ] 运行不通过自己的 git 历史搜索推导变更集
- [ ] `inventory.md` 在范围内，尽管它没有变更，因为 `combat.md` 声明它为自己的依赖
- [ ] 未变更、未被声明的 GDD 不被加载，也不计为已评审：报告写 `GDDs reviewed: 2 of 4 present`
- [ ] 在完整小节读取之前向用户展示范围

**Case 8b — 无先前评审：** 同一夹具但没有 `gdd-cross-review-*.md` 文件。
脚本打印 `PRIOR_REVIEW: NONE (full review required)`。

**断言（8b）：**
- [ ] 运行回退到 `full` 模式，并说明由于不存在先前评审而需要完整评审
- [ ] 四份系统 GDD 都被加载并评审（`GDDs reviewed: 4 of 4 present`）

---

### Case 9: 聚焦模式 — 只运行一轮，且报告说明哪些未运行

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/` 含有 Case 1 的集合：概念、支柱、系统索引和三份一致的系统 GDD，
  无冲突，且设计理论检查不会警告任何内容

**Case 9a — `/review-all-gdds consistency`**

**预期行为：**
1. Phase 1 照常加载全部内容；只启动 Phase 2（跨 GDD 一致性）的
   `game-designer` 子代理，检查清单 2a–2f
2. 不启动 Phase 3（游戏设计整体性）子代理
3. 报告的 `Focus:` 行写着 "consistency only — design theory not run"，且会话摘要的
   `Phases not run:` 行点名设计理论，而不是报告其为干净
4. 结论针对所运行的那一轮，并带标签：`PASS (consistency only — design theory not run)`
   —— 而非 NOT ASSESSED，因为用户只要求了一轮
5. 收尾部件既不提供 `/gate-check` 也不提供 `/create-architecture`：单轮评审
   不是二者所需的完整评审

**断言（9a）：**
- [ ] 恰好一次 `Agent` 启动：Phase 2 一致性子代理
- [ ] 设计理论阶段被点名未运行 —— 绝不静默省略，也绝不报告其未发现问题
- [ ] 结论为 `PASS (consistency only — design theory not run)`：带标签，绝不是无条件 PASS，也不是 NOT ASSESSED
- [ ] 既不提供 `/gate-check` 也不提供 `/create-architecture`
- [ ] 会话摘要的 `Phases not run:` 行点名设计理论

**Case 9b — `/review-all-gdds design-theory`**

**预期行为：** 9a 的镜像。只启动 Phase 3 子代理（检查清单 3a–3g），
Phase 4 和报告仍随后进行，且一致性轮被点名未运行。

**断言（9b）：**
- [ ] 恰好一次 `Agent` 启动：Phase 3 设计理论子代理
- [ ] `Focus:` 行点名一致性未运行，结论为 `PASS (design theory only — consistency not run)`，且会话摘要的 `Phases not run:` 行点名一致性
- [ ] 既不提供 `/gate-check` 也不提供 `/create-architecture`

---

## Protocol Compliance

- [ ] 在执行每个阶段前读取该阶段的 `references/N-*.md` 文件，并在该阶段期间压缩或恢复后再次读取
- [ ] Phase 2（一致性）与 Phase 3（设计理论）并行启动 —— 而非顺序执行
- [ ] 在请求任何写入前展示完整分析
- [ ] 未经 `AskUserQuestion` 批准，不写入报告、也不更新 `systems-index.md`
- [ ] 结论恰为以下之一：PASS、NOT ASSESSED、CONCERNS、FAIL
- [ ] 每个问题都引用涉及的 GDD、小节和文本
- [ ] 以基于结论构建的 `AskUserQuestion` 交接结尾：FAIL 或 NOT ASSESSED → 既不提供 `/create-architecture` 也不提供 `/gate-check`；CONCERNS → 只提供 `/create-architecture`；PASS → 二者都提供

---

## Coverage Notes

- 经济循环分析（3d，来源/去向循环）未做 fixture 测试。Case 2 演练的是 Phase 2
  的规则矛盾检查 —— 那是另一套检查清单，由另一个子代理运行 —— 因此它对 3d
  什么都说明不了。
- 设计理论阶段（Phase 3）的检查，包括支配性策略检测和认知过载，未单独做
  fixture 测试。
- Case 6 通过一份存在但为空的 GDD 覆盖了"少于两份可读 GDD"的触发项。未定义
  游戏支柱以及子代理未返回报告这两种 NOT ASSESSED 触发项未做 fixture 测试。
- Case 8 覆盖了有先前评审和无先前评审的 `since-last-review`；先前评审中变更的
  GDD 不点名任何依赖的情况未单独测试。Case 9 覆盖了 `consistency` 和
  `design-theory` 聚焦模式。
