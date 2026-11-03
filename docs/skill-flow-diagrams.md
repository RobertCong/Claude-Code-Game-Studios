# 技能流程图

技能在 7 个开发阶段中如何串联的可视化地图。
这些图展示每个技能之前和之后运行什么，以及它们之间流转哪些产出物。

---

## 默认路径：Minimal 严格度（四步到代码）

`modes.rigor: minimal` 是默认值。一页纸简报就是设计记录，
其构建顺序就是计划，因此没有史诗规划、冲刺或阶段闸门需要运行。
下面每个技能在任何档位下仍可运行；严格度改变的是要求什么，
而不是允许什么。在 `minimal` 下，`/help` 遵循这条路线。

```
MINIMAL PATH (modes.rigor: minimal — the default; no /gate-check, stage stays Concept)
  /setup-engine ───────────────────────────────────────────────► project.yaml + AGENTS.md
  /brainstorm ─────────────────────────────────────────────────► design/game-brief.md (one page)
        │                                                          (replaces concept doc, systems index, GDDs)
        ▼
  /create-stories ─────────────────────────────────────────────► production/epics/[slug]/story-*.md
        │                                                          (brief's build order is the plan —
        │                                                           no /create-epics, no /sprint-plan)
        ▼ (one story at a time, in build order)
  /dev-story [story] ──────────────────────────────────────────► routes to correct programmer agent
  /story-done [story] ─────────────────────────────────────────► story closed + next story named
        │
        └── back to /dev-story until every story is Complete, then:
              play the build · /create-stories for more · /settings to raise rigor
```

下面的概览是 `standard`/`full` 流水线。

---

## 完整流水线概览（从零到发布）

```
PHASE 1: CONCEPT
  /start ──────────────────────────────────────────────────────► routes to A/B/C/D
  /brainstorm ──────────────────────────────────────────────────► design/gdd/game-concept.md
  /setup-engine ────────────────────────────────────────────────► project.yaml + AGENTS.md
  /prototype [core-mechanic] ───────────────────────────────────► prototypes/[name]-concept/REPORT.md
        │ PROCEED                                                  (validate idea BEFORE writing GDDs)
        ▼
  /design-review [game-concept.md] ────────────────────────────► concept validated
  /art-bible ──────────────────────────────────────────────────► design/art/art-bible.md
  /map-systems ────────────────────────────────────────────────► design/gdd/systems-index.md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to systems-design
        │
        ▼
PHASE 2: SYSTEMS DESIGN
  /map-systems next ───────────────────────────────────────────► picks the next system to design
        │
        ▼ (for each system, in dependency order)
  /design-system [name] ──────────────────────────────────────► design/gdd/[system].md
  /design-review [system].md ─────────────────────────────────► per-GDD review comments
        │
        ▼ (after all MVP GDDs done)
  /review-all-gdds ────────────────────────────────────────────► design/gdd/gdd-cross-review-[date].md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to technical-setup
        │
        ▼
PHASE 3: TECHNICAL SETUP
  /create-architecture ────────────────────────────────────────► docs/architecture/architecture.md
  /architecture-decision (×N) ─────────────────────────────────► docs/architecture/[adr-nnn].md
  /architecture-review ────────────────────────────────────────► review report + docs/architecture/tr-registry.yaml
  /create-control-manifest ────────────────────────────────────► docs/architecture/control-manifest.md
  /test-setup ─────────────────────────────────────────────────► test framework + CI/CD pipeline
  /test-helpers ───────────────────────────────────────────────► tests/helpers/ (engine-specific library)
  /ux-design accessibility ─────────────────────────────────────► design/accessibility-requirements.md
  /ux-design patterns ──────────────────────────────────────────► design/ux/interaction-patterns.md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to pre-production
        │
        ▼
PHASE 4: PRE-PRODUCTION
  [UX — before epics, so specs exist when stories are written]
  /ux-design [screen/hud] ──────────────────────────────────────► design/ux/*.md
  /ux-review ──────────────────────────────────────────────────► UX specs approved (HARD gate for /team-ui)

  [Vertical slice — before epics, validate full game loop]
  /vertical-slice ─────────────────────────────────────────────► prototypes/[name]-vertical-slice/REPORT.md
  /playtest-report ────────────────────────────────────────────► production/qa/playtests/

  [Stories + sprint plan — only after vertical slice PROCEEDS]
  /create-epics [layer] ───────────────────────────────────────► production/epics/*/EPIC.md
  /create-stories [epic-slug] ─────────────────────────────────► production/epics/*/story-*.md
  /sprint-plan new ────────────────────────────────────────────► production/sprints/sprint-001.md
  /gate-check ─────────────────────────────────────────────────► PASS → advance to production
        │
        ▼
PHASE 5: PRODUCTION (repeating sprint loop)
  /sprint-status ──────────────────────────────────────────────► sprint snapshot
  /story-readiness [story] ────────────────────────────────────► story validated READY
        │
        ▼ (pick up and implement)
  /dev-story [story] ──────────────────────────────────────────► routes to correct programmer agent
        │
        ▼ (during implementation, as needed)
  /code-review ────────────────────────────────────────────────► code review report
  /scope-check ────────────────────────────────────────────────► scope creep detected / clear
  /content-audit ──────────────────────────────────────────────► GDD content gaps identified
  /bug-report ─────────────────────────────────────────────────► production/qa/bugs/BUG-NNNN.md
  /bug-triage ─────────────────────────────────────────────────► bugs re-prioritized + assigned

  [Team skills for feature areas — spawn when working a full feature]
  /team-combat / /team-narrative / /team-ui / /team-level / /team-audio

  [QA cycle per sprint]
  /qa-plan ────────────────────────────────────────────────────► production/qa/qa-plan-[sprint-slug]-[date].md
  /smoke-check ────────────────────────────────────────────────► smoke test gate (PASS/FAIL)
  /regression-suite ───────────────────────────────────────────► coverage gaps + missing regression tests
  /test-evidence-review ───────────────────────────────────────► evidence quality report
  /test-flakiness ─────────────────────────────────────────────► flaky test report
        │
        ▼
  /story-done [story] ─────────────────────────────────────────► story closed + next surfaced
  /sprint-plan [next] ─────────────────────────────────────────► next sprint
        │
        ▼ (after Production milestone)
  /milestone-review ───────────────────────────────────────────► milestone report
  /gate-check ─────────────────────────────────────────────────► PASS → advance to polish
        │
        ▼
PHASE 6: POLISH
  /perf-profile ───────────────────────────────────────────────► perf report + fixes
  /balance-check ──────────────────────────────────────────────► balance report + fixes
  /asset-audit ────────────────────────────────────────────────► asset compliance report
  /tech-debt ──────────────────────────────────────────────────► docs/tech-debt-register.md
  /soak-test ──────────────────────────────────────────────────► soak test protocol + results
  /team-polish ────────────────────────────────────────────────► polish sprint orchestrated
  /team-qa ────────────────────────────────────────────────────► full QA cycle sign-off
  /security-audit ─────────────────────────────────────────────► production/security/security-audit-[date]-[scope].md
  /localize qa ────────────────────────────────────────────────► production/localization/loc-qa-[locale]-[date].md
  /release-checklist ──────────────────────────────────────────► production/releases/release-checklist-[version].md
  /changelog ──────────────────────────────────────────────────► docs/CHANGELOG.md
  /patch-notes ────────────────────────────────────────────────► docs/patch-notes/[version].md (draft)
  /gate-check ─────────────────────────────────────────────────► PASS → advance to release
        │
        ▼
PHASE 7: RELEASE
  /launch-checklist ───────────────────────────────────────────► launch readiness report
  /team-release ───────────────────────────────────────────────► release pipeline orchestrated
        │
        ▼ (post-launch, ongoing)
  /hotfix ─────────────────────────────────────────────────────► emergency fix with audit trail
  /team-live-ops ──────────────────────────────────────────────► live-ops content plan
```

---

## 技能链：/design-system 详解

单个 GDD 如何被编写、评审并交接给架构阶段：

```
systems-index.md (input)
game-concept.md (input)
upstream GDDs (input, if any)
        │
        ▼
/design-system [name]
        │
        ├── Pre-check: feasibility table + engine risk flags
        │
        ├── Section cycle × 8:
        │     question → options → decision → draft → approval → WRITE
        │     [each section written to file immediately after approval]
        │
        └── Output: design/gdd/[system].md (complete, all 8 sections)
                │
                ▼
        /design-review design/gdd/[system].md
                │
                ├── APPROVED → mark DONE in systems-index, proceed to next system
                ├── NEEDS REVISION → agent shows specific issues, re-enter section cycle
                └── MAJOR REVISION → significant redesign needed before next system
                        │
                        ▼ (after all MVP GDDs + cross-review)
                /review-all-gdds
                        │
                        └── Output: gdd-cross-review-[date].md
```

---

## 技能链：UX / UI 流水线详解

界面和 HUD 规格在 Phase 4（预制作）编写，早于史诗编写，
这样用户故事的验收标准就能引用具体的 UX 产出物。
无障碍和交互模式规格更早编写，在 Phase 3
（技术搭建）中，因为在 `full` 下技术搭建 → 预制作闸门
要求它们（`standard` 下为推荐；`minimal` 下被删减）。

```
design/gdd/*.md (UI/UX requirements extracted)
design/player-journey.md (emotional arc, if authored)
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → UX specs ready, proceed to /create-epics
        ├── NEEDS REVISION → blocking issues listed → fix → re-run review
        └── MAJOR REVISION → fundamental UX problems → redesign before epics
                │
                ▼ (after APPROVED — in Phase 5 when implementing UI features)
        /team-ui
                │
                ├── Phase 1: /ux-design (if any specs still missing) + /ux-review
                ├── Phase 2: visual design (art-director)
                ├── Phase 3: layout implementation (ui-programmer)
                ├── Phase 4: accessibility audit (accessibility-specialist)
                └── Phase 5: final review

Note: /ux-design accessibility and /ux-design patterns belong in Phase 3
      (Technical Setup); /ux-design screen/hud and /ux-review belong in Phase 4
      (Pre-Production). /team-ui belongs in Phase 5 (Production) when a UI
      feature is being built.
```

---

## 技能链：Dev Story 流程详解

用户故事如何从待办列表走向关闭：

```
/story-readiness [story]
        │
        ├── READY → Status: ready-for-dev → pick up for implementation
        ├── NEEDS WORK → agent shows specific gaps → resolve → re-run readiness
        └── BLOCKED → ADR still Proposed, or upstream story incomplete
                │
                ▼ (after READY)
        /dev-story [story]
                │
                ├── Reads: story file, linked GDD requirement, ADR decisions, control manifest
                ├── Routes to: gameplay-programmer / engine-programmer / ui-programmer / etc.
                │
                └── Implementation begins
                        │
                        ▼ (optional, during/after implementation)
                /code-review          → architectural review of changeset
                /scope-check          → verify no scope creep vs. original story criteria
                /test-evidence-review → validate test files and manual evidence quality
                        │
                        ▼
                /story-done [story]
                        │
                        ├── COMPLETE → Status: Complete, sprint-status.yaml updated, next story surfaced
                        ├── COMPLETE WITH NOTES → complete but some criteria deferred (logged)
                        └── BLOCKED → acceptance criteria cannot be verified → investigate blocker
```

---

## 技能链：用户故事生命周期（从待办到关闭）

用户故事如何从待办列表走向关闭（概览视图）：

```
/create-epics [layer]
        │
        └── Output: production/epics/[slug]/EPIC.md
                │
                ▼
        /create-stories [epic-slug]
                │
                └── Output: production/epics/[slug]/story-NNN-[slug].md
                            (Status: Ready or Blocked if ADR is Proposed)
                │
                ▼
        /story-readiness [story]
                │
                ├── READY → /dev-story → implement → /story-done
                ├── NEEDS WORK → resolve gaps → re-run
                └── BLOCKED → fix upstream dependency first
```

---

## 技能链：QA 流水线详解

```
[Phase 3 — one-time infrastructure setup]
/test-setup ────────────────────────────────────────────────────► test framework scaffolded + CI/CD wired
/test-helpers ──────────────────────────────────────────────────► tests/helpers/ (GDUnit4, NUnit, etc.)

[Phase 5 — per-sprint QA cycle]
/qa-plan [sprint or feature]
        │
        ├── Reads: story files, GDDs, acceptance criteria
        ├── Classifies each story by test type:
        │     Logic → automated unit test (BLOCKING by default)
        │     Integration → integration test or documented playtest (BLOCKING by default)
        │     Visual/Feel → retained screenshot + lead sign-off (BLOCKING by default)
        │     UI → retained screenshot of each screen (BLOCKING by default)
        │     Config/Data → smoke check (ADVISORY by default)
        │     (gate levels are overridable per type via testing.strict in project.yaml)
        └── Output: production/qa/qa-plan-[sprint-slug]-[date].md
                │
                ▼
        /smoke-check
                │
                ├── PASS → QA hand-off cleared
                └── FAIL → block sprint close → fix critical paths first
                        │
                        ▼
                /regression-suite
                        │
                        └── Coverage gaps + list of fixed bugs without regression tests
                                │
                                ▼
                        /test-evidence-review
                                │
                                └── Validates evidence quality, not just existence
                                        │
                                        ▼ (if CI run history available)
                        /test-flakiness
                                │
                                └── Flaky test report + fix recommendations

[Phase 6 — extended stability testing]
/soak-test ─────────────────────────────────────────────────────► soak test protocol + observed results
/team-qa ───────────────────────────────────────────────────────► full QA cycle sign-off for release gate

[Ongoing — bug management]
/bug-report ────────────────────────────────────────────────────► production/qa/bugs/BUG-NNNN.md
/bug-triage ────────────────────────────────────────────────────► open bugs re-prioritized + assigned

[Meta — harness validation]
/skill-test [lint|spec|catalog] ────────────────────────────────► skill file structural + behavioral check
```

---

## 存量项目上手流程

对于已有工作的项目（使用 `/start` 的选项 D 或直接运行）：

```
/project-stage-detect    → stage detection report
        │
        ▼
/adopt
        │
        ├── Phase 1: detect what exists
        ├── Phase 2: FORMAT audit (not just existence)
        ├── Phase 3: classify gaps (BLOCKING / HIGH / MEDIUM / LOW)
        ├── Phase 4: ordered migration plan
        ├── Phase 5: write docs/adoption-plan-[date].md
        └── Phase 6: fix most urgent gap inline (optional)
                │
                ▼
        /design-system retrofit [path]    → fills missing GDD sections
        /architecture-decision retrofit [path] → fills missing ADR sections
        /gate-check                       → where are you in the pipeline?
```

---

## 如何阅读这些图

| 符号 | 含义 |
|--------|---------|
| `──►` | 产出该产出物 |
| `│ ▼` | 流入下一步 |
| `├──` | 分支（多种可能结果） |
| `×N` | 运行 N 次（每个系统、用户故事等各一次） |
| `(input)` | 被技能读取，但不在此处产出 |
| `[optional]` | 通过闸门并不需要 |
| `WRITE`（大写） | 立即写入磁盘的文件 |

---

## 常见入口点

| 你所在的位置 | 运行这个 |
|---------------|---------|
| 全新开始，没有想法 | `/start` → `/brainstorm` |
| 已有概念，没有引擎 | `/setup-engine` |
| 已有概念 + 引擎 | `/map-systems` |
| 系统设计进行中 | `/design-system [next system]` 或 `/map-systems next` |
| 所有 GDD 已完成 | `/review-all-gdds` → `/gate-check` |
| 处于技术搭建阶段 | `/create-architecture` → `/architecture-decision` |
| 开始 UX 设计 | `/ux-design screen [name]` 或 `/ux-design hud` |
| 搭建测试 | `/test-setup` → `/test-helpers` |
| 已有用户故事，准备写代码 | `/story-readiness [story]` → `/dev-story [story]` |
| 用户故事完成 | `/story-done [story]` |
| 为冲刺运行 QA | `/qa-plan` → `/smoke-check` → `/regression-suite` |
| 缺陷待办需要排序 | `/bug-triage` |
| 扩展稳定性测试 | `/soak-test` |
| 不确定 | `/help` |
| 现有项目 | `/adopt` |
