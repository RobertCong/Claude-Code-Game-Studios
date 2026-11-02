# Skill Test Spec: /help

## Skill Summary

`/help` 告诉用户他们在流水线中的位置，以及接下来要做的那一件事。它是只读的，并声明 Haiku 层级（`model: haiku`），该层级仅在用户于 Manual 模式下输入 `/help` 时使用——在 auto 模式下，或由 Claude 自行启动该技能时，使用会话模型运行（`.claude/docs/model-tiers.md`）。运行之前，它会被传入解析后的配置块（`project.stage`、`workflow`）以及 `.claude/scripts/story-status.sh` 的输出；它自己读取会话检查点（Step 3）。随后它读取 `.claude/docs/workflow-catalog.yaml`，通过一次调用 `bash .claude/scripts/artifact-check.sh --phase [phase]` 解析当前阶段的步骤完成情况，并在 Production 阶段读取 `production/sprint-status.yaml`。

当 `workflow` 解析为 `minimal` 时（默认值，因为 `modes.rigor` 默认为 `minimal`），它跳过阶段阶梯，读取会话检查点（Step 3），并走 minimal 路径（Step 4m）：引擎 → `design/game-brief.md` → 用户故事 → `/dev-story` ↔ `/story-done`。可选参数是**用户刚刚完成或正卡住的内容**——技能用它越过所指的步骤，其中的困惑性措辞会追加一段升级页脚。它不是主题筛选器。

输出是一个简短的 "Where You Are" 块，含 `✓ Done`、恰好一个 `→ Next up`、可选的 `~ Also available` 以及 `Coming up after that`。结论行是 `Verdict: **COMPLETE** — next steps identified.`。不写入任何文件，也不调用任何总监质量闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] Frontmatter 设置 `model: haiku`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 不包含 "May I write" 措辞，且 `allowed-tools` 中没有 Write 或 Edit（技能为只读）
- [ ] 有下一步交接（一条 `→ Next up` 建议加上升级路径）

---

## Director Gate Checks

无。`/help` 是只读的导览技能。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Production 阶段且有活跃冲刺

**Fixture:**
- `project.yaml` 设置 `project.stage: Production` 与 `modes.rigor: standard`
  （因此 `workflow` 解析为 `standard`）
- `production/sprints/sprint-004.md` 存在
- `production/sprint-status.yaml` 列出一个用户故事 `status: in-progress`、两个
  `status: ready-for-dev`、三个 `status: done`，以及一个 `status: blocked` 且带
  `blocker` 字段
- `production/session-state/active.md` 有一个 STATUS 块，指明进行中的用户故事

**Input:** `/help`

**Expected behavior:**
1. 技能从配置块取得 `project.stage: Production` 与 `workflow: standard`
2. 技能读取 `.claude/docs/workflow-catalog.yaml` 并运行
   `bash .claude/scripts/artifact-check.sh --phase production`
3. 技能读取 `production/sprint-status.yaml`：进行中的用户故事为
   "currently active"，ready-for-dev 的用户故事为 "next up"，done 的用户故事计入
   完成，被阻塞的用户故事连同其 `blocker` 文本一并指明
4. 由于 `active.md` 显示有活跃任务，它被醒目地置于顶部：
   "It looks like you were working on [story]"
5. 输出采用 Step 7 的形态，标题为 `## Where You Are: Production`，并带有
   单个 `→ Next up (REQUIRED)` 步骤
6. 结论为 COMPLETE

**Assertions:**
- [ ] 标题为 `## Where You Are: Production`
- [ ] 读取 `production/sprint-status.yaml`；进行中的用户故事被呈现为当前活跃
- [ ] 被阻塞的用户故事连同其 `blocker` 字段出现
- [ ] 恰好显示一个 `→ Next up (REQUIRED)` 步骤（而不是所有技能的列表）
- [ ] `active.md` 中进行中的用户故事被置于顶部（"It looks like you were working on …"）
- [ ] 结论为 COMPLETE
- [ ] 不写入任何文件

---

### Case 2: Concept Stage — 已配置引擎，没有概念文档

**Fixture:**
- `project.yaml` 设置 `project.stage: Concept`、`modes.rigor: full`，以及
  `engine.name: "Godot"`（选择 `full` 是因为在 `standard` 下，美术圣经仅在存在
  视觉资源用户故事时才被要求——`.claude/docs/workflow-modes.md`
  ——而 Concept 阶段的项目没有用户故事可据以判断）
- 没有 `design/gdd/game-concept.md`、没有 `design/art/art-bible.md`、没有
  `design/gdd/systems-index.md`、没有冲刺文件

**Input:** `/help`

**Expected behavior:**
1. 技能把 `Concept` 映射到目录中的 phase `concept`
2. `artifact-check.sh --phase concept` 报告 `engine-setup` PRESENT（通过
   `project.yaml` 中的 `engine.name` 匹配），而 `game-concept`、`art-bible`、`map-systems` 为 ABSENT
3. `✓ Done` 列出 Engine Setup
4. `→ Next up (REQUIRED)` 为 **Game Concept Document**，命令为 `/brainstorm`
5. `Coming up after that` 按顺序列出 Art Bible（`/art-bible`）与 Systems Map（`/map-systems`）
6. 结论为 COMPLETE

**Assertions:**
- [ ] 标题为 `## Where You Are: Concept`
- [ ] Engine Setup 显示在 `✓ Done` 下（而不是被报告为缺失）
- [ ] `→ Next up` 为通过 `/brainstorm` 生成的 Game Concept Document
- [ ] `/art-bible` 与 `/map-systems` 按该顺序出现在 "Coming up after that" 下
- [ ] 不建议任何 Production 阶段技能（例如 `/dev-story`、`/sprint-plan`）
- [ ] 结论为 COMPLETE

---

### Case 3: No stage recorded — 由产出物推断阶段

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`，且没有 `project.stage`
- 没有 `production/stage.txt`
- `design/gdd/game-concept.md` 与 `design/gdd/systems-index.md` 存在
- 没有 `docs/architecture/adr-*.md`，没有 `production/epics/**/story-*.md`，代码根目录为空

**Input:** `/help`

**Expected behavior:**
1. 配置块报告 `project.stage` 未设置
2. 技能应用 Step 2 的产出物推断（最超前的匹配获胜）：
   `design/gdd/systems-index.md` 存在且没有更超前的产物 → `systems-design`
3. 技能以 Step 7 的形态正常报告推断出的阶段
4. `→ Next up (REQUIRED)` 为通过 `/design-system` 编写的 System GDD。目录中的
   `design-system` 步骤只有一个 `note:` 检查，因此 `artifact-check.sh` 以一条
   note 报告其为 `NO_CHECK`——这是 **MANUAL** 步骤：技能会询问是否已有任何
   系统 GDD 完成，而不是断言一份都没有
5. 输入中没有困惑性措辞，因此不显示 Step 9 的升级块
6. 结论为 COMPLETE

**Assertions:**
- [ ] 未记录阶段时，技能不会停止或报错
- [ ] 推断出的阶段为 Systems Design（标题 `## Where You Are: Systems Design`），而不是 Concept
- [ ] `→ Next up` 为通过 `/design-system` 编写的 System GDD
- [ ] 技能询问用户是否已有任何系统 GDD 完成（MANUAL 步骤），而不是把 System GDD 报告为已完成或尚未开始
- [ ] 不显示 "Need more detail?" 升级块（`/project-stage-detect`、`/gate-check`、`/start`）
- [ ] 结论为 COMPLETE

---

### Case 4: Argument — 用户指出已完成的步骤并表示不确定

**Fixture:**
- `project.yaml` 设置 `project.stage: Systems Design` 与 `modes.rigor: standard`
- `design/gdd/systems-index.md` 列出两个 MVP 系统，两者均为 `Status: Approved`，
  且两份系统 GDD 都存在
- 没有 `design/gdd/gdd-cross-review-*.md`
- 目录中的 `design-review` 步骤没有产出物检查（`NO_CHECK`）

**Input:** `/help just finished design-review, not sure what's next`

**Expected behavior:**
1. 参数被读作用户刚刚完成的步骤（Step 5），而不是主题筛选器
2. 技能越过 Per-System Design Review，即使其产出物检查为 `NO_CHECK`
3. `→ Next up (REQUIRED)` 为通过 `/review-all-gdds` 进行的 Cross-GDD Review
4. "not sure" 属于困惑性措辞，因此追加 Step 9 的 "Need more detail?" 块，
   包含 `/project-stage-detect`、`/gate-check` 与 `/start`
5. **不**显示 `/settings` 的 rigor 行：用户听起来并未被流程压垮，且项目尚未
   超出 `standard`（`settings-guidance.md § 4` 的任一触发条件都未命中）
6. 结论为 COMPLETE

**Assertions:**
- [ ] 由于用户点名，Per-System Design Review 被视为已完成
- [ ] `→ Next up` 为通过 `/review-all-gdds` 进行的 Cross-GDD Review
- [ ] 升级块列出 `/project-stage-detect`、`/gate-check` 与 `/start`
- [ ] 不出现 `/settings` 的 rigor 变更行
- [ ] 结论为 COMPLETE

---

### Case 5: Director Gate Check — minimal 路径，无闸门且无 gate-check 路由

**Fixture:**
- `project.yaml` 含 `engine.name: "Godot"`，且没有 `modes` 块（`modes.rigor`
  默认为 `minimal`，因此 `workflow` 解析为 `minimal`）
- `design/game-brief.md` 存在
- `production/epics/core/story-001.md` 为 `Status: Complete`，
  `story-002.md` 为 `Status: In Progress`，`story-003.md` 为 `Status: Ready`
- `active.md`（其 CHECKPOINT 把 story-002 命名为当前任务，并带有
  **Next step:** `/dev-story`）与 git log（没有提交提及 story-002）都没有说明
  story-002 的实现已写入

**Input:** `/help`

**Expected behavior:**
1. `workflow: minimal` 使技能越过 Step 2 的其余部分；不映射 `project.stage`
2. 技能读取 `active.md` 的 STATUS 与 CHECKPOINT 块（Step 3），然后进入
   Step 4m
3. 技能运行 `bash .claude/scripts/artifact-check.sh --path minimal`
4. 注入的 `story-status.sh` 列表在第一行 `IN_PROGRESS` 上包含 story-002；
   技能不重新运行脚本，也不重新排序用户故事
5. 输出采用 minimal 形态：`## Where You Are: Minimal path — 1 of 3 stories complete`，
   其中 `✓ Done` 给出已完成用户故事的数量，而不是它们的标题
6. `→ Next up` 为 story-002，命令为 `/dev-story [story-002 path]`
7. 没有阶段标签，没有闸门行；概念文档、美术圣经、系统地图、GDD、
   冲刺计划与 `/gate-check` 都不会被呈现为必需
8. 不生成任何总监代理，也不调用任何写入工具

**Assertions:**
- [ ] 标题为 `Minimal path — 1 of 3 stories complete`
- [ ] 在选择下一步之前读取 `active.md` 的检查点（`minimal` 下会运行 Step 3）
- [ ] `→ Next up` 为通过 `/dev-story` 处理的 story-002，而不是 story-003
- [ ] 不出现 `/gate-check` 行，也不出现 "Approaching … gate" 行
- [ ] 游戏概念、美术圣经、系统地图与 GDD 都不被列为下一步
- [ ] 不调用任何总监闸门，输出中也不出现任何闸门 ID
- [ ] 不调用任何写入工具
- [ ] 结论为 COMPLETE

---

### Case 6: Minimal path — 检查点表明工作已写入

**Fixture:**
- 同 Case 5，但 `active.md` 的 CHECKPOINT 为
  **Next step:** `/story-done production/epics/core/story-002.md`（即
  `/dev-story` 完成一个用户故事时写入的内容）

**Input:** `/help`

**Expected behavior:**
1. Step 3 在 `minimal` 下运行，并找到检查点的下一步
2. story-002 仍位于第一行 `IN_PROGRESS`，但 `active.md` 表明其实现已写入，
   因此 `→ Next up` 为 story-002，命令为 `/story-done [story-002 path]`
3. 结论为 COMPLETE

**Assertions:**
- [ ] `→ Next up` 为通过 `/story-done` 处理的 story-002，而不是 `/dev-story`
- [ ] story-002 不被计入或列为已完成
- [ ] 结论为 COMPLETE

---

### Case 7: Minimal path — 仅剩一个被阻塞的用户故事与一个未知状态

**Fixture:**
- 同 Case 5，但 `story-002.md` 为 `Status: Blocked`（其文件说明它等待玩家
  精灵的美术资源），且 `story-003.md` 为 `Status: Draft`

**Input:** `/help I'm stuck`

**Expected behavior:**
1. 注入的列表中没有 `IN_REVIEW`、`IN_PROGRESS` 或 `TODO` 行：story-002
   位于 `BLOCKED` 行，story-003 位于 `OTHER` 行（`Draft`）
2. 技能指明 story-002 及其阻塞项，并按所写状态指明 story-003，
   并说明接下来无法构建任何内容
3. 它**不会**说构建顺序已完成，也不会提供 every-story-Complete 分支的 "three
   ways on"
4. `→ Next up` 为先清除其中的第一个——story-002 的阻塞项
5. "stuck" 属于困惑性措辞，因此追加 Step 9 的 "Need more detail?" 块——
   但不含其 `/gate-check` 行，因为 minimal 路径没有阶段闸门
6. 结论为 COMPLETE

**Assertions:**
- [ ] story-002 连同其阻塞项被指明；story-003 连同状态 `Draft` 被指明
- [ ] 两个用户故事都没有被推荐给 `/dev-story` 或 `/story-done`
- [ ] 输出没有说构建顺序已完成
- [ ] 标题为 `Minimal path — 1 of 3 stories complete`
- [ ] 升级块出现，且不含 `/gate-check` 行
- [ ] 结论为 COMPLETE

---

### Case 8: Minimal path，无游戏简报——已构建的游戏应被记录，而非重新头脑风暴

**Fixture:**
- `project.yaml` 含 `engine.name: "Godot"`，且没有 `modes` 块（`workflow` 解析
  为 `minimal`）
- 没有 `design/game-brief.md`、没有 `design/gdd/game-concept.md`、`production/epics/`
  下没有用户故事
- 运行 A：`src/` 含 12 个 `.gd` 文件。运行 B：`src/` 含 3 个 `.gd` 文件

**Input:** `/help`

**Expected behavior:**
1. `workflow: minimal` 进入 Step 4m；`artifact-check.sh --path minimal` 报告
   `engine-setup` 为 PRESENT，`game-brief` 不为 PRESENT
2. 运行 A：代码根目录已包含游戏（源文件达到 10 个或更多，与 Step 2 用于
   `production` 的测试相同），因此 `→ Next up` 为通过
   `/reverse-document design src/` 编写的游戏简报，它根据已构建内容写出
   `design/game-brief.md`
3. 运行 B：代码根目录尚不是游戏，因此 `→ Next up` 为通过
   `/brainstorm` 编写的游戏简报
4. 两者中 `/create-stories` 都紧随其后出现在 "Coming up after that" 下
5. 结论为 COMPLETE

**Assertions:**
- [ ] 运行 A 的 `→ Next up` 为 `/reverse-document design src/`（Godot 的代码根目录），而不是 `/brainstorm`，因为对已构建的游戏而言后者会开启一个新想法
- [ ] 运行 B 的 `→ Next up` 为 `/brainstorm`
- [ ] 10 个源文件的阈值决定二者之间的选择：12 个文件路由到 `/reverse-document`，3 个文件则不会
- [ ] 不把任何阶段标签、概念文档、美术圣经、系统地图或 `/gate-check` 呈现为必需
- [ ] 结论为 COMPLETE，且不写入任何文件

---

## Protocol Compliance

- [ ] 使用注入的配置块获取 `project.stage` 与 `workflow`，而不是重新读取它们
- [ ] 通过一次 `artifact-check.sh` 调用解析步骤完成情况，而不是为每一步执行 Glob
- [ ] 恰好给出一条主要（`→ Next up`）建议
- [ ] 绝不自动运行所推荐的技能
- [ ] 就 `MANUAL` 步骤询问用户，而不是假定其已完成或未完成
- [ ] 不写入任何文件
- [ ] 所有用例中结论均为 COMPLETE

---

## Coverage Notes

- 未单独测试 `sprint-status.yaml` 中每个用户故事都已完成的情况；此时将适用 Step 8 的闸门警告。
- 在 `workflow: full` 下，每个可选步骤都列在 `~ Also available` 下；
  Case 2 在 `full` 下运行只是为了让美术圣经成为必需项，并不对该列表做断言。
- minimal 路径的 "every story Complete" 分支（三条继续途径：试玩构建、
  `/create-stories`、`/settings`）未单独测试。
- 无简报的已构建游戏走 `/reverse-document` 路由的情况见 Case 8；Unity（`Assets/`）
  与 Unreal（`Source/<Module>/`）的代码根目录未给出 fixture。
