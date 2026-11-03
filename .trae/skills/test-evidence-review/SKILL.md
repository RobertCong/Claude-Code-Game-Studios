---
name: test-evidence-review
description: "对测试文件与证据进行质量评审 —— 不止于检查是否存在，还评估断言覆盖率。按用户故事给出 ADEQUATE/INCOMPLETE/MISSING/NOT ASSESSED 结论。"
argument-hint: "[story-path | sprint | system-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/test-evidence-review/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/review-receipts.sh check *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level,testing.strict`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

**`qa.level` 和 `testing.strict`**（已在上方解析）决定本次评审可以把什么
称为阻塞项 —— 与 `/story-done` 关闭用户故事所依据的规则相同，因此这里的
BLOCKING 项就是会阻止 `/story-done` 的项：
- **`qa.level: minimal`** 免测。Logic、Integration 或 Config/Data 类型的用户故事
  没有测试证据（Config/Data 则指没有冒烟测试报告）时，结论为
  `WAIVED (qa.level: minimal)` —— 而不是 MISSING —— 且不产生 BLOCKING 项；
  确实存在的测试仍会被评审，但其缺陷记为 ADVISORY。Visual/Feel 与 UI 证据（保留的
  截图，以及 Visual/Feel 的签核）永不豁免。
- **按用户故事类型的闸门级别**：从已解析配置块中读取 `testing.strict.<type>`
  （Logic→`logic`，Integration→`integration`，Visual/Feel→`visual`，
  UI→`ui`，Config/Data→`config`）：`true` → BLOCKING，`false` → ADVISORY，`unset`
  → 则适用纯布尔形式的 `testing.strict: true|false`（旧式写法）于所有
  类型；否则使用 `.claude/docs/coding-standards.md` 中的默认闸门级别
  （Logic、Integration、Visual/Feel 和 UI 为 BLOCKING；Config/Data 为
  ADVISORY）。下文所有 "BLOCKING" 均指该用户故事类型的闸门级别。

# 测试证据评审

`/smoke-check` 验证测试文件**存在**且**通过**。本技能更进一层 —— 它评审这些测试
和证据文档的**质量**。一个存在且通过的测试文件仍可能留下未被覆盖的关键行为。
一份存在的手工证据文档可能缺少关闭所需的签核。

**输出**：摘要报告（在对话中）+ 可选的 `production/qa/evidence-review-[date].md`

**何时运行**：
- 在 QA 交接签核之前（`/team-qa` Phase 5）
- 对任何测试质量存疑的用户故事
- 作为里程碑评审的一部分，用于 Logic 与 Integration 用户故事的质量审计

---

## 1. 解析参数

**模式：**
- `/test-evidence-review [story-path]` —— 评审单个用户故事的证据
- `/test-evidence-review sprint` —— 评审当前冲刺中的所有用户故事
- `/test-evidence-review [system-name]` —— 评审某个史诗/系统中的所有用户故事
- 无参数 —— 询问范围："单个用户故事"、"当前冲刺"、"某个系统"

---

## 2. 加载范围内的用户故事

根据参数：

**单个用户故事**：直接读取用户故事文件。提取：Story Type、Test
Evidence 部分、用户故事标识（slug）、系统名称。

**冲刺**：读取 `production/sprints/` 中最近修改的文件；提取
冲刺计划中的用户故事文件路径列表。

**系统**：Glob `production/epics/[system-name]/story-*.md`。

> **如果解析出的范围内没有任何用户故事，就此停止。** 报告
> `NOT ASSESSED — no stories in scope`，说明搜索了哪个范围、哪个
> 路径为空，并给出路由：没有冲刺文件 → `/sprint-plan new`（在 `workflow: minimal` 下
> 没有冲刺，改用 `/test-evidence-review [epic-slug]`）；冲刺计划
> 未列出任何用户故事 → `/create-stories [epic-slug]`；`[system-name]` glob
> 无匹配 → 报出该 glob。不要继续到第 3 节。
>
> **要守护空范围，而不只是单个用户故事的未知。** 这里的结论
> 词汇 —— ADEQUATE / INCOMPLETE / MISSING —— 需要一个"无法检查"的
> 取值，否则一个无法核实的用户故事就会获得一个声称已有人核实
> 它的结论；这正是 `NOT ASSESSED` 的用途。**但为单个用户故事的未知提供
> 归宿，对空范围的未知毫无帮助。** 没有用户故事时，
> 第 6 节的报告会渲染出空的 Summary 表并以
> `BLOCKING items: 0 / ADVISORY items: 0` 结尾 —— 读起来像是 *全部已评审，
> 一切正常*。本技能是用户故事关闭的闸门，而 `coding-standards.md` 将 Logic、
> Integration、Visual/Feel 和 UI 证据标记为 BLOCKING，因此虚假的干净结果会关闭无人
> 评审过的用户故事。

对得到的用户故事集合，用**针对性的分段 grep，而非完整读取每个用户故事**来收集以下字段：
```
Grep pattern="## Test Evidence" glob="production/epics/**/story-*.md" output_mode="content" -A 8
Grep pattern="## Acceptance Criteria" glob="production/epics/**/story-*.md" output_mode="content" -A 15
```
- **Story Type**（Logic / Integration / Visual/Feel / UI / Config/Data）以及
  声明的证据路径 —— 两者都在 `## Test Evidence` 下，因此第一次 grep 的
  `-A 8` 会捕获它们。
- Acceptance Criteria 列表 —— 来自第二次 grep 的 `## Acceptance Criteria` 块。
- 用户故事标识（slug，来自文件名）和 System（来自目录路径）—— 无需读取。
仅当某个用户故事的 Test Evidence 部分缺失或歧义时才完整读取它。
（在冲刺模式下，将 glob 限定为冲刺计划中的用户故事路径。）

---

## 3. 定位证据文件

对每个用户故事查找证据。**先检查用户故事声明的证据路径**
—— 即第 2 节从其 `## Test Evidence` 部分捕获的那一个。如果它存在，就用
它。仅当未声明路径或未找到时才回退到搜索：

**Logic 用户故事**：搜索引擎的单元测试根目录 —— `tests/unit/[system]/`
（Godot）、`Assets/Tests/EditMode/`（Unity）、`Source/<Module>/Private/Tests/`
（Unreal）；参见 `.claude/docs/directory-structure.md` —— 查找文件名
包含用户故事标识或其系统名的文件。测试文件的命名遵循
`.claude/rules/test-standards.md`，不一定叫 `[story-slug]_test.*`。

**Integration 用户故事**：同上，位于集成测试根目录（`tests/integration/[system]/`、
`Assets/Tests/PlayMode/` 或 Unreal 的测试根目录）
  - 还要检查 `production/qa/playtests/` 中提及该用户故事的试玩测试记录

**Visual/Feel 和 UI 用户故事**：对 `production/qa/evidence/` 执行 Glob，查找属于该
用户故事的保留图片（`*.png`、`*.jpg`、`*.gif`），以及
`[story-slug]-evidence.*`

**Config/Data 用户故事**：Glob `production/qa/smoke-*.md`（任何冒烟检查报告）

记录每个用户故事找到了什么（路径）或没找到什么（缺口）。

---

## 4. 评审自动化测试质量（Logic / Integration）

对找到的每个测试文件，读取并评估：

### 断言覆盖率

统计不同断言的数量（包含 assert、expect、
check、verify 或引擎特有断言模式的行）。断言数量低是一个
质量信号 —— 每个测试函数只做 1 个断言的测试可能
未覆盖预期行为的范围。

阈值：
- **每个测试函数 3+ 个断言** → 正常
- **每个测试函数 1-2 个断言** → 记为可能薄弱
- **0 个断言**（测试存在但无断言）→ 标记为 BLOCKING（该用户故事
  类型的闸门级别；在 `qa.level: minimal` 下为 ADVISORY）—— 该测试只是
  空转通过，证明不了任何东西

### 边界用例覆盖

对用户故事中每一个包含数字、阈值
或"当 X 发生时"条件的验收标准：检查是否有测试函数名或
测试体引用了该特定情况。

启发式方法：
- 在测试文件中 Grep "zero"、"max"、"null"、"empty"、"min"、"invalid"、
  "boundary"、"edge" —— 出现任一项都是积极信号
- 如果用户故事有带具体边界的 Formulas 部分：检查
  测试是否覆盖最小值/最大值

### 命名质量

测试函数名应描述：场景 + 预期结果。
各引擎的模式（`.claude/rules/test-standards.md`）：Godot
`test_[scenario]_[expected]`，Unity `[Scenario]_[Expected]`，Unreal
`<Project>.[System].[Scenario]`。

将命名笼统的函数（`test_1`、`test_run`、`testBasic`）标记为
**命名问题** —— 它们使失败更难诊断。

### 公式可追溯性

对于 GDD 中有 Formulas 部分的 Logic 用户故事：检查测试
文件是否至少包含一个测试，其名称或注释引用了公式
名称或某个公式值。一个执行了公式却未指明其名称的
测试，在公式变化时更难维护。

---

## 5. 评审手工证据质量（Visual/Feel / UI）

对找到的每份证据文档，读取并评估以下检查项。

**UI 用户故事不需要证据文档。** 当它没有时，其保留的
截图就是证据：只应用 截图/产出物完整性（用户故事更改的每个屏幕
都应有一张图片 —— 某个验收标准只是导航到的屏幕，
例如退出后的标题画面，不需要自己的图片）和 日期覆盖（图片的
日期）。UI 用户故事在这两项上即为 ADEQUATE —— 绝不因缺少文档、
标准关联或签核而为 INCOMPLETE。

### 标准关联

证据文档应引用用户故事中的每一条验收标准。
检查：证据文档是否包含每一条标准（或清晰的改述）？
缺失的标准意味着某条标准从未被验证。

### 签核完整性

什么能关闭用户故事遵循
`.claude/docs/coding-standards.md` 中的证据表 —— 与 `/story-done` 在每种
`qa.level` 下应用的规则相同：
- **Visual/Feel**：证据文档（来自 test-evidence 模板）必须有
  每一行签核为 `[x] Approved`。空白或缺失的行即为 INCOMPLETE。
- **UI**：不需要签核 —— 保留的截图即可关闭它。若存在签核则
  记下；绝不因缺少签核而将 UI 用户故事标记为 INCOMPLETE。

### 截图/产出物完整性

对于 Visual/Feel 用户故事：对 `production/qa/evidence/` 执行 Glob，查找属于该
用户故事的保留图片（`*.png`、`*.jpg`、`*.gif`）。描述了视觉检查
但没有保留任何图片的文档为 INCOMPLETE —— 该闸门默认是 BLOCKING，
而描述只是断言而非证据。

对于 UI 用户故事：要求对涉及的每个屏幕都有同样保留的截图。
走查日志受欢迎但非必需。

### 证据早于其代码

对每个有保留图片的用户故事，运行
`bash .claude/scripts/review-receipts.sh check production/qa/evidence/[story-slug]/stamp.txt`。
将每个 `CHANGED:` 或 `GONE:` 文件列为 POTENTIALLY STALE —— 它在证据
捕获之后发生了更改。`RECEIPT: NONE`：说明"无时间戳"并使用下面的日期检查。
这仅是报告中的一行：它从不改变用户故事的结论。

### 日期覆盖

证据文档应有日期。如果日期早于用户故事的
最后一次重大更改（启发式：与冲刺计划中的冲刺开始日期
比较），标记为 POTENTIALLY STALE —— 证据可能未覆盖最终
实现。

---

## 6. 构建评审报告

对每个用户故事给出结论：

| 结论 | 含义 |
|---------|---------|
| **ADEQUATE** | 测试/证据存在，通过质量检查，覆盖所有标准 |
| **INCOMPLETE** | 测试/证据存在但有质量缺口（断言薄弱、缺少签核） |
| **MISSING** | 某类用户故事在该 `qa.level` 下要求证据，但未找到任何测试或证据 |
| **NOT ASSESSED** | 无法对该用户故事进行评审 —— 见下文 |
| **WAIVED (qa.level: minimal)** | 在 `qa.level: minimal` 下无测试证据的 Logic、Integration 或 Config/Data 用户故事 —— 不要求测试，因此没有缺失；将其记为已豁免 |

> **`NOT ASSESSED` 是必需的，它不是更温和的 `MISSING`。**
> 其他三种结论都预设评审实际发生了。`MISSING` 意味着
> *我去看了，但那里什么都没有* —— 一个真实的、可报告的失败。它绝
> 不能用于 *我无法查看*，这根本不是关于用户故事的发现。在以下情况使用 `NOT ASSESSED`：
>
> - 用户故事的**类型无法确定**，因此所需证据
>   未知（`.claude/docs/coding-standards.md` 中的类型→证据映射
>   正是使任何其他结论有意义的基础）；
> - 证据路径已指明但**不可读或超出本次运行范围**；
> - 用户故事文件本身无法解析。
>
> **按用户故事说明属于上述哪种情况。** 读者无法对光秃秃的
> `NOT ASSESSED` 采取行动，而将其与 `MISSING` 区分的全部意义在于
> 二者有不同的修复方式：一个需要编写测试，另一个需要给
> 评审者访问权限或对用户故事进行分类。

冲刺/系统的总体结论取范围内最差的用户故事结论，且
**`NOT ASSESSED` 高于 `ADEQUATE`**：一次无法评估其部分
范围的运行并未确立该范围是充分的。它不高于
`INCOMPLETE` 或 `MISSING` —— 已知的失败比未知更可操作，
把一个真实失败降级到访问问题之后会掩埋它。`WAIVED`
低于 `ADEQUATE`：只有当范围内每个用户故事都被豁免时总体结论才读作 WAIVED，
无论哪种情况报告都会列出每个被豁免的用户故事。

> 为什么这很重要：证据评审判定**用户故事的完成**，而
> `coding-standards.md` 将 Logic、Integration、Visual/Feel 和 UI 证据设为 BLOCKING。一种无法表达"我无法检查"的结论
> 词汇，会迫使每个未知项落入关于该用户故事的三种断言之一 —— 这正是
> 一个无人核实过的用户故事获得"某人核实过"结论的方式。

```markdown
## Test Evidence Review

> **Date**: [date]
> **Scope**: [single story path | Sprint [N] | [system name]]
> **Stories reviewed**: [N]
> **Overall verdict**: ADEQUATE / INCOMPLETE / MISSING / NOT ASSESSED / WAIVED
> **qa.level**: [minimal | standard | full] — **testing.strict**: [the resolved per-type values, or "unset — coding-standards.md defaults"]

---

### Story-by-Story Results

#### [Story Title] — [Type] — [ADEQUATE/INCOMPLETE/MISSING/NOT ASSESSED/WAIVED]

**Test/evidence path**: `[path]` (found) / (not found)

**Automated test quality** *(Logic/Integration only)*:
- Assertion coverage: [N per function on average] — [adequate / thin / none]
- Edge cases: [covered / partial / not found]
- Naming: [consistent / [N] generic names flagged]
- Formula traceability: [yes / no — formula names not referenced in tests]

**Manual evidence quality** *(Visual/Feel/UI only)*:
- Criterion linkage: [N/M criteria referenced]
- Lead sign-off: [✓ approved | ✗ missing | deferred — reason] *(Visual/Feel only; a UI story needs none)*
- Artefacts: [screenshots present / missing / N/A]
- Freshness: [dated [date] — current / potentially stale]

**Issues**:
- BLOCKING: [description] *(prevents story-done)*
- ADVISORY: [description] *(should fix before release)*

---

### Summary

| Story | Type | Verdict | Issues |
|-------|------|---------|--------|
| [title] | Logic | ADEQUATE | None |
| [title] | Integration | INCOMPLETE | Thin assertions (avg 1.2/function) |
| [title] | Visual/Feel | INCOMPLETE | Lead sign-off missing |
| [title] | Logic | MISSING | No test file found |
| [title] | Logic | WAIVED | No test — waived at `qa.level: minimal` |

**BLOCKING items** (must resolve before story can be closed): [N]
**ADVISORY items** (should address before release): [N]
```

---

## 7. 写出输出（可选）

在对话中呈现报告。

询问："我可以将这份测试证据评审写入
`production/qa/evidence-review-[date].md` 吗？"

这是可选的 —— 报告单独使用也有价值。仅在用户
需要持久记录时才写入。

报告之后：

- 对于 BLOCKING 项："这些必须在 `/story-done` 能将用户故事标记为
  Complete 之前解决。你希望现在处理其中任何一项吗？"
- 对于薄弱断言："考虑运行 `/test-helpers [system]`，查看
  常见场景的脚手架断言模式。"
- 对于缺少签核："需要 [role] 进行手工签核。将
  `[evidence-path]` 分享给他们以完成签核。"

结论：**COMPLETE** —— 证据评审完成。若发现 BLOCKING 项则使用 CONCERNS。

---

## 协作协议

- **报告质量问题，不要修复它们** —— 本技能只读取和评估；
  它不修改测试文件或证据文档
- **ADEQUATE 意味着足以发布，而非完美** —— 不要对
  运作正常且足够全面、能给予信心的测试吹毛求疵
- **BLOCKING 与 ADVISORY 的区分很重要** —— 只有当缺口
  确实使某条用户故事标准未被验证时才标记 BLOCKING
- **写入前先询问** —— 报告文件是可选的；写入前始终确认
