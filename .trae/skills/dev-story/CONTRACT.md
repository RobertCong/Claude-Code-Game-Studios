# /dev-story — 交接契约

## 在流水线中的角色
通过为单个用户故事加载完整上下文（故事文件、TR 注册表、ADR、控制清单、引擎偏好），
路由到正确的程序员 agent，实现源码和测试，并让故事准备好进入 `/story-done`
（在 `standard`/`full` 下先经过 `/code-review`），从而衔接规划与代码。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `production/epics/**/*.md`（故事文件） | `Status: Ready`、`TR-ID`、`Governing ADR`、`Manifest Version`、`## Acceptance Criteria`、`## Test Evidence`、`## Dependencies`、`## Out of Scope` | **部分可变。** 本技能在任何 agent 运行前（Phase 3）把 `Status:` 设为 `In Progress` 并更新 `Last Updated:`，并在结束时用变更的文件替换 `## Files`——在 `minimal` 下，故事文件是唯一的进度记录，因为 `sprint-status.yaml` 不存在。在 ADR 版本不匹配且回答“Re-read the changed ADR”时，它把 `ADR Version` 设为 ADR 的当前版本，并刷新 `**ADR Decision Summary**` 和 `## Implementation Notes`；在清单不匹配且回答“Update”或“Use the old rules”时，它设置 `Manifest Version:`（后者还添加 `Manifest-Note:`）。故事文件中的其他一切对本技能均为只读 |
| `docs/architecture/tr-registry.yaml` | 与故事 TR-ID 匹配、带有当前 `requirement` 文本的条目 | 是 |
| `docs/architecture/adr-NNNN-[slug].md`（引用的 ADR） | `## Status`、`## Last Verified`（否则 `## Date`）——来自 `adr-status.sh`；`## Decision`（及其 `### Implementation Guidelines`）、`## Engine Compatibility`、`## ADR Dependencies`——仅在版本不匹配且回答“Re-read the changed ADR”时读取 | 是——ADR 绝不被编辑；不匹配时更新故事的戳记，而不是 ADR |
| `docs/architecture/control-manifest.md` | `Manifest Version:` 头部、层规则（必需模式、禁止模式、性能护栏） | 是 |
| `project.yaml` | `engine.name`、`engine.version`、`naming.*`、`performance.*`——这些字段各自的主要来源 | 是 |
| `.claude/docs/technical-preferences.md` | 上述任何字段在 `project.yaml` 中缺失或为空时的旧版回退；禁止模式和允许库的**唯一**来源（有意从未迁移），外加 `Engine Specialists` 章节 | 是——仅在字段从 `project.yaml` 缺失时需要，禁止模式则始终需要 |
| `docs/engine-reference/[engine]/VERSION.md` | 引擎版本、LLM 知识截止时间、截止后风险等级 | 是 |
| `production/session-state/active.md` | （在未给参数时读取以查找活动故事；不存在则创建） | 否 |

> **层级（Tier）。** SKILL.md 的 Phase 2 由 `workflow` 决定：TR 注册表在
> `full` 下必需，在 `standard` 下可选，在 `minimal` 下不要求；控制清单缺失时在
> `full`/`standard` 下警告，在 `minimal` 下不要求；当故事引用的 ADR 缺失、为 `Proposed`、
> `Deprecated` 或 `Superseded` 时，ADR 构成阻塞。

### 前置条件
- 目标故事必须具有 `Status: Ready`（在 `standard`/`full` 下由 `/story-readiness` 验证；在
  `minimal` 下，`/create-stories` 直接写入 `Ready` 的故事，`/story-readiness` 不在路径上）
- 故事中引用的 ADR 必须具有 `Status: Accepted`——如果 `Status: Proposed`，不要实现；
  将其作为阻塞项呈现，并引导用户运行 `/architecture-decision accept [ADR-id]`；`Deprecated` 或
  `Superseded` 同样阻塞，并点明后继 ADR。ADR 字段为 `N/A` 的故事不引用任何 ADR，在所有层级下
  都是如此
- 故事文件的 `## Dependencies` 中列出的所有故事都必须已经具有 `Status: Complete`（或 `Status: Done`）
- 必须配置引擎——`project.yaml` 中的 `engine.name`，或作为旧版回退，
  `.claude/docs/technical-preferences.md` 中不为 `[TO BE CONFIGURED]` 的 `**Engine**:` 值
- 在 `full` 下，`docs/architecture/tr-registry.yaml` 必须包含故事的 TR-ID（在 `standard` 下可选，在 `minimal` 下不要求）
- `docs/architecture/control-manifest.md` 存在时提供层规则；缺失时仅警告，绝不停止本技能

## 产生的输出

### 写入的文件
| 文件 | 保证的字段 / 章节 | 备注 |
|------|------------------------------|-------|
| `<code root>/[system]/[file].[ext]` | 带文档注释的公共 API；无硬编码玩法数值；遵循 ADR Implementation Guidelines 和 control-manifest 必需模式 | 由程序员 agent 创建或修改；代码根目录按 `.claude/docs/code-root-resolution.md` 解析 |
| `tests/unit/[system]/[story-slug]_test.[ext]` 或 `tests/integration/[system]/[story-slug]_test.[ext]` | 每个验收标准一个测试函数（仅 Logic/Integration 故事）；按引擎命名（`.claude/rules/test-standards.md`）；无随机种子；无外部 I/O | 由程序员 agent 创建；路径与故事中的 `## Test Evidence` 匹配 |
| 故事文件的 `## Files` 章节 | 程序员 agent 创建或修改的代码和测试文件，每行一个 | 通过 `md-section.sh replace` 替换（故事没有该节时在末尾添加）；在唯一的 In Progress 询问中点明，该询问被拒绝时跳过。`/story-done` 依据它检查范围 |
| `production/session-state/active.md` | `<!-- CHECKPOINT -->` 块：当前任务（故事路径）、下一步、阻塞项、进行中的文件、运行结果 | 在每种结果下由 `session-state.sh checkpoint` 写入：该块被替换，绝不追加（文件不存在时从 `.claude/docs/templates/session-state.md` 创建） |

### 输出保证
- 所有源文件遵循 `project.yaml` 中的命名约定（`naming.*`），其中缺失的任何约定回退到 `.claude/docs/technical-preferences.md`
- 测试文件路径与故事 `## Test Evidence` 章节中声明的路径完全一致
- 每个验收标准在实现总结中映射到测试函数（Logic/Integration）、一张 `OBSERVED` 保留截图
  （Visual/Feel 和 UI 的*外观*那一半），或标记为 `DEFERRED`（仅*手感*那一半——时机、重量、响应性）
- 未经先向用户呈现冲突，不会在故事的 `## Out of Scope` 边界之外写入任何文件
- 会话状态记录变更的文件和下一次推荐的调用（`/story-done`；在 `standard`/`full` 下先 `/code-review`）——INCOMPLETE 时，用 `/dev-story` 恢复；BLOCKED 时，记录解除阻塞的操作
- 实现总结说明一项**验证**结果——对编写的代码运行了什么（Godot：对变更脚本运行 `.claude/scripts/godot-parse-check.gd`；Unity：`commands.smoke`；Unreal：编辑器目标构建）及其退出码。当引擎可执行文件不可用时，这必须是 **`NOT VERIFIED — <reason>`**，绝不因为代码读起来正确就推断它没问题
- 实现总结说明一项**运行结果**——`OBSERVED — <what was on screen>` 并附 `production/qa/evidence/[story-slug]/` 下的保留截图、`NOT VERIFIED — <reason>`，或 `N/A — <reason>`（仅用于确实没有可观察内容的故事）。在默认闸门级别下，`NOT VERIFIED` 对 Visual/Feel 和 UI 故事是阻塞项。运行在 **`qa.level: minimal` 下不豁免**——测试可豁免，外观不可。流程：`.claude/docs/run-and-observe.md`
- 在 `qa.level: minimal` 下不写测试文件，对于 Logic 或 Integration 故事，总结会明确说明（`Test evidence: waived at qa.level: minimal`）；UI 和 Visual/Feel 故事没有豁免行，因为它们的截图仍然适用。豁免的运行与忘记写测试的运行绝不应产生相同的产出物
- **`NOT ASSESSED` 是故事 `Risk` 字段可接受的入站值**（当 `VERSION.md` 未分配等级时由 `/create-stories` 发出）。引擎专家检查每个代码故事，因此任何 Risk 值都无法跳过该检查
- **不假定完成。** 如果程序员 agent 提前停止或其输出无法解析，故事会报告为 **INCOMPLETE**，并点名具体破损处，且不会输出 `Implementation Complete`

## 不可变性规则
- 读取但**不**修改：`project.yaml`、`docs/architecture/tr-registry.yaml`、`docs/architecture/adr-NNNN-[slug].md`、`design/gdd/` 中的所有 GDD 文件、`docs/architecture/control-manifest.md`、`.claude/docs/technical-preferences.md`（旧版回退）、`docs/engine-reference/[engine]/VERSION.md`
- 通过程序员 agent 修改：`<code root>/**`（新增/更新的源文件；代码根目录按 `.claude/docs/code-root-resolution.md` 解析）以及引擎的测试根目录（新测试文件；Godot 上为 `tests/`）
- 由本技能自身修改，每次都在点明该文件的问题之后（在 `collaborative` 模式下；其他模式由 `.claude/docs/automation-modes.md` 管辖）：故事文件的 `Status:`、`Last Updated:`、`## Files`、`ADR Version`、`**ADR Decision Summary**`、`## Implementation Notes`、`Manifest Version:` 和 `Manifest-Note:`（见上方故事行）；故事在 `production/sprint-status.yaml` 中的条目（`status: in-progress`、顶层 `updated`）；依赖故事的 `Status:`（仅该依赖回答）；Config/Data 故事的数据文件；在 Unity 上，为 `Assets/Scripts/ScreenshotOnArg.cs`，当项目没有时从 `.claude/docs/run-and-observe.md` 原样写入
- 无需询问即修改：`production/session-state/active.md`——其 `<!-- CHECKPOINT -->` 块被覆盖，绝不追加
- 仅将故事文件自身的 `Status` 字段设为 `In Progress`（Phase 3，在任何 agent 运行前）。
  关闭正在实现的故事是 `/story-done` 的专属职责；本技能写入的唯一其他 `Status` 是在
  该依赖回答（硬性约束）下把某个依赖设为 `Complete`

## 硬性约束（绝不违反）
- 绝不自行判断把故事标记为 `Status: Done` 或 `Status: Complete`——那属于 `/story-done`。唯一例外是用户声明已完成的依赖（Phase 2 依赖回答“It is done, the status was never updated”）：只有在“May I update [dependency path] Status to Complete?”获批后，才把其 `Status` 设为 `Complete`
- 绝不未加载完整上下文包就开始实现（故事、注册表中的 TR-ID、ADR Decision + Implementation Guidelines——按故事中的提炼，或在该不匹配回答后从 ADR 重读——control-manifest 层规则、引擎偏好）
- 绝不在故事引用的 ADR 为 `Status: Proposed`、`Deprecated` 或 `Superseded` 时实现它——作为阻塞项呈现
- 绝不在 `## Test Evidence` 声明的路径没有测试文件时，把 Logic 或 Integration 故事写为完成
- 未经用户明确批准，绝不触碰故事 `## Out of Scope` 章节中列出的文件
- 绝不悄悄偏离 ADR 的 Implementation Guidelines——偏离必须在总结中标记
- 在任何情况下都不修改 ADR 文件或 GDD 文件
- 源文件和测试文件由程序员 agent 编写；本技能不直接编写任何文件，例外是在 Unity 上经询问后原样写入 `ScreenshotOnArg.cs` 捕获脚本

## 下游技能期望
**下一个技能：** `/story-done`
- 它会读取：故事文件（以检查 `Status`、`## Acceptance Criteria`、`## Test Evidence` 路径、`Type:`、引用的 ADR、TR-ID）
- 它假定：`## Test Evidence` 中声明的测试文件已在磁盘上存在（对于 Logic/Integration 故事）
- 它假定：`production/session-state/active.md` 记录了故事路径和变更的文件（用于在未给参数时定位进行中的故事）
- 它假定：解析出的代码根目录下的源文件存在，并与验收标准描述一致，以便基于 Grep 的偏离检查可以运行

## 已知脆弱点
- 如果故事内嵌的 `Manifest Version` 与当前 `docs/architecture/control-manifest.md` 头部日期不同，规则可能在故事编写后已改变——本技能会呈现这一点，但悄悄继续会产生违反较新清单规则的代码
- `## Test Evidence` 中的测试文件路径必须精确：`/story-done` 使用该字面路径进行 Glob 检查；这里的拼写错误会在下游产生错误的 BLOCKING 结果
- 如果 `docs/architecture/tr-registry.yaml` 中的 `requirement` 文本过时且与 GDD 不一致，实现可能满足注册表但不符合 GDD——按设计始终把注册表视为权威，但若发现明显差异要标记
- agent 失败按设计是非致命的（部分报告会被呈现），但被阻塞的程序员 agent 意味着没有编写任何源文件——`/story-done` 随后会在文件存在性检查上失败
- Config/Data 故事不产生测试文件；`/story-done` 必须看到故事头部中的 `Type: Config/Data` 才能正确分类故事——否则它会按错误的类型（例如 Logic，默认是 BLOCKING）解析测试证据闸门，并可能标记缺失测试
