# Agent Test Spec: game-designer

## Agent Summary
**Domain owned:** 核心循环设计、成长系统、战斗机制规则、经济设计、面向玩家的规则与交互、`design/gdd/` 中的机制 GDD。
**Does NOT own:** 代码实现（lead-programmer / gameplay-programmer）、美术与音频方向（art-director / audio-director）、最终叙事内容（narrative-director——与之协调）、详细的公式数学（systems-designer——向其委派）。
**Gate IDs handled:** None. 设计评审结论来自 `/design-review` 技能（APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED / NOT ASSESSED）；当该技能将 game-designer 作为专家生成时，代理返回发现。

---

## Static Assertions (Structural)

通过读取该代理的 `.claude/agents/game-designer.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及核心循环、成长、战斗规则、经济、面向玩家的设计——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit, WebSearch，且 `disallowedTools:` 列出 Bash
- [ ] 模型档位为 `inherit`——frontmatter `model:` 恰为 `inherit`（档位：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对代码实现、视觉美术风格或独立的叙事设定决策拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 项目的 `modes.workflow` 为 `full`。用户请 game-designer 设计一个「基于耐力的闪避」机制：玩家拥有耐力池，每次闪避消耗耐力，不闪避时耐力回复，闪避提供短暂的无敌窗口。
**Expected:** 遵循其 Question-First 工作流——询问闪避应让玩家获得何种感受以及它如何与支柱关联，提出 2–4 个选项并附推荐，然后按 Design Document Standard 起草 GDD，将其可调数值作为调参旋钮暴露，并在每次写入前询问。
**Assertions:**
- [ ] 在提出设计前询问澄清问题（预期的玩家体验、与支柱的关联），并提出 2–4 个选项及推荐，将选择留给用户
- [ ] 草稿使用 Design Document Standard 的八个章节：Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria
- [ ] Tuning Knobs 将每个数值（耐力池、闪避消耗、回复速率、无敌时长）归类为 feel、curve 或 gate，并将其放在外部数据文件中，而非硬编码
- [ ] 在创建文件前询问「May I create [filepath] with the section skeleton?」，在写入 `design/gdd/` 下每个章节前询问「May I write this section to [filepath]?」；不提供实现代码或美术方向

### Case 2: 领域外请求——转交或上报
**Scenario:** 团队成员请 game-designer 撰写世界内设定解释，说明耐力系统为何存在（例如游戏世界中角色具有耐力上限的叙事原因）。
**Expected:** 代理拒绝撰写叙事/设定内容，并转交给 writer 或 narrative-director。
**Assertions:**
- [ ] 不撰写叙事或设定内容
- [ ] 明确指出 `writer` 或 `narrative-director` 是正确处理者
- [ ] 它补充的任何设计意图（例如「耐力系统应强化身体现实主义的主题」）都作为给叙事团队的输入提出，而非直接写成设定本身

### Case 3: 评审发现——具体，结论留给评审技能
**Scenario:** `/design-review` 在全模式下生成 game-designer 作为对抗性专家，评审 `design/gdd/environmental-hazards.md`。生成提示写道：「Your job is NOT to validate this design — your job is to find problems. Anchor your review to the Player Fantasy stated in Section B.」玩家幻想是「世界危险但公平——每个危险都可读且可规避」。该 GDD 定义了三种危险类型（火、酸、电），但未规定玩家同时处于多个危险中时会发生什么、危险在闪避无敌窗口期间命中时会发生什么，以及伤害频率（每秒、每 tick、进入时）。
**Expected:** 返回具体发现，点名三个未定义的边界情况，并将其与所述玩家幻想挂钩，作为需要填补的缺口而非对该机制的否定。它返回发现而非结论——`/design-review` 给出结论。
**Assertions:**
- [ ] 点名每个缺失的边界情况：同时多危险暴露、闪避无敌期间的危害，以及未定义的伤害频率
- [ ] 至少将一个缺口与所述玩家幻想挂钩（例如未定义的伤害频率使危险的威胁不可读，违背「可读且可规避」）
- [ ] 将缺口表述为 GDD 中需要定义的规则（要指定什么），而非对该机制的否定，也不是实现建议
- [ ] 向评审返回发现，而非自打 APPROVED / NEEDS REVISION 印记

### Case 4: 冲突上报——正确的上级
**Scenario:** systems-designer 提出一个含 6 个变量、缩放交互复杂的伤害公式，认为它能带来最佳的调参粒度。game-designer 认为该公式对玩家而言过于复杂、难以直觉理解，希望采用更简单的 2 变量版本。
**Expected:** game-designer 拥有概念规则与玩家体验意图（「伤害应对玩家而言可理解」），但将公式粒度问题交给 systems-designer。如果双方无法解决分歧（一方要复杂、一方要简单），则上报给 creative-director 进行玩家体验裁决。
**Assertions:**
- [ ] 清楚陈述玩家体验意图（直观的伤害、玩家能动性）
- [ ] 将公式粒度决策交给 `systems-designer`
- [ ] 将未解决的分歧上报给 `creative-director`，由玩家体验裁决者裁定
- [ ] 不单方面将公式结构强加给 systems-designer

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 请求中包含游戏的三条支柱：「玩家作者性」「后果永久性」和「世界响应性」。一份「带传承加成的永久死亡」新机制规格被提交供该代理评估。
**Expected:** 评估对照全部三条所提供支柱评价该机制——永久死亡如何支持玩家作者性、传承加成如何体现或柔化后果永久性、世界如何响应玩家的死亡。直接使用支柱词汇，并标记支柱张力供用户决定。
**Assertions:**
- [ ] 在评估中按名称引用全部三条所提供的支柱
- [ ] 明确评估该机制对每条支柱的贡献
- [ ] 不生成泛泛的游戏设计建议——每一点都按名称与所提供支柱之一挂钩；框架术语（MDA、SDT）可支持某一点，但绝不取代它所涉及的支柱
- [ ] 至少标记一个具体的支柱张力（例如传承加成柔化了「后果永久性」），作为需用户决策的问题，而非静默自行解决

### Case 6: `modes.workflow: standard` 下的章节集合
**Scenario:** 与 Case 1 相同的「基于耐力的闪避」请求，但项目的 `modes.workflow` 为 `standard`。
**Expected:** 起草 `standard` 要求的五个章节——Overview、Detailed Rules、Edge Cases、Dependencies、Acceptance Criteria——外加 Formulas，因为闪避定义了数值规则（耐力消耗、回复速率、无敌时长）。
**Assertions:**
- [ ] 草稿包含 Overview、Detailed Rules、Edge Cases、Dependencies 和 Acceptance Criteria——Dependencies 未被丢弃
- [ ] 包含 Formulas，因为该机制定义了数值规则
- [ ] 不将 Player Fantasy 或 Tuning Knobs 视为该档位的必需章节

---

## Protocol Compliance

- [ ] 按 Design Document Standard 的章节起草机制文档，并在写入 `design/gdd/` 前逐章节询问
- [ ] 保持在声明的游戏设计领域内
- [ ] 设计 vs. 公式冲突未解决时上报给 creative-director
- [ ] 不做出有约束力的代码实现、视觉美术或独立设定决策
- [ ] 提供可执行的设计反馈，而非实现处方

---

## Coverage Notes
- 未覆盖经济设计评审（资源消耗点、来源、通胀预防）——应补充一个专门用例。
- 未覆盖成长系统评审（XP 曲线、解锁闸门、玩家强度轨迹）。
- 未覆盖直接的「评审这份 GDD」请求——设计评审结论来自用户运行的 `/design-review`。
- 未覆盖 `modes.workflow` 为 `minimal` 时的机制撰写，此时没有 GDD，`design/game-brief.md` 就是设计记录。
- 未覆盖跨多个互连系统的核心循环验证（而非仅单一机制）——推迟到 /review-all-gdds 集成。
- 与 systems-designer 就公式归属边界的协调协议可通过补充用例得到改进。
