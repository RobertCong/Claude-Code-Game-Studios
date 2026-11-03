---
name: consistency-check
description: "对照实体注册表扫描 GDD，查找跨文档冲突。采用 Grep 优先的方法，定位冲突的节与不同的数值。"
argument-hint: "[full | since-last-review | entity:<name> | item:<name>]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,system_overrides`



# 一致性检查

通过将所有 GDD 与实体注册表（`design/registry/entities.yaml`）
比对，检测跨文档不一致。采用 Grep 优先的方法：
只读取一次注册表，然后只定位提及已登记名称的 GDD 节 ——
除非某个冲突需要深入调查，否则不完整读取文档。

**本技能是写入时的安全网。** 它捕获 `/design-system` 的
逐节检查可能遗漏的问题，以及 `/review-all-gdds` 的整体评审过晚才发现的问题。

**何时运行：**
- 每写完一份新 GDD 之后（在转向下一个系统之前）
- 在 `/review-all-gdds` 之前（让该技能从干净的基线开始）
- 在 `/create-architecture` 之前（不一致会污染下游 ADR）
- 按需：`/consistency-check entity:[name]` 专门检查某个实体

**输出**：冲突报告 + 可选的注册表更正

---

每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

**`workflow`**（见 `.trae/docs/workflow-modes.md`），按每份 GDD 的
**生效**层级应用 —— 当该块列出对应行时，使用该 GDD 所属系统的 `system_overrides` 行
（以其文件名主干为准），否则使用项目值：
- `full` —— 对所有 GDD 节进行完整的实体注册表交叉检查。
- `standard` —— 仅对必需节进行交叉检查。报告的
  Scope 行会说明这一点，而为已登记名称在那些节之外陈述的每个值
  都会列为在该层级未检查（Phase 3 会应用此点）。
- `minimal` —— 无意义（没有 GDD 可检查）。

## Phase 1: 解析参数并加载注册表

**模式：**
- 无参数 / `full` —— 对照所有 GDD 检查所有已登记条目
- `since-last-review` —— 仅检查自上次评审报告以来修改过的 GDD
- `entity:<name>` —— 在所有 GDD 中检查某一个特定实体
- `item:<name>` —— 在所有 GDD 中检查某一个特定物品

**加载注册表：**

```
Read path="design/registry/entities.yaml"
```

如果文件不存在或没有条目：
> "实体注册表为空。运行 `/design-system` 来编写 GDD —— 每份 GDD 完成后，
> 注册表会自动填充。目前无可检查的内容。"

结论：**NOT ASSESSED — entity registry empty**。停止：没有进行任何比对，
因此没有可给出的 PASS，也没有可写入的内容。

从注册表构建四张查找表：
- **entity_map**：`{ name → { source, attributes, referenced_by } }`
- **item_map**：`{ name → { source, value_gold, weight, ... } }`
- **formula_map**：`{ name → { source, variables, output_range } }`
- **constant_map**：`{ name → { source, value, unit } }`

统计已登记条目总数。报告：
```
Registry loaded: [N] entities, [N] items, [N] formulas, [N] constants
Scope: [full | since-last-review | entity:name]
```

对于 `entity:<name>` 或 `item:<name>`，如果注册表中没有该名称的条目，
结论为 **NOT ASSESSED — `<name>` is not in the registry**：列出最接近的
已登记名称并停止。检查一个未登记的名称没有比对任何东西，
那不是 PASS。

---

## Phase 2: 定位范围内的 GDD

```
Glob pattern="design/gdd/*.md"
```

排除位于 `design/gdd/` 但不是系统 GDD 的文档：
`game-concept.md`、`systems-index.md`、`game-pillars.md`、`gameplay-tags.md`、
`entity-registry.md`、`fixture-swap-ledger.md`、`sound-bible.md` 以及任何
`gdd-cross-review-*.md`（`/review-all-gdds` 写在这里的报告）。

对于 `since-last-review` 模式：
```bash
git log --name-only --pretty=format: -- design/gdd/ | grep "\.md$" | sort -u
```
限定为自最近的 `design/gdd/gdd-cross-review-*.md`
文件创建日期以来修改过的 GDD。

在扫描前报告范围内的 GDD 列表。**如果列表为空** —— 不存在系统
GDD，或 `since-last-review` 未发现任何改动 —— 结论为
**NOT ASSESSED — no GDDs in scope**：说明是哪个筛选条件产生了零结果，并停止。
扫描空集不会发现冲突，那不是 PASS。

---

## Phase 3: Grep 优先的冲突扫描

对每个已登记条目，在所有范围内的 GDD 中 grep 该条目的名称。
不要完整读取 —— 只提取匹配行及其紧邻
上下文（-C 3 行）。

这是核心优化：与其读取 10 份 GDD × 每份 400 行
（4,000 行），不如 grep 50 个实体名称 × 10 份 GDD（50 次定向搜索，
每次命中约返回 10 行）。

**在生效层级为 `standard` 的 GDD 中，只比较必需节下的命中。**
生效层级按 GDD 计算：`system_overrides.<stem>` 在两个方向上都
替换该 GDD 的项目层级（`full` 行会使所有节都参与比较）。对每份这样的 GDD
grep 一次 `^## ` 以获取其标题和行号，并将每个名称命中归入其上方最近的标题：
只比较 Overview、Detailed Rules / Detailed Design、Formulas、Edge
Cases、Dependencies 或 Acceptance Criteria 下的命中 —— 当
`project.yaml` 设置 `workflow_overrides.tuning_knobs: true` 时还包括 Tuning Knobs（读取该标志
一次；它只会增加该节）。任何其他命中（未开启该标志时的 Tuning Knobs、Player Fantasy、任何其他节）
不产生发现也不记录；将每个陈述了值的命中（名称、GDD、节）
列在报告的 `Not checked at this tier` 行上。

### 3a: 实体扫描

对 entity_map 中的每个实体：

```
Grep pattern="[entity_name]" glob="design/gdd/*.md" output_mode="content" -C 3
```

对每个 GDD 命中，提取实体名称附近提及的值：
- 任何数值属性（数量、花费、持续时间、范围、速率）
- 任何分类属性（类型、层级、类别）
- 任何派生值（总计、输出、结果）
- entity_map 中登记的任何其他属性

将提取的值与注册表条目比对。

**冲突检测：**
- 注册表说 `[entity_name].[attribute] = [value_A]`。GDD 说 `[entity_name] has [value_B]`。→ **CONFLICT**
- 注册表说 `[item_name].[attribute] = [value_A]`。GDD 说 `[item_name] is [value_B]`。→ **CONFLICT**
- GDD 提及 `[entity_name]` 但未指明该属性。→ **NOTE**（无冲突，只是无法核实）

### 3b: 物品扫描

对 item_map 中的每个物品，在所有 GDD 中 grep 该物品名称。提取：
- 售价 / 价值 / 金币价值
- 重量
- 堆叠规则（可堆叠 / 不可堆叠）
- 类别

与注册表条目的值比对。

### 3c: 公式扫描

对 formula_map 中的每个公式，在所有 GDD 中 grep 该公式名称。提取：
- 公式附近提及的变量名
- 提及的输出范围或上限值

与注册表条目比对：
- 变量名不同 → **CONFLICT**
- 输出范围陈述不同 → **CONFLICT**

### 3d: 常量扫描

对 constant_map 中的每个常量，在所有 GDD 中 grep 该常量名称。提取：
- 常量名称附近提及的任何数值

与注册表值比对：
- 数字不同 → **CONFLICT**

---

## Phase 4: 深入调查（仅冲突）

对 Phase 3 中发现的每个冲突，对冲突的 GDD 做一次定向的整节读取，
以获取精确上下文：

```
Read path="design/gdd/[conflicting_gdd].md"
```
（或者如果文件很大，使用更宽上下文的 Grep）

按节读取：用 Grep 工具找到冲突节的标题
（pattern `^#`，content 模式），再用 offset 和 limit 读取该范围。

用完整上下文确认冲突。判断：
1. **哪份 GDD 是正确的？** 检查注册表中的 `source:` 字段 ——
   源 GDD 是权威所有者。任何与之矛盾的 GDD
   才是需要更新的那一个。
2. **注册表本身是否已过时？** 如果源 GDD 在注册表条目
   写入之后被更新过（检查 git log），注册表可能已过期。
3. **这是真实的设计变更吗？** 如果该冲突代表一次有意的
   设计决定，解决方式是：更新源 GDD，更新注册表，
   然后修复所有其他 GDD。

对每个冲突分类：
- **🔴 CONFLICT** —— 同一具名实体/物品/公式/常量在不同 GDD 中
  具有不同值。必须在架构开始前解决。
- **⚠️ STALE REGISTRY** —— 源 GDD 的值已更改但注册表未更新。
  注册表需要更新；其他 GDD 可能已经正确。
- **ℹ️ UNVERIFIABLE** —— 提及了实体但未陈述可比对的属性。
  不是冲突；只是记录该引用。

---

## Phase 5: 输出报告

```
## Consistency Check Report
Date: [date]
Registry entries checked: [N entities, N items, N formulas, N constants]
GDDs scanned: [N] ([list names])
Scope: [all GDD sections | required sections only — workflow: standard | per GDD — name each GDD whose effective tier differs, and its tier]
Not checked at this tier: [each value stated outside the required sections (name, GDD, section) — or "none"; omit when every GDD is at `full`]

---

### Conflicts Found (must resolve before architecture)

🔴 [Entity/Item/Formula/Constant Name]
   Registry (source: [gdd]): [attribute] = [value]
   Conflict in [other_gdd].md: [attribute] = [different_value]
   → Resolution needed: [which doc to change and to what]

---

### Stale Registry Entries (registry behind the GDD)

⚠️ [Entry Name]
   Registry says: [value] (written [date])
   Source GDD now says: [new value]
   → Update registry entry to match source GDD, then check referenced_by docs.

---

### Unverifiable References (no conflict, informational)

ℹ️ [gdd].md mentions [entity_name] but states no comparable attributes.
   No conflict detected. No action required.

---

### Clean Entries (no issues found)

✅ [N] registry entries verified across all GDDs with no conflicts.

---

Verdict: PASS | CONFLICTS FOUND | NOT ASSESSED
```

**结论：**
- **CONFLICTS FOUND** —— 检测到一个或多个冲突。列出解决步骤。
- **NOT ASSESSED** —— 没有进行任何比对：实体注册表为空或
  指定名称不在其中（Phase 1），或者范围内没有 GDD（Phase 2）。说明
  是哪种情况。
- **PASS** —— 无冲突。注册表与 GDD 在所有已检查值上一致，且至少覆盖一份 GDD。

---

## Phase 6: 注册表更正

**写入前重新读取。** Phase 1 在扫描前读取了注册表，而
另一个技能或会话可能此后已更改它。每次 Edit 之前，读取
当前的 `design/registry/entities.yaml`，在其节中找到该条目，
并将 Edit 锚定在该条目的当前文本上，绝不基于 Phase 1 所见的内容。在其所在节
最后一个现有条目之后追加新条目。

如果发现过时的注册表条目，询问：
> "我可以更新 `design/registry/entities.yaml` 来修复这 [N] 个过时条目吗？"

对每个过时条目：
- 更新 `value` / 属性字段
- 将 `revised:` 设为今天的日期
- 添加包含旧值的 YAML 注释：`# was: [old_value] before [date]`

如果在 GDD 中发现了注册表里没有的新条目，询问：
> "在 GDD 中发现了 [N] 个尚未登记到注册表中的实体/物品。
> 我可以将它们添加到 `design/registry/entities.yaml` 吗？"

只添加出现在不止一份 GDD 中的条目（真正的跨系统事实）。

**绝不删除注册表条目。** 如果某个条目从所有 GDD 中移除，设置 `status: deprecated`。

写入之后，运行 `bash .trae/scripts/registry.sh validate`，并在给出结论前
修复其中关于本次写入新增或更改条目的每一行（DUPLICATE、STATUS 或 LAYOUT 行，
或针对其所指名路径的 PATH_MISSING 行）；关于其他条目的行
向用户说明，而不是未经询问就修复。如果脚本
缺失或没有输出，说明注册表检查未运行，然后对照
文件头部规则重新读取你写入的条目。

写入之后：结论：**COMPLETE** —— 一致性检查完成。
如果冲突仍未解决：结论：**BLOCKED** —— [N] 个冲突需要人工解决后才能开始架构。

### 6b: 追加到反思日志

如果发现了任何 🔴 CONFLICT 条目（无论是否已解决），
询问："我可以将 [N] 条记录追加到 `docs/consistency-failures.md`（若不存在则创建）吗？"若同意，为每个冲突追加一条记录；
若不同意，说明这些冲突未记录。

```markdown
### [YYYY-MM-DD] — /consistency-check — 🔴 CONFLICT
**Domain**: [system domain(s) involved]
**Documents involved**: [source GDD] vs [conflicting GDD]
**What happened**: [specific conflict — entity name, attribute, differing values]
**Resolution**: [how it was fixed, or "Unresolved — manual action needed"]
**Pattern**: [generalised lesson, e.g. "Item values defined in combat GDD were not
referenced in economy GDD before authoring — always check entities.yaml first"]
```

如果 `docs/consistency-failures.md` 不存在，在追加前用此头部创建它：

```markdown
# Consistency Failure Log

<!-- Auto-maintained by /consistency-check. Do not edit manually. -->
<!-- One entry per detected conflict, in chronological order. -->

| Date | GDD A | GDD B | Conflict Type | Status |
|------|-------|-------|---------------|--------|
```

然后追加新的冲突条目。绝不要自行跳过记录 —— 文件缺失不是丢失冲突历史的理由；
只有用户的"不"才是。

---

## Phase 7: 会话状态与收尾

静默追加到 `production/session-state/active.md`（若不存在则创建该文件）：

```
<!-- CONSISTENCY-CHECK: [date] | GDDs checked: [N] | Conflicts found: [N] | Log: docs/consistency-failures.md -->
```

> **指向 `docs/consistency-failures.md` —— 即 Phase 6 实际追加内容的那个
> 文件。** 面包屑是留给未来会话遵循的指针。一个指向无人写入文件的
> 面包屑会使该会话去寻找它永远找不到的冲突历史，
> 而过程中不会有任何报错。绝不要在这里杜撰报告
> 文件名。

然后以 `AskUserQuestion` 控件收尾：

- **提示**："一致性检查完成 —— 发现 [N] 个冲突。接下来做什么？"
- **选项**：
  - `[A] Fix the highest-priority conflict now`
  - `[B] Run /design-review on the most conflicted GDD`
  - `[C] Stop here`

在 collaborative 和 guided 模式下，绝不要以纯文本结束技能 —— 始终
以该控件收尾。在 autonomous 模式下，打印发现与推荐的
下一步，然后通过 `log_decision` 记录（不使用控件）。

---

## 恢复 / 参考

- **如果 PASS**：运行 `/review-all-gdds` 进行整体设计理论评审，或
  如果所有 MVP GDD 都已完成，运行 `/create-architecture`。
- **如果 CONFLICTS FOUND**：修复被标记的 GDD，然后重新运行
  `/consistency-check` 以确认解决。
- **如果 STALE REGISTRY**：更新注册表（Phase 6），然后重新运行以验证。
- 每写完一份新 GDD 后运行 `/consistency-check`，以便尽早发现问题，
  而不是等到架构阶段。