# Skill Test Spec: /reverse-document

## Skill Summary

`/reverse-document <type> <path>` 从已有实现反向推导出文档。`type` 为 `design`
（GDD，写入 `design/gdd/[system-name].md`）、`architecture`（ADR，写入
`docs/architecture/[decision-name].md`）或 `concept`（由原型生成的
概念文档）。它读取代码，执行充分性检查（当实现太少、无从推断时停止），
呈现发现结果以及代码无法回答的问题，起草文档，并询问
"May I write this to [output path]?"。

`design` 产出随解析出的工作流层级伸缩：`full` 下为 8 节 GDD，
`standard` 下为 5 节 GDD，`minimal` 下为一页简报（当路径为代码根目录时
为整款游戏的 `design/game-brief.md`，单个系统则为 `design/[system-name]-brief.md`）。
`architecture` 与 `concept` 产出与层级无关。用户未确认的意图会带入文档，
标记为 `INTENT UNKNOWN — inferred from implementation, not confirmed`，且每个文档都带有
"Reverse-documented from implementation" 来源横幅。不适用任何总监闸门。
结论（Verdicts）：COMPLETE（批准后写入文档）或 BLOCKED（用户拒绝写入）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE、BLOCKED
- [ ] 在写入文档前包含 "May I write" 协作协议措辞
- [ ] 具备下一步交接（阶段 8 后续清单，例如 `/balance-check`）

---

## Director Gate Checks

无。`/reverse-document` 是文档工具。不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: Well-Structured Source at `full` — 8-section GDD produced

**Fixture:**
- `project.yaml` 解析出 `workflow: full`；health 没有 `system_overrides` 行
- `src/gameplay/health_system.gd` 存在（约 80 行），含：
  - `@export var max_health: int = 100`
  - `func take_damage(amount: int)` 含
    `health = clamp(health - amount, 0, max_health)`
  - `signal health_changed(new_value: int)`
  - 所有公共方法都有文档字符串（Docstrings）
- 用户回答每个 `UNCLEAR INTENT AREAS` 问题并批准写入

**Input:** `/reverse-document design src/gameplay/health_system.gd`

**Expected behavior:**
1. 技能读取源码并通过阶段 3b 的充分性检查
2. 技能呈现发现结果（MECHANICS IMPLEMENTED、FORMULAS DISCOVERED、
   UNCLEAR INTENT AREAS），并在起草前等待回答
3. 技能起草 8 节 GDD（Overview、Player Fantasy、Detailed Rules、
   Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria）
4. Formulas 节记录 clamp 表达式；Tuning Knobs 列出
   `max_health = 100`
5. 来源横幅（"Reverse-documented from implementation … from
   `src/gameplay/health_system.gd`"）直接位于标题下方
6. 技能询问 "May I write this to `design/gdd/health-system.md`?"
7. 批准后写入文件；结论为 COMPLETE

**Assertions:**
- [ ] 在展示任何草稿之前，发现结果已被呈现并得到回答
- [ ] 8 个 GDD 节全部存在（层级解析为 `full`）
- [ ] clamp 表达式出现在 Formulas 中；`max_health = 100` 作为 Tuning Knob 出现
- [ ] 来源横幅直接位于标题下方
- [ ] "May I write" 指明 `design/gdd/` 下的路径
- [ ] 结论为 COMPLETE

---

### Case 2: Unanswered Intent — INTENT UNKNOWN carried into the draft

**Fixture:**
- `project.yaml` 解析出 `workflow: full`
- `src/gameplay/enemy_ai.gd` 存在（约 120 行），含：
  - 一个巡逻/追击/攻击状态机
  - 带使用位置的行内常量：`if distance < 150:`、`speed = 3.5`
  - 没有由输入计算玩法值的算术表达式
  - 没有注释或文档字符串
- 用户回复 "just draft it" 而不回答意图问题，然后
  批准写入

**Input:** `/reverse-document design src/gameplay/enemy_ai.gd`

**Expected behavior:**
1. 充分性检查通过（找到机制与调优值）
2. 发现结果在 MECHANICS IMPLEMENTED 下列出状态机，把两个
   常量列为值，并给出 `FORMULAS DISCOVERED: none found in the source`
3. UNCLEAR INTENT AREAS 询问这些常量代表什么（例如 150 是否为
   仇恨范围、单位是什么）
4. 由于问题未获回答，草稿把每个问题逐字带入，作为开放问题标记为
   `INTENT UNKNOWN — inferred from implementation, not
   confirmed` —— 不会把推断出的意图当作既定结论
5. 不虚构任何公式来填充 Formulas 节
6. 技能询问 "May I write this to `design/gdd/enemy-ai.md`?"；批准后结论为 COMPLETE

**Assertions:**
- [ ] `FORMULAS DISCOVERED` 写为 `none found in the source`（标题保留，不省略）
- [ ] 每个未回答的问题都以 `INTENT UNKNOWN — inferred from implementation, not confirmed` 标记出现在文档中
- [ ] 草稿中不出现代码里没有的公式或设计意图
- [ ] 在写入文件之前询问 "May I write"
- [ ] 结论为 COMPLETE

---

### Case 3: Architecture Type on Interdependent Files — tier-independent ADR

**Fixture:**
- `project.yaml` 解析出 `workflow: minimal`
- `src/core/combat/` 下有 `combat_system.gd` 与 `damage_resolver.gd`；
  `combat_system.gd` 通过注入的引用调用 `damage_resolver.gd`
- 用户回答架构问题并批准写入

**Input:** `/reverse-document architecture src/core/combat/`

**Expected behavior:**
1. 技能读取该目录路径下的每个文件
2. 阶段 2 的架构分析梳理两个文件之间的依赖与耦合
   （combat_system → damage_resolver）
3. 阶段 3 询问架构意图问题（例如为什么把 resolver
   注入），而不是只描述代码
4. 草稿使用 `architecture-doc-from-code.md` 模板 —— `minimal` 层级
   不会把它变成一页简报
5. 技能询问 "May I write this to `docs/architecture/[decision-name].md`?"；
   批准后结论为 COMPLETE

**Assertions:**
- [ ] 两个文件都被分析，且 combat_system → damage_resolver 依赖被记录
- [ ] 产出为 `docs/architecture/` 下的 ADR，而非 `design/gdd/` 或 `-brief.md`
- [ ] `minimal` 层级不改变架构产出
- [ ] 结论为 COMPLETE

---

### Case 4: Thin Source — Sufficiency check stops the run

**Fixture:**
- `src/gameplay/inventory_system.gd` 仅含
  `class_name InventorySystem`、`extends Node` 与一个空的 `_ready()` ——
  没有机制、没有公式、没有调优值（非样板代码不足 20 行）

**Input:** `/reverse-document design src/gameplay/inventory_system.gd`

**Expected behavior:**
1. 技能读取文件；阶段 3b 统计出 0 个机制、0 个公式、0 个值
2. 技能停止并提示："`src/gameplay/inventory_system.gd` does not contain enough
   implementation to reverse-document. Found: 0 mechanics, 0 formulas, 0 tuning
   values. …"
3. 技能指向 `/design-system [name]`，作为承接仅存在于用户头脑中的设计的
   技能
4. 不呈现发现结果，不产出草稿，不写入文件

**Assertions:**
- [ ] 停止消息点明路径与三个计数（均为 0）
- [ ] 建议 `/design-system` —— 而不是虚构一个骨架
- [ ] 不调用任何写入工具
- [ ] 不给出结论（运行在阶段 4 之前停止）

---

### Case 5: Director Gate Check — No gate; declined write is BLOCKED

**Fixture:**
- 与 Case 1 相同的源码；用户在 "May I write" 提示处拒绝

**Input:** `/reverse-document design src/gameplay/health_system.gd`

**Expected behavior:**
1. 技能执行分析、呈现发现结果并起草文档
2. 不派生任何总监代理；输出中不出现闸门 ID
3. 用户拒绝写入；不创建文件

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 结论为 BLOCKED（用户拒绝写入）—— 不涉及闸门结论

---

### Case 6: Default Tier — a single system becomes a one-page brief

**Fixture:**
- `project.yaml` 未设置 `modes.rigor` 也未设置 `modes.workflow`，因此解析出的
  层级为 `minimal` —— 即默认值；没有 `system_overrides`
- 与 Case 1 相同的源码（`src/gameplay/health_system.gd`）
- 用户回答每个 `UNCLEAR INTENT AREAS` 问题并批准写入

**Input:** `/reverse-document design src/gameplay/health_system.gd`

**Expected behavior:**
1. 层级由配置块解析为 `minimal`，而非假定
2. 在任何草稿之前呈现并回答发现结果
3. 草稿采用 `.claude/docs/templates/game-brief.md`
   格式，是针对这一个系统的一页游戏简报 —— 而非 GDD
4. 来源横幅直接位于标题下方
5. 技能询问 "May I write this to `design/health-system-brief.md`?" —— 不是
   `design/gdd/`，也不是整款游戏的简报 `design/game-brief.md`
6. 批准后写入文件；结论为 COMPLETE

**Assertions:**
- [ ] 产出为 game-brief 格式的简报，而非 8 节或 5 节 GDD
- [ ] 路径为 `design/[system-name]-brief.md`
- [ ] 来源横幅出现在标题下方
- [ ] 结论为 COMPLETE

---

### Case 7: Minimal Tier, Path Is the Code Root — the whole-game brief

**Fixture:**
- `project.yaml`：`engine.name: Godot`（代码根目录 `src/`）；`modes.rigor: minimal`（工作流 `minimal`）；没有 `system_overrides`
- `src/` 下是一个小型成品游戏：`src/gameplay/health_system.gd`（同 Case 1）、`src/gameplay/enemy_ai.gd`（同 Case 2）以及启动游戏循环的 `src/main.gd` —— 共 14 个源文件
- 没有 `design/game-brief.md`
- 用户回答每个 `UNCLEAR INTENT AREAS` 问题并批准写入

**Input:** `/reverse-document design src/`

**Expected behavior:**
1. 层级由配置块解析为 `minimal`；路径就是代码根目录，因此目标是整款游戏，而非单个系统
2. 在任何草稿之前呈现并回答发现结果
3. 草稿采用 `.claude/docs/templates/game-brief.md` 格式，是覆盖整款游戏（提案、核心循环、已构建内容）的一页游戏简报，而不是 GDD，也不是单个系统的简报
4. 来源横幅直接位于标题下方
5. 技能询问 "May I write this to `design/game-brief.md`?" —— 不是 `design/gdd/`，也不是 `design/[system-name]-brief.md` 路径
6. 批准后写入文件；结论为 COMPLETE

**Assertions:**
- [ ] 产出为 game-brief 格式、覆盖整款游戏的一页简报
- [ ] 路径为 `design/game-brief.md`，不是 `design/[system-name]-brief.md`，也不在 `design/gdd/` 下
- [ ] 来源横幅出现在标题下方，且用户未确认的任何意图都标记为 `INTENT UNKNOWN — inferred from implementation, not confirmed`
- [ ] "May I write" 指明 `design/game-brief.md`，且在写入文件之前询问
- [ ] 结论为 COMPLETE

**Case 7b — a path inside the code root:** 相同夹具，输入 `/reverse-document design src/gameplay/health_system.gd`。

**Assertions (7b):**
- [ ] 简报写入 `design/health-system-brief.md`（Case 6），绝不写入 `design/game-brief.md`

---

## Protocol Compliance

- [ ] 在生成任何内容之前读取源码
- [ ] 当机制、公式与值全部计数为零时，在阶段 3b 的充分性检查处停止
- [ ] 等待意图问题的回答；未回答的问题作为 `INTENT UNKNOWN` 带入
- [ ] `design` 产出与解析出的层级匹配（`full` 为 8 节，`standard` 为 5 节，`minimal` 为简报 —— 路径为代码根目录时是 `design/game-brief.md`，单个系统时是 `design/[system-name]-brief.md`）
- [ ] 在其写入的每个文档标题下输出来源横幅
- [ ] 在创建任何输出文件之前询问 "May I write"
- [ ] 结论为 COMPLETE（已写入）或 BLOCKED（拒绝写入）

---

## Coverage Notes

- `standard` 层级（5 节 GDD，不含 Player Fantasy 与 Tuning Knobs）
  沿用 Case 1 的流程，只是节集合不同；未单独
  做夹具测试。`minimal` 简报对单个系统为 Case 6，对
  整款游戏为 Case 7。
- `concept` 类型（原型 → `prototypes/[name]/CONCEPT.md` 或
  `design/concepts/[name].md`）未被单独测试。
- `guided` 与 `autonomous` 自动化模式会按
  `automation-modes.md` 改变写入提示；此处只测试 `collaborative`。
