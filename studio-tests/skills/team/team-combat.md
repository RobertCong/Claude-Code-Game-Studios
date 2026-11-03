# Skill Test Spec: /team-combat

## Skill Summary

为单个战斗功能端到端编排完整的战斗团队流水线。协调 game-designer、gameplay-programmer、
ai-programmer、technical-artist、sound-designer、主要引擎专家（engine specialist）以及
qa-tester，历经六个结构化阶段：设计 → 架构（含引擎专家验证）→ 实现（并行）→
集成 → 验证 → 签核。Phase 0 解析 `review_mode`、`automation`、`team.size` 和
`workflow`（`workflow` 决定 GDD 的体量）；完整流水线在 `team.size: small` 及以上运行，
而默认的 `individual` 只运行 gameplay-programmer（仅在标记了 AI 工作时才运行
ai-programmer），并在 Phase 1 之前宣布这一收缩。每个阶段转换都使用
`AskUserQuestion`，实现前设有显式的 [A]/[B]/[C] 架构闸门。每个代理都写入技能
路径表中指定的目标；编排器唯一的写入是 GDD，即 `design/gdd/[feature].md`，
它在 game-designer 的草稿经 "May I write" 批准后写入。产出摘要报告，结论为
COMPLETE / NEEDS WORK / BLOCKED，并交接至 `/code-review`、
`/balance-check` 和 `/team-polish`。

---

## Static Assertions (Structural)

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具备 ≥2 个阶段标题（Phase 1 至 Phase 6 均存在）
- [ ] 包含结论关键词：COMPLETE、NEEDS WORK、BLOCKED
- [ ] 包含 "File Write Protocol"——子代理草稿与 QA 产出物留在有界例外之内，而实现文件
  （代码根目录、`assets/`）在其之外，作为一组一次性询问；编排器唯一的写入是
  `design/gdd/[feature].md`，在其自身的 "May I write" 询问之后进行，因为 `design/`
  不在例外之内
- [ ] 为每个阶段命名具体目标：`production/combat/[feature]-gdd-draft.md`
  （game-designer 对 `design/gdd/[feature].md` 的草稿）、
  `docs/architecture/[feature]-sketch.md`、`docs/architecture/[feature]-engine-notes.md`、
  `production/qa/test-cases/[feature]-cases.md`、`production/qa/bugs/BUG-[NNNN].md`
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式为何，且不在阶段闸门处
  声称启动总监
- [ ] 结尾有下一步交接（引用 `/code-review`、`/balance-check`、`/team-polish`）
- [ ] 存在 Error Recovery Protocol 小节：在把某个阶段视为完成前，确认指定产出物已落盘；
  立即上报 BLOCKED；始终产出部分报告；完整流程（surface → assess → options → partial
  report）见 `.trae/docs/error-recovery-protocol.md`
- [ ] 在阶段转换处使用 `AskUserQuestion` 征求用户批准后再继续（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求 Phase 1 之前有一行活跃集（active set）声明
- [ ] Phase 0 解析 `workflow`，Phase 1 据此确定 GDD 体量：`full` 下为 `## Summary` 加全部
  8 个小节；`standard` 下为 5 个标准小节，数值规则再加 Formulas；`minimal` 下为可选
  （以游戏简报为记录）
- [ ] Phase 3 明确标记为并行（gameplay-programmer、ai-programmer、technical-artist、sound-designer）
- [ ] Phase 2 包含启动主要引擎专家，依据 `project.yaml` 中的 `engine.name` 推导
  （Godot → `godot-specialist`），回退到 `.trae/docs/technical-preferences.md` 中的
  Primary 行
- [ ] Team Composition 列出全部七个角色（game-designer、gameplay-programmer、ai-programmer、
  technical-artist、sound-designer、引擎专家、qa-tester）

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 所有代理成功，完整流水线运行至完成

**测试夹具：**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`workflow: full`
- `design/gdd/game-concept.md` 存在且有内容
- `project.yaml` 中的 `engine.name` 为 Godot
- 所请求的战斗功能尚无 GDD
- 该功能涉及 NPC 反应（敌人招架并反击），因此标记了 AI 工作

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 在启动任何代理之前，用一行宣布 `team.size: small` 的活跃集（完整 Team Composition 流水线）
2. Phase 1——启动 game-designer；将设计起草到
   `production/combat/parry-riposte-gdd-draft.md`，覆盖全部 8 个必需小节（概览、玩家幻想、
   规则、公式、边界情况、依赖、调参旋钮、验收标准）；`AskUserQuestion` 呈现草稿并询问
   "May I write the design document to `design/gdd/parry-riposte.md`?"；批准后由编排器写入
3. Phase 2——启动 gameplay-programmer + ai-programmer；产出包含类结构、接口和文件清单的
   架构草图（`docs/architecture/parry-riposte-sketch.md`）；随后启动 `godot-specialist`
   验证惯用写法（`docs/architecture/parry-riposte-engine-notes.md`）；引擎专家的输出被纳入
4. `AskUserQuestion` 询问 "Architecture sketch complete. Approve to proceed with parallel
   implementation."，选项为 [A] Proceed / [B] Revise the architecture first / [C] Stop here
   ——实现代理仅在选择 [A] 时才启动
5. Phase 3——并行启动 gameplay-programmer、ai-programmer、technical-artist、sound-designer；
   三个实现代理返回其将创建或修改的文件，一次 `AskUserQuestion` 就整组文件征求同意，
   得到肯定答复后才写入；sound-designer 将事件清单起草到
   `production/combat/parry-riposte-audio-events.md`；四者全部返回后 Phase 4 才开始
6. Phase 4——集成把 Phase 3 的全部输出串联起来；验证调参旋钮为数据驱动；`AskUserQuestion`
   在 Phase 5 前确认集成
7. Phase 5——启动 qa-tester；依据验收标准编写测试用例到
   `production/qa/test-cases/parry-riposte-cases.md`；验证边界情况；对照预算检查性能影响
8. Phase 6——产出摘要报告：设计状态、每位团队成员的实施状态、测试结果、未决问题；
   结论：COMPLETE
9. 列出下一步：`/code-review`、`/balance-check`、`/team-polish`

**断言：**
- [ ] 在启动第一个代理之前，出现点名 `team.size: small` 的活跃集行
- [ ] 每个阶段转换处都调用 `AskUserQuestion`（至少 Phase 3 前和 Phase 5 前）
- [ ] Phase 3 前的闸门提供 [A] Proceed / [B] Revise / [C] Stop，且未选择 [A] 时不启动任何实现代理
- [ ] Phase 3 的代理被同时启动——gameplay-programmer、ai-programmer、technical-artist、
  sound-designer 之间没有顺序依赖
- [ ] 引擎专家在 Phase 3 开始之前的 Phase 2 运行（输出被纳入架构）
- [ ] 每个代理的提示词都从路径表中点名其目标；没有子代理写入 `design/` 之下
- [ ] 在就 Phase 3 整组文件进行一次询问之前，不写入任何实现文件（代码根目录、`assets/`）
- [ ] 在 Phase 1 的 "May I write" 批准之前，`design/` 下不写入任何内容，且编排器唯一的
  Write 是 `design/gdd/parry-riposte.md`
- [ ] 最终报告中出现结论 COMPLETE
- [ ] 下一步包含 `/code-review`、`/balance-check`、`/team-polish`
- [ ] 设计文档覆盖全部 8 个必需 GDD 小节

---

### Case 2: 代理阻塞 — 某个子代理在流水线中途返回 BLOCKED

**测试夹具：**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `design/gdd/parry-riposte.md` 存在（Phase 1 已完成）
- ai-programmer 代理返回 BLOCKED，因为不存在 AI 系统架构 ADR（ADR 状态为 Proposed）

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. Phase 1——找到设计文档；game-designer 确认其有效；该阶段获批
2. Phase 2——gameplay-programmer 完成架构草图；ai-programmer 返回 BLOCKED："ADR for AI
   behavior system is Proposed — cannot implement until ADR is Accepted"
3. 触发 Error Recovery Protocol："ai-programmer: BLOCKED — AI behavior ADR is Proposed"
4. 呈现 `AskUserQuestion`，选项为：(a) 跳过 ai-programmer 并记录缺口；(b) 以更窄范围重试；
   (c) 停在这里，先运行 `/architecture-decision`
5. 若用户选择 (a)：Phase 3 仅由 gameplay-programmer、technical-artist、sound-designer 继续；
   ai-programmer 的缺口在部分报告中记录
6. 产出最终报告：记录部分实现，ai-programmer 小节标记为 BLOCKED，总体结论：BLOCKED

**断言：**
- [ ] 在任何依赖阶段继续之前，出现 BLOCKED 的上报消息
- [ ] `AskUserQuestion` 至少提供三个选项：跳过 / 重试 / 停止
- [ ] 产出部分报告——已完成代理的工作不被丢弃
- [ ] 只要任一代理未解决，总体结论就是 BLOCKED（而非 COMPLETE）
- [ ] 阻塞原因引用该 ADR，并建议 `/architecture-decision`
- [ ] 编排器不会在被阻塞的依赖上悄悄继续

---

### Case 3: 无参数 — 显示清晰的用法指引

**测试夹具：**
- 任意项目状态

**输入：** `/team-combat`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法消息，说明必需参数（战斗功能描述）
3. 展示调用格式 `/team-combat [combat feature description] [--review full|lean|solo]`
   并给出示例（`melee parry system`、`ranged weapon spread`）
4. 技能退出，不启动任何子代理

**断言：**
- [ ] 未提供参数时技能不启动任何子代理
- [ ] 用法消息展示完整的 argument-hint：
  `/team-combat [combat feature description] [--review full|lean|solo]`
- [ ] 错误消息至少包含一个有效调用示例
- [ ] 除检测缺失参数所需之外，不读取任何文件
- [ ] 不显示结论（流水线从未运行）

---

### Case 4: 并行阶段验证 — Phase 3 代理同时运行

**测试夹具：**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `design/gdd/parry-riposte.md` 存在、完整，并标记了敌人 AI 反应
- 架构草图已按选项 [A] 批准
- 引擎专家已验证架构

**输入：** `/team-combat parry and riposte system`（从 Phase 2 完成处继续）

**预期行为：**
1. 架构批准后 Phase 3 开始
2. 全部四次 Agent 调用——gameplay-programmer、ai-programmer、technical-artist、
   sound-designer——都在等待任何结果之前发出
3. 技能等待全部四个代理完成，才进入 Phase 4
4. 若任一代理提前完成，技能也不会在四个全部返回前开始 Phase 4

**断言：**
- [ ] 四次 Agent 调用在同一批次中发出（彼此之间没有顺序等待）
- [ ] Phase 3 的四个代理全部返回结果之前，Phase 4 不开始
- [ ] 技能不会把一个 Phase 3 代理的输出作为另一个 Phase 3 代理的输入（它们相互独立）
- [ ] Phase 4 的集成步骤引用了全部四个 Phase 3 代理的结果

---

### Case 5: 架构阶段的引擎路由 — 引擎专家从配置解析

**测试夹具（变体 A——已配置引擎）：**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `project.yaml` 中的 `engine.name` 为 Godot；引擎版本固定在
  `docs/engine-reference/godot/VERSION.md`
- gameplay-programmer 产出的架构草图可用，且编排器已读取

**测试夹具（变体 B——未配置引擎）：**
- 同变体 A，但 `project.yaml` 中的 `engine.name` 未设置，且
  `.trae/docs/technical-preferences.md` 没有 Primary 引擎专家（显示
  `[TO BE CONFIGURED]`）

**输入：** `/team-combat parry and riposte system`

**预期行为（变体 A）：**
1. Phase 2——gameplay-programmer 产出架构草图
2. 技能从 `engine.name` 推导主要引擎专家（Godot → `godot-specialist`）；仅在
   `engine.name` 缺失时才查阅 `technical-preferences.md`
3. 引擎专家以架构草图的精炼简报（而非编排器已读过的文档路径）启动，并被问及 Phase 2
   的三个问题：惯用的类/节点结构、应优先采用的引擎原生系统、固定引擎版本中已弃用或发生
   变更的 API
4. 引擎专家将笔记写入 `docs/architecture/parry-riposte-engine-notes.md`；编排器在把该步骤
   视为完成前检查文件存在
5. 编排器在把 Phase 2 结果呈现给用户之前，将引擎笔记纳入架构
6. `AskUserQuestion` 架构闸门同时包含引擎专家的笔记和架构草图

**预期行为（变体 B）：**
1. Phase 2——gameplay-programmer 产出架构草图
2. 不启动引擎专家，也不预期引擎笔记文件
3. 运行输出记录 `Engine validation: NOT ASSESSED — no engine configured (engine.name
   unset in project.yaml)`
4. 架构闸门仍然运行；它呈现草图，但不将其描述为已通过引擎验证
5. 运行完成时，结论为 `COMPLETE — engine validation NOT ASSESSED (no engine configured)`

**断言：**
- [ ] 引擎专家的代理类型从 `engine.name` 推导（回退到 `technical-preferences.md`）——而非
  硬编码（变体 A）
- [ ] 因为编排器已读取草图，引擎专家的简报内联携带相关草图内容，而不是草图路径（变体 A）
- [ ] 引擎专家对照固定引擎版本检查已弃用或变更的 API（变体 A）
- [ ] 引擎专家的输出在 Phase 3 开始前被纳入（而非跳过或单独附加）（变体 A）
- [ ] 不启动引擎专家，且运行输出记录 `Engine validation: NOT ASSESSED — no engine
  configured`——跳过从不静默（变体 B）
- [ ] 没有专家运行时，绝不把架构描述为已通过引擎验证（变体 B）
- [ ] 运行完成时，其结论写作 `COMPLETE — engine validation NOT ASSESSED ([reason])`——
  绝不只是 COMPLETE（变体 B）

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual):
  gameplay-programmer` 行和 `Not spawned this run:` 行开头，后者点名 game-designer、
  technical-artist、sound-designer、引擎专家和 qa-tester（除非标记了 AI 工作，否则还包括
  ai-programmer）——且都在启动任何代理之前
- [ ] 在 `collaborative` 模式下，每个阶段转换都使用 `AskUserQuestion`——用户批准后流水线才推进
- [ ] 子代理写入通过 Agent 委派——草稿与 QA 产出物在有界例外之内，实现文件仅在就整组文件
  进行一次询问之后写入；编排器只写 `design/gdd/[feature].md`，且在 "May I write" 批准之后
- [ ] 遵循 Error Recovery Protocol：surface → assess → offer options → partial report
- [ ] 指定产出物在磁盘上缺失的阶段被视为失败，而非完成
- [ ] Phase 3 的代理按技能规格并行启动
- [ ] 即使代理处于 BLOCKED，也始终产出部分报告
- [ ] 结论为 COMPLETE / NEEDS WORK / BLOCKED 之一
- [ ] 输出结尾给出下一步：`/code-review`、`/balance-check`、`/team-polish`
- [ ] 在 `team.size: studio` 下，主要引擎专家的提示词允许其子专家；Phase 5 的 qa-tester
  被要求找出该功能如何失败，而不是确认它能工作；报告说明对抗性审查已运行；低于 `studio`
  时两项附加均不出现

---

## Coverage Notes

- NEEDS WORK 结论路径（qa-tester 在 Phase 5 发现失败）未在此单独测试；它遵循与 Case 2
  相同的错误恢复与部分报告协议。
- "Retry with narrower scope" 错误恢复选项在断言中列出，但其完整的递归行为
  （通过 `/create-stories` 拆分）由 `/create-stories` 规格覆盖。
- Phase 4 的集成逻辑（串联玩法、AI、VFX、音频）由正常路径用例隐式验证；专门的集成测试
  需要夹具代码文件。
- 引擎专家不可用（未配置引擎）由 Case 5 变体 B 覆盖。
- `studio` 的附加项（引擎子专家、对抗性评审轮）在 Protocol Compliance 中作了断言，但未
  单独立用例。
