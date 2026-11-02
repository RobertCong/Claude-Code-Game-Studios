# Skill Test Spec: /story-done

## Skill Summary

`/story-done` 闭合设计与实现之间的回路。在实现完一个用户故事时运行，它读取用户
故事文件，从 `docs/architecture/tr-registry.yaml` 重新读取当前需求文本（绝不使用
用户故事中引述的副本）以及治理 ADR 的 `## Decision` / `## Consequences`，验证
每条验收标准（自动、通过批量 `AskUserQuestion`，或作为
`DEFERRED — requires playtest session`），构建一张标准到测试的可追溯性表，检查
测试证据，并检查 GDD/ADR/清单/范围偏差（分类为 BLOCKING / ADVISORY / OUT OF
SCOPE）。随后评审模式决定 QA 覆盖率闸门（QL-TEST-COVERAGE）和代码评审步骤
（`full` 下为 LP-CODE-REVIEW，`lean` 下为一个 `/code-review` 问题，`solo` 下为
注明的跳过）。它产生 COMPLETE / COMPLETE WITH NOTES / NOT ASSESSED / BLOCKED
结论，并且只在一次 `AskUserQuestion` 选择之后更新用户故事文件、可选地向
`docs/tech-debt-register.md` 追加内容，并展示下一个用户故事 —— 没有冲刺计划时，
来自 `bash .claude/scripts/story-status.sh`，即 `/help` 和 `/sprint-status` 读取的
列表，且在用户故事文件写入之后运行。它只在打开截图后才说明截图显示了什么，
并就行为标准提问，而不是从代码中读出来。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥5 个阶段标题（复杂多阶段技能）
- [ ] 包含结论关键词：COMPLETE、COMPLETE WITH NOTES、NOT ASSESSED、BLOCKED
- [ ] `allowed-tools` 包含 Write/Edit，因此存在先询问后写入的措辞（"Use `AskUserQuestion` before writing anything" —— 覆盖用户故事文件和技术债注册表）
- [ ] 有下一步交接（从冲刺展示下一个用户故事）

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 所有验收标准都已满足，无偏差

**测试夹具：**
- `project.yaml` 设置 `modes.rigor: standard`（→ `workflow: standard`、
  `qa.level: standard`、`review_mode: lean`）和 `engine.name: Godot`，因此
  `tests/unit/` 是测试根目录
- 用户故事文件位于 `production/epics/core/story-light-pickup.md`，包含：
  - `Type: Logic` 和 3 条验收标准，且都按描述实现：AC-1 "Picking up a light adds it to the inventory"，AC-2 "A pickup at the
    carry limit is refused"，AC-3 "The picked-up light leaves the world"
  - `TR-light-001`；用户故事引述的是需求的旧措辞，而
    `tr-registry.yaml` 持有当前文本，实现与之一致
  - `ADR: ADR-0003`（Accepted），其指导已被遵循
  - 一个 `## Test Evidence` 小节，点名 `tests/unit/light/pickup_test.gd`，该文件
    存在且每条标准一个测试 —— `test_pickup_adds_to_inventory`、
    `test_pickup_refused_at_limit`、`test_pickup_removes_world_light` —— 因此每条
    标准都映射到一个测试
  - `Status: In Progress`
- `production/session-state/active.md` 中的 `/dev-story` 检查点将该用户故事命名为
  **Current task**，并带有 `Run result: OBSERVED — the light leaves
  the floor and the inventory count rises —
  production/qa/evidence/story-light-pickup/01-pickup.png`；该图像存在
- 用户故事中列出的实现文件在代码根目录中存在
- `production/sprints/` 中的冲刺计划有其他 READY / NOT STARTED 的 Must Have 用户故事

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取用户故事并提取其字段
2. 技能在 `tr-registry.yaml` 中 grep `TR-light-001` 并使用该当前文本
3. 技能映射 ADR 的标题，只读取 `## Decision` 和 `## Consequences`
4. 技能验证每条标准并构建可追溯性表：AC-1..AC-3 各自映射到其测试函数，全部 COVERED
5. 找到测试证据 —— 报告为 "Test file present at `<path>`"（存在性，而非通过
   声明）；检查点的 `Run result: OBSERVED` 连同其保留路径被注明
6. 无偏差
7. Phase 4b 注明 "QL-TEST-COVERAGE skipped — Lean mode."
8. Phase 5（lean）询问 "Code review is skipped in lean mode. Did you run `/code-review` on the implemented files?"
9. 完成报告，结论为 COMPLETE
10. `AskUserQuestion` "Verification complete. How do you want to proceed?"；选择
    "Close the story" 后，文件被更新
11. 技能展示冲刺中的下一个就绪用户故事

**断言：**
- [ ] 需求文本来自 `tr-registry.yaml`，而非用户故事的过时引述 —— 措辞差异不产生偏差
- [ ] 技能只读取 ADR 的 `## Decision` 和 `## Consequences` 片段，而非整个文件
- [ ] 每条标准都列出其状态（`auto-verified` / `confirmed` / `FAILS` / `DEFERRED`），并出现在 Criterion | Test | Status 可追溯性表中
- [ ] 测试证据被报告为存在，但不声称测试通过
- [ ] 在 `lean` 模式下技能询问是否运行过 `/code-review`，并将答案记录在 Completion Notes 的 `Code Review:` 行
- [ ] 可追溯性表将 AC-1..AC-3 各自映射到其测试函数，没有 UNTESTED 行
- [ ] 从检查点读取 `Run result:` 行（其 **Current task** 点名该用户故事），并注明其保留路径
- [ ] 结论为 COMPLETE —— 每条标准都映射到一个测试，运行已被观察并保留，且不存在偏差
- [ ] 在 Phase 7 的 `AskUserQuestion` 之前不编辑任何文件；选择 "Close the story" 后，用户故事获得 `Status: Complete`、一个 `Last Updated:` 日期和一个 `## Completion Notes` 小节
- [ ] 完成后，技能从 `production/sprints/` 展示下一个 READY / NOT STARTED 的 Must Have 或 Should Have 用户故事，并建议 `/story-readiness [path]`

---

### Case 2: 需要人工或试玩测试验证的标准

**测试夹具：**
- 同 Case 1，另加两条标准：
  - (a) "Player sees correct animation on pickup" —— 没有自动化测试；
    动画的一帧保留在 `production/qa/evidence/story-light-pickup/02-pickup-anim.png`
  - (b) "Pickup state persists across a full level run" —— 需要完整的游戏构建
- 5 条标准中有 1 条最终没有覆盖它的测试

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 标准 (a) 是主观/玩法标准 → 技能通过批量 `AskUserQuestion` 询问
   （"Does [criterion]?" —— `Yes — passes` / `No — fails` / `Not tested yet`）
2. 用户回答 `Yes — passes`。保留的帧是证据规则所要求的观察；该答案覆盖了静态图
   无法显示的动作，并计为人工测试
3. 标准 (b) 标记为 `DEFERRED — requires playtest session`，不阻塞
4. 可追溯性表显示 (b) 为 UNTESTED；5 条中有 1 条（≤50%）→ ADVISORY
5. Completion Notes 列出被推迟的条目，以及 "Untested criteria: [AC-N list].
   Recommend adding tests in a follow-up story."

**断言：**
- [ ] 技能就不可验证的标准询问用户，而不是假定其通过，每次调用最多批量 4 个此类问题 —— 行为标准绝不通过阅读代码来标记为已验证
- [ ] 在报告说明 `02-pickup-anim.png` 显示了什么之前，先用 `Read` 打开该图像；检查点的 `Run result:` 文本作为 `/dev-story` 的描述被引用，绝不复述为技能自己的观察
- [ ] 仅需试玩测试的标准标记为 `DEFERRED — requires playtest session`
- [ ] 结论为 COMPLETE WITH NOTES，且报告列出该 DEFERRED 标准 —— 既不是 BLOCKED 也不是 NOT ASSESSED，因为 DEFERRED 标准不阻塞，也不触发 NOT ASSESSED 条件
- [ ] 被推迟的标准在 Completion Notes 的 `Criteria:` 行中被点名，并附带未测试标准的建议
- [ ] 变体 —— 若用户对 (a) 回答 `No — fails`，该标准为 `FAILS`，结论为 BLOCKED，且技能不自行进入 Phase 7
- [ ] 变体 —— 若 `production/qa/evidence/` 下没有为该用户故事保留图像，且检查点没有 `Run result:` 行：用户对 (a) 的 `Yes — passes` 是断言而非证据，因此缺失的观察在 Logic 闸门级别被标记（默认 BLOCKING），且结论为 BLOCKED —— 绝不因该确认而给 COMPLETE WITH NOTES
- [ ] 技能在更新用户故事文件前仍然通过 `AskUserQuestion` 询问

---

### Case 3: 阻塞路径 — 检测到 GDD 偏差

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- 用户故事 TR-ID 在 `tr-registry.yaml` 中的当前文本为："Player can carry max 3 light sources"
- 代码根目录中的实现在玩法代码中有 `MAX_CARRIED_LIGHTS = 5`

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. GDD 规则检查（对照当前注册表文本）发现实现与 "max 3" 矛盾
2. 硬编码值检查也标记了本应放在数据文件中的玩法字面量
3. 该矛盾被分类为 BLOCKING，并引用其 GDD/TR 参考
4. 结论 BLOCKED；技能列出必须修复的内容并提供帮助，且不自行进入 Phase 7
5. 若用户明确要求照旧关闭，Phase 7 菜单会出现（总是询问，即使在自动模式下 —— `scope_changes`）

**断言：**
- [ ] 技能检测到当前需求文本与实现值之间的不匹配
- [ ] 偏差被中性报告为 BLOCKING，并附 GDD/TR 参考 —— 技能不编辑代码或 GDD 来调和它
- [ ] 结论为 BLOCKED，且除非用户明确要求照旧关闭，否则不进入 Phase 7
- [ ] 关闭一个 BLOCKED 用户故事无论自动化模式如何都要经由 Phase 7 的 `AskUserQuestion`
- [ ] 若通过 "Accept deviations as-is and close anyway" 关闭，偏差被记录在 Completion Notes 的 `Deviations:` 行

---

### Case 4: 边界情况 — 无参数，自动检测当前用户故事

**测试夹具：**
- `production/session-state/active.md` 将
  `production/epics/core/story-oxygen-drain.md` 命名为活跃用户故事
- 该用户故事文件存在，`Status: In Progress`

**输入：** `/story-done`（无参数）

**预期行为：**
1. 技能读取 `production/session-state/active.md` 并取活跃用户故事
2. 技能读取该用户故事文件并正常继续
3. 完成报告的 `**Story**:` 行点名自动检测到的路径
4. 若 `active.md` 未点名任何用户故事，技能读取最新的冲刺计划寻找 IN PROGRESS
   用户故事；若有多条，它询问 "Which story are we completing?"；若没有，它请求提供路径

**断言：**
- [ ] 未给出参数时，技能首先读取 `production/session-state/active.md`
- [ ] 报告的 `**Story**:` 行点名自动检测到的用户故事文件
- [ ] 冲刺中有多条进行中的用户故事时，技能通过 `AskUserQuestion` 询问是哪一条，而不是自行挑选
- [ ] 若任何地方都找不到用户故事，技能请用户提供路径

---

### Case 5: 总监闸门 — LP-CODE-REVIEW 在各评审模式下的行为

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full` 和 `qa.level: standard`（这样 QA
  覆盖率闸门不会因 `qa.level: minimal` 被跳过）
- 用户故事文件位于 `production/epics/core/story-light-pickup.md`，`Type: Logic`
- 所有验收标准都验证通过，无 GDD 偏差，实现文件存在，且具备 Case 1 的运行证据
  （`Run result: OBSERVED` 检查点及其保留图像）
- 评审模式来自 `modes.review_mode`（遗留镜像 `production/review-mode.txt`）或 `--review`

**Case 5a — full 模式：** `/story-done production/epics/core/story-light-pickup.md --review full`

**预期行为：**
1. 在 Phase 3–4 之后，技能以闸门 QL-TEST-COVERAGE 启动 `qa-lead`（除非
   `qa.level: minimal` 或为 Config/Data 用户故事）
2. 技能以闸门 LP-CODE-REVIEW 启动 `lead-programmer`，传入实现文件路径、
   用户故事路径、相关 GDD 小节和治理 ADR
3. 结论（APPROVE / CONCERNS / REJECT）呈现给用户
4. CONCERNS → `AskUserQuestion`：`Revise flagged issues` / `Accept and proceed` / `Discuss further`
5. REJECT → 在问题解决前没有 Phase 6 结论
6. NOT ASSESSED（缺少某个闸门输入）→ 技能点名缺失的输入，绝不将其读作 APPROVE：
   提供该输入并重跑闸门，或 Phase 6 结论最多为 NOT ASSESSED

**断言（5a）：**
- [ ] 技能在决定是否启动 LP-CODE-REVIEW 前使用已解析的评审模式
- [ ] LP-CODE-REVIEW 在 full 模式下、实现检查之后启动，并带有四项上下文
- [ ] REJECT 结论阻止用户故事在解决前达到 COMPLETE 结论
- [ ] CONCERNS 结论产生三选项的 `AskUserQuestion`
- [ ] 任一闸门的 NOT ASSESSED 结论绝不被当作 APPROVE / ADEQUATE：除非提供缺失的输入并重跑闸门，否则结论为 NOT ASSESSED，而非 COMPLETE
- [ ] 即使在 APPROVE 之后，技能仍在更新用户故事状态前通过 Phase 7 的 `AskUserQuestion` 询问

**Case 5b — lean 模式：** `--review lean`

**断言（5b）：**
- [ ] LP-CODE-REVIEW 不启动
- [ ] 技能以所列三个选项询问 "Did you run `/code-review` on the implemented files?"；三个选项都继续
- [ ] 注明 "QL-TEST-COVERAGE skipped — Lean mode."

**Case 5c — solo 模式：** `--review solo`

**断言（5c）：**
- [ ] LP-CODE-REVIEW 和 QL-TEST-COVERAGE 都不启动，也不询问代码评审问题
- [ ] 输出注明 "LP-CODE-REVIEW skipped — Solo mode." 和 "QL-TEST-COVERAGE skipped — Solo mode."
- [ ] 技能在将用户故事标记为 Complete 前仍要求 Phase 7 的 `AskUserQuestion`

---

### Case 6: `minimal` 下的 UI 用户故事，无冲刺计划 —— 截图即可关闭

**测试夹具：**
- `project.yaml` 设置 `modes.rigor: minimal`（→ `workflow: minimal`、
  `qa.level: minimal`、`review_mode: solo`）；`production/sprints/` 中没有冲刺
  计划 —— 简报的 build order 就是计划
- `production/epics/mvp/` 有 `story-001-*.md`（`Status: Complete`）、本用户故事
  `story-002-shop-panel.md`（`Status: In Progress`）和 `story-003-*.md`（`Status: Ready`）
- `story-002-shop-panel.md` 有 `Type: UI` 和两条标准："The shop panel shows
  all 6 item slots inside the frame at 1280x720" 和 "Each slot shows its price"
- `production/qa/evidence/story-002-shop-panel/01-shop-open.png` 存在并展示
  两者；检查点带有 `Run result: OBSERVED` 及该路径；没有证据文档，也没有签署

**输入：** `/story-done production/epics/mvp/story-002-shop-panel.md`

**预期行为：**
1. 在 `qa.level: minimal` 下，Logic、Integration 和 Config/Data 证据检查、
   >50% 未测试升级以及 Phase 4b 都被跳过（"QL-TEST-COVERAGE
   skipped — qa.level minimal."）—— 但 UI 截图检查运行
2. 保留的截图满足 UI 闸门；不要求证据文档或签署
3. Phase 4 只运行清单、硬编码值和范围检查（`minimal` 下不做 GDD/ADR
   可追溯性）；Phase 5 注明 "LP-CODE-REVIEW skipped — Solo mode."
4. 结论 COMPLETE；在 Phase 7 批准后，用户故事被标记为 Complete
5. Phase 8 走无冲刺分支：它在用户故事文件写入后运行
   `bash .claude/scripts/story-status.sh`；`story-003` 在其第一行 `TODO` 上 →
   "Run `/dev-story [path]`"

**断言：**
- [ ] UI 截图检查在 `qa.level: minimal` 下运行，且仅凭保留的图像即满足 —— UI 用户故事不要求证据文档或签署
- [ ] 结论为 COMPLETE，不会因缺少签署而 BLOCKED
- [ ] Phase 8 点名 `story-003` 并直接推荐 `/dev-story` —— `minimal` 下没有 `/story-readiness` 行，也没有 Sprint Close-Out Sequence
- [ ] 下一个用户故事来自 `bash .claude/scripts/story-status.sh`，且在本用户故事的 `Status: Complete` 写入之后运行 —— 不是来自对某个史诗文件夹的 grep
- [ ] 变体 —— `production/epics/combat/story-001-arena.md` 写着 `**Status:** In Review`：它是 Next Up（脚本在每个史诗文件夹中首先列出 `IN_REVIEW`），且 Next Up 行推荐用 `/story-done [path]` 关闭它，而不是 `/dev-story`
- [ ] 变体 —— `production/qa/evidence/` 下没有图像也没有 `Run result:` 行：在 `qa.level: minimal` 下 UI 闸门仍然是 BLOCKING，因此结论为 BLOCKED
- [ ] 变体 —— `story-003` 为 `Blocked`，点名其阻塞项，且没有其他未完成的用户故事：Phase 8 不打印 Next Up，点名 `story-003` 及其阻塞项，建议清除它，且绝不说 build order 已完成

---

### Case 7: NOT ASSESSED — 无人可评估的标准

**测试夹具：**
- 同 Case 1，另加第四条标准 AC-4："The pickup code is robust" —— 它没有
  点名任何可观察的结果，因此没有测试、运行或试玩测试能判定它

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. AC-1..AC-3 如 Case 1 一样验证
2. AC-4 完全无法评估 —— 不是 DEFERRED（没有会话能按所写判定它），也不是失败
3. 结论 NOT ASSESSED，点名 AC-4 以及什么能使其可检查（将其改写为可观察的条件）
4. 技能不自行进入 Phase 7

**断言：**
- [ ] 结论为 NOT ASSESSED —— 不是 COMPLETE 或 COMPLETE WITH NOTES，也不是 BLOCKED（没有任何已知失败）
- [ ] 输出点名 AC-4、为何无法评估，以及什么能使其可检查
- [ ] 只有当用户明确要求照旧关闭时才进入 Phase 7；此时它总是提示（`scope_changes`），且 Completion Notes 记录 AC-4 从未被评估
- [ ] 变体 —— AC-4 是一条可检查的标准，用户回答 `Not tested yet`：它在可追溯性表中为 UNTESTED，且结论为 NOT ASSESSED，点名什么能判定它
- [ ] 变体 —— 另一条标准也 FAILS：结论为 BLOCKED（BLOCKED 在 NOT ASSESSED 之前评估）

---

### Case 8: 参考文件只在需要它的分支上读取

**测试夹具：**
- 同 Case 1（`modes.rigor: standard`，因此 `review_mode: lean`；`engine.name: Godot`；
  带三条已覆盖标准的 Logic 用户故事及其保留的运行证据），没有冲刺计划，也没有
  `production/sprint-status.yaml`
- 技能文件夹含有 `references/review-gates.md`、`references/sprint-next.md` 和
  `references/tech-debt-row.md`
- 变体：`modes.review_mode: full`，一个在本用户故事之后还列有另一个用户故事的
  冲刺计划，以及一个建议性偏差（Case 3 的夹具，降级为建议性）

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 主路径在 `SKILL.md` 中。在 `lean` 下、没有冲刺计划且没有建议性偏差时，
   三个参考文件都不适用，运行不读取其中任何一个
2. Phase 6 询问 lean 的 `/code-review` 问题，而不加载 `references/review-gates.md`
3. 变体：在 `full` 下，运行在 Phase 6 读取 `references/review-gates.md`，在任一
   闸门代理启动前；选择 "Close and log as tech debt" 时，它在写入该行前读取
   `references/tech-debt-row.md`；有冲刺计划时，它在 Phase 8 读取
   `references/sprint-next.md`，在点名 Next Up 之前

**断言：**
- [ ] Lean、无冲刺计划：记录显示未读取任何 `references/*.md` 文件
- [ ] 变体：每个参考文件都在其承载的步骤开始前读取，绝不在运行开始时读取
- [ ] 已解析的设置（`review_mode`、`workflow`、`qa.level`、`automation`）仍支配每个步骤：lean 仍询问 `/code-review` 问题，Phase 7 仍在编辑用户故事文件前询问

---

## Protocol Compliance

- [ ] 只在需要它的分支上读取 `references/*.md` 文件，且在该分支步骤开始前
- [ ] 在更新用户故事文件前通过 `AskUserQuestion` 询问
- [ ] 只在用户选择 "Close and log advisory deviations as tech debt" 时才向 `docs/tech-debt-register.md` 追加内容，作为 `/tech-debt` 注册表表格的行并带 `Added` 日期 —— 绝不用自由散列条目
- [ ] 在询问前展示完整报告（标准、可追溯性、测试证据、偏差、范围）
- [ ] 以展示下一个就绪用户故事（冲刺计划）或史诗文件夹中的下一个用户故事（无冲刺计划）结尾
- [ ] 绝不自行关闭 BLOCKED 或 NOT ASSESSED 的用户故事 —— 只在用户的明确请求下，经由 Phase 7
- [ ] 绝不静默跳过代码评审：`full` 启动 LP-CODE-REVIEW，`lean` 询问，`solo` 注明跳过

---

## Coverage Notes

- 技能的完整 8 阶段流程在 Case 1-3 中演练；各阶段内的所有边界情况并非都
  被覆盖。
- 技术债记录（`docs/tech-debt-register.md`）只通过 Phase 7 选项和 Protocol
  Compliance 中的行格式说明覆盖；没有用例写入一行。
- `production/sprint-status.yaml` 更新和会话状态检查点（二者都在 Phase 7 批准后
  静默进行）不是主要断言。
- Case 6 覆盖 `minimal` 下的无冲刺计划分支；Sprint Close-Out Sequence 未在此测试。
- 带多个 TR-ID 或多个 ADR 的用户故事未显式测试。
