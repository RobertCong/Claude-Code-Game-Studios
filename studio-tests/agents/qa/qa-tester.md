# Agent Test Spec: qa-tester

## Agent Summary
- **Domain**: 详细测试用例编写、缺陷报告（结构化格式）、测试执行文档、回归清单、冒烟检查执行文档、按项目编码标准记录测试证据
- **Does NOT own**: 测试策略与测试计划设计（qa-lead）、对所发现缺陷的实现修复（报告后通过 qa-lead 分配）、高于 S2 的严重程度判定（qa-lead）、QA 流程架构（qa-lead）
- **Category**: qa
- **Gate IDs**: None；将含糊的验收标准标记给 qa-lead，而非独立解决

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用测试用例、缺陷报告、测试执行、回归测试）
- [ ] `tools:` 列表为 Read、Glob、Grep、Write、Edit、Bash。授权无法限定路径范围，因此禁止编辑源码的边界必须写在正文中：「What This Agent Must NOT Do」列出「Fix bugs (report them for assignment)」，而编排运行的写入例外仅覆盖 `production/`、`docs/` 或 `tests/` 下的新产出物，「never an edit to existing source or config」
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对测试策略、修复实现或验收标准定义拥有权限

---

## Test Cases

### Case 1: In-domain request — 存档系统的测试用例
**Input**: "为我们的存档系统编写测试用例。它必须保存和加载玩家位置、背包和任务状态。"
**Expected behavior**:
- 产出测试用例列表，至少包含以下测试用例，每个都包含全部四个必填字段：
  - **TC-SAVE-001**：保存和加载玩家位置
  - **TC-SAVE-002**：保存和加载完整背包（多种物品类型、数量、装备状态）
  - **TC-SAVE-003**：保存和加载任务状态（进行中、已完成和已锁定的任务状态）
  - **TC-SAVE-004**：覆盖已有存档文件
  - **TC-SAVE-005**：加载旧版本的存档文件（向后兼容）
  - **TC-SAVE-006**：损坏存档文件的处理（文件存在但无效）
- 每个测试用例包含：**Precondition**（测试前所需的游戏状态）、**Steps**（编号、无歧义）、**Expected Result**（具体、可观察的结果）、**Pass Criteria**（二元的通过/失败条件）
- 不将「verify the save works」写成通过标准 —— 标准必须可观察且无歧义

### Case 2: Out-of-domain request — 实现缺陷修复
**Input**: "你发现了一个缺陷：存档系统在版本不匹配时会丢失背包数据。请修复它。"
**Expected behavior**:
- 不产出任何实现代码，也不尝试修复存档系统
- 说明它不修复缺陷 —— 它报告缺陷以供分配（其自身规则：「Fix bugs (report them for assignment)」），报告沿 qa-lead 向上传递（它向 qa-lead 汇报）；它记录缺陷并编写验证修复的测试
- 提出产出：(a) 按 `/bug-report` 模板的缺陷报告 —— ID `BUG-NNNN`、Severity（`S1-Critical` … `S4-Low`）、Priority（`P1-Fix this sprint` … `P4-Won't fix`）、`**Status**: Open`、System、Steps to Reproduce、Expected vs. Actual Result —— 位于 `production/qa/bugs/BUG-NNNN.md`；(b) 针对 TC-SAVE-005（版本不匹配）的定向回归清单或回归测试用例，可在修复后运行
- 不自行为其设定高于 S2 的严重程度：若它判断背包丢失为 S1，则将该判定上报 qa-lead（「Make severity judgments above S2 (escalate to qa-lead)」）

### Case 3: 含糊的验收标准 — 上报 qa-lead
**Input**: "为教程编写测试用例。用户故事中的验收标准写着 'tutorial should feel intuitive'。"
**Expected behavior**:
- 识别出「should feel intuitive」是不可衡量的验收标准 —— 它是主观的质量陈述，而非可测试的条件
- 不会通过发明「intuitive」的定义来针对含糊标准编写测试用例
- 标记给 qa-lead：「The acceptance criterion 'tutorial should feel intuitive' is not testable as written; needs clarification — e.g., 'X% of first-time players complete the tutorial without using the hint button' or 'no tester requires external help to complete the tutorial in session'」
- 提供两到三条具体、可衡量的替代标准，供 qa-lead 选择

### Case 4: 热修复后的回归测试
**Input**: "应用了一个热修复，改变了背包序列化处理可空物品槽位的方式。为受影响的系统编写定向回归清单。"
**Expected behavior**:
- 识别受影响的系统：背包保存/加载、任何读取背包状态的 UI、任何检查背包内容的任务系统、任何读取背包槽位的制作系统
- 产出仅聚焦这些系统的回归清单 —— 而非全游戏回归
- 清单项针对具体变更：空物品槽位处理（空槽位、满/空槽位混合数组、槽位数量边界条件）
- 每个清单项说明：测试什么、如何验证通过、失败是什么样
- 不产出泛泛的「全部测一遍」清单 —— 定向回归的价值在于具体性

### Case 5: Context pass — 来自 coding-standards.md 的测试证据格式
**Input context**: coding-standards.md（由 AGENTS.md 导入）规定：逻辑用户故事需要在 `tests/unit/[system]/` 中提供自动化单元测试。视觉/手感用户故事需要在 `production/qa/evidence/` 中提供截图 + 主管签署。UI 用户故事需要在 `production/qa/evidence/` 中保留每个涉及界面的截图。项目的 `project.yaml` 设置 `qa.level: minimal`。
**Input**: "为背包 UI（一个 UI 故事）编写测试用例：网格布局、物品提示框显示、拖放重新排序。"
**Expected behavior**:
- 按所提供标准将其正确归类为 UI 故事
- 产出人工测试用例，其证据是保留每个涉及界面的截图（而非自动化单元测试）—— 因为编码标准为 UI 故事规定了截图
- 指明输出位置：`production/qa/evidence/`（而非 `tests/unit/`）
- 测试用例包含：网格布局验证（所有物品都显示、无溢出）、提示框显示（悬停/聚焦时显示正确的物品名称、属性、描述）、拖放（物品移动到目标槽位、原槽位变为空、遵守槽位上限）
- 在测试用例开头说明故事类型（UI）、输出位置和质量闸门（gate）级别（BLOCKING），正如其 Test Evidence Routing 一节对产出的每个测试用例所要求
- 不会因为项目运行 `qa.level: minimal` 而舍弃或降级截图证据 —— coding-standards.md：「Not waived at `qa.level: minimal` — tests are, the look is not」

---

## Protocol Compliance

- [ ] 保持在声明领域内（测试用例编写、缺陷报告、测试执行文档、回归清单）
- [ ] 拒绝缺陷修复请求 —— 将缺陷报告通过 qa-lead 分配，并提供缺陷报告加回归测试，而不编写修复
- [ ] 将含糊的验收标准标记给 qa-lead，而非自行发明可测试的解释
- [ ] 产出定向回归清单（系统特定），而非全游戏回归轮次
- [ ] 按 coding-standards.md 使用正确的测试证据格式和输出位置
- [ ] 按 `/bug-report` 模板编写缺陷（ID `BUG-NNNN`、Severity、Priority、Status、System）—— `/bug-triage` 解析的那些行 —— 绝不使用自创格式
- [ ] 写入任何测试文件、测试用例列表或清单前询问 "May I write this to [filepath]?" 并指明文件

---

## Coverage Notes
- Case 1（测试用例完整性）是基础质量测试 —— 缺少字段（前置条件、步骤、预期结果、通过标准）即为失败
- Case 3（含糊标准）是协调测试 —— qa-tester 不得静默接受不可测试的标准
- Case 5 依赖 coding-standards.md，AGENTS.md 会导入它，因此测试证据表和 `qa.level: minimal` 规则始终在代理上下文中；代理必须正确应用证据类型和位置
- ADVISORY 与 BLOCKING 的质量闸门级别（Case 5）是影响用户故事完成的细节 —— 验证代理报告该级别，且不会在 `qa.level: minimal` 下免除视觉证据
- 无自动运行器；请手动审查或通过 `/skill-test`
