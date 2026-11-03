# Skill Test Spec: /dev-story

## Skill Summary

`/dev-story` 实现一个用户故事。它定位该用户故事（参数，否则使用
`production/session-state/active.md` 中的活跃用户故事），解析该用户故事所属
系统的工作流层级，按层级校验所需输入（TR 注册表、主导 ADR、控制清单），用一次
grep 读取 ADR 的 `## Status`、`## Last Verified` 和 `## Date` —— `Proposed`、
`Deprecated` 或 `Superseded` 状态会在所有层级阻塞该用户故事，而 ADR 字段为
`N/A` 的用户故事不引用任何 ADR —— 并通过将用户故事的 `ADR Version` 与 ADR
当前版本（`Last Verified`，否则 `Date`，否则 `unversioned` —— 即
`/create-stories` 写入的规则）比较来检查 ADR 的新鲜度。它检查用户故事的
`Manifest Version` 及其依赖，请求把用户故事标记为 `In Progress`，并把实现
路由给程序员代理（programmer agent）及项目引擎专家。它本身不写源代码，且它
写入的每个文件 —— 用户故事字段、`sprint-status.yaml`、依赖项的 `Status`、
Config/Data 文件、Unity 的 `ScreenshotOnArg.cs` —— 都遵循点名该文件的询问；
只有会话状态检查点无需询问即可写入。

代理返回后，它验证代理已完成，运行引擎解析检查（parse check），启动构建以观察
任何玩家可见的内容（`Run result:` 行），打印 "Implementation Complete" 摘要，
并覆盖 `active.md` 中的 CHECKPOINT 块，其 **Next step** 依据结果而定：
Implementation Complete 后为 `/story-done`，INCOMPLETE 后为 `/dev-story` 继续，
BLOCKED 后为解除阻塞的操作。它从不关闭自己实现的用户故事 —— 那是
`/story-done` 的职责；在 `standard`/`full` 下会先推荐 `/code-review`。在
`qa.level: minimal` 下，Logic 或 Integration 用户故事的测试要求被豁免并打印
豁免说明；UI 或 Visual/Feel 用户故事的截图绝不被豁免，且运行并观察步骤在所有
层级都会执行。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 包含状态关键词：BLOCKED、INCOMPLETE、In Progress、NOT VERIFIED
- [ ] 包含 "May I write" 协作协议用语（针对它写入的文件自行询问；源代码和测试委托给子代理）
- [ ] 结尾有下一步交接（`/story-done`，standard/full 下先 `/code-review`）
- [ ] 说明逐层级的输入要求（`full` / `standard` / `minimal`）
- [ ] 说明实现委托给专家代理（不直接执行）

---

## Director Gate Checks

无总监质量闸门。`/dev-story` 派发实现代理（一名主程序员和引擎专家），而非总监
评审闸门，也不解析 `review_mode`。代码评审由单独的 `/code-review` 技能负责，
在 `standard`/`full` 下被列为下一步。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 在 full 工作流下实现 Logic 用户故事

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`specialists.code: godot-gdscript-specialist`、
  `modes.workflow: full`、`qa.level: standard`
- `production/epics/combat/story-001-damage-calc.md`：`Status: Ready`、Layer Core、
  Type Logic、`Requirement: TR-combat-001`、`ADR Governing Implementation: ADR-0003`、
  `ADR Version` 等于 ADR-0003 的 `## Last Verified` 日期、`Manifest Version`
  等于清单头部日期、Dependencies 为 None、Test Evidence 为
  `tests/unit/combat/combat_damage_calc_test.gd`
- `docs/architecture/tr-registry.yaml` 含 `TR-combat-001`；ADR-0003 存在且为
  Accepted；`docs/architecture/control-manifest.md` 存在
- `production/sprint-status.yaml` 不存在

**Input:** `/dev-story production/epics/combat/story-001-damage-calc.md`

**Expected behavior:**
1. 读取用户故事并从注册表 Grep `id: TR-combat-001`
2. Grep ADR-0003 的 `^## (Status|Last Verified|Date)` —— Status 为 Accepted 且其
   当前版本（`Last Verified` 日期）与用户故事一致，因此不读取该 ADR
3. 从清单 Grep `^## Core Layer Rules`；Manifest Version 匹配，不询问
4. 询问 "May I mark this story In Progress?"，点名用户故事文件（而非不存在的
   `sprint-status.yaml`）；确认后把用户故事的 `Status:` 设为 `In Progress`
   及其 `Last Updated:`；打印 "Sprint status not updated:
   production/sprint-status.yaml absent"
5. 派发 `gameplay-programmer`，以 `godot-gdscript-specialist` 为副手，
   简报中内联用户故事路径、TR-ID 查找、用户故事的 ADR Decision Summary 和
   Implementation Notes、Core 层规则，以及带测试要求的测试文件路径
6. 确认代理完成，运行 Godot 解析检查并报告其退出码
7. 打印 "Implementation Complete: [title]"，含文件、测试函数数量、
   Verification 和 `Run result:` 行；下一步为 `/code-review` 然后 `/story-done`
8. 覆盖 `active.md` 中的 `<!-- CHECKPOINT -->` 块

**Assertions:**
- [ ] 当 ADR-0003 的 `Last Verified` 与用户故事的 `ADR Version` 匹配时，不完整读取该 ADR
- [ ] In Progress 询问点名用户故事文件；`Status:` 仅在其之后、任何代理派发之前变为 `In Progress`，并打印 sprint-status 缺失提示
- [ ] 主代理为 `gameplay-programmer`；副手来自 `specialists.code`，不是名册表
- [ ] ADR 指导以内联方式传递，而不是 ADR 路径
- [ ] 简报点名 `tests/unit/combat/combat_damage_calc_test.gd`（`[system]_[feature]_test.gd`），并要求每个验收标准一个测试
- [ ] 报告解析检查的命令和退出码，且恰好出现一行 `Run result:`
- [ ] 用户故事未被标记为 Complete；交接为 `/code-review` 然后 `/story-done`
- [ ] `active.md` 中的 CHECKPOINT 块被覆盖，而非追加

---

### Case 2: 失败路径 —— 引用的 ADR 为 Proposed

**Fixture:**
- `project.yaml`：`modes.workflow: standard`
- 用户故事文件 `Status: Ready`，`ADR Governing Implementation: ADR-0005`
- `docs/architecture/adr-0005-*.md` 存在，`## Status` 为 Proposed

**Input:** `/dev-story production/epics/[epic-slug]/story-[NNN]-[slug].md`

**Expected behavior:**
1. 技能读取用户故事并解析为 `standard` 层级
2. 技能判断所引用的 ADR-0005 为 Proposed
3. 用户故事在会话状态中被置为 BLOCKED；不派发任何程序员代理
4. 输出点名 ADR-0005 并推荐 `/architecture-decision accept ADR-0005`
5. 生成部分报告；用户故事文件的 `Status:` 不变

**Assertions:**
- [ ] Proposed 状态取自 ADR-0005 的 `## Status` 小节，而非推断
- [ ] 不派发任何程序员或引擎专家代理
- [ ] 输出点名 ADR-0005 并推荐 `/architecture-decision`
- [ ] 用户故事头部保持 `Status: Ready`，且不显示 "May I mark this story In Progress?" 询问
- [ ] BLOCKED 记录在会话状态中，且检查点的 **Next step** 点名 `/architecture-decision accept ADR-0005` —— 而不是 `/story-done`

---

### Case 2b: 失败路径 —— `full` 层级的 Proposed ADR

文件检查表的 `full` 列有自己的 STOP 规则，因此上面的 `standard` 用例
并未覆盖它。

**Fixture:**
- `project.yaml`：`modes.workflow: full`
- 用户故事文件 `Status: Ready`、`ADR Governing Implementation: ADR-0005`，且
  `ADR Version` 早于 ADR-0005 的 `## Last Verified` 日期
- `docs/architecture/adr-0005-*.md` 存在，`## Status` 为 Proposed；
  `docs/architecture/tr-registry.yaml` 和控制清单存在

**Input:** `/dev-story production/epics/[epic-slug]/story-[NNN]-[slug].md`

**Expected behavior:**
1. 技能 Grep ADR-0005 的 `^## (Status|Last Verified|Date)` 并读到 `Proposed`
2. 在新鲜度比较之前停止："ADR [path] is still Proposed. Accept
   it with `/architecture-decision accept ADR-0005` before implementing."
3. 用户故事在会话状态中被置为 BLOCKED；不派发任何程序员代理

**Assertions:**
- [ ] 停止发生在 `full` 下
- [ ] Status 先于新鲜度检查决定：尽管版本不同，也不显示 ADR 版本不匹配提示，且除这一次 Grep 外不读取该 ADR
- [ ] 不派发任何程序员或引擎专家代理，用户故事保持 `Status: Ready`

---

### Case 3: 用户故事编写后 ADR 发生变更

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: full`
- 用户故事文件 `Status: Ready`、Type Logic、`Requirement: TR-combat-002`、
  `ADR Governing Implementation: ADR-0004`，`ADR Version` 早于 ADR-0004 的
  `## Last Verified` 日期，`Manifest Version` 等于清单头部日期，
  Dependencies 为 None
- `docs/architecture/tr-registry.yaml` 含 `TR-combat-002`；ADR-0004 存在，
  `## Status` 为 Accepted 且小于 50KB；`docs/architecture/control-manifest.md`
  存在
- 用户在提示处选择 `[A]`

**Input:** `/dev-story production/epics/[epic-slug]/story-[NNN]-[slug].md`

**Expected behavior:**
1. 对 ADR-0004 执行 `Grep "^## (Status|Last Verified|Date)"`，读到 Accepted 和一个
   不同于用户故事 `ADR Version` 的 `Last Verified` 日期
2. `AskUserQuestion`："Story was written against ADR v[story-date]. The ADR is now
   v[current-date]. Its decision may have changed. How do you want to proceed?"
   选项为 `[A] Re-read the changed ADR sections…`（点名刷新本用户故事的
   ADR 摘要和 ADR Version） / `[B] Implement from the story's summary…` /
   `[C] Stop…`
3. 选择 [A] 时：用 `wc -c` 检查大小；小于约 50KB 时，用一次 `Read` 读取该 ADR
4. 将用户故事的 `ADR Version` 设为 ADR-0004 的 `Last Verified` 日期，并用重新
   读取的指导替换其 ADR Decision Summary 和 Implementation Notes
5. 以内联方式把该指导传给程序员代理并派发

**Assertions:**
- [ ] 不匹配提示在任何代理派发之前显示
- [ ] 提供全部三个选项（[A] 重读 / [B] 接受偏差 / [C] 停止），且 [A] 点明它将做的用户故事编辑
- [ ] 选择 [A] 时检查大小，且小于 50KB 的 ADR 用单次 `Read` 读取
- [ ] 在派发程序员代理之前，用户故事的 `ADR Version` 变为 ADR-0004 的 `Last Verified` 日期 —— 而不是今天的日期
- [ ] 程序员代理简报携带新读取的 Decision 指导内联内容，而不是 [A] 之前用户故事持有的摘要

**Fixture (Date fallback):**
- 同上，但 ADR-0004 没有 `## Last Verified` 小节；其 `## Date` 等于用户故事的
  `ADR Version`（即 `/create-stories` 从中写入的值）

**Expected behavior (Date fallback):**
1. 同一次 Grep 未找到 `Last Verified`，因此该 ADR 的当前版本为其 `## Date`
2. 这与用户故事的 `ADR Version` 匹配：信任该用户故事，不显示提示，
   也不读取该 ADR

**Assertions (Date fallback):**
- [ ] 不显示不匹配提示 —— 依据 `## Date` 写入的 ADR 不会因缺少 `## Last Verified` 而被视为过期
- [ ] 除这一次 Grep 外不读取 ADR-0004

---

### Case 4: 边界情况 —— 无参数；从会话状态读取

**Fixture:**
- 未提供参数
- `production/session-state/active.md` 引用一个活跃用户故事文件
- 该用户故事文件存在，`Status: In Progress`

**Input:** `/dev-story`（无参数）

**Expected behavior:**
1. 技能检测到未提供参数
2. 技能读取 `production/session-state/active.md`
3. 技能找到活跃用户故事引用
4. 技能与用户确认："Continuing work on [story title] — is that correct?"
5. 确认后，技能继续处理该用户故事

**Assertions:**
- [ ] 未提供参数时，技能读取会话状态
- [ ] 技能在继续之前与用户确认活跃用户故事
- [ ] 技能不会在未确认的情况下静默假定活跃用户故事

**Fixture (no active story):**
- 未提供参数
- `production/session-state/active.md` 未指定活跃用户故事
- `production/epics/` 中有两个 `Status: Ready` 的用户故事和一个 `In Progress`

**Expected behavior (no active story):**
1. 技能询问 "Which story are we implementing?"
2. 它 Glob `production/epics/**/*.md` 并列出两个 `Status: Ready` 的用户故事

**Assertions (no active story):**
- [ ] 询问该问题，而不是猜测用户故事
- [ ] 只列出 `Status: Ready` 的用户故事

---

### Case 5: minimal 层级，Logic 用户故事 —— 测试豁免

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: minimal`、`qa.level: minimal`
- 用户故事 Type Logic，`Requirement: Brief MVP feature 1`，ADR 字段为
  `N/A (minimal — no ADRs)`
- 无 TR 注册表、无 ADR、无控制清单
- `docs/engine-reference/godot/VERSION.md` 将固定的版本评为 HIGH 风险

**Input:** `/dev-story production/epics/[slug]/story-001-[slug].md`

**Expected behavior:**
1. Phase 2 不会因缺少注册表、ADR 或清单而停止或置为 BLOCKED
2. 派发之前打印 `Briefing omits: …` 行，点名 TR 注册表、
   ADR 指导和控制清单
3. 派发 `gameplay-programmer` 及引擎专家（VERSION.md 风险 HIGH）
4. 简报省略测试要求，并告知代理："Do not write a test
   file for this story — test evidence is waived at `qa.level: minimal`."
5. Phase 5 被跳过；摘要打印 "Test evidence: waived at
   `qa.level: minimal` — no test was required or written for this story."
6. 运行并观察仍会执行，并打印一行 `Run result:`
7. 下一步直接为 `/story-done [story-path]` —— 不经过 `/code-review`

**Assertions:**
- [ ] 在 `minimal` 下不因缺少 TR 注册表、ADR 或清单而 STOP 或 BLOCKED
- [ ] `Briefing omits:` 行点名全部三个被丢弃的输入，包括 ADR
- [ ] 因 VERSION.md 将风险评为 HIGH 而派发引擎专家
- [ ] 向代理说明测试豁免，并在摘要中打印；不出现测试行或 "run your test suite" 段落
- [ ] 打印 `Run result:` 行 —— 运行并观察不被豁免
- [ ] 交接为 `/story-done`，无 `/code-review` 步骤

---

### Case 5b: minimal 层级，UI 用户故事 —— 仍需要截图

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: minimal`、`qa.level: minimal`
- 用户故事 Type UI，`Requirement: Brief MVP feature 2`，ADR 字段为
  `N/A (minimal — no ADRs)`
- 无 TR 注册表、无 ADR、无控制清单

**Input:** `/dev-story production/epics/[slug]/story-002-[slug].md`

**Expected behavior:**
1. 派发 `ui-programmer`；简报中没有测试项，也没有 "Do not write a test
   file" 句子 —— 测试要求始终只覆盖 Logic 和 Integration
2. 摘要打印 "Retained screenshot required under
   `production/qa/evidence/[story-slug]/` before this story can be closed…"
3. 运行并观察在 `production/qa/evidence/[story-slug]/` 下保留截图，
   并打印 `Run result: OBSERVED — …` 及路径
4. 下一步为 `/story-done [story-path]`

**Assertions:**
- [ ] 不告知 UI 用户故事其证据被豁免 —— 简报和摘要中的 "Test evidence: waived" 行都不出现
- [ ] 在 `qa.level: minimal` 下打印需要截图的提示行
- [ ] `Run result: OBSERVED` 点名一张保留的截图；`NOT VERIFIED` 结果会作为阻塞项报告，而不是备注
- [ ] 交接为 `/story-done`，无 `/code-review` 步骤

---

### Case 6: Unity —— 代码位于 `Assets/` 下，需请求写入捕获脚本

**Fixture:**
- `project.yaml`：`engine.name: Unity`、`specialists.code: unity-specialist`、
  `specialists.ui: unity-ui-specialist`、已设置 `commands.smoke` 和 `commands.run`、
  `modes.workflow: minimal`、`qa.level: minimal`
- 用户故事 Type UI（一个背包界面），`Requirement: Brief MVP feature 3`，ADR
  字段为 `N/A (minimal — no ADRs)`
- 项目有 `Assets/` 且没有 `src/`；`Assets/` 下不存在 `ScreenshotOnArg.cs`
- `docs/engine-reference/unity/VERSION.md` 将固定的版本评为 HIGH 风险

**Input:** `/dev-story production/epics/[slug]/story-003-[slug].md`

**Expected behavior:**
1. 以 `unity-specialist`（`specialists.code`）和 `unity-ui-specialist`
   （`specialists.ui`，针对 UI 用户故事）派发 `ui-programmer`
2. 简报将代码写入 `Assets/Scripts/<System>/`，即 Unity 代码根目录
3. 验证运行 `commands.smoke` 并报告其退出码
4. 启动之前，Glob `Assets/**/ScreenshotOnArg.cs`，未找到则询问
   "May I write `Assets/Scripts/ScreenshotOnArg.cs`?"；确认后按
   `.trae/docs/run-and-observe.md` 原样写入该脚本
5. 以 `--scene`/`--screenshot` 启动构建后的玩家程序，并打印
   `Run result: OBSERVED — …` 及保留路径

**Assertions:**
- [ ] 不在 `src/` 下写入任何文件 —— Godot 的路径不是默认值
- [ ] 两个专家都来自 `specialists` 块，而不是名册表
- [ ] `ScreenshotOnArg.cs` 仅在其询问之后写入，位置为 `Assets/Scripts/`，与 run-and-observe.md 给出的内容完全一致
- [ ] 若用户拒绝该询问，结果为 `Run result: NOT VERIFIED — ScreenshotOnArg.cs not written`，而不是观察到结果
- [ ] 验证点名 `commands.smoke` 及其退出码

---

### Case 7: 引擎未设置 —— 代码根目录无法解析，不写入任何内容

**Fixture:**
- `project.yaml` 没有 `engine` 块；`.trae/docs/technical-preferences.md`
  内容为 `Engine: [TO BE CONFIGURED]`
- 项目没有 `src/`、`Assets/` 或 `Source/` 中的任何一个
- `modes.workflow: minimal`；用户故事为 Type Logic

**Input:** `/dev-story production/epics/[slug]/story-001-[slug].md`

**Expected behavior:**
1. 代码根目录无法解析（`.trae/docs/code-root-resolution.md`：没有
   `engine.name`、没有旧的 `Engine:` 值、目录树中没有唯一明确根目录）
2. 不写入任何源文件，输出说明代码根目录未解析

**Assertions:**
- [ ] 不在 `src/` 或任何其他猜测的根目录下创建文件
- [ ] 输出将未解析的代码根目录列为未写入任何内容的原因
- [ ] 不打印 "Implementation Complete"

---

### Case 8: 通过选项 [C] 将依赖标记为 Complete

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: minimal`、`qa.level: minimal`
- `story-003` 在 Dependencies 下列出 `story-002`；`story-002` 为
  `Status: In Progress`
- 在依赖提示处用户选择 `[C]`，然后批准更新

**Input:** `/dev-story production/epics/[slug]/story-003-[slug].md`

**Expected behavior:**
1. 读取 story-002 的 `Status:` 并询问："Story '[story-003 title]' depends on
   '[story-002 title]' which is currently In Progress, not Complete. How do you
   want to proceed?"，选项为 `[A] Proceed anyway` / `[B] Stop` / `[C] The dependency
   is done but status wasn't updated — mark it Complete and continue`
2. 选择 [C] 时询问 "May I update `production/epics/[slug]/story-002-[slug].md` Status
   to Complete?"
3. 确认后将 story-002 的 `Status:` 设为 `Complete`，然后继续 story-003

**Assertions:**
- [ ] 依赖提示在任何代理派发之前出现
- [ ] story-002 仅在 "May I update … Status to Complete?" 询问之后被编辑，且只改其 `Status:`
- [ ] story-003 本身不被标记为 Complete —— 它在自身询问之后被置为 In Progress
- [ ] 若用户选择 `[B]`，story-003 将在会话状态中为 BLOCKED，且不派发任何代理

### Case 9: 代理提前停止 —— INCOMPLETE，检查点提示继续

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: minimal`、`qa.level: minimal`
- 用户故事 Type Logic、`Status: Ready`、ADR 字段 `N/A (minimal — no ADRs)`
- 程序员代理报告：在添加 `src/combat/damage.gd` 后达到回合上限，而该文件调用了它
  从未定义的辅助函数

**Input:** `/dev-story production/epics/[slug]/story-001-[slug].md`

**Expected behavior:**
1. Phase 6 将该用户故事视为 INCOMPLETE：标题如此说明，列出已存在的内容，
   点名未定义的辅助函数，并提出继续运行代理
2. 不打印 "Implementation Complete"，用户故事的 `Status:` 不推进
3. 检查点的 **Next step** 为 `/dev-story [story-path] — resume: [the
   undefined helper]`

**Assertions:**
- [ ] 不出现 "Implementation Complete"，`Status:` 也不推进到 `In Progress` 之后
- [ ] 检查点的 **Next step** 为 `/dev-story [story-path]` 以继续 —— 绝不是 `/story-done`，`/help` 会把它读作“工作已完成”

---

### Case 10: `full` 层级，用户故事无主导 ADR（`ADR: N/A`）

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: full`
- 用户故事 `Status: Ready`、Type Logic、`ADR Governing Implementation: N/A — no
  architectural pattern required`（即 `/create-stories` 为 `/create-epics`
  标记为未追溯的需求写入的内容）
- `docs/architecture/tr-registry.yaml` 含该用户故事的 TR-ID；控制清单存在

**Input:** `/dev-story production/epics/[slug]/story-004-[slug].md`

**Expected behavior:**
1. Phase 2 将 ADR 字段读为 `N/A`：用户故事不引用任何 ADR，因此 `full`
   列的 "ADR file [path] not found" STOP 不触发，也不 Grep 任何 ADR
2. 用户故事不被置为 BLOCKED；实现继续，ADR 指导在 `Briefing omits:` 行中
   点名

**Assertions:**
- [ ] 在 `full` 下，`N/A` 的 ADR 字段不触发 STOP，也不置为 BLOCKED
- [ ] 不会为 `N/A` 查找任何 ADR 文件
- [ ] 变体 —— 用户故事点名 `ADR-0006`，其 `## Status` 为 `Superseded by ADR-0009`：该用户故事在所有层级都被 BLOCKED，输出点名 ADR-0009 并说明要编辑其 ADR 字段（`/create-stories` 从不重写已有用户故事）

---

### Case 11: 两个 TR-ID 共享前缀 —— 注册表查找匹配精确 id

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: full`（固定：`full` 下
  需要 TR 注册表，因此查找总会运行）
- `docs/architecture/tr-registry.yaml` 先列出 `TR-combat-0010`，再列出
  `TR-combat-001`，各自为 `- id: TR-combat-NNN` 后跟自己的 `requirement:`
  行。`TR-combat-0010` 内容为 "Enemies drop loot on death"；`TR-combat-001` 内容为
  "Damage is clamped to the target's remaining health"
- 用户故事 A：`Requirement: TR-combat-001`。用户故事 B：`Requirement: TR-combat-0010`。
  两者 `Status: Ready`、Type Logic、ADR 主导字段为 `N/A`、Dependencies 为 None

**Input:** `/dev-story production/epics/combat/story-A-[slug].md`，随后对用户故事 B 相同

**Expected behavior:**
1. 对用户故事 A，注册表 grep 锚定行尾
   （`id: TR-combat-001\s*$`），因此 `id: TR-combat-0010` 不匹配
2. 匹配到的条目为 `TR-combat-001`；保留并简报给代理的是其 `requirement` 文本
   （"Damage is clamped…"）
3. 对用户故事 B，grep 只返回 `TR-combat-0010` 条目及其
   "Enemies drop loot on death" 需求
4. 两次运行都不读取整个注册表

**Assertions:**
- [ ] 用户故事 A 的简报携带 `TR-combat-001` 需求文本，绝不是 `TR-combat-0010` 的文本，尽管 `TR-combat-0010` 在文件中先出现
- [ ] 用户故事 B 的简报携带 `TR-combat-0010` 需求文本
- [ ] grep 模式以 `\s*$` 结尾（或以其他方式精确匹配），因此任何一次查找都不会返回另一个 id 的条目
- [ ] 两个用户故事都不完整读取整个注册表

---

## Protocol Compliance

- [ ] 不直接编写源代码 —— 委托给专家代理
- [ ] 在任何代理派发之前解析工作流层级并校验所需输入
- [ ] 不匹配和依赖提示（`AskUserQuestion`）在实现之前出现
- [ ] 技能自身写入的每个文件 —— 用户故事字段、`sprint-status.yaml`、依赖项的 `Status`、Config/Data 文件、`ScreenshotOnArg.cs` —— 都遵循点名该文件的询问；只有 `active.md` 检查点无需询问即可写入
- [ ] 代码只写入解析后的代码根目录；根目录未解析时不写入任何内容
- [ ] 跳过的阶段和丢弃的简报项在输出中声明
- [ ] 对提前停止的代理（INCOMPLETE）绝不输出 "Implementation Complete"
- [ ] 覆盖 `production/session-state/active.md` 中的 CHECKPOINT 块
- [ ] 以下一步交接结尾：`/story-done`（standard/full 下先 `/code-review`）

---

## Coverage Notes

- 代码根目录覆盖了 Godot（`src/`）和 Unity（`Assets/`，Case 6），以及
  引擎未解析的情况（Case 7）。Unreal（`Source/<Module>/<System>/`，以
  编辑器目标构建作为解析检查）未提供 fixture。
- INCOMPLETE 路径为 Case 9；引擎二进制不可用时的 `parse NOT VERIFIED`
  未提供 fixture。
- Manifest Version 不匹配提示（`[A]` 更新 / `[B]` 保留旧规则，记录
  `Manifest-Note` / `[C]` 停止）遵循 Case 3 的“派发前询问”模式，
  未单独测试。
- Config/Data 用户故事（不派发代理）以及 `testing.strict` 逐类型覆盖
  未覆盖。
