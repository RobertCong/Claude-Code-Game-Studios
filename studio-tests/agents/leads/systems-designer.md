# Agent Test Spec: systems-designer

## Agent Summary
**Domain owned:** 战斗公式、成长曲线、制作配方、状态效果交互矩阵、反馈循环分析、调参文档、模拟规格。
**Does NOT own:** 高层设计方向（game-designer——直接协作伙伴）、关卡与遭遇设计（level-designer）、叙事与美学决策、代码实现。
**Gate IDs handled:** None. 公式评审返回发现与选项；设计评审结论来自 `/design-review` 技能，该技能将 systems-designer 作为专家生成。

---

## Static Assertions (Structural)

通过读取该代理的 `.claude/agents/systems-designer.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及公式、成长曲线、平衡性数学、经济——而非泛泛而谈）
- [ ] `tools:` 列表以读写为主且排除 Bash（`disallowedTools:` 列出 Bash）；每次 Write/Edit 都受其「May I write」步骤或编排器具名路径例外把关
- [ ] 模型档位为 `inherit`——frontmatter `model:` 恰为 `inherit`（档位：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对叙事、视觉设计或概念机制规则的所有权拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 用户请 systems-designer 将战斗 GDD 的伤害公式形式化，用于其 Formulas 章节：`damage = base_attack * (1 + strength_modifier * 0.1) - defense * 0.5`，取值范围 base_attack [10–100]、strength_modifier [0–20]、defense [0–50]。
**Expected:** 按强制的 Formula Output Format 产出公式。输出范围按当前写法并不安全：它从 −15（base_attack 10、strength_modifier 0、defense 50）跨到 300（base_attack 100、strength_modifier 20、defense 0），因此代理标记出负值下限，并提供钳制选项供用户选择。
**Assertions:**
- [ ] 输出包含全部四个强制部分：具名表达式、变量表（Symbol / Type / Range / Description，含结果行）、输出范围和一则演算示例
- [ ] 输出范围说明未钳制结果跨 −15 到 300，并指出会导致负值的输入组合
- [ ] 以带推荐的选项形式提供约束负值下限的方式（例如最低伤害钳制），将选择留给用户
- [ ] 保持在系统领域内——不对该机制是否有趣或如何在代码中实现发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 一位编剧请 systems-designer 起草一个支线任务的脚本，该任务以稀有制作材料奖励玩家。
**Expected:** 代理拒绝撰写任务脚本——叙事决策超出其职责——只提供请求中的系统侧内容：该材料奖励在制作经济中应有多稀有。
**Assertions:**
- [ ] 不撰写任务叙事内容或对话
- [ ] 说明脚本是超出其职责的叙事工作，留给提出请求的编剧
- [ ] 转而提供系统侧的贡献（例如该材料的奖励稀有度或掉落率相对于制作经济），而不做叙事决策

### Case 3: 评审发现——边界处的退化情况
**Scenario:** `/design-review` 在全模式下生成 systems-designer 作为对抗性专家，评审一份战斗 GDD。生成提示写道：「For every formula in the GDD, plug in boundary values (minimum and maximum plausible inputs). Report whether any outputs go degenerate.」该 GDD 的公式为 `damage = base_attack * level_multiplier`，其中 `level_multiplier = (player_level / enemy_level) ^ 2`，等级范围为 1–50。玩家 50 级对抗 1 级敌人时，乘数为 2500x——10 基础攻击武器造成 25,000 伤害。
**Expected:** 报告该退化情况及其确切输入与输出，指出平方比率是原因，并以选项形式提供修改方案而不强制其一。它返回发现而非结论——`/design-review` 给出结论。
**Assertions:**
- [ ] 报告具体的退化输入值（玩家 50 级、敌人 1 级）及产生的输出（2500x 乘数、10 基础攻击造成 25,000 伤害）
- [ ] 指出平方等级比率是导致该问题的组件，并说明输出未钳制——仅受 1–50 等级范围约束，该范围将乘数上限封顶在 2500x——而不是称其无界
- [ ] 以选项形式至少提出一种修改方案（例如钳制比率、对数缩放），不强制选择
- [ ] 向评审返回发现，而非自打 APPROVED / NEEDS REVISION 印记

### Case 4: 冲突上报——正确的上级
**Scenario:** game-designer 想要一个简单的 2 变量伤害公式以利于玩家直觉理解。systems-designer 认为含元素交互的 6 变量公式对战斗系统的深度是必要的。双方无法就正确的复杂度水平达成一致。
**Expected:** systems-designer 清楚呈现取舍——6 变量系统的调参粒度 vs. 2 变量系统的玩家易读性——并上报给 creative-director 进行玩家体验裁决。「公式对玩家应有多复杂」是玩家体验问题，而非纯数学问题。
**Assertions:**
- [ ] 用具体示例呈现两种方案之间的取舍
- [ ] 上报给 `creative-director` 进行玩家体验裁决
- [ ] 不违背 game-designer 的反对单方面强加 6 变量公式
- [ ] 保持可参与实现任何被批准的复杂度水平

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 请求中包含当前平衡数据：敌人生命值范围为 100 到 10,000；玩家攻击范围为 15 到 150；平衡对局是一个 1,000 HP 的敌人对抗一个 100 攻击的玩家，每秒攻击一次；平衡对局下的目标击杀时间为 8–12 秒。提议的修订公式为：`damage_per_hit = attack * 0.8`。
**Expected:** 用提供的数值运行提议的公式。在平衡对局下，每次命中伤害为 80，因此击杀时间为 1,000 / 80 = 12.5 秒——超出 8–12 秒窗口半秒。代理报告该偏差，并以选项形式提供调整，全程使用所提供的数字。
**Assertions:**
- [ ] 在其变量范围或分析中使用所提供的 HP 与攻击范围（100–10,000 HP；15–150 攻击）
- [ ] 计算平衡对局的击杀时间：1,000 / (100 × 0.8) = 12.5 秒
- [ ] 将结果与所提供的 8–12 秒窗口比较，并指出它超出了上限
- [ ] 不给出泛泛的平衡建议——其论断和建议的调整使用所提供的数字

---

## Protocol Compliance

- [ ] 它产出的每个公式都包含四个强制部分：具名表达式、变量表、输出范围、演算示例
- [ ] 保持在声明的系统与公式领域内
- [ ] 将玩家体验复杂度取舍上报给 creative-director
- [ ] 不做出有约束力的叙事、视觉、代码实现或概念机制决策
- [ ] 提供具体的公式分析，而非主观设计意见
- [ ] 在创建文档前询问「May I create [filepath] with the section skeleton?」，在写入每个章节前询问「May I write this section to [filepath]?」

---

## Coverage Notes
- 未覆盖成长曲线设计（XP 曲线、升级缩放）——应补充一个专门用例。
- 未覆盖经济模型评审（资源生成与消耗速率、通胀预防）。
- 未覆盖状态效果交互矩阵（叠加规则、优先级、免疫交互）。
- 未覆盖注册表意识（在定义跨系统数值前检查 `design/registry/entities.yaml`）。
- 未覆盖跨系统公式依赖评审（例如制作公式输入到战斗公式）——推迟到集成测试。
