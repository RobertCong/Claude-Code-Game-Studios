# Skill Test Spec: /team-level

## Skill Summary

为单个关卡或区域编排完整的关卡设计团队。协调 narrative-director、world-builder、
level-designer、systems-designer、art-director、accessibility-specialist 和 qa-tester，
历经五个步骤：叙事 + 视觉方向并行（Step 1）、布局（Step 2）、系统（Step 3）、制作概念 +
无障碍并行（Step 4）以及 QA 规划（Step 5）。Phase 0 解析 `review_mode`、`automation` 和
`team.size`，技能在 Step 1 之前宣布活跃集——`individual` 只启动 level-designer，`small`
增加 systems-designer + art-director + qa-tester，`studio` 增加 narrative-director、
world-builder 和 accessibility-specialist。编排器自行汇编所有团队输出，并且仅在通过
`AskUserQuestion` 询问 "May I write…?" 之后写入 `design/levels/[level-name].md`；各代理
的产出物由子代理在有界写入例外之下写入。每个步骤闸门都使用 `AskUserQuestion`。产出摘要
报告，结论为 COMPLETE / BLOCKED，并交接至 `/design-review`、`/dev-story`、`/qa-plan`。

---

## Static Assertions (Structural)

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个阶段/步骤标题（Step 1 至 Step 5 均存在）
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] File Write Protocol：各代理的产出物由子代理在有界例外之下写入（指定路径、`production/`、
  `docs/` 或 `tests/` 下的新产出物、受门控的步骤）；唯一例外是汇编后的关卡文档，由编排器在
  其自身的 "May I write …?" 提示之后自行写入
- [ ] 为每个代理指定 `production/levels/[level-name]/` 下的目标——`narrative.md`、
  `lore.md`、`visual-direction.md`、`layout.md`、`systems.md`、`production-concepts.md`、
  `accessibility.md`——以及 qa-tester 的
  `production/qa/test-cases/[level-name]-cases.md`
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式为何，且不在阶段闸门处
  声称启动总监
- [ ] 结尾有下一步交接（引用 `/design-review`、`/dev-story`、`/qa-plan`）
- [ ] 存在 Error Recovery Protocol 小节：在把某步骤视为完成前，确认指定产出物已落盘；立即
  上报 BLOCKED；始终产出部分报告；完整流程（surface → assess → options → partial report）
  见 `.claude/docs/error-recovery-protocol.md`
- [ ] 在步骤转换处使用 `AskUserQuestion` 征求用户批准后再继续（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求 Step 1 之前有一行活跃集声明
- [ ] Step 1 明确并行启动 narrative-director、world-builder 和 art-director
- [ ] Step 4 明确标记为并行（art-director 和 accessibility-specialist 同时运行），并等待两者
- [ ] 上下文收集读取：`design/gdd/game-concept.md`（或 `design/game-brief.md`）、
  `design/gdd/game-pillars.md`、`design/levels/`、`design/narrative/` 以及相关世界构建文档
- [ ] `## How to Delegate` 列出全部七个角色（narrative-director、world-builder、
  level-designer、systems-designer、art-director、accessibility-specialist、qa-tester）
- [ ] accessibility-specialist 的输出包含严重度评级（BLOCKING / RECOMMENDED / NICE TO HAVE）
- [ ] 最终关卡设计文档保存到 `design/levels/[level-name].md`，其中 `[level-name]` 是参数
  经 slug 化——小写、空格 → 连字符——相邻区域路径使用同一规则

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 所有团队成员产出输出，文档汇编并保存

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- `design/gdd/game-concept.md` 存在且有内容
- `design/gdd/game-pillars.md` 存在
- `design/levels/` 目录存在（可能包含其他关卡文档）
- `design/narrative/` 目录存在，含相关叙事文档
- 森林区域的世界构建文档存在

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 在启动任何代理之前，用一行宣布 `team.size: studio` 的活跃集
2. 上下文收集——编排器读取 game-concept.md、game-pillars.md、`design/levels/` 中的既有
   关卡文档、`design/narrative/` 中的叙事文档，以及森林区域的世界构建文档
3. Step 1——narrative-director、world-builder 和 art-director 一起启动（三次 Agent 调用
   都在等待任何结果之前发出）：叙事目的与情感弧线；传说上下文与世界规则；视觉主题目标、
   光照氛围、形状语言和地标；`AskUserQuestion` 在 Step 2 之前呈现全部三个输出
4. Step 2——以 Step 1 的输出启动 level-designer，并把 art-director 的视觉目标作为显式
   约束；设计空间布局、节奏曲线、遭遇、谜题、入口/出口；编排器在 `design/levels/` 中检查
   所引用的每个相邻区域；`AskUserQuestion` 在 Step 3 之前确认布局
5. Step 3——启动 systems-designer：敌人构成、战利品表、难度平衡、区域专属机制、资源分布；
   `AskUserQuestion` 在 Step 4 之前确认系统
6. Step 4——art-director（地点专属制作概念）和 accessibility-specialist 并行启动；每个
   无障碍关注项评级为 BLOCKING / RECOMMENDED / NICE TO HAVE；编排器等待两者；
   `AskUserQuestion` 在 Step 5 之前呈现两个输出
7. Step 5——启动 qa-tester：关键路径的测试用例、边界/极端情况（流程中断、软锁）、试玩
   测试清单、验收标准
8. 编排器自行把所有团队输出汇编到关卡设计模板中——不重新启动 level-designer 来做——随后
   通过 `AskUserQuestion` 询问："May I write the compiled level design to
   `design/levels/forest-dungeon.md`?"，批准后写入
9. 摘要报告：区域概览、遭遇数、预估资源清单、叙事节拍、跨团队依赖、未解决的跨关卡依赖、
   带解决状态的无障碍关注项；结论：COMPLETE
10. 列出下一步：`/design-review design/levels/forest-dungeon.md`、`/dev-story`、`/qa-plan`

**断言：**
- [ ] 在启动第一个代理之前，出现点名 `team.size: studio` 的活跃集行
- [ ] 在启动任何代理之前，上下文收集期间读取全部五个来源
- [ ] Step 1 中 narrative-director、world-builder 和 art-director 的 Agent 调用并行发出，
  且三者都在 Step 2 之前完成
- [ ] level-designer 的简报把 art-director 在 Step 1 的视觉目标作为约束携带
- [ ] 每个步骤闸门都调用 `AskUserQuestion`（至少：Step 1、Step 2、Step 3、Step 4 之后）
- [ ] Step 4 的代理（art-director、accessibility-specialist）同时启动
- [ ] 汇编后的关卡文档由编排器写入，而非重新启动的代理，且仅在其自身的 "May I write" 批准
  之后
- [ ] 关卡文档保存到 `design/levels/forest-dungeon.md`（由参数 slug 化而来）
- [ ] 最终摘要报告中结论为 COMPLETE
- [ ] 下一步包含 `/design-review`、`/dev-story`、`/qa-plan`
- [ ] 摘要报告包含：区域概览、遭遇数、预估资源清单、叙事节拍

---

### Case 2: 代理阻塞（world-builder）— 产出部分报告并记录缺口

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- `design/gdd/game-concept.md` 存在
- 森林区域的世界构建文档不存在
- world-builder 代理返回 BLOCKED："No world-building docs found for the forest region —
  cannot provide lore context"

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集完成
2. Step 1——narrative-director 和 art-director 成功完成；world-builder 返回 BLOCKED
3. 触发 Error Recovery Protocol："world-builder: BLOCKED — no world-building docs for
   forest region"
4. 呈现 `AskUserQuestion`，选项为：
   - (a) 跳过 world-builder 并在最终报告中记录缺口
   - (b) 以更窄范围重试（world-builder 只聚焦于能从 game-concept.md 推断的内容）
   - (c) 停在这里，先创建世界构建文档
5. 若用户选择 (a)：流水线在没有传说基础的情况下继续 Step 2–5；缺失的世界构建上下文作为
   缺口列入最终报告
6. 若 world-builder 仍未解决，最终报告把 world-builder 小节标记为 BLOCKED，总体结论为
   BLOCKED

**断言：**
- [ ] world-builder 失败时立即上报 BLOCKED——在未获用户输入的情况下不直接进入 Step 2
- [ ] `AskUserQuestion` 至少提供三个选项（跳过 / 重试 / 停止）
- [ ] 产出部分报告——narrative-director 和 art-director 已完成的工作不被丢弃
- [ ] 缺失的世界构建上下文在最终报告中作为缺口点名
- [ ] world-builder 仍未解决时，总体结论为 BLOCKED（而非 COMPLETE）
- [ ] 不代 world-builder 写入任何内容——协议选项是 "skip this agent and note the gap"
  （`.claude/docs/error-recovery-protocol.md`），而非替代传说

---

### Case 3: 无参数 — 显示用法指引

**测试夹具：**
- 任意项目状态

**输入：** `/team-level`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法消息，说明必需参数（要设计的关卡名称或区域）
3. 展示调用格式 `/team-level [level name or area to design] [--review full|lean|solo]`
   并给出示例（`forest temple`、`tutorial village`、`final boss arena`）
4. 技能退出，不读取任何项目文件，也不启动任何子代理

**断言：**
- [ ] 未提供参数时技能不启动任何子代理
- [ ] 用法消息展示完整的 argument-hint：
  `/team-level [level name or area to design] [--review full|lean|solo]`
- [ ] 至少展示一个有效调用示例
- [ ] 失败前不读取任何 GDD 或关卡文件
- [ ] 不显示结论（流水线从未启动）

---

### Case 4: 无障碍评审闸门 — 阻塞性关注项在签核前上报

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- Step 1–3 成功完成
- `design/accessibility-requirements.md` 承诺层级：Standard
- accessibility-specialist（Step 4，并行）标记一个 BLOCKING 关注项：穿过森林地牢的关键
  路径要求玩家仅凭颜色区分两种环境危害（毒池与浅水）——没有形状、图标或音频提示加以区分

**输入：** `/team-level forest dungeon`

**预期行为：**
1. Step 1–3 完成；Step 4 并行阶段开始
2. accessibility-specialist 返回：BLOCKING 关注项——"Critical path hazard distinction
   relies on color only (toxic pools vs. shallow water). Shape, icon, or audio cue
   required per Standard accessibility tier."
3. art-director 返回 Step 4 输出（完成）
4. 技能通过 `AskUserQuestion` 呈现两个 Step 4 结果——BLOCKING 关注项被突出强调
5. `AskUserQuestion` 提供：
   - (a) 退回 level-designer + art-director，在 Step 5 之前重新设计被标记的元素
   - (b) 记录为已知无障碍缺口，继续 Step 5，并在最终报告中显式记录该关注项
6. 在用户确认该 BLOCKING 关注项之前，技能不进入 Step 5
7. 无论用户如何选择，最终摘要都列出该无障碍关注项及其解决状态

**断言：**
- [ ] BLOCKING 无障碍关注项不作为建议性事项处理——它作为阻塞项上报
- [ ] `AskUserQuestion` 呈现具体的关注项文本（而不只是 "accessibility issue found"）
- [ ] 用户确认 BLOCKING 关注项之前，Step 5（qa-tester）不开始
- [ ] 提供修订路径：可在继续前退回 level-designer + art-director
- [ ] 最终报告包含该无障碍关注项及其解决状态
- [ ] accessibility-specialist 阻塞时，art-director 已完成的输出不被丢弃

---

### Case 5: 循环关卡引用 — 标记相邻区域依赖

**测试夹具：**
- 已解析配置块：`automation: collaborative`（任意 `team.size`——level-designer 在每种
  规模下都活跃）
- Step 1–3 正在进行
- level-designer（Step 2）产出的布局指定了连接 "the crystal caves"（一个相邻区域）的
  入口/出口
- `design/levels/crystal-caves.md` 不存在——水晶洞穴区域尚未设计

**输入：** `/team-level forest dungeon`

**预期行为：**
1. Step 2——level-designer 产出布局，包含："West exit connects to crystal-caves entry
   point A"
2. 编排器在 `design/levels/` 中检查 `crystal-caves.md`；未找到文件
3. 上报依赖缺口："Level references crystal-caves as an adjacent area but
   `design/levels/crystal-caves.md` does not exist"
4. 呈现 `AskUserQuestion`，选项为：
   - (a) 以占位引用继续——在关卡文档中把该依赖记为 UNRESOLVED
   - (b) 暂停，先运行 `/team-level crystal caves` 来建立该区域
5. 技能不会杜撰水晶洞穴内容来满足该引用
6. 若用户选择 (a)：汇编关卡文档，西侧出口标记为 UNRESOLVED；在摘要报告的未解决跨关卡
   依赖小节中标记
7. 最终报告包含未解决的跨关卡依赖小节

**断言：**
- [ ] 技能通过检查 `design/levels/` 检测缺失的相邻区域——不假设它稍后会被创建
- [ ] 技能不杜撰水晶洞穴内容（传说、布局、连接）来解决该引用
- [ ] `AskUserQuestion` 提供一个 "design crystal caves first" 选项，引用 `/team-level`
- [ ] 若用户以占位继续，关卡文档明确把西侧出口标记为 UNRESOLVED
- [ ] 摘要报告包含列出未解决引用的未解决跨关卡依赖小节
- [ ] 循环或前向引用不会导致技能循环或崩溃

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual):
  level-designer` 行和 `Not spawned this run:` 行开头，后者点名流水线提到的其他每个代理
  ——且都在启动任何代理之前
- [ ] 在 `collaborative` 模式下，每个步骤转换都使用 `AskUserQuestion`——用户批准后流水线
  才推进
- [ ] 各代理的产出物由子代理写入编排器指定的路径；只有汇编后的关卡文档由编排器写入，且在
  其自身的 `AskUserQuestion` 批准之后
- [ ] 指定产出物在磁盘上缺失的步骤被视为失败，而非完成
- [ ] 遵循 Error Recovery Protocol：surface → assess → offer options → partial report
- [ ] Step 1（narrative-director、world-builder、art-director）和 Step 4（art-director、
  accessibility-specialist）按技能规格并行启动
- [ ] 即使代理处于 BLOCKED，也始终产出部分报告
- [ ] 无障碍 BLOCKING 关注项在 Step 5 之前上报，并要求用户明确确认
- [ ] 结论为 COMPLETE / BLOCKED 之一
- [ ] 结尾给出下一步：`/design-review`、`/dev-story`、`/qa-plan`

---

## Coverage Notes

- world-builder 阻塞用例（Case 2）中的 "Retry with narrower scope" 选项——重试行为本身未
  深入测试；其完整路径与 Case 2 及其他 team-* 规格中覆盖的代理阻塞模式类似。
- systems-designer（Step 3）阻塞场景未单独测试；适用相同的 Error Recovery Protocol，且该
  模式由 Case 2 验证。
- Step 4 的并行顺序（art-director 先于或后于 accessibility-specialist 完成）不影响结果
  ——无论顺序如何，两者都必须在 Step 5 之前返回。
- 关卡文档的 slug 规则（小写、空格 → 连字符）由 Case 1（`forest dungeon` →
  `forest-dungeon.md`）和 Case 5（`crystal caves` → `crystal-caves.md`）检验；特殊字符和
  超长名称未覆盖。
- `small` 的活跃集（增加 systems-designer + art-director）未单独立用例。
