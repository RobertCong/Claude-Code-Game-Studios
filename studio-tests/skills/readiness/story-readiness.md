# Skill Test Spec: /story-readiness

## Skill Summary

`/story-readiness` 校验一个用户故事文件是否已准备好供开发者领取并实现。它一次性
加载参考上下文（系统索引、控制清单的 `Manifest Version:` 头部、TR 注册表，以及
通过一次 Grep 取得的每份 ADR 状态），然后按六个检查清单组评估每个用户故事：
Design Completeness、Architecture Completeness、Scope Clarity、Open Questions、
Asset References 和 Definition of Done。为该系统解析出的工作流层级决定哪些组会
阻塞（`full`：全部；`standard`：除关键 ADR 外架构条目为建议性；`minimal`：
架构为 N/A）—— 但每个层级都有一条规则：用户故事引用而缺失、处于 `Proposed`、
`Deprecated` 或 `Superseded` 的 ADR 会 BLOCK，因为 `/dev-story` 会因它停止。
在 `minimal` 下，`design/game-brief.md` 代替 GDD。它产生 READY / NEEDS WORK /
BLOCKED / NOT ASSESSED 结论。它是只读的 —— 绝不写入或编辑文件。在 `full` 评审
模式下它随后运行 QL-STORY-READY 闸门（`qa-lead`）。

既未设置 `qa.level` 也未设置 `modes.rigor` 的 fixture 会解析为
`qa.level: minimal`（`rigor: minimal` 默认值）。此时证据条目对 Logic、Integration
和 Config/Data 类用户故事自动通过 —— 对 UI 或 Visual/Feel 绝不自动通过，它们
在每个 `qa.level` 下都要求保留截图（Case 6）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个阶段标题或编号检查小节
- [ ] 包含结论关键词：READY、NEEDS WORK、BLOCKED、NOT ASSESSED
- [ ] 不要求 "May I write" 措辞 —— `allowed-tools` 没有 Write 或 Edit
- [ ] 有下一步交接（结论之后做什么）

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 完全就绪的用户故事

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full` 和 `modes.review_mode: solo`
- 用户故事文件位于 `production/epics/core/story-light-pickup.md`，包含：
  - 一处 `GDD: design/gdd/light-system.md` 引用，引述具体需求
  - `TR-light-001`，存在于 `docs/architecture/tr-registry.yaml` 且 `status: active`
  - `ADR: ADR-0003`；`docs/architecture/adr-0003-inventory.md` 的 `## Status` 为 Accepted
  - `Type: Logic`、一个含 3 条可测试条目的 `## Acceptance Criteria` 小节，以及一个点名测试路径的 `## Test Evidence` 小节
  - 一个估时、一个 Out of Scope 声明，以及 `Dependencies: None`
  - 引擎说明（或 "N/A — no engine API involved"）、相关的清单规则和一条性能说明
  - `Manifest Version:` 与 `docs/architecture/control-manifest.md` 中的一致
  - 没有 TBD / UNRESOLVED 标记，也没有资源路径
- `production/sprints/` 中的冲刺计划列出了其他用户故事

**输入：** `/story-readiness production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能报告 "Validating 1 story files."
2. 技能一次性加载上下文：从控制清单 grep `Manifest Version`，
   索引 `tr-registry.yaml`，并用一次
   `Grep pattern="^## Status" glob="docs/architecture/adr-*.md"` 扫描解析每份 ADR 状态
3. 技能评估全部六个检查清单组
4. 技能输出 READY，所有检查通过
5. Phase 8 注明 "QL-STORY-READY skipped — Solo mode."
6. 第 7 节展示冲刺中的其他就绪用户故事

**断言：**
- [ ] ADR 状态通过对 `docs/architecture/adr-*.md` 的一次性 `^## Status` Grep 解析，而不是完整读取每份 ADR，且 ADR-0003 被发现为 Accepted
- [ ] 技能在 `tr-registry.yaml` 中查找 `TR-light-001` 并发现其为 active
- [ ] 当前清单版本来自对清单头部的 Grep，而非完整读取
- [ ] "Passing Checks (N/[total])" 小节点名全部六个组 —— Design Completeness、Architecture Completeness、Scope Clarity、Open Questions、Asset References（"no asset references"）、Definition of Done —— 并列出各组下通过的条目
- [ ] 所有检查通过时结论为 READY
- [ ] 技能不写入任何文件
- [ ] 第 7 节最多列出 3 个其他就绪的冲刺用户故事 —— 或声明 "Next ready stories: no sprint file found" / "none ready in [sprint]"，而不是省略该小节

---

### Case 2: 阻塞路径 — 引用的 ADR 为 Proposed（非 Accepted）

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- 用户故事 `production/epics/core/story-light-system.md` 引用 `ADR-0005`
- `docs/architecture/adr-0005-light-system.md` 存在，`## Status` 为 Proposed
- 其他用户故事内容都完整

**输入：** `/story-readiness production/epics/core/story-light-system.md`

**预期行为：**
1. 状态扫描发现 ADR-0005 为 `Proposed`
2. 技能将其标记为 BLOCKED，并给出修复文本 "BLOCKED: ADR-0005 is Proposed — wait for acceptance before implementing."
3. 技能输出 BLOCKED，在 Blockers 下列出该 ADR

**断言：**
- [ ] 在 `full` 下 ADR 为 Proposed 时，结论为 BLOCKED（不是 NEEDS WORK 或 READY）
- [ ] 输出明确点名 ADR-0005 为阻塞项
- [ ] 输出说明要等待该 ADR 被接受后再实现
- [ ] 无论其他检查是否通过，技能都不输出 READY
- [ ] 变体 —— 同一用户故事在 `modes.workflow: standard` 下，ADR-0005 的 `## Engine Compatibility` 表中有 `| **Layer** | Feature |`（非关键）：用户故事引用了该 Proposed ADR，因此结论仍为 BLOCKED —— 被引用的 Proposed ADR 在每个层级都阻塞，因为 `/dev-story` 会因它停止
- [ ] 变体 —— 同一非关键 ADR 在 `standard` 下，现在为 `Accepted`，而用户故事的 `Manifest Version:` 早于控制清单的：过时版本作为建议性列在 Gaps 下，并附其 `Fix:` 行，结论为 READY —— 建议性缺口不会使其降级

---

### Case 3: Needs Work — 缺失验收标准（每个层级都检查）

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: minimal`
- 用户故事 `production/epics/core/story-oxygen-drain.md` 有 `Type: Logic` 但没有 `## Acceptance Criteria` 小节
- 该用户故事不引用 ADR、不引用 TR-ID，也不引用清单版本

**输入：** `/story-readiness production/epics/core/story-oxygen-drain.md`

**预期行为：**
1. 在 `minimal` 下，技能评估 Design Completeness 和 Scope Clarity，并将
   Architecture Completeness 视为 N/A
2. 技能未找到验收标准
3. 技能输出 NEEDS WORK，点名该缺口，并附一行 `Fix:` 建议具体的、可观察的标准

**断言：**
- [ ] Acceptance Criteria 小节缺失时，结论为 NEEDS WORK（不是 BLOCKED 或 READY）
- [ ] 输出具体识别出缺失的 Acceptance Criteria，并附一行 `Fix:` 提出可测量的标准
- [ ] 不标记任何 ADR、TR-ID 或清单缺口 —— Architecture Completeness 在 `minimal` 下为 N/A
- [ ] 该用户故事不是 BLOCKED：没有任何需要外部动作的事项（没有缺失/DRAFT 依赖，也没有无人负责的 UNRESOLVED 问题）
- [ ] 变体 —— 同一 `minimal` 用户故事，其验收标准追溯到 `design/game-brief.md` 的 MVP 功能（没有 `design/gdd/` 路径）："GDD requirement referenced" 通过 —— 在 `minimal` 下由简报代替 GDD
- [ ] 变体 —— 该用户故事还点名了 `ADR-0005`，其 `## Status` 为 `Proposed`：在 `minimal` 下结论也为 BLOCKED —— 被引用 ADR 规则是唯一不为 N/A 的 Architecture Completeness 条目

---

### Case 4: 边界情况 — 过时的清单版本

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- 用户故事头部有 `Manifest Version: 2026-01-15`
- `docs/architecture/control-manifest.md` 有 `Manifest Version: 2026-03-10`
- 用户故事中其他一切通过

**输入：** `/story-readiness production/epics/core/story-mirror-rotation.md`

**预期行为：**
1. 技能从用户故事中提取 `2026-01-15`
2. 技能 grep 清单头部并提取 `2026-03-10`
3. 用户故事的版本更旧 → "Manifest version is current" 条目失败
4. 结论为 NEEDS WORK，并给出修复：审阅变更的规则并更新用户故事的 `Manifest Version:`

**断言：**
- [ ] 技能通过在 `docs/architecture/control-manifest.md` 中 grep `Manifest Version` 获得当前版本
- [ ] 技能将用户故事内嵌的版本与当前版本比较
- [ ] 在 `full` 下，过时的清单版本导致 NEEDS WORK（不是 BLOCKED，也不是 READY）
- [ ] 输出说明可能有新的清单规则适用，且 `Fix:` 要求审阅变更的规则、必要时更新用户故事，然后将其 `Manifest Version:` 设为当前值

---

### Case 5: 总监闸门 — QL-STORY-READY 在各评审模式下的行为

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- 用户故事文件存在且通过每个检查清单条目
- 评审模式来自 `modes.review_mode`（遗留镜像 `production/review-mode.txt`）或 `--review`

**Case 5a — full 模式：** `/story-readiness production/epics/core/story-light-pickup.md --review full`

**预期行为：**
1. 技能先完成自己的检查清单和结论
2. 技能通过 `Agent` 启动 `qa-lead`，闸门为 QL-STORY-READY，传入用户故事
   文件路径、用户故事类型、验收标准（逐字）、GDD 需求（TR-ID 与文本）、依赖
   状态和 Phase 4 结论
3. ADEQUATE → 用户故事放行
4. GAPS → `AskUserQuestion`：`Update story with suggested gaps` / `Accept and proceed anyway` / `Discuss further`
5. INADEQUATE → 闸门说明用户故事必须修订后才能进入冲刺：检查清单的 READY 被
   降级为 NEEDS WORK，最终结论行连同缺口重述；询问用户是更新用户故事还是
   照旧推进，照旧推进被记录为覆盖，而不是 READY
6. NOT ASSESSED（缺少某个闸门输入）→ 点名缺失的输入，绝不将其读作 ADEQUATE：
   提供该输入并重跑闸门，或使 READY 变为 NOT ASSESSED

**断言（5a）：**
- [ ] 技能在决定是否启动 QL-STORY-READY 前使用已解析的评审模式
- [ ] QL-STORY-READY 仅在检查清单结论存在后才启动
- [ ] GAPS 结果产生三选项的 `AskUserQuestion`
- [ ] INADEQUATE 结果覆盖检查清单的 READY：最终结论为 NEEDS WORK，并连同闸门的具体缺口重述
- [ ] 若用户照旧推进，结论保持 NEEDS WORK，且输出声明该覆盖（"proceeding despite QL-STORY-READY: INADEQUATE (user override)"）—— 绝不是静默的 READY
- [ ] 闸门返回 NOT ASSESSED 时点名缺失的输入，且绝不让 READY 继续成立：除非提供该输入并重跑闸门，否则结论为 NOT ASSESSED

**Case 5b — lean 或 solo 模式：** `--review lean` 或 `--review solo`

**预期行为：**
1. QL-STORY-READY 被跳过
2. 输出注明 "QL-STORY-READY skipped — Lean mode." 或 "QL-STORY-READY skipped — Solo mode."
3. 结论仅基于检查清单

**断言（5b）：**
- [ ] QL-STORY-READY 在 lean 或 solo 模式下不启动
- [ ] 跳过在输出中被注明，并点名模式
- [ ] 结论仅基于检查清单

---

### Case 6: `qa.level: minimal` 下的 UI 用户故事 —— 截图计划绝不被豁免

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: standard` 和 `qa.level: minimal`（单独设置，
  因此只有测试证据轴处于 `minimal`，且每个检查清单组都被评估）
- 尚无 `docs/architecture/control-manifest.md`，也没有 `tr-registry.yaml`
- 用户故事 `production/epics/ui/story-003-shop-panel.md` 有 `Type: UI`、
  一处引述其所实现需求的 `GDD: design/gdd/shop.md` 引用、两条点名商店面板
  显示内容的可测试验收标准、"No ADR applies — pure layout"、引擎说明、估时、
  Out of Scope 声明、`Dependencies: None` 和一条性能说明 —— 但没有
  `## Test Evidence` 小节，也没有任何其他地方提及截图将放在哪里
- 没有 TBD / UNRESOLVED 标记，也没有资源路径

**输入：** `/story-readiness production/epics/ui/story-003-shop-panel.md`

**预期行为：**
1. 架构条目通过或自动通过（明确 "No ADR applies"；没有 TR-ID、清单版本或
   清单可检查）
2. "Test evidence requirement is clear" 条目仍然适用 —— UI 是
   `qa.level: minimal` 自动通过的例外
3. `testing.strict.ui` 未设置，因此该条目默认严格：缺失的小节使用户故事为
   NEEDS WORK
4. `Fix:` 要求一个 `## Test Evidence` 小节，点名为每个涉及屏幕保留的截图将放在
   `production/qa/evidence/` 下的何处

**断言：**
- [ ] 结论为 NEEDS WORK，而非 READY —— 在 `qa.level: minimal` 下，UI 用户故事的证据条目不会自动通过
- [ ] 缺口点名缺失的截图计划，且其 `Fix:` 指向 `production/qa/evidence/`
- [ ] 缺失的截图计划是唯一缺口 —— 不标记任何 ADR、TR-ID 或清单缺口
- [ ] 变体 —— 一个 `Type: Logic` 用户故事，三条可测试标准且没有 `## Test Evidence` 小节，相同配置：在 `qa.level: minimal` 下证据条目自动通过，因此仅缺失该小节不会使其成为 NEEDS WORK

---

### Case 7: NOT ASSESSED — 无可评估内容，或无人可读的 ADR

**Case 7a — 范围内零个用户故事：**
- `production/epics/` 只有 `EPIC.md` 索引文件，没有用户故事文件
- **输入：** `/story-readiness all`

**断言（7a）：**
- [ ] 输出为 `NOT ASSESSED — no stories in scope`，点名搜索路径 `production/epics/**/*.md`
- [ ] 它引导到 `/create-epics [layer]`，然后 `/create-stories [epic-slug]`
- [ ] 不在空列表上打印 `Ready: 0 / Needs Work: 0 / Blocked: 0` 小结

**Case 7b — 引用的 ADR 无可读状态：**
- `project.yaml` 设置 `modes.workflow: full`
- 用户故事 `production/epics/core/story-save-slots.md` 通过其他所有条目，并引用
  `ADR-0007`；`docs/architecture/adr-0007-save-format.md` 存在但没有
  `## Status` 小节
- **输入：** `/story-readiness production/epics/core/story-save-slots.md`

**断言（7b）：**
- [ ] ADR 检查为 NOT ASSESSED —— 状态未知，而非失败 —— 且结论为 NOT ASSESSED：不是 BLOCKED，也不是 READY
- [ ] 输出点名 `docs/architecture/adr-0007-save-format.md`，并引导到 `/architecture-decision retrofit docs/architecture/adr-0007-save-format.md`
- [ ] 变体 —— 用户故事点名 `ADR-0007` 但不存在该文件：这是关于用户故事的发现，因此结论为 BLOCKED（"referenced ADR is missing"），而非 NOT ASSESSED

---

### Case 8: Deprecated 或 Superseded 的 ADR 会阻塞，修复指向用户故事的 ADR 字段

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: standard`（被引用的失效 ADR 在每个层级
  都阻塞；`standard` 表明它并非留给建议性规则处理）
- 用户故事 A `production/epics/core/story-save-format.md` 引用 `ADR-0006`；
  `docs/architecture/adr-0006-save-format.md` 的 `## Status` 为 Superseded by ADR-0009
- 用户故事 B `production/epics/core/story-input-map.md` 引用 `ADR-0008`；
  `docs/architecture/adr-0008-input-map.md` 的 `## Status` 为 Deprecated
- 两个用户故事在其他方面都完整

**输入：** `/story-readiness production/epics/core/story-save-format.md`，然后
`/story-readiness production/epics/core/story-input-map.md`

**预期行为：**
1. 状态扫描读到 A 为 `Superseded by ADR-0009`，B 为 `Deprecated`
2. 两个结论都是 BLOCKED，在 Blockers 下列出该 ADR：该决策已不再成立
3. A 的 `Fix:` 写着 `BLOCKED: ADR-0006 is Superseded by ADR-0009 — point the story
   at ADR-0009 (edit its ADR field — /create-stories never rewrites an existing
   story).` B 的点名 `ADR-0008`，状态为 `Deprecated`
4. 不写入任何内容：技能只告诉用户去编辑用户故事的 ADR 字段

**断言：**
- [ ] 在 `standard` 下，两个结论都是 BLOCKED，而非 NEEDS WORK 或 READY
- [ ] A 的 `Fix:` 点名后继 ADR-0009，并说明要编辑用户故事的 ADR 字段
- [ ] `Fix:` 声明 `/create-stories` 绝不重写已存在的用户故事，且不建议重跑它以刷新此用户故事
- [ ] B 的阻塞项点名 ADR-0008 及其 `Deprecated` 状态
- [ ] 不写入或编辑任何文件

---

### Case 9: 已弃用或已被取代的 TR-ID 需要处理，无论是否带引号

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `docs/architecture/tr-registry.yaml` 有：`TR-light-001` 带 `status: active`，
  `TR-light-004` 带 `status: deprecated`，`TR-light-005` 带
  `status: "superseded-by: TR-light-009"`（带引号），以及 `TR-light-006` 带
  `status: superseded-by: TR-light-010`（不带引号）
- 用户故事 S1、S4、S5 和 S6 各自引用 `TR-light-001`、`TR-light-004`、
  `TR-light-005` 和 `TR-light-006` 之一；其他所有检查清单条目都通过（ADR
  Accepted、清单版本为当前、标准、估时）

**输入：** `/story-readiness production/epics/core/story-S4.md`，然后 S5、S6，再 S1

**预期行为：**
1. 注册表查找找到每个 id 并读取其状态
2. S4、S5 和 S6 为 NEEDS WORK，不是 BLOCKED 也不是 READY："the requirement was
   removed or replaced"
3. 每个 `Fix:` 都说明要更新用户故事以引用当前需求 ID，或如果该引用已不适用就
   将其删除
4. S1 通过 TR-ID 条目，为 READY

**断言：**
- [ ] `deprecated` 产生 NEEDS WORK，并附"更新或删除"的 `Fix:`
- [ ] 带引号的 `"superseded-by: TR-light-009"` 和不带引号的 `superseded-by: TR-light-010` 被同样处理：二者都是 NEEDS WORK
- [ ] 已弃用和已被取代的 TR-ID 都不会作为 "valid and active" 通过
- [ ] 结论为 NEEDS WORK，绝不是 BLOCKED —— 不需要用户故事之外的任何动作
- [ ] S1（`status: active`）通过该条目，因此已弃用和已被取代的结果来自注册表状态，而非查找本身

---

## Protocol Compliance

- [ ] 不使用 Write 或 Edit 工具；任何帮助填补缺口的草稿只在对话中拟定
- [ ] 单用户故事输出遵循 Section 5 模板：Verdict 行、"Passing Checks (N/[total])"、每个 Gaps 附一行 `Fix:`，以及 BLOCKED 时的 Blockers
- [ ] 不请求写入批准（不写文件）
- [ ] 以推荐的下一步结尾（修复缺口，或在 READY 后 `/dev-story [story-path]`）
- [ ] 保持结论层级分明 —— NOT ASSESSED（无法评估）绝不报告为 BLOCKED

---

## Coverage Notes

- 注册表中缺失的 TR-ID 遵循与 Case 4 相同的 NEEDS WORK 模式；已弃用或已被取代的
  TR-ID 见 Case 9。
- 零用户故事范围见 Case 7a；`sprint` / `all` 对真实用户故事的聚合输出，以及
  Must Have 冲刺升级警告，未在此测试。
- 无参数路径（通过 `AskUserQuestion` 选择范围）未测试。
- 引用多个 ADR 的用户故事未测试；行为假定为叠加式的（所有 ADR 都必须为
  Accepted 才能得到 READY 结论）。
