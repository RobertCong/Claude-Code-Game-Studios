# Skill Test Spec: /team-polish

## Skill Summary

通过六阶段流水线编排打磨团队：性能评估
（performance-analyst，其报告携带优化清单，每一项都有负责人）
→ 优化（由活动集中的负责人实现该清单 ——
引擎层面根因交由 engine-programmer，内容工具交由 tools-programmer；
performance-analyst 不写任何游戏代码）→ 视觉打磨
（technical-artist，与 Phase 2 并行）→ 音频打磨（sound-designer，与
Phase 2 并行）→ 加固（qa-tester）→ 签核（编排器收集所有结果，
并给出 READY FOR RELEASE、NOT ASSESSED 或 NEEDS MORE WORK —— 当
预算未承诺或某阶段未运行时为 NOT ASSESSED）。Phase 0 解析 `review_mode`、
`automation`、`team.size` 与 `workflow`，技能在 Phase 1 之前宣布活动集
—— 默认的 `individual` 仅启动 performance-analyst + technical-artist，因此
没有程序员活动，报告会将优化清单记为已交接给
`/dev-story`；`small` 增加 sound-designer、qa-tester 与 engine-programmer（完整
流水线）；`studio` 保留该集合并增加一轮对抗性检验。每个代理在
有界写入例外下（无逐次写入提示）向 `production/polish/` 下的指定路径写入
带日期的报告，编排器说明目前尚无任何东西
读取 `production/polish/`。Phase 2–4 的代码、着色器、音频与资源变更
不在此例外内：一次询问覆盖整组。在每个阶段转换处使用
`AskUserQuestion`。只有当 Phase 1 识别出引擎层面根因时，
才会条件性启动 engine-programmer。

---

## Static Assertions (Structural)

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少包含 2 个 Phase 标题
- [ ] 包含结论关键词：READY FOR RELEASE、NOT ASSESSED、NEEDS MORE WORK —— 并说明 NOT ASSESSED 排在 READY FOR RELEASE 之上、NEEDS MORE WORK 之下
- [ ] 包含 "File Write Protocol" 章节
- [ ] 文件写入委托给子代理 —— 编排器不直接写文件
- [ ] 为每个代理在 `production/polish/` 下指定目标位置：`[area]-report-[date].md`（performance-analyst）、`[area]-render-notes-[date].md`（technical-artist）、`[area]-engine-fixes-[date].md`（engine-programmer）、`[area]-tool-fixes-[date].md`（tools-programmer）、`[area]-audio-notes-[date].md`（sound-designer）、`[area]-verification-[date].md`（qa-tester）
- [ ] 子代理无需逐次写入提示即可写入这些指定的 `production/` 路径（有界例外），若写入其外则必须询问；实现文件（代码、着色器、音频、资源）在此例外之外 —— 每个代理列出它将创建或更改的文件，技能在任何文件被写入之前一次性询问整组 —— 对 Phase 2–4 的整组一次询问，绝不逐阶段各问一次
- [ ] `small` 与 `studio` 集合包含 `engine-programmer`；在 `individual` 下没有程序员活动，报告会将优化清单记为已交接给 `/dev-story`
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式如何，且不声称总监在阶段闸门处启动
- [ ] 结尾具备后续步骤交接（引用 `/release-checklist`、`/sprint-plan update`、`/gate-check`）
- [ ] 存在 Error Recovery Protocol 章节：核实指定产出物在磁盘上、立即呈现 BLOCKED、始终产出部分报告，完整流程见 `.trae/docs/error-recovery-protocol.md`
- [ ] 在继续之前的阶段转换处使用 `AskUserQuestion`（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求在 Phase 1 之前有一行活动集公告
- [ ] 明确说明 Phase 3（视觉打磨）与 Phase 4（音频打磨）与 Phase 2 并行运行
- [ ] Phase 1 的报告携带优化清单，每一项都有负责人；performance-analyst 在任何阶段都不写游戏代码
- [ ] engine-programmer 仅在 Phase 1 识别出引擎层面根因时于 Phase 2 条件性启动
- [ ] Phase 6 签核在给出结论之前，将指标与预算进行比较
- [ ] Phase 6 列出每个遗留问题及其严重程度、可测量时测得的差距（例如 "3 ms over budget"）与建议

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与
`modes.automation: collaborative`，且不含 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 顺利路径 —— 完整流水线完成，结论 READY FOR RELEASE

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- 功能存在且功能上完整（例如 `combat` 系统）
- 性能预算在 `project.yaml` 中定义（`performance.target_framerate: 60`、`performance.frame_budget_ms: 16.6`、`performance.draw_call_limit: 2000`、`performance.memory_ceiling_mb: 2048`）
- 打磨开始前不存在任何帧预算违规
- 没有缺失的音频事件；VFX 资源完整
- 打磨变更未引入任何回归

**Input:** `/team-polish combat`

**Expected behavior:**
1. 在任何启动之前，用一行宣布 `team.size: small` 的活动集（完整流水线）
2. Phase 1：启动 performance-analyst；对 combat 系统做性能剖析，测量帧预算，检查内存使用；写入 `production/polish/combat-report-[date].md`，显示所有指标都在预算内
3. `AskUserQuestion` 呈现性能报告；用户在 Phase 2、3、4 开始之前批准
4. Phase 2：报告的优化清单仅包含轻微渲染项（例如绘制调用批处理），由 technical-artist 负责，因此并入其 Phase 3 简报；未识别出引擎层面根因，故不启动 engine-programmer；performance-analyst 不改动任何代码
5. Phase 3 与 Phase 4 与 Phase 2 同时启动：
   - Phase 3：technical-artist 审视 VFX 质量，优化粒子系统，添加屏幕震动与视觉表现力；写入 `production/polish/combat-render-notes-[date].md`
   - Phase 4：sound-designer 审视音频事件的完整性，检查混音电平，添加环境音层；写入 `production/polish/combat-audio-notes-[date].md`
   - 更改着色器、VFX 或资源的代理首先列出文件；一次 `AskUserQuestion` 覆盖 Phase 2–4 的整组，并且在得到同意之前不编辑任何内容
6. 三个并行阶段全部完成；`AskUserQuestion` 呈现结果；用户在 Phase 5 开始之前批准
7. Phase 5：qa-tester 运行边界用例测试、浸泡测试、压力测试与回归测试；全部通过；写入 `production/polish/combat-verification-[date].md`
8. `AskUserQuestion` 呈现测试结果；用户在 Phase 6 之前批准
9. Phase 6：编排器收集所有结果；将打磨前后的性能指标与预算进行比较；所有指标均通过
10. 报告说明 `production/polish/` 下的文件只是一份记录，仓库中尚无任何东西读取它们
11. 结论：READY FOR RELEASE

**Assertions:**
- [ ] 指明 `team.size: small` 的活动集行出现在第一个代理启动之前
- [ ] performance-analyst 在任何其他代理之前于 Phase 1 首先启动
- [ ] `AskUserQuestion` 出现在 Phase 1 输出之后、Phase 2/3/4 启动之前
- [ ] Phase 3 与 Phase 4 的 Agent 调用与 Phase 2 同时发起（而非在 Phase 2 完成之后）
- [ ] 当 Phase 1 未发现引擎层面根因时，不启动 engine-programmer
- [ ] performance-analyst 在任何阶段都不编辑代码、着色器或资源
- [ ] Phase 2–4 的实现文件由各代理列出，并在一次覆盖整组的 `AskUserQuestion` 中询问 —— 而非每阶段一次 —— 且在任何编辑之前完成
- [ ] 并行阶段完成且用户批准之前，不启动 qa-tester（Phase 5）
- [ ] 每个代理无需逐次写入提示即写入其指定的 `production/polish/[area]-…-[date].md` 路径，且编排器在将该阶段视为完成之前确认文件存在
- [ ] Phase 6 的结论基于指标与既定预算的比较
- [ ] 摘要报告包含：打磨前后性能指标、视觉打磨变更、音频打磨变更、测试结果
- [ ] 摘要说明目前尚无任何东西读取 `production/polish/`
- [ ] 编排器不直接写入任何文件
- [ ] 结论为 READY FOR RELEASE

---

### Case 2: 性能阻塞项 —— 帧预算违规无法完全解决

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`workflow: standard`（已固定：未设置时解析为 minimal，其后续步骤会把该问题加入简报的构建顺序，而非 `/sprint-plan update`；Case 8 覆盖该情况）
- 正在打磨的功能：`particle-storm` VFX 系统
- Phase 1 识别出一项帧预算违规：particle-storm 在目标硬件上耗时 12ms（本系统预算为 6ms）
- Phase 1 的优化清单将粒子工作分配给 technical-artist，将引擎层面的粒子更新热路径分配给 engine-programmer；两者应用之后耗时为 9ms —— 仍超出 6ms 预算
- 若不进行根本性设计变更，Phase 2 无法完全解决该违规

**Input:** `/team-polish particle-storm`

**Expected behavior:**
1. Phase 1：performance-analyst 识别出 12ms 帧耗时 vs. 6ms 预算；报告 "FRAME BUDGET VIOLATION: particle-storm costs 12ms, budget is 6ms"，并给出标明每项负责人的优化清单
2. `AskUserQuestion` 呈现该违规；用户选择继续尝试优化
3. Phase 2：engine-programmer 实现引擎层面项，technical-artist 实现粒子项（在对整组的一次询问之后）；重新剖析读数为 9ms —— 有所降低但仍超预算："Optimization reduced cost to 9ms (was 12ms) — 3ms over budget. No further gains achievable without design changes."
4. Phase 3 与 Phase 4 与 Phase 2 并行运行（视觉与音频打磨）
5. Phase 5：qa-tester 运行回归与边界用例测试；全部通过
6. Phase 6：编排器收集结果；帧预算违规（9ms vs 6ms 预算）仍未解决
7. 结论：NEEDS MORE WORK
8. 报告列出具体的未解决问题及其严重程度："particle-storm frame cost (9ms) exceeds budget (6ms) by 3ms — requires design scope reduction or budget renegotiation"
9. Next Steps：在 `/sprint-plan update` 中安排遗留问题；修复后重新运行 `/team-polish`

**Assertions:**
- [ ] Phase 1 以具体数字标记帧预算违规（实际值 vs. 预算）
- [ ] Phase 2 明确报告优化后的指标（达到 9ms，仍超出 3ms）
- [ ] 当预算违规仍然存在时，结论为 NEEDS MORE WORK（而非 READY FOR RELEASE）
- [ ] 具体未解决问题按名称列出，并量化剩余差距
- [ ] Next Steps 引用 `/sprint-plan update` 来安排剩余修复
- [ ] Phase 3 与 Phase 4 仍然运行（打磨工作不因 Phase 2 的部分解决而放弃）
- [ ] Phase 5 的 qa-tester 仍然运行（回归测试独立于性能结果）

---

### Case 3: 无参数 —— 展示用法指引

**Fixture:**
- 任意项目状态

**Input:** `/team-polish`（无参数）

**Expected behavior:**
1. 技能检测到未提供参数
2. 输出用法指引：例如 "Usage: `/team-polish [feature or area to polish] [--review full|lean|solo]` — specify the feature or area to polish (e.g., `combat`, `main menu`, `inventory system`, `level-1`)"
3. 技能退出，不启动任何代理

**Assertions:**
- [ ] 未提供参数时，技能不启动任何代理
- [ ] 用法消息展示完整 argument-hint —— `/team-polish [feature or area to polish] [--review full|lean|solo]` —— 以及参数示例
- [ ] 技能不从项目文件中猜测功能
- [ ] 不使用 `AskUserQuestion` —— 输出为直接指引

---

### Case 4: 引擎层面瓶颈 —— engine-programmer 在 Phase 2 条件性启动

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- 正在打磨的功能：`open-world` 环境流式加载
- Phase 1 识别出一个性能瓶颈，其根因在渲染流水线中："draw call overhead is caused by the engine's scene tree traversal in the spatial indexer — this is an engine-level issue, not a game code issue"
- 性能预算已定义；渲染开销超出目标帧预算

**Input:** `/team-polish open-world`

**Expected behavior:**
1. Phase 1：performance-analyst 对场景做性能剖析；识别出帧预算违规；根因分析指向引擎层面渲染流水线（空间索引器遍历开销）
2. Phase 1 输出明确将根因归类为引擎层面
3. `AskUserQuestion` 呈现包含引擎层面根因的性能报告；用户在 Phase 2 之前批准
4. Phase 2：为优化清单上的引擎层面渲染项启动 engine-programmer（属于 `small` 集合），写入 `production/polish/open-world-engine-fixes-[date].md`；performance-analyst 不写代码
5. Phase 3 与 Phase 4 也与 Phase 2 并行运行（视觉与音频打磨）；engine-programmer 列出它将更改的引擎文件以及其他代理的文件，一次询问覆盖整组
6. engine-programmer 在得到同意后处理空间索引器遍历；提供剖析器验证，显示该修复降低了开销
7. Phase 5：qa-tester 运行回归测试，包含针对引擎层面变更的测试
8. Phase 6：编排器收集所有结果；若指标现已在预算内，结论为 READY FOR RELEASE；否则为 NEEDS MORE WORK

**Assertions:**
- [ ] 除非 Phase 1 明确识别出引擎层面根因，否则 Phase 2 不启动 engine-programmer
- [ ] 当 Phase 1 识别出引擎层面根因时，Phase 2 会启动 engine-programmer
- [ ] engine-programmer 的 Phase 2 Agent 调用与 Phase 3、4 的调用同时发起（而非顺序执行），且不重新启动 performance-analyst 去改代码
- [ ] 在针对 Phase 2–4 实现集的一次询问得到同意之前，engine-programmer 不编辑任何内容
- [ ] Phase 3 与 Phase 4 也与 Phase 2 并行运行（不推迟到 Phase 2 完成之后）
- [ ] engine-programmer 的输出包含对该修复的剖析器验证
- [ ] Phase 5 的 qa-tester 运行覆盖引擎层面变更的回归测试
- [ ] 结论正确反映包含引擎修复在内的所有指标现在是否满足预算

---

### Case 5: 发现回归 —— 打磨变更破坏了既有功能

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`、`workflow: standard`（因与 Case 2 相同的原因而固定）
- 正在打磨的功能：`inventory-ui`
- Phase 1–4 成功完成；性能与打磨变更已应用
- Phase 5：qa-tester 运行回归测试，发现 Phase 3 应用的某项着色器优化破坏了悬停时的物品高亮辉光效果 —— 这是打磨轮次之前一直正常工作的既有功能

**Input:** `/team-polish inventory-ui`（Phase 5 场景）

**Expected behavior:**
1. Phase 1–4 完成；打磨变更包含 technical-artist 的着色器优化
2. Phase 5：qa-tester 运行回归测试并检测到 "Item highlight glow on hover no longer renders — regression introduced by shader optimization in Phase 3"
3. qa-tester 将发现写入 `production/polish/inventory-ui-verification-[date].md`（无逐次写入提示），并在其返回契约中将该回归作为 CONCERNS/BLOCKED 行返回
4. 编排器确认验证文件存在，然后在 Phase 5 → Phase 6 的转换处，在对话中写出 qa-tester 的完整分析 —— 点名被破坏的行为与导致它的 Phase 3 着色器变更 —— 并通过 `AskUserQuestion` 以 qa-tester 的建议为选项捕获决策
5. Phase 6：该回归被列入遗留问题，附严重程度与建议
6. 结论：NEEDS MORE WORK
7. Next Steps：在 `/sprint-plan update` 中安排修复，并在修复后重新运行 `/team-polish`

**Assertions:**
- [ ] 回归在 Phase 6 签核之前呈现
- [ ] 报告中同时点名具体被破坏的行为与应负责的变更
- [ ] qa-tester 的发现写入 `production/polish/inventory-ui-verification-[date].md`，无需单独的批准提示
- [ ] Phase 5 → 6 转换处的 `AskUserQuestion` 将该回归与 qa-tester 提出的解决方案作为可选项呈现
- [ ] Phase 6 将该回归列为遗留问题并附严重程度
- [ ] 当回归存在且未解决时，结论为 NEEDS MORE WORK
- [ ] Next Steps 将修复指向 `/sprint-plan update` 与一次 `/team-polish` 重新运行 —— 不把会话内修复报告为已验证

---

### Case 6: 未承诺预算 —— NOT ASSESSED，而非 READY FOR RELEASE

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- `project.yaml` 未设置 `performance.target_framerate`、`performance.frame_budget_ms`、`performance.draw_call_limit` 或 `performance.memory_ceiling_mb` 中的任何一项，且没有设计文档为该领域声明预算
- 正在打磨的功能：`main-menu`；每个阶段都完成，qa-tester 未发现回归

**Input:** `/team-polish main-menu`

**Expected behavior:**
1. Phase 1：performance-analyst 通过 `/perf-profile` 对菜单做性能剖析；每个指标都报告为已测量但 `NOT ASSESSED` —— 没有承诺预算 —— 绝不说成在预算内，或用 16.67 ms 之类的占位值计算余量
2. Phase 2–5 正常运行；未发现任何超出预算之处，也没有回归
3. Phase 6：没有已知问题，但预算比较无法运行，因此结论为 NOT ASSESSED —— 而非 READY FOR RELEASE —— 报告点名每个未设置的 `performance.*` 键
4. Next Steps：在 `project.yaml` 中承诺预算并重新运行 `/team-polish`；不提议将 `/release-checklist` 作为下一步

**Assertions:**
- [ ] 结论为 NOT ASSESSED，而非 READY FOR RELEASE
- [ ] 报告点名每个未设置的 `performance.*` 键作为原因
- [ ] 没有任何指标被描述为在预算内，也不针对占位预算计算余量
- [ ] Next Steps 要求提供预算并重新运行，而非交接给 `/release-checklist`
- [ ] 同一次运行中若发现回归，则结论会变为 NEEDS MORE WORK —— 缺失预算不会掩盖已知问题

---

### Case 7: 默认 `individual` —— 优化清单交接给 `/dev-story`

**Fixture:**
- 已解析配置块：`team.size: individual`、`automation: collaborative`
- 预算已在 `project.yaml` 中承诺（同 Case 1）
- 正在打磨的功能：`crafting-menu`；Phase 1 发现一项由 technical-artist 负责的绘制调用超限，以及一条由 gameplay-programmer 负责的 crafting 逻辑脚本热路径 —— 无引擎层面根因

**Input:** `/team-polish crafting-menu`

**Expected behavior:**
1. 活动集行点名 performance-analyst + technical-artist；未启动行点名 sound-designer、qa-tester、engine-programmer 与 tools-programmer
2. Phase 1：performance-analyst 写入 `production/polish/crafting-menu-report-[date].md`，附优化清单，每一项都标明负责人
3. Phase 2：没有程序员活动，因此没有代理实现该脚本项 —— performance-analyst 也不实现它；绘制调用项并入 technical-artist 的 Phase 3 简报
4. 报告在 "Optimisation list handed to `/dev-story`: `production/polish/crafting-menu-report-[date].md`" 下列出 gameplay-programmer 项
5. Phase 6：音频打磨与加固未运行；若该脚本热路径使某项指标仍超预算，结论为 NEEDS MORE WORK，否则为 NOT ASSESSED
6. Next Steps：用 `/dev-story` 实现交接的项，然后重新运行 `/team-polish`

**Assertions:**
- [ ] 本次运行中没有代理为 gameplay-programmer 项改代码，performance-analyst 也不改任何东西
- [ ] 报告将优化清单记作已交接给 `/dev-story`，含路径与每项的负责人
- [ ] 在 `individual` 下结论绝不为 READY FOR RELEASE
- [ ] 交接项所针对的超预算指标会使结论为 NEEDS MORE WORK

---

### Case 8: Workflow Minimal —— NEEDS MORE WORK 归入简报的构建顺序

**Fixture:**
- 已解析配置块：`workflow: minimal`（来自 `modes.rigor: minimal`）、`team.size: small`（已固定，以便完整流水线运行）、`automation: collaborative`
- `design/game-brief.md` 存在并含构建顺序；没有 `production/sprints/` 文件夹
- 预算已在 `project.yaml` 中承诺（同 Case 1）
- 正在打磨的功能：`particle-storm`，设置与 Case 2 相同：优化后耗时为 9ms，预算为 6ms

**Input:** `/team-polish particle-storm`

**Expected behavior:**
1. Phase 0 解析 `workflow` 以及 `review_mode`、`automation` 与 `team.size`
2. 运行按 Case 2 的方式推进至 Phase 6，结论为 NEEDS MORE WORK，并列出 3ms 差距
3. Next Steps：将遗留问题加入简报的构建顺序，因为 `minimal` 没有冲刺，然后在修复后重新运行 `/team-polish`

**Assertions:**
- [ ] `workflow` 是 Phase 0 解析的键之一
- [ ] 安排步骤说明要将遗留问题加入简报的构建顺序
- [ ] 不推荐 `/sprint-plan update`
- [ ] 仍点名在修复后重新运行 `/team-polish`
- [ ] 结论与遗留问题清单与 Case 2 相同

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual): performance-analyst + technical-artist` 行与一行 `Not spawned this run:` 开始，后者点名 sound-designer、qa-tester、engine-programmer 与 tools-programmer —— 这一切发生在任何代理启动之前
- [ ] Phase 1（评估）必须先完成，其他任何阶段才能开始
- [ ] 在 `collaborative` 模式下，每个阶段输出之后、下一阶段启动之前使用 `AskUserQuestion`
- [ ] 只要其代理在活动集中，Phase 3 与 Phase 4 就与 Phase 2 并行启动（不推迟）
- [ ] 只有当 Phase 1 明确识别出引擎层面根因时才启动 engine-programmer，且仅在 `small` 或 `studio` 下
- [ ] performance-analyst 产出优化清单且从不实现它；负责人不在活动集中的项会被记作已交接给 `/dev-story`
- [ ] Phase 2–4 的实现文件作为一组一次性询问 —— 而非每阶段一次
- [ ] 编排器不直接写入任何文件 —— 所有写入都委托给子代理
- [ ] 子代理仅对其指定的 `production/polish/` 路径跳过逐次写入提示；任何其他写入都需要 "May I write" 询问
- [ ] 指定产出物在磁盘上缺失的阶段被视为失败，而非完成
- [ ] 任何代理的 BLOCKED 状态都会立即呈现 —— 不被静默跳过
- [ ] 当部分代理完成而其他代理阻塞时，始终产出部分报告
- [ ] 结论只能是 READY FOR RELEASE、NOT ASSESSED 或 NEEDS MORE WORK 之一 —— 已知问题即为 NEEDS MORE WORK，即便其他内容未检查；只有当每个已测量指标都有承诺预算且每个阶段都运行时，才可能得出 READY FOR RELEASE
- [ ] 在 `team.size: individual` 下，sound-designer 的音频打磨与 qa-tester 的加固被记为未运行，因此除非已知问题使其变为 NEEDS MORE WORK，结论为 NOT ASSESSED
- [ ] NEEDS MORE WORK 结论始终列出具体遗留问题及其严重程度、可测量时的测得差距与建议
- [ ] Next Steps 交接引用 `/release-checklist`（成功时）、`/sprint-plan update`（在 `workflow: minimal` 下以简报的构建顺序替代）与一次 `/team-polish` 重新运行（失败时），以及在交接给发布之前的 `/gate-check`，并在 NOT ASSESSED 时要求补齐缺失预算或阶段后再重新运行
- [ ] 在 `team.size: studio` 下，Phase 5 的 qa-tester 会被要求找出被打磨功能如何失效，而非确认其成立，报告中说明已运行对抗性检验；不增加引擎专家

---

## Coverage Notes

- tools-programmer 可选代理（用于内容流水线工具修复）未
  单独测试 —— 它遵循与 engine-programmer 相同的条件性启动模式，
  只在 Phase 1 将某个原因追溯到内容创作工具时，于 Phase 2 在 `small` 或 `studio` 下
  被调用。
- Error Recovery Protocol 中的 "Retry with narrower scope" 与 "Skip this agent"
  解决路径未单独测试 —— 它们遵循与 Case 2 和 Case 5 中验证过的
  相同的 `AskUserQuestion` + 部分报告模式。
- Phase 6 签核逻辑（收集并比较所有指标）由 Case 1 与 Case 2 隐式
  验证。READY FOR RELEASE 与 NEEDS MORE WORK 的区分在这些用例中
  双向检验，NOT ASSESSED 则由 Case 6 检验。
- `individual` 路径 —— 音频打磨与加固未运行、优化清单
  交接给 `/dev-story` —— 由 Case 7 覆盖。
- 浸泡测试与压力测试（Phase 5）由 Case 1 的
  qa-tester 输出隐式验证。Case 5 聚焦 Phase 5 的回归检测方面。
- Phase 5 的 "minimum spec hardware" 测试路径未单独测试 —— 它在硬件
  可用时遵循相同的 qa-tester 委托模式。
- `studio` 的附加内容（对抗性评审轮次）在 Protocol Compliance 中作了断言，
  但没有专门用例。
