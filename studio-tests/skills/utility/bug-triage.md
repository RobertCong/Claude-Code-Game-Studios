# Skill Test Spec: /bug-triage

## Skill Summary

`/bug-triage` 将未解决的缺陷积压转化为按优先级排序、分配到冲刺的行动清单，并在 "May I write" 询问之后写入 `production/qa/bug-triage-[date].md`。它运行在 Sonnet 模型上。模式：`sprint`（将可修复的缺陷分配到当前冲刺，其余延后）、`full`（P1 → 当前冲刺，P2 → 下一冲刺，P3+ → 积压）、`trend`（仅趋势分析，不分配，仅依据头部字段）；无参数时若有冲刺文件则运行 `sprint`，否则运行 `full`。

缺陷在 `production/qa/bugs/*.md` 中发现，回退到 `production/qa/bugs.md`，再回退到 `production/qa/qa-plan-*.md` 的 "Bugs Found" 表格。每个缺陷获得一个 **severity**（S1 Critical – S4 Low，影响）和一个 **priority**（P1 Fix this sprint – P4 Won't fix / Deferred，紧迫度）——两个独立维度，因此报告按优先级而非严重程度对缺陷分组。偏差检查会标记系统性问题（一个冲刺内同一系统出现 3+ 个缺陷；同一用户故事出现 2+ 个 S1/S2；针对 Complete 用户故事提交的缺陷）。报告写入后结论为 `COMPLETE`，没有可分类的缺陷文件时结论为 `COMPLETE` 且不生成报告，用户拒绝写入时结论为 `BLOCKED`。在 `workflow: minimal` 下按设计没有冲刺：没有冲刺文件时技能会说明这一点，并将 P1 缺陷列为下一批修复项，优先于简报构建顺序中的下一个用户故事。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 在写入 `production/qa/bug-triage-[date].md` 前包含 "May I write" 用语
- [ ] 具备下一步交接（未分配的 S1 用 `/sprint-status`；回归修复后用 `/smoke-check`）

---

## Director Gate Checks

无。`/bug-triage` 是一个运维分类技能。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 冲刺模式，5 个缺陷按优先级分组

**Fixture:**
- `production/sprints/sprint-004.md` 是最新的冲刺文件，并注明有余量产能
- `production/qa/bugs/` 包含 5 个缺陷文件：
  - `BUG-0001.md` — S1、P1、Audio
  - `BUG-0002.md` — S2、P1、Combat
  - `BUG-0003.md` — S3、P2、UI
  - `BUG-0004.md` — S2、P2、VFX
  - `BUG-0005.md` — S4、P3、Tutorial

**Input:** `/bug-triage`

**Expected behavior:**
1. 无参数且存在冲刺文件 → `sprint` 模式
2. 读取 5 个缺陷文件和最新的冲刺文件
3. 分别分类严重程度和优先级；P1 缺陷被分配到 sprint 4
4. 报告包含 Triage Summary 表（P1：2，P2：2，P3：1，P4：0）、
   "Critical (S1/S2) unfixed count: 3"，以及独立的 P1、P2 和 P3/P4 表格
5. 展示报告并询问 "May I write this triage report to `production/qa/bug-triage-[date].md`?"
6. 仅在批准后写入

**Assertions:**
- [ ] 模式报告为 `sprint`
- [ ] BUG-0001 和 BUG-0002 位于 "P1 Bugs — Fix This Sprint" 表中，并分配到当前冲刺
- [ ] BUG-0003 和 BUG-0004 位于 P2 表；BUG-0005 位于 P3/P4 表
- [ ] Triage Summary 计数和 S1/S2 未修复数（3）正确
- [ ] "May I write" 指明 `production/qa/bug-triage-[date].md`，且批准前不写入任何内容

---

### Case 2: 未找到缺陷文件 — 停止且不生成报告

**Fixture:**
- `production/qa/bugs/` 不存在
- 没有 `production/qa/bugs.md`，也没有 `production/qa/qa-plan-*.md`

**Input:** `/bug-triage`

**Expected behavior:**
1. Step 2a 在其三个位置中都找不到缺陷来源
2. 技能说明："No bug files found in `production/qa/bugs/`. If bugs are tracked in a
   different location, adjust the glob pattern. If no bugs exist yet, there is nothing to triage."
3. 技能停止——不分类、不生成分类报告、不写入——并以
   `Verdict: COMPLETE — no bug files in production/qa/bugs/; nothing to triage.` 结束

**Assertions:**
- [ ] 输出说明在 `production/qa/bugs/` 中未找到缺陷文件
- [ ] 技能优雅停止，而不是报错
- [ ] 不生成任何分类表格
- [ ] 不询问 "May I write"，也不写入文件
- [ ] 停止时仍以结论结束：Verdict: COMPLETE — no bug files, nothing to triage

---

### Case 3: 系统性问题 — 偏差检查标记热点和回归

**Fixture:**
- `production/sprints/sprint-004.md` 存在
- `production/qa/bugs/` 有 4 个缺陷：3 个属于 Inventory 系统且在本冲刺提交，
  另有 1 个针对 `production/epics/core/story-003.md`，其 `Status: Complete`
- 用户在收到询问时批准写入

**Input:** `/bug-triage sprint`

**Expected behavior:**
1. 分类全部 4 个缺陷
2. "Systemic Issues Flagged" 列出 "Potential design or implementation quality issue in Inventory"
3. 它还标记 "Regression in completed story — story should be re-opened in sprint tracking"
4. Trend Analysis 将 Inventory 列为热点，并统计到 1 次回归
5. 询问 "May I write this triage report to `production/qa/bug-triage-[date].md`?"；
   用户批准后写入报告
6. 写入后，技能补充："Regressions found — consider re-opening the affected
   stories in sprint tracking and running `/smoke-check` to re-gate." 结论：COMPLETE

**Assertions:**
- [ ] Inventory 被标记为潜在质量问题（同一系统 3+ 个缺陷）
- [ ] 针对 Complete 用户故事的缺陷被标记为回归
- [ ] Trend Analysis 显示 Inventory 为热点，并显示 "Regressions: 1"
- [ ] 仅在 "May I write" 询问获批后才写入报告
- [ ] 写入后的消息建议使用 `/smoke-check`，结论为 COMPLETE

---

### Case 4: 冲刺产能已满 — 标记溢出，询问 Won't Fix，拒绝写入

**Fixture:**
- `production/sprints/sprint-004.md` 注明冲刺产能已满
- `production/qa/bugs/` 有一个 S2/P1 缺陷和一个被判为 P4 的 S4 缺陷（外观问题，超出范围）

**Input:** `/bug-triage sprint`

**Expected behavior:**
1. P1 缺陷不会被自动分配到已满的冲刺；它被标记为
   `Priority overflow — consider pulling from sprint`
2. S4 缺陷作为 P4 候选被提出，并询问 "Are these acceptable as Won't Fix?"
   ——在用户回答之前不会被标记为 Won't Fix
3. 用户拒绝写入报告
4. 结论为 BLOCKED——用户拒绝写入；不创建文件

**Assertions:**
- [ ] P1 缺陷带有 `Priority overflow` 标记，而不是冲刺分配
- [ ] 在任何缺陷被处置为 P4 之前询问 Won't Fix 问题
- [ ] 写入被拒绝时结论为 BLOCKED
- [ ] 不写入 `production/qa/bug-triage-[date].md`

---

### Case 5: 总监闸门检查 — Full 模式，无 P1 缺陷

**Fixture:**
- `modes.workflow: standard`（固定：未设置时会解析为 minimal，按设计没有冲刺）
- `production/sprints/` 中没有冲刺文件
- `production/qa/bugs/` 有两个缺陷，S3/P3 和 S4/P3

**Input:** `/bug-triage full`

**Expected behavior:**
1. 说明 "No sprint plan found — assigning to backlog only."
2. 两个缺陷都进入积压（P3+）
3. 在 "May I write" 批准后写入报告
4. 没有 P1 缺陷："No P1 bugs — build is in good shape for QA hand-off." 结论：COMPLETE
5. 不生成任何总监代理；不出现闸门 ID

**Assertions:**
- [ ] 说明 "No sprint plan found — assigning to backlog only."
- [ ] 两个缺陷都被处置为 Backlog
- [ ] 出现 "No P1 bugs — build is in good shape for QA hand-off."，结论为 COMPLETE
- [ ] 未调用任何总监闸门，也不出现闸门跳过消息

---

### Case 6: 最小工作流 — 按设计没有冲刺，P1 缺陷优先于简报中的下一个用户故事

**Fixture:**
- `project.yaml`：`modes.workflow: minimal`（固定：本用例测试 `minimal`
  措辞，与 Case 5 相反）
- 没有 `production/sprints/` 目录
- `design/game-brief.md` 列出三个功能的构建顺序；下一个未构建的是
  "Inventory screen"
- `production/qa/bugs/` 包含 BUG-0001（S1、P1、Audio）、BUG-0002（S3、P1、UI）和
  BUG-0003（S4、P3、Tutorial）

**Input:** `/bug-triage`（无参数；无冲刺文件，因此为 `full` 模式）

**Expected behavior:**
1. 不存在冲刺文件，因此运行 `full` 模式
2. Step 2b 说明在 `workflow: minimal` 下按设计没有冲刺——它不会
   打印 "No sprint plan found — assigning to backlog only."
3. 两个 P1 缺陷被列为下一批修复项，优先于简报构建顺序中的
   下一个用户故事（"Inventory screen"）
4. BUG-0003 进入积压；没有缺陷获得 `Sprint:` 分配
5. 在 "May I write this triage report to
   `production/qa/bug-triage-[date].md`?" 之后写入报告；结论：COMPLETE

**Assertions:**
- [ ] 无冲刺说明指出在 `workflow: minimal` 下没有冲刺，且不出现 "No sprint plan found — assigning to backlog only." 措辞
- [ ] BUG-0001 和 BUG-0002 被列为下一批修复项，位于简报构建顺序的下一个用户故事之前
- [ ] 没有缺陷被分配到冲刺，也没有缺陷被标记为 `Priority overflow`
- [ ] 仅在 "May I write" 询问后写入报告，结论为 COMPLETE

---

## Protocol Compliance

- [ ] 先在 `production/qa/bugs/*.md` 中发现缺陷，再使用回退位置
- [ ] 将严重程度（S1–S4）和优先级（P1–P4）保持为独立的分类
- [ ] 绝不在产能已满时自动分配到冲刺
- [ ] 绝不未经询问用户就将缺陷标记为 Won't Fix
- [ ] 在写入分类报告前询问 "May I write"
- [ ] 写入后（或没有可分类的缺陷文件时）结论为 COMPLETE，写入被拒绝时为 BLOCKED

---

## Coverage Notes

- `trend` 模式（仅 grep 头部字段，不读取缺陷正文，不分配）未单独测试。
- 合并形式 `production/qa/bugs.md` 和 `qa-plan-*.md` 的回退未单独测试。
- "同一用户故事 2+ 个 S1/S2 缺陷" 偏差标记和缺陷老化警告（>2 个冲刺）未单独测试。
