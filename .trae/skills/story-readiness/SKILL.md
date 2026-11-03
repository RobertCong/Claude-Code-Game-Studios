---
name: story-readiness
description: "检查用户故事是否已准备好实现：验收标准清晰、没有未决问题、ADR 和依赖有效。当用户询问某个故事或冲刺中的故事是否已准备好开始或构建时使用。"
argument-hint: "[story-file-path or 'all' or 'sprint'] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, Agent, Bash(bash "*/.claude/skills/story-readiness/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/story-facts.sh *), Bash(bash .claude/scripts/adr-status.sh *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation,workflow,qa.level,gate_level,story_granularity,system_overrides`

上述内容已解析完成——请直接使用；`--review` 会覆盖 `review_mode`。若没有解析块 →
使用 `.claude/docs/config-resolution.md` 中的默认值。

使用提问工具提问。若没有提问工具，就把选项编号列出并结束本轮
以等待回答。被跳过或忽略的问题不算回答：请用纯文本再次询问。

# Story Readiness

检查用户故事文件是否包含开发者在编写代码前所需的一切：
构建途中没有设计问题、无需猜测、没有含糊的验收标准。

**只读。** 它绝不写入或编辑文件。它只报告，并提出在对话中起草
修复内容。

**结论**，每个故事一个。按此顺序，第一个匹配的优先：

1. **BLOCKED**：读者可以清除的发现项。被引用的 ADR 缺失、
   为 `Proposed`、`Deprecated` 或 `Superseded`；依赖故事缺失或
   为 `Draft`；或某项验收标准包含无人负责的 UNRESOLVED 设计
   问题。
2. **NEEDS WORK**：某个阻塞性检查清单项未通过。故事现在就可以修复。
3. **NOT ASSESSED**：故事无法被评估。文件不可读、
   被引用的 ADR 没有可读的 `## Status`，或它点名的设计文档
   找不到。点名无法读取的内容。它绝不是 READY：没人能检查的故事
   不能算已证明就绪。它的优先级低于前两种失败，
   因为已知的阻塞项比未知项更有用。
4. **READY**：每一项都通过、有条件地 N/A，或属于建议性。建议性的
   缺口仍会列出。

询问遵循 `.claude/docs/automation-modes.md`（协作模式总是询问，引导模式
在重大选择时询问，自主模式记录并继续；`automation_always_ask`
类别总是询问）。

## Phase 1: 范围

范围是技能名之后输入的文本，去掉任何 `--review <mode>` 对。
剩下的是一个值；路径可以包含空格。如果什么都没输入，
用户请求中点名的故事、史诗或冲刺就是范围。

- **故事路径**：该故事。
- **`sprint`**：当前冲刺列出的故事（Phase 2 会读取它们）。
- **`all`**：`production/epics/` 下的每个 `story-*.md`。
- **某个史诗**（slug 或其文件夹）：该文件夹中的 `story-*.md` 文件。
- **为空**：询问：“What would you like to check?” 选项：A specific story file /
  All stories in the current sprint / All stories in production/epics/ / The
  stories of one epic。

**范围内零个故事：以 `NOT ASSESSED — no stories in scope` 停止。** 点名
范围和为空的路径，并路由到 `/create-stories`（在 `standard`
和 `full` 下，先 `/create-epics`）。绝不要在空列表上打印 `Ready: 0 / Needs Work: 0` 汇总：
它读起来像干净的结果。对于 `sprint`，“no sprint plan
found”和“the sprint plan lists no stories”是不同的报告；要说明是哪种。

在继续之前说“Checking [N] story files.”。

## Phase 2: 事实，本次运行读取一次

1. **故事。** 在范围内运行故事辅助脚本，使用上面解析的
   `story_granularity`：
   ```
   bash .claude/scripts/story-facts.sh --lint --granularity <story_granularity> [--sprint | --all | <path> ...]
   ```
   每个 `STORY` 行给出故事的状态、类型、层、估算、TR-ID、ADR、
   验收标准数量、测试证据行和依赖。每个 `LINT` 行
   是故事触发的规则。行是观察；结论由你判断。退出码 3
   表示某个文件未找到。有 `NOT_FOUND` 行时，每行点名一个冲刺 `file:`
   条目或一个不是文件的路径：把每个作为缺失的故事报告，并检查
   其余部分。没有 `NOT_FOUND` 行且有 `--sprint` 时，说明没有
   `production/sprint-status.yaml`：报告“no sprint plan found”。也要阅读每个故事文件：下面的可测试性、范围和
   资源条目需要它的文字。
2. **ADR。** 一次调用给出每个 ADR 的状态和层：
   `bash .claude/scripts/adr-status.sh`。`no_status` 或 `UNFILLED` 状态是
   格式错误的 ADR：绝不把缺失状态当作失败状态（路由：
   `/architecture-decision retrofit [file]`）。故事引用但表中没有行的 ADR 是缺失的。
3. **控制清单。** 只看 `docs/architecture/control-manifest.md` 中的
   `Manifest Version` 行。文件缺失：注明一次。
4. **TR 注册表。** 在 `docs/architecture/tr-registry.yaml` 中查找每个故事的 TR-ID
   及其 `status`。文件缺失：注明一次；TR-ID
   条目对每个故事都通过。
5. **冲刺优先级**（`sprint` 范围）：哪些故事是 Must Have 和 Should
   Have，来自 `production/sprints/` 中最新计划。

**每个故事的层级（Tier）。** `workflow` 按故事解析：使用故事所属系统的
`system_overrides` 行（其 `GDD:` 路径的 GDD 文件名主干；仅当没有 GDD 路径时
才使用 `TR-[system]-NNN` 中的 `[system]`），否则使用项目值。
一次运行中的故事可以处于不同层级。

## Phase 3: 检查清单

对每个故事检查每一项。层级决定哪些组构成阻塞：

| 组 | `full` | `standard` | `minimal` |
|---|---|---|---|
| Design Completeness | 阻塞 | 阻塞 | 阻塞；`design/game-brief.md` 代替 GDD |
| Architecture Completeness | 阻塞 | ADR 状态项阻塞；其余为建议性，除非涉及关键 ADR | 除 ADR 状态项外均为 N/A |
| Scope Clarity | 阻塞 | 阻塞 | 阻塞，但 Estimate 为建议性（没有冲刺计划可用于定尺寸） |
| Open Questions | 阻塞 | 阻塞 | 阻塞 |
| Asset References | 阻塞 | 阻塞 | 阻塞 |
| Definition of Done | 阻塞 | 阻塞 | 阻塞；测试证据项遵循 `qa.level` |

失败的**建议性**条目会列在 Gaps 下并附其 Fix，绝不单独
降低 READY。

### Design Completeness

- [ ] **需求可追溯**：故事点名其 `design/gdd/` 文件，并引用或
  链接其中的具体规则或验收标准，而不仅仅是文件名。在
  `minimal` 下：`design/game-brief.md` 和故事实现的 MVP 功能。
  点名的设计文档不存在：NOT ASSESSED。
- [ ] **自包含**：验收标准无需打开 GDD 就能说明“完成”意味着
  什么。
- [ ] **可测试**：每项验收标准都是具体、可观察的条件。不是：
  “Implement the jump mechanic.” 而是：“Jump reaches 5 units within 0.3 seconds
  when held.” 单元测试能够设置的验收标准（任何输入值）都是可测试的，
  即使发布的数据永远到不了那种情况。
- [ ] **无主观判断**：对于 Logic、Integration、UI 和 Config/Data，
  “feels responsive”或“looks good”会失败。对于 Visual/Feel，这类标准是预期的：
  当验收标准点名证据文件（如
  `production/qa/evidence/[slug]-evidence.md`）时通过，未点名时为 NEEDS WORK。

### Architecture Completeness

- [ ] **ADR 状态**，在每个层级：按 Phase 2 的表检查故事引用的
  每个 ADR。
  - `Accepted`：通过。
  - `Proposed`：BLOCKED。Fix：`BLOCKED: ADR-NNNN is Proposed — accept it with
    /architecture-decision accept ADR-NNNN once decided`。
  - `Deprecated` 或 `Superseded`：BLOCKED。Fix：`BLOCKED: ADR-NNNN is [status] —
    point the story at [successor] (edit its ADR field;
    /create-stories never rewrites an existing story)`。
  - 没有该 ADR 文件：BLOCKED。
  - 无可读状态：此项为 NOT ASSESSED；点名该文件。
  在 `standard` 下，缺失或为 Proposed 的**关键** ADR（其 `layer` 为基础层，或缺失）
  构成阻塞；对于其他 ADR，以下条目为建议性。
- [ ] **已引用 ADR 或声明 N/A**：一个 ADR，或带原因的显式 N/A
  （`ADR: N/A — [reason]`，或 `N/A (minimal — no ADRs)`）。留空失败。
- [ ] **TR-ID 有效**：每个 `TR-[system]-NNN` 都在注册表中且 `status:
  active`。`deprecated` 或 `superseded-by`（无论是否引用）：NEEDS WORK，Fix：把
  故事指向当前需求。不在注册表中：NEEDS WORK（故事
  可能早于它，或注册表需要 `/architecture-review`）。没有
  TR-ID，或没有注册表时通过。
- [ ] **Manifest Version 为当前版本**：将故事的 `Manifest Version` 与
  清单的比较。更旧：一个缺口，因为之后添加的规则可能适用。即使新规则看起来无关，
  它仍然是缺口：说明改了什么，并把决定留给
  用户。在 `full` 下无论新规则覆盖什么都为 NEEDS WORK；在
  `standard` 下为建议性。Fix，共三步：“Review the manifest rules added since
  [story's date]; update the story's rules if any apply; then set its Manifest
  Version to [current date].” 没有 `Manifest Version` 字段，或没有
  清单时通过。
- [ ] **引擎笔记**：故事触及的截止后引擎 API 有笔记或
  验证步骤，或故事声明“N/A — no engine API involved”。
- [ ] **已注明清单规则**：列出该层的规则，或“N/A — manifest
  not yet created”。没有清单时通过。

### Scope Clarity

- [ ] **估算**：小时数、点数或 T 恤尺寸。`unfilled Estimate`（仍为
  模板括号）失败。在 `minimal` 下为建议性。
- [ ] **已声明范围外**：有 Out of Scope 章节，或措辞使
  边界明确无歧义。
- [ ] **已列出依赖**：本故事需要的每个故事，或声明“None”。

### Open Questions

- [ ] **无未决标记**：没有 `marker` 行（作为完整单词大写的 TBD、TODO 或
  UNRESOLVED）。`?` 不是标记：像 `crit ? 2 : 1` 这样的公式通过。
  写成未决问题的验收标准仍然无法通过可测试性。
- [ ] **依赖存在且不是 Draft**：依赖故事缺失
  或为 `Draft` 会使故事 BLOCKED。`Story NNN` 表示同一
  史诗文件夹中的该编号；路径则精确点名一个。

### Asset References

- [ ] **故事使用的资源存在**：故事读取或在其上构建的 `assets/` 下的路径，
  或带 `.png`、`.jpg`、`.svg`、`.wav`、`.ogg`、`.mp3`、`.glb`、`.gltf`、`.tres`、`.tscn` 或
  `.res` 的路径。故事声明将创建的文件
  （新场景、新数据文件）不检查。缺失：NEEDS WORK；点名
  路径。报告“Referenced assets verified: [N] found”，或“No asset references”。
  仅检查存在性。

### Definition of Done

- [ ] **验收标准足够**：没有 `ac_below_min` 行。最低数量遵循
  `story_granularity`，因为 `/create-stories` 按它写入：

  | `story_granularity` | Logic、Integration | Visual/Feel、UI | Config/Data |
  |---|---|---|---|
  | `coarse` | 3 | 2 | 1 |
  | `balanced` | 2 | 2 | 1 |
  | `fine` | 1 | 1 | 1 |

- [ ] **已注明性能**：触及玩法循环、渲染或
  物理的故事声明预算，或“no performance impact expected — [reason]”。
- [ ] **已声明类型**：没有 `type_missing` 或 `type_unknown` 行。Fix：在头部添加
  `Type: [Logic|Integration|Visual/Feel|UI|Config/Data]`。
- [ ] **测试证据明确**：`## Test Evidence` 章节说明证据存放
  位置：Logic 和 Integration 为测试文件；UI 为每个屏幕的保留截图
  位于 `production/qa/evidence/`；Visual/Feel 则再加
  `production/qa/evidence/[story-slug]-evidence.md`。
  - 在 `qa.level: minimal` 下，Logic、Integration 和 Config/Data 通过：测试
    被豁免。不要列出缺口，也不要添加关于缺失测试文件、`tests/`
    文件夹或测试运行器的任何注释。UI 和
    Visual/Feel 仍会检查：它们的截图在每个层级都必需。
  - 否则由上面的 `gate_level` 行设定故事类型的级别。
    `blocking`：缺失章节为 NEEDS WORK。`advisory`：仅列出缺口。
    Fix：添加 `## Test Evidence`，并写明故事类型对应的证据位置。

## Phase 4: 结论

对每个故事应用开头的顺序。BLOCKED 的故事也可能有 NEEDS WORK
条目：两者都列出。

## Phase 5: QA 主管评审

阅读上面的 `review_gate` 行。`skill-gates=skip`（solo 或 lean）：跳过它，
回复中说“QL-STORY-READY skipped — [Solo | Lean] mode”。`skill-gates=run`：
阅读 `references/qa-lead-gate.md` 和 `.claude/docs/director-gates.md`，并在
报告之前运行它。跳过时，不要加载它。

## Phase 6: 报告并收尾

单个故事：

```
## Story Readiness: [story title]
File: [path]
Verdict: [READY / NEEDS WORK / BLOCKED / NOT ASSESSED]

### Passing Checks (N/[total])
Design Completeness: [passing items]
Architecture Completeness: [passing items, or "N/A at minimal (ADR status checked)"]
Scope Clarity: [passing items]
Open Questions: [passing items]
Asset References: [passing items, or "no asset references"]
Definition of Done: [passing items]

### Gaps
- [Checklist item]: [what is missing or wrong]
  Fix: [the text that resolves it]

### Blockers (if BLOCKED)
- [What blocks]: [the story, ADR or question that must clear first]
```

每次都要点名全部六个组，使用这些确切名称。没有通过项的组
写“none — see Gaps”，让读者看到它被检查过。

Gaps 只列出失败的检查清单项：绝不列通过或 N/A 的项，也绝不列
检查清单之外的观察（冲刺状态、另一份文档）。

多个故事：先给一份总结，然后为每个非 READY 的故事给出单故事块。

```
## Story Readiness Summary — [scope] — [date]
Ready: [N] · Needs Work: [N] · Blocked: [N] · Not Assessed: [N]

Ready: [title] ([path]), ...
Needs Work: [title]: [main gap]
Blocked: [title]: blocked by [story, ADR or question]
Not Assessed: [title]: [what could not be read]
```

`sprint` 范围：当某个 Must Have 故事不是 READY 时，把这段放在最前面：
`WARNING: [N] Must Have stories are not ready to implement: [each with its main
gap]. Fix them before the sprint starts, or replan with /sprint-plan update.`

**然后，对于单个故事：** 寻找其他可开始的故事。在
`production/sprints/` 中最新计划里，找到最多 3 个 Ready 或 Not Started 的、不是当前这个的、
不等待未完成依赖的、且为 Must Have 或 Should Have 的故事。每个都
列出一行描述及其估算。没有时，说明是哪一种：
`Next ready stories: no sprint file found` 或 `Next ready stories: none ready in
[sprint]`。

**提供帮助。** 询问：“Would you like me to draft the missing parts for any of
these stories?” 选项：Yes, draft them / No, that's all。选择 yes 时，只在
对话中起草缺失的部分。由用户或 `/create-stories` 写入它们。

重定向：
- 故事文件缺失：运行 `/create-stories [epic-slug]`（在 `standard` 和
  `full` 下，先 `/create-epics`）。
- 没有设计参考且改动很小（不到约一周）：运行
  `/quick-design [description]`，并在故事中引用该规格。
- 范围超出了其规模：拆分故事，或向制作人提出。

**以以下内容结束回复：**

```
Review: [QL-STORY-READY skipped — Solo mode | skipped — Lean mode | its verdict]
Next ready stories: [up to 3 | no sprint file found | none ready in [sprint]]   (one-story scope)
Next step: [/dev-story [path] when READY | fix the gaps above, then /story-readiness [path]]
Files changed: none
```
