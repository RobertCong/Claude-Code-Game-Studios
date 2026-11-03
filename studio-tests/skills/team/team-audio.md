# Skill Test Spec: /team-audio

## Skill Summary

通过四步流水线编排音频团队：音频方向（audio-director）→ 声音设计与无障碍评审并行
（sound-designer + accessibility-specialist）→ 技术实现与引擎验证并行（technical-artist +
主要引擎专家）→ 代码集成（gameplay-programmer）。Phase 0 解析 `review_mode`、`automation`
和 `team.size`，技能在 Step 1 之前用一行宣布活跃代理集——默认的 `team.size: individual`
只启动 sound-designer，其他所有代理都通过它咨询。在启动代理之前读取相关 GDD、声音圣经
（若存在）和既有音频资源清单。子代理把工作产出物写入编排器指定的路径，位于有界写入例外
之内；编排器自行汇编音频设计文档，并且仅在通过 `AskUserQuestion` 询问后才写入
`design/audio/audio-[feature].md`。每个步骤转换都使用 `AskUserQuestion`。当音频设计文档
产出时结论为 COMPLETE，当未解决的依赖使流水线停止时结论为 BLOCKED。未配置引擎时跳过引擎
专家，并记录 `Engine validation: NOT ASSESSED`。

---

## Static Assertions (Structural)

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具备 ≥2 个步骤/阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "File Write Protocol" 小节
- [ ] 子代理写入限于有界例外之内——编排器指定的路径、`production/`、`docs/` 或 `tests/`
  下的新产出物，且处于由 `AskUserQuestion` 门控的步骤中；这些边界内不逐次写入提示，边界外
  有 "May I write" 询问；实现文件（代码、着色器、音频、资源）在其之外——每个代理列出其将
  创建或修改的文件，技能在写入任何文件之前就整组文件询问一次
- [ ] 为每个代理指定 `production/audio/[feature]/` 下的目标：`direction.md`
  （audio-director）、`sfx-spec.md`（sound-designer）、`accessibility.md`
  （accessibility-specialist）、`integration-plan.md`（technical-artist）、
  `engine-notes.md`（引擎专家）
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式为何，且不在阶段闸门处
  声称启动总监
- [ ] 汇编后的音频设计文档由编排器写入，且仅在其通过 `AskUserQuestion` 询问 "May I write
  the audio design to `design/audio/audio-[feature].md`?" 之后（`design/` 在有界例外之外）
- [ ] 每个代理提示词都以返回契约结尾：写入的路径、≤5 条摘要、BLOCKED/CONCERNS 项各一行
- [ ] 结尾有下一步交接（引用 `/dev-story`、`/asset-audit`）
- [ ] 存在 Error Recovery Protocol 小节：在把某步骤视为完成前，确认指定产出物已落盘；立即
  上报 BLOCKED；始终产出部分报告；完整流程见 `.trae/docs/error-recovery-protocol.md`
- [ ] 在步骤转换处使用 `AskUserQuestion` 后才继续（`collaborative` 模式）
- [ ] Phase 0 解析 `review_mode`、`automation` 和 `team.size`，并要求 Step 1 之前有一行
  活跃集声明
- [ ] Step 2 明确并行启动 sound-designer 和 accessibility-specialist，且 How to Delegate
  列出 `accessibility-specialist`
- [ ] Step 2 把没有视觉线索或字幕的玩法关键音频事件标记为 BLOCKING，且 Step 3 等待用户
  解决或接受它
- [ ] Step 3 明确并行启动 technical-artist 和引擎专家（当配置了引擎时）
- [ ] 若存在，技能在上下文收集期间读取 `design/audio/sound-bible.md` 的声音圣经；仍留在
  `design/gdd/sound-bible.md`（较早位置）的声音圣经会被读取，并建议迁移
- [ ] 输出文档保存到 `design/audio/audio-[feature].md`

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 所有步骤完成，音频设计文档已保存

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- `project.yaml` 中的 `engine.name` 为 Godot
- 目标功能的 GDD 存在于 `design/gdd/combat.md`
- 声音圣经存在于 `design/audio/sound-bible.md`
- 既有音频资源列于 `assets/audio/`
- 计划的音频事件清单中不存在无障碍缺口

**输入：** `/team-audio combat`

**预期行为：**
1. 在启动任何代理之前，用一行宣布 `team.size: studio` 的活跃集
2. 上下文收集：编排器在启动任何代理之前读取 `design/gdd/combat.md`、
   `design/audio/sound-bible.md` 和 `assets/audio/` 资源清单
3. Step 1：启动 audio-director；为战斗定义声音标识、情感基调、自适应音乐方向、混音目标
   和自适应音频规则
4. `AskUserQuestion` 呈现音频方向；用户批准后 Step 2 才开始
5. Step 2：并行启动 sound-designer 和 accessibility-specialist；sound-designer 产出音效
   规格、带触发条件的音频事件清单和混音组；accessibility-specialist 识别关键玩法音频
   事件，并规定视觉回退与字幕要求
6. `AskUserQuestion` 呈现音效规格和无障碍要求；用户批准后 Step 3 才开始
7. Step 3：并行启动 technical-artist 和 `godot-specialist`（依据 `engine.name` 推导）；
   technical-artist 设计总线结构、中间件集成、内存预算和流式加载策略；引擎专家验证该集成
   方案对固定引擎是否惯用
8. `AskUserQuestion` 呈现技术方案；用户批准后 Step 4 才开始
9. Step 4：启动 gameplay-programmer；先返回其将创建或修改的代码与测试文件，编排器就整组
   文件询问一次，得到肯定答复后才把音频事件接到玩法触发器、实现自适应音乐、设置遮挡区域，
   并为音频事件触发编写单元测试
10. 对每个步骤，编排器都确认代理返回契约中指定的路径存在，才把该步骤视为完成
11. 编排器自行把所有输出汇编成单一音频设计文档（不重新启动子代理来写）
12. 编排器通过 `AskUserQuestion` 询问："May I write the audio design to
    `design/audio/audio-combat.md`?"，且仅在批准后写入
13. 摘要输出列出：音频事件数、预估资源数、实现任务以及任何未决问题
14. 结论：COMPLETE

**断言：**
- [ ] 在启动第一个代理之前，出现点名 `team.size: studio` 的活跃集行
- [ ] 声音圣经存在时，在上下文收集期间（Step 1 之前）被读取
- [ ] audio-director 先于 sound-designer 或 accessibility-specialist 启动
- [ ] `AskUserQuestion` 出现在 Step 1 输出之后、Step 2 启动之前
- [ ] Step 2 中 sound-designer 和 accessibility-specialist 的 Agent 调用同时发出
- [ ] Step 3 中 technical-artist 和 `godot-specialist` 的 Agent 调用同时发出
- [ ] Step 3 的 `AskUserQuestion` 获批之前不启动 gameplay-programmer
- [ ] 在就实现文件整组进行一次询问并得到肯定答复之前，gameplay-programmer 不写入任何代码
  或测试文件
- [ ] 音频设计文档写入 `design/audio/audio-combat.md`（而非其他路径），由编排器写入，且仅
  在其 `AskUserQuestion` 批准之后
- [ ] 摘要包含音频事件数和预估资源数
- [ ] 文档交付后结论为 COMPLETE

---

### Case 2: 无障碍缺口 — 关键玩法音频事件没有视觉回退

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- 目标功能的 GDD 存在
- Step 1 和 Step 2 正在进行
- sound-designer 的音频事件清单包含 "EnemyNearbyAlert"——一种空间音频提示，警告玩家有敌人
  正从屏幕外接近
- accessibility-specialist 评审事件清单，发现 "EnemyNearbyAlert" 没有视觉回退（未指定
  屏幕指示器、字幕或手柄震动）

**输入：** `/team-audio stealth`（Step 2 场景）

**预期行为：**
1. Step 1–2 进行；并行启动 accessibility-specialist 和 sound-designer
2. accessibility-specialist 返回评审，含 BLOCKING 关注项："`EnemyNearbyAlert` is a
   critical gameplay audio event (warns player of off-screen threat) with no visual
   fallback — hearing-impaired players cannot detect this threat."
3. 编排器在呈现 `AskUserQuestion` 之前，在对话中写出该关注项
4. `AskUserQuestion` 把该无障碍关注项作为 BLOCKING 问题呈现，选项例如：
   - 为 EnemyNearbyAlert 添加视觉指示器（例如 HUD 上的方向箭头）并继续
   - 添加手柄触觉反馈作为回退并继续
   - 停在这里，先解决所有无障碍缺口再进入 Step 3
5. 在用户解决或明确接受该缺口之前，不启动 Step 3（technical-artist + 引擎专家）
6. 若用户停止：产出 Step 1–2 输出的部分报告，结论为 `BLOCKED — [reason]`，点名未解决的
   EnemyNearbyAlert 缺口
7. 若用户接受缺口并继续：该缺口列入最终摘要的未决问题中

**断言：**
- [ ] 无障碍缺口在报告中标记为 BLOCKING（而非建议性）
- [ ] 说明具体事件名（"EnemyNearbyAlert"）和缺口性质
- [ ] `AskUserQuestion` 在启动 Step 3 之前上报该缺口
- [ ] 至少提供一个解决选项（添加视觉回退、添加触觉回退）
- [ ] 未经用户明确授权，缺口未解决时不启动 Step 3
- [ ] 若用户停止，结论为 `BLOCKED — [reason]` 并点名缺口，且 Step 1–2 的输出保留在部分
  报告中；若用户继续推进，最终摘要把该缺口列为未决问题

---

### Case 3: 无参数 — 显示用法指引或推断设计文档

**测试夹具：**
- 任意项目状态

**输入：** `/team-audio`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法指引：例如 "Usage: `/team-audio [feature or area to design audio for]
   [--review full|lean|solo]` — specify the feature or area to design audio for (e.g.,
   `combat`, `main menu`, `forest biome`, `boss encounter`)"
3. 技能退出，不启动任何代理

**断言：**
- [ ] 未提供参数时技能不启动任何代理
- [ ] 用法消息展示完整的 argument-hint——`/team-audio [feature or area to design audio
  for] [--review full|lean|solo]`——以及参数示例
- [ ] 未经用户指示，技能不会尝试从既有设计文档推断功能
- [ ] 不使用 `AskUserQuestion`——输出为直接指引

---

### Case 4: 缺少声音圣经 — 技能记录缺口并在没有它的情况下继续

**测试夹具：**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- 目标功能的 GDD 存在于 `design/gdd/main-menu.md`
- `design/audio/sound-bible.md` 和 `design/gdd/sound-bible.md` 均无声音圣经
- 引擎已配置；其他上下文文件存在

**输入：** `/team-audio main menu`

**预期行为：**
1. 上下文收集：编排器读取 `design/gdd/main-menu.md` 并检查 `design/audio/sound-bible.md`
2. 未找到声音圣经；编排器用一行记录缺口："No sound bible at
   `design/audio/sound-bible.md`; audio direction starts from the GDDs alone"
3. 流水线在没有声音圣经作为输入的情况下正常走完四个步骤
4. Step 1 的 audio-director 被告知不存在声音圣经，必须仅依据功能 GDD 建立声音标识
5. Next Steps 建议创建声音圣经并说明由谁编写：`audio-director` 代理从
   `.trae/docs/templates/sound-bible.md` 起草 `design/audio/sound-bible.md`，以本次运行
   Step 1 的方向为起点，并在写入前询问

**断言：**
- [ ] 编排器在上下文收集期间（Step 1 之前）检查声音圣经
- [ ] 缺少声音圣经在对话中明确记录——不被悄悄忽略
- [ ] 流水线不因缺少声音圣经而停止
- [ ] audio-director 在其提示词上下文中被告知不存在声音圣经
- [ ] Next Steps 建议创建声音圣经并点名其作者——`audio-director`，从
  `.trae/docs/templates/sound-bible.md` 起草
- [ ] 技能在本次运行中不自行写入 `design/audio/sound-bible.md`
- [ ] 若其他所有步骤成功，结论仍为 COMPLETE

---

### Case 5: 未配置引擎 — 跳过并记录引擎专家步骤

**测试夹具：**
- 已解析配置块：`team.size: studio`、`automation: collaborative`
- `project.yaml` 中的 `engine.name` 未设置，且 `.trae/docs/technical-preferences.md`
  没有 Primary 引擎专家（显示 `[TO BE CONFIGURED]`）
- 目标功能的 GDD 存在
- 声音圣经可能存在也可能不存在

**输入：** `/team-audio boss encounter`

**预期行为：**
1. Step 1–2 正常进行（audio-director、sound-designer、accessibility-specialist）
2. Step 3：technical-artist 正常启动；引擎专家的启动被 SKIPPED
3. 运行输出记录：`Engine validation: NOT ASSESSED — no engine configured (engine.name
   unset in project.yaml)`
4. Step 4：gameplay-programmer 仍然运行——缺少引擎不作为阻塞项处理
5. 结论：`COMPLETE — engine validation NOT ASSESSED (no engine configured)`——跳过是优雅的，
   不是阻塞项，且绝不只是 COMPLETE

**断言：**
- [ ] 未配置引擎时不启动引擎专家
- [ ] 技能不因缺少引擎配置而报错退出
- [ ] 运行输出包含 `Engine validation: NOT ASSESSED — no engine configured` 及
  `engine.name` 原因——跳过不被悄悄省略
- [ ] 本次运行中绝不把引擎集成描述为已验证或通过
- [ ] Step 3 中 technical-artist 仍然启动（跳过仅适用于引擎专家）
- [ ] Step 4 中 gameplay-programmer 仍然运行
- [ ] 结论为 `COMPLETE — engine validation NOT ASSESSED (…)`，绝不只是 COMPLETE
  （未配置引擎是优雅情形，不是阻塞项）

---

### Case 6: `review_mode` 不门控任何内容 — 同一请求在 full、lean 和 solo 下

**测试夹具：**
- `project.yaml`：`modes.review_mode: lean`（固定：下列运行会覆盖或保留它）、
  `team.size: studio`（固定：使流水线中的每个步骤和代理都活跃）
- `engine.name` 为 Godot；`design/gdd/combat.md` 和 `design/audio/sound-bible.md` 存在；
  事件清单中无无障碍缺口
- 运行 A：`/team-audio combat --review full`。运行 B：`/team-audio combat`（解析为
  `lean`）。运行 C：`/team-audio combat --review solo`

**预期行为：**
1. 三次运行都以相同的 `team.size: studio` 活跃集行开头
2. 三次运行都以相同的代理走相同的四个步骤：audio-director，然后 sound-designer +
   accessibility-specialist，然后 technical-artist + `godot-specialist`，然后
   gameplay-programmer。这些是执行步骤的团队成员，不是总监闸门
3. 任何运行都不在任何步骤启动 CD-、TD-、PR- 或 AD-PHASE-GATE："no phase below spawns
   CD-, TD-, PR- or AD-PHASE-GATE, at any `review_mode`"
4. 每个步骤转换处的 `AskUserQuestion`、对音频设计文档的单次询问以及结论，在三次运行中
   都相同

**断言：**
- [ ] 运行 A（`full`）、运行 B（`lean`）或运行 C（`solo`）中都不启动总监闸门（CD-、TD-、
  PR- 或 AD-PHASE-GATE）
- [ ] 三次运行的活跃集、每个步骤启动的代理以及步骤转换询问次数完全相同
- [ ] `--review full` 不增加评审步骤，`--review solo` 不删除评审步骤：只有 `team.size`
  改变谁被启动
- [ ] 每次运行都只在其自身的询问之后写入 `design/audio/audio-combat.md`，并以 COMPLETE
  结束

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual):
  sound-designer.` 和 `Not spawned this run:` 行开头，后者点名 audio-director、
  accessibility-specialist、technical-artist、引擎专家和 gameplay-programmer（通过
  sound-designer 咨询）——且都在启动任何代理之前
- [ ] 上下文收集（GDD、声音圣经、资源清单）在启动任何代理之前运行
- [ ] 在 `collaborative` 模式下，每次步骤输出之后、下一步骤启动之前都使用 `AskUserQuestion`
- [ ] 并行启动：Step 2（sound-designer + accessibility-specialist）和 Step 3
  （technical-artist + 引擎专家）都在等待结果之前发出全部 Agent 调用
- [ ] 子代理只写入编排器指定的路径；仅在有界例外（`production/`、`docs/`、`tests/`）之内
  跳过逐次写入提示
- [ ] 编排器仅在明确的 `AskUserQuestion` 批准之后写入汇编后的音频设计文档
- [ ] 指定产出物在磁盘上缺失的步骤被视为失败，并恢复该代理——不报告为完成
- [ ] 任何代理的 BLOCKED 状态都立即以 "[AgentName]: BLOCKED — [reason]" 上报——不被悄悄
  跳过
- [ ] 当部分代理完成、其他代理阻塞时，始终产出部分报告
- [ ] 音频设计文档路径遵循 `design/audio/audio-[feature].md` 模式
- [ ] 结论恰好为 COMPLETE（当该步骤被跳过时限定为 `— engine validation NOT ASSESSED
  ([reason])`）或 BLOCKED——不使用其他结论值
- [ ] Next Steps 交接引用 `/dev-story` 和 `/asset-audit`

---

## Coverage Notes

- Error Recovery Protocol 中的 "Retry with narrower scope" 和 "Skip this agent" 解决路径
  未单独测试——它们遵循 Case 2 和 Case 5 中验证的相同 `AskUserQuestion` + 部分报告模式。
- Step 4（gameplay-programmer）的正常路径行为由 Case 1 隐式验证。该步骤的失败模式遵循
  标准 Error Recovery Protocol。
- accessibility-specialist 的字幕和说明文字要求（超出视觉回退之外）由 Case 1 隐式验证。
  Case 2 聚焦于更严重的情形：关键玩法事件完全没有回退。
- 引擎专家的验证逻辑（惯用集成、版本特定变更）只针对已配置和未配置状态测试。引擎专家
  输出的具体内容不在本行为规格的范围内。
- `guided` 和 `autonomous` 自动化模式（自动推进、`log_decision`）未单独立用例；individual
  规模的收缩由 Protocol Compliance 的声明检查覆盖，而非完整运行。
