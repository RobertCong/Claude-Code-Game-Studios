# /story-done — 交接契约

## 在流水线中的角色
通过验证每条验收标准、检查测试证据、检测 GDD/ADR 偏差，并在用户批准之后将用户故事文件更新为 `Status: Complete` 且加入 `## Completion Notes` 章节，来关闭单个用户故事的实现循环。

## 所需输入

### 必须存在的文件
| 文件 | 必需字段 / 章节 | 只读？ |
|------|---------------------------|-----------|
| `production/epics/**/*.md`（用户故事文件） | `Status:`（预期：`In Progress`，或若跳过了 `/dev-story` 则为 `Ready` — `/dev-story` 会设置 `In Progress`，而 `/story-done` 是唯一会关闭其所验证用户故事的技能 — `/dev-story` 的依赖选项 `[C]` 也会在用户表示某个依赖已完成之后、经过询问后设置 `Complete`）、`Type:`、`Manifest Version`、TR-ID、ADR 引用、`## Acceptance Criteria`、要创建/修改的文件列表、`## Test Evidence` 路径 | 否 — 状态与完成说明在批准后写入 |
| `docs/architecture/tr-registry.yaml` | 每个 TR-ID 的条目，包含当前 `requirement` 文本 | 是 |
| 每个 TR-ID 所引用的 GDD 章节 | 用于交叉校验的验收标准与关键规则 | 是 |
| `docs/architecture/adr-NNNN-[slug].md`（被引用的 ADR） | `## Decision`、`## Consequences` | 是 |
| `docs/architecture/control-manifest.md` | `Manifest Version:` 头部日期、禁止的模式 | 是（检查存在性；不存在 = 跳过陈旧性检查） |
| `production/session-state/active.md` | 活动用户故事路径（未给参数时使用） | 否 — `<!-- CHECKPOINT -->` 块会被覆盖 |

> **层级。** TR 注册表、GDD 章节和 ADR 行属于 `standard`/`full` 输入。
> 在 `workflow: minimal` 下，用户故事追溯到简报，Phase 5 不执行 GDD
> 或 ADR 检查；清单、硬编码值和范围检查仍会运行。在
> `qa.level: minimal` 下不要求测试证据（SKILL.md Phase 4）— 但
> Visual/UI 的运行并观察截图不被豁免。

### 测试证据文件（检查存在性，不要求预先存在 — 缺失会触发闸门）
| 用户故事类型 | 预期位置 |
|------------|------------------|
| Logic | `tests/unit/[system]/[story-slug]_test.[ext]` |
| Integration | `tests/integration/[system]/[story-slug]_test.[ext]` 或 `production/qa/playtests/` 中的试玩记录 |
| Visual/Feel | `production/qa/evidence/[story-slug]-evidence.md` + 一张保留截图 |
| UI | 所触碰每个屏幕的保留截图，位于 `production/qa/evidence/` 下 — 无需证据文档或签署确认 |
| Config/Data | `production/qa/smoke-*.md` |

### 前置条件
- 用户故事文件必须能通过参数路径、在 `production/session-state/active.md` 中，或在当前冲刺文件中以 `IN PROGRESS` 被找到
- 必须已尝试实现（用户故事 `## Files` 章节列出的文件应当存在）— 本技能不实现；它验证
- 在 `qa.level: full` 下，Config/Data 用户故事的冒烟报告默认 BLOCKING（显式的 `testing.strict.config: false` 保持其为建议性），且任何 UNTESTED 验收标准都会阻塞；在 `standard` 下只有超过一半未测试才阻塞
- 对 Logic 和 Integration 用户故事，`## Test Evidence` 路径处的测试文件必须**存在**，才可能得出 COMPLETE 结论 — 除非 `project.yaml` 中的 `testing.strict` 将该类型设为建议性（`testing.strict.logic`/`.integration: false`），此时缺失测试记录为警告但不阻塞
- 对 Visual/Feel 和 UI 用户故事，`production/qa/evidence/` 下必须存在保留截图，才可能得出 COMPLETE 结论；Visual/Feel 还需要一份每行签署确认为 `[x] Approved` 的证据文档（UI 只需截图，正如 `coding-standards.md` 所述）— 除非 `testing.strict.visual`/`.ui` 设为 `false`，此时缺口记录为警告但不阻塞
- **本技能不执行测试。** Phase 4 检查文件存在；不运行任何东西。存在且**失败**的测试仍满足闸门，因此失败的测试在此无法阻塞 COMPLETE 结论 — 此闸门检查的是存在性，不是"存在且通过"。通过/失败由 `/gate-check` 和 `/smoke-check` 确立，两者都会运行套件，且都在用户故事关闭之后进行。见 `SKILL.md` 的 Phase 3。

## 发出的结论
`COMPLETE` / `COMPLETE WITH NOTES` / `NOT ASSESSED` / `BLOCKED`。

`NOT ASSESSED` 排序高于 `COMPLETE` — 一条或多条验收标准完全无法评估，这与评估后认定其满足并不相同。优先级为 `BLOCKED`，然后 `NOT ASSESSED`，然后 `COMPLETE WITH NOTES`，然后 `COMPLETE`；见 `SKILL.md` 的结论章节。

## 产生的输出

### 写入的文件
| 文件 | 保证的字段 / 章节 | 说明 |
|------|------------------------------|-------|
| `production/epics/**/*.md`（用户故事文件） | `Status: Complete`、`## Completion Notes` 块（日期、标准数量、偏差、测试证据路径、代码评审状态、Reviewed by） | 在用户明确批准后更新 |
| `production/sprint-status.yaml` | `status: done`、`completed: [date]`、顶层 `updated` 字段 | 若文件存在，则与用户故事文件一并静默更新 |
| `docs/tech-debt-register.md` | 建议性偏差条目（若用户确认） | 若存在建议性偏差且用户同意则追加 |
| `production/session-state/active.md` | `<!-- CHECKPOINT -->` 块：当前任务（用户故事路径、结论、已关闭或仍开放）、下一步（下一个用户故事，或结论所指的修复）、阻塞项、技术债数量 | 由 `session-state.sh checkpoint` 在每次运行、每个结论下写入，无论是否关闭：该块被替换，绝不追加（若文件不存在则从 `.claude/docs/templates/session-state.md` 创建） |

### 输出保证
- `Status: Complete` 仅在用户明确批准后写入：在 COMPLETE 或 COMPLETE WITH NOTES 结论下，或 — 在 BLOCKED 或 NOT ASSESSED 结论下 — 仅当用户明确要求仍然关闭时（Phase 7 的覆盖，始终作为 `scope_changes` 决策弹出询问），并将覆盖风险记录在 `## Completion Notes` 中
- `## Completion Notes` 始终包含：完成日期、标准通过数、偏差摘要、测试证据路径（或"None required"）、代码评审状态，以及 Reviewed by 行：`lead-programmer`、`/code-review (you said you ran it; not verified here)`，或当没有其他人评审时 `self, no independent review`
- 会话状态始终记录最终结论和下一个推荐的用户故事路径

## 不可变性规则
- 读取但不修改：`docs/architecture/tr-registry.yaml`、`docs/architecture/adr-NNNN-[slug].md`（仅 Decision + Consequences）、GDD 章节、`docs/architecture/control-manifest.md`、代码根目录下的源文件 — 按引擎为 `src/`、`Assets/` 或 `Source/`（仅搜索）— 以及引擎测试根目录下的测试文件（检查存在性；绝不运行或编辑）
- 修改：用户故事 `.md` 文件（状态 + 完成说明）、`production/sprint-status.yaml`（若存在）、`production/session-state/active.md`（`<!-- CHECKPOINT -->` 块，被覆盖）、`docs/tech-debt-register.md`（追加一行，并更新其 `Last updated:` 和 `Total items:` 行，仅在用户批准时）
- 在任何情况下都不写入代码根目录或测试根目录

## 硬性约束（绝不违反）
- 未经用户明确批准（"May I update the story file?"），绝不设置 `Status: Complete`
- 当 Logic 用户故事解析出的闸门级别为 BLOCKING 时，绝不因缺少单元测试而将其标记为 Complete — 该级别默认即为 BLOCKING，且只要 `testing.strict.logic` 为 `true` 都是 BLOCKING；仅当 `testing.strict.logic` 显式为 `false` 时为 ADVISORY
- 当 Integration 用户故事解析出的闸门级别为 BLOCKING 时，绝不因缺少证据（集成测试文件或试玩会话日志）而将其标记为 Complete — 默认 BLOCKING，在 `testing.strict.integration: true` 下也是；仅在显式 `false` 下为 ADVISORY
- 当 Visual/Feel 或 UI 用户故事解析出的闸门级别为 BLOCKING 时，绝不因 `production/qa/evidence/` 中缺少保留截图而将其标记为 Complete — 默认 BLOCKING，在 `testing.strict.visual`/`.ui: true` 下也是；仅在显式 `false` 下为 ADVISORY。对视觉检查的文字描述不能替代图片
- 绝不自动修复失败的验收标准 — 报告失败并询问用户该怎么办
- 当结论为 BLOCKED 或 NOT ASSESSED 时，绝不自行进入 Phase 7（文件更新）— 列出阻塞项并提供帮助解决它们；只有用户明确要求仍然关闭时才进入 Phase 7，且届时始终弹出询问（`scope_changes`），即使在 autonomous 模式下也是如此
- 绝不悄悄覆盖 BLOCKED 结论 — 若用户坚持在存在阻塞项时推进，在 `## Completion Notes` 中明确记录覆盖风险

## 下游技能期望
**下一个技能：** `/gate-check`（Production → Polish 闸门，或冲刺末评审）
- 它将读取：`production/epics/` 中的用户故事文件，检查 `Status: Complete` 以及是否存在 `## Completion Notes`
- 它将读取：`tests/unit/` 和 `tests/integration/` 中的测试文件是否存在，并通过 Bash 运行测试套件
- 它假设：每个 `testing.strict.logic` 闸门解析为 BLOCKING（默认值）的 Complete Logic 用户故事都有对应的**存在**的测试文件；在显式 `testing.strict.logic: false` 下，Logic 用户故事可以在 `## Completion Notes` 中记录测试缺口的情况下为 Complete
  > **是存在性，不是通过。** `/story-done` 检查测试文件存在，不运行任何东西，因此一个 Complete 的 Logic 用户故事可能携带一个失败的测试。`/gate-check` 运行套件是**第一个**确立通过/失败的地方，因此它绝不能把 Complete 状态当作测试已通过的证据 — 它必须运行它们。这也是为何未配置的测试运行器在那里是 `NOT ASSESSED` 而非静默跳过：没有运行，上游也没有任何东西验证过该用户故事。
- 它假设：Complete 的 Visual/Feel 和 UI 用户故事在 `production/qa/evidence/` 中有保留截图，且 Visual/Feel 用户故事还有一份已签署的证据文档 — 该闸门默认 BLOCKING；只有在显式 `testing.strict.visual`/`.ui: false` 下，此类用户故事才可在 `## Completion Notes` 中记录偏差的情况下为 Complete
- 它将读取：`production/sprint-status.yaml` 中的 `status: done` 条目（若该文件存在）

## 已知脆弱点
- 优先检查用户故事的 `## Test Evidence` 路径；当它不匹配时，Phase 4 会先搜索 `tests/unit/[system]/`（或 `tests/integration/[system]/`）再标记测试缺失，因此名称略有差异的文件仍会被找到 — 但该文件夹之外的文件不会
- 范围检查读取用户故事的 `## Files` 列表（由 `/create-stories` 填充，由 `/dev-story` 替换）。在该章节存在之前编写的用户故事，在其指明本用户故事时回退到检查点的 **Files in progress**，否则报告范围为 NOT ASSESSED；已提交的变更不会被看到，因为它只比较未提交的文件
- 如果用户故事头部缺少 `Type:`，测试证据闸门的执行仅为 ADVISORY — 用户故事可能在没有测试的情况下溜过
- 若 `docs/architecture/control-manifest.md` 不存在，则跳过清单版本陈旧性检查；跳过检查会在报告中注明，但不阻塞
- `production/sprint-status.yaml` 的更新是静默的（没有单独的批准）；如果该文件使用的键结构与预期不同，更新会静默失败，冲刺跟踪会变得陈旧
- 可追溯性表的升级规则（`qa.level: standard` 下 >50% UNTESTED = BLOCKING，`full` 下任何 UNTESTED 都阻塞）可能被合理无法自动化的延期 Visual/Feel 标准触发 — 确保延期标准被明确标记为 `DEFERRED`（而不是留作未勾选）以避免误升级
