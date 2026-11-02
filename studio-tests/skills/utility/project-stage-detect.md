# Skill Test Spec: /project-stage-detect

## Skill Summary

`/project-stage-detect [role]` 判定项目的开发阶段及其缺口。它先执行一次确定性检查
（`bash .claude/scripts/artifact-check.sh`，逐个产出物报告 PRESENT / ABSENT / SHORT /
PATTERN_MISS / NO_CHECK），然后扫描 `design/`、代码根目录、
`production/`、`prototypes/`、`docs/architecture/` 与 `tests/`。

已配置的阶段（`project.yaml` 中的 `project.stage`，否则使用旧式的
`production/stage.txt`）对该阶段是什么具有权威性，但技能始终也会运行自己的
启发式判断，并在产出物与之不符时明确说明。启发式判断从最先进的阶段倒序检查：
Production = 代码根目录有 10 个以上源文件；Pre-Production = 引擎已配置、源文件
少于 10 个；Technical Setup = 有系统索引、无引擎；Systems Design = 有概念、
无完整系统索引；Concept = 无概念文档；Polish 与 Release 仅能显式判定。解析出的
工作流层级决定哪些缺失文档计为缺口（`minimal` 下 GDD/ADR/冲刺均不计）。代码根目录
无法解析意味着源文件未被计数：`NOT ASSESSED — code root unresolved`，绝不写作
零个文件。

报告携带 **Stage Confidence**，先匹配者优先：FAIL（关键缺口阻碍进展）→ CONCERNS
（信号含糊 —— 配置阶段与观测阶段不一致时总是如此）→ NOT ASSESSED（阶段所依赖的某项
检查未运行，并点名）→ PASS（清晰检出）。在 `workflow: minimal` 下，配置阶段从不
推进（该路径上没有 `/gate-check`），因此它落后于观测阶段会被报告，但不构成不一致。
技能展示摘要、缺口与下一步，然后询问 "May I write the full stage analysis to
production/project-stage-report.md?"。它从不写入阶段本身。不适用任何
总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含全部七个阶段名称：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release
- [ ] 包含 Stage Confidence 取值 PASS、CONCERNS、NOT ASSESSED 与 FAIL，并给出先匹配顺序
- [ ] 在写入 `production/project-stage-report.md` 前包含 "May I write" 措辞
- [ ] 具备下一步交接（Follow-Up Actions 点名 `/map-systems`、`/reverse-document`、`/architecture-decision`、`/sprint-plan`、`/milestone-review`）

---

## Director Gate Checks

无。`/project-stage-detect` 是诊断工具。它不派生任何代理
（`Agent` 不在其允许工具内），也不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: Configured Stage Matches the Artifacts

**Fixture:**
- `project.yaml` 含 `project.stage: Production` 与 `engine.name: Godot`
- `src/` 有 24 个源文件；`design/gdd/` 有 4 个 GDD 与 `systems-index.md`，
  每个被索引的系统对应一个 GDD
- `docs/architecture/` 含 `architecture.md` 与 5 个 ADR；`design/art/art-bible.md`
  与 UX 规格均存在；`tests/unit/` 中每个系统都有测试 —— `full` 层级会标记的
  文档类型均不缺失，因此没有缺口需要权衡
- `production/sprints/sprint-002.md` 存在
- 解析出的工作流层级：`full`

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 技能在手工扫描之前运行 `bash .claude/scripts/artifact-check.sh`
2. 技能从 `project.yaml` 读取配置阶段 `Production`
3. 技能仍运行启发式判断；24 个源文件（10+）表明为 Production
4. 报告说明配置阶段与观测阶段一致；Stage Confidence 为 PASS
5. 技能展示摘要、缺口与下一步，然后询问 "May I write the full
   stage analysis to production/project-stage-report.md?"

**Assertions:**
- [ ] `artifact-check.sh` 作为首个扫描步骤运行
- [ ] 检出的阶段为 Production，启发式结果与配置结果一并报告
- [ ] Stage Confidence 为 PASS
- [ ] "May I write" 指明 `production/project-stage-report.md`，且批准前不写入任何内容
- [ ] `project.yaml` 与 `production/stage.txt` 均未被修改

---

### Case 2: No Configured Stage — Inferred From Artifacts, Role Filter Applied

**Fixture:**
- `project.yaml` 中没有 `project.stage`，也没有 `production/stage.txt`
- `engine.name: Godot`；`src/` 有 14 个源文件
- `design/gdd/` 有 3 个 GDD；`docs/architecture/` 没有 ADR
- 解析出的工作流层级：`full`

**Input:** `/project-stage-detect programmer`

**Expected behavior:**
1. 技能找不到配置阶段，进而从启发式判断自动检出
2. 14 个源文件（10+）→ 阶段 Production
3. programmer 角色把建议聚焦于架构文档、测试覆盖
   与缺失的 ADR
4. 缺失的 ADR 作为缺口呈现并附澄清问题，同时
   建议 `/architecture-decision` 或 `/reverse-document architecture`
5. 技能在写入报告前询问；任何地方都不写入阶段值

**Assertions:**
- [ ] 推断出的阶段为 Production，依据是 10+ 源文件规则
- [ ] 针对 programmer 角色，建议聚焦于架构文档、测试与 ADR
- [ ] ADR 缺口以澄清问题的形式表述，而不仅是列出
- [ ] 不向 `project.yaml` 或 `production/stage.txt` 写入任何阶段值

---

### Case 3: Configured Stage Contradicted by the Artifacts

**Fixture:**
- `project.yaml` 含 `project.stage: Release`
- `engine.name: Godot`；`src/` 有 2 个源文件；没有 ADR、没有架构
  文档、没有史诗（epic）
- 解析出的工作流层级：`full`

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 技能读取配置阶段 `Release`
2. 启发式判断指向 Pre-Production（引擎已配置、源文件少于 10 个）
3. 技能报告两者，并明确说明它们不一致 —— 配置阶段可能已过时，
   或存在本仓库之外的工作
4. 配置值不会被静默替换，不一致也不会被一个自信的结果
   掩盖

**Assertions:**
- [ ] 输出点明配置阶段（Release）与观测阶段（Pre-Production）二者
- [ ] 不一致被明确说明
- [ ] Stage Confidence 为 CONCERNS（信号含糊），或若同时发现关键缺口则为 FAIL —— 绝不为 PASS
- [ ] 配置阶段既不被静默覆盖，也不在任何文件中被重写

---

### Case 4: Minimal Workflow Tier — Absent Docs Are Not Gaps

**Fixture:**
- 解析出的工作流层级：`minimal`
- `project.yaml` 含 `project.stage: Concept`，与 `/start` 写入的一致 —— 最小路径上
  没有任何环节运行 `/gate-check`，因此它从未推进
- `design/game-brief.md` 存在；`engine.name: Godot`；`src/` 有 5 个源文件
- 没有 GDD、没有美术圣经、没有 ADR、没有史诗、没有冲刺计划

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 技能使用解析出的层级 `minimal`，而不是假定某一层级
2. 它把一份简报加一个引擎视为正常状态
3. 它不会把缺失的 GDD、美术圣经、UX 规格、ADR、史诗或冲刺
   计划标记为缺口
4. 它不会因缺失 GDD 而建议 `/reverse-document`，也不会建议 `/sprint-plan`
5. Production 一行通过简报的构建顺序来报告用户故事，绝不
   写作 "no sprint plan"
6. 启发式判断观测到 Pre-Production（引擎已配置、源文件少于 10 个）；配置的
   Concept 被报告为在此层级尚未推进 —— 属预期滞后，而非不一致 —— 因此它本身
   不会使 Stage Confidence 变为 CONCERNS

**Assertions:**
- [ ] 缺失的 GDD、美术圣经、ADR、史诗或冲刺计划均未列为缺口
- [ ] 不因缺失 GDD 而建议 `/reverse-document`（此夹具已有简报；Case 7 覆盖缺失简报的情况），也不建议 `/sprint-plan`
- [ ] Production 完整度一行引用简报的构建顺序
- [ ] 配置的 Concept 阶段未被报告为与观测阶段不一致
- [ ] 报告仍在 "May I write" 询问之后提供

---

### Case 5: Director Gate Check — None; Declined Write Leaves No File

**Fixture:**
- 任意项目状态
- 任意评审模式
- 用户在 "May I write" 询问处拒绝

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 技能完成检测并展示摘要
2. 不派生任何总监或其他代理；不出现闸门 ID
3. 技能询问 "May I write the full stage analysis to
   production/project-stage-report.md?"
4. 用户拒绝；不创建文件

**Assertions:**
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 不派生任何子代理
- [ ] 摘要先于写入询问展示
- [ ] 拒绝后不创建 `production/project-stage-report.md`

---

### Case 6: Unresolved Code Root — NOT ASSESSED, not a greenfield project

**Fixture:**
- 没有 `project.stage`，没有 `production/stage.txt`
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md`
  写为 `[TO BE CONFIGURED]`
- `src/` 与 `Assets/` 均存在，且各自持有源文件（目录树含糊）
- `design/gdd/game-concept.md` 与 `design/gdd/systems-index.md` 存在，每个被索引的
  系统都有 GDD；`docs/architecture/` 持有 Foundation 层
  的 ADR —— `standard` 层级会标记的内容均不缺失
- 解析出的工作流层级：`standard`

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 代码根目录无法解析（无引擎、两个候选根目录），因此
   源文件计数不运行
2. Source Code 一节写为 `NOT ASSESSED — code root unresolved` —— 而不是
   "0 source files"，项目也不会被称为全新项目（greenfield）
3. 缺少计数时，Production 行（10+ 源文件）既不能确认也不能排除 —— 其下的
   各行会指向 Technical Setup（有系统索引、无引擎）—— 因此报告说明哪项检查
   未运行，而不是静默地落在较低阶段
4. 没有配置阶段且没有缺口，因此没有更高等级可排：Stage Confidence 为
   **NOT ASSESSED**，并点名未解析的代码根目录。两个候选根目录是
   该检查无法运行的原因，而非含糊信号（CONCERNS）

**Assertions:**
- [ ] 不报告源文件数为零；Source Code 行为 `NOT ASSESSED — code root unresolved`
- [ ] 不假定代码根目录为 `src/`
- [ ] Stage Confidence 为 NOT ASSESSED，并点名未运行的检查 —— 不为 PASS
- [ ] 报告仍在 "May I write" 询问之后提供

---

### Case 7: Minimal Workflow, No Game Brief — The follow-up depends on how much code exists

**Fixture:**
- 解析出的工作流层级：`minimal`
- 没有 `project.stage`，没有 `production/stage.txt`；`engine.name: Godot`（代码根目录 `src/`）
- 没有 `design/game-brief.md`，没有 `design/gdd/` 文件，没有冲刺计划
- 场景 (a)：`src/` 有 14 个源文件
- 场景 (b)：`src/` 有 3 个源文件

**Input:** `/project-stage-detect`

**Expected behavior:**
1. 技能使用解析出的层级 `minimal`；缺失的 GDD、ADR、史诗与冲刺计划仍不算缺口
2. 缺失的 `design/game-brief.md` 被报告，Follow-Up Actions 处理它
3. (a) 代码根目录已包含游戏（10 个或更多源文件），因此后续为 `/reverse-document design src/` —— 简报由已构建的内容生成 —— 而不是 `/brainstorm`
4. (b) 代码很少时后续为 `/brainstorm`，而不是 `/reverse-document`
5. 两种情况下都不建议 `/sprint-plan`；报告仍在 "May I write" 询问之后提供

**Assertions:**
- [ ] 缺失的游戏简报在 `minimal` 下被报告
- [ ] (a) 建议 `/reverse-document design <code root>`，点名解析出的代码根目录（`src/`），且不建议 `/brainstorm`
- [ ] (b) 建议 `/brainstorm`，不建议 `/reverse-document`
- [ ] 两种场景中的建议都以源文件计数（10 个或更多）为条件，计数在解析出的代码根目录中进行
- [ ] 不报告任何 GDD、ADR、史诗或冲刺计划缺口，也不建议 `/sprint-plan`

---

## Protocol Compliance

- [ ] 在手工扫描产出物之前运行 `artifact-check.sh`
- [ ] 存在时读取 `project.stage`（其次 `production/stage.txt`），并始终同时运行启发式判断
- [ ] 配置阶段与观测阶段不一致时明确说明
- [ ] 仅在解析出的工作流层级允许的范围内呈现缺口，每个缺口都附澄清问题
- [ ] 以 PASS / CONCERNS / NOT ASSESSED / FAIL 报告 Stage Confidence，先匹配 FAIL → CONCERNS → NOT ASSESSED → PASS；配置/观测不一致为 CONCERNS
- [ ] 对未解析的代码根目录报告为 `NOT ASSESSED — code root unresolved`，绝不写作零个源文件
- [ ] 在写入 `production/project-stage-report.md` 前询问 "May I write"；从不写入阶段值

---

## Coverage Notes

- Concept（无概念文档）与 Technical Setup（有系统索引、无引擎）沿用
  同一张启发式表，未单独做夹具测试。
- Polish 与 Release 是仅能显式判定的阶段；它们只能来自
  配置值，Case 3 已覆盖。
- `standard` 层级（仅标记已构建系统缺失的 GDD 与关键 ADR）
  未被单独测试。
