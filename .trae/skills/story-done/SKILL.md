---
name: story-done
description: "关闭已完成的用户故事：逐条验证验收标准，检查设计或 ADR 偏差并更新其状态。当用户说某个用户故事已完成、做完了或可以关闭时使用。"
argument-hint: "[story-file-path] [--review full|lean|solo]"
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Agent, Bash(bash "*/.claude/skills/story-done/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/story-facts.sh *), Bash(bash .claude/scripts/story-status.sh*), Bash(bash .claude/scripts/adr-status.sh *), Bash(bash .claude/scripts/md-section.sh *), Bash(bash .claude/scripts/review-receipts.sh check *), Bash(bash .claude/scripts/session-state.sh *), Bash(git status --porcelain*)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation,automation_always_ask,workflow,qa.level,gate_level,system_overrides`

以上为解析结果 — 直接使用；`--review` 会覆盖 `review_mode`。无块 → 使用 `.claude/docs/config-resolution.md` 中的默认值。

用提问工具询问。没有提问工具时，将选项编号列出并结束回合等待。跳过或忽略的提问不是回答：用纯文本再问一次。

# 用户故事完成

关闭一个已完成的用户故事。每条验收标准都会对照证据进行检查，与 GDD、ADR 以及用户故事自身范围的偏差都会作为事实报告，并且只有在用户确认"是"之后才把用户故事标记为 Complete。

**写入（在用户确认"是"之后）：** 用户故事文件（`Status`、`Last Updated`、一个 `## Completion Notes` 章节）及其 `production/sprint-status.yaml` 条目；仅当用户选择该选项时才写入 `docs/tech-debt-register.md`。会话检查点会在每次运行结束时写入，无论结论如何。
**下一步：** 下一个用户故事（Phase 8）。

询问遵循 `.claude/docs/automation-modes.md`（collaborative 始终询问，guided 仅在重大选择时询问，autonomous 记录后继续；`automation_always_ask` 类别始终询问）。

检查清单（复制它并随进度勾选）：

```
- [ ] Phase 1: story found, facts and settings read
- [ ] Phase 2: what the story is checked against, loaded for its tier
- [ ] Phase 3: each criterion verified, traceability table built
- [ ] Phase 4: test evidence and run result checked
- [ ] Phase 5: deviations and scope checked
- [ ] Phase 6: review gates run, or their skip noted
- [ ] Phase 7: report and verdict shown; close asked
- [ ] Phase 8: next story named, checkpoint written, closing block printed
```

## Phase 1: 用户故事及其设置

**哪个用户故事。** 在技能名之后输入的文本，移除任何 `--review <mode>` 对之后，就是用户故事路径。若什么都没输入：

1. `production/session-state/active.md` 中的检查点：其 **Current task** 行，当其指明某个用户故事时。
2. 否则是进行中的用户故事：`bash .claude/scripts/story-facts.sh --all`，状态为 `IN_REVIEW` 或 `IN_PROGRESS` 的行。若有多个：询问"Which story are we closing?"，每个用户故事一个选项。
3. 没有：询问路径。当 `production/epics/` 完全没有用户故事文件时，停止：
   "No stories found in `production/epics/` — run `/create-stories [epic-slug]` to make them (at `standard` and `full`, run `/create-epics` first if there is no epic yet)."

**其事实。** `bash .claude/scripts/story-facts.sh <story-path>` 给出状态、类型、层级、TR-ID、ADR、标准数量、测试证据状态和依赖。然后完整读取用户故事：标准文本、Test Evidence 路径、`## Files`、Out of Scope。

**层级。** 用户故事所属系统的 `workflow`，以其 `GDD:` 路径的 GDD 文件名主干为键（`design/gdd/<stem>.md` → `<stem>`；仅当没有 GDD 路径时，才用其 TR-ID 的 `[system]`）：若存在该系统的 `system_overrides` 行则用该行，否则用项目值。

**`qa.level` 要求什么**（`.claude/docs/coding-standards.md` 的证据行）。从上面的 `qa.level` 行取值，绝不从 `workflow` 或 `rigor` 取值：两者是分开设置的，因此 `workflow: minimal` 搭配 `qa.level: standard` 仍然要求 Logic 用户故事的单元测试。

| 检查项 | `qa.level: minimal` | `qa.level: standard` | `qa.level: full` |
|---|---|---|---|
| Logic、Integration 测试 | 豁免 | 必需 | 必需 |
| Config/Data 冒烟报告 | 豁免 | 必需，默认建议性 | 必需，默认**阻塞** |
| Visual/Feel、UI 保留截图 | 必需 | 必需 | 必需 |
| 未测试标准（Phase 3） | 从不升级 | 超过一半则阻塞 | **任何一条**都阻塞 |

外观从不豁免：Visual/Feel 或 UI 用户故事在每个层级都需要其截图。各类型的**闸门级别**是上面的 `gate_level` 行。在 `full` 下，Config/Data 的默认值（`config=advisory(default…)`）变为阻塞；显式的 `testing.strict.config: false` 仍使其为建议性。

## Phase 2: 用户故事对照什么来检查

按层级。按章节读取每个文档，绝不整篇读取。

- **`full`：** 每个 TR-ID 的当前需求文本：在 `docs/architecture/tr-registry.yaml` 中匹配 `id: <TR-ID>\s*$` 的行及其下的条目文本（锚点可防止 `TR-combat-001` 匹配到 `TR-combat-0010`；`\s*` 兼容 Windows 行尾）。绝不要使用用户故事中引用的文本；GDD 的 Acceptance Criteria 与 Detailed Design（`bash .claude/scripts/md-section.sh extract design/gdd/<file>.md "Acceptance Criteria"`，然后对 `"Detailed Design"` 做同样操作；退出 3：改试 `"Detailed Rules"`，即设计标准对同一章节的命名）；每个 ADR 的状态用 `bash .claude/scripts/adr-status.sh <ADR ids>` 获取，然后读取其 Decision 与 Consequences 章节。
- **`standard`：** 相同的 GDD 章节；仅对关键 ADR 读取 ADR 章节（`adr-status.sh` 的 layer 列显示为 Foundation，或没有 layer）。
- **`minimal`：** 无。用户故事自己的标准就是规格。

在每个层级，当 `docs/architecture/control-manifest.md` 存在时，记下其 `Manifest Version` 行。

## Phase 3: 验证每条标准

依次处理每条验收标准：

- **通过查看核实：** 标准所指名的文件存在；它所指的测试文件存在（报告"test file present"，绝不报告"test passes"：此处不运行任何东西）；属于数据文件却出现在玩法代码中的数字字面量；属于本地化文件却出现在代码根目录中的面向玩家字符串（按 `.claude/docs/code-root-resolution.md` 解析代码根；无法解析时报告 `NOT ASSESSED — code root unresolved`，绝不要报零命中）。
- **通过询问核实：** 行为类标准（"玩家在……时受到伤害"）、手感类标准和性能类标准。绝不要通过阅读代码就把一条标记为通过：代码说明应该发生什么，而不是构建实际做了什么。每次询问最多四条："Does [criterion]?" 选项：Yes — passes / No — fails / Not tested yet。`Not tested yet` 是 UNTESTED，会让结论最多停留在 NOT ASSESSED，直到有人核实。
- **通过屏幕查看核实：** 关于可见内容的标准，由 `production/qa/evidence/[story-slug]/` 下你打开并实际看到其中内容的保留图片来覆盖（`[story-slug]`：用户故事文件名去掉 `.md`）。绝不要描述你没打开过的图片；检查点的 `Run result: OBSERVED — <text>` 是 `/dev-story` 的描述，引用时须如此注明。
- **需要完整试玩测试：** `DEFERRED — requires playtest session`。它不阻塞。

然后将每条标准映射到覆盖它的内容：测试根目录下的测试、"Yes — passes"，或一张保留图片。

```
| Criterion | Covered by | Status |
|-----------|------------|--------|
| AC-1: [text] | tests/unit/[system]/[file]::[test] | COVERED |
| AC-2: [text] | production/qa/evidence/[slug]/01-[what].png | COVERED |
| AC-3: [text] | — | UNTESTED |
```

未测试标准按 Phase 1 的表格升级：线上方为阻塞；线下方为建议性，并在 Completion Notes 中列为 "Untested criteria: [AC-N list]"。

## Phase 4: 测试证据与运行结果

按用户故事的类型，在 Phase 1 的闸门级别下。跳过 `qa.level` 豁免的检查，并说明：`Test evidence: waived at qa.level minimal`。

- **Logic：** 用户故事 Test Evidence 章节中的确切路径，否则在 `tests/unit/[system]/` 下任意位置查找。
- **Integration：** 在 `tests/integration/[system]/` 下同样查找，否则在 `production/qa/playtests/` 中查找指明本用户故事的试玩记录（`/playtest-report` 会将它们写入那里）。
- **UI：** UI 用户故事由所触碰每个屏幕的保留截图满足，位于 `production/qa/evidence/` 下。无需证据文档或签署确认。
- **Visual/Feel：** 截图，且 Visual/Feel 用户故事还需要签署确认：`production/qa/evidence/[story-slug]-evidence.md`，其中每一行签署确认均为 `[x] Approved`（一个人可以签署所有角色）。
- **Config/Data：** 一份 `production/qa/smoke-*.md` 报告；没有则："No smoke check report found. Run `/smoke-check`."
- **No Type：** 建议性："Story Type not declared. Add `Type:` to the story header."

缺失的项就是该闸门级别下的缺口：BLOCKING 阻止 COMPLETE，ADVISORY 写入注释。指出缺失什么以及它应放在哪里。旁边没有图片的证据文档不是证据：被描述的检查只是断言。

**证据是否比其代码更旧？** 对保留图片运行 `bash .claude/scripts/review-receipts.sh check production/qa/evidence/[story-slug]/stamp.txt`。每个 `CHANGED:` 或 `GONE:` 文件："[file] changed after the evidence was captured — re-capture it." `RECEIPT: NONE`："no stamp — whether the evidence is older than the code cannot be told"。报告这些行；它们绝不改变结论。

**运行结果，适用于所有其他类型。** 从 `/dev-story` 检查点（仅当其 **Current task** 指明本用户故事时）或用户故事的 Completion Notes 中取 `Run result:` 行。`OBSERVED` 且带路径：注明它。`N/A — <reason>`：只接受说明为何没有任何可观察内容的理由（"it's a Logic story"不是理由）。`NOT VERIFIED` 出现在标准涉及屏幕上内容的用户故事上：该闸门级别下的缺口。没有该行：建议性，"confirm the build was launched and looked at"。用户对屏幕类标准回答"Yes — passes"却没有保留图片，那是断言而非观察：该闸门级别下的缺口。

## Phase 5: 偏差与范围

按层级运行（`minimal` 跳过第 1 和第 3 项）：

1. **GDD 规则**（`full`；`standard` 仅在其必需章节）：在变更文件中搜索当前 GDD 文本和 TR 需求所使用的名称。
2. **清单：** 用户故事的 `Manifest Version` 比清单更旧：ADVISORY，"written against manifest v[story]; current is v[current] — run `/story-readiness` to check"。没有清单：跳过。用户故事中的 `Manifest-Note:` 行按原样带入偏差。
3. **ADR 约束**（`full`；`standard` 对关键 ADR）：搜索 ADR 的 Decision 或清单所禁止的模式。
4. **变更文件中的硬编码值**。
5. **范围：** 用户故事在 `## Files` 下列出的文件与变更的代码和测试文件（`git status --porcelain`）对比。列表中未指名的变更文件属于 OUT OF SCOPE。没有 `## Files` 章节的用户故事：当其 Current task 指明本用户故事时，使用检查点的 **Files in progress**；否则报告 `Scope: NOT ASSESSED — the story lists no files`。工作区干净：报告 `Scope: not checked — no uncommitted changes to compare`。

每个偏差都是 **BLOCKING**（与 GDD 或 ADR 冲突）、**ADVISORY**（有偏移但行为相同；由用户决定）或 **OUT OF SCOPE**（仅供参考）。将其作为事实陈述；由用户判断。

## Phase 6: 评审闸门

读取上面的 `review_gate` 行。

- **`skill-gates=skip`：** 不使用代理。注明 `QL-TEST-COVERAGE skipped — [Solo | Lean] mode` 和 `LP-CODE-REVIEW skipped — [Solo | Lean] mode`。在 `lean` 模式下，询问："Did you run `/code-review` on the implemented files?" 选项：Yes — it passed or was approved with suggestions / No — skipping review for this story / No — I'll run it before the sprint close-out。该回答设定 Reviewed by。
- **`skill-gates=run`：** 读取 `references/review-gates.md` 和 `.claude/docs/director-gates.md`，并立即运行两个闸门。若为跳过，不要加载它。

**Reviewed by** 永远不为空：LP-CODE-REVIEW 运行时为 `lead-programmer`；lean 模式选 Yes 时为 `/code-review (you said you ran it; not verified here)`；solo 模式、任一 No 以及尚无实现文件时为 `self, no independent review`。

## Phase 7: 报告、结论与关闭

```markdown
## Story Done: [title]
**Story**: [path] · **Type**: [type] · **Date**: [today]

### Acceptance Criteria: [X/Y passing]
- [x] [criterion] — [how verified]
- [ ] [criterion] — FAILS: [reason]
- [?] [criterion] — DEFERRED: requires playtest

### Traceability
[the Phase 3 table]

### Test Evidence
**Required**: [what the type needs at this qa.level, or "waived at qa.level minimal"]
**Found**: [YES — path | NO — BLOCKING | NO — ADVISORY]

### Deviations
[NONE, or each: BLOCKING / ADVISORY / OUT OF SCOPE — description — reference]

### Review
**Reviewed by**: [value]

### Verdict: [COMPLETE | COMPLETE WITH NOTES | NOT ASSESSED | BLOCKED]
```

**结论，首个匹配者胜出：**

1. **BLOCKED：** 有标准失败，或存在 BLOCKING 缺口或偏差。
2. **NOT ASSESSED：** 某条标准无法评估：它未指明任何可观察结果、用户回答"Not tested yet"、某个评审闸门返回 NOT ASSESSED 且其输入未被提供、证据存在但无法读取，或判断某偏差所需的 GDD 或 ADR 缺失。逐一指出并说明什么能解决它。它排序在两个通过之上，且绝不掩盖失败。
3. **COMPLETE WITH NOTES：** 每条标准通过或为 DEFERRED，并列出建议性项。信息行不是建议性项：证据戳记行、缺失的冲刺文件和运行结果绝不把 COMPLETE 变成 COMPLETE WITH NOTES。
4. **COMPLETE：** 每条标准通过，没有任何建议性项。

**然后在写入任何内容之前询问：** "How do you want to proceed?" 选项：Close the story — mark it Complete and log notes (Recommended) / Close and log the advisory deviations as tech debt / Don't close yet — I'll fix things first / Close anyway, accepting the deviations。在 BLOCKED 或 NOT ASSESSED 时，推荐"Don't close yet"并列出必须改变什么。关闭这样的用户故事属于 `scope_changes` 决策：当 `automation_always_ask` 行列出了它时，在每个自动化模式下都要询问，即便正是用户自己的请求走到了这里。仅在明确选择关闭时才写入。

**关闭时：**

1. `bash .claude/scripts/md-section.sh set-field <story> Status Complete`，然后 `set-field <story> "Last Updated" <YYYY-MM-DD> --after Status`。
2. 在用户故事末尾添加内容，使用文件编辑，绝不用 shell 命令（shell 写入会跳过项目的写入检查）：
   ```markdown
   ## Completion Notes
   **Completed**: [date]
   **Criteria**: [X/Y passing] ([deferred items])
   **Deviations**: [None, or the advisory ones]
   **Test Evidence**: [path, or "waived at qa.level minimal", or "none required"]
   **Reviewed by**: [value]
   ```
3. "Close and log as tech debt"：读取 `references/tech-debt-row.md`，为每个建议性偏差添加一行。
4. `production/sprint-status.yaml`（若存在）：本用户故事的条目写入 `status: done` 和 `completed: [date]`，顶层的 `updated` 写为今天。关闭的回答已涵盖此项。
5. 打印建议的提交：`git add [the changed code and test files] [story path]` 和 `git commit -m "feat: [story title] ([TR-ID])"`。

**在"Don't close yet"时：** 不修改任何用户故事文件。列出用户标记的内容。绝不自行修复失败的验收标准：报告它并询问该怎么办。

## Phase 8: 下一个用户故事、检查点、收尾

**下一个用户故事。** 若 `production/sprints/` 中没有冲刺计划（在 `workflow: minimal` 下总是如此）：在关闭之后运行 `bash .claude/scripts/story-status.sh`，使本用户故事的新状态被包含在内。它会按路线顺序打印未完成的用户故事；不要重新排序。第一个 `In Review` 用户故事是下一个（第一个 `IN_REVIEW` 行），否则是第一个 `In Progress`，否则是第一个 `Ready` 或 `Not Started`（`TODO`）：

```
### Next Up
**[Story NNN: title]** — [one line]
Run `/story-done [path]` to close it (In Review) — else `/dev-story [path]` to implement it.
```

当上面的 `workflow` 行为 `minimal` 时，完全不打印 `/story-readiness` 行，甚至不作为选项：它不在该路径上。在 `workflow: standard` 或 `full` 下没有冲刺计划时，添加"Run `/story-readiness [path]` first."

- 仅剩 `COMPLETE N of N`：每个用户故事都已构建。提供选项：试玩构建并记下感觉不对的地方；用 `/create-stories` 从简报中添加用户故事；或用 `/settings` 提高 `modes.rigor`（如果游戏已经超出了其简报）。
- 仅剩 `BLOCKED`、`OTHER` 或 `NO_STATUS` 行：没有 Next Up，且构建顺序**尚未**完成。逐个指出每个用户故事及其阻塞项、`Draft` 或无状态。
- 在此分支上绝不打印 Sprint Close-Out Sequence：没有冲刺。

若有冲刺计划：读取 `references/sprint-next.md`。

**检查点**，在每次运行、每个结论下都要写，无论是否关闭。将该块通过管道传给 `bash .claude/scripts/session-state.sh checkpoint`，它会替换旧块：

```
**Updated:** [date]
**Branch:** `[current git branch]`
**Current task:** /story-done — [story path]: [verdict], [closed | left open]
**Next step:** [the Next Up command, or the fix the verdict named]
**Blocked on:** [nothing, or what blocked the verdict]
**Files in progress:** none
**Open questions:** [tech debt logged: N items, or none]
```

**本次运行的最后一条回复以此块结束**（如果之前展示过，请重复它）：

```
Verdict: [COMPLETE | COMPLETE WITH NOTES | NOT ASSESSED | BLOCKED] — [story path]
Story: [closed — Status: Complete | left open — Status: [status]]
Review: [Reviewed by value; the gates' skip notes]
Next step: [/dev-story [path] | /story-done [path] | the fix | play the build]
```
