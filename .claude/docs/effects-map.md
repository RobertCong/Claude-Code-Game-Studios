# project.yaml — Effects Map

> ## READ ONE SECTION, NEVER THIS WHOLE FILE
>
> 本文档篇幅很大，远超任何单次查询所需。它按「每个设置一节」组织，每节标题为
> `## <key>`，因此读者可以只取自己需要的那一节。
>
> **所以整篇打开的成本是你实际所需的许多倍。** 要查询某个设置，请这样做：
>
> ```
> Grep pattern="^## modes.review_mode" path=".claude/docs/effects-map.md" -A 40
> ```
>
> 读取你所需键对应的那一节，然后停下。技能们对自己的参考文件早已应用同一条规则——
> `/gate-check` 只加载目标阶段的那一行，并声明"绝不加载其他行"——这里同样适用，
> 而且这是整个框架中最大的文件。
>
> 引用本文档的某一节，绝不要引用整篇。诸如"参见 effects-map.md 了解完整 schema"
> 这类指引会诱使对方完整读取如此体量的文件，而接受这一邀请的代价是无声的。请改为
> 指名你需要的 `## <key>` 小节。

本文档说明每个 `project.yaml` 设置在读取它的所有技能中实际起什么作用。它是纳入
版本跟踪的权威参考。

**用途：** 当技能读取某个设置时，本文档是关于每个取值对该技能行为意味着什么的
权威来源。实现在新增设置或改变技能对某个设置的响应方式时，应更新本文件。

**每个设置的格式：**
- 优先级链——多个来源同时存在时哪个来源胜出
- 各取值意图——用平实语言说明该取值的含义
- 技能行为表——每个技能在每个取值下究竟会发生什么变化

**覆盖范围：** 本文档覆盖受每个设置影响最大的技能。未列出的技能（例如 `ux-review`、
`balance-check`、`test-flakiness`、`test-helpers`、`test-setup`、`soak-test`、
`perf-profile`、`launch-checklist`、`release-checklist`、`skill-test`、`skill-improve`、
`vertical-slice`）不会受到 `project.yaml` 设置的实质影响，因此无需在此登记。只有当
某个技能的行为确实会依据设置取值分叉时，才应添加该技能。

**本地覆盖模式：** `project.yaml` 作为团队共享配置提交至 git。每位开发者的个人覆盖
存放在 `project.local.yaml`（已被 gitignore）。所有设置的优先级链为：
`project.local.yaml` → `project.yaml` → 历史镜像 → `modes.rigor` 展开 → 硬编码默认值。
展开步骤仅适用于 `rigor` 所前置的六个开关（`modes.workflow`、`docs.density`、`qa.level`、
`modes.story_granularity`、`modes.review_mode`、`team.size`），正因如此它们**没有**硬编码
默认值——见 `modes.rigor` 一节。
**密钥不属于这两个文件中的任何一个——请使用环境变量。** 完整设计（包括哪些设置可被
本地覆盖的白名单）见下方"Local Override Pattern"一节。

---

## Local Override Pattern — `project.local.yaml`

`project.local.yaml` 文件让每位开发者可以覆盖特定设置供自己使用，而不影响团队。
该文件已被 gitignore，永不提交。

### How it works

优先级链（每个设置）：`project.local.yaml` → `project.yaml` → 硬编码默认值

如果某设置出现在 `project.local.yaml` 中，则以该值为准。如果不存在，则使用
`project.yaml` 中的值。如果那里也不存在，则由硬编码默认值接管。

---

### Deep merge semantics

当两个文件都设置了某个嵌套值时，只有被显式设置的键会被覆盖。同一块中的兄弟键
会保留。

示例：

`project.yaml`:
```yaml
testing:
  strict:
    logic: true
    integration: true
    visual: false
```

`project.local.yaml`（稀疏覆盖）：
```yaml
testing:
  strict:
    logic: false
```

技能看到的有效配置为：`logic: false, integration: true, visual: false`。只有被显式设置的
`logic` 键被覆盖；兄弟键来自 `project.yaml`。

---

### Whitelist — which settings can be locally overridden

只有个人体验类设置可以在本地覆盖。项目级事实（引擎、阶段、命名约定、磁盘上的必需
内容）锁定在 `project.yaml`，因为开发者之间的分歧会破坏团队协作。

判断某设置应归属哪一侧的规则：

> **如果某设置会影响存在哪些产出物或其磁盘上的样子，它必须锁定在 `project.yaml`。
> 如果某设置只改变你的个人体验（为你生成哪些 agent、你是否会收到提示、你的本地
> CI 绕过），它可以在本地覆盖。**

**可本地覆盖**（仅个人体验——不影响磁盘上的产出物）：

| 设置 | 为什么本地覆盖是合理的 |
|---------|-------------------------------|
| `modes.review_mode` | 你个人希望多少 AI 评审 |
| `modes.automation` | AI 向你提问的频率 |
| `modes.automation_always_ask` | 你的个人安全类别 |
| `team.size` | 为你的评审生成哪些 agent（评审深度不同，产出物不变） |
| `testing.strict.*`（每种类型） | 失败是否阻塞你的本地工作（CI 仍执行 `project.yaml` 默认值） |
| `performance.enforce` | 预算违规是否阻塞你的本地工作（CI 执行项目默认值） |
| `features.session_state` | 你的会话跟踪偏好 |
| `features.token_budget_warn_at` | 你的个人成本阈值 |
| `features.read_guard` | 是否拒绝你对大型设计文档的整文件读取 |
| `features.read_guard_kb` | 超过多大即被拒绝 |
| `updates.check` | 你是否看到新版本提示行；对你关闭不影响队友 |

**锁定在 `project.yaml`**（项目级——本地化会造成产出物分歧）：

| 设置 | 为什么必须是项目级 |
|---------|----------------------------|
| `schema_version`、`framework.*` | 文件元数据而非偏好——**不受下方报告影响**，因为 `project.local.yaml` 中写入 `schema_version: 1` 本身是正确的 |
| `project.name`、`version`、`genre`、`kind`、`stage` | 项目身份 |
| `engine.*`、`specialists.*` | 整个团队必须使用同一引擎 |
| `naming.*` | 代码约定必须在团队内保持一致 |
| `platform.*` | 游戏事实（发行在哪些平台） |
| `performance.target_framerate`、`frame_budget_ms`、`draw_call_limit`、`memory_ceiling_mb` | 游戏预算、共享目标 |
| `accessibility.target` | 游戏承诺，项目级 |
| `cadence.*` | 冲刺/里程碑长度影响团队协作 |
| `modes.rigor` | 前置下面四项——锁定原因与它们相同 |
| `modes.workflow` 和 `workflow_overrides` | 影响撰写文档中哪些章节为必需 |
| `modes.story_granularity` | 影响仓库中用户故事的粒度——团队必须一致 |
| `docs.density` | 影响撰写文档的深度——团队必须产出风格一致的文档 |
| `qa.level` | 影响用户故事在磁盘上必须包含哪些测试证据 |
| `qa.coverage_minimum` | 项目质量底线 |
| `strict_gate_checks` | 影响 `project.stage` 是否推进——属于项目级写操作 |
| `commands.*` | 构建/测试命令是项目事实 |
| `testing.framework` | 整个项目使用同一框架 |

> **手工写入 `project.local.yaml` 的锁定键会被报告，而不会被吞掉。**
> `/settings --local` 会拒绝写入这类键，但该文件本就是供手工编辑的，而这条路径此前
> 没有防护：其中的 `modes.rigor: full` 是一个真实存在且取值合法的键，因此枚举校验会
> 放行它，随后解析过程对该路径从不查阅本地文件——设置就此消失，用户看到的仍是他们
> 试图覆盖的默认值，而任何地方都没有报错。此前每项检查校验的都是**值**，没有任何
> 检查校验**位置**。现在 `yaml-helper.sh` 中的 `validate_local_scope` 会在
> `resolve_config` 的 `notes:` 行中列出这类键。它**只警告、从不调和**：不编辑文件、
> 不开始遵循该键、也不改变解析结果——锁定的设置决定磁盘上存在哪些产出物，因此悄悄
> 应用它恰恰会产生此表所防范的分歧。干净的文件保持静默——只有键确实放错了位置时你
> 才会被告知。

---

### `/settings --local` flag behavior

```
/settings workflow=minimal               → writes to project.yaml (team-wide)
/settings --local automation=autonomous  → writes to project.local.yaml (just you)
```

**行为规则：**

- 默认（无标志）：写入 `project.yaml`
- `--local` 标志：写入 `project.local.yaml`（若不存在则创建）
- 对锁定设置使用 `--local` → 报错：
  > *"`<setting>` 不能在本地覆盖——它是项目级设置。请使用
  > `/settings <setting>=<value>`（不加 `--local`）为整个团队修改。"*
- 当同一设置当前已在本地被覆盖时写入 `project.yaml` → 警告：
  > *"该设置当前在 `project.local.yaml` 中被本地覆盖。
  > 写入 `project.yaml` 不会影响你的有效值。"*

---

### Schema validation on read

当技能或钩子读取任一文件时：

| 问题 | 行为 |
|-------|----------|
| 未知键（拼写错误或过期设置） | 会话开始时警告：*"`project.local.yaml` 含有未知键 `modes.automaton` ——拼写错误？已忽略。"* 不会阻塞（与未来设置向前兼容）。 |
| 取值不在枚举范围内（例如 `automation: chaotic`） | 硬错误：技能退出并说明有效取值。 |
| 类型不匹配（例如整数字段被设为字符串） | 硬错误：技能退出并说明期望类型。 |

---

### Creation and error handling

| 场景 | 行为 |
|----------|----------|
| 在全新项目上运行 `/start` | 仅创建 `project.yaml`。**不**创建 `project.local.yaml`。 |
| `project.local.yaml` 不存在时执行 `/settings --local <x>=<y>` | 创建仅包含该设置的 `project.local.yaml`。 |
| `project.local.yaml` 存在但 `project.yaml` 不存在 | 硬错误：*"`project.yaml` 缺失——请运行 `/start` 创建一个。本地覆盖需要一个基础配置。"* |
| 两个文件都存在 | 先读取 `project.yaml`，再在其上深度合并 `project.local.yaml`。正常运作。 |
| 两个文件设置了同一个键 | `project.local.yaml` 胜出。不做提示。 |

---

### Two-developer clash scenarios — and why the whitelist prevents them

**文件级冲突（`project.yaml`）：**
标准的 git 合并冲突。每位开发者的 `project.local.yaml` 都被 gitignore，永远不会与
他人的文件冲突。常规 git 工作流即可处理团队级变更。

**逻辑不一致（由白名单防范）：**

以下是白名单所防范的情形示例：

> Sarah 在本地设置 `modes.workflow: minimal` 以跳过 GDD 要求。她因此不写 GDD，
> 因为她的本地模式不要求这些。Mike 用团队的 `project.yaml` 取值 `standard` 运行
> `/gate-check`；gate-check 发现 GDD 缺失，于是失败。

这不会发生，因为 `modes.workflow` 锁定在 `project.yaml`。`qa.level`、`docs.density`、
`strict_gate_checks`、`naming.*` 以及所有其他影响磁盘上产出物的设置同样如此。

个人体验类设置（`automation`、`review_mode`、`team.size`、`testing.strict.*`、
`performance.enforce`）可以自由分歧而不影响他人。

---

### Stricter reviewer reviewing a looser reviewer's work

一个常见的担忧："如果我队友的评审设置比我更严格会怎样？他们的 `/gate-check` 或
`/design-review` 会不会在我的工作里挑出问题？"

答案取决于你说的是哪种差异：

**评审深度不同，项目要求相同（健康）：**

- 队友 A：本地 `review_mode: full`、`automation: collaborative`、`testing.strict.logic: true`
- 队友 B：本地 `review_mode: solo`、`automation: autonomous`、`testing.strict.logic: false`
- 两人都受相同的 project.yaml 锁定设置约束（例如 `workflow: standard`、`qa.level: standard`）

B 写出的 GDD 满足 `workflow: standard`（5 个必需章节全部齐全）。B 的 `/design-review`
以 `review_mode: solo` 运行——快速的建议性检查，不生成专家代理。B 继续推进。

之后 A 以 `review_mode: full` 评审同一份 GDD——生成 5–15 位专家，发现 B 的轻量评审
遗漏的打磨机会与边缘情况。A 将发现记录为 PR 评论或后续 issue。B 处理真正重要的那些。

**这是正常的团队协作。** 不同的评审者发现不同的问题，正体现了拥有多位评审者的价值。
磁盘上的产出物是相同的，只是评审深度不同。这一情形不会造成任何项目状态分歧。

**要求不同（由白名单防范）：**

如果 `qa.level` 可以本地覆盖：

- B 在本地设置 `qa.level: minimal`。B 的用户故事不包含测试证据。
- B 的 `/story-done` 在没有证据的情况下接受了该故事。故事在磁盘上被标记为 `Complete`。
- A 拉取更新。A 的 `qa.level: standard` 要求证据。A 的 `/story-done` 本会拒绝它。
- A 下一次 `/gate-check` 失败，因为 B 的多个"Complete"故事都缺少证据。

这就是产出物分歧问题。为防止它，`qa.level` 锁定在 `project.yaml`。团队共同商定
要求是什么；个人只覆盖自己的个人体验，绝不覆盖团队标准。

**需要记住的模式：**

| 差异类型 | 结果 |
|----------------|---------|
| 评审深度不同（review_mode、team.size） | 更严格的评审者会暴露更多发现——健康。产出物不变。 |
| 对失败的本地严格程度不同（testing.strict.*、performance.enforce） | 更严格的开发者本地 `/story-done` 会更早阻塞——他们在本地修复。CI 使用 project.yaml 默认值，因此团队级质量底线保持不变。 |
| 产出物要求不同（workflow、qa.level、docs.density 等） | **不可能发生——这些都已锁定。** 团队在 project.yaml 中一次性达成一致。 |

---

### CI behavior

CI 环境没有 `project.local.yaml`——该文件被 gitignore，在全新克隆中永远不会存在。
因此 CI 总是依据 `project.yaml` 默认值运行：严格的项目标准，没有任何针对开发者的
覆盖。

这是有意为之，而且很重要：

| 设置 | 快速迭代的本地默认值 | CI 默认值（`project.yaml`） |
|---------|----------------------------------|------------------------------|
| `modes.review_mode`（可本地覆盖） | 单人开发时用 `solo` | `lean`（团队的常见选择——阶段闸门始终运行） |
| `testing.strict.logic`（可本地覆盖） | `false`，便于快速提交 WIP | `true`（测试失败会阻塞 CI） |
| `modes.automation`（可本地覆盖） | 单人流程用 `autonomous` | `collaborative`（团队的协作协议，但 CI 本来也不提问——这在 CI 上基本是空操作） |

开发者可以在本地以宽松的闸门迭代，但 CI 会用严格的项目默认值发现问题。无论任何
单个开发者的本地配置如何，团队的质量底线都在 CI 层面得到执行。

---

### Secrets — never in either file

`project.yaml` 和 `project.local.yaml` 用于**偏好与配置**，绝不用于**密钥**。
API 密钥、令牌和凭证应放在：

- **环境变量**（生产/CI 的首选）
- **`.env` 文件**（已被 gitignore，本地开发用）
- **操作系统钥匙串**（与服务集成且该服务支持时）

当技能需要 API 密钥时（例如 `/asset-spec` 调用 Midjourney），它从环境读取，而不是
从 `project.yaml` 读取。`project.yaml` 只存储**使用哪个**生成器
（`art.generator: midjourney`），不存储其 API 密钥。

CI 环境通常没有 `project.local.yaml`（被 gitignore，不在克隆中）——因此 CI 总是
依据 `project.yaml` 默认值运行。这是正确的行为：CI 用严格的项目默认值，本地工作
用较宽松的开发者覆盖。

---

## modes.review_mode

**控制：** 技能执行期间生成多少专家代理与总监代理  
**取值：** `full` | `lean` | `solo`  
**默认：** *无*——由 `modes.rigor` 提供（`minimal`（默认值）产出 `solo`；`standard` 产出 `lean`；`full` 产出 `full`）  
**设置方式：** `/settings`，或 `migrate-v1-config.sh`（由 `/adopt` 运行）在迁移 v1.0 的 `production/review-mode.txt` 时设置。`/start` 与 `/adopt` 自身从不写入它——未设置时，它跟随 `modes.rigor`  
**读取方：** 见下方技能表

**优先级链（所有技能）：** 行内参数标志 → `project.yaml` 中的 `modes.review_mode` → `production/review-mode.txt`（历史回退） → `modes.rigor` 展开（无终结默认值；`minimal`→`solo`，`standard`→`lean`，`full`→`full`）

> **design-review 遵循标准链。** `modes.review_mode` 控制 design-review 的深度，
> 其行内标志为 `--review`，以便与其他所有感知评审模式的技能保持一致；在未设置任何
> 值时，它像它们一样跟随 `modes.rigor`：`minimal`（默认）下为 `solo`，`standard`
> 下为 `lean`。

> **热修复 / 首日补丁例外：** 这些技能是应急或发布关键流水线。它们从不被
> `review_mode` 门控——所有 agent 始终运行。

> **九个 `team-*` 编排器中的 `review_mode`。** `review_mode` 设定总监闸门的深度：
> `full` 生成流水线指定的每个总监闸门，`lean` 跳过总监闸门（除非它们是 PHASE-GATE
> 类型），`solo` 完全跳过闸门生成。没有任何团队流水线会生成 PHASE-GATE
> （`/gate-check` 是它们唯一的生成者），因此在这些编排器中 `lean` 与 `solo` 行为
> 相同，而 `full` 额外增加两项：`/team-release` 的技术总监发布签核，以及在
> `team.size: small` 时 `/team-narrative` 的 `localization-lead` 与 `world-builder`。
>
> 在编排器之外，下方*核心技能*表中的技能按该表所述读取 `review_mode`。

---

### Value intent

| 取值 | 意图 |
|-------|--------|
| `full` | 所有总监与专家闸门均启用。最适合团队、学习，或希望每个决策都获得全面 AI 反馈的人。 |
| `lean` | 仅阶段闸门——跳过各技能的总监签核。即 `rigor: standard` 对应的取值。在质量与 token 成本之间取得平衡。 |
| `solo` | 无闸门、不生成总监（流水线自身的评审，例如 `/team-narrative` 的 ND-CONSISTENCY，仍会运行）。最快。适合有把握的单人迭代。默认值，源自 `rigor: minimal`。 |

---

### Core skills (currently review-mode aware)

| 技能 | full | lean | solo |
|-------|------|------|------|
| **design-review** | Phase 3b 中生成 5–15 位专家代理 | 不生成专家代理——仅单会话分析 | 仅执行 Phase 1–4，不委派，不提示后续步骤 |
| **gate-check** | 总监小组并行运行——**面板宽度由 `modes.workflow` 决定**，与此轴无关 | 总监小组并行运行——宽度规则相同；阶段闸门始终运行 | 仅检查产出物是否存在，不生成总监 |
| **design-system** | 所有章节专家 + CD-GDD-ALIGN 签核闸门 | 仅 Section D 与 H 的专家（当 G 的开关相互影响时也含 G，当视觉反馈是核心时也含 Visual/Audio）；跳过 CD-GDD-ALIGN | 不生成章节专家；跳过 CD-GDD-ALIGN |
| **art-bible** | 所有章节专家 + AD-ART-BIBLE 签核闸门 | 所有章节专家，跳过 AD-ART-BIBLE | 所有章节专家，跳过 AD-ART-BIBLE |
| **architecture-decision** | 引擎专家 + TD-ADR 闸门 | 引擎专家；跳过 TD-ADR | 引擎专家；跳过 TD-ADR |
| **create-architecture** | TD-ARCHITECTURE + LP-FEASIBILITY 代理并行运行 | 两者均跳过 | 两者均跳过 |
| **brainstorm** | CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE | 全部跳过 | 全部跳过 |
| **map-systems** | TD-SYSTEM-BOUNDARY、PR-SCOPE、CD-SYSTEMS | 全部跳过 | 全部跳过 |
| **story-done** | QL-TEST-COVERAGE + LP-CODE-REVIEW | 两者均跳过 | 两者均跳过 |
| **sprint-plan** | PR-SPRINT 可行性检查 | 跳过 | 跳过 |
| **create-epics** | PR-EPIC 范围检查 | 跳过 | 跳过 |
| **create-stories** | QL-STORY-READY + 测试用例规格 | 跳过 | 跳过 |
| **prototype** | CD-PLAYTEST 评审——APPROVE 保留建议；CONCERNS 与 REJECT 交由用户决定 | 跳过——建议未经评审直接成立 | 跳过——建议未经评审直接成立 |
| **milestone-review** | PR-MILESTONE 可行性检查 | 跳过——无制作人结论 | 跳过——无制作人结论 |
| **playtest-report** | CD-PLAYTEST 创意评估 | 跳过 | 跳过 |
| **story-readiness** | QL-STORY-READY 验收标准检查 | 跳过 | 跳过 |
| **create-control-manifest** | TD-MANIFEST（technical-director）评审 | 跳过 | 跳过 |
| **propagate-design-change** | TD-CHANGE-IMPACT（technical-director）评审 | 跳过 | 跳过 |

---

### Skills that do not read `modes.review_mode`

这些技能在 `full`、`lean` 和 `solo` 下运行方式相同。它们都不接受 `--review` 标志。

| 技能 | 各档位下都运行的内容 |
|-------|--------------------------|
| **review-all-gdds** | Phase 2 一致性检查与 Phase 3 设计理论检查，并行执行 |
| **architecture-review** | 引擎审计之后会咨询主引擎专家（未配置引擎时记为 NOT ASSESSED） |
| **dev-story** | 核心程序员路由，外加引擎专家对每个代码故事的检查 |
| **code-review** | 配置引擎后调用语言、着色器与 UI 专家，另为 Logic 与 Integration 故事调用 `qa-tester` |
| **security-audit** | 生成 `security-engineer` 执行审计 |

---

### Team orchestration skills (pipeline behavior — different relationship)

团队技能是执行流水线，不是评审闸门。在其中，`review_mode` 只设定总监闸门深度；
`team.size` 决定选用哪些 agent（见 `## team.size`），而流水线自身的评审步骤在所有
模式下都会运行。

| 技能 | full | lean | solo |
|-------|------|------|------|
| **全部九个 `team-*`** | 流水线指定的每个总监闸门 | 仅 PHASE-GATE 类型闸门 | 无总监闸门 |
| **team-release** | + 在 go/no-go 决策前进行技术总监发布签核 | 不运行签核——记为 `not run (review_mode: lean)` | 不运行签核——记为 `not run (review_mode: solo)` |
| **team-narrative** | ND-CONSISTENCY；在 `team.size: small` 时 + `localization-lead` 与 `world-builder` | ND-CONSISTENCY；在 `small` 时仅 `narrative-director` + `writer` | 当 `narrative-director` 活跃时仍运行 ND-CONSISTENCY |

---

### Special cases and notes

- **gate-check** 是唯一一个 `full` 与 `lean` 行为相同的技能——阶段闸门始终运行。
  只有 `solo` 会跳过它们。这是有意为之：阶段闸门是最低质量底线，不是可选项。
  **运行多少位总监是另一条独立的轴**——`modes.workflow` 设定面板宽度（`minimal` →
  仅 PR，`standard` → TD + PR，`full` → 全部四位），因为总监属于 Opus 档位，小项目
  不应承担与大型项目相同的四人总监小组成本。宽度绝不会软化结论：参与运行者中
  最严格的结论仍然胜出，且 `/gate-check` 会列出它跳过了哪些视角。
- **art-bible** 无论何种模式都始终生成其章节专家——只有最终签核闸门受
  `review_mode` 控制。专家委派对撰写产出物是否有用是强制要求，这一点没有改变。
  **design-system** 不同：`lean` 只为高风险章节（D 与 H，以及重要时的 G 与
  Visual/Audio）保留专家，`solo` 则在没有专家的情况下起草每个章节，且每次跳过的
  生成都会按名称公布。因此，决定 `art-bible` **生成数量**的并不是 `review_mode`，
  而是：(a) `modes.workflow`，通过最终撰写多少章节——`standard` 要求章节 1–4 而非
  全部 9 章，且 Phase 1 会推荐该档位的章节集——以及 (b) 将调用*同一* agent、输入
  *相同*的连续章节（2–4，以及 5–6）合并为一次委派。若不合并，章节 5 和 6 会用
  完全相同的 `sections 1–4` 简报两次生成 `art-director`。每个章节仍由专家撰写；
  逐章节审批与写入文件保持不变。
- **dev-story** 的核心程序员路由（gameplay-programmer、ui-programmer 等）无论何种
  模式都始终运行——只有针对 HIGH 风险故事的可选引擎专家升级受闸门控制。
- **hotfix** 与 **day-one-patch** 豁免——所有 agent 始终运行。
- 当闸门被跳过时，技能会在继续之前输出：`"[GATE-ID] skipped — [mode] mode."`。
  这在所有技能中保持一致。

---

## modes.rigor

**控制：** 项目整体承载多少流程——`/start` 提出的那个设置下方六个开关的单一问题
**取值：** `minimal` | `standard` | `full`
**默认：** `minimal`——理由见 `.claude/hooks/yaml-helper.sh` 中
`_yaml_helper_defaults` 上方的说明块。简版：更重的档位要花更多成本才能达到可运行
代码，却并不会产生更好的结果。
**设置方式：** `/start`（Phase 4：根据用户描述推断、展示、确认后保存）、`/settings`
**读取方：** 没有任何技能直接读取——它是*通过*所提供的六个开关被读取的

**优先级链：** `project.yaml` 中的 `modes.rigor` → 硬编码默认值 `minimal`
（**已锁定**——不可从 `project.local.yaml` 覆盖，与它所前置的四个*磁盘*开关
`modes.workflow`、`docs.density`、`qa.level`、`modes.story_granularity` 一样——
因为这五个都会改变磁盘上存在哪些产出物。它同样前置的两个个人体验开关
`modes.review_mode` 与 `team.size` 则仍可在本地覆盖。）

---

### Expansion table

| `modes.rigor` | `modes.workflow` | `docs.density` | `qa.level` | `modes.story_granularity` | `modes.review_mode` | `team.size` |
|---|---|---|---|---|---|---|
| `minimal` *（默认）* | `minimal` | `terse` | `minimal` | `coarse` | `solo` | `individual` |
| `standard` | `standard` | `balanced` | `standard` | `balanced` | `lean` | `individual` |
| `full` | `full` | `thorough` | `full` | `fine` | `full` | `studio` |

### It fronts, it does not replace

展开结果位于**所有显式来源之下、终结默认值之上**：

```
project.local.yaml → project.yaml → legacy file → rigor expansion → default
```

这一顺序是向下兼容的保证，也是迁移免费的原因。有三点后果值得明确说明：

- **既有 `project.yaml` 的行为完全不变。** 如果它已经设置
  `docs.density: terse`，第 2 步会在咨询展开之前给出答案——因此无论 `rigor` 是否
  存在，其取值和报告的来源（`project.yaml`）都不变。无需迁移，无需升
  `schema_version`。
- **覆盖是双向的。** 与 `workflow_overrides` 的**布尔标志**——它们是叠加式且只能
  更严格——不同，显式设置的开关可以比 rigor 级别所隐含的*更宽松*。
  （`workflow_overrides.system_overrides` 同样是双向的——它替换档位；只有那些标志
  是只能更严格。）
  若继承"只能更严格"的规则，"全面但紧凑"就无法表达，而这正是文档一直以来引用的
  唯一非对角组合。
- **`modes.workflow` 保留 `workflow_overrides.system_overrides`。** 按系统的档位
  仍优先于 rigor 推导出的项目档位。`workflow` 之所以被前置而非折叠掉，正是因为它
  驱动约 5 种不同行为，并拥有唯一的按系统覆盖机制。

因此六个被前置的开关在 `_yaml_helper_defaults` 中**没有条目**。若在那里设置终结
默认值，它会先于展开给出答案，使 `rigor` 对任何没有同时设置子开关的人成为空操作。

### Provenance

派生值报告其来源为 `rigor:<level>`，因此词汇表为
`{project.local.yaml, project.yaml, <legacy path>, rigor:<level>, default,
unset}`。`/settings` 将其渲染为 `(derived from rigor: standard)`，并强制把这五项
追加到它的全量查看列表中——它们都不是任一 YAML 文件的叶子，因此仅枚举文件叶子
恰好会隐藏用户刚刚选择的设置。

---

## modes.workflow

**控制：** 在代码开始之前要求多少设计文档——文档的 token/时间成本与达到可运行代码
的速度之间的取舍  
**取值：** `full` | `standard` | `minimal`  
**默认：** *无*——由 `modes.rigor` 提供（`minimal`（默认值）产出 `minimal`；`standard` 产出 `standard`；`full` 产出 `full`）  
**设置方式：** `/start`（通过 `modes.rigor`）、`/settings`  
**读取方：** 见下方技能表

**优先级链：** `project.yaml` 中的 `modes.workflow` → `modes.rigor` 展开 → *（无硬编码默认值）*

> **为什么中间档位叫 `standard` 而不是 `indie`。** 以开发者类型命名的标签会把
> "开发者类型"与"流程级别"混为一谈。`standard` 描述的是*流程的量*，而不是用户，
> 并且能与 `minimal`、`full` 干净地配对。

> **宽松而非限制：** `workflow` 控制什么是必需的——而不是什么是被允许的。任何技能
> 都可以在任何 workflow 级别下运行。该设置改变的是 gate-check 强制执行什么、
> 完整性检查校验什么，而不是用户可以调用什么。

> **`minimal` 底线：** 即使在 minimal 模式下，代码开始前也要求选定引擎并填写
> **`design/game-brief.md`**——简报中的构建顺序字段就是计划，因此没有单独的
> `sprint-plan` 步骤。两者都只需几分钟，却能防止下游的真正问题。其余一切都可以跳过。

> **通过 `workflow_overrides` 的兜底出口：** 想要*几乎*标准的集合再加一项额外要求
> （例如始终强制 Edge Cases）的用户，应使用 `workflow_overrides`，而不是升级到
> `full`。见下一节。

---

### Value intent

| 取值 | Token/时间成本 | 代码前必需 | 最适合 |
|-------|----------------|---------------------|----------|
| `full` | 高 | 每个系统全部 8 个 GDD 章节、完整架构、所有 ADR、美术圣经、逐屏 UX 规格 | 设计正确性比速度更重要的项目——团队、商业作品、学习完整流水线 |
| `standard` | 平衡 | 每个系统 5 个 GDD 章节、一份架构文档、关键 ADR、游戏概念、系统索引 | 已超出简报承载能力的项目——多个相互作用的系统，或需要他人实现的设计 |
| `minimal` | 低 | 一页 `design/game-brief.md` + 引擎选择（简报中的构建顺序即计划；无单独冲刺计划） | **默认。** 快速进入编码——小范围、game jam 项目，或设计已在脑中。项目成长时再提高 |

**standard 必需的 GDD 章节：** Overview、Detailed Rules、Edge Cases、Dependencies、
Acceptance Criteria。
**standard 条件项：** Formulas——当系统**定义了数值规则**时必需：比率、曲线、阈值、
成本、伤害、掉落权重，或任何平衡性调整会调节的值。仅当系统不定义此类值时才可选。

> **判定标准是系统定义了什么，而不是它叫什么。** `systems-index.md` 中的 `Category`
> 列只是一个*提示*——`Gameplay`、`Economy` 和 `Progression` 系统几乎总是符合——
> 但它不是判定标准，一个定义了数值规则的 `Core`、`UI` 或 `Persistence` 系统同样
> 符合。
>
> 不要把它改述为"当系统类别为 combat、economy、progression 或 AI 时必需"。这四个
> 词并不是 `/map-systems` 写入的词汇：`templates/systems-index.md` 将类别定义为
> `Core · Gameplay · Progression · Economy · Persistence · UI · Audio · Narrative ·
> Meta`，并把 **combat 与 AI 列为 `Gameplay` 下的示例系统**。因此，完全按模板指示
> 归类为 combat 的战斗系统，曾经一个类别都匹配不上，而 Formulas 恰好在最可能需要
> 它的系统上被悄悄丢弃了。`coding-standards.md` 与 `rules/design-docs.md` 早已声明
> 了"有数学"的判定标准；各技能现已与之对齐，而非反过来。

> **`standard` 下 Edge Cases 是必需的。** 跳过它会在实现期间持续产生"等等，如果 X
> 为 null 会怎样？"这类技术债。这 5 个必需章节是产出可实现代码的最小集合。

> **美术圣经在 `standard` 下是条件项。** 仅当项目中存在视觉资源故事时才必需。以代码
> 为主的项目在 `standard` 级别下可以完全跳过它。

---

### Authoring skills

| 技能 | full | standard | minimal |
|-------|------|----------|---------|
| **design-system** | 全部 8 个章节必需 | 5 个必需章节 + 条件项 Formulas；跳过 Player Fantasy、Tuning Knobs | 不要求——游戏简报取代 GDD。仍可自愿运行。 |
| **art-bible** | 全部 9 个章节必需 | 仅当存在视觉资源故事时才要求；要求时至少章节 1–4 | 不要求。仍可自愿运行。 |
| **create-architecture** | 完整架构——所有分层、模块归属、数据流、API 边界、完整 ADR 审计 | 简化——仅系统分层图 + 关键 ADR 列表 | 不要求。仍可自愿运行。 |
| **ux-design** | 每个屏幕都需要 UX 规格 | 仅核心屏幕（主菜单、HUD、主要玩法循环） | 不要求。仍可自愿运行。 |
| **map-systems** | design-system 之前必需 | design-system 之前必需 | 不要求 |
| **architecture-decision** | 必需 ADR 列表上的所有 ADR 都必须完成 | 仅关键 ADR——Foundation 层系统 | 不要求 |

---

### Review and validation skills

| 技能 | full | standard | minimal |
|-------|------|----------|---------|
| **design-review** | 全部 8 个章节都校验——缺少任何章节都会阻止批准 | 校验 5 个必需章节；缺少可选章节会警告但不阻止 | 不适用——没有 GDD 可评审 |
| **review-all-gdds** | 校验所有 GDD 的全部 8 个章节 | 校验所有 GDD 的 5 个必需章节；可选章节仅作提示性展示 | 不适用 |
| **architecture-review** | 完整可追溯性矩阵——所有 GDD、所有 ADR | 缩减范围——仅架构文档 + 关键 ADR | 不适用 |
| **consistency-check** | 完整实体注册表与所有 GDD 章节交叉核对 | 实体注册表仅对照必需章节检查 | 无意义——没有 GDD 可检查 |
| **content-audit** | 完整内容数量审计，对照所有 GDD 规格 | 有限审计——仅统计必需章节中的规格 | 无法运行——不存在系统索引 |

---

### Phase gate enforcement (gate-check)

`gate-check` 是 workflow 影响最显著的地方——产出物清单按阶段、按模式各不相同。

| 闸门 | full | standard | minimal |
|------|------|----------|---------|
| Concept → Systems Design | game-concept.md、游戏支柱、Visual Identity Anchor | 仅 game-concept.md | 仅 `design/game-brief.md`（内容检查，非章节检查） |
| Systems Design → Technical Setup | systems-index、所有 MVP GDD 已评审（8 个章节）、跨 GDD 评审 | systems-index、5 章节 GDD 已评审、跨 GDD 评审可选 | 不适用——简报与代码之间无闸门；该闸门以该说明判定为 PASS |
| Technical Setup → Pre-Production | 引擎、美术圣经章节 1–4+、3+ 个 ADR、架构、UX 规格已启动 | 引擎、仅在存在视觉资源时要求美术圣经、关键 ADR、架构 | 引擎已配置（必需底线） |
| Pre-Production → Production | 冲刺计划、完整美术圣经、史诗、UX 规格、控制清单；建议完成垂直切片及其试玩测试（缺失 → CONCERNS） | 史诗、冲刺计划；建议完成美术圣经、UX 规格、控制清单；建议垂直切片 | 简报的 Build order + `production/epics/` 下的用户故事；垂直切片相关项取消——核心循环有趣且端到端可运行，在当前构建上检查 |
| Production → Polish | 核心机制、测试、冒烟检查、QA 签核、3+ 次试玩测试 | 核心机制、冒烟检查、端到端可玩、1+ 次试玩测试、无未解决的 S1 bug | 冒烟检查、端到端可玩、无未解决的 S1 bug |
| Polish → Release | 所有功能、内容完成、本地化（每个语言执行 `/localize qa`）、QA、冒烟、无未解决的 S1–S3 bug、最新的 `/security-audit` 无未解决的 CRITICAL/HIGH | 所有功能、冒烟、无未解决的 S1 bug、安全审计 | 冒烟、无未解决的 S1 bug |

<!-- gate-check reconciliation: at `full` and `standard` the Vertical Slice
     keeps its long-standing "recommended, not blocking → CONCERNS if absent;
     FAIL if built-and-broken" status — the tier table never upgrades it to a
     hard blocker. At `minimal` its items drop, and two checks on the current
     build replace them. The genuinely-required floor item at this gate is the
     sprint plan at `standard`/`full`; at `minimal` there is no separate
     sprint-plan step — the brief's Build order plus stories is the floor at
     `minimal`. -->

**总监小组宽度**（`/gate-check` 的 Section 4b）是 workflow 在此处的第二项影响。
总监属于 Opus 档位，因此小组规模按项目大小设定，而非固定为四位：

| `workflow` | 小组人数 | 总监 |
|---|---|---|
| `full` | 4 | `creative-director`、`technical-director`、`producer`、`art-director` |
| `standard` | 2 | `technical-director`、`producer` |
| `minimal` | 1 | `producer` |

`review_mode` 仍是决定小组*是否*运行的轴（`solo` 完全跳过它）；workflow 只决定它
有多宽。收窄绝不软化结论——参与运行者中最严格的结论仍然胜出，且 `/gate-check` 会
列出未参与的视角。

---

### Planning and implementation skills

| 技能 | full | standard | minimal |
|-------|------|----------|---------|
| **create-epics** | 要求所有 GDD 已获批（8 个章节） | 要求 5 章节 GDD 已获批 | **跳过**（Option A）——没有单独的史诗文档。`/create-stories` 直接读取 `design/game-brief.md`，并自行合成隐式的史诗容器。 |
| **create-stories** | 要求必需列表上的所有 ADR 均已存在 | 要求关键 ADR 已存在 | 无 ADR 要求 |
| **dev-story** | 要求 TR 注册表 + 治理 ADR——缺失则阻塞，且遇到状态为 `Proposed`、`Deprecated` 或 `Superseded` 的 ADR 也阻塞；缺少控制清单会警告 | TR 注册表可选；仅当被引用的 ADR 缺失或状态为 `Proposed`、`Deprecated`、`Superseded` 时阻塞 | 不要求 TR 注册表或 ADR——依据 `design/game-brief.md` 实现；被引用的 ADR 若缺失或状态为 `Proposed`、`Deprecated`、`Superseded` 仍然阻塞 |
| **story-readiness** | 完整校验 TR 注册表 + ADR + 控制清单；任何被引用的 ADR 缺失或状态为 `Proposed`、`Deprecated`、`Superseded` 都**阻塞** | TR 注册表可选；检查关键 ADR，任何被引用的 ADR 缺失或状态为 `Proposed`、`Deprecated`、`Superseded` 都**阻塞** | 验收标准检查（简报代替 GDD）；任何被引用的 ADR 缺失或状态为 `Proposed`、`Deprecated`、`Superseded` 仍**阻塞** |
| **story-done** | 完整 GDD 可追溯性 + ADR 一致性检查 | 5 章节 GDD 可追溯性检查 | 仅验收标准检查 |
| **qa-plan** | 从全部 8 个 GDD 章节推导完整测试计划 | 从 5 个必需章节推导测试计划 | 仅从验收标准推导测试计划 |
| **regression-suite** | 从所有章节（含 Edge Cases）映射关键路径 | 从必需章节（含 Edge Cases）映射关键路径 | 仅冒烟测试覆盖 |
| **release-checklist** | `production/qa/bugs/` 中存在未解决的 S1、S2 或 S3 bug 会使 Quality Gates 项失败 | 未解决的 S1 失败；未解决的 S2/S3 列为风险 | 未解决的 S1 失败；未解决的 S2/S3 列为风险 |
| **launch-checklist** | 零未解决的 S1–S3 bug，无例外 | 零未解决的 S1；S2 或记录在案的例外 | 零未解决的 S1；S2 或记录在案的例外 |
| **team-release** | qa-lead 核实无未解决的 S1–S3 bug | qa-lead 核实无未解决的 S1 bug | qa-lead 核实无未解决的 S1 bug |

---

### Support skills

| 技能 | full | standard | minimal |
|-------|------|----------|---------|
| **project-stage-detect** | 检查所有文档类型；缺失美术圣经或 UX 规格会被标为缺口 | 调整预期——仅在存在视觉资源故事时才标记美术圣经缺失；非核心 UX 规格不标记 | 有 `design/game-brief.md` + 引擎即为正常状态；GDD 缺失不标记为缺口 |
| **adopt** | 对所有文档类型执行完整格式合规审计 | 审计范围缩减至必需文档 | 仅检查 `design/game-brief.md` 格式 |
| **reverse-document** | 从代码生成完整 8 章节 GDD | 从代码生成 5 章节 GDD | 从代码生成 `design/game-brief.md` |
| **propagate-design-change** | 对所有 ADR 执行完整级联影响分析 | 仅检查关键 ADR 中的引用 | 不适用 |
| **help** | 完整产出物检测——将所有缺失文档作为后续步骤呈现 | 将"缺少什么"调整为仅必需文档——可选文档不作为缺口呈现 | 有 `design/game-brief.md` + 引擎即为正常状态，下一步就是写代码 |

---

### Workflow change mid-project

当通过 `/settings` 更改 `workflow` 时，该技能会输出一条提示信息：

> "Workflow 已从 [old] 变为 [new]。运行 `/content-audit` 查看现在哪些是必需项或
> 额外项。不会自动迁移——既有文件保持原样。"

不会自动删除、自动生成或阻塞任何文档。该设置仅影响此后*新*的强制执行。

---

## workflow_overrides

**控制：** 可选的细粒度要求，用于覆盖所选 workflow 级别
**位置：** **`project.yaml` 的顶层**——是 `modes:` 的兄弟节点，*而非*其子节点
**取值：** 含子标志的对象（见下）
**默认：** 全部为 false / 空
**设置方式：** `/settings`
**读取方：** `/design-system`、`/design-review`、`/art-bible`、`/gate-check`、`/review-all-gdds`、`/qa-plan`

> **为什么特意指出位置。** `resolve_config` 从文档根读取
> `workflow_overrides.system_overrides.*`（`yaml-helper.sh`），而全部 14 个消费方
> 技能文件也都用 grep 匹配同一顶层路径。嵌套在 `modes:` 之下仍是合法 YAML，因此
> 不会报错——只是该设置永远不会被读取。如果你从某处复制了 `workflow_overrides`
> 块，请检查缩进：它属于文档根，绝不在 `modes:` 之下。

**优先级链：** 三个 `workflow_overrides` **布尔标志**（`edge_cases`、`tuning_knobs`、
`art_bible_strict`）是在所选 `workflow` 级别之上的*叠加*——它们只会让要求更严格，
绝不更宽松。它们都没有能退出 workflow 级别所施加要求的取值。

> **`workflow_overrides.system_overrides` 不是标志，也不是叠加式——它会双向替换档位。**
> 该规则不适用于它。在 `full` 项目中，`system_overrides.inventory: minimal` 确实会把
> 该系统的必需章节降为零。这是有意的——见
> `.claude/docs/workflow-modes.md § workflow_overrides`。把叠加规则套在整个键上是
> 错误的：该保证从未适用于 `system_overrides`，因此不要依赖它作为安全网。

---

### Fields

```yaml
workflow_overrides:
  edge_cases: false          # force Edge Cases section required (no-op at standard since already required; relevant at minimal)
  tuning_knobs: false        # force Tuning Knobs section required (relevant at standard, no-op at full)
  art_bible_strict: false    # force all 9 art bible sections required regardless of asset stories
  system_overrides: {}       # per-system tier overrides — see below
```

### Per-system overrides

```yaml
workflow_overrides:
  system_overrides:
    combat: full              # combat-system GDD requires full (8 sections) regardless of project workflow
    boss-encounters: full
    inventory: minimal        # inventory needs no GDD — the game brief covers it (minimal = no required sections)
```

`system_overrides` 是 `system_name: workflow_level` 的映射。被命名的系统使用覆盖值；
所有其他系统使用项目级的 `workflow`。

---

### Affected skills

| 技能 | workflow_overrides 如何改变行为 |
|-------|----------------------------------------|
| **design-system** | 优先读取 `system_overrides[system_name]`；否则回退到项目 `workflow`。应用覆盖值对应的章节要求。 |
| **design-review** | 同样的查找——对被命名的系统按覆盖档位而非项目默认值校验。 |
| **art-bible** | 若 `art_bible_strict: true`，无论 `workflow` 级别如何都要求全部 9 个章节。 |
| **gate-check** | 校验所有必需 GDD 是否完整时会考虑 `system_overrides`。`system_overrides.combat: full` 的系统会阻塞闸门，直到 combat 的全部 8 个章节存在。 |
| **review-all-gdds** | 按每个 GDD 的有效档位（项目 workflow + 任何系统覆盖）进行校验。 |

---

## modes.automation

**控制：** 技能在行动前是否会先征求决策与批准，还是给出建议后直接推进——用户控制力
与速度之间的取舍  
**取值：** `collaborative` | `guided` | `autonomous`  
**默认：** `collaborative`  
**设置方式：** `/start`、`/settings`  
**读取方：** 使用 `AskUserQuestion` 或写入文件的所有 68 个技能

**优先级链：** `project.yaml` 中的 `modes.automation` → 硬编码默认值

> **与 review_mode、workflow 不同，该设置不是逐技能表格。**
> 它定义适用于所有技能的通用交互规则。若逐技能拆解，只会把同一答案重复 68 次。

> **覆盖 COLLABORATIVE-DESIGN-PRINCIPLE.md：** `guided` 与 `autonomous`
> 模式会有意放宽该文档所定义的 Q→O→D→Draft→Approval 协议。这是用户主动选择的。
> `collaborative` 则完全保留该协议。

> **安全网——`automation_always_ask`：** 即使在 `autonomous` 模式下，也可以配置
> 某些类别的决策始终弹出询问。见下一节。

---

### Value intent

| 取值 | 速度 | 控制力 | 变化 |
|-------|-------|---------|--------------|
| `collaborative` | 最慢 | 完全——每个决策都由用户做出 | 当前行为。严格遵循 Q→O→D→Draft→Approval。 |
| `guided` | 平衡 | 高——重大决策由用户做，次要决策自动推进 | AI 说明建议并对次要决策直接推进。AskUserQuestion 仅保留给重大/不可逆决策。 |
| `autonomous` | 最快 | 低——AI 自行决策、记录并推进 | 不调用 AskUserQuestion（`automation_always_ask` 中的类别除外）。无草稿评审。无写入批准。所有决策记入决策日志。 |

---

### Universal rules per mode

#### collaborative (current behavior — no change)

- 每个多选项决策都调用 `AskUserQuestion`
- 每个设计选择都给出 2–4 个选项及其利弊
- 每次写文件前展示完整草稿并获批准
- 每次写入前询问"我可以把它写入 [filepath] 吗？"
- 创建骨架前询问"我可以用骨架创建 [filepath] 吗？"
- 多章节撰写技能中逐章节批准
- 多文件变更需要用户对完整变更集的显式批准

#### guided

- `AskUserQuestion` 仅用于**重大决策**（见下方分类）
- 次要决策：AI 在行内说明建议并推进——例如
  *"这里采用静态工具类模式——它符合现有架构。除非你想调整方向，否则继续。"*
- 更新既有文件：写入前简要展示草稿——给出简短摘要后即推进，不等待明确的"是"
- "我可以写入吗？"仅对**新文件**询问，且新文件会等待回答——对既有文件的更新直接进行
- 重大决策仍会给出选项，但最多 2 个选择，并附明确建议
- 多章节撰写：每个已批准章节立即写入，无逐章节确认提示

#### autonomous

- 不调用 `AskUserQuestion`，**除非**是 `automation_always_ask` 中列出的类别
- 无草稿评审
- 无"我可以写入吗？"提示——直接写入
- 每个决策都直接选择推荐项，不展示备选方案
- 所有决策立即记录到 `production/session-logs/decision-log.md`，包含：时间戳、技能、
  决策点、所选选项、理由
- 用户在会话后查看决策日志，以审计所做的选择

#### every mode — a question with no answer

- 被跳过、被关闭或返回空内容的问题**不是回答**，在任何模式、任何工具下都是如此
  （已关闭的问题、把每个问题都返回为跳过的无头运行、什么都没选的回复）
- 不写入任何内容，不改动模式或设置，也不代其选择任何选项；该问题会以纯文本
  重新询问，并点名它在等待什么
- `autonomous`：该模式本不需要的问题按常规决定并记录；属于 `automation_always_ask`
  类别或由被豁免技能提出的问题会再次询问
- 在无人能回答的场景（CI、无头运行）中，技能会停止并报告正在等待什么，而不是代替选择

---

### Major vs minor decision classification (guided mode)

**重大——guided 模式下始终使用 AskUserQuestion：**

| 决策类型 | 示例 |
|---------------|---------|
| 选择系统名称或文档路径 | "这个系统该叫什么？" |
| 互斥的设计方向 | "实时还是回合制？" |
| 任何会门控下游工作的选择 | 引擎选择、架构方案 |
| 范围变更 | "砍掉这个功能还是延期？" |
| 任何需要大量返工才能更改的决策 | 核心循环机制 |

**次要——guided 模式下由 AI 建议并推进：**

| 决策类型 | 示例 |
|---------------|---------|
| 下一步做哪个章节 | "接下来处理 Edge Cases" |
| 可选章节的纳入 | "加一节 Visual Notes——它符合该系统" |
| 格式与结构选择 | 标题层级、表格还是散文 |
| 为已确定的方向补充细节 | 已批准方案内的子选项 |
| 阶段完成后的下一步路由 | "现在运行 design-review" |

---

### Affected skills by category

**撰写类技能——影响最大。** 在 `collaborative` 下，每份文档会暂停 10–15 次。
在 `guided` 下降至 2–3 次，`autonomous` 下为 0 次。

`brainstorm`、`design-system`、`art-bible`、`create-architecture`、`ux-design`、
`map-systems`、`architecture-decision`、`create-epics`、`create-stories`、
`sprint-plan`、`prototype`

**评审类技能——中等影响。** 呈现发现后暂停，询问下一步做什么。在 `guided` 下
路由决策自动推进。在 `autonomous` 下采用推荐路径并记录。

`design-review`、`architecture-review`、`gate-check`、`review-all-gdds`、
`story-readiness`、`story-done`、`milestone-review`、`playtest-report`

**团队编排技能——中等影响。** 阶段之间暂停进行确认。在 `guided` 下流水线自动推进，
除非状态为 BLOCKED。在 `autonomous` 下完整流水线端到端运行。

`team-combat`、`team-ui`、`team-audio`、`team-qa`、`team-release`、
`team-narrative`、`team-polish`、`team-level`、`team-live-ops`

**实现类技能——影响较低。** 写代码前就架构问题暂停。在 `guided` 下只有真正含糊的
决策才会停下。在 `autonomous` 下选择常规做法并记录。

`dev-story`、`code-review`

**设置与工具类技能——影响最低。** 为初始配置或路由问题暂停。在 `guided` 下自动应用
默认值。在 `autonomous` 下直接采用推荐默认值而不提示。

`start`、`adopt`、`setup-engine`、`retrospective`、`localize`、`propagate-design-change`、
`asset-spec`、`smoke-check`、`qa-plan`、`story-readiness`

---

### Exemptions — skills that ignore the automation setting

这些技能无论该设置如何，都始终以 `collaborative` 方式运行。原因如下。

| 技能 | 为什么始终协作 |
|-------|--------------------------|
| **hotfix** | 紧急决策——用户必须在任何行动前批准范围与风险 |
| **gate-check** | 结果必须经审阅——没有用户确认的闸门结论毫无意义 |
| **day-one-patch** | 发布关键——每个操作都需要显式签核 |
| **setup-engine** | 影响整个项目的一次性不可逆选择 |

---

### Decision log format (autonomous mode)

写入 `production/session-logs/decision-log.md`——仅追加。

```markdown
## [timestamp] — [skill-name]

**Decision point:** [what was being decided]
**Options considered:** [list of options that would have been presented]
**Chosen:** [what was picked]
**Reason:** [one-line rationale]
**Category:** [scope_changes | file_deletions | schema_changes | etc., or "minor"]
```

若文件不存在则创建。它绝不会被截断——每次会话都追加到既有日志。

---

## modes.automation_always_ask

**控制：** 无论自动化模式如何都始终触发 AskUserQuestion 的决策类别
**取值：** 类别名称列表
**默认：** `[scope_changes, file_deletions, schema_changes]`
**设置方式：** `/settings`
**读取方：** 所有遵循 `modes.automation` 的技能

> **让 `autonomous` 变得安全。** 没有它，`autonomous` 就是"AI 字面意义上做所有事，
> 什么都不问"。有了它，AI 会完成大部分工作，但会在你明确指定的破坏性或不可逆
> 决策上停下来。

---

### Recognized categories

| 类别 | 该类别下的决策示例 |
|----------|----------------------------------------|
| `scope_changes` | 砍掉功能、推迟截止日期、拆分/合并史诗、移除验收标准 |
| `file_deletions` | 移除用户故事、删除 GDD、移除系统、移除测试文件 |
| `schema_changes` | 修改 project.yaml、用户故事模板、控制清单、ADR 模板、GDD 模板 |
| `architecture_decisions` | 新建 ADR、替换 ADR、变更系统边界 |
| `version_bumps` | 引擎版本变更、框架版本升级、依赖的主版本变更 |
| `external_calls` | 在 autonomous 模式下调用外部 API（资源生成、AI 服务） |

该列表是这些字符串构成的 YAML 列表。技能会判断当前决策是否属于已配置的某一类别，
若是则无论 `automation` 取值如何都会提示。

---

### Affected skills

| 技能 | 通常触发的类别 |
|-------|--------------------------------|
| **scope-check** | `scope_changes` |
| **propagate-design-change** | `schema_changes`、`architecture_decisions` |
| **architecture-decision** | `architecture_decisions` |
| **setup-engine** | `version_bumps`、`schema_changes` |
| **story-done** | `file_deletions`（移除/替换测试文件时） |
| **asset-spec** | `external_calls`（调用外部生成器时） |

---

## modes.story_granularity

**控制：** 每个用户故事的规模，以及每个史诗/冲刺包含多少用户故事
**取值：** `coarse` | `balanced` | `fine`
**默认：** *无*——由 `modes.rigor` 提供（`minimal`（默认值）产出 `coarse`；`standard` 产出 `balanced`；`full` 产出 `fine`）
**设置方式：** `/start`（通过 `modes.rigor`）、`/settings`
**读取方：** `/create-stories`、`/sprint-plan`、`/sprint-status`、`/story-readiness`

**优先级链：** `project.yaml` 中的 `modes.story_granularity` → `modes.rigor` 展开 → *（无硬编码默认值）*

---

### Value intent

| 取值 | 用户故事形态 | 每冲刺故事数 | 最适合 |
|-------|-------------|-------------------|----------|
| `coarse` | 1 个故事 = 1 个功能。每个 3–5 天工作量。每个故事 5–10 条验收标准。默认值，源自 `rigor: minimal`。 | 2–4 | 单人开发者、做原型、"我很清楚要做什么"的人 |
| `balanced` | 1 个故事 = 1 个任务。每个 1–2 天工作量。每个故事 2–4 条验收标准。即 `rigor: standard` 对应的取值。 | 6–10 | 大多数项目 |
| `fine` | 1 个故事 = 1 条验收标准。每个只需数小时。便于代码评审。频繁执行 /story-done。 | 15–25 | 团队、学习、任何需要细致交接的场景 |

---

### Affected skills

| 技能 | coarse | balanced | fine |
|-------|--------|----------|------|
| **create-stories** | 每个故事承载 5–10 条验收标准，覆盖整个功能 | 每个故事承载 2–4 条验收标准，覆盖一个任务 | 每个故事承载 1 条验收标准；故事名称 = 验收标准的复述 |
| **sprint-plan** | 依据速率每冲刺分配 2–4 个故事。 | 每冲刺分配 6–10 个故事。 | 每冲刺分配 15–25 个故事。 |
| **sprint-status** | 燃尽图按功能规模读取。 | 燃尽图按任务规模读取。 | 燃尽图按验收标准规模读取。 |

---

## docs.density

**控制：** 撰写文档中每个章节的深入程度——与哪些章节为必需无关
**取值：** `terse` | `balanced` | `thorough`
**默认：** *无*——由 `modes.rigor` 提供（`minimal`（默认值）产出 `terse`；`standard` 产出 `balanced`；`full` 产出 `thorough`）
**设置方式：** `/start`（通过 `modes.rigor`）、`/settings`
**读取方：** `/design-system`、`/art-bible`、`/create-architecture`、`/ux-design`、`/map-systems`、`/brainstorm`

**优先级链：** `project.yaml` 中的 `docs.density` → `modes.rigor` 展开 → *（无硬编码默认值）*

> **与 `workflow` 不同，但默认并不独立。** `workflow` 控制存在哪些章节；`density`
> 控制每个章节的深入程度。`modes.rigor` 同时设定两者，因此不作额外指定时你得到的
> 就是那条对角线（`rigor: full` → 8 个章节*且*详尽散文）。非对角组合仍然可达，
> 这也正是 `rigor` 允许双向覆盖的原因：`rigor: full` + 显式的 `docs.density: terse`
> 得到"所有章节都存在，但每个都很紧凑"——即"全面但紧凑"模式，这是任何单个旋钮
> 都无法单独表达的。

---

### Value intent

| 取值 | 每章节的输出风格 |
|-------|--------------------------|
| `terse` | 项目符号列表。每节 2–5 行。跳过理由说明与叙事性铺陈。跳过"在这款游戏中……"之类的开场白。只写实现所需的事实。默认值，源自 `rigor: minimal`。 |
| `balanced` | 带简要理由说明的段落。在有用处给出示例。即 `rigor: standard` 对应的取值。 |
| `thorough` | 完整散文。每个决策都给出理由。包含示例、考虑过的备选方案、设计历史。 |

---

### Combination matrix with workflow

|  | docs.density: terse | balanced | thorough |
|---|---|---|---|
| **workflow: minimal** | 项目符号形式的游戏简报 *（默认）* | 散文形式的游戏简报 | 游戏简报 + 理由说明 |
| **workflow: standard** | 5 个章节，项目符号 | 5 个章节，段落 | 5 个章节 + 示例 |
| **workflow: full** | 8 个章节，项目符号 *（全面但紧凑）* | 8 个章节，段落 *（当前 full）* | 8 个章节 + 理由说明 + 示例 |

---

### Affected skills

| 技能 | terse | balanced | thorough |
|-------|-------|----------|----------|
| **design-system** | 每个 GDD 章节 2–5 条项目符号。跳过 Player Fantasy 类开场白。 | 用段落解释关键决策。 | 完整散文，含决策历史与考虑过的备选方案。 |
| **art-bible** | 每个美术圣经章节是约束与参考资料的符号列表。 | 用段落解释每项视觉选择。 | 完整散文，含风格探索、参考资料、每项选择的理由。 |
| **create-architecture** | 分层图 + 决策要点。不写长篇论述。 | 图 + 用段落解释分层选择。 | 完整散文，含每层的理由、取舍与考虑过的备选方案。 |
| **ux-design** | 线框描述 + 交互要点。 | 线框图 + 用段落描述流程。 | 完整散文，含用户研究摘要与备选流程考量。 |
| **map-systems** | 一行式系统描述。 | 每个系统一段简述 + 依赖说明。 | 逐系统的完整理由说明 + 关系分析。 |
| **brainstorm** | 支柱要点 + 概念要点。 | 支柱 + 概念，附简要理由。 | 支柱 + 概念 + 详尽理由 + 备选方案。 |

---

## testing.framework

**控制：** 项目使用哪个测试框架——决定 CI 中的测试运行器命令与各引擎假设
**取值：** 因引擎而异（见表格）
**默认：** 由 `/setup-engine` 依据引擎选择自动填充
**设置方式：** `/setup-engine`、`/settings`
**读取方：** `/test-helpers`——唯一引用它的技能。`/qa-plan`、`/dev-story`、`/regression-suite`、`/test-setup` 与 `/smoke-check` **不**提及该键，尽管它们看似是合理的读取方。
  *（通过 grep 推导。像 `session_state_enabled()` 这样的辅助函数式读取不会显现，因此请将此列表视为已验证的下限，而非上限。）*

**优先级链：** `project.yaml` 中的 `testing.framework` → 引擎默认值

> **迁移自 `technical-preferences.md`。**

---

### Engine defaults

| 引擎 | 默认测试框架 | 备选方案 |
|--------|------------------------|--------------|
| Godot | `gdunit4` | `godot-test`、`WAT` |
| Unity | `unity-test-framework` | `nunit`、自研 |
| Unreal | `unreal-automation` | Google Test、自研 |

---

### Affected skills

| 技能 | `testing.framework` 如何使用 |
|-------|--------------------------------|
| **qa-plan** | 测试计划贴合该框架的惯用法（断言风格、测试夹具模式、参数化测试） |
| **dev-story** | 在实现简报中把测试框架名称传给程序员子代理 |
| **regression-suite** | 测试文件命名与发现模式匹配框架约定 |
| **test-setup** | 为引擎搭建正确的测试布局（Godot 的 gdUnit4 位于 `addons/gdUnit4/` + `tests/`；Unity 的 `Assets/Tests/` asmdef；Unreal 的 `Source/<Module>/Private/Tests/`） |
| **smoke-check** | 调用与该框架相配的测试运行器 |

---

## testing.strict

**控制：** 测试失败或缺失测试证据时是阻止用户故事关闭，还是仅警告并允许继续——按测试类型分别设定
**取值：** `{logic, integration, visual, ui, config}` → `true | false` 的映射
**默认：** `{logic: true, integration: true, visual: true, ui: true, config: false}`
**设置方式：** `/settings`
**读取方：** `story-done`、`story-readiness`、`gate-check`、`smoke-check`、`dev-story`、`test-evidence-review`

> **按类型而非单一布尔值。** 全局的 `testing.strict: true|false` 会强制全有或全无：
> 要么所有测试失败都阻塞，要么都不阻塞。按类型设定符合多数团队的实际工作方式——
> 逻辑与视觉采用严格闸门，冒烟检查仅作建议。

> **与 `qa.level` 组合：** `qa.level` 控制证据是否**必需**。`testing.strict` 控制
> 在证据存在时失败是否**阻塞**。若 `qa.level: minimal`，严格映射实际上会被忽略
> （不要求证据，也就没有什么需要严格对待）。

---

### Value intent per type

| 类型 | `true` | `false` |
|------|--------|---------|
| `logic`（公式、AI、状态机） | 单元测试失败**阻塞**——故事无法关闭 | 失败仅**警告**——故事可在有警告的情况下关闭 |
| `integration`（多系统） | 集成测试失败**阻塞** | 失败仅**警告** |
| `visual`（动画、VFX、手感） | 截图证据缺失/失败**阻塞**（默认） | 仅作建议——故事可关闭 |
| `ui`（菜单、HUD、界面） | 缺少界面截图**阻塞**（默认） | 仅作建议——故事可关闭 |
| `config`（平衡性调整） | 冒烟检查失败**阻塞** | 仅作建议——故事可关闭（默认） |

---

### Affected skills

| 技能 | strict.[type]: true | strict.[type]: false |
|-------|---------------------|----------------------|
| **story-done** | 该类型的故事因测试/证据失败而无法关闭 | 故事可关闭；警告记入故事文件 |
| **story-readiness** | 在实现前校验测试需求存在——缺失则阻塞 | 校验但不阻塞——以警告形式呈现 |
| **gate-check** | 该类型的 CI 失败会阻塞阶段推进 | 该类型的 CI 失败以关注项呈现，而非阻塞项 |
| **smoke-check** | 冒烟失败（config 严格）会阻塞 QA 交接 | 冒烟失败会被标记，但交接继续 |
| **dev-story** | 引用测试需求——若缺失则将该故事标为不可验证 | 引用测试需求——仅作建议 |
| **test-evidence-review** | 该类型证据的缺口是**阻塞**项（本次运行以 CONCERNS 结束） | 该缺口为**建议**性质 |

> **未设置键时的解析。** 每个技能读取 `testing.strict.<type>`；若不存在，则把
> `testing.strict` 当作普通布尔值读取（旧式写法）；若仍不存在，则回退到硬编码
> 默认值。对 `story-done`、`story-readiness`、`gate-check` 与 `dev-story` 而言，
> 硬编码默认值就是上方的按类型默认映射（logic/integration/visual/ui 严格，config
> 建议）。**`smoke-check` 是例外**：它是构建健康闸门，因此未设置的
> `testing.strict.config` 默认为*严格*（FAIL 会阻塞 QA 交接）——以保留其 v1.0 行为。
> 只有显式设置 `testing.strict.config: false` 才会让冒烟失败仅作建议。

---

## qa.level

**控制：** 把用户故事标记为 Done 需要哪些测试证据
**取值：** `minimal` | `standard` | `full`
**默认：** *无*——由 `modes.rigor` 提供（`minimal`（默认值）产出 `minimal`；`standard` 产出 `standard`；`full` 产出 `full`）
**设置方式：** `/start`（通过 `modes.rigor`）、`/settings`
**读取方：** `/story-done`、`/story-readiness`、`/dev-story`、`/smoke-check`、`/gate-check`、`/qa-plan`、`/regression-suite`、`/team-qa`、`/test-evidence-review`、`/create-stories`、`/retrospective`、`/test-setup`

**优先级链：** `project.yaml` 中的 `qa.level` → `modes.rigor` 展开 → *（无硬编码默认值）*

> **与 `testing.strict` 是不同的轴。** `qa.level` = 需要什么证据。`testing.strict`
> = 失败是否阻塞。想要"最小 QA"的用户设置 `qa.level: minimal`，严格映射便会
> 实际失效。

---

### Value intent

| 方面 | minimal | standard | full |
|--------|---------|----------|------|
| 逻辑类故事 | 无需测试，不标记缺口 | 需要单元测试（strict.logic 控制阻塞） | 单元测试，且每条验收标准都被覆盖 |
| 集成类故事 | 无需测试 | 需要集成测试或试玩测试文档 | 同上 + 回归覆盖 |
| 视觉类故事 | 需要截图 + 主管签核——观感从不豁免（strict.visual 控制阻塞） | 同上 | 同上 |
| UI 类故事 | 需要每个涉及界面的截图——从不豁免（strict.ui 控制阻塞） | 同上 | 同上 |
| 配置/数据类故事 | 无需证据 | 冒烟检查仅作建议 | 需要冒烟检查（除非 `testing.strict.config: false`，否则阻塞） |
| /story-done 测试闸门 | 仅验收标准，但 UI 与 Visual/Feel 截图永不豁免 | 按故事类型强制执行 | 对每种故事类型都强制执行 |
| /gate-check 阶段强制执行 | 无测试闸门 | 逻辑 + 集成必须通过 | 完整覆盖 + 回归套件 |
| /dev-story 路由提示 | 无"Test required: ..."行 | 包含按类型的测试需求 | 按类型，且每条标准都必须被覆盖 |
| 回归套件要求的阶段 | 从不 | Polish 阶段 | Production 阶段 |
| 最适合 | Game jam 作品、一次性原型、快速迭代 | 大多数项目 | 商业项目、主机认证、学习、要求严格的团队 |

---

### Affected skills

| 技能 | minimal | standard | full |
|-------|---------|----------|------|
| **story-done** | 仅检查验收标准——不要求测试证据，但 UI 与 Visual/Feel 截图永不豁免 | 需要按类型的证据；严格程度由 `testing.strict` 决定；超过一半标准未测试则阻塞 | 需要按类型的证据；Config/Data 冒烟报告默认阻塞；任何未测试的标准都阻塞 |
| **story-readiness** | 不校验测试需求，但 UI 与 Visual/Feel 截图要求除外 | 校验每种故事类型的测试需求 | 校验测试需求 + 覆盖率目标 |
| **dev-story** | 路由提示中没有"Test required"行 | 把按类型的测试需求传给程序员代理 | 按类型的需求，且每条标准都必须被测试覆盖 |
| **smoke-check** | 可选；无游戏测试（WAIVED）时，若已设置则运行 `commands.smoke`（否则 `commands.build`），由启动与关键路径检查承担结论；构建存在但无人启动则为 NOT ASSESSED | 阶段推进前必需 | 每次提交前必需 |
| **gate-check** | 阶段推进时不强制执行测试 | 逻辑 + 集成测试必须通过 | 完整覆盖检查 + 回归套件 |
| **qa-plan** | 完全跳过或仅最小冒烟计划 | 按故事类型的完整计划 | 完整计划 + 按系统的覆盖率目标 |
| **regression-suite** | 不生成 | 进入 Polish 阶段时生成 | 进入 Production 阶段时生成 |
| **team-qa** | 没有测试的逻辑、集成或配置/数据类故事为 WAIVED；其在人工 QA 中走查验收标准即为证据 | 对这些类型而言自动化测试就是证据 | 同上 |
| **test-evidence-review** | 无测试证据的故事为 WAIVED 而非 MISSING；既有测试中的缺口为 ADVISORY；截图永不豁免 | 按类型审查证据；阻塞/建议由 `testing.strict` 决定 | 同上 |

---

## qa.coverage_minimum

**控制：** 在 `qa.level: full` 下强制的最低代码覆盖率百分比
**取值：** 0–100 的整数，或 `null` 表示未设置
**默认：** `null`
**设置方式：** `/settings`
**读取方：** 仅 `/gate-check`。`/story-done` 不引用该键，也没有 CI 运行器读取它。
  *（通过 grep 推导。像 `session_state_enabled()` 这样的辅助函数式读取不会显现，因此请将此列表视为已验证的下限，而非上限。）*

**优先级链：** `project.yaml` 中的 `qa.coverage_minimum` → 若为 `null` 则不强制

> **仅在 `qa.level: full` 下有意义。** 在 minimal 与 standard 下被忽略。在 standard
> 或 minimal 级别设置非空值会在会话启动时发出警告：
> *"coverage_minimum 已设置，但 qa.level 不是 full——该值不会被强制执行。"*

> **实现因引擎而异。** 各引擎的覆盖率测量方式不同：
> - Godot：gdunit4 覆盖率报告（markdown 导出）
> - Unity：Unity Test Framework 覆盖率（xml 导出）
> - Unreal：基于 clang 标志的 gcov 风格覆盖率
> CCGS 不对这些做统一——gate-check 读取与该引擎相配的报告。

---

## strict_gate_checks

> ### RESERVED - NOT IMPLEMENTED
>
> **没有任何技能或钩子读取该设置。设置它没有任何效果。** 下文描述的是预期设计，
> 而非当前行为。
>
> 你在设置时不会校验该值，也没有任何东西读取它。

**控制：** 阶段闸门失败是阻止阶段推进，还是仅发出警告
**取值：** `true` | `false`
**默认：** `true`
**设置方式：** `/settings`
**读取方：** 暂时没有（预期读取方：`/gate-check`）

**优先级链：** `project.yaml` 中的 `strict_gate_checks` → 硬编码默认值 `true`

> **与 `review_mode: solo` 不同。** `review_mode: solo` 会*完全*跳过闸门——总监甚至
> 不会运行。`strict_gate_checks: false` 会正常运行闸门，但把结论视为建议性质。

---

### Value intent

| 取值 | 行为 |
|-------|----------|
| `true` | 默认。FAIL 或 BLOCKING-CONCERNS 结论会阻止阶段推进。`project.stage` 不会前进。用户必须处理发现项并重新运行闸门。 |
| `false` | 所有闸门结论都是建议性质。`/gate-check` 仍会运行并报告发现项。无论结论如何，`project.stage` 都会在用户确认后前进。 |

---

### Affected skills

| 技能 | true | false |
|-------|------|-------|
| **gate-check** | FAIL 结论会在写入新阶段前停止执行；CONCERNS 结论会提示用户，但默认"停留在当前阶段"。 | 所有结论都作为信息呈现；用户会被询问"仍然前进吗？"，默认为是。 |

---

## team.size

**控制：** 默认哪些 agent 处于活跃状态——单人开发者不应在每次变更时都受到工作室级闸门审查
**取值：** `individual` | `small` | `studio`
**默认：** *无*——由 `modes.rigor` 提供（`minimal`/`standard` 产出 `individual`，`full` 产出 `studio`）
**设置方式：** `/start`（通过 `modes.rigor`）、`/settings`
**读取方：** 所有 `team-*` 技能、`/gate-check`、所有通过 `Agent` 生成 agent 的技能

**优先级链：** `project.local.yaml` 中的 `team.size` → `project.yaml` → `modes.rigor` 展开（`full` → `studio`，否则 `individual`） → 无终结默认值。可本地覆盖——它是个人体验旋钮，而非磁盘产出物。

> **`minimal`/`standard` 下为 `individual`，`full` 下为 `studio`。** CCGS 的用户绝大多数
> 是单人独立开发者，因此两个较轻的 rigor 档位会把 `team.size` 解析为 `individual`——
> 一个 `minimal`（默认）或 `standard` 项目每个角色只获得一个活跃 agent，而不是 15 个
> （含总监与主管）。只有 `rigor: full` 才会选择完整的 `studio` 名册；大型项目上的
> 小团队应显式设置 `team.size: small`，它会优先于 rigor 推导出的值。

> **与 `workflow` 是不同的轴。** `workflow` 控制*要求哪些文档*。`team.size` 控制
> *有哪些 agent 来撰写它们*。一个处于 `workflow: full` 的单人开发者仍然不需要全部
> 49 个 agent——他们需要的是用更小的活跃集获得同样的覆盖。

---

### Active agent set per value

| 取值 | 活跃集 | 备注 |
|-------|-----------|-------|
| `individual` | 核心 8 个：`producer`、`game-designer`、`gameplay-programmer`、引擎专家（由引擎驱动）、`technical-artist`、`sound-designer`、`qa-tester`、`writer`。**默认。** | 总监与 lead-* 仅在显式调用时运行（例如通过 `/architecture-decision`）。核心 8 之外的专家通过其最近的核心 agent 路由。每个 `team-*` 技能会为每个取值指定自己的集合，该集合可能位于核心 8 之外（`team-release` 运行 `release-manager`）；各技能自己的 `team.size` 列表具有权威性，下方"Affected skills"表与之对应。 |
| `small` | 核心 15 个：总监（CD、TD、PR）+ 主管（LP、AD、QL、ND）+ game-designer + systems-designer + 引擎专家 + technical-artist + sound-designer + qa-tester + ux-designer + writer | `team-*` 技能会加入其 `small` 集合（见下）；多数技能只在 `studio` 下才达到完整流水线。 |
| `studio` | 全部 49 个 agent 可用。相关时路由引擎子专家（例如独立于 `unity-specialist` 的 `unity-dots-specialist`）。`team-combat`、`team-ui` 与 `team-polish` 中的对抗式评审环节。 | 商业作品、学习完整组织架构、并行工作的大型团队。 |

---

### Affected skills

| 技能 | individual | small | studio |
|-------|------|-------|--------|
| **team-combat** | 单个 agent（gameplay-programmer）运行流水线；仅当标记了 AI 工作时才升级至 ai-programmer | 按文档所述的默认流水线 | 默认 + 主引擎专家可使用其子专家 + 对抗式评审环节（Phase 5 的 qa-tester 寻找它如何被破坏） |
| **team-narrative** | 仅 writer；narrative-director 仅在明确的支柱冲突时调用 | narrative-director + writer，且在 `review_mode: full` 时加 localization-lead 与 world-builder | 全部六个叙事 agent，无论评审模式如何 |
| **team-ui** | ui-programmer + ux-designer | + accessibility-specialist + art-director | + 引擎 UI 专家 + 对抗式评审环节（Phase 4 的评审者寻找它在何处不符合规格） |
| **team-audio** | 仅 sound-designer | + audio-director + technical-artist + gameplay-programmer | + accessibility-specialist + 主引擎专家 |
| **team-level** | 仅 level-designer | + systems-designer + art-director + qa-tester | + narrative-director + world-builder + accessibility-specialist |
| **team-qa** | 仅 qa-tester；qa-lead 仅在阶段闸门处调用 | qa-lead + qa-tester 流水线 | qa-lead + 按故事生成 qa-tester + 签核 |
| **team-release** | 仅 release-manager | + producer + devops-engineer + qa-lead + community-manager | + security-engineer + analytics-engineer + localization-lead + performance-analyst，且游戏为多人时加 network-programmer |
| **team-polish** | performance-analyst + technical-artist；没有启用的程序员，因此 Phase 2 的优化清单交给 `/dev-story` | + sound-designer + qa-tester + engine-programmer（实现 Phase 2 的优化清单），且当 Phase 1 把某个成因追溯到内容创作工具时加 tools-programmer | 与 small 相同的 engine-programmer，另加对抗式评审环节（Phase 5 的 qa-tester 寻找它如何被破坏） |
| **team-live-ops** | live-ops-designer + economy-designer | + analytics-engineer + community-manager | + writer + narrative-director |
| **gate-check** | 面板宽度属于 `modes.workflow` 的轴，与此轴无关（闸门始终运行）——`team.size` 只影响每位总监评审内的专家深度 | 对总监而言与 individual 相同；总监评审内的专家使用 small 集合 | 同上，另加引擎子专家 |
| **architecture-decision** | TD-ADR（在 `full` 评审模式下）+ 主引擎专家 | 同上 | 同上——任何规模下都没有子专家或对抗式评审者 |

---

### Special cases

- `team.size` 不决定总监是否运行：`/gate-check` 的面板遵循 `review_mode` 与 `modes.workflow`，且没有任何 `team-*` 流水线会生成总监阶段闸门。在团队技能中，"阶段闸门"是其自身流水线列出的决策点之一，与 `automation` 模式无关。
- `individual` 不会禁用 agent——它只改变默认哪些处于活跃状态。任何 agent 仍可按名称调用。
- 当 `team.size: individual` 且需要非核心 agent 时（例如多人故事需要 `network-programmer`），技能会发出信息性提示，并通过最近的活跃核心 agent 路由。

---

## platform.multiplayer

**控制：** 项目是否包含实时在线多人——决定路由哪些专家、要求哪些架构章节  
**取值：** `true` | `false`  
**默认：** 无——未设置不等于 `false`  
**设置方式：** `/settings`  
**读取方：** `security-audit`、`team-release`（以及 `security-engineer` agent）

**优先级链：** `project.yaml` 中的 `platform.multiplayer` → 未设置（`platform.*` 锁定在 `project.yaml`，因此 `project.local.yaml` 无法设置它）。除 `/settings` 外没有任何东西写入它，因此在多数项目上它处于未设置状态：`/security-audit` 与 `/team-release` 会询问游戏是否为多人，而不是把未设置当作 `false`。

> **与 `platform.online` 不同。** `multiplayer` 特指*实时多人*（网络专家、netcode
> 评审、复制架构）。`platform.online` 涵盖其他所有在线功能（云存档、排行榜、
> 遥测）。见下一节。

> **这是项目属性，不是模式。** 它描述游戏是什么，而不是流水线如何运作。它位于
> `platform` 下，与 `targets`、`primary_input`、`gamepad_support` 并列——不在 `modes` 中。

---

### Value intent

| 取值 | 含义 |
|-------|---------|
| `true` | 游戏具有实时在线多人。`/security-audit` 会运行其 netcode 类别，并将 HIGH 级别的发现评为发布阻塞；`/team-release` 会加入 `network-programmer` 的签核。 |
| `false` | 无实时多人。`/security-audit` 跳过 netcode 类别并说明这一点；`/team-release` 不生成 `network-programmer`。 |

---

### Affected skills

| 技能 | multiplayer: true | multiplayer: false |
|-------|------------------|-------------------|
| **security-audit** | 包含 netcode 评审——认证、复制、作弊向量 | 跳过 netcode 评审，并在报告中说明 |
| **team-release** | `network-programmer` 纳入发布签核流水线 | `network-programmer` 排除在外 |

没有其他技能读取该键：`/dev-story`、`/create-architecture` 与 `/gate-check` 依据
摆在面前的用户故事、GDD 或架构来决定联网范围。

---

## platform.online

**控制：** 项目是否具有任何在线功能（排行榜、云存档、遥测、IAP）
**取值：** `true` | `false`
**默认：** 无——未设置不等于 `false`
**设置方式：** `/settings`
**读取方：** `security-audit`、`team-release`（以及 `security-engineer` agent）

**优先级链：** `project.yaml` 中的 `platform.online` → 未设置（`platform.*` 锁定在 `project.yaml`，因此 `project.local.yaml` 无法设置它）。除 `/settings` 外没有任何东西写入它：`/security-audit` 与 `/team-release` 会询问，而不是把未设置当作 `false`。

> **与 `platform.multiplayer` 相互独立。** 带 Steam Cloud 与排行榜的单人游戏是
> `online: true, multiplayer: false`。这两个设置对专家路由的影响不同。

---

### Value intent

| 取值 | 含义 |
|-------|---------|
| `true` | 项目包含在线服务（云存档、排行榜、成就、遥测、IAP、任何运行时调用外部 API 的功能）。当此项或 `platform.multiplayer` 为 true 或未设置时，`/security-audit` 会运行 Category 2（网络与多人——含明文令牌检查）；`/team-release` 会加入 `security-engineer` 签核。 |
| `false` | 项目完全离线。仅当 `platform.multiplayer` 也为 false 时，`/security-audit` 才跳过 Category 2。 |

---

### Affected skills

| 技能 | online: true | online: false |
|-------|--------------|---------------|
| **security-audit** | 运行 Category 2（网络）——服务器权威、数据包校验、速率限制、明文令牌 | 仅当 `platform.multiplayer` 也为 false 时才跳过 Category 2 |
| **team-release** | 游戏在线或存储玩家数据时进行 `security-engineer` 签核 | 没有由在线功能驱动的安全签核 |

没有其他技能读取该键：`/create-architecture`、`/dev-story`、`/team-live-ops`
与 `/gate-check` 依据摆在面前的文档来决定在线范围。

---

## platform.cert_tier

> ### WIRED — this setting is live
>
> `/launch-checklist` 与 `/release-checklist` 都会解析它并按其四个取值分支——
> `none` 不输出认证章节，`itch` 与 `steam` 输出各自商店页面的要求，`console`
> 输出完整平台认证——当它未设置时会询问哪些平台在范围内。

**控制：** 认证目标——界定 `/launch-checklist` 的需求范围
**取值：** `none` | `itch` | `steam` | `console`
**默认：** *无*——未设置就保持未设置，因此技能会主动询问
**设置方式：** `/settings`——没有其他东西写入它，因此在你设置之前它一直保持未设置（技能会询问）
**读取方：** `/launch-checklist`、`/release-checklist`

**优先级链：** `project.yaml` 中的 `platform.cert_tier` → 未设置（不替换任何默认值：
未设置是缺失的决策，`none` 是已做出的决策，技能必须能区分二者）

---

### Value intent

| 取值 | 所需合规项 | 最适合 |
|-------|---------------------|----------|
| `none` | 无认证 | 内部发布、alpha、game jam 作品（这是显式选择——未设置不等于 `none`） |
| `itch` | itch.io 上传要求（构建体积、页面设置、年龄标签） | 独立 Web/桌面发布 |
| `steam` | Steamworks 集成、商店页面、成就、depot 构建、系统需求、通用内容规则 | 商业 PC 发布 |
| `console` | 平台认证（PlayStation/Xbox/Switch）——繁重合规：TRC/XR/Lotcheck、存档数据规则、手柄映射规则、年龄评级机构 | 主机发布 |

---

### Affected skills

| 技能 | none | itch | steam | console |
|-------|------|------|-------|---------|
| **launch-checklist** | 仅内部发布——无外部要求 | + itch.io 页面设置、butler 上传、构建体积 | + Steamworks 集成、商店页面、成就 depot、通用内容检查 | + 平台特定 TRC、认证提交、主机存档格式合规 |
| **release-checklist** | 仅冒烟通过 + 版本号提升 | + itch.io 页面已上线、构建已上传至 butler | + Steam 商店页面已上线、depot 已推送、成就已上线 | + 平台提交已获接受、年龄评级机构已通过 |

---

## accessibility.target

> ### RESERVED - NOT IMPLEMENTED
>
> **没有任何技能或钩子读取该设置。设置它没有任何效果。** 下文描述的是预期设计，
> 而非当前行为。
>
> 你在设置时会校验其拼写是否合法，然后便将其忽略。下文所述的无障碍专家路由与
> Polish 阶段审计**在任何级别下都不会发生**——`/team-ui`、`/team-level`、
> `/team-polish` 与 `/gate-check` 都不读取该设置，`/start` 也不会询问它。

**控制：** 无障碍承诺级别——决定是否路由无障碍专家，并对审计要求设门
**取值：** `none` | `standard` | `aaa`
**默认：** `none`
**设置方式：** `/settings`
**读取方：** 暂时没有（预期读取方：`/team-ui`、`/team-level`、`/team-polish`、`/gate-check`）

**优先级链：** `project.yaml` 中的 `accessibility.target` → 硬编码默认值 `none`

> **默认是 `none` 而非 `standard`。** CCGS 的多数用户是单人开发者与 game jam
> 创作者——若默认 `standard`，会对那些无障碍专家纯属额外负担的项目自动生成该专家。
> `/start` 不会询问它；你通过 `/settings` 自行设置。

---

### Value intent

| 取值 | 必需功能 | 专家路由 |
|-------|-------------------|--------------------|
| `none` | 无强制要求 | 不生成 `accessibility-specialist` |
| `standard` | 色盲安全配色、任何语音内容的字幕、按键重映射 | `accessibility-specialist` 在 team-ui、team-level 中运行 |
| `aaa` | 完整 Game Accessibility Guidelines：运动、视觉、听觉、认知类别 | `accessibility-specialist` 在所有 team-* 技能中运行；Polish 阶段强制审计 |

---

### Affected skills

| 技能 | none | standard | aaa |
|-------|------|----------|-----|
| **team-ui** | 不生成 accessibility-specialist | HUD/菜单评审纳入 accessibility-specialist | 每个界面都纳入 accessibility-specialist + 无障碍审计环节 |
| **team-level** | 不生成 accessibility-specialist | accessibility-specialist 评审关卡的色盲安全性与指引标识 | accessibility-specialist 评审完整的移动性/音频/认知考量 |
| **team-polish** | 无无障碍环节 | 加入最终无障碍环节 | 完成前需要完整无障碍审计 |
| **gate-check** | 任何阶段都无无障碍检查 | Polish 闸门检查 standard 要求的必需功能 | Polish 闸门要求完整的 Game Accessibility Guidelines 合规审计 |

---

## cadence.sprint_length and cadence.milestone_length

> ### RESERVED - NOT IMPLEMENTED
>
> **没有任何技能或钩子读取该设置。设置它没有任何效果。** 下文描述的是预期设计，
> 而非当前行为。
>
> 本文件之外没有任何引用。

**控制：** 规划时使用的默认冲刺与里程碑时长
**取值：**
- `sprint_length`：`1w` | `2w` | `3w` | `4w` | `none`
- `milestone_length`：`4w` | `6w` | `8w` | `12w`
**默认：** `sprint_length: 2w`、`milestone_length: 8w`
**设置方式：** `/settings`
**读取方：** 暂时没有（预期读取方：`/sprint-plan`、`/milestone-review`、`/sprint-status`、未来的速率跟踪）

**优先级链：** `project.yaml` 中的 `cadence.*` → 硬编码默认值

> **`sprint_length` 取 `none`** 表示持续流 / 看板式——没有冲刺边界。之后按需手动
> 调用 `/sprint-plan`。速率跟踪按周而非按冲刺进行。

---

### Affected skills

| 技能 | 变化内容 |
|-------|--------------|
| **sprint-plan** | 产能按 `sprint_length × team.size velocity baseline` 计算。取 `none` 时该技能改为输出持续流计划。 |
| **milestone-review** | 回顾范围对应的里程碑窗口 = `milestone_length`。 |
| **sprint-status** | 燃尽图 x 轴跨度 = `sprint_length`。 |
| **retrospective** | 冲刺回顾按 `sprint_length` 节奏触发（当 sprint_length 为 `none` 时按周触发）。 |

---

## performance.target_framerate and performance.frame_budget_ms

**控制：** 帧率目标及其每帧毫秒预算
**取值：** 整数（例如 `60`、`16.67`）
**默认：** 无——未设置表示从未承诺过任何预算
**设置方式：** 用户手动设置，或通过 `/settings`
**读取方：** `/perf-profile`、`/gate-check`、`/team-polish`

## performance.draw_call_limit and performance.memory_ceiling_mb

**控制：** 每帧绘制调用上限与总内存上限
**取值：** 整数
**默认：** 无——未设置表示从未承诺过任何预算
**设置方式：** 用户手动设置，或通过 `/settings`
**读取方：** `/perf-profile`、`/gate-check`、`/team-polish`

> **每个设置都需要在本文件中有自己的 `## ` 标题，而不只是表格中的一行。**
> 死设置审计从这些标题推导它要检查的内容，因此仅在表格中被提及的设置对它不可见
> ——它既无法在失去读取方时被报告为 DEAD，也无法在获得读取方时被捕获。
> 落在审计视野之外的设置，正是"有文档但已死"或"能工作却被列为已死"的条目
> 悄然存续的方式。
>
> **未设置不是零，也不是默认值。** 没人设置过的预算不等于已经达成的预算——
> 对于没有承诺目标的指标，`/perf-profile` 必须报告 `NOT ASSESSED`，而不是拿占位值
> 去测量。基于臆造预算、背后没有任何剖析数据算出的余量数值，读起来像是通过，
> 实际并非通过；见 `.claude/rules/skill-authoring.md` 中的义务 1 与义务 2。

## performance.enforce

**控制：** 性能预算违规是发出警告还是阻塞
**取值：** `warn` | `block` | `off`
**默认：** `warn`
**设置方式：** `/settings`
**读取方：** `/perf-profile`、`/gate-check`、CI 运行器

**优先级链：** `project.local.yaml` 中的 `performance.enforce` → `project.yaml` → 硬编码默认值 `warn`，由 `resolve_config --keys performance.enforce` 解析

> **从解析后的配置块读取，绝不直接读 `project.yaml`。** 该键在 `/settings --local` 的白名单上。`/perf-profile` 的 Phase 0 与 `/gate-check` 的 Section 3 就是上表承诺的两个读取方——一个键通过枚举校验、被接受、被展示，却无人读取，正是这条警告所防范的失败。

> **与 `testing.strict` 模式一致。** 定义当 `performance.target_framerate`、
> `frame_budget_ms`、`draw_call_limit` 或 `memory_ceiling_mb` 中定义的预算被超出时
> 会发生什么。

---

### Value intent

| 取值 | 行为 |
|-------|----------|
| `warn` | 默认。性能剖析会把违规记录为发现项。CI 会记录但不失败。`/gate-check` 将其作为关注项呈现，而非阻塞项。 |
| `block` | 剖析失败会阻塞 CI。`/gate-check` 将违规视为 FAIL 结论（自 Polish 阶段起）。 |
| `off` | 性能预算仅供参考——不对剖析运行设门，也不呈现发现项。 |

---

## project.stage

**控制：** 当前开发阶段——决定 gate-check 校验哪些内容，以及预期存在哪些产出物  
**取值：** `Concept` | `Systems Design` | `Technical Setup` | `Pre-Production` | `Production` | `Polish` | `Release`  
**默认：** `Concept`  
**设置方式：** 由 `/gate-check` 在 PASS 时设置，或在用户显式接受 CONCERNS 时设置（被接受的风险会被记录）；FAIL 绝不会推进它——绝不要手动设置  
**读取方：** `gate-check`、`project-stage-detect`、`help`、`day-one-patch`、`team-release`、`launch-checklist`、`release-checklist`、`map-systems`、`team-qa`、`adopt`

> **阶段数量：** 本文档采用 gate-check 所实现的 7 阶段现实：
> `Concept | Systems Design | Technical Setup | Pre-Production | Production | Polish | Release`

> **这是项目属性，不是模式。** 它记录项目在其生命周期中所处的位置。只有 `/start`
> （在上手引导时）与 `/gate-check` 会写入它——`/gate-check` 在 PASS 结论且用户确认时写入，
> 或在 CONCERNS 结论且用户显式接受其风险时写入（风险会被记录）；FAIL 绝不会推进它。
> 会话中途绝不要手动写入，除非是为了纠正错误的自动检测。

> **历史回退 + 双写。** 阶段先读 `project.yaml` 中的 `project.stage`，再读历史文件
> `production/stage.txt`，最后是产出物自动检测。当 `/gate-check` 推进阶段时，它会同时
> 双写 `project.yaml` 与 `production/stage.txt`，因此尚未迁移的钩子仍能正确解析。
> `/start` 也会双写初始阶段。历史 `.txt` 文件在
> `.claude/scripts/migrate-v1-config.sh --finalize` 时退役。

---

### Stage progression and gate requirements

每一行是离开该阶段时必须通过的闸门。

| 离开阶段 | 通过所需的关键产出物 | gate-check 写入 |
|------------|-------------------------------|-------------------|
| **Concept** | `game-concept.md`、设计支柱、Visual Identity Anchor | `Systems Design` |
| **Systems Design** | `systems-index.md`、所有 MVP GDD 已评审、跨 GDD 一致性检查 | `Technical Setup` |
| **Technical Setup** | 引擎已配置、美术圣经章节 1–4（在 `standard` 下仅当存在视觉故事时）、3+ 个 ADR、架构文档、可追溯性索引、测试框架、无障碍与交互模式文档 | `Pre-Production` |
| **Pre-Production** | 史诗已定义、首次冲刺计划、UX 规格、控制清单（垂直切片是建议项，非必需） | `Production` |
| **Production** | 核心机制已实现、主路径可玩、冒烟检查通过、QA 签核 | `Polish` |
| **Polish** | 所有功能完成、内容完成、本地化、安全审计、无未解决的 S1–S3 bug | `Release` |

闸门会随 `modes.workflow` 调整——`standard` 与 `minimal` 级别下的要求见
`modes.workflow` 一节。

---

### Affected skills

| 技能 | 如何使用阶段 |
|-------|------------------|
| **gate-check** | 读取当前阶段以确定要校验哪个闸门。在 PASS 时或在用户显式接受 CONCERNS 时写入下一阶段。 |
| **project-stage-detect** | 先读取 `project.stage`——若已设置，则以它为权威。仅在缺失时才回退到启发式检测。 |
| **help** | 用阶段判断"你在流水线的哪一步"，并给出正确的后续步骤。 |
| **sprint-status** | 在状态摘要中显示当前阶段。 |
| **day-one-patch** | 仅当阶段为 `Release` 或 `Polish` 时继续；否则说明当前尚不合适。 |
| **team-release** | 除非阶段为 `Release`，否则在 Phase 1 前停止（"请先运行 `/gate-check release`"）；继续需要显式覆盖，并记录在 go/no-go 记录与报告中。它绝不写入阶段。 |

---

## project.kind

> ### RESERVED - NOT IMPLEMENTED
>
> **没有任何技能或钩子读取该设置。设置它没有任何效果。** 下文描述的是预期设计，
> 而非当前行为。
>
> 本文件之外没有任何引用。

**控制：** 项目属于哪种类型——据此路由技能子集
**取值：** `game` | `tool` | `engine` | `mod` | `library`
**默认：** `game`
**设置方式：** `/start`、`/setup-engine`
**读取方：** 许多技能（建议性路由——见下）

**优先级链：** `project.yaml` 中的 `project.kind` → 硬编码默认值 `game`

---

### Value intent

| 取值 | 含义 | 停用内容 |
|-------|---------|-------------------|
| `game` | 默认。适用完整的 CCGS 框架。 | 无 |
| `tool` | 开发者工具，而非游戏 | 跳过美术圣经、叙事、关卡设计、试玩测试 |
| `engine` | 游戏底层的自研引擎或库 | 完全跳过游戏专属关注项（叙事、美术、试玩测试） |
| `mod` | 面向既有游戏的模组 | 跳过引擎设置；假定沿用父引擎；缩小架构范围 |
| `library` | 可复用库 | 强调测试 + API 设计；设计文档更轻量；无资源流水线 |

---

### Affected skills

| 技能 | game | tool | engine | mod | library |
|-------|------|------|--------|-----|---------|
| **brainstorm** | 完整的游戏概念产出 | 工具概念产出（用户、问题、方案） | 引擎概念（目标用例、范围） | 模组概念（改变了什么） | 库概念（API 接口面、目标使用者） |
| **art-bible** | 在相应 workflow 级别下必需 | 跳过 | 跳过 | 可选（取决于视觉范围） | 跳过 |
| **map-systems** | 完整的游戏系统分解 | 工具子系统 | 引擎子系统 | 被修改系统的映射 | 库模块映射 |
| **playtest-report** | 在相应阶段必需 | 跳过，或以用户测试替代 | 跳过 | 必需（兼容性测试） | 跳过，或以 API 使用测试替代 |
| **setup-engine** | 游戏引擎设置 | 跳过，或以构建工具设置替代 | 自指——引擎*就是*项目本身 | 假定沿用父引擎 | 跳过，或以库脚手架替代 |

---

## engine.name and specialists

**控制：** 在代码实现、评审与架构验证时路由到哪些引擎专属专家代理  
**取值：** `Godot` | `Unity` | `Unreal`  
**默认：** `[UNSET]`——必须通过 `/setup-engine` 配置  
**设置方式：** `/setup-engine`  
**读取方：** `dev-story`、`code-review`、`architecture-decision`、`create-architecture`、`team-combat`、`team-ui`、`team-audio`

> **目前存放在 `technical-preferences.md` 中**，而非 `project.yaml`。完成
> YAML 扩展后，`engine.name` 与专家路由表会迁移到 `project.yaml` 的
> `specialists` 块。技能行为不变——改变的只是来源文件。

> **这是项目属性，不是模式。** 引擎选择驱动专家路由的方式，与
> `platform.multiplayer` 驱动网络路由相同——技能响应的是关于项目的事实，
> 而不是流程偏好。

---

### Specialist routing by engine

| 引擎 | 语言/代码专家 | 着色器专家 | UI 专家 | 其他专家 |
|--------|--------------------------|-------------------|---------------|----------------------|
| **Godot** | `godot-gdscript-specialist`（GDScript）或 `godot-csharp-specialist`（C#）——由 `engine.language` 决定 | `godot-shader-specialist` | `godot-specialist` | `godot-gdextension-specialist` |
| **Unity** | `unity-specialist` | `unity-shader-specialist` | `unity-ui-specialist` | `unity-addressables-specialist`、`unity-dots-specialist` |
| **Unreal** | `unreal-specialist` | `unreal-specialist` | `ue-umg-specialist` | `ue-gas-specialist`、`ue-blueprint-specialist`、`ue-replication-specialist` |
| **[UNSET]** | 不生成专家——发出警告 | 不生成专家 | 不生成专家 | 无 |

---

### Affected skills

| 技能 | `engine.name` 如何使用 |
|-------|------------------------|
| **dev-story** | 把代码类用户故事路由给程序员代理，随后把改动文件交给语言专家（未配置时为通用引擎专家）做引擎 API 检查。 |
| **code-review** | 根据被评审文件的类型，把评审路由给语言、着色器或 UI 专家。 |
| **architecture-decision** | 撰写前加载 `docs/engine-reference/[engine]/VERSION.md`。生成引擎专家以验证 ADR 的 API 正确性与版本截止后的兼容性。 |
| **create-architecture** | 依据引擎选择，把引擎专属约束与模式写入架构文档。 |
| **team-combat / team-ui / team-audio** | 生成各自流水线指定的引擎专家：team-combat 生成主引擎专家（来自 `team.size: small`），team-ui 生成引擎 UI 专家（`specialists.ui`，在 `studio` 下），team-audio 生成主引擎专家（在 `studio` 下）。其余六个 `team-*` 技能不生成任何专家。 |

---

## commands

> **自「运行并观察」步骤起已启用。** 该块在 v1.1 的大部分时间里都是 RESERVED——
> 由 `/setup-engine` 写入，却无人读取。随着解析检查与冒烟闸门的落地，`test`、`smoke`
> 与 `build` 先后获得了读取方；`run` 最后才获得读取方，即 `/dev-story` Phase 6
> 步骤 4 开始启动游戏以便观察之时。底部的逐技能表现在描述的是当前行为，而非意图。
> `validate-push.sh` 曾被列为读取方，但从未真正读取过。

**控制：** 用于构建、测试、运行与冒烟测试项目的显式 shell 命令
**取值：** 字符串——可被 shell 执行的命令
**默认：** `[UNSET]`——由 `/setup-engine` 填入引擎典型默认值
**设置方式：** `/setup-engine`、`/settings`
**写入方：** `/setup-engine`、`/settings`。**读取方：** `test`——`/smoke-check`、`/hotfix`（缩小到受影响的测试套件）、`/bug-report`（verify 模式，缩小到受影响的测试套件）、`/day-one-patch`（针对性修复，以及已设置时的更广泛回归——未设置则记为 NOT ASSESSED）、`/dev-story`（Godot 解析检查的可执行文件解析）、`/test-setup`（Unreal 上 `<Project>.` 过滤根）、`project-coherence.sh`；`smoke`——`/dev-story`（Unity 解析检查）、`/smoke-check`（测试被 WAIVED 时的构建检查）；`build`——`/smoke-check`（测试被 WAIVED 且 `smoke` 未设置时的构建检查）、`project-coherence.sh`；`run`——`/dev-story`（Phase 6 步骤 4，即运行并观察步骤）。`/launch-checklist` 与 `/regression-suite` 会提及这些命令，但不会执行它们。
  *（通过 grep 推导。辅助函数式读取不会显现，因此请将此列表视为已验证的下限，而非上限。）*

**优先级链：** `project.yaml` 中的 `commands.*` → 引擎典型默认值 → 无可用命令

> **为什么要求显式：** 没有这个块，CCGS 就不得不猜测调用项目的引擎典型约定。
> 逐项目显式声明更好——可覆盖项目自定义构建的情况（例如某个 Godot 项目用 gdunit4
> 跑测试，却用自定义导出脚本做构建）。

---

### Fields

每条命令可以是简单字符串（在所有操作系统上使用），也可以是感知操作系统的映射：

**简单形式**（一条命令，在每个操作系统上使用）：
```yaml
commands:
  build: "godot --headless --export-debug '<PRESET>'"   # ask; see the note below
  test:  "godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode"
  run:   "godot --path . --windowed --resolution 1280x720"
  smoke: "godot --headless --quit-after 5"
```

注意 `build` 是简单形式最不适合的那一行：导出预设命名的是一个*平台*，因此单条构建
字符串只有在项目只构建一个平台时才可移植。其余三行确实与操作系统无关。

**感知操作系统的形式**（不同操作系统使用不同命令）：
```yaml
commands:
  build:
    default: "godot --headless --export-debug 'Linux/X11'"
    windows: "godot.exe --headless --export-debug 'Windows Desktop'"
    macos:   "godot --headless --export-debug 'macOS'"
  test:
    default: "godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode"
  run:
    default: "godot --path . --windowed --resolution 1280x720"
  smoke:
    default: "godot --headless --quit-after 5"
```

**解析规则：** 若取值为字符串，则在任何操作系统上原样使用。若取值为映射，
技能/钩子会读取当前操作系统并选取匹配的键（`linux`、`windows`、`macos`）。若无
操作系统专属键匹配，则回退到 `default`。

这解决了 Windows/Linux/macOS 之间路径与可执行文件名称的差异，同时不破坏白名单
（`commands` 仍锁定在 project.yaml——操作系统专属键位于被锁定的文件内部，而非
本地覆盖）。

| 字段 | 用途 |
|-------|---------|
| `build` | 供 CI 或发布使用的完整项目构建。`/smoke-check` 仅在 `commands.smoke` 未设置时把它作为 WAIVED 路径的构建检查来运行；`project-coherence.sh`（`/smoke-check` 首先运行它）会检查它命名的导出预设，而 `/launch-checklist` 只询问构建是否产出有效产物。 |
| `test` | 运行完整测试套件。由 `/smoke-check` 运行，并由 `/hotfix`、`/bug-report`（verify 模式）与 `/day-one-patch` 缩小到受影响的测试套件后运行；`project-coherence.sh` 会检查它命名的测试运行器。`/regression-suite` **不**运行它。 |
| `run` | 以固定分辨率窗口化启动**游戏**——而非编辑器。由 `/dev-story` Phase 6 步骤 4 用来观察功能并留存截图；逐引擎追加的捕获标志见 `.claude/docs/run-and-observe.md`。 |
| `smoke` | 最小化的「能否启动？」检查。由 `/dev-story` 作为 Unity 解析检查（Phase 6 步骤 2）运行，也由 `/smoke-check` 在 `qa.level: minimal` 豁免测试时作为构建检查运行。 |

---

### Engine defaults

当 `/setup-engine` 运行时，它会依据引擎选择填充 `commands`——但 **build** 行除外，
那一行必须**询问**用户。构建产物由项目自定义的字符串命名（Godot 导出预设、Unity
构建目标），本仓库中没有任何引擎参考资料能提供它。见 `/setup-engine` 的
§"The Godot `build` row must not hardcode `'Linux/X11'`"。

| 引擎 | build | test | run | smoke |
|--------|-------|------|-----|-------|
| Godot | `godot --headless --export-debug '<PRESET>'` | `godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode` | `godot --path . --windowed --resolution 1280x720` | `godot --headless --quit-after 5` |
| Unity | `"<Unity editor>" -batchmode -quit -projectPath . -buildTarget <TARGET> -build<PLATFORM>Player Builds/<Target>/<Game>.exe` | `"<Unity editor>" -batchmode -runTests -projectPath . -testPlatform EditMode -testResults test-results/editmode.xml` | `Builds/<Target>/<Game>.exe -screen-width 1280 -screen-height 720 -screen-fullscreen 0` | `"<Unity editor>" -batchmode -quit -projectPath . -logFile -` |
| Unreal | `"<UE root>/Engine/Binaries/DotNET/AutomationTool/AutomationTool.exe" BuildCookRun -project="$(pwd -W 2>/dev/null || pwd)/<project>.uproject" -platform=Win64 -build -cook`（逐项目确认） | `"<UE root>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$(pwd -W 2>/dev/null || pwd)/<project>.uproject" -ExecCmds="Automation RunTests <project>.; Quit" -unattended -nullrhi -stdout -FullStdOutLogOutput` | `"<UE root>/Engine/Binaries/Win64/UnrealEditor.exe" "$(pwd -W 2>/dev/null || pwd)/<project>.uproject" -game -windowed -ResX=1280 -ResY=720` | `"<UE root>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$(pwd -W 2>/dev/null || pwd)/<project>.uproject" -game -nullrhi -unattended -stdout -ExecCmds="Quit"` |

表中 Unreal 一行是 Windows 的写法。`/setup-engine` 在 Linux 上写入 Linux 块
（`Engine/Build/BatchFiles/RunUAT.sh`、`Engine/Binaries/Linux/UnrealEditor`），在
macOS 上只写入 `build`，把 `test`、`run` 与 `smoke` 留为未设置，并在 `project.yaml`
中加一条注释，请你通过 `/settings` 设置它们——见
`docs/engine-reference/unreal/current-best-practices.md` 的 "Command Line"。

> **`<PRESET>` 与 `<TARGET>` 是占位符，不是可供复制的取值。** Godot 导出预设就是
> 操作者输入到 `export_presets.cfg` 中的字符串；随附默认值按平台而定
> （`Windows Desktop`、`macOS`、`Web`、`Linux/X11`）。复制一个你并不拥有的预设名，
> 会得到一条以 `Unknown export preset` 失败的构建命令；复制一个你*确实*拥有、
> 但并非本意的预设名，会得到一条成功却构建了错误平台的命令。后者才是危险的那个。
> 如果尚无任何预设——这很常见，因为 `/setup-engine` 通常在项目还没有任何预设时
> 运行——请写入 `[TO BE CONFIGURED]`，而不是猜测一个名称。

用户可按需通过 `/settings commands.<field>=<value>` 或直接编辑 `project.yaml` 逐项目覆盖。

---

### Affected skills

| 技能 | `commands` 如何使用 |
|-------|------------------------|
| **smoke-check** | 运行 `commands.test`，未设置时使用引擎默认值；在 Unreal 上会先构建编辑器目标。这是 QA 交接的关键路径。 |
| **launch-checklist** | 输出一个清单**项**，询问构建是否产出有效产物。它**不**运行 `commands.build`；验证是一个人工步骤。 |
| **validate-push.sh** | **不**读取 `commands.*`。它会对推送到受保护分支（`main`/`master`/`release/*`）发出警告，且不运行任何构建或冒烟命令——其中的阻塞路径已被注释掉，因此它永远不会让推送失败。 |
| **dev-story** | Phase 6 步骤 2 是解析检查：Godot 上运行 `.claude/scripts/godot-parse-check.gd`，Unity 上运行 `commands.smoke`，Unreal 上构建编辑器目标。Phase 6 步骤 4 运行 `commands.run`——窗口化启动游戏——以观察功能并留存截图（`.claude/docs/run-and-observe.md`）。 |
| **regression-suite** | 通过 **glob 匹配测试文件名**来映射覆盖率。它**不**调用 `commands.test`，因此这里的覆盖率意味着「存在测试文件」，而绝不是「测试通过」。 |

---

## naming

**控制：** 项目的代码命名约定
**取值：** 见下方字段列表
**默认：** 因引擎而异（由 `/setup-engine` 自动填充）
**设置方式：** `/setup-engine`、`/settings`
**读取方：** `/adopt`、`/architecture-review`、`/asset-spec`、
`/create-architecture`、`/create-control-manifest`、`/dev-story`、
`/vertical-slice`——各自从 `project.yaml` 读取 `naming.*`，并把这些约定
传入简报、清单或规格。**`/code-review` 不读取，`validate-commit.sh` 也不读取**。
  *（读取方列表通过 grep 推导，因此请将其视为已验证的下限，而非上限——
  通过辅助函数读取取值的技能不会显现。）*

> **这些约定是指导，不是闸门。** 它们通过被传入简报、清单与规格，到达实际写代码
> 的人手中。没有任何东西检查结果：`/code-review` 不会依据它们校验文件，
> `validate-commit.sh` 也不会对违规发出警告——两者都不含任何命名逻辑。如果你需要
> 强制执行，必须自行添加。
>
> **资源文件名。** 当 Godot 的 `assets/` 下某个文件的名称包含大写字母、空格或连字符
> 时，`validate-assets.sh` 会发出警告（它期望小写加下划线），且它不接受任何配置输入。
> `/asset-spec` 依据 `naming.*` 指定资源名称。Unity 的 `Assets/` 与 Unreal 的
> `Content/` 不做命名检查：这些引擎以 PascalCase 命名资源。在 Godot-C# 上，
> `/setup-engine` 会设置 `naming.files: PascalCase`，此时该钩子会对完全按
> `/asset-spec` 所指定方式命名的资源发出警告。`naming.files` 按其自身示例
> （`PlayerController.cs`）描述的是**源文件**，且没有键管理资源文件名，因此在那种
> 情况下请把该钩子的命名警告视为建议性质。

> **从 `technical-preferences.md` 迁移而来**，该文件正在被删除。命名约定是项目级
> 事实，由项目上的每个人共享，因此它们应与其他结构化配置一起位于 `project.yaml`。

---

### Fields

| 字段 | 取值 | Godot 默认值 | Unity 默认值 | Unreal 默认值 |
|-------|--------|---------------|---------------|----------------|
| `classes` | `PascalCase` \| `snake_case` \| `camelCase` | PascalCase | PascalCase | PascalCase |
| `variables` | `snake_case` \| `camelCase` | snake_case | camelCase | camelCase |
| `constants` | `SCREAMING_SNAKE` \| `PascalCase` | SCREAMING_SNAKE | SCREAMING_SNAKE | SCREAMING_SNAKE |
| `signals` (Godot) / `events` (Unity, Unreal) | `past_tense` \| `on_event_name` | past_tense | on_event_name | OnEventName |
| `files` | `snake_case` \| `PascalCase` \| `kebab-case` | snake_case | PascalCase | PascalCase |
| `scenes` / `prefabs` | `snake_case` \| `PascalCase` | snake_case | PascalCase | PascalCase |

> **`signals` 与 `events`：** Godot 原生使用 signals；Unity 使用 C# events 或
> UnityEvents；Unreal 使用 delegates 与 dynamic multicast。为在各引擎间保持一致，
> 该字段在 project.yaml 中仍名为 `signals`——无论何种引擎，都把它理解为
> 「类事件的回调」。

---

### Affected skills

| 技能 | 命名约定如何使用 |
|-------|--------------------|
| **dev-story** | 把命名约定作为实现上下文的一部分传给程序员子代理 |
| **create-control-manifest** | 把约定输出为清单行（classes、variables、signals/events、files、constants） |
| **asset-spec** | 按已配置的约定指定资源命名 |
| **create-architecture** / **architecture-review** | 与 `performance.*` 一同作为项目配置读取 |
| **vertical-slice** / **adopt** | 作为项目配置读取；`/adopt` 以 MEDIUM 严重度审计合规性 |

没有任何技能或钩子*依据*这些约定校验代码——见上方说明。

---

## features.session_state

**控制：** 执行框架是运行完整的会话跟踪流水线（钩子、日志文件、`active.md`
检查点），还是依赖骨架优先的产出文件来恢复  
**取值：** `off` | `on`  
**默认：** `on`  
**设置方式：** `/settings`  
**读取方：** 五个钩子——`session-start.sh`（仅其恢复预览）、
`pre-compact.sh`、`session-stop.sh`、`log-agent.sh` 与 `log-agent-stop.sh`。没有技能读取它，`statusline.sh` 也不读取。

> **`on` 是推荐设置。** 长篇幅技能会预先写出自描述的骨架文件，这本身就能覆盖
> 大部分任务中途的恢复；会话流水线还会增加会话开始时的检查点预览、会话归档与
> 子代理计数。只有在你想省下那段预览的 token 时才应把它设为 `off`。

> **优先级链：** `project.local.yaml` 中的 `features.session_state` →
> `project.yaml` → 硬编码默认值 **`on`**。钩子通过 `yaml-helper.sh` 中的
> `session_state_enabled()` 读取它，并在为 `off` 时提前退出。
> 技能不读取它：无论其取值如何，`/dev-story` 与 `/story-done` 都会更新
> `active.md` 中的检查点。

> **默认值刻意设为 `on`。** `.claude/docs/context-management.md` 让你把
> `production/session-state/active.md` 当作崩溃恢复检查点来依赖，因此把此项默认
> 关闭会悄悄夺走恢复能力、会话归档与子代理计数。`off` 所节省的——检查点预览，
> 每次会话开始最多约 750 个 token——属于显式退出
> （`/settings features.session_state=off`），绝非静默默认。

> **`session-start.sh` 是按块门控，而非在顶部门控。** 它的冲刺、里程碑与 git
> 上下文不属于会话状态流水线；只有 `active.md` 恢复预览受门控。它的检查同样采用
> 失败即放行（fail OPEN）——该钩子会有条件地 source `yaml-helper.sh`，而未定义的
> 函数为假值，这会无形地抑制恢复检查点。

---

### Value intent

| 取值 | 意图 |
|-------|--------|
| `off` | 通过骨架优先的产出文件恢复。长篇幅技能在开始前写出完整骨架（所有章节标题、空正文）。若上下文被清除或压缩，代理会读取骨架 + 相关文档并继续。五个会话状态钩子什么都不做，因此没有日志；技能仍会更新 `active.md` 中的检查点，但会话开始不会显示它。每次会话开始最多节省约 750 个 token。 |
| `on` | 完整的会话跟踪。会话结束归档、压缩日志与代理审计日志全部启用。在每次会话开始时增加检查点预览，上限为 25 行或 3,000 个字符（最多约 750 个 token）。压缩钩子写入磁盘日志，不向 Claude 的上下文添加任何内容。 |

---

### Hook behavior

> **实现说明：** 功能开关检查位于每个钩子脚本内部，而不是在执行框架层面。每个
> 感知会话状态的钩子都会在顶部调用 `yaml-helper.sh` 中的
> `session_state_enabled()`（先 awk 读取 `project.local.yaml`，再读取 `project.yaml`），
> 若取值为 `off` 则静默退出、不产生任何输出——但 `session-start.sh` 例外，它只跳过
> 自己的恢复预览。这确保了执行框架始终触发钩子——由钩子决定是否采取行动。

| 钩子 | session_state: off | session_state: on |
|------|--------------------|-------------------|
| **session-start.sh** | 正常运行（git/冲刺上下文）——跳过 `active.md` 检查点预览 | 完整运行，包括 `active.md` 检查点预览 |
| **detect-gaps.sh** | 照常运行——缺口检测独立于会话状态 | 照常运行 |
| **pre-compact.sh** | 空操作——静默退出（不追加压缩日志） | 向 `compaction-log.txt` 追加一行且不打印任何内容（PreCompact 输出永远不会到达 Claude；由 `session-start.sh` 恢复上下文） |
| **session-stop.sh** | 空操作——静默退出 | 当 `active.md` 有变化时把它归档到 `session-log.md`，追加提交与未提交文件名，把生成计数写入 `session-cost.md`；不打印任何内容 |
| **log-agent.sh** | 空操作——静默退出 | 追加到 agent-audit.log |
| **log-agent-stop.sh** | 空操作——静默退出 | 追加到 agent-audit.log |

---

### File existence by mode

| 文件 | session_state: off | session_state: on |
|------|--------------------|-------------------|
| `production/session-state/active.md` | 仍由技能写入；会话开始不显示它 | 由技能写入；会话开始显示其检查点 |
| `production/session-logs/session-log.md` | 不写入 | 每次会话 `active.md` 的仅追加归档 |
| `production/session-logs/compaction-log.txt` | 不写入 | 压缩事件的仅追加时间戳日志 |
| `production/session-logs/agent-audit.log` | 不写入 | 代理生成/完成事件的仅追加日志 |

---

### Skeleton-first pattern (session_state: off recovery mechanism)

长篇幅技能必须把写出骨架文件作为第一个动作——在任何章节讨论开始之前。骨架包含
所有章节标题，正文为空，并在每个章节处带一个 `<!-- STATUS: incomplete -->` 标记。

```markdown
# Combat System — GDD

## Overview
<!-- STATUS: incomplete -->

## Player Fantasy
<!-- STATUS: incomplete -->

## Detailed Rules
<!-- STATUS: incomplete -->
...
```

当每个章节被批准并写入后，标记会变为 `<!-- STATUS: done -->`。
恢复时（`/clear` 或压缩之后），代理会读取骨架，识别哪些章节为 `done`、哪些为
`incomplete`，读取相关 ADR 与系统索引，并从第一个 `incomplete` 章节继续。无需
`active.md`。

**要求实现骨架优先的技能：**

| 技能 | 输出文件 | 骨架写入时机 |
|-------|-------------|----------------------|
| **design-system** | `design/gdd/[system].md` | Phase 1（章节讨论）之前 |
| **art-bible** | `design/art/art-bible.md` | 从 `.claude/docs/templates/art-bible.md` 生成，在询问之后、章节 1 获批时写入 |
| **create-architecture** | `docs/architecture/architecture.md` | 非骨架优先：在 Phase 7 完成询问后一次性写入（对既有文档就地更新） |
| **ux-design** | `design/ux/[screen].md` | 屏幕讨论之前 |
| **create-stories** | `production/epics/[epic-slug]/story-NNN-[slug].md` | 非骨架优先：在步骤 6 写入，此时询问已列出每个文件 |
| **create-epics** | `production/epics/[epic-slug]/EPIC.md` | 非骨架优先：在其逐史诗询问「May I write `production/epics/[epic-slug]/EPIC.md` and add its row to `production/epics/index.md`」之后写入 |
| **map-systems** | `design/gdd/systems-index.md` | 系统枚举之前 |
| **brainstorm** | `design/gdd/game-concept.md`（`standard`/`full`）· `design/game-brief.md`（`minimal`） | 概念讨论之前 |

> **关于代理：** `world-builder` 与 `narrative-director` 是代理，不是可调用的技能
> ——它们没有 SKILL.md 文件。这些代理的长篇产出通过上方技能（design-system、
> art-bible 等）生成，这些技能负责强制执行骨架优先。

---

### Status line behavior

> **阶段检测始终独立于会话状态。** 无论 `session_state` 取何值，`statusline.sh`
> 都会从 `project.yaml` 的 `project.stage` 或产出物启发式规则自动检测阶段；面包屑
> 同样如此：`statusline.sh` 从不读取 `session_state`。（在 `workflow: minimal` 下，
> 状态栏显示用户故事数量而非阶段。）

| 功能 | session_state: off | session_state: on |
|---------|--------------------|-------------------|
| 上下文百分比显示 | 始终显示 | 始终显示 |
| 模型显示 | 始终显示 | 始终显示 |
| 阶段显示 | 来自 project.yaml 或启发式规则——但在 `workflow: minimal` 下由 `Minimal · <done>/<total> stories`（尚无故事时为 `Minimal · brief`）取代 | 相同 |
| 史诗/功能/任务面包屑 | 从 `active.md` 中的 `<!-- STATUS -->` 块解析（不受门控） | 从 `active.md` 中的 `<!-- STATUS -->` 块解析 |

---

### Affected skills

技能以两种方式与会话状态交互：**推断**（读取 `active.md` 以补全缺失的参数）与
**提取**（在完成工作后追加一个 SESSION EXTRACT 块）。两者都不受门控：没有技能读取
`session_state`，因此无论其取值如何，两者都会发生。

#### Inference — skills that read `active.md` to fill in missing arguments

当 `active.md` 中没有任何可供推断的内容时，这些技能必须显式接收参数。若调用时
未提供参数，它们应提示用户，而不是静默失败。

| 技能 | 从 `active.md` 推断什么 | 未找到任何内容时的回退 |
|-------|----------------------------------|---------------------|
| **dev-story** | 活跃用户故事的路径（未提供参数时） | 提示用户输入故事路径 |
| **story-done** | 进行中用户故事的路径（未提供参数时） | 提示用户输入故事路径 |
| **team-release** | 目标版本（未提供参数时） | 提示用户输入版本 |
| **team-qa** | 活跃冲刺（未提供参数时） | 提示用户输入冲刺文件 |
| **help** | 当前任务与 STATUS 块，用于生成感知上下文的建议 | 在没有会话上下文的情况下响应——仅从冲刺/史诗中给出后续步骤 |

#### Extraction — skills that write session state to active.md

这些技能在完成工作后写入一个结构化块，无论 `session_state` 是什么。
`/dev-story` 与 `/story-done` 会覆盖 `<!-- CHECKPOINT -->` 块；其余技能追加一个
SESSION EXTRACT。

| 技能 | 写入 active.md 的内容 |
|-------|-----------------------------|
| **dev-story** | 检查点：故事路径、下一步、阻塞项、改动文件、运行结果 |
| **story-done** | 检查点：结论、故事路径、下一个故事、技术债数量 |
| **architecture-review** | 结论、TR 覆盖率计数、新增 TR-ID、GDD 标记、ADR 缺口、报告路径 |
| **prototype** | 原型范围、当前阶段、关键决策 |
| **vertical-slice** | 切片概念、当前阶段、阻塞项 |
| **team-qa** | QA 阶段备注、阻塞问题 |
| **map-systems** | 任务记录：已枚举的系统、当前阶段 |

---

### Token cost summary

| 场景 | session_state: off | session_state: on |
|----------|--------------------|-------------------|
| 每次会话开始 | 约 500 个 token（仅 git/冲刺上下文） | 约 500–1,250 个 token（+ 检查点预览，最多约 750） |
| 每次压缩事件 | 0（压缩钩子输出永远不会到达 Claude） | 0（仅写入磁盘日志） |
| 每次会话结束 | 0 | 仅文件 I/O（无对话 token） |
| `/clear` 之后的恢复 | 读取骨架 + 2–3 份文档（约 1,000–3,000 个 token） | 读取 `active.md`（约 200–500 个 token） |

> **说明：** `off` 的恢复成本（读取骨架 + 文档）只在确实需要恢复时才付出。`on` 的
> 会话开始成本则在每次会话都要付出，无论是否需要恢复。

---

## features.token_budget_warn_at

> ### RESERVED - NOT IMPLEMENTED
>
> **没有任何技能或钩子读取该设置。设置它没有任何效果。** 下文描述的是预期设计，
> 而非当前行为。
>
> 你在设置时不会校验该值，也没有任何东西读取它。
> 任何阈值都不会触发警告。

**控制：** 触发会话警告的上下文使用率阈值
**取值：** 0.0 到 1.0 之间的浮点数
**默认：** `0.7`（使用率达 70% 时警告）
**设置方式：** `/settings`
**读取方：** 暂时没有（预期读取方：`session-start.sh`、`statusline.sh`）

**优先级链：** `project.yaml` 中的 `features.token_budget_warn_at` → 硬编码默认值 `0.7`

> 当会话上下文使用率超过该阈值时给出警告。帮助注重成本的用户在会话失控前执行
> `/clear`。设为 `1.0` 可禁用。

---

### Behavior

| 阈值 | 触发内容 |
|-----------|-----------|
| 低于 `warn_at` | 无警告 |
| 达到或高于 `warn_at` | `statusline.sh` 以黄色显示上下文使用率；下一次会话开始钩子输出一行提示：*“Last session reached [X]% context — consider /clear if continuing work.”* |
| 达到 90%+ | 无论 `warn_at` 取何值，黄色都变为红色 |

---

## features.read_guard

**控制：** 是否拒绝整文件读取大型设计文档  
**取值：** `on` | `off`；`true` 与 `false` 同样有效  
**默认：** `on`  
**设置方式：** `/settings`  
**读取方：** `validate-read.sh`（PreToolUse Read），经由 `.claude/scripts/read-guard.sh check`

> **优先级链：** `project.local.yaml` 中的 `features.read_guard` →
> `project.yaml` → 默认 **`on`**。

对 `design/`、`docs/architecture/` 或 `production/session-state/` 下超过
`features.read_guard_kb` 的文件，若 Read 未指定 offset 与 limit，则会被拒绝。
拒绝信息会列出该文档的各级标题及行号，以便下一次调用带 offset 与 limit 读取
其中一个章节。范围读取始终放行，因此没有技能会被该防护卡住；图片与 PDF 从不检查。
它选择阻塞而非警告，因为警告仍会让整次读取发生，而读取本身就是成本。

---

## features.read_guard_kb

**控制：** 超过多大即由 `features.read_guard` 拒绝整文件读取  
**取值：** 整数 KB（1 KB = 1,024 字节）  
**默认：** `40`  
**设置方式：** `/settings`  
**读取方：** `validate-read.sh`，经由 `.claude/scripts/read-guard.sh check`

> **优先级链：** `project.local.yaml` 中的 `features.read_guard_kb` →
> `project.yaml` → 默认 **`40`**。不是整数的取值会被忽略，`read-guard.sh check`
> 会在其 `threshold` 行中指明该值。

按文件大小而非行数：token 成本随字节数增长，而一个表格行就可能有 2 KB。
40 KB 约合 10,000 个 token，高于所有随附模板（最大为 33 KB）。

---

## updates.check

**控制：** 会话开始时是否告知你有更新的 Claude Code Game
Studios 版本发布  
**取值：** `true` | `false`  
**默认：** `true`  
**设置方式：** `/settings`（`/settings --local updates.check=false` 仅为你自己关闭）  
**读取方：** `session-start.sh`，经由 `update-check.sh`

> 当有更新版本发布时，会话开始会显示一行：*“Update: Claude
> Code Game Studios 1.3.0 is out (this project has 1.2.0). What changed and how
> to upgrade: <release page> — to stop this notice: /settings --local
> updates.check=false”*。不会下载或更改任何内容；是否升级仍由你决定
> （`UPGRADING.md`）。

> **优先级链：** `project.local.yaml` 中的 `updates.check` → `project.yaml` →
> 默认 **`true`**。除 `true` 或 `false` 之外的取值会被跳过，并在会话开始的
> schema 错误中指明。只要设置了 `CI` 环境变量，该检查也会关闭：那里没有人会
> 读取会话开始输出。

---

### How it checks

- 每天最多一次，后台任务向 GitHub 请求最新发布
  （`api.github.com/repos/Donchitos/Claude-Code-Game-Studios/releases/latest`），
  并把结果存入 `~/.cache/claude-code-game-studios/latest-release`
  （当设置了 `$XDG_CACHE_HOME` 时位于其下）。该文件按用户区分且位于所有项目之外，
  因此 `git status` 保持干净，一次检查即可覆盖本机上的每个项目。
- 会话开始只读取该文件。它不发起网络调用，也从不等待；新结果从下一次会话起显示。
- 离线，或既无 `curl` 也无 `wget` 时，它保持静默。缓存会保留上一次的结果，外加一行
  `error=` 说明上次检查失败的原因。
- 绝不提供预发布版本。
- 比较的版本是框架自身钩子文件所携带的版本，而不是 `framework.version`：保留你
  `project.yaml` 的升级会让该数字停留在旧值，提示行就会宣告你已拥有的那个版本。
- 取值为 `false` 时，不读取任何内容，也不发起任何请求。

---

## schema_version

**控制：** 该文件遵循 project.yaml schema 的哪个版本
**取值：** 整数
**默认：** `1`（对应 CCGS 的 v1.1）
**设置方式：** `/start`、`/adopt`
**读取方：** 所有解析 project.yaml 的技能与钩子（用于迁移安全）

> 让未来的 CCGS 版本能够检测并迁移旧的 project.yaml 文件。迁移逻辑会把文件中的
> `schema_version` 与当前 CCGS 期望的版本比较。若更新，则警告。若更旧，则执行迁移。

---

### Migration behavior

| project.yaml schema_version | 当前 CCGS 期望 | 行为 |
|----------------------------|---------------------|----------|
| 与期望一致 | — | 正常运作 |
| 低于期望 | — | `/adopt` 警告并提供迁移；技能运行时带弃用警告 |
| 高于期望 | — | 所有技能警告："This project.yaml was created by a newer CCGS version. Some settings may be ignored." |
| 缺失 | — | 视为旧式（v1.1 之前）；在下一次 `/start` 或 `/adopt` 时提示迁移 |

---

## framework

**控制：** 记录哪个 CCGS 版本创建或最后修改了本项目
**取值：** `framework.version`（semver 字符串）+ `framework.last_upgraded`（ISO 日期）
**默认：** 每次发布时盖入模板的 `project.yaml`
**设置方式：** 模板；`/start`（经由 `set-stage.sh`）、`/setup-engine` 与 `/gate-check` 会把该块写入它们创建的 `project.yaml`，而 `migrate-v1-config.sh`（由 `/adopt` 运行）会把 `framework.version` 写入它构建的那份文件
**读取方：** 没有任何技能据此分支——它是文件元数据，而非行为设置。它出现在 `/start`、`/gate-check`、`/settings` 与 `/setup-engine` 中，作为它们**写入或展示**的 `project.yaml` 块的一部分，也出现在 `yaml-helper.sh` 中。
  *（已核实上述四个技能会提及它；但每个技能是读取它还是仅仅输出它，未做区分，因此此处说的是「出现在」，而非「被读取」。）*

---

### Fields

```yaml
framework:
  version: "1.2.0"
  last_upgraded: "2026-10-18"
```

| 字段 | 用途 |
|-------|---------|
| `version` | 创建该项目的 CCGS 版本（或最后更新到的版本——见 `UPGRADING.md`）。 |
| `last_upgraded` | 最近一次模板更新的 ISO 日期。 |

---

### Affected skills

无。没有任何技能或钩子读取 `framework.version` 或 `last_upgraded`——`/adopt`
不查阅它们，也没有钩子检查它们的时效。它们记录项目来自哪个模板版本；
`UPGRADING.md` 是升级路径。

---

## Migration from v1.0 → v1.1

当 v1.0 的 CCGS 项目升级到 v1.1 时，迁移工具（通过 `/adopt` 运行）会把旧式文件
转换为 `project.yaml`。本节说明预期的行为。

### Detection

当满足以下条件时，项目被检测为需要迁移：
- 仓库根目录**不**存在 `project.yaml`，且
- 存在一个或多个旧式文件：
  - `production/stage.txt`
  - `production/review-mode.txt`
  - `.claude/docs/technical-preferences.md`

### Preservation

| 旧式来源 | 迁移至 |
|---------------|-------------|
| `production/stage.txt`（单行） | `project.stage` |
| `production/review-mode.txt`（单行） | `modes.review_mode` |
| `.claude/docs/technical-preferences.md` → "Engine & Language" 章节 | `engine.name`、`engine.version`、`engine.language`、`engine.rendering`、`engine.physics` |
| `technical-preferences.md` → "Input & Platform" 章节 | `platform.targets`、`platform.primary_input`、`platform.gamepad_support`、`platform.touch_support` |
| `technical-preferences.md` → "Naming Conventions" 章节 | `naming.classes`、`naming.variables`、`naming.constants`、`naming.signals`、`naming.files`、`naming.scenes` |
| `technical-preferences.md` → "Performance Budgets" 章节 | `performance.target_framerate`、`performance.frame_budget_ms`、`performance.draw_call_limit`、`performance.memory_ceiling_mb` |
| `technical-preferences.md` → "Testing" 章节 | `testing.framework`、`qa.coverage_minimum`（仅接受裸数字——散文内容会被报告以手工录入） |
| `technical-preferences.md` → "Engine Specialists" 章节 | `specialists.code`、`specialists.shader`、`specialists.ui`、`specialists.additional` |

**取值重命名——`review_mode: none` → `solo`。** v1.0 用 `none` 表示「无总监评审」
档；v1.1 把该档重命名为 `solo`（枚举为 `full | lean | solo`）。迁移会**强制**
把旧式 `none` 转换为 `solo`，并在迁移报告的 Warnings 中报告该重命名。这是唯一
有文档记录的取值重命名，因此它被映射并标记，而非原样保留：原样写入 `none` 会产生
一个枚举非法的 `project.yaml`，`resolve_config` 会拒绝它并回退到 `modes.rigor`
的取值——在 `standard` 下即 `lean`，评审*开启*——从而反转了用户的本意。
`--finalize` 保留性检查会应用同样的映射，因此不会误判为拒绝。每一个*其他*非 v1.1
的 stage/review 取值都是分叉，而非重命名：原样保留并标记为需人工处理，绝不强制
转换。

旧式文件中不存在的设置（如 `qa.level`、`docs.density`、`team.size` 等 v1.1 新增
设置）会从 v1.1 schema 获得硬编码默认值。

### Cleanup (optional, non-destructive)

迁移在 v1.1 中是**非破坏性的**：旧式文件**不会**被自动删除。迁移会生成
`project.yaml` 并保留旧式文件。钩子与技能优先读取 `project.yaml`；若某个特定键
缺失，则回退到旧式文件。

只有当用户运行 `.claude/scripts/migrate-v1-config.sh --finalize`（由 `/adopt`
驱动，后者在 Phase 2g 自动检测 v1.0 项目）时，旧式文件才会被删除。清理步骤会在
删除前验证每个旧式文件的内容都已保留在 `project.yaml` 中。

### Failure modes

| 问题 | 行为 |
|---------|----------|
| 旧式文件格式错误（无法解析） | 迁移会按文件发出警告，保持该文件不变，继续处理其他文件。`project.yaml` 得到可解析的值 + 其余项的默认值。 |
| 解析出的取值与 v1.1 枚举不符（例如分叉中的 `stage: Alpha`） | 迁移会在 `project.yaml` 中写入原始取值并附一条 `_migration_warning` 注释。由用户手工处理。 |
| `project.yaml` 与旧式文件同时存在（脑裂） | 迁移工具拒绝运行。错误："Both project.yaml and legacy files exist — resolve which is authoritative before migrating." |
| 分叉的 `technical-preferences.md` 中有自定义章节 | 自定义内容会被记录到 `production/migration-report.md`，标注为 "not migrated — please integrate manually." |

### Migration report

每次迁移运行都会写入 `production/migration-report.md`：

- 检测到的来源文件
- 已保留的取值（逐文件 → 逐设置）
- 应用的默认值（针对 v1.1 新增设置）
- 遇到的警告（格式错误、枚举不符等）
- 需人工审阅的条目

用户在运行 `--finalize` 之前阅读该报告。

---

## Complete example `project.yaml`

一份包含所有设置的完整 project.yaml，展示了单人 Godot 项目的合理默认值。
在撰写或迁移时，可将此作为参考形态。

```yaml
schema_version: 1

framework:
  version: "1.2.0"
  last_upgraded: "2026-10-18"

project:
  name: "Forge Knights"
  genre: "ARPG"
  version: "0.1.0"
  stage: Concept             # Concept | Systems Design | Technical Setup | Pre-Production | Production | Polish | Release
  kind: game                 # game | tool | engine | mod | library

modes:
  review_mode: lean          # full | lean | solo
  workflow: standard         # minimal | standard | full
  automation: collaborative  # collaborative | guided | autonomous
  automation_always_ask:     # decision categories that always prompt regardless of mode
    - scope_changes
    - file_deletions
    - schema_changes
  story_granularity: balanced  # coarse | balanced | fine

# TOP-LEVEL, not nested under `modes:` — resolve_config reads
# `workflow_overrides.system_overrides.*` from the document root
# (yaml-helper.sh), and every skill greps the same top-level path.
# Nesting it under `modes:` parses as valid YAML and is silently never read.
workflow_overrides:
  edge_cases: false          # force GDD Edge Cases section required
  tuning_knobs: false        # force GDD Tuning Knobs section required
  art_bible_strict: false    # force all 9 art bible sections regardless of asset stories
  system_overrides: {}       # { combat: full, inventory: minimal }

docs:
  density: balanced          # terse | balanced | thorough

testing:
  framework: gdunit4         # engine-specific — auto-populated by /setup-engine
  strict:
    logic: true              # unit test failures BLOCK story closure
    integration: true        # integration test failures BLOCK
    visual: true             # missing screenshot BLOCKS
    ui: true                 # missing screenshot BLOCKS
    config: false            # advisory only

qa:
  level: standard            # minimal | standard | full
  coverage_minimum: null     # integer 0-100; only enforced at level: full

strict_gate_checks: true     # phase gate failures block stage transition

team:
  size: individual           # individual | small | studio

platform:
  multiplayer: false         # real-time multiplayer
  online: false              # any online features (leaderboards, cloud, telemetry)
  targets: [PC]              # [PC, Mobile, Web, Console]
  primary_input: "Keyboard/Mouse"
  gamepad_support: "Full"    # Full | Partial | None
  touch_support: "None"      # Full | Partial | None
  cert_tier: none            # none | itch | steam | console

engine:
  name: "Godot"              # Godot | Unity | Unreal — set by /setup-engine
  version: "4.7"
  language: "GDScript"       # GDScript | C# | C++ | Blueprint
  rendering: "Forward+"
  physics: "Jolt"

specialists:                 # auto-populated by /setup-engine
  code: "godot-gdscript-specialist"
  shader: "godot-shader-specialist"
  ui: "godot-specialist"
  additional: ["godot-gdextension-specialist"]

naming:
  classes: PascalCase        # PascalCase | snake_case | camelCase
  variables: snake_case
  constants: SCREAMING_SNAKE
  signals: past_tense        # past_tense | on_event_name (engine-interpreted)
  files: snake_case
  scenes: snake_case

accessibility:
  target: none               # none | standard | aaa

cadence:
  sprint_length: "2w"        # 1w | 2w | 3w | 4w | none
  milestone_length: "8w"     # 4w | 6w | 8w | 12w

performance:
  target_framerate: 60
  frame_budget_ms: 16.67
  draw_call_limit: null
  memory_ceiling_mb: null
  enforce: warn              # warn | block | off

commands:                    # simple string OR OS-aware map per command
  build: "godot --headless --export-debug '<PRESET>'"   # your export_presets.cfg name
  test: "godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode"
  run: "godot --path . --windowed --resolution 1280x720"
  smoke: "godot --headless --quit-after 5"

features:
  session_state: on          # off | on
  token_budget_warn_at: 0.7  # 0.0-1.0; warn at this context % usage
  read_guard: on             # on | off; true and false also work. Refuse whole-file reads of large design docs
  read_guard_kb: 40          # the size, in KB, over which they are refused

updates:
  check: true                # false: no new-release line at session start
```

还有一个极简的稀疏 `project.local.yaml` 示例——一位希望在本地使用 autonomous 模式的开发者：

```yaml
modes:
  automation: autonomous
features:
  session_state: on
```

只包含被覆盖的键；其余一切都从 `project.yaml` 级联继承。
哪些设置可/不可在本地覆盖的完整白名单，见 "Local Override Pattern" 一节。
