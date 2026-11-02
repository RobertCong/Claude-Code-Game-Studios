# Agent Test Spec: qa-lead

## Agent Summary
**Domain owned:** 测试策略、QL-STORY-READY 闸门、QL-TEST-COVERAGE 闸门、缺陷严重度分级、发布质量闸门。
**Does NOT own:** 功能实现（程序员）、游戏设计决策、创意方向、制作排期。
**Gate IDs handled:** QL-STORY-READY, QL-TEST-COVERAGE.

---

## Static Assertions (Structural)

通过读取该代理的 `.claude/agents/qa-lead.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及测试策略、故事就绪度、覆盖率、缺陷分级——而非泛泛而谈）
- [ ] `tools:` 包含用于故事文件、测试文件和 coding-standards 的 Read；Bash 用于在每次 QA 交接前运行 `/smoke-check`；Write/Edit 用于它产出的 QA 计划和签署报告，每次写入都在其协作协议中由用户批准把关
- [ ] 模型档位为 `inherit`——frontmatter `model:` 恰为 `inherit`（档位：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对实现决策或游戏设计拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一个 Logic 类型的「玩家受到危险地块伤害」故事被提交进行就绪度检查。闸门上下文传入了 `.claude/docs/director-gates/ql-story-ready.md` 指定的每一项输入：故事文件路径（`production/epics/hazards/story-002-hazard-damage.md`）、故事类型（Logic）、逐字验收标准——(1) 玩家生命值按危险的伤害值减少，(2) 发出携带伤害量的 `damaged` 事件，(3) 玩家在 0.5 秒模拟时间内不能再次受伤（无敌窗口）——以及故事覆盖的 GDD 需求（`TR-hazards-002`：「危险地块在接触时对玩家造成伤害；每次命中给予 0.5 秒无敌」）。全部三条 AC 都可测量且具体。请求标记为 QL-STORY-READY。
**Expected:** 返回结论 ADEQUATE，理由确认全部三条 AC 都具体且每条都可由自动化测试验证。
**Assertions:**
- [ ] 结论恰为 ADEQUATE / GAPS / INADEQUATE 之一（QL-STORY-READY 的结论词汇）——闸门指定的每项输入都已提供，因此 NOT ASSESSED 不适用
- [ ] 明确陈述结论词 `ADEQUATE`——`/story-readiness` 和 `/create-stories` 依据裸结论词分支
- [ ] 理由逐一处理三条 AC，并确认每条都可由自动化测试验证（该闸门的 Logic 故事检查）
- [ ] 输出保持在 QA 范围内——不对该机制是否设计良好发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 开发者请 qa-lead 为新物理系统实现自动化测试框架（harness）。
**Expected:** 代理不承担框架代码本身。它定义框架必须验证什么，并将编写工作转交给 qa-tester——其测试编写与执行的委托人，并与 lead-programmer 协调该物理系统的可测试性。
**Assertions:**
- [ ] 不自行编写框架代码
- [ ] 明确指出 `qa-tester`（其 Delegation Map 中测试编写与执行的所有者）是实现者；可将 `lead-programmer` 列为可测试性联系人
- [ ] 它补充的任何测试策略（框架必须验证什么）都作为输入交给实现者——其回答不含框架代码

### Case 3: 闸门结论——正确的词汇
**Scenario:** 一个「战斗感觉响应灵敏且有打击感」的故事被提交进行就绪度检查。唯一的验收标准写道：「Combat should feel good to the player.」这是主观且不可测量的。请求标记为 QL-STORY-READY。
**Expected:** 返回结论 INADEQUATE，具体指出不可测量的 AC，并就如何使其可测试给出指导（例如「输入到命中反馈延迟 ≤ 100ms」）。
**Assertions:**
- [ ] 结论恰为 ADEQUATE / GAPS / INADEQUATE 之一——不是自由文本
- [ ] 明确陈述结论词 `INADEQUATE`——单条完全主观的 AC 没有任何可细化的内容，因此不是 GAPS；且它发现的问题以闸门词汇为准，因此即使场景未点名 GDD 需求也不是 NOT ASSESSED
- [ ] 理由指出未满足可测量性要求的具体 AC
- [ ] 就如何重写 AC 使其可测试给出可执行指导——用可测量基准替代「感觉良好」

### Case 4: 冲突上报——正确的上级
**Scenario:** 项目运行 `qa.level: standard`。一个 Logic 类型故事的自动化测试断言「敌人巡逻路径在 5 秒墙钟时间内访问所有航点」。gameplay-programmer 认为时间波动会导致测试不稳定，想换用人工走查；qa-lead 需要该故事的自动化证据。双方对前进方式意见不一。
**Expected:** qa-lead 同意墙钟断言违反了项目的确定性规则，但不接受对 Logic 故事使用人工走查——它要求确定性重写（例如固定步长模拟或注入时钟）。如果分歧仍然存在，它上报给 technical-director——其质量标准汇报线，也是两个代理的共同上级。
**Assertions:**
- [ ] 指出「within 5 seconds」墙钟断言是 coding-standards.md 的 Determinism 规则所禁止的时间相关断言——不为其辩护为可接受
- [ ] 不单方面推翻 gameplay-programmer 关于测试不稳定的担忧
- [ ] 若未解决，上报给 `technical-director`（qa-lead 在质量标准上的「Reports to」；coordination-rules.md 规则 3 下的共同上级）——而非 lead-programmer，后者是 gameplay-programmer 自己的主管
- [ ] 不放弃覆盖率要求——Logic 故事仍需要一个通过的自动化测试，因此它要求确定性替代方案，而非接受人工走查

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 代理收到一个闸门上下文块，其中包含 coding-standards.md 的测试标准章节，该章节规定：Logic 故事需要阻塞式自动化单元测试，Visual/Feel 故事需要阻塞式留存截图 + 主管签署，Config/Data 故事需要通过冒烟检查（建议性）。上下文声明项目运行 `qa.level: standard`。一个分类为「Logic」类型的故事被提交，但仅以人工走查文档作为证据。
**Expected:** 评估引用 coding-standards.md 中的具体测试证据要求，指出「Logic」故事需要自动化单元测试（而不仅是人工走查），并引用该具体要求返回 INADEQUATE。
**Assertions:**
- [ ] 引用所提供上下文中具体的故事类型分类（「Logic」）
- [ ] 引用 coding-standards.md 中 Logic 故事的具体证据要求（自动化单元测试）
- [ ] 指出所提交的证据类型（人工走查）对该故事类型不足
- [ ] 不将建议性级别的要求当作阻塞性要求

### Case 6: 闸门输入缺失——NOT ASSESSED
**Scenario:** QL-STORY-READY 被调用评审一个 Logic 类型故事「冲刺时耐力消耗」，附带其文件路径、类型和两条具体且可测量的验收标准——但没有 GDD 需求：上下文省略了故事覆盖的 TR-ID 和文本，故事文件也未提及。
**Expected:** 返回 `QL-STORY-READY: NOT ASSESSED`，点名缺失的输入（故事覆盖的 GDD 需求），而非 ADEQUATE——对照无人提供的需求的就绪度尚未得到确立。
**Assertions:**
- [ ] 结论为 `NOT ASSESSED`——不是 ADEQUATE、GAPS 或 INADEQUATE——因为它能读取的标准未显示问题
- [ ] 点名缺失的输入：故事覆盖的 GDD 需求（TR-ID 和文本）
- [ ] 不编造或臆测 GDD 需求来完成检查

### Case 7: `qa.level: minimal`——测试豁免，截图不豁免
**Scenario:** 被要求为一个冲刺的 QA 计划设置测试证据闸门时，代理被告知项目运行 `qa.level: minimal`（默认值）。该冲刺包含一个没有测试文件的 Logic 故事和一个 UI 故事。
**Expected:** 应用所给定的 `qa.level`（其起草工作流会询问 `qa.level` 或 `testing.strict` 是否改变任何闸门级别）：Logic 故事缺少测试不是阻塞项——在 `minimal` 下测试被豁免——而 UI 故事仍需要为其触及的每个屏幕留存截图。
**Assertions:**
- [ ] 在 `qa.level: minimal` 下，不将 Logic 故事缺少测试标记为阻塞项或硬性闸门
- [ ] 说明 `qa.level: minimal` 豁免测试证据
- [ ] 仍要求 UI 故事的留存截图——外观永不豁免

---

## Protocol Compliance

- [ ] QL-STORY-READY 结论仅使用 ADEQUATE / GAPS / INADEQUATE——或当闸门指定的输入缺失且未发现问题时，返回 NOT ASSESSED 并说明该输入
- [ ] QL-TEST-COVERAGE 结论仅使用 ADEQUATE / GAPS / INADEQUATE——或当闸门指定的输入缺失且未发现问题时，返回 NOT ASSESSED 并说明该输入
- [ ] 保持在声明的 QA 与测试策略领域内
- [ ] 将未解决的技术标准争议上报给 technical-director
- [ ] 将每个闸门结论陈述为明确的结论词——传入多个故事时每个故事一个——而非由行文暗示的结论
- [ ] 不做出有约束力的实现或游戏设计决定

---

## Coverage Notes
- 未覆盖 QL-TEST-COVERAGE（冲刺或里程碑的整体覆盖率评估）——当覆盖率报告可用时应补充专门用例。
- 此处未覆盖缺陷严重度分级（S1–S4 分类）——推迟到 /bug-triage 技能集成。
- 未覆盖发布质量闸门执行（崩溃率、严重缺陷数量、性能基准）。
- 未覆盖 QL-STORY-READY 与故事 Done 标准（/story-done 技能）之间的交互。
