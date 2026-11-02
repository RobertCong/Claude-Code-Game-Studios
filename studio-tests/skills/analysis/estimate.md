# Skill Test Spec: /estimate

## Skill Summary

`/estimate [task-description]` 估算单个任务的工作量。它从参数中读取任务描述（如果描述过于模糊、无法估算，则先请求澄清），从 `CLAUDE.md` 读取项目上下文，并从 `design/gdd/` 读取任何相关游戏设计文档（GDD）（Phase 1）。它扫描受影响的代码以评估复杂度、集成点和测试覆盖率，并读取 `production/sprints/` 中类似已完成任务和历史速度（Phase 2）。它分析代码复杂度、范围和风险（Phase 3），然后输出估算（Phase 4）：一张复杂度评估（Complexity Assessment）表、按乐观（Optimistic）/ 预期（Expected）/ 悲观（Pessimistic）三种情景给出的天数工作量估算、一个等于预期数值的推荐预算、一个带驱动因素的高 / 中 / 低置信度、风险因素、依赖、带合计的建议拆分，以及备注与假设——随后是一行摘要和 `Verdict: COMPLETE — estimate generated.`。估算值按半天取整。该技能为只读，不调用任何总监质量闸门（gate）。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具有必需的前置元数据（frontmatter）字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含乐观 / 预期 / 悲观情景、高 / 中 / 低置信度，以及 `COMPLETE` 结论
- [ ] 不要求「May I write」措辞（只读；明确说明不写入任何文件）
- [ ] 具有下一步交接（如何在冲刺规划中使用该估算）

---

## Director Gate Checks

无。估算是提供建议的信息型技能；不调用任何质量闸门（gate）。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 文档化系统中已有既定模式的清晰任务

**Fixture:**
- `project.yaml`：`engine.name: godot`，因此代码根为 `src/`
- `design/gdd/combat.md` 记录了近战命中检测
- `src/combat/` 存放近战攻击代码；其中已有类似的碰撞代码
- `production/sprints/sprint-003.md` 到 `sprint-005.md` 记录了已完成的战斗任务

**Input:** `/estimate Add hitbox detection to melee attacks`

**Expected behavior:**
1. 技能复述任务；描述足够具体，因此不请求澄清
2. 由于任务涉及已文档化的系统，技能读取 `design/gdd/combat.md`
3. 技能扫描 `src/combat/`，找出受影响的文件、集成点和现有测试
4. 技能读取 `production/sprints/`，查找类似的已完成任务和速度
5. 输出遵循 Phase 4 模板：复杂度评估、工作量估算（乐观 / 预期 / 悲观，以天计）、推荐预算、置信度、风险因素、依赖、带合计的建议拆分、备注与假设
6. 推荐预算等于预期数值；所有数值均为半天增量
7. 简短摘要给出推荐预算、置信度和最大的单一风险
8. 输出以 `Verdict: COMPLETE — estimate generated.` 结束；不写入任何文件

**Assertions:**
- [ ] 在产出估算之前，已读取战斗 GDD 和冲刺历史
- [ ] 复杂度评估的规模行给出受影响文件的 Grep 计数（非空行数、分支行数），并说明分支数量只是近似值而非实测复杂度
- [ ] 工作量以三个天数形式给出（乐观、预期、悲观），而不是单一数字
- [ ] 推荐预算等于预期数值，而不是乐观数值
- [ ] 数值按半天取整，而不是按小时
- [ ] 结尾摘要点明预算、置信度和最大风险
- [ ] 不写入任何文件

---

### Case 2: 高不确定性 — 新子系统，架构未定

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `src/` 中没有任何在线或匹配子系统的源文件
- `design/gdd/online.md` 描述了大厅，需求为开放的「TBD」，并说明网络方案（传输方式、主机模型）尚未决定

**Input:** `/estimate Implement online lobby matchmaking`

**Expected behavior:**
1. 技能读取 `design/gdd/online.md`，发现未解决的需求和未定的网络方案
2. 代码扫描未发现现有子系统；「Existing patterns available」为 No
3. 风险因素表列出具体的未知项：GDD 未决定的网络方案、新技术、不明确的需求
4. 置信度为低，并解释其驱动因素
5. Phase 5 建议在投入前通过 `/prototype` 进行时间盒式的技术探索（spike）
6. 不写入任何文件

**Assertions:**
- [ ] 当任务方案未定、没有现有代码且需求为 TBD 时，置信度为低
- [ ] 风险因素表指出驱动不确定性的具体未知项
- [ ] 输出建议在投入前进行时间盒式的 `/prototype` 技术探索
- [ ] 不写入任何文件

---

### Case 3: 无冲刺速度数据 — 仍产出估算，并说明数据缺口

**Fixture:**
- `project.yaml`：`engine.name: godot`；`src/core/` 存放存档所涉及的背包代码
- `design/gdd/save-load.md` 清晰记录了存档系统
- `production/sprints/` 为空——没有历史冲刺

**Input:** `/estimate Implement save and load of player inventory`

**Expected behavior:**
1. 技能读取任务、GDD 和受影响的代码
2. 技能查找过往冲刺数据，未找到
3. 仍产出包含全部三种情景和推荐预算的估算
4. 备注与假设（或置信度说明）指出没有可用的冲刺历史，因此数值未按团队速度校准
5. 不会为了弥补缺失数据而悄悄抬高任何数值——任何额外风险都被明确点出
6. 不写入任何文件

**Assertions:**
- [ ] 没有冲刺历史时，技能不报错也不停止
- [ ] 仍产出包含乐观、预期和悲观数值的估算
- [ ] 输出说明没有可用于速度校准的冲刺历史
- [ ] 针对缺失数据的任何余量都以风险形式说明，而不是隐藏在数值中

---

### Case 4: 模糊任务 — 估算前先澄清

**Fixture:**
- `project.yaml`：`engine.name: godot`
- 项目在 `src/` 下有 GDD 和源代码；存在冲刺历史

**Input:** `/estimate make combat feel better`

**Expected behavior:**
1. 技能读取任务描述，发现其过于模糊、无法有意义地估算（没有范围、没有明确的改动）
2. 技能在继续前请求澄清
3. 在任务得到澄清之前，不产出复杂度评估、工作量估算或结论
4. 不写入任何文件

**Assertions:**
- [ ] 对于没有指明具体改动的任务，技能请求澄清
- [ ] 在澄清得到回答之前，不产出任何估算数值
- [ ] 对未澄清的任务不打印 `Verdict: COMPLETE`
- [ ] 不写入任何文件

---

### Case 5: 质量闸门合规 — 无质量闸门；估算仅供参考

**Fixture:**
- `project.yaml`：`engine.name: godot`，`modes.review_mode: full`
- 任务涉及一个已文档化的中等复杂度系统；其代码位于 `src/` 下

**Input:** `/estimate Add item pickup with inventory stacking`

**Expected behavior:**
1. 技能读取上下文，扫描代码和冲刺历史；产出估算
2. 在任何评审模式下都不调用总监质量闸门
3. 估算仅作为建议性输出呈现
4. 后续步骤包括「run `/sprint-plan update` to add it to the next sprint」

**Assertions:**
- [ ] 无论评审模式如何，都不调用总监质量闸门
- [ ] 输出纯属信息性质——没有审批或写入提示
- [ ] 后续步骤建议引用 `/sprint-plan`
- [ ] 估算不因评审模式而改变

---

## Protocol Compliance

- [ ] 在估算前读取任务参数、项目上下文和任何相关 GDD
- [ ] 在可用时读取 `production/sprints/` 以获取类似任务和速度
- [ ] 产出一个工作量区间（乐观 / 预期 / 悲观天数），而不是单一数字
- [ ] 不写入任何文件
- [ ] 不调用任何总监质量闸门
- [ ] 以与结果匹配的 Phase 5 后续步骤结束（低置信度时用 `/prototype`，任务超过 10 天时用 `/create-stories`，安排排期时用 `/sprint-plan update`）

---

## Coverage Notes

- 该技能每次运行只估算一个任务；包含多个用户故事的冲刺文件不是受支持的输入。
- 「任务超过 10 天 → 通过 `/create-stories` 拆分为更小的用户故事」这一分支没有单独用例。
- 天数数值的准确性取决于团队，因此不做测试；断言检查的是区间的结构、来源及其声明的驱动因素。
