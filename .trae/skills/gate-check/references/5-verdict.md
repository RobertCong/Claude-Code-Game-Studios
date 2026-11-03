# /gate-check —— 第 5 与 5a 节：结论与验证链

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 5. 输出结论

**本文件包含：**

- 5. 输出结论：报告、`NOT ASSESSED`、结论优先级
- 5a. 验证链：步骤 1-4

```
## Gate Check: [Current Phase] → [Target Phase]

**Date**: [date]
**Checked by**: gate-check skill

### Required Artifacts: [X/Y present]
- [x] design/gdd/game-concept.md (design/game-brief.md at `minimal`) — exists, 2.4KB
- [ ] docs/architecture/ — MISSING (no ADRs found)
- [x] production/sprints/ — exists, 1 sprint plan

### Quality Checks: [X/Y passing]
- [x] GDD has 8/8 required sections
- [ ] Tests — FAILED (3 failures in tests/unit/)
- [?] Core loop playtested — MANUAL CHECK NEEDED

### Blockers
1. **No Architecture Decision Records** — Run `/architecture-decision` to create one
   covering core system architecture before entering production.
2. **3 test failures** — Fix failing tests in tests/unit/ before advancing.

### Recommendations
- [Priority actions to resolve blockers]
- [Optional improvements that aren't blocking]

### Verdict: [PASS / NOT ASSESSED / CONCERNS / FAIL]
- **PASS**: All required artifacts present, all quality checks passing
- **CONCERNS**: Minor gaps exist but can be addressed during the next phase —
  the stage advances only if the user explicitly accepts them (Section 6)
- **FAIL**: Critical blockers must be resolved before advancing
- **NOT ASSESSED**: One or more required checks could not be run at all — name
  which, and why, in the Blockers section

### Accepted Risks (only when the user advanced on CONCERNS)
- [each concern, as listed above] — accepted by the user, [date]
```

**`NOT ASSESSED`——当闸门无法查看时。** 排序：它**高于 PASS**
（无法检查自身部分范围的闸门，并未确立该阶段已
就绪）且**低于 CONCERNS 和 FAIL**（已知的阻塞项比未知项更可行动，
把它降到访问问题之后会将其埋没）。它不是更温和的 FAIL：
“我检查了并发现了阻塞项”和“我无法检查”需要不同的修复——前者需要
完成工作，后者需要产出输入或让它变得可读。

**结论优先级——第一条匹配的规则胜出**，按以下顺序评估：
**FAIL**，然后 **CONCERNS**，然后 **NOT ASSESSED**，然后 **PASS**。同时存在
真实阻塞项和无法评估检查的闸门为 FAIL：阻塞项才是
可行动的发现项。带有无法评估检查的 CONCERNS 结论仍会在
阻塞项下列出该检查，标记为 NOT ASSESSED 并给出原因：正是它阻碍了
阶段推进（第 6 节），因此读者必须在关注项旁边看到它。

在以下任一情况下输出它：

- **必需产出物存在但无法评估**——为空、不可读，或
  仍完全是 `[TO BE CONFIGURED]` / 模板占位符。存在但为空
  是最像存在的那个情形。
- **质量检查的输入不携带任何实测数据**。第 3 节会把
  性能预算与“`tests/performance/` 中的剖析数据或最近的
  `/perf-profile` 输出”对比——而 `/perf-profile` 的报告模板会预填
  `[16.67ms]` 作为预算，因此它可能从零剖析数据渲染出“>99% headroom”。
  占位数字不是测量值：没人设定的预算不是
  已满足的预算。缺失数据已经会触发提示（第 4 节提议运行
  `/perf-profile`）；这里覆盖的是*存在但空洞*的数据，也就是
  看起来像测量值的那种情形。
- **层级要求的测试检查无法执行**——未配置测试运行器，
  或运行器已配置但启动失败。第 3 节会“如果配置了测试运行器”就运行
  套件，而未配置的运行器没有产生任何失败，因此测试检查对结论
  毫无贡献，闸门仍可能达到 PASS。与此同时 `testing.strict.logic` 与
  `.integration` 都默认为 `true`，所以项目自身的配置
  把那些闸门定为 BLOCKING。一个从未运行过的阻塞性闸门，正是这个
  结论要指出的未知项。补救措施已列在第 8 节的后续行动中
  （`/test-setup`）；这里说明的是结论如何处理它。

  > **把这一条限定在要求测试的层级。** 在 `qa.level: minimal` 下
  > 根本不适用任何测试闸门（见上方的配置块），因此那里缺少运行器
  > 是已配置的态势，而不是漏洞——触发它会令每个
  > `minimal` 闸门永久处于 NOT ASSESSED 并停止阶段推进，这与下方
  > 总监触发条件所警告的过度宽泛解读相同。只在已解析层级
  > 确实要求测试检查时才触发。
- **用户从未了结的 `MANUAL CHECK NEEDED` 项**。第 4 节已经
  拒绝为无法核实的事项假定 PASS 并如此标记，未了结的项会落到这里，
  绝不会落入 PASS、CONCERNS 或 FAIL 之中。
- **已解析层级本应派生**的总监没有返回——它
  报错、没有产出结论，或被中断。

  > **把这一条限定得很窄，不要把它读成“运行的总监少于四位”。**
  > 第 4b 节是*按设计*收窄面板——`minimal` 下 1 位、`standard` 下 2 位、
  > `full` 下 4 位、`solo` 下 0 位——这种收窄是有意宣布的削减，
  > 而不是评估失败。宽泛解读会让每个 `minimal`、`standard` 和 `solo`
  > 闸门永久处于 NOT ASSESSED，这意味着结论永远不可能为 PASS，
  > 第 6 节也永远无法推进 `project.stage`。**那会破坏大多数项目的阶段
  > 推进**，因为那些正是常见层级。只有当层级*确实*要求的总监
  > 未能返回时才触发——那是你预期中的面板出现的空洞，
  > 绝不是你刻意选择的面板。
- 被引用的上游结论本身为 `NOT ASSESSED`——它会向上传播，
  而不会解析为通过。

绝不要通过假定宽松解读来了结未知项。如果检查无法运行，
这个事实就是发现项。

---

## 5a. 验证链

在 Phase 5 起草结论后，最终确定前先质疑它。

**步骤 1——生成 5 个质疑性问题**，旨在推翻结论：

> **工具行动要求**：以下 5 个质疑性问题中，至少要有 2 个通过重读具体文件（Read 工具）或重跑具体检查（Grep 工具）来回答——不能仅靠反思。用 [TOOL ACTION] 标记这些项，表示使用了工具。

对于 **PASS** 草稿：
- “哪些质量检查是我真正读取文件核实的，而不是推断它们通过了？”
- “有没有我未经用户确认就标为 PASS 的 MANUAL CHECK NEEDED 项？[TOOL ACTION] 重新扫描清单，找出任何 [?] 或 MANUAL CHECK 项。”
- “我是否确认了所有列出的产出物都有真实内容，而不只是空标题？[TOOL ACTION] 重新读取该文件，确认其中含有非占位符内容。”
- “有没有我当作次要而忽略的阻塞项，实际上可能导致该阶段无法成功？”
- “哪一项检查是我最没把握的，为什么？”

对于 **CONCERNS** 草稿：
- “鉴于项目当前状态，列出的任何 CONCERN 是否可能升级为阻塞项？”
- “该关注项能否在下一个阶段内解决，还是会随时间累积恶化？”
- “我是否为了回避更严厉的结论，把任何 FAIL 条件软化成了 CONCERN？”
- “有没有我没检查、但可能揭示更多阻塞项的产出物？”
- “所有 CONCERNS 合在一起是否构成阻塞性问题，即便单独看每一项都很轻微？”

对于 **FAIL** 草稿：
- “我是否准确区分了硬性阻塞项与强烈建议？”
- “有没有哪些 PASS 项是我过于宽松了？”
- “我是否遗漏了用户应当知道的额外阻塞项？”
- “我能否给出通往 PASS 的最小路径——必须改变的具体 3 件事？”
- “该失败条件可解决吗，还是它表明存在更深层的设计问题？”

**步骤 2——独立回答每个问题。**
不要引用结论草稿的文本——重新检查具体文件或询问用户。

**步骤 3——必要时修订：**
- 如果任何答案揭示出遗漏的阻塞项 → 升级结论（PASS→CONCERNS 或 CONCERNS→FAIL）
- 如果任何答案揭示出某项检查是**无法运行**，而不是运行后通过 → PASS→NOT ASSESSED。上面两个 PASS 草稿问题
  （“真正读取文件核实，还是推断”、“我标为 PASS 的 MANUAL CHECK NEEDED
  项”）正是为了找出这一点，任何一个是肯定回答都会把
  结论移到此处
- 如果任何答案揭示出被夸大的阻塞项 → 只有在援引具体证据时才降级
- 绝不通过重新推理缺失输入，把 NOT ASSESSED 改回 PASS。
  只有获得该输入才能清除它
- 如果答案一致 → 确认结论不变

**步骤 4——在最终报告输出中记录验证情况**：
`Chain-of-Verification: [N] questions checked — verdict [unchanged | revised from X to Y]`

---
