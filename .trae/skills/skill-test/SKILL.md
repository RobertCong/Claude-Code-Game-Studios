---
name: skill-test
description: "校验技能文件的结构合规性与行为正确性。四种模式：static 结构检查器、spec 规格测试、category 分类评分量规、audit 审计。"
argument-hint: "static [skill-name | all] | spec [skill-or-agent-name] | category [skill-or-agent-name | all] | audit"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 始终询问 · guided 仅重大事项 · autonomous 记录并继续；
`automation_always_ask` 类别始终提示）。

# 技能测试

校验技能（`.trae/skills/*/SKILL.md`）和 agent（`.trae/agents/*.md`）的
结构合规性与行为正确性。无外部依赖 —
完全在现有的技能/钩子/模板架构内运行。

**四种模式：**

| 模式 | 命令 | 用途 | Token 成本 |
|------|---------|---------|------------|
| `static` | `/skill-test static [name\|all]` | 结构检查器 — 每个技能 7 项合规检查，外加 agent、委派和兼容性观察项 | 低（约 1k/技能） |
| `spec` | `/skill-test spec [name]` | 行为验证器 — 评估技能或 agent 的测试规格中的断言 | 中（每个约 5k） |
| `category` | `/skill-test category [name\|all]` | 分类评分量规 — 按类别专属指标检查技能或 agent | 低（每个约 2k） |
| `audit` | `/skill-test audit` | 覆盖率报告 — 技能、agent 规格、最近测试日期 | 低（共约 3k） |

**一次通过能证明什么。** 每种模式都只读取文件；没有一种会运行技能。`static`：
文件具备技能所需的结构，而非它行为正确。`spec`：仔细阅读，说明覆盖了
每种情况，而非 Trae 运行时会遵循它们。`category`：技能按书面内容
满足其类别的评分量规。`audit`：哪些技能和 agent 有规格，以及各自
上次检查的时间。技能实际做什么，只有运行时才显现：在一个一次性项目副本中
发出真实请求，在你使用的每个模型上，分别在有技能和无技能的情况下运行
（Anthropic 的 Agent Skills 最佳实践，“Build evaluations first”）。

---

## Phase 1: 解析参数

根据第一个参数确定模式：

- `static [name]` → 对一个技能运行 7 项结构检查，或对一个 agent 运行观察项
- `static all` → 对所有技能运行 7 项结构检查（Glob `.trae/skills/*/SKILL.md`），外加每个 agent 的观察项
- `spec [name]` → 读取技能或 agent 及其测试规格，评估断言
- `category [name]` → 运行 `studio-tests/quality-rubric.md` 中类别专属的评分量规
- `category all` → 对每个技能和每个在 catalog 中带 `category:` 的 agent 运行分类评分量规
- `audit`（或无参数）→ 读取 catalog，列出所有技能和 agent，展示覆盖率

若参数无法识别，输出用法并停止。

**旧的 spec 文件夹。** Glob `CCGS Skill Testing Framework/catalog.yaml`。若
它存在，先说明：“`CCGS Skill Testing Framework/` 在 1.2.0 中已更名为
`studio-tests/`，而本技能只读取 `studio-tests/`。请移动你在那里写过的
任何规格；UPGRADING.md（v1.1.3 → v1.2.0，`studio-tests/`）说明了方法。”
然后继续使用 `studio-tests/`。

**在 `spec` 或 `category` 之前先解析名称。** 在
`studio-tests/catalog.yaml` 中查找：`skills:` 下的条目是技能
（`.trae/skills/[name]/SKILL.md`）；`agents:` 下的条目是 agent
（`.trae/agents/[name].md`）。若 catalog 中没有条目，则使用这两个文件中
存在的那一个。仅当两者都不存在时，报告“‘[name]’ 既不是
`.trae/skills/` 中的技能，也不是 `.trae/agents/` 中的 agent。”并停止。
一个同时也是普通单词的名称仍然是名称：`/skill-test spec help` 测试的是 `/help`
技能，绝不会是对本技能用法的请求。

这 7 项检查针对 SKILL.md 结构做 lint，因此仅适用于技能。给定 agent
名称时，`static` 只运行下方的观察项：agent 文件没有
可 lint 的阶段或结论关键词。绝不要把 agent 报告为缺失。

---

## Phase 2A: Static 模式 — 结构检查器

对每个被测技能，完整读取其 `SKILL.md` 及其 `references/` 文件夹中的每个文件，
并将它们作为一个技能运行全部 7 项检查 — 最长的技能会把每个阶段
放在 `references/` 中。frontmatter 检查（1、6 和 7）读取 `SKILL.md`。

### Check 1 — 必需的 frontmatter 字段
文件必须在 YAML frontmatter 块中包含以下全部字段：
- `name:`
- `description:`
- `argument-hint:`
- `user-invocable:`

并且**不得**包含 `model:` 或 `allowed-tools:`：Trae 的 Skill frontmatter 不支持
`model`，`allowed-tools` 的工具名白名单也容易静默失效。

若缺少任一必需字段，或仍包含 `model:` / `allowed-tools:`，则 **FAIL**。frontmatter
无法解析的文件同样无法通过 Check 1 — 格式错误的 YAML 是这项检查存在的目的所要捕获的
结构缺陷，而不是无法评估的文件；参见下方的单技能结果规则。

### Check 2 — 多个阶段
技能必须具有 ≥2 个带编号的阶段标题。查找类似模式：
- `## Phase N` 或 `## Phase N:`
- `## N.`（带编号的顶层章节）
- 如果阶段未显式编号，至少 2 个不同的 `##` 标题

若找到的类阶段标题少于 2 个则 **FAIL**。

### Check 3 — 结论关键词

技能必须传达明确的结论。接受以下任一：
- **质量闸门 / 评审结论** — `PASS`、`FAIL`、`CONCERNS`、`APPROVED`、
  `BLOCKED`、`COMPLETE`、`READY`、`COMPLIANT`、`NON-COMPLIANT`
- **Go / no-go 结论** — `PROCEED`、`PIVOT`、`KILL`、`GO`、`NO-GO`
- **严重程度量表** — `CRITICAL`、`HIGH`、`MEDIUM`、`LOW`。审计技能按
  严重程度对发现项排序，而不是为整次运行给出一个结论。

若上述均不存在**且**技能产出评估 — 即其
description 或正文承诺了评审、审计、检查、质量闸门或就绪判断 — 则 **FAIL**。

若上述均不存在，且技能的输出是产出物
或一个值而非判断，则 **WARN**（绝不 FAIL）。`/settings` 是参考案例：它打印
并写入配置，没有可给出的结论。不要为了满足这项检查而凭空编造一个。

> 一个更窄的列表 — 只有质量闸门结论，其他一律硬性 FAIL — 会因并非
> 技能自身的问题而错误地使其失败：`/prototype` 和
> `/vertical-slice` 在自己的 description 中声明 `PROCEED`/`PIVOT`/`KILL`，
> `/adopt` 和 `/security-audit` 按严重程度排序，而 `/settings` 按设计
> 本就没有结论。一个对合理模式产生误报失败的检查器将不再被信任。

### Check 4 — 协作协议用语
技能必须包含写入前询问的用语。查找：
- `"May I write"`（规范形式）
- 文件写入说明附近的 `"before writing"` 或 `"approval"`
- 同一章节内相近位置出现 `"ask"` + `"write"`

若不存在则 **WARN**（一些只读技能合理地跳过此项）。
若技能正文承诺写入文件（提到 `Write`/`Edit`，或要求把产出物写到某个路径）但没有写入前询问用语，则 **FAIL**。Trae 不写 `allowed-tools`，因此不能再靠它判断技能是否可写。

### Check 5 — 下一步交接
技能必须以推荐的下一步行动或后续路径结束。查找：
- 提到另一个技能的最终章节（例如 `/story-done`、`/gate-check`）
- “Recommended next” 或 “next step” 措辞
- “Follow-Up” 或 “After this” 章节

若不存在则 **WARN**。

### Check 6 — Fork 上下文复杂度
如果 frontmatter 包含 `context: fork`，技能应具有 ≥5 个阶段标题
（`##` 级别或带编号的 Phase N 标题）。Fork 上下文适用于复杂的多阶段
技能；简单技能不应使用它。

若设置了 `context: fork` 但找到的阶段少于 5 个，则 **WARN**。

### Check 7 — 参数提示合理性
`argument-hint` 必须非空。如果技能正文提到多种模式
（例如 “Mode A | Mode B”），提示应反映它们。将
提示与第一个阶段的 “Parse Arguments” 章节交叉核对。

若提示为 `""` 或记录的模式与提示不匹配，则 **WARN**。

### Agent 与委派观察项（不计分）

对技能运行 `bash .trae/scripts/agent-check.sh --skill [name]`，
对 agent 运行 `bash .trae/scripts/agent-check.sh --agent [name]`，或在 `static all` 时一次性运行
`bash .trae/scripts/agent-check.sh`。它打印观察项，从不给出结论，此处任何内容都不会改变
技能的结论。在 `Observations:` 下报告它们，并逐一评判：

- **`DELEGATION:`** 技能中把工作交给 agent 的部分。阅读它并
  说明简报是否给出了目标、输出格式、工具与
  来源以及边界，以及它交给 agent 的是仅需少量
  工具调用的任务，还是对技能自身工作的复查。它的 `markers:` 是词数
  标记，用来说明该看哪里，而非评分。
- **`AGENT:`** description 旁边的工具与 `disallowedTools`：指出 description 中的任务并不需要的任何工具。Trae 子代理没有回合上限或自动记忆，因此不要评价这些字段。
- **`NOTE:`** 无法解析的 frontmatter；`asks-user`（agent 没有
  提问工具，因此其问题应放在报告末尾）；被忽略或
  描述与实际不符的设置（`agent-type-list`、`preload-off`、
  `disallowed-specifier`、`memory-grants`）。
- **`OVERLAP:`** 两个共享特征词的 description：说明各自
  是否仍能单独识别其 agent，或哪个请求会落到错误的那一个。

如果脚本无法运行，写 `Observations: not run (<reason>)`。绝不省略
该章节：缺失的章节读起来与干净通过的章节相同。

### 兼容性观察项（不计分）

对技能运行 `bash .trae/scripts/trae-compat-check.sh --skill [name]`，
对 agent 运行 `bash .trae/scripts/trae-compat-check.sh --agent [name]`，或在 `static all` 时一次性运行
`bash .trae/scripts/trae-compat-check.sh`。每条 `FOUND:`
行都是文件仍然带有 Trae 不会按 Claude Code 方式执行的构造，并标明
其类别：frontmatter、shell-lines、subagents、variables、rules、hooks 或 legacy-paths。
这些行值得在迁移或评审时逐条确认；它们不改变技能的行为结论。在
`Compatibility:` 下报告它们，每个类别一行，注明其构造和行号；
对于 `static all`，改为按类别给出 `COUNT:` 总计。`NOT FOUND:`
行表示名称未匹配任何文件：如实说明。如果脚本无法运行，写
`Compatibility: not run (<reason>)`。

---

### Static 模式输出格式

对单个技能：
```
=== Skill Static Check: /[name] ===

Check 1 — Frontmatter Fields:    PASS
Check 2 — Multiple Phases:       PASS (7 phases found)
Check 3 — Verdict Keywords:      PASS (PASS, FAIL, CONCERNS)
Check 4 — Collaborative Protocol: PASS ("May I write" found)
Check 5 — Next-Step Handoff:     WARN (no follow-up section found)
Check 6 — Fork Context Complexity: PASS (8 phases, context: fork set)
Check 7 — Argument Hint:         PASS

Observations (not scored):
  Delegation, "Phase 3: Implementation" (line 202): ux-designer, ui-programmer.
    The brief names the output file and limits but no sources to read.

Compatibility (not scored):
  variables: var:CLAUDE_SKILL_DIR (line 10) · legacy-paths: .legacy (line 88)

Verdict: WARNINGS (1 warning, 0 failures)
Recommended: Add a "Follow-Up Actions" section at the end of the skill.
```

对单个 agent，没有结论，只有观察项：
```
=== Agent Static Check: qa-lead ===

Model: inherit · Effort: unset · Turn limit: 20
Tools: Read, Glob, Grep, Write, Edit, Bash. Fits the job (it writes test plans).
Observations (not scored):
  asks-user (lines 31, 52): tells the agent to get approval before writing.
  overlap with qa-tester (creation, regression, test): each still singled out.
Compatibility (not scored):
  frontmatter: tools, tools-string, model, maxTurns (lines 4-6)
```

WARN 或 FAIL 行会在括号中说明其原因，任何非
COMPLIANT 的结论都以一行 `Recommended:` 结尾，指出修复方式。

单技能的 `Verdict:` 是四个值之一，与 `static all` 的
Result 列相同：**COMPLIANT**（无警告、无失败）、**WARNINGS**（有警告、
无失败）、**NON-COMPLIANT**（任何 FAIL），或 **NOT ASSESSED**（文件无法
读取或解析，或其检查无法运行 — 说明原因）。

对于 `static all`，生成一张摘要表，然后列出任何不合规的技能：
```
=== Skill Static Check: All 74 Skills ===

Skill                  | Result       | Issues
-----------------------|--------------|-------
gate-check             | COMPLIANT    |
design-review          | COMPLIANT    |
story-readiness        | WARNINGS     | Check 5: no handoff
...

Summary: 48 COMPLIANT, 3 WARNINGS, 1 NON-COMPLIANT, 1 NOT ASSESSED
Aggregate Verdict: N WARNINGS / N FAILURES / N NOT ASSESSED

Agents (observations, not scored): 49 read
  asks-user: N agents · agent-type-list: N · preload-off: N · frontmatter: N
  Overlap pairs: [each pair, with whether both are still singled out]
  Delegation blocks: N in N skills; [the ones whose brief lacks a part]

Compatibility (not scored): N FOUND lines in N of N files read
  [feature]: [construct] N files, N hits; ...   (one line per feature)
```

**`NOT ASSESSED` 在此是每个技能的结果，而不只是一行汇总。** 文件缺失或
其他原因无法读取（权限、未找到），以致任何检查都无法开始
的技能，会报告为 `NOT ASSESSED` 并附原因 — 绝不从表中
省略，也绝不计为 COMPLIANT。排序**高于
COMPLIANT**、**低于 WARNINGS 和 NON-COMPLIANT**。文件*已被*读取但
frontmatter 无法解析是另一种情况：Check 1 在其上失败（见
上文），因此报告为 **NON-COMPLIANT**，而非 NOT ASSESSED — 缺陷在
技能本身，而不在于检查器对它的访问权限。

**并且要说明分母。** 表头中的 `All 74 Skills` 必须是实际
检查的数量，而非存在的数量：当两者不同时，报告 `[N] of [M] skills checked`。
一份计数悄悄加起来小于其自身标题的摘要，正是本技能
应当在其他技能中捕获的失败。

Static 模式下不写入任何文件。

---

## Phase 2B: Spec 模式 — 行为验证器

### Step 1 — 定位文件

使用 Phase 1 中解析出的技能或 agent 文件。
从 `studio-tests/catalog.yaml` 查找规格路径 — 使用匹配的 `skills:` 或 `agents:`
条目上的 `spec:` 字段。

若任一缺失：
- 缺少技能或 agent：使用 Phase 1 的消息。
- catalog 中缺少规格路径：“catalog.yaml 中未为 ‘[name]’ 设置规格路径。”
- 在路径处未找到规格文件：“规格文件缺失于 [path]。运行 `/skill-test audit`
  查看覆盖率缺口。”

### Step 2 — 读取两个文件

完整读取技能 — 其 `SKILL.md` 及其 `references/` 文件夹中的每个文件 — 或
agent 文件，以及测试规格文件。

### Step 3 — 评估断言

**针对运行它的模型所能看到的内容进行评估。** 技能会在一个
会话中运行，而派生出的 agent 在其自己的上下文中运行，两者都会加载项目的
`AGENTS.md`，以及它在 `@path` 行上导入的每个文件（派生出的 agent
会逐字引用 `coordination-rules.md` 而无需读取它）。
也要读取这些文件。其中陈述的规则对每个技能和 agent 都算数 —
引用其来源文件。当技能或 agent 自身的文件与之矛盾时，
以自身文件为准：它是更具体的指令。

**对于 agent**，规格的各章节是针对 agent 文件评估的 —
并且也针对其正文提到的每个可加载技能（Trae 用 Skill 工具按需加载，不预先注入）：

- **Static Assertions** — 对照 agent 的 frontmatter 和正文逐条检查。
  命名了字面值（一个 `description` 关键词、一个 frontmatter 键、
  一个工具名）的断言是与文件的精确比较：`tools: Read, Glob` 不满足
  “tools includes Write”，近似匹配是 FAIL，绝不是 PARTIAL。
- **Test Cases** — 按下方评估技能的方式，根据 agent 的
  书面说明评估每个用例的预期行为。命名了质量闸门 ID（`LP-FEASIBILITY`、`CD-PILLARS`、…）的用例
  就是对该闸门的调用：派生它的技能会让 agent 先读取
  `.trae/docs/director-gates/[gate-id].md`，因此该文件的 Prompt 和
  Verdicts 就是 agent 针对该用例的说明 — 也要读取它。
- **重定向与升级用例** — agent 被要求做另一个角色
  拥有的工作，或遇到它无法解决的冲突。当已加载的
  `coordination-rules.md` 覆盖该步骤时，该用例即满足 — 规则 2（不得在其领域之外做约束性决策）、规则 3（将冲突升级给共同的父级）或
  规则 5（未经委派不得在其目录之外创建文件） — **并且**
  agent 自身的文件在其协作者、委派、
  升级或“不得”列表中指明了拥有该职责的角色。两者都要引用；不要要求 agent
  用自己的话重述该重定向。若 agent 的文件声称该工作归自己所有，
  或没有已加载的文件指明谁拥有它，则为 FAIL。
- **Protocol Compliance** — 使用规格自身的 `## Protocol Compliance` 列表
  代替下方的四项技能检查。

**对于技能**，以相同方式对照技能的前置元数据和正文（`SKILL.md` 及其 `references/` 文件）
检查规格中的每条 **Static Assertions**；字面值是精确
比较。`/skill-test static` 只运行其 7 项固定检查，因此规格自身的
静态行 — 一个结论关键词、一个阶段、在命名文件之前写 “May I write” —
在此评估，否则就无处评估。

本步骤的其余部分同样适用于技能和 agent。

对规格中的每个 **Test Case**：

1. 阅读 **Fixture** 描述（假定的项目文件状态）
2. 阅读 **Expected behavior** 步骤
3. 阅读每个 **Assertion** 复选框

没有 **Fixture** 的用例会把其 **Input** 当作 fixture；没有
**Assertions** 列表的用例会把每个 **Expected behavior** 要点当作断言 —
大多数 agent 规格就是这样写的，不会仅因
没有单独的检查清单就让用例结论悬而未决。

对每条断言，评估若在给定 fixture 状态下正确遵循技能的书面说明，
是否会满足它。这是由模型评估的推理检查，而非代码执行。

标记每条断言：
- **PASS** — 技能说明清楚地满足该断言
- **PARTIAL** — 技能说明部分涉及，但存在歧义
- **FAIL** — 在给定 fixture 下技能说明不会满足该断言
- **NOT ASSESSED** — 该断言完全无法评估：它命名的
  fixture 状态规格从未定义、依赖任何静态阅读都无法确定的运行时行为，
  或引用了不存在的文件或章节（文件只是
  对该行为保持沉默，则属于 FAIL 或 PARTIAL，而不是此类）。将其排在
  **PASS 之上**（无人能评估的断言并未被满足）且
  **PARTIAL 和 FAIL 之下**（有人已识别的歧义比无人能
  触及的更可操作）。不要因技能“可能”会处理某条无法评估的断言
  就将其判为 PASS — 这种判断正是规格存在的目的所要取代的。

对于技能的 **Protocol Compliance** 章节（始终存在），照评估用例
断言的方式（PASS、PARTIAL、FAIL 或 NOT ASSESSED）评估规格自身列表的每一行。
规格会把没有用例重复的规则放在那里（“covered by the protocol compliance assertions above”），
因此未被评估的列表就是一套无人检查的规则。这四项检查是
下限，在列表尚未覆盖它们时添加：
- 检查技能是否要求文件写入前先 “May I write”
- 检查技能是否在请求批准前呈现发现项
- 检查技能是否以推荐的下一步结束
- 检查技能是否避免未经批准自动创建文件

### Step 4 — 构建报告

```
=== Skill Spec Test: /[name] ===
Date: [date]
Spec: studio-tests/skills/[category]/[name].md

Static Assertions:
  [PASS] [assertion text]
  [NOT ASSESSED] [assertion text]
     Reason: [why it could not be evaluated]

Case 1: [Happy Path — name]
  Fixture: [summary]
  Assertions:
    [PASS] [assertion text]
    [FAIL] [assertion text]
       Reason: The skill's Phase 3 says "..." but the fixture state means "..."
  Case Verdict: FAIL

Case 2: [Edge Case — name]
  ...
  Case Verdict: PASS

Protocol Compliance:
  [PASS] Uses "May I write" before file writes
  [PASS] Presents findings before asking approval
  [PARTIAL] No explicit next-step handoff at end

Overall Verdict: FAIL (1 case failed, 1 protocol line partial)
```

Case Verdict 是其断言中最差的结果，Overall
Verdict 是静态断言、用例和 Protocol
Compliance 中最差的结果，顺序为：
FAIL、PARTIAL、NOT ASSESSED、PASS。无人能评估的断言会阻止
整体结果读作 PASS。

对于 agent，表头为 `=== Agent Spec Test: [name] ===`，`Spec:` 是其在
`studio-tests/agents/` 下的路径，并且 Case 1 之前会有一个 `Static Assertions:`
块。

### Step 5 — 提供写入结果

“我可以把这些结果写入 `studio-tests/results/skill-test-spec-[name]-[date].md`
并更新 `studio-tests/catalog.yaml` 吗？”

若是：
- 将结果文件写入 `studio-tests/results/`
- 更新 `studio-tests/catalog.yaml` 中技能或 agent 的条目：
  - `last_spec: [date]`
  - `last_spec_result: PASS|PARTIAL|FAIL|NOT ASSESSED` — 即 Overall Verdict

---

## Phase 2D: Category 模式 — 评分量规评估

### Step 1 — 定位技能与类别

使用 Phase 1 中解析出的技能或 agent 文件。
在 `studio-tests/catalog.yaml` 中查找其 `skills:` 或 `agents:` 条目上的 `category:`
字段。

若两个文件都不存在：使用 Phase 1 的消息。
若没有 `category:` 字段：“catalog.yaml 中未为 ‘[name]’ 分配类别。
先在其条目中添加 `category: [name]`。”

对于 `category all`：收集每个带 `category:` 字段的技能和 agent
并逐一处理，技能和 agent 分别在两个表中报告。
`category: utility` 的技能仅按 U1（静态检查通过）和 U2
（质量闸门模式正确，若适用）评估 — U1 跳到 static 模式。
对照 `.trae/skills/*/SKILL.md` 和 `.trae/agents/*.md`
交叉检查（Audit 模式的 Step 2 glob）：按名称列出任何未在 catalog 中的技能或 agent，
或已编目但没有 `category:` 的，标记为 **NOT ASSESSED** — 绝不悄悄
排除在运行之外。

### Step 2 — 读取评分量规章节

读取 `studio-tests/quality-rubric.md`。
提取与该类别匹配的章节（例如 `### gate`、`### team`；agent 的类别
在 `## Agent Categories` 下，例如 `### director`）。
若评分量规中没有该类别的章节，结果为 **NOT ASSESSED**：
指明缺失的章节，绝不借用其他类别的指标。

### Step 3 — 读取技能

完整读取技能的 `SKILL.md` 及其 `references/` 文件夹中的每个文件，或
agent 的 `.trae/agents/[name].md`，
以及 Phase 2B Step 3 描述的项目上下文 — 由
`AGENTS.md` 或其导入文件中的规则满足的指标即算满足，并引用该文件。其针对
重定向与升级用例的规则也决定领域、推迟和升级
指标（D2、D3、L2、S1–S3、O2）。

### Step 4 — 评估评分量规指标

对类别评分量规表中的每个指标：
1. 检查技能或 agent 的书面说明是否清楚地满足该标准
2. 标记 PASS、FAIL、WARN 或 NOT ASSESSED（该指标无法评估 — 说明原因）
3. 对于 FAIL/WARN/NOT ASSESSED，指出文本中的确切缺口（引用
   相关章节、注明其缺失，或指明无法评估的内容）

### Step 5 — 输出报告

对于 agent，表头为 `=== Agent Category Check: [name] ([category]) ===`。

```
=== Skill Category Check: /[name] ([category]) ===

Metric G1 — Review mode read:      PASS
Metric G2 — Director panel width:  FAIL
  Gap: Phase 3 spawns only CD-PHASE-GATE at `workflow: full`; TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE absent
Metric G3 — Lean mode: PHASE-GATE only: PASS
Metric G4 — Solo mode: no directors:    PASS
Metric G5 — No auto-advance:       PASS

Verdict: FAIL (1 failure, 0 warnings)
Fix: Size the Phase 3 panel from `modes.workflow` — PR at `minimal`, TD + PR at
     `standard`, all four at `full` — and name any perspective a narrower panel leaves out.
```

类别结论按首个匹配优先：任何指标失败时为 **FAIL**；否则
任何指标警告时为 **WARNINGS**；否则任何指标无法
评估（评分量规章节缺失、文件无法读取）时为 **NOT ASSESSED**；否则
所有指标通过时为 **PASS** — 与 static 和 spec 模式相同的排序。它就是
catalog 中的 `last_category_result`。

### Step 6 — 提供更新 Catalog

“我可以更新 `studio-tests/catalog.yaml`，为 [name] 记录本次类别检查
（`last_category`、`last_category_result`）吗？”

---

## Phase 2C: Audit 模式 — 覆盖率报告

### Step 1 — 读取 Catalog

读取 `studio-tests/catalog.yaml`。若缺失，注明 catalog 尚不存在
（首次运行状态）。

### Step 2 — 枚举所有技能和 Agent

Glob `.trae/skills/*/SKILL.md` 获取完整的技能列表。
从每个路径（目录名）提取技能名称。

Glob `.trae/agents/*.md` 获取完整的 agent 列表 — 仓库本身，
而非 catalog，才是被覆盖集合（`.trae/rules/skill-authoring.md` §5：
质量闸门从被覆盖集合推导，而非枚举它）。将两个 glob 的结果
与 catalog 的 `skills:`/`agents:` 条目比较，并按名称报告任何
未在 catalog 中的技能或 agent，这样未编目的就不会悄悄漏掉。

### Step 3 — 构建技能覆盖率表

对每个技能：
- 检查规格文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `studio-tests/skills/*/[name].md`）
- 从 catalog 查找 `last_static`、`last_static_result`、`last_spec`、`last_spec_result`、
  `last_category`、`last_category_result`、`category`（若不在 catalog 中则标记为
  “never” / “—”）
- 优先级来自 catalog 的 `priority:` 字段（critical/high/medium/low）

### Step 3b — 构建 Agent 覆盖率表

对 catalog `agents:` 章节中的每个 agent：
- 检查规格文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `studio-tests/agents/*/[name].md`）
- 从 catalog 查找 `last_spec`、`last_spec_result`、`last_category`、
  `last_category_result`、`category`

### Step 4 — 输出报告

```
=== Skill Test Coverage Audit ===
Date: [date]

SKILLS (74 total)
Specs written: 73 (99%) | Never static tested: 74 | Never category tested: 74

Skill                  | Cat      | Has Spec | Last Static | S.Result | Last Cat | C.Result | Priority
-----------------------|----------|----------|-------------|----------|----------|----------|----------
gate-check             | gate     | YES      | never       | —        | never    | —        | critical
design-review          | review   | YES      | never       | —        | never    | —        | critical
...

AGENTS (49 total)
Agent specs written: 49 (100%)

Agent                  | Category   | Has Spec | Last Spec   | Result | Last Cat | C.Result
-----------------------|------------|----------|-------------|--------|----------|----------
creative-director      | director   | YES      | never       | —      | never    | —
technical-director     | director   | YES      | never       | —      | never    | —
...

Top 5 Priority Gaps (skills with no spec, critical/high priority):
(none if all specs are written)

Skill coverage:  73/74 specs (99%)
Agent coverage:  49/49 specs (100%)
```

Audit 模式下不写入任何文件。

提供：“你想运行 `/skill-test static all` 来检查所有技能的
结构合规性吗？`/skill-test category all` 来运行分类评分量规
检查？或 `/skill-test spec [name]` 来运行特定的行为测试？”

---

## Phase 3: 建议的下一步

任何模式完成后，提供与上下文相关的后续建议：

- 在 `static [name]` 之后：“若存在测试规格，运行 `/skill-test spec [name]` 来验证行为
  正确性。”
- 在带失败的 `static all` 之后：“先处理 NON-COMPLIANT 技能。对每个技能单独运行
  `/skill-test static [name]` 以获取详细的修复指导。”
- 在 `spec [name]` 通过之后：“更新 `studio-tests/catalog.yaml` 记录本次
  通过日期。考虑运行 `/skill-test audit` 以找到下一个规格缺口。”
- 在 `spec [name]` 失败之后：“审查失败的断言，并更新技能
  或 agent，或测试规格，以解决不匹配。”
- 在 `audit` 之后：“从 critical 优先级的缺口开始。使用
  `studio-tests/templates/skill-test-spec.md` 的规格模板（agent 用：
  `agent-test-spec.md`）创建新规格。”