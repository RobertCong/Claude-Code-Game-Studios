# Skill Test Spec: /vertical-slice

## Skill Summary

`/vertical-slice [--review full|lean|solo]` 是制作前（Pre-Production）的验证
构建：一个完整的 [起始 → 挑战 → 解决] 循环，达到接近正式制作的质量，回答一个
关于玩家体验 *且* 构建可行性的可证伪问题。它读取概念（`design/gdd/game-concept.md`，
或在 `rigor: minimal` 下为 `design/game-brief.md`）、系统索引、架构和控制清单，
定义验证问题和 3–5 分钟的范围，请求把计划记录到
`production/session-state/active.md`，然后询问 "May I create the vertical slice
directory at `prototypes/[concept-name]-vertical-slice/` and begin
implementation?"。每个切片文件都以
`VERTICAL SLICE - NOT FOR PRODUCTION` 头开始，使用该文件自身的注释语法。

在一次一问的复盘（debrief）之后，它写入
`prototypes/[concept-name]-vertical-slice/REPORT.md`（依据
`.claude/docs/templates/vertical-slice-report.md`）和一行
`prototypes/index.md`，一次询问同时点名两者。结论为
**PROCEED / PIVOT / KILL**，当没有人从头到尾玩过该循环时另有
**NOT ASSESSED** —— 其排序高于 PROCEED、低于 PIVOT 和 KILL，且绝不会被记录为
PROCEED。该结论输入 `/gate-check production`：它会让任何 Vertical Slice
Validation 项中有 NO 的已构建切片 FAIL，因此在出现此类 NO 之后 PROCEED 不可用。
解析后的 `modes.workflow` 决定 PROCEED 的路线：在 `minimal` 下没有冲刺，因此
速度日志（velocity log）输入简报的构建顺序，下一步为 `/create-stories` 然后
`/dev-story`；在 `standard` 和 `full` 下则为史诗、用户故事、冲刺和闸门列表。
在 `full` 评审模式下，`creative-director` 通过 **CD-PLAYTEST**
（APPROVE / CONCERNS / REJECT，或 NOT ASSESSED）评审结果：APPROVE 保持建议不变；
CONCERNS 交由用户处理（修订 / 接受 / 讨论）；REJECT 表示 PROCEED 不能成立 ——
用户选择 PIVOT 或 KILL，报告记录总监的理由。PIVOT 写入 `PIVOT-NOTE.md`；
KILL 运行五项健全性检查（soundness check）并追加到 `prototypes/GRAVEYARD.md`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：PROCEED、PIVOT、KILL、NOT ASSESSED
- [ ] 在创建切片目录之前、在写入 REPORT.md、PIVOT-NOTE.md 和 GRAVEYARD.md 之前包含 "May I" 用语
- [ ] 每个结论都有下一步交接（PROCEED → `/create-epics`、`/create-stories`、`/sprint-plan`、`/gate-check production`；PIVOT → `/design-system`、`/architecture-decision`、`/vertical-slice`；KILL → `/brainstorm` 或 `/prototype`）
- [ ] 说明 CD-PLAYTEST：在 `full` 下派发，在 `lean`/`solo` 下跳过并附注说明

---

## Director Gate Checks

- **Full mode**：CD-PLAYTEST —— `creative-director` 接收 REPORT.md 内容、
  验证问题，以及支柱和核心幻想（来自
  `design/gdd/game-concept.md`，或来自 `design/game-brief.md` 的提案和
  "what they feel" 行）。APPROVE → 建议保持不变；CONCERNS → 与建议一并显示，
  由用户决定（修订 / 接受 / 讨论）；
  REJECT → PROCEED 不能成立：用户选择 PIVOT 或 KILL，且 REPORT.md
  记录总监的理由（PIVOT 或 KILL 成立）；NOT ASSESSED [missing
  input] → 既不支持也不推翻建议：补齐输入并重新运行闸门，或记录
  `CD-PLAYTEST: NOT ASSESSED — [input]`。对 REPORT.md 及其 `prototypes/index.md`
  行的任何变更都先询问。当切片自身的结论为 NOT ASSESSED 时跳过该闸门：
  "CD-PLAYTEST skipped — the slice has not been played yet."
- **Lean mode**：跳过 —— "CD-PLAYTEST skipped — Lean mode."
- **Solo mode**：跳过 —— "CD-PLAYTEST skipped — Solo mode."

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 构建切片，在无人协助下试玩，PROCEED

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`engine.language: GDScript`、
  `modes.review_mode: solo`、`modes.workflow: standard`（固定：未设置会解析为
  minimal，从而让 PROCEED 路由到 `/create-stories` 和 `/dev-story`，而不是
  step 7 的列表）
- `design/gdd/game-concept.md`（核心幻想、支柱）、`design/gdd/systems-index.md`、
  `docs/architecture/architecture.md` 和 `docs/architecture/control-manifest.md`
  存在；`prototypes/` 中没有 `ember-trail-vertical-slice/`
- 在复盘中，玩家在无人协助下完成了循环，40 秒内到达第一个有意义的操作，
  感受到了核心幻想，且未遇到乐趣阻塞；用户回答 PROCEED

**Input:** `/vertical-slice`

**Expected behavior:**
1. 读取概念、系统索引、架构和清单；陈述一个同时覆盖玩家体验和构建可行性的
   验证问题
2. 呈现 3–5 分钟范围和构建计划；确认中点名
   `production/session-state/active.md`，并把检查点写在那里
3. 询问 "May I create the vertical slice directory at
   `prototypes/ember-trail-vertical-slice/` and begin implementation?"；它写入的
   每个 GDScript 文件都以 `# VERTICAL SLICE - NOT FOR PRODUCTION` 开头
4. 与用户迭代直至循环可玩，然后请求从头试玩，并一次一问地提出六个复盘问题
5. 依据 `.claude/docs/templates/vertical-slice-report.md` 起草报告，含
   逐日速度日志；询问 "May I write this report to
   `prototypes/ember-trail-vertical-slice/REPORT.md` and add its row to
   `prototypes/index.md`?"；写入两者
6. 注明 "CD-PLAYTEST skipped — Solo mode."
7. PROCEED 路由到 `/create-epics layer:foundation`、`/create-epics layer:core`、
   `/create-stories`、`/sprint-plan` 和 `/gate-check production`

**Assertions:**
- [ ] 验证问题同时包含玩家体验和构建可行性两个部分
- [ ] 在写入任何切片文件之前确认范围，且检查点询问点名 `active.md`
- [ ] 目录询问在任何切片文件之前；每个 GDScript 文件的头部为 `#` 注释，绝不是 `//`
- [ ] 复盘问题在从头试玩之后一次一问
- [ ] REPORT.md 和 `prototypes/index.md` 行仅在一次同时点名两者的询问之后写入；该行记录 PROCEED
- [ ] 正式阶段步骤为 `/gate-check production`（Pre-Production → Production），而不是 `/gate-check pre-production`

---

### Case 2: 失败路径 —— 已构建切片中存在 NO，不能 PROCEED

**Fixture:**
- 同 Case 1，但在复盘中玩家需要开发者解释核心操作（问题 1：否）
- 用户仍然回答 PROCEED，随后在被询问时选择 PIVOT

**Input:** `/vertical-slice`

**Expected behavior:**
1. 技能不记录 PROCEED：`/gate-check production` 会让任何 Vertical Slice
   Validation 项中有 NO 的已构建切片 FAIL
   （`.claude/skills/gate-check/references/gate-production.md`）
2. 它要求用户选择 PIVOT 或 KILL，并以问题 1 的答案为理由点名
3. 用户选择 PIVOT；REPORT.md 在其询问之后写入，结论为 PIVOT，
   并点名该 NO
4. PIVOT 路线运行：两个延续问题，一次一个，然后 "May I
   write this to `prototypes/ember-trail-vertical-slice/PIVOT-NOTE.md`?"

**Assertions:**
- [ ] 当有验证项为 NO 时，不把 PROCEED 写入 REPORT.md 或 `prototypes/index.md`
- [ ] 由用户而非技能在 PIVOT 和 KILL 之间选择
- [ ] 报告点名未通过的验证项
- [ ] PIVOT-NOTE.md 仅在其询问之后写入，内容包含哪些有效、哪些失败，以及下一个切片应证明什么

---

### Case 3: 模式变体 —— CD-PLAYTEST 在 full 下运行，在 lean 和 solo 下跳过

**Fixture:**
- 一个切片已完成复盘，建议为 PROCEED，且 REPORT.md 已写入
- 运行 A：`modes.review_mode: full`；CD-PLAYTEST 返回 APPROVE
- 运行 B：`modes.review_mode: lean`
- 运行 C：`modes.review_mode: full`，输入 `/vertical-slice --review solo`

**Expected behavior:**
1. 运行 A：REPORT.md 写入之后，为 CD-PLAYTEST 派发 `creative-director`，
   传入 REPORT.md 内容、验证问题以及支柱和核心幻想；APPROVE 使 PROCEED
   保持不变，REPORT.md 不变
2. 运行 B：不派发；"CD-PLAYTEST skipped — Lean mode."
3. 运行 C：`--review solo` 覆盖解析得到的 `full`；不派发；"CD-PLAYTEST
   skipped — Solo mode."

**Assertions:**
- [ ] 运行 A 仅在 REPORT.md 存在之后派发 CD-PLAYTEST，并传入三项输入
- [ ] 运行 A 的 APPROVE 保持建议不变，且不触发任何 REPORT.md 更新询问
- [ ] 运行 B 和 C 不派发任何总监，并打印各自的跳过说明
- [ ] 任何运行中都不派发其他总监闸门

---

### Case 4: 边界情况 —— 切片已构建，但没有人玩过

**Fixture:**
- 循环已达到可演示状态，但用户本次会话无法从头到尾试玩
- `modes.review_mode: full`

**Input:** `/vertical-slice`

**Expected behavior:**
1. Phase 5 的试玩未发生，因此结论为 NOT ASSESSED，并附原因
2. REPORT.md 在其询问之后记录速度日志和 NOT ASSESSED；
   `prototypes/index.md` 行记录 NOT ASSESSED
3. 不派发 CD-PLAYTEST："CD-PLAYTEST skipped — the slice has not been
   played yet."
4. 下一步：完成试玩并从 `active.md` 检查点继续复盘，然后在询问之后更新
   REPORT.md；不会把该切片当作已通过而送去 `/gate-check production`

**Assertions:**
- [ ] 结论为 NOT ASSESSED —— 绝不是 PROCEED —— 并说明原因
- [ ] NOT ASSESSED 的排序高于 PROCEED、低于 PIVOT 和 KILL
- [ ] 对未试玩的切片不派发 CD-PLAYTEST，并声明跳过
- [ ] 不提供 PROCEED 的后续步骤

---

### Case 5: 总监质量闸门 —— CD-PLAYTEST 返回 REJECT、CONCERNS 或 NOT ASSESSED

**Fixture:**
- 一个切片已完成复盘，建议为 PROCEED，且 REPORT.md 已写入；
  `modes.review_mode: full`；`design/gdd/game-concept.md` 含支柱
- 运行 A：CD-PLAYTEST 返回 REJECT —— 核心幻想不存在。被询问 PIVOT
  或 KILL 时，用户选择 KILL；没有试玩测试会话显示出情绪高点，
  且这是该概念的第三次切片尝试
- 运行 B：CD-PLAYTEST 返回 CONCERNS —— 解决节拍削弱了一个支柱；
  用户选择 `Accept with noted concerns`
- 运行 C：CD-PLAYTEST 返回 NOT ASSESSED —— 它接收的上下文中缺少
  支柱

**Input:** `/vertical-slice`

**Expected behavior:**
1. 运行 A：REJECT 被读作质量闸门的裁决，而非切片结论。PROCEED
   不能成立：技能要求用户选择 PIVOT 或 KILL；用户选择
   KILL；在 "May I update `prototypes/[concept-name]-vertical-slice/REPORT.md`
   and its `prototypes/index.md` row?" 之后，两者都记录 KILL，且 REPORT.md 记录
   总监的理由。Phase 8 的 KILL 路线运行：两个检查清单项适用，因此该
   KILL 是健全的，并询问 "May I append this to `prototypes/GRAVEYARD.md`?"
2. 运行 B：关注项与 PROCEED 一并显示，选项为 `Revise the recommendation` /
   `Accept with noted concerns` / `Discuss further`；选择 Accept 时，PROCEED 保持成立，
   且在更新询问之后，REPORT.md 记录这些关注项
3. 运行 C：点名缺失的输入；补齐支柱后重新运行闸门，或在更新询问之后记录
   `CD-PLAYTEST: NOT ASSESSED — [input]`；PROCEED
   既不因其得到确认，也不因其被推翻

**Assertions:**
- [ ] 总监的答复被读作 APPROVE / CONCERNS / REJECT / NOT ASSESSED —— 绝不是它自己的 PROCEED / PIVOT / KILL
- [ ] 运行 A：REJECT 之后不保留 PROCEED；由用户选择 PIVOT 或 KILL，且总监的理由写入 REPORT.md
- [ ] 运行 A：GRAVEYARD.md 条目仅在其询问之后追加，并附具体的终止理由
- [ ] 运行 B：由用户决定；只有用户主动修订时建议才改变
- [ ] 运行 C：NOT ASSESSED 不被当作 APPROVE
- [ ] 每次 REPORT.md / `prototypes/index.md` 更新都遵循一次同时点名两者的询问

---

### Case 6: minimal 工作流 —— PROCEED 路由到用户故事，速度日志输入简报

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`engine.language: GDScript`、
  `modes.workflow: minimal`、`modes.review_mode: solo`（固定：本用例测试
  `minimal` 的 PROCEED 路线，与 Case 1 相反）
- `design/game-brief.md` 含提案（pitch）、一个 "what they feel" 行，以及三个
  功能的构建顺序；没有 `design/gdd/game-concept.md`，没有冲刺计划，也没有
  `production/sprints/`
- 在复盘中，玩家在无人协助下完成了循环，40 秒内到达第一个有意义的操作，
  感受到了核心幻想，且未遇到乐趣阻塞；用户回答 PROCEED

**Input:** `/vertical-slice`

**Expected behavior:**
1. 读取简报代替概念，并按 Case 1 构建
2. 报告的逐日速度日志被描述为输入简报的构建顺序，而非冲刺规划
   （"at `workflow: minimal`, which has no sprints, into
   the brief's build order"）
3. PROCEED 打印 minimal 路线：`/create-stories`（来自简报），然后是
   第一个用户故事上的 `/dev-story`。技能声明 "the rest of this list is the
   `standard`/`full` path"
4. 不提供 `/create-epics layer:foundation`、`/create-epics layer:core` 和
   `/sprint-plan` 步骤作为下一步

**Assertions:**
- [ ] 工作流从 `project.yaml`（`modes.workflow: minimal`）解析，而非仅凭 rigor 预设假定
- [ ] PROCEED 的下一步为 `/create-stories` 然后 `/dev-story`
- [ ] 在 `minimal` 下不推荐 `/create-epics` 和 `/sprint-plan` 作为下一步
- [ ] 速度日志与简报的构建顺序关联，且不引用或创建任何冲刺计划
- [ ] REPORT.md 和 `prototypes/index.md` 行在一次同时点名两者的询问之后仍记录 PROCEED

---

## Protocol Compliance

- [ ] 在定义验证问题之前读取概念（在 `minimal` 下为简报）
- [ ] 构建之前确认范围；在把计划记录到 `active.md` 之前、在创建 `prototypes/[concept-name]-vertical-slice/` 之前询问
- [ ] 将切片文件保留在 `prototypes/` 下，每个都以自身注释语法的 `VERTICAL SLICE - NOT FOR PRODUCTION` 头开始
- [ ] 在写入 REPORT.md（及其 `prototypes/index.md` 行）、PIVOT-NOTE.md、GRAVEYARD.md 以及任何闸门后的报告更新之前询问
- [ ] 在验证项为 NO 之后绝不记录 PROCEED，也绝不为无人玩过的切片记录 PROCEED
- [ ] 在 CD-PLAYTEST 之前应用评审模式，跳过时打印跳过说明
- [ ] 以各结论对应的下一步结束

---

## Coverage Notes

- 多轮构建循环、第 3 天的沉没成本停止（sunk-cost stop）以及逐日速度
  日志需要实际运行才能验证。
- 重新运行时读取先前的 `PIVOT-NOTE.md` 以构建新的验证问题，
  未测试。
- `rigor: minimal` 的 PROCEED 路线为 Case 6。简报的提案和 "what they
  feel" 行在 CD-PLAYTEST 输入中代替支柱，未测试，因为
  该闸门在 `full` 之外会被跳过。
- 健全性检查清单给出 0–1 项的 KILL（改为建议一次有针对性的 PIVOT）
  未测试。
- 联网游戏的限制（本地切片无法验证网络手感）属于建议性文字，未测试。
