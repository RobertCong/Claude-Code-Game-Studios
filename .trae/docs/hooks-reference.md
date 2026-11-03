# 活动钩子（Active Hooks）

钩子在 `.claude/settings.json` 中配置，并自动触发：

| 钩子 | 事件 | 触发条件 | 动作 |
| ---- | ----- | ------- | ------ |
| `validate-commit.sh` | PreToolUse (Bash, PowerShell) | `git commit` 命令 | 校验设计文档章节、JSON 数据文件、硬编码值、TODO 格式 |
| `validate-push.sh` | PreToolUse (Bash, PowerShell) | `git push`、`git tag`、`git merge` 以及发布类命令 | 对推送到受保护分支（`main`、`master` 和 `release/*`）发出警告，并对会先询问的步骤发出警告：`git tag`（非列表）、`git merge`（非 `--abort`）、`gh release`、`butler push` 以及带 `+run_app_build` 的 `steamcmd`。哪些命令计入由 `bash .claude/scripts/write-guard.sh git` 决定 |
| `validate-registry.sh` | PreToolUse (Write/Edit) | 对 `design/registry/entities.yaml` 和 `docs/architecture/tr-registry.yaml` 的写入与编辑 | 当变更会删除或重新编号条目，或设置的状态超出文件头部列出的取值时，发出警告，且绝不阻塞。它在写入之前运行，此时旧文件仍可对比；检查本身是 `bash .claude/scripts/registry.sh compare`。写入注册表的技能还会在写入后运行 `registry.sh validate`，因为钩子并非在每种工具中都会运行 |
| `validate-write.sh` | PreToolUse (Write/Edit) | 对下文所列规则的写入与编辑 | 当写入会替换技能从不覆盖的文件（已存在的 `EPIC.md`、`project.godot`、`tests/helpers/*`、技术债登记表、引擎参考资料文档、`/test-setup` 创建的文件）、将配置值设为列表之外的值或 `project.local.yaml` 无法容纳的键、设置评审模式、让原型文件缺少 `PROTOTYPE` 或 `VERTICAL SLICE` 头部或在 `prototypes/` 与代码根目录之间越界、在冻结生效期间修改字符串表，或从子代理写入除 `production/`、`docs/` 或 `tests/` 下的新文件之外的任何内容时，发出警告，且绝不阻塞。检查为 `bash .claude/scripts/write-guard.sh check`，写入这些文件的技能也会自行运行它 |
| `validate-read.sh` | PreToolUse (Read) | 在 `design/`、`docs/architecture/` 或 `production/session-state/` 下不带 offset 和 limit 的 Read | 阻止对超过 40 KB 的文档做整文件读取（`features.read_guard_kb`），并按行返回该文档的标题，使重试只需读取一个章节；带范围的读取始终通过。`features.read_guard: off` 可将其关闭。检查为 `bash .claude/scripts/read-guard.sh check` |
| `validate-agent-artifact.sh` | SubagentStop | 子代理停止 | 当其返回契约指定的文件（"Write your full output to `<path>`"）不在磁盘上时，无论其回复怎么写，都把它视为失败阶段，向你发出警告，且绝不阻塞。仅向你显示：在此事件中，发给 Claude 的文本会让子代理继续运行 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 资源文件变更 | 检查 `assets/`、`Assets/` 或 `Content/` 下的数据文件 JSON，且只在 Godot 的 `assets/` 中检查资源命名 |
| `session-start.sh` | SessionStart | 会话开始 | 加载冲刺上下文、里程碑、git 活动；检测并预览用于恢复的活动会话状态文件，若其检查点命名的分支与当前所在分支不同则输出一行提示；当有新版本发布时输出一行提示，来源是 `update-check.sh` 在后台最多每天刷新一次的缓存（`effects-map.md` 中的 `updates.check`） |
| `detect-gaps.sh` | SessionStart | 会话开始 | 检测全新项目（建议 /start），以及存在代码/原型时缺失的文档，建议 /reverse-document 或 /project-stage-detect |
| `pre-compact.sh` | PreCompact | 上下文压缩 | 向 `production/session-logs/compaction-log.txt` 追加一行，不打印任何内容：Claude Code 不会把 PreCompact 的输出加入对话。每次压缩后都会再次运行的 `session-start.sh` 才是恢复上下文的机制 |
| `notify.sh` | Notification (`permission_prompt`, `idle_prompt`) | Claude 正在等待权限提示，或已空闲约一分钟 | 通过 PowerShell 显示 Windows 通知气泡 |
| `session-stop.sh` | Stop, async | **每次回复结束** — 而非每个会话一次 | 更新会话日志，并把子代理派生统计写入 `production/session-logs/session-cost.md`；不打印任何内容。仅当其内容哈希发生变化时才归档 `active.md`；没有这一守卫时，长会话会在每一轮追加整个文件。它在后台运行，因此该轮不必等待它；在 `claude -p` 下若会话结束时仍在运行则会被取消 |
| `log-agent.sh` | SubagentStart | 代理被派生、恢复，或团队成员处理新消息 | 审计轨迹起点 — 记录带时间戳和会话 ID 的子代理调用。SubagentStart 在恢复时以及每条 agent-team 消息时也会触发，因此派生统计会把这些计入 |
| `log-agent-stop.sh` | SubagentStop | 代理停止 | 审计轨迹终点 — 补全子代理记录。跳过 Claude Code 的内部代理（提示建议、`/btw`），它们到达时 `agent_type` 为空 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 技能文件变更 | 在写入或编辑任何 `.claude/skills/` 文件后，建议运行 `/skill-test` |

`validate-*` 钩子发出的警告会显示给你并传给 Claude（来自
`validate-agent-artifact.sh` 的则仅显示给你），格式为钩子 JSON（`yaml-helper.sh`
中的 `hook_warn`）；只有必须立即修复的问题才会以退出码 2 结束，以及读守卫的拒绝。
关于为何 stderr 不够，见 `hooks-reference/hook-input-schemas.md`。

### 子代理成本可见性

上述三个钩子构成一条链。`log-agent.sh` 为每次派生向
`production/session-logs/agent-audit.log` 写入一条固定三字段格式的记录：

```
YYYYMMDD_HHMMSS | <session_id> | Agent invoked: <agent_type>
```

`session-stop.sh` 通过检索字面字符串 `" | $SESSION_ID | Agent invoked: "` 来统计
当前会话，然后把计数加上按代理的细分写入
`production/session-logs/session-cost.md`。

该记录的字段顺序是固定的。`session-stop.sh` 按字面匹配它，因此不同的顺序会让派生
计数静默归零，而不是报错。

当钩子输入没有 session id 时，`session-stop.sh` 不写入总数。跨越日志中所有会话的
总数看起来合理但实际是错的，这比没有更糟。

携带代理名的字段是 `agent_type` — 而不是 `agent_name`。见
`hooks-reference/hook-input-schemas.md`。

## 评估过但有意未添加的事件

Claude Code 提供的钩子事件远多于上述钩子使用的八个。以下事件经评估后未采用，
原因如下。

| 事件 | 未采用原因 |
| ---- | ---- |
| `UserPromptSubmit` | 会在**每次提示**时重新注入会话状态。`.claude/docs/config-resolution.md` 已经否决了它的较弱版本 — 在会话开始时注入配置 — 因为那 "would cost tokens on every session whether or not any skill needs config, and it would go stale mid-session as `/settings` writes land"。按提示触发是同样的论点，而且被放大。 |
| `ConfigChange` | 只为 Claude Code 自己的设置文件触发 — user、project、local、policy 和 skills。它**不会**为 `project.yaml` 触发，因此在这里监视框架配置的钩子永远不会运行。`FileChanged` 才是监视任意文件的事件。 |
| `FileChanged` 针对 `project.yaml` | 配置在每次技能调用时于技能正文中解析，正是为了让每次运行都读取最新值。唯一残留的过期内容是已注入到更早一次调用中的文本，这是 `config-resolution.md` 中已接受的取舍。 |
| `PreToolUse` `updatedInput` | 可以改写不合规的提交信息，而不是阻止它。静默编辑用户输入违背协作协议：本项目会阻止并解释，而不是未经请求就行动。 |
| `PostToolUseFailure` | 只会增加一份没有读者的日志。 |
| `SessionEnd` | `session-stop.sh` 保留在 `Stop` 上。`SessionEnd` 在终止时触发，而崩溃可能永远到不了那里，内容哈希守卫已经让每次回复触发变得廉价。 |
| `PostCompact` | 它的输出和 `systemMessage` 永远不会到达 Claude，而 `session-start.sh` 已经在压缩后恢复上下文。在这里加钩子只会为每次压缩付出一次进程启动的代价。 |
| `InstructionsLoaded` | 用于调试究竟加载了哪些 CLAUDE.md 和规则文件很有用，但它是诊断手段，不是项目需求。需要时在你自己的 `.claude/settings.local.json` 中接入它，而不是在每次加载时都付出代价。 |

钩子参考文档：`.claude/docs/hooks-reference/`
钩子输入 schema 文档：`.claude/docs/hooks-reference/hook-input-schemas.md`
