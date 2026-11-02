# Skill Test Spec: /content-audit

## Skill Summary

`/content-audit [system-name | --summary]` 将设计所指定的内容数量
与实际已构建的内容进行比较。它为系统及其 MVP/优先级层级读取
`design/gdd/systems-index.md`，当注册表有条目时，从
`design/registry/entities.yaml` 的 `entities:` 与 `items:` 章节获取计划中的具名内容，
并用两次 grep（Summary 是否存在，以及
数字加内容名词的计数）预扫描 GDD，然后只完整读取它需要的 GDD
（Phase 1）。接着它为每种内容类型 glob 实现目录——
`assets/data/**/enemies/**`、`assets/data/**/items/**`、解析后的代码根下的场景文件，
等等（Phase 2）——并生成差距表
`System | Content Type | Specified | Found | Gap | Status`，每行 Status 为
COMPLETE / IN PROGRESS / EARLY / NOT STARTED，带 HIGH PRIORITY 标记，以及一行摘要
（Phase 3）。完整报告只在 "May I write" 之后写入
`docs/content-audit-[YYYY-MM-DD].md`；`--summary` 不写入任何内容。`modes.workflow` 设定
范围：`full` 审计每个 GDD 计数，`standard` 只统计必需 GDD
章节中的计数（并指明任何被排除的），而 `minimal` 没有可供
审计的系统索引。运行以 COMPLETE 结束，或当必需
输入缺失、范围内没有任何内容给出计数、或无法取得 Found 计数
（代码根未解析）时以 `NOT ASSESSED — NO DATA` 结束——对于无法计算
差距的运行，绝不用 COMPLETE。不调用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含状态与结论关键词：COMPLETE、IN PROGRESS、EARLY、NOT STARTED、NOT ASSESSED
- [ ] 在可选报告写入 `docs/content-audit-[YYYY-MM-DD].md` 之前包含 "May I write"
- [ ] 有下一步交接（差距表评审之后该做什么）

---

## Director Gate Checks

无。内容审计是分析技能；不调用任何闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 所有指定内容均已呈现

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/gdd/systems-index.md` 列出 Enemies（MVP）与 Items（MVP）
- `design/registry/entities.yaml` 没有条目
- `design/gdd/enemies.md` 指定 "4 enemy types: Grunt, Sniper, Tank, Boss"
- `design/gdd/items.md` 指定 "3 items"
- `assets/data/enemies/` 包含 `grunt.json`、`sniper.json`、`tank.json`、`boss.json`
- `assets/data/items/` 包含 3 个物品 `.json` 文件

**Input:** `/content-audit`

**Expected behavior:**
1. 技能读取系统索引；空注册表被跳过，改用 GDD 扫描
2. 预扫描 grep 发现两份 GDD 都声明了内容计数；两者都被完整读取
3. 技能 glob `assets/data/**/enemies/**` 与 `assets/data/**/items/**`
4. 差距表：Enemies — Specified 4、Found 4、Gap 0、COMPLETE；Items — Specified 3、Found 3、Gap 0、COMPLETE
5. 摘要行：7 specified、7 found、整体差距 0%
6. 技能展示表格并询问 "May I write the full report to `docs/content-audit-[YYYY-MM-DD].md`?"
7. 输出以 `Verdict: COMPLETE — content audit finished.` 结束

**Assertions:**
- [ ] 差距表使用列 System、Content Type、Specified、Found、Gap、Status
- [ ] 两行都显示 Specified = Found、Gap 0 与 Status COMPLETE
- [ ] 摘要行报告 7 specified、7 found 与 0% gap
- [ ] 不引发 HIGH PRIORITY 标记
- [ ] 在 "May I write" 询问得到肯定答复之前不写入任何文件

---

### Case 2: Gaps Found — MVP 敌人内容才刚开始

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/gdd/systems-index.md` 将 Enemies 标记为 MVP
- `design/gdd/enemies.md` 指定 "3 enemy types: Grunt, Sniper, Boss"
- `assets/data/enemies/` 只包含 `grunt.json`

**Input:** `/content-audit enemies`

**Expected behavior:**
1. 单系统审计：技能跳过预扫描，完整读取 `design/gdd/enemies.md`
2. 技能找到 1 个敌人定义文件
3. 差距表行：Enemies — Specified 3、Found 1、Gap 2、Status EARLY（33%）
4. Enemies 被标记为 HIGH PRIORITY：状态 EARLY 且带 MVP 标记
5. 技能询问 "May I write the full report to `docs/content-audit-[YYYY-MM-DD].md`?"；回答是后，报告的 HIGH PRIORITY Gaps 章节列出 Enemies 及其理由
6. 下一步包括 "Run `/create-stories [epic-slug]` for each HIGH PRIORITY gap."

**Assertions:**
- [ ] Specified（3）、Found（1）与 Gap（2）都显示出来
- [ ] 3 个中 1 个（33%）的 Status 为 EARLY，而非 IN PROGRESS 或 NOT STARTED
- [ ] Enemies 因处于 EARLY 且带 MVP 标记而被标记为 HIGH PRIORITY
- [ ] 技能现在标记该差距；它不假设内容之后会补上
- [ ] 下一步指向针对 HIGH PRIORITY 差距的 `/create-stories`

---

### Case 3: No Design Inputs — 没有可对照审计的内容

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/gdd/systems-index.md` 不存在
- `design/gdd/` 不包含任何 GDD
- `design/registry/entities.yaml` 没有条目

**Input:** `/content-audit`

**Expected behavior:**
1. 技能将其输入记录为 FOUND / ABSENT；系统索引、GDD 与注册表条目全部为 ABSENT
2. 每个必需输入都为 ABSENT，因此技能停止
3. 输出报告 `NOT ASSESSED — NO DATA`，指明缺失的系统索引与 GDD，以及产出它们的技能（`/map-systems`、`/design-system`）
4. 不生成差距表，也不生成差距百分比（不做除以零）
5. 不提供报告写入，也不写入任何文件

**Assertions:**
- [ ] 结论为 `NOT ASSESSED — NO DATA`，而非 COMPLETE
- [ ] 不生成差距表或整体差距百分比
- [ ] 输出指明缺失的输入与产出它们的技能
- [ ] 不出现 "May I write" 提示，也不写入任何文件

---

### Case 3b: No Counts Anywhere — GDD 存在，但没有一份给出计数

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/gdd/systems-index.md` 列出 Core Loop
- `design/gdd/core-loop.md` 有 `## Summary`，且只描述机制——没有内容计数，也没有具名列表
- `design/registry/entities.yaml` 没有条目

**Input:** `/content-audit`

**Expected behavior:**
1. 系统索引与 GDD 都为 FOUND，因此技能不会在输入不足检查处停止
2. 扫描 (b) 没有匹配项；`core-loop.md` 有 Summary，因此注明 "No auditable content counts"，不完整读取
3. 没有行带有 Specified 计数，因此不计算 Gap、Status 或整体差距百分比（Specified 为 0）
4. 运行以 `Verdict: NOT ASSESSED — NO DATA` 结束，说明没有 GDD 给出计数，并指明用 `/design-system` 添加计数

**Assertions:**
- [ ] 不计算整体差距百分比，也没有行被标记为 COMPLETE
- [ ] 结论为 `NOT ASSESSED — NO DATA`，绝不对空差距表给出 COMPLETE
- [ ] 输出说明没有 GDD 给出计数，并指明 `/design-system`

---

### Case 4: Edge Case — 缺少 Summary 的 GDD 描述了内容但没有计数

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/gdd/systems-index.md` 列出 Enemies 与 Quests
- `design/gdd/enemies.md` 有 `## Summary` 并指定 "3 enemy types: Grunt, Sniper, Boss"；`assets/data/enemies/` 有全部 3 个
- `design/gdd/quests.md` 没有 `## Summary` 章节，只说游戏有 "a handful of side quests"，没有数字或具名列表
- 用户对报告写入回答是

**Input:** `/content-audit`

**Expected behavior:**
1. 技能 glob `design/gdd/*.md` 求分母：N = 3，因为 glob 也计入 `systems-index.md`（在步骤 1 读取；它没有 `## Summary`）；Summary grep 只匹配 `enemies.md`；内容计数 grep 也只匹配 `enemies.md`
2. 对于缺失的 Summary，技能按失败开放原则完整读取 `quests.md`，而不是将其视为范围外——失败开放规则优先于内容计数收窄
3. 技能将 Quests 内容类型记录为 "Unspecified" 并标记为设计差距；它不杜撰计数
4. Enemies 行为 COMPLETE（3 个中 3 个）
5. 写出的报告 `docs/content-audit-[YYYY-MM-DD].md` 在 "Unspecified Content Counts" 下列出 `quests.md`
6. 报告注明计数是基于文件扫描的近似值

**Assertions:**
- [ ] `quests.md` 因缺少 `## Summary` 而被完整读取，即使内容计数 grep 未匹配它
- [ ] Quests 内容被记录为 "Unspecified"，绝不给估算计数
- [ ] 报告的 Unspecified Content Counts 章节指明 `quests.md`
- [ ] Enemies 行仍正常审计（Specified 3、Found 3、COMPLETE）
- [ ] 报告带有近似值警示

---

### Case 5: Gate Compliance — 无闸门；可选报告需要批准

**Fixture:**
- `project.yaml`：`modes.workflow: full`，`modes.review_mode: full`
- GDD 指定 10 个内容项；实现目录中找到 9 个

**Input:** `/content-audit`

**Expected behavior:**
1. 技能读取设计输入并扫描实现；生成差距表
2. 无论评审模式如何，都不调用总监闸门
3. 技能在任何写入之前展示差距表与摘要
4. 技能询问 "May I write the full report to `docs/content-audit-[YYYY-MM-DD].md`?"
5. 若用户回答否，则不写入任何内容；任何 asset 文件都不会被修改

**Assertions:**
- [ ] 在任何评审模式下都不调用总监闸门
- [ ] 差距表被展示，且不自动写入任何文件
- [ ] 报告写入被提供为 `docs/content-audit-[YYYY-MM-DD].md`，但不是强制
- [ ] 技能不修改任何 asset 文件

---

### Case 6: Standard Workflow — 只审计必需章节中的计数

**Fixture:**
- `modes.workflow` 解析为 `standard`
- `design/gdd/systems-index.md` 列出 Enemies（MVP）
- `design/gdd/enemies.md` 的 `## Detailed Design` 指定 "3 enemy types: Grunt, Sniper, Boss"；其 `## Tuning Knobs` 章节提到 "2 elite variants"
- `assets/data/enemies/` 包含 `grunt.json`、`sniper.json`、`boss.json`

**Input:** `/content-audit`

**Expected behavior:**
1. `## Detailed Design`（`standard` 下的必需章节）中的计数被审计：Enemies — Specified 3、Found 3、Gap 0、COMPLETE
2. "2 elite variants" 计数位于 `## Tuning Knobs`，`standard` 不要求该章节；它没有差距行，并列为该层级下未审计
3. 输出以 `Verdict: COMPLETE — content audit finished.` 结束

**Assertions:**
- [ ] Detailed Design 的计数被审计，Enemies 行为 COMPLETE
- [ ] Tuning Knobs 的计数不在差距表或总计中
- [ ] 输出将 Tuning Knobs 计数注明为在 `standard` 下未审计，而不是静默丢弃

---

### Case 7: Minimal Workflow — 没有可对照审计的系统索引

**Fixture:**
- `project.yaml`：`modes.rigor: minimal`（`workflow` 解析为 `minimal`）
- `design/game-brief.md` 存在；`design/gdd/systems-index.md` 不存在

**Input:** `/content-audit`

**Expected behavior:**
1. 系统索引为 ABSENT，这在 `minimal` 下是常态
2. 输出报告 `NOT ASSESSED — NO DATA`，指明缺失的系统索引与创建它的 `/map-systems`
3. 没有差距表、没有差距百分比，也没有报告写入

**Assertions:**
- [ ] 结论为 `NOT ASSESSED — NO DATA`，而非 COMPLETE
- [ ] 输出指明 `design/gdd/systems-index.md` 缺失，以及 `/map-systems` 是产出它的技能
- [ ] 不计算差距百分比，也不写入任何文件

---

### Case 8: Code Root Unresolved — 不取得关卡计数

**Fixture:**
- `modes.workflow` 解析为 `full`
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md` 显示 `[TO BE CONFIGURED]`；`src/` 与 `Source/` 都存在，因此目录树无法决定根
- `design/gdd/systems-index.md` 列出 Levels（MVP）与 Enemies（MVP）
- `design/gdd/levels.md` 指定 "6 levels"；`design/gdd/enemies.md` 指定 "3 enemy types: Grunt, Sniper, Boss"
- `assets/data/enemies/` 包含 3 个敌人文件；`assets/` 下不存在场景文件

**Input:** `/content-audit`

**Expected behavior:**
1. Enemies 从 `assets/data/` 审计：Specified 3、Found 3、COMPLETE
2. 关卡扫描需要代码根，而代码根未解析：Levels 行的 Found 为 `NOT ASSESSED — code root unresolved`——不是 0，其 Status 也不是 NOT STARTED
3. Levels 不获得 HIGH PRIORITY 标记，并被排除在两个摘要总计之外；摘要有说明
4. 运行以 `Verdict: NOT ASSESSED — NO DATA` 结束，并指明未解析的代码根

**Assertions:**
- [ ] Levels 行显示 `NOT ASSESSED — code root unresolved`，绝不是 Found 0 或 NOT STARTED
- [ ] 摘要总计排除 Levels 并说明这一点
- [ ] 结论为 NOT ASSESSED，而非 COMPLETE

---

## Protocol Compliance

- [ ] 在扫描实现之前读取系统索引、注册表（当它有条目时）与范围内 GDD
- [ ] 没有 `## Summary` 的 GDD 会被完整读取，即使内容计数 grep 未匹配它
- [ ] 应用解析后的 `modes.workflow`：`standard` 只审计必需 GDD 章节中的计数，并指明任何被排除的
- [ ] 差距表显示 System、Content Type、Specified、Found、Gap、Status
- [ ] 行 Status 为以下之一：COMPLETE、IN PROGRESS、EARLY、NOT STARTED；无法取得 Found 的行记为 `NOT ASSESSED` 并排除在总计之外
- [ ] 只在 "May I write" 之后写入，且只写入 `docs/content-audit-[YYYY-MM-DD].md`；`--summary` 不写入任何内容
- [ ] 缺失的必需输入、没有计数的范围、或未取得的 Found 计数会产出 `NOT ASSESSED — NO DATA`，绝不产出计算出的差距百分比或 COMPLETE
- [ ] 不调用任何总监闸门
- [ ] 在 Unity 上，每个内容 glob 也会在没有 `data/` 段的 `Assets/` 下运行（例如 `Assets/**/Items/**`、`*Item*.asset`）——Unity 项目的物品、能力、任务与对话绝不会因仅扫描 `assets/data/` 而被报告为 NOT STARTED

---

## Coverage Notes

- `--summary` 模式（打印表格、不写入任何内容、以 "Run
  `/content-audit` without `--summary` to write the full report." 结束）没有
  单独用例。
- Unity 关卡在代码根下找到（`Assets/`、`*.unity`），
  其他内容类型在 `Assets/` 下（已在 Protocol Compliance 中断言）；Unreal
  关卡在 `Content/` 下（`*.umap`，数据资产为 `*.uasset`）；两个
  引擎都没有单独用例。
- 资源命名、大小与格式合规是 `/asset-audit` 的职责，不是本
  技能的。
