# Skill Test Spec: /adopt

## Skill Summary

`/adopt` 审计既有项目的产出物——GDD、ADR、用户故事、基础设施文件与
`technical-preferences.md`——检查其格式是否符合模板技能流水线的要求。它按严重程度
（BLOCKING / HIGH / MEDIUM / LOW）对每处差距分类，编排一份编号且有序的迁移计划，
并在用户通过 `AskUserQuestion` 明确批准之后写入
`docs/adoption-plan-[date].md`。

解析后的 `workflow` 层级限定审计范围：`full` 要求全部 8 个 GDD 章节，
`standard` 要求 5 个（数值系统另需 Formulas），而 `minimal`——默认值，因为
`modes.rigor` 默认为 `minimal`——改为审计 `design/game-brief.md`，并且仅作为
建议性检查审计任何现有 GDD，计划中也不规定基础设施引导（`/architecture-review`、
`/create-control-manifest`、`/sprint-plan`、`/gate-check` 都不在 minimal 路径上）。
因此，涉及 GDD 与 ADR 审计的 Fixture 会在 `project.yaml` 中设置 `modes.rigor: full`。

v1.0 项目（没有 `project.yaml`，旧版配置含真实值）只能由
`.trae/scripts/migrate-v1-config.sh` 迁移——先 `--dry-run`，在询问并指明其写入
的文件之后才真正运行，`--finalize` 则留到用户读过迁移报告之后再执行。`/adopt`
从不写入评审模式；它只报告解析出的评审模式。

本技能与 `/project-stage-detect`（检查存在什么）不同。
`/adopt` 检查已有内容是否真的能与模板的技能配合工作。

不适用任何总监闸门。本技能不调用任何总监代理。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含严重程度层级关键词：BLOCKING、HIGH、MEDIUM、LOW
- [ ] 在写入采用计划之前包含 "May I write" 或 `AskUserQuestion` 措辞
- [ ] 结尾有下一步交接（例如提出立即修复优先级最高的差距）

---

## Director Gate Checks

无。`/adopt` 是遗留项目审计类实用技能。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 所有 GDD 合规，无 BLOCKING 或 HIGH 差距

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full`、`project.stage`，以及 `engine.name`、
  `engine.version`、`engine.language`、`engine.rendering`、`engine.physics`
- `design/gdd/` 包含 3 个 GDD 文件；每个都有全部 8 个必需章节且含内容，
  并有有效的 `> **Status**:` 字段
- `docs/architecture/adr-0001.md` 存在，含 `## Status`、`## ADR Dependencies`、
  `## Engine Compatibility`、`## GDD Requirements Addressed` 与 `## Performance Implications`
- `docs/architecture/tr-registry.yaml` 与 `docs/architecture/control-manifest.md` 存在
- `docs/engine-reference/[engine]/VERSION.md` 存在

**Input:** `/adopt`

**Expected behavior:**
1. 技能输出 "Scanning project artifacts..."，随后静默读取所有产出物
2. 报告检测到的阶段、GDD 数量、ADR 数量、用户故事数量
3. Phase 2 审计：对每个 GDD 路径各运行一次 `gdd-structure-check.sh`；3 个 GDD
   都具备全部 8 个章节与有效的 Status 字段
4. ADR 审计：所有关键章节均存在
5. 基础设施审计：注册表、清单与引擎参考资料均存在
6. Phase 3：零个 BLOCKING 且零个 HIGH 差距——项目被报告为
   与模板兼容，仅剩建议性改进（任何 MEDIUM/LOW 项，例如缺少
   `sprint-status.yaml`，都列为建议）
7. 使用 `AskUserQuestion` 询问是否写入计划；用户选择写入
8. 采用计划写入 `docs/adoption-plan-[date].md`
9. Phase 6b 报告解析出的评审模式（"Review mode resolves to `full` —
   from `modes.rigor`, unless something pins it"），且不为其写入任何内容
10. Phase 7 走 "no BLOCKING or HIGH" 分支："No blocking gaps — this project
   is template-compatible. What next?"

**Assertions:**
- [ ] 技能在呈现任何输出之前静默读取
- [ ] "Scanning project artifacts..." 出现在静默读取阶段之前
- [ ] 每个 GDD 都以显式路径调用 `gdd-structure-check.sh`（不是无参数调用）
- [ ] 差距计数显示 `BLOCKING: 0` 与 `HIGH: 0`，且项目被报告为与模板兼容
- [ ] 在写入采用计划之前使用 `AskUserQuestion`
- [ ] 采用计划文件写入 `docs/adoption-plan-[date].md`
- [ ] 不向 `project.yaml` 写入 `modes.review_mode`，也不创建 `production/review-mode.txt`——评审模式只被报告，从不固定
- [ ] Phase 7 通过 `AskUserQuestion` 询问 "No blocking gaps — this project is template-compatible. What next?"

---

### Case 2: Non-Compliant Documents — GDD 缺章节，存在 BLOCKING 与 HIGH 差距

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full` 并配置引擎
- `design/gdd/` 包含 2 个 GDD 文件：
  - `combat.md` — 缺少 `## Acceptance Criteria` 与 `## Formulas` 章节
  - `movement.md` — 全部 8 个章节均存在
- 一个 ADR（`adr-0001.md`）缺少 `## Status` 章节
- `docs/architecture/tr-registry.yaml` 不存在

**Input:** `/adopt`

**Expected behavior:**
1. 技能扫描所有产出物
2. Phase 2 审计发现：
   - `combat.md`：缺少 2 个章节（Acceptance Criteria、Formulas）
   - `adr-0001.md`：缺少 `## Status`——BLOCKING 影响
   - `tr-registry.yaml`：缺失——HIGH 影响
3. Phase 3 分类：
   - BLOCKING：`adr-0001.md` 缺少 `## Status`（用户故事就绪检查会静默通过）
   - HIGH：`tr-registry.yaml` 缺失；`combat.md` 缺少 Acceptance Criteria（无法生成用户故事）
   - MEDIUM：`combat.md` 缺少 Formulas
4. Phase 4 构建有序迁移计划：
   - 步骤 1（BLOCKING）：为 `adr-0001.md` 添加 `## Status`——命令：`/architecture-decision retrofit`
   - 步骤 2（HIGH）：运行 `/architecture-review` 以引导生成 tr-registry.yaml
   - 步骤 3（HIGH）：为 `combat.md` 添加 Acceptance Criteria——命令：`/design-system retrofit`
   - 步骤 4（MEDIUM）：为 `combat.md` 添加 Formulas
5. 差距预览把 BLOCKING 项以条目形式列出（写出实际文件名），HIGH/MEDIUM 以计数显示
6. `AskUserQuestion` 询问是否写入计划；获批后写入
7. Phase 7 提出立即修复优先级最高的差距（ADR Status）

**Assertions:**
- [ ] 差距预览中 BLOCKING 差距以显式文件名条目列出
- [ ] 差距预览中 HIGH 与 MEDIUM 以计数显示
- [ ] 迁移计划各项按 BLOCKING 优先排序
- [ ] 每个计划项都包含修复命令或手工步骤
- [ ] 写入之前使用 `AskUserQuestion`
- [ ] Phase 7 提出立即回填第一个 BLOCKING 项

---

### Case 3: Mixed State — 部分文档合规、部分不合规，报告不完整

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full` 并配置引擎、命名与性能
- 4 个 GDD 文件：2 个完全合规，2 个有差距（一个缺 Tuning Knobs，一个缺 Formulas）
- ADR：3 个文件——2 个合规，1 个缺 `## ADR Dependencies`
- 用户故事：5 个文件——3 个有 TR-ID 引用，2 个没有
- 基础设施：所有关键文件均存在

**Input:** `/adopt`

**Expected behavior:**
1. 技能审计所有产出物类型
2. 采用审计摘要显示 `GDDs audited: 4 (2 fully compliant, 2 with gaps)`、
   `ADRs audited: 3 (2 fully compliant, 1 with gaps)` 与 `Stories audited: 5`
3. 差距分类：
   - 无 BLOCKING 差距
   - HIGH：1 个 ADR 缺少 `## ADR Dependencies`
   - MEDIUM：2 个 GDD 缺章节（Tuning Knobs、Formulas）；2 个用户故事缺少 TR-ID
4. 差距预览没有 BLOCKING 条目，并以计数显示 HIGH / MEDIUM
5. 迁移计划先列 HIGH 差距，再列 MEDIUM 差距，且 GDD 差距先于用户故事差距
6. 包含说明："Existing stories continue to work — do not regenerate stories
   that are in progress or done"
7. 使用 `AskUserQuestion` 询问写入计划；获批后写入

**Assertions:**
- [ ] 摘要以 `N (X fully compliant, Y with gaps)` 与 `Stories audited: 5` 显示 GDD 与 ADR 计数
- [ ] 摘要显示 `BLOCKING: 0`，且差距预览不列出任何 BLOCKING 条目
- [ ] 2 个缺少 TR-ID 的用户故事被计为 MEDIUM 差距
- [ ] 计划中包含既有用户故事兼容性说明
- [ ] HIGH 差距先于 MEDIUM 差距；MEDIUM 的 GDD 差距先于 MEDIUM 的用户故事差距
- [ ] 写入之前使用 `AskUserQuestion`

---

### Case 4: No Artifacts Found — 全新项目，指引运行 /start

**Fixture:**
- 仓库在 `design/gdd/`、`docs/architecture/`、`production/epics/` 中没有任何文件
- `project.yaml` 中没有 `project.stage`，也没有 `production/stage.txt`
- 没有源代码：`src/`、`Assets/` 或 `Source/` 均不存在
- 没有 game-concept.md、没有 game-brief.md、没有 systems-index.md

**Input:** `/adopt`

**Expected behavior:**
1. Phase 1 的存在性检查未找到任何产出物
2. 技能推断为 "Fresh"——没有可迁移的遗留工作
3. 使用 `AskUserQuestion`：
   - "This looks like a fresh project — no existing artifacts found. `/adopt` is for
     projects with work to migrate. What would you like to do?"
   - 选项："Run `/start`"、"My artifacts are in a non-standard location"、"Cancel"
4. 用户选择 "Run `/start`"；技能说明后停止——不进行审计

**Assertions:**
- [ ] 未找到任何产出物时使用 `AskUserQuestion`（而不是纯文本消息）
- [ ] `/start` 作为具名选项呈现
- [ ] 在 `/start` 或 Cancel 之后技能停止——不运行审计阶段；"help me find them" 会进入搜索，而不是停止
- [ ] 不写入任何采用计划文件

---

### Case 5: Director Gate Check — 无闸门；minimal 层级把审计范围限定在简报

**Fixture:**
- `project.yaml` 配置了引擎，且没有 `modes` 块（`workflow`
  解析为 `minimal`）
- `design/game-brief.md` 存在
- `design/gdd/combat.md` 存在且缺少 `## Acceptance Criteria`

**Input:** `/adopt`

**Expected behavior:**
1. Phase 2 审计 `design/game-brief.md`；不预期 GDD、ADR 与 UX 规格
2. `combat.md` 按 `standard` 标准作为建议性检查——其缺少的 Acceptance
   Criteria 作为参考信息报告，而不计为 HIGH 差距
3. 计划不规定基础设施引导：其步骤 3 用一行说明它不在 minimal 路径上，并把
   `/create-stories` 命名为下一步（尚不存在用户故事）
4. 任何时点都不生成总监代理
5. 输出中不出现任何闸门 ID（CD-*、TD-*、AD-*、PR-*）
6. 技能运行期间不调用 `/gate-check`

**Assertions:**
- [ ] 审计 `design/game-brief.md`
- [ ] 缺失的 ADR 与 UX 规格不被报告为差距
- [ ] `combat.md` 缺少的 Acceptance Criteria 不计入 HIGH 总数
- [ ] 计划不规定 `/architecture-review`、`/create-control-manifest`、`/sprint-plan` 或 `/gate-check` 中的任何一项——它们都不在 minimal 路径上
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 技能在没有任何闸门结论的情况下到达计划写入或取消

---

### Case 6: v1.0 Project — 运行转换器，绝不手工迁移

**Fixture:**
- 仓库根目录没有 `project.yaml`
- `production/stage.txt` 内容为 `Production`；`.trae/docs/technical-preferences.md`
  含 `- **Engine**: Godot 4.6` 以及已填写的命名章节
- `design/gdd/` 含 GDD；没有 `production/migration-report.md`

**Input:** `/adopt`

**Expected behavior:**
1. Phase 2g 识别出需要迁移的 v1.0 项目（没有 `project.yaml`，
   旧版文件含真实、可迁移的值）
2. 它在审计期间运行 `bash .trae/scripts/migrate-v1-config.sh --dry-run`
   （试运行不写入任何内容）——它不会手工编写 `project.yaml`
3. 迁移在 Phase 3 被归类为 BLOCKING 并排在计划首位，计划报告试运行列出的内容
4. 计划之后，Phase 7 首先提出迁移：它询问 "May I run the
   converter? It writes `project.yaml` and `production/migration-report.md`."，
   并且仅在获批之后才不带 `--dry-run` 运行它
5. 它告知用户在运行 `bash .trae/scripts/migrate-v1-config.sh --finalize`
   之前先阅读 `production/migration-report.md`，且在用户读过报告之前不自行运行
   `--finalize`

**Assertions:**
- [ ] 在任何真实迁移之前运行 `--dry-run`，并报告其输出
- [ ] `project.yaml` 仅由转换器写入，且在指明 `project.yaml` 与 `production/migration-report.md` 的询问获批之后
- [ ] 在用户读过 `production/migration-report.md` 之前不运行 `--finalize`
- [ ] 迁移是 BLOCKING 项，且排在计划首位
- [ ] 运行期间不删除任何旧版文件

---

## Protocol Compliance

- [ ] 在静默读取阶段之前输出 "Scanning project artifacts..."
- [ ] 在呈现任何结果之前静默读取所有产出物
- [ ] 在询问是否写入之前展示采用审计摘要与差距预览
- [ ] 在写入采用计划文件之前使用 `AskUserQuestion`
- [ ] 采用计划写入 `docs/adoption-plan-[date].md`——不写入任何其他路径
- [ ] 迁移计划各项排序：BLOCKING 最先，HIGH 其次，MEDIUM 第三，LOW 最后
- [ ] Phase 7 始终给出单个具体的下一步动作（而不是通用列表）
- [ ] 绝不重新生成既有产出物——只填补已有内容中的差距
- [ ] 任何时点都不调用总监闸门

---

## Coverage Notes

- `gdds`、`adrs`、`stories` 与 `infra` 参数模式会缩小审计范围；
  每种模式都遵循与完整审计相同的模式，但只限于该产出物类型。
  此处未单独做 fixture 测试。
- systems-index.md 括号中状态值的检查（BLOCKING）是一个特例，
  会在写入计划之前触发立即修复提议；未单独测试。
- "help me find them" 路径（按标题搜索，每次移动前作为
  `file_deletions` 决策询问，绝不覆盖，然后重新运行 Phase 1）未给出
  fixture。
- Phase 6b 报告解析出的评审模式且不写入任何内容——`review_mode` 由
  `modes.rigor` 统领，因此固定它会遮蔽 rigor 的展开；Case 1
  断言不为它写入任何内容。
- 转换器的拒绝情形（当其值与配置不一致或迁移已运行时退出 3；`--finalize`
  在值不匹配时退出 4）未单独测试；Case 6 覆盖迁移本身。
