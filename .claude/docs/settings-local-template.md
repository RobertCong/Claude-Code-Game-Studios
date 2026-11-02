# settings.local.json 模板

创建 `.claude/settings.local.json`，用于存放不应提交到版本控制的个人覆盖设置。
随附的 `.gitignore` 已经忽略它。

## settings.local.json 示例

```json
{
  "permissions": {
    "allow": [
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(npm run *)"
    ],
    "deny": [
      "Bash(git push *)"
    ]
  }
}
```

把 `*` 放在子命令之后。`Bash(git commit *)` 只允许提交；`Bash(git *)` 会允许所有
git 命令，包括 `git push`。只读命令如 `git status`、`git log` 和 `ls` 无需规则：
Claude Code 会直接运行它们而不询问。你的规则会添加到 `.claude/settings.json` 中
随附的规则之上，因此其中的 deny 规则仍然生效。

## 权限模式

Claude Code 有多种权限模式。随附的 `.claude/settings.json` 以 `default` 模式启动
终端会话；若要以其他模式启动，在此处设置 `permissions.defaultMode`。
`setup-requirements.md` 中的 "One setting CCGS does ship" 列出了它能改变和不能
改变的内容。你也可以在会话过程中切换。游戏开发建议：

### 开发期间 — 手动（`default`）
Claude 在运行大多数命令和编辑文件之前都会询问。这对生产代码最安全。

### 原型期间 — `acceptEdits`
文件编辑以及 `mkdir`、`mv` 等常见文件系统命令会被直接接受而不询问；其他命令仍会
询问。它作用于整个工作目录，而不只是 `prototypes/`，因此回到生产代码时要切回来。

### 代码评审期间 — `plan`
Claude 会读取文件并运行只读命令来探索，但不会编辑你的源文件。

### `auto`
无需常规提示即可运行：后台分类器会在每个动作执行前检查。本地 `defaultMode`
无法以该模式启动终端会话；请在会话过程中切换（`setup-requirements.md` 列出了
可用途径）。

## 本地自定义钩子

你可以在 `settings.local.json` 中添加个人钩子，它会扩展（而非覆盖）项目钩子。
例如，每次 Claude 完成一次回复时记录一行个人日志：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo \"Response finished at $(date)\" >> \"$CLAUDE_PROJECT_DIR/production/session-logs/my-stops.log\"'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

钩子的输出只有对少数事件才会传回 Claude，例如 `SessionStart` 和
`UserPromptSubmit`。对于其他事件（包括 `Stop`），Claude Code 会把 stdout 写入
调试日志，因此只打印不写文件的钩子什么也显示不出来：要像上面那样写入文件，或写入
其他工具。`Stop` 在每次回复结束时触发，而不是每个会话一次。
