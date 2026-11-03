# 钩子输入/输出 schema（Trae）

本文记录 `.trae/hooks.json` 中每个事件通过 stdin 收到的 JSON 负载，以及钩子的输出
如何传递给用户和模型。完整参考资料是 Trae 钩子文档：
<https://docs.trae.cn/ide_hook-configuration-reference>。

所有负载都有公共字段 `session_id`、`cwd`、`hook_event_name`、`workspace_roots`；
下面的示例只展示事件特有的字段。

## PreToolUse

在工具执行前触发。退出码 2 **阻止**该调用；退出 0 让调用继续走正常的权限流程。
只警告而不阻止时，退出 0 并打印钩子 JSON——见下文“输出”。

### PreToolUse: RunCommand

```json
{
  "tool_name": "RunCommand",
  "tool_input": {
    "command": "git commit -m 'feat: add player health system'"
  }
}
```

Trae 的终端工具名是 `RunCommand`（不是 `Bash`/`PowerShell`）。`matcher` 必须写
`RunCommand` 才能覆盖所有终端命令。

### PreToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "content": "extends Node\n..."
  }
}
```

### PreToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "old_string": "var hp = 10",
    "new_string": "var hp = config.max_hp",
    "replace_all": false
  }
}
```

### PreToolUse: Read

```json
{
  "tool_name": "Read",
  "tool_input": {
    "file_path": "design/gdd/combat.md",
    "offset": 1,
    "limit": 200
  }
}
```

Trae 的 PreToolUse 负载**没有** `transcript_path`、`agent_type`、`agent_id`。
子代理发起的调用与主代理形状相同，`validate-write.sh` 的子代理例外因此退化为普通规则。

## PostToolUse

在工具完成后触发。**无法阻止**——工具已经执行了。退出码 2 会把 stderr 传给模型，
以便它修正刚写入的内容。退出 0 时 stderr 只进入调试日志，因此警告性质的提示必须以
钩子 JSON 的形式写到 stdout。

```json
{
  "tool_name": "Write",
  "tool_input": { "file_path": "assets/data/weapons.json", "content": "..." },
  "tool_response": { "success": true }
}
```

## SessionStart

在创建会话后、第一个提示之前触发。`source` 目前只支持 `startup`。

```json
{ "source": "startup" }
```

纯文本 stdout 会作为附加上下文给模型；也可以用：

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "上下文文本"
  }
}
```

也可以通过 `TRAE_ENV_FILE` 写入环境变量，供本次会话后续的 Hook 和 RunCommand 使用。

## Stop

**每次模型完成一次回复时都会触发**，而不是在会话结束时只触发一次。

```json
{
  "stop_hook_active": false,
  "loop_count": 0,
  "last_assistant_message": "..."
}
```

退出码 2 会让模型继续工作而非停止；`loop_limit`（默认 5）限制阻断次数。

## Notification

`notification_type` 是 `permission_prompt` 或 `idle_prompt`；同时带 `message` 和
可选 `tool_use_id`。

```json
{
  "notification_type": "idle_prompt",
  "message": "Agent is waiting for your input",
  "tool_use_id": "toolu_xxx"
}
```

## 输出

### 通用流程控制

```json
{ "continue": true, "stopReason": "string" }
```

`continue: false` 会停止本次执行，优先级高于事件特定的 `decision`。

### PreToolUse

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "原因",
    "updatedInput": { "command": "改写后的命令" },
    "additionalContext": "给模型的附加上下文"
  }
}
```

`permissionDecision` 可选 `allow` / `deny` / `ask`；多个 Hook 同时返回时优先级为
`deny` → `ask` → `allow`。`updatedInput` 会整体替换原始参数。

### PostToolUse / Stop

```json
{
  "decision": "block",
  "reason": "阻断原因",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "给模型的附加上下文"
  }
}
```

`decision` 只支持 `block`。在 Stop 上，`reason` 会作为新的用户请求让模型继续。

### 没有 `systemMessage`

Trae 的 Hook 输出规范没有 `systemMessage`。需要让用户看到的信息请写入
`permissionDecisionReason` 或 `reason`；需要让模型看到的信息写入
`additionalContext`。本仓库的 `hook_warn` 只输出 `additionalContext`。

### 退出码

| 退出码 | 行为 |
| ---- | ---- |
| `0` | 成功。stdout 按事件解析为 JSON 或纯文本；stderr 进入调试日志。 |
| `2` | 阻断性错误。在 PreToolUse 等价于 `permissionDecision: deny`；在 PostToolUse/Stop 把 stderr 传给模型；在 SessionStart 不影响流程。 |
| 其他 | 非阻断性错误，输出被忽略。 |

## 不支持的事件

Trae 没有 `SubagentStart` / `SubagentStop` / `PostCompact`。子代理审计钩子
（`log-agent.sh`、`log-agent-stop.sh`、`validate-agent-artifact.sh`）因此未注册。
