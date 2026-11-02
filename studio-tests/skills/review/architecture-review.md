# Skill Test Spec: /architecture-review

## Skill Summary

`/architecture-review` 是一个 Opus 层级技能，用于检查整套架构决策是否覆盖了
游戏的设计。它从每份 GDD 中提取技术需求（TR-ID），在可追溯性矩阵中把每一条
映射到覆盖它的 ADR，检测跨 ADR 冲突，按依赖排序 ADR（通过
`.claude/scripts/adr-dep-graph.sh`），对照 `docs/engine-reference/` 审计引擎
兼容性，咨询主引擎专家，并检查 `docs/architecture/architecture.md` 对系统索引
的覆盖。它产生 PASS / CONCERNS / NOT ASSESSED / FAIL 结论。

它接受一个聚焦参数（默认为 `full`，或 `coverage`、`consistency`、`engine`、
`single-gdd [path]`、`rtm`）。在报告之后，它通过 `AskUserQuestion` 询问是否
写入评审报告（`docs/architecture/architecture-review-[date].md`）、可追溯性
索引和 `docs/architecture/tr-registry.yaml`。它是 Technical Setup 与
Pre-Production 之间的质量闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个阶段标题
- [ ] 包含结论关键词：PASS、CONCERNS、NOT ASSESSED、FAIL
- [ ] `allowed-tools` 包含 Write，因此存在写入批准措辞（"May I update the systems index?"、"May I update `docs/architecture/tr-registry.yaml`…"）
- [ ] 结尾有下一步交接（Phase 9）
- [ ] 记录了参数模式：`full`、`coverage`、`consistency`、`engine`、`single-gdd [path]`、`rtm`

---

## Director Gate Checks

无。此技能不解析 `review_mode`（其配置块只请求 `automation` 和 `workflow`），
也不启动任何总监闸门。它唯一启动的代理是 Phase 5 的主引擎专家。架构签署闸门
（TD-ARCHITECTURE、LP-FEASIBILITY）属于 `/create-architecture`，不属于本技能。

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 每条需求都由一份 Accepted ADR 覆盖

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`、`engine.name: Godot`、`engine.version: 4.6`
- `design/gdd/systems-index.md` 加两份系统 GDD（`combat.md`、`inventory.md`），
  各自有 `## Summary` 和 Detailed Rules 中的技术需求
- `docs/architecture/adr-0001-*.md` … `adr-0003-*.md`，各自有 `## Status: Accepted`、
  `## GDD Requirements Addressed`、`## Engine Compatibility` 和 `## ADR Dependencies`，
  其 `**Depends On**` 行已填写 —— `adr-0001` 为 `None`，`adr-0002` 和
  `adr-0003` 为 `ADR-0001` —— 因此 `adr-dep-graph.sh` 找到真实边，且
  `NO_DEPS_SECTION` 下不列出任何 ADR；它们合起来覆盖每条需求；没有两条相互矛盾
- `docs/architecture/architecture.md` 存在并点名索引中的每个系统
- 没有此前的 `docs/architecture/architecture-review-*.md` 报告
- 闸门前置条目都存在：`tests/unit/`、`tests/integration/`（Godot 测试根目录）、
  `.github/workflows/tests.yml`、`design/accessibility-requirements.md`、
  `design/ux/interaction-patterns.md`

**输入：** `/architecture-review`

**预期行为：**
1. 新鲜度检查打印 `RECEIPT: NONE` → 完整评审
2. 技能统计分母（N_gdd、N_adr），用定向 Grep（而非整个文件）加载所需小节，并报告
   "Loaded [N] GDDs, [M] ADRs, engine: Godot 4.6"
3. 技能提取 TR-ID（复用已有的 `tr-registry.yaml` ID）并构建矩阵
4. 技能运行 `bash .claude/scripts/adr-dep-graph.sh`，并从其 `ORDER:` 行打印推荐的实现顺序
5. 技能运行引擎审计并咨询 `godot-specialist`
6. 报告以 `### Verdict: PASS` 结尾
7. Phase 8 询问要写入什么；Phase 9 提供 `/gate-check pre-production`

**断言：**
- [ ] 输出报告 "Loaded [N] GDDs, [M] ADRs, engine: [name + version]"
- [ ] 可追溯性矩阵列出每个 TR-ID 及其 GDD、系统、需求、ADR 覆盖和状态；每一行都是 ✅
- [ ] ADR 依赖顺序取自 `adr-dep-graph.sh` 的 `ORDER:` 行，而非手工追溯，且把 `adr-0001` 放在最前；`NO_DEPS_SECTION` 和 `UNFILLED_DEPS` 为空，因此无环结果是干净图，而非结构性缺口
- [ ] 结论为 PASS 仅因为所有需求都由 **Accepted** ADR 覆盖、不存在冲突、且引擎参考一致
- [ ] 报告头部有 `Mode: full` 和 `Workflow: full` 行
- [ ] 报告包含每项评审输入的 `review-receipts.sh hash` 行（ADR、GDD、TR 注册表、引擎参考、`project.yaml`、技能自身文件），并在 TR 注册表写入后取得
- [ ] 在 Phase 8 的 `AskUserQuestion` 之前不写入任何文件（`[A]` 全部三个文件 / `[B]` 只写报告到 `docs/architecture/architecture-review-[date].md` / `[C]` 暂不写入）
- [ ] 收尾部件提供 `/gate-check pre-production`，因为每个闸门前检查清单条目都是 ✅

---

### Case 2: 失败路径 — Foundation 缺口加上跨 ADR 归属冲突

**测试夹具：**
- 同 Case 1，但：
  - `save-system.md`（Foundation 层系统）要求 "Player progress
    persists between sessions"，而没有 ADR 涉及它
  - `adr-0002` 和 `adr-0004` 都是 Accepted，且都声称对玩家生命值拥有权限

**输入：** `/architecture-review`

**预期行为：**
1. 持久化需求显示为 `❌ GAP` 行
2. 该缺口出现在 "Coverage Gaps" 下，附建议的 `/architecture-decision [title]`、
   Domain 和 Engine Risk
3. 打印一个冲突块 `## Conflict: [ADR-0002] vs [ADR-0004]`
4. 结论为 FAIL；Blocking Issues 至少列出 Foundation 缺口
5. 两份 ADR 都不被编辑；由用户决定如何解决

**断言：**
- [ ] 结论为 FAIL（Foundation 层需求未被覆盖）
- [ ] 缺口行点名 TR-ID、GDD 和需求，并给出建议的 `/architecture-decision` 命令
- [ ] 冲突块点名两个 ADR 编号、一个 Type（State / Data ownership）、每份 ADR 的主张、Impact，以及至少两个解决方案
- [ ] 技能不自动解决冲突，也不编辑任何一份 ADR
- [ ] 若 `docs/consistency-failures.md` 存在，Phase 8 的 `[A]` 选项点名它（"…and append 1 conflict entry to `docs/consistency-failures.md`"），且只在用户选择 `[A]` 时追加该条目；`[B]`（只写报告）只写报告，不写其他；若文件不存在，则不创建它
- [ ] 收尾部件不提供 `/gate-check`；它提供通过 `/architecture-decision [system]` 编写缺失的 ADR

---

### Case 3: 部分路径 — 覆盖依赖一份 Proposed ADR

**测试夹具：**
- 同 Case 1，但 `adr-0003`（唯一覆盖 `TR-inventory-001` 的 ADR）为 `## Status: Proposed`
- `adr-0004`（Accepted）在其 `## ADR Dependencies` 表中写着 `**Depends On**: ADR-0003`

**输入：** `/architecture-review`

**预期行为：**
1. `TR-inventory-001` 被标记为 `🟡 Covered (Proposed)`，而非 ✅
2. 依赖分析标记 "ADR-0004 depends on ADR-0003 — but ADR-0003 is still Proposed"
3. 结论被限制在 CONCERNS，并点名出路：`/architecture-decision accept ADR-0003`

**断言：**
- [ ] 技能在标记覆盖前读取每份 ADR 的 `## Status`；Proposed 的 ADR 绝不产生 ✅
- [ ] 当覆盖依赖一份 Proposed ADR 时，结论为 CONCERNS（而非 PASS）
- [ ] 输出点名 `/architecture-decision accept ADR-0003` 作为清除它的途径
- [ ] 对 Proposed ADR 的未解决依赖被标记出来

---

### Case 4: 边界情况 — 缺失架构文档；格式错误的 ADR

**Case 4a — 没有主架构文档：**
- 同 Case 1，但 `docs/architecture/architecture.md` 不存在

**断言（4a）：**
- [ ] 报告以具名条目声明 `Architecture document coverage: NOT ASSESSED — no docs/architecture/architecture.md`，而不是不展示任何 Phase 6 发现
- [ ] 总体结论为 NOT ASSESSED，而非 PASS：Phase 6 属于 `full` 范围且没有运行，即使每条需求都被覆盖（别处的 CONCERNS 或 FAIL 发现仍会优先）

**Case 4b — ADR 存在但都没有可扫描的小节：**
- 同 Case 1（`modes.workflow: full` —— 在默认 `minimal` 层级、即没有 `modes`
  块的 `project.yaml` 下，该技能不适用），但三个 `docs/architecture/adr-*.md`
  文件都不含 Phase 1b 扫描所寻找的六个标题：`## Status`、
  `## Decision`、`## GDD Requirements Addressed`、`## Engine Compatibility`、
  `## ADR Dependencies`、`## Performance Implications`

**断言（4b）：**
- [ ] 技能报告 "[N] ADRs found, none carries a scannable section — run `/architecture-decision retrofit [file]` on each"（子命令在前 —— 若路径在前，`/architecture-decision` 会开始撰写一份新 ADR）
- [ ] 技能不报告零覆盖或设计失败 —— 这是格式失败
- [ ] ADR 没有 `## Status` 的行标记为 `❓ Not assessed`，且结论不是 PASS —— 也不因覆盖问题而判 FAIL，因为覆盖是未知而非缺失

---

### Case 5: 引擎专家咨询 —— 已配置与未配置引擎

**Case 5a — 已配置引擎：** Case 1 夹具（`engine.name: Godot`）

**预期行为：**
1. 在 Phase 5 引擎审计之后，技能通过 `Agent` 启动 `godot-specialist`，
   传入引擎相关 ADR、引擎参考文档和审计发现
2. 专家的发现出现在 `### Engine Specialist Findings` 下，并计入结论

**断言（5a）：**
- [ ] 专家由 `engine.name` 解析（Godot → `godot-specialist`）
- [ ] 它在引擎审计之后启动，且提示中包含审计发现
- [ ] 输出包含 `### Engine Specialist Findings` 小节
- [ ] 不启动或提及任何总监闸门（TD-ARCHITECTURE、LP-FEASIBILITY 或任何其他闸门 ID）

**Case 5b — 未配置引擎：** 同 Case 1，但 `engine.name` 在 `project.yaml` 中未设置，`technical-preferences.md` 仍为 `[TO BE CONFIGURED]`

**断言（5b）：**
- [ ] 不启动引擎专家
- [ ] 输出记录 `Engine validation: NOT ASSESSED — no engine configured`，而不是省略该步骤
- [ ] 结论为 NOT ASSESSED，而非 PASS —— 引擎审计属于 `full` 范围，且没有可对照的固定引擎，即使每条需求都被覆盖

---

## Protocol Compliance

- [ ] 在任何写入批准前展示完整的可追溯性矩阵（Phase 1a 的新鲜度问题和 Phase 2 的含糊需求问题可能更早出现）
- [ ] 每次写入批准都使用带标签选项的 `AskUserQuestion`，而不是纯文本的 "May I?"
- [ ] 在请求写入前展示要写入的内容（报告、systems-index 行）
- [ ] 绝不重新编号或删除已有的 `tr-registry.yaml` 条目；将某条标记为弃用需与用户确认
- [ ] 结论恰为以下之一：PASS、CONCERNS、NOT ASSESSED、FAIL
- [ ] 以 `AskUserQuestion` 的 Phase 9 交接结尾；任何闸门前条目为 ❌ 时不提供 `/gate-check`

---

## Coverage Notes

- `coverage`、`consistency`、`engine`、`single-gdd` 和 `rtm` 模式未单独做
  fixture 测试；Case 1–5 演练默认的 `full` 模式。
- Phase 5b（将 GDD 修订标记作为 `Needs Revision` 写入 `systems-index.md`）
  未测试；它需要一条与 GDD 矛盾的 HIGH RISK 引擎发现。
- 新鲜度回执路径（全部 `UNCHANGED`，且报告覆盖或不覆盖本次运行；部分
  `CHANGED`/`NEW`；`GONE`；`UNRESOLVED`）未做 fixture 测试。
- `standard` 层级的缩减范围（仅架构文档 + 关键 ADR）未测试。
- 默认 `minimal` 层级（没有 `modes` 块的 `project.yaml`），其中技能的
  范围表说明评审不适用 —— 未做 fixture 测试；每个用例都固定
  `modes.workflow: full`。`workflow_overrides.system_overrides` 也未测试：
  此技能不请求该键，因此按系统的层级对它没有影响。
