# Skill Test Spec: /scope-check

## Skill Summary

`/scope-check` 是 Haiku 层级的只读技能，将功能、冲刺或里程碑的
原始计划范围与实际已实现的内容进行比较。它接受整个参数字符串——
功能名（可能由多个词组成）、冲刺编号或里程碑名称——并在
`design/gdd/[feature].md`（或 `design/` 中的匹配文件）、
`production/sprints/sprint-NNN.md` 或 `production/milestones/[name].md` 定位基线。
如果基线缺失，它报告缺失文件并停止。然后它读取
当前状态（相关源文件、`git log`、TODO/FIXME 注释、活动
冲刺计划）并生成比较报告：Original Scope、Current Scope、
Scope Additions、Scope Removals、Bloat Score、Risk Assessment 以及
Cut / Defer / Keep / Flag 建议。结论随净范围
变化：≤10% PASS，>10–25% CONCERNS，>25% FAIL。当百分比
没有意义时——基线没有枚举任何条目，或无法读取当前状态——
结论为 NOT ASSESSED，并替换数字块。
不写入任何文件，也不调用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：PASS、CONCERNS、NOT ASSESSED、FAIL
- [ ] 不要求 "May I write" 措辞（技能声明为只读，且 `allowed-tools` 没有 Write/Edit）
- [ ] 有下一步交接（Phase 5：按结论给出后续动作）

---

## Director Gate Checks

无。范围检查是只读的建议型技能；不调用任何闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 多词功能进展正常

**Fixture:**
- `design/gdd/inventory-crafting-system.md` 枚举 20 个范围条目
- `src/gameplay/inventory/` 与 `src/gameplay/crafting/` 实现了全部 20 项，外加最近一次提交中发现的一项新增（物品排序）
- 没有条目被丢弃

**Input:** `/scope-check inventory crafting system`

**Expected behavior:**
1. 技能使用整个参数 "inventory crafting system" 定位基线——而不只是 "inventory"
2. 技能读取 `design/gdd/inventory-crafting-system.md` 作为基线（Phase 1）
3. 技能读取当前状态：相关源文件、该工作的 `git log --oneline`、TODO/FIXME 注释（Phase 2）
4. 报告列出 Original Scope 与 Current Scope；Scope Additions 表指明物品排序及其来源、日期、理由与工作量
5. Bloat Score：20 original、21 current、1 added（+5%）、0 removed
6. 结论：**PASS** — On Track
7. Phase 5：无需动作；建议在下一个里程碑之前重新运行；以 "Run `/scope-check [name]` again after cuts are made to verify the verdict improves." 结束

**Assertions:**
- [ ] 基线从完整的多词参数定位，而不是其第一个词
- [ ] 新增项在 Scope Additions 表中以 source、when、justified 与 effort 列指明
- [ ] Bloat Score 显示原始、当前、新增与移除计数以及净百分比
- [ ] 净变化 ≤10% 时结论为 PASS
- [ ] 不写入任何文件

---

### Case 2: Significant Creep — 冲刺增加了计划外条目

**Fixture:**
- `production/sprints/sprint-003.md` 列出 8 个计划用户故事
- 冲刺开始以来的提交增加了在线排行榜、成就系统与拍照模式，均未出现在冲刺计划中
- 没有计划用户故事被丢弃

**Input:** `/scope-check sprint-3`

**Expected behavior:**
1. 技能读取 `production/sprints/sprint-003.md` 作为基线
2. 技能从 `git log` 与源码树找到三项新增
3. Scope Additions 表指明全部三项；Bloat Score 显示 8 original、11 current、+37.5%
4. 建议将条目归入 Cut / Defer / Keep / Flag
5. 结论：**FAIL** — Significant Creep
6. Phase 5：建议上报给制作人，并引用 `/sprint-plan update` 重新规划或 `/estimate` 重新建立基线

**Assertions:**
- [ ] 每个计划外新增都在 Scope Additions 表中明确指明
- [ ] 净变化在 25% 与 50% 之间时结论为 FAIL
- [ ] 输出建议上报给制作人，并引用 `/sprint-plan update` 或 `/estimate`
- [ ] 技能不编辑冲刺计划，也不移除用户故事——发现项仅为建议

---

### Case 3: Baseline Missing — 报告缺失文件并停止

**Fixture:**
- 没有 `design/gdd/crafting.md`，且 `design/` 中没有文件匹配 "crafting"
- `src/gameplay/crafting/` 包含已实现的代码

**Input:** `/scope-check crafting`

**Expected behavior:**
1. Phase 1 查找 `design/gdd/crafting.md` 与 `design/` 中的匹配文件；均不存在
2. 技能报告哪个基线文件缺失并停止
3. 不生成比较报告、Bloat Score 或百分比

**Assertions:**
- [ ] 输出指明它查找但未找到的基线文件
- [ ] 技能在 Phase 1 停止——不渲染 Phase 3 比较报告
- [ ] 没有基线时不产出百分比，也不产出 PASS 结论
- [ ] 不写入任何文件

---

### Case 4: Empty Baseline — NOT ASSESSED，而非 0%

**Fixture:**
- `design/gdd/dialogue.md` 存在，但只包含章节标题与 `[TO BE CONFIGURED]` 占位符——没有范围条目
- `src/narrative/dialogue/` 包含已实现的代码

**Input:** `/scope-check dialogue`

**Expected behavior:**
1. Phase 1 找到基线文档，因此不在此停止
2. Phase 4 检测到基线未枚举任何范围条目
3. Bloat Score 块被替换为 `Baseline unusable — see verdict` 及原因；不渲染 `Original items: 0` 或 `Net scope change: 0%`
4. 结论：**NOT ASSESSED**，说明基线一侧无法读取及其原因
5. Phase 5：说明基线文档需要填充；不提供针对相同输入的重新运行

**Assertions:**
- [ ] 基线没有条目时结论为 NOT ASSESSED，绝不是 PASS
- [ ] 报告中任何地方都不出现计算出的百分比
- [ ] 输出说明哪一侧不可用以及如何修复（填充基线文档）
- [ ] 技能不提供针对相同输入的重新运行

---

### Case 4b: Unreadable Current State — NOT ASSESSED，而非 −100%

**Fixture:**
- `production/sprints/sprint-004.md` 列出 6 个计划用户故事
- 没有源文件与这些用户故事相关，`git log` 显示冲刺开始以来没有提交，也没有任何标记为进行中的内容

**Input:** `/scope-check sprint-4`

**Expected behavior:**
1. Phase 1 读取 `production/sprints/sprint-004.md` 作为基线——6 个条目
2. Phase 2 找不到可供读取的当前状态
3. Phase 4 发出 NOT ASSESSED，而不是计算变化：0 个当前条目会算出 −100%，而 ≤10% 行会将其读作 PASS
4. Bloat Score 块被替换为 `Current state unusable — see verdict`；不渲染 `Current items: 0` 或百分比
5. 结论说明当前状态一侧无法读取及其原因，Phase 5 说明如何修复（将技能指向工作所在位置），但不提供针对相同输入的重新运行

**Assertions:**
- [ ] 结论为 NOT ASSESSED，绝不是 PASS
- [ ] 报告中不出现 −100%（或任何百分比）
- [ ] 输出指明当前状态是无法读取的一侧
- [ ] 技能不提供针对相同输入的重新运行

---

### Case 5: Minor Creep in Full Review Mode — CONCERNS，无闸门

**Fixture:**
- `project.yaml` 有 `modes.review_mode: full`
- `production/milestones/alpha.md` 枚举 10 个范围条目
- 当前状态有全部 10 项，外加两项新增（设置菜单重做与一个额外敌人类型）

**Input:** `/scope-check alpha`

**Expected behavior:**
1. 技能读取 `production/milestones/alpha.md` 作为基线
2. Bloat Score：10 original、12 current、+20%
3. 结论：**CONCERNS** — Minor Creep
4. 无论评审模式如何，都不调用总监闸门
5. Phase 5：提供识别 2–3 项削减比最佳的新增项，并引用 `/sprint-plan update`
6. 技能结束时不写入任何文件

**Assertions:**
- [ ] 净变化在 10% 与 25% 之间时结论为 CONCERNS
- [ ] 在任何评审模式下都不调用总监闸门
- [ ] 输出提供识别削减比最佳的新增项，并引用 `/sprint-plan update`
- [ ] 不写入任何文件

---

## Protocol Compliance

- [ ] 在任何比较之前定位基线文档（`design/gdd/`、`production/sprints/`、`production/milestones/`），若缺失则停止
- [ ] 从源文件、`git log`、TODO/FIXME 注释与活动冲刺计划读取当前状态
- [ ] 结论遵循净变化表：≤10% PASS，>10–25% CONCERNS，>25% FAIL
- [ ] 当基线没有条目或当前状态无法读取时，发出 NOT ASSESSED 而非百分比
- [ ] 不写入任何文件
- [ ] 不调用任何总监闸门
- [ ] 声明 `model: haiku`（当使用声明的层级时：`.claude/docs/model-tiers.md`）

---

## Coverage Notes

- >50% 的 "Out of Control" 区段与 Case 2 共享 FAIL 结论，未
  单独测试。
