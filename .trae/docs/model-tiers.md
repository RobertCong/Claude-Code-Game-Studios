# 模型层级分配

> ### 技能的 `model:` 何时生效 —— 仅限技能
>
> 技能的 `model:` 会在该技能运行的那一轮剩余时间内覆盖会话模型，你的下一条提示则回到会话模型。是否发生覆盖取决于技能的启动方式：
>
> | 技能的启动方式 | `model:` 是否生效？ |
> |---|---|
> | 你在 Manual（`default`）模式下键入 `/skill-name` | 生效 |
> | 你在 auto 模式下键入 `/skill-name` | `sonnet` 和 `opus`：生效。`haiku`：不生效 —— auto 模式不支持 Haiku，因此会话保持其模型 |
> | Claude 自己通过 Skill 工具启动技能 | 不生效 —— 由会话模型运行它 |
>
> 由此得出两点：
>
> - **在 Sonnet 会话中，`opus` 技能花费更高。** 键入
>   `/architecture-review`、`/gate-check` 或 `/review-all-gdds` 会把那一轮
>   切换到 Opus。
> - **`haiku` 技能在 auto 模式下省不了钱**（本项目的设置会让终端会话以 Manual 启动，但用户可以切换）—— 在 Claude 自己启动它时也一样。绝不要告诉用户 `haiku` 层级为他们省了钱。
>
> 由于覆盖会在你的下一条提示时结束，一个在聊天中停下来询问你某些事情的技能，会在你回答后以会话模型完成。
>
> **这不适用于 agent。** `.claude/agents/*.md` 中的 `model:` 是另一种机制，它以独立会话的方式创建，而不是内联执行，Claude Code 文档说明它是会生效的：它在子 agent 模型顺序中位居第二，仅次于 Claude 为某一次调用传入的 `model`。参见下面的 agent 章节。

技能和 agent 按任务复杂度分配层级。层级以 `model:` 接受的别名书写，绝不用模型 ID：Claude Code 会把每个别名解析为该系列中的当前模型，因此本表在新模型发布时无需改动。

| 层级 | `model:` | 使用时机 |
|------|----------|-------------|
| **Haiku** | `haiku` | 只读状态检查、格式化、简单查找 —— 无需创意判断 |
| **Sonnet** | `sonnet` | 实现、设计撰写、单个系统分析 —— 大多数工作的默认选择 |
| **Opus** | `opus` | 多文档综合、高风险阶段闸门结论、跨系统整体评审 |
| **Session** | `inherit` | 仅限 agent —— 在会话所用的任何模型上运行 |

使用 `model: haiku` 的技能（5 个）：`/help`、`/onboard`、`/project-stage-detect`、`/scope-check`、`/sprint-status`

> `/patch-notes` 和 `/changelog` 是 `sonnet`，不是 `haiku`：两者都产出**面向玩家**的文案，需要最廉价层级被定义为不承担的判断力。完整理由见各技能自身的头部说明。
>
> `/settings` 出于同样的原因被移出 `haiku`。它不只读取和格式化 —— 它要带来源解析每个叶子项，然后把配置的严谨度（rigor）与项目可观察的实际工作方式进行对比。这属于综合，而 Haiku 那一行的定义正是排除综合。

使用 `model: opus` 的技能（3 个）：`/architecture-review`、`/gate-check`、`/review-all-gdds`

其他所有技能均为 Sonnet。创建新技能时，如果它只读取和格式化，就分配 Haiku；如果它必须综合 5 个以上文档且输出高风险，就分配 Opus；否则显式写入 `model: sonnet`。每个技能都会声明一个层级。层级是否生效取决于技能的启动方式（见本文件顶部的表格）。

**Agent 模型层级。** 全部 49 个 agent 都使用 `model: inherit`，在会话模型上运行。没有任何 agent 固定指定模型。

这一点偏离了随附的默认配置。上游把三个 agent 固定为 `opus` ——
`creative-director`、`producer`、`technical-director` —— 并把 16 个固定为 `sonnet`：
`lead-programmer`、`prototyper`、`devops-engineer`、`community-manager`，以及
12 个引擎子专家（`godot-csharp-specialist`、
`godot-gdextension-specialist`、`godot-gdscript-specialist`、
`godot-shader-specialist`、`ue-blueprint-specialist`、`ue-gas-specialist`、
`ue-replication-specialist`、`ue-umg-specialist`、
`unity-addressables-specialist`、`unity-dots-specialist`、
`unity-shader-specialist`、`unity-ui-specialist`）。那 19 个固定项都已改为
`inherit`，因此现在每个子 agent 都取会话所用的任何模型 ——
包括本仓库中任何固定项都无法指定的模型。

有两点后果值得牢记：

- **成本与延迟取决于会话，而非 agent。** Sonnet 会话会让三位总监也在 Sonnet 上运行。若要在这些调用上用 Opus，就启动一个 Opus 会话，或在此处重新固定它们。
- **上下文窗口下限不复存在。** 固定项过去能保证一个下限：`opus` agent 的运行窗口从不小于其父级。现在没有任何东西能保证这一点，不过子 agent 仍从给它的简报（brief）开始，而不是从父级对话开始，所以这只在简报非常大时才有影响。

哪些技能分派哪些子专家不受这一切影响：`/dev-story` 和 `/code-review` 会创建 `project.yaml` 的 `specialists` 块（由 `/setup-engine` 写入）中指定的子专家；`/team-ui` 会创建 `unity-ui-specialist` 和 `ue-umg-specialist`；`/team-release` 会创建 `devops-engineer` 和 `community-manager`，而 `/team-live-ops` 会创建 `community-manager`。

上面 Haiku 那一行仍然不描述任何 agent：它面向只读查找和格式化，而每个 agent 都会起草、撰写或判断。

如果只是想临时而非永久这样做，那正是 `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` 的用途。在你的 `.claude/settings.local.json` 中设置它（Claude Code v2.1.257 或更高版本），会在创建时覆盖每个 agent 自己的 `model:` 行：

```json
{ "env": { "CLAUDE_CODE_SUBAGENT_MODEL_FORCE": "1" } }
```

既然没有固定项可覆盖，它就是空操作，因此只有当你再次固定 agent 时它才有价值。仅设置 `CLAUDE_CODE_SUBAGENT_MODEL` 做不到这一点：它只适用于未自行设置模型的 agent —— 而现在每个 agent 都是如此。
