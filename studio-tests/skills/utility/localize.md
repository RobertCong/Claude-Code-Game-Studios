# Skill Test Spec: /localize

## Skill Summary

`/localize` 通过一个必需的子命令运行本地化流水线：
`scan`、`extract`、`validate`、`status`、`brief`、`cultural-review`、
`vo-pipeline`、`rtl-check`、`freeze` 或 `qa`。它作用于 `assets/data/strings/` 下的单一源字符串表
（`strings-en.json` 是英文源；其他语言环境与之并列），
并将报告写入 `production/localization/`。

`scan`、`validate` 与 `status` 是只读的。`extract` 会展示新增键条目的差异，
并在仅追加该差异之前询问 "May I write these new entries to
`assets/data/strings/strings-en.json`?"；其结论为 **COMPLETE**。
没有子命令时，技能打印用法并以结论 **FAIL** 停止——缺少必需子命令。
无法解析代码根的扫描会报告 `NOT ASSESSED — code root unresolved`；
没有字符串表的状态运行会报告 `NOT ASSESSED — no string table found`。`cultural-review`
与 `qa` 会派发 `localization-lead`；`qa` 按语言环境给出
PASS / PASS WITH CONDITIONS / NOT ASSESSED / FAIL 结论，首个命中顺序为 FAIL →
NOT ASSESSED → PASS WITH CONDITIONS → PASS。其检查基于试玩，因此
无人试玩过的语言环境为 NOT ASSESSED，发布质量闸门不会将其
计为通过。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、FAIL、NOT ASSESSED、PASS WITH CONDITIONS
- [ ] 在写入字符串表或报告之前包含 "May I write" 协作协议用语
- [ ] 有下一步交接（以 `/gate-check release` 结尾的 Recommended Workflow 链）
- [ ] QA 闸门说明是分层的：在 `workflow: full` 下，Polish → Release 闸门要求每个要交付的已翻译语言环境为 PASS 或 PASS WITH CONDITIONS（在 `standard` 下为建议，在 `minimal` 下舍弃）
- [ ] `freeze` 提问在用户回答前指明它将写入的文件——"This writes `production/localization/freeze-status.md`"

---

## Director Gate Checks

无。`/localize` 是流水线工具，不派发任何总监。它唯一派发的代理
是 `localization-lead`（运营层级的代理），且仅在
`cultural-review` 与 `qa` 模式下。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Extract — 新字符串建立键并在批准后追加

**Fixture:**
- `project.yaml` 中有 `engine.name: Godot`，因此代码根为 `src/`
- `src/ui/hud.gd` 用 `tr()` 包裹了三个字符串，而它们在
  `assets/data/strings/strings-en.json` 中没有条目
- 不存在 `production/localization/freeze-status.md`

**Input:** `/localize extract`

**Expected behavior:**
1. 技能扫描源文件中的本地化字符串引用，并与
   `assets/data/strings/` 中的表进行比对
2. 技能为每个未建键的字符串提议一个新条目，键的形式为
   `[category].[subcategory].[description]`（例如 `ui.hud.health_label`）
3. 每个新条目都带有 `context` 字段：出现位置、最大长度、
   占位符含义
4. 技能展示差异并询问 "May I write these new entries to
   `assets/data/strings/strings-en.json`?"
5. 批准后只写入新条目（而非整表替换）；
   结论为 COMPLETE

**Assertions:**
- [ ] 提议的键遵循 `[category].[subcategory].[description]`
- [ ] 每个新条目都包含 `context` 字段
- [ ] 在任何写入之前展示差异，且 "May I write" 指明 `assets/data/strings/strings-en.json`
- [ ] 只写入这三个新条目——现有条目不被重写
- [ ] 结论为 COMPLETE

---

### Case 2: 无子命令 — 打印用法并 FAIL

**Fixture:**
- 任意项目状态

**Input:** `/localize`

**Expected behavior:**
1. 技能在参数中找不到任何子命令
2. 技能输出用法（十个模式）并停止
3. 结论为 FAIL——缺少必需子命令

**Assertions:**
- [ ] 打印列出可用模式的用法
- [ ] 结论为 FAIL，原因为 "missing required subcommand"
- [ ] 不执行任何扫描、提取或校验工作
- [ ] 不写入任何文件，也不出现 "May I write" 询问

---

### Case 3: Validate — 按语言环境报告缺口，不写入任何内容

**Fixture:**
- `assets/data/strings/` 中有 `strings-en.json`、`strings-fr.json` 与
  `strings-de.json`
- `strings-de.json` 缺少英文源中存在的 4 个键
- 一个法语条目缺少其英文源具有的 `{playerName}` 占位符

**Input:** `/localize validate`

**Expected behavior:**
1. 技能读取 `assets/data/strings/` 中的每个字符串表文件
2. 对 `de`，将这 4 个键报告为 Completeness 缺口
3. 对 `fr`，在受影响键上报告 Placeholder 不匹配
4. 结果按语言环境与严重程度分组
5. 技能不写入任何内容——validate 是只读的

**Assertions:**
- [ ] 点名这 4 个缺失的键并归因到 `de` 语言环境
- [ ] 占位符不匹配针对 `fr` 语言环境及其键报告
- [ ] 输出按语言环境与严重程度分组
- [ ] 不写入或修改任何文件，也不出现 "May I write" 询问

---

### Case 4: 无字符串表时的 Status — NOT ASSESSED

**Fixture:**
- `assets/data/strings/` 不存在

**Input:** `/localize status`

**Expected behavior:**
1. 技能查找源字符串表但找不到
2. 整个 status 输出为 `NOT ASSESSED — no string table found`
3. 技能不生成全为零的覆盖率矩阵，也不把
   源语言行预填为 `100%`

**Assertions:**
- [ ] 输出为 `NOT ASSESSED — no string table found`
- [ ] 不生成计数为零的覆盖率矩阵
- [ ] 源语言不被报告为 `100%` 覆盖率
- [ ] 不写入任何文件（status 是只读的）

---

### Case 5: 总监闸门检查 — 无；文化评审使用 localization-lead

**Fixture:**
- `assets/data/strings/strings-en.json` 存在并含有面向玩家的字符串
- 任意评审模式

**Input:** `/localize cultural-review`

**Expected behavior:**
1. 技能派发 `localization-lead`，审计字符串与资源的文化
   敏感性
2. 发现以表格呈现，每条发现的严重程度为 BLOCKING、ADVISORY 或
   NOTE
3. 技能询问 "May I write this cultural review report to
   `production/localization/cultural-review-[date].md`?"
4. 不派发任何总监代理，输出中也不出现闸门 ID

**Assertions:**
- [ ] `localization-lead` 是唯一派发的代理
- [ ] 不调用任何总监闸门（creative、technical、producer、art），也不出现闸门跳过消息
- [ ] 每条发现都带有 BLOCKING、ADVISORY 或 NOTE 严重程度
- [ ] "May I write" 在报告写入前指明 `production/localization/cultural-review-[date].md`

---

### Case 6: 代码根无法解析时的 Scan — NOT ASSESSED，绝不报 "no hardcoded strings"

**Fixture:**
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md`
  内容为 `[TO BE CONFIGURED]`
- `src/` 与 `Assets/` 都存在，且都含有带硬编码字符串的 UI 代码
  （目录树有歧义）

**Input:** `/localize scan`

**Expected behavior:**
1. 技能尝试解析代码根但无法做到（没有引擎，且有两个候选根）
2. 对硬编码字符串搜索报告 `NOT ASSESSED — code root unresolved`，
   并说明哪些检查未运行
3. 它不猜测 `src/`，也不报告零命中或 "no hardcoded
   strings found"——那会被读成"没有需要本地化的内容"
4. 不写入任何内容——scan 是只读的

**Assertions:**
- [ ] 代码搜索的输出为 `NOT ASSESSED — code root unresolved`
- [ ] 不报告 "no hardcoded strings" 或零命中结果
- [ ] 不假定代码根为 `src/`
- [ ] 不写入任何文件，也不出现 "May I write" 询问

---

### Case 7: 对无人试玩过的语言环境执行 QA — NOT ASSESSED

**Fixture:**
- `assets/data/strings/strings-en.json` 与 `strings-fr.json` 存在且校验
  通过
- 无人试玩过法语构建：对功能、溢出、语境准确性或 VO 检查
  都没有游戏内观察记录

**Input:** `/localize qa`

**Expected behavior:**
1. 技能派发 `localization-lead` 制定 QA 计划
2. 基于试玩的检查没有结果，且没有未解决的 BLOCKING 发现，
   因此法语结论为 **NOT ASSESSED**，并点名每项未运行的检查
3. 不会仅凭字符串表就给出 PASS 或 PASS WITH CONDITIONS 结论
4. 技能询问 "May I write this localization QA report to
   `production/localization/loc-qa-fr-[date].md`?"；报告说明该语言环境
   尚未通过发布闸门的 QA

**Assertions:**
- [ ] 法语 Status 为 NOT ASSESSED，并点名未运行的检查
- [ ] 对未试玩的语言环境不给出 PASS 或 PASS WITH CONDITIONS
- [ ] "May I write" 在写入前指明 loc-qa 报告路径
- [ ] 报告不将该语言环境呈现为已清关进入 Polish → Release 闸门

---

## Protocol Compliance

- [ ] 未给出子命令时以用法和结论 FAIL 停止
- [ ] `scan`、`validate` 与 `status` 不写入任何文件
- [ ] 在写入字符串表（extract）或任何报告（brief、cultural-review、vo-pipeline 脚本、rtl-check、qa）之前，以目标路径询问 "May I write"
- [ ] Extract 只写入新条目的差异，绝不整表替换
- [ ] 代码根或字符串表缺失时报告 NOT ASSESSED，而不是零结果
- [ ] `qa` 按语言环境给出 PASS、PASS WITH CONDITIONS、NOT ASSESSED 或 FAIL，首个命中顺序为 FAIL → NOT ASSESSED → PASS WITH CONDITIONS → PASS
- [ ] 以 Recommended Workflow 链 / `/gate-check release` 交接结束

---

## Coverage Notes

- 代码根已解析的 `scan`（带文件路径与行号的发现）
  未单独测试；Case 6 覆盖无法解析的代码根。
- 当 `freeze-status.md` 显示 Status: ACTIVE 时的 `extract`（新键追加到
  `## Post-Freeze Changes` 并给出冻结违规警告）未测试。
- `freeze`（冻结前清单与 `AskUserQuestion` [A]/[B]）、`brief`、
  `vo-pipeline` 与 `rtl-check` 没有专门用例覆盖；`qa` 仅
  覆盖其 NOT ASSESSED 分支（Case 7）。
- `qa` 闸门说明——FAIL 只阻塞该语言环境的发布——需要
  多语言环境的实机运行来验证。
