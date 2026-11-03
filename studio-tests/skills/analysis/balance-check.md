# Skill Test Spec: /balance-check

## Skill Summary

`/balance-check [system-name|path-to-data-file]` 识别平衡性领域
（战斗、经济、成长、战利品，或直接给出的数据文件），从
`assets/data/` 与 `design/balance/` 读取该领域的数据文件，然后读取
目标值——优先来自 `design/registry/entities.yaml`（其 `constants:` 与
`formulas:` 块），对注册表未提供的内容则来自 `design/gdd/` 中该系统的 GDD。
它将每个数据值与其目标进行比较——注册表常量的 `value`、注册表公式的
`output_range`，或 GDD 的范围——再运行领域特定检查，并打印一份报告，
包含 Data Sources Analyzed、Health Summary、Outliers Detected 表
（Item/Value | Expected Range | Actual | Issue）、Degenerate Strategies、Progression
Analysis、按优先级排序的 Recommendations 表与 Values That Need Attention。
它找不到的输入会使受影响章节变为 `NOT ASSESSED — NO DATA`，并指明
缺失的来源与 `/design-system`，绝不给估算值；没有目标的值列为
`no stated range — not judged`。报告之后，
`AskUserQuestion` 提供 [A] 立即修复、[B] 将报告保存到
`design/balance/balance-check-[system]-[date].md`、[C] 停止；只有选 [B] 才写入。
不调用任何总监闸门。Health Summary 首个匹配生效：
CRITICAL ISSUES、CONCERNS、NOT ASSESSED、HEALTHY。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：HEALTHY、CONCERNS、CRITICAL ISSUES、NOT ASSESSED
- [ ] 有先询问后写入的措辞：保存是一个 `AskUserQuestion` 选项，并指明其目标路径，且只有选择该选项时才发生 Write
- [ ] 有下一步交接（发现项评审之后该做什么）

---

## Director Gate Checks

无。平衡性检查是分析技能；在任何评审模式下都不调用闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 所有平衡性值都在预期范围内

**Fixture:**
- `assets/data/combat-balance.json` 存在，含 6 个属性值
- `design/registry/entities.yaml` 没有条目（随附的空桩）
- `design/gdd/combat-system.md` 为全部 6 个属性给出预期范围
- 全部 6 个值都落在其范围内；不存在退化策略

**Input:** `/balance-check combat`

**Expected behavior:**
1. 技能从参数识别出 Combat 领域
2. 技能读取 `assets/data/combat-balance.json`（以及 `design/balance/` 中任何 combat 文件）
3. 注册表没有条目，因此技能仅用 GDD 来确定预期范围
4. 6 个值逐一与各自的 GDD 范围比较，没有越界；combat 检查未发现主导选项
5. 报告在 Data Sources Analyzed 下列出 `assets/data/combat-balance.json` 与 `design/gdd/combat-system.md`；Outliers Detected 表没有行
6. Health Summary 为 HEALTHY
7. Phase 6 `AskUserQuestion` 提供 [A] / [B] / [C]；在用户选择之前不写入任何内容

**Assertions:**
- [ ] Data Sources Analyzed 列出读取的每个文件，包括数据文件与 GDD
- [ ] 空注册表被跳过，由 GDD 提供预期范围
- [ ] Outliers Detected 表没有行
- [ ] Health Summary 为 HEALTHY
- [ ] 在用户选择选项 [B] 之前不写入任何文件

---

### Case 2: Outlier — 玩家伤害远高于其预期范围

**Fixture:**
- `assets/data/combat-balance.json` 中有 `player_damage_base: 140`
- `design/gdd/combat-system.md` 为 `player_damage_base` 给出 90–110 的预期范围
- 其他所有属性都在范围内

**Input:** `/balance-check combat`

**Expected behavior:**
1. 技能读取数据文件与 `player_damage_base` 的 GDD 范围，并将每个值与其范围比较
2. Outliers Detected 表列出 `player_damage_base`，Expected Range 90–110、Actual 140，并附问题描述
3. Recommendations 表为其提供一行，含 Priority、Suggested Fix 与 Impact
4. Values That Need Attention 给出建议调整及理由
5. Health Summary 为 CONCERNS——一个可经调参修复的离群值，且无退化策略、成长停滞或无出口循环
6. 若用户选择 [A] 并修改由 combat GDD 定义的 `player_damage_base`，技能会提醒他们在提交前对该 GDD 运行 `/propagate-design-change`

**Assertions:**
- [ ] `player_damage_base` 出现在 Outliers Detected 表中，Expected Range 90–110、Actual 140
- [ ] Recommendations 表以 Priority 对该修复排序
- [ ] Health Summary 为 CONCERNS——不是 HEALTHY，也不是在没有关键类发现时给出 CRITICAL ISSUES
- [ ] 选择 [A] 时，对 GDD 定义值的修复之后跟随 `/propagate-design-change` 提醒

---

### Case 3: No Design Targets — 数据存在，但无 GDD 或注册表定义范围

**Fixture:**
- `assets/data/economy-balance.yaml` 存在，含 10 个普通属性值（价格与比率，仅凭数据无法显示 faucet/sink 循环）
- `design/registry/entities.yaml` 没有条目
- `design/gdd/` 中没有 GDD 覆盖经济

**Input:** `/balance-check economy`

**Expected behavior:**
1. 技能将其输入记录为 FOUND / ABSENT：数据文件为 FOUND；注册表条目与经济 GDD 为 ABSENT
2. 技能读取数据文件并在 Data Sources Analyzed 下列出它
3. 需要预期值的章节（Outliers Detected，以及需要目标的 Progression Analysis）被标记为 `NOT ASSESSED — NO DATA`，指明缺失的经济 GDD 与空注册表，并指明 `/design-system` 是写入它们的技能
4. 不杜撰也不从数据本身推断任何预期范围
5. Health Summary 为 NOT ASSESSED——报告说这些值无法判定，而不是说它们没问题

**Assertions:**
- [ ] 当注册表与 GDD 都不提供预期范围时，技能不杜撰范围
- [ ] 受影响章节被标记为 `NOT ASSESSED — NO DATA`，而不是显示为空表
- [ ] 输出指明缺失的设计来源（`design/gdd/` 中的经济 GDD、空的 `design/registry/entities.yaml`）与 `/design-system`
- [ ] Health Summary 为 NOT ASSESSED——不是 HEALTHY，也不是 CONCERNS，因为没有发现任何错误

---

### Case 4: Registry First — 注册表值覆盖矛盾的 GDD

**Fixture:**
- `design/registry/entities.yaml` 的 `constants:` 列出 `player_damage_base`，`value: 100`、`unit: damage`、`source: design/gdd/combat-system.md`（注册表常量携带值，而不是范围）
- `design/gdd/combat-system.md` 仍说 `player_damage_base` 范围为 100–130（已过期）
- `assets/data/combat-balance.json` 中有 `player_damage_base: 125`

**Input:** `/balance-check combat`

**Expected behavior:**
1. 技能在读取 GDD 之前 grep `design/registry/entities.yaml`（带上下文的 `^  - name:`）
2. `player_damage_base` 的目标是注册表常量的 `value`，即 100，而不是 GDD 的范围
3. 125 与注册表值 100 不同，因此 `player_damage_base` 出现在 Outliers Detected 表中，Expected Range 100（注册表值）、Actual 125——尽管它落在过期的 GDD 范围内
4. 对于注册表未列出的任何值，仍会读取 GDD
5. Data Sources Analyzed 列出注册表、GDD 与数据文件

**Assertions:**
- [ ] 在 GDD 之前读取注册表
- [ ] `player_damage_base` 依据注册表值（100）判定，而非 GDD 范围（100–130）
- [ ] `player_damage_base: 125` 被报告为离群值
- [ ] Data Sources Analyzed 包含 `design/registry/entities.yaml`

---

### Case 5: No Argument, Gate Compliance and the Save Path — 无参数、闸门合规与保存路径

**Fixture:**
- Combat 数据、注册表与 GDD 存在；1 个属性略微超出其范围
- `project.yaml`：`modes.review_mode: full`
- `modes.automation` 解析为 `collaborative`

**Input:** `/balance-check`（无参数）

**Expected behavior:**
1. 技能询问用户要检查哪个系统；用户回答 "combat"
2. 技能读取数据与设计目标并打印报告
3. 不调用任何总监闸门
4. 报告之后，`AskUserQuestion` 提供 [A] 立即修复、[B] 保存到 `design/balance/balance-check-combat-[date].md`、[C] 停止
5. 选 [B]：报告写入 `design/balance/balance-check-combat-[YYYY-MM-DD].md`（按需创建目录），确认写入，技能以 "Re-run `/balance-check` after fixes to verify." 结束
6. 选 [C]：不写入任何内容；总结未关闭的问题，输出以同一行重运行提示结束

**Assertions:**
- [ ] 没有参数时，技能在读取数据前询问要检查哪个系统
- [ ] 在任何评审模式下都不调用总监闸门
- [ ] 报告在保存选项之前展示，且保存选项指明 `design/balance/balance-check-[system]-[date].md`
- [ ] 选项 [B] 以 YYYY-MM-DD 形式的日期写入该路径；选项 [C] 不写入任何内容
- [ ] [B] 与 [C] 都以 "Re-run `/balance-check` after fixes to verify." 结束

---

### Case 6: Orphan Stat — 无 GDD 或注册表定义的孤立数据值

**Fixture:**
- `assets/data/combat-balance.json` 含 6 个属性加 `legacy_armor_mult: 1.5`
- `design/registry/entities.yaml` 没有条目
- `design/gdd/combat-system.md` 为这 6 个属性给出范围，对 `legacy_armor_mult` 没有给出任何内容
- 这 6 个属性都在其范围内；不存在退化策略

**Input:** `/balance-check combat`

**Expected behavior:**
1. 每个值都与其目标比较；这 6 个属性都在范围内
2. `legacy_armor_mult` 不存在目标，因此列在 Values That Need Attention 下为 `no stated range — not judged`
3. 它不是 Outliers Detected 行，也不会从报告中丢弃
4. Health Summary 为 NOT ASSESSED，并指明 `legacy_armor_mult` 是无法判定的值

**Assertions:**
- [ ] `legacy_armor_mult` 被报告为 `no stated range — not judged`，与任何离群值分开
- [ ] 孤立属性不会被静默跳过，也不会依据从数据推断的范围判定
- [ ] Health Summary 为 NOT ASSESSED，而非 HEALTHY，并指明未判定的值

---

## Protocol Compliance

- [ ] 在分析之前读取该领域的数据文件（Phase 2）以及注册表、然后是 GDD（Phase 3）
- [ ] 将每个数据值与其目标比较（注册表常量 `value`、注册表公式 `output_range`，或 GDD 范围）；越界值成为 Outliers Detected 行，没有目标的值记为 `no stated range — not judged`
- [ ] Outliers Detected 表使用列 Item/Value、Expected Range、Actual、Issue；Recommendations 使用 Priority、Issue、Suggested Fix、Impact
- [ ] 输入缺失的章节为 `NOT ASSESSED — NO DATA`，绝不估算，并指明缺失的来源与 `/design-system`
- [ ] 仅在用户选择保存选项时写入，且只写入 `design/balance/balance-check-[system]-[date].md`
- [ ] 不调用任何总监闸门
- [ ] Health Summary 首个匹配：CRITICAL ISSUES、CONCERNS、NOT ASSESSED、HEALTHY——仅当每个值都已对照明示目标判定时才为 HEALTHY

---

## Coverage Notes

- 所有输入都缺失的情况（无数据文件、无注册表条目、无
  GDD）未单独测试；此时技能会停止，并报告
  `NOT ASSESSED — NO DATA` 作为整体结论，指明缺失了什么以及
  哪个技能产出它。
- CRITICAL ISSUES（退化策略、成长停滞、没有出口的循环）没有
  单独用例；Case 2 固定了单独一个离群值即为 CONCERNS。
- 数据文件路径参数（Phase 1 的 "File path given"）未测试；此时
  领域从文件内容推断。
