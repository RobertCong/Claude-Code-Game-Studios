---
name: hotfix
description: "绕过常规冲刺流程的紧急修复——建立热修复分支、跟踪审批、验证回填、保留完整审计轨迹。"
argument-hint: "[bug-id or description]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(git rev-parse *), Bash(git tag --list*), Bash(git branch --list *)
model: sonnet
---

# 热修复（Hotfix）

> **仅限显式调用**：仅当用户用 `/hotfix` 显式请求时才应运行本技能。不要基于上下文匹配自动调用。

## Phase 1: 评估严重程度

读取缺陷描述或 ID。按 `/bug-triage` 的量表评估严重程度：

- **S1（Critical，致命）**：崩溃、数据丢失或功能完全失效——游戏无法继续（安全问题的评级依据其影响）
- **S2（High，高）**：主要功能损坏，但游戏仍可游玩
- **S3 或更低**：功能降级但有绕过办法，或仅外观问题——适用常规缺陷修复工作流

用 `AskUserQuestion` 确认：
- 提示："我评估为 **[assessed severity]** —— [brief rationale]。请确认严重程度以继续："
- 选项：
  - `[A] S1（Critical，致命）—— 崩溃、数据丢失或功能完全失效`
  - `[B] S2（High，高）—— 主要功能损坏，但游戏仍可游玩`
  - `[C] S3 或更低 —— 重定向到常规缺陷修复工作流`

若选 [C]：停止。结论：**REDIRECTED** —— S3 及以下请使用常规缺陷修复工作流。

---

## Phase 2: 创建热修复记录

起草热修复记录：

```markdown
## Hotfix: [Short Description]
Date: [Date]
Severity: [S1/S2]
Reporter: [Who found it]
Status: IN PROGRESS

### Problem
[Clear description of what is broken and the player impact]

### Root Cause
[To be filled during investigation]

### Fix
[To be filled during implementation]

### Testing
[What was tested and how]

### Approvals
- [ ] Fix reviewed by lead-programmer
- [ ] Regression test passed (qa-tester)
- [ ] Release approved (producer)

### Rollback Plan
[How to revert if the fix causes new issues]
```

询问："我可以把它写入 `production/hotfixes/hotfix-[date]-[short-name].md` 吗？"

若同意，写入文件，必要时创建目录。

---

## Phase 3: 创建热修复分支

检查这是否为 git 仓库：

`Bash: git rev-parse --is-inside-work-tree 2>/dev/null`

若该命令失败或返回为空：记录"不是 git 仓库——请手动创建分支。"并跳过分支创建。

`[base-ref]` 是缺陷所在的发布版本。发布是 `main`（主干）上的标签，因此它就是该发布的标签（`git tag --list`；最新的通常是在线构建）——或者，若曾经切出过用于稳定该发布的 `release/*` 分支，则是该分支（`git branch --list 'release/*'`）。绝不用 `main` 的头部：它可能包含尚未发布的工作。

若检查通过，在创建分支前使用 `AskUserQuestion`：
- 提示："准备从 [base-ref] 创建热修复分支 'hotfix/[short-name]' 吗？"
- 选项：
  - `[A] 是 —— 创建分支`
  - `[B] 使用其他基准引用 —— 我来指定`
  - `[C] 跳过 —— 我自己创建分支`

仅在用户选 [A] 时运行 `git checkout -b hotfix/[short-name] [base-ref]`。若选 [B]：向用户询问基准引用，然后用该引用运行命令。若选 [C]：跳过分支创建并继续 Phase 4。

---

## Phase 4: 调查并提出方案

找出根因。起草最小修复：哪些文件改动、改动做什么，以及刻意不去碰什么。不要借热修复之名重构、清理或添加功能。

呈现根因与拟议修复，然后询问："我可以实施这个修复吗？" 在此批准之前不要修改任何代码——紧急流程之所以能赢得审计轨迹，是因为它在变更*存在之前*就批准变更，而不是之后。

---

## Phase 4b: 实施（仅限批准后）

实施已批准的最小变更。通过运行受影响系统的定向测试来验证修复，使用 `project.yaml` 中的 `commands.test`（在运行器允许时收窄到受影响的套件）——绝不凭记忆写运行器命令行，那会丢掉引擎需要的参数（gdUnit4 缺少 `--remote-debug tcp://127.0.0.1:0` 会挂起）。检查相邻系统是否出现回归。若 `commands.test` 未设置，或没有测试覆盖受影响的系统，说明该情况，并在热修复记录的 Testing 章节记录 `Tests: NOT RUN — [reason]`；随后 Phase 5b 的 QA 闸门（gate）会承担验证职责。

用根因、修复细节与测试结果更新热修复记录。

---

## Phase 5: 收集审批

使用 `Agent` 工具并行请求签核：

- `subagent_type: lead-programmer` —— 评审修复的正确性与副作用
- `subagent_type: qa-tester` —— 对受影响的系统运行定向回归测试
- `subagent_type: producer` —— 批准部署时机与沟通计划

三者都必须返回 APPROVE 才能继续。若任一返回 CONCERNS 或 REJECT，不要部署——先暴露问题并解决它。

---

## Phase 5b: QA 重新入场闸门

审批之后，确定部署热修复前所需的 QA 范围。通过 `Agent` 启动 `qa-lead`，提供：
- 热修复描述与受影响系统
- Phase 5 的回归测试结果
- 所有涉及被改动文件的系统清单（用 Grep 查找调用方）

询问 qa-lead：**完整冒烟检查是否足够，还是该修复需要一次定向 team-qa 复核？**

应用结论：
- **Smoke check sufficient** —— 针对热修复构建运行 `/smoke-check`。若 PASS 或
  PASS WITH WARNINGS，进入 Phase 6（将警告带入热修复记录）。
  若 **FAIL**，不要部署：带着失败的检查项回到 Phase 4，在那里让修订后的修复获得批准，实施它（Phase 4b），然后重新运行 Phase 5 的审批——其中包括 qa-tester 的回归运行——以及本 QA 步骤。一个破坏冒烟套件的热修复是第二起事故，不是修复。
- **Targeted QA pass required** —— 运行 `/team-qa feature: [affected-system]`，仅限定在受影响的系统。若 QA 返回 APPROVED 或 APPROVED WITH CONDITIONS，进入 Phase 6；若 NOT APPROVED 或 BLOCKED，按上述冒烟检查 FAIL 处理。
- **Full QA required** —— 触及核心系统的 S1 修复可能需要完整的 `/team-qa sprint`。这会推迟部署，但能防止坏补丁。

**若 QA 步骤返回 `NOT ASSESSED`，说明闸门未运行——应视为未满足，而不是已满足。** `/smoke-check` 在套件从未执行时返回该值，`/team-qa` 在某个周期未产生已执行证据时返回该值。**NOT ASSESSED 结果不是通过**——无论来自哪个技能——而在时间压力下，宽松的解读方式恰恰会显得合理，
这正是此处要把它写下来的原因。要么取得缺失的结果——结论会说明怎样才能让它可运行——要么将决策明确交给制作人，明说这是决定部署一个未验证的热修复，而不是一个悄悄放行的闸门。在热修复记录的 Testing 章节记录该决策——谁做的、为什么。

不要跳过此闸门。破坏其他东西的热修复比原缺陷更糟。

---

## Phase 6: 更新缺陷状态并部署

> **停止——部署需要明确批准，无一例外。** 合并热修复并为补丁发布打标签是本技能中唯一不可逆的动作，
> 因此即便分支创建（可逆）已经被闸门化，它同样需要闸门。在任何合并、打标签或部署之前，使用 `AskUserQuestion`：
>
> - 提示："热修复已验证并获批准。合并到 [targets]、打标签 [patch tag]
>   并部署？" —— `[targets]` 为 `main`，仅当该发布有 `release/*` 分支时才加上它
> - 选项：`[A] 是 —— 合并并部署` / `[B] 仅合并到 main —— 暂缓
>   发布` / `[C] 在此停止`
>
> 无论 `modes.automation` 为何（包括 `autonomous`）都适用。紧急流程恰恰是最可能出现、也最难恢复未经评审的不可逆步骤的地方。

选 `[A]` 时：将热修复分支合并到 `main`，若该发布有 `release/*` 分支也合并到它；在修复后的构建上打补丁发布标签（下一个补丁版本，例如 `v1.2.0` → `v1.2.1`）——若有 `release/*` 分支则打在该分支头部，否则打在热修复分支头部——并部署该标签，而不是 `main` 的头部。选 `[B]` 时：仅合并到 `main`——不合并发布分支、不打标签、不部署。选 `[C]` 时：停止——不合并、不打标签、不部署，也不更新缺陷文件；热修复记录的状态保持 IN PROGRESS，并说明这一点。

> **除非你验证，否则回填未经验证。** frontmatter 宣称
> "backport verified"。合并之后，确认修复已存在于 `main`（主干）——以及该发布的 `release/*` 分支（若存在）——并说明结果。未回填的热修复意味着缺陷会在下一个从 `main` 打出的发布中重现，这是最常见的热修复回归。

若存在原始缺陷文件则更新它——按编号在 `production/qa/bugs/` 中查找，方式与 `/bug-report verify` 相同。先询问："我可以更新
`production/qa/bugs/[bug file]`，写入下面的修复记录并将其 Status 设为
`Fixed — Pending Verification` 吗？"

```markdown
## Fix Record
**Fixed in**: hotfix/[branch-name] — [commit hash or description]
**Fixed date**: [date]
**Status**: Fixed — Pending Verification
```

在缺陷文件头部设置 `**Status**: Fixed — Pending Verification`。

输出部署摘要。其标题随 Phase 6 的回答而定——选 `[A]` 时为 `Hotfix
Deployed: [short-name]`，选 `[B]` 时为 `Hotfix Merged to main — release held:
[short-name]`——且选 `[B]` 时结尾行省略 Tag，因为未创建任何标签：

```
## Hotfix Deployed: [short-name]

**Severity**: [S1/S2]
**Root cause**: [one line]
**Fix**: [one line]
**QA gate**: [Smoke check PASS / Team-QA APPROVED / NOT ASSESSED — [why, and whose
             explicit decision it was to deploy anyway]]
**Approvals**: lead-programmer ✓ / qa-tester ✓ / producer ✓
**Backport**: [verified present on `main` (and the `release/*` branch, if the
              release has one) — or NOT VERIFIED, with what was not checked]
**Rollback plan**: [from Phase 2 record]

Merge to: [targets] · Tag: [patch tag]
Next: /bug-report verify [BUG-ID] after deploy to confirm resolution
```

### 规则（Rules）
- 热修复必须是修复问题的最小变更——不清理、不重构
- 每次热修复都必须在部署前记录回滚计划
- 热修复分支从它所修复的发布开始——取其标签，或取其 `release/*`
  分支（若存在）——并合并到 `main`（主干），仅当该 `release/*` 分支存在时才合并到它；补丁发布打标签
- 所有热修复都要求在 48 小时内进行事后复盘
- 若修复复杂到需要超过 4 小时，上报给 `technical-director`

---

## Phase 7: 部署后验证

部署后，运行 `/bug-report verify [BUG-ID]` 以确认修复在已部署构建中解决了问题。

若为 VERIFIED FIXED：运行 `/bug-report close [BUG-ID]` 正式关闭。
若为 STILL PRESENT：热修复失败——立即重新打开、评估回滚并上报。
若为 CANNOT VERIFY：修复未获确认——不要关闭缺陷；在已部署构建中按复现步骤游玩一遍，然后再次运行 `/bug-report verify [BUG-ID]`，回答其手动游玩问题以确定结果。

在 48 小时内安排事后复盘。`/retrospective` 回顾的是冲刺或里程碑，不是事故：使用
`.claude/docs/templates/incident-response.md` 记录该复盘，并在下一次
`/retrospective` 上提出其经验教训。

使用 `AskUserQuestion`：
- 提示："热修复完成。下一步是什么？"
- 选项：
  - `[A] 运行 /smoke-check 验证修复`
  - `[B] 运行 /patch-notes 记录本次热修复`
  - `[C] 在此停止`
