# Skill Test Spec: /perf-profile

## Skill Summary

`/perf-profile` 是一个静态分析性能剖析器。它接受系统名或 `full` 作为范围，在产出任何内容之前将其所需的每项输入记录为 `FOUND` 或 `ABSENT`，从注入在其顶部的配置块解析 `performance.enforce`（Phase 0；该块还携带 `automation` 和 `workflow`），并用 `get_effective_yaml_key` 读取已提交的预算键 `performance.target_framerate`、`performance.frame_budget_ms`、`performance.draw_call_limit` 和 `performance.memory_ceiling_mb`，之后才回退到设计文档或 `AGENTS.md`（Phase 2）。它分析源代码中的 CPU、内存、渲染和 I/O 热点候选（Phase 3）——它不摄入运行时剖析器导出文件。报告将每个有预算的行评为 `OK` / `WARNING` / `OVER`；没有已提交预算的指标为 `NOT ASSESSED`，摘要仅针对已设置的预算给出余量（否则为 `no budget set — headroom not assessed`）。该技能在写入前询问「May I write this profiling report to `production/polish/[scope]-report-[date].md`?」（Phase 4），针对 M 或 L 工作量的热点提供实施 / 削减范围 / 推迟 / 上报四个选项（Phase 5），并交接给 `/architecture-decision`、`/scope-check` 或 `/sprint-plan update`（Phase 6）。不调用任何总监质量闸门。结论为：COMPLETE，或当所有必需输入都缺失时的 NOT ASSESSED — NO DATA。在 `workflow: minimal`（没有冲刺）下，被接受的优化进入简报的构建顺序，且 Phase 6 不指向 `/sprint-plan update`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、NOT ASSESSED — NO DATA，以及逐指标状态 OK / WARNING / OVER
- [ ] 包含点名 `production/polish/[scope]-report-[date].md` 的「May I write」措辞
- [ ] 具有下一步交接（Phase 6：`/architecture-decision`、`/scope-check`、`/sprint-plan update`）

---

## Director Gate Checks

无。性能剖析是建议性分析技能；在任何评审模式下都不调用质量闸门（gate）。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 预算已提交，发现战斗热点

**Fixture:**
- `project.yaml`：`engine.name: godot`、`performance.target_framerate: 60`、
  `performance.frame_budget_ms: 16.6`、`performance.draw_call_limit: 200`、
  `performance.memory_ceiling_mb: 2048`；`performance.enforce` 未设置（解析为
  `warn`）；`modes.automation` 未设置（collaborative）
- 没有任何配置键、设计文档或 `AGENTS.md` 章节给出加载时间目标
- `src/gameplay/combat/enemy_manager.gd` 有一个 `_process()`，它遍历每个敌人，并在该循环内遍历每个活动弹体，且每帧为每个敌人投射一条射线
- 将嵌套循环改造为空间分区是一项多日改动

**Input:** `/perf-profile combat`

**Expected behavior:**
1. 技能记录其输入：源代码 FOUND、已提交预算 FOUND
2. Phase 0：`performance.enforce` 解析为 `warn`——违规属于发现项，而不是阻塞项
3. Phase 2：在任何回退之前，用 `get_effective_yaml_key` 读取四个 `performance.*` 键
4. Phase 3：列出战斗的 `_process()` 函数；识别出嵌套循环和每帧射线检测
5. Phase 4：报告的 Performance Budgets 表将 16.6 ms、2048 MB 和 200 次绘制调用作为预算，其中这三行各自带有 OK / WARNING / OVER 状态；Load time 行没有已提交预算，为 `NOT ASSESSED`；热点和建议引用 `enemy_manager.gd` 并给出行号
6. 摘要给出前 3 个热点、针对三个已设置预算的估算余量、加载时间的 `no budget set — headroom not assessed`，以及推荐的下一步行动
7. 技能询问「May I write this profiling report to `production/polish/combat-report-[date].md`?」
8. 嵌套循环热点被评为 Fix Effort M 或 L，因此 Phase 5 提供：实施、通过 `/scope-check` 削减范围、推迟到 Polish，或通过 `/architecture-decision` 上报
9. Verdict: COMPLETE

**Assertions:**
- [ ] 预算来自用 `get_effective_yaml_key` 读取的四个 `performance.*` 键，而不是来自设计文档或硬编码的 16.67 ms
- [ ] 嵌套循环和每帧射线检测被报告为热点，并带有 `file:line` 位置
- [ ] 每条优化建议都说明位置、预期收益、风险和实现方式
- [ ] 帧时间、内存和绘制调用行带有 OK / WARNING / OVER 状态；Load time 行为 `NOT ASSESSED`，而不是 OK
- [ ] 不为加载时间声称任何余量；摘要写明 `no budget set — headroom not assessed`
- [ ] 「May I write」点名 `production/polish/combat-report-[date].md`，并先于任何写入
- [ ] M/L 工作量的热点触发 Phase 5 选项（实施 / `/scope-check` / 推迟到 Polish / `/architecture-decision`）
- [ ] 结论为 COMPLETE

---

### Case 2: 无已提交预算 — 预算行为 NOT ASSESSED

**Fixture:**
- `project.yaml` 有 `engine.name: godot`，且没有 `performance` 块
- 没有任何设计文档和 `AGENTS.md` 章节给出帧率、内存、加载时间或绘制调用目标
- `src/` 包含带 `_process()` 函数的玩法脚本

**Input:** `/perf-profile full`

**Expected behavior:**
1. `get_effective_yaml_key` 对四个预算键均返回空；设计文档和 `AGENTS.md` 回退也未找到目标
2. 源代码为 FOUND，因此 Phase 3 分析仍然运行并报告热点
3. Performance Budgets 表的每一行都是 `NOT ASSESSED`——都没有对照模板的 `[16.67ms]` 占位符进行衡量
4. 摘要不针对无人设置的预算声称余量：它写明 `no budget set — headroom not assessed`
5. 技能询问「May I write this profiling report to `production/polish/full-report-[date].md`?」；`NOT ASSESSED` 行保留在供写入的文件中

**Assertions:**
- [ ] 没有任何预算行显示 OK、WARNING 或 OVER；每一行都是 `NOT ASSESSED`
- [ ] `[16.67ms]` 占位符从不被用作预算，也不声称任何余量数值
- [ ] 热点分析仍然运行并被报告
- [ ] `NOT ASSESSED` 行保留在供写入的报告中，而不是被删掉

---

### Case 3: 无可剖析内容 — 整体结论 NOT ASSESSED — NO DATA

**Fixture:**
- 全新项目：`project.yaml` 有 `engine.name: godot` 且没有 `performance` 块，代码根 `src/` 不存在
- 不存在任何设计文档
- 任何地方都没有剖析器输出

**Input:** `/perf-profile full`

**Expected behavior:**
1. 技能列出其输入并逐项记录：源代码 ABSENT、预算 ABSENT、剖析器输出 ABSENT
2. 每项必需输入都是 ABSENT，因此技能在 Phase 3 之前停止
3. 技能报告整体结论为 `NOT ASSESSED — NO DATA`，点名缺失的内容以及由哪个技能产出
4. 不填写任何报告模板，也不提供任何写入

**Assertions:**
- [ ] 每项输入都被记录为 FOUND 或 ABSENT，而不是假定存在
- [ ] 整体结论为 `NOT ASSESSED — NO DATA`，而不是 COMPLETE
- [ ] 输出点名每项缺失输入以及由哪个技能产出
- [ ] 没有填写好的报告、没有余量数值，也没有「May I write」提示

---

### Case 4: 本地强制级别覆盖为 `block` — 违规即阻塞项

**Fixture:**
- `project.yaml`：`engine.name: godot`、`performance.enforce: warn`、`performance.draw_call_limit: 200`，其他三个预算已设置
- `project.local.yaml`：`performance.enforce: block`，因此技能顶部解析出的配置块显示 `block`
- `src/levels/forest/forest_builder.gd` 实例化了 600 个独立的植被 `MeshInstance3D` 节点，每个都有自己的材质且没有实例化
- `modes.automation` 未设置（collaborative）

**Input:** `/perf-profile forest`

**Expected behavior:**
1. Phase 0 使用技能顶部解析出的配置块中的 `block`，而不是重新读取 `project.yaml` 会得到的 `warn`
2. forest 范围的绘制调用估算超过 200；Draw calls 行为 OVER
3. 报告明确说明该违规是阻塞项——会阻止发布——并且 `/gate-check` 会因此使 Polish 质量闸门 FAIL
4. 给出建议（例如对植被进行批处理或实例化）及其预期收益
5. 技能在写入 `production/polish/forest-report-[date].md` 前询问「May I write」

**Assertions:**
- [ ] 本地 `block` 生效，而不是已提交的 `warn`——`performance.enforce` 来自解析出的配置块
- [ ] Draw calls 行相对于 200 预算为 OVER
- [ ] 报告说明该违规是阻塞项，并且 `/gate-check` 会因此使 Polish 质量闸门 FAIL
- [ ] 「May I write」先于任何写入

---

### Case 5: 完整评审模式下强制级别为 `off` — 仅供参考，无质量闸门

**Fixture:**
- `project.yaml`：`engine.name: godot`、`modes.review_mode: full`、`modes.workflow: standard`（固定：未设置会解析为 `minimal`，而 `minimal` 没有冲刺，因此 Phase 6 会点名简报的构建顺序而不是 `/sprint-plan update`）、`performance.enforce: off`，四个预算全部已设置
- `src/` 包含一个 `_process()`，其估算帧开销超过 `performance.frame_budget_ms`

**Input:** `/perf-profile full`

**Expected behavior:**
1. 无论评审模式如何，都不调用总监质量闸门
2. Performance Budgets 表中仍报告估算帧时间
3. 由于 `off` 下预算仅供参考，超预算的帧时间不会作为违规发现或修复建议提出
4. 技能在写入报告前询问「May I write」
5. 输出以 Phase 6 后续步骤结束：`/architecture-decision`、`/scope-check [feature]`、`/sprint-plan update`

**Assertions:**
- [ ] 在任何评审模式下都不调用总监质量闸门
- [ ] 估算帧时间仍出现在预算表中
- [ ] 超预算指标不作为违规发现或修复建议提出
- [ ] 「May I write」先于任何写入
- [ ] 后续步骤点名 `/architecture-decision`、`/scope-check` 和 `/sprint-plan update`

---

### Case 6: `workflow` — 已接受的优化流向何处

**Fixture:**
- 同 Case 1：预算已提交，`enemy_manager.gd` 有嵌套循环和
  每帧射线检测，且嵌套循环热点被评为 Fix Effort M 或 L
- `modes.rigor: minimal`，因此 `modes.workflow` 解析为 `minimal`（无冲刺）
- 用户为嵌套循环热点选择 A
- 变体：`modes.workflow: standard`（固定：这是有冲刺的层级）

**Input:** `/perf-profile combat`

**Expected behavior:**
1. 因为某个热点为 M 或 L，所以运行 Phase 5，选项 A 的文案为「Implement the
   optimization」，并在 `minimal` 下注明没有冲刺，该项工作添加到简报的构建顺序
2. 在 `minimal` 下用户选择 A 后，优化被导向简报的构建顺序，而不是冲刺
3. Phase 6 的排期说明要求将优化添加到简报的构建顺序，而不是运行 `/sprint-plan update`；不点名 `/sprint-plan` 作为排期方式
4. 在 `standard` 变体下：选项 A 提供立即进行修复或安排排期，且 Phase 6 点名 `/sprint-plan update`
5. 两次运行的结论均为 COMPLETE

**Assertions:**
- [ ] 在 `minimal` 下，选项 A 和 Phase 6 都指向简报的构建顺序
- [ ] 在 `minimal` 下，不推荐 `/sprint-plan update`
- [ ] `standard` 变体：Phase 6 点名 `/sprint-plan update`，且选项 A 不提及构建顺序
- [ ] 其他 Phase 5 选项（`/scope-check`、推迟到 Polish、`/architecture-decision`）以及 Phase 6 中针对 `/architecture-decision` 和 `/scope-check [feature]` 的行在两次运行中相同
- [ ] 结论为 COMPLETE

---

### Case 7: 会话从子文件夹启动 — 仍从项目根读取预算

**Fixture:**
- 项目根下的 `project.yaml`：`engine.name: godot`、
  `performance.target_framerate: 60`、`performance.frame_budget_ms: 16.6`、
  `performance.draw_call_limit: 200`、`performance.memory_ceiling_mb: 2048`
- 会话的工作目录是 `src/gameplay/`（子文件夹），而不是根目录
- `src/gameplay/combat/enemy_manager.gd` 有一个带嵌套循环的 `_process()`

**Input:** `/perf-profile combat`

**Expected behavior:**
1. Phase 2 将四个 `get_effective_yaml_key` 读取作为单条命令运行，该命令
   先切换到项目根，并从那里加载 `.trae/hooks/yaml-helper.sh`
2. 四个键都返回其已提交值；没有因从子文件夹找不到辅助脚本或 `project.yaml` 而返回空
3. Performance Budgets 表使用 16.6 ms、2048 MB 和 200 次绘制调用；这些行
   不是 `NOT ASSESSED`

**Assertions:**
- [ ] 预算读取是单条命令，先切换到项目根再加载辅助脚本，而不是从当前文件夹运行四次读取
- [ ] 四个值都是已提交值，而不是空值
- [ ] 没有预算行因工作目录而成为 `NOT ASSESSED`：在 `project.yaml` 中设置的预算绝不会被报告为未设置
- [ ] 嵌套循环仍被发现并以 `file:line` 位置报告

---

## Protocol Compliance

- [ ] 在产出任何报告之前，将每项输入记录为 FOUND 或 ABSENT
- [ ] 在回退到设计文档或 `AGENTS.md` 之前，用 `get_effective_yaml_key` 读取四个 `performance.*` 预算键
- [ ] 没有已提交预算的指标为 `NOT ASSESSED`——绝不对照 `[16.67ms]` 占位符衡量——且摘要仅针对已设置的预算声称余量
- [ ] 应用解析出的配置块中的 `performance.enforce`：`warn` → 发现项，`block` → 阻塞项，`off` → 仅供参考
- [ ] 在写入前询问「May I write」并点名 `production/polish/[scope]-report-[date].md`，且将 `NOT ASSESSED` 章节保留在写入的文件中
- [ ] 不调用任何总监质量闸门
- [ ] 以 Phase 6 的下一步交接结束；排期行取决于 `workflow`（`standard`/`full` 下为 `/sprint-plan update`，`minimal` 下为简报的构建顺序）

---

## Coverage Notes

- 未识别的 `performance.enforce` 值（向用户显示后按 `warn` 处理）此处未测试。
- 该技能仅为静态分析；通过运行时剖析确认热点列在报告的「Requires Investigation」章节下，这些用例不覆盖该路径。
- 在 Phase 5 选项 C 下推迟 M/L 热点会将其记录在 `### Deferred to Polish` 下；该记录未单独断言。
