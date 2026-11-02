# 为 Claude Code Game Studios 做贡献

CCGS 是一个使用 Claude Code 进行独立游戏开发的协作框架。欢迎贡献——bug 修复、填补真实空白的新技能、代理改进和钩子修复。不符合框架方向的 PR 会被关闭，且不会给出冗长解释。

## 什么样的 PR 是好 PR

- **Bug 修复**——某处坏了，这是修复
- **新技能**，填补尚未覆盖的工作流空白
- **改进**现有代理、技能或钩子
- **文档修正**——错误信息、失效引用、过时步骤

以 PR 形式提交的功能请求会被关闭。请改为开 issue。

**这个仓库不是什么：**
CCGS 是帮助你制作游戏的系统，不是存放你用它制作的游戏的地方。CCGS 为你的项目生成的 GDD、ADR、PRD、游戏概念、关卡设计、叙事文档或任何其他产出物都不会在这里合并——请把它们留在你自己的仓库里。

## 不可妥协的技术规则

以下是你若遗漏就会被拒绝 PR 的事项。

**技能文件**
- 技能位于 `.claude/skills/<name>/SKILL.md`——必须使用子目录格式。扁平的 `.md` 文件会被 Claude Code 静默忽略。
- SKILL.md 必须包含 YAML frontmatter：`name`、`description`、`argument-hint`、`allowed-tools` 和 `model`
- 模型层级：只读状态检查用 `haiku`，多文档综合和阶段闸门用 `opus`，其他一律用 `sonnet`

**钩子**
- 使用 `grep -E`——绝不要用 `grep -P`（Perl 正则会在 Windows Git Bash 上出错）
- 为没有安装 `jq` 或 `python` 的系统提供回退
- 钩子在每次会话启动时运行——它们必须快速退出，并在不适用时优雅退出（`exit 0`）

**代理**
- 新代理必须包含 **Collaboration Protocol** 章节，说明代理如何提问以及如何把决策交给用户
- 未经用户明确授权，代理不得修改其记录领域之外的文件

**参考文档**
- 如果你的 PR 新增或修改了技能、代理或钩子，请更新对应的参考文档（agent-roster、skills-reference、hooks-reference 或 rules-reference）。只新增内容而不更新索引的 PR 会被退回。

## 协作原则

CCGS 不是自主系统。每个工作流都遵循：
**提问 → 选项 → 决策 → 草稿 → 批准 → 写入**

技能和代理必须先询问再行动。没有用户明确确认，任何东西都不得写入文件。如果你的贡献中有代理单方面做决策或写文件，它不会被合并。

## 测试你的改动

在 Claude Code 会话中运行并确认端到端可用。对于技能，调用该技能并验证输出符合技能声称的行为。对于钩子，触发相关事件并确认钩子正确触发且干净退出。

在 PR 描述中附一段简短说明，描述你测试了什么以及输出是什么样的。

## 提交格式

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```
feat: add /retrospective skill for end-of-sprint reviews
fix: correct grep -P usage in session-start hook
docs: update skills-reference with new /qa-plan entry
```

类型：`feat`、`fix`、`docs`、`chore`、`refactor`、`test`

## PR 流程

- 你的 PR 会通过 CODEOWNERS 自动分配给维护者
- 评审按实际情况进行——这是一个单人维护的项目
- 如果你的 PR 开放数周没有反馈，发一条提醒评论是可以的
- 被合并的贡献者会在发布说明中署名

## 平台兼容性

CCGS 必须能在 Windows（Git Bash）、macOS 和 Linux 上工作。如果你的钩子或脚本使用了任何平台特定内容，它会被拒绝。拿不准时，在 Windows 上测试。
