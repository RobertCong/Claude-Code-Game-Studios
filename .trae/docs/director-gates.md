# Director Gates — 共享评审模式

所有总监与主管评审闸门的索引。技能从本索引引用闸门 ID，而不是把提示词内联 —
这样提示词需要更新时不会出现漂移。每个闸门的完整定义（Trigger、Context to pass、
Prompt、Verdicts）位于 `.claude/docs/director-gates/` 下一组独立文件中，文件名即
闸门 ID 的小写形式。

**范围**：全部 7 个制作阶段（Concept → Release），全部 3 位 Tier 1 总监，
所有关键 Tier 2 主管。任何技能、团队编排器或工作流都可以调用这些闸门。

**当某个技能为某个闸门派生总监时，它绝不能自己去读闸门定义文件。把闸门定义文件
的路径写进 `Agent` 提示词，并指示总监代理先读它，然后只传入该闸门所在行要求的
上下文字段。闸门定义由被派生的代理在其自身的上下文窗口中读取。**

---

## 闸门索引

按前缀识别代理：`CD-` creative-director · `TD-` technical-director ·
`PR-` producer · `AD-` art-director · `LP-` lead-programmer · `QL-` qa-lead ·
`ND-` narrative-director。下列定义文件位于
`.claude/docs/director-gates/`；每个文件的头部注明其所属代理的模型层级。

| 闸门 ID | 用途 | 定义文件 |
|---------|---------|-----------------|
| CD-PILLARS | 游戏支柱确定后的支柱压力测试 | cd-pillars.md |
| CD-GDD-ALIGN | 某个系统 GDD 编写完成后的 GDD 支柱对齐检查 | cd-gdd-align.md |
| CD-SYSTEMS | `/map-systems` 之后的系统分解愿景检查 | cd-systems.md |
| CD-NARRATIVE | 故事/设定文档的叙事一致性检查 | cd-narrative.md |
| CD-PLAYTEST | 试玩测试报告的玩家体验验证 | cd-playtest.md |
| CD-PHASE-GATE | 阶段转换时的创意就绪度检查 | cd-phase-gate.md |
| TD-SYSTEM-BOUNDARY | GDD 编写之前的系统边界评审 | td-system-boundary.md |
| TD-FEASIBILITY | 早期概念风险的技术可行性评估 | td-feasibility.md |
| TD-ARCHITECTURE | 主架构文档的签署确认 | td-architecture.md |
| TD-ADR | 单份 ADR 在标记为 Accepted 之前的评审 | td-adr.md |
| TD-ENGINE-RISK | 超出模型知识截止时间的 API 的引擎版本风险 | td-engine-risk.md |
| TD-PHASE-GATE | 阶段转换时的技术就绪度检查 | td-phase-gate.md |
| TD-MANIFEST | 控制清单写入之前的评审 | td-manifest.md |
| TD-CHANGE-IMPACT | 设计变更影响评估的评审 | td-change-impact.md |
| PR-SCOPE | 范围与时间线验证 | pr-scope.md |
| PR-SPRINT | 冲刺计划可行性评审 | pr-sprint.md |
| PR-MILESTONE | 里程碑风险评估 | pr-milestone.md |
| PR-EPIC | 故事拆分之前的史诗结构可行性 | pr-epic.md |
| PR-PHASE-GATE | 阶段转换时的制作就绪度检查 | pr-phase-gate.md |
| AD-CONCEPT-VISUAL | 游戏支柱锁定后的视觉识别锚点 | ad-concept-visual.md |
| AD-ART-BIBLE | 资源生产之前的美术圣经签署确认 | ad-art-bible.md |
| AD-PHASE-GATE | 阶段转换时的视觉就绪度检查 | ad-phase-gate.md |
| LP-FEASIBILITY | 架构的实现可行性 | lp-feasibility.md |
| LP-CODE-REVIEW | 已实现的用户故事的代码评审 | lp-code-review.md |
| QL-STORY-READY | 冲刺之前验收标准的可测试性检查 | ql-story-ready.md |
| QL-TEST-COVERAGE | 某个用户故事关闭前的测试覆盖率评审（`/story-done`） | ql-test-coverage.md |
| ND-CONSISTENCY | 编剧产出物的叙事一致性检查 | nd-consistency.md |
| AD-VISUAL | 美术/技术美术决策的视觉一致性检查 | ad-visual.md |

---

## 评审模式

评审强度决定闸门是否运行。

**全局配置**：`project.yaml` 中的 `modes.review_mode` — 取值只有一个词：`full`、
`lean` 或 `solo`。旧版回退：`production/review-mode.txt`（单行，取值相同）；
两者同时存在时 `project.yaml` 优先。`/start` 从不写入它：保持未设置时，它跟随
`modes.rigor`（`minimal` → `solo`，`standard` → `lean`，`full` → `full`）。仅在
`/settings modes.review_mode=<value>` 时显式设置。

**单次运行覆盖**：任何使用闸门的技能都接受 `--review [full|lean|solo]`，
仅覆盖该次运行的全局配置。

| 模式 | 运行内容 |
|------|-----------|
| `full` | 所有闸门启用 — 每个工作流步骤都评审 |
| `lean` | 仅 PHASE-GATE（`/gate-check`）— 跳过分技能闸门。对应 `rigor: standard` 的值 |
| `solo` | 任何地方都不运行总监闸门（游戏创作活动、原型、最快速度）。**默认值** — 对应 `rigor: minimal` 的值 |

**一个例外：** 只要 narrative-director 在团队中，`/team-narrative` 在任何评审模式下
都会运行 ND-CONSISTENCY — 它是该流水线唯一的叙事一致性检查，不是可选的评审。

---

## 调用模式（可复制到任何技能中）

**强制要求：每次派生闸门之前都要应用评审模式。**

该值已经解析完成 — 技能调用
`` !`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode` ``
（并授予对应的 `allowed-tools` 权限 — 见 `config-resolution.md`），
然后从输出的块中读取 `review_mode`。不要在技能里重新推导它。完整链路
（`project.local.yaml` → `project.yaml` → `production/review-mode.txt`
→ `modes.rigor` 展开，`standard`→`lean`）、其默认值及失败模式在
`.claude/docs/config-resolution.md` 中说明，并由配置测试套件覆盖。

若技能接受内联 `--review [mode]` 参数，则该参数覆盖本次运行解析出的值。

应用解析出的模式：
- `solo` → **跳过所有闸门**。记录：`[GATE-ID] skipped — Solo mode`
- `lean` → **除非这是 PHASE-GATE，否则跳过**（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）。记录：`[GATE-ID] skipped — Lean mode`
- `full` → 正常派生

> **PHASE-GATE 的评审面板宽度是第二个独立维度。** `review_mode` 决定四个
> PHASE-GATE 是否运行；`modes.workflow` 决定其中多少个运行 — `minimal` → 仅 PR，
> `standard` → TD + PR，`full` → 全部四个。该规则及其理由位于 `/gate-check`
> 第 4b 节，它是唯一派生 PHASE-GATE 的技能。本索引中其他闸门都是单总监闸门，
> 不受影响。宽度永远不会软化结论：下面的升级规则对实际运行的评审者同样适用。

```
# Apply mode check, then:
Spawn `[agent-name]` via `Agent`:
- Gate: [GATE-ID] — `Agent` prompt instructs the agent to read
  `.claude/docs/director-gates/[gate-id].md` FIRST (parent must not read it)
- Context: [fields under that gate's **Context to pass**]
- Await the verdict before proceeding.
```

对于并行派生（在一个闸门点上派生多位总监）：对每个闸门分别应用模式检查，
然后同时派生所有存活的代理 — 在等待任何结果之前发出全部 `Agent` 调用；
在继续之前收集所有结论。

---

## 标准结论格式

每个闸门返回其三种结论之一 — 或在无法判断时返回 NOT ASSESSED。技能必须处理
全部四种情况。三个判断词由各闸门自定义 — 以其定义文件中的 **Verdicts** 行为准 —
下表的行说明它们的含义（TD-FEASIBILITY 的 VIABLE / CONCERNS / HIGH RISK，
PR-MILESTONE 的 ON TRACK / AT RISK / OFF TRACK）。NOT ASSESSED 是每个闸门都
相同的词，因此没有 Verdicts 行列出它：

| 结论 | 含义 | 默认动作 |
|---------|---------|----------------|
| **APPROVE / READY** | 无问题。继续。 | 继续工作流 |
| **CONCERNS [list]** | 存在问题但不阻塞。 | 通过 `AskUserQuestion` 呈现给用户 — 选项：`Revise flagged items` / `Accept and proceed` / `Discuss further`。Revise flagged items：起草该章节的专家重新起草；修订走技能正常的先批准后写入步骤，并在头部记录 `REVISED [date]`。 |
| **REJECT / NOT READY [blockers]** | 存在阻塞问题。不要继续。 | 向用户呈现阻塞项。在问题解决之前不要写文件或推进阶段。 |
| **NOT ASSESSED [what was missing]** | 闸门指定的一项输入缺失或无法读取，因此未做判断。 | 说明缺失了什么。绝不要把它当作 APPROVE/READY：补齐输入后重新运行闸门，或记录 NOT ASSESSED 并让技能自身的结论体现这一点。 |

**排序**：NOT ASSESSED 位于 REJECT / NOT READY 和 CONCERNS 之下、APPROVE / READY
之上 — 已知问题比未知问题更可操作，而一个无法查看的闸门没有批准任何东西。
发现问题的总监若同时缺少输入，应使用问题对应的结论词，并在理由中说明缺失的输入。
技能报告为缺失的产出物是信息，而不是缺失输入。在阶段闸门上，目标阶段所需的产出物
缺失属于发现项（NOT READY 或 CONCERNS）；被 `/gate-check` 判定为 "not expected
before [phase]" 或 "not required at `workflow: [tier]`" 的则不是发现项 — 阶段闸门
判断的是即将进入阶段的就绪度，而不是更后阶段。

**升级规则**：多个总监并行派生时，按上述排序取最严格的结论 — 一个 NOT READY
覆盖所有 READY 结论，一个 NOT ASSESSED 使结果无法成为 READY。

---

## 记录闸门结果

闸门结束后，在相关文档的状态头部记录结论：

```markdown
> **[Director] Review ([GATE-ID])**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date] / NOT ASSESSED [date] — [missing input]
```

对于阶段闸门，按情况记录到 `docs/architecture/architecture.md` 或
`production/session-state/active.md`。

---

## 并行闸门协议

在需要多位总监的检查点上（最常见于 `/gate-check`）：

```
Spawn in parallel (issue all `Agent` calls before waiting for any result):
creative-director → CD-PHASE-GATE, technical-director → TD-PHASE-GATE,
producer → PR-PHASE-GATE, art-director → AD-PHASE-GATE

Collect every verdict from the directors that ran, then apply escalation rules:
- Any NOT READY / REJECT → overall verdict minimum FAIL
- Any CONCERNS → overall verdict minimum CONCERNS
- Any NOT ASSESSED (and no NOT READY / REJECT or CONCERNS) → overall verdict at best NOT ASSESSED
- All READY / APPROVE → eligible for PASS (still subject to artifact checks)
```

---

## 各阶段的闸门覆盖

| 阶段 | 必需闸门 | 可选闸门 |
|-------|---------------|----------------|
| **Concept** | CD-PILLARS、AD-CONCEPT-VISUAL | TD-FEASIBILITY、PR-SCOPE |
| **Systems Design** | TD-SYSTEM-BOUNDARY、CD-SYSTEMS、PR-SCOPE、CD-GDD-ALIGN（每份 GDD） | ND-CONSISTENCY、AD-VISUAL、TD-CHANGE-IMPACT（GDD 修订时） |
| **Technical Setup** | TD-ARCHITECTURE、TD-ADR（每份 ADR）、TD-MANIFEST、LP-FEASIBILITY、AD-ART-BIBLE | TD-ENGINE-RISK |
| **Pre-Production** | PR-EPIC、QL-STORY-READY（每个用户故事）、PR-SPRINT、PHASE-GATE 面板（通过 gate-check — `minimal` 时仅 PR，`standard` 时 TD + PR，`full` 时全部四个） | CD-PLAYTEST |
| **Production** | LP-CODE-REVIEW（每个用户故事）、QL-STORY-READY、PR-SPRINT（每个冲刺）、QL-TEST-COVERAGE（每个用户故事，通过 `/story-done`） | PR-MILESTONE、AD-VISUAL、TD-CHANGE-IMPACT（GDD 修订时） |
| **Polish** | CD-PLAYTEST、PR-MILESTONE | AD-VISUAL |
| **Release** | PHASE-GATE 面板（通过 gate-check — `minimal` 时仅 PR，`standard` 时 TD + PR，`full` 时全部四个） | — |
