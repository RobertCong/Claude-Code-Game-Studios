# Skill Test Spec: /team-narrative

## Skill Summary

通过五阶段流水线编排叙事团队：叙事方向（narrative-director）→ 世界基础、对话起草与
视觉方向（world-builder、writer 和 art-director 并行）→ 关卡叙事集成（level-designer）→
一致性评审（narrative-director）→ 打磨 + 本地化合规（writer、localization-lead 和
world-builder 并行）。Phase 0 解析 `review_mode`、`automation` 和 `team.size`，技能在
Phase 1 之前宣布活跃集——默认的 `individual` 只启动 writer（仅当出现明确的支柱冲突时才
启动 narrative-director），`small` 增加 narrative-director，当 `review_mode` 为 `full`
时再加 localization-lead 和 world-builder，`studio` 则无论评审模式如何都启用全部叙事代理。
每个代理都起草到技能路径表中指定的 `production/narrative/[content-slug]/` 下的具体路径；
Phase 4 运行 ND-CONSISTENCY 闸门；编排器在一次批准后把最终文档写入 `design/narrative/`。
每个阶段转换都使用 `AskUserQuestion`。产出叙事摘要报告。所有阶段成功时结论为 COMPLETE——
当 ND-CONSISTENCY 评审无法评估时为 `COMPLETE — consistency NOT ASSESSED ([input])`——
当依赖未解决时为 BLOCKED。

---

## Static Assertions (Structural)

- [ ] 具备必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具备 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "File Write Protocol" 小节
- [ ] 子代理在 `production/narrative/[content-slug]/` 下写入草稿；编排器只写入最终的
  `design/narrative/` 文档，且在一次 "May I write" 批准之后
- [ ] 为每个代理命名具体的草稿路径（包括 level-designer 和 localization-lead），并说明每个
  设计产出物最终成为的 `design/narrative/` 文档——localization-lead 的评审不是其中之一，
  仍留在 `production/`
- [ ] 每个代理提示词都以返回契约结尾：写入的路径、≤5 条摘要、BLOCKED/CONCERNS 项各一行
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式为何，且不在阶段闸门处
  声称启动总监
- [ ] 结尾有下一步交接（引用 `/design-review`、`/localize extract`、`/dev-story`）
- [ ] 存在 Error Recovery Protocol 小节：确认指定产出物已落盘；立即上报 BLOCKED；始终产出
  部分报告；完整流程见 `.claude/docs/error-recovery-protocol.md`
- [ ] 在阶段转换处使用 `AskUserQuestion` 后才继续（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求 Phase 1 之前有一行活跃集声明
- [ ] Phase 2 明确并行启动 world-builder、writer 和 art-director
- [ ] Phase 5 明确并行启动 writer、localization-lead 和 world-builder

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 五个阶段全部完成，交付叙事文档

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- 目标功能已有游戏概念和 GDD（例如 `design/gdd/faction-intro.md`）
- 存在角色声音档案（例如 `design/narrative/characters/`）
- 存在可交叉引用的既有传说条目（例如 `design/narrative/lore/`）
- 既有条目与新内容之间不存在传说矛盾

**输入：** `/team-narrative faction introduction cutscene for the Ironveil faction`

**预期行为：**
1. 在启动任何代理之前，用一行宣布 `team.size: studio` 的活跃集
2. Phase 1：启动 narrative-director；将叙事简报草稿写入
   `production/narrative/[content-slug]/brief.md`，定义故事节拍、涉及角色、情感基调与
   传说依赖
3. `AskUserQuestion` 呈现叙事简报；用户批准后 Phase 2 才开始
4. Phase 2：并行启动 world-builder、writer 和 art-director；world-builder 起草 Ironveil
   传说条目，writer 依据角色声音档案起草对话，art-director 起草视觉方向——各自位于
   `production/narrative/[content-slug]/` 之下
5. 阶段闸门：收集全部三个 Phase 2 输出，随后 `AskUserQuestion` 呈现传说、对话和视觉方向
   摘要；用户批准后 Phase 3 才开始
6. Phase 3：启动 level-designer；产出环境叙事布局、触发器布置与节奏计划
7. `AskUserQuestion` 呈现关卡叙事计划；用户批准后 Phase 4 才开始
8. Phase 4：以 ND-CONSISTENCY 闸门启动 narrative-director；评审声音、传说和节奏并返回
   APPROVE
9. `AskUserQuestion` 呈现评审结果；用户批准后 Phase 5 才开始
10. Phase 5：并行启动 writer、localization-lead 和 world-builder；writer 进行最终自查；
    localization-lead 验证 i18n 合规；world-builder 最终确定正典层级
11. 编排器列出最终文档并一次性询问 "May I write these [N] narrative documents to
    `design/narrative/`?"；批准后写入
12. 呈现最终摘要报告
13. 结论：COMPLETE

**断言：**
- [ ] 在启动第一个代理之前，出现点名 `team.size: studio` 的活跃集行
- [ ] narrative-director 在 Phase 1 中先于任何其他代理启动
- [ ] `AskUserQuestion` 出现在 Phase 1 输出之后、Phase 2 启动之前
- [ ] Phase 2 中 world-builder、writer 和 art-director 的 Agent 调用同时发出（而非顺序发出）
- [ ] Phase 2 的 `AskUserQuestion` 获批之前不启动 level-designer
- [ ] Phase 4 以闸门 ND-CONSISTENCY 重新启动 narrative-director——在每种评审模式下都如此，
  因为这是本流水线自身的评审，`review_mode` 从不跳过它——其 APPROVE / CONCERNS / REJECT
  结论决定 Phase 5 是否开始
- [ ] Phase 5 同时启动全部三个代理（writer、localization-lead、world-builder）
- [ ] 每个代理的提示词都从技能路径表中点名其草稿路径
- [ ] 在一次性 "May I write" 批准之前，`design/narrative/` 下不写入任何内容
- [ ] 摘要报告包含：叙事简报状态、创建/更新的传说条目、编写的对话行数、关卡叙事集成点、
  一致性评审结果
- [ ] 编排器除已批准的最终文档外不写入任何内容
- [ ] 交付后结论为 COMPLETE

---

### Case 2: 发现传说矛盾 — world-builder 在 writer 继续前发现冲突

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- `design/narrative/lore/ironveil-history.md` 的既有传说条目称 Ironveil 阵营建立于 200 年前
- 新的叙事简报（来自 Phase 1）称 Ironveil 建立于 50 年前
- Phase 2 中 writer 已与 world-builder 并行启动

**输入：** `/team-narrative ironveil faction introduction cutscene`

**预期行为：**
1. Phase 1–2 正常开始
2. Phase 2 的 world-builder 检测到叙事简报与既有传说之间的事实矛盾：建立日期冲突
3. world-builder 返回 BLOCKED，原因："Lore contradiction found — founding date conflicts
   with `design/narrative/lore/ironveil-history.md`"
4. 编排器立即上报该矛盾："world-builder: BLOCKED — Lore contradiction: founding date in
   narrative brief (50 years ago) conflicts with existing canon (200 years ago in
   `ironveil-history.md`)"
5. 编排器评估依赖：writer 的对话依赖正典传说——不解决该矛盾，writer 的草稿就无法定稿
6. `AskUserQuestion` 呈现错误恢复选项：
   - 跳过 world-builder，并在最终报告中记录缺口
   - 以更窄范围重试（例如 world-builder 依据用户确认的正典工作）
   - 停在这里，先解决传说文档中的矛盾
7. writer 的输出在部分报告中保留——工作不被丢弃
8. 在矛盾解决或用户明确选择跳过之前，编排器不进入 Phase 3

**断言：**
- [ ] Phase 3 开始之前上报该矛盾
- [ ] 编排器不会通过挑选某一版本来悄悄解决矛盾
- [ ] `AskUserQuestion` 至少呈现 3 个选项，包括 "stop and resolve first"
- [ ] writer 的草稿输出在部分报告中保留，不被丢弃
- [ ] 在用户解决矛盾或明确选择跳过 world-builder 之前，不启动 Phase 3（level-designer）
- [ ] 若用户停下来解决矛盾，结论为 BLOCKED（而非 COMPLETE）

---

### Case 3: 无参数 — 显示用法指引

**测试夹具：**
- 任意项目状态

**输入：** `/team-narrative`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法指引：例如 "Usage: `/team-narrative [narrative content description]
   [--review full|lean|solo]` — describe the story content, scene, or narrative area to
   work on (e.g., `boss encounter cutscene`, `faction intro dialogue`, `tutorial
   narrative`)"
3. 技能退出，不启动任何代理

**断言：**
- [ ] 未提供参数时技能不启动任何代理
- [ ] 用法消息展示完整的 argument-hint——`/team-narrative [narrative content
  description] [--review full|lean|solo]`——以及一个参数示例
- [ ] 技能不会尝试从项目文件中猜测或推断叙事主题
- [ ] 不使用 `AskUserQuestion`——输出为直接指引

---

### Case 4: 本地化合规 — localization-lead 因不可翻译字符串而阻塞

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- Phase 1–4 成功完成
- Phase 5 开始；writer 和 world-builder 无问题完成
- localization-lead 发现一行对话使用了硬编码的格式化日期字符串（例如 `"On March 12th,
  Year 3"`），在没有区域感知格式化器的情况下无法经受针对不同区域的翻译，并在其返回契约中
  将其作为 BLOCKED 项返回

**输入：** `/team-narrative ironveil faction introduction cutscene`（Phase 5 场景）

**预期行为：**
1. Phase 5 并行启动 writer、localization-lead 和 world-builder
2. localization-lead 返回 BLOCKED："String key `dialogue.ironveil.intro.003` contains a
   hardcoded date format (`March 12th, Year 3`) that will not localize correctly —
   requires a locale-aware date placeholder"
3. 编排器立即上报："localization-lead: BLOCKED — [reason with the string key]"
4. writer 和 world-builder 的 Phase 5 输出保留在部分报告中
5. `AskUserQuestion` 呈现错误恢复选项：
   - 跳过并在最终报告中记录缺口（带着被标记的字符串交付）
   - 以更窄范围重试（例如 writer 修改那一行，然后 localization-lead 重新检查）
   - 停下来，在定稿前解决
6. 若用户跳过，最终摘要把未修复的字符串键列入未解决项；若用户停下来，结论为
   `BLOCKED — [reason]`

**断言：**
- [ ] localization-lead 在 Phase 5 中与 writer 和 world-builder 同时启动
- [ ] 硬编码日期格式被识别为本地化阻塞项（而非悄悄通过）
- [ ] 上报的 BLOCKED 消息中包含具体的字符串键和原因
- [ ] `AskUserQuestion` 提供跳过并记录缺口、重试和停止三种选项
- [ ] 若用户未修复即继续，最终报告点名未修复的字符串键；若用户停止，结论为 BLOCKED
- [ ] 未经用户批准，技能不会自动改写有问题的行

---

### Case 5: writer 阻塞 — 缺少角色声音档案

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- Phase 1 的 narrative-director 产出叙事简报，引用两个角色：Commander Varek 和 Advisor
  Selene
- `design/narrative/characters/` 中没有这两个角色的声音档案
- Phase 2 开始；world-builder 和 art-director 正常进行

**输入：** `/team-narrative ironveil surrender negotiation scene`

**预期行为：**
1. Phase 1 完成；叙事简报把 Commander Varek 和 Advisor Selene 列为角色
2. Phase 2：writer 与 world-builder、art-director 并行启动
3. writer 返回 BLOCKED："Cannot produce dialogue — no voice profiles found for Commander
   Varek or Advisor Selene in `design/narrative/characters/`. Voice profiles required to
   match character tone and speech patterns."
4. 编排器立即上报该阻塞项："writer: BLOCKED — Missing prerequisite: character voice
   profiles for Commander Varek and Advisor Selene"
5. world-builder 的输出保留；产出包含传说条目的部分报告
6. `AskUserQuestion` 呈现错误恢复选项：
   - 跳过 writer，并在最终报告中记录缺口
   - 以更窄范围重试（例如内联提供最小化的声音指导）
   - 停在这里，先创建声音档案再继续
7. 除非用户明确选择跳过，编排器不会在没有 writer 输出的情况下进入 Phase 3（level-designer）

**断言：**
- [ ] Phase 3 开始之前上报 writer 阻塞
- [ ] world-builder 已完成的传说输出在部分报告中保留
- [ ] 具体点名缺失的前置条件（声音档案）（角色名与预期文件路径）
- [ ] `AskUserQuestion` 至少提供一个解决缺失前置条件的选项
- [ ] 编排器不会伪造声音档案或杜撰角色声音
- [ ] 未经用户明确授权，writer 处于 BLOCKED 时不启动 Phase 3

---

### Case 6: `review_mode` 只影响 `small` 名册，不门控其他内容 — ND-CONSISTENCY 在每种模式下都运行

**测试夹具：**
- `project.yaml`：运行 A–C 为 `team.size: studio`，运行 D–F 为 `team.size: small`
  （固定：名册是 `review_mode` 仍然影响的唯一事项）；`modes.review_mode` 未设置，因此
  每次运行的 `--review` 值决定
- `design/gdd/faction-intro.md`、角色声音档案和既有传说均存在
- 运行 A 和 D：`/team-narrative faction introduction cutscene --review full`。
  运行 B 和 E：`--review lean`。运行 C 和 F：`--review solo`

**预期行为：**
1. 运行 A–C（`studio`）：无论评审模式为何，全部六个代理都活跃，因此活跃集行、各阶段和
   启动的代理完全相同
2. 运行 D–F（`small`）：三次运行中 narrative-director + writer 都活跃。运行 D（`full`）
   增加 localization-lead 和 world-builder；在运行 E 和 F 中，它们通过 writer 咨询，并在
   `Not spawned this run:` 行中点名
3. Phase 4 在全部六次运行中都以 ND-CONSISTENCY 启动 `narrative-director`："This phase
   runs in every review mode — it is this pipeline's own review, not an optional director
   gate"
4. 任何运行都不在任何阶段启动 CD-、TD-、PR- 或 AD-PHASE-GATE

**断言：**
- [ ] 六次运行中的每一次都在 Phase 4 以 ND-CONSISTENCY 启动；`lean` 和 `solo` 不会跳过它
- [ ] 任何运行都不启动总监闸门（CD-、TD-、PR- 或 AD-PHASE-GATE）
- [ ] 运行 A–C 显示相同的活跃集、阶段和询问
- [ ] 在 `small` 下，localization-lead 和 world-builder 只在运行 D（`full`）中启动，并在
  运行 E 和 F 的 `Not spawned this run:` 下点名
- [ ] 在 `small` 下的 `lean` 和 `solo` 中，传说与 i18n 工作仍通过 writer 完成，且输出如此
  说明
- [ ] ND-CONSISTENCY 的 APPROVE / CONCERNS / REJECT 回答在每种模式下都决定 Phase 5 是否开始

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual):
  writer.` 和 `Not spawned this run:` 行开头，后者点名 narrative-director、world-builder、
  art-director、level-designer 和 localization-lead（通过 writer 咨询）——且都在启动任何
  代理之前
- [ ] 在 `collaborative` 模式下，每次阶段输出之后、下一阶段启动之前都使用 `AskUserQuestion`
- [ ] 并行启动：Phase 2（world-builder + writer + art-director）和 Phase 5（writer +
  localization-lead + world-builder）都在等待结果之前发出全部 Agent 调用
- [ ] 未获 "May I write" 批准，不在 `design/` 下写入任何内容——`design/` 在有界例外
  （`production/`、`docs/`、`tests/`）之外
- [ ] 在 `team.size: individual` 下，Phase 4 不启动 narrative-director；输出说明
  "ND-CONSISTENCY not run — narrative-director is not active at `team.size: individual`;
  consistency self-checked by writer."，且从不把 writer 的自查呈现为闸门结论
- [ ] ND-CONSISTENCY 的 `NOT ASSESSED [missing input]` 回答绝不视为 APPROVE：点名缺失的
  输入，然后要么补上并重跑闸门，要么把 `ND-CONSISTENCY: NOT ASSESSED — [input]` 带入报告
  的一致性评审结果，且结论写作 `COMPLETE — consistency NOT ASSESSED ([input])`，绝不
  只是 COMPLETE
- [ ] 指定产出物在磁盘上缺失的阶段被视为失败，而非完成
- [ ] 任何代理的 BLOCKED 状态都立即上报——不被悄悄跳过
- [ ] 当部分代理完成、其他代理阻塞时，始终产出部分报告
- [ ] 结论恰好为 COMPLETE、`COMPLETE — consistency NOT ASSESSED ([input])` 或 BLOCKED——
  不使用其他结论值
- [ ] Next Steps 交接引用 `/design-review`、`/localize extract` 和 `/dev-story`

---

## Coverage Notes

- Phase 3（level-designer）和 Phase 4（narrative-director 评审）的正常路径行为由 Case 1
  隐式验证。这些阶段无需单独用例，因为其失败模式遵循标准 Error Recovery Protocol。
- Error Recovery Protocol 中的 "Retry with narrower scope" 和 "Skip this agent" 解决路径
  未单独走到完成——Case 2、4 和 5 检查它们被提供。
- 建议性的本地化关注项（例如德语/芬兰语 +30% 扩展警告）未单独立用例；Case 4 只覆盖
  localization-lead 作为 BLOCKED 返回的关注项。
- writer 在 Phase 5 中的 "all lines under 120 characters" 和 "string keys not raw strings"
  检查由 Case 4 的本地化合规场景隐式覆盖。
- `small` 的活跃集（依赖 review_mode 的 localization-lead 和 world-builder）在 Case 6 的
  名册层面检查；其逐阶段的运行未走查。
