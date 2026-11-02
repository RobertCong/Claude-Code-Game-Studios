# Phase 5: QA 主管评审（QL-STORY-READY）

仅当 `review_gate` 行显示 `skill-gates=run`（`review_mode: full`）时阅读。
在故事起草完成之后、Phase 6 写入询问之前运行它。

**先看已有的 QA 计划。** 查找最新的 `production/qa/qa-plan-*.md`。如果
其 Automated Tests Required 章节包含本史诗中故事的规格（按
标题或 slug 匹配），它们可以代替 agent 的规格。两者不同时，询问：
“Which test specs should these stories carry?” 选项：The QA plan's / The QA
lead's / None yet。“None yet”会写入
`*Test cases not yet defined — run /qa-plan to generate them.*` 这绝不会增加
第二次交接。

**把评审交给 `qa-lead` agent，仅一次，** 使用闸门 **QL-STORY-READY**。该
agent 读取自己的闸门文件；不要在这里读取它。一份报告同时携带
结论和规格：绝不要为规格再交给它第二项工作。

简报：
- **目标：** 判断每个已起草故事的验收标准是否可测试，并为通过的故事
  编写测试规格。
- **交给它：** 完整故事列表内联（尚无故事文件存在，因此故事
  代替闸门的路径），每个都附其验收标准、类型，以及带来自
  `tr-registry.yaml` 需求文本的 TR-ID；以及史诗 GDD 的
  验收标准作为参考。
- **返回：** 每个故事为 ADEQUATE、GAPS、INADEQUATE，或 NOT ASSESSED 并点名
  缺失的输入。对于每个 ADEQUATE 故事，其规格块按以下格式：Logic 和 Integration
  每个验收标准一个 Given/When/Then，Visual/Feel 和 UI 用人工步骤。
- **边界：** 它不写任何文件。

对每个故事的结论采取行动：

- **ADEQUATE：** 保留其规格。
- **GAPS：** 询问：“How do you want to handle the flagged criteria?” 选项：Revise
  them / Accept and go on / Discuss further。回答之前不要修改任何内容。选择
  Revise：起草新的验收标准，展示它们，并在一次后续简报中只把这些故事送回
  agent。选择 Accept：验收标准保持不变，故事的
  QA Test Cases 读作 `*Test cases not yet defined — run /qa-plan to generate them.*`
- **INADEQUATE：** 故事按现状不应写入。与用户一起修改其验收标准
  （起草、展示、确认），然后向 agent 索取其规格。如果用户
  不愿修改，就把它从本次运行中移除，并在 Phase 6 列表中
  点名它已被移除。
- **NOT ASSESSED：** 不等于 ADEQUATE。点名缺失的输入，然后补充它并再次
  询问，或在没有规格的情况下写入故事（`/qa-plan` 行）并在 Phase 6 列表中标记为
  `QL-STORY-READY: NOT ASSESSED — [input]`。

故事只有在 ADEQUATE 后才携带规格：不可测试的验收标准无法被正确
构建。规格写入故事的 `## QA Test Cases`；用户依据它们构建，
不自行编造新的。

Logic 和 Integration：

```
Test: [criterion text]
  Given: [precondition]
  When: [action]
  Then: [expected result]
  Edge cases: [boundary values or failure states]
```

Visual/Feel 和 UI：

```
Manual check: [criterion text]
  Setup: [how to reach the state]
  Verify: [what to look for]
  Pass condition: [an unambiguous pass]
```
