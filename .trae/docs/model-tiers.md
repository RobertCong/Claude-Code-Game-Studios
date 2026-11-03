# 模型层级分配（Trae）

Trae 的 Skill frontmatter **没有** `model:` 字段，模型由当前会话或子代理配置决定。
因此本仓库在迁移时移除了 74 个技能和 49 个 agent 的 `model:` 行；下面的层级保留为
**选择模型的建议**，而不是可执行配置。

## 建议层级

| 层级 | 使用时机 | 适合的技能 / 角色 |
|------|----------|------------------|
| **轻量 / Flash** | 只读状态检查、格式化、简单查找 —— 无需创意判断 | `help`、`onboard`、`project-stage-detect`、`scope-check`、`sprint-status` |
| **标准 / Code** | 实现、设计撰写、单个系统分析 —— 大多数工作的默认选择 | 其余技能与大部分 agent |
| **强推理 / Pro** | 多文档综合、高风险阶段闸门结论、跨系统整体评审 | `architecture-review`、`gate-check`、`review-all-gdds` |

`patch-notes` 和 `changelog` 建议用标准层级，而不是轻量层级：两者都产出**面向玩家**的
文案，需要判断力。`settings` 同理 —— 它要带来源解析每个叶子项，再把配置的严谨度
（rigor）与项目可观察的实际工作方式进行对比。

## 子代理模型

`.trae/agents/*.md` 支持 `model:`，但只接受 Trae 内置模型名（例如
`Doubao-Seed-2.1-Pro`、`Doubao-Seed-2.1-Turbo`、`glm-5.3`、`kimi-k3`、
`qwen-3.8-max` 等）。**省略 `model` 会继承当前会话模型**，这是本仓库的默认选择：

- 成本与延迟取决于会话，而非 agent。
- 需要更强推理时，在 Trae 中为本次会话切换模型，或给特定 agent 加 `model:`
  （只在该 agent 确实长期需要更强模型时）。
- 不要在 49 个 agent 上批量固定模型；这会让会话模型选择失效，并增加成本。

## 技能与 agent 的分派关系

哪些技能分派哪些子专家不受模型配置影响：`dev-story` 和 `code-review` 会创建
`project.yaml` 的 `specialists` 块（由 `setup-engine` 写入）中指定的子专家；
`team-ui` 会创建 `unity-ui-specialist` 和 `ue-umg-specialist`；`team-release` 会创建
`devops-engineer` 和 `community-manager`，而 `team-live-ops` 会创建
`community-manager`。

Trae 由内置 Agent 按子代理的 `description` 自动调度，不能按名字强制调用；技能中的
分派说明应写成「委派给 X 子代理」，而不是依赖 `subagent_type` 精确匹配。
