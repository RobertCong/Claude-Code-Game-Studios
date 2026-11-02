# Skill Test Spec: /tech-debt

## Skill Summary

`/tech-debt` 通过四个子命令跟踪技术债：`scan`、`add`、
`prioritize` 与 `report`。无子命令时它打印用法并以
Verdict FAIL 停止。`scan` 搜索代码根（按引擎解析：`src/`、
`Assets/` 或 `Source/`）中的 `TODO`、`FIXME`、`HACK` 与 `@deprecated` 标记、
重复块、超过 500 行的文件与超过 50 行的函数，将
发现项归入六个债务类别，说明覆盖了多少文件，并在追加
（绝不覆盖）条目前询问
"May I write these findings to `docs/tech-debt-register.md`?"——更新匹配的 `Open` 行，并将
模式已消失的 `Open` 行提议为 `Resolved [date]`。新行遵循
技能的 Debt Register Format（下一个 `TD-NNN`、十列、一个 `Added` 日期）。
对零个源文件的扫描为 `NOT ASSESSED — no source files to scan`，
代码根未解析为 `NOT ASSESSED — code root unresolved`，两者都不写入
任何内容。`add` 通过提示与三个 `AskUserQuestion` 选择收集
条目，然后询问 "May I append
this entry to `docs/tech-debt-register.md`?"。`prioritize` 根据每个注册表
条目的 Impact 与 Effort 列将其评分为 `impact ÷ effort`，重新排序
并在写回前询问；它推荐下个冲刺要做什么，或在
`workflow: minimal`（无冲刺）时推荐接下来构建什么，收尾的下一步
将高优先级项送往 `/sprint-plan` 或简报的构建顺序。技能
解析 `automation` 与 `workflow`。`report` 为只读。不调用任何总监闸门。
结论：COMPLETE、BLOCKED（用户拒绝写入）、FAIL（缺少
子命令）、NOT ASSESSED。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED、FAIL、NOT ASSESSED
- [ ] 包含 "May I write" 措辞（写入 `docs/tech-debt-register.md`）
- [ ] 有下一步交接（Phase 3：`/sprint-plan`、`/tech-debt report`）

---

## Director Gate Checks

无。技术债跟踪是内部代码库分析技能；不调用任何
闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 扫描将新发现项追加到现有注册表

**Fixture:**
- `project.yaml`：`engine.name: godot`；`modes.automation` 未设置（collaborative）
- `docs/tech-debt-register.md` 采用技能的 Debt Register Format，并有 2 个 `Open` 行：
  - TD-001 — Code Quality，Files `src/core/save_system.gd`：针对存档路径 bug 的 `# HACK` 变通。该 `HACK` 注释已不在文件中
  - TD-002 — Code Quality，Files `src/gameplay/combat.gd`：该文件中的 `# TODO` 注释
- `src/gameplay/combat.gd` 有 2 条 `# TODO` 注释与 1 条 `# FIXME` 注释
- `src/ui/hud.gd` 有 620 行；`src/` 中共有 12 个源文件

**Input:** `/tech-debt scan`

**Expected behavior:**
1. 技能将代码根解析为 `src/` 并扫描债务指标
2. 发现项包括 2 个 TODO、FIXME（视为伪装成债务的 bug）以及 `hud.gd` 作为超过 500 行的文件
3. 每个发现项被归入六个类别之一（Architecture、Code Quality、Test、Documentation、Dependency、Performance）
4. 输出说明分母——扫描了 12 个源文件
5. 与注册表匹配：2 个 TODO 与 TD-002 的文件和类型相同，因此更新 TD-002；TD-001 的 `HACK` 已消失，因此 TD-001 被提议为 `Resolved [date]`；FIXME 与 `hud.gd` 成为新行 TD-003 与 TD-004
6. 技能展示发现项与 TD-001 的解决，然后询问 "May I write these findings to `docs/tech-debt-register.md`?"——一次批准覆盖两者
7. 获得批准后，TD-001 的 Status 变为 `Resolved YYYY-MM-DD` 且该行保留；TD-002 被更新；TD-003 与 TD-004 以全部十列追加，Status 为 `Open`，`Added` 设为今天（`YYYY-MM-DD`），Priority 为 `—`
8. 结论：**COMPLETE** — scan findings written to register

**Assertions:**
- [ ] 扫描覆盖解析后的代码根 `src/`，检查 TODO、FIXME、HACK、`@deprecated`、超过 500 行的文件与超过 50 行的函数
- [ ] 每个发现项被归入六个债务类别之一
- [ ] 扫描的文件数量与发现项一同说明
- [ ] "May I write" 指明 `docs/tech-debt-register.md`，且在展示发现项之后出现
- [ ] 两个 TODO 发现项更新 TD-002，而不是添加重复行
- [ ] TD-001 在同一次批准内被提议为 `Resolved [date]`，并保留在注册表中而非删除
- [ ] 新行取接下来的 ID（TD-003、TD-004）并带有 `Added` 日期；注册表就地更新，绝不整体替换
- [ ] 结论为 COMPLETE

---

### Case 2: No Subcommand — 用法与 FAIL

**Fixture:**
- `docs/tech-debt-register.md` 存在
- `src/` 包含带 TODO 注释的源文件

**Input:** `/tech-debt`

**Expected behavior:**
1. Phase 1 未找到子命令
2. 技能输出列出 `scan`、`add`、`prioritize` 与 `report` 的用法
3. 技能停止——不运行扫描，也不读取或写入注册表
4. 结论：**FAIL** — missing required subcommand

**Assertions:**
- [ ] 用法列出四个子命令
- [ ] 不执行扫描，也不写入任何文件
- [ ] 结论为 FAIL，说明缺少子命令

---

### Case 3: Empty Code Root — NOT ASSESSED，而非干净扫描

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `src/` 存在但不含源文件
- `docs/tech-debt-register.md` 存在，含 3 个条目

**Input:** `/tech-debt scan`

**Expected behavior:**
1. 技能将代码根解析为 `src/` 并统计扫描覆盖的文件数：零
2. 技能报告 **NOT ASSESSED — no source files to scan**，解释 "no debt indicators found" 描述的是空搜索，而不是代码库
3. 技能停止：没有 "May I write" 提示、不写注册表、无 COMPLETE 结论

**Assertions:**
- [ ] 零文件扫描被报告为 NOT ASSESSED — no source files to scan
- [ ] 输出不声称 "no debt found" 或代码库干净
- [ ] 不写入注册表，也不提供写入
- [ ] 不发出 COMPLETE 结论

---

### Case 3b: Code Root Unresolved — NOT ASSESSED，不凭猜测扫描任何内容

**Fixture:**
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md` 显示 `[TO BE CONFIGURED]`
- `src/` 与 `Source/` 都存在且包含源文件，因此目录树无法决定根
- `docs/tech-debt-register.md` 存在，含 3 个条目

**Input:** `/tech-debt scan`

**Expected behavior:**
1. 无法按 `.claude/docs/code-root-resolution.md` 解析代码根
2. 技能报告 `NOT ASSESSED — code root unresolved` 并停止
3. 两个目录都不凭猜测扫描；没有 "May I write" 提示、不写注册表、无 COMPLETE 结论

**Assertions:**
- [ ] 结论为 `NOT ASSESSED — code root unresolved`
- [ ] 不从猜测的根报告任何债务发现项
- [ ] 不写入注册表，也不提供写入

---

### Case 4: Add Mode — 用户拒绝写入

**Fixture:**
- `docs/tech-debt-register.md` 存在，含 4 个条目
- `modes.automation` 未设置（collaborative）

**Input:** `/tech-debt add`

**Expected behavior:**
1. 技能以纯文本询问描述与受影响文件
2. 技能使用 `AskUserQuestion` 收集类别——六个选项，从 Architecture 到 Performance
3. 技能使用 `AskUserQuestion` 收集修复工作量——S、M、L、XL
4. 技能使用 `AskUserQuestion` 收集若不修复的影响——Low、Med、High、Critical
5. 技能展示完整的新条目
6. 技能询问 "May I append this entry to `docs/tech-debt-register.md`?"
7. 用户拒绝——不写入任何内容
8. 结论：**BLOCKED** — user declined write

**Assertions:**
- [ ] 类别通过 `AskUserQuestion` 收集，提供六个债务类别
- [ ] 工作量通过 `AskUserQuestion` 收集，提供 S / M / L / XL
- [ ] 影响通过 `AskUserQuestion` 收集，提供 Low / Med / High / Critical，以便 `prioritize` 可为该行评分
- [ ] 在追加提示之前展示完整条目
- [ ] 拒绝时注册表不变，结论为 BLOCKED

---

### Case 4a: Add Mode — 匹配现有 Open 条目

**Fixture:**
- `docs/tech-debt-register.md` 存在，且有一条 `Open` 条目与用户即将添加的条目
  文件相同、类别相同

**Input:** `/tech-debt add`

**Expected behavior:**
1. Case 4 的步骤 1–5 照常运行
2. **追加前先匹配：**在追加询问之前，技能展示
   现有 `Open` 条目（文件与类别相同），并询问是否改为更新它
   而不是添加重复条目
3. 选择 "update" 时，匹配的条目就地更新——不添加重复行
4. 选择 "add anyway"（用户拒绝更新）时，技能仍询问
   "May I append this entry to `docs/tech-debt-register.md`?"，回答是后
   在与匹配项并存的情况下追加新条目

**Assertions:**
- [ ] 与现有 `Open` 条目文件相同、类别相同的新条目，绝不在先展示匹配项并询问之前被追加
- [ ] "Update" 编辑匹配行，而不是添加新行
- [ ] 拒绝更新不会结束运行：仍提供追加，并在写入前询问

---

### Case 4b: Report Mode Without a Register — NOT ASSESSED

**Fixture:**
- `docs/tech-debt-register.md` 不存在

**Input:** `/tech-debt report`

**Expected behavior:**
1. 技能查找注册表，未找到
2. 结论：**NOT ASSESSED** — no register to report on; run `/tech-debt scan` first
3. 不打印趋势或总计，也不写入任何内容

**Assertions:**
- [ ] 结论为 NOT ASSESSED，而不是零条目报告或 "stable" 趋势
- [ ] 输出指明 `/tech-debt scan` 是创建注册表的方式
- [ ] 不写入任何文件

---

### Case 5: Prioritize in Full Review Mode — 已评分、重新排序、已批准

**Fixture:**
- `project.yaml`：`modes.review_mode: full`；`modes.workflow: standard`（固定：未设置会解析为 minimal，从而推荐下一次构建而非冲刺）
- `docs/tech-debt-register.md` 有 4 个条目：TD-001 High/S、TD-002 Low/L、TD-003
  Critical/M、TD-004 Med/—（Effort 尚未估算）

**Input:** `/tech-debt prioritize`

**Expected behavior:**
1. 技能读取 `docs/tech-debt-register.md`
2. 每个条目的评分为 `impact ÷ effort`（Impact Low 1 … Critical 4；Effort S 1 … XL 4）：TD-001 3.0、TD-003 2.0、TD-002 0.3；TD-004 列在它们之后为 "not scored — Effort not judged"
3. 注册表按评分重新排序，技能推荐哪些条目属于下个冲刺
4. 无论评审模式如何，都不调用总监闸门
5. 技能展示重新排序后的注册表，然后询问 "May I write the re-prioritized register back to `docs/tech-debt-register.md`?"
6. 获得批准后写入文件
7. 结论：**COMPLETE** — register re-prioritized and saved

**Assertions:**
- [ ] 条目根据其自身列以 `impact ÷ effort` 评分并重新排序：TD-001、TD-003、TD-002
- [ ] TD-004 不获得杜撰的分数；它列为未评分，并指明缺失的 Effort
- [ ] 给出下个冲刺的建议
- [ ] 在任何评审模式下都不调用总监闸门
- [ ] 写入只在 "May I write" 提示获批后发生
- [ ] 结论为 COMPLETE
- [ ] 下一步将高优先级项送往 `/sprint-plan`

---

### Case 5b: Prioritize at Workflow Minimal — 下一步构建，而非冲刺

**Fixture:**
- `project.yaml`：`modes.rigor: minimal`（workflow 解析为 `minimal`，它没有冲刺）；`modes.automation` 未设置（collaborative）
- `docs/tech-debt-register.md` 有 3 个 `Open` 条目：TD-001 High/S、TD-002 Low/L、TD-003 Critical/M
- `design/game-brief.md` 存在，含三个编号条目的构建顺序；没有 `production/sprints/` 文件夹

**Input:** `/tech-debt prioritize`

**Expected behavior:**
1. 技能解析出 `workflow: minimal` 并读取注册表
2. 条目按 Case 5 评分并重新排序：TD-001 3.0、TD-003 2.0、TD-002 0.3
3. 建议说明接下来构建哪些条目，而不是哪些属于下个冲刺
4. 技能询问 "May I write the re-prioritized register back to `docs/tech-debt-register.md`?" 并在批准后写入
5. 下一步告诉用户将高优先级项加入简报的构建顺序，而不是运行 `/sprint-plan`；它们仍包含 `/tech-debt report`
6. 结论：**COMPLETE** — register re-prioritized and saved

**Assertions:**
- [ ] 建议是 "which to build next"；"sprint" 一词未用作放置这些条目的位置
- [ ] 下一步指明简报的构建顺序（`design/game-brief.md`）是高优先级项的归属
- [ ] 不推荐 `/sprint-plan`
- [ ] 评分、重新排序与批准后写入规则与 Case 5 相同
- [ ] 结论为 COMPLETE

---

## Protocol Compliance

- [ ] 要求子命令；没有子命令时打印用法并以 FAIL 停止
- [ ] `scan` 按引擎解析代码根（`src/`、`Assets/`、`Source/`）并说明覆盖的文件数量
- [ ] 零文件或根未解析的扫描为 NOT ASSESSED，且不写入任何内容
- [ ] 每次注册表写入之前都有指明 `docs/tech-debt-register.md` 的 "May I write" / "May I append" 提示，且在展示内容之后
- [ ] `scan` 追加且绝不覆盖现有条目；匹配 `Open` 行的发现项更新它，模式已消失的 `Open` 行被提议为 `Resolved [date]`，绝不删除
- [ ] 新行遵循 Debt Register Format：下一个 `TD-NNN` ID、全部十列、`YYYY-MM-DD` 形式的 `Added` 日期
- [ ] 拒绝写入以 BLOCKED 结束
- [ ] 不调用任何总监闸门
- [ ] 以 Phase 3 的下一步结束（`/sprint-plan`、`/tech-debt report`）；在 workflow `minimal` 下，冲刺步骤变为 "add them to the brief's build order"
- [ ] 通过 `resolve_config` 解析 `automation` 与 `workflow`

---

## Coverage Notes

- 带注册表的 `report` 模式（按类别与工作量的只读摘要，
  从每行的 `Added` 与 `Resolved` 日期得出新增与已解决计数，
  标记超过 3 个冲刺的条目，Verdict COMPLETE — debt report generated）
  不在此测试。
- Unity 与 Unreal 的扫描仅在解析后的根（`Assets/`、
  `Source/`）上不同，未单独测试。
