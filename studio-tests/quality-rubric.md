# 技能质量评分标准

供 `/skill-test category [name|all]` 在结构合规之外评估技能。
每个类别定义 4–5 个二值 PASS/FAIL 指标，针对该技能的具体职责。

当技能写明的指令清晰满足标准时，指标为 PASS。
当指令缺失、含糊或自相矛盾时，指标为 FAIL。
当指令部分满足标准时，指标为 WARN。
当完全无法评估时，指标为 NOT ASSESSED —— 评分标准中没有该类别
的章节，或技能/代理文件无法读取。

---

## 技能类别

### `gate`

**技能**：gate-check

闸门技能控制阶段转换。它们必须在不自动推进阶段的前提下强制正确性，
并必须尊重三种评审模式。

| 指标 | PASS 标准 |
|---|---|
| **G1 — 读取评审模式** | 技能在决定生成哪些总监前，从解析后的配置块读取 `review_mode`（以及 `workflow`）—— `modes.review_mode`、旧版 `production/review-mode.txt`，否则用 `modes.rigor` 的值 |
| **G2 — 总监小组规模** | 除非 `solo`，PHASE-GATE 小组按 `modes.workflow` 设定的规模并行运行 —— `minimal` 仅 PR，`standard` TD + PR，`full` 全部 4 个（CD、TD、PR、AD）—— 且输出要点明更窄小组遗漏的视角 |
| **G3 — lean 模式：仅 PHASE-GATE** | 在 `lean` 模式下，只运行 `*-PHASE-GATE` 闸门；内联闸门（CD-PILLARS、TD-ARCHITECTURE 等）跳过 |
| **G4 — solo 模式：无总监** | 在 `solo` 模式下，不生成任何总监闸门；每个都记为“skipped — Solo mode” |
| **G5 — 不自动推进** | 未经用户通过“May I”问题明确确认，技能绝不写入 `project.yaml` 中的 `project.stage` 或旧版 `production/stage.txt` |

---

### `review`

**技能**：design-review, architecture-review, review-all-gdds

评审技能读取文档并给出结构化结论。它们主要是只读的，不得在分析阶段
触发总监闸门。

| 指标 | PASS 标准 |
|---|---|
| **R1 — 只读约束** | 未经用户明确批准，技能不修改被评审文档；任何写操作（评审日志、索引更新）都以“May I write”为前提 |
| **R2 — 8 章节检查** | 技能明确评估全部 8 个必需 GDD 章节（或等价的架构章节） |
| **R3 — 正确的结论词汇** | 结论必须恰好是以下之一：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED / NOT ASSESSED（design-review、ux-review）或 PASS / CONCERNS / FAIL / NOT ASSESSED（architecture-review、review-all-gdds） |
| **R4 — 分析期间无总监闸门** | 技能在其分析阶段不生成总监闸门；当技能的范围和利害关系需要时，分析后的总监评审是可以接受的 |
| **R5 — 结构化发现** | 输出在最终结论前包含按章节的状态表或检查清单 |

> **例外：**
> - `design-review`：其正文允许 `Write, Edit`，用于支持可选的“Revise now”路径（所有写入都以用户批准为前提）并写入评审日志。R1 仍然满足，因为被评审文档绝不会被静默修改。

---

### `authoring`

**技能**：design-system, quick-design, architecture-decision, ux-design, ux-review, art-bible, create-architecture

编写技能协作创建或更新设计文档。完整的 GDD/UX 编写技能使用逐章节
循环；轻量编写技能使用适合其较小范围的单草稿模式。

| 指标 | PASS 标准 |
|---|---|
| **A1 — 逐章节循环** | 完整编写技能（design-system、ux-design、art-bible）一次编写一个章节，在继续下一节前提交内容供批准。轻量技能（quick-design、architecture-decision、create-architecture）可以先起草完整文档再请求批准 —— 对于实现范围约一周以内的文档，单草稿是可接受的。 |
| **A2 — 每节都询问可否写入** | 完整编写技能在写入每个章节前询问“May I write this to [filepath]?”。轻量技能对完整文档询问一次。 |
| **A3 — 改造模式** | 技能检测目标文件是否已存在，并提出更新特定章节而不是覆盖整个文档。总是创建新文件的轻量技能（quick-design）豁免。 |
| **A4 — 总监闸门在正确层级** | 如果为此技能定义了总监闸门（如 CD-GDD-ALIGN、TD-ADR），它只在 `full` 下运行；在 `lean` 和 `solo` 下跳过并附具名说明（`[GATE-ID] skipped — Lean mode` / `— Solo mode`） |
| **A5 — 骨架优先** | 完整编写技能在填充内容前创建包含所有章节标题的文件骨架，以便会话中断时保留进度。轻量技能豁免。 |

> **完整编写技能**（必须通过全部 5 个指标）：`design-system`、`ux-design`、`art-bible`
> **轻量编写技能**（A1、A2、A5 使用单草稿模式；仅新建文件的技能对 A3 豁免）：`quick-design`、`architecture-decision`、`create-architecture`
> **评审模式技能**（按评审指标评估）：`ux-review`

---

### `readiness`

**技能**：story-readiness, story-done

就绪度技能在实现前后验证用户故事。它们必须给出多维结论，并与总监
闸门模式正确集成。

| 指标 | PASS 标准 |
|---|---|
| **RD1 — 多维检查** | 技能检查 ≥3 个独立维度（如 Design、Architecture、Scope、DoD）并分别报告每个维度 |
| **RD2 — 四级结论** | 结论层级定义清晰，NOT ASSESSED 位于通过值与失败值之间：READY > NOT ASSESSED > NEEDS WORK > BLOCKED（story-readiness）；COMPLETE > COMPLETE WITH NOTES > NOT ASSESSED > BLOCKED（story-done） |
| **RD3 — BLOCKED 需要外部行动** | BLOCKED 结论仅用于故事作者无法独自解决的问题（如 Proposed 状态的 ADR、无法解决的依赖） |
| **RD4 — 总监闸门在正确模式** | QL-STORY-READY 或 LP-CODE-REVIEW 闸门在 `full` 模式下生成，在 `lean`/`solo` 下跳过并附跳过说明 |
| **RD5 — 下一故事交接** | 完成后，技能从当前冲刺中给出下一个 READY 故事。若没有冲刺计划，`/story-done` 点名构建顺序中的下一个故事，`/story-readiness` 说明未找到冲刺文件 |

---

### `pipeline`

**技能**：create-epics, create-stories, dev-story, create-control-manifest, propagate-design-change, map-systems, vertical-slice

流水线技能产出的产出物会被其他技能消费。它们必须按正确 schema 写文件，
尊重层级/优先级顺序，并在写入前设置闸门。

| 指标 | PASS 标准 |
|---|---|
| **P1 — 正确的输出 schema** | 每个产出文件遵循项目模板（EPIC.md、故事 frontmatter 等）；技能引用模板路径 |
| **P2 — 层级/优先级顺序** | 产出史诗或故事的技能尊重层级顺序（foundation → core → feature → presentation）和优先级字段 |
| **P3 — 每个产出物前询问可否写入** | 技能在创建输出文件前询问“May I write …?” —— 每个文件一个问题，或一次批准点名变更集中的每个文件；它绝不写入批准未点名的文件 |
| **P4 — 总监闸门在正确层级** | 范围内的闸门（PR-EPIC、QL-STORY-READY、LP-CODE-REVIEW 等）在 `full` 下运行，在 `lean`/`solo` 下跳过并附说明 |
| **P5 — 先读后写** | 技能在产出产出物前读取相关 GDD/ADR/清单，确保对齐 |

---

### `analysis`

**技能**：consistency-check, balance-check, content-audit, code-review, tech-debt,
scope-check, estimate, perf-profile, asset-audit, security-audit, test-evidence-review, test-flakiness

分析技能扫描项目并给出发现。它们在分析期间只读，且在任何建议写入
文件前必须询问。

| 指标 | PASS 标准 |
|---|---|
| **AN1 — 只读扫描** | 分析阶段不改变任何东西：扫描本身不包含 Write 或 Edit，也不包含会改变状态的 Bash（只读命令如 `git log` 或测量文件大小是可以的） |
| **AN2 — 结构化发现表** | 输出包含发现表或检查清单（不只是散文），每项发现带严重程度/优先级 |
| **AN3 — 不自动写入** | 任何建议的文件写入（如技术债登记、修复补丁）都以“May I write”为前提 |
| **AN4 — 分析期间无总监闸门** | 分析技能不生成总监闸门；它们产出发现供人工评审 |

---

### `team`

**技能**：team-combat, team-narrative, team-audio, team-level, team-ui, team-qa,
team-release, team-polish, team-live-ops

团队技能为某个部门编排多个专家代理。它们必须生成正确的代理，并行运行
彼此独立的代理，并立即暴露阻塞项。

| 指标 | PASS 标准 |
|---|---|
| **T1 — 具名代理列表** | 技能明确点名要生成哪些代理以及顺序 |
| **T2 — 独立时并行** | 输入互不依赖的代理并行生成（单条消息、多个 `Agent` 调用） |
| **T3 — 暴露 BLOCKED** | 若任何生成的代理返回 BLOCKED 或失败，技能立即暴露并停止依赖工作 —— 绝不静默跳过 |
| **T4 — 继续前收集所有结论** | 依赖阶段等待所有并行代理完成后才继续 |
| **T5 — 无参数时给出用法错误** | 若缺少必需参数（如功能名），技能要么输出用法提示并停止，要么推断参数（如发布版本、当前冲刺）并与用户确认 —— 两种情况都必须在生成任何代理前完成 |

---

### `sprint`

**技能**：sprint-plan, sprint-status, milestone-review, retrospective, changelog, patch-notes

冲刺技能读取生产状态并产出报告或计划产出物。它们在特定模式阈值下
设有 PR-SPRINT 或 PR-MILESTONE 闸门。

| 指标 | PASS 标准 |
|---|---|
| **SP1 — 读取冲刺/里程碑状态** | 技能在产出输出前读取 `production/sprints/` 或 `production/milestones/` |
| **SP2 — 正确的冲刺闸门** | PR-SPRINT（用于计划）或 PR-MILESTONE（用于里程碑评审）闸门在 `full` 模式下运行，在 `lean`/`solo` 下跳过 |
| **SP3 — 结构化输出** | 输出使用一致结构（速率表、风险列表、行动项），而不是自由散文 |
| **SP4 — 不自动提交** | 未经“May I write”，技能绝不写入冲刺文件或里程碑记录 |

---

### `utility`

**技能**：start, help, brainstorm, onboard, adopt, hotfix, prototype, localize,
launch-checklist, release-checklist, smoke-check, soak-test, test-setup, test-helpers,
regression-suite, qa-plan, bug-triage, bug-report, playtest-report, asset-spec,
reverse-document, project-stage-detect, setup-engine, skill-test, skill-improve,
day-one-patch，以及任何不在上述类别中的技能

通用技能通过 7 项标准静态检查。如果它们恰好会生成总监闸门，闸门模式
逻辑也必须正确。

| 指标 | PASS 标准 |
|---|---|
| **U1 — 通过全部 7 项静态检查** | `/skill-test static [name]` 返回 COMPLIANT 且 0 个 FAIL |
| **U2 — 闸门模式正确（如适用）** | 如果技能生成任何总监闸门，它读取评审模式并正确应用 full/lean/solo 逻辑 |

---

## 代理类别

供 `/skill-test category [agent-name]` 按类别指标评估
`.trae/agents/` 中的代理定义。

没有任何类别固定模型。Trae 中模型由当前会话或子代理配置决定，`.trae/agents/` 的
frontmatter 不含 `model:`；其 `agents/` 下的规格断言该字段不存在；见
`.trae/docs/model-tiers.md`。

### `director`

**代理**：creative-director, technical-director, art-director, producer

| 指标 | PASS 标准 |
|---|---|
| **D1 — 正确的结论词汇** | 第一行返回 `[GATE-ID]: [word]`，该词取自被调用闸门的 **Verdicts** 行 —— 或当闸门点名的输入未提供时返回 `NOT ASSESSED` 并点名缺失输入 |
| **D2 — 尊重领域边界** | 不在其声明领域之外做出有约束力的决策 |
| **D3 — 冲突上报** | 当两个部门冲突时，上报给正确的上级（creative-director 或 technical-director），而不是单方面决定 |

### `lead`

**代理**：lead-programmer, qa-lead, narrative-director, audio-director, game-designer,
systems-designer, level-designer

| 指标 | PASS 标准 |
|---|---|
| **L1 — 闸门结论或发现** | 为闸门调用的主管（lead-programmer 的 LP-、qa-lead 的 QL-、narrative-director 的 ND- 闸门）返回该闸门的 **Verdicts** 词汇 —— 或 `NOT ASSESSED` 并点名缺失输入；没有闸门的主管返回发现，把结论留给调用技能 |
| **L2 — 上报给共同上级** | 领域外冲突上报给 creative-director（设计）或 technical-director（技术） |

### `specialist`

**代理**：gameplay-programmer, ai-programmer, technical-artist, sound-designer,
engine-programmer, tools-programmer, network-programmer, security-engineer,
accessibility-specialist, ux-designer, ui-programmer, performance-analyst, prototyper,
writer, world-builder

| 指标 | PASS 标准 |
|---|---|
| **S1 — 留在领域内** | 明确把自己限定在声明领域内；把领域外请求转交出去 |
| **S2 — 不做有约束力的跨领域决策** | 不单方面决定属于其他专家的事项 |
| **S3 — 正确转交** | 领域外请求被重定向到正确的代理，而不是静默拒绝 |

### `engine`

**代理**：godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
godot-shader-specialist, godot-gdextension-specialist, unity-specialist, unity-ui-specialist,
unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist,
unreal-specialist, ue-blueprint-specialist, ue-gas-specialist, ue-umg-specialist,
ue-replication-specialist

| 指标 | PASS 标准 |
|---|---|
| **E1 — 版本感知** | 在建议 API 调用前引用 `docs/engine-reference/` 中的引擎版本；标记截止日期之后的风险 |
| **E2 — 文件路由** | 把文件类型路由到正确的子专家（如 `.gdshader` → godot-shader-specialist，而不是 godot-gdscript-specialist） |
| **E3 — 引擎特定模式** | 强制执行引擎特定惯例（如 GDScript 静态类型、C# 属性导出、蓝图函数库） |

### `qa`

**代理**：qa-tester

| 指标 | PASS 标准 |
|---|---|
| **Q1 — 产出产出物而非代码** | 主要输出是测试用例、bug 报告或覆盖率缺口 —— 不是实现代码 |
| **Q2 — 证据格式** | 测试用例遵循项目的测试证据格式（按 coding-standards.md 分为单元/集成/视觉/UI） |
| **Q3 — 不扩大范围** | 不提议新功能；把缺口标记出来供人决定 |

### `operations`

**代理**：devops-engineer, release-manager, live-ops-designer, community-manager,
analytics-engineer, economy-designer, localization-lead

| 指标 | PASS 标准 |
|---|---|
| **O1 — 领域归属清晰** | 代理描述清楚说明它拥有什么（流水线、发布、经济等） |
| **O2 — 转交实现** | 不编写游戏逻辑或引擎代码；委托给合适的专家 |
| **O3 — 工具集匹配角色** | frontmatter 中的 `tools:` 匹配该角色的运营（而非编码）性质 |
