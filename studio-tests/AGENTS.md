# Studio Tests —— Trae 指令

本文件夹是 Claude Code Game Studios 技能/代理框架的质量保证层。它自成一体，与任何游戏项目分离。

## 关键文件

| 文件 | 用途 |
|------|---------|
| `catalog.yaml` | 全部 74 个技能与 49 个代理的主注册表。包含类别、规格路径和最近测试跟踪字段。运行任何测试命令时始终先读它。 |
| `quality-rubric.md` | 按类别划分的通过/失败指标。运行 `/skill-test category` 时，读取该技能类别对应的 `###` 章节。 |
| `skills/[category]/[name].md` | 技能的行为规格 —— 5 个或更多测试用例 + 协议合规断言。 |
| `agents/[tier]/[name].md` | 代理的行为规格 —— 5 个或更多测试用例 + 协议合规断言。 |
| `templates/skill-test-spec.md` | 编写新技能规格文件的模板。 |
| `templates/agent-test-spec.md` | 编写新代理规格文件的模板。 |
| `results/` | 保存结果时由 `/skill-test spec` 写入。未被 gitignore —— 若要避免结果进入提交，请把它加入 `.gitignore`。 |

## 路径约定

- 技能规格：`studio-tests/skills/[category]/[name].md`
- 代理规格：`studio-tests/agents/[tier]/[name].md`
- 目录：`studio-tests/catalog.yaml`
- 评分标准：`studio-tests/quality-rubric.md`

`catalog.yaml` 中的 `spec:` 字段是每个技能/代理规格的权威路径。
始终读取它，而不是猜测路径。

## 技能类别

```
gate        → gate-check
review      → design-review, architecture-review, review-all-gdds
authoring   → design-system, quick-design, architecture-decision, art-bible,
              create-architecture, ux-design, ux-review
readiness   → story-readiness, story-done
pipeline    → create-epics, create-stories, dev-story, create-control-manifest,
              propagate-design-change, map-systems, vertical-slice
analysis    → consistency-check, balance-check, content-audit, code-review,
              tech-debt, scope-check, estimate, perf-profile, asset-audit,
              security-audit, test-evidence-review, test-flakiness
team        → team-combat, team-narrative, team-audio, team-level, team-ui,
              team-qa, team-release, team-polish, team-live-ops
sprint      → sprint-plan, sprint-status, milestone-review, retrospective,
              changelog, patch-notes
utility     → all remaining skills
```

## 代理层级

```
directors      → creative-director, technical-director, producer, art-director
leads          → lead-programmer, narrative-director, audio-director, game-designer,
                 systems-designer, level-designer, qa-lead
specialists    → gameplay-programmer, engine-programmer, network-programmer,
                 ai-programmer, tools-programmer, ui-programmer, ux-designer,
                 technical-artist, sound-designer, performance-analyst, prototyper,
                 writer, world-builder
engine/godot   → godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
                 godot-shader-specialist, godot-gdextension-specialist
engine/unity   → unity-specialist, unity-ui-specialist, unity-shader-specialist,
                 unity-dots-specialist, unity-addressables-specialist
engine/unreal  → unreal-specialist, ue-gas-specialist, ue-replication-specialist,
                 ue-umg-specialist, ue-blueprint-specialist
operations     → devops-engineer, release-manager, live-ops-designer,
                 community-manager, analytics-engineer, economy-designer,
                 localization-lead
qa             → qa-tester, security-engineer, accessibility-specialist
```

层级是规格文件所在的目录。评分标准类别是代理在 `catalog.yaml` 中的
`category:`，两者可以不同：`security-engineer` 和
`accessibility-specialist` 位于 `qa/` 下，但按 `specialist` 评级。

## 测试技能或代理的工作流

1. 读取 `catalog.yaml` 获取 `spec:` 路径和 `category:` —— 技能从
   `skills:` 条目读取，代理从 `agents:` 条目读取
2. 读取技能 `.trae/skills/[name]/SKILL.md` 及其 `references/` 文件夹中的
   每个文件，或读取代理 `.trae/agents/[name].md`
3. 读取项目 `AGENTS.md` 及它按路径引用的标准文件：每个子代理都会收到它们，
   因此其中陈述的规则（例如 `coordination-rules.md` 中的重定向）算作
   技能或代理自身的规则
4. 读取 `spec:` 路径下的规格
5. 评估规格中的 Static Assertions、每个用例的断言，以及其
   Protocol Compliance 列表
6. 提出把结果写入 `results/` 并更新 `catalog.yaml`

## Fixture 默认值

每个技能规格在其用例上方都有一个 `## Fixture Defaults` 章节。用例的
沙盒项目从下面这个 `project.yaml` 块开始：

```yaml
modes:
  rigor: minimal            # → workflow minimal, docs.density terse, qa.level minimal,
                            #   story_granularity coarse, review_mode solo, team.size individual
  automation: collaborative
```

- 用例 Fixture 中指定的设置优先于该块，显式的子开关（`modes.workflow`、
  `modes.review_mode`、`qa.level` 等）优先于 `rigor` 预设
  （`.trae/docs/config-resolution.md` § Defaults）。
- 若用例声明 `project.yaml` 未设置任何 `modes` 键，或不存在
  `project.yaml`，则运行时不带该块：它测试的是未设置的默认值。
- 除非用例点名，否则不存在 `project.local.yaml`。
- 若用例的预期行为会随某个设置改变，它要在自己的 Fixture 中固定该设置
  并说明原因 —— 例如 `modes.workflow: standard`（固定原因：
  未设置时解析为 minimal，而 minimal 推荐下一次构建而不是冲刺）。

固定该块是为了让框架默认值的变化不会悄悄改变用例所测试的内容。如果
一个规格的大多数用例都需要不同的默认值，它可以在自己的章节中设置。

## 改进技能的工作流

使用 `/skill-improve [name]`。它处理完整循环：
测试 → 诊断 → 提出修复 → 重写 → 重新测试 → 保留或回滚。

## 规格有效性说明

本文件夹中的规格断言的是**正确**行为，而不是某个技能或代理今天的实际
行为。失败断言意味着技能或代理是错的，直到证明并非如此：修复它并重跑，
绝不要为了让断言通过而削弱它。
规格也可能出错 —— 当某条断言本身就在断言错误行为时，应按正确行为修正
规格，而不是按技能当前的行为修正。

## 此文件夹可删除

`.trae/` 中没有任何东西从这里导入，其他所有 CCGS 技能和代理也能在没有
它的情况下工作 —— 但 `/skill-test` 和 `/skill-improve` 会按路径读取它。
没有它时：`/skill-test static` 仍然可用，`/skill-test spec` 和
`/skill-test category` 停止工作，`/skill-test audit` 会报告不存在目录，
`/skill-improve` 会跳过其类别检查（`README.md` 中的表格有详细说明）。
