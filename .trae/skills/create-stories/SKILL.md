---
name: create-stories
description: "把一个史诗（epic）拆解为可实现的用户故事，并附带验收标准。当用户想要某个史诗的用户故事或下一批要构建的工作时使用。不用于把整个设计转成史诗。"
argument-hint: "[epic-slug | epic-path] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,review_gate,automation,workflow,docs.density,story_granularity,qa.level,system_overrides`

上一步命令的输出已解析完成——请直接使用；`--review` 会覆盖 `review_mode`。若没有解析块 →
使用 `.trae/docs/config-resolution.md` 中的默认值。

使用提问工具提问。若没有提问工具，就把选项编号列出并结束本轮
以等待回答。被跳过或忽略的问题不算回答：请用纯文本再次询问。

# Create Stories

一个用户故事是一个可实现的行为：小到符合
`story_granularity` 设定的规模、自包含，并可追溯到一项需求和治理它的
决策。每个史诗运行一次本技能，按依赖顺序：
先基础（Foundation）史诗，再核心（Core）、功能（Feature）、表现（Presentation）。

**写入：** `production/epics/[epic-slug]/story-NNN-[slug].md`、史诗的
`EPIC.md` Stories 表，以及它在 `production/epics/index.md` 中的行。
**下一步：** 在 `workflow: minimal` 下 `/dev-story [story-path]`；否则
`/story-readiness [story-path]`，然后 `/dev-story`。

询问遵循 `.trae/docs/automation-modes.md`（协作模式总是询问，引导模式
在重大选择时询问，自主模式记录并继续；`automation_always_ask`
类别总是询问）。

检查清单（复制它并随进度勾选）：

```
- [ ] Phase 1: epic found, tier resolved
- [ ] Phase 2: inputs loaded, each ADR's status reported
- [ ] Phase 3-4: stories drafted, typed, Ready or Blocked
- [ ] Phase 5: QA lead review run, or its skip noted
- [ ] Phase 6: story list shown, one ask to write
- [ ] Phase 7: stories, EPIC.md and index.md written (or index absence said)
- [ ] Phase 8: next step asked, closing block printed
```

## Phase 1: 史诗与设置

**层级（Tier）。** 史诗所属系统的 `workflow`：如果史诗 slug（其 GDD 系统）在
`system_overrides` 中有对应的行就用它，否则使用项目值。

**`story_granularity`** 决定每个故事的验收标准数量。分组或拆分
验收标准以达到该数量：

| `story_granularity` | 每个故事的 AC 数 | 规模 |
|---|---|---|
| `coarse`（默认，`rigor: minimal`） | 5-10 | 一个完整功能，多天 |
| `balanced`（`rigor: standard`） | 2-4 | 一个任务，约一次会话 |
| `fine` | 1 | 一个验收标准；故事名称重述它 |

**`docs.density`** 决定每个故事说明文字的深度（上下文、实现
笔记、ADR 总结），绝不决定 AC 数量或 AC 文本：`terse`（默认）= 要点
笔记，无前言；`balanced` = 一小段上下文加笔记；`thorough` =
完整上下文、指导与 ADR 理由。TR-ID、ADR Version 和验收
标准永远不会被裁剪。

**哪个史诗。** 技能名之后输入的文本，去掉任何 `--review <mode>`
对：史诗 slug（`combat`）或路径（`production/epics/combat/EPIC.md`）。
如果什么都没输入，用户请求中指定的史诗（“the loot epic”）也算
已指定。

- **已指定，但那里没有 `EPIC.md`：** 在 `standard` 和 `full` 下停止：“No epic at
  `production/epics/[slug]/EPIC.md`. Run `/create-epics` to create it, or check the
  slug with `ls production/epics/`.” 绝不基于猜测进行分解。在 `minimal` 下，
  说明该层级不需要 `/create-epics` 史诗，采用 Phase 2 的 `minimal` 分支，并
  点明它使用的 slug。
- **为空，在 `minimal` 下：** 采用 Phase 2 的 `minimal` 分支。
- **为空，在 `standard` 或 `full` 下：** 列出 `production/epics/*/EPIC.md` 及其各自
  状态，然后询问：“Which epic would you like to break into stories?” 每个史诗一个
  选项。**没有找到史诗：** 停止并说明 “No epics found under
  `production/epics/`. Run `/create-epics layer: foundation` first.” 绝不要提出
  没有选项的问题。

## Phase 2: 加载输入

### `minimal`：从简报构建史诗

1. **没有 `design/game-brief.md`：** 停止。“There is no brief to build stories from
   yet: run `/brainstorm` first; it writes the one-page brief.” 当代码根目录
   已经包含游戏（10 个或更多源文件）时，改用
   `/reverse-document design [code root]`。
2. 完整阅读 `design/game-brief.md`（一页）。
3. **史诗。** `<slug>` 是简报的工作标题经 slug 化（如果没有
   标题则为 `mvp`），或用户指定的史诗。
   - `production/epics/<slug>/EPIC.md` 存在：它就是史诗。使用其范围，仍
     追溯到简报，且绝不重写它。
   - 不存在：起草一个，仅在 Phase 6 的询问点明它之后于 Phase 7 写入。
     目标 = 简报的一句话提案；范围 = 其 MVP 功能列表；
     顺序 = 其 **Build order**。保持简洁。
   - 文件夹中已有故事（回访）：绝不重写已有的
     `story-*.md`。只为它们未覆盖的简报条目，或用户点名的新条目
     添加故事，并从现有最高的 `story-NNN` 继续编号。
4. **每个 MVP 功能一个故事，按 Build order**，每个都追溯到简报。没有
   故事因 ADR 原因被阻塞：该层级没有 ADR。

在 `minimal` 下不读取任何 GDD、控制清单、TR 注册表或 ADR。转到 Phase 3。

### `standard` 和 `full`：史诗及其治理内容

1. **史诗：** 完整阅读 `production/epics/[epic-slug]/EPIC.md`（其层、GDD、
   治理 ADR，以及带 TR-ID 的 GDD Requirements 表）。
2. **GDD：** 按标题读取其章节，绝不读整个文件：
   `bash .trae/scripts/md-section.sh extract design/gdd/[file].md "Acceptance Criteria"`，
   对 `Formulas`、`Edge Cases` 和 `Detailed Design` 同样处理（退出码 3：尝试
   `Detailed Rules`，即设计标准中同一章节的名称）；在 `full` 下
   还需要其他必需章节（`list` 显示标题）。
3. **控制清单：** 仅史诗所在层，以及版本：
   `bash .trae/scripts/md-section.sh extract docs/architecture/control-manifest.md "[Layer] Layer Rules"`，
   加上其 `Manifest Version` 行。
4. **TR 注册表：** 仅本系统的条目：在
   `docs/architecture/tr-registry.yaml` 中，匹配 `system: <slug>\s*$` 的行，
   每条目的 `id` 在上方、文本在下方。锚点可防止 `combat`
   匹配 `combat-ai`；`\s*` 可处理 Windows 行尾。
5. **ADR**，史诗点名的每一个（治理 ADR，或在其需求表中的，
   包括 Proposed 的），在一次调用中：
   ```
   bash .trae/scripts/adr-status.sh ADR-0001 ADR-0003 ...
   ```
   每一行给出状态、层、`version`（故事的 ADR Version 戳记）、
   `depends_on` 以及缺失的章节。然后用
   `md-section.sh extract` 只读取每个 ADR 的 `Summary`、`Decision`（其中的
   Implementation Guidelines）和 `Engine Compatibility`。Engine Notes 是取自 Engine
   Compatibility 的故事字段，不是 ADR 章节。缺少这些章节的 ADR 早于
   模板：读取一次，并标记它以供 `/architecture-decision retrofit
   [file]` 处理。

**点名但无文件的 ADR**（`NOT_FOUND`）：

- `full`：在分解任何故事之前停止。
- `standard`：仅当它是关键 ADR（基础层）时停止；否则警告，继续，
  并把其治理的故事写为 `Blocked`，直到它存在。
- 停止时：“Epic references [ADR-NNNN: title] but no file for it was found in
  `docs/architecture/`. Check the epic's Governing ADRs list, or run
  `/architecture-decision` to create it. Cannot create stories until the
  referenced ADR files exist.”

**起草前报告**，使用真实状态，每个 ADR 单独列出并附其
状态：

```
Loaded: epic [name] · GDD [file] · manifest v[date], [layer] rules
ADRs: ADR-0001 Accepted · ADR-0002 Accepted · ADR-0003 Accepted · ADR-0004 Proposed · [ADR-NNNN missing]
```

绝不要在某个缺失时说“all present”，或在没有清单版本时点明一个
清单版本。

## Phase 3: 为每个故事定类型

| 类型 | 当其验收标准涉及 |
|---|---|
| **Logic** | 公式、阈值、状态转换、AI 决策、计算 |
| **Integration** | 两个或更多系统、跨边界信号、存档/读档往返 |
| **Visual/Feel** | 动画、VFX、“feels responsive”、时机、屏幕震动、音频同步 |
| **UI** | 菜单、HUD、按钮、界面、对话框、工具提示 |
| **Config/Data** | 仅平衡性数值和数据文件，无新逻辑 |

混合型故事采用实现风险最高的类型。类型决定
`/story-done` 所需的证据。

## Phase 4: 起草故事

把需要相同核心实现的需求归入一个故事，符合
`story_granularity` 的数量。顺序：先基础行为，再边缘情况，
UI 最后。对每个故事：

- **需求：** 注册表中的 TR-ID，通过史诗的 GDD
  Requirements 表匹配。仅当没有匹配条目时，写 `TR-[system]-???` 并说明
  原因。
- **ADR：** 治理如何构建它的那个（需求表会点名它）。
  - `Accepted`：内嵌它。
  - `Proposed`：`Status: Blocked`，并附“BLOCKED: ADR-NNNN is Proposed — accept it
    with `/architecture-decision accept ADR-NNNN` once decided”。
  - `Deprecated` 或 `Superseded`：`Status: Blocked`，并附“BLOCKED: ADR-NNNN is
    [status] — point the story at [successor] (edit its ADR field;
    `/create-stories` never rewrites an existing story) before implementing”。
  - 某个 `Accepted` ADR 的 `depends_on` 点名了未 Accepted 的 ADR：以同样方式
    阻塞，并点明该 ADR。
  - 多个适用：全部列出，最直接的在前。
  - 无适用：`ADR: N/A — [reason]`，例如“pure data configuration”。绝不
    留空：留空意味着未检查。
- **ADR Version：** 故事的 **ADR Version** 是 ADR 的 `## Last Verified`
  日期，否则其 `## Date`，否则 `unversioned`（`version` 列）。当它仍与 ADR 匹配时，
  `/dev-story` 信任故事的 ADR 总结。
- **引擎风险：** 来自 ADR 的 Engine Compatibility（其知识风险）。
- **估算：** 根据验收标准和故事触及的文件提出一个 T 恤尺寸：
  `S`（几小时）、`M`（约一天）或 `L`（数天）。这是
  提议：Phase 6 会展示它，用户可更改。`/story-readiness` 会让
  Estimate 仍为模板括号的故事失败，所以绝不要留下它。

## Phase 5: QA 主管评审

阅读上面的 `review_gate` 行。`skill-gates=skip`（solo 或 lean）：不评审；
在 Phase 6 列表和收尾块中注明“QL-STORY-READY skipped — [Solo | Lean] mode”。
`skill-gates=run`：阅读 `references/qa-lead-gate.md` 和
`.trae/docs/director-gates.md`，并在 Phase 6 询问之前立即运行它。跳过时，
不要加载它。

## Phase 6: 展示故事，询问一次

```
## Stories for Epic: [name]
ADRs: ADR-0001 Accepted · ADR-0002 Accepted · ADR-0004 Proposed   (every ADR, from Phase 2)

Story 001: [title] — Logic — ADR-0001 — Ready — Estimate M
  Covers: TR-[system]-001 ([one-line requirement])
  Test required: tests/unit/[system]/[slug]_test.[ext]

Story 002: [title] — Integration — ADR-0004 — BLOCKED (ADR-0004 is Proposed) — Estimate L
  Covers: TR-[system]-002, TR-[system]-003
  Test required: tests/integration/[system]/[slug]_test.[ext]

Story 003: [title] — Visual/Feel — ADR-0001 — Ready — Estimate S
  Covers: TR-[system]-004
  Evidence required: retained screenshot + sign-off in production/qa/evidence/[slug]-evidence.md

[N stories: N Logic, N Integration, N Visual/Feel, N UI, N Config/Data; N Blocked]
QL-STORY-READY: [skipped — Solo mode | its verdicts]
```

在 `minimal` 下，每一行追溯到 `Brief MVP feature N`，没有 ADRs 行，且
每个 MVP 功能一个故事：不为 MVP 列表之外的简报条目添加额外故事。然后
询问：“May I write these [N] stories to `production/epics/[epic-slug]/`, and
[create | update] `production/epics/[epic-slug]/EPIC.md` and update
`production/epics/index.md`?” 选项：Yes, write all [N] / Not yet, I want to
adjust first；调整可以改变任何估算。点明 Phase 7 触及的每个文件：仅当 `EPIC.md`
不存在时才*创建*它，`index.md` 不存在时则把它排除。同意之前
什么也不写。

## Phase 7: 写入

### 故事文件

**每个故事**为 `production/epics/[epic-slug]/story-[NNN]-[slug].md`，按
`.trae/docs/templates/story.md` 布局。绝不重复使用故事编号。每个文件
都以文件方式写入，绝不通过 shell 命令：shell 写入会跳过项目的写入
检查。

在 `minimal` 下没有 GDD、ADR、TR 注册表或清单。精确填写这些
字段：

| 字段 | `minimal` 下的值 |
|---|---|
| GDD | `design/game-brief.md` |
| Requirement | `Brief MVP feature N`，绝不是 TR-ID |
| ADR Governing Implementation、ADR Decision Summary、ADR Version | `N/A (minimal — no ADRs)` |
| Manifest Version、Control Manifest Rules | `N/A (minimal — no control manifest)` |
| Engine | `engine.name` + `engine.version` |
| Risk | `docs/engine-reference/<engine>/VERSION.md` 为锁定版本给出的等级（其时间线行，或其总体评级）。无文件或无等级：`NOT ASSESSED (no VERSION.md risk rating)`，绝不猜测。`/dev-story` 将 NOT ASSESSED 视为 HIGH |
| Engine Notes | `none (no ADR engine-compatibility analysis at minimal)` |
| Acceptance Criteria | 来自简报的 **Player goal & fail state** 和 MVP 功能，使其具体且可测试；绝不从一条光秃秃的要点凭空编造 |

在每个层级：
- **QA Test Cases：** 当评审被跳过时，写
  `*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*`。
  绝不要即兴编造测试用例。
- **Test Evidence：** 由 `qa.level` 决定。在 `qa.level: minimal` 下测试被
  豁免（建议性），但 Visual/Feel 或 UI 故事的保留截图不豁免。
- **Estimate：** Phase 6 中的规模，加上用户所做的任何更改。
- **Dependencies：** 按路径点名本故事所需的每个故事。
- **Files：** 故事计划创建或更改的代码和测试文件，
  位于代码根目录和测试根目录下。`/dev-story` 会用真实列表替换它们。

### `EPIC.md`

在 `minimal` 下且尚无 EPIC.md 时，用下面的表写入 Phase 2 草稿。
否则用该表替换其“Stories: Not yet created”行，或在
回访时每个新故事追加一行，文件其余部分保持
原样：

```markdown
## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | [title] | Logic | Ready | ADR-0001 |
| 002 | [title] | Integration | Blocked | ADR-0004 |
```

### `production/epics/index.md`

将史诗的 `Stories` 单元格设为 `[N] stories`，
即本次运行后史诗的故事总数。当文件不存在时，说明：
`Epics index not updated: production/epics/index.md absent`。

## Phase 8: 收尾

如果 `production/epics/` 中的其他史诗没有故事，列出它们。然后询问：
“[N] stories written to `production/epics/[epic-slug]/`. What next?” 选项为以下
适用者：

- 开始实现：在 `minimal` 下 `/dev-story [first-story-path]`，
  否则 `/story-readiness [first-story-path]`（推荐）
- 为 [next epic] 创建故事：`/create-stories [slug]`（仅当某个史诗
  还没有故事时）
- 规划冲刺：`/sprint-plan new`（仅当每个史诗都有故事时；绝不在
  `minimal` 下，那里简报的构建顺序就是计划）
- 本次会话到此为止

绝不开始实现或编写代码：本技能止于故事文件。
验收标准来自 GDD（`minimal` 下为简报），实现
笔记来自 ADR，规则来自清单；没有任何内容是编造的。

**本次运行的最后一个回复以此块结尾**，在上面的问题
得到回答之后（如果你之前展示过它，请重复）：

```
Verdict: COMPLETE — [N] stories written to production/epics/[epic-slug]/ ([N] Ready, [N] Blocked)
Review: [QL-STORY-READY skipped — Solo mode | skipped — Lean mode | its verdicts]
Index: [production/epics/index.md updated | Epics index not updated: production/epics/index.md absent]
Next step: [/dev-story [first-story-path] | /story-readiness [first-story-path]]
```

当用户拒绝写入时：`Verdict: BLOCKED — user declined. No story
files written.`