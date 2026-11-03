# Skill Test Spec: /map-systems

## Skill Summary

`/map-systems` 将游戏概念拆解为系统索引。它读取
`design/gdd/game-concept.md`（在 `minimal` 下为 `design/game-brief.md`）及游戏
支柱（pillar），枚举显式和隐式系统，将依赖关系映射到各层
（Foundation → Core → Feature → Presentation → Polish），分配优先级层级
（MVP / Vertical Slice / Alpha / Full Vision），推导设计顺序，并在获得批准后
依据 `.trae/docs/templates/systems-index.md` 写入
`design/gdd/systems-index.md`。每个协作阶段都以一次 `AskUserQuestion` 结束。

三个总监质量闸门依次运行，各自位于独立的阶段：
依赖图获批后运行 TD-SYSTEM-BOUNDARY（technical-director），优先级获批后、
写入之前运行 PR-SCOPE（producer），索引写入后运行 CD-SYSTEMS
（creative-director）。在 `lean` 和 `solo` 下，每个闸门都跳过并附具名说明。
在 `standard`/`full` 下，它是 `/design-system` 的前置要求；在 `minimal` 下为
可选。结论：COMPLETE（已写入索引）或 BLOCKED（用户拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（针对 `design/gdd/systems-index.md`）
- [ ] 结尾有下一步交接（`/design-system`）
- [ ] 说明三个闸门及各阶段：TD-SYSTEM-BOUNDARY（Phase 3）、PR-SCOPE（Phase 4）、CD-SYSTEMS（Phase 5，写入之后）

---

## Director Gate Checks

在 `full` 模式下，依次执行：
1. **TD-SYSTEM-BOUNDARY**（`technical-director`）—— 依赖排序获批之后、
   优先级分配之前。REJECT → 与用户一同修订边界；
   CONCERNS → 在索引中内联注明。
2. **PR-SCOPE**（`producer`）—— 优先级获批之后、索引写入之前。
   UNREALISTIC → 写入前提出修订层级分配；
   OPTIMISTIC → 显示建议的调整并询问是否应用。
3. **CD-SYSTEMS**（`creative-director`）—— 索引写入之后；它接收
   索引路径、支柱与核心幻想（在 `minimal` 下为简报的提案（pitch）和
   "what they feel" 行）、每个层级的分配，以及高风险和瓶颈系统。
   REJECT → 在编写 GDD 之前修订系统集合；
   CONCERNS → `AskUserQuestion`（`Revise the system set` / `Accept — record them
   in the index` / `Discuss further`）；选择 Accept 时，它们会被记录为
   `> **Creative Director Note** (<tier>): …`，直接位于
   `## Priority Tiers` 表下方。

三者中的任何一个都可能答复 NOT ASSESSED [missing input]；它绝不会被读作批准 ——
要么补齐输入并重新运行闸门，要么继续运行并在索引中记录
`[GATE-ID]: NOT ASSESSED — [input]`。

在 `lean` 模式下，每个闸门都跳过并附说明：
"TD-SYSTEM-BOUNDARY skipped — Lean mode."、"PR-SCOPE skipped — Lean mode."、
"CD-SYSTEMS skipped — Lean mode."

在 `solo` 模式下，同样出现这三条说明，但标为 "Solo mode."

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 在 full 评审模式下拆解概念并写入索引

**Fixture:**
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: full`
- `design/gdd/game-concept.md` 存在，Core Mechanics 提及战斗和背包，
  并有 MVP Definition 小节
- `design/gdd/game-pillars.md` 存在，含 2 个支柱
- 尚不存在 `design/gdd/systems-index.md`
- TD-SYSTEM-BOUNDARY 返回 APPROVE，PR-SCOPE 返回 REALISTIC，CD-SYSTEMS
  返回 APPROVE

**Input:** `/map-systems`

**Expected behavior:**
1. 读取概念和支柱；Glob `design/gdd/*.md`
2. 按类别呈现系统 —— 名称、类别、一句话描述、显式或隐式（例如战斗隐含
   生命值、伤害计算、命中检测、战斗 UI）—— 并询问缺失 / 合并 / 不需要的系统
3. 呈现分层依赖图（瓶颈、叶节点、任何循环），并询问
   "Does this dependency ordering look right?…"
4. 批准后派发 TD-SYSTEM-BOUNDARY，传入依赖图（每个系统 → 它依赖什么）、
   层级分配、瓶颈系统，以及任何循环及其建议的解决方案
5. 呈现优先级层级，其理由引用本项目的支柱；批准后派发 PR-SCOPE
6. 呈现摘要（按类别计数、MVP 数量、设计顺序前 3 项、高风险项），并询问
   "May I write the systems index to
   `design/gdd/systems-index.md`?"
7. 写入索引，然后派发 CD-SYSTEMS，传入索引路径、支柱/核心幻想、每个层级的
   系统分配，以及高风险和瓶颈系统
8. 更新 `production/session-state/active.md`；结论：COMPLETE；提供
   `/design-system [first-system-in-order]`

**Assertions:**
- [ ] 推断隐式系统并标记为 implicit，同时给出理由
- [ ] TD-SYSTEM-BOUNDARY 在依赖图获批之后、优先级呈现之前派发，并接收完整依赖图 —— 不是摘要
- [ ] PR-SCOPE 在优先级获批之后、写入询问之前派发
- [ ] 询问 "May I write the systems index to `design/gdd/systems-index.md`?"，批准前不写入任何内容
- [ ] CD-SYSTEMS 仅在索引写入后派发，并接收全部四个层级和高风险系统 —— 不只是 MVP 列表
- [ ] Systems Enumeration 表保留模板的列（`# / System Name / Category / Priority / Status / Design Doc / Depends On`）—— 不新增列
- [ ] `active.md` 被更新，结论为 COMPLETE

---

### Case 2: 失败路径 —— 未找到游戏概念

**Fixture:**
- `project.yaml`：`modes.workflow: standard`
- `design/gdd/game-concept.md` 和 `design/game-brief.md` 都不存在

**Input:** `/map-systems`

**Expected behavior:**
1. Phase 1 未找到概念
2. 技能输出："No game concept found. Run `/brainstorm` first to create one,
   then come back to decompose it into systems."
3. 技能停止 —— 不枚举、不运行闸门、不写索引

**Assertions:**
- [ ] 打印出 "No game concept found" 消息
- [ ] 技能推荐以 `/brainstorm` 作为下一步操作
- [ ] 不呈现系统枚举，也不派发任何闸门
- [ ] 不创建 `design/gdd/systems-index.md`，且不输出 COMPLETE 结论

---

### Case 3: 总监质量闸门 —— CD-SYSTEMS 在写入后返回 CONCERNS

**Fixture:**
- 游戏概念和支柱存在；尚无索引
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: full`
- TD-SYSTEM-BOUNDARY 返回 APPROVE，PR-SCOPE 返回 REALISTIC
- CD-SYSTEMS 返回 CONCERNS：核心幻想隐含的一个 MVP 系统缺失
- 在 CONCERNS 询问处用户选择 `Accept — record them in the index`

**Input:** `/map-systems`

**Expected behavior:**
1. 在 "May I write" 批准之后写入索引
2. 派发 CD-SYSTEMS 并返回 CONCERNS
3. 通过 `AskUserQuestion` 显示关注项：`Revise the system set` /
   `Accept — record them in the index` / `Discuss further`
4. 选择 Accept 时，该关注项以
   `> **Creative Director Note** (MVP): …` 的形式记录在索引中，直接位于
   `## Priority Tiers` 表下方
5. 更新会话状态；结论：COMPLETE

**Assertions:**
- [ ] CD-SYSTEMS 仅在索引写入之后派发，而非写入询问之前
- [ ] CONCERNS 作为选择交给用户 —— 在用户选择之前不编辑索引
- [ ] 只有点明该编辑的 Accept 选择才会写入注记；注记直接位于 `## Priority Tiers` 表下方，并点名 MVP 层级
- [ ] 若用户选择 `Revise the system set`，将与之重新处理受影响的系统，并再次询问索引重写
- [ ] CONCERNS 不会触发完整的重新拆解（那是 REJECT 的路径）
- [ ] 结论为 COMPLETE

---

### Case 4: 边界情况 —— 系统索引已存在

**Fixture:**
- `project.yaml`：`modes.workflow: standard`
- `design/gdd/game-concept.md` 存在
- `design/gdd/systems-index.md` 已存在，含 8 个系统，其中 3 个已设计

**Input:** `/map-systems`

**Expected behavior:**
1. 技能读取现有索引并呈现其当前状态
2. 技能询问："The systems index already exists with 8 systems (3 designed, 5 not
   started). What would you like to do?"，选项为 "Update the index with new systems"、
   "Design the next undesigned system"、"Review and revise priorities"
3. 用户选择一个操作
4. 技能从现有索引继续，而不是重新创建它

**Assertions:**
- [ ] 技能在继续之前检测并读取现有索引
- [ ] 呈现系统数量及已设计 / 未开始的分项
- [ ] 提供全部三个选项 —— 索引不会被自动覆盖
- [ ] 除非用户选择，技能不会从头重新执行完整拆解

---

### Case 5: 总监质量闸门 —— lean 和 solo 模式跳过全部三个闸门并附注

**Fixture (lean mode):**
- 游戏概念存在
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: lean`

**Lean mode expected behavior:**
1. 系统、依赖和优先级如 Case 1 呈现并获批
2. 在其对应阶段注明 "TD-SYSTEM-BOUNDARY skipped — Lean mode." 和
   "PR-SCOPE skipped — Lean mode."
3. 询问 "May I write"；批准后写入索引
4. 注明 "CD-SYSTEMS skipped — Lean mode."
5. 更新会话状态并打印结论：COMPLETE

**Assertions (lean mode):**
- [ ] 三条跳过说明都出现，各自位于自己的阶段
- [ ] 不派发任何总监代理
- [ ] "May I write" 询问仍在写入之前
- [ ] 即使 CD-SYSTEMS 被跳过，也更新 `active.md` 并打印结论：COMPLETE

**Fixture (solo mode):**
- 同一概念，`project.yaml`：`modes.workflow: standard`、`modes.review_mode: full`
- Input: `/map-systems --review solo`

**Solo mode expected behavior:**
1. `--review solo` 覆盖解析得到的 `full`
2. 同样跳过三个闸门，并标为 "Solo mode."

**Assertions (solo mode):**
- [ ] 三条跳过说明都带有 "Solo mode." 标签
- [ ] 除此之外，行为与该技能的 lean 模式一致

---

### Case 6: guided 模式 —— 新索引仍需询问；更新则不询问

**Fixture (new index):**
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: solo`、
  `modes.automation: guided`
- 游戏概念存在；无 `design/gdd/systems-index.md`

**Fixture (update):**
- 同上，但 `design/gdd/systems-index.md` 存在，且用户选择了 "Update the
  index with new systems"

**Input (both fixtures):** `/map-systems`

**Expected behavior:**
1. 新索引：摘要之后询问 "May I write the systems index to
   `design/gdd/systems-index.md`?"，仅在确认后写入 —— `guided` 对新文件
   询问 "May I write?"
2. 更新：呈现摘要，点名 `design/gdd/systems-index.md`，无需等待明确同意即写入
   更新，并说明写入了什么

**Assertions:**
- [ ] `guided` 下的新索引：显示写入询问，答复前不写入任何内容
- [ ] `guided` 下的更新：无写入询问；写入前显示摘要和目标，写入后报告结果

---

### Case 7: 总监质量闸门 —— TD-SYSTEM-BOUNDARY 返回 REJECT

**Fixture:**
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: full`
- 游戏概念和支柱存在；尚无索引
- TD-SYSTEM-BOUNDARY 返回 REJECT：两个系统承担同一职责，必须合并

**Input:** `/map-systems`

**Expected behavior:**
1. 依赖图获批并派发 TD-SYSTEM-BOUNDARY
2. 呈现 REJECT，点名这两个系统
3. 与用户一同修订边界；显示修订后的依赖图
4. 只有此时才呈现优先级并派发 PR-SCOPE

**Assertions:**
- [ ] REJECT 未解决期间不开始优先级分配
- [ ] 在呈现优先级之前向用户显示修订后的边界
- [ ] 修订之前不派发 PR-SCOPE，也不写入任何内容
- [ ] REJECT 不作为注记记录并略过 —— 那是 CONCERNS 的处理方式

---

## Protocol Compliance

- [ ] 在任何拆解之前读取游戏概念（在 `minimal` 下为简报）和支柱
- [ ] 在枚举、依赖、优先级和写入处使用 `AskUserQuestion`
- [ ] 写入之前询问 "May I write the systems index to `design/gdd/systems-index.md`?" —— 在 `collaborative` 下，以及在 `guided` 下针对新索引
- [ ] CD-SYSTEMS 的 CONCERNS 仅通过用户选择才进入已写入的索引；TD-SYSTEM-BOUNDARY 的 CONCERNS 在索引中内联注明
- [ ] 在 full 模式下，闸门在各自阶段依次运行，绝不在其输入存在之前运行
- [ ] 跳过的闸门在 lean/solo 输出中以名称和模式注明
- [ ] 以下一步交接结尾：`/design-system [next-system]`

---

## Coverage Notes

- 循环依赖检测及其建议的解决方案属于 Phase 3 的一部分 ——
  此处未单独做 fixture 测试。
- PR-SCOPE 的 UNREALISTIC、CD-SYSTEMS 的 REJECT 路径，以及三个闸门中任何一个
  的 NOT ASSESSED 答复，未提供 fixture。
- `autonomous`（通过 `log_decision` 记录枚举并在不询问的情况下写入）
  未测试。
- `next` 和 `[system-name]` 参数模式（交接给 `/design-system`）
  此处未测试 —— 它们是索引完成后的便利功能。
- `docs.density` 深度（逐系统说明文字的位置）未做 fixture 锁定。
