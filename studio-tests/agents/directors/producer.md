# Agent Test Spec: producer

## Agent Summary
**Domain owned:** 范围管理、冲刺规划验证、里程碑跟踪、史诗（epic）优先级排序、制作阶段闸门。
**Does NOT own:** 游戏设计决策（creative-director / game-designer）、技术架构（technical-director）、创意方向。
**Gate IDs handled:** PR-SCOPE, PR-SPRINT, PR-MILESTONE, PR-EPIC, PR-PHASE-GATE.

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/producer.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及范围、冲刺、里程碑、制作——而非泛泛而谈）
- [ ] `tools:` 包含 Write 和 Edit（它按 Output Format 编写冲刺计划并维护风险登记册），并且只有在预加载技能需要时才包含 Bash（`skills:` 包含 `scope-check`，后者会读取 `git log`）
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对设计决策或技术架构拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一份冲刺计划被提交用于 Sprint 7。该计划在 2 周内为 4 名团队成员承诺 9 个故事点，列明了依赖，且没有单个故事超过 3 天。最近 3 个冲刺的历史速度平均为 11.5 点；没有积压债务被带入，且里程碑约束对本冲刺没有额外要求。请求标记为 PR-SPRINT。
**Expected:** 返回 `PR-SPRINT: REALISTIC`，理由指出负载低于历史速度，同时保留了其 Sprint Planning Rules 要求的 20% 缓冲（9 ≤ 11.5 的 80%）。
**Assertions:**
- [ ] 结论恰为 REALISTIC / CONCERNS / UNREALISTIC 之一
- [ ] 结论文本格式为 `PR-SPRINT: REALISTIC`
- [ ] 理由将承诺的 9 点与 11.5 点的速度以及 20% 缓冲规则进行比较——而非泛泛的「看起来可行」
- [ ] 输出保持在制作范围内——不对故事是否设计良好或技术是否可靠发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 团队成员请 producer 评估游戏「基于重量的背包」机制是否有趣且吸引人。
**Expected:** 代理拒绝评估游戏手感，并转交给 game-designer 或 creative-director。
**Assertions:**
- [ ] 不对该机制的设计质量做出任何有约束力的评估
- [ ] 明确指出 `game-designer` 或 `creative-director` 是正确处理者
- [ ] 其任何评论都只涉及制作方面的影响（例如该机制依赖哪些其他系统）——绝不涉及该机制是否有趣、吸引人或设计良好

### Case 3: 闸门结论——正确的词汇
**Scenario:** 一份范围估算被提交，面向一位拥有 4 个月时间线的独立开发者。MVP 原本是两个系统（移动和战斗），估算为 3 个月。修订后的 MVP 又增加了三个系统——制作、天气和阵营声望——使估算恰好达到 4 个月：占用整个时间线，没有为计划外工作留下任何缓冲。这三个系统都可以移到下一个范围层级而不破坏 MVP。请求标记为 PR-SCOPE。
**Expected:** 返回 `PR-SCOPE: OPTIMISTIC`——该闸门的中间结论，并给出具体调整——因为只有在一切顺利时 MVP 才能装下：点名新增的三个系统，并建议将哪些移到更晚的范围层级以恢复缓冲。不是 UNREALISTIC：估算未超过时间线，因此两者都不必修改。
**Assertions:**
- [ ] 结论恰为 REALISTIC / OPTIMISTIC / UNREALISTIC 之一（PR-SCOPE 的结论词汇）——不是 CONCERNS，也不是自由文本
- [ ] 结论文本格式为 `PR-SCOPE: OPTIMISTIC`
- [ ] 理由点名消耗掉缓冲的那三个具体系统
- [ ] 不评估这些系统是否是好的设计——只评估它们是否适配计划

### Case 4: 冲突上报——正确的上级
**Scenario:** game-designer 想加入一个后期机制（影响所有玩法系统的动态天气），technical-director 警告这需要额外 3 个冲刺。game-designer 与 technical-director 就是否推进意见不一。
**Expected:** Producer 不在该机制是否值得加入（设计决策）或是否可行（技术决策）上选边。Producer 量化制作影响（延迟 3 个冲刺、里程碑滑期风险），向用户呈现取舍，并遵循 coordination-rules.md 规则 3：game-designer 与 technical-director 没有共同上级，而该机制是否值得其成本属于设计冲突，因此交给 creative-director——当创意意图与制作产能冲突时，范围问题的裁决者。
**Assertions:**
- [ ] 用具体数字量化制作影响（冲刺数、里程碑日期滑期）
- [ ] 不做出有约束力的设计或技术决定
- [ ] 向用户呈现冲突，并清楚说明范围影响
- [ ] 依照 coordination-rules.md 规则 3（无共同上级；属设计冲突）将冲突上报给 `creative-director`——而非 technical-director，也不直接抛给用户，仿佛不存在上报目标

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 代理收到一个闸门上下文块，其中包含当前里程碑截止日期（8 周后，双周冲刺）和最近 4 个冲刺的速度数据（8、10、9、11 点）。一份冲刺计划被提交，共 14 个故事点，分为五个故事：玩家移动（3）、跳跃缓冲（2，依赖玩家移动）、敌人巡逻 AI（5）、暂停菜单（2）和存档槽（2）。请求标记为 PR-SPRINT。
**Expected:** 评估使用所提供的速度数据，指出 14 点远超约 9.5 点的平均值（在保留 20% 缓冲后更是如此），返回 `PR-SPRINT: UNREALISTIC` 并点名要推迟的故事，同时引用 8 周里程碑窗口来评估超支对里程碑的影响。
**Assertions:**
- [ ] 使用所提供上下文中的具体速度数值（而非泛泛估算）
- [ ] 在产能评估中引用 8 周截止日期
- [ ] 计算或估算里程碑窗口内的剩余冲刺数（四个双周冲刺），这是其「至少提前 2 个冲刺标记里程碑风险」职责的要求
- [ ] 从提供的五个故事中按标题点名要推迟的故事，且绝不保留依赖于玩家移动的跳跃缓冲却推迟玩家移动
- [ ] 不给出与所提供截止日期和速度数据脱节的泛泛范围建议

### Case 6: 缺少闸门输入——NOT ASSESSED
**Scenario:** 一份冲刺计划被提交，包含五个故事——标题、估算和依赖，排序正确——以及里程碑约束，但没有团队产能：上下文未提供，且 `production/sprints/` 中没有更早的冲刺可供推导速度。请求标记为 PR-SPRINT。
**Expected:** 返回 `PR-SPRINT: NOT ASSESSED`，将团队产能列为它无法读取的输入。故事负载是否现实取决于衡量它的产能，因此不给出可行性结论。
**Assertions:**
- [ ] 结论文本为 `PR-SPRINT: NOT ASSESSED`——不是 REALISTIC，也不臆测为 UNREALISTIC
- [ ] 将团队产能列为缺失的输入
- [ ] 不编造产能或速度数值来评判负载

### Case 7: `minimal` 下的阶段闸门——简报中的 Build order 就是计划
**Scenario:** `/gate-check production` 在 `workflow: minimal` 下运行时，显式设置 `review_mode: lean` 来运行评审小组，因此仅生成 producer 一人处理 PR-PHASE-GATE。上下文给出目标阶段（Production）、档位，以及该档位下闸门要求的产出物：一份填写完整的 `design/game-brief.md` 及其 Build order，以及 `production/epics/` 下的故事。两者均存在——Build order 列出四个 MVP 功能，前三个相互独立，第四个依赖第一个，并且按该顺序每个功能各有一个故事，没有 Blocked。`team.size` 为 `individual`；简报声明 MVP 的六周目标。冲刺计划和冲刺产能以 "not required at `workflow: minimal`" 传入。
**Expected:** 返回 `PR-PHASE-GATE: READY`——在该档位下 Build order 就是计划，其依赖已排序，四个故事适合独立开发者的六周。缺失的冲刺计划和速度不构成发现。
**Assertions:**
- [ ] 结论恰为 READY / CONCERNS / NOT READY 之一（PR-PHASE-GATE 的结论词汇），格式为 `PR-PHASE-GATE: READY`
- [ ] 将 Build order 作为计划来评判，并检查其依赖顺序（第四个功能在第一个之后）
- [ ] 不将缺失的冲刺计划或速度作为关注项提出，也不对其回答 NOT ASSESSED——它们是以 "not required at `workflow: minimal`" 传入的
- [ ] 不编造冲刺产能来评判负载

---

## Protocol Compliance

- [ ] 返回所调用闸门定义文件列出的结论词汇——PR-SPRINT 和 PR-EPIC 为 REALISTIC / CONCERNS / UNREALISTIC；PR-SCOPE 为 REALISTIC / OPTIMISTIC / UNREALISTIC；PR-MILESTONE 为 ON TRACK / AT RISK / OFF TRACK；PR-PHASE-GATE 为 READY / CONCERNS / NOT READY；任何闸门在缺少其指定输入时返回 `NOT ASSESSED` 并说明该输入
- [ ] 保持在声明的制作领域内
- [ ] 通过量化范围影响并向用户呈现来上报设计/技术冲突
- [ ] 在输出中使用闸门 ID（例如 `PR-SPRINT: REALISTIC`），而非行文中的散文式结论
- [ ] 不做出有约束力的游戏设计或技术架构决定
- [ ] 在阶段闸门上，将调用技能以 "none" 传入、但目标阶段所需的产出物视为一项发现（NOT READY 或 CONCERNS）；将以 "not expected before [phase]" 或 "not required at `workflow: [tier]`" 传入的产出物视为无发现——它评判的是即将进入阶段的就绪度，而非更靠后阶段

---

## Coverage Notes
- PR-EPIC（`/create-epics` 在写入任何史诗前运行的史诗结构评审）尚无用例。
- 未覆盖 PR-MILESTONE（里程碑健康度评审）——推迟到与 /milestone-review 技能的集成。
- PR-PHASE-GATE 仅覆盖了 `minimal` 档位（Case 7）；针对冲刺计划评判的 `standard`/`full` Production 闸门尚无用例。
- 此处未覆盖多冲刺燃尽图与速度趋势分析。
