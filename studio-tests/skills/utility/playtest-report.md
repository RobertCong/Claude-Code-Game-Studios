# Skill Test Spec: /playtest-report

## Skill Summary

`/playtest-report` 有两种模式。`new` 输出空白试玩测试报告模板并以结论 COMPLETE 停止，不保存任何内容；`analyze [path]` 从文件读取原始记录，交叉引用设计文档，用结构化发现项填充模板，并标记与设计意图冲突的观察。缺陷（崩溃、帧率下降）进入 Bugs Encountered 表，而不是 Gameplay Flow → Pain points。模板包含以下小节：Session Info、Test Focus、First Impressions、Gameplay Flow（哪些有效、痛点、困惑、惊喜）、Bugs Encountered、Feature-Specific Feedback、Quantitative Data、Overall Assessment 和 Top 3 Priorities。

发现项被分入四个类别并路由：设计变更交给 `/propagate-design-change [path]`，平衡性调整交给 `/balance-check [system]`，缺陷交给 `/bug-report`，打磨项交给 `production/` 积压。在 `full` 评审模式下，技能为闸门 **CD-PLAYTEST** 生成 `creative-director`；在 `lean` 和 `solo` 下则跳过闸门并附注说明。随后它询问 "May I write this playtest report to `production/qa/playtests/playtest-[date]-[tester].md`?"。结论为 **COMPLETE**。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 在写入报告前包含 "May I write" 协作协议用语
- [ ] 具备下一步交接（设计变更后用 `/design-review`，缺陷修复后用 `/bug-triage`）

---

## Director Gate Checks

- **Full mode**：CD-PLAYTEST——`creative-director` 对照游戏支柱和核心幻想评审报告（APPROVE / CONCERNS / REJECT，或在缺少输入时为 NOT ASSESSED），评审发生在发现项分类之后、报告保存之前
- **Lean mode**：跳过 CD-PLAYTEST（不是 PHASE-GATE）；附注
  "CD-PLAYTEST skipped — Lean mode."
- **Solo mode**：跳过 CD-PLAYTEST；附注 "CD-PLAYTEST skipped — Solo mode."

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 分析记录，发现项按类别路由

**Fixture:**
- `production/qa/notes/session-01.md` 记录一名测试者的笔记："framerate
  drops every time the forest area loads"、"I could not work out how to open
  the first door"，以及 "the second boss hits far too hard"
- `design/gdd/` 中有教程和战斗 GDD；教程 GDD 说明第一扇门用于教学
  交互键
- 评审模式：`solo`

**Input:** `/playtest-report analyze production/qa/notes/session-01.md`

**Expected behavior:**
1. 技能读取笔记并交叉引用设计文档
2. 技能填充模板；帧率下降进入 Bugs Encountered 表
3. Phase 3 将发现项分入四个类别：门的困惑为设计变更，
   首领伤害为平衡性调整，帧率下降为缺陷
4. 路由：对教程 GDD 运行 `/propagate-design-change`，对
   combat 运行 `/balance-check`，对帧率下降运行 `/bug-report`
5. 技能注明 "CD-PLAYTEST skipped — Solo mode."，并询问 "May I write this
   playtest report to `production/qa/playtests/playtest-[date]-[tester].md`?"
6. 获批后写入文件；结论为 COMPLETE

**Assertions:**
- [ ] 帧率下降出现在 Bugs Encountered 表中，而不是 Gameplay Flow 下
- [ ] 发现项分入四个类别（design、balance、bug、polish）
- [ ] 每个类别路由到其指定的技能（`/propagate-design-change`、`/balance-check`、`/bug-report`）
- [ ] 写入前 "May I write" 指明 `production/qa/playtests/playtest-[date]-[tester].md`
- [ ] 结论为 COMPLETE

---

### Case 2: New 模式 — 空白模板输出

**Fixture:**
- 任意项目状态

**Input:** `/playtest-report new`

**Expected behavior:**
1. 技能选择 `new` 模式
2. 技能输出空白模板，每个小节标题及其
   方括号占位符均未填写
3. 不读取任何笔记文件，也不编造任何发现项
4. 模式在模板之后结束：不路由、不经过总监闸门、不询问保存，
   结论为 COMPLETE——输出空白模板；未保存任何内容

**Assertions:**
- [ ] 输出包含标题 Session Info、Test Focus、First Impressions、Gameplay Flow、Bugs Encountered、Feature-Specific Feedback、Quantitative Data、Overall Assessment 和 Top 3 Priorities
- [ ] 占位符（例如 `[Date]`、`[Name/ID]`）保持未填写
- [ ] 不读取任何笔记文件，也不编造任何发现项
- [ ] 无 "May I write" 询问，也不写入文件
- [ ] 结论为 COMPLETE

---

### Case 3: 观察与设计意图冲突

**Fixture:**
- `design/gdd/crafting.md` 说明制作是玩家每局都会参与的核心循环
- `production/qa/notes/session-02.md` 记录测试者在 40 分钟内从未打开
  制作菜单
- 评审模式：`solo`

**Input:** `/playtest-report analyze production/qa/notes/session-02.md`

**Expected behavior:**
1. 技能读取笔记并交叉引用 `design/gdd/crafting.md`
2. 技能将该观察标记为与设计意图冲突
3. Phase 3 将其放入 "Design changes needed" 类别
4. 路由指明对 `design/gdd/crafting.md` 运行 `/propagate-design-change`
5. 在 "May I write" 询问后保存报告；结论为 COMPLETE

**Assertions:**
- [ ] 制作相关的观察被明确标记为与 GDD 的意图冲突
- [ ] 它被归类为设计变更，而不是打磨项
- [ ] 建议对受影响的 GDD 运行 `/propagate-design-change`
- [ ] 写入后结论为 COMPLETE

---

### Case 4: 边界情况 — Full 评审模式但没有可用支柱

**Fixture:**
- 评审模式：`full`
- `design/gdd/game-concept.md` 和 `design/game-brief.md` 都不存在
- `production/qa/notes/session-03.md` 包含试玩测试笔记

**Input:** `/playtest-report analyze production/qa/notes/session-03.md`

**Expected behavior:**
1. 技能结构化并分类发现项
2. 技能为 CD-PLAYTEST 生成 `creative-director`，传入报告内容和
   待验证的假设
3. 由于两个支柱来源都不存在，提示中说明 "No pillars
   available — assess against the hypothesis alone."，而不是省略支柱
4. 总监的评估在保存询问之前展示

**Assertions:**
- [ ] 生成 CD-PLAYTEST（评审模式为 `full`）
- [ ] 闸门提示说明没有可用支柱，而不是静默传入空值
- [ ] 技能不编造支柱
- [ ] 评估在 "May I write" 之前展示

---

### Case 5: 总监闸门 — 按评审模式决定 CD-PLAYTEST

**Fixture:**
- `design/gdd/game-concept.md` 存在且包含支柱
- `production/qa/notes/session-04.md` 包含试玩测试笔记
- 运行三次：`--review full`、`--review lean`、`--review solo`
- 在 full 运行中，`creative-director` 返回 CONCERNS

**Input:** `/playtest-report analyze production/qa/notes/session-04.md --review [mode]`

**Expected behavior:**
1. Full：在 Phase 3 分类之后，为 CD-PLAYTEST 生成 `creative-director`，
   传入报告内容、来自 `game-concept.md` 的支柱和假设；
   展示其 CONCERNS 评估，并在报告中添加
   `## Creative Director Assessment` 小节
2. Lean：不生成总监；附注 "CD-PLAYTEST skipped — Lean mode."
3. Solo：不生成总监；附注 "CD-PLAYTEST skipped — Solo mode."
4. 三次运行随后都询问 "May I write"，并以结论 COMPLETE 结束

**Assertions:**
- [ ] 在 full 模式下，CD-PLAYTEST 在报告保存前生成 `creative-director`
- [ ] 遇到 CONCERNS 时，报告增加包含结论和反馈的 `## Creative Director Assessment` 小节
- [ ] 在 lean 模式下，跳过附注指明 CD-PLAYTEST 和 Lean mode
- [ ] 在 solo 模式下，跳过附注指明 CD-PLAYTEST 和 Solo mode
- [ ] 任何模式下都不生成其他总监闸门

---

## Protocol Compliance

- [ ] `analyze` 在填充模板前读取笔记文件并交叉引用设计文档
- [ ] 发现项被分类为 design / balance / bug / polish，并路由到指定的后续动作
- [ ] 在生成 CD-PLAYTEST 前应用评审模式，跳过时打印跳过附注
- [ ] 在询问保存前展示总监的评估（full 模式）
- [ ] 在写入前询问 "May I write this playtest report to `production/qa/playtests/playtest-[date]-[tester].md`?"
- [ ] 以结论 COMPLETE 和下一步（`/design-review`、`/bug-triage`）结束

---

## Coverage Notes

- CD-PLAYTEST 的 REJECT 结论遵循与 CONCERNS 相同的路径（添加评估小节），未单独测试；APPROVE 只添加批准附注。NOT ASSESSED（总监缺少输入）会添加说明缺失内容的小节，绝不被解读为批准；未单独测试。
- 在 `modes.workflow: minimal` 下，`design/game-brief.md` 取代
  `game-concept.md`，但简报没有支柱：其一句话提案和 "Who
  it's for / what they feel" 行会代替支柱传入；未单独测试。
- 视频或截图附件未测试；报告仅包含文本。
