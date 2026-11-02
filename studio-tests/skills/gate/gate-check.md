# Skill Test Spec: /gate-check

## Skill Summary

`/gate-check` 校验项目是否已准备好推进到下一个开发阶段。它用
`.claude/scripts/artifact-check.sh` 解析产出物是否存在，抽读结论所依据的产出物，
运行目标闸门的质量检查（从 `.claude/skills/gate-check/references/` 下的一个文件
加载），就不可验证的条目询问用户，运行总监小组（其是否存在由 `review_mode` 设定、
宽度由 `workflow` 设定），并产生 PASS / CONCERNS / NOT ASSESSED / FAIL 结论。
在 PASS 且用户确认后，它把新阶段写入 `project.yaml` 中的 `project.stage`，以及
遗留的 `production/stage.txt`。它管辖全部 6 个阶段转换。

技能顶部的已解析配置块决定层级。没有 `project.yaml` 时，`modes.rigor` 默认为
`minimal`，进而解析出 `workflow: minimal` 和 `review_mode: solo` —— 因此下面
每个 fixture 都固定了它所依赖的键。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个阶段标题（编号的 Phase N 或 ## 小节）
- [ ] 包含结论关键词：PASS、CONCERNS、NOT ASSESSED、FAIL
- [ ] 针对阶段更新包含 "May I" 写入批准措辞
- [ ] 结尾有下一步交接（Follow-Up Actions 小节）

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — Concept 产出物全部存在，推进到 Systems Design

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full` 和 `modes.review_mode: solo`
- `design/gdd/game-concept.md` 存在且包含真实内容：核心循环、目标受众、游戏支柱
  小节，以及一个视觉标识锚点（Visual Identity Anchor）小节，内含一条视觉规则和
  2 条支撑性视觉原则
- 尚无系统索引和美术圣经。`artifact-check.sh --phase concept` 将这些目录步骤
  （`required=true`）报告为 ABSENT，但二者都不是 Concept → Systems Design 闸门
  文件中的条目，由加载的闸门文件决定该闸门要求什么
- 没有针对该概念的 `/design-review` 记录

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能只加载 `.claude/skills/gate-check/references/gate-systems-design.md`
2. 技能运行 `bash .claude/scripts/artifact-check.sh --phase concept` 解析存在性，
   然后抽读 `design/gdd/game-concept.md`，确认它有真实内容（不是模板骨架）
3. 技能检查游戏支柱、视觉标识锚点、核心循环和目标受众
4. 技能找不到评审记录，将 "Game concept has been reviewed" 标记为
   `[?] MANUAL CHECK NEEDED` 并询问用户；用户确认已评审过
5. 技能输出 "Director Panel skipped — Solo mode. Gate verdict based on
   artifact and quality checks only."
6. 技能输出第 5 节报告，然后输出 Chain-of-Verification 行
7. 在 PASS 时，技能询问 "May I update `project.stage` in `project.yaml` to
   'Systems Design' (and the legacy `production/stage.txt`)?"
8. 用户确认后，技能写入两处，重新读取两处并确认二者一致

**断言：**
- [ ] 存在性通过 `artifact-check.sh --phase concept` 解析，而不是打开文件查看存在什么
- [ ] ABSENT 的 systems-index 与 art-bible 目录步骤不被报告为阻塞项 —— 目录的 `required=` 标记只是一种观察；闸门文件的清单才是该闸门要求的内容
- [ ] `design/gdd/game-concept.md` 在被标记 `[x]` 前已抽读确认真实内容
- [ ] 输出包含 "Required Artifacts: [X/Y present]" 小节和 "Quality Checks: [X/Y passing]" 小节
- [ ] 未经确认的评审条目被询问，而不是假定 PASS
- [ ] 输出包含一行 `### Verdict:`，取值为 PASS / NOT ASSESSED / CONCERNS / FAIL 之一
- [ ] 输出包含 `Chain-of-Verification: [N] questions checked — verdict [unchanged | revised from X to Y]`
- [ ] 技能在写入前询问，且只在确认后同时写入 `project.yaml`（`project.stage`）和 `production/stage.txt`
- [ ] 写入后，技能重新读取两个文件，若发现不一致就报告，而不是继续
- [ ] 下一步建议是 `/map-systems`（尚不存在系统索引），而不是 `/create-architecture`
- [ ] 变体：若 `design/gdd/systems-index.md` 已写好（目录在 Concept 中将 `/map-systems` 排在前），选项 [A] 改为按其设计顺序取第一个系统的 `/design-system`

---

### Case 2: 失败路径 — Concept → Systems Design 缺少必需产出物

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/game-concept.md` 不存在
- 不存在游戏支柱文档
- `design/gdd/` 目录为空或不存在

**输入：** `/gate-check systems-design`

**预期行为：**
1. `artifact-check.sh` 将 game-concept 步骤报告为 `ABSENT`
2. 技能把必需产出物标记为缺失（在 `full` 下是阻塞项）
3. 技能输出 FAIL 结论
4. 技能在 Blockers 下列出缺失的概念文档
5. 技能建议用 `/brainstorm` 创建一份
6. 技能不自行创建缺失的文件

**断言：**
- [ ] 结论是 FAIL（不是 PASS、CONCERNS 或 NOT ASSESSED）—— 在优先级顺序中 FAIL 最先评估
- [ ] 输出明确点名 `design/gdd/game-concept.md` 缺失
- [ ] 输出包含 "Blockers" 小节，且至少 1 个条目
- [ ] 输出建议将 `/brainstorm` 作为补救动作
- [ ] 结论为 FAIL 时技能不写入 `project.yaml` 或 `production/stage.txt`
- [ ] 技能不创建 `design/gdd/game-concept.md` 或任何其他缺失产出物来制造 PASS

---

### Case 3: 无参数 — 自动检测当前阶段

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`，且没有 `project:` 块；
  `production/stage.txt` 内容为 `Concept`，因此配置块从遗留镜像报告
  `project.stage: Concept (production/stage.txt)`（若完全没有任何 `project.yaml`，
  层级会解析为 `minimal`，其闸门目标是 `design/game-brief.md`，而不是下面的概念文档）
- `design/gdd/game-concept.md` 存在且有内容
- 尚无系统索引

**输入：** `/gate-check`（无参数）

**预期行为：**
1. 技能从已解析的配置块（遗留的 `production/stage.txt` 镜像）/
   project-stage-detect 启发式取当前阶段
2. 技能用 `AskUserQuestion` 确认："Detected stage: **Concept**. Running
   gate for Concept → Systems Design transition. Is this correct?"，选项为
   `[A] Yes — run this gate` / `[B] No — pick a different gate`
3. 选择 `[A]` 后，技能运行 Concept → Systems Design 检查
4. 输出标题指出正在校验的转换

**断言：**
- [ ] 当前阶段来自 `production/stage.txt`（经由已解析的配置块）或 project-stage-detect 启发式
- [ ] 技能在运行检查前用 `AskUserQuestion` 确认检测到的转换 —— 未给出参数时这一步从不跳过
- [ ] 仅当用户选择 `[B] No — pick a different gate` 时才展示全部六个闸门的完整列表
- [ ] 输出标题点名两个阶段："Gate Check: Concept → Systems Design"

---

### Case 4: 边界情况 — 人工检查条目："I don't know" 不等于 "not yet"

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full` 和 `modes.review_mode: solo`
- Concept → Systems Design 的全部必需产出物都存在，且其他所有检查都通过：
  `design/gdd/game-concept.md` 含有真实内容，包含游戏支柱小节、核心循环、
  目标受众，以及带有一条视觉规则和 2 条支撑性原则的视觉标识锚点
- 不存在评审记录（"Game concept has been reviewed" 检查无法自动验证）

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能验证所有产出物都存在
2. 技能执行到 "Game concept has been reviewed (`/design-review` verdict not MAJOR REVISION NEEDED)"
3. 没有评审记录 → 该条目标记为 `[?] MANUAL CHECK NEEDED`
4. 技能询问用户该概念是否已评审

**Case 4a — 用户回答 "I don't know"：** 该条目保持未解决，因此结论是
NOT ASSESSED，而不是 PASS。

**Case 4b — 用户回答 "Not yet"：** 该检查有了答案 —— 概念未评审 —— 因此它
运行了并失败了。没有任何未知项：结论是 CONCERNS 或 FAIL（FAIL 和 CONCERNS
在 NOT ASSESSED 之前评估），并点名 `/design-review` 为修复方式。

**断言：**
- [ ] 无法自动验证的条目标记为 `[?] MANUAL CHECK NEEDED`，而不是假定 PASS
- [ ] 技能至少对一个不可验证的质量条目向用户提问
- [ ] 技能不默认将不可验证的条目标记为 PASS
- [ ] 4a：用户始终未解决的 `MANUAL CHECK NEEDED` 条目产生 NOT ASSESSED（它优先于 PASS），并在 Blockers 小节中写明该条目及原因
- [ ] 4b："not yet" 的回答是一次失败的检查，绝不是未知项 —— 结论是 CONCERNS 或 FAIL，不是 NOT ASSESSED 也不是 PASS，输出点名 `/design-review`（唯一例外是 Production 闸门的试玩问题，其中 "not yet" 表示没有人玩过 —— 见 Case 8）
- [ ] 技能在 NOT ASSESSED 或 FAIL 结论下不写入阶段，在 CONCERNS 下也不写入，除非用户明确接受所列风险（Case 7）

---

### Case 5: 总监闸门 — 小组是否存在（`review_mode`）与小组宽度（`workflow`）

**测试夹具（所有子用例）：**
- Concept → Systems Design 的全部必需产出物都存在
- `design/gdd/game-concept.md` 存在
- 评审模式来自 `project.yaml` 中的 `modes.review_mode`（遗留镜像：
  `production/review-mode.txt`）或内联的 `--review` 标志

**Case 5a — 完整小组：** `modes.review_mode: full`，`modes.workflow: full`

**输入：** `/gate-check systems-design`

**预期行为：**
1. 技能从已解析的配置块取得 `review_mode: full` 和 `workflow: full`
2. 技能并行启动全部 4 位 PHASE-GATE 总监：
   - CD-PHASE-GATE（creative-director）
   - TD-PHASE-GATE（technical-director）
   - PR-PHASE-GATE（producer）
   - AD-PHASE-GATE（art-director）
3. 总监结论为 READY / CONCERNS / NOT READY，或在缺少某个闸门输入时为
   NOT ASSESSED；任何 CONCERNS → 总体结论至少为 CONCERNS；任何
   NOT READY → 总体结论至少为 FAIL；任何 NOT ASSESSED（且没有 NOT READY
   或 CONCERNS）→ 总体结论最多为 NOT ASSESSED，并点名缺失的输入
4. 在打印 Director Panel 小结之前，所有结论都已收集完毕

**断言（5a）：**
- [ ] 技能在决定小组是否运行之前读取已解析的 `review_mode`
- [ ] 4 位 PHASE-GATE 总监全部被启动（小组宽度来自 `workflow: full`）
- [ ] 总监并行启动（所有 `Agent` 调用在任何结果被等待前就已发出）
- [ ] 任何一位总监的 CONCERNS 结论都会传导为总体至少 CONCERNS
- [ ] 任何一位总监的 NOT READY 结论都会使总体结论至少为 FAIL —— 绝不自动 PASS
- [ ] 总监的 NOT ASSESSED 绝不计为 READY：在没有 NOT READY 或 CONCERNS 伴随的情况下，总体结论为 NOT ASSESSED，且 Director Panel 小结会针对该总监展示这一点

**Case 5b — solo 模式：** `modes.review_mode: solo`（或 `--review solo`）

**预期行为：**
1. 技能判定为 `solo`
2. 不启动任何总监
3. 输出声明："Director Panel skipped — Solo mode. Gate verdict based on
   artifact and quality checks only."
4. 闸门结论仅由产出物/质量检查推导

**断言（5b）：**
- [ ] solo 模式下不启动任何总监闸门
- [ ] 跳过被写入输出（"Director Panel skipped — Solo mode"），而非静默处理
- [ ] 结论仅基于产出物和质量检查
- [ ] 缩小/跳过的小组本身不会使结论变为 NOT ASSESSED

**Case 5c — 宽度跟随 `workflow`，而非 `review_mode`：** `modes.review_mode: full`，`modes.workflow: standard`

**预期行为：**
1. 小组以 `standard` 宽度运行（评审模式不是 `solo`）：只有 `technical-director` + `producer`
2. 输出点名被省略的部分，例如 "Panel: 2 of 4 (`workflow: standard`).
   Creative and Art perspectives not consulted. Set `modes.workflow: full` for
   the complete panel." —— 这里 `workflow` 是单独设置的，因此提高
   `modes.rigor` 不会改变它

**断言（5c）：**
- [ ] 恰好启动 TD-PHASE-GATE 和 PR-PHASE-GATE —— `review_mode: full` 不会加宽小组
- [ ] 输出点名未运行的视角以及如何获得它们：`modes.workflow: full`，即配置块为 `workflow` 显示的来源
- [ ] 输出绝不建议用 `--review full` 加宽小组 —— `--review` 决定小组是否运行，而非其宽度
- [ ] 刻意收窄的小组本身不会产生 NOT ASSESSED

**Case 5d — lean 模式，宽度来自 rigor：** 小组以 `lean` 运行（阶段闸门正是
lean 模式保留的部分）；其宽度仍跟随 `workflow`。

- (i) `project.yaml` 只设置 `modes.rigor: standard` → 配置块解析出
  `review_mode: lean` 和 `workflow: standard`，二者都来自 `rigor:standard`
- (ii) `project.yaml` 设置 `modes.rigor: minimal` 和 `modes.review_mode: lean`
  （显式指定 —— 仅 `rigor: minimal` 会解析出 `solo` 并跳过小组），外加一份
  已填写的 `design/game-brief.md` → `workflow: minimal`

**断言（5d）：**
- [ ] (i)：恰好启动 TD-PHASE-GATE 和 PR-PHASE-GATE，且输出为 "Panel: 2 of 4"，并指向将 `modes.rigor` 提升到 `full`（`workflow` 正是来源于此）
- [ ] (ii)：只启动 PR-PHASE-GATE，且输出为 "Panel: 1 of 4"，点名未运行的三个视角
- [ ] 在两种情况下，lean 模式都不跳过小组，且收窄的小组本身不产生 NOT ASSESSED

---

### Case 6: 总监上下文 — 后续阶段的产出物是 "not expected"，绝不是 "none"

**测试夹具：**
- `project.yaml` 只设置 `modes.rigor: standard` → `workflow: standard`、
  `review_mode: lean`，因此小组为 `technical-director` + `producer`
- 已配置引擎；`design/gdd/systems-index.md` 列出 3 个 MVP 系统，每个都有
  包含 5 个标准小节的 GDD、都经过评审，且有一份结论为 PASS 的
  `/review-all-gdds` 报告；系统索引双向映射依赖并定义了 MVP 层级
- 完全没有 `docs/architecture/`（无架构文档、无 ADR），没有
  `production/sprints/`，也没有用户故事

**输入：** `/gate-check technical-setup`

**预期行为：**
1. 技能加载 `gate-technical-setup.md` 并应用其 `standard` 缩减
2. 技能并行启动 TD-PHASE-GATE 和 PR-PHASE-GATE，向各自传递目标阶段、
   `workflow: standard`，以及该层级下闸门的必需和推荐产出物
3. TD 上下文将架构文档和 ADR 列表作为 "not expected before Pre-Production"
   传入；PR 上下文将冲刺计划作为 "not expected before Production" 传入 ——
   二者都不是 "none"
4. 两位总监都返回 READY；所有产出物和质量检查都通过；结论为 PASS，并
   提供阶段写入

**变体（ii）：** 同一项目在 `/gate-check pre-production`（目标 Pre-Production，
在 `standard` 下要求架构文档）下，而架构文档仍然缺失：TD 上下文将其作为
"none" 传入，这对总监是一个发现（CONCERNS 或 NOT READY），结论不是 PASS。

**断言：**
- [ ] 每位总监都收到目标闸门在已解析层级下的必需和推荐产出物，而不只是阶段名称
- [ ] 对于目标闸门在该层级不要求的产出物，任何总监上下文都不传入 "none" —— 它读作 "not expected before [phase]"（或 "not required at `workflow: [tier]`"）
- [ ] 在每位总监都 READY 且所有检查都通过时，结论为 PASS —— 缺失的架构文档和冲刺计划不会把它变成 CONCERNS
- [ ] 变体（ii）：目标闸门要求且不存在的产出物作为 "none" 传入，绝不是 "not expected"，且结论不是 PASS

---

### Case 7: CONCERNS 覆盖 — 用户接受风险；FAIL 永远不可被覆盖

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: standard` 和 `modes.review_mode: solo`
- `design/gdd/game-concept.md` 含有核心循环和目标受众，且用户确认已评审；
  它没有游戏支柱小节，也没有视觉标识锚点 —— 二者在 `standard` 下都是推荐的，
  因此缺失 → CONCERNS

**输入：** `/gate-check systems-design`，然后在 CONCERNS 结论之后，用户说
"advance anyway"

**预期行为：**
1. 结论为 CONCERNS，点名缺失的游戏支柱和视觉标识锚点；默认不提供阶段写入
2. 应要求，技能列出两项关注项，并提一个问题，同时接受它们并请求写入：
   "…Accept these risks — [list] — and may I update `project.stage` in
   `project.yaml` to 'Systems Design' (and the legacy `production/stage.txt`)?"
3. 在明确肯定后，闸门报告增加一个 `### Accepted Risks` 小节（每项关注项、
   由用户接受、带日期），并写入和重新读取两个阶段文件

**变体（FAIL）：** `design/gdd/game-concept.md` 不存在，结论为 FAIL，用户说
"advance anyway"：技能不写入阶段 —— 任何覆盖都不会把 FAIL 变成阶段变更 ——
而是点名阻塞项和 `/brainstorm`。

**断言：**
- [ ] 在 CONCERNS 下，只有在用户明确接受所列风险后才写入阶段，绝不默认写入
- [ ] 报告在 `### Accepted Risks` 下记录已接受的风险
- [ ] 变体：在 FAIL 下，无论用户要求什么，阶段都绝不写入；NOT ASSESSED 同样如此

---

### Case 8: `workflow: minimal` 下的 `/gate-check production` —— 切片条目被丢弃

**测试夹具：**
- `project.yaml` 只设置 `modes.rigor: minimal` → `workflow: minimal`、
  `qa.level: minimal`、`review_mode: solo`
- `design/game-brief.md` 已填写，包含三个 MVP 功能的 Build order
- `production/epics/core/` 下有三个用户故事文件，每个功能一个
- 没有 `prototypes/`，没有垂直切片，没有冲刺计划，没有试玩测试报告

**输入：** `/gate-check production`；用户对两个当前构建问题都回答是
（核心循环有趣；一个"开始 → 挑战 → 解决"循环能端到端运行）

**预期行为：**
1. 技能运行 `artifact-check.sh --phase pre-production` 和
   `artifact-check.sh --path minimal`；`game-brief` 和 `create-stories`
   两行是底线
2. 垂直切片条目不在 Required Artifacts 列表中，也不引发 CONCERNS ——
   在 `minimal` 下它们被丢弃，两个当前构建检查取而代之
3. 结论为 PASS；提供阶段写入，然后是一行 rigor 契合度提示
   （Production 运行在 `rigor: minimal` 上）

**变体：** 对 "it runs end to end" 回答 "no" → FAIL（损坏的构建不推进，
正如其他层级下损坏的切片不推进一样）；对 "the core loop is fun" 回答
"not yet" → NOT ASSESSED（没有人玩过该构建）。

**断言：**
- [ ] 在 `minimal` 下，没有垂直切片条目被列为缺失或转为 CONCERNS
- [ ] 两个当前构建检查被询问并决定结论：都回答是 → PASS；回答 "no" → FAIL；对趣味问题回答 "not yet" → NOT ASSESSED
- [ ] 底线从 `artifact-check.sh --path minimal` 读取，而不是打开文件查看存在什么

---

### Case 9: 其层级文件标记为 "not applicable" 的闸门

**测试夹具：** `project.yaml` 设置 `modes.rigor: minimal` 和 `modes.review_mode:
lean`（否则小组会运行）；一份已填写的 `design/game-brief.md`；没有 GDD

**输入：** `/gate-check technical-setup`

**预期行为：** Systems Design → Technical Setup 闸门在 `minimal` 下不适用：
结论为 PASS，并附带闸门文件的说明（"No design gate at minimal workflow…"），
输出写着 "Director Panel skipped — gate not applicable at `workflow: minimal`"，
且阶段写入在执行前仍会询问。

**断言：**
- [ ] 结论为 PASS，而非 NOT ASSESSED —— 不适用的闸门是"没有剩余必需产出物的闸门不得 PASS"这一规则的具名例外
- [ ] 打印闸门文件的说明，且不启动任何总监
- [ ] 缺失的 GDD 不被报告为阻塞项

---

### Case 10: minimal 层级的收尾路径 —— 已构建但无简报的游戏被送往 `/reverse-document`

**测试夹具：**
- `project.yaml` 设置 `modes.rigor: minimal`（因此 `workflow: minimal`）和
  `engine.name: Godot`
- `src/` 下有 15 个 GDScript 文件（代码根目录已包含该游戏）
- 没有 `design/game-brief.md`，没有 `design/gdd/game-concept.md`，没有 GDD
- 变体：`src/` 为空（新项目）

**输入：** `/gate-check systems-design`

**预期行为：**
1. `minimal` 下的目标产出物是 `design/game-brief.md`；它缺失，因此结论为
   FAIL，点名该简报为阻塞项
2. 不写入阶段
3. 收尾的下一步部件跳过阶段阶梯菜单（`/map-systems`、`/design-system`），
   因为 minimal 路径不是阶梯，并提供 `paths.minimal` 中第一个未完成的步骤：
   简报
4. 由于代码根目录已包含该游戏，该步骤是
   `/reverse-document design src/`（它从已构建的内容写出简报），而不是
   `/brainstorm`
5. 变体（空 `src/`）：该步骤是 `/brainstorm`

**断言：**
- [ ] 收尾部件由 minimal 路径构建，没有 `/map-systems` 或 `/design-system` 选项
- [ ] 在已构建游戏且无简报的情况下，第一个选项是 `/reverse-document design src/`，且已填入代码根目录，`/brainstorm` 不作为获取简报的方式提供
- [ ] 变体 —— 代码根目录为空时，第一个选项是 `/brainstorm`，而不是 `/reverse-document`
- [ ] 结论为 FAIL，且无论提供哪条路径都不写入阶段

---

## Protocol Compliance

- [ ] 在更新阶段前询问（"May I update `project.stage` in `project.yaml` … (and the legacy `production/stage.txt`)?"）
- [ ] 在请求写入批准前展示完整清单报告
- [ ] 以 "Follow-Up Actions" 小节结尾，按结论列出下一步
- [ ] 未经用户明确确认绝不推进阶段 —— 在 NOT ASSESSED 或 FAIL 下绝不推进，在 CONCERNS 下也只在用户明确接受所列风险后才推进，报告会在 `### Accepted Risks` 下记录这些风险
- [ ] 未经询问绝不自动创建 `production/stage.txt` 或 `project.yaml`
- [ ] 绝不创建缺失产出物来把 FAIL 变成 PASS

---

## Coverage Notes

- Production → Polish 和 Polish → Release 闸门不在此覆盖，因为它们需要复杂的
  多产出物设置（冲刺计划、试玩测试数据、QA 签署）；这些推迟到专门的后续规格。
- `minimal` 层级的 Concept 闸门目标（`design/game-brief.md` 而非
  `game-concept.md`）以及 `system_overrides` 键校验未被覆盖。
- 垂直切片校验块（`standard`/`full` 下的 Pre-Production → Production 闸门）
  未被覆盖，因为它需要可玩构建的上下文，无法表达为文档 fixture；在 `minimal`
  下它被丢弃（Case 8）。
- `minimal` 收尾路径只测试了缺失简报这一步（Case 10）；后续步骤
  （`/create-stories`、`/dev-story`）未单独测试。
