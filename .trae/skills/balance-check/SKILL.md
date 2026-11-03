---
name: balance-check
description: "在公式与数据中发现平衡性异常值、断裂的成长曲线、退化策略、经济失衡。'检查游戏平衡性'。"
argument-hint: "[system-name|path-to-data-file]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

# 平衡性检查



每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

## 输入不足 —— 在产出任何报告之前先检查

**如果本技能所需的输入不存在，答案就是"无法运行" —— 而不是一份填好的报告。** 先检查，
若检查不通过就停止。

1. 列出本技能读取的输入（数据文件、既往报告、性能分析器输出、测试结果、注册表、源代码）。
2. 对每一项记录 `FOUND` 或 `ABSENT` —— 而不是"假定存在"。
3. 如果某个章节所需的任何输入为 ABSENT，该章节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻产出物推断，也不要留下一个应由
   下一位模板读者填写的必填单元格。
4. 如果**所有**必需输入都为 ABSENT，停止并把 **`NOT ASSESSED — NO DATA`** 作为整体结论
   报告，指明缺失了什么，以及由哪个技能产出它。

**`NOT ASSESSED` 的结论也是一种成功。** 在没有数据时，这是对"数据说明了什么？"这一问题
正确且有价值的回答。它防止的失败模式很具体：一个结论枚举中没有"无法运行"状态的报告会产生
**虚假的干净通过** —— 例如在没有资源、也没有标准的项目上返回 COMPLIANT 的资源审计，或在
零性能分析数据、从未设定预算的情况下报告"相对 16.67ms 预算 >99% 余量"的性能剖析。

**没有证据绝不等同于证明不存在。** 一次扫描因为没有文件可扫而找不到匹配，并没有验证任何
东西。要说明两者中发生的是哪一种 —— 读者无法从绿色结果中分辨。

---

## Phase 1: 识别平衡性领域

根据 `$ARGUMENTS` 确定平衡性领域 —— 使用整个字符串，因为数据文件路径可能包含空格：

- **战斗** → 武器/技能 DPS、击杀所需时间（TTK）、伤害类型交互
- **经济** → 资源来源/消耗、获取速率、物品定价
- **成长** → 经验/战力曲线、死区、战力突增
- **战利品** → 稀有度分布、保底计时器、背包压力
- **给出文件路径** → 直接加载该文件，并根据内容推断领域

若无参数，询问用户要检查哪个系统。

---

## Phase 2: 读取数据文件

从 `assets/data/` 与 `design/balance/` 中读取已识别领域的相关文件。
记录读取过的每个文件 —— 它们将出现在报告的 Data Sources 章节中。

---

## Phase 3: 读取设计文档

**注册表优先。** 如果 `design/registry/entities.yaml` 存在，先于 GDD 读取它。其 `constants`
与 `formulas` 章节保存了跨 GDD 的具名数值与输出范围 —— 即平衡性目标 —— 且已经过提炼，
每一项都带有 `source:` GDD 与任何 `revised:` 日期：
```
Grep pattern="^  - name:" path="design/registry/entities.yaml" output_mode="content" -A 6
```
对于注册表列出的任何常量或公式（`constants:` 与 `formulas:` 块），从注册表获取其预期值；
这些是权威的跨文档数值，GDD 不得与之矛盾。**如果 `design/registry/entities.yaml` 不存在或
没有条目**（在 `/design-system` 填充之前，它以空存根形式随项目提供），跳过此项，仅使用 GDD。

然后从 `design/gdd/` 读取该系统的 GDD，以了解预期设计目标、调参旋钮与预期取值范围 ——
用于填补注册表未提供的任何内容。这是"正确"行为的基线。按章节读取：用 Grep 工具（pattern
`^#`，content 模式）找出需要的标题，再用 offset 与 limit 读取那些范围。

如果数据文件为 FOUND，但两个来源都没有为本领域提供目标值，则那些需要对照目标进行判断的
章节（Outliers Detected，以及当该领域有曲线时的 Progression Analysis）为
`NOT ASSESSED — NO DATA`。每个章节都要说明缺失了什么 —— 它在 `design/gdd/` 中寻找的 GDD，
以及注册表是不存在还是为空 —— 并指出 `/design-system`，它负责写入这两者。

---

## Phase 4: 执行分析

**所有领域：把每个值与其目标比较。** 对数据文件中的每个具名数值，从 Phase 3 取得其目标 ——
注册表常量的 `value`、注册表公式的 `output_range`，或 GDD 声明的范围 —— 并进行比较。超出
目标的值会在 Outliers Detected 中记为一行（`player_damage_base` 140 对照 90–110）。在任何
地方都没有目标的值既不算在范围内，也不算异常值：把它列在 Values That Need Attention 下，
注明 `no stated range — not judged`。

然后运行领域特定的检查：

**战斗平衡：**
- 计算每个战力层级下所有武器/技能的 DPS
- 检查每个层级的击杀所需时间
- 识别任何碾压其他所有选项（严格更优）的选项
- 检查防御性选项是否会造成无法被击杀的状态
- 验证伤害类型/抗性交互是否平衡

**经济平衡：**
- 以流量速率绘制所有资源来源与消耗
- 预测资源随时间的累积
- 检查是否存在无限资源循环
- 验证金币消耗是否与金币产出同步增长
- 检查是否有任何物品永远不值得购买

**成长平衡：**
- 绘制经验曲线与战力曲线
- 检查死区（过长时间没有有意义的成长）
- 检查战力突增（能力突然跃升）
- 验证内容门槛与预期玩家战力是否对齐
- 检查跳过/刷取策略是否破坏预期节奏

**战利品平衡：**
- 计算获取每个稀有度层级的预期时间
- 检查保底计时器的数学
- 验证在任何阶段都没有战利品是严格无用的
- 检查背包压力与获取速率的对比

---

## Phase 5: 输出分析

```
## Balance Check: [System Name]

### Data Sources Analyzed
- [List of files read]

### Health Summary: [NOT ASSESSED / HEALTHY / CONCERNS / CRITICAL ISSUES]

### Outliers Detected
| Item/Value | Expected Range | Actual | Issue |
|-----------|---------------|--------|-------|

### Degenerate Strategies Found
- [Strategy description and why it is problematic]

### Progression Analysis
[Graph description or table showing progression curve health]

### Recommendations
| Priority | Issue | Suggested Fix | Impact |
|----------|-------|--------------|--------|

### Values That Need Attention
[Specific values with suggested adjustments and rationale]
```

根据最严重的发现选择 Health Summary，先匹配者优先：
- **CRITICAL ISSUES** —— 存在退化策略（某个选择碾压所有替代方案）、成长停滞或无法完成，
  或没有消耗端的经济循环
- **CONCERNS** —— 异常值或曲线问题，可通过一轮调参修复，没有关键级别的发现
- **NOT ASSESSED** —— 无可分析内容（上方无数据路径）、某个需要目标的章节为
  `NOT ASSESSED — NO DATA`，或某个值没有可据以判断的声明范围；要指明是哪一种。它排在两种
  发现类结论之下，因为已测得的问题比缺口更具可操作性，但高于 HEALTHY
- **HEALTHY** —— 每个值都对照已声明的目标判断、无异常值、无退化策略、成长在声明的目标之内

---

## Phase 6: 修复与验证循环

呈现报告后，使用 `AskUserQuestion`：
- 提示："平衡性检查完成。你接下来想做什么？"
- 选项：
  - `[A] 立即修复最高优先级问题 —— 带我逐步处理`
  - `[B] 把报告保存到 design/balance/balance-check-[system]-[date].md`
  - `[C] 就此停止 —— 我自己查看这些发现`

**作为子 agent 运行？** `game-designer` 会预加载本技能，而子 agent 没有 `AskUserQuestion`。
在回复末尾以简短列表给出该问题及这三个选项，然后停止：调用你的人会去询问用户并把回答传回。

若选 [A]：
- 询问先处理哪个问题（按优先级行引用 Recommendations 表格）
- 引导用户更新 `assets/data/` 中相关的数据文件，或 `design/balance/` 中的公式
- 每次修复后，提议重新运行相关的平衡性检查，以验证没有引入新的异常值
- 如果修复改动了 GDD 中定义的、或被 ADR 引用的调参旋钮，提醒用户：
  > "该值在某个设计文档中定义。请对受影响的 GDD 运行 `/propagate-design-change [path]`，
  > 在提交前找出下游影响。"

若选 [B]：
- 把报告写入 `design/balance/balance-check-[system]-[date].md`（必要时创建目录）。使用当前
  日期作为 [date]，格式为 YYYY-MM-DD。
- 确认文件已写入，然后以如下内容结束："修复后请重新运行 `/balance-check` 以验证。"

若选 [C]：
- 总结未解决的问题，并以如下内容结束："修复后请重新运行 `/balance-check` 以验证。"