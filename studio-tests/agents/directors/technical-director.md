# Agent Test Spec: technical-director

## Agent Summary
**Domain owned:** 系统架构决策、技术可行性评估、ADR 监督与批准、引擎风险评估、技术阶段闸门。
**Does NOT own:** 游戏设计决策（creative-director / game-designer）、创意方向、视觉美术风格、制作排期（producer）。
**Gate IDs handled:** TD-SYSTEM-BOUNDARY, TD-FEASIBILITY, TD-ARCHITECTURE, TD-ADR, TD-ENGINE-RISK, TD-MANIFEST, TD-CHANGE-IMPACT, TD-PHASE-GATE.

---

## Static Assertions (Structural)

通过读取该代理的 `.trae/agents/technical-director.md` frontmatter 进行验证：

- [ ] `description:` 字段存在且针对具体领域（提及架构、可行性、ADR——而非泛泛而谈）
- [ ] `tools:` 为 Read, Glob, Grep, Write, Edit, Bash, WebSearch
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏设计决策或创意方向拥有决定权

---

## Test Cases

### Case 1: 领域内请求——适当的输出格式
**Scenario:** 主架构文档被提交签署，并附其上下文：技术需求基线中的每个 TR-ID 都映射到一个 ADR，基础层（Foundation-layer）的 ADR 均为 Accepted，唯一的 HIGH 风险引擎领域被标记为待解决问题。其「Combat System」章节描述了分层设计——输入层 → 游戏逻辑层 → 表现层——每层之间有清晰定义的接口。请求标记为 TD-ARCHITECTURE。
**Expected:** 返回 `TD-ARCHITECTURE: APPROVE`，理由确认闸门对该文档的检查：需求覆盖率、引擎风险已处理，以及层之间干净、最小的 API 边界。
**Assertions:**
- [ ] 结论恰为 APPROVE / CONCERNS / REJECT 之一
- [ ] 结论文本格式为 `TD-ARCHITECTURE: APPROVE`
- [ ] 理由具体引用分层结构及其接口定义作为 API 边界检查——而非泛泛的架构建议
- [ ] 输出保持在技术范围内——不对该机制是否有趣或是否符合创意愿景发表评论

### Case 2: 领域外请求——转交或上报
**Scenario:** 编剧请 technical-director 评审并批准游戏开场过场动画的对话脚本。
**Expected:** 代理拒绝评估对话质量，并将内容决策转交给 narrative-director——其拥有对话方向，且编剧向其汇报；creative-director 仍是创意决策的上报目标。
**Assertions:**
- [ ] 不就对话内容或结构做出任何有约束力的决定
- [ ] 明确指出 `narrative-director` 是对话内容的所有者——creative-director 将对话委托给它，且 coordination-rules.md 规则 1 禁止跳过层级；同时将 `creative-director` 列为上报目标也是可以的
- [ ] 仅评论影响对话的技术约束（例如本地化字符串长度限制、数据格式）——不对台词的质量、语气或措辞作评判

### Case 3: 闸门结论——正确的词汇
**Scenario:** 某概念已识别的技术风险（平台：PC；引擎：Godot 4.6）包括一个多人机制：每帧从每个活跃实体向其他所有实体进行射线检测以判定视线。在预期数量下（一个大型区域内有 1000 个实体），这是 O(n²)——每帧约一百万次射线检测。该机制本身可以通过不同的实现方式存活。请求标记为 TD-FEASIBILITY。
**Expected:** 返回 `TD-FEASIBILITY: CONCERNS`——该闸门的中间结论，附缓解建议列表——引用 O(n²) 复杂度以及按当前实现会突破帧预算的实体数量。不是 HIGH RISK，因为该概念无需修改。
**Assertions:**
- [ ] 结论恰为 VIABLE / CONCERNS / HIGH RISK 之一（TD-FEASIBILITY 的结论词汇）——不是 APPROVE / REJECT，也不是自由文本
- [ ] 结论文本格式为 `TD-FEASIBILITY: CONCERNS`
- [ ] 理由包含具体的算法复杂度问题和实体数量阈值
- [ ] 至少提出一项缓解措施（例如空间分区、兴趣管理），但不强制选择哪一种

### Case 4: 冲突上报——正确的上级
**Scenario:** game-designer 想为每个背包物品加入实时物理模拟（屏幕上同时有数百个物品）。technical-director 评估认为技术上代价高昂，并提议简化模拟。game-designer 不同意，认为这对游戏手感至关重要。
**Expected:** technical-director 清楚陈述技术成本与约束，提出可实现类似手感的替代实现方案，但明确将设计优先级决策交给 creative-director 作为玩家体验取舍的裁决者，最终由用户决定。
**Assertions:**
- [ ] 用具体信息表达技术担忧（例如性能预算、估算成本）
- [ ] 至少提出一种能在保留意图的同时降低成本的替代方案
- [ ] 明确将「这值得付出这些成本吗」的决策交给 `creative-director`（其设计决策的上报目标；coordination-rules.md 规则 3 适用于无共同上级的设计冲突），最终决定留给用户——不单方面砍掉该功能
- [ ] 不声称有权推翻 game-designer 的设计意图

### Case 5: 上下文传递——使用提供的上下文
**Scenario:** 一份提议 GPU 驱动渲染管线——在计算着色器上进行剔除和绘制提交——的 ADR 在其被 Accepted 之前被提交，并附引擎版本及其相关 ADR。闸门上下文块补充了目标平台约束：移动端、60fps 目标、2GB RAM 上限、不支持计算着色器。该 ADR 从未提及平台。请求标记为 TD-ADR。
**Expected:** 评估引用上下文中的具体硬件约束，指出计算着色器依赖与所述平台约束不兼容，并返回 `TD-ADR: REJECT`——该决策依赖目标平台不具备的能力，属于不健全的技术假设——并引用这些具体信息。
**Assertions:**
- [ ] 引用所提供的具体平台约束（移动端、2GB RAM、不支持计算着色器）
- [ ] 不给出与所提供约束脱节的泛泛性能建议
- [ ] 正确识别与平台约束冲突的架构组件
- [ ] 结论文本为 `TD-ADR: REJECT`，理由与所提供上下文挂钩，而非套话式警告

### Case 6: 缺少闸门输入——NOT ASSESSED
**Scenario:** 主架构文档被提交签署，包含其 ADR 列表（基础层 ADR 均为 Accepted）和引擎知识缺口清单；其分层与接口均健全。闸门指定的技术需求基线缺失：上下文未提供，且 `docs/architecture/tr-registry.yaml` 不存在。请求标记为 TD-ARCHITECTURE。
**Expected:** 返回 `TD-ARCHITECTURE: NOT ASSESSED`，将技术需求基数列为它无法读取的输入——没有它，闸门的第一项检查（每项需求是否都有架构决策覆盖？）就无法进行。
**Assertions:**
- [ ] 结论文本为 `TD-ARCHITECTURE: NOT ASSESSED`——不是 APPROVE，尽管它能检查的文档每个部分都健全
- [ ] 将技术需求基数列为缺失的输入
- [ ] 不从架构文档本身重建需求列表并据此评判覆盖率

### Case 7: 阶段闸门——针对即将进入的阶段评判
**Scenario:** `/gate-check technical-setup` 在 `workflow: standard` 下生成 TD-PHASE-GATE。上下文给出目标阶段（Technical Setup）、档位，以及该档位下闸门要求和建议的产出物：一份枚举 MVP 系统的系统索引、每份处于 5 个标准章节且已评审的 MVP GDD，以及——建议性的——跨 GDD 评审报告。全部存在；系统索引双向给出每个系统的依赖和数据流。引擎参考路径为 `docs/engine-reference/godot/VERSION.md`。架构文档和 ADR 列表以 "not expected before Pre-Production" 传入。
**Expected:** 返回 `TD-PHASE-GATE: READY`——系统与 GDD 提供了足够的架构依据，这正是进入 Technical Setup 所需。缺失的架构文档和 ADR 是即将进入阶段的工作，而非该阶段的缺口。
**Variant:** 同一项目在目标阶段为 Pre-Production 时，架构文档是必需的且以 "none" 传入 → `TD-PHASE-GATE: NOT READY` 或 `CONCERNS`，并点名缺失的架构文档。
**Assertions:**
- [ ] 结论恰为 READY / CONCERNS / NOT READY 之一（TD-PHASE-GATE 的结论词汇），格式为 `TD-PHASE-GATE: READY`
- [ ] 当架构文档或 ADR 以 "not expected before Pre-Production" 传入时，不将其列为阻塞项或关注项
- [ ] 不对其回答 NOT ASSESSED——以「尚未预期」传入的产出物既不是发现，也不是缺失输入
- [ ] Variant：目标阶段要求、却以 "none" 传入的产出物是一项发现（NOT READY 或 CONCERNS）——而非 NOT ASSESSED

---

## Protocol Compliance

- [ ] 返回所调用闸门定义文件列出的结论词汇——TD-ARCHITECTURE、TD-ADR、TD-SYSTEM-BOUNDARY、TD-ENGINE-RISK、TD-MANIFEST 和 TD-CHANGE-IMPACT 为 APPROVE / CONCERNS / REJECT；TD-FEASIBILITY 为 VIABLE / CONCERNS / HIGH RISK；TD-PHASE-GATE 为 READY / CONCERNS / NOT READY；任何闸门在缺少其指定输入时返回 `NOT ASSESSED` 并说明该输入
- [ ] 保持在声明的技术领域内
- [ ] 将设计优先级冲突交给 creative-director
- [ ] 在输出中使用闸门 ID（例如 `TD-FEASIBILITY: CONCERNS`），而非行文中的散文式结论
- [ ] 不做出有约束力的游戏设计或创意方向决定
- [ ] 在阶段闸门上，将调用技能以 "none" 传入、但目标阶段所需的产出物视为一项发现（NOT READY 或 CONCERNS）；将以 "not expected before [phase]" 或 "not required at `workflow: [tier]`" 传入的产出物视为无发现——它评判的是即将进入阶段的就绪度，而非更靠后阶段

---

## Coverage Notes
- TD-ADR 仅覆盖了平台冲突（Case 5）；对缺少章节或未标记后截止日期 API 的 ADR 尚无用例。
- 未覆盖针对具体引擎版本（例如 Godot 4.6 后截止日期 API）的 TD-ENGINE-RISK 评估——推迟到引擎专家集成测试。
- TD-PHASE-GATE 仅覆盖了一个目标阶段（Case 7）；其后续阶段判断（Production 及之后：架构在构建中是否经得起考验？）尚无用例。
- 此处未覆盖多领域架构评审（例如同时触及 TD-ARCHITECTURE 和 TD-ENGINE-RISK）。
