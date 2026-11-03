# 迁移指南：v1.0 → v1.1 project.yaml

本指南介绍如何将**现有项目的配置文件**转换为
`project.yaml`。它与
[UPGRADING.md](../UPGRADING.md) 中的模板差异说明不同 —— 那个文件告诉你哪些*技能和 agent
文件*在各版本之间发生了变化，以及是否可以安全覆盖。本
指南涵盖的是*项目自身的数据*：你在
`production/stage.txt`、`production/review-mode.txt` 和
`.trae/docs/technical-preferences.md` 中配置的值。

如果你是在 v1.1 上搭建一个**全新**项目，则不需要这份指南 ——
`/start` 会直接写入 `project.yaml`，所有旧版文件都不适用。

---

## 你需要迁移吗？

如果仓库根目录下**不存在** `project.yaml`，且以下文件至少存在一个，
那么你有一个需要迁移的 v1.0 项目：

- `production/stage.txt`
- `production/review-mode.txt`
- 含有真实值的 `.trae/docs/technical-preferences.md`（仍是
  充满 `[TO BE CONFIGURED]` 占位符的副本是未经改动的模板
  默认值，不是可迁移数据，不计入）

运行 `/adopt`，它会自动检测这种情况（Phase 2g），并引导你
完成下面的步骤。你也可以直接运行转换器。

---

## 会保留哪些内容

| 来源 | 目标（`project.yaml`） |
|---|---|
| `production/stage.txt` | `project.stage` |
| `production/review-mode.txt` | `modes.review_mode` |
| `technical-preferences.md` → Engine & Language | `engine.name`, `engine.version`, `engine.language`, `engine.rendering`, `engine.physics` |
| `technical-preferences.md` → Input & Platform | `platform.targets`, `platform.primary_input`, `platform.gamepad_support`, `platform.touch_support` |
| `technical-preferences.md` → Naming Conventions | `naming.classes`, `naming.variables`, `naming.constants`, `naming.signals`, `naming.files`, `naming.scenes` |
| `technical-preferences.md` → Performance Budgets | `performance.target_framerate`, `performance.frame_budget_ms`, `performance.draw_call_limit`, `performance.memory_ceiling_mb` |
| `technical-preferences.md` → Testing | `testing.framework`, `qa.coverage_minimum` |
| `technical-preferences.md` → Engine Specialists | `specialists.code`, `specialists.shader`, `specialists.ui`, `specialists.additional` |

在 v1.0 中根本不存在的设置（`modes.rigor`、`qa.level`、
`docs.density`、`team.size`、`modes.story_granularity`，以及 v1.1
模式系统的其余部分）会采用 v1.1 的硬编码默认值 —— 它们没有什么
需要保留的。

**有一个值被重命名了：** v1.0 的 `review-mode.txt: none`（「不进行总监
评审」）在 v1.1 中变为 `modes.review_mode: solo`，这是同一档位的
新名称。转换器会映射它，并在迁移
报告的 Warnings 中明确指出，因此你会看到这次重命名，而不是让它悄悄发生。

**有意不迁移：** `technical-preferences.md` 的 Forbidden Patterns
和 Allowed Libraries 章节没有对应的 `project.yaml` 结构。
因此转换器绝不会删除这个文件 —— 参见下文「完成迁移」。

---

## 运行迁移

转换是一个经过测试的脚本，而不是由 AI 手工编辑 ——
v1.1 计划将迁移过程中的数据丢失评为最高严重度风险，而
文字迁移无法像脚本那样做单元测试。`/adopt` 会为你驱动
它，你也可以自己运行：

```bash
# 1. Preview — writes nothing, just reports what it would do
bash .trae/scripts/migrate-v1-config.sh --dry-run

# 2. Migrate — writes project.yaml + production/migration-report.md
#    Every legacy file is left in place, untouched.
bash .trae/scripts/migrate-v1-config.sh

# 3. Read the report before finalizing
cat production/migration-report.md

# 4. Finalize — deletes legacy files, ONLY after re-verifying each one's
#    value made it into project.yaml. Refuses (exit 4) and deletes nothing
#    on any mismatch.
bash .trae/scripts/migrate-v1-config.sh --finalize
```

第 4 步是可选的，并且有意分开。完全跳过它也没问题 ——
对于 `project.yaml` 没有的任何键，每个技能和钩子都会回退到旧版文件，
因此两者可以无限期共存。当你确信 `project.yaml` 正确，
并且希望用一个配置文件代替三个文件时，再运行它。

**`technical-preferences.md` 永远不会被删除**，即使使用 `--finalize` 也一样 ——
Forbidden Patterns 和 Allowed Libraries 仍然存放在那里，而且永远如此，
因为 v1.1 目前还没有对应的结构。

### 阅读 `production/migration-report.md`

报告分为五个部分：

- **Source files detected** —— 转换器找到了哪些旧版文件
- **Values preserved** —— 按来源文件、按设置列出写入了
  `project.yaml` 的内容
- **Defaults applied** —— 没有可迁移来源的新 v1.1 设置
- **Warnings** —— 转换器无法干净解析的任何内容（见下文）
- **Manual review** —— 它发现但拒绝猜测的内容（例如分叉的
  `technical-preferences.md` 中的自定义章节）

---

## 可能出现的问题（以及脚本的处理方式）

| 情况 | 行为 |
|---|---|
| 某个旧版文件格式错误 / 无法解析 | 按文件发出警告，保持原样，继续迁移其他所有*可以*解析的内容。`project.yaml` 会得到能读取到的值，其余使用默认值。 |
| 解析出的值不匹配 v1.1 枚举（例如某个分叉的 `stage: Alpha`） | 原样写入并附警告注释，标记为需手动解决 —— 转换器不会悄悄强制转换或丢弃它。 |
| `project.yaml` **和**旧版文件都已存在 | 拒绝运行（退出码 3）。存在两个事实来源且无法判断你最后编辑的是哪一个，脚本不会去猜 —— 请先自行解决（决定哪个是权威来源，删除或重命名另一个）。 |
| 分叉的 `technical-preferences.md` 中有自定义章节 | 记录到迁移报告中，标记为「not migrated — integrate manually」。不会悄悄丢失任何内容。 |

如果你遇到脑裂情况（两者都存在），这通常意味着你
要么在一个还留有旧版文件的项目上运行了 `/start`，
要么手工进行了部分迁移。选择含有真实值的那个，
移除或备份另一个，然后重新运行 `--dry-run`。

---

## 迁移之后

1. 将 `project.yaml` 与你旧的 `technical-preferences.md` 抽查对比 ——
   尤其是引擎、命名和性能值。
2. 运行 `/settings`，以技能读取的方式查看生效配置。
3. 无论你是否运行过 `--finalize`，框架中的其他一切工作方式完全相同 ——
   不必着急。

关于 v1.0 中不存在的新设置（首当其冲的是 `modes.rigor`），
请参阅 [README 的 Configuration 章节](../README.md#configuration)
以及 `.trae/docs/effects-map.md` 中的完整规格。
