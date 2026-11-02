# Skill Test Spec: /patch-notes

## Skill Summary

`/patch-notes` 是一个 Sonnet 档技能，它把一次发布的变更转化为面向玩家的补丁说明。在读取任何历史记录之前，它把近期提交归类为 Game 或 Framework / maintenance（Unclear 计入 Framework），只使用 Game 提交，并说明用了多少个、总共多少个。它从 `production/releases/[version]/changelog.md`、`docs/CHANGELOG.md` 中该版本的条目，以及作为回退的、自上个发布标签以来的 `git log` 收集变更数据。它检查语气指南（`.claude/docs/technical-preferences.md`、`docs/PATCH-NOTES-STYLE.md`、`design/community/tone-guide.md`）和补丁说明模板（`docs/patch-notes-template.md`、`.claude/docs/templates/patch-notes-template.md`），移除仅内部使用的变更，并把其余部分翻译成玩家语言，采用 Brief、Detailed（默认）或 Full 风格——若存在模板则改用该模板的结构，并说明用了哪个模板。不使用总监闸门。技能询问“May I write these patch notes to `docs/patch-notes/[version].md`, and an archive copy to `production/releases/[version]/patch-notes.md`?”——指名两个文件——并在批准后写入两者。结论：COMPLETE（说明已生成并保存）或 BLOCKED（没有变更日志数据且没有 git 历史，或历史中没有 Game 提交）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 措辞（技能会写入补丁说明文件）
- [ ] 具有下一步交接（`/release-checklist`、community-manager 语气评审）

---

## Director Gate Checks

无。补丁说明生成是一个快速编译任务，不调用任何闸门。

---

## Fixture Defaults

除非该用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 变更日志过滤为面向玩家的条目

**Fixture:**
- `docs/CHANGELOG.md` 有一个 `v0.4.0` 条目，包含 5 个事项：
  - "Add dual-wield melee system"（面向玩家）
  - "Fix crash on level transition"（面向玩家）
  - "Add enemy patrol AI"（面向玩家）
  - "Refactor input handler to use event bus"（仅内部）
  - "Update dependency: Godot 4.6"（仅内部）
- 自上个标签以来的 git 历史包含这些事项背后的 Game 提交
- 不存在语气指南，也不存在补丁说明模板

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 技能对近期提交进行分类，并说明用了多少个、总共多少个
2. 技能读取 `docs/CHANGELOG.md` 中的 `v0.4.0` 条目
3. 未找到语气指南，因此应用默认语气；未找到模板，因此使用内置的 Detailed 风格（默认的 `--style`）
4. 技能保留 3 个面向玩家的事项，移除 2 个内部事项
5. 技能用玩家语言改写这些事项（不含任务 ID，不含内部系统名）
6. 技能展示说明，并带有按类别统计的变更数以及被排除的内部变更清单
7. 技能询问“May I write these patch notes to `docs/patch-notes/v0.4.0.md`, and an archive copy to `production/releases/v0.4.0/patch-notes.md`?”
8. 用户批准；两个文件都被写入；结论 COMPLETE

**Assertions:**
- [ ] 说明中只出现 3 个面向玩家的事项；2 个内部事项作为被排除项单独列出以供审阅
- [ ] 条目以通俗语言撰写，不含内部任务 ID 或系统名
- [ ] 说明使用内置的 Detailed 风格（Highlights、New Content、… Known Issues）——当未给出 `--style` 且不存在模板时的默认值
- [ ] 指名 `docs/patch-notes/v0.4.0.md` 的“May I write”提示在任何文件写入之前出现
- [ ] 写入后结论为 COMPLETE

---

### Case 2: 无变更日志文件 —— 回退到 git 历史

**Fixture:**
- `production/releases/v0.4.0/changelog.md` 和 `docs/CHANGELOG.md` 都不存在
- 标签 `v0.3.0` 存在；范围 `v0.3.0..HEAD` 中有 6 个 Game 提交和 2 个 Framework / maintenance 提交（一个改动钩子，一个改动 CI）

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 技能对提交进行分类，保留 Game 提交，排除 2 个框架提交，并说明用了多少个、总共多少个
2. 技能找不到变更日志来源，于是使用自 `v0.3.0` 到 HEAD 的 `git log` 作为回退
3. 技能不会以 BLOCKED 停止——“No changelog data found … Run `/changelog [version]` first”路径还要求 git 历史为空或不可用
4. 技能仅根据 Game 提交生成说明
5. 技能在写入前询问“May I write”

**Assertions:**
- [ ] git 历史可用时技能不崩溃，也不以 BLOCKED 停止
- [ ] 技能回退到自上个标签（`v0.3.0`）到 HEAD 的 `git log`
- [ ] 输出说明用了多少个、总共多少个提交
- [ ] 2 个框架 / maintenance 提交不出现在补丁说明中
- [ ] 任何文件写入之前出现“May I write”提示

---

### Case 3: 来自设计文件夹的语气指导 —— 融入输出

**Fixture:**
- `docs/CHANGELOG.md` 有一个 `v0.4.0` 条目，包含面向玩家的事项；git 历史包含对应的 Game 提交
- `design/community/tone-guide.md` 存在，含指导：“upbeat, encouraging tone; avoid passive voice”
- `docs/PATCH-NOTES-STYLE.md` 不存在，且 `.claude/docs/technical-preferences.md` 没有语气、语态或风格字段
- 不存在补丁说明模板

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 技能读取变更日志条目
2. 技能检查三个语气来源，并找到 `design/community/tone-guide.md`
3. 技能提取该指南的指示，并将其应用于说明的语言和表述，取代内置默认语气
4. 结构仍保持内置的 Detailed 风格
5. 技能展示说明，询问“May I write”，并在批准后写入

**Assertions:**
- [ ] 技能在 Phase 2b 中检查语气来源，包括 `design/community/tone-guide.md`
- [ ] 语气指南的指示被应用于取代内置默认语气
- [ ] 条目使用主动语态（“Fixed a crash when…”、“You can now…”），而非被动语态（“A crash was fixed”）
- [ ] 语气指导只改变措辞——输出结构仍为 Detailed 风格

---

### Case 4: 存在补丁说明模板 —— 代替内置风格使用

**Fixture:**
- `.claude/docs/templates/patch-notes-template.md` 存在，包含一个头部块、`## New`、`## Fixed` 和 `## Known Issues` 小节，以及一个页脚
- `docs/CHANGELOG.md` 有一个 `v0.4.0` 条目，包含一个新功能和一个缺陷修复，两者都面向玩家；git 历史包含对应的 Game 提交

**Input:** `/patch-notes v0.4.0 --style full`

**Expected behavior:**
1. 技能对 `docs/patch-notes-template.md` 和 `.claude/docs/templates/patch-notes-template.md` 做 glob；找到并读取后者
2. 技能把该模板用作输出结构，而非内置的 Brief / Detailed / Full 模板——即便传入了 `--style full`
3. 新功能归入 `## New` 下，修复归入 `## Fixed` 下
4. 模板的头部和页脚被保留
5. 输出说明使用了该模板，且它取代了 `--style full`
6. 技能询问“May I write”，并在批准后写入

**Assertions:**
- [ ] 技能在生成之前对两个模板位置都做 glob
- [ ] 模板的结构取代内置风格——尽管有 `--style full`，也不出现 Full 风格的“Developer Commentary”小节
- [ ] 新功能置于 `## New` 下，修复置于 `## Fixed` 下
- [ ] 输出中保留模板的头部和页脚
- [ ] 输出注明使用了 `.claude/docs/templates/patch-notes-template.md`，且它取代了所请求的 `--style full`

---

### Case 5: 闸门合规 —— 无闸门；community-manager 另行处理

**Fixture:**
- `docs/CHANGELOG.md` 有一个 `v0.4.0` 条目，包含面向玩家的事项；git 历史包含对应的 Game 提交
- `project.yaml` 设置 `modes.review_mode: full`

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 技能编译补丁说明；不生成总监闸门（技能只解析 `automation`，从不解析 `review_mode`）
2. 技能自评审说明（Phase 5），然后展示说明并询问是否写入
3. 下一步建议 `/release-checklist`，并建议在公开发布前把草稿交给 community-manager 做语气评审
4. 用户批准；说明被写入；结论 COMPLETE

**Assertions:**
- [ ] 无论评审模式如何，都不调用总监闸门
- [ ] 输出建议（但不要求）在发布前由 community-manager 做语气评审
- [ ] 技能从编译与自评审直接进入“May I write”提示
- [ ] 结论为 COMPLETE

---

### Case 6: 来源校验停止 —— 零 Game 提交

**Fixture:**
- `git log --oneline -20` 显示 20 个提交，全部触及框架或工具链——提交主题诸如 "fix: session-start hook timeout"、"docs: skill catalog"、"ci: cache the test runner"——且没有一个指名 `design/` 或代码根目录中的游戏系统
- `production/releases/v0.4.0/changelog.md` 和 `docs/CHANGELOG.md` 都不存在

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 在 Phase 2 之前，技能对采样的提交进行分类：0 个 Game、20 个 Framework / maintenance
2. 技能以“The git history in this repo does not appear to belong to [game] …”停止，并描述这些提交实际覆盖了什么
3. 不生成说明，也不写入任何内容；结论 BLOCKED

**Assertions:**
- [ ] 输出给出分类结果——20 个提交中 0 个为 Game 提交
- [ ] 输出包含 "does not appear to belong to" 停止语，而不是用框架提交写成的说明（不会把钩子修复写成“Fixed an issue where …”）
- [ ] 不出现“May I write”提示，也不写入文件
- [ ] 结论为 BLOCKED，而非 COMPLETE

---

### Case 7: 无变更日志数据 —— 既无变更日志也无 git 历史

**Fixture:**
- `production/releases/v0.4.0/changelog.md` 和 `docs/CHANGELOG.md` 都不存在
- 项目目录不是 git 仓库，因此 `git log` 不返回任何内容

**Input:** `/patch-notes v0.4.0`

**Expected behavior:**
1. 采样的日志为空，因此跳过来源校验——没有可分类的内容
2. Phase 2 找不到变更日志来源，也找不到 git 历史；技能输出“No changelog data found for v0.4.0. Run `/changelog v0.4.0` first to generate the internal changelog, then re-run `/patch-notes v0.4.0`.”
3. 不生成也不写入任何内容；结论 BLOCKED

**Assertions:**
- [ ] 不显示 "does not appear to belong to" 来源校验停止语——空历史不等于错误的历史
- [ ] 输出包含“No changelog data found for v0.4.0”，并推荐 `/changelog v0.4.0`
- [ ] 不生成说明，不出现“May I write”提示，也不写入文件
- [ ] 结论为 BLOCKED

---

## Protocol Compliance

- [ ] 在读取历史之前运行来源校验，只使用 Game 提交，并说明使用了多少个
- [ ] 在回退到 `git log` 之前，先读取该版本的变更日志条目（`production/releases/[version]/changelog.md`、`docs/CHANGELOG.md`）
- [ ] 只把条目过滤为面向玩家的事项，并列出被排除的内部变更以供审阅
- [ ] 用通俗语言改写条目，不含内部 ID
- [ ] 写入补丁说明之前始终询问“May I write”
- [ ] 不调用任何总监闸门
- [ ] 声明 `model: sonnet`——它撰写面向玩家的文案

---

## Coverage Notes

- 缺少版本参数（技能会先询问再继续）未测试。
- 所有变更日志条目均为内部（零个面向玩家事项）的情况未测试。
- Case 5 中提到的 community manager 咨询是建议性的；该步骤由单独技能或人工评审处理。
