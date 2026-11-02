# Skill Test Spec: /ux-design

## Skill Summary

`/ux-design` 逐节编写 UX 文档。参数决定模式和输出文件：`hud` → `design/ux/hud.md`；`patterns` → `design/ux/interaction-patterns.md`；`accessibility` → `design/accessibility-requirements.md`（唯一在 `design/ux/` 之外写入的模式）；其他任何值 → `design/ux/[kebab-name].md` 处的屏幕/流程规格。无参数时，它询问 “What are we designing today?”，而不是报错。

Phase 2 在询问任何内容之前先读取上下文：游戏概念（或游戏简报）、玩家旅程、GDD 的 UI Requirements、现有 UX 规格、模式库目录、美术设定集、无障碍需求，以及 `project.yaml` `platform` 块中的输入方式。如果输出文件已存在，技能进入 retrofit 模式，只填充 Empty 或 Placeholder 小节。否则它询问 “May I create the skeleton file at [path]?” 并写入该模式的骨架。

随后每个小节运行 Context → Questions → Options → Decision → Draft → Approval → Write：“Does this capture the [section name] correctly?”，然后 “May I write the [section name] section to `[filepath]`?”，再用 Edit 替换占位符。在各模式的指导文件中，只加载当前模式的那一份，模板指南则一次读取一个小节。经过交叉引用检查后，交接说明规格必须通过 `/ux-review`，并以结论 `COMPLETE` 结束。没有总监质量闸门（director gate）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：`COMPLETE`
- [ ] 包含每个小节的 “May I write” 用语，以及针对骨架的 “May I create”
- [ ] 包含下一步交接（用 `/ux-review` 验证已完成的规格）
- [ ] 记录四种模式及其输出路径，包括 `accessibility` 对应的 `design/accessibility-requirements.md`

---

## Director Gate Checks

无。`/ux-design` 只解析 `automation`、`workflow` 和 `docs.density`（不解析 `review_mode`），也不启动总监闸门。`/ux-review` 是单独的验证步骤。可就子主题咨询专家（`art-director`、`ui-programmer`、`game-designer`、`narrative-director`）；其输出会呈现给用户，且本会话负责所有文件写入。

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 新的 HUD 设计

**Fixture:**
- 没有 `design/ux/hud.md`
- `design/gdd/combat.md` 和 `design/gdd/stamina.md` 有 `## UI Requirements` 小节；`design/gdd/save-system.md` 没有
- `project.yaml` 有 `platform` 块（`targets: [PC]`、`gamepad_support: Full`）
- `design/gdd/game-concept.md` 和 `design/player-journey.md` 存在

**Input:** `/ux-design hud`

**Expected behavior:**
1. 模式为 HUD 设计；输出文件为 `design/ux/hud.md`
2. UI Requirements 通过对 `design/gdd/*.md` 的一次 Grep 收集；技能统计三份系统 GDD——`game-concept.md` 位于 `design/gdd/` 但不属于系统 GDD——将 `save-system.md` 列为未匹配，并在排除它之前与用户确认它是无界面（headless）的
3. 输入方式从 `platform` 块推导（键盘/鼠标和手柄）——不询问用户
4. 展示上下文摘要，然后询问 “Anything else I should read before we start, or shall we proceed?”
5. 没有现有文件，因此询问：“May I create the skeleton file at `design/ux/hud.md`?”——用户同意后，写入 HUD 骨架并更新 `production/session-state/active.md`。骨架包含 `/ux-review` 的 HUD 检查清单要求的所有小节，使完成的规格能够通过该评审
6. Phase 4 读取 `.claude/skills/ux-design/references/sections-hud.md`，绝不读取另外两份按模式的指导文件（`sections-ux-spec.md`、`sections-patterns.md`）；若某个小节需要深入，HUD 设计指南会一次读取一个小节，绝不整份读取
7. 每个小节：起草 → “Does this capture the [section name] correctly?” → “May I write the [section name] section to `design/ux/hud.md`?” → 用 Edit 替换该小节的占位符
8. Phase 5 展示交叉引用检查（Cross-Reference Check）结果
9. Phase 6 说明规格在实现前应用 `/ux-review` 验证，然后以四个选项询问（立即运行 `/ux-review` / 设计另一个屏幕 / 更新模式库 / 停止）；结论 `COMPLETE`

**Assertions:**
- [ ] 没有 UI Requirements 小节的 GDD 会被列出并与用户确认，而不是静默排除
- [ ] `game-concept.md` 不计为系统 GDD，因此不会被列为未匹配
- [ ] 输入方式来自 `project.yaml` 的 `platform` 块，不询问用户
- [ ] 骨架只在 “May I create the skeleton file at `design/ux/hud.md`?” 批准之后写入
- [ ] HUD 骨架包含 `/ux-review` Phase 3B 检查的所有小节：HUD Philosophy、Information Architecture、Layout Zones、HUD element specifications、HUD States by Gameplay Context、Information Hierarchy、Visual Budget、Feedback & Notification Systems、Platform Adaptation、Tuning Knobs、Acceptance Criteria
- [ ] 在三份按模式的指导文件中，只加载 `sections-hud.md`，且不整份读取任何指南
- [ ] 每个小节先获批，然后在写入前单独询问 “May I write the [section name] section…”
- [ ] 交接说明实现前必须运行 `/ux-review`，且结论为 `COMPLETE`

---

### Case 2: 已有文档 — 仅对不完整小节执行 retrofit

**Fixture:**
- Scenario (a)：`design/ux/main-menu.md` 存在，基于 UX 规格骨架构建；Purpose & Player Need、Player Context on Arrival、Navigation Position 和 Entry & Exit Points 有实际内容；其他每个小节均为 `[To be designed]`
- Scenario (b)：`design/accessibility-requirements.md` 存在，基于无障碍骨架构建；Accessibility Tier Definition 承诺 Standard 层级；其他每个小节均为 `[To be designed]`

**Input:** (a) `/ux-design main-menu` (b) `/ux-design accessibility`

**Expected behavior:**
1. 在任何骨架步骤之前，技能用 glob 匹配输出路径——在 (b) 中是 `design/accessibility-requirements.md`，而不是 `design/ux/` 下的路径——并找到该文件
2. 它读取文件，将每个小节分类为 Complete / Empty / Placeholder，展示状态表，并以 “I'll work on the [N] incomplete sections only — existing content will not be overwritten.” 结尾
3. 跳过骨架创建
4. Phase 4 只编写 Empty/Placeholder 小节，在获得 “May I write” 批准后用 Edit 就地填充每个占位符
5. (a) 四个完整小节不变；(b) 已承诺的层级不变

**Assertions:**
- [ ] 检测到现有文件，不写入骨架
- [ ] 在编写之前展示状态表和 “incomplete sections only” 消息
- [ ] 仅编写 Empty 或 Placeholder 小节；完整小节不被覆盖
- [ ] 每个填充的小节都在各自的 “May I write” 批准之后用 Edit 写入
- [ ] (a) 状态表各行使用 UX 规格骨架的小节名称（例如 `Purpose & Player Need`、`Layout Specification`、`States & Variants`、`Input Method Completeness Checklist`）
- [ ] (b) 状态表各行使用无障碍骨架的小节名称（例如 `Accessibility Tier Definition`、`Visual Accessibility`、`Motor Accessibility`），且文件保持在 `design/accessibility-requirements.md`

---

### Case 3: 上下文缺失 — 没有游戏概念，也没有玩家旅程

**Fixture:**
- 没有 `design/gdd/game-concept.md`，也没有 `design/game-brief.md`
- 没有 `design/player-journey.md`
- 没有 `design/ux/inventory.md`

**Input:** `/ux-design inventory`

**Expected behavior:**
1. 技能警告：“No game concept found. Run `/brainstorm` first to establish the game's foundation before designing UX.”，并且只有在用户要求时才继续
2. 它指出缺少旅程：“No player journey map found at `design/player-journey.md`. Designing without it means we'll be making assumptions about player context…”
3. 上下文摘要显示 “Journey phase(s): unknown — no journey map”
4. 规格的 Open Questions 小节记录：“Player journey map not yet created. Author it from the template at `.claude/docs/templates/player-journey.md`…”
5. 技能绝不告诉用户去运行 `/ux-design` Phase 2b 来创建旅程图

**Assertions:**
- [ ] 缺少游戏概念时产生 `/brainstorm` 警告，且技能只有在用户同意后才继续
- [ ] 在对话中指出缺少玩家旅程，并在 Open Questions 中连同模板路径一起记录
- [ ] 补救措施指向模板，绝不指回 `/ux-design`
- [ ] 上下文摘要将旅程阶段标记为未知

---

### Case 4: 未提供参数 — 询问而不是失败

**Fixture:**
- 没有参数
- `design/ux/main-menu.md` 和 `design/accessibility-requirements.md` 都不存在，因此两种场景都会新建文件
- Scenario (a)：用户输入 “Main Menu”
- Scenario (b)：用户选择 “The project-wide accessibility requirements”

**Input:** `/ux-design`

**Expected behavior:**
1. 技能不会失败；它询问 “What are we designing today?”，选项为：“A specific screen or flow (I'll name it)”、“The game HUD”、“The interaction pattern library”、“The project-wide accessibility requirements”、“I'm not sure — help me figure it out”
2. (a) 名称被规范化为 kebab-case；输出文件为 `design/ux/main-menu.md`
3. (b) 输出文件为 `design/accessibility-requirements.md`，骨架询问指明该路径，而不是 `design/ux/` 下的路径
4. (b) 首先编写 Accessibility Tier Definition 小节
5. 在骨架获批之前不创建任何文件

**Assertions:**
- [ ] 不出现用法错误；询问 “What are we designing today?” 并提供五个选项
- [ ] (a) 输入的屏幕名称会转换为 `design/ux/` 下的 kebab-case 文件名
- [ ] (b) 无障碍模式写入 `design/accessibility-requirements.md`
- [ ] (b) 层级定义先于其他无障碍小节编写
- [ ] 在骨架获批之前不写入任何文件

---

### Case 5: 无总监闸门 — `/ux-review` 是单独的评审

**Fixture:**
- `project.yaml` 中 `modes.review_mode: full`，并有 `platform` 块（`targets: [PC, Console]`、`gamepad_support: Full`）
- 没有 `design/ux/settings-menu.md`

**Input:** `/ux-design settings-menu`

**Expected behavior:**
1. 技能照常编写屏幕规格；不解析评审模式，也没有任何分支依赖它
2. UX 规格骨架的头部包含从 Phase 2h 填入的 `> **Platform Target**:`——PC 和 Console、键盘/鼠标和手柄——这是 `/ux-review` 检查的行
3. 不启动任何总监闸门代理，也不出现闸门 ID 或跳过说明
4. 若咨询了专家（例如就可行性咨询 `ui-programmer`），其输出会展示给用户，并由本会话——而不是代理——写入文件
5. 运行以 `/ux-review` 说明和结论 `COMPLETE` 结束

**Assertions:**
- [ ] 骨架头部的 Platform Target 行使用 `platform` 块中的目标和输入方式
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] `modes.review_mode: full` 不会改变技能的行为
- [ ] 专家输出会呈现给用户；代理绝不写入文件
- [ ] 结论为 `COMPLETE`，并指明 `/ux-review` 为验证步骤

---

### Case 6: 交接 — 指明 Production 闸门以及评审要求取决于什么

**Fixture:**
- `modes.rigor: standard`（固定：交接说明 Production 闸门如何按工作流层级对待
  `/ux-review`，而 `standard` 正是推荐运行它的层级）
- 一份屏幕规格 `design/ux/settings-menu.md`，其所有小节都已批准并
  写入；交叉引用检查已运行
- 变体：用户选择 “Design another screen first, then review all specs together”

**Input:** `/ux-design settings-menu`（继续到交接）

**Expected behavior:**
1. Phase 6 更新 `production/session-state/active.md`
2. 在提供选项之前，它说明：“This spec should be validated with
   `/ux-review` before it enters the implementation pipeline. The Production gate
   (`/gate-check production`) requires all key screen specs to have passed
   `/ux-review` at `workflow: full` (recommended at `standard`).”
3. 随后询问 “Run `/ux-review [filename]` now, or do something else first?”，
   提供四个选项（立即运行 / 设计另一个屏幕 / 更新模式库 / 停止）
4. 变体：它会补充 “Reminder: run `/ux-review` on all completed specs before
   running `/gate-check production`.”
5. 收尾的下一步包括：在所有关键屏幕都有已批准的 UX 规格后运行
   `/gate-check production`
6. 结论：`COMPLETE`

**Assertions:**
- [ ] 交接指明 `/gate-check production` 是依赖 `/ux-review` 的闸门，而不只是 `/ux-review` 本身
- [ ] 说明该要求在 `workflow: full` 下适用、在 `standard` 下仅为推荐，因此不会告诉 `standard` 项目该评审是强制性的
- [ ] 该说明出现在选项问题之前
- [ ] 变体——选择 “Design another screen first” 时会补充指明 `/gate-check production` 的提醒
- [ ] 下一步在屏幕规格获批后列出 `/gate-check production`
- [ ] 结论为 `COMPLETE`

---

## Protocol Compliance

- [ ] 一旦知道模式——无参数时，模式问题最先出现（Case 4）——在询问用户其他任何内容之前读取上下文
- [ ] 在创建骨架之前检查是否存在输出文件；retrofit 只填充 Empty 或 Placeholder 小节
- [ ] 骨架只在 “May I create the skeleton file at [path]?” 之后创建
- [ ] 小节逐节起草；每个小节先获批，然后在写入前询问 “May I write the [section name] section to `[filepath]`?”
- [ ] 加载当前模式的按模式指导文件，绝不加载另外两份；模板指南一次读取一个小节，绝不整份读取
- [ ] 以 `/ux-review` 交接和结论 `COMPLETE` 结尾

---

## Coverage Notes

- 模式库模式（`patterns`）未做 fixture 测试。
- 当 `project.yaml` 和 `technical-preferences.md` 都未配置平台时的
  输入方式询问未测试。
- Phase 5 对尚未进入模式库的模式给出的提示未单独测试。
- `guided` 和 `autonomous` 自动化模式、`docs.density` 深度，以及
  会话中断后的恢复未测试。
