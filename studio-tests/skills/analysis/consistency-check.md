# Skill Test Spec: /consistency-check

## Skill Summary

`/consistency-check [full | since-last-review | entity:<name> | item:<name>]`
将 `design/gdd/` 中每一份范围内的 GDD 与实体注册表
（`design/registry/entities.yaml`）进行比较。它只读取一次注册表，建立实体、
物品、公式与常量的查找表，然后对每份 GDD 逐个 grep 每个已注册名称
（`-C 3`），而不是读取整份文档；只有冲突才会触发针对性的
章节读取。注册表条目的 `source:` GDD 是权威归属方。
在有效层级为 `standard` 的 GDD 中——即项目层级，或该
系统的 `system_overrides` 行——只比较必需的 GDD 章节
（当 `workflow_overrides.tuning_knobs` 为 true 时再加上 Tuning Knobs），并在
报告中说明这一点。发现项被分类为 🔴 CONFLICT、⚠️ STALE REGISTRY 或 ℹ️ UNVERIFIABLE，
报告结论为 PASS 或 CONFLICTS FOUND——或当注册表
为空、指定实体不在其中、或范围内没有 GDD 时为 NOT ASSESSED，因为对空集
的扫描不算 PASS。注册表更正只在
"May I update / May I add" 询问之后才写入；之后结论为 COMPLETE，或
在冲突仍存在时为 BLOCKED。每个 🔴 CONFLICT 都在
"May I append" 询问之后追加到 `docs/consistency-failures.md`，一条面包屑追加到
`production/session-state/active.md`，技能以
`AskUserQuestion` 组件收尾（collaborative 与 guided 模式）。无总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：PASS、CONFLICTS FOUND、NOT ASSESSED、COMPLETE、BLOCKED
- [ ] 分析阶段（1–5）为只读
- [ ] 结尾有下一步交接
- [ ] 注册表写入之前有 "May I update" / "May I add" 措辞，并指明 `design/registry/entities.yaml`
- [ ] 冲突日志写入之前有 "May I append" 措辞，并指明 `docs/consistency-failures.md`

---

## Director Gate Checks

无总监闸门——此技能不生成任何总监闸门代理。一致性检查
是机械式扫描；扫描本身不需要创意总监或技术总监评审。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 注册表与 4 份 GDD 一致

**Fixture:**
- `modes.workflow` 解析为 `full`；`modes.automation` 解析为 `collaborative`
- `design/registry/entities.yaml` 有 3 个实体与 2 个常量，每个都有 `source:` GDD
- `design/gdd/` 包含 4 份系统 GDD，外加 `game-concept.md`、`systems-index.md` 和一份 `gdd-cross-review-[date].md`
- GDD 为某个已注册名称陈述的每个值都与注册表一致

**Input:** `/consistency-check`

**Expected behavior:**
1. 技能读取注册表并报告 `Registry loaded: 3 entities, 0 items, 0 formulas, 2 constants` 与 `Scope: full`
2. 技能 glob `design/gdd/*.md`，排除 `game-concept.md`、`systems-index.md` 与 cross-review 报告，并在扫描前报告 4 份范围内 GDD
3. 每个已注册名称都以 3 行上下文在范围内 GDD 中被 grep；不完整读取任何 GDD
4. 无冲突或过期条目；报告的 Clean Entries 行显示 `✅ 5 registry entries verified across all GDDs with no conflicts.`
5. 结论：PASS
6. 不向 `docs/consistency-failures.md` 追加任何内容；面包屑追加到 `production/session-state/active.md`
7. 以 `AskUserQuestion` 组件收尾（Fix / Run `/design-review` / Stop）

**Assertions:**
- [ ] 在扫描前报告范围内 GDD 列表（4 份 GDD，排除非系统文档）
- [ ] 扫描通过 grep 已注册名称进行，而非完整读取每份 GDD
- [ ] 注册表与 GDD 一致时结论为 PASS
- [ ] 不写入 `design/registry/entities.yaml` 与 `docs/consistency-failures.md`；唯一的写入是 `active.md` 面包屑
- [ ] 面包屑指明 `docs/consistency-failures.md`，而非杜撰的报告文件
- [ ] 技能以 `AskUserQuestion` 组件收尾，而非纯文本

---

### Case 2: Failure Path — 某份 GDD 与已注册常量矛盾

**Fixture:**
- `modes.workflow` 解析为 `full`
- 注册表 `constants:` 中有 `crit_multiplier` 值 1.5，`source: design/gdd/combat.md`，`referenced_by: [combat.md, loot.md]`
- `design/gdd/combat.md` 声明 `crit_multiplier = 1.5`
- `design/gdd/loot.md` 声明 `crit_multiplier = 2.0`
- 注册表条目比 `combat.md` 的最后一次提交更新（未过期）

**Input:** `/consistency-check`

**Expected behavior:**
1. 常量扫描（3d）grep `crit_multiplier`，在 `loot.md` 中找到 2.0
2. Phase 4 对冲突章节做针对性读取，并使用注册表 `source:` 判定 `combat.md` 为权威
3. 报告列出 `🔴 crit_multiplier`：Registry (source: combat.md) = 1.5；Conflict in loot.md = 2.0；Resolution: change `loot.md` to 1.5
4. 结论：CONFLICTS FOUND
5. 技能询问 "May I append 1 entries to `docs/consistency-failures.md` (creating it if absent)?"；获得批准后追加一条冲突条目（若文件不存在，先以其文件头创建），指明 `combat.md` 与 `loot.md`
6. 不自动编辑任何 GDD；冲突未解决时最终结论为 BLOCKED

**Assertions:**
- [ ] 结论为 CONFLICTS FOUND（而非 PASS）
- [ ] 冲突条目指明两份 GDD 并显示两个值（1.5 与 2.0）
- [ ] 冲突被分类为 🔴 CONFLICT，解决方案针对非源 GDD（`loot.md`）
- [ ] 只有在指明该文件的 "May I append" 询问获批准后，才向 `docs/consistency-failures.md` 追加 reflexion-log 条目
- [ ] 技能不自动解决冲突——未经用户选择修复，两份 GDD 都不会被编辑
- [ ] 冲突未解决时最终结论为 BLOCKED

---

### Case 3: Stale Registry — 源 GDD 在注册表条目之后发生了变更

**Fixture:**
- `modes.workflow` 解析为 `full`
- 注册表 `entities:` 中有 `goblin`，`health: 40`，`source: design/gdd/combat.md`
- `design/gdd/combat.md` 现在说 goblin 生命值为 50；`git log` 显示它在注册表条目写入之后发生了变更
- 没有其他 GDD 陈述 goblin 的生命值

**Input:** `/consistency-check entity:goblin`

**Expected behavior:**
1. 范围限定为所有 GDD 中的 `goblin` 实体；报告显示 `Scope: entity:goblin`
2. 在源 GDD 本身发现不一致；Phase 4 检查 git 历史并将其分类为 ⚠️ STALE REGISTRY，而非 🔴 CONFLICT
3. 报告将其列在 Stale Registry Entries 下：注册表说 40，源 GDD 现在说 50
4. 技能询问："May I update `design/registry/entities.yaml` to fix the 1 stale entries?"
5. 批准后：`health` 变为 50，`revised:` 设为今天，并添加一条 `# was: 40 before [date]` 注释；不删除任何内容
6. 写入后结论为 COMPLETE
7. 不向 `docs/consistency-failures.md` 追加任何条目（仅记录 🔴 CONFLICT 条目）

**Assertions:**
- [ ] 该发现被分类为 ⚠️ STALE REGISTRY，与 🔴 CONFLICT 不同
- [ ] 在 "May I update `design/registry/entities.yaml`" 询问获批之前不写入注册表
- [ ] 获批后的更新设置 `revised:`，并以 `# was:` 注释保留旧值
- [ ] 写入后结论为 COMPLETE
- [ ] 对于过期注册表发现，不写入 `docs/consistency-failures.md`

---

### Case 4: Edge Case — 空注册表，无 GDD

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/registry/entities.yaml` 是随附的桩文件，没有任何条目
- `design/gdd/` 为空

**Input:** `/consistency-check`

**Expected behavior:**
1. 技能读取注册表，发现没有任何条目
2. 技能输出："Entity registry is empty. Run `/design-system` to write GDDs — the registry is populated automatically after each GDD is completed. Nothing to check yet."
3. 结论：**NOT ASSESSED — entity registry empty**；技能停止，不进行扫描
4. 不写入任何文件——不写注册表、不写 reflexion 日志、不写会话状态面包屑

**Assertions:**
- [ ] 技能输出空注册表消息并指明 `/design-system`
- [ ] 结论为 NOT ASSESSED，并说明空注册表是原因——绝不是 PASS、CONFLICTS FOUND、COMPLETE 或 BLOCKED，也绝不是完全没有结论（`.trae/rules/skill-authoring.md` obligation 1）
- [ ] 不写入任何文件，包括 `production/session-state/active.md`
- [ ] 技能不崩溃，也不产出部分报告

---

### Case 4b: Edge Case — 注册表已有条目，但范围内没有 GDD

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/registry/entities.yaml` 有 3 个实体，每个都有 `source:` GDD
- `design/gdd/gdd-cross-review-[date].md` 存在，且此后没有系统 GDD 发生变更

**Input:** `/consistency-check since-last-review`

**Expected behavior:**
1. 技能读取注册表并报告它加载了什么
2. `since-last-review` 过滤发现零份变更的 GDD；范围内列表为空
3. 结论：**NOT ASSESSED — no GDDs in scope**，指明 `since-last-review` 是
   产生零结果的过滤器；技能停止，不进行扫描

**Assertions:**
- [ ] 结论为 NOT ASSESSED，绝不是 PASS——没有比较任何内容
- [ ] 输出指明产生空范围的过滤器
- [ ] 不扫描任何 GDD，也不写入冲突日志条目

---

### Case 4c: Edge Case — 指定实体不在注册表中

**Fixture:**
- `modes.workflow` 解析为 `full`
- `design/registry/entities.yaml` 有实体 `goblin` 与 `orc_warlord`
- `design/gdd/` 包含 3 份系统 GDD；其中一份提到 `goblin_shaman`

**Input:** `/consistency-check entity:goblin_shaman`

**Expected behavior:**
1. 技能读取注册表并报告它加载了什么，`Scope: entity:goblin_shaman`
2. `goblin_shaman` 没有注册表条目
3. 结论：**NOT ASSESSED — `goblin_shaman` is not in the registry**，列出
   最接近的已注册名称（`goblin`）；技能停止，不进行扫描

**Assertions:**
- [ ] 结论为 NOT ASSESSED，并指明未注册的实体——绝不是 PASS
- [ ] 列出最接近的已注册名称
- [ ] 不扫描任何 GDD，也不写入任何内容

---

### Case 5: Director Gate — full 评审模式下不生成闸门

**Fixture:**
- `project.yaml`：`modes.review_mode: full`，`modes.workflow: full`
- `design/registry/entities.yaml` 有条目
- `design/gdd/` 包含 ≥2 份 GDD

**Input:** `/consistency-check`

**Expected behavior:**
1. 技能加载注册表并运行一致性扫描
2. 评审模式不起任何作用：技能的配置块只解析 `automation`、`workflow` 与 `system_overrides`
3. 任何时候都不生成总监闸门代理
4. 正常产出报告与结论

**Assertions:**
- [ ] 不生成任何总监闸门代理（无 CD-、TD-、PR-、AD- 前缀的闸门）
- [ ] 技能不解析也不读取评审模式——其配置块只请求 `automation`、`workflow` 与 `system_overrides`
- [ ] 输出中不含 "Gate: [GATE-ID]" 或跳过闸门的条目
- [ ] 评审模式 `full` 对此技能的行为没有影响

---

### Case 6: Standard Workflow — 只比较必需的 GDD 章节

**Fixture:**
- `modes.workflow` 解析为 `standard`
- 注册表 `constants:` 中有 `crit_multiplier` 值 1.5，`source: design/gdd/combat.md`
- `design/gdd/combat.md` 的 `## Detailed Design` 声明 `crit_multiplier = 1.5`
- `design/gdd/loot.md` 仅在其 `## Tuning Knobs` 章节中声明 `crit_multiplier = 2.0`，而 `standard` 不要求该章节；`loot.md` 没有任何必需章节陈述它的值

**Input:** `/consistency-check`

**Expected behavior:**
1. 只比较 `standard` 所要求章节内的命中项
2. `loot.md` 在 `## Tuning Knobs` 中的值不被比较：不会为其引发 🔴 CONFLICT，也不会向 `docs/consistency-failures.md` 追加任何内容
3. 报告的 Scope 行说明检查仅覆盖必需章节，并列出 `loot.md` 的 Tuning Knobs 提及项为该层级下未检查
4. 结论：PASS——必需章节与注册表一致

**Assertions:**
- [ ] 在 `standard` 下，Tuning Knobs 的值不会被报告为 🔴 CONFLICT
- [ ] 报告说明了仅限必需章节的范围，并指明它未检查的提及项——更窄的扫描不是静默的
- [ ] 结论为 PASS

---

### Case 6b: Standard Workflow — 逐系统覆盖使某份 GDD 变为 `full`

**Fixture:**
- `modes.workflow` 解析为 `standard`；`project.yaml` 中有
  `workflow_overrides.system_overrides.loot: full`
- 注册表 `constants:` 中有 `crit_multiplier` 值 1.5，`source: design/gdd/combat.md`
- `design/gdd/combat.md` 的 `## Detailed Design` 声明 `crit_multiplier = 1.5`
- `design/gdd/loot.md` 仅在其 `## Tuning Knobs` 章节中声明 `crit_multiplier = 2.0`

**Input:** `/consistency-check`

**Expected behavior:**
1. 配置块列出 `system_overrides: loot=full`，因此 `loot.md` 的有效层级为 `full`，其所有章节都被比较；`combat.md` 保持 `standard`
2. `loot.md` 的 Tuning Knobs 值被比较，并引发为 `🔴 crit_multiplier`（注册表 1.5，`loot.md` 2.0）
3. 报告的 Scope 行指明 `loot.md` 以 `full` 检查
4. 结论：CONFLICTS FOUND

**Assertions:**
- [ ] `loot.md` 中的 Tuning Knobs 值被比较，因为其有效层级为 `full`——仅凭项目层级会跳过它（Case 6）
- [ ] 报告指明有效层级与项目层级不同的那份 GDD
- [ ] 结论为 CONFLICTS FOUND，而非 PASS

---

### Case 7: Registry Changed Since Phase 1 — 重新读取，再让每次 Edit 锚定当前文本

**Fixture:**
- `modes.workflow` 解析为 `full`
- 运行开始时的注册表：`entities:` 有 `goblin`（`health: 40`，
  `source: design/gdd/combat.md`）与 `orc`；`items:` 有 `health_potion`
- `design/gdd/combat.md` 说 goblin 生命值为 50（在注册表
  条目写入之后变更：已过期）；`iron_sword` 在
  `combat.md` 与 `loot.md` 中都带有声明的伤害值出现，且不在注册表中
- 在 Phase 1 读取与写入之间，另一个会话编辑了
  `design/registry/entities.yaml`：它在 `orc` 之后添加了 `troll` 实体，在 `health_potion` 之后
  添加了 `iron_axe` 物品，并修改了 `goblin` 上的 `referenced_by`
  列表
- 用户批准两个询问：过期条目更新与新条目添加

**Input:** `/consistency-check`

**Expected behavior:**
1. 扫描报告一条 ⚠️ STALE REGISTRY 条目（`goblin`）和一个未注册的
   跨 GDD 物品（`iron_sword`）
2. 在更新 Edit 之前，技能读取当前的
   `design/registry/entities.yaml`，在其中找到 `goblin` 条目，并让
   Edit 锚定该条目的当前文本（包括已变更的 `referenced_by`），
   而不是 Phase 1 所看到的内容
3. 在添加 Edit 之前，它再次读取该文件，并在
   `items:` 章节最后一个现有条目之后追加 `iron_sword`，此时该条目是 `iron_axe`
4. 另一个会话的变更得以保留：`troll`、`iron_axe` 与新的
   `referenced_by` 都仍在文件中

**Assertions:**
- [ ] 每次注册表 Edit 之前都会 Read `design/registry/entities.yaml`，而不只在 Phase 1 读取
- [ ] 更新 `goblin` 的 Edit 锚定该条目当时读取到的文本，并且在不覆盖另一会话的 `referenced_by` 变更的情况下成功
- [ ] `iron_sword` 追加在 `iron_axe`（最后一个现有 `items:` 条目）之后，而不是 `health_potion` 之后
- [ ] 运行结束后 `troll`、`iron_axe` 与已变更的 `referenced_by` 仍存在：注册表从不根据 Phase 1 的副本整体重写
- [ ] 每次注册表写入仍等待各自的 "May I update" / "May I add" 批准

---

## Protocol Compliance

- [ ] 在每次注册表编辑前读取注册表（每次编辑都重新读取，因此 Case 3 读取两次，Case 7 展示并发变更得以保留），然后 grep GDD；仅对冲突进行整节读取
- [ ] 在任何注册表写入询问之前完整展示报告
- [ ] 报告结论为 PASS、CONFLICTS FOUND 或 NOT ASSESSED（空注册表、未注册名称、或范围内没有 GDD——绝不对没有比较任何内容的情况给出 PASS）；更正后的结论为 COMPLETE 或 BLOCKED
- [ ] 应用每份 GDD 的有效层级（解析后的 `modes.workflow`，或该系统的 `system_overrides` 行）：在 `standard` 下只比较必需的 GDD 章节（当 `workflow_overrides.tuning_knobs` 为 true 时再加上 Tuning Knobs），并在报告中说明
- [ ] 无总监闸门——评审模式不是输入
- [ ] 注册表写入以 "May I update" / "May I add" 为闸门；条目从不删除（改为 `status: deprecated`）
- [ ] 每个 🔴 CONFLICT 都在指明它的 "May I append" 询问之后追加到 `docs/consistency-failures.md`
- [ ] 在 collaborative 与 guided 模式下以 `AskUserQuestion` 收尾；在 autonomous 模式下打印发现项并通过 `log_decision` 记录

---

## Coverage Notes

- 此技能检查 GDD 之间已注册的事实。深度设计理论分析
  （游戏支柱漂移、主导策略）由 `/review-all-gdds` 处理。
- 不在注册表中的事实不会被比较；两份 GDD 在
  未注册值上不一致不会被检测到。Phase 6 提议注册出现在多份
  GDD 中的名称。
- `since-last-review` 仅测试其空范围路径（Case 4b），未测试
  能找到变更 GDD 的运行。
- `modes.workflow: minimal` 未单独测试：minimal 项目通常
  没有 GDD，空范围会像 Case 4 和 4b 那样以 NOT ASSESSED 结束。
