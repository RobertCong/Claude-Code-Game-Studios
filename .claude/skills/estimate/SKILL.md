---
name: estimate
description: "根据复杂度、依赖、速度和风险估算任务工作量。给出带置信度等级的结构化估算。"
argument-hint: "[task-description]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: sonnet
---

# 估算

## Phase 1: 理解任务

从参数中读取任务描述。如果描述过于含糊、无法进行有意义的估算，请先请求澄清再继续。

阅读 CLAUDE.md 了解项目背景：技术栈、编码规范、架构模式以及任何估算准则。

如果任务涉及已记录的功能或系统，请阅读 `design/gdd/` 中相关的设计文档。按章节阅读：用 Grep 工具（模式 `^#`，content 模式）找到所需标题，再用 offset 和 limit 读取相应区间。

---

## Phase 2: 扫描受影响的代码

识别需要改动的文件与模块：

- 对每个受影响文件，用 Grep 测量规模与分支数——Read、Glob 和 Grep
  是本技能仅有的工具，因此这些计数就是测量结果：
  - **规模：** `Grep pattern="[^[:space:]]" path="[file]" output_mode="count"`——
    统计非空行。
  - **分支数：** `Grep pattern="(^|[^A-Za-z0-9_])(if|elif|for|foreach|while|match|switch|case|catch)([^A-Za-z0-9_]|$)|&&|[|][|]" path="[file]" output_mode="count"`——
    统计包含分支或布尔运算符的行。该计数近似圈复杂度
    （注释和字符串也会计入）；请按近似值报告，
    绝不要当作实测的复杂度。
  - **依赖：** 每个文件引入了什么——`preload`/`load(`（GDScript）、
    `using`（C#）、`#include`（C++）——以及哪些其他文件引用了它。
  - 把 Grep 无法计数的文件（缺失、二进制、不可读）列入“备注
    与假设”，而不是从总数中遗漏。
- 识别与其他系统的集成点
- 检查受影响区域中现有的测试覆盖率
- 从 `production/sprints/` 读取过往冲刺数据，寻找类似的已完成任务和历史速度。
  **如果没有**，请在“备注与假设”中说明——“未找到冲刺历史；
  本估算未按团队速度校准”——并把它视为置信度等级中的一项风险，
  而不是悄悄给数字加余量。

---

## Phase 3: 分析复杂度因素

**代码复杂度：**
- 受影响文件的规模与分支数（第 2 阶段的 Grep 计数）
- 依赖数量与耦合程度
- 是否触及核心/引擎代码，还是叶子/功能代码
- 可以沿用现有模式，还是需要新模式

**范围：**
- 涉及的系统数量
- 新代码与现有代码修改的比例
- 需要新增的测试覆盖量
- 所需的数据迁移或配置变更

**风险：**
- 新技术或不熟悉的库
- 不清楚或含糊的需求
- 对未完成工作的依赖
- 跨系统集成的复杂度
- 性能敏感度

---

## Phase 4: 生成估算

```markdown
## Task Estimate: [Task Name]
Generated: [Date]

### Task Description
[Restate the task clearly in 1-2 sentences]

### Complexity Assessment

| Factor | Assessment | Notes |
|--------|-----------|-------|
| Systems affected | [List] | [Core, gameplay, UI, etc.] |
| Files likely modified | [Count] | [Key files listed below] |
| Size of affected files | [N non-blank lines; M branch lines] | Grep counts; branch lines approximate complexity |
| New code vs modification | [Ratio] | |
| Integration points | [Count] | [Which systems interact] |
| Test coverage needed | [Low / Medium / High] | |
| Existing patterns available | [Yes / Partial / No] | |

**Key files likely affected:**
- `[path/to/file1]` -- [what changes here]

### Effort Estimate

| Scenario | Days | Assumption |
|----------|------|------------|
| Optimistic | [X] | Everything goes right, no surprises |
| Expected | [Y] | Normal pace, minor issues, one round of review |
| Pessimistic | [Z] | Significant unknowns surface, blocked for a day |

**Recommended budget: [Y days]**

### Confidence: [High / Medium / Low]

[Explain which factors drive the confidence level for this specific task.]

### Risk Factors

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|

### Dependencies

| Dependency | Status | Impact if Delayed |
|-----------|--------|-------------------|

### Suggested Breakdown

| # | Sub-task | Estimate | Notes |
|---|----------|----------|-------|
| 1 | [Research / spike] | [X days] | |
| 2 | [Core implementation] | [X days] | |
| 3 | [Testing and validation] | [X days] | |
| | **Total** | **[Y days]** | |

### Notes and Assumptions
- [Key assumption that affects the estimate]
- [Any caveats about scope boundaries]
```

输出估算，并附一段简要总结：推荐预算、置信度等级以及最大的单一风险因素。

本技能是只读的——不写入任何文件。结论：**COMPLETE**——已生成估算。

---

## Phase 5: 下一步

- 如果置信度为低：建议在做出承诺前先做一个限时调研（`/prototype`）。
- 如果任务超过 10 天：建议通过 `/create-stories` 将其拆分为更小的用户故事。
- 若要安排该任务：运行 `/sprint-plan update` 把它加入下一个冲刺（如果项目没有冲刺计划，例如默认的 minimal 工作流，则改为加入简报的构建顺序）。

### 指导原则

- 始终给出区间（乐观 / 预期 / 悲观），绝不给单一数字
- 推荐预算应取预期估算，而不是乐观估算
- 按半天粒度取整——用小时估算会给超过一天的任务带来虚假的精确感
- 不要悄悄加余量——明确点出风险，让团队自行决定
- 当方案尚未确定或核心需求仍待定时，置信度一律为低——建立在未定决策上的区间只是猜测
