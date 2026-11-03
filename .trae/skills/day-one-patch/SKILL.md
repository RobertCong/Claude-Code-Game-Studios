---
name: day-one-patch
description: "首发日补丁——针对黄金母盘（gold master）之后发现的已知问题做聚焦修复。带 QA 闸门与回滚的迷你冲刺。"
argument-hint: "[scope: known-bugs | cert-feedback | all]"
user-invocable: true
disable-model-invocation: true
---

# 首发日补丁（Day-One Patch）

每款已发布的游戏都有首发日补丁。在上线日之前规划好它，可以避免混乱。本技能将补丁范围限定为仅安全且必要的内容，通过一次轻量级 QA 流程为其设闸门，并确保在任何东西发布之前都存在回滚计划。它是一次迷你冲刺——不是热修复，也不是完整冲刺。

**何时运行：**
- 黄金母盘（gold master）构建锁定之后（认证通过或上线候选已打标签）
- 当存在风险太高、不宜在黄金母盘中处理的已知缺陷时
- 当认证反馈要求在提交后做小修复时
- 当上线前试玩测试在发布闸门通过后发现必须修复的问题时

**首发日补丁范围规则：**
- 仅限可安全快速修复的 P1/P2 缺陷
- 不添加新功能——仅做修复
- 不重构——最小可行变更
- 任何需要超过 4 小时开发时间的修复都属于补丁 1.1，而非首发日

**输出：** `production/releases/day-one-patch-[version].md`

---

## Phase 1: 加载发布上下文

读取：
- `project.yaml` 中的 `project.stage`（回退 `production/stage.txt`）——确认项目处于 Release 阶段
- `production/gate-checks/` 中最新文件——阅读发布闸门结论
- `production/qa/bugs/*.md` —— 加载所有 Status: Open 或 Fixed — Pending Verification 的缺陷
- `production/sprints/` 中最新的——了解已发布的内容
- `production/security/security-audit-*.md` 中最新的——检查是否有未决安全事项

若解析出的阶段（project.yaml → stage.txt）不是 `Release` 或 `Polish`：
> "首发日补丁准备面向 Release 阶段的项目。当前阶段：[stage]。在接近上线之前，本技能并不适用。"

**检查前提，不要假设它。** 整个技能建立在"已有一个通过了发布闸门的
黄金母盘"之上——正是该前提为其轻量级 QA 流程（而非完整流程）提供了正当性。因此要验证它，而不是从阶段值推断：

- **`production/gate-checks/` 中没有文件**，或没有任何文件记录发布闸门
  结论：报告 `Release gate: NOT ASSESSED — no gate-check record found`。不要
  静默继续。清楚地说明：下文缩减的 QA 范围是一个谁都找不到的闸门所赋予的正当性，并询问是先运行 `/gate-check` 还是改为执行完整 QA 流程。
- **最新记录为 FAIL、CONCERNS 或 NOT ASSESSED**：点名它并停止。
  在从未通过闸门的构建之上打首发日补丁，不算首发日
  补丁；那是迟到的发布闸门，且范围指向了错误的变更。
- 仅有 `project.stage: Release` **不能**确立这一点。阶段是对项目所处位置的主张；闸门记录才是它获得该位置的证据。

---

## Phase 2: 确定补丁范围

### Step 2a —— 分类未决缺陷是否纳入补丁

对每个未决缺陷，评估：

| 标准 | 是否纳入首发日？ |
|-----------|-------------------|
| S1 或 S2 严重程度 | 是 —— 若可安全修复则必须纳入 |
| P1 优先级 | 是 |
| 修复估算 < 4 小时 | 是 |
| 修复需要架构变更 | 否 —— 延后到 1.1 |
| 修复引入新的代码路径 | 否 —— 风险太高 |
| 修复仅为数据/配置（无代码变更） | 是 —— 风险极低 |
| 认证反馈要求 | 是 —— 平台批准所必需 |
| S3/S4 严重程度 | 仅在琐碎的配置修复时纳入；否则延后 |

### Step 2b —— 向用户呈现补丁范围

使用 `AskUserQuestion`：
- 提示："基于未决缺陷与认证反馈，这是拟定的首发日补丁范围。这样看是否正确？"
- 展示：纳入缺陷表（ID、严重程度、描述、估算工作量）
- 展示：延后缺陷表（ID、严重程度、延后原因）
- 选项：`[A] 批准此范围` / `[B] 调整 —— 我想添加或移除条目` / `[C] 不需要首发日补丁`

若选 [C]：输出 "不需要首发日补丁。请继续 `/launch-checklist`。" 停止。

### Step 2c —— 检查总范围

汇总估算工作量。若总量超过 1 天工作量：
> "⚠️ 补丁范围为 [N 小时] —— 超过安全的首发日窗口。考虑将较低优先级的条目延后到补丁 1.1。臃肿的首发日补丁引入的风险多于它消除的风险。"

使用 `AskUserQuestion` 确认继续或缩减范围。

---

## Phase 3: 回滚计划

在编写任何代码之前，定义回滚流程。这一点不容商量。

通过 `Agent` 启动 `release-manager`。请其产出一份回滚计划，涵盖：
- 如何在每个目标平台上回退到黄金母盘构建
- 平台特定的回滚约束（部分平台无法回滚认证构建）
- 由谁负责触发回滚
- 若发生回滚，需要向玩家做哪些沟通

呈现回滚计划。询问："我可以把这份回滚计划写入 `production/releases/rollback-plan-[version].md` 吗？"

在回滚计划写入之前，不要进入 Phase 4。

---

## Phase 4: 实施修复

对已批准范围内的每个代码修复，启动一个聚焦的实施循环：

1. 通过 `Agent` 启动 `lead-programmer`，提供：
   - 缺陷报告（精确复现步骤，以及已知时的根因）
   - 约束：仅最小可行修复，不清理
   - 受影响的文件（来自缺陷报告的 Technical Context 章节）

   它针对每个缺陷返回最小修复及其将改动的文件——不写入任何内容。

2. 对整组统一询问一次："我可以应用这些修复吗？[BUG-ID → 文件，每行一个]"。在此批准之前不做任何代码变更。

3. 同意后，将每个已批准的修复交回 `lead-programmer`（一次携带其计划的新 `Agent` 调用）实施，并用 `project.yaml` 中的 `commands.test` 运行定向测试，在运行器允许时收窄到受影响的套件——绝不凭记忆写运行器命令行。若 `commands.test` 未设置，说明该情况，并为该缺陷记录 `Tests: NOT RUN — commands.test unset`。

4. 通过 `Agent` 启动 `qa-tester` 验证：修复后该缺陷是否仍能复现？

对于仅配置/数据的修复：直接做变更（无需程序员代理）。先询问，点名文件与变更："我可以编辑 `[config file]` —— `[key]`：[old value] → [new value] 吗？" 确认值已变更，并重新运行任何相关的冒烟测试。

---

## Phase 5: 补丁 QA 闸门

这是轻量级 QA 流程——不是完整的 `/team-qa`。补丁在发布闸门时已通过 QA 批准；我们只是再次验证改动的区域。

通过 `Agent` 启动 `qa-lead`，提供：
- 所有改动文件的清单
- 已修复缺陷的清单（含 Phase 4 的验证状态）
- 受影响系统的冒烟检查范围

询问 qa-lead 判断：**定向冒烟检查是否足够，还是有任何修复触及需要更广泛回归的系统？**

运行所需的 QA 范围：
- **Targeted smoke check** —— 运行 `/smoke-check`（它不接受系统参数）
- **Broader regression** —— 在引擎的测试根（Godot 为 `tests/unit/` 与 `tests/integration/`，Unity 为 `Assets/Tests/`，Unreal 为 `Source/<Module>/Private/Tests/` —— `.trae/docs/directory-structure.md`）运行受影响系统的测试，使用 `project.yaml` 中的 `commands.test`，在运行器允许时收窄到受影响的套件——绝不凭记忆写运行器命令行。若 `commands.test` 未设置，更广泛的回归为 NOT ASSESSED；说明该情况。

QA 结论必须为 PASS 或 PASS WITH WARNINGS 才能继续。若为 FAIL：将失败的修复移出首发日补丁范围并延后到 1.1。

**若 QA 结论为 `NOT ASSESSED`，那不是通过。** `/smoke-check` 在
套件从未运行（无构建、无运行器，或无人确认的结果）时返回它。
不要据此继续，也不要把它重读为 PASS WITH WARNINGS：warnings
值意味着有人看了并发现了次要问题，而这个值意味着没人看过。
要么取得结果（结论会说明怎样才能让它可运行），要么把
修复延后到 1.1。首发日补丁会发布给每一位在首发日购买游戏的玩家，那是未验证变更最糟糕的受众。

---

## Phase 6: 生成补丁记录

```markdown
# Day-One Patch: [Game Name] v[version]

**Date prepared**: [date]
**Target release**: [launch date or "day of launch"]
**Base build**: [gold master tag or commit]
**Patch build**: [patch tag or commit]

---

## Patch Notes (Internal)

### Bugs Fixed
| BUG-ID | Severity | Description | Fix summary |
|--------|----------|-------------|-------------|
| BUG-NNNN | S[1-4] | [description] | [one-line fix] |

### Deferred to 1.1
| BUG-ID | Severity | Description | Reason deferred |
|--------|----------|-------------|-----------------|
| BUG-NNNN | S[1-4] | [description] | [reason] |

---

## QA Sign-Off

**QA scope**: [Targeted smoke / Broader regression]
**Verdict**: [PASS / PASS WITH WARNINGS / NOT ASSESSED]
**QA lead**: qa-lead agent
**Date**: [date]
**Warnings (if any)**: [list or "None"]
**Not assessed (if any)**: [what could not be checked, and why — or "None"]

---

## Rollback Plan

See: `production/releases/rollback-plan-[version].md`

**Trigger condition**: If [N] or more S1 bugs are reported within [X] hours of launch, execute rollback.
**Rollback owner**: [user / producer]

---

## Approvals Required Before Deploy

- [ ] lead-programmer: all fixes reviewed
- [ ] qa-lead: QA gate PASS confirmed
- [ ] producer: deployment timing approved
- [ ] release-manager: platform submission confirmed

---

## Player-Facing Patch Notes

[Draft for community-manager to review before publishing]

[list player-facing changes in plain language]
```

询问："我可以把这份补丁记录写入 `production/releases/day-one-patch-[version].md` 吗？"

---

## Phase 7: 后续步骤

补丁记录写入之后：

1. 运行 `/patch-notes` 生成面向玩家的补丁说明版本
2. 补丁上线后，对每个已修复缺陷运行 `/bug-report verify [BUG-ID]`
3. 对每个已验证的修复运行 `/bug-report close [BUG-ID]`
4. 在上线后 48–72 小时安排上线后复盘，对 `production/milestones/` 中的上线里程碑使用 `/retrospective [milestone-name]`

**若补丁后仍有任何 S1 缺陷未决：**
> "⚠️ S1 缺陷仍未关闭且未获修补。这些是已接受的风险。请将它们记录在回滚计划的触发条件中——若它们大规模出现，回滚可能比后续补丁更可取。"

使用 `AskUserQuestion`：
- 提示："首发日补丁完成。下一步是什么？"
- 选项：
  - `[A] 运行 /patch-notes —— 生成面向玩家的补丁说明`
  - `[B] 运行 /bug-report 记录部署后发现的问题`
  - `[C] 在此停止`

---

## 协作协议（Collaborative Protocol）

- **范围纪律就是一切**——抵制范围蔓延；每一次新增都会增加风险
- **回滚计划优先，始终如此**——没有回滚计划的补丁是不负责任的
- **延后不等于遗忘**——每个延后缺陷都列在记录的
  "Deferred to 1.1" 表中；之后运行 `/bug-triage` 将它们排入 1.1 冲刺
  （若项目没有冲刺计划，如默认 minimal 工作流，则排入简报的构建顺序）
- **玩家沟通是补丁的一部分**——`/patch-notes` 是必需产出，不是可选项