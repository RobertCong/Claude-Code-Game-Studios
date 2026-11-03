# Skill Test Spec: /hotfix

## Skill Summary

`/hotfix` 在冲刺流程之外执行紧急修复，并留有审计记录。
只有当用户主动输入时它才运行（`disable-model-invocation: true`）。流程：

1. **评估严重程度**（按 `/bug-triage` 的量表为 S1 Critical / S2 High / S3 或更低），并通过
   `AskUserQuestion` 确认；S3 或更低时停止并给出 `Verdict: **REDIRECTED**`。
2. **热修复记录**——询问 "May I write this to
   `production/hotfixes/hotfix-[date]-[short-name].md`?"
3. **分支**——检查是否为 git 仓库，然后在运行
   `git checkout -b hotfix/[short-name] [base-ref]` 之前询问。`[base-ref]` 是
   缺陷所在的发布版本：`main` 上的标签，或为该版本稳定化而切出的 `release/*`
   分支——绝不是 `main` 的最新提交。
4. **调查与提案**——根因与最小修复，然后在任何代码改动之前询问
   "May I implement this fix?"；随后实现并运行针对性测试。
5. **批准**——`lead-programmer`、`qa-tester` 与 `producer` 并行生成；三者都必须
   返回 APPROVE，而 CONCERNS 或 REJECT 会阻止部署。
6. **QA 再入闸门**——`qa-lead` 选择冒烟测试、针对性的
   `/team-qa feature: [system]`，或完整 QA；冒烟测试 FAIL 会把修复送回 Phase 4。
   NOT ASSESSED 的结果不算通过：仍要部署的话，需要 producer 明确决策，
   并记录在热修复记录中。
7. **部署**——在任何合并、打标签或部署之前无条件使用 `AskUserQuestion`
   （即使在 `autonomous` 模式下也是如此）；合并到 `main`，且仅当发布版本存在
   `release/*` 分支时才合并到该分支；为补丁发布打标签并验证
   回填；在更新缺陷文件之前询问，然后将其设为
   `Fixed — Pending Verification`；打印 "Hotfix Deployed"（选择 `[B]` 时打印
   "Hotfix Merged to main — release held"，且不含 Tag）；`[C]` 则停止，不合并、
   不打标签、不更新缺陷文件；随后执行 `/bug-report verify`（CANNOT VERIFY 通过
   实际游玩复现步骤并回答其手动游玩问题来解决）以及事后复盘
   （使用 incident-response 模板记录——`/retrospective` 没有事故模式）。

针对性测试使用 `project.yaml` 中的 `commands.test` 运行；当它未设置或
没有测试覆盖该系统时，热修复记录写明 `Tests: NOT RUN — [reason]`。
返回 NOT APPROVED 或 BLOCKED 的 `/team-qa` 通过与冒烟测试 FAIL 相同的方式处理。
S1 采用 `/bug-triage` 的定义：崩溃、数据丢失，或功能完全失效。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] Frontmatter 设置 `disable-model-invocation: true`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：REDIRECTED、APPROVE / CONCERNS / REJECT（签核）、NOT ASSESSED（QA 闸门）
- [ ] 包含 "May I write"（热修复记录）、"May I implement this fix?"（代码）与 "May I update"（缺陷文件）措辞
- [ ] 有下一步交接（`/bug-report verify [BUG-ID]`、事后复盘）

---

## Director Gate Checks

不使用任何具名总监闸门 ID（CD-*、TD-*、AD-*、PR-*），评审模式
也不适用。Phase 5 并行生成三个**阻塞性签核**——
`lead-programmer`、`qa-tester` 与 `producer`（唯一的总监层级代理）——
三者都必须在部署前返回 APPROVE。Phase 5b 生成 `qa-lead` 以
选择 QA 范围。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — S1 崩溃修复，含记录、分支、批准与回填

**Fixture:**
- Git 仓库；线上构建是 `main` 上的发布标签 `v1.2.0`，且不存在
  `release/*` 分支（trunk 默认形态）
- `src/gameplay/arena.gd` 中存在缺陷（进入首领竞技场时崩溃）；
  `production/qa/bugs/BUG-0031.md` 存在且 `**Status**: Open`
- 三个签核都返回 APPROVE；`qa-lead` 选择冒烟测试，结果为 PASS

**Input:** `/hotfix BUG-0031`

**Expected behavior:**
1. 评估为 S1 并通过 `AskUserQuestion` 确认；用户选择 `[A] S1 (Critical)`
2. 询问 "May I write this to `production/hotfixes/hotfix-[date]-boss-arena-crash.md`?" 并写入
3. 运行 `git rev-parse --is-inside-work-tree`，询问 "Ready to create hotfix branch
   'hotfix/boss-arena-crash' from v1.2.0?"，并在 `[A] Yes — create branch` 之后
   才运行 `git checkout -b hotfix/boss-arena-crash v1.2.0`
4. 呈现根因与最小修复，询问 "May I implement this fix?"，随后实现并运行针对性测试
5. 并行生成 `lead-programmer`、`qa-tester` 与 `producer`；三者均 APPROVE
6. `qa-lead` → 冒烟测试 PASS
7. 询问 "Hotfix validated and approved. Merge to `main`, tag v1.2.1 and deploy?"
   （不指明发布分支——因为不存在）；用户选择 `[A]`
8. 合并到 `main`，在修复后的构建上打标签 `v1.2.1`，并确认修复已在 `main` 上
9. 在将其设为 `Fixed — Pending Verification` 之前询问 "May I update
   `production/qa/bugs/BUG-0031.md` …?"，然后打印 "Hotfix Deployed: boss-arena-crash"，
   并带有 `Tag: v1.2.1` 与 `Next: /bug-report verify`

**Assertions:**
- [ ] 热修复记录在创建分支之前写入
- [ ] 分支从发布标签 `v1.2.0` 开始，而不是从 `main` 的最新提交
- [ ] 仅在用户选择 `[A]` 之后才创建分支
- [ ] 在 "May I implement this fix?" 获批之前不修改任何代码
- [ ] 三个签核代理作为同时发出的 `Agent` 调用生成
- [ ] 在 Phase 6 部署问题得到回答之前不发生任何合并
- [ ] 不创建或合并任何 `release/*` 分支；补丁发布被打上标签
- [ ] 摘要的 Backport 行说明其在 `main` 上存在
- [ ] 在用户批准 "May I update" 问题之前不编辑缺陷文件
- [ ] `BUG-0031.md` 的 Status 变为 `Fixed — Pending Verification`

---

### Case 2: Sign-off REJECT — 部署被阻止

**Fixture:**
- 针对 S1 缺陷的修复已实现
- `qa-tester` 返回 REJECT："Player health clamping regression detected"；
  `lead-programmer` 与 `producer` 返回 APPROVE

**Input:** `/hotfix`

**Expected behavior:**
1. Phase 5 收集全部三个响应
2. 由于其中一个返回 REJECT，技能不部署：它呈现该回归并先解决它
3. 在 REJECT 仍成立期间，不会到达 Phase 5b 的 QA 闸门与 Phase 6 的部署问题
4. 不发生任何合并、打标签或部署

**Assertions:**
- [ ] qa-tester 的 REJECT 及其回归被展示给用户
- [ ] 在 REJECT 未解决时，技能不会继续部署
- [ ] 在 REJECT 仍成立期间不发出部署 `AskUserQuestion`
- [ ] 不执行任何合并

---

### Case 3: Release Branch — 即使在 autonomous 模式下也保留部署批准

**Fixture:**
- `project.yaml` 设置 `modes.automation: autonomous`
- 线上发布 `v1.3.0` 有 `release/1.3` 分支，为认证稳定化而切出；
  热修复分支从 `release/1.3` 开始
- 一个 S2 修复获得全部三个 APPROVE 签核，且冒烟测试 PASS

**Input:** `/hotfix`

**Expected behavior:**
1. 尽管设置为 `autonomous`，Phase 6 仍询问 "Hotfix validated and approved. Merge to `main`
   and `release/1.3`, tag v1.3.1 and deploy?"，选项为 `[A] Yes — merge and deploy` /
   `[B] Merge to main only — hold the release` / `[C] Stop here`
2. 用户选择 `[B]`
3. 修复只合并到 `main`；不合并到 `release/1.3`，不打标签，也不部署
4. 摘要标题为 "Hotfix Merged to main — release held"，且没有 Tag 行

**Assertions:**
- [ ] 即使 `modes.automation` 为 `autonomous`，仍提出部署问题
- [ ] 问题指明 `release/1.3`，因为该发布版本存在此分支
- [ ] 提供全部三个选项
- [ ] 选择 `[B]` 时，不合并 `release/1.3`、不创建标签，也不部署任何内容
- [ ] 选择 `[B]` 时，`main` 收到该修复
- [ ] 选择 `[B]` 时，摘要不写 "Deployed"，也不指明任何标签

---

### Case 4: Not an Emergency — 外观类 S4 在任何工作开始前被重定向

**Fixture:**
- 用户报告制作人员名单页面的一处拼写错误

**Input:** `/hotfix typo in the credits screen`

**Expected behavior:**
1. Phase 1 评估为 S4（Low——外观类），并请用户确认严重程度
2. 用户选择 `[C] S3 or lower — redirect to normal bug fix workflow`
3. 技能停止：结论 REDIRECTED——S3 及以下使用常规缺陷修复流程

**Assertions:**
- [ ] 通过 `AskUserQuestion` 确认严重程度，选项为 S1 / S2 / S3-or-lower
- [ ] 结论为 REDIRECTED
- [ ] 不写入任何热修复记录，也不创建任何分支
- [ ] 不修改任何代码，也不生成任何代理

---

### Case 5: Director Gate Check — Producer 签核，且 NOT ASSESSED 的 QA 不算通过

**Fixture:**
- `project.yaml`：`modes.rigor: standard`（因此没有游戏测试的项目得到 NOT ASSESSED，而非 WAIVED）
- S1 修复已实现；三个签核均 APPROVE
- `qa-lead` 选择冒烟测试；`/smoke-check` 返回 `NOT ASSESSED — no game tests found`

**Input:** `/hotfix`

**Expected behavior:**
1. `producer` 作为阻塞性签核生成，而非具名总监闸门；不出现任何闸门 ID
2. NOT ASSESSED 的 QA 结果被视为未满足，而非通过
3. 技能要么获取缺失的结果，要么把决策明确交给 producer，
   作为部署未验证热修复的决策。这一兜底出口是刻意设计的：
   紧急修复可能必须在测试套件存在之前就发布，但只能作为
   具名决策，绝不能作为悄然放行的闸门
4. 如果 producer 决定部署未验证的修复，该决策——由谁做出以及
   原因——会记录在热修复记录中，摘要的 QA 闸门行写为
   NOT ASSESSED，并说明原因以及这是谁的明确决策

**Assertions:**
- [ ] 输出中不出现任何闸门 ID（CD-*、TD-*、AD-*、PR-*）
- [ ] NOT ASSESSED 不会像 QA 闸门已通过那样推进到 Phase 6
- [ ] 只有在三个 APPROVE 签核加上 producer 明确决定部署未验证版本之后，才会继续部署
- [ ] 该决策记录在热修复记录中
- [ ] 摘要把 QA 闸门记录为 NOT ASSESSED，并写明原因以及是谁的决策

---

### Case 6: Smoke Check FAIL — 回到 Phase 4，且 CONCERNS 签核仍会阻止

**Fixture:**
- S1 修复已实现；三个签核均 APPROVE；`qa-lead` 选择冒烟测试
- `/smoke-check` 返回 FAIL："Player health clamping regression detected"
- 在修订后的修复上，`lead-programmer` 返回 CONCERNS（"the clamp now runs on
  the save path too"）；`qa-tester` 与 `producer` 返回 APPROVE

**Input:** `/hotfix`

**Expected behavior:**
1. FAIL 阻止部署：技能带着失败的检查回到 Phase 4，
   呈现修订后的修复，并在改动代码之前再次询问 "May I implement this fix?"
2. 实现之后（Phase 4b），它重新运行 Phase 5 的全部三个签核——
   其中包括 qa-tester 的回归运行——然后重新执行 QA 步骤
3. `lead-programmer` 的 CONCERNS 与 REJECT 一样会阻止：它被展示给
   用户，并在技能继续之前解决
4. 只有在三者都返回 APPROVE 且重新运行的冒烟测试通过之后，才提出
   Phase 6 的部署问题

**Assertions:**
- [ ] 冒烟测试 FAIL 绝不会到达部署问题
- [ ] 修订后的修复有自己的 "May I implement this fix?" 批准
- [ ] 针对修订后的修复重新运行全部三个签核与 QA 步骤
- [ ] 签核中的 CONCERNS 在解决之前会阻止部署；它不被视为批准
- [ ] FAIL 或 CONCERNS 仍成立期间不发生任何合并、打标签或部署

---

## Protocol Compliance

- [ ] 在任何工作开始前确认严重程度；S3 或更低为 REDIRECTED
- [ ] 在热修复记录之前询问 "May I write"
- [ ] 在创建分支之前询问
- [ ] 在修改代码之前询问 "May I implement this fix?"
- [ ] 使用 `commands.test` 运行针对性测试，绝不凭记忆写运行器命令；当该键未设置（或没有覆盖该系统的测试）时记录 `Tests: NOT RUN — [reason]`
- [ ] 把 `/team-qa` 的 NOT APPROVED 或 BLOCKED 按冒烟测试 FAIL 处理
- [ ] 在部署问题中选 `[C] Stop here` 时，不合并、不打标签、不更新任何内容，记录保持 IN PROGRESS
- [ ] 只有在三个 APPROVE 签核且 QA 闸门已运行的情况下才部署——或者，
      当 QA 闸门为 NOT ASSESSED 时，必须有 producer 明确决定部署
      未验证版本，并记录在热修复记录中
- [ ] 无论 `modes.automation` 如何，在任何合并、打标签或部署之前都先询问
- [ ] 从该修复所针对的发布版本（其标签，或若存在则其 `release/*` 分支）开始热修复分支
- [ ] 在 `main` 上验证回填，且仅当发布版本存在 `release/*` 分支时才在该分支上验证
- [ ] 在编辑缺陷文件之前询问 "May I update"

---

## Coverage Notes

- 非 git 工作目录（"Not a git repository — create the branch manually."）
  未单独测试。
- `qa-lead` 选择针对性的 `/team-qa feature: [system]` 通过（APPROVED /
  APPROVED WITH CONDITIONS）或完整 QA 未单独测试。
- Phase 7 部署后验证（VERIFIED FIXED → `/bug-report close`；STILL
  PRESENT → 重新打开并评估回滚；CANNOT VERIFY → 缺陷保持打开，直到
  在已部署构建中实际游玩其复现步骤，并通过 `/bug-report verify` 的
  手动游玩问题上报）未单独测试。
