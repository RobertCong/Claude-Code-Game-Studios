# /gate-check —— 交接契约

## 在流水线中的角色
通过审计必需产出物与质量检查，校验项目是否已准备好从一个开发阶段推进到下一个阶段，产出 PASS / NOT ASSESSED / CONCERNS / FAIL 结论（NOT ASSESSED 高于 PASS——无法检查自身部分范围的闸门并未确立就绪状态；优先级顺序见 SKILL.md 的结论一节），并在 PASS 且用户确认时，或在 CONCERNS 且用户明确接受所列风险时，把新阶段名写入 `project.yaml` 的 `project.stage`（并为向后兼容写入旧版 `production/stage.txt`）。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `project.yaml`（`project.stage`，回退 `production/stage.txt`） | 阶段名（未提供参数时用于自动检测当前阶段） | 是 |
| `project.yaml`（`modes.workflow`，它跟随 `modes.rigor`——默认 `minimal`；`workflow_overrides.system_overrides.*`、`workflow_overrides.art_bible_strict`） | 工作流层级——选择逐闸门的产出物清单（第 2b 节）；在校验 MVP GDD 时解析按系统覆盖 | 是 |
| `docs/engine-reference/[engine]/VERSION.md` | 引擎版本、cutoff 之后的风险等级（在引擎校验检查中读取） | 是 |
| `.claude/docs/technical-preferences.md` | 当 `project.yaml` 中这些键缺失或为空时，作为 `engine.*`、`naming.*` 和 `performance.*` 的旧版回退；禁用模式的唯一来源（从未迁移）。在质量检查中被引用 | 是——仅在 `project.yaml` 缺少相应键时必需 |
| `docs/consistency-failures.md` | 带领域标记的条目，作为提高审查力度的上下文呈现（存在则读取；缺失则跳过） | 是 |

### 阶段特定输入（视目标闸门读取子集）
| 目标闸门 | 检查的关键文件 |
|-------------|------------------|
| Concept → Systems Design | `design/gdd/game-concept.md`；游戏支柱位于其中**或**可选的 `design/gdd/game-pillars.md`——在 `minimal` 层级改用 `design/game-brief.md`（支柱检查取消） |
| Systems Design → Technical Setup | `design/gdd/systems-index.md`、`design/gdd/` 中所有 MVP GDD、跨 GDD 评审报告 |
| Technical Setup → Pre-Production | `docs/architecture/` 中的 ADR（≥3）、`docs/engine-reference/[engine]/deprecated-apis.md`、`docs/architecture/architecture.md`、`docs/architecture/requirements-traceability.md`、`design/accessibility-requirements.md`、`design/ux/interaction-patterns.md` |
| Pre-Production → Production | `production/sprints/`（首个冲刺计划）、`docs/architecture/control-manifest.md`、`production/epics/`（Foundation + Core 层史诗）、`design/ux/hud.md`、`design/ux/` 关键界面规格；推荐但非阻塞：`prototypes/*-vertical-slice/REPORT.md` 及其位于 `production/qa/playtests/` 的试玩测试——在 `minimal` 层级，只需一份填写完整的 `design/game-brief.md`（含其构建顺序）以及 `production/epics/` 下的用户故事（无冲刺计划；其余项取消，包括垂直切片项——改用对当前构建的两项检查替代：核心循环有趣，且能端到端跑通） |
| Production → Polish | 代码根下的子系统（按 `.claude/docs/code-root-resolution.md` 解析）、引擎的测试根——`tests/unit/` + `tests/integration/`（Godot）、`Assets/Tests/`（Unity）、`Source/<Module>/Private/Tests/`（Unreal）——且所有 Logic 用户故事均被覆盖、`production/qa/smoke-*.md`（PASS 或 PASS WITH WARNINGS）、`production/qa/playtests/`（≥3 次会话） |
| Polish → Release | 所有 Must Have 用户故事的完整测试证据、QA 签核报告、本地化检查、`production/qa/` QA 计划、发布清单输出、变更日志、最新一份全范围 `production/security/security-audit-*.md`（外加之后任何一次 `quick` 重跑） |

### 前置条件
- 目标阶段参数必须是以下之一：`systems-design`、`technical-setup`、`pre-production`、`production`、`polish`、`release`；若省略，则根据 `project.yaml` 中的 `project.stage`（回退 `production/stage.txt`）自动检测，并校验下一次跃迁
- 本技能不要求同一会话中先运行过任何技能，但会把缺失的前置条件（例如缺少 ADR、缺少试玩测试报告）作为阻塞项呈现在结论中

## 产出的输出

### 写入的文件
| 文件 | 保证包含的字段 / 章节 | 说明 |
|------|------------------------------|-------|
| `production/gate-checks/gate-[phase]-[date].md`（或用户选择的路径） | 带逐项状态的完整清单、阻塞项列表、建议、结论、验证链注记 | 仅在用户批准后写入（“我可以把这份闸门校验报告写入 production/gate-checks/ 吗？”） |
| `project.yaml`（`project.stage`）+ 旧版 `production/stage.txt` | 新阶段名（为向后兼容双写） | 仅在结论为 PASS 且用户明确确认，或结论为 CONCERNS 且用户明确接受所列风险时写入；在 FAIL 或 NOT ASSESSED 下绝不写入 |

### 输出保证
- 闸门报告始终包含：产出物清单（含文件大小或“MISSING”）、质量检查结果、阻塞项列表（PASS 时为空）、建议，以及验证链注记——此外，当用户在 CONCERNS 下推进时，还包含 `### Accepted Risks` 一节（每条关注项、由用户接受、带日期）
- `project.stage`（及旧版 `production/stage.txt`）只在确认的 PASS 后，或在用户明确接受风险后的 CONCERNS 后，才更新为新阶段名——绝不臆测性写入
- 任何无法自动核实的事项都标记为 `MANUAL CHECK NEEDED`，并在最终确定结论前询问用户

## 不可变规则
- 读取但不修改：`design/gdd/` 中所有 GDD、`docs/architecture/` 中所有 ADR、`docs/architecture/control-manifest.md`、`docs/architecture/tr-registry.yaml`、`.claude/docs/technical-preferences.md`（旧版回退）、`docs/engine-reference/[engine]/VERSION.md`、`docs/engine-reference/[engine]/deprecated-apis.md`、`production/epics/` 中所有用户故事文件、`production/sprints/` 中所有冲刺文件、`production/qa/playtests/` 中所有试玩测试文件、代码根下的源文件（仅 Grep）、引擎测试根下的测试文件（通过 Bash 运行）
- 修改：`project.yaml`（仅 `project.stage`）+ 旧版 `production/stage.txt`（两者仅在确认的 PASS 或被接受的 CONCERNS 覆盖时）、`production/gate-checks/[report].md`（新文件，需用户批准）
- 不修改用户故事文件、ADR、GDD 或任何源码/测试代码

## 硬性约束（绝不违反）
- 除非结论为 PASS 且用户已明确确认推进，或结论为 CONCERNS 且用户已明确接受每一项所列风险（记录在报告的 `### Accepted Risks` 中），否则绝不写入阶段（`project.yaml` 的 `project.stage` 或旧版 `production/stage.txt`）
- 在任何情况下都不在 FAIL 或 NOT ASSESSED 结论下写入阶段——没有任何覆盖能把这两种结论变成阶段变更
- 绝不自动推进阶段——即便是 PASS 结论，也需要用户明确确认后才写入文件
- 绝不为无法自动核实的事项假定 PASS——始终标记 `MANUAL CHECK NEEDED` 并询问用户
- 绝不阻止用户继续工作——结论只决定是否写入阶段；CONCERNS 覆盖会把已接受的风险记录在闸门报告中
- 绝不把目标闸门尚不要求的产出物向总监传“none”——那是“在 [阶段] 之前不预期”（或“在 `workflow: [tier]` 下不要求”），不构成发现项；“none”专指闸门要求但实际不存在的产出物
- 在起草结论后、最终确定前，始终运行验证链（5 个质疑性问题）
- 如果在 Pre-Production → Production 闸门中任何垂直切片校验项为 NO，则无论其他检查如何，结论自动为 FAIL，适用于 `full` 与 `standard`；在 `minimal` 下切片项取消，若对两项当前构建检查（核心循环有趣、能端到端跑通）中任一项回答“否”，同样为 FAIL（层级削减放宽的是必须*存在*的东西，绝不让损坏的构建变得可通过）
- 工作流层级削减（第 2b 节）只会*放宽*要求（必需 → 缺失即 CONCERNS，或取消）；绝不新增要求。唯一新增要求的是 `workflow_overrides`：经 `system_overrides` 钉到高于项目层级的系统，在该系统 GDD 满足更高章节数之前会阻塞闸门；`art_bible_strict: true` 会无视层级强制完整美术圣经
- gate-check 遵循 `modes.workflow`，但不受 `modes.automation` 约束——协作提示协议（“协作协议”一节）始终适用；阶段闸门绝不自动运行

## 下游技能的预期
**下一个技能（PASS 时）：** 视闸门而定

| 通过的闸门 | 启用的下游技能 |
|-------------|-------------------------|
| Concept → Systems Design | `/map-systems`——或者当 `design/gdd/systems-index.md` 已存在时，对第一个系统运行 `/design-system` |
| Systems Design → Technical Setup | 先 `/create-architecture`——主架构与 ADR 工作计划（它需要引擎，若未配置则先 `/setup-engine`）——然后 `/architecture-decision` |
| Technical Setup → Pre-Production | 若 `docs/architecture/control-manifest.md` 尚不存在，先 `/create-control-manifest`，然后 `/vertical-slice`；切片验证核心循环后，再 `/create-epics` 与 `/create-stories` |
| Pre-Production → Production | `/dev-story`、`/sprint-plan`、`/story-readiness` |
| Production → Polish | `/perf-profile`、`/playtest-report`、`/smoke-check` |
| Polish → Release | `/launch-checklist`、`/team-release`（发布清单、变更日志与安全审计在此闸门之前完成） |

- 下游技能会从 `project.yaml`（回退 `production/stage.txt`）读取 `project.stage`，以确认自己的阶段已激活再继续
- `/create-epics` 读取 `docs/architecture/control-manifest.md`——在 `full` 下必需，在 `standard` 下存在则读取——Pre-Production → Production 闸门会检查它

## 已知脆弱点
- `project.yaml` 中的 `project.stage`（以旧版 `production/stage.txt` 为回退）是权威的阶段指示器——若在 `/gate-check` 之外被手动改成错误值，未来会话的自动检测就会出错；绝不要在 `/gate-check` 的阶段写入之外编辑它们
- Production → Polish 闸门会通过 Bash 运行测试套件。如果未配置测试运行器命令或启动失败（例如 `addons/gdUnit4/` 下未安装 gdUnit4），测试检查会给出 `NOT ASSESSED`，其优先级高于 PASS——因此闸门不能仅凭一个从未运行过的套件推进阶段。若同时发现问题，结论为 CONCERNS，且在该检查为 NOT ASSESSED 期间不提供其覆盖
- Pre-Production → Production 闸门有一个硬性的垂直切片校验块；任何主观清单项（例如“核心机制手感好”）都需要通过 `AskUserQuestion` 获得用户答复——如果用户没玩过构建就回答，可能产生错误的 PASS
- `production/gate-checks/` 中的闸门报告文件不会被任何下游技能校验完整性；因会话中断而写出的残缺报告，看起来会和完整报告一模一样
- `docs/consistency-failures.md` 是可选上下文，会调整审查力度但不改变正式清单；如果该文件存在但已过时，提高审查力度的信号可能指向已解决的问题
