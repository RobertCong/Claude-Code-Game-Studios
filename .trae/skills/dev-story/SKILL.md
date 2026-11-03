---
name: dev-story
description: "在代码中实现单个用户故事并编写测试，遵循其 ADR。当用户要求构建、实现或开始处理某个用户故事时使用。不用于事先检查就绪状态，也不用于在之后关闭该用户故事。"
argument-hint: "[story-path]"
user-invocable: true
disable-model-invocation: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level,gate_level,engine_values,specialists,perf_budgets,system_overrides`

上一步命令的输出已解析完成——请直接使用。若没有解析块 → 使用
`.trae/docs/config-resolution.md` 中的默认值。

使用提问工具提问。若没有提问工具，就把选项编号列出并结束本轮
以等待回答。被跳过或忽略的问题不算回答：请用纯文本再次询问。

# Dev Story

实现一个用户故事：检查它能否开始，标记为 In Progress，用根据故事构建的
简报把代码交给合适的程序员 agent，然后检查结果能否解析、看起来是否正确，并
完成交接。

**写入**（每次都在点明它的问题之后）：故事的 `Status`、`Last Updated`
和 `## Files`，以及它在 `production/sprint-status.yaml` 中的条目。程序员 agent
在代码根目录和测试根目录下编写代码和测试
（`.trae/docs/code-root-resolution.md`）。会话检查点和证据
戳记无需询问即可写入。
**下一步：** `/story-done [story-path]`；在 `standard` 和 `full` 下，先
`/code-review [files]`。

询问遵循 `.trae/docs/automation-modes.md`（协作模式总是询问，引导模式
在重大选择时询问，自主模式记录并继续；`automation_always_ask`
类别总是询问）。

检查清单（复制它并随进度勾选）：

```
- [ ] Phase 1: story found, tier resolved
- [ ] Phase 2: prerequisites checked (ADR, manifest, dependencies)
- [ ] Phase 3: story marked In Progress (one ask)
- [ ] Phase 4: programmer and engine specialist chosen
- [ ] Phase 5: work handed out with a full brief
- [ ] Phase 6: finished? parse check, run and look, one Run result line
- [ ] Phase 7: summary, ## Files, checkpoint, closing block
```

## Phase 1: 用户故事

技能名之后输入的文本就是故事路径。如果没有输入，就取
`production/session-state/active.md` 检查点中指定的故事并确认：
“继续处理 [title]——对吗？” 若那里没有：询问“我们要实现哪个用户故事？”
并把 `bash .trae/scripts/story-facts.sh --all` 的 `TODO` 行
作为选项。如果 `production/epics/` 下完全没有故事文件：以如下信息停止：
“No stories found in `production/epics/` — run `/create-stories [epic-slug]` to make them (at `standard` and `full`, run `/create-epics` first if there is no epic yet).”

`bash .trae/scripts/story-facts.sh <story-path>` 给出它的类型、层、TR-ID、
ADR 和依赖。然后完整阅读该用户故事。

**层级（Tier）。** 故事所属系统的 `workflow`，依据其
`GDD:` 路径的 GDD 文件名主干确定（`design/gdd/<stem>.md` → `<stem>`；仅在没有 GDD
路径时才使用其 TR-ID 中的 `[system]`）：如果该系统有 `system_overrides` 行就用它，
否则使用项目值。在你第一次回复中说明：`Tier: workflow [value]`。该值——绝不是
`rigor` 或 `qa.level`——决定 Phase 2 的列和结尾的下一步。

## Phase 2: 能否开始？

| 输入 | `full` | `standard` | `minimal` |
|---|---|---|---|
| TR 注册表 `docs/architecture/tr-registry.yaml` | 缺失：**停止**，“Run `/architecture-review` to bootstrap it” | 可选 | 不要求 |
| 故事指定的 ADR | 缺失、`Proposed`、`Deprecated` 或 `Superseded`：**停止** | 同上，仅当故事指定了 ADR 时 | 同上，仅当故事指定了 ADR 时 |
| 控制清单 `docs/architecture/control-manifest.md` | 缺失：警告，继续 | 缺失：警告，继续 | 不要求 |

如果故事的 ADR 字段为 `N/A — [reason]`，表示它没有指定 ADR。

**ADR。** `bash .trae/scripts/adr-status.sh <ADR id>` 给出其状态和
`version`。停止消息：`Proposed` ——“ADR-NNNN is still Proposed. Accept it with
`/architecture-decision accept ADR-NNNN` before implementing.” `Deprecated` 或
`Superseded` ——“ADR-NNNN is [status]; point the story at [successor] (edit its ADR
field; `/create-stories` never rewrites an existing story) before implementing.”
`NOT_FOUND` ——“ADR file not found. Run `/architecture-decision`, or correct the
story's ADR field.”

**不要打开 ADR。** 程序员读的是故事中的 ADR Decision Summary 和 Implementation Notes。
将 ADR 的 `version` 与故事的 `ADR Version` 比较：

- 相等，或故事没有 `ADR Version`（在戳记之前编写），或两者都是
  `unversioned`：信任故事。在后两种情况下在总结中注明（“summary
  trusted unverified”）。
- 它们不同，或 ADR 是 `unversioned` 但故事指定了日期：阅读
  `references/version-mismatch.md`。匹配时，不要加载它。

不要把缺失的戳记当作过期的戳记：未知时回退到故事，
`/story-readiness` 和 `/code-review` 是之后发现漂移的检查。

**清单。** 当它存在时，将它的 `Manifest Version` 行与
故事的比较。若不同：阅读 `references/version-mismatch.md`。

**依赖。** 对故事 Depends on 行上的每个路径，运行
`bash .trae/scripts/story-facts.sh <path>`。如果不是 `COMPLETE`：询问“[this story]
depends on [dependency], which is [status], not Complete. How do you want to go
on?” 选项：Proceed anyway — I accept the risk / Stop — I'll finish the
dependency first / It is done, the status was never updated — mark it Complete。
停止：故事为 BLOCKED（Phase 7），不运行 agent。标记为完成：先询问“May I set [path]
Status to Complete?”。继续：在 Deviations 下注明。`NOT_FOUND`：警告
“Dependency story not found: [path]”。

上述任何停止：不运行 agent。转到 Phase 7 并编写 BLOCKED 检查点。

## Phase 3: 标记为 In Progress

在任何 agent 之前，询问一次：“May I mark this story In Progress? This sets `Status`
and `Last Updated` in [story path] and its entry in `production/sprint-status.yaml`,
and at the end lists the files changed under its `## Files`.” 如果冲刺文件不存在，
就把它排除在问题之外。把接下来要做的事放在
问题之前：问题应是回复中的最后内容。若同意：

- `bash .trae/scripts/md-section.sh set-field <story> Status "In Progress"`，然后
  `set-field <story> "Last Updated" <YYYY-MM-DD> --after Status`。在 `minimal` 下，
  故事文件是唯一的进度记录。
- `production/sprint-status.yaml`：该故事的条目设为 `status: in-progress`，
  顶层 `updated` 设为今天。没有该文件：说明 `Sprint status not updated:
  production/sprint-status.yaml absent`。

被拒绝：两者都不改，在总结中打印 `Story not marked In Progress — declined`，
然后继续。

## Phase 4: 由谁实现

**Config/Data 故事不需要 agent。** 把每个值变更以 from → to 形式展示，询问“May
I write [data file]?”，然后编辑它。转到 Phase 6。

| 故事 | 程序员 agent |
|---|---|
| 基础层，任意类型 | `engine-programmer` |
| Type UI | `ui-programmer` |
| Type Visual/Feel | `gameplay-programmer` |
| Core 或 Feature，玩法 | `gameplay-programmer` |
| Core 或 Feature，AI 或寻路 | `ai-programmer` |
| Core 或 Feature，网络 | `network-programmer` |

**引擎专家，适用于每个代码故事。** 来自上面的 `specialists` 行：
`code`（`specialists.code`，语言专家：它能区分 Godot C# 项目和 GDScript 项目，
而 `engine.name` 做不到），加上当故事涉及着色器或材质时的 `shader`，以及 UI
故事的 `ui`；当 `code` 为 `unset` 时用 `primary`（通用引擎专家）。不要凭记忆指定
专家：那一行是项目的选择。所有值都是 `unset` 且没有 `primary`：说明“No engine specialist configured”
并在没有专家的情况下继续。

## Phase 5: 分发工作

把实现交给程序员 agent。简报指向文件；绝不要把整份文档
粘贴进去。

- **目标：** 依据验收标准实现 [story path]，保持在其
  Out of Scope 边界内。
- **来源：**
  1. 故事文件。它包含验收标准、边界和 QA 测试用例。
  2. 每个要查找的 TR-ID（`TR-[system]-NNN`）：在
     `docs/architecture/tr-registry.yaml` 中匹配 `id: <TR-ID>\s*$` 的行。
     其 `requirement` 文本是事实来源，而不是故事中引用的文本。
  3. ADR 指导，**内联**：故事的 ADR Decision Summary 和
     Implementation Notes。绝不要给 ADR 路径。
  4. 控制清单中的 [Layer] Layer Rules，按节。
  5. `project.yaml` 中的 `naming.*` 和上面的 `perf_budgets` 行。
  6. 故事 Test Evidence 章节中的测试文件路径。
- **测试**，按 `qa.level`，针对 Logic 和 Integration 故事：
  - `minimal`：“Do not write a test file for this story — test evidence is waived at
    `qa.level: minimal`.” 要明确说出：省略一行和忘记一行
    在 agent 看来是一样的。
  - `standard`：“Write the test at [path] with the code. Each acceptance criterion
    needs at least one test function.” 按引擎命名，见
    `.trae/rules/test-standards.md`。不使用随机种子、不使用依赖时间的
    断言、不使用外部 I/O。
  - `full`：同上，并加上“every criterion must be covered: `/story-done` blocks on
    any untested one.”
- **产出：** 创建或修改的文件、编写的测试函数、任何
  问题或阻塞项，以及它是否完成。
- **边界：** 只在解析出的代码根目录下写代码，测试只在
  测试根目录下写。代码根目录未解析：什么也不写并报告。不要触碰故事范围之外的
  文件：改为报告需求。公共 API 要有文档注释。ADR 未覆盖的架构选择：
  报告计划，不要自行决定。不为一次性使用创建辅助函数或抽象，不为不可能发生的情况
  编写错误处理（只在输入和数据文件边界验证），编写通用逻辑，
  绝不为了通过测试而对某个值做特殊处理。

**向两位读者说明简报省略了什么。** Phase 2 发现缺失的输入
（TR 注册表、ADR、清单）会被省略：告诉 agent “No [input] is
passed — it does not exist at this tier; do not go looking for it”，并在分发前
告诉用户一行：`Briefing omits: [inputs] — implementing against
the acceptance criteria and the [GDD | brief].`

**然后在程序员报告后把引擎检查交给专家。**
简报：检查变更文件中针对 [engine + version] 错误或已变更的引擎 API 用法，
对照 `docs/engine-reference/<engine>/`；返回文件、行、问题、修复的列表；
不要编辑任何内容。破坏验收标准的问题退回给程序员一次；其余写入总结。

## Phase 6: 检查结果

**agent 完成了吗？** 它提前停止、触及限制，或其报告在任务中途结束：
故事为 **INCOMPLETE**。以此为标题说明，列出已存在的内容，
指出破损处，提出恢复该 agent。绝不在此之上打印“Implementation Complete”，
并保持状态不变。

**它写了它所说的内容吗？** 先验证产出物：agent 报告点名的文件若不在磁盘上，
就是失败的步骤，无论报告多么流畅：恢复 agent 并点明缺失的
文件。报告为 BLOCKED、错误或“cannot complete”：立即说明，不要
越过它阻塞的范围继续，并给出部分报告
（`.trae/docs/error-recovery-protocol.md`）。范围太大：用
`/create-stories` 拆分。ADR 与故事不一致：报告冲突；绝不猜测。

**测试在那里吗？** 在 `qa.level: standard` 和 `full` 下，对于 Logic 或 Integration
故事，查看 Test Evidence 路径的文件。缺失：如果该类型在 `gate_level` 行上处于
BLOCKING 级别，标记“story unverifiable — test required before
`/story-done`”；如果是 ADVISORY，作为建议注明。在 `minimal` 下
无需检查：测试被豁免。

**它能解析吗？** 运行其退出码能回答该问题的检查，并报告
命令、退出码和任何错误行：

- **Godot：** 先运行一次 `godot --headless --path . --import`，然后
  `godot --headless --path . -s res://.trae/scripts/godot-parse-check.gd -- res://<each changed .gd>`。
  退出码 1 表示某个脚本未能加载；其 `PARSE FAIL:` 行会点名它。绝不使用
  `--check-only`，仅 `--import` 不是解析检查。可执行文件优先取
  `commands.test` 在其文件名标明 godot 时指定的那个（像 `bash
  run-tests.sh` 这样的包装脚本不是编辑器），否则取 `engine.path`，再否则取 `godot`。绝不要
  在磁盘上搜索一个：三者都无法运行时，该检查就是未验证。
- **Unity、Unreal：** 阅读 `references/engine-checks.md`。
- **没有引擎可执行文件：** `parse NOT VERIFIED — engine binary not available`。
  绝不通过阅读代码推断它能解析。

**运行并观察**（`.trae/docs/run-and-observe.md`）。对于玩家能看到的每个故事
（每个 Visual/Feel 和 UI 故事，以及任何其他有可见界面的故事）：直接启动到
故事触及的场景，将截图直接捕获到
`production/qa/evidence/[story-slug]/`（`[story-slug]` 是故事文件名
去掉 `.md`；先用 `mkdir -p` 创建文件夹），用
`bash .trae/scripts/review-receipts.sh hash <each changed file> > production/qa/evidence/[story-slug]/stamp.txt`
为其打戳记，然后打开图片并与验收标准比较。在 `qa.level:
minimal` 下不豁免。只报告一行纯文本，以 `Run result:` 开头（不加粗：
`/story-done` 按原样读取）：

- `Run result: OBSERVED — <what was on screen>`，并附保留路径；
- `Run result: NOT VERIFIED — <reason>`（没有引擎，未捕获任何内容）；在默认
  闸门级别下，这会阻止 Visual/Feel 或 UI 故事通过 `/story-done`；
- `Run result: N/A — <reason>`，适用于没有可观察内容的故事；原因说明
  为何没有（`/story-done` 不接受“it's a Logic story”）。

Visual/Feel 验收标准中只有手感那一半（时机、重量）DEFERRED 到
`/team-qa`：静态截图无法展示它。

本技能预批准 PATH 上的 `godot`。通过 `engine.path` 或
`commands.test` 指定的可执行文件运行的引擎会先询问：用户批准一次，或
把 `Bash(<that executable> *)` 加入 `.trae/settings.local.json`。

## Phase 7: 总结、文件、检查点

```
## Implementation Complete: [title]

**Files changed**:
- `[code root path]` — created / modified ([what])
- `[test path]` — [N] test functions
**Test evidence**: waived at `qa.level: minimal` — no test was required or written   (Logic/Integration at minimal, instead of the test line)
**Verification**: [command] — [exit code and result | parse NOT VERIFIED — <reason>]

**Acceptance criteria**:
- [x] [criterion] — [file:function | test name | OBSERVED in <image path>]
- [ ] [criterion] — DEFERRED: feel, needs a playtest
**Deviations**: [None | files outside scope, an accepted dependency or version risk]
**Engine risks**: [None | the specialist's findings]
**Blockers**: [None | each]
```

在 `qa.level: standard` 和 `full` 下，添加：“Run your test suite and confirm the new
tests pass before `/story-done`: it checks that the test file exists, and runs
nothing.” 在 `minimal` 下省略该句：没有测试可运行。对于没有保留图像的 Visual/Feel
或 UI 故事，添加：“A retained screenshot under
`production/qa/evidence/[story-slug]/` is required before `/story-done`”（并且，对于
Visual/Feel，`production/qa/evidence/[story-slug]-evidence.md` 中的签核）。

**`## Files`。** 按 Phase 3 询问所述，将本节正文替换为变更的代码和测试
文件列表，每行一个：
通过 stdin 把列表传给 `bash .trae/scripts/md-section.sh replace <story> "Files"`。
没有该节的故事：用文件编辑在其末尾添加 `## Files` 和列表，
绝不用 shell 命令（shell 写入会跳过项目的写入检查）。如果 Phase 3 的询问
被拒绝，跳过这一步。

**检查点**，在每种结果下都执行。把该块通过管道传给
`bash .trae/scripts/session-state.sh checkpoint`，它会替换旧的检查点：

```
**Updated:** [date]
**Branch:** `[current git branch]`
**Current task:** /dev-story — [story path] ([title])
**Next step:** [the Next step below]
**Blocked on:** [nothing, or the blocker]
**Files in progress:** [changed files, comma-separated]
**Run result:** [OBSERVED — … | NOT VERIFIED — … | N/A — …, as in the closing block: /story-done reads it here]
**Open questions:** [none, or one line each]
```

**本次运行的最后一个回复以此块结尾**，这是唯一打印 `Run result:` 行的
地方：不要在回复的其他任何地方打印它。下一步依据你在 Phase 1 声明的层级（`workflow` 行，
绝不是 `rigor` 或 `qa.level`）。下一步：在 `minimal` 下，`/story-done [path]`。在 `standard` 和 `full` 下，
`/code-review [files]`，然后 `/story-done [path]`。INCOMPLETE：`/dev-story [path]`
以恢复。BLOCKED：解除阻塞的操作（`/architecture-decision accept
ADR-NNNN`、要完成的依赖、要评审的 diff）。

```
Story: [path] — [Implemented | INCOMPLETE — <breakage> | BLOCKED — <reason>]
Run result: [OBSERVED — … | NOT VERIFIED — … | N/A — …]
Next step: [Implemented, Tier: workflow minimal → /story-done [path] | Implemented, Tier: workflow standard or full → /code-review [changed files], then /story-done [path] | INCOMPLETE → /dev-story [path] to resume | BLOCKED → the unblocking action]
```