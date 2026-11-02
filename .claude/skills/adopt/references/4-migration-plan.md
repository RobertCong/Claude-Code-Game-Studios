# /adopt — Phase 4: 构建迁移计划

> `/adopt` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 4: 构建迁移计划

编写一份带编号、有序的行动计划。排序规则：
1. 先处理 BLOCKING 缺口（在任何流水线技能可靠运行之前必须修复）
2. 其次处理 HIGH 缺口，基础设施先于 GDD/ADR 内容（引导需要正确的格式）
3. MEDIUM 缺口的顺序：GDD 缺口先于 ADR 缺口，ADR 缺口先于用户故事缺口（用户故事依赖 GDD 和 ADR）
4. LOW 缺口最后

对每个缺口，生成一条计划条目，包含：
- 清晰的问题陈述（一句话，不含术语）
- 若有技能可处理，给出修复它的确切命令
- 若需要直接编辑，给出手动步骤
- 时间估计（粗略：5 分钟 / 30 分钟 / 1 个会话）
- 用于追踪的复选框 `- [ ]`

**特殊情况 — systems-index 中带括号的状态值：**
如果存在，这始终是第一项。展示需要更改的确切值
以及确切替换文本。在写入计划之前，主动提出立即修复。

**特殊情况 — ADR 缺少 Status 字段：**
对每个受影响的 ADR，修复方式是：
`/architecture-decision retrofit docs/architecture/adr-[NNNN]-[slug].md`
将每个 ADR 列为单独的可勾选项。

**特殊情况 — GDD 缺少章节：**
对每个受影响的 GDD，列出缺少哪些章节以及修复方式：
`/design-system retrofit design/gdd/[filename].md`

**基础设施引导顺序** — 始终按此顺序呈现：
1. 先修复 ADR 格式（注册表依赖读取 ADR 的 Status 字段）
2. 运行 `/architecture-review` → 引导生成 `tr-registry.yaml`
3. 运行 `/create-control-manifest` → 创建带版本标记的清单
4. 运行 `/sprint-plan update` → 创建 `sprint-status.yaml`
5. 运行 `/gate-check [phase]`（进入项目当前所在阶段的质量闸门；在 Concept 阶段没有闸门 — Concept 是默认阶段，无需运行）→ 权威地写入 `project.yaml` 中的 `project.stage`（以及旧版 `stage.txt`）

**在 `workflow: minimal` 下，计划不规定上述任何顺序。** 这些都不
在 minimal 路径上：不预期存在 ADR，简报的构建顺序就是
计划（没有 `/sprint-plan`），那里也不会运行 `/gate-check`。计划的
Step 3 用一行说明这一点，并改为指出该路径的下一步 —
不存在用户故事时用 `/create-stories`，否则用 `/dev-story`。

**现有用户故事** — 明确说明：
> “现有用户故事可继续与所有模板技能配合工作 — 字段缺失时
> 所有新的格式检查都会自动通过。在它们被重新生成之前，
> 不会受益于 TR-ID 陈旧性追踪或清单版本检查。这是
> 有意为之：不要重新生成已经进行中的用户故事。”

---
