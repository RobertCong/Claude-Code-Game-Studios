# Skill Test Spec: /sprint-status

## Skill Summary

`/sprint-status` 是一个 Haiku 档的只读技能，用于产出简洁的冲刺快照。它使用由其参数指名的冲刺，或 `production/sprints/` 中最近修改的文件，并读取 `production/sprint-status.yaml` 作为用户故事状态的事实来源（当 yaml 缺失时回退到 markdown 扫描并给出警告）。它 grep 用户故事文件的 `Last Updated` 字段，并在某个 In Progress 用户故事的日期超过 4 天时将其标记为 STALE。燃尽结论为 On Track / At Risk / Behind，由完成百分比相对于已消耗时间百分比推导而来，任何 STALE 用户故事会把它至少升级为 At Risk。快速升级标记置于输出顶部：SPRINT AT RISK 严重标记、Must Haves 完成标记以及缺失用户故事标记。当不存在任何冲刺文件时，它在 `standard`/`full` 工作流下指向 `/sprint-plan new`，并在 `minimal` 下报告构建顺序进度——此时，如果每个未完成的用户故事都是 Blocked、Draft 或无状态，它会指名它们（每个受阻的附上其阻塞项）并且绝不报告构建顺序已完成。它从不写入文件，不调用任何总监闸门，且最多给出一条建议。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具备 ≥2 个 phase 标题或编号检查小节
- [ ] 包含燃尽结论关键词：On Track、At Risk、Behind
- [ ] 不要求 "May I write" 措辞（只读技能）
- [ ] 具有下一步交接（Recommendation 小节）

---

## Director Gate Checks

无。`/sprint-status` 是一个只读报告技能，不调用任何闸门。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 混合冲刺，因 Must Have 受阻而为 At Risk

**Fixture:**
- `production/sprints/sprint-004.md` 是最近修改的冲刺文件
- `production/sprint-status.yaml` 覆盖冲刺 4：它于 13 天前开始，并于今天起 7 天后结束（已消耗 65% 时间）
- yaml 列出 6 个用户故事：
  - 3 个为 `status: done`
  - 2 个为 `status: in-progress`，均在最近 2 天内更新
  - 1 个为 `status: blocked`，`priority: must-have`，
    `blocker: "Waiting on physics ADR acceptance"`

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能选择 `sprint-004.md` 并读取 `production/sprint-status.yaml`
2. 技能计算已消耗 65% 时间、3/6 = 50% 完成——落后 15 个百分点
3. 在剩余 35% 冲刺时间（低于 40%）时存在受阻的 Must Have，触发顶部严重标记：“SPRINT AT RISK: … Recommend replanning with `/sprint-plan update`.”
4. 技能输出状态表，blocker 置于 Blocker 列，燃尽结论为 At Risk

**Assertions:**
- [ ] 输出包含“Progress: 3/6 tasks (50%)”，以及列出全部 6 个用户故事的状态表
- [ ] 受阻用户故事在 Blocker 列中被指名，并附“Waiting on physics ADR acceptance”
- [ ] 燃尽为 At Risk（50% 完成 vs 65% 时间已消耗——落后 15 个百分点）
- [ ] SPRINT AT RISK 严重标记出现在顶部，并推荐 `/sprint-plan update`
- [ ] 技能不写入任何文件

---

### Case 2: 全部用户故事完成 —— On Track 并带完成标记

**Fixture:**
- `production/sprints/sprint-004.md` 是最近修改的冲刺文件
- `production/sprint-status.yaml` 覆盖冲刺 4：它于 5 天前开始，并于今天起 5 天后结束（已消耗 50% 时间）
- 全部 5 个用户故事为 `status: done`（3 个 `must-have`，2 个 `should-have`）

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能读取 yaml——5/5 完成
2. 100% 完成相对于 50% 时间已消耗 → On Track
3. 完成标记出现在顶部：“All Must Haves complete. Team can pull from Should Have backlog.”
4. Must-Haves at Risk 读作“None.”；省略 Attention Needed 小节
5. 技能以一条建议结束

**Assertions:**
- [ ] 燃尽为 On Track
- [ ] 完成标记“All Must Haves complete. Team can pull from Should Have backlog.”出现在顶部
- [ ] 输出显示“Progress: 5/5 tasks (100%)”
- [ ] 输出最多给出一条建议（或“Sprint is on track — no action needed.”）
- [ ] 不写入任何文件

---

### Case 3: 无冲刺文件 —— 指引运行 /sprint-plan

**Fixture:**
- `production/sprints/` 目录不存在
- `project.yaml` 设置 `modes.workflow: standard`

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能找不到任何冲刺文件
2. 在 `standard` 工作流下，技能报告：“No sprint files found. Start a sprint with `/sprint-plan new`.”
3. 技能停止

**Assertions:**
- [ ] 不存在冲刺文件时技能不报错也不崩溃
- [ ] 输出说明“No sprint files found”并推荐 `/sprint-plan new`
- [ ] 技能就此停止——不输出燃尽结论，也不输出状态表
- [ ] 在 `standard` 下不使用 `workflow: minimal` 的构建顺序报告

---

### Case 4: 边界情况 —— 陈旧的 In Progress 用户故事（已标记）

**Fixture:**
- `production/sprints/sprint-004.md` 是最近修改的冲刺文件
- `production/sprint-status.yaml` 覆盖冲刺 4：10 天冲刺，已过 5 天（已消耗 50% 时间）；4 个用户故事——2 个 `done`，2 个 `in-progress`（50% 完成）
- `production/epics/combat/story-003-dash.md`（进行中）带有 `> **Last Updated**: [6 days before today]`
- `production/epics/combat/story-004-parry.md`（进行中）带有 `> **Last Updated**: [3 days before today]`
- 没有用户故事为 Blocked

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能通过一次 grep 在 `production/epics/**/story-*.md` 中解析 `Last Updated` 字段来确定日期
2. story-003 已 6 天——超过 4 天阈值——被标记 STALE；story-004（3 天）不标记
3. Attention Needed 表列出 story-003，含其 Last Updated 日期、Days Stale 和 STALE 注记
4. 仅凭百分比本应为 On Track 的燃尽被升级为 At Risk，原因“At Risk — 1 stale story(ies): …”指名 story-003 及其自身年龄 6 天

**Assertions:**
- [ ] 日期通过一次 grep 从用户故事文件的 `Last Updated` 字段获取，而非来自 `active.md` 或逐个用户故事读取
- [ ] story-003（6 天）在 Attention Needed 中按名标记为 STALE；story-004（3 天）不标记
- [ ] 尽管 50% 完成相对于 50% 时间已消耗，燃尽仍为 At Risk，且升级原因把陈旧数（1）和 story-003 自身年龄（6 天）作为两个独立数字给出
- [ ] 输出不把“陈旧”与“Blocked”混为一谈——story-003 保持其 IN PROGRESS 状态并附带 STALE 注记

---

### Case 5: 闸门合规 —— 只读；不调用闸门

**Fixture:**
- `production/sprints/sprint-004.md` 存在，且 `production/sprint-status.yaml` 列出 4 个用户故事（2 个 `done`，2 个 `in-progress`）并带冲刺日期
- `project.yaml` 设置 `modes.review_mode: full`

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能读取冲刺并产出状态快照
2. 无论评审模式如何，技能都不调用任何总监闸门
3. 输出是带燃尽结论（On Track、At Risk 或 Behind）的普通状态报告
4. 技能不提示用户批准，也不请求写入任何文件

**Assertions:**
- [ ] 在任何评审模式下都不调用总监闸门
- [ ] 输出不含任何“May I write”提示
- [ ] 技能完成并返回燃尽结论，无需用户交互
- [ ] `review_mode` 不在技能解析的键之列（它解析 `story_granularity` 和 `workflow`）

---

### Case 6: 默认最小工作流 —— 构建顺序进度，无冲刺文件

**Fixture:**
- `production/sprints/` 不存在
- `project.yaml` 既未设置 `modes.rigor` 也未设置 `modes.workflow`，因此注入块读作 `workflow: minimal (rigor:minimal)`
- 注入的 `story-status.sh` 列表为：
  ```
  IN_REVIEW    production/epics/core/story-003-dash.md
  IN_PROGRESS  production/epics/core/story-002-jump.md
  TODO         production/epics/core/story-004-parry.md  (Ready)
  COMPLETE     1 of 4
  ```

**Input:** `/sprint-status`

**Expected behavior:**
1. 技能找不到冲刺文件；在 `workflow: minimal` 下它报告构建顺序进度，而非指向 `/sprint-plan`
2. 技能输出“Build order: 1 of 4 stories complete”
3. Next 为 story-003（In Review），即第一行——优先于在文件顺序中更靠前的 story-002；技能推荐 `/story-done production/epics/core/story-003-dash.md`
4. 技能停止——无燃尽结论、无状态表、无写入

**Assertions:**
- [ ] 输出不说“No sprint files found”，也不推荐 `/sprint-plan new`
- [ ] 输出显示“Build order: 1 of 4 stories complete”——`In Review` 用户故事不计为完成
- [ ] Next 为 story-003，即列表第一行，附带 `/story-done` 及其路径——用户故事文件未被重新排序为文件顺序
- [ ] 不输出燃尽结论，也不写入任何文件

---

### Case 7: 最小工作流 —— 每个未完成用户故事都是 Blocked 或 Draft

**Fixture:**
- `production/sprints/` 不存在；注入块读作 `workflow: minimal (rigor:minimal)`
- 注入的 `story-status.sh` 列表为：
  ```
  BLOCKED      production/epics/core/story-003-dash.md  (Blocked)
  OTHER        production/epics/core/story-004-parry.md  (Draft)
  COMPLETE     2 of 4
  ```
- story-003 的文件带有注记 `BLOCKED: waiting on the dash animation`

**Input:** `/sprint-status`

**Expected behavior:**
1. 没有 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO` 行，且 4 个用户故事中 2 个已完成，因此没有 Next，构建顺序也未完成
2. 技能输出“Build order: 2 of 4 stories complete”
3. 技能指名 story-003 及其阻塞项，以及 story-004 及其状态 `Draft`
4. 技能给出一条建议——清除 story-003 的阻塞项——然后停止

**Assertions:**
- [ ] 输出绝不声称构建顺序已完成——没有“Build order done”行，也不做三选一
- [ ] 没有任何用户故事被呈现为 Next——既非 Blocked 的 story-003，也非 Draft 的 story-004
- [ ] story-003 被指名并附其阻塞项“waiting on the dash animation”，取自其 `BLOCKED:` 注记
- [ ] story-004 被指名并附其原样状态 `Draft`
- [ ] 输出恰好给出一条建议，且不写入任何文件

---

## Protocol Compliance

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在燃尽结论之前展示用户故事状态表
- [ ] 不请求批准
- [ ] 以最多一条推荐的下一步结束
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）

---

## Coverage Notes

- 在 `workflow: minimal` 下，全 Complete（“Build order done”）和 `STORIES none` 分支未测试。
- `production/sprint-status.yaml` 缺失时的 markdown 回退（及其“No `sprint-status.yaml` found”警告）未测试。
- 没有日期的冲刺（“burndown assessment skipped”）未测试。
- 通过参数选择特定冲刺（`/sprint-status 3`）未测试；上述用例使用最近修改的冲刺文件。
