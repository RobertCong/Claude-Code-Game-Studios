# /adopt — Phase 2: 格式审计

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 2: 格式审计

**本文件内容：**

- 2a：GDD 格式审计
- 2b：ADR 格式审计
- 2c：systems-index.md 格式审计
- 2d：用户故事格式审计
- 2e：基础设施审计
- 2f：项目配置审计
- 2g：v1.0 迁移检查

对于范围内的每种产出物类型（取决于参数模式**以及解析出的
workflow 层级**），不仅要检查文件是否存在，还要检查它是否包含
模板所要求的内部结构。在 `minimal` 下，将审计范围限定为
`design/game-brief.md` — 不要审计 GDD、ADR 或 UX 规格（它们不被预期）。
步骤 2e（仅 Engine reference 行）、2f（项目配置）和 2g（v1.0
迁移检查）在每个层级都会运行。

### 2a: GDD 格式审计

**以确定性的方式收集章节存在情况 — 不要通过读取 GDD 来统计
标题。** 对 Phase 1 中发现的每个 GDD，将其路径显式传给
结构检查脚本：

```
Bash: bash .claude/scripts/gdd-structure-check.sh [path-to-gdd]
```

**一次传入一个路径；不要直接裸调用它。** 无参数形式只会扫描
`design/gdd/`，而棕地项目的 GDD 并不保证都放在那里 — 传入
Phase 1 找到的任何路径。脚本会为每个文件打印 `PRESENT:` 列表，
并在适用时打印 `ABSENT:` 列表。它只报告**存在情况**，
不做 REQUIRED/ADVISORY 判断（那是下方的层级逻辑），而且它
已经接受 `## Detailed Design` 作为满足 `Detailed Rules`
要求，因此不要把该别名标记为缺失。

如果脚本对某个路径打印 `Not found:` 或报错，那是**发现失败，
而非格式缺口** — 报告为“无法审计 [path]”，不要
将其计为缺失章节的发现项。

**然后对每个文件的 PRESENT/ABSENT 列表应用上文解析出的 workflow 层级**。
哪些章节是**必需**的（缺失 = 缺口）与**建议**的（缺失 =
仅供参考）：
- **`full`** — 全部 8 个章节均为必需。
- **`standard`** — 5 个必需章节（Overview、Detailed Rules、Edge Cases、
  Dependencies、Acceptance Criteria）+ 对任何定义数值规则的系统都需要 Formulas
  （速率、曲线、阈值、成本 — 系统的 `Category` 是
  提示，不是判定依据）；Player Fantasy 和 Tuning Knobs 为建议项。
- **`minimal`** — 不预期存在 GDD；改为审计 `design/game-brief.md`，
  对照 `.claude/docs/templates/game-brief.md`：六个必填字段
  均存在且不是占位符；三个一句话项为建议项。任何确实
  存在的 GDD 按 `standard` 标准做建议性检查。

脚本的 8 个规范标签是：Overview、Player Fantasy、Detailed Rules、
Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria。

一个被报告为 PRESENT 的章节仍可能是空标题。对每个 GDD，还要
用定向 grep（而非完整读取）记录：
- 仅有占位符的章节 — 脚本的 `PLACEHOLDER:` 行列出了
  仅包含 `[To be designed]` 或空内容的现有章节；只有一行的
  存根正文效果相同，因此抽查较短的章节。
- `**Status**:` 头部字段 — `Grep pattern="^>?[[:space:]]*\*\*Status\*\*:"`。
  有效值：`Draft`、`In Design`、`Designed`、`In Review`、`Approved`、
  `Implemented`、`Needs Revision`。

> **`>?` 是关键，`Draft`/`Implemented` 同样关键。** 两个生成器
> 都把该字段写在块引用内 — `.claude/docs/templates/game-design-document.md`
> 和 `/design-system` 产出 `> **Status**: …` — 因此锚点
> `^\*\*Status\*\*:` 什么都匹配不到，并会把*每一份*符合模板的 GDD
> 报告为缺少 Status。模板自身的值列表提供了 `Draft` 和
> `Implemented`，因此二者都必须算作有效。

### 2b: ADR 格式审计

对找到的每个 ADR 文件，检查以下关键章节：

| 章节 | 缺失时的影响 |
|---|---|
| `## Status` | **BLOCKING** — `/story-readiness` 的 ADR 状态检查会静默放行一切 |
| `## ADR Dependencies` | HIGH — `/architecture-review` 中的依赖排序会失效 |
| `## Engine Compatibility` | HIGH — 截止日期后 API 的风险未知 |
| `## GDD Requirements Addressed` | MEDIUM — 可追溯性矩阵失去覆盖 |
| `## Performance Implications` | LOW — 对流水线不关键 |

对每个 ADR 记录：存在哪些章节、缺失哪些章节、若 Status 章节存在则记录
当前的 Status 值。

### 2c: systems-index.md 格式审计

如果 `design/gdd/systems-index.md` 存在：

1. **带括号的状态值** — Grep 查找任何包含括号的
   Status 单元格：`"Needs Revision ("`、`"In Progress ("` 等。
   这些会破坏 `/gate-check`、`/create-stories`
   和 `/architecture-review` 中的精确字符串匹配。**BLOCKING。**

2. **有效状态值** — 检查 Status 列的值仅来自：
   `Not Started`、`In Progress`、`In Review`、`Designed`、`Approved`、`Needs Revision`
   标记任何无法识别的值。

3. **列结构** — 检查表格至少包含：System name、
   Layer、Priority、Status 列。缺少列会降低技能功能。

### 2d: 用户故事格式审计

对找到的每个用户故事文件：

- **`Manifest Version:` 字段** — 是否存在于故事头部？（LOW — 缺失时自动通过）
- **TR-ID 引用** — 故事是否包含 `TR-[a-z]+-[0-9]+` 模式？（MEDIUM — 无陈旧性追踪）
- **ADR 引用** — 故事是否引用至少一个 ADR？（检查 `ADR-` 模式）
- **Status 字段** — 是否存在且可读？
- **验收标准** — 故事是否有复选框列表（`- [ ]`）？

### 2e: 基础设施审计

| 产出物 | 路径 | 缺失时的影响 |
|---|---|---|
| TR 注册表 | `docs/architecture/tr-registry.yaml` | HIGH — 没有稳定的需求 ID |
| 控制清单 | `docs/architecture/control-manifest.md` | HIGH — 用户故事没有层级规则 |
| 清单版本标记 | 在清单头部：`Manifest Version:` | MEDIUM — 陈旧性检查失效 |
| 冲刺状态 | `production/sprint-status.yaml` | MEDIUM — `/sprint-status` 回退到 markdown |
| 阶段文件 | `project.yaml` 中的 `project.stage`（回退到 `production/stage.txt`） | MEDIUM — 阶段自动检测不可靠 |
| 引擎参考 | `docs/engine-reference/[engine]/VERSION.md` | HIGH — ADR 引擎检查失效 |
| 架构可追溯性 | `docs/architecture/requirements-traceability.md` | MEDIUM — 没有持久化矩阵 |

在 `workflow: minimal` 下仅 Engine reference 行适用。TR 注册表、
控制清单及其版本标记、冲刺状态、阶段文件和
可追溯性矩阵不在 minimal 路径上，因此它们的缺失不算缺口。

### 2f: 项目配置审计

读取 `project.yaml`（主配置存储）和 `.claude/docs/technical-preferences.md`（旧版镜像）。只要任一来源有真实值，该设置就算已配置（在 technical-preferences.md 中，`[TO BE CONFIGURED]` 表示未配置）：
- `engine.name`/`version`/`language`/`rendering`/`physics`（或 Engine/Language/Rendering/Physics 字段）→ 若两者均未配置则为 HIGH（ADR 技能会失败）
- `naming.*`（或 Naming conventions）→ MEDIUM
- `performance.*`（或 Performance budgets）→ MEDIUM
- Forbidden Patterns、Allowed Libraries（仅 technical-preferences.md — 未迁移到 project.yaml）→ LOW（按设计初始为空）

### 2g: v1.0 迁移检查

当仓库根目录不存在 `project.yaml`，且至少有一个旧版文件存在时，
项目就是**需要迁移的 v1.0 项目**：`production/stage.txt`、
`production/review-mode.txt`，或包含
真实值的 `.claude/docs/technical-preferences.md`。

“真实值”指转换器实际会迁移的某个键 — Engine、
Language、Rendering、Physics、命名、平台和性能字段、
Framework，或 specialists。并非仅仅是“某个条目被填写了”：
随附模板自带一条散文式默认值（`- **Required Tests**: …`），它
永远不会被迁移，若将其计入，每个全新克隆都会被当作 v1.0
项目。

不要手工迁移。运行转换器，它是确定性的，并由
框架自身的测试套件覆盖：

```bash
bash .claude/scripts/migrate-v1-config.sh --dry-run
```

试运行不写入任何内容；记录它列出的内容用于报告。审计期间
不要运行转换器 — Phase 2 为静默读取。迁移在 Phase 3 中被
归类为 BLOCKING，位于计划之首，且 **Phase 7 将其作为首个
行动提供**：报告试运行列出的内容，然后询问“我可以运行
转换器吗？它会写入 `project.yaml` 和 `production/migration-report.md`。”如果
用户批准，则不带 `--dry-run` 运行。它
写入 `project.yaml` 以及 `production/migration-report.md`，且**不删除
任何东西** — 整个操作可随时用 `git checkout` 回滚。

然后告诉用户在运行以下命令前阅读 `production/migration-report.md`：

```bash
bash .claude/scripts/migrate-v1-config.sh --finalize
```

`--finalize` 只有在证明旧版文件的值已存在于
`project.yaml` 中后才会删除它；若不匹配，它不删除任何内容并以退出码 4 结束。它从不删除
`technical-preferences.md`，因为其中仍保存着 Forbidden Patterns 和 Allowed
Libraries。

**如果脚本以退出码 3 拒绝**，不要绕过它。退出码 3 表示
两种情况之一，消息会说明是哪一种：

- **值不一致（DISAGREE）** — 两个事实来源，无法知道
  用户最后编辑的是哪一个。将其呈现出来，让用户决定。
- **已存在 `production/migration-report.md`** — 这里已运行过
  一次迁移，因此这些是迁移后的遗留物，下一步是 `--finalize`，
  而不是再运行一次 `migrate`。

两个文件仅仅*存在*并不构成退出码 3，绝不能报告为
冲突：`/start` 会在每个新的 v1.1 项目上写入 `production/stage.txt` 作为
镜像，因此一致才是正常状态。脚本会说
`the legacy files mirror it (values agree)` 并以 0 退出。

在 Phase 3 中归类为 **BLOCKING**：在迁移运行之前，每个技能都通过
旧版回退链读取配置，v1.1 设置不可用。

---
