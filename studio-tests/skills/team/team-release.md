# Skill Test Spec: /team-release

## Skill Summary

通过 7 阶段流水线编排发布团队，从发布候选版本到
部署及发布后监控。协调 release-manager、qa-lead、
devops-engineer、producer、security-engineer（在线/多人/玩家
数据场景必需）、network-programmer（多人场景必需）、analytics-engineer、
localization-lead、performance-analyst 与 community-manager。Phase 0 解析
`review_mode`、`automation`、`team.size`、`workflow` 与 `project.stage`。
`/gate-check release` 是发布前必须通过的准备就绪闸门，因此
当 `project.stage` 不是 `Release` 时，技能在 Phase 1 之前停止，不启动
任何代理，提示 "run `/gate-check release` first"，并提供一个显式覆盖选项，
该覆盖会作为 `Stage override: …` 记录在 go/no-go 记录与报告中 —— 技能
绝不自行设置 `project.stage`。技能在 Phase 1 之前宣布活动集 ——
默认的 `individual` 仅启动 release-manager。每个代理写入
`production/releases/` 下各自的指定文件（补丁说明位于
`docs/patch-notes/`）。Phase 3 的代理并行运行。最终给出 go/no-go
决策；若制作人判定 NO-GO，则跳过部署（Phase 6）；即便判定 GO，
在任何自动化模式下仍需要显式的 `AskUserQuestion` 批准。
以发布后监控计划收尾。

---

## Static Assertions (Structural)

- [ ] 具备必需的前置元数据（frontmatter）字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个 Phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] File Write Protocol 区分子代理（有界例外：指定路径、`production/`、`docs/` 或 `tests/` 下的新产出物、处于闸门内的阶段 —— 无逐次写入提示）与子技能（常规协议 —— 写入前先询问），并要求对标签、推送、构建与商店页面变更进行显式确认
- [ ] File Write Protocol 章节说明编排器不直接写文件
- [ ] 为每个代理指定目标位置，使任意两个并行代理不共用文件：`production/releases/release-plan-[version].md`、`release-checklist-[version].md`、`qa-gate-[version].md`、`build-[version].md`、`security-signoff-[version].md`、`netcode-signoff-[version].md`、`localization-signoff-[version].md`、`performance-signoff-[version].md`、`analytics-signoff-[version].md`、`go-no-go-[version].md`、`announcement-[version].md`、`release-report-[version].md`，以及 `docs/patch-notes/[version].md`
- [ ] 存在 Error Recovery Protocol 章节：核实指定产出物在磁盘上、立即呈现 BLOCKED、始终产出部分报告，完整流程（呈现 / 评估 / 提供选项 / 部分报告）见 `.claude/docs/error-recovery-protocol.md`
- [ ] Phase 0 解析 `project.stage`，Phase 1 之前的阶段检查在其不为 `Release` 时停止（"run `/gate-check release` first"），不启动任何代理；唯一越过它的方式是显式 `AskUserQuestion` 覆盖，在任何 `automation` 模式下都会询问，并作为 `Stage override:` 行记录在 go/no-go 记录与最终报告中
- [ ] 具备指向发布后监控与 `/retrospective` 的后续步骤交接；技能本身不写 `project.stage` 或 `production/stage.txt`
- [ ] qa-lead 按已解析 `workflow` 的发布闸门阈值检查未关闭缺陷：任何层级都查 S1，`full` 下还查 S2 与 S3
- [ ] 「阶段闸门（phase gate）」是流水线自身列出的决策点，无论 `automation` 模式如何；没有任何条款称总监在阶段闸门处启动
- [ ] Phase 2 采用主干开发：发布候选版本是 `main` 上的一个提交，仅在发布需要稳定（冻结 / 认证）时才切出 `release/*` 分支，且每个修复也都会落到 `main`
- [ ] `/patch-notes` 由 release-manager 在 Phase 6 运行，community-manager 依据其输出撰写公告
- [ ] 在需要用户批准才能继续的阶段转换处使用 `AskUserQuestion`
- [ ] Phase 0 解析 `team.size`，且技能要求在 Phase 1 之前有一行活动集公告
- [ ] 明确说明 Phase 3 的代理（qa-lead、devops-engineer，以及可选的 security-engineer、network-programmer）并行运行
- [ ] Phase 6（Deployment）以 Phase 5 的 GO 决策为条件，并且无论 `modes.automation` 如何都需要显式 `AskUserQuestion` 批准
- [ ] security-engineer 被描述为以 `platform.online` / `platform.multiplayer` 及玩家数据为条件 —— 并非总是启动，缺失的键会被询问，而非被读作 `false`

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与
`modes.automation: collaborative`，且不含 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 顺利路径（单人游戏）—— 所有阶段完成，版本已部署

**Fixture:**
- 已解析配置块：`review_mode: full`、`team.size: studio`、`automation: collaborative`
- `project.yaml` 中的 `project.stage` 为 `Release`（`/gate-check release` 已通过）
- 里程碑验收标准全部满足（制作人可确认）
- `project.yaml` 设置 `platform.online: false` 与 `platform.multiplayer: false`；游戏不收集任何玩家数据
- 本次发布不计划冻结或平台认证
- `main` 上的所有 CI 构建均干净
- 没有未关闭的 S1/S2 缺陷；所有字符串均已翻译

**Input:** `/team-release v1.0.0`

**Expected behavior:**
1. 阶段检查通过（`project.stage: Release`）；在任何启动之前，用一行宣布 `team.size: studio` 的活动集
2. Phase 1：通过 Agent 启动 `producer`；确认所有里程碑验收标准已满足；识别任何延期范围；写入 `production/releases/release-plan-v1.0.0.md`；AskUserQuestion：用户批准后才进入 Phase 2
3. Phase 2：通过 Agent 启动 `release-manager`；在 `main` 上提升版本号，该提交即发布候选版本；未找到来自 Polish 阶段的发布清单，因此调用 `/release-checklist`（`production/releases/release-checklist-v1.0.0.md`）；不切出 `release/*` 分支，因为无需稳定；AskUserQuestion：用户批准后才进入 Phase 3
4. Phase 3（并行）：同时向 `qa-lead`（回归套件、关键路径签核、`production/releases/qa-gate-v1.0.0.md`）与 `devops-engineer`（构建产物、CI 验证、`production/releases/build-v1.0.0.md`）发起 Agent 调用；不启动 security-engineer（`platform.online: false`，无玩家数据），也不启动 network-programmer（`platform.multiplayer: false`），Phase 3 输出会点名每一处跳过及其原因
5. Phase 4：localization-lead 核实所有字符串均已翻译（`production/releases/localization-signoff-v1.0.0.md`）；performance-analyst 对发布构建做基准测试（`performance-signoff-v1.0.0.md`）；`analytics-engineer` 核实遥测在发布构建上正确触发（`analytics-signoff-v1.0.0.md`）—— 每个代理写入各自文件
6. Phase 5：通过 Agent 启动 `producer`；从 qa-lead、release-manager、devops-engineer 与 technical-director 收集签核；没有未关闭的阻塞问题；制作人宣布 GO（`production/releases/go-no-go-v1.0.0.md`）
7. Phase 6：`AskUserQuestion` "Producer verdict is GO. Execute Phase 6 — tag, deploy to staging, deploy to production?"，选项为 [A] Yes, deploy / [B] Staging only — hold production / [C] Stop here；用户选择 [A]
8. Phase 6：release-manager + devops-engineer 为发布打标签，通过 `/changelog` 定稿变更日志，部署到预发环境，然后部署到生产；同时 release-manager 通过 `/patch-notes v1.0.0` 定稿补丁说明（`docs/patch-notes/v1.0.0.md`），`community-manager` 依据其撰写上线公告（`production/releases/announcement-v1.0.0.md`）
9. Phase 7：release-manager 生成发布报告（`production/releases/release-report-v1.0.0.md`）；制作人更新里程碑跟踪；qa-lead 监控回归；community-manager 发布；analytics-engineer 确认线上仪表盘健康
10. 后续步骤：监控仪表盘 48 小时；若发生重大问题则 `/retrospective`
11. 结论：COMPLETE —— 发布已执行并部署

**Assertions:**
- [ ] 指明 `team.size: studio` 的活动集行出现在第一个代理启动之前
- [ ] Phase 2 不切出 `release/*` 分支：发布候选版本是 `main` 上的版本号提升提交
- [ ] Phase 3 的 qa-lead 与 devops-engineer Agent 调用同时发起，而非顺序发起
- [ ] 当 `platform.online` 与 `platform.multiplayer` 为 false 且无玩家数据时，不启动 security-engineer，且 Phase 3 输出会点名说明（例如 `security-engineer: not spawned — platform.online: false, platform.multiplayer: false, no player data`）—— 跳过从不静默
- [ ] 每个代理都被告知其各自的指定输出文件 —— 并行的 Phase 3 与 Phase 4 代理从不共用文件 —— 且编排器在将该阶段视为完成之前确认文件存在
- [ ] Phase 5 的制作人在宣布 GO 之前从 qa-lead、release-manager、devops-engineer 与 technical-director 收集签核
- [ ] 只有在用户在 Phase 6 的 `AskUserQuestion` 中选择 [A] 之后，Phase 6 部署才开始
- [ ] `/changelog` 由 release-manager 在 Phase 6 调用（而非直接编写）
- [ ] `/patch-notes v1.0.0` 由 release-manager 在 Phase 6 调用，community-manager 依据其输出撰写公告 —— 绝不要求 community-manager 运行 `/patch-notes`
- [ ] Phase 7 的监控计划包含 48 小时发布后监控承诺
- [ ] 阶段检查处没有停止、也没有覆盖询问，因为 `project.stage` 读到 `Release`；技能既不写 `project.stage` 也不写 `production/stage.txt`，也不虚构上线后的阶段值
- [ ] 最终输出中出现结论：COMPLETE

---

### Case 2: Go/No-Go 为 NO —— Phase 3 发现 S1 缺陷，跳过部署

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`project.stage: Release`
- v0.9.0 的发布候选版本是 `main` 上的一个提交
- qa-lead 在 Phase 3 回归测试中发现主菜单中一个此前未报告的 S1 崩溃
- devops-engineer 的构建干净，产物已就绪

**Input:** `/team-release v0.9.0`

**Expected behavior:**
1. Phase 1–2 正常完成；确定发布候选版本提交
2. Phase 3（并行）：devops-engineer 返回干净的构建签核；qa-lead 返回并指出一个 S1 缺陷，回归套件失败；qa-lead 判定质量闸门：NOT PASSED
3. 在 Phase 3 → 4 的转换处，编排器在对话中写出 qa-lead 的完整结果 —— "QA-LEAD: S1 bug found — [crash description]. Quality gate: NOT PASSED." —— 并通过 `AskUserQuestion` 捕获决策
4. Phase 5：通过 Agent 启动 `producer`；制作人收到 qa-lead 的 NOT PASSED 结论；制作人宣布 NO-GO，理由为："S1 bug [ID] is open and unresolved. Releasing is not safe."
5. 编排器呈现 "PRODUCER: NO-GO — [rationale]"，并使用 `AskUserQuestion` 给出选项：修复阻塞项并重新运行受影响的阶段、推迟发布，或以记录在案的理由覆盖 NO-GO
6. Phase 6（Deployment）被完全跳过 —— 不打标签、不部署到预发环境、不部署到生产
7. Phase 6 的两个复制步骤都不运行 —— release-manager 不运行 `/patch-notes`，也不启动 community-manager（没有可公告的部署）
8. 技能以部分报告收尾，总结完成了什么（Phase 1–5）、跳过了什么（Phase 6）及其原因
9. 结论：BLOCKED —— 发布未部署

**Assertions:**
- [ ] qa-lead 的 S1 缺陷发现会在 Phase 3 完成后立即呈现给用户 —— 不被压制到 Phase 5
- [ ] 制作人的 NO-GO 决策明确引用该 S1 缺陷与质量闸门结果
- [ ] 制作人宣布 NO-GO 时，Phase 6 部署被完全跳过
- [ ] NO-GO 时不产出补丁说明或上线公告 —— 不运行 `/patch-notes`，也不启动 community-manager
- [ ] 部分报告清楚说明哪些阶段已完成、哪些被跳过及其原因
- [ ] 因 NO-GO 跳过部署时，结论为 BLOCKED（而非 COMPLETE）
- [ ] AskUserQuestion 向用户提供解决选项（修复并重新运行 / 推迟 / 带理由覆盖）
- [ ] 覆盖路径（若被选择）要求书面理由，并在任何 Phase 6 动作之前将其作为 "Override Justification" 字段嵌入记录

---

### Case 3: 在线游戏的安全审计 —— security-engineer 在 Phase 3 启动

**Fixture:**
- 已解析配置块：`review_mode: full`、`team.size: studio`、`automation: collaborative`、`project.stage: Release`
- `project.yaml` 设置 `platform.multiplayer: true` 与 `platform.online: true`；游戏存储玩家账户数据
- v2.1.0 的发布候选版本存在
- qa-lead 与 devops-engineer 均返回干净的签核

**Input:** `/team-release v2.1.0`

**Expected behavior:**
1. Phase 1–2 正常完成
2. Phase 3（并行）：编排器从 `project.yaml` 读到 `platform.multiplayer: true` 与 `platform.online: true`，注意到存储的玩家数据；同时向 `qa-lead`、`devops-engineer`、`security-engineer` 与 `network-programmer` 发起 Agent 调用
3. security-engineer 执行发布前安全审计：审查认证流程、反作弊存在情况、数据隐私合规性；返回签核
4. network-programmer 验证延迟补偿、重连处理与高负载下的带宽；返回签核
5. Phase 3 的四个代理全部完成；在 Phase 4 开始之前收集其结果
6. Phase 5：制作人在做出 go/no-go 判断之前，从 qa-lead、release-manager、devops-engineer、security-engineer、network-programmer 与 technical-director 收集签核
7. 其余阶段正常进行至 COMPLETE

**Assertions:**
- [ ] 当游戏具备在线功能、多人或玩家数据时，security-engineer 会在 Phase 3 启动 —— 不被跳过
- [ ] 当游戏具备多人功能时，network-programmer 会在 Phase 3 启动
- [ ] Phase 3 的四个 Agent 调用（qa-lead、devops-engineer、security-engineer、network-programmer）同时发起
- [ ] security-engineer 的审计覆盖认证、反作弊与数据隐私合规
- [ ] Phase 5 制作人的签核收集包含 security-engineer 与 network-programmer，以及 qa-lead、release-manager、devops-engineer 与 technical-director
- [ ] 在 security-engineer 签核之前，Phase 6 部署不会开始
- [ ] 对于有玩家数据的游戏，技能不把 security-engineer 视为可选

---

### Case 4: 本地化遗漏 —— 未翻译字符串进入 go/no-go 判断

**Fixture:**
- 已解析配置块：`team.size: studio`、`automation: collaborative`、`project.stage: Release`
- `project.yaml` 设置 `platform.online: false` 与 `platform.multiplayer: false`；无玩家数据
- v1.2.0 的发布候选版本存在
- Phase 3（qa-lead、devops-engineer）以干净的签核完成
- Phase 4：localization-lead 在法语区域（受支持语言）发现 47 个未翻译字符串，并将其作为 BLOCKED/CONCERNS 项返回
- 制作人判定该遗漏阻塞发布，并宣布 NO-GO

**Input:** `/team-release v1.2.0`

**Expected behavior:**
1. Phase 1–3 以干净的签核完成
2. Phase 4：翻译检查委托给 localization-lead（在 `studio` 下活动）；其签核写入 `production/releases/localization-signoff-v1.2.0.md`，编排器确认文件存在
3. 在 Phase 4 → 5 的转换处，编排器在对话中写出本地化发现，并通过 `AskUserQuestion` 捕获决策 —— 不自动推进
4. Phase 5：制作人将未翻译字符串评估为未关闭问题，并宣布 NO-GO
5. 编排器呈现 "PRODUCER: NO-GO — [rationale naming the untranslated French strings]"，并通过 `AskUserQuestion` 提供：修复阻塞项并重新运行受影响的阶段 / 推迟发布 / 带记录在案的理由覆盖 NO-GO
6. Phase 6 被完全跳过；部分报告将 Phase 1–5 列为已完成、Phase 6 列为已跳过及其原因
7. 结论：BLOCKED —— 发布未部署

**Assertions:**
- [ ] 当 localization-lead 在活动集中时，Phase 4 将翻译检查委托给它
- [ ] 本地化发现在 go/no-go 运行之前，于 Phase 4 → 5 的转换处通过 `AskUserQuestion` 呈现
- [ ] 制作人的 NO-GO 理由点名未翻译字符串问题
- [ ] 解决选项包含重新运行受影响的阶段 —— 技能不要求从 Phase 1 重新开始
- [ ] 若用户覆盖，书面理由会在任何 Phase 6 动作之前嵌入记录
- [ ] 编排器自身不写任何文件 —— 它不产出翻译来解除发布阻塞
- [ ] 结论为 BLOCKED，且 NO-GO 时 Phase 6 不运行

---

### Case 5: 无参数 —— 技能推断版本或询问

两个变体中 `project.stage` 均为 `Release`。

**Fixture（变体 A —— 存在里程碑数据）:**
- `production/milestones/` 存在并含有一个里程碑文件；最近的里程碑为 "v1.1.0 — Gold"
- `production/session-state/active.md` 引用某个版本或里程碑

**Fixture（变体 B —— 无可发现的版本）:**
- `production/milestones/` 不存在
- `production/session-state/active.md` 未引用任何版本
- 不存在可据以推断版本的 git 标签

**Input:** `/team-release`（无参数）

**Expected behavior（变体 A）:**
1. 参数检查：未提供版本；读取 `production/session-state/active.md` 与 `production/milestones/` 中最近的里程碑文件
2. 推断 v1.1.0 为目标版本；报告 "No version argument provided — inferred v1.1.0 from milestone data. Proceeding."
3. 在开始 Phase 1 之前用 AskUserQuestion 确认："Releasing v1.1.0. Is this correct?"
4. 按输入为 `/team-release v1.1.0` 的方式继续

**Expected behavior（变体 B）:**
1. 参数检查：未提供版本；读取可用的状态文件 —— 无可发现的版本
2. 使用 AskUserQuestion："What version number should be released? (e.g., v1.0.0)"
3. 等待用户输入后再继续

**Assertions:**
- [ ] 未提供参数时，技能不会默认使用硬编码的版本字符串
- [ ] 在询问之前，技能读取 `production/session-state/active.md` 与里程碑文件（变体 A）
- [ ] 推断出的版本在继续之前通过 AskUserQuestion 与用户确认（变体 A）
- [ ] 无可发现版本时使用 AskUserQuestion —— 技能不猜测（变体 B）
- [ ] 里程碑文件缺失时技能不会报错 —— 它回退到询问（变体 B）

---

### Case 6: 阶段仍为 Polish —— 在 Phase 1 之前停止，不启动任何代理

**Fixture:**
- 已解析配置块：`review_mode: full`、`team.size: studio`、`automation: autonomous`、`project.stage: Polish`
- `/gate-check release` 尚未运行；v1.0.0 的发布候选版本存在

**Input:** `/team-release v1.0.0`

**Expected behavior（变体 A —— 用户停止）:**
1. Phase 0 解析出 `project.stage: Polish`；阶段检查在 Phase 1 之前停止："The release readiness gate has not passed (project.stage: Polish) — run `/gate-check release` first."
2. `AskUserQuestion` 提供 `[A] Stop — I'll run /gate-check release (recommended)` / `[B] Proceed anyway — override the stage check` —— 即便 `automation` 为 `autonomous` 也会询问
3. 用户选择 `[A]`：不启动任何代理，不写入任何文件，不打标签也不部署
4. 结论：BLOCKED —— 发布闸门未通过

**Expected behavior（变体 B —— 用户覆盖）:**
1. 同样的停止与询问；用户选择 `[B]`，并在被问及原因时回答 "cert window closes Friday"
2. 运行以覆盖信息进入制作人的简报，继续至 Phase 1
3. go/no-go 记录（`production/releases/go-no-go-v1.0.0.md`）与最终报告携带 `Stage override: project.stage was Polish — release gate not passed; the user chose to proceed: cert window closes Friday`
4. 运行结束时 `project.stage` 仍读到 `Polish`

**Assertions:**
- [ ] 在阶段检查问题得到回答之前，不发起任何 `Agent` 调用
- [ ] 停止消息点名 `/gate-check release` 为应首先运行的步骤
- [ ] 在 `autonomous` 模式下也会询问该问题 —— 覆盖从不自动采用
- [ ] 选择 `[A]` 时结论为 BLOCKED，且完全不启动任何代理（连 release-manager 都不启动）
- [ ] 选择 `[B]` 时，覆盖及其原因出现在 go/no-go 记录与最终报告中
- [ ] 两种变体中技能都不写 `project.stage` 或 `production/stage.txt`

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual): release-manager.` 与一行 `Not spawned this run:` 开始，后者点名流水线列出的其他所有代理，并通过 release-manager 进行咨询 —— 这一切发生在任何代理启动之前
- [ ] 在 `collaborative` 模式下，在每个阶段转换闸门（Phase 1 后、Phase 2 后、Phase 3 后、Phase 4 后、Phase 5 go/no-go 后）使用 `AskUserQuestion`
- [ ] 活动集中的 Phase 3 代理始终以并行 Agent 调用发起 —— qa-lead 与 devops-engineer 从不顺序执行
- [ ] security-engineer 依据 `platform.online` / `platform.multiplayer` 与玩家数据有条件启动 —— 绝不静默跳过：缺失的键会被询问，跳过会在 Phase 3 输出中点名
- [ ] 在 `review_mode: lean` 或 `solo` 下，Phase 5 签核不启动 technical-director，go/no-go 记录写作 `technical-director sign-off: not run (review_mode: <mode>)`，而非将其列为已给出
- [ ] technical-director 的 `NOT ASSESSED [missing input]` 回答会如实记录在 go/no-go 记录中，绝不计为签核
- [ ] 当切出 `release/*` 分支以稳定发布时，它只接收缺陷修复，且每个修复也都会落到 `main`
- [ ] File Write Protocol：编排器从不直接调用 Write/Edit —— 子代理在有界例外下写入其指定路径，子技能在写入前先询问
- [ ] Phase 6 部署严格以 Phase 5 的 GO 结论与显式 `AskUserQuestion` 批准为条件 —— 绝不自动触发，包括在 `autonomous` 模式下
- [ ] 错误恢复：任何 BLOCKED 代理都会在继续进入依赖阶段之前立即呈现
- [ ] 指定产出物在磁盘上缺失的阶段被视为失败，而非完成
- [ ] 若任何阶段失败或流水线被中止，始终产出部分报告（Case 2 与 Case 4）
- [ ] 结论：仅当部署完成时为 COMPLETE；当阶段检查中止运行、go/no-go 为 NO，或存在未解决的硬性阻塞项时为 BLOCKED
- [ ] 阶段检查：当 `project.stage` 不为 `Release` 时，在用户回答停止问题之前不启动任何代理；继续需要显式 `[B]` 覆盖，并会记录（Case 6）
- [ ] 后续步骤始终包含 48 小时发布后监控与 `/retrospective` 建议 —— 绝不直接写 `project.stage`

---

## Coverage Notes

- Phase 7 的发布后动作（发布报告、里程碑跟踪、社区发布、仪表盘监控）由 Case 1 隐式验证。由于 Phase 7 不设闸门且没有阻塞性失败模式，无需单独的边界用例。
- "devops-engineer 构建失败" 路径未单独测试 —— 它会在 Phase 3 呈现为 BLOCKED 结果，并遵循标准错误恢复协议（呈现 → 评估 → AskUserQuestion 选项）。
- 并行的 Phase 4 路径（"若有可用资源" 时与 Phase 3 并行运行）交由技能自行判断；Case 4 将 Phase 4 作为顺序阶段测试。
- Phase 6 的 `[B] Staging only — hold production` 选项未单独测试。
- 需要稳定的发布（冻结或平台认证，因而切出 `release/*` 分支）没有专门用例；该规则在 Protocol Compliance 中作了断言。
- "带记录在案理由覆盖 NO-GO" 路径在 Case 2 与 Case 4 中检验了其理由步骤，但未走完整个部署流程。
