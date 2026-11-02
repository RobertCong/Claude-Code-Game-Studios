# Skill Test Spec: /quick-design

## Skill Summary

`/quick-design [brief description of the change]` 为小到不足以编写完整 GDD 的变更生成轻量级快速设计规格（Quick Design Spec）。它首先将变更分类为 **Tuning**、**Tweak**、**Addition** 或 **New Small System**，并通过 `AskUserQuestion` 确认分类，其选项 `[F]` 会转向 `/design-system`。若变更引入的系统具有显著的跨系统依赖、需要约一周以上的工作量，或改变系统的核心规则，则改为转向 `/design-system`（结论 `REDIRECTED`）。

它随后扫描上下文（`design/gdd/` 中的相关 GDD、系统索引（若存在）、`design/quick-specs/` 中的先前规格——每个都要点名，无论一致还是冲突——以及 Tuning 情况下的 `assets/data/`），按其类别格式起草规格，完整呈现并提供批准 / 修订 / 转向选项，批准后询问 “May I write this Quick Design Spec to `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`?”。规格所需的任何 GDD 编辑都会单独询问，并展示旧文本与新文本。它以交接块和结论 `COMPLETE` 结束。

该技能没有总监质量闸门（director gate），也不解析 `review_mode`；按设计，快速规格会绕过 `/design-review` 和 `/review-all-gdds`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：`COMPLETE`、`REDIRECTED`
- [ ] 包含 “May I write” 协作协议用语（针对快速规格文件，以及单独针对任何 GDD 更新）
- [ ] 结尾包含下一步交接
- [ ] 说明快速规格按设计绕过 `/design-review` 和 `/review-all-gdds`，并列出何时应转向完整流水线
- [ ] 记录将超范围变更转向 `/design-system` 的范围检查

---

## Director Gate Checks

无。该技能只解析 `automation` 和 `workflow`（不解析 `review_mode`），`allowed-tools` 中没有 `Agent` 工具，也不启动任何总监或专家代理。评审模式设置对它没有影响。

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 对现有系统做 Tweak

**Fixture:**
- `design/gdd/movement.md` 存在，并在其 Detailed Rules 中描述冲刺无敌
- `design/gdd/systems-index.md` 存在
- `design/quick-specs/dash-cooldown-tuning-[earlier-date].md` 调整了 movement 中的冲刺冷却，未涉及无敌

**Input:** `/quick-design make dash invincible on frame 1`

**Expected behavior:**
1. 技能将变更分类为 Tweak，并询问 “I've classified this as **Tweak** — [reason]. Is that correct?”，选项为 `[A]`–`[F]`
2. 上下文扫描读取 `design/gdd/movement.md` 的相关小节、系统索引和 `design/quick-specs/`，并报告 “Found GDD at `design/gdd/movement.md`. Relevant section: [section]. Prior quick specs for this system: `design/quick-specs/dash-cooldown-tuning-[earlier-date].md` — agrees.”
3. 它起草 Tweak/Addition 格式：Change Summary、Motivation、Design Delta（引用当前 GDD 规则）、New Rules / Values、Affected Systems、Acceptance Criteria、GDD Update Required?
4. 它呈现完整草稿，然后以 `[A] Approve — write it as shown` / `[B] Revise — I'll describe what to change` / `[C] This grew too large — redirect to /design-system instead` 询问
5. 选择 `[A]`：询问 “May I write this Quick Design Spec to `design/quick-specs/dash-invincibility-tweak-[YYYY-MM-DD].md`?”——用户同意后，如有需要创建 `design/quick-specs/`，并写入文件
6. 由于规格改变了 `movement.md` 中的一条规则，它随后单独询问 “May I update `design/gdd/movement.md` — specifically the [section] section?”，并先展示旧文本与新文本
7. 它打印交接块（路径、类型、系统、GDD 更新状态）和 “Verdict: **COMPLETE**”

**Assertions:**
- [ ] 在任何上下文扫描或起草之前，通过 `AskUserQuestion` 确认分类
- [ ] 即使先前的冲刺冷却规格并不冲突，也在上下文报告中点名它
- [ ] 草稿使用 Tweak/Addition 格式，且其 Design Delta 引用当前 GDD 文本
- [ ] 在询问写入审批之前展示完整草稿
- [ ] 文件路径为 `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`，日期为当天
- [ ] GDD 编辑在快速规格写入之后单独询问，并展示旧文本与新文本
- [ ] 运行以交接块和结论 `COMPLETE` 结束

---

### Case 2: 失败路径 — 范围过大；转向 /design-system

**Fixture:**
- Scenario (a)：请求为 “redesign the entire combat system”
- Scenario (b)：已起草一个 Tweak，在批准步骤用户选择 `[C] This grew too large — redirect to /design-system instead`

**Input:** (a) `/quick-design redesign the entire combat system` (b) `/quick-design allow combo to cancel into roll`

**Expected behavior:**
1. (a) 该变更改变了系统的核心规则，因此技能在起草前停止并转向 `/design-system`——直接转向，或通过分类提示的选项 `[F]`
2. (b) 技能在批准步骤停止
3. 两种情况下都输出：“Verdict: **REDIRECTED** — use `/design-system` for this change.”
4. 不在 `design/quick-specs/` 下写入任何文件

**Assertions:**
- [ ] (a) 检测到范围超限，技能在起草前停止
- [ ] (a) 即使技能在分类组件之前就停止，也会打印结论行，而不只是通过 `[F]` 时才打印
- [ ] 消息将 `/design-system` 指明为替代方案
- [ ] 不写入任何快速规格文件
- [ ] 结论为 `REDIRECTED`，而不是 `COMPLETE`

---

### Case 3: 边界情况 — 调参超出文档化的可调范围

**Fixture:**
- `design/gdd/player-controller.md` 有一条 Tuning Knobs 条目 `jump_height`，文档化范围为 3–5
- `assets/data/player.json` 中 `jump_height: 5`
- 先前的快速规格 `design/quick-specs/jump-height-tuning-[earlier-date].md` 曾把 `jump_height` 设为 5

**Input:** `/quick-design increase jump height from 5 to 6 units`

**Expected behavior:**
1. 技能将变更分类为 Tuning 并确认
2. 上下文扫描还会检查 `assets/data/` 中保存该值的数据文件，并点名曾改动该参数的先前快速规格，标记为冲突——它设置的值正是本次变更要替换的值
3. 草稿使用 Tuning 格式：单个 Change 表（Parameter、Old Value、New Value、Rationale）、Tuning Knob Mapping 和 Acceptance Criteria
4. Tuning Knob Mapping 说明新值超出文档化范围，并解释为何应扩展该范围
5. 验收标准引用从 `assets/data/[file]` 读取该值

**Assertions:**
- [ ] 由于变更是 Tuning，会检查 `assets/data/` 中的数据文件
- [ ] 报告涉及 `jump_height` 的先前快速规格，而不是静默地与它矛盾
- [ ] 草稿使用单表 Tuning 格式，而不是 Tweak/Addition 小节
- [ ] Tuning Knob Mapping 说明该值超出文档化范围，并解释扩展原因

---

### Case 4: 边界情况 — 无参数且无系统索引

**Fixture:**
- 没有 `design/gdd/systems-index.md`
- `design/quick-specs/` 可能存在也可能不存在

**Input:** `/quick-design`（无参数）

**Expected behavior:**
1. 技能以纯文本提示要求用户描述变更
2. 在用户描述变更之前，它不显示分类组件、不选择变更，也不写入任何内容
3. 描述之后，它照常分类并确认
4. 上下文扫描注明 “No systems index found — skipping dependency tier check.” 并继续

**Assertions:**
- [ ] 无参数时，技能以纯文本要求描述，而不是猜测变更
- [ ] 只有在用户描述变更之后才进行分类
- [ ] 以文档化的语句说明系统索引缺失，并继续运行
- [ ] 在批准步骤之前不写入任何文件

---

### Case 5: 无总监闸门 — 评审模式没有影响

**Fixture:**
- 变更在范围内（一个 Addition：“add a parry window to the block mechanic”）
- `design/gdd/combat.md` 存在（该项目层级下自愿编写的 GDD），并描述格挡机制
- `project.yaml` 中 `modes.review_mode: full`，`modes.workflow: minimal`

**Input:** `/quick-design add a parry window to the block mechanic`

**Expected behavior:**
1. 技能按正常流程运行；`review_mode` 不在它解析的键之中，也没有任何分支依赖它
2. 不启动任何类型的代理（该技能没有 `Agent` 工具）
3. 规格在 “May I write” 之后被起草、批准并写入
4. Pipeline Notes 说明快速规格按设计绕过 `/design-review` 和 `/review-all-gdds`，并列出何时应转向 `/design-system`
5. 在 `workflow: minimal` 下，交接说明直接进入 `/dev-story`，而不是 `/story-readiness`

**Assertions:**
- [ ] 不启动任何总监闸门或其他代理
- [ ] `modes.review_mode: full` 不会改变技能的行为
- [ ] 输出说明快速规格绕过 `/design-review` 和 `/review-all-gdds`，并为较大变更指明 `/design-system`
- [ ] 在 `workflow: minimal` 下，交接直接指向 `/dev-story`

---

### Case 6: 边界情况 — 系统没有 GDD（默认层级）

**Fixture:**
- `project.yaml` 中 `modes.rigor: minimal`；`design/gdd/` 中没有系统 GDD
- `design/game-brief.md` 描述跳跃；`production/epics/movement/story-002-jump.md` 以跳跃高度 5 实现它

**Input:** `/quick-design increase jump height from 5 to 6 units`

**Expected behavior:**
1. 分类为 Tuning 并确认
2. 上下文扫描找不到 GDD，并报告 “No GDD for movement — using the brief and `production/epics/movement/story-002-jump.md`”
3. 规格以 `design/game-brief.md` 作为其 GDD Reference 起草、展示，并在 “May I write” 之后写入
4. 不提议 GDD 更新（没有可更新的 GDD）；交接指向 `/dev-story`

**Assertions:**
- [ ] 技能不会因为没有 GDD 而停止，也不会转向 `/design-system`
- [ ] 报告点名它用来替代 GDD 的简报和用户故事
- [ ] 规格的 GDD Reference 为 `design/game-brief.md`
- [ ] 在 “May I write” 批准之前不写入任何内容

---

## Protocol Compliance

- [ ] 起草前先分类并确认变更；超范围变更转向 `/design-system`
- [ ] 规格格式与确认的类别匹配（Tuning 表；Tweak/Addition 小节；New Small System 精简 GDD）
- [ ] 在 “May I write” 询问之前展示完整草稿
- [ ] 写入之前询问 “May I write this Quick Design Spec to `design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md`?”
- [ ] GDD 编辑单独询问，展示旧文本与新文本，未经批准绝不执行
- [ ] 无总监闸门；不读取评审模式
- [ ] 以交接块和下一步（`/story-readiness`，或在 `minimal` 下为 `/dev-story`）结尾

---

## Coverage Notes

- New Small System 格式（Overview、Core Rules、Tuning Knobs、Acceptance
  Criteria、Systems Index）未做 fixture 测试。
- 批准步骤的 `[B] Revise` 循环未单独测试。
- `guided` 和 `autonomous` 自动化模式未测试。
- 范围阈值属于判断性决策；技能的类别定义和转向清单才是权威定义，
  并未通过统计工时来测试。
