# 活动钩子（Active Hooks）

钩子在 `.trae/hooks.json`（`version: 1`）中配置，并自动触发。Trae 只支持
`SessionStart`、`UserPromptSubmit`、`PreToolUse`、`PostToolUse`、`Stop`、`Notification`
六类事件；`PreCompact` 视版本而定。

| 钩子 | 事件 | 触发条件 | 动作 |
| ---- | ----- | ------- | ------ |
| `validate-deny.sh` | PreToolUse (RunCommand) | 所有终端命令 | 执行 `.trae/hooks/deny-rules.json` 中的 130 条 deny 规则；命中即拒绝并说明原因 |
| `validate-protected.sh` | PreToolUse (Read/Write/Edit) | 受保护路径 | 阻止读取 `.env`，以及写入 `.env`、`.uasset`、`.umap` |
| `validate-commit.sh` | PreToolUse (RunCommand) | `git commit` 命令 | 校验设计文档章节、JSON 数据文件、硬编码值、TODO 格式 |
| `validate-push.sh` | PreToolUse (RunCommand) | `git push`、`git tag`、`git merge` 以及发布类命令 | 对推送到受保护分支（`main`、`master` 和 `release/*`）发出警告，并对会先询问的步骤发出警告：`git tag`（非列表）、`git merge`（非 `--abort`）、`gh release`、`butler push` 以及带 `+run_app_build` 的 `steamcmd`。哪些命令计入由 `bash .trae/scripts/write-guard.sh git` 决定 |
| `validate-registry.sh` | PreToolUse (Write/Edit) | 对 `design/registry/entities.yaml` 和 `docs/architecture/tr-registry.yaml` 的写入与编辑 | 当变更会删除或重新编号条目，或设置的状态超出文件头部列出的取值时，发出警告，且绝不阻塞。它在写入之前运行，此时旧文件仍可对比；检查本身是 `bash .trae/scripts/registry.sh compare`。写入注册表的技能还会在写入后运行 `registry.sh validate`，因为钩子并非在每种工具中都会运行 |
| `validate-write.sh` | PreToolUse (Write/Edit) | 对下文所列规则的写入与编辑 | 当写入会替换技能从不覆盖的文件（已存在的 `EPIC.md`、`project.godot`、`tests/helpers/*`、技术债登记表、引擎参考资料文档、`test-setup` 创建的文件）、将配置值设为列表之外的值或 `project.local.yaml` 无法容纳的键、设置评审模式、让原型文件缺少 `PROTOTYPE` 或 `VERTICAL SLICE` 头部或在 `prototypes/` 与代码根目录之间越界、在冻结生效期间修改字符串表，或从子代理写入除 `production/`、`docs/` 或 `tests/` 下的新文件之外的任何内容时，发出警告，且绝不阻塞。检查为 `bash .trae/scripts/write-guard.sh check`，写入这些文件的技能也会自行运行它 |
| `validate-read.sh` | PreToolUse (Read) | 在 `design/`、`docs/architecture/` 或 `production/session-state/` 下不带 offset 和 limit 的 Read | 阻止对超过 40 KB 的文档做整文件读取（`features.read_guard_kb`），并按行返回该文档的标题，使重试只需读取一个章节；带范围的读取始终通过。`features.read_guard: off` 可将其关闭。检查为 `bash .trae/scripts/read-guard.sh check` |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 资源文件变更 | 检查 `assets/`、`Assets/` 或 `Content/` 下的数据文件 JSON，且只在 Godot 的 `assets/` 中检查资源命名 |
| `session-start.sh` | SessionStart | 会话开始 | 加载冲刺上下文、里程碑、git 活动；检测并预览用于恢复的活动会话状态文件，若其检查点命名的分支与当前所在分支不同则输出一行提示；当有新版本发布时输出一行提示，来源是 `update-check.sh` 在后台最多每天刷新一次的缓存（`effects-map.md` 中的 `updates.check`） |
| `detect-gaps.sh` | SessionStart | 会话开始 | 检测全新项目（建议 `start`），以及存在代码/原型时缺失的文档，建议 `reverse-document` 或 `project-stage-detect` |
| `pre-compact.sh` | PreCompact（视版本） | 上下文压缩 | 向 `production/session-logs/compaction-log.txt` 追加一行，不打印任何内容：Trae 不会把 PreCompact 的输出加入对话。每次压缩后都会再次运行的 `session-start.sh` 才是恢复上下文的机制 |
| `notify.sh` | Notification (`permission_prompt`, `idle_prompt`) | Trae 正在等待权限提示，或已空闲约一分钟 | 通过 PowerShell 显示 Windows 通知气泡 |
| `session-stop.sh` | Stop | **每次回复结束** — 而非每个会话一次 | 更新会话日志，并写入子代理派生统计；不打印任何内容。仅当其内容哈希发生变化时才归档 `active.md`；没有这一守卫时，长会话会在每一轮追加整个文件 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 技能文件变更 | 在写入或编辑任何 `.trae/skills/` 文件后，建议运行 `skill-test` 技能 |

`validate-*` 钩子发出的警告通过 `additionalContext` 传给模型（`yaml-helper.sh`
中的 `hook_warn`）；只有必须立即修复的问题才会以退出码 2 结束，以及读守卫的拒绝。
Trae 的 Hook 输出不支持 `systemMessage`，所以本仓库的钩子只使用
`hookSpecificOutput.additionalContext` 和 `permissionDecision`。

## 子代理审计与成本

Trae 不支持 `SubagentStart` / `SubagentStop`，因此：

- `log-agent.sh`、`log-agent-stop.sh` 和 `validate-agent-artifact.sh` 保留在
  `.trae/hooks/` 中，但**没有注册**。
- `session-stop.sh` 仍会写会话日志，但不再有子代理派生明细。
- 需要审计时，可在 Trae 的 Agent 调用后手动运行 `log-agent.sh`，或从 Trae 的
  会话记录中查看。

## 评估过但有意未添加的事件

Trae 的事件集比 Claude Code 小。以下事件或字段经评估后未采用：

| 事件 / 字段 | 未采用原因 |
| ---- | ---- |
| `UserPromptSubmit` | 会在**每次提示**时重新注入会话状态，消耗 token 且可能在 `/settings` 写入后过期。 |
| `SubagentStart` / `SubagentStop` | Trae 运行时没有这两个事件。 |
| `PostCompact` | 输出不会进入对话；`session-start.sh` 已在压缩后恢复上下文。 |
| `PreToolUse.updatedInput` | 静默改写用户输入违背协作协议：本项目会阻止并解释，而不是未经请求就行动。 |

钩子参考文档：`.trae/docs/hooks-reference/`
钩子输入 schema 文档：`.trae/docs/hooks-reference/hook-input-schemas.md`
