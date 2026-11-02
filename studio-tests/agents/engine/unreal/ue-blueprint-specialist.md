# Agent Test Spec: ue-blueprint-specialist

## Agent Summary
- **Domain**: Blueprint 架构、Blueprint/C++ 边界、Blueprint 图表质量、Blueprint 性能优化、Blueprint Function Library 设计
- **Does NOT own**: C++ 实现（gameplay-programmer 负责暴露 Blueprint 调用的 C++ 钩子）、美术资源或着色器、UI/UX 流程设计（ux-designer）
- **Gate IDs**: None；C++/Blueprint 边界架构裁定交由 unreal-specialist

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 Blueprint 架构与优化）
- [ ] `tools:` 列表符合该代理角色（Read/Write/Edit 用于 Blueprint 相关文件；不含服务器或部署工具，Bash 通过 `disallowedTools:` 排除）
- [ ] 模型档位为 `sonnet` —— frontmatter `model:` 精确为 `sonnet`（档位见：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对 C++ 实现决策拥有权限

---

## Test Cases

### Case 1: In-domain request — Blueprint 图表性能评审
**Input**: "评审我们的 AI 行为 Blueprint。它每帧运行基于 tick 的逻辑，同时为 30 个 NPC 检查视线。"
**Expected behavior**:
- 识别出以 tick 为主的逻辑是性能问题
- 建议从 EventTick 改为事件驱动模式（感知系统事件、定时器，或以更低频率轮询）—— 当事件足以胜任时，绝不每帧轮询
- 指出同时进行视线检查的逐 NPC 开销，包括 Tick 内对 NPC 数组的任何循环
- 建议先做性能分析（`stat game`、Blueprint Profiler），并在实测 Blueprint 开销显著时，认为将系统迁移到 C++ 是合理的 —— 30 个 NPC 低于其自动转 C++ 的阈值（超过 100 个实例的 tick 逻辑）
- 对每个发现，输出其所违反的 Performance Rule 或 Review Checklist 条目，以及替代方案

### Case 2: Out-of-domain request — C++ 实现
**Input**: "为这个技能冷却系统编写 C++ 实现。"
**Expected behavior**:
- 用其边界规则对该冷却系统分类：技能系统逻辑在其「Must Be C++」列表中，因此它不会提供该系统的 Blueprint 重新实现
- 转而描述边界：C++ 定义框架并暴露钩子（`BlueprintCallable`、`BlueprintNativeEvent`、`BlueprintImplementableEvent`）；Blueprint 提供调优数值（`EditAnywhere` / `BlueprintReadWrite`）以及简单的事件响应，如冷却反馈
- 将 C++ 实现转交 gameplay-programmer（其指定伙伴，负责向 Blueprint 暴露 C++ 钩子），将边界决策转交 unreal-specialist，而不是自行编写 C++ 系统

### Case 3: Domain boundary — Blueprint 中不安全的裸指针访问
**Input**: "我们的 Blueprint 调用 GetOwner() 后立即访问其结果上的组件，没有检查是否有效。"
**Expected behavior**:
- 将其标记为运行时崩溃风险，依据其 Review Checklist 条目「Error/failure paths are handled (not just the happy path)」：GetOwner() 在某些生命周期状态下可能返回 null
- 提供正确的 Blueprint 模式：在任何属性/组件访问之前使用 IsValid() 节点，并处理无效分支
- 指出对于派生自 Actor 的引用，Blueprint 的空检查不是可选的
- 不会静默修复代码 —— 解释原始写法为何不安全，并在编辑 Blueprint 前先询问

### Case 4: Blueprint 图表复杂度 — 是否适合 Function Library 重构
**Input**: "我们主 GameMode Blueprint 在单个图表中有 600+ 个节点，伤害计算逻辑在 8 处重复。"
**Expected behavior**:
- 诊断为可维护性与可测试性问题
- 建议将重复逻辑提取到 Blueprint Function Library（BFL）
- 描述如何组织 BFL：计算用纯函数，可从任意 Blueprint 静态调用
- 指出如果伤害逻辑对性能敏感或与 C++ 共享，可能适合交由 unreal-specialist 评审迁移
- 输出具体的重构计划，而非模糊建议

### Case 5: Context pass — Blueprint 复杂度预算
**Input context**: 项目约定规定，每个 Blueprint 事件图表最多 100 个节点，超过则必须提取 Function Library。
**Input**: "这是我们的背包 Blueprint 图表 [显示 150 个节点]。可以交付了吗？"
**Expected behavior**:
- 将所述的 150 节点数与项目约定中的 100 节点事件图表预算进行对照
- 标记该图表超出复杂度阈值
- 不会按现状批准
- 产出可提取到 Function Library 的候选子图列表，使主图表回到预算以内
- 对提取出的函数应用其自身标准（每个函数图表最多 20 个节点），与项目的事件图表预算保持区分，而不是用一个数字替代另一个

---

## Protocol Compliance

- [ ] 保持在声明领域内（Blueprint 架构、性能、图表质量）
- [ ] 将 C++ 实现请求转交 gameplay-programmer，将边界裁定转交 unreal-specialist
- [ ] 将发现建立在其自身的 Performance Rules 和 Blueprint Review Checklist 之上，指出每条发现所违反的规则，而非自由发挥意见
- [ ] 主动执行 Blueprint 安全模式（空检查、IsValid）
- [ ] 评估图表复杂度时引用项目约定，同时保留其自身的每函数节点上限

---

## Coverage Notes
- Case 3（空指针安全）是安全关键测试 —— 这是交付版本崩溃的常见来源
- Case 5 要求项目约定包含明确的节点预算；若未配置，代理会回退到其自身标准（每个函数图表最多 20 个节点）并说明这一点
- 无自动运行器；请手动审查或通过 `/skill-test`
