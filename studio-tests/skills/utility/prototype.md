# Skill Test Spec: /prototype

## Skill Summary

`/prototype [concept] [--path html|engine|paper] [--review full|lean|solo]
[--spike]` 在编写 GDD 之前运行一次一次性的概念原型。它首先通过
`AskUserQuestion` 确认意图（Prototype this concept / Skip — concept
already proven / Mid-production spike），形成一个可证伪的假设（"If the
player [does X], they will feel [Y] — we will know this is true if [Z]"），并
询问风险最高的假设。它选择 HTML、Engine 或 Paper 路径（按类型表，
预先给出推荐），呈现一份 3–5 条的要点计划，询问是否将其记录为
`production/session-state/active.md` 中的检查点，然后询问 "May I create the prototype
directory at `prototypes/[concept-name]-concept/` and begin implementation?"。
每个原型文件都以该文件自身注释语法中的 `PROTOTYPE - NOT FOR PRODUCTION` 头开头
（GDScript 与 Python 中为 `#`，C#、C++ 与
JavaScript 中为 `//`，HTML 与 Markdown 中为 `<!-- -->`），并且有意放宽
标准。

在一次只问一个问题的复盘之后，它填写
`.trae/docs/templates/prototype-report.md`，询问是否写入
`prototypes/[concept-name]-concept/REPORT.md` 并把其行添加到
`prototypes/index.md`（一次询问同时指明两者）。结论为 **PROCEED / PIVOT / KILL**。PIVOT 写入
`PIVOT-NOTE.md`；KILL 运行包含五项内容的健全性检查，并追加到
`prototypes/GRAVEYARD.md`。在 `full` 评审模式下，`creative-director` 通过
**CD-PLAYTEST** 评审结果，并回答 APPROVE / CONCERNS / REJECT：APPROVE 保持
该建议；CONCERNS 交给用户决定（Revise / Accept /
Discuss）；REJECT 意味着 PROCEED 不能成立——用户选择 PIVOT 或 KILL，
REPORT.md 记录总监的理由。NOT ASSESSED 的回答（总监
缺少某项输入）绝不等同于批准。`--spike` 把
整个流程替换为约 4 小时的 spike：在创建其文件夹之前询问，在写入
`SPIKE-NOTE.md` 并从 `active.md` 清除该 spike 之前询问，且
没有 CD 闸门，也没有 PROCEED/PIVOT/KILL。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：PROCEED、PIVOT、KILL、NOT ASSESSED（没有人玩过的原型）
- [ ] 在创建原型目录与报告之前包含 "May I create" / "May I write" 措辞
- [ ] 每种结论都有下一步交接（PROCEED → `/design-review`、`/gate-check`、`/map-systems`、`/design-system`；PIVOT → `/prototype` 或 `/brainstorm`；KILL → `/brainstorm`）

---

## Director Gate Checks

- **Full 模式**：CD-PLAYTEST——`creative-director` 接收 REPORT.md
  内容、假设与游戏支柱（来自 `design/gdd/game-concept.md`，或来自
  `design/game-brief.md` 的提案与 "what they feel" 一行），并返回
  APPROVE / CONCERNS / REJECT，或在缺少输入时返回 NOT ASSESSED。
  APPROVE → 建议成立；CONCERNS → 与建议一同展示，
  由用户决定（Revise / Accept / Discuss）；REJECT → PROCEED 不能
  成立：用户选择 PIVOT 或 KILL，REPORT.md 记录总监的
  理由；NOT ASSESSED → 绝不等于批准：指明缺失的输入，并
  重新运行闸门，或把评审记录为 NOT ASSESSED。如果两份文档都
  不存在："CD-PLAYTEST skipped — game pillars not yet defined at concept
  prototype stage."
- **Lean 模式**：跳过——"CD-PLAYTEST skipped — Lean mode."
- **Solo 模式**：跳过——"CD-PLAYTEST skipped — Solo mode."
- **Spike 模式**：在任何评审模式下都没有 CD 闸门，也没有阶段闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Engine 原型，PROCEED

**Fixture:**
- `design/gdd/game-concept.md` 描述一个 2D 平台游戏；`project.yaml` 含
  `engine.name: Godot` 与 `engine.language: GDScript`
- `prototypes/` 中没有 `grapple-hook-concept/`
- 评审模式：`solo`；`modes.workflow: standard`（已固定：未设置时解析为
  minimal，会把 PROCEED 路由到 `/create-stories` 与 `/dev-story`，而非
  步骤 7 的列表——Case 6 覆盖该路由）
- 在复盘中用户报告假设 CONFIRMED 并回答 PROCEED

**Input:** `/prototype grapple-hook traversal`

**Expected behavior:**
1. `AskUserQuestion` 确认意图；用户选择 "Prototype this concept"
2. 技能以 If / feel / know-if 形式陈述一个可证伪的假设，并询问
   风险最高的假设
3. 路径控件预先给出 Engine 推荐（移动手感即是
   假设）
4. 呈现并确认计划，询问中指明
   `production/session-state/active.md`；检查点写入该处
5. 技能询问 "May I create the prototype directory at
   `prototypes/grapple-hook-concept/` and begin implementation?"；它写入的每个
   GDScript 文件都以 `# PROTOTYPE - NOT FOR PRODUCTION` 开头（GDScript
   注释使用 `#`；用 `//` 头将无法解析）
6. 复盘问题逐个提出；报告依据
   `.trae/docs/templates/prototype-report.md` 起草；询问 "May I write this report to
   `prototypes/grapple-hook-concept/REPORT.md` and add its row to
   `prototypes/index.md`?"；向 `prototypes/index.md` 追加一行
7. 记录 "CD-PLAYTEST skipped — Solo mode."；PROCEED 路由到 `/design-review`、
   `/gate-check`、`/art-bible`、`/map-systems`、`/design-system`、`/review-all-gdds`

**Assertions:**
- [ ] 假设可证伪，并带有可测量的信号
- [ ] 在用户选择之前，路径提示中已推荐 Engine
- [ ] 目录询问指明 `prototypes/grapple-hook-concept/`，且位于写入任何原型文件之前
- [ ] 每个原型脚本都以 `#` 注释携带 `PROTOTYPE - NOT FOR PRODUCTION` 头，绝不使用 `//`；代码根目录下不写入任何文件
- [ ] REPORT.md 仅在其询问之后写入，该询问也指明 `prototypes/index.md`，且索引新增一行，结论为 PROCEED
- [ ] PROCEED 的后续步骤包含 `/map-systems` 与 `/design-system`

---

### Case 2: PIVOT — 写入结转说明

**Fixture:**
- `trade-routes` 的纸面原型刚刚完成复盘
- 用户回答 PIVOT：路线规划很有吸引力，维护计算则不然
- 评审模式：`solo`

**Input:** `/prototype trade-routes --path paper`

**Expected behavior:**
1. Paper 路径在目录询问之后写入 `prototypes/trade-routes-concept/rules.md` 与
   `play-log.md`
2. REPORT.md 在其询问之后写入，结论为 PIVOT
3. 技能逐个询问："What specifically worked in this prototype that
   we should preserve…?" 与 "What is the single most important thing to change?"
4. 技能询问 "May I write this to `prototypes/trade-routes-concept/PIVOT-NOTE.md`?"
5. 说明包含原始假设、需要保留的内容、需要修改的内容以及
   修订后的假设；后续步骤为 `/prototype [revised-concept]` 或
   `/brainstorm [hint]`

**Assertions:**
- [ ] 遵循 `--path paper`，产出 `rules.md` 与 `play-log.md`
- [ ] 两个结转问题分开询问
- [ ] 在写入 `PIVOT-NOTE.md` 之前询问 "May I write" 并指明它
- [ ] 说明中包含修订后的假设
- [ ] 后续步骤提供用于修订后概念的 `/prototype` 或 `/brainstorm`

---

### Case 3: KILL — 健全性检查与墓地条目

**Fixture:**
- `procedural-dialogue` 的 HTML 原型已完成复盘
- 用户回答 KILL；复盘显示经过 2 次试玩测试，测试者始终没有理解核心
  操作，没有观察到有趣的时刻，且该概念只有在开发者解释时才
  成立

**Input:** `/prototype procedural-dialogue --path html`

**Expected behavior:**
1. REPORT.md 在其询问之后写入，结论为 KILL
2. 技能运行五项 KILL 清单；有 3 项适用，因此该结论是健全的
3. 技能询问 "May I append this concept to `prototypes/GRAVEYARD.md`?"
4. 条目包含 Kill reason、What worked、What failed 与 Next time，
   并给出具体的淘汰原因（而不是 "it was boring"）
5. 下一步：`/brainstorm open` 或 `/brainstorm [new-hint]`

**Assertions:**
- [ ] 应用 KILL 清单，并以 2+ 规则判定健全性
- [ ] 在写入之前，询问 "May I append" 并指明 `prototypes/GRAVEYARD.md`
- [ ] 墓地条目包含全部四个字段以及具体的淘汰原因
- [ ] 后续步骤路由到 `/brainstorm`

---

### Case 4: Spike Mode — 无复盘、无闸门、无 PROCEED/PIVOT/KILL

**Fixture:**
- 项目处于 Production 阶段
- 评审模式：`full`；`modes.workflow: standard`（已固定：未设置时解析为 minimal，
  其 spike 说明与 `active.md` 措辞由 Case 7 覆盖）
- `production/sprints/sprint-004.md` 是当前冲刺，且 `active.md` 显示它

**Input:** `/prototype rope-physics --spike`

**Expected behavior:**
1. 技能跳过 Phase 1–9 并运行 Spike 模式
2. 以纯文本询问 spike 问题："Can we [do X] using [approach Y]?"
3. 路径控件同 Phase 3；范围限制为 2–3 条要点；约 4 小时上限
4. 在写入任何 spike 文件之前询问 "May I create `prototypes/rope-physics-spike-[date]/` and build the
   spike there?"
5. 询问 "Did the spike answer the question? YES or NO, and why in one sentence."
6. 只询问一次，同时指明两个文件："May I write
   `prototypes/rope-physics-spike-[date]/SPIKE-NOTE.md` and clear the spike from
   `production/session-state/active.md`?"；随后写入说明（问题、结果
   YES / NO / PARTIAL、下一步该做什么）并更新 `active.md`
7. 说明中的 "what to do next" 提供：加入当前冲刺 / 进一步调查 /
   放弃该想法。`active.md` 被清除回当前冲刺状态

**Assertions:**
- [ ] 跳过意图控件与假设/复盘阶段
- [ ] 只有在其询问之后才创建 spike 文件夹
- [ ] `SPIKE-NOTE.md` 与 `active.md` 只在一次同时指明两者的询问之后写入
- [ ] 输出是 `-spike-[date]` 文件夹中的 `SPIKE-NOTE.md`，而不是 REPORT.md
- [ ] 即使评审模式为 `full`，也没有 CD-PLAYTEST 生成或跳过说明
- [ ] 不发出任何 PROCEED / PIVOT / KILL 结论
- [ ] 在 `standard` 下，说明的后续步骤选项写为 "add to current sprint"，且 `active.md` 返回当前冲刺状态

---

### Case 5: Director Gate — 按评审模式与游戏支柱决定 CD-PLAYTEST

**Fixture:**
- 已构建一个概念原型，且 REPORT.md 已写入，带有 PROCEED
  建议
- 运行 A：`--review full`，`design/gdd/game-concept.md` 存在且含游戏支柱；
  `creative-director` 返回 REJECT——核心幻想不存在；被询问
  PIVOT 或 KILL 的用户选择 PIVOT
- 运行 B：`--review full`，`game-concept.md` 与 `design/game-brief.md` 都不存在
- 运行 C：`--review lean`

**Input:** `/prototype [concept] --review [mode]`

**Expected behavior:**
1. 运行 A：为 CD-PLAYTEST 生成 `creative-director`，传入 REPORT.md
   内容、假设与游戏支柱。其 REJECT 意味着 PROCEED 建议
   不能成立：技能请用户选择 PIVOT 或 KILL（不替他们
   选择），用户选择 PIVOT，随后在一次指明 REPORT.md 与
   `prototypes/index.md` 的询问之后，报告记录总监的结论与理由
   以及最终的 PIVOT 建议；Phase 9 然后运行 PIVOT 路线
2. 运行 B：不生成；记录 "CD-PLAYTEST skipped — game pillars not yet defined at
   concept prototype stage."
3. 运行 C：不生成；记录 "CD-PLAYTEST skipped — Lean mode."

**Assertions:**
- [ ] 运行 A 在 REPORT.md 写入之后为 CD-PLAYTEST 生成 `creative-director`
- [ ] 运行 A：总监的结论被读作 APPROVE / CONCERNS / REJECT 之一，而不是它自己的 PROCEED / PIVOT / KILL
- [ ] 运行 A：REJECT 之后不保留 PROCEED；请用户选择 PIVOT 或 KILL
- [ ] 运行 A 的最终建议是用户的 PIVOT，且 REPORT.md 连同总监的理由一并记录
- [ ] 运行 B 以 "game pillars not yet defined" 说明跳过，而不是在没有游戏支柱的情况下生成
- [ ] 运行 C 以 Lean 模式说明跳过
- [ ] 不生成任何其他总监闸门

---

### Case 6: NOT ASSESSED（未游玩）与 `workflow: minimal` 的 PROCEED 路由

**Fixture:**
- 运行 A：原型在本次会话中已构建，但还没有人玩过
- 运行 B：给出 PROCEED 建议，`project.yaml` 含 `modes.workflow: minimal`

**Input:** `/prototype [concept]`

**Expected behavior:**
1. 运行 A：由于尚无有趣性证据，PROCEED/PIVOT/KILL 都不可达；
   技能报告 NOT ASSESSED 并停止，而不是猜测，并把 "play it,
   then run `/prototype [same concept]` again" 命名为下一步
2. 运行 B：Phase 9 的 PROCEED 路线提供 `/create-stories`（来自简报），然后
   在第一个用户故事上提供 `/dev-story`，而不是 GDD/`/map-systems`/`/art-bible` 路径

**Assertions:**
- [ ] 运行 A 的结论为 NOT ASSESSED，而不是猜测的 PROCEED/PIVOT/KILL
- [ ] 在试玩测试发生之前，运行 A 的报告与 `prototypes/index.md` 行都写作 NOT ASSESSED
- [ ] 运行 B 推荐的路径是 `workflow: minimal` 路线（`/create-stories`、`/dev-story`），而不是 `standard`/`full` 的 GDD 流水线

---

### Case 7: Spike Mode at `workflow: minimal` — 构建顺序，而非冲刺

**Fixture:**
- `project.yaml`：`modes.workflow: minimal`（已固定：本用例测试 `minimal`
  措辞，与 Case 4 相反）；评审模式 `full`
- 没有 `production/sprints/` 目录。`design/game-brief.md` 列出构建顺序；
  进行中的用户故事是 `production/epics/core/story-002.md`（`Status: In Progress`），
  且 `production/session-state/active.md` 将其指明为当前任务
- 用户对 spike 问题回答 YES

**Input:** `/prototype rope-physics --spike`

**Expected behavior:**
1. spike 按 Case 4 运行，询问相同：先是 spike 文件夹，然后是一次同时
   指明 `SPIKE-NOTE.md` 与 `active.md` 的询问
2. `SPIKE-NOTE.md` 包含所测试的问题、结果（YES / NO / PARTIAL）以及
   下一步该做什么：把该机制加入简报的构建顺序 / 进一步调查 /
   放弃该想法。它不提供 "add to current sprint"
3. `active.md` 被更新以清除该 spike 并返回进行中的用户故事
   （story-002），而不是冲刺状态
4. 没有 CD 闸门，也没有 PROCEED / PIVOT / KILL

**Assertions:**
- [ ] 说明的后续步骤选项指明简报的构建顺序，而不是当前冲刺
- [ ] 写入之后，`active.md` 把 story-002 指明为当前任务，且不提及冲刺
- [ ] spike 文件夹与说明及 `active.md` 的写入各自都先有一次指明文件的询问
- [ ] 不创建或引用任何冲刺文件
- [ ] 没有 CD-PLAYTEST 生成或跳过说明，也不发出任何 PROCEED / PIVOT / KILL 结论

---

## Protocol Compliance

- [ ] 在构建之前通过 `AskUserQuestion` 确认意图（除非使用 `--spike`）
- [ ] 形成可证伪的假设；若概念过于模糊而无法形成假设则停止
- [ ] 在构建之前呈现计划并获得确认
- [ ] 在创建 `prototypes/[concept-name]-concept/` 之前，以及在写入 REPORT.md（含其 `prototypes/index.md` 行）、PIVOT-NOTE.md 或 GRAVEYARD.md 之前询问
- [ ] 在 spike 模式下，在创建 spike 文件夹之前以及在写入 `SPIKE-NOTE.md` 与 `active.md` 之前询问
- [ ] 把原型文件保留在 `prototypes/` 下，每个都以自身注释语法携带 `PROTOTYPE - NOT FOR PRODUCTION` 头
- [ ] 在 CD-PLAYTEST 之前应用评审模式，并在跳过时打印跳过说明
- [ ] 以每种结论对应的后续步骤收尾

---

## Coverage Notes

- "Skip — concept already proven"（记录证据，建议 `/map-systems`
  或 `/design-system`，然后停止）未测试。
- 概念过于模糊而无法形成假设（技能停止并请用户
  收窄范围）仅由协议合规部分覆盖。
- 在下一次运行时读取先前的 `PIVOT-NOTE.md` 以播种修订后的假设
  未测试。
- Engine 路径的多轮修复循环与 2 小时沉没成本规则需要实际
  运行才能验证。
- CD-PLAYTEST 的 APPROVE（建议成立）、CONCERNS（用户决定：
  Revise / Accept / Discuss）、对 PIVOT 或 KILL 建议的 REJECT（该建议
  成立）以及 NOT ASSESSED（绝不等同于批准）未单独测试。
