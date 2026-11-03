# 设置指南（Settings Guidance）— 该推荐哪个值，以及何时推荐

项目设置的**建议性**层。本文件回答其他文档都不回答的两个问题：

1. **技能应该为给定项目或用户推荐哪个值？**
2. **技能应该在何时主动建议修改**一个已经设置好的配置？

## 与同类文档的边界

| 文档 | 回答的问题 | 性质 |
|---|---|---|
| `effects-map.md` | 每个设置*做什么* | 描述性 |
| `config-resolution.md` | 设置*如何解析*（优先级链） | 机制性 |
| **`settings-guidance.md`**（本文件） | 该*推荐*哪个值，以及*何时*推荐 | 规范性 |

技能**按需**引用本文件，只在「推荐设置」的时刻引用。它**不是** CLAUDE.md 的导入项
— 建议性内容不应进入每轮对话的上下文。

---

## 1. 最重要的配置项：`modes.rigor`

几乎所有「我该用什么设置？」的问题都可归结为一个选择：
`modes.rigor`（`minimal` | `standard` | `full`，默认 `minimal`）。它统领六个子项 —
`modes.workflow`、`docs.density`、`qa.level`、`modes.story_granularity`、
`modes.review_mode`、`team.size`。推荐 **rigor**，而不是这六项；让展开逻辑处理其余
部分。完整的展开表在 `effects-map.md § modes.rigor`。

`modes.automation`（`collaborative` | `guided` | `autonomous`）是一个**独立维度** —
即技能多久停下来确认一次 — *不*由 rigor 统领。按工作风格选择它，而不是按游戏类型
（见 § 5）。

---

## 2. 原型类型 → rigor 预设

将项目匹配到某个原型；推荐与之配对的 rigor。这些是起点，不是结论 — 用户随时可以覆盖。

| 原型 | Rigor | 原因 | 常见覆盖 |
|---|---|---|---|
| 周末创作活动 / 原型 / 一次性项目 | `minimal` | 发布比记录更重要；设计存在于作者脑中 | 提升一个深度系统：`workflow_overrides.system_overrides: {combat: full}` |
| 小型单人或业余游戏（街机、解谜、短篇叙事） | `minimal` → 若规模扩大则 `standard` | 从轻量开始；当范围被证明真实时再增加 rigor | — |
| 专注的商业独立游戏（平台跳跃、roguelike、战棋、构筑卡牌） | `standard` | 一个充分理解的循环；设计足以正确构建 | 「全面但紧凑」：`rigor: full` + `docs.density: terse` |
| 系统密集型 / 长线项目（开放世界 RPG、殖民地模拟、沉浸式模拟、4X、生存） | `full` | 大量相互作用的系统；一个设计错误要花数周 | 单人开发：磁盘上保留 `full`，本地设置 `review_mode: solo` |
| 长线运营 / 竞技多人 | `full` + 领域强化 | 完整流水线*加上*网络代码/安全/长线运营 | 为在线关键类型提高 `qa.level` / `testing.strict.*` |

**模型：** 表格给出基线；覆盖项处理对角线情况。多数真实项目是一个基线加一两个
有意的例外。

---

## 3. 根据描述的概念预植 rigor

当用户已经描述过他们的游戏（例如 `/start` Phase 2 的自由文本），将其映射到某个
原型，并**预选**推荐值，而不是冷冰冰地提问。信号：

| 概念提到… | 倾向于 |
|---|---|
| open-world、RPG、sim、sandbox、faction、crafting、economy、MMO、multiplayer、"systems" | `full` |
| jam、weekend、prototype、"first game"、small、"just trying"、experiment | `minimal` |
| "release"、"commercial"、"on Steam"、单一清晰的核心循环 | `standard` |
| *模糊 / 以上都没有* | `minimal`（文档记录的默认值） |

**规则：** 这些是启发式判断，绝不是锁定。始终用用户自己的语言与其确认预选结果
（"听起来像是个大型系统向游戏 — 我建议 `full` rigor；要这样吗？"）。如果用户
**还没有概念**（在探索），不要预植 `full` — 默认 `minimal`，等概念出现后再重新考虑。

"还没有概念"意味着**没有信号**，而不是特指某条上手引导路径。粗略的一行提示仍然是
一种描述：如果它触发了上述信号，就按信号预植。只有当用户没有给出任何可映射内容时，
才回退到「探索阶段用 `minimal`」。（`/start` Phase 4 在为其 Path A/B 分支推断
rigor 时应用同样的规则。）

---

## 4. 何时建议*修改*（自适应触发器）

双向且**基于阈值**。只在阈值*跨越*时触发，绝不每次会话都触发 — 这正是防止它变成
`automation` 模式所要消除的唠叨。

| 触发器（跨越） | 方向 | 可检测信号 | 建议动作 |
|---|---|---|---|
| 项目规模超出其档位 | ↑ 提高 | 系统 GDD 数量跨过约 9，或代码根目录（`src/`、`Assets/` 或 `Source/`）跨过 Production 阈值，而 rigor 仍为 `minimal` | "你在 `rigor: minimal` 下已有 N 个系统 — 这个规模的项目大多用 `standard`。要重新考虑吗？→ `/settings`" |
| 阶段推进到 Production | ↑ 提高 | `/gate-check` PASS 进入 Production，而 rigor 仍为 `minimal` | 同上，在闸门处提供一次 |
| 用户听起来被流程压垮 | ↓ 降低 | 出现 "too many steps"、"so much documentation"、"overwhelmed" 之类的说法 — *且* rigor 尚未是 `minimal` | "如果必填文档列表感觉太重，降低 rigor 可以精简它 → `/settings modes.rigor=standard`" |
| 所选 rigor 与描述的范围不匹配 | 标记一次 | 上手引导的选择与 Phase-2 描述矛盾 | 用一句话说明，提供 `/settings`，不要再次询问 |

**频率守卫：** 跨越*本身*就是闸门。由于宿主（PASS 时的 `/gate-check`、按需的
`/help`）本身并不频繁，不需要持久的「已提醒过」状态 — 但绝不要在一次会话中重复
发出同一条建议。

---

## 5. 哪些技能引用本文件，以及何时引用

| 技能 | 时机 | 使用的章节 |
|---|---|---|
| `/start` | Phase 4 — 为卡片推断 rigor | § 2（预设）、§ 3（根据概念预植） |
| `/help` | 用户听起来卡住/被压垮时的升级页脚 | § 4（降低触发器） |
| `/gate-check` | PASS 进入新阶段时 | § 4（提高触发器） |
| `/settings` | 查看输出 — 延伸阅读 | § 2（选择值） |

这些技能各自带有指向本文件的**一行指针**。

---

## 6. 如何表述建议

- **建议，而非命令。** 一行说明建议及理由；由用户决定。（`collaborative`/`guided`
  要求如此；即使是 `autonomous` 也把 rigor 变更视为 `schema_changes` 决策并询问。）
- **始终引导到 `/settings`** — 绝不要因为给出建议而顺手修改 `project.yaml`。
- **一行，然后停止。** 提醒就是提醒，不是说教。
