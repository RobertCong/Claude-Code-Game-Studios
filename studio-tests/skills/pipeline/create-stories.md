# Skill Test Spec: /create-stories

## Skill Summary

`/create-stories` 将单个史诗（epic）拆分为可供开发者使用的用户故事文件。在
`standard`/`full` 工作流下，它读取 `production/epics/[epic-slug]/EPIC.md`、
该史诗的 GDD、主导 ADR（按小节限定读取，绝不无界读取）、控制清单中本层的
规则，以及 TR 注册表中本系统的条目。在 `minimal` 下，它改为从
`design/game-brief.md` 合成一个隐式史诗，并且只有在写入询问点名该文件之后才
写入该史诗的 `EPIC.md`。

每个用户故事按类型分类（Logic / Integration / Visual/Feel / UI /
Config/Data），该类型决定其所需的测试证据。由 Proposed ADR 主导的用户故事会被
置为 `Status: Blocked`。在 `full` 评审模式下，`qa-lead` 会以质量闸门
QL-STORY-READY（结论 ADEQUATE / GAPS / INADEQUATE）被派发 **一次**，并为
ADEQUATE 的用户故事返回测试用例规格；GAPS 交由用户处理（修订 / 接受 / 讨论），
INADEQUATE 会阻塞该用户故事直至其被修订；在 `lean`/`solo` 下该质量闸门跳过
并附注说明。所有用户故事在一次摘要中呈现，技能只询问一次 —— "May I write
these [N] stories to `production/epics/[epic-slug]/`, and update
`production/epics/[epic-slug]/EPIC.md` and `production/epics/index.md`?" ——
然后写入 `story-NNN-[slug].md` 文件，并更新该史诗的 `EPIC.md` 和
`production/epics/index.md`。结论：COMPLETE 或 BLOCKED（用户拒绝）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（整套用户故事只批准一次）
- [ ] 结尾有下一步交接（`/story-readiness`、`/dev-story`）
- [ ] 说明当主导 ADR 为 Proposed 时用户故事 Status: Blocked
- [ ] 说明 QL-STORY-READY 质量闸门：full 模式下启用，lean/solo 下跳过

---

## Director Gate Checks

在 `full` 模式下：所有用户故事拆分完成后、写入询问之前，通过 `Agent` 以质量
闸门 QL-STORY-READY 派发一次 `qa-lead`。它为每个用户故事返回结论
（ADEQUATE / GAPS / INADEQUATE），并为 ADEQUATE 的用户故事附上
Given/When/Then 规格（Logic、Integration）或人工验证步骤（Visual/Feel、UI）。
GAPS → `AskUserQuestion` 提供 `Revise flagged criteria` / `Accept and proceed` /
`Discuss further` —— 在用户选择之前不做任何修订。INADEQUATE →
阻塞：在写入询问之前与用户一同修订该用户故事（或将其弃用并指名）。
NOT ASSESSED [missing input] → 绝不当作 ADEQUATE 读取：补齐输入并重新请求
结论，或者在没有 qa-lead 规格的情况下写入该用户故事，并在用户故事列表中标记
`QL-STORY-READY: NOT ASSESSED — [input]`。

在 `lean` 模式下：跳过 QL-STORY-READY。输出注明：
"QL-STORY-READY skipped — Lean mode."

在 `solo` 模式下：跳过 QL-STORY-READY。输出注明：
"QL-STORY-READY skipped — Solo mode."

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 史诗含 3 个用户故事，所有 ADR 均为 Accepted

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: full`、
  `modes.review_mode: lean`、`modes.story_granularity: fine`（每个
  验收标准一个用户故事）
- `production/epics/combat/EPIC.md` 存在，含 3 条 GDD 需求并列出其
  主导 ADR
- 该史诗的 GDD 存在，每条需求恰好对应一个验收标准（其中一个
  是伤害公式）
- 所有主导 ADR 文件都存在，`## Status` 为 Accepted
- `docs/architecture/control-manifest.md` 存在
- `docs/architecture/tr-registry.yaml` 含全部 3 条需求的 TR-ID
- `production/epics/index.md` 中该史诗的行状态为 `Not yet created`

**Input:** `/create-stories combat`

**Expected behavior:**
1. 完整读取 EPIC.md 和 GDD；从清单中 Grep 本层的 `## <layer> Layer Rules`
   和本系统的 TR 注册表条目；通过标题映射 + 限定读取加载每份 ADR
2. 报告 "Loaded epic [name], GDD [filename], [N] governing ADRs [status], [manifest status]."
3. 按类型对每个用户故事分类（伤害公式故事为 Logic）
4. 注明 "QL-STORY-READY skipped — Lean mode."
5. 呈现用户故事列表（标题、类型、ADR、覆盖的 TR-ID、测试/证据路径）
6. 询问一次："May I write these 3 stories to `production/epics/combat/`, and
   update `production/epics/combat/EPIC.md` and `production/epics/index.md`?"
7. 写入 `story-001-[slug].md` … `story-003-[slug].md`，更新 EPIC.md 的
   Stories 表和索引行至 `3 stories`
8. 询问下一步，推荐 `/story-readiness [first-story-path]`；结论：COMPLETE

**Assertions:**
- [ ] 恰好起草 3 个用户故事 —— 在 `fine` 下每个验收标准一个
- [ ] 每个用户故事文件都有头部字段 Epic、Status、Layer、Type、Manifest Version，以及含 GDD、`Requirement: TR-[system]-NNN`、ADR Governing Implementation、ADR Version、Engine/Risk 的 Context 块
- [ ] 每个用户故事都有 Acceptance Criteria、QA Test Cases、Test Evidence 和 Dependencies 小节
- [ ] 公式故事被归类为 Logic，证据路径为 `tests/unit/[system]/…`（Godot 测试根目录）
- [ ] 出现 "QL-STORY-READY skipped — Lean mode."，且每个 QA Test Cases 小节写明 "N/A — no qa-lead specs at this tier…"（不自行编造测试用例）
- [ ] 在显示完整列表之后只询问一次 "May I write"，且点名这 3 个用户故事、`EPIC.md` 和 `production/epics/index.md`
- [ ] 文件命名为 `production/epics/combat/story-NNN-[slug].md`
- [ ] 技能不启动实现

---

### Case 2: 失败路径 —— 指定的史诗不存在

**Fixture:**
- `project.yaml`：`modes.workflow: full`
- `production/epics/` 含其他史诗，但没有 `nonexistent-epic/` 目录

**Input:** `/create-stories nonexistent-epic`

**Expected behavior:**
1. 技能查找 `production/epics/nonexistent-epic/EPIC.md` —— 未找到
2. 技能输出明确错误并点名该路径
3. 技能推荐 `/create-epics`（上一步），或对照 `production/epics/` 下的
   史诗核对 slug
4. 不创建任何用户故事文件，也不从简报合成史诗

**Assertions:**
- [ ] 技能输出明确错误并点名 `production/epics/nonexistent-epic/EPIC.md`
- [ ] 不写入任何用户故事文件、EPIC.md 或索引行
- [ ] 技能推荐 `/create-epics`
- [ ] 技能在 `full` 下不会落入 `minimal` 的简报合成分支

---

### Case 3: 被阻塞的用户故事 —— ADR 为 Proposed

**Fixture:**
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: solo`、
  `modes.story_granularity: fine`
- EPIC.md 存在，含 2 条需求，各一个验收标准；两份主导 ADR 文件都存在
- 需求 1 由 `## Status` 为 Accepted 的 ADR 主导
- 需求 2 由 ADR-0007 主导，其 `## Status` 为 Proposed

**Input:** `/create-stories [epic-slug]`

**Expected behavior:**
1. 两份 ADR 文件都存在，因此 `full` 层级的文件存在性检查通过
2. 技能读取每份主导 ADR 的状态，发现 ADR-0007 为 Proposed
3. 用户故事 2 被起草为 `Status: Blocked`，并附注
   "BLOCKED: ADR-0007 is Proposed — accept it with `/architecture-decision accept ADR-0007` once decided"
4. 用户故事 1 被起草为 `Status: Ready`
5. 在单次 "May I write" 询问之前，被阻塞的用户故事在用户故事列表中被标记

**Assertions:**
- [ ] ADR 状态取自该 ADR 的 `## Status` 小节，而非假设
- [ ] 用户故事 2 为 `Status: Blocked`，且附注点名 ADR-0007 和 `/architecture-decision accept` —— 绝不是裸的 `/architecture-decision`，那会启动一份新 ADR
- [ ] 变体 —— ADR-0007 的 `## Status` 为 `Superseded by ADR-0009` 时：用户故事 2 仍为 `Status: Blocked`，且其附注点名 ADR-0009 作为应指向的 ADR
- [ ] 用户故事 1 为 `Status: Ready` —— 被阻塞的 ADR 不影响它
- [ ] 被阻塞的用户故事在写入批准前被标记，而不是写入后才发现
- [ ] 两个用户故事文件都被写入（被阻塞的用户故事仍会写入 —— 只是被标记）

---

### Case 4: 边界情况 —— 未提供参数

**Fixture:**
- `project.yaml`：`modes.workflow: standard`
- `production/epics/` 包含 2 个史诗子目录，每个都有 `EPIC.md`

**Input:** `/create-stories`（无参数）

**Expected behavior:**
1. 技能在 `standard` 下检测到没有参数
2. Glob `production/epics/*/EPIC.md`
3. 通过 `AskUserQuestion` 询问："Which epic would you like to break into stories?"
   并将这 2 个史诗（及其状态）作为选项
4. 只拆分用户选择的史诗

**Assertions:**
- [ ] 技能询问 "Which epic would you like to break into stories?" 而不是报错
- [ ] Glob 得到的两个史诗都作为选项提供
- [ ] 在用户选择之前不写入任何用户故事文件
- [ ] 技能不会在没有用户输入的情况下静默选择一个史诗
- [ ] 技能不会在 `standard` 下走 `minimal` 的简报合成分支

**Fixture (no epics):**
- `project.yaml`：`modes.workflow: standard`
- `production/epics/` 中没有 `EPIC.md`

**Expected behavior (no epics):**
1. Glob 无返回，因此技能停止："No epics found under
   `production/epics/`. Run `/create-epics layer: foundation` first — an epic is
   what this skill decomposes."

**Assertions (no epics):**
- [ ] 不会以空选项列表询问 "Which epic…"
- [ ] 停止信息点名 `/create-epics`，且不写入任何内容

---

### Case 5: 总监质量闸门 —— full 模式下 QL-STORY-READY 对一个用户故事返回 GAPS

**Fixture:**
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: full`、
  `modes.story_granularity: fine`
- EPIC.md 存在，含 2 条需求，各一个验收标准；两份主导 ADR 均为 Accepted
- QL-STORY-READY 判定用户故事 1 为 ADEQUATE，用户故事 2 为 GAPS（一个
  验收标准含糊）
- 在 GAPS 询问处用户选择 `Revise flagged criteria`

**Input:** `/create-stories [epic-slug]`

**Expected behavior:**
1. 两个用户故事都被拆分
2. 针对整个用户故事列表，以 QL-STORY-READY 派发一次 `qa-lead`
3. 呈现评估结果：用户故事 1 为 ADEQUATE 并附测试用例规格；用户故事 2
   为 GAPS 并点名含糊的标准
4. 针对用户故事 2 的 `AskUserQuestion`：`Revise flagged criteria` /
   `Accept and proceed` / `Discuss further`
5. 选择修订时：起草并显示用户故事 2 修订后的标准；通过一次后续调用仅为
   用户故事 2 重新请求规格
6. 两者都达到 ADEQUATE 后，呈现用户故事列表并发出单次写入询问；每个用户故事
   的 QA Test Cases 小节都包含 qa-lead 规格

**Assertions:**
- [ ] `qa-lead` 为所有用户故事只派发一次（不是每个用户故事一次，也不为用户故事 1 的规格再派发第二次）；唯一的后续调用只覆盖用户故事 2
- [ ] 逐用户故事结论使用 ADEQUATE / GAPS / INADEQUATE，并点名未通过的标准
- [ ] GAPS 结论连同三个选项交给用户 —— 在用户选择之前不修订用户故事 2 的标准
- [ ] 在写入询问之前显示用户故事 2 修订后的标准；在达到 ADEQUATE 之前它不带规格
- [ ] 若用户选择 `Accept and proceed`，用户故事 2 将以其标准不变的方式写入，且其 QA Test Cases 写明 `*Test cases not yet defined — run /qa-plan to generate them.*`
- [ ] 用户故事 1 的 QA Test Cases 小节包含来自质量闸门的 Given/When/Then（Logic/Integration）或 Setup/Verify/Pass condition（Visual/Feel、UI）块
- [ ] `full` 模式下不出现 "QL-STORY-READY skipped" 提示

---

### Case 6: minimal 层级 —— 从简报合成史诗，随后再次访问

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`engine.version: "4.6"`，且没有
  `modes` 键 —— `modes.rigor` 默认为 `minimal`，因此 `workflow`、`qa.level`
  和评审模式分别解析为 `minimal` / `minimal` / `solo`
- `design/game-brief.md`，工作标题为 "Lantern Keeper"，含玩家目标与失败
  状态、2 个 MVP 功能以及构建顺序
- `docs/engine-reference/godot/VERSION.md` 不存在
- 不存在 `production/epics/` 目录

**Input:** `/create-stories`

**Expected behavior:**
1. 在 `minimal` 下无参数会走 Step 2 的 `minimal` 分支并读取简报；
   不会因缺少 GDD、ADR、控制清单或 TR 注册表而停止
2. 起草 `production/epics/lantern-keeper/EPIC.md` 但不写入
3. 注明 "QL-STORY-READY skipped — Solo mode."
4. 按构建顺序每个 MVP 功能呈现一个用户故事，共 2 个，并询问一次以写入
   它们并创建 `production/epics/lantern-keeper/EPIC.md`（不涉及 `index.md`
   —— 它不存在）
5. 写入 `EPIC.md` 和两个用户故事；打印 `Epics index not updated:
   production/epics/index.md absent`
6. 推荐 `/dev-story [first-story-path]` —— 不推荐 `/story-readiness`，也不提供
   `/sprint-plan` 选项

**Assertions:**
- [ ] 在单次写入询问之前不写入任何内容（包括 `EPIC.md`），且该询问点名 `EPIC.md`
- [ ] 每个用户故事的 ADR 字段写明 `Requirement: Brief MVP feature N`、`N/A (minimal — no ADRs)`，其 Manifest Version 为 `N/A (minimal — no control manifest)`
- [ ] 每个用户故事的 Risk 为 `NOT ASSESSED (no VERSION.md risk rating)` —— 绝不猜测等级
- [ ] 每个 QA Test Cases 小节都写有 "N/A — no qa-lead specs at this tier…" 这一行
- [ ] 索引行点名 `production/epics/index.md`，而不是系统索引

**Fixture (return visit):**
- 在该次运行之后同上：`production/epics/lantern-keeper/` 含 `EPIC.md`（一个
  2 行的 Stories 表）、`story-001-…` 和 `story-002-…`；简报现列出第 3 个
  MVP 功能

**Expected behavior (return visit):**
1. 读取已有的用户故事和 `EPIC.md`；为新功能起草一个用户故事
2. 询问一次，点名新用户故事和 `EPIC.md` 的更新；写入
   `story-003-[slug].md` 并向 Stories 表追加一行

**Assertions (return visit):**
- [ ] `story-001` 和 `story-002` 保持不变
- [ ] 新用户故事编号为 003，接在现有最大编号之后
- [ ] `EPIC.md` 保留其两行及所有其他小节；恰好追加一行

**Fixture (an `EPIC.md` with no stories yet):**
- 同第一个 fixture，但已运行过 `/create-epics`，因此
  `production/epics/lantern-keeper/EPIC.md` 存在（范围来自简报，Stories
  为 "Not yet created"），且文件夹中没有用户故事文件

**Expected behavior (an `EPIC.md` with no stories yet):**
1. 现有 `EPIC.md` 即为该史诗：不再从简报起草新的
2. 写入询问点名这 2 个用户故事，并说 *update* `EPIC.md`，而不是 *create*

**Assertions (an `EPIC.md` with no stories yet):**
- [ ] 现有 `EPIC.md` 除 Stories 表之外的所有小节保持不变
- [ ] Step 5 的询问说的是 *update* `EPIC.md`

---

## Protocol Compliance

- [ ] 在起草用户故事之前加载全部上下文（EPIC、GDD、ADR、清单层规则、TR 注册表条目）
- [ ] 在 "May I write" 询问之前完整显示用户故事列表
- [ ] 对整套用户故事只询问一次 "May I write"，不是每个用户故事一次，并点名其涉及的所有文件（用户故事、`EPIC.md`、存在时的 `production/epics/index.md`）
- [ ] 被阻塞的用户故事在写入批准前被标记 —— 而不是写入后才发现
- [ ] TR-ID 引用注册表 —— 需求文本不内联嵌入用户故事文件
- [ ] 控制清单规则逐用户故事引自清单，而非编造
- [ ] 以下一步交接结尾：`/story-readiness` → `/dev-story`（在 `minimal` 下直接 `/dev-story`）

---

## Coverage Notes

- 在 `minimal` 下，无简报时 "run `/brainstorm` first" 的停止（或游戏已构建
  时的 `/reverse-document design [code root]`），以及指定不存在史诗 slug
  （此时走 `minimal` 分支而非 `/create-epics`），未提供 fixture。
- `full` 下缺失 ADR 文件的停止，以及 `standard` 下关键/非关键 ADR
  的区分，未单独测试。
- INADEQUATE（与用户一同修订用户故事，或弃用并指名）以及
  NOT ASSESSED 的闸门答复，未提供 fixture。
- Integration 用户故事的测试证据（试玩测试文档替代方案）遵循与 Logic
  用户故事相同的批准模式 —— 未单独做 fixture 测试。
- 用户故事粒度在 Case 1、3、5 中固定为 `fine`，以便用户故事数量
  确定；`coarse` 和 `balanced` 分组，以及按 `docs.density` 的说明深度，
  未做 fixture 锁定。
- 已有 QA 计划的替换提示（Use QA-plan specs / Use qa-lead specs /
  Skip）未测试。
