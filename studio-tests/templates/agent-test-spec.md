# Agent Test Spec: [agent-name]

## Agent Summary

[用一段话描述该代理的负责域、它拥有哪些决策权，以及哪些工作委托出去、哪些直接处理。
注明它会触发哪些闸门（如有）。]

**Domain**: [该代理负责的文件/目录]
**Escalates to**: [父级代理——例如设计冲突时上报给 creative-director]
**Delegates to**: [该代理通常派生的子代理]

---

## Static Assertions (Structural)

- [ ] 代理文件存在于 `.trae/agents/[name].md`
- [ ] Frontmatter 包含 `name`、`description`、`model`、`tools` 字段
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 清晰声明负责域
- [ ] 记录上报路径
- [ ] 不在其负责域之外做决策

---

## Test Cases

### Case 1: In-Domain Request — [brief name]

**Scenario**：明显属于该代理负责域的请求。

**Fixture**：
- [相关项目状态]
- [提供给代理的输入]

**Expected behavior**：
1. 代理接受请求
2. 代理产出[特定输出类型]
3. 代理在写入文件前征询同意（如适用）

**Assertions**：
- [ ] 代理在其负责域内处理请求，不上报
- [ ] 输出格式符合预期结构
- [ ] 遵循协作协议（征询 → 起草 → 批准）

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 2: Out-of-Domain Redirect — [brief name]

**Scenario**：落在该代理负责域之外的请求。

**Fixture**：
- [属于其他代理的请求]

**Expected behavior**：
1. 代理识别出该请求超出负责域
2. 代理将其转交给正确的代理
3. 代理不尝试处理该请求

**Assertions**：
- [ ] 代理拒绝并转交（不静默处理跨域工作）
- [ ] 转交时指明正确的代理

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 3: Gate Verdict — [brief name]

**Scenario**：代理作为总监闸门检查的一部分被调用。

**Fixture**：
- [提交评审的项目状态]
- [闸门 ID：例如 CD-PHASE-GATE]

**Expected behavior**：
1. 代理先读取闸门的定义文件，再读取其中点名的文档
2. 代理以 `[GATE-ID]: [word]` 开头，其中 `[word]` 取自该闸门的 **Verdicts** 行
3. 代理将结论返回给调用方技能，自身不据此采取行动

**Assertions**：
- [ ] 第一行为 `[GATE-ID]: [word]`，word 取自被调用闸门的 Verdicts 行——或在闸门点名的某项输入未提供时，为 `NOT ASSESSED` 并指明该输入
- [ ] 为结论提供理由
- [ ] 代理在给出自身结论后不再继续推进被评审的工作——阻断取决于闸门失败词的调用方技能而非代理本身（CONCERNS 不构成阻断；技能会将其提交给用户）

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 4: Conflict Escalation — [brief name]

**Scenario**：该代理的负责域与其他代理的决策发生冲突。

**Fixture**：
- [两个同级代理给出的相互冲突的决策]

**Expected behavior**：
1. 代理识别冲突
2. 代理上报给共同的父级（或 creative-director / technical-director）
3. 代理不单方面解决跨域冲突

**Assertions**：
- [ ] 冲突被显式呈现
- [ ] 遵循正确的上报路径
- [ ] 未进行单方面的跨域改动

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

### Case 5: Context Pass-Through — [brief name]

**Scenario**：代理收到来自父级代理、带有完整上下文的任务。

**Fixture**：
- [从父级传入的上下文块]
- [要执行的具体子任务]

**Expected behavior**：
1. 代理读取并使用所提供的上下文
2. 代理完成子任务
3. 代理将结果返回给父级（不必要地询问用户）

**Assertions**：
- [ ] 代理使用所提供的上下文，而非重复询问
- [ ] 结果限定在子任务范围内，不向外扩展
- [ ] 输出格式适合父级代理消费

**Case Verdict**: PASS / FAIL / PARTIAL / NOT ASSESSED

---

## Protocol Compliance

- [ ] 保持在声明的负责域内——不做单方面的跨域改动
- [ ] 将冲突上报给正确的父级
- [ ] 在文件写入前使用 `"May I write"`（或本身为只读）
- [ ] 在请求批准前呈现发现
- [ ] 不在委托层级中跳级

---

## Coverage Notes

[覆盖率方面的任何缺口、已知但未测试的边缘情况，或需要实际调用代理才能验证的
行为。]
