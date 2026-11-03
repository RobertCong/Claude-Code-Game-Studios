---
name: asset-audit
description: "依照命名规范、文件大小预算与格式标准审计资源。找出孤立资源与缺失引用。"
argument-hint: "[category|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash(stat *), Bash(file *), Bash(od *), Bash(wc *), Bash(du *)
model: sonnet
# Read-only diagnostic skill — no specialist agent delegation needed
---

# 资源审计

## 测量文件大小与格式需要 Bash

本技能的报告需要**对照预算的文件大小**、**纹理尺寸**（二次幂）、**音频采样率**以及用于
孤立资源检测的**最后修改时间**。这些都无法从 `Read`/`Glob`/`Grep` 获得 —— 它们需要 `stat`
或读取二进制文件头，因此只读的测量命令（`stat`、`file`、`od`、`wc`、`du`）已在上方预批准；
用 Glob 列出文件。任何其他操作都需要先询问。

**如果你无法进行某项测量，该单元格就是 `NOT ASSESSED`，绝不是估算值。** 一张靠猜测填满的
大小预算表比空表更糟：它看起来像证据。即使在一个满是真实资源的项目上，这也是真实存在的
虚构风险：如果模板要求提供工具白名单无法产生的数字表格，完成它的唯一办法就是编造。

---

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

## Phase 1: 读取标准

读取美术圣经的 Asset Standards 章节（`design/art/art-bible.md`）以及相关设计文档中的任何
资源标准 —— 大小预算与格式规则来自那里。命名模式使用下面 Phase 3 中的那些，除非美术圣经
声明了自己的模式。按章节读取美术圣经：用 Grep 工具找出标题（pattern `^#`，content 模式），
再用 offset 与 limit 读取该范围。

如果两者都没有声明大小预算 —— 或者根本没有美术圣经 —— Size 章节为
`NOT ASSESSED — no size budget set`，报告需指出 `/art-bible`，其 Asset Standards 章节负责
设定预算、格式与命名规范。

---

## Phase 2: 扫描资源目录

资源位于引擎的资源根目录下：Godot 为 `assets/`，Unity 为 `Assets/`，Unreal 为 `Content/`。
按 `.claude/docs/code-root-resolution.md` 解析引擎及其代码根目录；Phase 3 的孤立资源与
缺失资源搜索读取的就是该代码根目录。如果无法解析，停止：
`NOT ASSESSED — engine unresolved`，并指出 `/setup-engine`。

使用 Glob 扫描资源根目录：

- **Godot** —— `assets/art/**/*`、`assets/audio/**/*`、`assets/vfx/**/*`、
  `assets/shaders/**/*`、`assets/data/**/*`
- **Unity** —— `Assets/**/*`，排除脚本（`*.cs`、`*.asmdef`）与 `*.meta` 文件
- **Unreal** —— `Content/**/*.uasset` 与 `Content/**/*.umap`

匹配到的文件即为 `Total assets scanned`。如果没有任何文件，针对已扫描文件的检查 ——
Naming、Size、Format、Orphaned —— 为 `NOT ASSESSED — no assets under <asset root>`；
缺失资源搜索仍会运行。

---

## Phase 3: 执行合规检查

**命名规范：**
- 美术：`[category]_[name]_[variant]_[size].[ext]`
- 音频：`[category]_[context]_[name]_[variant].[ext]`
- 所有文件必须为小写并使用下划线

这些是 Godot 的规范。Unity 与 Unreal 以 PascalCase 命名资源，因此在那些引擎上，只依据
美术圣经声明的命名规则检查名称；若没有该规则，Naming 为
`NOT ASSESSED — no naming rule for <engine>`（指出 `/art-bible`）。

**文件标准：**
- 纹理：二次幂尺寸、正确格式（UI 用 PNG，3D 用压缩格式）、在大小预算之内
- 音频：正确的采样率、格式（音效用 OGG，音乐用 OGG/MP3）、在时长限制之内。
  `file` 会报告音频文件的格式与采样率，但不报告其长度，此处也没有预批准的工具能做到；
  因此时长预算为 `NOT ASSESSED — duration not measurable here`，并指明它覆盖的文件。
- 数据：合法的 JSON/YAML、符合 schema

在 Unreal 上，资源文件（`.uasset`、`.umap`）不保留其源文件的格式或尺寸，因此该处的 Format
为 `NOT ASSESSED`；其大小仍会被测量。

**孤立资源：** 在代码根目录中搜索对每个资源文件的引用。标记任何没有引用的资源。

**缺失资源：** 在代码根目录中搜索资源引用，并验证文件确实存在。

两种搜索都需要代码：如果代码根目录中没有任何源文件，Orphaned 与 Missing 为
`NOT ASSESSED — no code to search`。在 Unity 与 Unreal 上，大多数资源引用位于场景、预制体
和其他资源中，而非代码中，因此没有任何代码点名的资源可能仍在使用：在这些引擎上 Orphaned
为 `NOT ASSESSED`。

---

## Phase 4: 输出审计报告

```markdown
# Asset Audit Report -- [Category] -- [Date]

## Summary
- **Total assets scanned**: [N]
- **Naming violations**: [N]
- **Size violations**: [N]
- **Format violations**: [N]
- **Orphaned assets**: [N]
- **Missing assets**: [N]
- **Sections not assessed**: [none | each section and why]

## Naming Violations
| File | Expected Pattern | Issue |
|------|-----------------|-------|

## Size Violations
| File | Budget | Actual | Overage |
|------|--------|--------|---------|

## Format Violations
| File | Expected Format | Actual Format |
|------|----------------|---------------|

## Orphaned Assets (no code references found)
| File | Last Modified | Size | Recommendation |
|------|-------------|------|---------------|

## Missing Assets (referenced but not found)
| Reference Location | Expected Path |
|-------------------|---------------|

## Recommendations
[Prioritized list of fixes, one per violation, each naming the change — the
target resolution or compression for a size violation, the corrected name for a
naming violation, the target format for a format violation]

## Verdict: [NOT ASSESSED / COMPLIANT / WARNINGS / NON-COMPLIANT]
```

根据发现选择结论，先匹配者优先：
- **NON-COMPLIANT** —— 任何大小违规，或任何被代码引用但并不存在的资源
- **WARNINGS** —— 只有命名、格式或孤立资源类发现
- **NOT ASSESSED** —— 审计未覆盖其范围：完全没有数据（上方路径）、扫描到零个资源，或任何
  章节为 `NOT ASSESSED` —— 要指明是哪一种。它排在两种发现类结论之下，因为已测得的违规比
  缺口更具可操作性，但高于 COMPLIANT
- **COMPLIANT** —— 至少扫描到一个资源、每个章节都已评估、无任何发现

本技能为只读 —— 它产出报告，但不写入文件。

---

## Phase 5: 后续步骤

- 使用 Phase 3 的模式（或在美术圣经声明了自己的模式时使用其模式）修复命名违规。
- 若缺少标准，运行 `/art-bible` 写入其 Asset Standards 章节。
- 人工复查确认后，删除已确认的孤立资源。
- 运行 `/content-audit`，把资源数量与 GDD 规定的需求进行交叉核对。
