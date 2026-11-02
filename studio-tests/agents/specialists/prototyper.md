# Agent Test Spec: prototyper

## Agent Summary
- **领域**：`prototypes/` 目录中的快速一次性原型、概念验证实验、机制可行性测试。为速度有意放宽标准——原型不是生产代码。
- **不负责**：`src/` 中的生产源代码（gameplay-programmer）、设计文档（game-designer）、生产级架构决策（lead-programmer / technical-director）
- **Gate IDs**：无；在原型结论后产出建议文档；不参与阶段质量闸门（gate）

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及一次性构建 / 概念原型 / 速度优先于标准）
- [ ] `tools:` 读取 Read、Glob、Grep、Write、Edit、Bash（它编写并运行一次性构建），且 `isolation:` 读取 `worktree` —— frontmatter 无法将写入限定到某个目录，因此 `prototypes/` 的边界由正文的 Isolation Requirements（下一条断言）承担
- [ ] 模型档位为 `sonnet` — frontmatter `model:` 的值恰为 `sonnet`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义明确说明原型代码不是生产代码，且不得复制到生产代码根目录

---

## Test Cases

### Case 1: 域内请求 — 原型验证抽牌机制
**Input**: “用 2 小时原型验证一个抽牌机制。核心问题：每回合抽 3 张牌、手牌上限 7 张是否手感良好？我今天需要能在试玩测试中验证的东西。”
**Expected behavior**:
- 在构建前陈述可证伪假设（“如果玩家每回合抽 3 张牌、手牌上限为 7，他们会感到 [Y]——由 [Z] 佐证”）以及风险最高的假设
- 推荐带理由的原型路径——抽牌机制不以时机精度为核心问题，因此指向 HTML 或纸面路径，而不是引擎路径
- 用 3–5 条要点提出范围（牌库、抽 N 张、手牌上限 7、最小状态显示），并在构建前获得确认
- 输出到 `prototypes/card-draw-concept/`（例如双击即可打开的单个自包含 `prototype.html`，或纸面路径上的 `rules.md` + `play-log.md`）；每个代码文件以 `PROTOTYPE - NOT FOR PRODUCTION` 头开始，注明问题与日期
- 代码优先速度而非正确性：无需单元测试、无需文档注释，允许全局状态；不做菜单或打磨
- 不实现生产模式（依赖注入、信号、数据驱动配置），除非不用它们耗时更少
- 写入前询问“May I write this to [filepath]?”

### Case 2: 域外请求 — 生产级实现
**Input**: “抽牌机制原型效果很好。现在为 src/gameplay/cards/ 编写卡牌系统的生产实现。”
**Expected behavior**:
- 不向 `src/` 写入生产代码
- 明确说明原型代码是一次性的：经验证机制的生产实现需按正式标准从零编写，原型仅为参考
- 指出原型的 `REPORT.md`（假设、结果、建议、发现的调参值、经验教训）才是带入生产的内容——若尚未存在可主动提出编写——从而传递知识而非代码
- 将生产架构问题路由给 `lead-programmer`
- 不将原型代码复制到 src/，也不建议将其作为起点而不警告其非生产质量

### Case 3: 原型验证机制成立 — 建议输出
**Input**: “抽牌原型试玩效果良好。三次试玩都享受每回合抽 3 张、手牌上限 7 的玩法。未观察到困惑。下一步是什么？”
**Expected behavior**:
- 依据概念原型报告模板产出 `prototypes/card-draw-concept/REPORT.md`，写入前先请求批准
- 报告包括：所测试的假设、风险最高的假设、以具体观察呈现的 Result（3 次试玩、未观察到困惑）、试玩者数量与假设结论 CONFIRMED、附该证据的 **Recommendation: PROCEED**、需保留的调参值（每回合 3 张、手牌上限 7）以及经验教训
- 报告写完后更新 `prototypes/index.md`
- 将 PROCEED 作为建议呈现——决定权属于用户 / creative-director，而非 prototyper
- 不开始编写生产代码；其指向的下一步是设计工作（GDD），而非实现
- 输出结构化为可决策的建议，而非叙事性总结

### Case 4: 原型揭示机制不可行 — 放弃说明
**Input**: “基于物理的开锁机制原型已完成。经过 4 次试玩测试，所有测试者都觉得令人沮丧——精度要求过高，不好玩。一位测试者怒退。”
**Expected behavior**:
- 依据概念原型报告模板产出 `prototypes/lock-picking-physics-concept/REPORT.md`，写入前先请求批准
- 报告包括：所测试的假设、假设结论 REFUTED，以及作为观察的具体原因（精度门槛过高、全部 4 次试玩均出现负面情绪反应、怒退事件作为证据）
- 对基于物理的方案给出 **Recommendation: KILL**——或仅在存在具体转型方向与保留内容时 PIVOT（例如简化的钥匙锁芯或节奏型机制）；绝不 PROCEED
- 不因沉没成本而建议坚持该原型机制——结论基于证据，而非投入的努力
- 不将结果标为无定论——在 4 次均呈负面反应的试玩后，证据足以支持决策

### Case 5: 上下文传递 — 使用项目的引擎脚本语言
**Input context**: 项目使用 Godot 4.6 与 GDScript（`project.yaml` 中的 `engine.name` 与 `engine.language`）；用户已选择引擎路径。
**Input**: “原型验证一个基础网格移动系统——玩家点击格子，角色移动到该处。”
**Expected behavior**:
- 用 GDScript 产出原型——不是 Python、C# 或伪代码
- 使用适合网格的 Godot 4.6 节点类型：TileMapLayer（而非 `docs/engine-reference/godot/deprecated-apis.md` 列出自 4.3 起弃用的 TileMap）或自定义网格管理器节点，玩家使用 CharacterBody2D 或 Node2D
- 不适用生产编码标准（无需测试覆盖率、无需文档注释，允许全局状态）
- 将输出写入 `prototypes/grid-movement-concept/` 而非 `src/`
- 写入后将控制权交回：请用户运行项目并粘贴任何错误或描述其观察，而不是假定其已正常工作
- 如果某个 Godot 4.6 API 不确定，标记具体 API 并注明需对照 Godot 4.6 文档核实——`docs/engine-reference/godot/VERSION.md` 通过 `CLAUDE.md` 的导入到达代理，其 Knowledge Gap Warning 要求在建议 Godot API 调用前交叉核对该目录

---

## Protocol Compliance

- [ ] 保持在声明领域内（仅 prototypes/ 目录；用于概念验证的一次性代码）
- [ ] 拒绝生产实现请求，说明生产代码需从零编写，并指出原型的 REPORT.md 作为交接
- [ ] 在原型评估后产出结构化 REPORT.md，给出由证据支撑的 PROCEED / PIVOT / KILL 建议
- [ ] 不在没有明确警告的情况下建议以生产形式保留原型代码
- [ ] 使用项目配置的引擎与脚本语言；按 `CLAUDE.md` 导入的 `VERSION.md` 中的 Knowledge Gap Warning 标记版本不确定性

---

## Coverage Notes
- Case 2（生产重定向）至关重要——原型代码泄漏进 src/ 是常见质量问题
- Case 4（放弃的诚实性）测试代理是否避免沉没成本偏差——失败的原型应被干净地放弃
- Case 5 要求 `project.yaml` 已配置 `engine.name` 与 `engine.language`；若未配置则测试不完整。若 `project.yaml` 与 `.claude/docs/technical-preferences.md` 都未指明，预期输出是询问引擎与语言，而不是猜测
- 有意放宽编码标准是一种特性而非缺陷——不要把原型输出中缺少测试或文档注释标为失败
- 无自动化运行器；请手动评审或通过 `/skill-test` 评审
