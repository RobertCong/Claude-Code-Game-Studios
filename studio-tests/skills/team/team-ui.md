# Skill Test Spec: /team-ui

## Skill Summary

为单个 UI 功能通过完整 UX 流水线编排 UI 团队。协调 ux-designer、ui-programmer、
art-director、引擎 UI 专家和 accessibility-specialist，历经五个结构化阶段：上下文收集 +
UX 规格（Phase 1a/1b）→ UX 评审闸门（Phase 1c）→ 视觉设计（Phase 2）→ 实现（Phase 3）→
并行评审（Phase 4）→ 打磨（Phase 5）。Phase 0 解析 `review_mode`、`automation` 和
`team.size`，技能在启动任何代理之前宣布活跃集——默认的 `individual` 启动 ui-programmer +
ux-designer，`small` 增加 accessibility-specialist + art-director，`studio` 增加引擎 UI
专家以及对抗性的 Phase 4 评审。Phase 1a 把它的五个输入各自报告为存在或 ABSENT，缺失的
`design/accessibility-requirements.md` 会以 `Accessibility: NOT ASSESSED` 向下传递。每个
阶段转换都使用 `AskUserQuestion`。把所有文件写入委派给子代理和子技能（`/ux-design`、
`ui-programmer`）。产出摘要报告，结论为 COMPLETE / BLOCKED，并交接至 `/ux-review`、
`/code-review`、`/team-polish`。

---

## Static Assertions (Structural)

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具备 ≥2 个阶段标题（Phase 1a 至 Phase 5 均存在）
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] File Write Protocol：子代理在有界例外之下写入（指定路径、`production/`、`docs/` 或
  `tests/` 下的新产出物、受门控的阶段），在边界外则先询问；子技能（`/ux-design`）写入前
  先询问；编排器不直接写文件；实现文件（代码、着色器、音频、资源）在其之外——每个代理列出
  其将创建或修改的文件，技能在写入任何文件之前就整组文件询问一次
- [ ] 为每个代理指定 `production/ui/[feature-name]/` 下的目标：`visual-design.md`
  （art-director，Phase 2）、`engine-notes.md`（引擎 UI 专家）、`review-[agent].md`
  （Phase 4 的每位评审者各一个文件）
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式为何，且不在阶段闸门处
  声称启动总监
- [ ] 结尾有下一步交接（引用 `/ux-review`、`/code-review`、`/team-polish`）
- [ ] 存在 Error Recovery Protocol 小节：确认指定产出物已落盘；立即上报 BLOCKED；始终产出
  部分报告；完整流程（surface → assess → options → partial report）见
  `.trae/docs/error-recovery-protocol.md`
- [ ] 在阶段转换处使用 `AskUserQuestion` 征求用户批准后再继续（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求启动任何代理之前有一行活跃集声明
- [ ] Phase 4 明确标记为并行（ux-designer、art-director、accessibility-specialist）
- [ ] UX 评审闸门（Phase 1c）定义为阻塞闸门——技能不得在未获 APPROVED 结论时进入 Phase 2，
  除非用户显式覆盖 NEEDS REVISION 或 NOT ASSESSED，且最终报告记录该覆盖
- [ ] Team Composition 列出全部五个角色（ux-designer、ui-programmer、art-director、
  引擎 UI 专家、accessibility-specialist）
- [ ] 引擎 UI 专家从 `project.yaml` 中的 `specialists.ui` 读取（回退到
  `.trae/docs/technical-preferences.md`），且 `specialists.ui: null` 视为未设置
- [ ] 引用交互模式库（`design/ux/interaction-patterns.md`）——ui-programmer 必须使用既有模式
- [ ] Phase 1a 在设计开始之前读取 `design/accessibility-requirements.md`

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 从 UX 规格到打磨的完整流水线成功

**测试夹具：**
- 已解析配置块：`review_mode: full`、`team.size: studio`、`automation: collaborative`
- `design/gdd/game-concept.md` 存在，含平台目标与目标受众
- `design/player-journey.md` 存在
- `design/ux/interaction-patterns.md` 存在，含相关模式
- `design/accessibility-requirements.md` 存在，含承诺层级（例如 Standard）
- `project.yaml` 中的 `engine.name` 为 Godot，`specialists.ui` 为 `godot-specialist`

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 在启动任何代理之前，用一行宣布 `team.size: studio` 的活跃集
2. Phase 1a——编排器读取 game-concept.md、player-journey.md、相关的 GDD UI 小节、
   interaction-patterns.md、accessibility-requirements.md；把每个输入报告为存在或 ABSENT；
   为 ux-designer 汇总一份简报
3. Phase 1b——调用 `/ux-design inventory-screen`（或直接启动 ux-designer）；使用
   `ux-spec.md` 模板产出 `design/ux/inventory-screen.md`；`AskUserQuestion` 在评审前确认
   规格
4. Phase 1c——调用 `/ux-review design/ux/inventory-screen.md`；返回 APPROVED；闸门通过，
   进入 Phase 2
5. Phase 2——启动 art-director；评审完整 UX 规格（而不只是线框图）；应用视觉处理；验证
   颜色对比度；产出含资源清单的视觉设计规格；`AskUserQuestion` 在 Phase 3 之前确认
6. Phase 3——先启动 `godot-specialist`（来自 `specialists.ui`）；为 ui-programmer 产出
   实现笔记；以 UX 规格 + 视觉规格 + 引擎笔记启动 ui-programmer；产出实现；若引入了新
   模式，则更新 interaction-patterns.md
7. Phase 4——并行启动 ux-designer、art-director、accessibility-specialist，各自被要求找出
   实现未满足其规格之处，而不是确认其相符（`studio` 的对抗性审查）；三者都在 Phase 5 之前
   返回结果
8. Phase 5——处理评审反馈；验证动画可跳过；通过音频事件系统确认 UI 音效；
   interaction-patterns.md 最终检查
9. 摘要报告：UX 规格状态、UX 评审结论、视觉设计状态、实现状态、无障碍合规、输入方式支持、
  模式库状态；结论：COMPLETE

**断言：**
- [ ] 在启动第一个代理之前，出现点名 `team.size: studio` 的活跃集行
- [ ] Phase 1a 读取全部五个来源，并在向 ux-designer 简报之前把每个来源列为存在或 ABSENT
- [ ] 在 Phase 2 之前检查 UX 评审闸门——未获 APPROVED 时 Phase 2 不开始
- [ ] Phase 2 的 art-director 评审完整规格，而不只是线框图
- [ ] 引擎 UI 专家取自 `specialists.ui`，并在 Phase 3 中先于 ui-programmer 启动
- [ ] ui-programmer 列出其将创建或修改的文件，且在就该组文件进行一次询问并得到肯定答复之前
  不写入任何文件
- [ ] Phase 4 的代理同时启动（ux-designer、art-director、accessibility-specialist）
- [ ] 在 `team.size: studio` 下，Phase 4 的提示词具有对抗性，且摘要报告说明对抗性审查已运行
- [ ] 所有文件写入都委派给子代理和子技能
- [ ] 最终摘要报告中结论为 COMPLETE
- [ ] 下一步包含 `/ux-review`、`/code-review`、`/team-polish`

---

### Case 2: UX 评审闸门 — 规格未通过评审；技能在实现前停止

**测试夹具：**
- 已解析配置块：`automation: collaborative`（任意 `team.size`——ux-designer 在每种规模下
  都活跃）
- Phase 1b 产出 `design/ux/inventory-screen.md`
- `/ux-review` 返回 NEEDS REVISION 结论，并标记具体关注项（例如手柄导航流程不完整、对比度
  低于最低要求）

**输入：** `/team-ui inventory screen`

**预期行为：**
1. Phase 1a + 1b 完成——UX 规格产出
2. Phase 1c——`/ux-review design/ux/inventory-screen.md` 返回 NEEDS REVISION
3. 技能不进入 Phase 2
4. 呈现 `AskUserQuestion`，含具体被标记的关注项和选项：
   - (a) 退回 ux-designer 处理问题并重新评审
   - (b) 接受风险并仍进入 Phase 2（有意识的决定）
5. 若用户选择 (a)：ux-designer 修订规格，重新运行 `/ux-review`；循环继续直到 APPROVED 或
   用户覆盖
6. 若用户选择 (b)：技能继续，并在最终报告中显式记录 NEEDS REVISION 说明
7. 技能不会悄悄越过闸门继续

**断言：**
- [ ] UX 评审结论为 NEEDS REVISION 时 Phase 2 不开始
- [ ] `AskUserQuestion` 在提供选项之前呈现具体被标记的关注项
- [ ] 用户必须做出有意识的覆盖选择——技能不假设覆盖
- [ ] 若用户接受风险，最终报告记录该覆盖：NEEDS REVISION 结论、仍未解决的关注项，以及
  用户选择继续
- [ ] 提供修订并重新评审的循环（而不只是单次失败）
- [ ] 技能不会在评审失败时丢弃已产出的 UX 规格

**Variant B — `/ux-review` 返回 NOT ASSESSED：**
- 夹具同上，但 `design/accessibility-requirements.md` 缺失，其他评审维度未发现缺口，因此
  `/ux-review` 返回 NOT ASSESSED（accessibility: no committed tier）
- 预期：Phase 2 不开始；`AskUserQuestion` 点名未能评估的维度及其缺失输入
  （`/ux-design accessibility`），并提供选项：产出该输入并重跑评审，或有意识地继续；若
  用户继续，最终报告记录 NOT ASSESSED 覆盖，且 Phase 4 仍报告
  `Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md
  absent)`

**断言（变体 B）：**
- [ ] 未经用户明确决定，NOT ASSESSED 时 Phase 2 不开始——它与 NEEDS REVISION 一样阻塞
- [ ] 提示词点名 `/ux-review` 无法评估的维度，以及能使其可检查的输入，而非规格修订
- [ ] 技能不会针对同一缺失输入重跑 `/ux-review` 并把结果当作新的
- [ ] 覆盖记录在最终报告中，含 NOT ASSESSED 结论和未评估维度

---

### Case 3: 无参数 — 显示用法指引

**测试夹具：**
- 任意项目状态

**输入：** `/team-ui`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法消息，说明必需参数（UI 功能描述）
3. 展示调用格式 `/team-ui [UI feature description] [--review full|lean|solo]` 并给出
   示例（`inventory screen`、`main menu`、`combat HUD`）
4. 技能退出，不启动任何子代理，也不读取任何项目文件

**断言：**
- [ ] 未提供参数时技能不启动任何子代理
- [ ] 用法消息展示完整的 argument-hint：
  `/team-ui [UI feature description] [--review full|lean|solo]`
- [ ] 至少展示一个有效调用示例
- [ ] 失败前不读取任何 UX 规格文件或 GDD
- [ ] 不显示结论（流水线从未启动）

---

### Case 4: 无障碍并行评审 — Phase 4 同时运行三条线

**测试夹具：**
- 已解析配置块：`review_mode: full`、`team.size: small`、`automation: collaborative`
- `design/ux/inventory-screen.md` 存在（APPROVED）
- 视觉设计规格完整
- 实现完整
- `design/accessibility-requirements.md` 承诺层级：Standard

**输入：** `/team-ui inventory screen`（从 Phase 3 完成处继续）

**预期行为：**
1. 确认实现完成后 Phase 4 开始
2. 同时发出三次 Agent 调用：ux-designer、art-director、accessibility-specialist
3. 每条线独立运作：
   - ux-designer：验证实现与线框图相符，测试仅键盘和仅手柄导航，检查无障碍功能是否生效
   - art-director：在最低和最高支持分辨率下验证与艺术圣经的视觉一致性
   - accessibility-specialist：对照 `design/accessibility-requirements.md` 中的 Standard
     无障碍层级进行审计；任何违规都标记为阻塞项
4. 技能等待全部三个结果，才进入 Phase 5
5. 在 Phase 5 开始之前，`AskUserQuestion` 呈现全部三个评审结果

**断言：**
- [ ] 三次 Agent 调用都在等待任何结果之前发出（并行，而非顺序）
- [ ] Phase 4 的三个代理全部返回之前，Phase 5 不开始
- [ ] accessibility-specialist 显式读取 `design/accessibility-requirements.md` 以获取承诺
  层级
- [ ] 无障碍违规标记为 BLOCKING（而不仅是建议性）
- [ ] `AskUserQuestion` 在 Phase 5 批准前一起展示三条评审线的结果
- [ ] Phase 4 任一代理的输出都不作为另一个 Phase 4 代理的输入

---

### Case 5: 缺少交互模式库 — 技能记录缺口而不杜撰模式

**测试夹具：**
- 已解析配置块：`automation: collaborative`（任意 `team.size`）
- `design/ux/interaction-patterns.md` 不存在
- 其他所有必需文件都存在

**输入：** `/team-ui settings menu`

**预期行为：**
1. Phase 1a——编排器尝试读取 `design/ux/interaction-patterns.md`；文件未找到
2. 技能上报缺口："interaction-patterns.md does not exist — no existing patterns to
   reuse"
3. 呈现 `AskUserQuestion`，选项为：
   - (a) 先运行 `/ux-design patterns` 建立模式库，然后继续
   - (b) 在没有模式库的情况下继续——ui-programmer 把创建的所有模式视为新模式，并在完成时
     把每个模式添加到一个新的 `design/ux/interaction-patterns.md`
4. 技能不会从其他来源杜撰或假设模式
5. 若用户选择 (b)：明确指示 ui-programmer 把创建的所有模式视为新模式，并在完成时把每个模式
   添加到一个新的 `design/ux/interaction-patterns.md`
6. 最终报告记录 interaction-patterns.md 已创建（若用户跳过则仍缺失）

**断言：**
- [ ] 技能不会悄悄忽略缺失的模式库
- [ ] 技能不会仅凭功能名称或 GDD 猜测来杜撰模式
- [ ] `AskUserQuestion` 提供 "create pattern library first" 选项（引用
  `/ux-design patterns`）
- [ ] 若用户在没有模式库的情况下继续，ui-programmer 被告知把所有模式视为新模式
- [ ] 最终报告记录模式库状态（已创建 / 缺失 / 已更新）
- [ ] 技能不会整体失败——记录缺口并给用户选择

---

### Case 6: `review_mode` 不门控任何内容 — art-director 在 lean 和 solo 下仍在名册中

**测试夹具：**
- `project.yaml`：运行 A–C 为 `team.size: small`，运行 D 为 `team.size: individual`
  （固定：`small` 是包含 art-director 和 accessibility-specialist 的最小规模）；
  `modes.review_mode` 未设置，因此每次运行的 `--review` 值决定
- `design/gdd/game-concept.md`、`design/player-journey.md`、
  `design/ux/interaction-patterns.md` 和 `design/accessibility-requirements.md`
  （层级 Standard）存在；`/ux-review` 返回 APPROVED
- 运行 A：`/team-ui inventory screen --review full`。运行 B：`--review lean`。运行 C：
  `--review solo`。运行 D：`individual` 下的 `--review lean`

**预期行为：**
1. 运行 A–C 以相同的 `team.size: small` 活跃集行开头：
   ui-programmer + ux-designer + accessibility-specialist + art-director
2. 在三次运行中，art-director 都为 Phase 2（视觉设计）和 Phase 4 评审而启动，
   accessibility-specialist 为 Phase 4 而启动——评审模式不会跳过团队成员
3. 任何运行都不在任何阶段启动 CD-、TD-、PR- 或 AD-PHASE-GATE："no phase below spawns
   CD-, TD-, PR- or AD-PHASE-GATE, at any `review_mode`"
4. 运行 D（`individual`）在 `Not spawned this run:` 下点名 art-director 和
   accessibility-specialist；它们的工作通过 ui-programmer 和 ux-designer 咨询。造成这一点
   的是规模，而非 `lean`

**断言：**
- [ ] 运行 A（`full`）、运行 B（`lean`）和运行 C（`solo`）中，art-director 都在 Phase 2
  和 Phase 4 启动
- [ ] Phase 4 评审在三次运行中都并行启动相同的三个代理
- [ ] 任何运行都不启动总监闸门（CD-、TD-、PR- 或 AD-PHASE-GATE）
- [ ] 运行 A–C 显示相同的活跃集、阶段和询问
- [ ] 运行 D 中不启动 art-director，且输出把这一点归因于 `team.size: individual`，而非
  `lean`

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual):
  ui-programmer + ux-designer` 行和 `Not spawned this run:` 行开头，后者点名 art-director、
  accessibility-specialist 和引擎 UI 专家——且都在启动任何代理之前
- [ ] 在 `collaborative` 模式下，每个阶段转换都使用 `AskUserQuestion`——用户批准后流水线
  才推进
- [ ] UX 评审闸门（Phase 1c）为阻塞式——未获 APPROVED，或用户未显式覆盖 NEEDS REVISION 或
  NOT ASSESSED 结论（且最终报告记录该覆盖），Phase 2 不能开始
- [ ] 当 `design/accessibility-requirements.md` 缺失时，Phase 4 报告
  `Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md
  absent)`，且绝不报告无障碍闸门已通过
- [ ] 未配置引擎时，跳过引擎 UI 专家，且运行输出记录
  `Engine validation: NOT ASSESSED — no engine configured`
- [ ] 当无障碍闸门或引擎验证为 NOT ASSESSED 时，结论逐一点名
  （`COMPLETE — [accessibility | engine validation] NOT ASSESSED ([reason])`）——绝不
  只是 COMPLETE
- [ ] 所有文件写入都委派给子代理和子技能——编排器不直接调用 Write 或 Edit
- [ ] Phase 4 的代理按技能规格并行启动
- [ ] 遵循 Error Recovery Protocol：surface → assess → offer options → partial report
- [ ] 即使代理处于 BLOCKED，也始终产出部分报告
- [ ] 结论为 COMPLETE / BLOCKED 之一
- [ ] 结尾给出下一步：`/ux-review`、`/code-review`、`/team-polish`

---

## Coverage Notes

- HUD 专属路径（`/ux-design hud` + `hud-design.md` 模板 + Phase 5 的视觉预算检查）未在此
  单独测试；它共享相同的阶段结构，但使用不同模板。
- interaction-patterns.md 的 "Update in place" 路径（实现期间新增模式）由 Case 1 的 Phase 3
  隐式检验——使用已知新模式的专门夹具会增强覆盖。
- 引擎 UI 专家不可用（未配置引擎）在 Protocol Compliance 中作了断言，但未给专门夹具；缺失
  accessibility-requirements 文件由 Case 2 变体 B 在 Phase 1c 闸门处检验。
- NEEDS REVISION 和 NOT ASSESSED 覆盖（Case 2 两个变体）必须记录在最终报告中；这一点已作
  断言，但未进一步测试其下游影响。
- `/ux-review` 返回 MAJOR REVISION NEEDED 结论的情形未立用例。
