# Skill Test Spec: /create-epics

## Skill Summary

`/create-epics` 读取范围内的 GDD、架构文档、Accepted ADR 和 TR 注册表，
并把每个系统转换为一个映射到架构模块的史诗（epic）。系统按层顺序处理
（Foundation → Core → Feature → Presentation），同一层内按
`systems-index.md` 的顺序处理。每个史诗都会被呈现（层、GDD、架构模块、
主导 ADR、引擎风险、ADR 覆盖率、未追溯需求），并在写入任何内容之前询问用户
"Shall I create Epic: [name]?"。

史诗写入 `production/epics/[epic-slug]/EPIC.md`，每个史诗都在完成自身的
"May I write `production/epics/[epic-slug]/EPIC.md` and add its row to
`production/epics/index.md` (creating it if absent)?" 询问之后写入，该询问
点明了随后要创建或更新的索引。已存在的 EPIC.md 绝不会被覆盖：用户可选择
原地更新（保留其 Stories 表）或跳过。在 `full` 评审模式下，PR-EPIC 质量闸门
（producer）在该层的所有史诗定义完成之后、写入任何文件之前运行；在 `lean`
和 `solo` 下则跳过并附注说明。评审模式来自 `resolve_config`
（`review_mode`），可通过 `--review` 按次覆盖。
结论：COMPLETE（已写入 N 个史诗）或 BLOCKED（用户拒绝了所有史诗、在质量闸门
处停止，或未找到符合条件的系统）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（逐史诗批准）
- [ ] 结尾有下一步交接（`/create-stories [epic-slug]`）
- [ ] 说明 PR-EPIC 质量闸门行为：在 full 模式下运行；在 lean/solo 下跳过

---

## Director Gate Checks

在 `full` 模式下：当前层的所有史诗定义完成后、写入任何史诗文件之前，
运行 PR-EPIC（`producer`，`.claude/docs/director-gates/pr-epic.md`）。
结论：REALISTIC → 进入写入询问；CONCERNS →
`AskUserQuestion` 提供 `[A] Proceed as planned` / `[B] Revise epic boundaries` /
`[C] Stop`；UNREALISTIC → 提出拆分或合并史诗，修订，再次呈现修订后的史诗，
并在写入前重新运行质量闸门。CONCERNS 的 `[B]` 同样会在质量闸门重新运行之前
再次呈现修订后的史诗。NOT ASSESSED [missing input] → 绝不当作 REALISTIC
读取：补齐输入并重新运行质量闸门，或者继续运行并在输出和结论行中注明
`PR-EPIC: NOT ASSESSED — [input]`。

在 `lean` 模式下：跳过 PR-EPIC。输出注明："PR-EPIC skipped — Lean mode."

在 `solo` 模式下：跳过 PR-EPIC。输出注明："PR-EPIC skipped — Solo mode."

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 两份已批准的 GDD 生成两个史诗

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: full`、`modes.review_mode: lean`
- `design/gdd/systems-index.md` 列出 2 个 Foundation 系统
- 两个系统在 `design/gdd/` 中都有已批准的 GDD，每份都含 `## Summary`
- `docs/architecture/architecture.md` 为每个系统都有一个模块
- Accepted ADR 在 `docs/architecture/tr-registry.yaml` 中覆盖两个系统的所有 TR-ID；
  第一个系统有两个主导 ADR，其 Engine Compatibility 分别评定 Knowledge Risk
  为 LOW 和 HIGH
- `docs/architecture/control-manifest.md` 存在
- 不存在 `production/epics/` 目录

**Input:** `/create-epics layer: foundation`

**Expected behavior:**
1. Glob `design/gdd/*.md`（排除 systems-index 及其他非系统文档）以确定 N，
   然后 Grep `^## Summary` 以界定 Foundation 系统范围
2. 读取 2 份范围内 GDD、`architecture.md`、范围内 ADR 的 Decision / GDD
   Requirements Addressed / Engine Compatibility 小节、TR 注册表和清单头部；
   报告 "Loaded 2 GDDs, [M] ADRs, engine: …"
3. 对每个系统：呈现史诗块并询问 "Shall I create Epic: [name]?"
4. 注明 "PR-EPIC skipped — Lean mode."
5. 对每个史诗：询问 "May I write `production/epics/[epic-slug]/EPIC.md` and
   add its row to `production/epics/index.md` (creating it if absent)?"，
   并在批准后写入两者
6. 创建或更新 `production/epics/index.md`
7. 结论：COMPLETE —— 已写入 2 个史诗；下一步 `/create-stories [epic-slug]`

**Assertions:**
- [ ] 在任何写入询问之前，显示每个史诗块并询问 "Shall I create Epic: [name]?"
- [ ] 逐史诗询问 "May I write"（不是两个史诗只问一次）
- [ ] 文件落在 `production/epics/[epic-slug]/EPIC.md`
- [ ] 每份 EPIC.md 都包含 Layer、GDD path、Architecture Module、Governing ADRs 表、GDD Requirements 表、Definition of Done
- [ ] 第一个史诗的 Engine Risk 为 HIGH —— 取其主导 ADR 中的最高值，而不是第一个值或平均值
- [ ] Definition of Done 要求 Logic 和 Integration 用户故事在 `tests/`（Godot 测试根目录）下通过测试，要求 Visual/Feel 和 UI 用户故事在 `production/qa/evidence/` 中保留截图 —— UI 每个涉及的界面各一张，Visual/Feel 另需主管签核
- [ ] 出现 "PR-EPIC skipped — Lean mode."；未派发 producer
- [ ] 写入后创建或更新 `production/epics/index.md`，且仅在此前已点名该索引的询问之后
- [ ] 结论为 COMPLETE，并指明 `/create-stories [epic-slug]`

---

### Case 2: 失败路径 —— 未找到系统 GDD

**Fixture:**
- `project.yaml`：`modes.workflow: full`
- `design/gdd/` 只包含 `game-concept.md` 和 `systems-index.md`（没有
  系统 GDD）

**Input:** `/create-epics all`

**Expected behavior:**
1. Glob `design/gdd/*.md` 并排除非系统文档 —— N = 0
2. 报告 "No system GDDs found in `design/gdd/` — run `/design-system` first"
   并停止
3. 不呈现任何史诗、不运行质量闸门、不写文件

**Assertions:**
- [ ] `game-concept.md` 和 `systems-index.md` 不被计为系统 GDD
- [ ] 打印出 "No system GDDs found … run `/design-system` first" 消息
- [ ] 不显示任何 "Shall I create Epic" 或 "May I write" 询问，也不写入任何 EPIC.md 或 index.md
- [ ] 结论为 BLOCKED（未找到符合条件的系统），而不是 COMPLETE

---

### Case 3: 总监质量闸门 —— full 模式在写入前派发 PR-EPIC

**Fixture:**
- 2 份已批准 GDD、架构、ADR、TR 注册表和清单同 Case 1
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: full` —— 固定
  工作流，因为未设置时会解析为 `minimal`，此时技能读取简报而非 GDD，质量闸门
  根本不会介入
- PR-EPIC 返回 REALISTIC

**Input:** `/create-epics layer: foundation`

**Full mode expected behavior:**
1. 两个史诗都通过 "Shall I create Epic: [name]?" 呈现并被接受
2. 通过 `Agent` 派发 `producer`，质量闸门为 PR-EPIC，接收史诗结构摘要、
   层、里程碑时间线和团队产能
3. 收到 REALISTIC 时：继续执行逐史诗的 "May I write" 询问
4. 获得批准后写入史诗文件

**Assertions (full mode):**
- [ ] PR-EPIC 只派发一次，且在两个史诗都定义完成之后
- [ ] PR-EPIC 在任何 "May I write" 询问之前运行
- [ ] 在 PR-EPIC 给出结论之前不写入任何 EPIC.md

**Fixture (per-run override):**
- 同一项目，`modes.workflow: full`、`modes.review_mode: full`
- Input: `/create-epics layer: foundation --review lean`

**Override expected behavior:**
1. `--review lean` 覆盖解析得到的 `full`
2. 跳过 PR-EPIC —— 在输出中注明
3. 直接继续执行 "May I write" 询问

**Assertions (override):**
- [ ] 输出中出现 "PR-EPIC skipped — Lean mode."
- [ ] 不派发 producer 代理，写入询问直接紧跟史诗定义之后

---

### Case 4: 边界情况 —— full 工作流下存在未追溯需求

**Fixture:**
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: solo`
- 一份已批准的 Foundation GDD，其系统在 `tr-registry.yaml` 中有 5 个 TR-ID；
  Accepted ADR 覆盖其中 3 个（2 个未追溯）

**Input:** `/create-epics [system-name]`

**Expected behavior:**
1. 史诗块显示 "GDD Requirements Covered by ADRs: 3 / 5"，并在
   "Untraced Requirements" 下列出这 2 个未追溯的 TR-ID
2. 警告："⚠️ 2 requirements in [system] have no ADR. The epic can be created, but
   `/create-stories` will write their stories with no governing ADR (`ADR: N/A`)
   and `Status: Ready` — nothing downstream blocks them, so they would be
   implemented without architectural guidance. Run `/architecture-decision` first
   if they need a decision, or proceed and accept the gap."
3. 询问 "Shall I create Epic: [name]?"，选项为 `[A] Yes, create it` /
   `[B] Skip this epic` / `[C] Pause — I need to write ADRs first`
4. 选择 [A] 时：注明 "PR-EPIC skipped — Solo mode."，询问 "May I write"，
   且 EPIC.md 的 GDD Requirements 表将这两行标记为 `❌ No ADR`

**Assertions:**
- [ ] 在创建询问之前显示覆盖率计数和 2 个未追溯 TR-ID
- [ ] 未追溯需求警告指名 `/architecture-decision`，并说明下游实际会发生什么：用户故事以 `Ready` 状态写入且没有主导 ADR —— 不得声称它们会被 Blocked
- [ ] 提供选项 `[C] Pause — I need to write ADRs first`
- [ ] 写出的 EPIC.md 将未追溯行标记为 `❌ No ADR`（不静默丢弃）

---

### Case 5: 总监质量闸门 —— PR-EPIC 返回 CONCERNS

**Fixture:**
- 2 份已批准 GDD、架构、ADR、TR 注册表和清单同 Case 1
- `project.yaml`：`modes.workflow: full`、`modes.review_mode: full`
- PR-EPIC 返回 CONCERNS（某个史诗的范围过大）

**Input:** `/create-epics layer: foundation`

**Expected behavior:**
1. 派发 PR-EPIC，其返回 CONCERNS 并附具体反馈
2. 技能在任何写入询问之前呈现制作人的评估
3. `AskUserQuestion`："Producer raised concerns about the epic structure. How do
   you want to proceed?"，选项为 `[A] Proceed as planned — I accept the producer's
   concerns` / `[B] Revise epic boundaries — split or merge as recommended` /
   `[C] Stop — I want to reconsider the scope`
4. 选择 [B]：从 Step 4 起修订史诗定义并重新运行 PR-EPIC
5. 选择 [C]：停止，结论：BLOCKED —— 用户希望重新考虑史诗范围

**Assertions:**
- [ ] 在任何 "May I write" 询问之前，向用户显示制作人的 CONCERNS
- [ ] 质量闸门结论未定时，技能不写入史诗
- [ ] 提供全部三个选项（[A] 继续 / [B] 修订 / [C] 停止）
- [ ] 选择 [B] 时，在任何写入询问之前再次呈现修订后的史诗并重新运行 PR-EPIC
- [ ] 选择 [C] 时，以结论 BLOCKED 结束且不写入任何文件

---

### Case 6: 边界情况 —— 某个系统已存在 EPIC.md

**Fixture:**
- 同 Case 1（`modes.workflow: full`、`modes.review_mode: lean`）
- `production/epics/[first-slug]/EPIC.md` 已存在，其头部有
  `**Stories**: 3 stories`，并有 3 行的 `## Stories` 表；
  `production/epics/index.md` 中已有其行，内容为 `3 stories`
- 第二个系统没有 EPIC.md

**Input:** `/create-epics layer: foundation`

**Expected behavior:**
1. 两个史诗都通过 "Shall I create Epic: [name]?" 呈现并被接受
2. 对第一个系统，技能不覆盖：它询问 "An EPIC.md already exists for [name].
   Update it in place, or skip it?"，选项为 `[A] Update in place —
   keep its Stories table` / `[B] Skip this epic`；用户选择 [A]
3. 更新会重写除 `Stories` 之外的头部字段、Overview、Governing ADRs、
   GDD Requirements 和 Definition of Done，并保持 `**Stories**` 行和
   `## Stories` 表原样不变
4. 对第二个系统，随后执行正常的 "May I write `…/EPIC.md` and add its row to
   `production/epics/index.md`…?" 询问
5. `production/epics/index.md` 保留第一个史诗的一行，仍为 `3 stories`，
   并为第二个史诗新增一行

**Assertions:**
- [ ] 在任何写入之前检测到已存在的文件，并提供更新 / 跳过 —— 不覆盖它
- [ ] 更新后，`**Stories**` 头部行和全部 3 行 `## Stories` 均保持不变
- [ ] 索引中没有第一个史诗的重复行，也不会把它重置为 `Not yet created`
- [ ] 第二个系统的 EPIC.md 仅在其自身的 "May I write" 询问之后写入

---

### Case 7: standard 层级 —— GDD 缺少 `## Summary`，一项未追溯的非关键需求

**Fixture:**
- `project.yaml`：`modes.workflow: standard`、`modes.review_mode: solo`
- `design/gdd/systems-index.md` 列出一个 Foundation 系统和一个 Core 系统；
  两份 GDD 都早于 `## Summary` 的引入（Summary 扫描一个也匹配不到）
- `docs/architecture/architecture.md` 为每个系统都有一个模块，
  `docs/architecture/tr-registry.yaml` 保存两个系统的 TR-ID
- Foundation 系统的 TR-ID 由一份 Accepted 的 Foundation 层 ADR 覆盖；
  Core 系统的其中一个 TR-ID 没有 ADR
- `docs/architecture/control-manifest.md` 不存在

**Input:** `/create-epics all`

**Expected behavior:**
1. Glob `design/gdd/*.md` 得到 N = 2；`^## Summary` 扫描返回 0 个匹配
2. 注明一次："No `## Summary` sections found across 2 GDDs — scoping from
   `systems-index.md` instead of Summary."，并完整读取两份范围内的 GDD
3. 在没有控制清单的情况下继续（存在则读取，`standard` 下并非必需）
4. Core 史诗在 "Untraced Requirements" 下列出其未追溯 TR-ID，仅作信息 ——
   不发出 ⚠️ 未追溯需求警告，也不阻塞任何内容
5. 注明 "PR-EPIC skipped — Solo mode."；每个史诗都在其自身询问之后写入

**Assertions:**
- [ ] 零匹配的 Summary 扫描按原样报告，两个系统仍在范围内 —— 不被解读为“范围内没有内容”
- [ ] 缺失的控制清单不会在 `standard` 下中止运行
- [ ] 列出未追溯的非关键需求，但不发出 ⚠️ 警告
- [ ] 两个史诗都被写入，各自在其自身的 "May I write" 询问之后

---

## Protocol Compliance

- [ ] 在任何 "May I write" 询问之前向用户显示史诗定义
- [ ] 逐史诗询问 "May I write"，不是整批只问一次
- [ ] 已存在的 EPIC.md 由用户选择原地更新或跳过 —— 绝不覆盖
- [ ] PR-EPIC 质量闸门（若启用）在写入询问之前运行 —— 而非之后
- [ ] 跳过的质量闸门在输出中以名称和模式注明
- [ ] EPIC.md 内容只来源于 GDD、ADR 和架构文档 —— 不虚构任何内容
- [ ] 从不创建用户故事；为每个已创建的史诗以下一步交接 `/create-stories [epic-slug]` 结尾

---

## Coverage Notes

- Feature 和 Presentation 层遵循与 Foundation 和 Core 相同的逐史诗模式 ——
  层特定的顺序未单独测试。
- `minimal` 层级（可选；从 `design/game-brief.md` 分解，无简报则停止）
  未提供 fixture。
- `## Summary` 部分采用行（0 < M < N）未单独测试；零匹配行为 Case 7。
- PR-EPIC 的 UNREALISTIC 处理（修订、再次呈现修订后的史诗、重新运行质量闸门）、
  NOT ASSESSED 的闸门答复，以及无参数的 "Which layer or system…" 询问
  未单独测试。
