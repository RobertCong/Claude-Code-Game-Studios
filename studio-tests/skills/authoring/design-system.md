# Skill Test Spec: /design-system

## Skill Summary

`/design-system <system-name>` 为单个系统在 `design/gdd/[system-name].md` 编写游戏设计文档（GDD）。需要哪些小节取决于解析出的 `workflow` 层级（该系统的 `system_overrides` 行优先）：`full` 下全部 8 个（Overview、Player Fantasy、Detailed Design、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria）；`standard` 下 5 个加条件性的 Formulas；自愿的 `minimal` 下 5 个。`## Summary` 在每个层级都会编写，且位于其他小节之后。

五个阶段中的每一个都是 `references/N-*.md` 文件，技能在执行该阶段之前读取它，如果在该阶段期间对话被压缩（compacted），则再次读取。

技能先读取上下文（游戏概念、系统索引、实体注册表、依赖 GDD 的小节、引擎参考资料），呈现上下文摘要和技术可行性简报（Technical Feasibility Brief），然后询问 “May I create the skeleton file at `design/gdd/[system-name].md`?”。随后每个小节运行 Context → Questions → Options → Decision → Draft → Approval → Write 循环：在 `collaborative` 模式下，草稿和 “Approve the [Section Name] section?” 组件出现在同一响应中，获批的小节立即用 Edit 写入。每个小节都会咨询专家代理，受各小节的评审模式检查约束。

所有小节写完后，CD-GDD-ALIGN 闸门只在 `full` 模式下运行一次。`retrofit <path>` 只填充现有 GDD 中缺失或占位的小节。技能绝不内联提供 `/design-review`——它会引导用户到新会话。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：`APPROVED`、`CONCERNS`、`BLOCKED`
- [ ] 包含 “May I write” / “May I create” 协作协议用语（骨架和逐节审批）
- [ ] 结尾包含下一步交接
- [ ] 记录骨架优先方式（获批后先创建带标题的文件，再填写内容）
- [ ] 记录 CD-GDD-ALIGN 闸门：仅在 full 模式下运行；在 lean 和 solo 下跳过并给出明确说明
- [ ] 记录针对现有 GDD 文件的 retrofit 模式

---

## Director Gate Checks

评审模式取自解析后的 `review_mode`（`project.yaml` 中的 `modes.review_mode`）；`--review full|lean|solo` 可对单次运行进行覆盖。

**CD-GDD-ALIGN**（`creative-director`）在 Step 5a-bis 中运行一次，时机是所有小节和 Summary 都已写入、且自检已从文件中读回 GDD 之后。它接收 GDD 路径、游戏支柱、MDA 美学目标以及 GDD 的 Player Fantasy 小节（或说明该层级未编写该小节）。结论记录在 GDD 的 Status 头中，格式为 `> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]`。

- `full` → 启动。
- `lean` → 跳过（不是 PHASE-GATE）。说明：“CD-GDD-ALIGN skipped — Lean mode.”
- `solo` → 跳过。说明：“CD-GDD-ALIGN skipped — Solo mode.”

各小节的专家启动（不是总监闸门）有自己的检查：`solo` 全部跳过；`lean` 跳过它们，但以下情况除外：Section D（Formulas）和 H（Acceptance Criteria）；当 Section D 定义了可调参数相互作用的公式时的 Section G（Tuning Knobs）；以及当系统的视觉反馈处于核心地位时的 Visual/Audio（即玩家需要读取其事件来游玩的 `Gameplay` 或 `UI` 系统）；`full` 会启动它们。每次跳过的启动都会打印该小节的说明，指明代理和模式，例如 “`creative-director` not consulted — Lean mode. Review manually before production.”

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 新建 combat GDD，full 模式，full 工作流

**Fixture:**
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在；`combat` 被列出，`Category: Gameplay`
- 没有 `design/gdd/combat.md`
- `project.yaml` 中 `engine.name: Godot`，`modes.review_mode: full`，`modes.workflow: full`，`modes.automation: collaborative`；`docs/engine-reference/godot/` 包含 `VERSION.md` 和 `modules/physics.md`（combat 映射到 Physics 领域）
- CD-GDD-ALIGN 返回 APPROVE

**Input:** `/design-system combat`

**Expected behavior:**
1. Phase 2 在询问任何内容之前读取游戏概念、系统索引、实体注册表（若存在）和依赖 GDD 的小节，然后呈现 “Designing: Combat” 上下文摘要和技术可行性简报及其 `AskUserQuestion`
2. 询问 “Ready to start designing combat?”
3. 询问 “May I create the skeleton file at `design/gdd/combat.md`?”——用户同意后，写入骨架，包含全部 8 个必需小节以及模板中的其他小节，每个小节均为 `[To be designed]`；更新 `production/session-state/active.md`
4. 按顺序走查 Section A–H；每个草稿都在同一响应中跟随 “Approve the [Section Name] section?”，选项为 `[A] Approve — write it to file` / `[B] Make changes — describe what to fix` / `[C] Start over`
5. Section B 咨询 `creative-director`；Section C 并行启动 Combat 行的 `game-designer` 及支持代理；Section D 启动 `systems-designer`；Section E `systems-designer`；Section H `qa-lead`
6. 每个获批的小节立即由一次 Edit 写入，其 `old_string` 包含该小节标题；每写完一个就更新 `active.md`
7. Visual/Audio 和 Game Feel 被视为必需（Gameplay 类别）——不提供为可跳过项
8. `## Summary` 在其他小节之后编写；Step 5a 从文件中读回 GDD
9. CD-GDD-ALIGN 启动一次并返回 APPROVE；Status 头记录 `APPROVED [date]`
10. 完成摘要引导用户在新会话中运行 `/design-review design/gdd/combat.md`

**Assertions:**
- [ ] 骨架只在 “May I create the skeleton file” 批准之后写入，且包含全部 8 个必需的小节标题
- [ ] 每个小节草稿都在同一响应中跟随 “Approve the [Section Name] section?” 组件
- [ ] 每个小节都在其批准之后立即通过一次以其标题为锚点的 Edit 单独写入
- [ ] Section C 的专家来自路由表的 Combat 行，并在起草前并行启动
- [ ] CD-GDD-ALIGN 在所有小节和 Summary 写入之后启动一次——而不是每个小节启动一次
- [ ] 结论记录为 `> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [date]`
- [ ] `/design-review` 被引导到新会话，绝不内联提供

---

### Case 2: Retrofit 模式 — 在 standard 层级只填充不完整小节

**Fixture:**
- `project.yaml` 中 `engine.name: Godot`，`modes.workflow: standard`，`modes.review_mode: lean`
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在；`inventory` 被列出，`Category: Economy`（引擎领域 Scripting）
- `docs/engine-reference/godot/` 包含 `VERSION.md` 和 `modules/`，但没有 `modules/scripting.md`
- `design/gdd/inventory.md` 存在，Overview、Detailed Design 和 Formulas 已完整写入；其 `## Summary` 仅为 `[To be designed]`
- `## Edge Cases` 和 `## Acceptance Criteria` 仅包含 `[To be designed]`；`## Dependencies` 正文为空
- 该文件没有 Player Fantasy 或 Tuning Knobs 小节

**Input:** `/design-system retrofit design/gdd/inventory.md`

**Expected behavior:**
1. 技能读取现有 GDD，并识别哪些小节已存在、仅有占位符或为空
2. 它呈现 “Retrofit: Inventory” 块：已写入的小节（不会被改动）以及缺失或不完整的小节（将被编写）
3. Player Fantasy 和 Tuning Knobs 列为可添加项，而不是缺口，因为 `standard` 不要求它们
4. 它询问：“Shall I fill the 3 missing sections? I will not modify any existing content.”
5. 用户同意后，Phase 2 照常运行；§2e 指出缺失的模块——“no engine reference for `Scripting` under `docs/engine-reference/godot/modules/`; feasibility not checked against the pinned engine”——并将其带入 §5-pre
6. 不创建骨架；只有 Edge Cases、Dependencies 和 Acceptance Criteria 运行小节循环，然后 §5-pre 替换 Summary 占位符
7. 每次写入只替换占位符或空正文；Overview、Detailed Design 和 Formulas 不被修改

**Assertions:**
- [ ] 在进行任何更改之前展示 retrofit 块
- [ ] 该层级不要求的小节不会被报告为缺口
- [ ] 技能询问 “Shall I fill the 3 missing sections? I will not modify any existing content.”
- [ ] 缺失的 `scripting.md` 模块在输出中被点名，而不是像已检查过可行性那样静默跳过
- [ ] 不创建骨架，完整小节不被重新编写或覆盖
- [ ] 每个填充的小节在写入前仍需经过逐节批准

---

### Case 3: 总监闸门 — CD-GDD-ALIGN 返回 CONCERNS、REJECT 或 NOT ASSESSED

**Fixture:**
- `design/gdd/game-concept.md`（支柱包含 “Fearless Exploration”）和 `design/gdd/systems-index.md` 存在；`stamina` 被列出，`Category: Gameplay`
- `project.yaml` 中 `modes.review_mode: full`，`modes.workflow: full`
- 全部八个小节（包括 Player Fantasy）以及 Summary 都已为 `design/gdd/stamina.md` 写入
- Scenario (a)：CD-GDD-ALIGN 返回 CONCERNS：“Detailed Design's stamina drain undercuts the 'Fearless Exploration' pillar”
- Scenario (b)：CD-GDD-ALIGN 返回 REJECT：“stamina exhaustion strands the player mid-exploration, which the 'Fearless Exploration' pillar rules out”
- Scenario (c)：CD-GDD-ALIGN 返回 NOT ASSESSED——没有可用的 MDA 美学目标来对照检查 GDD

**Input:** `/design-system stamina`（运行到 Step 5a-bis）

**Expected behavior:**
1. `creative-director` 携带质量闸门（gate）CD-GDD-ALIGN 启动，并接收 GDD 路径、游戏支柱、MDA 美学目标和 GDD 的 Player Fantasy 小节
2. (a) CONCERNS 通过 `AskUserQuestion` 呈现，并附上标准选项：`Revise flagged items` / `Accept and proceed` / `Discuss further`
3. (a) 如果选择 “Revise flagged items”：Detailed Design 再次运行其小节循环——先咨询其专家——并通过 “Approve the Detailed Design section?” 批准后才写入；Status 头记录 `REVISED [date]`
4. (a) 如果选择 “Accept and proceed”：Status 头记录 `CONCERNS (accepted) [date]`
5. (b) 展示阻塞项；被标记的小节以相同方式重新起草并重新批准，然后才写入其他任何内容，Status 头记录 `REVISED [date]`，绝不记录 `APPROVED`
6. (c) 指出缺失的输入；用户可以补充并重新运行闸门，或由 Status 头记录 `NOT ASSESSED [date] — [missing input]`，绝不记录 `APPROVED`
7. 只有在结论记录之后，技能才继续进入实体注册表步骤（5b）

**Assertions:**
- [ ] CD-GDD-ALIGN 接收已完成的 GDD 路径、游戏支柱、MDA 目标和 Player Fantasy 小节
- [ ] (a) CONCERNS 连同三个标准选项一起展示给用户，不会自动接受
- [ ] 修订的小节会重新运行其小节循环，并在写入前重新获批
- [ ] Status 头记录 `REVISED [date]` 或 `CONCERNS (accepted) [date]`，与用户的选择一致
- [ ] (b) REJECT 之后，在被标记的小节修订完成之前，不运行任何后续步骤（5b 注册表、5d 系统索引）
- [ ] (c) NOT ASSESSED 绝不会被记录或报告为批准

---

### Case 4: Lean 与 Solo 模式 — 闸门只跳过一次；专家启动遵循各自检查

**Fixture:**
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在；系统为 `stamina`（`Category: Gameplay`）；没有 `design/gdd/stamina.md`
- `project.yaml` 中 `engine.name: Godot`，`modes.workflow: full`
- Section D 的耐力公式没有相互作用的可调参数；耐力条是玩家游玩时需要读取的反馈
- Scenario (a)：`modes.review_mode: lean`
- Scenario (b)：`modes.review_mode: solo`

**Input:** `/design-system stamina`

**Expected behavior:**
1. (a) Section B、C、E 和 G 在不启动专家的情况下起草，且各自打印带模式的说明，例如 “`creative-director` not consulted — Lean mode. Review manually before production.”
2. (a) Section D 仍启动 `systems-designer`，Section H 启动 `qa-lead`，Visual/Audio 启动 `art-director`——因为耐力反馈对游玩至关重要
3. (a) 在 Step 5a-bis：“CD-GDD-ALIGN skipped — Lean mode.”——只打印一次，而不是每个小节一次
4. (b) 不启动任何专家或总监代理；每个跳过启动的小节都带有其说明，例如 “`creative-director` not consulted — Solo mode. Review manually before production.”
5. (b) 在 Step 5a-bis：“CD-GDD-ALIGN skipped — Solo mode.”
6. 两种场景下，每个小节在写入前仍需要 “Approve the [Section Name] section?” 批准

**Assertions:**
- [ ] (a) lean 模式下 Section B、C、E 和 G 不启动其专家即可起草，而 Section D、H 和 Visual/Audio 仍会启动各自专家
- [ ] (a) 每个在 lean 下跳过的启动都会打印 “not consulted — Lean mode” 说明并指出其代理——没有一个被静默跳过
- [ ] (a) CD-GDD-ALIGN 跳过说明只在 Step 5a-bis 出现一次
- [ ] (b) solo 模式下不启动任何代理，每个被跳过的专家都会留下 “not consulted — Solo mode” 说明
- [ ] (b) 跳过说明为 “CD-GDD-ALIGN skipped — Solo mode.”
- [ ] 两种模式下都需要逐节的用户批准

---

### Case 5: 输入缺失与拒绝创建骨架

**Fixture:**
- 每个场景中 `project.yaml` 都有 `modes.workflow: standard`——该层级要求系统索引，因此指向 `/map-systems` 是正确的
- Scenario (a)：无参数；`design/gdd/systems-index.md` 将 `stamina` 列为优先级最高的 “Not Started” 系统（MVP，Core 层）
- Scenario (b)：无参数；没有系统索引
- Scenario (c)：`/design-system stamina`，概念和索引都存在；用户拒绝创建骨架

**Input:** (a) `/design-system` (b) `/design-system` (c) `/design-system stamina`

**Expected behavior:**
1. (a) `AskUserQuestion`：“The next system in your design order is **stamina** (MVP | Core). Start designing it?”，选项为 `[A] Yes — design stamina` / `[B] Pick a different system` / `[C] Stop here`
2. (b) 技能停止，并输出用法消息（“Usage: `/design-system <system-name>` …”）、retrofit 示例，以及 “No systems index found. Run `/map-systems` first to map your systems and get the design order.”
3. (c) 技能停止并提示：“Verdict: **BLOCKED** — skeleton creation declined. …”，不进入 Section A
4. 三种场景都不会在批准之前写入 GDD 文件

**Assertions:**
- [ ] (a) 根据系统索引提议下一个系统，并提供三个选项
- [ ] (b) 打印用法消息和 `/map-systems` 指引；不写入任何内容
- [ ] (c) 拒绝创建骨架会产生 BLOCKED 结论，并在 Section A 之前停止
- [ ] 未经批准不会创建 GDD 文件

---

### Case 6: Minimal 项目，一个系统被 `system_overrides` 提升

**Fixture:**
- `project.yaml` 中 `modes.workflow: minimal`，`modes.review_mode: solo`，`workflow_overrides.system_overrides.combat: standard`
- `design/game-brief.md` 存在；其 MVP 功能描述 combat（一条伤害规则和一个硬直阈值），其构建顺序将 combat 列在第一位
- 没有 `design/gdd/game-concept.md`，没有 `design/gdd/systems-index.md`，没有 `design/gdd/combat.md`

**Input:** `/design-system combat`

**Expected behavior:**
1. combat 的有效层级是 `standard`（来自覆盖）；项目层级为 `minimal`
2. §2a 走 `minimal` 分支，因为它以项目层级为准：它读取 `design/game-brief.md` 并跳过系统索引读取，不会以 “No game concept found” 或 “No systems index found” 停止
3. 它从简报中一次性推导 `Category`、`Layer` 和 `Priority`（例如 `Gameplay`、`Foundation` 或 `Feature`、`MVP`）
4. 骨架和小节走查遵循 `standard`：A、C、D（combat 定义了数值规则）、E、F、H——没有 Player Fantasy 或 Tuning Knobs
5. §5-pre 的 Quick reference 标记推导出的值，例如 “Category: Gameplay (inferred from the brief — no systems index at this tier)”
6. §5d 说明 “no `design/gdd/systems-index.md` at this workflow tier; nothing to update”，且不写入系统索引

**Assertions:**
- [ ] 运行读取简报，不会因缺少游戏概念或系统索引而停止
- [ ] 所需小节集合为 `standard`（有效层级）的集合——而不是项目层级的
- [ ] Category、Layer 和 Priority 从简报推导，并在 Quick reference 中标记为推断
- [ ] 不创建系统索引；§5d 报告没有可更新内容

---

### Case 7: 每个阶段之前读取阶段文件，压缩后再次读取

**Fixture:**
- `project.yaml` 中 `engine.name: Godot`，`modes.workflow: standard`，`modes.review_mode: solo`
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在；`stamina` 被列出，`Category: Gameplay`；没有 `design/gdd/stamina.md`
- 技能文件夹包含 `references/1-parse-arguments.md` 到 `references/5-post-design.md`
- 运行中，在 Section D（Formulas）起草期间对话被压缩；随后用户回复未决问题，运行继续

**Input:** `/design-system stamina`

**Expected behavior:**
1. SKILL.md 本身不承载阶段步骤；在开始每个阶段之前，运行会读取该阶段的文件：`references/1-parse-arguments.md`，然后 `2-gather-context.md`，然后 `3-file-skeleton.md`，然后 `4-section-design.md`，然后 `5-post-design.md`
2. 在读取某阶段文件之前，不执行该阶段的任何步骤——例如在 `1-parse-arguments.md` 之前不读取上下文或提问，在 `3-file-skeleton.md` 之前不询问骨架，在 `4-section-design.md` 之前不运行小节循环
3. 压缩之后，运行会在恢复 Section D 之前再次读取 `references/4-section-design.md`，正如技能所述：“Read it again if the conversation was compacted or resumed during this phase.”
4. 运行不会因为压缩而重新读取其他阶段的阶段文件，也不会凭先前读取的记忆继续 Section D
5. 随后运行会在 Summary 和自检之前读取 `references/5-post-design.md`

**Assertions:**
- [ ] 记录显示按顺序读取了五个 `references/N-*.md` 文件，每个都在该阶段工作开始之前读取
- [ ] 在该阶段文件被读取之前，不发生任何阶段工作（上下文读取、骨架询问、小节草稿、Summary）
- [ ] 压缩之后，在 Section D 恢复之前再次读取 `references/4-section-design.md`
- [ ] 在 SKILL.md 中解析的设置（`workflow`、`review_mode`、`automation`、`docs.density`）在阶段文件中仍然适用；运行不会再次询问它们

---

### Case 8: 已填充的注册表与带编号标题的依赖 GDD — 块形式 grep 能找到事实

**Fixture:**
- `project.yaml` 中 `engine.name: Godot`，`modes.workflow: standard`，`modes.review_mode: solo`
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在；`stamina` 被列出，`Category: Gameplay`，且 `Depends on: combat`
- `design/registry/entities.yaml` 有一个生效的 `constants:` 列表，包含两个条目：
  - `- name: stagger_threshold`，`value: 40`，`source: design/gdd/combat.md`（由 combat 拥有）
  - `- name: stamina_cost_dodge`，`value: 25`，`source: design/gdd/stamina.md`，以及块形式的 `referenced_by:` 列表（键在一行，`- design/gdd/combat.md` 在下一行）
- 同一文件的头部注释中有一个 `gold_carry_limit: 9999` 的示例条目，引用 `design/gdd/inventory.md`
- `design/gdd/combat.md` 存在，带有编号标题：`## 1. Overview`、`## 3. Detailed Design`、`## 4. Formulas`、`## 5. Edge Cases`、`## 6. Dependencies`、`## 7. Tuning Knobs`；其 Formulas 小节使用 `stagger_threshold`，Tuning Knobs 小节也列出它
- 没有 `design/gdd/stamina.md`

**Input:** `/design-system stamina`

**Expected behavior:**
1. 注册表查询使用两次 grep：一次查找 `source: design/gdd/stamina.md` 并带尾部上下文（`-A 6`），一次查找 `design/gdd/stamina.md` 并带前导上下文（`-B 8`）；`-B 8` 的匹配能到达 `referenced_by` 路径上方的所属条目，因此 `stamina_cost_dodge` 被找到为由 stamina 拥有，`stagger_threshold` 被找到为 stamina 必须遵守的事实
2. 不依赖单行的 `referenced_by.*stamina` 模式，因为该列表是块形式的
3. 对于依赖 GDD `combat.md`，运行会 grep `^## ([0-9]+\. )?(Dependencies|Formulas|Edge Cases|Tuning Knobs)`，使编号标题 `## 4. Formulas`、`## 5. Edge Cases`、`## 6. Dependencies` 和 `## 7. Tuning Knobs` 全部匹配；不读取整份 GDD
4. 上下文摘要的 “Known cross-system facts (from registry)” 列出 `stamina_cost_dodge=25` 和 `stagger_threshold=40` 及其所属 GDD，并标记为锁定
5. 被注释掉的 `gold_carry_limit: 9999` 示例不会被列为已知事实

**Assertions:**
- [ ] 注册表搜索同时使用 `source: design/gdd/stamina.md` 和带 `-B 8` 上下文的路径，而不仅是一行 `referenced_by` 模式
- [ ] `stamina_cost_dodge`（通过其 `source:` 和块形式 `referenced_by:` 找到）和 `stagger_threshold` 出现在 Known cross-system facts 下，并带有值和拥有者
- [ ] 依赖 GDD 的各小节尽管带有 `N.` 标题编号仍被找到——Dependencies、Formulas、Edge Cases 和 Tuning Knobs 四项全部读取
- [ ] `combat.md` 按小节读取，而不是整份读取
- [ ] 被注释的 `gold_carry_limit` 示例不作为锁定值呈现

---

## Protocol Compliance

- [ ] 在询问任何内容之前读取上下文；在 `standard`/`full` 项目中缺少游戏概念或系统索引时，以 `/brainstorm` 或 `/map-systems` 消息停止（`minimal` 项目改为读取简报，即使某个系统被 `system_overrides` 提升）
- [ ] 骨架只在 “May I create the skeleton file at `design/gdd/[system-name].md`?” 之后创建
- [ ] 在 collaborative 模式下，每个小节草稿之后都跟随其批准组件，未经批准不写入任何小节
- [ ] 小节增量写入，并在每次之后更新 `production/session-state/active.md`
- [ ] 专家启动遵循各小节的评审模式检查；每次跳过的启动都会留下 “not consulted” 说明，指出代理和模式，lean 与 solo 均如此
- [ ] CD-GDD-ALIGN 在所有小节之后于 full 模式下运行一次；lean 和 solo 打印指明闸门和模式的跳过说明
- [ ] `/design-review` 被引导到新会话，绝不内联运行或提供
- [ ] 在执行每个阶段之前读取其 `references/N-*.md` 文件，并在该阶段期间发生压缩或恢复后再次读取
- [ ] 以下一步 `AskUserQuestion` 和 Recommended Next Steps（`/consistency-check`、`/map-systems next`、新会话中的 `/design-review`）结尾

---

## Coverage Notes

- `guided` 和 `autonomous` 自动化模式（跳过逐节组件直接写入；
  autonomous 下的 `log_decision`）未做 fixture 测试。
- `minimal` 项目中未设覆盖的自愿 GDD（从 `design/game-brief.md` 取
  5 个标准小节，Formulas 不会被拉回）未做 fixture 测试；Case 6 覆盖的是
  某个系统被覆盖提升的 `minimal` 项目。`minimal` 项目中无参数提示
  （按设计不存在系统索引）也未测试。
- Section C 和 D 之后的注册表冲突检查，以及 Step 5b 的实体注册表更新，
  未单独测试。
- Step 5d 的系统索引更新以及上下文窗口（≥70%）提示未测试。
- 会话中断后的恢复与继续未测试。
