# Phase 2: 当 ADR 或清单在故事编写后发生变化

仅在 Phase 2 发现版本不匹配时阅读。

## ADR

ADR 的 `version`（来自 `adr-status.sh`：其 Last Verified 日期，否则其 Date，
否则 `unversioned`）与故事的 `ADR Version` 不同，或 ADR 为
`unversioned` 而故事指定了日期。其决策可能已经改变。

询问：“Story was written against ADR v[story date]. The ADR is now v[current].
How do you want to go on?” 选项：

- **Re-read the changed ADR and refresh the story (Recommended).** 使用
  `bash .trae/scripts/md-section.sh extract <adr> "Decision"` 读取 ADR 的
  Decision、Engine Compatibility 和 ADR Dependencies 章节，另外两个同样处理。
  然后编辑故事：`ADR Version` 变为 ADR 的 `version`
  （绝不是今天的日期，否则下次运行又会不匹配），并且 ADR Decision
  Summary 和 `## Implementation Notes` 会被替换为你读到的指导。
  程序员的简报携带新指导，绝不携带旧总结。
- **Implement from the story's summary — I accept the drift.** 简报携带
  总结，并告诉 agent 它早于当前 ADR。在 Deviations 下注明。
- **Stop — I want to review the ADR first.** 不运行 agent。

## 控制清单

故事的 `Manifest Version` 与清单的不同。新规则可能适用。

询问：“Story was written against manifest v[story date]. The current manifest is
v[current]. How do you want to go on?” 选项：

- **Update the story's manifest version and use the current rules (Recommended).**
  把故事的 `Manifest Version` 设为当前日期，然后阅读该层的
  规则以供简报使用。
- **Use the old rules — I accept the risk.** 把 `Manifest Version` 设为当前
  日期，并在故事头部添加 `Manifest-Note: Proceeded with old manifest rules on [date] —
  non-compliance risk accepted.`。在 Deviations 下注明；
  `/story-done` 会把该笔记带入其偏离项。
- **Stop — I want to review the manifest first.** 不运行 agent。

每个选项都点明它对故事所做的编辑，因此选择它本身就是询问。
