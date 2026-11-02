# Skill Test Spec: /milestone-review

## Skill Summary

`/milestone-review` 根据 `production/milestones/` 中的里程碑定义（若存在）以及 `production/sprints/` 中的冲刺报告，评审里程碑的进展：功能完成度、质量指标、代码健康度、风险、速度、范围建议以及 Go/No-Go 建议（NOT ASSESSED / GO / CONDITIONAL GO / NO-GO）。阻塞的用户故事及其阻塞项来自 `production/sprint-status.yaml` 和用户故事文件，未关闭的缺陷来自 `production/qa/bugs/`。在产出任何报告之前，它把每个输入记录为 FOUND 或 ABSENT；若某小节的输入缺失，该小节读作 `NOT ASSESSED — NO DATA`，若每一必需输入都缺失，它就以该值作为整体结论停止。在完整评审模式下，它在生成 Go/No-Go 建议之前以 PR-MILESTONE 闸门生成 `producer`；producer 的结论（ON TRACK / AT RISK / OFF TRACK）会内联展示，而 AT RISK 或 OFF TRACK 会就如何表述该建议发起一次 `AskUserQuestion`。在 lean 和 solo 模式下，闸门会被跳过并给出说明。技能在持久化之前询问“May I write this to `production/milestones/[milestone-name]-review.md`?”。结论：COMPLETE（评审已保存）、BLOCKED（拒绝写入）或 `NOT ASSESSED — NO DATA`（完全没有输入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED、NOT ASSESSED
- [ ] 包含 Go/No-Go 建议取值：GO、CONDITIONAL GO、NO-GO
- [ ] 包含 "May I write" 措辞（技能会写入评审文档）
- [ ] 具有下一步交接（`/gate-check`、`/sprint-plan`）

---

## Director Gate Checks

| Gate ID       | Trigger condition                              | Mode guard                |
|---------------|------------------------------------------------|---------------------------|
| PR-MILESTONE  | Before the Go/No-Go recommendation is generated | full only (not lean/solo) |

PR-MILESTONE 结论：ON TRACK / AT RISK / OFF TRACK——或 NOT ASSESSED [missing input]（`.claude/docs/director-gates.md`），在该情况下技能从不建议 GO。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 接近完成、有一个功能延期的里程碑

**Fixture:**
- `production/milestones/milestone-03.md` 存在（里程碑定义模板），其 Feature List 中有 8 个功能
- 7 个功能为 `Status: Complete`
- 1 个功能为 `Status: Deferred`（延期到 milestone-04）
- `production/sprints/sprint-007.md` 至 `sprint-009.md` 存在，并带有 `/sprint-plan` 写入的标题
- 这些功能的用户故事存在于 `production/epics/` 下；没有一个是 `Blocked`
- `project.yaml` 设置 `modes.review_mode: full`
- producer 返回 ON TRACK

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能读取 `milestone-03.md`，对冲刺报告做 glob（N = 3）并 grep 其小节，然后 grep 用户故事文件中的 Blocked 状态（无）
2. 技能编译评审：7 个功能列入 Fully Complete；延期功能不计为完成
3. 技能以 PR-MILESTONE 生成 `producer`，传入里程碑名称与目标日期、完成百分比、阻塞用户故事数（0）、速度数据和候选裁剪项
4. producer 的 ON TRACK 结论内联展示在 Go/No-Go 小节；不询问表述问题
5. 技能展示评审并询问“May I write this to `production/milestones/milestone-03-review.md`?”
6. 用户批准；文件被写入；结论 COMPLETE

**Assertions:**
- [ ] 延期功能未列在 Fully Complete 下，也未计入完成百分比（8 个中完成 7 个）
- [ ] 在完整模式下、生成 Go/No-Go 建议之前生成 PR-MILESTONE，并传入完成百分比和阻塞用户故事数
- [ ] producer 的 ON TRACK 结论内联出现在 Go/No-Go 小节，且不发起表述性的 `AskUserQuestion`（只有 AT RISK 和 OFF TRACK 才会发起）
- [ ] 技能在写入前询问“May I write”，并指名 `production/milestones/milestone-03-review.md`
- [ ] 写入后结论为 COMPLETE

---

### Case 2: 受阻里程碑 —— producer 返回 OFF TRACK

**Fixture:**
- `production/milestones/milestone-03.md` 列出 5 个功能
- 2 个功能为 `Status: Complete`
- 3 个功能为 `Status: Blocked`；每个在 `production/epics/[its epic]/` 下有一个用户故事，其文件带有 `> **Status**: Blocked` 和一条指明其阻塞项的 `BLOCKED:` 注记
- 冲刺报告存在于 `production/sprints/` 中；它们没有指名任何阻塞项
- `project.yaml` 设置 `modes.review_mode: full`
- producer 返回 OFF TRACK

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能读取里程碑和冲刺报告，然后 grep 用户故事文件中的 `Blocked` 状态和 `BLOCKED:` 注记；在 Blocked 表中编译这 3 个受阻功能及其阻塞项
2. 技能生成 PR-MILESTONE，传入 40% 的完成百分比和 3 的阻塞用户故事数
3. 在 OFF TRACK 时，技能通过 `AskUserQuestion` 询问：“Producer verdict: OFF TRACK. The milestone is in jeopardy. This review will recommend NO-GO. How do you want to proceed?”，选项为 [A] 接受 NO-GO、[B] 覆盖为 CONDITIONAL GO、[C] 停止
4. 用户选择 [A]；Go/No-Go 建议为 NO-GO
5. 技能展示评审，询问“May I write”，并在批准后写入

**Assertions:**
- [ ] Blocked 表中每个受阻功能都与其阻塞项一起指名，阻塞项取自其用户故事的 `BLOCKED:` 注记——冲刺报告不含任何阻塞项，因此未从用户故事文件读取的阻塞项即为臆造
- [ ] PR-MILESTONE 收到阻塞用户故事数（3），该数从用户故事文件统计
- [ ] OFF TRACK 会在生成建议之前发起带 Accept NO-GO / Override to CONDITIONAL GO / Stop 的 `AskUserQuestion`
- [ ] 选择 [A] 后，建议为 NO-GO——技能不会在 OFF TRACK 结论下发布 GO
- [ ] 写入文件之前仍出现“May I write”提示

---

### Case 3: 完整模式 —— PR-MILESTONE 因范围漂移返回 AT RISK

**Fixture:**
- `production/milestones/milestone-03.md` 列出 6 个已完成功能，其中 2 个不在原始定义中（里程碑中期新增）
- 冲刺报告存在于 `production/sprints/` 中
- `project.yaml` 设置 `modes.review_mode: full`
- producer 返回 AT RISK，把新增的 2 个功能列为范围漂移并列出缓解措施

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能编译评审
2. PR-MILESTONE 返回 AT RISK 并附缓解措施
3. 技能通过 `AskUserQuestion` 询问：“Producer verdict: AT RISK. Milestone may slip. How should the Go/No-Go section be framed?”，选项为 [A] CONDITIONAL GO、[B] NO-GO、[C] GO
4. 用户选择 [A]；Go/No-Go 小节读作 CONDITIONAL GO，并列出 producer 的条件
5. 技能展示评审，询问“May I write”，并在批准后写入

**Assertions:**
- [ ] producer 的 AT RISK 评估（包括其范围漂移发现）内联展示在 Go/No-Go 小节——未被压制
- [ ] AT RISK 会在写入文件之前发起带 CONDITIONAL GO / NO-GO / GO 的 `AskUserQuestion`
- [ ] 选择 [A] 后，建议为 CONDITIONAL GO，且其 Conditions 列表携带 producer 的条件
- [ ] 只有在批准“May I write”之后才写入评审

---

### Case 4: 边界情况 —— 无里程碑定义且无冲刺数据

**Fixture:**
- `production/milestones/` 不存在
- `production/sprints/` 不存在
- `production/risk-register/` 不存在
- 代码根目录下不存在任何源文件
- 没有用户故事文件、没有 `production/sprint-status.yaml`，也没有 `production/qa/bugs/`
- `project.yaml` 设置 `modes.review_mode: full`

**Input:** `/milestone-review current`

**Expected behavior:**
1. 技能列出其输入，并把每个记录为 FOUND 或 ABSENT
2. 每一必需输入都是 ABSENT，因此技能停止并把 `NOT ASSESSED — NO DATA` 作为整体结论报告
3. 报告指名缺失了什么以及它们来自何处：冲刺报告由 `/sprint-plan` 写入；里程碑定义依据 `.claude/docs/templates/milestone-definition.md` 手工撰写
4. 不臆造里程碑定义，不生成闸门，不写入文件

**Assertions:**
- [ ] 技能不崩溃，也不用估算值填充评审模板
- [ ] 结论为 `NOT ASSESSED — NO DATA`——而非 GO，也非 COMPLETE
- [ ] 输出指名缺失的输入及其各自来源（冲刺报告来自 `/sprint-plan`；里程碑来自里程碑定义模板）
- [ ] 不生成 PR-MILESTONE，也不出现“May I write”提示

---

### Case 5: Lean/Solo 模式 —— 跳过 PR-MILESTONE 闸门

**Fixture:**
- `production/milestones/milestone-03.md` 列出 5 个功能，全部 `Status: Complete`
- 冲刺报告存在于 `production/sprints/` 中
- `production/qa/bugs/` 不存在——没有通过 `/bug-report` 提交任何缺陷
- `project.yaml` 设置 `modes.review_mode: solo`

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能从注入的配置块读取 `review_mode`——为 `solo`
2. 技能编译评审；由于没有缺陷文件，Quality Metrics 的缺陷行读作 `NOT ASSESSED — NO DATA`
3. 跳过 PR-MILESTONE；输出注明“PR-MILESTONE skipped — Solo mode.”
4. Go/No-Go 小节在没有 producer 结论的情况下展示
5. 技能询问“May I write this to `production/milestones/milestone-03-review.md`?”
6. 用户批准；评审文件被写入；结论 COMPLETE

**Assertions:**
- [ ] 在 solo 模式下不调用 PR-MILESTONE 闸门
- [ ] 输出包含“PR-MILESTONE skipped — Solo mode.”
- [ ] Go/No-Go 小节不携带 producer 结论（没有归属于 producer 的 ON TRACK / AT RISK / OFF TRACK）
- [ ] Quality Metrics 的缺陷行读作 `NOT ASSESSED — NO DATA`——而非“0”——同时有输入的其它小节仍正常产出
- [ ] 写入之前仍需要用户批准
- [ ] 写入后结论为 COMPLETE

---

### Case 6: 由 rigor 推导为 Lean 模式 —— 跳过 PR-MILESTONE 并给出 Lean 说明

**Fixture:**
- `production/milestones/milestone-03.md` 列出 4 个功能，全部 `Status: Complete`
- 冲刺报告存在于 `production/sprints/` 中
- `project.yaml` 设置 `modes.rigor: standard` 且未固定评审模式，因此注入块读作 `review_mode: lean (rigor:standard)`

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能从注入的配置块读取 `review_mode`——为 `lean`
2. 技能编译评审
3. 跳过 PR-MILESTONE；输出注明“PR-MILESTONE skipped — Lean mode.”
4. Go/No-Go 小节在没有 producer 结论的情况下展示
5. 技能询问“May I write”，批准后写入；结论 COMPLETE

**Assertions:**
- [ ] 在 lean 模式下不调用 PR-MILESTONE 闸门
- [ ] 输出包含“PR-MILESTONE skipped — Lean mode.”——而非 Solo 说明
- [ ] Go/No-Go 小节不携带 producer 结论
- [ ] 写入之前仍需要用户批准，写入后结论为 COMPLETE

---

### Case 7: 闸门返回 NOT ASSESSED —— 绝不 GO

**Fixture:**
- `production/milestones/milestone-03.md` 列出 5 个功能，全部 `Status: Complete`，但未给出目标日期
- 冲刺报告存在于 `production/sprints/` 中；用户故事存在于 `production/epics/` 下，且没有一个是 `Blocked`
- `project.yaml` 设置 `modes.review_mode: full`
- producer 返回 NOT ASSESSED——没有可用于判断的目标日期
- 当被问及该日期时，用户也没有可提供的日期

**Input:** `/milestone-review milestone-03`

**Expected behavior:**
1. 技能编译评审并生成 PR-MILESTONE；它返回 NOT ASSESSED
2. 技能指名缺失的输入（目标日期），并视该结果既非 ON TRACK，也不能作为建议 GO 的理由
3. 评审自身的发现没有任何一项要求 CONDITIONAL GO 或 NO-GO，因此 Go/No-Go 建议读作 NOT ASSESSED，并指名缺失的目标日期
4. 技能询问“May I write”，批准后写入；结论 COMPLETE

**Assertions:**
- [ ] 尽管所有功能都 Complete，Go/No-Go 建议仍为 NOT ASSESSED——绝不 GO
- [ ] Go/No-Go 小节中指名称缺失的目标日期
- [ ] 针对 NOT ASSESSED 不发起 AT RISK 和 OFF TRACK 的表述问题
- [ ] 写入文件之前仍出现“May I write”

---

## Protocol Compliance

- [ ] 在产出报告之前把每个输入记录为 FOUND 或 ABSENT；当每一必需输入都缺失时报告 `NOT ASSESSED — NO DATA`，任一单节输入缺失时该节也如此
- [ ] 在完整模式下，于生成 Go/No-Go 建议之前生成 PR-MILESTONE，并在询问是否写入之前展示完整评审
- [ ] 写入评审文档之前始终询问“May I write”
- [ ] PR-MILESTONE 闸门仅在完整模式下运行；lean 和 solo 输出中会出现跳过说明
- [ ] 结论表述清晰——COMPLETE、BLOCKED（拒绝写入）或 `NOT ASSESSED — NO DATA`——且 Go/No-Go 建议为 NOT ASSESSED / GO / CONDITIONAL GO / NO-GO 之一

---

## Coverage Notes

- `production/milestones/` 缺失但冲刺报告存在（技能会说明并仅依据冲刺报告评审）的情况未测试。
- `current` 选择跳过以 `-review.md` 结尾的文件未测试。
- 拒绝写入的路径（结论 BLOCKED）未测试。
- 速度计算的具体细节（故事点 vs. 故事数）不在此验证；它们属于评审编译阶段的实现细节。
