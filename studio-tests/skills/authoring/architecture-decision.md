# Skill Test Spec: /architecture-decision

## Skill Summary

`/architecture-decision` 负责编写一份架构决策记录（ADR）。它有三种入口模式：常规编写（`/architecture-decision [title]`）、`retrofit <path>`（在现有 ADR 中补充缺失的小节，不改动其余内容），以及 `accept <ADR-id>`（唯一能将 ADR 从 `Proposed` 变为 `Accepted` 的路径）。当 retrofit 询问缺失的 Status 而用户回答 `Accepted` 时，它会写入 `Proposed`，并把该 ADR 交给验收模式处理。

常规编写会先加载引擎上下文（`docs/engine-reference/[engine]/VERSION.md`，并对 MEDIUM/HIGH 风险领域给出知识缺口警告），选取下一个 ADR 编号，检查 `docs/registry/architecture.yaml` 中的约束立场，然后以确认/调整式的 `AskUserQuestion` 呈现其假设（Status 始终为 `Proposed`，从不询问）。随后它一次性按模板起草整份 ADR，交由主引擎专家验证（Step 5.5），仅在 `full` 评审模式下运行 TD-ADR 质量闸门（gate）（Step 5.6），运行一个始终会报告结果的 GDD 同步检查，并在写入 `docs/architecture/adr-[NNNN]-[slug].md` 之前只询问一次——“May I write it?”。更新注册表需要单独审批。收尾输出会提示用户在新会话中运行 `/architecture-review`，并在决策确定后运行 `/architecture-decision accept ADR-NNNN`。编写模式从不设置 `Accepted`，也从不解除用户故事的阻塞。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含状态/结论关键词：`Proposed`、`Accepted`，以及 TD-ADR 结果 `CONCERNS` / `REJECT`
- [ ] 包含 “May I write” 协作协议用语（整份 ADR 的写入审批与注册表审批）
- [ ] 结尾包含下一步交接（`/architecture-review`、`accept ADR-NNNN`）
- [ ] 记录质量闸门（gate）行为：先由引擎专家验证，再在 full 模式下运行 TD-ADR；lean/solo 模式下跳过 TD-ADR 并给出明确说明
- [ ] 记录编写模式始终产出 `Proposed`，只有验收模式才会设置 `Accepted`——retrofit 的 `Accepted` 回答会转由验收模式处理
- [ ] 提及来自 `docs/engine-reference/` 的引擎版本标记（Engine Compatibility 表）

---

## Director Gate Checks

评审模式取自解析后的 `review_mode`（`project.yaml` 中的 `modes.review_mode`）；`--review full|lean|solo` 可对单次运行进行覆盖。

在 `full` 模式下：草稿生成后，先由主引擎专家验证（Step 5.5），然后由 `technical-director` 携带质量闸门（gate）TD-ADR 启动（Step 5.6）。两者按此顺序运行，不并行。出现 CONCERNS 时，会原样展示关注项，用户可选择 `Revise flagged items` / `Accept and proceed` / `Discuss further`；出现 REJECT 时，草稿会在写入审批之前修订。任何结论都不会改变 ADR 的 Status。

在 `lean` 模式下：跳过 TD-ADR（它不是 PHASE-GATE）。输出会注明 “TD-ADR skipped — Lean mode.”。引擎专家验证仍会运行。

在 `solo` 模式下：跳过 TD-ADR。输出会注明 “TD-ADR skipped — Solo mode.”。引擎专家验证仍会运行。

无论哪种模式，写入的 ADR 均为 `Status: Proposed`。

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 新建渲染 ADR，full 模式，TD-ADR 通过

**Fixture:**
- `project.yaml` 中 `engine.name: Godot`，`modes.review_mode: full`
- `docs/engine-reference/godot/VERSION.md` 存在，并将锁定版本标记为 HIGH 风险；`breaking-changes.md` 列出的变更中包含一项 Rendering 变更
- `docs/architecture/` 包含 `adr-0001-*.md` 和 `adr-0002-*.md`；均未涉及渲染
- `docs/registry/architecture.yaml` 存在，且没有涉及渲染的立场
- `design/gdd/visual-effects.md` 存在；用户确认它是驱动该决策的 GDD，且其中名称与 ADR 的 Key Interfaces 一致
- 引擎专家只发现次要问题；TD-ADR 返回 APPROVE

**Input:** `/architecture-decision rendering-approach`

**Expected behavior:**
1. Step 1 首先读取 `VERSION.md`，并针对 Rendering 领域显示 ENGINE KNOWLEDGE GAP WARNING
2. Step 2 扫描 `docs/architecture/` 并分配 ADR-0003
3. Step 3a 在读取任何现有 ADR 之前先读取注册表
4. Step 4 以确认/调整式 `AskUserQuestion` 呈现假设（问题、2–3 个备选方案、GDD 关联、依赖、`Status: Proposed`）；在用户确认之前不生成任何 ADR
5. Step 5 起草完整模板，包括 Engine Compatibility 表（引擎、领域、知识风险、参考来源）
6. `godot-specialist` 验证草稿；次要问题写入 Risks 小节
7. 随后 `technical-director` 携带质量闸门（gate）TD-ADR 启动，并返回 APPROVE
8. GDD 同步检查打印 `GDD sync: checked 1 referenced GDD(s), no naming inconsistencies.`——绝不静默
9. “ADR draft is complete. May I write it?”——用户同意后，写入 `docs/architecture/adr-0003-rendering-approach.md`，其 `Status: Proposed`
10. 展示注册表候选条目，并单独询问 “May I update `docs/registry/architecture.yaml` with these [N] new stances?”
11. 收尾输出包含固定提示：在新会话中运行 `/architecture-review`，以及 “Run `/architecture-decision accept ADR-0003` when the decision is settled”

**Assertions:**
- [ ] `VERSION.md` 在任何其他步骤之前读取，且针对 HIGH 风险领域显示知识缺口警告
- [ ] 在生成 ADR 之前通过 `AskUserQuestion` 确认假设；Status 显示为 `Proposed`，从不询问
- [ ] 引擎专家验证在 TD-ADR 之前运行（顺序执行，非并行）
- [ ] 一次 “May I write” 审批覆盖整份 ADR；文件为 `docs/architecture/adr-0003-rendering-approach.md`
- [ ] 即使 TD-ADR 返回 APPROVE，写入的 ADR 仍为 `Status: Proposed`
- [ ] GDD 同步检查以一行报告 `visual-effects.md` 的干净结果
- [ ] 注册表更新有独立的审批提示，与 ADR 写入分开
- [ ] 收尾输出包含新会话中运行 `/architecture-review` 的提示以及 `accept ADR-0003` 命令

---

### Case 2: 失败路径 — TD-ADR 返回 CONCERNS

**Fixture:**
- 与 Case 1 相同，但 TD-ADR 返回 CONCERNS：“Alternatives do not address the mobile renderer”
- 修订后仍有一点未解决（移动端应针对哪个渲染器）

**Input:** `/architecture-decision rendering-approach`

**Expected behavior:**
1. TD-ADR 携带草稿、引擎版本、领域和相关 ADR 启动
2. CONCERNS 会原样展示给用户，并附上 `director-gates.md` 中的标准选项：`Revise flagged items` / `Accept and proceed` / `Discuss further`
3. 用户选择 `Revise flagged items`；只有在这之后才会修订 Decision 或 Alternatives 小节（Step 5.6）
4. 未解决的点会作为独立的 `AskUserQuestion` 呈现，选项来自评审内容外加 “Different approach — I'll describe it”
5. 仍会询问写入审批；在此之前不写入任何内容
6. ADR 以 `Status: Proposed` 写入

**Assertions:**
- [ ] TD-ADR 接收 ADR 草稿/路径、引擎版本和领域作为上下文
- [ ] CONCERNS 原样展示，由用户选择 Revise / Accept / Discuss——在该选择之前不修订草稿
- [ ] 每个未解决的决策都是一个独立的 `AskUserQuestion`，并提供自由文本兜底选项
- [ ] 只有在 “May I write” 审批之后才写入 ADR，且为 `Status: Proposed`

---

### Case 3: Lean 与 Solo 模式 — 跳过 TD-ADR；无法运行的检查会明确说明

**Fixture:**
- Scenario (a)：`project.yaml` 中 `modes.review_mode: lean`，`engine.name: Godot`
- Scenario (b)：同一项目，以 `--review solo` 调用
- Scenario (c)：在未配置引擎的项目上以 `--review solo` 调用——`engine.name` 未设置，`.claude/docs/technical-preferences.md` 仍为 `[TO BE CONFIGURED]`；在 Step 1 的提示处，用户不运行 `/setup-engine` 而继续
- `design/gdd/` 中没有 GDD，因此 ADR 的 GDD Requirements Addressed 不指定任何 GDD

**Input:** (a) `/architecture-decision save-format` (b) 和 (c) `/architecture-decision save-format --review solo`

**Expected behavior:**
1. (a) 和 (b)：运行引擎专家验证（Step 5.5）
2. (a) 输出注明 “TD-ADR skipped — Lean mode.”，并继续执行 GDD 同步检查
3. (b) 和 (c)：输出注明 “TD-ADR skipped — Solo mode.”，并继续执行 GDD 同步检查
4. (c) 不启动引擎专家，输出记录 `Engine validation: NOT ASSESSED — no engine configured (engine.name unset in project.yaml)`
5. GDD 同步检查打印 `GDD sync: NOT ASSESSED — [the ADR names no GDDs]`，而不是干净的一行结果
6. 在写入文件之前仍会询问 “May I write it?”
7. ADR 以 `Status: Proposed` 写入

**Assertions:**
- [ ] 在 lean 或 solo 模式下不启动 `technical-director`
- [ ] 跳过说明明确指出闸门和模式（“TD-ADR skipped — Lean mode.” / “— Solo mode.”）
- [ ] `--review solo` 参数会覆盖本次运行解析出的 `review_mode`
- [ ] (a) 和 (b)：引擎专家验证仍会运行
- [ ] (c) 未配置引擎时，输出会说明引擎验证为 NOT ASSESSED，而不是静默通过
- [ ] 未指定 GDD 时，GDD 同步检查报告 NOT ASSESSED，而非干净结果
- [ ] 在写入文件之前询问 “May I write”，且 Status 为 `Proposed`

---

### Case 4: 边界情况 — 拟议决策与已登记的立场冲突

**Fixture:**
- `docs/registry/architecture.yaml` 记录了一项接口契约（contract）：`damage_delivery → signal pattern (ADR-0003)`
- ADR-0003 为 Accepted
- 用户在调用技能时、Step 1 之前就陈述了提案：决定采用直接方法调用传递伤害

**Input:** `/architecture-decision damage-pipeline`，并在同一消息中附上该描述

**Expected behavior:**
1. Step 3a 在打开任何现有 ADR 之前读取注册表，并在 “Existing Architectural Stances (must not contradict)” 下将相关立场作为锁定约束（constraint）呈现
2. 仍在 Step 3a 中——就在立场之后、Step 4 的假设提示之前——技能会指出冲突：“⚠️ Conflict: This ADR proposes [X], but ADR-0003 established that [Y]…”
3. 它提供三个选项：(1) 与现有立场保持一致，(2) 以明确的替代方案取代 ADR-0003，(3) 说明为何本案例属于例外
4. 在冲突解决或被接受为有意的例外之前，不会进入 Step 4
5. 如果用户选择取代：在注册表步骤中，旧条目会被设置为 `status: "superseded_by: ADR-[NNNN]"`（带引号），并添加新条目——除此之外不修改现有条目

**Assertions:**
- [ ] 注册表在读取任何现有 ADR 文件之前读取
- [ ] 冲突警告明确指出 ADR-0003，并恰好提供上述三个选项
- [ ] 在冲突解决之前，不出现确认/调整假设提示（Step 4）
- [ ] 取代时，旧注册表条目被标记为 `superseded_by`，而不是被编辑或删除

---

### Case 5: 验收模式 — 状态只能通过 `accept` 变为 Accepted

**Fixture:**
- `docs/architecture/adr-0005-physics-layers.md` 存在，`Status: Proposed`
- Scenario (a)：其 `## ADR Dependencies` 列出 `Depends On: ADR-0002`，而 ADR-0002 为 `Proposed`
- Scenario (b)：其唯一依赖是 ADR-0001，且为 `Accepted`；`production/epics/*/story-*.md` 下的三个文件提及 `ADR-0005` 且为 Blocked——其中两个使用 `/create-stories` 写入的表头形式（`> **Status**: Blocked`），一个使用 `**Status:** Blocked`
- `modes.automation` 为 `autonomous`

**Input:** `/architecture-decision accept ADR-0005`

**Expected behavior:**
1. 技能用 glob 匹配 `docs/architecture/adr-0005-*.md` 并读取唯一匹配项
2. (a) 它拒绝执行并指出阻塞项：ADR-0005 依赖 ADR-0002，而后者仍为 Proposed；不编辑任何文件
3. (b) 它在询问前先找到待解除阻塞的用户故事，然后询问 “Accept ADR-0005 — [title]? …”，并附上数量（“3 stories become Ready”），选项为 `[A] Yes — accept it` / `[B] Not yet — leave it Proposed`
4. (b) 即使自动化为 `autonomous`，该提示仍会出现
5. (b) 用户同意后：将 `## Status` 编辑为 `Accepted`，保持现有 `## Date` 不变（仅在缺失时添加），把三个用户故事从 `Blocked` 移到 `Ready`，并报告该 ADR 及每个被移动的用户故事

**Assertions:**
- [ ] (a) 当某个依赖不是 `Accepted` 时拒绝验收，并指出 ADR-0002；不写入任何内容
- [ ] (b) 确认提示说明将有多少个用户故事变为 Ready
- [ ] (b) 在 `autonomous` 自动化模式下仍会出现确认提示
- [ ] (b) 只有在用户确认后，Status 才变为 `Accepted`，三个用户故事才移到 `Ready`
- [ ] 仅在 `production/epics/` 下匹配用户故事
- [ ] (b) 三个用户故事都能找到——Blocked 的 grep 能匹配 `> **Status**: Blocked` 和 `**Status:** Blocked`，而不只是字面量 `Status: Blocked`

---

### Case 5b: 验收模式 — 仅将 ADR 作为后继提及的用户故事被排除

**Fixture:**
- `docs/architecture/adr-0005-physics-layers.md` 存在，`Status: Proposed`，
  且 `## ADR Dependencies` 小节的唯一依赖 ADR-0001 为 `Accepted`
- `production/epics/` 下的三个用户故事为 `> **Status**: Blocked`：
  - `story-001.md`：因 ADR-0005 为 Proposed 而被阻塞
  - `story-002.md`：阻塞原因为 “BLOCKED: ADR-0003 is Superseded — point the
    story at ADR-0005 (edit its ADR field …) before implementing”；ADR-0005
    仅作为 ADR-0003 的后继者被提及
  - `story-003.md`：因无关原因被阻塞，未提及 ADR-0005
- 用户回答 `[A] Yes — accept it`

**Input:** `/architecture-decision accept ADR-0005`

**Expected behavior:**
1. 依赖检查通过
2. Blocked 用户故事的 grep 返回全部三个文件；只有 `story-001.md` 将
   ADR-0005 作为其被阻塞的原因。`story-002.md` 被排除，因为它仅将
   ADR-0005 作为要指向的后继者提及：它仍受 ADR-0003 约束，接受 ADR-0005
   并不会重新指向它
3. 确认提示显示 “1 story becomes Ready”，而不是 2 或 3
4. 用户同意后：`## Status` 变为 `Accepted`；只有 `story-001.md` 从
   `Blocked` 移到 `Ready`；报告列出该 ADR 和那一个用户故事

**Assertions:**
- [ ] 提示中的待解除阻塞故事数为 1
- [ ] `story-002.md` 保持 `Blocked`、未被编辑，且不在移动报告中
- [ ] `story-003.md` 保持 `Blocked`、未被编辑
- [ ] 只有在用户确认后 `story-001.md` 才变为 `Ready`

---

### Case 6: Retrofit — 缺失的 Status 回答为 `Accepted`

**Fixture:**
- `docs/architecture/adr-0004-input-mapping.md` 存在，包含 Context、Decision、Consequences、Engine Compatibility 和 GDD Requirements Addressed，但没有 `## Status` 和 `## ADR Dependencies`
- ADR-0001 为 `Accepted`
- `production/epics/*/story-*.md` 下的一个文件提及 `ADR-0004`，且包含 `> **Status**: Blocked`

**Input:** `/architecture-decision retrofit docs/architecture/adr-0004-input-mapping.md`

**Expected behavior:**
1. retrofit 块会列出缺失的小节：Status（BLOCKING）、ADR Dependencies（HIGH）和 Date（MEDIUM——fixture 中没有 `## Date`，也没有 `## Last Verified`），然后询问 “Shall I add the 3 missing sections? I will not modify any existing content.”
2. 询问当前状态时，用户回答 “Accepted”——该决策已生效；询问依赖时，用户回答 “Depends On: ADR-0001”
3. 技能追加 `## Status` 为 `Proposed`、ADR Dependencies 小节和 `## Date`（当天日期，注明为 retrofit 日期）；现有小节不变
4. 随后对 ADR-0004 运行验收模式：依赖检查通过（ADR-0001 为 Accepted），找到被阻塞的用户故事，并询问 “Accept ADR-0004 — [title]? …”，附带 “1 story becomes Ready”
5. 用户同意后：`## Status` 变为 `Accepted`，保留 retrofit 添加的 `## Date`，该用户故事从 `Blocked` 移到 `Ready`

**Assertions:**
- [ ] 只追加缺失的小节；现有小节不受影响
- [ ] retrofit 回答的 `Accepted` 绝不会直接写入 `## Status`；`Accepted` 只有在验收模式的依赖检查和确认之后才会出现
- [ ] 确认提示明确故事数量，与 Case 5 相同
- [ ] 变体——用户拒绝 “Shall I add the 3 missing sections?”：不写入任何小节，包括 `## Date`

---

## Protocol Compliance

- [ ] 首先加载引擎上下文（`VERSION.md`），并将其标记写入 Engine Compatibility 表
- [ ] 在生成 ADR 之前通过 `AskUserQuestion` 确认假设
- [ ] 写入前对整份 ADR 只询问一次 “May I write”；注册表更新有独立的审批
- [ ] TD-ADR 仅在 full 模式下运行；lean/solo 会打印跳过说明，指出闸门和模式
- [ ] TD-ADR 的 CONCERNS 原样展示，并附上 `Revise flagged items` / `Accept and proceed` / `Discuss further`，未经用户选择绝不修订
- [ ] TD-ADR 的 `NOT ASSESSED` 回答会指出缺失的输入，绝不作为批准呈现
- [ ] 编写模式始终写入 `Status: Proposed`；`Accepted` 只由验收模式在其依赖检查和用户明确确认之后设置——可直接通过 `accept`，或在 retrofit 传入 `Accepted` 回答时设置
- [ ] 引擎验证和 GDD 同步检查在无法运行时各自报告 `NOT ASSESSED`，绝不静默通过
- [ ] 编写模式不解除用户故事的阻塞；它会列出仍在等待该 ADR 的用户故事
- [ ] 以下一步交接结尾：在新会话中运行 `/architecture-review`，以及 `/architecture-decision accept ADR-NNNN`

---

## Coverage Notes

- retrofit 仅针对缺失 Status 回答 `Accepted` 的情况做了 fixture 测试
  （Case 6）；其他回答（`Proposed`、`Deprecated`、`Superseded`）以及对
  Engine Compatibility 和 GDD Requirements Addressed 的 retrofit 未测试。
- 验收模式对缺失 `## Status`、依赖小节缺失或为 `UNKNOWN`、以及 ADR
  已为 Accepted 或 Superseded 的拒绝情况，未逐一做 fixture 测试。
- 在 GDD 同步检查的三种结果中，单行干净结果（Case 1）和 `NOT ASSESSED`
  （Case 3）已测试；警告块及其三选项写入审批未测试。
- `team.size` 和 `docs.density` 的各种变化未测试。
- ADR 编号除 Case 1 外未单独做 fixture 测试。
