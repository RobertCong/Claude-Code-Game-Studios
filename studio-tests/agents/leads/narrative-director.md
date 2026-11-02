# Agent Test Spec: narrative-director

## Agent Summary
**Domain owned:** 故事架构、角色设计方向、世界构建监督、ND-CONSISTENCY 闸门、对话策略。
**Does NOT own:** 视觉美术风格（art-director）、技术系统或代码（lead-programmer）、制作排期（producer）、游戏机制规则（game-designer）。
**Gate IDs handled:** ND-CONSISTENCY（结论为 APPROVE / CONCERNS / REJECT，定义于 `.claude/docs/director-gates/nd-consistency.md`）。

---

## Static Assertions (Structural)

通过读取该代理的 `.claude/agents/narrative-director.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及故事、角色、世界构建、一致性——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit, WebSearch，且 `disallowedTools:` 列出 Bash
- [ ] 模型档位为 `inherit`——frontmatter `model:` 恰为 `inherit`（档位：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对视觉风格、技术系统或制作排期拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一份关于「沉没档案馆」地点的新设定文档被提交。该文档确立档案馆在大崩塌期间于 200 年前被淹没，与世界圣经中既定的时间线一致。文中引用的所有具名角色都与其既定档案一致，语气符合叙事圣经的语气指南。闸门上下文传入了 `.claude/docs/director-gates/nd-consistency.md` 指定的每一项输入：文档路径、语气指南、世界圣经的时间线规则，以及它所引用角色的档案。请求标记为 ND-CONSISTENCY。
**Expected:** 返回 `APPROVE`，理由确认时间线对齐、角色一致性和语气。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一（ND-CONSISTENCY 闸门的词汇）——此处为 APPROVE
- [ ] 理由回答闸门提示提出的每个问题：角色与既定档案的一致性、与既定设定的矛盾、以及语气
- [ ] 理由引用所核实的具体既定事实（200 年时间线、大崩塌事件）
- [ ] 输出保持在叙事范围内——不对该地点的视觉设计或其技术实现发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 开发者请 narrative-director 评审并优化用于档案馆器物「远古辉光」视觉效果着色器的代码。
**Expected:** 代理拒绝评估着色器代码。它点名 `technical-artist`——其自身「must not」列表中着色器、VFX 和渲染代码的所有者——为评审与优化者；同时将 `art-director`（拥有该效果应有的外观）列为也可以。它补充的任何叙事输入只是该效果应承载的情绪。
**Assertions:**
- [ ] 不评审、重写或优化着色器代码，也不就视觉实现做出任何有约束力的决定
- [ ] 依其「Review or change shader, VFX or rendering code (technical-artist owns it; art-director owns how it should look)」限制，点名 `technical-artist`（或引擎的着色器专家）为着色器代码的所有者——同时点名 `art-director` 可以接受，但仅点名 art-director 不可以
- [ ] 它给出的任何叙事输入（例如「应感觉古老而神圣，而非技术化」）都作为给视觉所有者的输入提出，而非视觉或技术决定

### Case 3: 闸门结论——正确的词汇
**Scenario:** 一份关于角色「Aldric Vorne」的新背景故事文档被提交。文档称 Aldric 150 年前出生于首都，并亲眼见证了大崩塌；背景故事的核心弧线是他对目睹的大崩塌的愧疚。既定的世界圣经则称 Aldric 出生于大崩塌后 50 年，在一个外省小镇而非首都。请求标记为 ND-CONSISTENCY。
**Expected:** 返回 `REJECT`——被矛盾的事实承载着背景故事的核心弧线，因此它们破坏其叙事基础，而非局部修正——并列出两处矛盾：出生时间（150 年前 vs. 大崩塌后 50 年）与出生地点（首都 vs. 外省小镇）。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一——不是自由文本；此处为 REJECT，因为被矛盾的事实对整个背景故事是承重的（它发现的矛盾以闸门词汇为准，因此即使未传入角色档案也不是 NOT ASSESSED）
- [ ] 结论按闸门的 `REJECT [contradictions ...]` 形式具体包含这两处矛盾——而非仅「与设定不符」
- [ ] 引用世界圣经作为既定事实的权威来源
- [ ] 不自行撰写替代背景故事——重写属于内容作者（设定条目在其 Delegation Map 中委派给 `writer` / `world-builder`）

### Case 4: 冲突上报——正确的上级
**Scenario:** 一位编剧在其最新对话中设定古代文明「只用歌唱交流」。world-builder 的现有设定条目描述同一文明通过书写字形交流。两者都向 narrative-director 汇报，双方就哪个为正式设定意见不一。
**Expected:** narrative-director 在自己层级解决冲突——它是 writer 与 world-builder 的共同上级，因此不上报给 creative-director。遵循其协作协议，它提出调和选项并附推荐的正典裁决（例如「字形书写是正典的主要交流方式；歌唱是仪式/典礼性的」），将最终决定留给用户，然后指示 writer 与 world-builder 都将各自工作对齐确认的裁决。
**Assertions:**
- [ ] 作为共同上级自行解决冲突——不将这一叙事内部冲突交给 creative-director
- [ ] 提出调和选项并清楚陈述推荐裁决，将最终正典决定留给用户
- [ ] 指示双方更新文档以符合裁决：writer 修订对话，world-builder 更新设定条目
- [ ] 提议将裁决作为正典事实记录在世界构建文档中，以便后续设定可据此检验

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 一个新故事章节被提交进行 ND-CONSISTENCY 评审。它引入了一个此前未登记的角色。闸门上下文传入三份文档：世界圣经（大崩塌的时间线与原因）、角色注册表（正典角色的年龄、出身和阵营），以及描述沉没档案馆守护者的阵营文档。
**Expected:** 评估将新角色与角色注册表交叉核对（无冲突），将章节的时间线引用与世界圣经核对，并对照阵营文档评估章节对档案馆守护者的刻画。使用全部三份所提供文档中的具体事实，并返回 ND-CONSISTENCY 结论。
**Assertions:**
- [ ] 将新角色与所提供角色注册表交叉核对
- [ ] 将时间线引用与所提供世界圣经事实核对
- [ ] 对照所提供阵营文档评估阵营刻画
- [ ] 返回 APPROVE / CONCERNS / REJECT 之一，理由可追溯到所提供三份文档——没有泛泛的叙事反馈

### Case 6: 闸门输入缺失——NOT ASSESSED
**Scenario:** ND-CONSISTENCY 被调用评审一个「Aldric Vorne」开口说话的新对话文件。闸门上下文传入文件路径和世界构建规则，对话没有与其中任何一项矛盾——但 Aldric 的角色档案（闸门指定的输入）未被传入，因此无法对照它检查其口吻。
**Expected:** 返回 `ND-CONSISTENCY: NOT ASSESSED`，点名缺失的输入（Aldric Vorne 的角色档案），而非 APPROVE——对照从未见过的档案的口吻一致性尚未得到确立。
**Assertions:**
- [ ] 结论为 `NOT ASSESSED`——不是 APPROVE、CONCERNS 或 REJECT——因为它能读取的输入未显示任何不一致
- [ ] 点名缺失的输入：Aldric Vorne 的角色档案
- [ ] 不从对话本身或记忆中重建 Aldric 的既定口吻来完成检查

---

## Protocol Compliance

- [ ] ND-CONSISTENCY 结论仅使用 APPROVE / CONCERNS / REJECT——或当闸门指定的输入缺失且未发现不一致时，返回 NOT ASSESSED 并说明该输入
- [ ] 在创建叙事文档前询问「May I create [filepath] with the section skeleton?」，在写入每个章节前询问「May I write this section to [filepath]?」
- [ ] 保持在声明的叙事领域内
- [ ] 在自己层级解决叙事内部冲突而非上报，同时将最终正典决定留给用户
- [ ] CONCERNS 或 REJECT 结论按闸门提示的 `CONCERNS [...]` / `REJECT [...]` 形式点名具体不一致或矛盾——绝不只有结论词
- [ ] 不做出有约束力的视觉设计、技术或制作决定

---

## Coverage Notes
- 未覆盖对话质量评审（区别于世界构建一致性）——应补充一个专门用例。
- CONCERNS 结论（可修复且不破坏叙事基础的不一致）尚无专门用例。
- 未覆盖跨整套章节的多文档一致性检查——推迟到 /review-all-gdds 集成。
- 机制变更的叙事影响（例如某个游戏机制削弱故事张力）需要与 game-designer 协调，此处未覆盖。
- 未覆盖角色弧线评审（成长、动机在时间上的一致性）。
