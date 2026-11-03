# 自动化模式 — 共享技能模式

本文档为每个使用 `AskUserQuestion` 或写文件的技能定义标准的 `modes.automation` 模式。技能引用本文档，而不是内联嵌入完整的模式处理规则——这样当模式需要更新时，可以消除偏差。

**范围**：68 个技能，涵盖创作、评审、团队编排、实现和工具类。任何通过 `AskUserQuestion` 对决策进行质量闸门（gate）控制、或写文件的技能，都应遵循此模式。

**配套规格**：`.trae/docs/effects-map.md` 的 `modes.automation` 节是行为的唯一事实来源。本文档是实现模式。

> **不要在技能运行期间阅读 `effects-map.md`** —— 它是一个非常大的文件，是编写规格的参考资料，而非运行时输入，并且**本文档自给自足**，足以决定该问什么、该继续做什么。
> 如果某个情况确实未在此覆盖，只读它的 `modes.automation` 节，绝不要读整个文件。

---

## 如何使用本文档

在任何技能中，在启动时添加一个解析步骤，并在每个受闸门控制的位置引用下面这个能识别模式的 AskUserQuestion 模式。

**启动前置步骤**（添加在 Phase 0 / Phase 1 附近）：

```
Resolve automation mode (once, store for the run):
1. Read `modes.automation` from `project.local.yaml` (if present) → use that
2. Else read `modes.automation` from `project.yaml` → use that value
3. Else → default to `collaborative`

Pattern reference: `.trae/docs/automation-modes.md`.
```

该解析通过 `get_effective_yaml_key modes.automation` 自动完成——该辅助函数会把 project.local.yaml 深度合并到 project.yaml 之上。

**在每个 AskUserQuestion 位置**，遵循下文 §通用规则 中的模式表。技能作者把每个决策标记为 **major**（重大）或 **minor**（次要）（依据 §重大与次要 中的分类矩阵），以便模式应用正确的规则。

---

## 三种模式

| 模式 | 速度 | 控制 | 变化内容 |
|------|-------|---------|--------------|
| `collaborative` | 最慢 | 完全——每个决策都由用户决定 | 默认。严格遵循 Q→O→D→Draft→Approval。 |
| `guided` | 平衡 | 高——重大决策由用户决定，次要决策自动继续 | AI 说明建议，并对次要决策继续推进。AskUserQuestion 仅保留给重大决策。 |
| `autonomous` | 最快 | 低——AI 决定、记录并继续 | 不使用 AskUserQuestion（`automation_always_ask` 类别除外）。所有决策均记录。 |

**默认**：`collaborative`。新项目从此开始。

**设置方式**：`/start`、`/settings`。

---

## 各模式的通用规则

### Collaborative（当前 v1.0 行为——无变化）

- 每个多选项决策都调用 `AskUserQuestion`
- 每个设计选择都提供 2–4 个选项，并附优缺点说明
- 每次写文件前都展示完整草稿并请求批准
- 每次写入前都询问 "May I write this to [filepath]?"
- 多节创作技能中逐节批准
- 多文件变更需要明确批准

### Guided

- 仅对**重大决策**调用 `AskUserQuestion`（见下方分类）
- 次要决策：AI 内联说明建议并继续推进——例如
  > *"此处采用静态工具模式——它契合现有架构。除非你想改变方向，否则继续。"*
- 对现有文件的更新：写入前简要展示草稿——短暂总结后即继续，不等待明确的 "yes"
- 仅对**新文件**询问 "May I write?"，新文件会等待回答——对现有文件的更新直接继续
- 重大决策仍展示选项，但上限为 2 个选择，并附明确建议
- 多节创作：立即写入每个已批准的节，不逐节确认

### Autonomous

- 不调用 `AskUserQuestion`，**除非**属于 `modes.automation_always_ask` 中列出的类别
- 不做草稿评审
- 不出现 "May I write?" 提示——直接写入
- 对每个决策选择推荐选项，不展示备选方案
- 所有决策通过 `log_decision`（yaml-helper.sh 中的辅助函数）记录到
  `production/session-logs/decision-log.md`
- 用户在会话结束后查看决策日志，以审计所做选择

### 每种模式：没有回答的问题

一个返回为**跳过、关闭或空**的问题不是回答，在每种模式和每个工具上都如此：用户关闭了该问题、无头运行把每个问题都返回为跳过、或者回复中什么都没选。

- 不要写文件、不要更改模式或设置、也不要代其选择选项。
- 用纯文本再次询问，说明在等待什么回答，然后等待。
- 在 `autonomous` 中，模式不要求的问题可以照常决定：选择推荐选项并通过 `log_decision` 记录。属于 `automation_always_ask` 类别的问题，或属于豁免技能的问题，是用户的：再次询问并等待。
- 在无人能回答的情况下（CI、无头运行），停止并报告正在等待什么，而不是替其选择。

---

## 重大与次要决策分类

技能在应用模式规则之前，把每个受闸门控制的决策标记为 **major**（重大）或 **minor**（次要）。

### 重大——guided 模式下始终使用 AskUserQuestion

| 决策类型 | 示例 |
|---------------|---------|
| 选择系统名称或文档路径 | "What should we call this system?" |
| 互斥的设计方向 | "Real-time or turn-based?" |
| 任何制约下游工作的选择 | 引擎选择、架构方案 |
| 范围变更 | "Cut this feature or slip the deadline?" |
| 任何不做大量返工就无法更改的决策 | 核心循环机制 |

### 次要——guided 模式下由 AI 推荐并继续

| 决策类型 | 示例 |
|---------------|---------|
| 接下来处理哪个小节 | "Moving to Edge Cases next" |
| 可选小节的纳入 | "Adding a Visual Notes section — fits the system" |
| 格式与结构选择 | 标题层级、表格与散文 |
| 为已确定的方向补充细节 | 已批准方案下的子选项 |
| 阶段完成后的下一步路由 | "Running design-review now" |

---

## `automation_always_ask` 类别

即使在 `autonomous` 模式下，某些决策类别也**始终**触发
`AskUserQuestion`。配置的列表位于 `project.yaml` 中的
`modes.automation_always_ask`。

**默认**（未设置时）：`[scope_changes, file_deletions, schema_changes]`。

### 可识别的类别

**此表是你可以配置的集合，而不是始终询问的集合。** 只有实际列在 `modes.automation_always_ask` 中的类别——即上述三个默认类别，除非项目覆盖它们——才会中断 `autonomous` 运行。其他行在项目选择启用之前不起作用。用 `resolve_config` 读取已解析的列表，而不是假设此处某行处于激活状态。把项目从未配置过的类别（例如 `architecture_decisions`）当作激活状态，会报告项目从未要求的规则违规。

| 类别 | 该类别中的决策示例 |
|----------|----------------------------------------|
| `scope_changes` | 砍掉功能、推迟截止日期、拆分/合并史诗、移除验收标准 |
| `file_deletions` | 移除用户故事、删除 GDD、移除系统、移除测试文件 |
| `schema_changes` | 对 project.yaml、story 模板、control manifest、ADR 模板、GDD 模板的变更 |
| `architecture_decisions` | 新建 ADR、替换 ADR、系统边界变更 |
| `version_bumps` | 引擎版本变更、框架版本升级、依赖主版本变更 |
| `external_calls` | 在 autonomous 模式下调用外部 API（资源生成、AI 服务） |

### 辅助函数

```bash
is_always_ask_category <category>
```

如果指定类别在 `modes.automation_always_ask` 中，返回 0，
否则返回 1。技能在落入上述六个类别中任一类的决策点使用它。

---

## 豁免——忽略自动化设置的技能

这些技能无论设置如何，始终表现为 `collaborative`：

| 技能 | 为何始终协作 |
|-------|--------------------------|
| `hotfix` | 紧急决策——用户必须在任何行动前批准范围和风险 |
| `gate-check` | 结果必须经过评审——未经确认的闸门结论违背了其目的 |
| `day-one-patch` | 发布关键——每个操作都需要明确签署 |
| `setup-engine` | 影响整个项目的一次性不可逆选择 |

这些技能**不**添加上述自动化前置步骤。它们完全保留
v1.0 的 Q→O→D→Draft→Approval 协议。

---

## 决策日志格式（autonomous 模式）

当 `autonomous` 模式跳过某个 `AskUserQuestion` 时，技能调用
`log_decision` 写入结构化条目。每个条目的格式：

```markdown
## [timestamp] — [skill-name]

**Decision point:** [what was being decided]
**Options considered:** [list of options that would have been presented]
**Chosen:** [what was picked]
**Reason:** [one-line rationale]
**Category:** [scope_changes | file_deletions | schema_changes | … or "minor"]
```

写入 `production/session-logs/decision-log.md`（仅追加，绝不截断，
不存在时创建）。用户在会话结束后查看日志，以审计所做选择。

### 辅助函数

```bash
log_decision "<skill-name>" "<decision-point>" "<options>" "<chosen>" "<reason>" "<category>"
```

封装上述格式。技能在 autonomous 模式的每个决策点调用它，
包括所选值与推荐默认值不同的情况（以便审计跟踪完整）。

### 记录什么，以及以什么粒度

这些规则让 autonomous 日志在各次运行之间保持一致：

- **记录每个本应显示 `AskUserQuestion` 组件的决策**——
  包括选项/措辞选择，而不仅是最终批准。措辞/选项决策
  （哪个方案、哪个公式、哪些边界情况）通常是最有信息量的条目；
  不要只记录机械的 "approve this section" 步骤。
- **把单个多标签页组件折叠为一条记录。** 在 **Chosen** 下列出每个标签页的
  选择，而不是每个标签页发一条记录。
- **不要记录模型为自己合成的对话式回答**
  （例如起草某节时的内部问答）——只记录本应是显式用户决策的内容。
- **不要为常规的 "may I write?" 文件闸门单独发记录**——
  把写入折叠进它所实现的决策（autonomous 模式本来就直接写入）。

### 对数据文件写入进行分类

最常见的分类错误是把数据文件追加当作
`schema_changes` 决策：

- **向注册表或索引追加事实**——例如
  `design/registry/entities.yaml`、`design/gdd/systems-index.md`——属于
  **`minor`**。它添加数据，不改变*模板*。
- **`schema_changes`** 指编辑 `project.yaml` 或某个
  模板（story / ADR / GDD / control-manifest 模板）的*结构*。这些始终询问。
- **当确实不确定**是 `minor` 还是某个始终询问类别时，
  优先选择始终询问类别并提示——故障安全。

---

## 技能在每个 AskUserQuestion 位置应用的模式

```
At each decision point in this skill:

1. Classify the decision: major or minor (see §Major vs Minor above).
2. Check whether the decision falls into an `automation_always_ask`
   category: scope_changes, file_deletions, schema_changes,
   architecture_decisions, version_bumps, external_calls.
3. Apply the mode rule:

   collaborative:           AskUserQuestion always.
   guided + major:          AskUserQuestion with capped options + recommendation.
   guided + minor:          State recommendation inline, proceed.
   autonomous + always_ask: AskUserQuestion (regardless of mode).
   autonomous + other:      Pick recommended, log via log_decision, proceed.
4. If the question comes back skipped, dismissed or empty, it is not an
   answer: see §Every mode: a question with no answer.
```

这就是契约。遵循此模式的技能在全部三种自动化模式下产生
一致的行为。
