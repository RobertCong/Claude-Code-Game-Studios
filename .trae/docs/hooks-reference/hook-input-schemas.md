# 钩子输入/输出 schema

本文记录每种事件类型下，每个 Claude Code 钩子通过 stdin 收到的 JSON 负载，以及钩子的输出如何传递给用户和 Claude。每个负载还带有公共字段 `session_id`、`transcript_path`、`cwd` 和
`hook_event_name`；下面的示例只展示事件特有的字段。完整参考资料是 Claude Code 钩子文档（https://code.claude.com/docs/en/hooks）。

## PreToolUse

在工具执行前触发。退出码 2 **阻止**该调用。退出码 0 让调用继续走正常的权限流程——它并不等于批准，用户仍可能被询问。若要只警告而不阻止，退出 0 并打印钩子 JSON——
见下文[输出](#output-warnings-someone-sees)。

### PreToolUse: Bash

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git commit -m 'feat: add player health system'",
    "description": "Commit changes with message",
    "timeout": 120000
  }
}
```

PowerShell 工具发送的形状相同，只是 `"tool_name": "PowerShell"`，因此匹配器写 `Bash|PowerShell` 即可同时覆盖两者。

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
    "old_string": "var health = 100",
    "new_string": "var health: int = 100"
  }
}
```

### PreToolUse: Read

```json
{
  "tool_name": "Read",
  "tool_input": {
    "file_path": "src/gameplay/health.gd"
  }
}
```

在真实的负载中，文件工具的 `file_path` 是绝对路径，使用平台自身的分隔符——Windows 上是反斜杠。应先剥掉项目根目录，再从剩余部分的开头进行匹配（`assets/data/`）。像
`/assets/data/` 这样在任意位置匹配的片段，也会命中同名的父文件夹以及项目之外的文件，例如用户自己的 `~/.claude/skills/`。
`validate-assets.sh` 演示了剥离的做法。

## PostToolUse

在工具完成后触发。**无法阻止**——工具已经执行了。退出码 2 会把 stderr 显示给 Claude，以便它修正刚写入的内容。退出 0 时 stderr 只进入调试日志，因此警告性质的提示必须以钩子 JSON 的形式写到 stdout。

### PostToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "content": "{\"goblin\": {\"health\": 50}}"
  },
  "tool_response": {
    "filePath": "assets/data/enemy_stats.json",
    "type": "create"
  }
}
```

### PostToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "old_string": "\"health\": 50",
    "new_string": "\"health\": 75"
  },
  "tool_response": { "filePath": "assets/data/enemy_stats.json" }
}
```

## SubagentStart

通过 `Agent` 工具创建子代理时触发（Claude Code 2.1.63 之前名为 `Task`；`Task` 在权限规则和
`tools:` frontmatter 中仍可作为别名使用，但钩子负载中的 `tool_name` 现已为 `Agent`）。代理的名称在 `agent_type` 中——没有 `agent_name` 字段。

```json
{
  "agent_id": "agent-abc123",
  "agent_type": "game-designer"
}
```

## SessionStart

在会话开始、恢复、被 `/clear` 清除或被压缩时触发。
stdin 携带 `source`：`startup`、`resume`、`clear`、`compact` 或 `fork`。纯 stdout 会被加入 Claude 的上下文——正是这个事件在压缩之后恢复上下文。

## PreCompact

在上下文压缩前触发。stdin 携带 `trigger`（`manual` 或 `auto`）。
**它的输出不会到达 Claude**：stdout 进入调试日志，`systemMessage` 被丢弃。退出码 2 会阻止压缩。

## Stop

**每次 Claude 完成一次回复时都会触发**，而不是在会话结束时只触发一次。
stdin 携带公共字段以及 `stop_hook_active` 和
`last_assistant_message`。退出码 2 会让 Claude 继续工作而非停止。

## <a id="output-warnings-someone-sees"></a>Output: warnings someone sees

只做警告、不得阻止的钩子应退出 0——并且**在退出 0 时，stderr 不会到达任何人**。改为把 JSON 对象打印到 stdout：

```json
{
  "systemMessage": "Shown to the user",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Given to Claude next to the tool result"
  }
}
```

- stdout 必须**只**包含该对象。
- `hookEventName` 在 `hookSpecificOutput` 内是必需的。
- **不要写 `permissionDecision`**，除非你确实有意为之：在 PreToolUse 上，`"allow"` 会跳过用户的权限提示。

CCGS 钩子使用 `.claude/hooks/yaml-helper.sh` 中的 `hook_warn`，它负责构建该对象并转义消息，无需 `jq`：

```bash
. .claude/hooks/yaml-helper.sh
hook_warn PostToolUse "Asset names must be lowercase: $FILE_PATH"
exit 0
```

## Exit Code Reference（退出码参考）

| Exit Code | Meaning |
|-----------|---------|
| 0 | 成功。stdout 上的 JSON 对象会被读取为钩子输出；其他 stdout 进入调试日志，但 UserPromptSubmit、UserPromptExpansion、SessionStart 和 PostModelSwitch 除外，这些事件上它会加入 Claude 的上下文。stderr 只进入调试日志。 |
| 2 | 在 PreToolUse（Claude 将 stderr 视为原因）、UserPromptSubmit（提示词被抹除）、UserPromptExpansion、Stop、SubagentStop（子代理继续工作）和 PreCompact 上阻止。在 PostToolUse 上向 Claude 显示 stderr——工具已执行。在 SessionStart、SubagentStart、PostCompact 和 PostModelSwitch 上只向用户显示 stderr。在 Notification 上被忽略。按事件分列的完整表格见 Claude Code 钩子文档。 |
| Other | 非阻塞错误；操作照常继续。 |

**输出上限为 10,000 个字符（实测；Claude Code 钩子文档未说明这一点）。**
纯 stdout，以及 `additionalContext`、`systemMessage` 和
`initialUserMessage` 各自单独计量。超过上限后，Claude Code 会把文本存到文件，并传递一个路径
外加 2,000 字符的预览，而且没有任何机制提示 Claude 去读取该文件。把 Claude 必须看到的内容保持在上限之内——`session-start.sh` 正因如此对其检查点预览做了截断。

## Notes（备注）

- 钩子通过 **stdin**（管道）接收 JSON。用 `INPUT=$(cat)` 捕获。
- 如可用则用 `jq` 解析，为跨平台兼容可回退到 `grep`。
- 在 Windows 上，`grep -P`（Perl 正则）通常不可用。改用 `grep -E`（POSIX 扩展）。
- 在 Windows 上路径分隔符可能是 `\`。比较路径时用 `sed 's|\\|/|g'` 归一化。
