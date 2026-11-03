# Skill Test Spec: /day-one-patch

## Skill Summary

`/day-one-patch` 为黄金母盘（gold master）之后发现的已知问题运行一个仅修缺陷的
迷你冲刺：范围 → 回滚方案 → 修复 → 轻量 QA 闸门 → 补丁记录。
仅在用户主动输入时运行（`disable-model-invocation: true`）。

阶段 1 读取 `project.stage`（`project.yaml`，回退 `production/stage.txt`）
并要求为 `Release` 或 `Polish`；读取 `production/gate-checks/` 中最近的记录，
并 **核实发布闸门已通过**，而不是从阶段推断；并从 `production/qa/bugs/*.md`
加载 Status 为 `Open` 或 `Fixed — Pending Verification` 的缺陷，
外加最近的冲刺与安全审计。阶段 2 对每个缺陷做纳入分类（S1/S2、P1、修复不足
4 小时、仅数据/配置以及认证要求者可纳入；架构改动与
新增代码路径推迟到 1.1；S3/S4 仅在可做简单的配置修复时纳入），并请
用户批准范围，其中 `[C] No day-one patch needed` 作为出口。

在任何修复之前，`release-manager` 起草一份回滚方案，写入
`production/releases/rollback-plan-[version].md`。代码修复交由
`lead-programmer`，它先返回每个修复及将要改动的文件，且不写入任何内容；技能随后
就整批一次性询问 —— "May I apply these
fixes? [BUG-ID → files]" —— 之后才做任何代码改动，并由 `qa-tester` 验证每个
修复。针对性与更广泛的测试用 `project.yaml` 中的 `commands.test` 运行
（未设置 → 每个修复显示 `Tests: NOT RUN`，更广泛的回归为 NOT ASSESSED）。
配置/数据修复直接进行，但先有一次 "May I edit" 询问，点名文件与
值改动。`qa-lead` 决定 QA 范围（`/smoke-check`，或引擎测试根目录中受影响
系统的测试）；补丁 QA 结论必须为 PASS 或 PASS WITH WARNINGS 才能
继续 —— FAIL 将修复推迟到 1.1，NOT ASSESSED 从不视为通过。补丁
记录在询问 "May I write" 之后写入 `production/releases/day-one-patch-[version].md`。
不派生任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] frontmatter 设置 `disable-model-invocation: true`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键字：PASS、PASS WITH WARNINGS、NOT ASSESSED、FAIL
- [ ] 对回滚方案与补丁记录都包含 "May I write" 措辞，对直接配置/数据修复包含 "May I edit"
- [ ] 具备下一步交接（`/patch-notes`、`/bug-report verify`、`/retrospective [milestone-name]`（针对上线里程碑））

---

## Director Gate Checks

不派生任何总监级代理（creative-director、technical-director、
producer、art-director）。该技能派生工作代理 ——
`release-manager`（回滚方案）、`lead-programmer` 与 `qa-tester`（修复）、
`qa-lead`（补丁 QA 范围）—— 并检查 `production/gate-checks/` 中已有的发布闸门记录；
它本身不运行 `/gate-check`。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Scope, rollback plan first, fixes, patch record

**Fixture:**
- `project.yaml` 含 `project.stage: Release`
- `production/gate-checks/` 中最近的文件记录了一次发布闸门 PASS
- `production/qa/bugs/` 含三个 Open 缺陷：
  - `BUG-0010` —— S2、P1，代码修复预计 2 小时
  - `BUG-0011` —— S3，单值配置/数据修复
  - `BUG-0012` —— S2，修复需要架构改动

**Input:** `/day-one-patch`

**Expected behavior:**
1. 阶段 1 确认 Release 阶段与通过的发布闸门
2. 阶段 2 建议纳入 BUG-0010 与 BUG-0011，推迟 BUG-0012
   （"Fix requires architecture change — defer to 1.1"）；`AskUserQuestion` 提供
   Approve / Adjust / No day-one patch needed
3. 批准后，`release-manager` 起草回滚方案，技能询问
   "May I write this rollback plan to `production/releases/rollback-plan-[version].md`?"
   —— 在写入之前不开始任何修复工作
4. `lead-programmer` 返回 BUG-0010 的最小修复及将要改动的文件，
   不写入任何内容；技能询问 "May I apply these fixes? [BUG-0010 → files]"，
   仅在回答 yes 时 `lead-programmer` 才实施并用
   `commands.test` 运行针对性测试；`qa-tester` 验证它。BUG-0011 的配置
   改动在没有程序员代理的情况下直接进行，此前技能询问
   "May I edit `[config file]` — `[key]`: [old value] → [new value]?"
5. `qa-lead` 设定 QA 范围；QA 结论为 PASS
6. 技能询问 "May I write this patch record to `production/releases/day-one-patch-[version].md`?"
7. 记录在 Bugs Fixed 下列出 BUG-0010 与 BUG-0011，在 Deferred to 1.1 下列出 BUG-0012 及其原因
8. 下一步提供 `/patch-notes`

**Assertions:**
- [ ] BUG-0012 因需要架构改动而推迟到 1.1
- [ ] 在任何工作之前通过 `AskUserQuestion` 批准范围
- [ ] 在任何修复尝试之前写入回滚方案
- [ ] 在一次 "May I apply these fixes?" 询问获批之前不改动任何代码文件，且 `lead-programmer` 在提议时不写入任何内容
- [ ] BUG-0011 在不派生 `lead-programmer` 的情况下修复
- [ ] 在点名文件与值改动的 "May I edit" 询问获批之前不编辑配置文件
- [ ] "May I write" 指明 `production/releases/day-one-patch-[version].md`
- [ ] 下一步包含 `/patch-notes`

---

### Case 2: Critical Bug That Cannot Be Fixed Safely — Accepted risk, rollback trigger

**Fixture:**
- Release 阶段；记录显示发布闸门 PASS
- `production/qa/bugs/` 含 `BUG-0020` —— S1（存档文件数据丢失），其修复需要
  架构改动 —— 以及 `BUG-0021` —— S2、P1、1 小时修复

**Input:** `/day-one-patch`

**Expected behavior:**
1. BUG-0020 为 S1，但其修复需要架构改动，因此建议
   推迟到 1.1；BUG-0021 被纳入
2. 用户批准范围；补丁针对 BUG-0021 继续
3. 写入补丁记录后，技能警告："S1 bugs remain open and were
   not patched. These are accepted risks. Document them in the rollback plan trigger
   conditions — if they occur at scale, rollback may be preferable to a follow-up patch."

**Assertions:**
- [ ] BUG-0020 出现在推迟表中并附原因（架构改动）
- [ ] BUG-0021 仍被打补丁 —— S1 不阻塞补丁的其余部分
- [ ] 在写入记录之后显示 "S1 bugs remain open" 警告
- [ ] 警告指向回滚方案的触发条件

---

### Case 3: No Release-Gate Record — NOT ASSESSED, not assumed

**Fixture:**
- `project.yaml` 含 `project.stage: Release`
- `production/gate-checks/` 为空（无发布闸门记录）
- `production/qa/bugs/` 中存在 Open 缺陷

**Input:** `/day-one-patch`

**Expected behavior:**
1. 阶段 1 未找到发布闸门记录
2. 报告 `Release gate: NOT ASSESSED — no gate-check record found`
3. 说明缩减的 QA 范围依赖一个无人能找到的闸门
4. 询问是先运行 `/gate-check` 还是改为执行完整 QA
5. 不静默继续到范围界定或修复

**Assertions:**
- [ ] 报告 `Release gate: NOT ASSESSED — no gate-check record found`
- [ ] 不把 `project.stage: Release` 本身当作闸门已通过的证据
- [ ] 向用户提供先运行 `/gate-check` 或完整 QA 两个选项
- [ ] 在用户回答之前不产出回滚方案、修复或补丁记录

---

### Case 4: Nothing Worth Patching — User selects "No day-one patch needed"

**Fixture:**
- Release 阶段；记录显示发布闸门 PASS
- `production/qa/bugs/` 只有两个需要代码改动的 S4 外观问题

**Input:** `/day-one-patch`

**Expected behavior:**
1. 两个 S4 缺陷都被提议推迟（S3/S4 仅在可做简单配置修复时纳入）
2. 询问范围问题；用户选择 `[C] No day-one patch needed`
3. 技能输出 "No day-one patch required. Proceed to `/launch-checklist`." 并停止
4. 无回滚方案、无代理、无补丁记录

**Assertions:**
- [ ] 两个 S4 缺陷都列为推迟，而非纳入
- [ ] 选择 `[C]` 时显示 "No day-one patch required. Proceed to `/launch-checklist`."
- [ ] 技能停止且不写入任何文件
- [ ] 不派生 `release-manager`、`lead-programmer` 或 `qa-lead`

---

### Case 5: Director Gate Check — Patch QA NOT ASSESSED is not a pass

**Fixture:**
- `project.yaml`：`modes.rigor: standard`（因此没有游戏测试的项目会得到 NOT ASSESSED，而不是 WAIVED）
- Release 阶段；记录显示发布闸门 PASS；一个已纳入的 S2/P1 修复已实施
- `qa-lead` 选择针对性冒烟检查；`/smoke-check` 返回
  `NOT ASSESSED — no game tests found`

**Input:** `/day-one-patch`

**Expected behavior:**
1. 技能不把 NOT ASSESSED 当作 PASS 或 PASS WITH WARNINGS
2. 它要么获得真实结果（按结论所述使其可运行），要么把该修复推迟到 1.1
3. 任何时刻都不派生总监级代理，也不运行 `/gate-check`
4. 若写入补丁记录，其中显示 QA 结论，并在 "Not assessed" 中填写无法检查的内容及原因

**Assertions:**
- [ ] NOT ASSESSED 不会让补丁当作已通过而继续
- [ ] 该修复要么以真实结果重新验证，要么推迟到 1.1
- [ ] 不派生 creative-director、technical-director、producer 或 art-director
- [ ] 任何写入的记录都说明 QA 结论及未评估的内容

---

### Case 6: Deferred Bugs With No Sprint Plan — Scheduled into the brief's build order

**Fixture:**
- `project.yaml`：`project.stage: Release`；`modes.rigor: minimal`（工作流 `minimal`，无冲刺）
- `production/gate-checks/` 中最近的文件记录了一次发布闸门 PASS
- 没有 `production/sprints/` 目录；`design/game-brief.md` 存在并含构建顺序
- `production/qa/bugs/` 含 `BUG-0030` —— S2、P1、1 小时修复 —— 以及 `BUG-0031` —— S2，修复需要架构改动

**Input:** `/day-one-patch`

**Expected behavior:**
1. BUG-0030 被纳入，BUG-0031 推迟到 1.1；用户批准范围，补丁运行到记录阶段
2. 补丁记录在 "Deferred to 1.1" 表中列出 BUG-0031
3. 技能告知用户运行 `/bug-triage` 来安排被推迟的缺陷，并且由于项目没有冲刺计划，应把它们放入简报的构建顺序，而不是 1.1 冲刺

**Assertions:**
- [ ] 每个被推迟的缺陷都在记录的 "Deferred to 1.1" 表中
- [ ] 技能指向 `/bug-triage` 来安排被推迟的缺陷
- [ ] 没有冲刺计划时，点名的去处是简报的构建顺序，而不是 1.1 冲刺
- [ ] 不创建也不要求冲刺文件

---

## Protocol Compliance

- [ ] 在界定范围之前确认 Release/Polish 阶段并核实发布闸门记录
- [ ] 从 `production/qa/bugs/*.md` 加载缺陷
- [ ] 在任何工作之前获得用户对范围的批准
- [ ] 在任何修复之前写入回滚方案
- [ ] 在 `lead-programmer` 改动任何代码之前，一次性询问 "May I apply these fixes?"
- [ ] 用 `commands.test` 运行测试，绝不凭记忆写运行器命令行；键未设置时如实说明（更广泛的回归为 NOT ASSESSED）
- [ ] 要求 PASS 或 PASS WITH WARNINGS 才能继续；FAIL 推迟该修复；NOT ASSESSED 从不视为通过
- [ ] 在回滚方案之前与补丁记录之前询问 "May I write"，在直接配置/数据改动之前询问 "May I edit"

---

## Coverage Notes

- Release/Polish 之外的阶段（"Day-one patch prep is for Release-stage
  projects"）未被单独测试。
- 最近闸门记录为 FAIL、CONCERNS 或 NOT ASSESSED（点名并停止）
  未被单独测试。
- 超过 1 天的范围警告与 `cert-feedback` 范围参数未被单独测试。
