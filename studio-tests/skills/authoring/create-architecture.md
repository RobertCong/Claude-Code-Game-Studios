# Skill Test Spec: /create-architecture

## Skill Summary

`/create-architecture` 负责产出主架构文档 `docs/architecture/architecture.md`。Phase 0 加载上下文，并在缺少前置条件时提前停止：引擎参考资料（没有引擎 → `/setup-engine`）、`design/gdd/systems-index.md`（在 `standard`/`full` 下缺失 → `/map-systems`）、以及 `design/gdd/game-concept.md`（缺失 → `/brainstorm`；在 `minimal` 下由一页式 `design/game-brief.md` 替代）。它从每份 GDD 中承载需求的章节提取技术需求基线（Technical Requirements Baseline，`TR-[system]-[NNN]`），根据现有 ADR 的标题清点 ADR，并在编写前以 `AskUserQuestion` 展示引擎知识缺口清单（Engine Knowledge Gap Inventory）。

Phase 1–4（分层图、模块归属、数据流、API 边界）均逐项呈现并批准。Phase 5 审计现有 ADR，并将每条基线需求映射到 ADR 覆盖情况；未被覆盖的需求成为 Required New ADRs。Phase 7 以 `[A]/[B]/[C]` 选项询问 “All sections approved. May I write the master architecture document?”。Phase 7b 收集 TD-ARCHITECTURE 与 LP-FEASIBILITY 评审，将它们并排呈现，并在把签核记录到 Document Status 小节之前询问。Phase 8 更新 `production/session-state/active.md` 并打印固定的交接模板。

已有的 `docs/architecture/architecture.md` 绝不会未经询问就被替换：Phase 0e 提供就地更新选定小节（提升文档版本）、重写整份文档或停止的选项。聚焦领域参数（`layers`、`data-flow`、`api-boundaries`、`adr-audit`）就是选定某一小节的就地更新；若尚无文档，则改为提供完整走查。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含质量闸门（gate）原话中的签核结论关键词：`APPROVE`、`CONCERNS`、`FEASIBLE`，以及 `REVISED after …` 记录
- [ ] 包含写入前询问用语：通过 `AskUserQuestion` 请求写入审批（“May I write the master architecture document?”、“May I update the Document Status section…”）
- [ ] 结尾包含下一步交接（`/architecture-decision`、`/architecture-review`、`/create-control-manifest`）
- [ ] 记录 `docs/architecture/architecture.md` 一致的写入模型——文件何时首次创建，以及每个已批准小节何时写入
- [ ] 记录质量闸门（gate）行为：full 模式下运行 TD-ARCHITECTURE + LP-FEASIBILITY；lean/solo 下各自跳过并给出明确说明
- [ ] 记录缺少引擎、系统索引和游戏概念时的停止分支
- [ ] 记录 retrofit：检测到已有的 `docs/architecture/architecture.md`，在任何重写之前先提供更新选定小节

---

## Director Gate Checks

评审模式取自解析后的 `review_mode`（`project.yaml` 中的 `modes.review_mode`）；`--review full|lean|solo` 可对单次运行进行覆盖。

在 `full` 模式下：`docs/architecture/architecture.md` 写入后，由 TD-ARCHITECTURE（`technical-director`）和 LP-FEASIBILITY（`lead-programmer`）评审。两者都是被启动的代理，各自读取自己的闸门文件（`.claude/docs/director-gates/td-architecture.md`、`lp-feasibility.md`）；它们的输入相互独立，因此会一起启动，并在 Step 3 呈现之前收集双方结论。父会话从不读取这些文件：它把文档路径、技术需求基线（TR-ID 及数量）、带状态的 ADR 清单以及引擎知识缺口清单传给 TD-ARCHITECTURE。

在 `lean` 模式下：两者都不是 PHASE-GATE，因此都被跳过。输出注明 “TD-ARCHITECTURE and LP-FEASIBILITY skipped — Lean mode.”

在 `solo` 模式下：两者都被跳过，输出为 “TD-ARCHITECTURE and LP-FEASIBILITY skipped — Solo mode.”

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 新建架构文档，full 模式，评审通过

**Fixture:**
- `project.yaml` 中 `engine.name: Godot`，`modes.review_mode: full`，`modes.workflow: full`
- `docs/engine-reference/godot/` 包含 `VERSION.md`、`breaking-changes.md`、`deprecated-apis.md`、`current-best-practices.md` 和 `modules/`
- `design/gdd/game-concept.md` 和 `design/gdd/systems-index.md` 存在且包含实际内容
- `design/gdd/combat.md` 和 `design/gdd/inventory.md` 遵循 GDD 模板
- `docs/architecture/adr-0001-event-bus.md` 存在（`Status: Accepted`）
- 没有 `docs/architecture/architecture.md`
- TD-ARCHITECTURE 返回 APPROVE；LP-FEASIBILITY 返回 FEASIBLE

**Input:** `/create-architecture`

**Expected behavior:**
1. Phase 0a 读取四份引擎文档，并且只读取与系统索引中领域匹配的 `modules/` 文档
2. Phase 0b 对每份 GDD 中承载需求的章节（Detailed Rules/Design、Formulas、Dependencies、Tuning Knobs、Acceptance Criteria）执行 Grep，并呈现技术需求基线，其 ID 形如 `TR-combat-001 (provisional)`（尚无 TR 注册表）
3. Phase 0c 通过 `## Status`/`## Summary` 和 `**Domain**` 的 Grep 构建 ADR 清单，而不是完整读取
4. Phase 0d 展示引擎知识缺口清单，并询问 `[A] Proceed — flag HIGH RISK domains…` / `[B] Let me check the engine reference first…` / `[C] Show me which domains are HIGH RISK and why`
5. Phase 1–4：每个提案（分层图、归属图、每个数据流场景、API 边界）都在下一个之前呈现并批准，每次批准都记录到 `production/session-state/active.md`——在 Phase 7 之前不向架构文档写入任何内容
6. Phase 7：一段摘要，然后询问 “All sections approved. May I write the master architecture document?”，选项为 `[A] Yes — write…` / `[B] Show me the full draft inline first…` / `[C] Not yet…`
7. Phase 7b：TD-ARCHITECTURE（接收文档路径、TR 基线、带状态的 ADR 清单和知识缺口清单）与 LP-FEASIBILITY 评审已写入的文档；两份评估并排展示；用户选择 `Accept — proceed to handoff`
8. 展示拟议的 Document Status 块，然后询问 “May I update the Document Status section with the sign-off results?”
9. Phase 8 将摘要写入 `production/session-state/active.md`，并打印带以下标题的交接内容：“Architecture Complete”、“Run These ADRs Next”、“Gate-Check Readiness”；其 **Then:** 行指明 `/architecture-review`，评审通过后再指明 `/create-control-manifest`，就绪块指明 `/gate-check pre-production`

**Assertions:**
- [ ] 基线使用 `TR-[system]-[NNN]` 形式的 ID，并且基于扫描的 GDD 章节构建，而不是完整读取整个文件
- [ ] 知识缺口清单及其三选项 `AskUserQuestion` 出现在 Phase 1 之前
- [ ] 每个小节都在询问批准之前完整呈现
- [ ] 主文档只在 Phase 7 的 `AskUserQuestion` 批准之后写入
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 在文档写入之后各自以代理（`technical-director`、`lead-programmer`）身份启动，且两份结论都在 Step 3 之前收集
- [ ] TD-ARCHITECTURE 按名称接收其四项上下文；父会话不读取闸门文件
- [ ] Document Status 的签核只在 “May I update” 批准之后写入
- [ ] 交接使用固定模板标题，且不带尾随评论
- [ ] 交接指明 `/gate-check pre-production`——绝不使用 `[stage]` 占位符，因为本技能运行时它会解析为已经通过的闸门
- [ ] `docs/architecture/architecture.md` 在 Phase 7 询问之前不会被写入，哪怕是一部分；Phase 2–4 的批准写入会话状态

---

### Case 2: 评审关注项 — LP-FEASIBILITY 返回 CONCERNS

**Fixture:**
- 与 Case 1 相同，直到 Phase 7b
- LP-FEASIBILITY 返回 CONCERNS：“Save/load path has no owning module for serialisation”
- Scenario (a)：TD-ARCHITECTURE 返回 APPROVE
- Scenario (b)：TD-ARCHITECTURE 返回 NOT ASSESSED，并指出它无法读取的某个上下文项

**Input:** `/create-architecture`

**Expected behavior:**
1. Step 3 并排展示 Technical Director 评估与 Lead Programmer 结论，包括具体的关注项
2. `AskUserQuestion`：`Accept — proceed to handoff` / `Revise flagged items first` / `Discuss specific concerns`
3. 如果选择 Accept：拟议的 Document Status 为 `LP-FEASIBILITY: [date] — CONCERNS (accepted)`，并且只有在 “May I update the Document Status section…” 回答为是之后才应用
4. 如果选择 Revise：被标记的小节按 Phase 1–4 的方式重新起草并批准，修订后的文档通过 Phase 7 的询问一次性写入，随后状态为 `LP-FEASIBILITY: [date] — REVISED after CONCERNS`
5. 对于返回 CONCERNS 的评审，技能不会记录 `FEASIBLE`
6. (b) Step 4 拟议 `TD-ARCHITECTURE: [date] — NOT ASSESSED — [missing input]`，绝不记录 `APPROVE`，且交接的第一行写明 `NOT ASSESSED`

**Assertions:**
- [ ] 关注项文本与 TD 评估一起展示给用户
- [ ] 向用户提供 Accept / Revise flagged items first / Discuss specific concerns
- [ ] 选择接受时记录 `CONCERNS (accepted)`，而不是 `FEASIBLE`
- [ ] 修订时记录 `REVISED after CONCERNS`，且修订后的文档在其小节批准之后一次性写入
- [ ] 未经 “May I update” 批准，不写入任何 Document Status 变更
- [ ] (b) NOT ASSESSED 的评审会连同缺失的输入一起记录，绝不作为批准

---

### Case 3: Lean 与 Solo 模式 — 两项评审均跳过，仅凭用户批准写入

**Fixture:**
- 与 Case 1 相同的项目，但 Scenario (a)：`project.yaml` 中 `modes.review_mode: lean`
- Scenario (b)：同一项目，以 `--review solo` 调用

**Input:** (a) `/create-architecture` (b) `/create-architecture --review solo`

**Expected behavior:**
1. Phase 0–7 按 Case 1 运行；文档在 Phase 7 批准之后写入
2. 在 Phase 7b 两项评审都不运行；输出注明 (a) “TD-ARCHITECTURE and LP-FEASIBILITY skipped — Lean mode.” (b) “TD-ARCHITECTURE and LP-FEASIBILITY skipped — Solo mode.”
3. Step 4 展示 Document Status 块，两行均为 `skipped — [mode] mode`，
   并在应用之前询问；随后技能继续进入 Phase 8 交接，不会因评审被跳过而
   阻塞

**Assertions:**
- [ ] 不启动 `technical-director` 或 `lead-programmer`，且在 lean 或 solo 模式下不应用任何 TD-ARCHITECTURE 评审
- [ ] 跳过说明指出两个闸门和模式
- [ ] (b) `--review solo` 参数会覆盖本次运行解析出的 `review_mode`
- [ ] 文档仅凭用户批准写入，完成不会被阻塞
- [ ] Document Status 记录两项评审在该模式下均被跳过（在其询问之后），从而使文档说明为何没有签核
- [ ] 仍会打印 Phase 8 交接

---

### Case 3b: 评审拒绝 — 不提供 Accept 选项

**Fixture:**
- 与 Case 1 相同的项目，`full` 模式；`technical-director` 返回
  `TD-ARCHITECTURE: REJECT`（某个 Core 系统依赖 Presentation 层模块）；
  `lead-programmer` 返回 `LP-FEASIBILITY: FEASIBLE`

**Input:** `/create-architecture`

**Expected behavior:**
1. 两项评审在 Phase 7b 并行启动
2. Step 3 并排展示 `TD-ARCHITECTURE: REJECT` 和 `LP-FEASIBILITY: FEASIBLE`
3. `AskUserQuestion` 提供 `Revise flagged items first` 和 `Discuss specific concerns`——**不**提供 `Accept`
4. 选择 `Revise flagged items first` 后，被标记的小节按 Phase 1–4 的方式重新起草并批准，修订后的文档通过 Phase 7 的询问一次性写入
5. 不记录任何内容为已批准；Step 4 记录 `REVISED after REJECT`，交接的第一行也使用相同值

**Assertions:**
- [ ] 在等待任一结果之前就发出 `technical-director` 和 `lead-programmer` 调用
- [ ] 在 REJECT 仍然存在时，`Accept — proceed to handoff` 不是可选项
- [ ] 修订后的文档在重新起草的小节批准之后一次性写入——而不是逐节写入
- [ ] 本次运行的 Document Status 绝不将 TD-ARCHITECTURE 显示为 APPROVE；交接行写明 `REVISED after REJECT`

---

### Case 4: 边界情况 — 系统索引缺失或为空

**Fixture:**
- 引擎已配置；`design/gdd/game-concept.md` 存在
- Scenario (a)：`modes.workflow: standard`，没有 `design/gdd/systems-index.md`
- Scenario (b)：`modes.workflow: standard`，`design/gdd/systems-index.md` 存在但只包含模板占位符
- Scenario (c)：`modes.workflow: minimal`，没有系统索引，没有游戏概念，`design/game-brief.md` 存在

**Input:** `/create-architecture`

**Expected behavior:**
1. 技能在读取任一设计文件之前先检查两者是否存在
2. (a) 停止并提示：“No systems index found. Run `/map-systems` first…”——不构建基线，不写入文件
3. (b) 将只有占位符的索引视为缺失，并以相同方式停止
4. (c) 说明在 `minimal` 下不要求系统索引，读取 `design/game-brief.md` 替代游戏概念，并继续

**Assertions:**
- [ ] (a) 技能以 `/map-systems` 提示停止，不写入任何内容
- [ ] (b) 存在但仅有占位符的系统索引被视为缺失
- [ ] (c) 在 `minimal` 下技能说明不要求索引，并从游戏简报继续
- [ ] 在 `standard` 下（a、b），缺少设计文件时运行不会越过 Phase 0b；在 `minimal` 下（c），简报可替代两者，仅当简报也缺失时才停止

---

### Case 5: ADR 审计 — Proposed ADR 与未覆盖需求

**Fixture:**
- 与 Case 1 相同，另有 `docs/architecture/adr-0002-save-format.md`，其 `Status: Proposed`
- 另有 `design/gdd/crafting.md`，它早于 GDD 模板编写，不含任何被扫描的小节标题
- 基线需求 `TR-combat-002`（连招状态机）未被任何 ADR 的 GDD Requirements Addressed 小节或决策文本覆盖

**Input:** `/create-architecture`

**Expected behavior:**
1. Phase 0b 的章节 Grep 在 `crafting.md` 中没有匹配，因此技能完整读取它、说明这一点，其需求以 `TR-crafting-NNN` 进入基线——零匹配的 GDD 绝不会被视为没有需求
2. Phase 0c 列出 ADR-0001（Accepted）和 ADR-0002（Proposed）及其领域
3. Phase 5 展示 ADR 质量表和可追溯性表，将 `TR-combat-002` 标记为 `❌ GAP`，并给出已覆盖/缺口数量
4. 该缺口列在 Required New ADRs 下，按层分组，Foundation 在前，形式为 `/architecture-decision [title] → covers: TR-combat-002`
5. Phase 8 的 “Gate-Check Readiness” 将 ADR-0002 列在 “Accept ADRs” 下，将尚未编写的 ADR 列在 “Write ADRs” 下
6. “Run These ADRs Next” 最多列出 Phase 6 中的三个 ADR，按优先级排序

**Assertions:**
- [ ] `crafting.md` 未匹配任何被扫描章节，因此被完整读取并报告，且为基线贡献 TR-ID
- [ ] ADR 状态来自标题扫描，ADR-0002 被报告为 Proposed
- [ ] `TR-combat-002` 被标记为 GAP，并成为 Required New ADR，指明它所覆盖的 TR-ID
- [ ] Required New ADRs 按层分组，Foundation 在前
- [ ] “Gate-Check Readiness” 将 ADR-0002 列在 “Accept ADRs” 下
- [ ] “Run These ADRs Next” 列出的条目不超过三个

---

### Case 6: 已有架构文档 — 就地更新，绝不未经询问覆盖

**Fixture:**
- 与 Case 1 相同的项目，但 `project.yaml` 中 `modes.review_mode: lean`
- Scenario (a)：`docs/architecture/architecture.md` 存在，`Version: 2`，所有小节均已写入；用户选择 `[A] Update chosen sections in place` 并选择 Data Flow
- Scenario (b)：没有 `docs/architecture/architecture.md`；输入为 `/create-architecture layers`

**Input:** (a) `/create-architecture` (b) `/create-architecture layers`

**Expected behavior:**
1. (a) Phase 0e 找到文档，读取其 Document Status 和标题，并询问 “An architecture document already exists (v2, [last updated]). What should this run do?”，选项为 `[A] Update chosen sections in place` / `[B] Rewrite the whole document — replaces the existing file` / `[C] Stop`
2. (a) 只编写 Phase 3（Data Flow）；输出说明跳过了哪些阶段
3. (a) Phase 7 的询问指明 Data Flow 小节以及从 v2 到 v3 的变更；用户同意后，仅用 `Edit` 替换 `## Data Flow`，并将 `Version` 变为 3
4. (a) 文档的其他所有小节保持不变，交接指明 v3
5. (b) 技能说明没有架构文档可供 `layers` 聚焦领域更新，并改为提供完整走查；在用户回答之前不写入任何内容

**Assertions:**
- [ ] (a) 在任何编写之前检测到现有文档，且替换它只可能是用户明确选择 `[B]`
- [ ] (a) 只重新编写并写入所选小节；其他小节保持原样
- [ ] (a) 版本号被提升，而不是重置为 v1.0
- [ ] (b) 无文档时的聚焦领域运行不写入任何内容，并提供完整走查

---

### Case 7: 带 TR 注册表重新运行 — 已登记 ID 复用，新 ID 为临时

**Fixture:**
- 与 Case 1 相同的项目，但 `/architecture-review` 已运行：`docs/architecture/tr-registry.yaml` 包含 `TR-combat-001`（`requirement: "Hitbox detection per-frame"`，`status: active`）和 `TR-combat-002`（`requirement: "Old combo timing"`，`status: deprecated`）
- `design/gdd/combat.md` 仍描述逐帧命中框检测，并新增连招状态机；`design/gdd/inventory.md` 没有注册表条目

**Input:** `/create-architecture`

**Expected behavior:**
1. Phase 0b 在为基线编号之前读取 `docs/architecture/tr-registry.yaml`
2. 命中框检测保留 `TR-combat-001`
3. 连招状态机从 `registry.sh next-id tr combat`（`TR-combat-003`）编号，而不是 `TR-combat-002`，并标记为 `(provisional)`
4. 库存相关需求从 `TR-inventory-001 (provisional)` 开始
5. 基线的标题行给出已登记和临时的数量，并说明已读取注册表

**Assertions:**
- [ ] 已登记的 ID 不会分配给不同需求，已弃用的 `TR-combat-002` 也不会被复用
- [ ] 不在注册表中的每个 ID 都标记为 `(provisional)`
- [ ] 没有注册表时（Case 1），标题说明注册表缺失，且每个 ID 都是临时的

---

## Protocol Compliance

- [ ] 缺少引擎时在编写前停止；在 `standard`/`full` 项目中缺少系统索引或游戏概念时也停止；在 `minimal` 下从 `design/game-brief.md` 继续，仅当它也缺失时才停止
- [ ] 每个小节都在询问批准之前完整呈现
- [ ] 写入审批使用带标签选项的 `AskUserQuestion`，而不是纯文本询问
- [ ] 对 `docs/architecture/architecture.md` 遵循一致的写入模型，且未经用户选择绝不替换已有文档
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 仅在 full 模式下运行；lean/solo 打印跳过说明，指出每个闸门和模式
- [ ] Document Status 的签核只在 “May I update” 批准之后记录
- [ ] 以固定交接模板和下一步（`/architecture-decision`、`/architecture-review`、`/create-control-manifest`）结尾

---

## Coverage Notes

- 在聚焦领域参数中，只有无现有文档的 `layers` 做了 fixture 测试
  （Case 6 b）。针对现有文档的聚焦领域运行遵循 Case 6 (a) 的更新路径，
  但未单独测试。
- “未配置引擎” 的停止分支仅做了结构性断言。
- `workflow: standard`（仅系统分层图和关键 ADR 清单）在 Phase 0b 之后
  未做 fixture 测试；Case 4 只覆盖其停止分支。
- `docs.density` 的深度变化以及 `guided` / `autonomous` 自动化模式
  未测试。
