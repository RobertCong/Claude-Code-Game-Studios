# Skill Test Spec: /qa-plan

## Skill Summary

`/qa-plan [sprint | feature: system-name | story: path]` 在实现之前生成 QA 计划。`sprint` 读取 `production/sprints/` 中最新的文件（若存在 `production/sprint-status.yaml` 则读取它）以获取用户故事列表；`feature:` 按系统名 glob `production/epics/*/story-*.md`；`story:` 加载单个文件；无参数时通过 `AskUserQuestion` 询问范围。被引用但不存在的用户故事文件会被标记为 MISSING，计划继续；范围中零个用户故事时停止，输出 `NOT ASSESSED — no stories in scope` 并给出路径（例如 "No sprint plan found. Run `/sprint-plan new`."）。

用户故事字段通过有针对性的 grep 收集。已声明的 `Type:` 按原样接受；缺失的类型从验收标准推断并标记为缺口。没有 `## Acceptance Criteria` 的用户故事会被完整读取并作为 QA 发现项报告，绝不跳过。在展示分类摘要表之后，展示计划（Test Summary、Automated Tests Required、Manual QA Checklist、Smoke Test Scope、Playtest Requirements、Definition of Done），然后通过一次 `AskUserQuestion`（multiSelect）询问是否写入 `production/qa/qa-plan-[sprint-slug]-[date].md`，以及是否回填用户故事文件中的 `## QA Test Cases`。`qa.level` 会改变计划的深度，但任何级别都不会删掉 Visual/Feel 和 UI 截图行。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含空范围用的结论关键词 `NOT ASSESSED`
- [ ] 写入前请求批准：一个 `AskUserQuestion` 选项指明 `production/qa/qa-plan-[sprint-slug]-[date].md`，以及规则 "Never write the plan without asking"
- [ ] 具备下一步交接（实现后用 `/smoke-check sprint`，`/story-done` 检查测试文件）

---

## Director Gate Checks

无。`/qa-plan` 是一个规划工具。它不生成任何代理（`Agent` 不在其允许工具中），且不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 含四个已分类用户故事的冲刺

**Fixture:**
- `production/sprints/sprint-003.md` 是最新的冲刺，引用 4 个
  用户故事文件，每个都有验收标准以及已声明的 Type：Logic、
  Integration、Visual/Feel、UI
- 这些用户故事引用 `design/gdd/` 中的 GDD；`engine.name: Godot`
- `qa.level: standard`；`modes.automation: collaborative`

**Input:** `/qa-plan sprint`

**Expected behavior:**
1. 技能读取最新的冲刺文件并报告 "Building QA plan for 4
   stories in [scope]."
2. 通过分节 grep 收集用户故事字段；每个已声明的 Type 都被接受，
   不重新分类
3. 在生成计划之前展示分类摘要表
4. 计划的 Test Summary 映射：Logic → `tests/unit/[system]/` 下的单元测试，
   Integration → `tests/integration/[system]/` 下的集成测试，
   Visual/Feel → 截图 + lead 签核，UI → 保留每个涉及界面的截图
5. 展示计划，然后一次 multiSelect `AskUserQuestion` 提供 "Write QA
   plan to production/qa/qa-plan-[sprint-slug]-[date].md" 以及用户故事
   回填选项
6. 写入后，下一步指明 `/smoke-check sprint`（实现后）
   和 `/story-done`

**Assertions:**
- [ ] 全部 4 个用户故事都出现在计划中，且各自的已声明 Type 保持不变
- [ ] 分类摘要表出现在计划之前
- [ ] Logic 和 Integration 行指明 `tests/unit/` 和 `tests/integration/` 下的测试路径
- [ ] UI 行的人工验证是保留每个涉及界面的截图，而不是逐步走查
- [ ] 在 multiSelect 批准前不写入任何内容，且写入路径为 `production/qa/qa-plan-[sprint-slug]-[date].md`
- [ ] 下一步指明 `/smoke-check sprint` 和 `/story-done`

---

### Case 2: 用户故事缺少验收标准，以及一个用户故事文件缺失

**Fixture:**
- 最新的冲刺文件引用 4 个用户故事路径
- 一个用户故事没有 `## Acceptance Criteria` 小节
- 一个被引用的用户故事路径在磁盘上不存在
- 其余 2 个用户故事完整

**Input:** `/qa-plan sprint`

**Expected behavior:**
1. 缺失路径被标记为 MISSING，计划继续
2. AC grep 无匹配的用户故事被完整读取，计划说明它没有
   可测试标准——这是 QA 发现项，而不是被跳过的用户故事
3. 2 个完整的用户故事被正常分类和规划
4. 写入前请求批准

**Assertions:**
- [ ] 缺失文件被报告为 MISSING，且不会导致整个计划失败
- [ ] 没有验收标准的用户故事被完整读取并作为 QA 发现项报告
- [ ] 该用户故事不会被静默地从计划中丢弃
- [ ] 两个完整的用户故事获得正常的测试分配

---

### Case 3: 模式变体 — qa.level minimal

**Fixture:**
- 与 Case 1 相同的 4 个用户故事冲刺
- `qa.level: minimal`

**Input:** `/qa-plan sprint`

**Expected behavior:**
1. 技能只生成最小冒烟计划
2. 省略 "Automated Tests Required" 小节，Test Summary 的
   "Automated Test Required" 列留空
3. Definition of Done 只删除测试文件和冒烟行；它仍然
   要求为 Visual/Feel 和 UI 用户故事保留每个涉及界面的截图，
   并为 Visual/Feel 用户故事提供已签核的证据文档——
   `qa.level` 可豁免测试，但绝不豁免截图
4. 写入前请求批准

**Assertions:**
- [ ] 不出现 "Automated Tests Required" 小节
- [ ] Test Summary 的自动化测试列为空
- [ ] Definition of Done 没有测试文件或冒烟检查行
- [ ] Definition of Done 仍要求为 Visual/Feel 和 UI 用户故事保留截图，并为 Visual/Feel 用户故事提供已签核的证据文档
- [ ] 写入计划前仍请求批准

---

### Case 4: 无冲刺计划 — NOT ASSESSED

**Fixture:**
- `production/sprints/` 不包含任何文件
- 没有 `production/sprint-status.yaml`
- `modes.rigor: standard`（因此预期有冲刺）

**Input:** `/qa-plan sprint`

**Expected behavior:**
1. 解析出的范围包含零个用户故事
2. 技能在 Phase 2 之前停止，并报告 `NOT ASSESSED — no stories in scope`，
   指明所搜索的范围和空路径
3. 技能给出路径："No sprint plan found. Run `/sprint-plan new`."
4. 不生成计划，也不请求写入批准

**Assertions:**
- [ ] 结论为 `NOT ASSESSED — no stories in scope`
- [ ] 指明空路径 `production/sprints/`
- [ ] 建议使用 `/sprint-plan new`
- [ ] 不生成带空表格的计划文档，也不写入任何内容

---

### Case 5: 总监闸门检查 — 无

**Fixture:**
- 一个含已分类用户故事和验收标准的冲刺
- 任意评审模式

**Input:** `/qa-plan sprint`

**Expected behavior:**
1. 技能分类用户故事并生成计划
2. 不生成任何总监或其他代理；不出现闸门 ID
3. 范围解析之后唯一的交互步骤是单次写入批准

**Assertions:**
- [ ] 未调用任何总监闸门，也不出现闸门跳过消息
- [ ] 不生成任何子代理
- [ ] Phase 2–4 运行期间不向用户询问任何内容
- [ ] 写入前恰好有一次批准提示

---

## Protocol Compliance

- [ ] 当范围为空时以 `NOT ASSESSED — no stories in scope` 停止，并指向负责生成的技能
- [ ] 将缺失的用户故事文件标记为 MISSING 并继续
- [ ] 接受已声明的 `Type:` 值；推断并标记缺失的 Type
- [ ] 绝不因缺少验收标准小节而跳过用户故事
- [ ] 在请求写入之前展示分类表和计划
- [ ] 仅在 `AskUserQuestion` 批准后写入；仅当选择该选项时才回填用户故事文件

---

## Coverage Notes

- `feature: [system-name]` 和 `story: [path]` 范围，以及无参数时的范围问题，
  未单独测试。
- 没有 `Type:` 字段的用户故事（从验收标准推断并标记为缺口）仅由协议合规性覆盖。
- 回填选项（在每个用户故事文件中编辑 `## QA Test Cases`）未详细测试。
- 在 `rigor: minimal` 下，空冲刺路径指向 `/qa-plan feature:` 或
  `/qa-plan story:`，而不是 `/sprint-plan new`；未单独测试。
