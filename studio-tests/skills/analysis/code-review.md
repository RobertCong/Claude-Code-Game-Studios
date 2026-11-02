# Skill Test Spec: /code-review

## Skill Summary

`/code-review [file(s)] [story-path]` 对源文件执行架构评审。它读取
目标文件与项目编码标准（Phase 1），
从 `project.yaml` 解析引擎专家（Phase 2），通过只读取被引用 ADR 的
`## Decision` 与 `## Consequences` 章节来检查合规性（Phase 3），然后评估六项
标准检查、架构与 SOLID，以及游戏特定关注点（Phases 4–6）。适用的引擎专家——
以及针对 Logic/Integration 用户故事的 `qa-tester`——被并行生成，每个
专家发现都记录 file/line、证据以及 VERIFIED /
UNVERIFIED 置信度（Phase 7）。报告（Phase 8）以结论结束，首个
匹配生效：CHANGES REQUIRED、NOT ASSESSED（没有可评审内容、引擎
专家评审未运行，或某个报告章节——例如对无法读取的被引用 ADR 的 ADR Compliance——
显示 NOT ASSESSED）、APPROVED WITH
SUGGESTIONS、APPROVED。它仅从 Bash 授予 `git log`。Phase 9
通过 `AskUserQuestion` 提供下一步。技能为只读，不调用任何
总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：APPROVED、APPROVED WITH SUGGESTIONS、CHANGES REQUIRED、NOT ASSESSED
- [ ] 不要求 "May I write" 措辞（只读；声明不写入任何文件）
- [ ] 有下一步交接（如何处理发现项）

---

## Director Gate Checks

无。代码评审在任何评审模式下都不调用总监闸门。它确实会生成
引擎专家与 `qa-tester` 作为评审者（Phase 7）；它们不是闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 符合标准且遵循其 ADR 的文件

**Fixture:**
- `project.yaml`：`engine.name: godot`、`specialists.code: godot-gdscript-specialist`、`specialists.shader: null`、`specialists.ui: null`
- `src/gameplay/health_component.gd` 满足 Phase 4 的全部六项检查：
  - 每个公共方法与类都有文档注释（`##`）
  - 每个方法的圈复杂度低于 10，且行数低于 40
  - 依赖注入；无单例
  - 所有调参值从 `assets/data/` 加载
  - 依赖接口，而非具体类
- 头部注释：`# Implements ADR-0004 (docs/architecture/adr-0004-health.md)`
- `docs/architecture/adr-0004-health.md` 有 `## Decision` 与 `## Consequences` 章节，且代码遵循所选方案
- 专家报告没有问题；没有可建议的内容

**Input:** `/code-review src/gameplay/health_component.gd`

**Expected behavior:**
1. 技能读取源文件与编码标准
2. 技能在文件头部找到 `ADR-0004` 引用
3. 技能 grep ADR 的 `^## ` 标题，然后只读取 `## Decision` 与 `## Consequences` 段落
4. 通过 `Agent` 为 `.gd` 文件生成 `godot-gdscript-specialist`；`shader: null` 与 `ui: null` 被视为未设置，不生成
5. 报告显示 ADR Compliance: COMPLIANT、Standards Compliance: 6/6 passing、Engine Specialist Findings: CLEAN、Testability: `N/A — no story path given`，以及 Positive Observations 章节
6. 结论为 APPROVED
7. Phase 9 `AskUserQuestion` 提供 [A] Run `/story-done` 与 [B] Stop here

**Assertions:**
- [ ] ADR 通过标题映射与对 `## Decision` 和 `## Consequences` 的受限读取来读取，而非无界完整读取
- [ ] 为 `.gd` 文件生成 `godot-gdscript-specialist`；不生成任何名为 `null` 的代理
- [ ] Standards Compliance 显示 `6/6 passing`，ADR Compliance 显示 COMPLIANT
- [ ] Testability 显示 `N/A — no story path given`；没有用户故事时不生成 `qa-tester`
- [ ] Positive Observations 章节存在
- [ ] 结论为 APPROVED，Phase 9 提供 `/story-done` 或停止
- [ ] 不写入或编辑任何文件

---

### Case 2: Changes Required — 缺少文档注释与使用单例，无 ADR

**Fixture:**
- `project.yaml`：`engine.name: godot`、`specialists.code: godot-gdscript-specialist`
- `src/ui/inventory_ui.gd` 有：
  - 2 个公共方法（`refresh_slots`、`sort_items`）没有文档注释
  - 第 42 与 87 行使用了 `GameManager.instance`
  - 其他所有标准均满足
- 文件头部没有 ADR 引用，也没有触及它的提交提到 ADR
- 未传入用户故事路径

**Input:** `/code-review src/ui/inventory_ui.gd`

**Expected behavior:**
1. 技能在文件头部与 `git log --oneline -- src/ui/inventory_ui.gd` 中搜索 `ADR-NNNN` 引用，均未找到
2. 输出注明："No ADR references found — ADR compliance check skipped. For full ADR compliance review, provide the story path: `/code-review [files] [story-path]`."
3. Standards Compliance 显示 4/6 passing，并带行号引用列出失败项：两个未加文档的方法与第 42、87 行的单例
4. Required Changes 列出缺失的文档注释与单例，修复方案为依赖注入
5. 结论为 CHANGES REQUIRED
6. Phase 9 提供 [A] Fix the issues and re-run `/code-review`、[B] Run `/story-done` anyway with noted exceptions、[C] Stop here

**Assertions:**
- [ ] "No ADR references found" 注记指明了该命令的带 story-path 形式
- [ ] 缺失的文档注释以方法名（`refresh_slots`、`sort_items`）列出，而不仅是行号引用
- [ ] 单例使用被标记并带有文件与行号（42、87）
- [ ] Standards Compliance 显示 `4/6 passing`
- [ ] 结论为 CHANGES REQUIRED，Phase 9 提供三个 CHANGES REQUIRED 选项
- [ ] 技能不编辑该文件

---

### Case 3: Architectural Violation — 代码使用了其 ADR 拒绝的模式

**Fixture:**
- `project.yaml`：`engine.name: godot`、`specialists.code: godot-gdscript-specialist`
- `src/core/save_system.gd` 头部：`# Implements ADR-0010 (docs/architecture/adr-0010-save-format.md)`
- `adr-0010-save-format.md` 的 `## Decision`：存档数据经由 `SaveService` 以 JSON 处理；明确拒绝游戏代码直接进行 `FileAccess` 写入
- `save_system.gd` 在第 58 行直接用 `FileAccess.open(..., FileAccess.WRITE)` 写入存档数据
- 代码在其他方面满足全部六项标准检查

**Input:** `/code-review src/core/save_system.gd`

**Expected behavior:**
1. 技能只读取 ADR-0010 的 Decision 与 Consequences 章节
2. 直接的 `FileAccess` 写入被分类为 ARCHITECTURAL VIOLATION (BLOCKING)——即 ADR 明确拒绝的模式
3. ADR Compliance 显示 VIOLATION，列出 ADR-0010、结果以及带严重级别的偏差
4. 该违规出现在 Required Changes 下
5. 结论为 CHANGES REQUIRED
6. 下一步：修复实现以符合 `docs/architecture/adr-0010-save-format.md`，或——如果设计确实发生了变更——运行 `/architecture-decision` 修订现有 ADR，而不是创建一个竞争性 ADR

**Assertions:**
- [ ] 偏差被分类为 ARCHITECTURAL VIOLATION (BLOCKING)，而非 ADR DRIFT 或 MINOR DEVIATION
- [ ] ADR Compliance 显示 VIOLATION 并指明 ADR-0010
- [ ] 违规列在 Required Changes 下
- [ ] 结论为 CHANGES REQUIRED
- [ ] 输出要求遵循现有 ADR 或通过 `/architecture-decision` 修订它，绝不写入竞争性 ADR

---

### Case 4: Edge Case — 指定路径下没有源文件

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `src/networking/` 不存在

**Input:** `/code-review src/networking/`

**Expected behavior:**
1. 技能将其输入记录为 FOUND / ABSENT；目标源文件为 ABSENT
2. 每个必需输入都为 ABSENT，因此技能在产出评审章节之前停止
3. 输出报告 `NOT ASSESSED — NO DATA` 作为整体结论，指明 `src/networking/` 缺失
4. 不生成任何专家或 `qa-tester` 代理
5. 不填写任何评审章节，结果也不以 APPROVED 呈现

**Assertions:**
- [ ] 路径不存在时技能不崩溃
- [ ] 输出指明尝试的路径 `src/networking/`
- [ ] 结论为 `NOT ASSESSED — NO DATA`，而非 APPROVED
- [ ] 没有可评审内容时不生成任何专家代理

---

### Case 5: No Engine Configured — 被跳过的专家会说明自身；无闸门

**Fixture:**
- `project.yaml` 有 `modes.review_mode: full` 且没有 `engine.name`；`.claude/docs/technical-preferences.md` 显示 `[TO BE CONFIGURED]`
- `src/gameplay/loot_system.gd` 在第 31 行硬编码掉落率 `0.05`；其他一切均满足标准

**Input:** `/code-review src/gameplay/loot_system.gd`

**Expected behavior:**
1. Phase 2 发现未配置引擎，跳过引擎专家步骤
2. 输出记录 `Engine validation: NOT ASSESSED — no engine configured (engine.name unset in project.yaml)`
3. Engine Specialist Findings 显示 `N/A — no engine configured`；不生成任何引擎专家
4. Standards Compliance 列出 "Configuration values loaded from data files" 失败项及第 31 行，修复方案列在 Required Changes 下
5. 结论为 CHANGES REQUIRED——已知缺陷优先于被跳过的引擎评审，报告仍会说明后者
6. 在任何评审模式下都不调用总监闸门
7. 不编辑任何文件

**Assertions:**
- [ ] 输出包含 `Engine validation: NOT ASSESSED — no engine configured` 行
- [ ] Engine Specialist Findings 显示 `N/A — no engine configured`，且不生成任何引擎专家代理
- [ ] 硬编码值在 Standards Compliance 下被报告，并带行号引用
- [ ] 结论为 CHANGES REQUIRED，而非 NOT ASSESSED，也绝不是 APPROVED
- [ ] 即使在评审模式 `full` 下也不调用总监闸门
- [ ] 不做任何代码编辑

---

### Case 5b: No Engine Configured, Clean File — NOT ASSESSED，绝不 APPROVED

**Fixture:**
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md` 显示 `[TO BE CONFIGURED]`
- `src/gameplay/loot_table.gd` 满足 Phase 4 的全部六项检查，且不引发架构、SOLID 或游戏特定关注点

**Input:** `/code-review src/gameplay/loot_table.gd`

**Expected behavior:**
1. Phase 2 记录 `Engine validation: NOT ASSESSED — no engine configured`；不生成任何引擎专家
2. Required Changes 或 Suggestions 下不列出任何内容
3. 结论为 NOT ASSESSED，并指明未运行的引擎专家评审
4. Phase 9 提供 NOT ASSESSED 选项，并指明 `/setup-engine` 是让评审完整的方式

**Assertions:**
- [ ] 结论为 NOT ASSESSED，而非 APPROVED——跳过引擎检查的评审并未批准代码
- [ ] 结论指明引擎专家评审是未运行的部分
- [ ] Phase 9 不提供 `/story-done`；它指明 `/setup-engine`

### Case 6: Referenced ADR missing — 章节的 NOT ASSESSED 会传导到结论

**Fixture:**
- `project.yaml`：`engine.name: godot`、`specialists.code: godot-gdscript-specialist`
- `src/gameplay/stamina.gd` 满足 Phase 4 的全部六项检查，且不引发
  架构、SOLID 或游戏特定关注点；专家报告其为干净
- 其头部显示 `# Implements ADR-0008 (docs/architecture/adr-0008-stamina.md)`，
  而该文件不存在

**Input:** `/code-review src/gameplay/stamina.gd`

**Expected behavior:**
1. Phase 3 找到 `ADR-0008` 引用，但无法读取该 ADR
2. ADR Compliance 显示 `NOT ASSESSED — ADR-0008 could not be read`
3. Required Changes 或 Suggestions 下不列出任何内容
4. 结论为 NOT ASSESSED，并指明 ADR Compliance 章节与 ADR-0008

**Assertions:**
- [ ] ADR Compliance 显示 NOT ASSESSED 并指明 ADR-0008——不是 `NO ADRS FOUND`，也不是 COMPLIANT
- [ ] 结论为 NOT ASSESSED，绝不是 APPROVED：无法评估的章节会传导到结论
- [ ] 变体——文件完全未指明 ADR：ADR Compliance 显示 `NO ADRS FOUND`，结论为 APPROVED（缺失引用与无法读取的引用不同）

---

## Protocol Compliance

- [ ] 在评审之前读取目标文件与编码标准（Phase 1）
- [ ] 从 `project.yaml` 读取 `specialists` 块，回退到 `technical-preferences.md`；`null` 专家被跳过，绝不生成
- [ ] 报告中的每个专家发现都带有 file/line、证据，以及 VERIFIED 或 `UNVERIFIED — specialist claim`
- [ ] 不编辑任何源文件（只读技能）
- [ ] 不调用任何总监闸门
- [ ] 结论，首个匹配：CHANGES REQUIRED、NOT ASSESSED、APPROVED WITH SUGGESTIONS、APPROVED——当引擎专家评审未运行或任何报告章节显示 NOT ASSESSED 时绝不给出批准
- [ ] `allowed-tools` 授予 `Bash(git log *)` 与受限的 `yaml-helper.sh resolve_config` 模式，而非裸 `Bash`——技能为只读：它运行 `git log` 与配置解析器，别无其他
- [ ] Phase 9 的提示与选项分支使用与 Phase 8 报告相同的结论词汇

---

## Coverage Notes

- 对目录的批量评审未单独测试；同样的检查逐文件
  应用。
- `qa-tester` 可测试性评审（Logic 与 Integration 用户故事，用户故事路径
  作为最后一个参数传入）没有单独用例。
- 测试文件存在性检查属于 `/test-evidence-review` 的职责。
