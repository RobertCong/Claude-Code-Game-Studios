# Skill Test Spec: /launch-checklist

## Skill Summary

`/launch-checklist` 生成覆盖代码、内容、QA、商店、法务、基础设施、社区与运营的
上线就绪清单，并按项目范围收窄。它接收已解析的 `rigor`、`project.stage`、`platform.cert_tier`
与 `automation`，并据此划定范围：无法触及的阶段被声明为不在范围内，
`rigor: minimal` 会裁掉流程性条目，Platform Certification 节**仅**在
`cert_tier` 取值（`none | itch | steam | console`）下生成。未设置 `cert_tier` 是一个提问，
而不是生成全部轨道的许可；若无法确定，该节标记为
`NOT ASSESSED — cert tier unknown`。

Phase 2 读取 `AGENTS.md`、最新里程碑、`production/releases/` 中任何现有清单
以及内容日历。Phase 3 扫描代码根中的
TODO/FIXME/HACK、调试输出、占位资源与硬编码开发值，并
对每次扫描报告其分母（`scanned [N] files, [M] hits`）或
`NOT ASSESSED — [reason]`；无法评估的条目写成 `- [?]` 并附图例，
绝不写成空框或勾选。缺陷行遵循 `workflow`：S1 与 S2（或有
记录的例外），在 `full` 下为 S1–S3 且无例外。Phase 4b 对每个
没有任何扫描或文件能确定的条目，按节询问一次
`AskUserQuestion`，回答为 yes / no / not yet / N/A：yes 勾选，no 或 not yet 为失败条目
（Blocking，或带解决办法或已接受风险的 Conditional），N/A 则排除；
在 `dry-run` 与 `autonomous` 模式下跳过，并明确说明。清单
以 Go / No-Go 节结束。**Blocking Items** 是所有 FAIL 或未解决的
发现，且没有记录的解决办法或已接受风险；**Conditional Items** 是
有记录的解决办法或明确接受风险的不足。**Overall
Status** 由它们计算，首个命中者胜出：`NOT READY`（任何阻塞项）
→ `NOT ASSESSED`（任何 `[?]` 条目、`NOT ASSESSED` 节或未确认条目，逐项
点名）→ `CONDITIONAL`（任何条件项）→ `READY`。除非参数为
`dry-run`，否则它询问 "May I write this to
`production/releases/launch-checklist-[date].md`?"，并在得到回答之前不创建任何内容——
连目录也不创建。下一步：若 `project.stage` 不是 `Release`（`Polish`、更早阶段或未设置），
先运行 `/gate-check release`，然后
`/team-release`。不派发任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] frontmatter 设置 `disable-model-invocation: true`：仅在用户手动输入时运行，该设置在 frontmatter 中声明，而非在正文中询问
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：READY、CONDITIONAL、NOT ASSESSED、NOT READY（Overall Status 首个命中顺序为 NOT READY → NOT ASSESSED → CONDITIONAL → READY），以及无法评估的扫描与 cert tier 的 NOT ASSESSED
- [ ] 在写入清单之前包含 "May I write" 用语，且在得到回答之前不创建任何文件或目录
- [ ] 有 Phase 4b，按节询问一次 `AskUserQuestion`，答案为 yes / no / not yet / N/A，no / not yet 为失败条目，N/A 排除
- [ ] 有下一步交接（仅当 `project.stage` 不是 `Release` 时的 `/gate-check release`，以及 `/team-release`）

---

## Director Gate Checks

无。`/launch-checklist` 没有 `Agent` 工具，也不派发任何总监。
"Sign-Offs Required" 列表（Creative Director、Technical Director、QA Lead、
Producer、Release Manager）是给人工使用的清单文本，之后通过
`/team-release` 协调；正式的闸门结论来自 `/gate-check`。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — Steam 项目，扫描干净，各节全部确认，READY

**Fixture:**
- `project.yaml`：`project.stage: Release`、`modes.rigor: standard`、`platform.cert_tier: steam`，
  引擎 Godot（代码根 `src/`）；单机游戏，无服务器
- `src/` 有 40 个源文件，没有 TODO/FIXME/HACK，没有调试输出，没有占位资源或硬编码开发值
- `assets/` 存在且为最终资源
- `production/releases/` 尚不存在
- 在 Phase 4b 中，用户对每个节都回答 `Yes — all of them`，但
  Infrastructure 问题除外，其中 `Some differ` 使每个 Servers 条目为 N/A，
  而每个 Analytics 与 Monitoring 条目为 yes

**Input:** `/launch-checklist 2026-11-01`

**Expected behavior:**
1. Target Launch 读取为 2026-11-01
2. Phase 3 将每次扫描报告为 `scanned [N] files, 0 hits`
3. Platform Certification 仅包含 Steam 块（Steamworks SDK、商店页面、
   depot 构建、成就、通用内容规则）加上所有层级都有的无障碍行
4. 浸泡测试条目要求 `/soak-test` 能运行的最长浸泡（或手工运行的
   更长浸泡），而不是 `/soak-test` 无法产生的固定时长
5. Phase 4b 按节询问一次 `AskUserQuestion`，只列出没有任何
   扫描或文件能确定的条目（不是 Phase 3 的计数），每个回答为 yes / no /
   not yet / N/A
6. 已确认的条目勾选为 `(confirmed by the user)`；Servers 条目
   写成 `- N/A — [item]` 并排除在状态之外。没有任何阻塞、条件或未确认项，
   因此首个命中规则给出 READY
7. 技能展示清单及摘要（Overall Status、条目总数、阻塞
   数、条件数、未评估数、存在未完成节的部门）
8. 询问 "May I write this to `production/releases/launch-checklist-[date].md`?"；
   在回答之前不创建 `production/releases/`
9. 下一步：`/team-release`——阶段已为 `Release`，因此不提供 `/gate-check`

**Assertions:**
- [ ] Phase 3 的每行扫描都显示其分母（`scanned [N] files, [M] hits`）
- [ ] 不出现主机（TRC/Lotcheck）或 itch.io 条目
- [ ] 浸泡测试条目不要求比 `/soak-test` 提供的更长的浸泡
- [ ] Phase 4b 每节至多询问一个问题，且不询问任何 Phase 3 计数
- [ ] Overall Status 为 READY——每个条目都基于证据或 Phase 4b 回答而勾选，或标记为 N/A
- [ ] 摘要给出总数、阻塞数、条件数与未评估数
- [ ] "May I write" 指明 `production/releases/launch-checklist-[date].md`，且在用户回答前不存在该目录
- [ ] 下一步指明 `/team-release`，且不提供 `/gate-check`

---

### Case 2: 阻塞性发现 — FIXME 与调试输出

**Fixture:**
- 同 Case 1，但 `src/` 中有 3 条 `FIXME` 注释，生产代码中有一处 `print()` 调试调用
- `src/` 还有一条 `HACK` 注释，其理由记录在旁边

**Input:** `/launch-checklist 2026-11-01`

**Expected behavior:**
1. Phase 3 统计 FIXME 及其位置，并找到调试输出
2. Code Quality 显示 "FIXME count: 3 (zero required)"，且 "No debug output" 条目未勾选
3. 它们出现在 Blocking Items 下——没有解决办法或已接受风险的发现
4. 有理由的 HACK 出现在 Conditional Items 下，并附其理由
5. Overall Status 为 NOT READY——阻塞项高于其他一切
6. 保存前仍会询问 "May I write"

**Assertions:**
- [ ] FIXME 计数为 3，并附文件位置
- [ ] 报告调试 `print()`，且其条目未勾选
- [ ] Blocking Items 列出 FIXME 与调试输出
- [ ] 有记录的 HACK 位于 Conditional Items，而非 Blocking Items
- [ ] Overall Status 为 NOT READY（不是 READY、CONDITIONAL 或 NOT ASSESSED）

---

### Case 3: 未设置 Cert Tier — 询问，不生成所有轨道

**Fixture:**
- `project.yaml`：`project.stage: Release`、`modes.rigor: standard`，没有 `platform.cert_tier`
- 配置块显示 `platform.cert_tier: (unset -- ask which platforms are in scope)`

**Input:** `/launch-checklist 2026-11-01`

**Expected behavior:**
1. 技能询问哪些平台在范围内，而不是生成所有认证轨道
2. 若用户回答，则只生成匹配层级的块
3. 若无法确定，该节标记为 `NOT ASSESSED — cert tier unknown`
4. 未设置不被当作 `none`——该节不会被静默省略

**Assertions:**
- [ ] 技能询问哪些平台在范围内
- [ ] 主机、Steam 与 itch.io 块绝不一起全部生成
- [ ] 没有回答时，该节为 `NOT ASSESSED — cert tier unknown`
- [ ] 不出现 "omitted — cert_tier is 'none'" 行

---

### Case 4: 无内容可扫描 — `[?]` 条目，而非绿色勾选

**Fixture:**
- `project.yaml`：`project.stage: Release`、`platform.cert_tier: itch`，引擎 Godot
- `src/` 存在但为空；没有 `assets/` 目录

**Input:** `/launch-checklist 2026-11-01`

**Expected behavior:**
1. Phase 3 将代码扫描报告为 `NOT ASSESSED — no source files`（或
   `directory empty`），将占位资源扫描报告为
   `NOT ASSESSED — no asset folder`，而不是零命中
2. 受影响的条目（例如 "All placeholder art replaced with final assets"、
   "No debug output in production code"）写成 `- [?]`
3. 包含图例 `[?] = not assessed — the input to this check was absent`
4. Platform Certification 仅包含 itch.io 块
5. 没有发现任何内容，因此 Blocking Items 为空——而 `[?]` 条目使
   Overall Status 为 **NOT ASSESSED**，点名无法运行的扫描，绝不
   为 READY

**Assertions:**
- [ ] 没有输入的扫描不会被报告为零命中
- [ ] "All placeholder art replaced with final assets" 为 `- [?]`，未勾选且不是 `- [ ]`
- [ ] 出现 `[?]` 图例
- [ ] 不出现 Steamworks 或主机条目
- [ ] Overall Status 为 NOT ASSESSED，并点名 `[?]` 扫描（代码与占位资源扫描）；不是 READY 或 CONDITIONAL

---

### Case 5: 总监闸门检查 — 试运行，cert tier 为 `none`

**Fixture:**
- `project.yaml`：`project.stage: Release`、`platform.cert_tier: none`
- 代码根含源文件

**Input:** `/launch-checklist dry-run`

**Expected behavior:**
1. Target Launch 读取为 DRY RUN
2. Platform Certification 被替换为一行
   `Platform Certification: omitted — cert_tier is 'none' (internal/jam release).`
3. Phase 4b 被跳过，输出说明这一点；原本会询问的条目保持
   未确认，因此 Overall Status 为 NOT ASSESSED
4. 清单被展示，但不进行 "May I write" 询问，也不写入任何文件
5. 不派发任何总监或其他代理；不出现闸门 ID
6. 下一步指明 `/team-release`；阶段为 `Release`，因此不提供 `/gate-check`

**Assertions:**
- [ ] 出现 "omitted — cert_tier is 'none'" 行，且不生成任何认证行
- [ ] 试运行中不询问任何 Phase 4b 问题，说明跳过，且 Overall Status 为 NOT ASSESSED
- [ ] 试运行模式下不进行 "May I write" 询问，也不写入任何文件
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 下一步指明 `/team-release`，且不提供 `/gate-check`

---

### Case 6: 阶段仍为 Polish — 回答使其为 CONDITIONAL 或 NOT ASSESSED

**Fixture:**
- 同 Case 1，但 `project.stage: Polish` 且 `modes.rigor: full`（`workflow: full`）
- 变体 A：在 Phase 4b 中，Marketing 条目全部为 yes，但 "Press/influencer
  review keys distributed" 回答为 `not yet`——用户说密钥在
  上线当天早上发出，制作人接受该风险；其他每个节都为 `Yes —
  all of them`（Servers 如 Case 1 为 N/A）
- 变体 B：同变体 A，但用户未回答 Legal 问题

**Input:** `/launch-checklist 2026-11-01`

**Expected behavior:**
1. Testing 缺陷行为 `workflow: full` 版本：零 S1，以及零 S2 与 S3
   且无例外
2. 变体 A：媒体密钥条目是带已接受风险的失败条目，因此归入
   Conditional Items，并点名由谁接受；没有阻塞或未确认项；
   Overall Status 为 CONDITIONAL
3. 变体 B：Legal 条目保持未确认并被点名；Overall Status 为
   NOT ASSESSED（高于 CONDITIONAL）
4. 下一步：先运行 `/gate-check release`——阶段仍为 `Polish`——
   然后 `/team-release`

**Assertions:**
- [ ] `not yet` 回答绝不被勾选；带已接受风险时列在 Conditional Items 下
- [ ] 变体 A 的 Overall Status 为 CONDITIONAL
- [ ] 变体 B 的 Overall Status 为 NOT ASSESSED，并点名未回答的 Legal 条目
- [ ] 在 `workflow: full` 下不为 S2 或 S3 提供任何 "documented exception"
- [ ] 下一步在 `/team-release` 之前指明 `/gate-check release`

---

## Protocol Compliance

- [ ] 按 `project.stage`、`modes.rigor` 与 `platform.cert_tier` 收窄清单范围
- [ ] 认证按四个 `cert_tier` 取值分支，而非按平台名分支
- [ ] 每次扫描都报告分母或 `NOT ASSESSED — [reason]`
- [ ] 无法评估的条目写成 `- [?]` 并附图例
- [ ] 保存前询问 "May I write"（试运行中完全跳过），且在得到回答之前不创建任何文件或目录
- [ ] Phase 4b 按节询问一次，只针对必须由人确认的条目，绝不自答；在 `dry-run` 与 `autonomous` 模式下跳过 Phase 4b 并明确说明
- [ ] 只要 `project.stage` 不是 `Release`，就在下一步中指明 `/gate-check release`
- [ ] 将无解决办法或已接受风险的发现放在 Blocking Items 下，将有记录的解决办法或已接受风险的不足放在 Conditional Items 下
- [ ] Overall Status 为 READY、CONDITIONAL、NOT ASSESSED 或 NOT READY，首个命中顺序为 NOT READY → NOT ASSESSED → CONDITIONAL → READY

---

## Coverage Notes

- `cert_tier: console`（TRC/Lotcheck、存档数据、手柄映射、年龄分级）
  未单独测试。
- 阶段收窄（尚未到达阶段的条目被声明为不在范围内）与
  `rigor: minimal` 裁剪未单独测试。
- `production/releases/` 中的现有清单仅作为上下文读取；未测试
  与其进行的比较。
