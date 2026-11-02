---
name: content-audit
description: "对照实际实现审计 GDD 的内容数量 —— 计划 vs 已构建。"
argument-hint: "[system-name | --summary | (no arg = full audit)]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/content-audit/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys workflow,automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

已在上方解析 —— 直接使用。无解析块 → 使用 `.claude/docs/config-resolution.md` 中的默认值。

# 内容审计

> 审计前先解析 `modes.workflow`：本技能依赖层级的行为
> （"只审计必需节中的规格"）遵循已解析的层级，绝不
> 使用假设的层级。当 `design/gdd/systems-index.md` 这类必需输入
> 缺失时，报告
> **`NOT ASSESSED — NO DATA`**，而不是计算缺口百分比（在没有指定任何内容时
> 会除以零）。


当本技能被调用时：

解析参数：
- 无参数 → 对所有系统进行完整审计
- `[system-name]` → 仅审计该单一系统
- `--summary` → 仅输出摘要表，不写文件

---

**`workflow`**（见 `.claude/docs/workflow-modes.md`）：
- `full` —— 对照所有 GDD 规格的完整内容数量审计。
- `standard` —— 仅审计必需节中的规格；将那些节之外发现的任何数量
  列为在该层级未审计。
- `minimal` —— 无法运行（不存在系统索引）。

## 输入不足 —— 在产出任何报告之前先检查这一点

**如果本技能所需的输入不存在，答案就是"无法运行" ——
而不是一份填好的报告。** 先检查，若检查失败则停止。

1. 列出本技能读取的输入（数据文件、既往报告、性能剖析器输出、
   测试结果、注册表、源代码）。
2. 对每一项，记录 `FOUND` 或 `ABSENT` —— 而不是"假设存在"。
3. 如果某个节所需的任何输入为 ABSENT，该节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻
   产出物推断它，也不要留下一个强制单元格等模板的下一位读者
   填写。
4. 如果**每一项**必需输入都是 ABSENT，停止并报告
   **`NOT ASSESSED — NO DATA`** 作为整体结论，说明缺了什么、
   由哪个技能产出（`design/gdd/systems-index.md` 由 `/map-systems` 产出，GDD 由 `/design-system` 产出）。

**结论为 `NOT ASSESSED` 是一种成功。** 在没有数据时，它是对
"数据说明了什么？"正确且有用的回答。这防止的失败模式很
具体：一个结论枚举中没有"无法运行"状态的报告会产生
**虚假的干净通过** —— 一个在没有资源也没有标准的项目上返回 COMPLIANT 的资源审计，
或一个在零剖析数据、从未设定预算的情况下报告"相对于
16.67ms 预算有 >99% 余量"的性能剖析。

**证据的缺失绝不是缺失的证据。** 一次因为无文件可扫描而没有
匹配的扫描，没有验证任何东西。要说明属于两种情况中的哪一种 ——
读者无法从一个绿色结果中分辨。

---

## Phase 1 — 上下文收集

1. **读取 `design/gdd/systems-index.md`**，获取系统的完整列表、它们的
   类别以及 MVP/优先级层级。按节读取它：用 Grep 工具找到需要的标题
   （pattern `^#`，content 模式），再用
   offset 和 limit 读取那些范围。

2. **注册表优先计数**：如果 `design/registry/entities.yaml` 存在，先读取
   它。其 `entities` 和 `items` 节就是本次审计计数的跨 GDD 具名内容，
   已按条目提炼并带有 `source:` GDD：
   ```
   Grep pattern="^  - name:" path="design/registry/entities.yaml" output_mode="content" -A 2
   ```
   `- name:` 出现在全部四个注册表节中；只保留其
   `-A 2` 上下文显示位于 `entities:` 或 `items:` 之下的名称（即本次审计
   计数的具名内容 —— 而非 `formulas:`/`constants:`）。将它们用作
   **计划**的具名内容集合，无需完整读取拥有它们的 GDD。
   **如果 `design/registry/entities.yaml` 不存在或没有条目**（它在 `/design-system`
   填充之前以空桩形式提供），跳过此步骤，依靠
   下面的 GDD 扫描 —— 行为不变，只是成本更高。

3. **L0 预扫描**：在完整读取任何 GDD 之前，运行**两次** grep —— 它们
   回答不同的问题，不得共用同一模式：

   a. 哪些 GDD 带有 Summary（分母 / 失败开放检查）：
   ```
   Grep pattern="^## Summary" glob="design/gdd/*.md" output_mode="files_with_matches"
   ```

   b. 哪些 GDD 实际声明了内容数量（收窄步骤）：
   ```
   Grep pattern="[0-9]+[[:space:]]+(enemies|enemy types|levels|areas|maps|stages|items|weapons|equipment|abilities|skills|spells|cutscenes|conversations|dialogue scenes|bosses|quests)|(enemy|item|weapon|ability|level) types:" glob="design/gdd/*.md" output_mode="files_with_matches"
   ```

   > **保持两次扫描分开。** `## Summary` 会匹配每一份合规的 GDD，
   > 因此与它取并集不会收窄任何范围，而 `N enemies` 这样的字面占位符
   > 匹配不到任何真实 GDD。模式 (b) 匹配数字后跟
   > 步骤 5 实际提取的内容名词。

   **对缺失的 Summary 失败开放。** 确立分母：glob
   `design/gdd/*.md` 并计数为 **N**。**扫描 (a)** 匹配数少于 N 意味着
   这些 GDD 早于 `## Summary` —— 绝不将缺失的 Summary 视为系统
   不在范围内；零匹配的 (a) 意味着"尚无 GDD 带有 Summary"，而不是"没有
   可审计内容"。完整读取未匹配的范围内 GDD。

   对于单系统审计：跳过此步骤，直接完整读取。
   对于完整审计：完整读取**扫描 (b)** 匹配**且
   尚未被步骤 2 的注册表条目完全覆盖**的 GDD，
   加上扫描 (a) 遗漏的每一份 GDD —— **失败开放规则优先于此
   收窄**：没有 `## Summary` 的 GDD 即使扫描 (b) 未匹配到它，
   也要完整读取。只有既有 Summary 又没有内容数量表述的 GDD（
   纯机制 GDD）才会在不完整读取的情况下记为"无可审计的内容数量"。

4. **完整读取范围内的 GDD 文件**（若给定了系统名，则读取该单系统 GDD）。
   此步骤需要整份 GDD：按其标题
   分范围读取（用 Grep 工具找到标题：pattern `^#`，content 模式），因为超过 40 KB 的
   整文件 Read 会被拒绝。

5. **对每份 GDD，提取明确的内容数量或列表**，并注明每个条目所在的 `##` 节 —— 在 `standard` 下，
   必需节（`.claude/docs/workflow-modes.md`）之外的数量会进入
   "Not audited at this tier" 列表，绝不进入清单。查找类似
   以下模式：
   - "N enemies" / "enemy types:" / 具名敌人列表
   - "N levels" / "N areas" / "N maps" / "N stages"
   - "N items" / "N weapons" / "N equipment pieces"
   - "N abilities" / "N skills" / "N spells"
   - "N dialogue scenes" / "N conversations" / "N cutscenes"
   - "N quests" / "N missions" / "N objectives"
   - 任何明确的枚举列表（具名内容条目的项目符号列表）

6. **根据提取的数据构建内容清单表**：

   | 系统 | 内容类型 | 指定数量/列表 | 源 GDD |
   |--------|-------------|---------------------|------------|

   注意：如果 GDD 定性描述了内容但未给出数量，记录
   "Unspecified" 并标记它 —— 未指定的数量是值得注意的设计缺口。

---

## Phase 2 — 实现扫描

对 Phase 1 中发现的每种内容类型，扫描相关目录以统计
已实现的数量。使用 Glob 和 Grep 定位文件。

**在 Unreal 上，内容位于 `Content/`** —— 地图和数据资产都在那里 —— 而
代码根目录（`Source/<Module>/`）只保存 C++。因此在 Unreal 上，下面每个 `assets/…` glob
还会在 `Content/` 下运行（用 `*.uasset` 替代数据扩展名），
关卡则是 `Content/**/*.umap`。跳过这一点会在每个
Unreal 项目上找到零个关卡并报告为 NOT STARTED。

**在 Unity 上，内容位于 `Assets/` 下**（精确比较大小写 ——
`.claude/docs/code-root-resolution.md`），很少放在 `data/` 文件夹中。因此在
Unity 上，下面每个 `assets/…` glob 还会在 `Assets/` 下运行，无需
`data/` 段 —— 对于物品，`Assets/**/items/**`、`Assets/**/Items/**` 和
`Assets/**/*Item*.asset` —— 且数据文件包括 `.asset`（ScriptableObject）
和 `.prefab`。跳过这一点会在 Unity 项目上找到零个物品、能力、任务和对话
并报告为 NOT STARTED。

**关卡 / 区域 / 地图：**
- Glob `assets/**/*.tscn`、`assets/**/*.unity`、`assets/**/*.umap`
- 在**代码根目录**中 Glob 场景文件：`*.tscn`（Godot）、`*.unity`（Unity）；在 Unreal 上，
  改用 `Content/**/*.umap`（见上文）。按 `.claude/docs/code-root-resolution.md` 解析该根目录。**如果代码根目录无法解析，报告 `NOT ASSESSED — code root unresolved`，而不是零命中。**
- 在名为 `levels/`、`areas/`、`maps/`、
  `worlds/`、`stages/` 的子目录中查找场景文件
- 统计看起来是关卡/场景定义（而非 UI 场景）的唯一文件

**敌人 / 角色 / NPC：**
- Glob `assets/data/**/enemies/**`、`assets/data/**/characters/**`
- Glob `<code root>/**/enemies/**`、`<code root>/**/characters/**`
- 查找定义实体属性的 `.json`、`.tres`、`.asset`、`.yaml` 数据文件
- 在角色子目录中查找场景/预制体文件

**物品 / 装备 / 战利品：**
- Glob `assets/data/**/items/**`、`assets/data/**/equipment/**`、
  `assets/data/**/loot/**`
- 查找 `.json`、`.tres`、`.asset` 数据文件

**能力 / 技能 / 法术：**
- Glob `assets/data/**/abilities/**`、`assets/data/**/skills/**`、
  `assets/data/**/spells/**`
- 查找 `.json`、`.tres`、`.asset` 数据文件

**对话 / 会话 / 过场动画：**
- Glob `assets/**/*.dialogue`、`assets/**/*.csv`、`assets/**/*.ink`
- 在 `assets/data/` 中 Grep 对话数据文件

**任务 / 委托：**
- Glob `assets/data/**/quests/**`、`assets/data/**/missions/**`
- 查找 `.json`、`.yaml` 定义文件

**引擎相关说明（在报告中注明）：**
- 计数是近似值 —— 本技能无法完美解析每个引擎
  格式，也无法区分仅编辑器用的文件与随包发布的
  内容
- 场景文件可能既包含玩法内容又包含系统/UI 场景；扫描
  会统计所有匹配并注明此注意事项

---

## Phase 3 — 缺口报告

产出缺口表：

```
| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|
```

**状态类别：**
- `COMPLETE` —— Found ≥ Specified（100%+）
- `IN PROGRESS` —— Found 为 Specified 的 50–99%
- `EARLY` —— Found 为 Specified 的 1–49%
- `NOT STARTED` —— Found 为 0

**优先级标记：**
在报告中将某系统标记为 `HIGH PRIORITY`，如果：
- 状态为 `NOT STARTED` 或 `EARLY`，且
- 该系统在系统索引中被标记为 MVP 或 Vertical Slice，或
- 系统索引显示该系统阻塞下游系统

**摘要行：**
- 指定的内容条目总数（Specified 列所有值之和）
- 找到的内容条目总数（Found 列所有值之和）
- 总体缺口百分比：`(Specified - Found) / Specified * 100`

Found 为 `NOT ASSESSED`（代码根目录无法解析）的行没有 Gap 或
Status，绝不是 `NOT STARTED`，并且不计入两个总计；摘要会说明它。

---

## Phase 4 — 输出

### 完整审计与单系统模式

向用户呈现缺口表和摘要。询问："我可以将完整报告写入 `docs/content-audit-[YYYY-MM-DD].md` 吗？"

如果同意，写入该文件：

```markdown
# Content Audit — [Date]

## Summary
- **Total specified**: [N] content items across [M] systems
- **Total found**: [N]
- **Gap**: [N] items ([X%] unimplemented)
- **Scope**: [Full audit | System: name] — [all GDD sections | required sections only (workflow: standard)]
- **Not audited at this tier**: [counts found only outside the required sections — or "none"; omit at `full`]

> Note: Counts are approximations based on file scanning.
> The audit cannot distinguish shipped content from editor/test assets.
> Manual verification is recommended for any HIGH PRIORITY gaps.

## Gap Table

| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|

## HIGH PRIORITY Gaps

[List systems flagged HIGH PRIORITY with rationale]

## Per-System Breakdown

### [System Name]
- **GDD**: `design/gdd/[file].md`
- **Content types audited**: [list]
- **Notes**: [any caveats about scan accuracy for this system]

## Recommendation

Focus implementation effort on:
1. [Highest-gap HIGH PRIORITY system]
2. [Second system]
3. [Third system]

## Unspecified Content Counts

The following GDDs describe content without giving explicit counts.
Consider adding counts to improve auditability:
[List of GDDs and content types with "Unspecified"]
```

写入报告后，询问：

> "你想为任何内容缺口创建待办用户故事吗？"

如果同意：对用户选择的每个系统，建议一个用户故事标题，并根据
缺口规模指引他们使用 `/create-stories [epic-slug]` 或 `/quick-design`。

### --summary 模式

直接将缺口表和摘要打印到对话。不写文件。
以这句话结尾："运行不带 `--summary` 的 `/content-audit` 以写入完整报告。"

---

## Phase 5 — 后续步骤

审计之后，推荐价值最高的后续行动：

- 如果任何系统为 `NOT STARTED` 且标记为 MVP → "运行 `/design-system [name]`，
  在实现开始前向 GDD 添加缺失的内容数量。"
- 如果总体缺口 >50% → "运行 `/sprint-plan`，在即将到来的冲刺中分配内容工作。"
- 如果任何系统被标记为 HIGH PRIORITY → "对每个 HIGH PRIORITY 缺口运行 `/create-stories [epic-slug]`。"
- 如果使用了 `--summary` → "运行 `/content-audit`（不带标志）以将完整报告写入 `docs/`。"

以匹配本次运行的结论收尾：
- 结论：**COMPLETE** —— 内容审计完成。
- 结论：**NOT ASSESSED — NO DATA** —— 某项必需输入缺失（见
  顶部说明）、范围内没有任何内容给出数量（没有注册表条目，且每份 GDD 都是
  "Unspecified" 或 "No auditable content counts"），或无法取得 Found 计数
  （`NOT ASSESSED — code root unresolved`）；说明是哪一种，对于缺失的数量
  说明 `/design-system`。绝不要为一次无法计算缺口的运行打印 COMPLETE。
