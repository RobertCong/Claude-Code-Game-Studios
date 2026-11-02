# Skill Test Spec: /changelog

## Skill Summary

`/changelog` 是一个 Sonnet 档技能，它根据自上一个发布标签以来的 git 提交生成两份变更日志——一份内部用，一份面向玩家。在使用注入的历史记录之前，它会把每个提交归类为 Game 或 Framework / maintenance（Unclear 计入 Framework），只使用 Game 提交，并说明用了多少个、总共多少个；若 Game 提交为零则停止。若完全没有历史记录（不是 git 仓库，或没有任何提交），它会跳过该检查并在 Phase 1 停止。它读取 `production/sprints/` 中的冲刺计划与 `design/gdd/` 中的 GDD 作为上下文，并把变更归入 New Features、Improvements、Bug Fixes、Balance Changes、Technical Debt / Refactoring（仅内部变更日志）、Known Issues 和 Miscellaneous。内部变更日志以 Metrics 小节结尾，统计没有任务引用的提交数。无标签时，它把范围限定为 `git log --oneline -n 100`，而不是读取完整日志。不使用总监闸门。该技能会询问“May I write this changelog to `docs/CHANGELOG.md`?”，并提供追加 / 覆盖 / 拒绝三个选项。结论：写入后为 CHANGELOG WRITTEN，用户拒绝写入时为 COMPLETE，没有历史记录或没有一条属于本游戏时为 BLOCKED。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个 phase 标题
- [ ] 包含结论关键词：CHANGELOG WRITTEN、COMPLETE、BLOCKED
- [ ] 包含 "May I write" 措辞（技能会写入变更日志）
- [ ] 具有下一步交接（面向玩家发布时为 `/patch-notes`，或 `/release-checklist`）

---

## Director Gate Checks

无。变更日志生成是一个快速编译任务，不调用任何闸门。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 自上个发布标签以来有多个冲刺

**Fixture:**
- Git 历史中有标签 `v0.3.0`；它是注入标签列表中最新的标签
- 自该标签以来：跨冲刺 006、007、008 有 12 个提交——全部为 Game 提交（机制、内容、缺陷修复），并指名了出现在 `design/` 中的系统
- `production/sprints/sprint-006.md` 至 `sprint-008.md` 存在，并列出任务 ID 出现在提交信息中的那些用户故事
- `docs/CHANGELOG.md` 尚不存在

**Input:** `/changelog`

**Expected behavior:**
1. 技能把注入的提交归类为 Game 或 Framework / maintenance，并说明用了多少个、总共多少个
2. 技能读取 `git log --oneline v0.3.0..HEAD`
3. 技能读取 `production/sprints/` 中冲刺 006–008 的冲刺计划，作为变更背后的上下文
4. 技能把变更分类为 New Features、Improvements、Bug Fixes、Balance Changes、Technical Debt / Refactoring、Known Issues 和 Miscellaneous，并带有 Metrics 小节
5. 技能同时输出内部变更日志和面向玩家的变更日志
6. 技能询问“May I write this changelog to `docs/CHANGELOG.md`?”，选项为 [A] 追加、[B] 覆盖、[C] 否
7. 用户选择 [B]；文件被创建；结论 CHANGELOG WRITTEN

**Assertions:**
- [ ] 变更日志覆盖 `v0.3.0..HEAD` 中的提交，且输出说明使用了注入提交中的多少个、总共多少个
- [ ] 条目采用该技能的小节集合——New Features、Improvements、Bug Fixes、Balance Changes、Technical Debt / Refactoring、Known Issues、Miscellaneous——而不是笼统的 Features/Fixes 划分
- [ ] 分类之前读取 `production/sprints/` 中相关冲刺的冲刺计划作为上下文
- [ ] 两份变更日志都在“May I write”提示前展示，且在批准前不写入任何内容
- [ ] 写入后结论为 CHANGELOG WRITTEN

---

### Case 2: 未找到 Git 标签 —— 使用限定范围

**Fixture:**
- Git 仓库有 20 个提交且没有标签；20 个全部为 Game 提交
- 注入的标签列表为空
- `docs/CHANGELOG.md` 不存在

**Input:** `/changelog`

**Expected behavior:**
1. 技能找不到可用于锚定范围的标签
2. 技能用 `git log --oneline -n 100` 限定范围——它不读取无界的完整日志
3. 20 个提交都落在 100 个提交的界限内，因此窗口到达历史起点，技能无需请求起始引用
4. 技能说明它使用了多少个提交
5. 技能编译分类后的变更日志，并在写入前询问“May I write”

**Assertions:**
- [ ] 不存在 git 标签时技能不报错
- [ ] 范围通过有界的 `git log --oneline -n 100` 读取，绝不使用无界的完整日志
- [ ] 覆盖全部 20 个提交，且技能不请求起始引用（界限到达第一个提交）
- [ ] 输出说明 20 个提交中使用了多少个
- [ ] 尽管缺少标签，变更日志仍按小节组织

---

### Case 3: 提交信息无任务 ID —— 按内容分类，在 Metrics 中统计

**Fixture:**
- 自上个标签以来的 git 日志有 8 个 Game 提交
- 3 个提交引用了与冲刺用户故事匹配的任务 ID（例如 `[STORY-012]`）
- 5 个提交没有任务 ID："tweak dash cooldown 0.8 -> 0.6"、"fix player clipping through ledge"、"add footstep sounds"、"level tweaks"、"combat cleanup"

**Input:** `/changelog`

**Expected behavior:**
1. 技能按每个提交改动了什么来分类，无论它是否有任务 ID
2. "tweak dash cooldown 0.8 -> 0.6" 归入 Balance Changes；"fix player clipping through ledge" 归入 Bug Fixes
3. "combat cleanup" 只说明做了清理，未指明任何修复、功能或调优，因此归入 Technical Debt / Refactoring——仅出现在内部变更日志中
4. "level tweaks" 过于含糊、无法自信分类，归入 Miscellaneous
5. Metrics 小节报告 `Commits without task reference: 5`
6. 技能询问“May I write”，并在批准后写入

**Assertions:**
- [ ] 无论有无任务 ID，提交都按内容分类——未标记的 "tweak dash cooldown 0.8 -> 0.6" 归入 Balance Changes，而非单独的无 ID 分组
- [ ] "combat cleanup" 列在内部变更日志的 Technical Debt / Refactoring 下，且不出现在面向玩家的变更日志中
- [ ] 过于含糊、无法分类的 "level tweaks" 列在 Miscellaneous 下
- [ ] Metrics 小节包含 `Commits without task reference: 5`
- [ ] 没有提交被悄悄丢弃——全部 8 个都出现在某个小节中

---

### Case 4: 已存在 CHANGELOG.md —— 新条目置于顶部，旧条目保留

**Fixture:**
- `docs/CHANGELOG.md` 已存在，包含 `v0.2.0` 和 `v0.3.0` 的小节
- 自 `v0.3.0` 标签以来存在新的 Game 提交

**Input:** `/changelog`

**Expected behavior:**
1. 技能编译自 `v0.3.0` 以来这一时期的新条目
2. 在询问之前，技能检查 `docs/CHANGELOG.md` 是否存在——它存在，因此推荐 [A] 追加
3. 技能询问“May I write this changelog to `docs/CHANGELOG.md`?”，选项为 [A] 追加（推荐）、[B] 覆盖、[C] 否
4. 用户选择 [A]；新条目被置于文件顶部（最新在前）；`v0.2.0` 和 `v0.3.0` 小节保持完整；结论 CHANGELOG WRITTEN

**Assertions:**
- [ ] 技能在询问前检查 `docs/CHANGELOG.md` 是否存在，并因存在而推荐 [A] 追加
- [ ] 提示把追加、覆盖和拒绝作为不同选项提供
- [ ] 选择 [A] 时，新条目被置于文件顶部（最新在前），而非底部，也不会替换整个文件
- [ ] 写入的文件中保留已有的 `v0.2.0` 和 `v0.3.0` 条目

---

### Case 5: 闸门合规 —— 无闸门；拒绝写入以 COMPLETE 结束

**Fixture:**
- Git 历史中自上个标签以来有 Game 提交
- `project.yaml` 设置 `modes.review_mode: full`

**Input:** `/changelog`

**Expected behavior:**
1. 技能编译两份变更日志；不生成总监闸门（技能只解析 `automation`，从不解析 `review_mode`）
2. 技能从展示变更日志直接进入写入提示
3. 用户选择 [C] 否 —— 我会手动复制
4. 技能停止且不写入；结论 COMPLETE

**Assertions:**
- [ ] 无论评审模式如何，都不调用总监闸门
- [ ] 输出不引用任何闸门结果
- [ ] 技能从展示变更日志直接进入“May I write”提示
- [ ] 选择 [C] 时不写入文件，结论为 COMPLETE，而非 CHANGELOG WRITTEN

---

### Case 6: 来源校验停止 —— 零 Game 提交

**Fixture:**
- 注入的 30 个提交全部触及框架或工具链——提交主题诸如 "fix: session-start hook timeout"、"docs: skill catalog"、"ci: cache the test runner"——且没有一个指名 `design/` 或代码根目录中的游戏系统
- `docs/CHANGELOG.md` 不存在

**Input:** `/changelog`

**Expected behavior:**
1. 技能对每个注入的提交进行分类：0 个 Game，30 个 Framework / maintenance
2. 技能以“The git history in this repo does not appear to belong to [game] …”停止，并描述这些提交实际覆盖了什么
3. 不生成变更日志，也不写入任何内容；结论 BLOCKED

**Assertions:**
- [ ] 输出给出分类结果——30 个提交中 0 个为 Game 提交
- [ ] 输出包含 "does not appear to belong to" 停止语，而不是用框架提交构建的变更日志（不会把钩子修复写成“Fixed an issue where …”）
- [ ] 不出现“May I write”提示，也不写入文件
- [ ] 结论为 BLOCKED——而非 COMPLETE，也非 CHANGELOG WRITTEN

---

### Case 7: 无历史记录 —— 不是 git 仓库

**Fixture:**
- 项目目录不是 git 仓库，因此两个注入的历史块都为空
- `docs/CHANGELOG.md` 不存在

**Input:** `/changelog`

**Expected behavior:**
1. 注入的提交列表为空，因此跳过来源校验——没有可分类的内容
2. Phase 1 的 `git rev-parse --is-inside-work-tree` 失败；技能输出“No git history found. A changelog is built from commits …”
3. 不生成也不写入任何内容；结论 BLOCKED

**Assertions:**
- [ ] 不显示 "does not appear to belong to" 来源校验停止语——空历史不等于错误的历史
- [ ] 输出说明未找到 git 历史，并提供两个选项：提交现有工作，或直接提供变更清单
- [ ] 不生成变更日志，不出现“May I write”提示，也不写入文件
- [ ] 结论为 BLOCKED

---

## Protocol Compliance

- [ ] 把注入的提交归类为 Game 或 Framework / maintenance，并且只使用 Game 提交
- [ ] 编译之前读取 git 日志和 `production/sprints/` 中的冲刺计划
- [ ] 写入变更日志之前始终询问“May I write”
- [ ] 不调用任何总监闸门
- [ ] 写入后结论为 CHANGELOG WRITTEN，拒绝写入时为 COMPLETE，没有历史记录或没有 Game 提交时为 BLOCKED
- [ ] 声明 `model: sonnet`——它撰写面向玩家的文案

---

## Coverage Notes

- 尚无任何提交的 git 仓库（与 Case 7 相同的 Phase 1 停止）未单独测试。
- 超过 100 个提交且无标签（技能会说明并请求起始引用，而非扩大范围）未测试。
- 合并提交与压缩提交在这些测试中未显式区分；这属于 git 日志解析阶段的实现细节。
- 面向玩家输出时，应在 `/changelog` 之后运行 `/patch-notes` 技能；该交接在 patch-notes 规格中验证。
