# Skill Test Spec: /brainstorm

## Skill Summary

`/brainstorm` 引导游戏概念的构思过程。它**首先**根据解析后的 `workflow` 层级
进行分支：

- **`minimal`**（默认值——`modes.rigor` 默认为 `minimal`）运行
  **Lean Brief 流程**：2–3 个一句话概念、一次选择、以对话方式填写简报字段，
  并在用户回答 "Brief is ready. May I write it to `design/game-brief.md`?" 之后
  写出一页式 `design/game-brief.md`。不运行任何总监闸门，也不写入
  `game-concept.md`。
- **`standard` / `full`** 运行完整流程：创意发现、3 个不同概念、核心循环、
  游戏支柱、玩家类型、范围，然后在用户回答 "Game concept is ready. May I write it to
  `design/gdd/game-concept.md`?" 之后写出 `design/gdd/game-concept.md`。

在完整流程中，总监闸门在三个时点分别运行，而非一起运行：CD-PILLARS
（creative-director）与 AD-CONCEPT-VISUAL（art-director）在游戏支柱达成一致后
并行运行（Phase 4）；TD-FEASIBILITY（technical-director）在技术风险识别之后、
范围分层之前运行（Phase 6）；PR-SCOPE（producer）在范围分层确定之后运行。
评审模式来自解析后的配置（`--review` 可覆盖）；`lean` 与 `solo` 会跳过全部四个，
并各自给出具名说明。两条流程都以 `Verdict: **COMPLETE**` 结束。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE（在 Lean Brief 流程与完整流程中均是）
- [ ] 对 `design/game-brief.md` 与 `design/gdd/game-concept.md` 都包含 "May I write" 措辞
- [ ] 结尾有下一步交接（完整流程的 design-first 步骤中的 `/map-systems`；Lean Brief 流程中的 `/create-stories`）
- [ ] 在 full 模式下记录 4 个总监闸门：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
- [ ] 在 lean 与 solo 模式下为每个闸门记录具名跳过说明

---

## Director Gate Checks

仅完整流程（`workflow: standard` 或 `full`）：

- **Full 评审模式**：CD-PILLARS 与 AD-CONCEPT-VISUAL 在游戏支柱达成一致后并行生成；
  TD-FEASIBILITY 在技术风险识别后生成；PR-SCOPE 在范围分层确定后生成。
- **Lean 评审模式**：全部 4 个跳过（没有一个是 PHASE-GATE）。说明为
  "CD-PILLARS skipped — Lean mode."、"AD-CONCEPT-VISUAL skipped — Lean mode."、
  "TD-FEASIBILITY skipped — Lean mode."、"PR-SCOPE skipped — Lean mode."
- **Solo 评审模式**：全部 4 个跳过，说明相同，但为 "Solo mode"。

`workflow: minimal`（Lean Brief 流程）：完全不生成任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Full 模式、3 个概念、闸门在三个时点运行

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full`（`workflow` → `full`，`review_mode` → `full`）
- 没有现存的 `design/gdd/game-concept.md`
- CD-PILLARS 返回 APPROVE；TD-FEASIBILITY 返回 VIABLE，PR-SCOPE 返回 REALISTIC（各闸门自己的结论词）

**Input:** `/brainstorm`

**Expected behavior:**
1. 层级分支：`full` → 完整流程
2. Phase 1 提出发现性问题（最喜欢的游戏以纯文本回答；Experience / Timeline /
   Dev level 问题一起提出）
3. Phase 2 呈现 3 个概念，然后用一个含五个选项的问题进行选择
4. 游戏支柱锁定后，CD-PILLARS 与 AD-CONCEPT-VISUAL 并行生成；其结果以两个
   一起提出的问题呈现（Pillars / Visual anchor）
5. Phase 6 询问平台与引擎（引擎问题总会被提示）；TD-FEASIBILITY 在风险识别后、
   范围分层之前生成
6. PR-SCOPE 在范围分层确定后生成
7. 技能询问 "Game concept is ready. May I write it to `design/gdd/game-concept.md`?"
8. 获批后写入，含 Visual Identity Anchor 一节；design-first 的后续步骤包含 `/map-systems`
9. 结论为 COMPLETE

**Assertions:**
- [ ] 恰好呈现 3 个概念选项
- [ ] CD-PILLARS 与 AD-CONCEPT-VISUAL 作为同时发出的 `Agent` 调用下发
- [ ] TD-FEASIBILITY 在范围分层确定之前生成；PR-SCOPE 在其之后
- [ ] 写入之前询问 "May I write it to `design/gdd/game-concept.md`?"
- [ ] 概念文档包含 Visual Identity Anchor 一节
- [ ] 下一步交接列出 `/map-systems`
- [ ] 结论为 COMPLETE

---

### Case 2: Failure Path — CD-PILLARS 返回 REJECT

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full`
- 游戏支柱与反支柱已与用户达成一致
- CD-PILLARS 返回 REJECT："The pillars do not carry weight — none forces a design choice"
- AD-CONCEPT-VISUAL 返回 3 个具名视觉方向

**Input:** `/brainstorm`

**Expected behavior:**
1. 两个闸门已并行生成；技能收集两个结果
2. 由于 CD-PILLARS 返回 REJECT，两个问题**不会**一起提出：creative-director
   的反馈单独放在一个 Pillars 问题中呈现，选项为 `Lock in as-is` / `Revise [specific pillar]` / `Discuss further`
3. 先解决游戏支柱问题；只有之后才单独提出 Visual anchor 问题，并附上
   art-director 的 3 个方向
4. 只要游戏支柱问题尚未解决，技能就不会进入文档生成或写入询问

**Assertions:**
- [ ] CD-PILLARS 的反馈展示给用户
- [ ] 向用户提供 `Revise [specific pillar]` 与 `Discuss further`（也可以 `Lock in as-is`）
- [ ] REJECT 之后的第一个问题不含 Visual anchor 问题
- [ ] 在游戏支柱问题解决之前不请求选择视觉锚点
- [ ] 此时不写入 `design/gdd/game-concept.md`

---

### Case 3: Lean Mode — 全部 4 个闸门以具名说明跳过

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`（`workflow` → `standard`，`review_mode` → `lean`）
- 没有现存的游戏概念

**Input:** `/brainstorm`

**Expected behavior:**
1. 层级分支：`standard` → 完整流程
2. Phase 4："CD-PILLARS skipped — Lean mode. AD-CONCEPT-VISUAL skipped — Lean mode."
3. Phase 6："TD-FEASIBILITY skipped — Lean mode."，随后 "PR-SCOPE skipped — Lean mode."
4. 不生成任何总监代理
5. 询问 "Game concept is ready. May I write it to `design/gdd/game-concept.md`?"
6. 获批后写入；结论为 COMPLETE

**Assertions:**
- [ ] 4 条跳过说明全部出现，每条都指明其闸门与 "Lean mode"
- [ ] 不为任何总监发起 `Agent` 调用
- [ ] 写入之前仍然询问 "May I write"
- [ ] 结论为 COMPLETE

---

### Case 4: Solo Default — Minimal 层级运行 Lean Brief 流程

**Fixture:**
- `project.yaml` 设置了 `engine.name`，且没有 `modes` 块（`modes.rigor`
  默认为 `minimal`：`workflow` → `minimal`，`review_mode` → `solo`）
- 没有 `design/game-brief.md`，没有 `design/gdd/game-concept.md`

**Input:** `/brainstorm roguelike`

**Expected behavior:**
1. 层级分支：`minimal` → Lean Brief 流程；跳过 Phase 1–5
2. 根据提示提出 2–3 个一句话概念，并提一个问题供选择或组合
3. 以对话方式填写简报字段（pitch、core loop、player goal & fail
   state、MVP、out of scope、build order），并呈现简报以供一次确认
4. 询问 "Brief is ready. May I write it to `design/game-brief.md`?"，选项为
   `[A] Yes — write it` / `[B] Revise a field first`
5. 后续步骤：`/create-stories`，然后 `/dev-story`；**不**列出 `/setup-engine`，
   因为 `engine.name` 已设置
6. 结论为 COMPLETE

**Assertions:**
- [ ] 输出文件为 `design/game-brief.md`；不写入 `design/gdd/game-concept.md`
- [ ] 提出 2–3 个一句话概念（而不是完整的 9 字段概念卡片）
- [ ] 不生成任何总监代理
- [ ] 后续步骤列出 `/create-stories` 与 `/dev-story`，而不是 `/map-systems` 或 `/setup-engine`
- [ ] 结论为 COMPLETE

---

### Case 5: Director Gate — PR-SCOPE 返回 UNREALISTIC

**Fixture:**
- `project.yaml` 设置 `modes.rigor: full`
- 概念、游戏支柱与范围分层均已确定
- PR-SCOPE 返回 UNREALISTIC："The MVP would take 18+ months for a solo developer"
- 用户把 MVP 削减到技能提供的调整后分层，然后对写入询问回答
  `[A] Yes — write it`

**Input:** `/brainstorm`

**Expected behavior:**
1. PR-SCOPE 在范围分层确定后生成
2. 技能向用户呈现 producer 的评估
3. 由于结论为 UNREALISTIC，技能在写入文档之前提出调整 MVP
   定义或范围分层
4. 写入询问只在该提议解决之后才提出；由用户决定
5. 用户批准写入后，写入 `design/gdd/game-concept.md`

**Assertions:**
- [ ] 在 "May I write" 询问之前向用户展示 PR-SCOPE 评估
- [ ] 技能提出调整 MVP 定义或范围分层
- [ ] 技能**不会**丢弃或自动否决该概念——由用户决定
- [ ] 仅在用户批准写入之后才写入概念
- [ ] 写入的概念中的 "Estimated Scope" 与 Scope Tiers 时间线一致（例如 "Large (X–Y months, solo)"）

---

### Case 6: Solo Review on the Full Flow — 全部 4 个闸门以 Solo 模式说明跳过

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`（`workflow` → `standard`）
- 没有现存的游戏概念

**Input:** `/brainstorm --review solo`

**Expected behavior:**
1. 层级分支：`standard` → 完整流程；`--review solo` 覆盖本次运行解析出的
   `review_mode`
2. Phase 4："CD-PILLARS skipped — Solo mode. AD-CONCEPT-VISUAL skipped — Solo mode."
3. Phase 6："TD-FEASIBILITY skipped — Solo mode."，随后 "PR-SCOPE skipped — Solo mode."
4. 不生成任何总监代理
5. 询问 "Game concept is ready. May I write it to `design/gdd/game-concept.md`?"，
   并在获批后写入概念；结论为 COMPLETE

**Assertions:**
- [ ] 4 条跳过说明全部出现，每条都指明其闸门与 "Solo mode"（而非 "Lean mode"）
- [ ] 不为任何总监发起 `Agent` 调用
- [ ] 仅在用户批准之后才写入概念
- [ ] 结论为 COMPLETE

---

## Protocol Compliance

- [ ] 先于其他一切检查 `workflow`，并且只运行一条流程
- [ ] 完整流程在用户作出承诺前呈现 3 个概念；Lean Brief 流程呈现 2–3 个一句话概念
- [ ] 概念选择始终会询问，与 `modes.automation` 无关
- [ ] 在 full 模式下闸门在各自的时点生成（CD-PILLARS 与 AD-CONCEPT-VISUAL 一起；TD-FEASIBILITY；PR-SCOPE）
- [ ] 在完整流程（`workflow: standard` / `full`）中，lean 与 solo 模式会跳过全部 4 个闸门并逐一具名说明；Lean Brief 流程完全不生成闸门
- [ ] 在写入 `design/game-brief.md` 或 `design/gdd/game-concept.md` 之前询问 "May I write"
- [ ] 以结论 COMPLETE 与该层级的下一步交接收尾

---

## Coverage Notes

- TD-FEASIBILITY 返回 HIGH RISK（提议重新审视范围）未单独测试。
- 闸门回答 NOT ASSESSED（缺少某项输入）绝不等同于批准——会指明缺失的输入并
  重新运行闸门，或把结果记录为 not assessed；未单独测试。
- 概念细化循环（"Generate fresh directions"）未做 fixture 测试。
- 续用已有的 `design/game-brief.md` 或 `design/gdd/game-concept.md` 未单独测试。
- 游戏支柱循环与写入循环在 `guided` / `autonomous` 自动化下的行为未在此测试。
