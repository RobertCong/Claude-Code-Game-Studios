---
name: tech-debt
description: "跟踪、分类并排定整个代码库中的技术债 —— 扫描技术债指标，并维护登记册。"
argument-hint: "[scan|add|prioritize|report]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow`

# 技术债



每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

## Phase 1: 解析子命令

根据参数确定模式：

- `scan` —— 扫描代码库中的技术债指标
- `add` —— 手动添加一条新的技术债条目
- `prioritize` —— 重新排定现有债务登记册的优先级
- `report` —— 生成当前债务状况的摘要报告

如果未提供子命令，输出用法并停止。Verdict：**FAIL** —— 缺少必需的子命令。

---

## Phase 2A: 扫描模式

在**代码根目录**中搜索技术债指标（按 `.trae/docs/code-root-resolution.md` 解析：依引擎为
`src/`、`Assets/` 或 `Source/`）：

- `TODO` 注释（计数并分类）
- `FIXME` 注释（这些是伪装成技术债的缺陷）
- `HACK` 注释（需要正规解决方案的临时变通）
- `@deprecated` 标记
- 重复的代码块（多个文件中出现的相似模式）
- 超过 500 行的文件（可能是上帝对象）
- 超过 50 行的函数（可能过于复杂）

对每项发现分类：

- **架构债务**：错误的抽象、缺失的模式、耦合问题
- **代码质量债务**：重复、复杂度、命名、缺失类型
- **测试债务**：缺失测试、不稳定测试、未覆盖的边界情况
- **文档债务**：缺失文档、过时文档、未文档化的 API
- **依赖债务**：过时的软件包、已弃用的 API、版本冲突
- **性能债务**：已知的慢路径、未优化的查询、内存问题

**在呈现任何内容之前，先确认确实有东西可扫描。** 统计扫描实际覆盖的源文件数量。如果代码根
目录无法解析，报告 `NOT ASSESSED — code root unresolved` 并按下方说明停止。如果该计数为
**零** —— 代码根目录不存在，或其中没有任何源文件 —— 报告：

> **NOT ASSESSED — no source files to scan.** 代码根目录中没有任何代码，所以"未发现技术债
> 指标"只是关于一次空搜索的陈述，而不是关于代码库的陈述。请在实现工作开始后再运行本技能。

然后停止。不要写入登记册，也不要给出 COMPLETE 结论。

这一区分正是扫描的全部要点：**在 400 个文件中零发现是干净的代码库；在零个文件中零发现则
完全没有信息。** 把两者都渲染为"COMPLETE —— 扫描发现已写入登记册"会被读成前者。报告发现时
必须给出分母，包括分母很大而计数确实为零的情况。

向用户呈现发现。

询问："我可以把这些发现写入 `docs/tech-debt-register.md` 吗？"

若同意，更新登记册，绝不覆盖它。**追加前先匹配：** 与现有 `Open` 条目文件和债务种类相同的
发现，更新该条目而不是新增重复项。若现有 `Open` 条目所描述的模式已不在其文件中，则提议将其
标记为 `Resolved [date]` —— 列出这些条目并纳入同一次批准。Verdict：**COMPLETE** —— 扫描发现
已写入登记册。

若不同意，就此停止。Verdict：**BLOCKED** —— 用户拒绝写入。

---

## Phase 2B: 添加模式

向用户询问描述与受影响文件（纯文本提示）。

**作为子 agent 运行？** `lead-programmer` 会预加载本技能，而子 agent 没有 `AskUserQuestion`。
在一条回复中返回下面的三个问题（类别、工作量、影响），每个以简短选项列表形式给出，然后
停止：调用你的人会去询问用户。在回答返回之前，不向登记册写入任何内容。

然后使用 `AskUserQuestion` 收集**类别**：
- 提示："这项技术债属于哪个类别？"
- 选项：
  - `[A] 架构债务 —— 错误的抽象、缺失的模式、耦合问题`
  - `[B] 代码质量债务 —— 重复、复杂度、命名、缺失类型`
  - `[C] 测试债务 —— 缺失测试、不稳定测试、未覆盖的边界情况`
  - `[D] 文档债务 —— 缺失/过时的文档、未文档化的 API`
  - `[E] 依赖债务 —— 过时的软件包、已弃用的 API、版本冲突`
  - `[F] 性能债务 —— 已知的慢路径、内存问题、未优化的查询`

然后使用 `AskUserQuestion` 收集**预估修复工作量**：
- 提示："修复这一项预计需要多少工作量？"
- 选项：
  - `[A] S —— 小（1 天以内）`
  - `[B] M —— 中（1–3 天）`
  - `[C] L —— 大（3–7 天）`
  - `[D] XL —— 特大（超过 1 周）`

然后使用 `AskUserQuestion` 收集**若不修复会带来的影响** —— 即登记册的 Impact 列，由
`/tech-debt prioritize` 打分：
- 提示："如果永远不修，这会带来什么代价？"
- 选项：`[A] Low` / `[B] Med` / `[C] High` / `[D] Critical`

向用户呈现完整的新条目。

**追加前先匹配：** 若现有 `Open` 条目已具有相同的文件和相同的类别，向用户展示它，并询问是否
改为更新该条目而不是新增重复项。

询问："我可以把此条目追加到 `docs/tech-debt-register.md` 吗？"（若匹配到条目，则问"我可以
改为更新现有条目吗？"）

若同意，追加条目（或更新匹配到的条目）。Verdict：**COMPLETE** —— 条目已加入登记册。

若不同意，就此停止。Verdict：**BLOCKED** —— 用户拒绝写入。

---

## Phase 2C: 优先级模式

读取 `docs/tech-debt-register.md` 处的债务登记册。若不存在：
Verdict：**NOT ASSESSED** —— `docs/tech-debt-register.md` 处没有登记册；请先运行
`/tech-debt scan`。停止。

按各条目自身的列打分：`impact ÷ effort`，其中 Impact 的 `Low` 为 1、`Med` 为 2、`High` 为
3、`Critical` 为 4，Effort 的 `S` 为 1、`M` 为 2、`L` 为 3、`XL` 为 4，四舍五入到一位小数
并写入 Priority。分值高者在前；同分时较旧的 `Added` 日期优先。Impact 或 Effort 为 `—` 的
条目不打分：把它们列在已打分条目之后，注明"not scored —— [column] not judged"，而不是猜测
一个分值。

按优先级分数重新排序登记册，并建议下个冲刺应纳入哪些条目（在 `workflow: minimal` 下没有
冲刺，则建议接下来构建哪些）。

向用户呈现重新排定优先级后的登记册。

询问："我可以把重新排定优先级后的登记册写回 `docs/tech-debt-register.md` 吗？"

若同意，写入更新后的文件。Verdict：**COMPLETE** —— 登记册已重新排定优先级并保存。

若不同意，就此停止。Verdict：**BLOCKED** —— 用户拒绝写入。

---

## Phase 2D: 报告模式

读取债务登记册。若不存在：Verdict：**NOT ASSESSED** —— 没有可报告的登记册；请先运行
`/tech-debt scan`。停止。

生成汇总统计：

- 按类别统计未关闭条目及其预估修复总工作量
- 当前冲刺期间新增与解决的条目，依据每个条目的 `Added` 日期及其 `Resolved [date]` 状态
- 趋势方向（增长 / 稳定 / 缩减）—— 该时间窗内的新增与解决对比

标记任何在登记册中已存在超过 3 个冲刺的条目。

向用户输出报告。该模式为只读 —— 不写入任何文件。Verdict：**COMPLETE** —— 债务报告已生成。

---

## Phase 3: 后续步骤

- 运行 `/sprint-plan`，把高优先级债务条目安排进下一个冲刺（在 `workflow: minimal` 下没有
  冲刺，改为把它们加入简报的构建顺序）。
- 在每个冲刺开始时运行 `/tech-debt report`，以跟踪债务随时间的变化趋势。

### 债务登记册格式

```markdown
## Technical Debt Register
Last updated: [Date]
Total items: [N] | Estimated total effort: [T-shirt sizes summed]

| ID | Category | Description | Files | Effort | Impact | Priority | Status | Added | Sprint |
|----|----------|-------------|-------|--------|--------|----------|--------|-------|--------|
| TD-001 | [Cat] | [Description] | [files] | [S/M/L/XL] | [Low/Med/High/Critical] | [Score] | [Open / Resolved YYYY-MM-DD / Accepted — reason] | [YYYY-MM-DD] | [Sprint to fix or "Backlog"] |
```

每一个会添加行的技能 —— 本技能，以及 `/story-done` 在把偏差记录为债务时 —— 都按此顺序写入
全部十列；创建文件的技能先写入上面的表头与表头行：

- **ID** —— `TD-` 加三位数字，比登记册中现有最高 ID 大 1（新登记册为 `TD-001`）。ID 永不
  复用。
- **Category** —— 扫描模式下六个类别之一，书写时不带 "Debt"：`Architecture`、`Code Quality`、
  `Test`、`Documentation`、`Dependency`、`Performance` —— 与 `/story-done` 写出的拼写一致，
  这样报告模式才能对它们统一归组。
- **Description** —— 这项债务是什么，以及为何承担它。
- **Files** —— 受影响的路径，以逗号分隔；当该债务没有单一文件时写作 `—`。
- **Effort** —— `S`、`M`、`L` 或 `XL`，与添加模式一致；尚未估算时为 `—`。
- **Impact** —— `Low`、`Med`、`High` 或 `Critical`：若不修复的代价；尚未判断时为 `—`。
- **Priority** —— 由 `/tech-debt prioritize` 写入的分数；在它运行之前为 `—`。
- **Status** —— 添加时为 `Open`。`Resolved YYYY-MM-DD` 记录债务被修复的日期；
  `Accepted — reason` 记录有意保留它的决定。
- **Added** —— 写入该行的日期，`YYYY-MM-DD`。报告模式依据此日期和 `Resolved` 日期统计新增
  与已解决条目。
- **Sprint** —— 计划修复它的冲刺，或 `Backlog`。

### 规则
- 技术债本身并非坏事 —— 它是一种工具。登记册跟踪的是有意识的决策。
- 每条债务条目都必须解释为什么接受它（截止日期、原型、信息缺失）
- "扫描"应至少每个冲刺运行一次，以发现新的债务
- 超过 3 个冲刺仍无行动的条目，要么修复，要么以有据可查的理由有意识地接受