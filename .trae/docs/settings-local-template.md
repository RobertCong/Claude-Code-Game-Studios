# 本地覆盖模板（Trae）

Trae 没有项目级的 `settings.local.json`。个人覆盖走下面三条路，且都不应提交到仓库。

## 1. 个人指令：`CLAUDE.local.md`

Trae 兼容 `CLAUDE.local.md`，并会从项目根目录读取它。用于记录只属于你的偏好，例如：

```markdown
# 我的本地约定

- 回复先给结论，再给步骤。
- 不要自动提交；每次提交前先展示 diff。
```

`CLAUDE.local.md` 已被 `.gitignore` 忽略。

## 2. 个人权限：Trae 用户设置

Trae 的权限配置属于用户级，不随项目仓库分发：

- 图形界面：**设置 > 规则与记忆 / 权限**。
- 配置文件：`~/.trae-cn/permission/global.json`（macOS/Linux）。

项目的危险命令拦截不依赖这里，而是 `.trae/hooks/deny-rules.json` +
`.trae/hooks/validate-deny.sh`，因此克隆仓库即可获得同一套 deny 规则。个人只应
在此基础上加自己的白名单，不要删除项目规则。

## 3. 个人钩子：`~/.trae-cn/hooks.json`

Trae 会把全局 Hook 与项目 Hook 合并执行。个人 Hook 写到
`~/.trae-cn/hooks.json`，使用与 `.trae/hooks.json` 相同的 `version: 1` 结构：

```json
{
  "version": 1,
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.trae/my-session-log.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

可用的 Hook 事件：`SessionStart`、`UserPromptSubmit`、`PreToolUse`、
`PostToolUse`、`Stop`、`Notification`。`PreCompact` 视 Trae 版本而定。

## 自动化程度

Trae 没有 Claude Code 的 `default` / `acceptEdits` / `plan` / `auto` 权限模式。
对应关系是：

- **手动确认**：Trae 的默认审批模式；大多数命令和文件编辑前会询问。
- **减少询问**：在 Trae 设置里调整审批策略，或把 Hook 运行方式设为
  「本地自动运行」。
- **只读评审**：让 Agent 只读文件、不写入；本仓库的评审技能本身不会写源文件。
- **完全自动**：由 Trae 的 Agent 自动模式承担；项目的协作协议仍然要求
  在写文件前询问，除非用户明确切换到自动模式。
