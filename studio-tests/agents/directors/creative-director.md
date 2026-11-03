# Agent Test Spec: creative-director

## Agent Summary
**Domain owned:** 创意愿景、游戏支柱、GDD 对齐、系统拆解反馈、叙事方向、试玩测试反馈解读、阶段闸门（创意方面）。
**Does NOT own:** 技术架构或实现细节（交给 technical-director）、制作排期（producer）、视觉美术风格执行（交给 art-director）。
**Gate IDs handled:** CD-PILLARS, CD-GDD-ALIGN, CD-SYSTEMS, CD-NARRATIVE, CD-PLAYTEST, CD-PHASE-GATE.

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/creative-director.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及创意愿景、支柱、GDD 对齐——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit, WebSearch，且 `disallowedTools:` 列出 Bash
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对技术架构或制作排期拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一款叙事生存游戏的支柱集合被提交进行压力测试，包含其反支柱、核心幻想和独特钩子。该钩子点明其最接近的同类作品——「像 *Don't Starve*，而且你失去的每个幸存者都会永久改变世界」——而三条支柱中没有一条是该同类作品所围绕的目标。它有三条支柱——「涌现故事」「有意义的牺牲」和「有人居住的世界」——每条都有定义和一项点明它能裁定真实决策的设计测试；这些支柱彼此拉扯（牺牲 vs. 玩家想要守护的世界）。请求标记为 CD-PILLARS。
**Expected:** 返回 `CD-PILLARS: APPROVE`，并对每条支柱给出具体反馈，依照闸门标准评判：是否可证伪、是否与其他支柱形成张力、是否使游戏差异化、是否能裁定真实的设计分歧。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一
- [ ] 结论文本格式为 `CD-PILLARS: APPROVE`（闸门 ID 前缀、冒号、结论关键词）
- [ ] 按名称对三条支柱逐一给出反馈，并对照闸门标准（可证伪性、张力、与 *Don't Starve* 的差异化），而非泛泛的创意建议
- [ ] 输出保持在创意范围内——不对引擎可行性或冲刺排期发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 开发者请 creative-director 评审一个拟用于存储玩家存档数据的 PostgreSQL schema。
**Expected:** 代理拒绝评估该 schema，并转交给 technical-director。
**Assertions:**
- [ ] 不就 schema 设计做出任何有约束力的决定
- [ ] 明确指出 `technical-director` 是正确处理者
- [ ] 对 schema 的任何评论都限于其创意影响（例如存档必须记住哪些玩家选择）——不提出任何表、列、键或查询设计

### Case 3: 闸门结论——正确的词汇
**Scenario:** 一份「制作（Crafting）」系统的 GDD 被提交，其中包含游戏支柱——「好奇心总能得到回报」和「世界会记得」——以及其 MDA 目标：发现优先。第 4 节（Formulas）定义了一条惩罚探索的资源衰减公式——与「玩家幻想」章节所要求的「无惧漫游的自由」相矛盾，并违背好奇心支柱。其余每个章节都服务于支柱，且重新调整该公式即可在不重新设计系统的情况下解决冲突。请求标记为 CD-GDD-ALIGN。
**Expected:** 返回 `CD-GDD-ALIGN: CONCERNS`，具体引用公式行为与「玩家幻想」表述之间的矛盾。修复以创意约束的形式陈述；公式本身留给设计团队。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一——不是自由文本
- [ ] 结论文本格式为 `CD-GDD-ALIGN: CONCERNS`
- [ ] 理由引用或直接指向 GDD 第 4 节（Formulas）、「玩家幻想」章节以及「好奇心总能得到回报」支柱
- [ ] 将修复陈述为创意约束（例如衰减不得惩罚漫游），并把公式留给 `game-designer`（其机制设计受委托人）——不撰写替代的公式数值

### Case 4: 冲突上报——正确的上级
**Scenario:** technical-director 提出担忧：核心循环机制（实时分支对话）实现成本过高，建议砍掉。creative-director 出于创意理由不同意。
**Expected:** creative-director 承认技术约束，不推翻 technical-director 的可行性评估，但保留界定创意目标的权力。对于冲突本身，creative-director 是最高层级的创意上报点，在实现可行性上服从 technical-director，同时为设计意图辩护。解决路径是双方共同向用户呈现取舍选项。
**Assertions:**
- [ ] 不单方面推翻 technical-director 的可行性担忧
- [ ] 清楚区分「我们创意上想要什么」与「它如何被构建」
- [ ] 提议向用户呈现取舍，而非单方面解决
- [ ] 不声称拥有实现决策的决定权

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 代理收到一个闸门上下文块，其中包含游戏支柱文档（`design/gdd/game-pillars.md`）和一份待评审的新系统 GDD。支柱文档将「玩家作者性」「后果永久性」和「世界响应性」定义为三条核心支柱。请求标记为 CD-GDD-ALIGN。
**Expected:** 评估使用所提供文档中的确切支柱词汇，而非泛泛的创意启发式。任何批准或关注都回溯到三条具名支柱中的一条或多条。
**Assertions:**
- [ ] 使用所提供上下文文档中的确切支柱名称
- [ ] 不生成与所提供支柱脱节的泛泛创意反馈
- [ ] 引用与被评审机制最相关的具体支柱
- [ ] 不引用所提供文档中不存在的支柱

### Case 6: 缺少闸门输入——NOT ASSESSED
**Scenario:** 一份完整且内部自洽的系统 GDD 被提交，包含其「玩家幻想」章节，但没有游戏支柱：上下文未提供，且 `design/gdd/game-concept.md`、`design/gdd/game-pillars.md` 或 `design/game-brief.md` 均不存在。请求标记为 CD-GDD-ALIGN。
**Expected:** 返回 `CD-GDD-ALIGN: NOT ASSESSED`，将游戏支柱列为它无法读取的输入。没有人提供支柱，就无法评判与支柱的对齐，因此不给出对齐结论。
**Assertions:**
- [ ] 结论文本为 `CD-GDD-ALIGN: NOT ASSESSED`——不是 APPROVE，尽管 GDD 本身看起来没有任何问题
- [ ] 将游戏支柱列为缺失的输入
- [ ] 不从被评审的 GDD 中推断支柱并据此评判对齐

---

## Protocol Compliance

- [ ] 返回所调用闸门定义文件列出的结论词汇——CD-PILLARS、CD-GDD-ALIGN、CD-SYSTEMS、CD-NARRATIVE 和 CD-PLAYTEST 为 APPROVE / CONCERNS / REJECT；CD-PHASE-GATE 为 READY / CONCERNS / NOT READY；任何闸门在缺少其指定输入时返回 `NOT ASSESSED` 并说明该输入
- [ ] 保持在声明的创意领域内
- [ ] 通过向用户呈现取舍来上报冲突，而非单方面推翻
- [ ] 在输出中使用闸门 ID（例如 `CD-PILLARS: APPROVE`），而非行文中的散文式结论
- [ ] 不做出有约束力的跨领域决定（技术、制作、美术执行）
- [ ] 在阶段闸门上，将调用技能以 "none" 传入、但目标阶段所需的产出物视为一项发现（NOT READY 或 CONCERNS）；将以 "not expected before [phase]" 或 "not required at `workflow: [tier]`" 传入的产出物视为无发现——它评判的是即将进入阶段的就绪度，而非更靠后阶段

---

## Coverage Notes
- 此处未覆盖多闸门场景（例如一次提交同时触发 CD-PILLARS 和 CD-GDD-ALIGN）——推迟到集成测试。
- CD-PHASE-GATE（创意总监自身的就绪度评审，由 `/gate-check` 在 `workflow: full` 时运行）尚无用例。
- CD-PLAYTEST（对 `/playtest-report` 报告的评审）尚无用例。
- 未覆盖与 art-director 在视觉支柱对齐方面的交互。
