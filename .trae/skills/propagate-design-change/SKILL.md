---
name: propagate-design-change
description: "查找因 GDD 变更而失效的架构决策（ADR），并逐一引导处理。当用户改动了 GDD 中的某个数字或规则、并询问哪些 ADR 或架构决策现在已过时，使用本技能。"
argument-hint: "[path/to/changed-gdd.md] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Bash(bash "*/.claude/skills/propagate-design-change/../../hooks/yaml-helper.sh" resolve_config *), Bash(git diff *), Bash(git log *), Bash(bash .claude/scripts/adr-status.sh*), Bash(bash .claude/scripts/md-section.sh *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation,automation_always_ask,workflow,system_overrides`

以上已解析 —— 直接使用；本次运行中 `--review` 会覆盖 `review_mode`。没有对应配置块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

使用提问工具发问。若没有该工具，将选项编号列出，并结束本轮以等待回答。跳过或关闭的问题
不算回答：请改用纯文本再次提问。

# 传播设计变更

当 GDD 发生变更时，依据它编写的架构决策可能不再成立。本技能会找出该变更涉及的每一个
ADR，比对 ADR 当时的假设与 GDD 现在的表述，并逐一引导用户处理。

**示例：** `/propagate-design-change design/gdd/combat-system.md`

所有提问遵循 `.claude/docs/automation-modes.md`（collaborative 总是询问，guided 仅在重大
选择时询问，autonomous 记录后继续；`automation_always_ask` 类别总是询问：此处的 ADR 影响
属于 `schema_changes` 与 `architecture_decisions`）。

**层级。** 取被变更 GDD 所属系统的 `workflow`：若有 `system_overrides` 行则用该行，否则
用项目值。被固定为 `minimal` 的系统，即使在 `standard` 项目上也没有 ADR。`full` 检查每一个
ADR；`standard` 检查关键的（Foundation 层）ADR 以及任何点名了被变更 GDD 的 ADR；`minimal`
没有可检查的内容（Phase 4）。

## Phase 1: GDD 路径

技能名之后输入的文字，去掉其中任何 `--review <mode>` 对，即为被变更的 GDD。该参数必填。
缺失时："用法：`/propagate-design-change design/gdd/[system].md` —— 请给出发生变化的那份
GDD 的路径。"不是文件时："未找到 [path]。请检查路径后重试。"

## Phase 2: 变更内容

向 git 求证，绝不凭肉眼比对两份完整文档：

```bash
git diff HEAD -- design/gdd/[filename].md
```

结果为空：变更可能已经提交，因此扩大到最近一次触及它的提交：`git diff HEAD~1 HEAD -- design/gdd/[filename].md`。

- 完全没有历史（`git log --oneline -1 -- design/gdd/[filename].md` 无输出）："git 中没有
  旧版本 —— 这是一份新的 GDD，而非修订版。无可传播的内容。"然后停止。
- 有历史，但两次 diff 都为空：报告"`[file]` 没有未提交或最近一次提交的变更"，并询问要传播
  哪个修订版。空 diff 意味着*此处*没有变化，而非没有任何内容受影响。

从各个 hunk 看：`@@` 头部标出了每处变更所在的章节，因此变更章节列表直接来自 diff 本身。
没有 hunk 的章节按构造即未变更。仅当某个 hunk 无法单独理解时（例如改动的数字，其含义依赖
于它上方的规则）才读取周边章节，且只读该章节：`bash .claude/scripts/md-section.sh extract design/gdd/[file].md "[Section]"`。

## Phase 3: 变更摘要

```
## Change Summary: [GDD filename]
Date of revision: [today]

Changed sections:
- [Section]: [what changed — new rule, removed rule, formula modified, …]

Unchanged sections:
- [Section]

Key changes affecting architecture:
- [change likely to affect ADRs]
```

**其他使用这些事实的 GDD。** 当 `design/registry/entities.yaml` 不存在或没有条目时（在
`/design-system` 填充之前，它以空存根形式随项目提供），跳过此项；下方的 ADR 检查仍会运行。
否则，它记录了哪些 GDD 依赖本系统的事实：在其中搜索 `source: design/gdd/[filename]`。对于
本 GDD 所拥有、且其值被 diff 改动的每个实体、常量或公式，其 `referenced_by:` 列表指出了
那些现在可能产生分歧的 GDD。把它们列在"需复查的下游 GDD"下。

## Phase 4: 范围内的 ADR

`bash .claude/scripts/adr-status.sh` 会列出每个 ADR 及其状态、层与缺失章节。

- **`full`：** 每一个 ADR。
- **`standard`：** 关键的那些（`layer` 列为 Foundation，或没有层：存疑时按关键处理）以及
  任何点名了被变更 GDD 的 ADR。
- **`minimal`：** 报告"minimal 工作流下不做 ADR 检查 —— 设计变更已记录；无架构影响分析。"
  停止。

先确定分母：它们的数量为 **N**。N 为 0 时："`docs/architecture/` 中未找到 ADR —— 无可检查
的内容。"停止。

**哪些引用了本 GDD。** 无需通读整个 ADR：

1. 每个 ADR 的 GDD Requirements Addressed 章节
   （`bash .claude/scripts/md-section.sh extract <adr> "GDD Requirements Addressed"`），
   查找点名了被变更 GDD 的行；
2. 在所有 ADR 中搜索被变更 GDD 的文件名，以捕获在正文中引用它、却没有表格行的 ADR。

两者的并集即为受影响集合 **M**。

| 结果 | 含义 | 操作 |
|---|---|---|
| **M ≥ 1** | 正常。 | 继续。另外 N − M 个不在本次检查范围内：绝不可把它们描述为"已验证未受影响"。 |
| **M = 0**，且所有范围内 ADR 都缺少 GDD Requirements Addressed（`missing` 列） | 无法计算可追溯性。 | "[N] 个 ADR，均无 'GDD Requirements Addressed' 章节 —— 无法计算可追溯性（pre-production 质量闸门的阻塞项）。运行 `/architecture-decision retrofit [adr]`。"停止。 |
| **M = 0**，且这些章节存在 | 没有 ADR 引用本 GDD。 | "没有 ADR 引用 [gdd] —— 无架构影响。"停止。 |

当 `docs/architecture/requirements-traceability.md` 存在时读取它。

报告："已检查 [N] 个 ADR。[M] 个引用了 [gdd filename]（[X] 个在需求表中，[Y] 个仅在正文中）。"

## Phase 5: 影响分析

对 **M** 中的每个 ADR，用 `md-section.sh extract` 读取其 Context、Decision 与 Consequences
章节：判断某个决策是否仍然成立，需要它的推理过程，绝不能只看表格行。然后，针对它列出的
每条来自被变更 GDD 的需求：

1. 该需求在当前 GDD 中是否仍然存在？
2. ADR 编写时 GDD 是怎么说的，现在又是怎么说的？
3. 该决策是否仍然成立？

对每个 ADR 分类：

| 状态 | 含义 |
|--------|---------|
| ✅ **Still Valid** | 变更未触及本 ADR 所决定的内容 |
| ⚠️ **Needs Review** | 变更可能影响它；需要人工判断 |
| 🔴 **Likely Superseded** | 变更与本 ADR 所假设的内容相矛盾 |

```
### ADR-NNNN: [title]
Status: [Still Valid | Needs Review | Likely Superseded]

What the ADR assumed about this GDD:
  "[quote from its GDD Requirements Addressed or Context]"

What the GDD now says:
  "[quote from the current GDD]"

Assessment:
  [whether the decision still holds, and why]

Recommended action:
  [Keep as-is | Review and update | Mark Superseded and write a new ADR]
```

## Phase 6: 影响报告，然后是评审

在请求任何操作之前，先展示完整报告：

```
## Design Change Impact Report
GDD: [filename]
Date: [today]
Changes detected: [N sections changed]
ADRs referencing this GDD: [M]

### Not Affected
[ADRs whose decisions still hold]

### Needs Review ([count])
[ADRs that may need updating]

### Likely Superseded ([count])
[ADRs whose assumptions the change contradicts]
```

**技术评审。** 读取上方的 `review_gate` 行。`skill-gates=skip`（solo 或 lean）：不调用
agent；注明 `TD-CHANGE-IMPACT skipped — [Solo | Lean] mode`。`skill-gates=run`：将评审交给
`technical-director` agent，质量闸门为 **TD-CHANGE-IMPACT**（`.claude/docs/director-gates/td-change-impact.md`；
该 agent 会自行读取该文件）。简报：

- **目标：** 在用户据此行动之前，检查影响报告。
- **提供给它：** 上面的完整报告：变更摘要、每个受影响 ADR 及其分类与建议操作。
- **检查：** 没有 ADR 被过度低估；建议操作合理；没有遗漏对其他 ADR 或系统的连带影响。
- **返回：** APPROVE、CONCERNS、REJECT，或指出缺失输入的 NOT ASSESSED。
- **边界：** 它不编辑任何文件。

根据结论行动：

- **APPROVE：** 进入 Phase 7。
- **CONCERNS：** 展示被标记的 ADR 或操作，并询问："你希望如何继续？"选项：修订影响评估 /
  带已知关注项接受 / 进一步讨论。
- **REJECT：** 不要进入 Phase 7；先重新分析影响。
- **NOT ASSESSED：** 这不是批准（`.claude/docs/director-gates.md`）。指出缺失了什么，然后
  补齐并重新运行评审；或者，当用户选择在没有它的情况下继续时，进入 Phase 7，并在报告与
  最终结论行中注明 `TD-CHANGE-IMPACT: NOT ASSESSED — [input]`。

## Phase 7: 逐个处理 ADR

对每个标记为 Needs Review 或 Likely Superseded 的 ADR，逐一询问："ADR-NNNN
（[title]）—— [status]。你希望如何处理？"选项：

- 标记为 Superseded（由我编写新的 ADR）
- 就地更新（小幅修订）：说明要修订什么；由用户自行编辑
- 保持原样（该变更不影响此决策）
- 暂时跳过（稍后再看）

**标记为 Superseded。** 询问"我可以把 [ADR file] 的 Status 设为 Superseded 吗？"若同意，
只替换其 `## Status` 章节的正文：

```
bash .claude/scripts/md-section.sh replace docs/architecture/[adr-file].md "Status" <<'EOF'
Superseded — replacement pending (see docs/architecture/change-impact-[date]-[system-slug].md)
EOF
```

这是本技能唯一会写入的形式。`adr-status.sh` 会将其读作 Superseded，因此 `/dev-story` 与
`/create-stories` 会阻塞那些仍然指向它的用户故事。新 ADR 写好后，会记录它替代了哪一个。
不要改动 ADR 中的其他内容：其正文保持不变。

## Phase 8: 可追溯性索引

当 `docs/architecture/requirements-traceability.md` 存在时，询问"我可以把变更后的需求加入
可追溯性索引吗？"若同意，为每条变更需求添加一行：

```markdown
## Superseded Requirements
| Date | GDD | Requirement | Changed To | ADRs Affected | Resolution |
|------|-----|-------------|------------|---------------|------------|
| [date] | [gdd] | [old requirement text] | [new requirement text] | ADR-NNNN | [Superseded/Updated/Valid] |
```

## Phase 9: 变更影响文档

询问"我可以把变更影响报告写入
`docs/architecture/change-impact-[date]-[system-slug].md` 吗？"该文档包含变更摘要、影响分析、
每个 ADR 所选择的处理方式，以及需要编写或更新的 ADR。

## Phase 10: 后续操作

根据处理结果：

- 标记为 Superseded 的 ADR："运行 `/architecture-decision [title]` 编写替代文档，然后再次
  运行 `/propagate-design-change` 检查覆盖情况。"
- 需要就地更新的 ADR：列出每个 ADR 中要修改的字段。
- 受影响 ADR 较多时："更新完成后运行 `/architecture-review`，检查可追溯性矩阵是否仍然自洽。"

在 Phase 9 写入之后以 `Verdict: COMPLETE — change impact report saved` 结束；若用户拒绝写入，
则用 `Verdict: BLOCKED — user declined the write`。
