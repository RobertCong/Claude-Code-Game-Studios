> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。




# 质量闸门：Production → Polish

**必需产出物：**
- [ ] 代码根中有组织为子系统的活跃代码
- [ ] GDD 中的所有核心机制都已实现（将 `design/gdd/` 与代码根交叉对照）
- [ ] 主要玩法路径可端到端游玩
- [ ] 引擎测试根下存在测试文件——`tests/unit/` 与 `tests/integration/`（Godot）、`Assets/Tests/EditMode/` 与 `Assets/Tests/PlayMode/`（Unity）、`Source/<Module>/Private/Tests/`（Unreal）——覆盖 Logic 与 Integration 用户故事
- [ ] 本冲刺的所有 Logic 用户故事在引擎的单元测试位置（`tests/unit/`、`Assets/Tests/EditMode/` 或 `Source/<Module>/Private/Tests/`）都有对应的单元测试文件
- [ ] 已运行冒烟检查，结论为 PASS 或 PASS WITH WARNINGS——报告存在于 `production/qa/`（标记为 `(quick — …)` 的 `quick` 运行不算数：它跳过了覆盖率扫描）
- [ ] `production/qa/` 中至少有一份 QA 计划（由 `/qa-plan` 生成），覆盖本冲刺、最后一个制作冲刺或本制作阶段——若缺失则运行 `/qa-plan`（CONCERNS——建议性，非阻塞）
- [ ] QA 签核报告存在于 `production/qa/`（由 `/team-qa` 生成），结论为 APPROVED 或 APPROVED WITH CONDITIONS
- [ ] `production/qa/playtests/` 中至少记录了 3 次不同的试玩测试会话
- [ ] 试玩测试报告覆盖：新玩家体验、中期游戏系统、难度曲线
- [ ] 游戏概念中的趣味假设已得到明确验证或修订

**质量检查：**
- [ ] 测试通过（通过 Bash 运行测试套件）
- [ ] 任何缺陷跟踪器或已知问题中都没有未关闭的 S1 Critical 缺陷
- [ ] 核心循环按设计运行（对照 GDD 验收标准）
- [ ] 性能在预算内（检查 `project.yaml` 中的 `performance.*`，否则参考 technical-preferences.md 中的目标）
- [ ] 试玩测试发现已经过评审，关键趣味问题已得到处理（不只是记录下来）
- [ ] 未发现“困惑循环”——游戏中没有哪个位置让超过 50% 的试玩者卡住却不知道为什么
- [ ] 难度曲线与难度曲线设计文档一致（若 `design/difficulty-curve.md` 中存在）
- [ ] 所有已实现界面都有对应的 UX 规格（没有“直接在代码里设计”的界面）
- [ ] 交互模式库已更新，涵盖实现中使用的所有模式
- [ ] 无障碍合规性已对照 `design/accessibility-requirements.md` 中确定的层级得到验证

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的
削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的
机制。

- **`full`** —— 核心机制 + Logic/Integration 测试 + 冒烟检查（PASS 或 PASS WITH WARNINGS）+ QA 签核 + 3 次以上试玩测试全部必需
- **`standard`** —— QA 签核 + 逐故事测试覆盖 → 推荐；
  **核心机制 + 冒烟检查 + 可端到端游玩 + 1 次以上有记录的
  试玩测试 + 无未关闭的 S1 Critical 缺陷**必需
- **`minimal`** —— **冒烟检查 + 可端到端游玩 + 无未关闭的 S1 Critical
  缺陷**必需；核心机制交叉检查 → 推荐；其余一切**取消**。削减放宽的是必须*存在*的东西，绝不是必须*可用*的东西——
  一个仅凭“能启动”就结束制作的闸门，并没有问过游戏是否好玩。
