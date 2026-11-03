# Skill Test Spec: /release-checklist

## Skill Summary

`/release-checklist [platform: pc|console|mobile|all]` 生成按项目范围收窄的
预发布清单。它解析 `modes.rigor`、`modes.workflow`、
`project.stage` 与 `platform.cert_tier`，读取 `AGENTS.md` 与
`production/milestones/` 中的当前里程碑，并从
`production/qa/bugs/` 读取未解决缺陷（Severity 与 Status
行）。缺陷条目使用解析出的 `workflow` 对应的发布
闸门阈值——未解决的 S1、S2 或 S3 在
`full` 下失败，在 `standard`/`minimal` 下仅未解决的 S1 失败（未解决的 S2/S3 列为风险）
——且没有缺陷文件时读作 `NOT ASSESSED — no bug records`，绝不为零。
它扫描代码根中的 TODO / FIXME / HACK，
始终说明分母（`scanned [N] source files: …`），或
在无根可解析时为 `NOT ASSESSED — code root unresolved`，或在
根不存在或为空时为 `NOT ASSESSED — no source files found to scan`。
缺少测试输出时报告为
`Test results: NOT ASSESSED — no test output or CI logs found`。

清单包含 Codebase Health、Build Verification、Quality Gates 与 Content
Complete 节，设备块由参数选择（默认 `all`），随后是
**仅**由 `platform.cert_tier` 选择的认证块：`none` → 单行
"Certification: omitted — cert_tier is 'none' …"；`itch` → itch.io 行；
`steam` → Steamworks 行；`console` → TRC/XR/Lotcheck 行。未设置 `cert_tier`
意味着询问哪些平台在范围内，或使用
`### Certification: NOT ASSESSED — cert tier unknown`；未设置绝不被当作
`none`。它以 Store / Distribution、Launch Readiness 和
`### Go / No-Go: [READY / NOT ASSESSED / NOT READY]` 结束——首个命中顺序为 NOT READY（
阻塞项失败），然后是 NOT ASSESSED（任何节或条目 NOT ASSESSED），然后是 READY——
最后询问 "May I write this to
`production/releases/release-checklist-[version].md`?"。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：READY、NOT READY、NOT ASSESSED
- [ ] 在写入清单之前包含 "May I write" 用语
- [ ] 有下一步交接（正式结论用 `/gate-check`，签核用 `/team-release`）

---

## Director Gate Checks

无。`/release-checklist` 不派发任何代理（`Agent` 不在其允许
工具中）。Sign-offs Required 列表（QA Lead、Technical Director、Producer、
Creative Director）是给人工使用的清单，而非被派发的闸门。正式的阶段
推进由 `/gate-check` 负责。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — Steam 层级的 PC 构建

**Fixture:**
- `platform.cert_tier: steam`；`project.stage: Polish`；`engine.name: Godot`
- `src/` 有 40 个源文件，包含 3 条 TODO、1 条 FIXME 与 0 条 HACK 注释
- `production/milestones/` 有当前里程碑
- `production/qa/bugs/` 有 `BUG-0003.md`（S1，`**Status**: Closed`）与
  `BUG-0004.md`（S4，`**Status**: Open`）；`modes.rigor` 未设置（`workflow: minimal`）
- CI 测试输出存在

**Input:** `/release-checklist pc`

**Expected behavior:**
1. 技能读取 `AGENTS.md` 与当前里程碑
2. Codebase Health 说明分母：`scanned 40 source files: 3 TODO, 1
   FIXME, 0 HACK`，并列出该 FIXME
3. 生成 PC 设备块；没有 Console 或 Mobile 设备块
4. 认证仅为 Steamworks 块
5. 其后是 Store / Distribution、Launch Readiness 与 Go / No-Go 行
6. 技能展示条目总数与已知阻塞项，然后询问 "May I write this
   to `production/releases/release-checklist-[version].md`?"；下一步指明
   `/gate-check` 与 `/team-release`

**Assertions:**
- [ ] 报告 TODO/FIXME/HACK 计数时附扫描文件数
- [ ] 仅出现 PC 设备块
- [ ] 认证包含 Steamworks 行，且没有 itch.io 或主机认证行
- [ ] Go / No-Go 为 READY 或 NOT READY——绝不为 NOT ASSESSED，因为此 fixture 中每节都可评估
- [ ] Quality Gates 缺陷行从 `production/qa/bugs/` 统计（0 个未解决 S1、S2 或 S3）；已关闭的 S1 与未解决的 S4 不导致任何失败
- [ ] 在指明 `production/releases/release-checklist-[version].md` 的 "May I write" 询问之前不写入任何内容

---

### Case 2: 设备参数与认证层级是两个独立维度

**Fixture:**
- `platform.cert_tier: itch`
- 代码根中存在源文件

**Input:** `/release-checklist console`

**Expected behavior:**
1. `console` 参数选择 Console 设备块（挂起/恢复、用户
   切换、手柄提示）
2. 认证遵循 `cert_tier`，而非参数：仅 itch.io 块
3. 不出现 Steamworks 行与 TRC/XR/Lotcheck 行

**Assertions:**
- [ ] Console 设备块存在
- [ ] 唯一的认证块是 itch.io
- [ ] 不出现主机认证行（TRC/Lotcheck、第一方提交）
- [ ] 不出现 Steamworks 行

---

### Case 3: cert_tier 为 none 与未设置 — 输出不同

**Fixture:**
- 运行 A：`platform.cert_tier: none`
- 运行 B：`platform.cert_tier` 缺失（解析块显示为未设置），且
  用户无法说明哪些平台在范围内

**Input:** `/release-checklist`（无参数 → `all` 的设备块）

**Expected behavior:**
1. 运行 A 不生成认证块，仅一行 "Certification: omitted —
   cert_tier is 'none' (internal build, alpha or jam release)."
2. 运行 B 询问哪些平台在范围内，而不是生成所有轨道；
   没有回答时生成 `### Certification: NOT ASSESSED — cert tier unknown`
   并说明原因
3. 两次运行中，`all` 参数都不会导致生成所有认证轨道

**Assertions:**
- [ ] 运行 A 显示 "omitted — cert_tier is 'none'" 行且无认证行
- [ ] 运行 B 询问哪些平台在范围内
- [ ] 运行 B 的认证节为 `NOT ASSESSED — cert tier unknown`，而非 `none` 行
- [ ] 两次运行都不会同时生成 itch.io、Steamworks 与主机认证

---

### Case 4: 边界情况 — 无内容可扫描，无测试输出

**Fixture:**
- `platform.cert_tier: steam`
- 没有 `engine.name`，没有遗留引擎值，且 `src/`、`Assets/`、
  `Source/` 都不存在（代码根无法解析）
- 没有测试输出目录或 CI 日志
- `production/qa/bugs/` 有一个缺陷，`BUG-0002.md`（S2，`**Status**: Closed`）

**Input:** `/release-checklist pc`

**Expected behavior:**
1. 代码根无法解析，因此不运行扫描
2. Codebase Health 读作 `NOT ASSESSED — code root unresolved`
   （`.trae/docs/code-root-resolution.md`），而非 `0` 个 TODO/FIXME/HACK
3. 测试行读作 `Test results: NOT ASSESSED — no test output or CI logs
   found`，而非被省略
4. 清单其余部分仍会生成并提供写入

**Assertions:**
- [ ] 不报告 TODO/FIXME/HACK 的裸 `0` 计数
- [ ] Codebase Health 为 `NOT ASSESSED — code root unresolved`
- [ ] 存在测试结果的 NOT ASSESSED 行
- [ ] Go / No-Go 绝不为 READY：它为 NOT ASSESSED 并点名两个未评估的节，
      若有阻塞项失败则为 NOT READY
- [ ] 写入仍等待 "May I write" 询问

---

### Case 5: 总监闸门检查 — 无；签核列出但不派发

**Fixture:**
- `platform.cert_tier: console`；存在源文件
- 任意评审模式

**Input:** `/release-checklist all`

**Expected behavior:**
1. 技能生成含所有设备块与主机
   认证块的清单
2. Sign-offs Required 列表以未勾选条目出现
3. 不派发任何总监或其他代理；不出现闸门 ID
4. 下一步指向 `/gate-check` 与 `/team-release`

**Assertions:**
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 尽管列出了签核，但不派发任何子代理
- [ ] 主机认证块是唯一的认证块
- [ ] 下一步指明 `/gate-check` 与 `/team-release`

---

### Case 6: 已知阻塞项高于未评估节

**Fixture:**
- `platform.cert_tier: steam`；`project.stage: Polish`
- 没有 `engine.name`，没有遗留引擎值，且 `src/`、`Assets/`、
  `Source/` 都不存在（代码根无法解析）
- CI 测试输出存在
- `production/qa/bugs/BUG-0007.md` 是 S1（Critical）缺陷，`**Status**: Open`

**Input:** `/release-checklist pc`

**Expected behavior:**
1. Codebase Health 读作 `NOT ASSESSED — code root unresolved`
2. Quality Gates 的 "Zero open S1 (Critical) bugs" 失败——这是阻塞项，在所有层级
3. Go / No-Go 为 NOT READY：首个命中者胜出，NOT READY 高于
   NOT ASSESSED
4. Rationale 将该 S1 缺陷列为阻塞项；未评估的 Codebase
   Health 节仍读作 NOT ASSESSED，而非被丢弃

**Assertions:**
- [ ] Go / No-Go 为 NOT READY——而非 NOT ASSESSED
- [ ] S1 缺陷在 Rationale 中列为阻塞项
- [ ] Codebase Health 仍显示 `NOT ASSESSED — code root unresolved`

---

### Case 7: 缺陷阈值遵循工作流层级

**Fixture:**
- `platform.cert_tier: steam`；存在源文件；CI 测试输出存在
- 运行 A：`modes.rigor: standard`（`workflow: standard`）；`production/qa/bugs/BUG-0012.md`
  是 S2（High）缺陷，`**Status**: Open`，且没有其他未解决缺陷
- 运行 B：`modes.rigor: full`（`workflow: full`）；`production/qa/bugs/BUG-0013.md`
  是 S3（Medium）缺陷，`**Status**: Open`，且没有其他未解决缺陷

**Input:** `/release-checklist pc`

**Expected behavior:**
1. 两次运行都从 `production/qa/bugs/` 读取缺陷，而非从里程碑
2. 运行 A：未解决的 S2 不导致任何条目失败——在 `standard` 下仅未解决的 S1 阻塞——
   并在 Rationale 中列为风险；不生成 S2/S3 行
3. 运行 B："Zero open S2 (High) and S3 (Medium) bugs" 行因未解决的
   S3 失败，该缺陷在 Rationale 中列为阻塞项；Go / No-Go 为 NOT READY

**Assertions:**
- [ ] 运行 A 的 Go / No-Go 不因该 S2 而为 NOT READY，且该 S2 在 Rationale 中作为风险出现
- [ ] 运行 B 的 Go / No-Go 为 NOT READY，并点名 BUG-0013 为阻塞项
- [ ] 两次运行都不为 `workflow: full` 下的 S3 提供 "documented exception"

---

### Case 8: 无缺陷记录 — NOT ASSESSED，而非零

**Fixture:**
- `platform.cert_tier: steam`；存在源文件；CI 测试输出存在
- `production/qa/bugs/` 不存在

**Input:** `/release-checklist pc`

**Expected behavior:**
1. Quality Gates 缺陷行读作 `NOT ASSESSED — no bug records`，而非 `0`
2. 缺陷条目不被勾选
3. Go / No-Go 为 NOT ASSESSED（点名这些缺陷条目），除非其他位置有阻塞项
   失败——绝不为 READY
4. 输出说明缺陷通过 `/bug-report` 提交

**Assertions:**
- [ ] 没有裸 `0` 缺陷计数，也没有勾选的 "Zero open S1 (Critical) bugs" 条目
- [ ] 出现 `NOT ASSESSED — no bug records`
- [ ] Go / No-Go 不为 READY

---

## Protocol Compliance

- [ ] 解析 `platform.cert_tier`，且仅按 `none | itch | steam | console` 分支
- [ ] 将未设置的 `cert_tier` 视为提问（或 NOT ASSESSED），绝不视为 `none`
- [ ] 设备块由参数选择，认证由 `cert_tier` 选择
- [ ] 每次扫描计数都说明分母，或报告 NOT ASSESSED
- [ ] 从 `production/qa/bugs/` 读取未解决缺陷，并按解析出的 `workflow` 应用发布闸门阈值（`full` 下 S1–S3，`standard`/`minimal` 下 S1）；无缺陷文件 → `NOT ASSESSED — no bug records`
- [ ] Go / No-Go 取首个命中：NOT READY，然后 NOT ASSESSED，然后 READY
- [ ] 在询问 "May I write" 之前展示总数与阻塞项
- [ ] 以 `/gate-check` 与 `/team-release` 作为下一步结束

---

## Coverage Notes

- `project.stage` 收窄（未到达阶段的条目标记为不在范围内）与
  `modes.rigor: minimal` 裁剪未单独测试。
- 移动设备块（按设计将 App Store / Play Store 行保留在设备块中）
  没有专门用例测试。
- READY 与 NOT READY 的判定取决于未勾选条目与
  用户输入；需要实机运行来验证理由文本。
- 已解析但不存在或为空的代码根读作
  `NOT ASSESSED — no source files found to scan`；未单独测试。
