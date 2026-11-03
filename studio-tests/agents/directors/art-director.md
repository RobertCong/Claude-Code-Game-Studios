# Agent Test Spec: art-director

## Agent Summary
**Domain owned:** 视觉识别（visual identity）、美术圣经（art bible）的撰写与执行、资源质量标准、UI/UX 视觉设计、视觉阶段闸门、概念美术评估。
**Does NOT own:** UX 交互流程与信息架构（ux-designer 的领域）、音频方向（audio-director）、代码实现。
**Gate IDs handled:** AD-CONCEPT-VISUAL, AD-ART-BIBLE, AD-VISUAL, AD-PHASE-GATE.

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/art-director.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及视觉识别、美术圣经、资源标准——而非泛泛而谈）
- [ ] `tools:` 包含 Read（也可打开图像以进行视觉评审）以及用于维护美术圣经的 Write/Edit，且不含 Bash——`disallowedTools:` 会屏蔽它
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对 UX 交互流程或音频方向拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 一份完整的美术圣经被提交签署，其中包含游戏支柱与核心幻想、平台约束，以及在头脑风暴期间选定的视觉识别锚点。其色彩章节定义了一套低饱和的土色主色板，并用高对比度的强调色呼应游戏支柱「衰败之美」；其形状语言、资源标准和角色方向与该章节一致，且处于所述平台约束之内。请求标记为 AD-ART-BIBLE。
**Expected:** 返回 `AD-ART-BIBLE: APPROVE`，理由确认色板的内部自洽性，且色彩系统符合该支柱的情绪目标。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一
- [ ] 结论文本格式为 `AD-ART-BIBLE: APPROVE`
- [ ] 理由点明具体的色板特征，并说明它们如何服务于「衰败之美」的情绪目标（该闸门的色彩对情绪检查）——而非泛泛的美术建议
- [ ] 输出保持在视觉领域内——不对 UX 交互模式或音频氛围发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 音效设计师请 art-director 规定当玩家进入战斗区域时环境音效应如何分层并躲闪（ducking）。
**Expected:** 代理拒绝定义音频行为，并转交给 audio-director。
**Assertions:**
- [ ] 不就音频分层或躲闪行为做出任何有约束力的决定
- [ ] 明确指出 `audio-director` 是正确处理者
- [ ] 其任何评论都只涉及该区域的视觉氛围（例如「音频应匹配该区域的视觉张力」）——不规定任何音频层、躲闪量、淡入淡出时间或触发条件

### Case 3: 闸门结论——正确的词汇
**Scenario:** 在支柱刚刚锁定后，概念与支柱集合被提交以确定视觉识别锚点。三条支柱是「有趣的战斗」「精彩的故事」和「大量内容」；它们的设计测试都没有提到氛围、气氛或世界应有的感觉，也没有给出任何视觉参照物。请求标记为 AD-CONCEPT-VISUAL。
**Expected:** 返回 `AD-CONCEPT-VISUAL: CONCERNS`——这是闸门对尚不足以区分视觉识别的支柱所给出的结论——指出哪些支柱没有给出视觉方向，以及缺少什么（氛围、形状语言、色彩含义）。
**Assertions:**
- [ ] 结论恰为 CONCEPTS / STRONG / CONCERNS 之一（AD-CONCEPT-VISUAL 的结论词汇）——不是 APPROVE / REJECT，也不是自由文本
- [ ] 结论文本格式为 `AD-CONCEPT-VISUAL: CONCERNS`
- [ ] 理由点明具体哪些支柱没有给出视觉方向，以及它们未覆盖闸门四个方向组成部分（视觉规则、氛围、形状语言、色彩哲学）中的哪些——而非泛泛的「支柱太模糊」
- [ ] 不自行改写支柱——支柱变更应回到用户和 creative-director

### Case 4: 冲突上报——正确的上级
**Scenario:** ux-designer 提议在 HUD 中使用高对比度、色彩鲜艳的图标以提升可读性。art-director 认为这违反了美术圣经中克制的视觉语言，会削弱视觉识别。
**Expected:** art-director 陈述视觉识别方面的担忧并引用美术圣经，承认 ux-designer 的可读性目标是合理的，并上报给 creative-director，以裁定视觉一致性与可用性之间的取舍。
**Assertions:**
- [ ] 上报给 `creative-director`（创意领域冲突的共同上级）
- [ ] 不单方面推翻 ux-designer 的可读性建议
- [ ] 清楚地将冲突界定为两个合理目标之间的取舍
- [ ] 引用被违反的具体美术圣经规则

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 代理收到一个闸门上下文块，其中包含现有美术圣经及具体色板数值（主色：#8B7355、#6B6B47；强调色：#C8A96E）和风格规则（「不用纯白、不用纯黑；所有阴影都带暖色调」）。一个新型资源被提交评审：第一张敌人精灵图集，其身体颜色取自主色板，但轮廓为纯黑（#000000），高光为纯白（#FFFFFF），阴影为冷蓝灰色（#5A6A7A）。请求标记为 AD-VISUAL。
**Expected:** 评估引用所提供美术圣经中的具体十六进制数值和风格规则，而不是泛泛的色彩理论建议，并返回 `AD-VISUAL: REJECT`——该精灵图违反了全部三条风格规则，属于在该资源类型投入使用前必须解决的风格违规——并将每项违规对应到它所违反的规则。
**Assertions:**
- [ ] 引用所提供美术圣经上下文中的具体色板数值
- [ ] 应用所提供文档中的具体风格规则（不用纯白/纯黑、阴影带暖色调），并指出违反这些规则的轮廓色、高光色和阴影色
- [ ] 不生成与所提供美术圣经脱节的泛泛美术方向反馈
- [ ] 结论文本为 `AD-VISUAL: REJECT`，其理由可追溯到所提供上下文中的具体条目或规则

### Case 6: 缺少闸门输入——NOT ASSESSED
**Scenario:** 一份完整且内部自洽的美术圣经被提交签署，包含支柱和视觉识别锚点，但没有平台或性能约束：上下文未提供，`project.yaml` 未设置任何 `platform.*` 或 `performance.*` 键，且 `.trae/docs/technical-preferences.md` 仍只有未配置的占位符。请求标记为 AD-ART-BIBLE。
**Expected:** 返回 `AD-ART-BIBLE: NOT ASSESSED`，将平台与性能约束列为它无法读取的输入——没有这些，闸门关于「资源标准在该平台上可实现」的检查就无法进行。
**Assertions:**
- [ ] 结论文本为 `AD-ART-BIBLE: NOT ASSESSED`——不是 APPROVE，尽管它能检查的每个章节都健全
- [ ] 将平台与性能约束列为缺失的输入
- [ ] 不臆测平台或预算来完成评审

---

## Protocol Compliance

- [ ] 返回所调用闸门定义文件列出的结论词汇——AD-ART-BIBLE 和 AD-VISUAL 为 APPROVE / CONCERNS / REJECT；AD-CONCEPT-VISUAL 为 CONCEPTS / STRONG / CONCERNS；AD-PHASE-GATE 为 READY / CONCERNS / NOT READY；任何闸门在缺少其指定输入时返回 `NOT ASSESSED` 并说明该输入
- [ ] 保持在声明的视觉领域内
- [ ] 将 UX 与视觉的冲突上报给 creative-director
- [ ] 在输出中使用闸门 ID（例如 `AD-ART-BIBLE: APPROVE`），而非行文中的散文式结论
- [ ] 不做出有约束力的 UX 交互、音频或代码实现决定
- [ ] 在阶段闸门上，将调用技能以 "none" 传入、但目标阶段所需的产出物视为一项发现（NOT READY 或 CONCERNS）；将以 "not expected before [phase]" 或 "not required at `workflow: [tier]`" 传入的产出物视为无发现——它评判的是即将进入阶段的就绪度，而非更靠后阶段

---

## Coverage Notes
- 未覆盖 AD-PHASE-GATE（完整的视觉阶段推进）——推迟到与 /gate-check 技能的集成。
- 此处未覆盖资源流水线标准（文件格式、分辨率、命名约定）的合规检查。
- 未覆盖着色器视觉输出评审——与引擎专家的该交互推迟处理。
- UI 组件视觉评审（区别于 UX 流程评审）可通过补充用例得到改进。
