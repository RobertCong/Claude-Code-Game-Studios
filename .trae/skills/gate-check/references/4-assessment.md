# /gate-check —— 第 4 与 4b 节：评估与总监面板

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 4. 协作式评估

**本文件包含：**

- 4. 协作式评估：无法核实的事项绝不算 PASS
- 4b. 总监面板评估：`review_mode` 决定是否派生总监，`workflow` 决定面板宽度
- 闸门 ID
- 点名被省略的视角，并把面板结果应用到结论

对于无法自动核实的事项，**询问用户**：

- “我无法自动核实核心循环是否好玩。它经过试玩测试了吗？”
- “未找到试玩测试报告。做过非正式测试吗？”
- “性能剖析数据不可用。要运行 `/perf-profile` 吗？”

**绝不为无法核实的事项假定 PASS。** 把它们标记为 MANUAL CHECK NEEDED。
答复可以了结该项：“否”或“还没有”是已检查的失败项
（CONCERNS 或 FAIL，并点名能闭合它的技能——未评审的概念或 GDD 对应
`/design-review [doc]`）——Production 闸门上的趣味性问题除外
（已有人玩过垂直切片；在 `minimal` 下是当前构建的核心循环是否有趣），
那里的“还没有”意味着没人玩过：NOT ASSESSED
（`gate-production.md`）。只有未答复的项或“我不知道”会保持
MANUAL CHECK NEEDED，第 5 节会把它转为 NOT ASSESSED。

这适用于关于项目状态的问题。拒绝提供缺失数据的提议
（例如 `/perf-profile`）会让该项保持 NOT ASSESSED；在
`performance.enforce: off` 下，它不会进入结论。

---

## 4b. 总监面板评估

面板由**两个独立的维度**决定，两者都在 Phase 1 中解析：`review_mode`
决定面板*是否*运行，`workflow` 决定它*有多宽*。

**维度 1——`review_mode` 决定是否派生任何总监：**
- `solo` → 完全跳过面板。在输出中注明：“已跳过总监面板——Solo 模式。闸门结论仅基于产出物与质量检查。”继续到 Phase 5。
- `lean` → 运行面板（阶段闸门在 lean 模式下始终运行——这正是它们的目的）。
- `full` → 运行面板。

**维度 2——`workflow` 决定面板宽度。** 总监属于 Opus 层级，因此
面板按项目规模调整，而不是固定为四位。闸门在每个层级都会运行，
只是广度随之缩放：

| `workflow` | 面板 | 总监 |
|---|---|---|
| `minimal` | 1 | `producer` |
| `standard` | 2 | `technical-director`、`producer` |
| `full` | 4 | `creative-director`、`technical-director`、`producer`、`art-director` |

`producer` 出现在每个面板中——范围与进度的就绪度是没有任何层级
可以省略的判断。`technical-director` 从 `standard` 开始加入，因为那是
第一个要求架构产出物的层级。`creative-director` 与
`art-director` 从 `full` 开始加入，那是唯一要求完整美术圣经与
UX 规格集供其评估的层级。

> **宽度不等于严格度。** 更窄的面板不会软化结论：
> `.trae/docs/director-gates.md` 中的升级规则不变——
> *实际运行者*返回的最严格结论仍然胜出。不要从从未被咨询的
> 视角推断出 PASS。

在生成最终结论之前，按已解析层级通过 `Agent`，使用 `.trae/docs/director-gates.md` 中的并行闸门协议，把各总监作为**并行子代理**派生。同时发出所有 `Agent` 调用——不要等一个开始后再启动下一个。

**闸门 ID：**

1. **`creative-director`** —— 闸门 **CD-PHASE-GATE**（`.trae/docs/director-gates/cd-phase-gate.md`）
2. **`technical-director`** —— 闸门 **TD-PHASE-GATE**（`.trae/docs/director-gates/td-phase-gate.md`）
3. **`producer`** —— 闸门 **PR-PHASE-GATE**（`.trae/docs/director-gates/pr-phase-gate.md`）
4. **`art-director`** —— 闸门 **AD-PHASE-GATE**（`.trae/docs/director-gates/ad-phase-gate.md`）

向每位总监传入：目标阶段名称、解析出的 `workflow` 层级、目标
闸门在该层级下的必需与推荐产出物（即已加载闸门文件经层级削减和
`qa.level` 放宽后的清单——本闸门要求的内容，而不是后续闸门将要求的），
已存在的产出物列表，以及其闸门自身的上下文——在此点名，以便本会话
永远不必读取闸门文件：
- **CD-PHASE-GATE**：游戏支柱与核心幻想（来自
  `design/gdd/game-concept.md`，否则 `design/game-brief.md`）。
- **TD-PHASE-GATE**：架构文档路径、引擎参考路径
  （`docs/engine-reference/<engine>/VERSION.md`）以及 ADR 列表。
- **PR-PHASE-GATE**：已存在的冲刺与里程碑产出物、上文解析出的 `team.size`
  （若存在计划，则附上当前冲刺计划的产能），以及
  `production/epics/` 下状态为 `Blocked` 的用户故事数量。在
  `workflow: minimal` 下，把 `design/game-brief.md` 中的 Build order 作为计划传入——
  该层级没有冲刺计划。
- **AD-PHASE-GATE**：已存在的美术与视觉产出物、视觉识别锚点
  （来自 `design/gdd/game-concept.md`，否则取 `design/game-brief.md` 的“Art & audio direction”
  一行），以及美术圣经路径。

告诉每位总监按章节阅读任何 GDD、ADR 或美术圣经：用 Grep 工具
（模式 `^#`，content 模式）找到标题，再用 offset 和 limit
读取相应区间。

把每个上下文项作为以下三种之一传入，这样任何总监都不必猜测：
- **Present**——其路径或值（`0` 个被阻塞的用户故事也是一个值）。
- **“none”**——目标闸门（或更早的闸门）在该层级要求或推荐它，
  但它不存在（在 `/gate-check pre-production` 时没有架构文档）。
  对总监而言，这是关于项目、需要判断的事实，而不是缺失的输入。
- **“not expected before [phase]”**——目标闸门尚未要求它；
  点名其闸门首次要求它的阶段（Pre-Production 之前的架构文档与 ADR，
  Production 之前的冲刺计划）。该层级永远不要求的项目则写作
  “not required at `workflow: [tier]`”（例如 `minimal` 下的任何冲刺计划）。
  两者都绝不以“none”传入，也都不是发现项——总监判断的是
  即将进入阶段是否就绪，而不是更晚的阶段。

**在输出中点名被省略的视角。** 在总监面板摘要下方，当
面板比四位窄时，说明哪些视角没有运行以及如何获得它们——例如
“面板：4 位中的 2 位（`workflow: standard`）。未咨询创意与美术视角。
将 `modes.rigor` 提升到 `full`（或设置 `modes.workflow: full`）以获得
完整面板。” 点名配置块中显示为 `workflow` 来源的设置：当
`modes.workflow` 被单独设置时，提升 `modes.rigor` 不会改变它。绝不为此
指向 `--review full`——`--review` 决定面板是否运行，而不是它有多宽。
一个沉默地变窄的面板，读起来会像从未审阅过的评审者给出的一份
健康证明。

**收集所有实际运行的总监的答复，然后呈现总监面板摘要**（实际运行的每位总监一行；点名 `workflow` 省略掉的那些）：

```
## Director Panel Assessment

Creative Director:  [READY / CONCERNS / NOT READY / NOT ASSESSED]
  [feedback]

Technical Director: [READY / CONCERNS / NOT READY / NOT ASSESSED]
  [feedback]

Producer:           [READY / CONCERNS / NOT READY / NOT ASSESSED]
  [feedback]

Art Director:       [READY / CONCERNS / NOT READY / NOT ASSESSED]
  [feedback]
```

**应用到结论：**
- 任何总监返回 NOT READY → 结论至少为 FAIL（没有任何覆盖能把 FAIL 变成阶段变更——第 6 节）
- 任何总监返回 CONCERNS → 结论至少为 CONCERNS
- 任何总监返回 NOT ASSESSED（且没有任何一位返回 NOT READY 或 CONCERNS）→ 结论最好也只是 NOT ASSESSED；点名该总监表示缺失的输入——它绝不算作 READY
- 所有实际运行的总监都返回 READY → 有资格获得 PASS（仍受第 3 节产出物与质量检查的约束）

---
