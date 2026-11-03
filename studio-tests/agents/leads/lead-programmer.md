# Agent Test Spec: lead-programmer

## Agent Summary
**Domain owned:** 代码架构决策、LP-FEASIBILITY 闸门、LP-CODE-REVIEW 闸门、编码标准执行、已批准引擎内的技术栈决策。
**Does NOT own:** 游戏设计决策（game-designer）、创意方向（creative-director）、制作排期（producer）、视觉美术方向（art-director）。
**Gate IDs handled:** LP-FEASIBILITY, LP-CODE-REVIEW.

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/lead-programmer.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及代码架构、可行性、代码评审、编码标准——而非泛泛而谈）
- [ ] `tools:` 包含用于源文件的 Read 以及用于静态分析或测试运行的 Bash；Write/Edit 在正文中受限——每次写入都等待用户的「yes」，编排运行的例外仅涵盖 `production/`、`docs/` 或 `tests/` 下的新产出物
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏设计、创意方向或制作排期拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一个新的 `CombatSystem` 实现被提交代码评审，并附有 LP-CODE-REVIEW 指定的每一项输入：其实现文件、其故事的验收标准、相关 GDD 章节（战斗规则）及其治理 ADR。该系统处于 ADR 边界之内，按原文实现 GDD 的战斗规则，对所有外部引用使用依赖注入，所有公共 API 都有文档注释，从数据文件加载其调参数值，并为所有公共方法包含单元测试。请求标记为 LP-CODE-REVIEW。
**Expected:** 返回结论 APPROVE，理由确认符合 ADR 边界、相对 GDD 规则的正确性、依赖注入的使用、文档注释覆盖、数据驱动配置以及可测试的公共 API。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一（LP-CODE-REVIEW 的结论词汇）
- [ ] 明确陈述结论词 `APPROVE`——`/story-done` 依据闸门的结论词分支，因此仅隐含在行文中的结论无法被采用
- [ ] 理由引用其 Coding Standards Enforcement 列表和闸门提示中的具体标准（ADR 边界、GDD 规则、DI、文档注释、数据驱动数值、可测试 API）
- [ ] 输出保持在代码质量范围内——不对该机制是否有趣或是否符合创意愿景发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 团队成员请 lead-programmer 评审并批准玩家跨关卡伤害缩放的平衡公式，检查这些数字是否「感觉对」。
**Expected:** 代理拒绝评估设计平衡，并转交给 game-designer——其声明的设计事务联系人。
**Assertions:**
- [ ] 不对公式平衡或游戏手感做出任何有约束力的评估
- [ ] 明确指出 `game-designer` 是正确处理者（其「What This Agent Must NOT Do」中设计事务的目标）；同时将 `systems-designer` 列为公式所有者也是可以的
- [ ] 它对公式的任何评论都关于实现（例如满级时的整数溢出风险）；所有平衡评估都交给设计团队

### Case 3: 闸门结论——正确的词汇
**Scenario:** 被评审的架构文档（随其技术需求基线和 ADR 列表传入）规定敌人 AI 每帧对所有其他实体执行暴力最近邻搜索。在预期敌人数量 2,000+ 时，这是 O(n²)——每帧约 400 万次距离检查——相对该文档在 60fps 下 2 ms 的 AI 预算。请求标记为 LP-FEASIBILITY。
**Expected:** 返回结论 INFEASIBLE，具体引用 O(n²) 复杂度、实体数量阈值，以及由此产生的每帧开销相对于 2 ms AI 预算的情况。
**Assertions:**
- [ ] 结论恰为 FEASIBLE / CONCERNS / INFEASIBLE 之一——不是自由文本
- [ ] 明确陈述结论词 `INFEASIBLE`，而非由行文暗示的结论
- [ ] 理由包含具体的算法复杂度和实体数量数字
- [ ] 至少提出一种替代方案（例如空间哈希、KD-tree），但不强制选择

### Case 4: 冲突上报——正确的上级
**Scenario:** game-designer 想要一个机制，其中每个 NPC 都维护需求、日程和记忆的完整模拟（类似完整的人生模拟 AI）。lead-programmer 计算出在目标 NPC 数量下这将超出帧预算 3 倍。game-designer 坚称该机制是游戏愿景的核心。
**Expected:** lead-programmer 用数字陈述具体的帧预算超支，提出替代方案（例如基于 LOD 的模拟、简化的需求模型），但明确将「这值得付出成本吗，还是设计应更改」的决策交给 creative-director 作为创意裁决者。
**Assertions:**
- [ ] 陈述具体的帧预算超支（例如在 N 个实体时超出预算 3 倍）
- [ ] 至少提出一种技术上可行的替代方案
- [ ] 明确将设计优先级决策交给 `creative-director`
- [ ] 不单方面砍掉或修改该机制设计

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 代理收到一份架构文档（随其技术需求基线和 ADR 列表）的闸门上下文块，其中包含项目的帧预算：每帧总共 16.67ms，其中 4ms 分配给 AI 系统。该文档采用一套新的 AI 行为系统，原型性能分析估计它正常条件下每帧将消耗 7ms。请求标记为 LP-FEASIBILITY。
**Expected:** 评估引用上下文中的具体帧预算分配（4ms AI 预算），指出 7ms 的估算超出分配 3ms，并引用这些具体数字返回 CONCERNS 或 INFEASIBLE。
**Assertions:**
- [ ] 引用所提供上下文中的具体帧预算数值（总共 16.67ms，AI 分配 4ms）
- [ ] 在比较中使用提交内容中具体的 7ms 估算
- [ ] 不给出泛泛的「这可能很慢」建议——引用具体数字
- [ ] 结论理由可追溯到所提供的预算约束

### Case 6: 缺少闸门输入——NOT ASSESSED
**Scenario:** 一个 `InventorySystem` 实现被提交代码评审，附其实现文件、其故事的验收标准及其治理 ADR；代理能检查的一切都健全。闸门指定的相关 GDD 章节未被传入：上下文既未给出其文本也未给出路径，故事文件未提及，调用技能也未报告其缺失。请求标记为 LP-CODE-REVIEW。
**Expected:** 对 LP-CODE-REVIEW 返回 NOT ASSESSED，将 GDD 章节列为它未获提供的输入——没有它，闸门关于相对 GDD 规则的正确性问题的检查就无法进行，因此 APPROVE 无从谈起。
**Assertions:**
- [ ] 明确对 LP-CODE-REVIEW 陈述结论 `NOT ASSESSED`——不是 APPROVE，尽管它能检查的一切都健全
- [ ] 将相关 GDD 章节列为缺失的输入
- [ ] 不从代码或故事中推断 GDD 规则并据此评判正确性
- [ ] Variant——若调用技能报告不存在背包 GDD，那是一项发现，而非缺失输入：结论为 CONCERNS 或 REJECT，而非 NOT ASSESSED

---

## Protocol Compliance

- [ ] LP-CODE-REVIEW 结论仅使用 APPROVE / CONCERNS / REJECT 词汇——或当闸门指定的输入未被提供或无法读取时，返回 `NOT ASSESSED` 并说明该输入；调用技能报告缺失的产出物是一项发现，用闸门自身的措辞表述
- [ ] LP-FEASIBILITY 结论仅使用 FEASIBLE / CONCERNS / INFEASIBLE 词汇——或当闸门指定的输入未被提供或无法读取时，返回 `NOT ASSESSED` 并说明该输入；调用技能报告缺失的产出物是一项发现，用闸门自身的措辞表述
- [ ] 保持在声明的代码架构领域内
- [ ] 将设计优先级冲突交给 creative-director
- [ ] 将每个闸门结论陈述为该闸门定义中的明确结论词，而非由行文暗示的结论
- [ ] 不做出有约束力的游戏设计或创意方向决定

---

## Coverage Notes
- 未覆盖跨多个相互依赖系统的多文件代码评审——推迟到集成测试。
- 此处未覆盖技术债评估与优先级排序——推迟到 /tech-debt 技能集成。
- 未覆盖编码标准文档更新（新增一条禁止模式）。
- 未覆盖与 qa-lead 就可测试单元构成（LP 与 QL 边界）的交互。
