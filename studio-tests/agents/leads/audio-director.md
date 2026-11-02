# Agent Test Spec: audio-director

## Agent Summary
**Domain owned:** 声音识别——音效调色板、音乐方向与情绪映射、音频事件架构、混音策略、自适应音频设计、音频资源规范与命名。
**Does NOT own:** 视觉设计（art-director）、音频引擎代码（gameplay-programmer / engine-programmer）、音频中间件变更（需 technical-director 批准）、叙事故事内容（narrative-director）、UX 交互流程（ux-designer）。
**Gate IDs handled:** None. 未向 audio-director 分配任何总监闸门（`AD-` 闸门属于 art-director）。设计评审结论来自 `/design-review` 技能，该技能将 audio-director 作为返回发现的专家生成。

---

## Static Assertions (Structural)

通过读取该代理的 `.claude/agents/audio-director.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及音乐方向、音效设计、混音、音频实现——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit, WebSearch，且 `disallowedTools:` 列出 Bash
- [ ] 模型档位为 `inherit`——frontmatter `model:` 恰为 `inherit`（档位：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对视觉设计、代码实现或叙事内容拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 用户已批准游戏「探索」音乐层的方向：一套由分层音轨（stems）组成的生成式环境系统，随环境密度变化，采用稀疏、有机、略带忧郁的调色板，用以强化支柱「有人居住的世界」。用户请 audio-director 起草该层的音频资源规范。
**Expected:** 以代理自身的格式起草规范：每个资源按音频命名约定命名，每个类别给出格式、采样率、响度目标和文件大小预算，并将音轨/密度行为回溯到该支柱。展示草稿，并在写入文件前询问。
**Assertions:**
- [ ] 每个资源名称遵循 `[category]_[context]_[name]_[variant].[ext]`（例如 `mus_explore_forest_calm_loop.ogg`）
- [ ] 为音乐资源指定格式、采样率、响度目标（LUFS）和文件大小预算
- [ ] 理由将密度驱动的音轨分层与「有人居住的世界」支柱挂钩
- [ ] 保持在音频范围内，并在创建文件前询问「May I create [filepath] with the section skeleton?」，在写入每个章节前询问「May I write this section to [filepath]?」

### Case 2: 领域外请求——转交或上报
**Scenario:** 开发者请 audio-director 评估音频设置菜单的 UI 流程（屏幕与选项的顺序）是否直观且组织良好。
**Expected:** 代理不就屏幕流程或菜单组织作出裁决——那属于 UX，而非音频。它将回答限于菜单必须呈现的音频需求（源自其自身的混音策略），并将流程与布局留给 ux-designer。
**Assertions:**
- [ ] 不就 UI 流程、屏幕顺序或信息架构做出任何有约束力的决定
- [ ] 说明流程与布局属于音频领域之外，而不是去评估它们
- [ ] 明确指出 `ux-designer` 是菜单流程与布局的所有者（其文件将 UX 决策交给 ux-designer）
- [ ] 将贡献限于取自其混音策略的音频需求（例如其音量层级中每个总线一个滑块——master、music、SFX、dialogue）

### Case 3: 评审发现——具体，结论留给评审技能
**Scenario:** `/design-review` 在全模式下生成 audio-director 作为对抗性专家，评审一份包含音乐触发器的首领遭遇 GDD。生成提示写道：「Your job is NOT to validate this design — your job is to find problems. Be specific and critical.」该 GDD 的最终首领提示是一首明快、大调、快节奏的管弦乐；该遭遇的游戏支柱和叙事语境则指定「恐惧、不可避免与悲剧性牺牲」。
**Expected:** 返回具体发现：该提示的大调、快节奏和明快音区与情绪目标相矛盾，并以选项形式提供修改方向。它返回发现而非结论——评审结论由 `/design-review` 产生。
**Assertions:**
- [ ] 指出冲突的具体音乐特征（大调、快节奏、明快音区）
- [ ] 点名该提示所违背的情绪目标（恐惧、不可避免、悲剧性牺牲），将其视为该遭遇的情绪映射
- [ ] 以带推荐的选项形式提供可执行的修改方向（例如小调式、更慢的节奏、更薄的编制）
- [ ] 向评审返回发现，而非自打 APPROVED / NEEDS REVISION 印记

### Case 4: 冲突上报——正确的上级
**Scenario:** sound-designer 提议使用基于实时射线检测的物理查询来实现音频遮挡。technical-artist 认为这太昂贵，提议改用基于区域的触发器系统。双方都同意遮挡效果值得保留；冲突纯粹关于实现方式。
**Expected:** audio-director 将期望的音频行为（遮挡听起来应如何、何时激活）定义为任一方案都必须满足的需求，随后将射线检测 vs. 区域的选择交给 `lead-programmer`——其文件为音频系统实现指定的代理——或交给 `technical-director` 处理技术冲突。它不挑选实现方式，也不把决定交给争议双方中的任何一方。
**Assertions:**
- [ ] 清楚定义期望的音频行为（玩家听到什么、遮挡何时生效、衰减多强）
- [ ] 将实现方式（射线检测 vs. 区域触发）交给 `lead-programmer` 或 `technical-director`——而非交给争议方 sound-designer 或 technical-artist
- [ ] 不单方面选择技术实现方法
- [ ] 将音频行为表述为任一实现都必须满足的需求，使技术决策可据此检验

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 请求中包含游戏的三条支柱：「涌现故事」「有意义的牺牲」和「有人居住的世界」。一份环境氛围音频规范被提交：每个生物群系一个静态循环，没有任何层对玩家行为或世界事件作出响应。
**Expected:** 评估按名称对照全部三条支柱来评价该氛围规范。它指出静态循环不支持「涌现故事」，因为音频中没有任何部分响应游戏状态，并指出自适应音频是缺口所在。
**Assertions:**
- [ ] 在评估中按名称引用全部三条所提供的支柱
- [ ] 明确评估该音频规范对每条支柱的贡献
- [ ] 指出「涌现故事」未得到支持，因为循环不响应游戏状态，并点名自适应音频（状态驱动的层或过渡）是缺失的部分
- [ ] 不生成泛泛的音频方向建议——所有反馈都与所提供支柱词汇挂钩

---

## Protocol Compliance

- [ ] 用它指定的每个音频资源都以 `[category]_[context]_[name]_[variant].[ext]` 命名
- [ ] 保持在声明的音频领域内
- [ ] 将实现方式的决策交给技术主管
- [ ] 将音频反馈与请求中提供的支柱或情绪目标挂钩，而非泛泛的音频建议
- [ ] 不做出有约束力的视觉设计、UX、叙事或代码实现决定

---

## Coverage Notes
- 未覆盖混音平衡评审（音乐、音效与对话之间的相对电平）——应补充一个专门用例。
- 未覆盖音频实现策略评审（中间件选择、流式加载方式）。
- 未覆盖向 sound-designer 委派详细音效文档和事件列表。
- 未覆盖本地化对音频的影响（配音录制指导、特定语言的音乐时值）。
