# Skill Test Spec: /team-live-ops

## Skill Summary

通过 7 阶段的规划流水线编排长线运营（Live Ops）团队，产出
赛季或活动计划。协调 live-ops-designer、economy-designer、
analytics-engineer、community-manager、narrative-director 与 writer。Phase 0
解析 `review_mode`、`automation`、`team.size` 与 `workflow`，技能在
Phase 1 之前宣布活动集 —— `individual` 启动 live-ops-designer + economy-designer，
`small` 增加 analytics-engineer + community-manager，`studio` 增加 writer +
narrative-director。Phase 3 与 Phase 4（经济设计与分析）同时运行。
Phase 7 依据 `design/live-ops/ethics-policy.md` 检查经济设计。子代理
在 `production/` 下写入工作产出物；编排器汇编最终文档，并且只有在通过
`AskUserQuestion` 询问 "May I write the season plan to
`design/live-ops/…`?" 之后，才将其写入
`design/live-ops/seasons/`。以一份合并后的赛季计划收尾，
在交接给制作之前需要用户批准。

---

## Static Assertions (Structural)

- [ ] 具备必需的前置元数据（frontmatter）字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个 Phase 标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] Output Documents 章节：编排器在写入之前通过 `AskUserQuestion` 询问 "May I write the season plan to `design/live-ops/…`?"，因为 `design/` 位于有界写入例外之外
- [ ] 具备 File Write Protocol 章节，将子代理写入限制在有界例外内（指定路径、`production/`、`docs/` 或 `tests/` 下的新产出物、处于闸门内的阶段）—— 子代理若超出这些边界则需询问
- [ ] 为每个代理在 `production/live-ops/[season-slug]/` 下指定目标位置 —— `brief.md`、`narrative.md`、`economy.md`、`analytics.md`、`narrative-text.md`、`copy.md`、`comms.md` —— 每个代理一个文件
- [ ] 将阶段闸门定义为流水线自身列出的决策点，无论 `automation` 模式如何，且不声称总监在阶段闸门处启动
- [ ] 结尾具备后续步骤交接，引用 `/design-review`、`/sprint-plan` 与 `/team-release`
- [ ] 在阶段转换处使用 `AskUserQuestion`，以在继续之前获取用户批准（`collaborative` 模式）
- [ ] Phase 0 解析 `team.size`，且技能要求在 Phase 1 之前有一行活动集公告
- [ ] 明确说明 Phase 3 与 Phase 4 可同时运行（并行启动）
- [ ] 存在错误恢复章节：核实指定产出物在磁盘上、立即呈现 BLOCKED、始终产出部分报告，若无法解决则以 BLOCKED 结束
- [ ] Output documents 章节指定 `design/live-ops/seasons/` 下的路径

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与
`modes.automation: collaborative`，且不含 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 顺利路径 —— 全部 7 个阶段完成，产出赛季计划

**Fixture:**
- 已解析配置块：`team.size: studio`、`automation: collaborative`、`workflow: standard`（已固定：未设置时解析为 minimal，其后续步骤使用简报的构建顺序而非 `/sprint-plan`；Case 6 覆盖该情况）
- `design/live-ops/economy-rules.md` 存在，含当前经济配置
- `design/live-ops/ethics-policy.md` 存在，含项目伦理政策
- 游戏概念文档存在于其标准路径
- 正在规划的新赛季名不存在任何既有赛季文档

**Input:** `/team-live-ops "Season 2: The Frozen Wastes"`

**Expected behavior:**
1. 在任何启动之前，用一行宣布 `team.size: studio` 的活动集
2. Phase 1：通过 Agent 启动 `live-ops-designer`；收到含范围、内容清单与留存机制的赛季简报；呈现给用户
3. AskUserQuestion：用户在 Phase 2 开始之前批准 Phase 1 的输出
4. Phase 2：通过 Agent 启动 `narrative-director`；读取 Phase 1 的赛季简报；产出叙事框架文档（主题、故事钩子、世界观关联）；呈现给用户
5. Phase 3 与 4（并行）：在等待任一结果之前，通过两次 Agent 调用同时启动 `economy-designer` 与 `analytics-engineer`；economy-designer 读取 `design/live-ops/economy-rules.md`
6. Phase 5：并行启动 `narrative-director` 与 `writer`，产出游戏内叙事文本与面向玩家的文案；两者都读取 Phase 2 的叙事框架文档
7. Phase 6：通过 Agent 启动 `community-manager`；读取赛季简报、经济设计与叙事框架；产出含草稿文案的沟通日历
8. Phase 7：收集所有阶段输出；呈现合并后的赛季计划摘要，包含经济健康检查、分析准备情况、依据 `design/live-ops/ethics-policy.md` 的伦理评审，以及待解问题
9. AskUserQuestion：用户批准完整的赛季计划
10. 编排器汇编三份文档，并通过 AskUserQuestion 询问 "May I write the season plan to `design/live-ops/seasons/…`?"，覆盖 `S2_[name].md`、`S2_[name]_analytics.md` 与 `S2_[name]_comms.md`；仅在批准后写入
11. 结论：COMPLETE —— 赛季计划已产出并交接给制作

**Assertions:**
- [ ] 指明 `team.size: studio` 的活动集行出现在第一个代理启动之前
- [ ] 全部 7 个阶段按顺序执行；Phase 3 与 4 以并行 Agent 调用发起
- [ ] Phase 7 的合并摘要包含全部六个部分（赛季简报、叙事框架、经济设计、分析计划、内容清单、沟通日历）
- [ ] Phase 7 的伦理评审部分明确引用 `design/live-ops/ethics-policy.md`
- [ ] 三份输出文档写入 `design/live-ops/seasons/`，遵循 `S[N]_[name].md`、`S[N]_[name]_analytics.md`、`S[N]_[name]_comms.md` 命名约定
- [ ] `design/live-ops/` 下的文档仅在其 `AskUserQuestion` 批准之后由编排器写入 —— 没有子代理在 `design/` 下写入
- [ ] 仅在用户批准赛季计划之后，最终输出中出现结论：COMPLETE
- [ ] 后续步骤引用 `/design-review`、`/sprint-plan` 与 `/team-release`

---

### Case 2: 发现伦理违规 —— 奖励元素违反伦理政策

**Fixture:**
- 全部标准长线运营 fixture 齐备（economy-rules.md、ethics-policy.md）
- `design/live-ops/ethics-policy.md` 包含规则 "No randomized premium rewards without published drop rates and a pity timer"
- economy-designer（Phase 3）提议一个 "Mystery Chest" 机制，具备随机付费奖励、未公布掉落率且无保底计时

**Input:** `/team-live-ops "Season 3: Shadow Tournament"`

**Expected behavior:**
1. Phase 1–4 正常进行；economy-designer 提议 Mystery Chest 机制
2. Phase 7：编排器依据伦理政策审查 Phase 3 的输出；将 Mystery Chest 识别为该政策 "No randomized premium rewards without published drop rates and a pity timer" 规则的违规
3. Phase 7 摘要的伦理评审部分明确标记该违规："ETHICS FLAG: Mystery Chest mechanic in Phase 3 economy design violates 'No randomized premium rewards without published drop rates and a pity timer'. Approval is blocked until this is resolved."
4. 在提议批准赛季计划之前，呈现带解决选项的 AskUserQuestion
5. 在伦理违规被解决或用户明确豁免之前，技能不给出 COMPLETE 结论，也不写输出文档

**Assertions:**
- [ ] Phase 7 的伦理评审部分明确点名违规元素及其违反的政策规则
- [ ] 存在伦理违规时，技能不自动批准赛季计划
- [ ] 使用 AskUserQuestion 呈现该违规并提供解决选项（修改经济设计、带记录在案理由覆盖、取消）
- [ ] 违规未解决时不写入输出文档
- [ ] 若用户选择修改：技能重新启动 economy-designer 产出修正后的设计，然后返回 Phase 7 评审
- [ ] 仅在伦理标记清除之后才给出结论：COMPLETE；取消则以结论：BLOCKED 结束

---

### Case 3: 无参数 —— 展示用法指引

**Fixture:**
- 任意项目状态

**Input:** `/team-live-ops`（无参数）

**Expected behavior:**
1. 检测到无参数
2. 输出："Usage: `/team-live-ops [season name or event description] [--review full|lean|solo]` — Provide the name or description of the season or live event to plan."
3. 技能立即退出，不启动任何子代理

**Assertions:**
- [ ] 技能不猜测赛季名，也不虚构范围
- [ ] 用法消息展示完整 argument-hint：`/team-live-ops [season name or event description] [--review full|lean|solo]`
- [ ] 在参数检查失败之前，不发起任何 Agent 调用
- [ ] 不读取也不写入任何文件

---

### Case 4: 并行阶段验证 —— Phase 3 与 Phase 4 同时运行

**Fixture:**
- 已解析配置块：`team.size: small`、`automation: collaborative`
- 全部标准长线运营 fixture 齐备
- Phase 1（赛季简报）与 Phase 2（叙事框架）已批准
- Phase 3（economy-designer）与 Phase 4（analytics-engineer）的输入相互独立

**Input:** `/team-live-ops "Season 1: The First Thaw"`（在 Phase 3/4 转换处观察）

**Expected behavior:**
1. Phase 2 获得用户批准后，编排器在等待任一结果之前同时发起两次 Agent 调用（economy-designer 与 analytics-engineer）
2. 两个代理都以赛季简报作为上下文；analytics-engineer 不等待 economy-designer 的输出才开始
3. economy-designer 的输出与 analytics-engineer 的输出在 Phase 5 开始之前一并收集
4. 若两个并行代理之一阻塞，另一个继续；报告部分结果

**Assertions:**
- [ ] Phase 3 与 Phase 4 的两次 Agent 调用都在等待任一结果之前发起 —— 它们不是顺序执行
- [ ] analytics-engineer 的提示词不将 economy-designer 的输出列为必需输入（输入相互独立）
- [ ] 若 economy-designer 阻塞但 analytics-engineer 成功，分析输出被保留，且阻塞通过 AskUserQuestion 呈现
- [ ] 在 Phase 3 与 Phase 4 的结果都被收集之前，Phase 5 不开始
- [ ] 技能文档明确说明 "Phases 3 and 4 can run simultaneously"

---

### Case 5: 缺少伦理政策 —— `design/live-ops/ethics-policy.md` 不存在

**Fixture:**
- `design/live-ops/economy-rules.md` 存在
- `design/live-ops/ethics-policy.md` 不存在
- 其他所有 fixture 齐备

**Input:** `/team-live-ops "Season 4: Desert Heat"`

**Expected behavior:**
1. Phase 1–6 正常进行
2. Phase 7：编排器尝试运行伦理评审；检测到 `design/live-ops/ethics-policy.md` 缺失
3. Phase 7 摘要包含缺口标记："ETHICS REVIEW SKIPPED: `design/live-ops/ethics-policy.md` not found. Economy design was not reviewed against an ethics policy. Recommend creating one before production begins."
4. 技能仍完成赛季计划并达到 COMPLETE 结论，但该缺口在输出与赛季设计文档中被醒目标记
5. 后续步骤包含创建伦理政策文档的建议

**Assertions:**
- [ ] 伦理政策文件缺失时，技能不报错
- [ ] 文件缺失时，技能不虚构伦理政策规则
- [ ] Phase 7 摘要明确说明伦理评审被跳过及其原因
- [ ] 尽管文件缺失，仍可达到结论：COMPLETE
- [ ] 缺口标记出现在赛季设计输出文档中（不仅是对话中）
- [ ] 后续步骤建议创建 `design/live-ops/ethics-policy.md`

---

### Case 6: Workflow Minimal —— 冲刺步骤变为简报的构建顺序

**Fixture:**
- 已解析配置块：`workflow: minimal`（来自 `modes.rigor: minimal`）、`team.size: studio`（已固定，以便完整流水线运行）、`automation: collaborative`
- `design/game-brief.md` 存在并含构建顺序；没有 `production/sprints/` 文件夹
- `design/live-ops/economy-rules.md` 与 `design/live-ops/ethics-policy.md` 存在，且经济设计未提出伦理标记

**Input:** `/team-live-ops "Season 5: Harvest Moon"`

**Expected behavior:**
1. Phase 0 解析 `workflow` 以及 `review_mode`、`automation` 与 `team.size`
2. 流水线按 Case 1 运行，并在用户批准赛季计划后以结论：COMPLETE 结束
3. Next Steps：对赛季设计文档运行 `/design-review`；不用 `/sprint-plan`，而是将赛季的内容工作加入简报的构建顺序，因为 `minimal` 没有冲刺；内容就绪时运行 `/team-release`

**Assertions:**
- [ ] `workflow` 是 Phase 0 解析的键之一
- [ ] 安排步骤说明要将赛季的内容工作加入简报的构建顺序
- [ ] 不推荐 `/sprint-plan`
- [ ] 仍列出 `/design-review` 与 `/team-release`
- [ ] 运行的其余部分（活动集行、并行的 Phase 3 与 4、伦理评审、`design/live-ops/seasons/` 文档之前的 "May I write"）不因 `workflow` 而改变

---

## Protocol Compliance

- [ ] 在默认的 `team.size: individual` 下，运行以 `Active set (team.size: individual): live-ops-designer + economy-designer` 行与一行 `Not spawned this run:` 开始，后者点名 analytics-engineer、community-manager、narrative-director 与 writer —— 这一切发生在任何代理启动之前
- [ ] 在 `collaborative` 模式下，每个阶段转换处都使用 `AskUserQuestion` —— 用户在下一阶段开始之前批准
- [ ] 当 analytics-engineer 在活动集中（`small` 或 `studio`）时，Phase 3 与 Phase 4 并行启动，而非顺序执行
- [ ] 子代理仅在有界例外下写入编排器指定的路径；`design/live-ops/` 下的文档由编排器在一次 `AskUserQuestion` "May I write the season plan…" 批准之后写入
- [ ] 指定产出物在磁盘上缺失的阶段被视为失败，而非完成
- [ ] Phase 7 的伦理评审始终明确引用伦理政策文件路径
- [ ] 错误恢复：任何 BLOCKED 代理都会立即通过 AskUserQuestion 选项（跳过 / 重试 / 停止）呈现
- [ ] 若任何阶段阻塞，会产出部分报告 —— 工作绝不被丢弃
- [ ] 结论：仅在用户批准合并后的赛季计划之后为 COMPLETE；若存在任何未解决的伦理违规则为 BLOCKED
- [ ] 计划为 COMPLETE 后的后续步骤包含 `/design-review`、`/sprint-plan`（在 `workflow: minimal` 下以简报的构建顺序替代）与 `/team-release`；因伦理标记以 BLOCKED 结束的运行则改为点名修订与重新运行

---

## Coverage Notes

- Phase 5 的并行启动（narrative-director + writer）遵循与 Phase 3/4 相同的模式，
  但此处未单独测试 —— 它使用 Case 4 中验证过的同一并行 Agent 协议。
- "economy-rules.md 缺失" 的边界用例未单独测试 —— 它会作为
  economy-designer 的 BLOCKED 结果呈现，并遵循在 Case 4 中隐式测试过的标准错误恢复
  路径。
- 完整的内容撰写流水线（Phase 5 输出验证）由 Case 1 顺利路径的
  合并摘要检查隐式验证。
- 社区经理沟通日历格式（上线前、上线日、赛季中期、最后一周）由 Case 1
  隐式验证；无需单独的边界用例。
- Case 2 与 Case 5 仅依赖 economy-designer 与 Phase 7 评审，二者在
  每个 `team.size` 下都会运行。
