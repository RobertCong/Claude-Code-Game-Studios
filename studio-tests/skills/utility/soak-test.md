# Skill Test Spec: /soak-test

## Skill Summary

`/soak-test [duration] [focus]` 为延长试玩会话生成观察协议——由人试玩，
技能编写计划。时长取
`30m`、`1h`、`2h` 或 `4h`（默认 `1h`）；焦点取 `memory`、`stability`、
`balance` 或 `all`（默认 `all`）。它从 `project.yaml` 读取 `engine.name` 与 `performance.*`
（回退到 `technical-preferences.md`）、游戏
概念或简报、最新试玩与 QA 计划，然后按所选时长
构建定时检查点，并给出引擎相关的内存指引，其告警
阈值相对于本次会话自身的 T+0 基线，单位按
显示值记录。它给出的引擎工具与计数器名称未被
`docs/engine-reference/` 覆盖，因此标记为 NOT SOURCEABLE——这些指针由
测试者在 T+0 确认，并记录实际使用的工具。

协议文档包含 Verdict 节，提供 PASS / PASS WITH CONCERNS /
NOT ASSESSED / FAIL 供测试者在会话后填写；短时浸泡
不能返回 PASS。技能在写入前询问 "May I write this soak test protocol to
`production/qa/soak-test-[date]-[duration].md`?"，且绝不自行运行
浸泡。其运行步骤以 `/bug-triage sprint` 结束，或在
`workflow: minimal` 下以 `/bug-triage full` 结束（该模式没有冲刺）。不适用
任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：PASS、PASS WITH CONCERNS、NOT ASSESSED、FAIL
- [ ] 在写入协议之前包含 "May I write" 协作协议用语
- [ ] 有下一步交接（会话后 `/bug-triage sprint`，`workflow: minimal` 下 `/bug-triage full`；修复 FAIL 后 `/smoke-check`）

---

## Director Gate Checks

无。`/soak-test` 是 QA 规划工具。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — Godot 上 2 小时全焦点浸泡

**Fixture:**
- `project.yaml` 中有 `engine.name: Godot`、`performance.target_framerate: 60` 与
  `modes.workflow: standard`（固定：未设置会解析为 minimal，从而以
  `/bug-triage full` 结束运行步骤，见 Case 6）
- `design/gdd/game-concept.md` 说明预期会话时长
- 用户批准写入

**Input:** `/soak-test 2h all`

**Expected behavior:**
1. 技能加载上下文：引擎、性能预算、概念、最新试玩与 QA 计划
2. `2h` 的检查点：T+0、T+20、T+40、T+60、T+80、T+100、T+120
3. Godot 内存项：Debugger 的内存监视器、Static Memory（单位按
   显示值）、Object Count、Orphan Nodes——名称标记为 NOT SOURCEABLE，因为
   `docs/engine-reference/godot/` 未覆盖它们，供测试者在 T+0 确认；
   前 15 分钟后内存较 T+0 增长 > 20% 时告警；
   场景卸载后 Orphan Nodes 必须回到其 T+0 值
4. 稳定性项（60 fps 目标）与平衡/疲劳项都包含
5. 协议文档包含 Pre-Session Setup、Baseline (T+0)、每个
   检查点的 Checkpoint Log、Post-Session Analysis，以及留给测试者的 Verdict 节
6. 技能询问 "May I write this soak test protocol to
   `production/qa/soak-test-[date]-2h.md`?"
7. 写入后，打印以 `/bug-triage sprint` 结束的运行步骤

**Assertions:**
- [ ] 检查点恰为 T+0、T+20、T+40、T+60、T+80、T+100、T+120
- [ ] 内存阈值相对于 T+0，单位按显示值记录（不假定单位）
- [ ] Godot 工具与计数器名称标记为 NOT SOURCEABLE，不呈现为已验证，且 Pre-Session Setup 询问实际使用的工具
- [ ] 内存、稳定性与平衡观察项全部存在（焦点 `all`）
- [ ] 以 `production/qa/soak-test-[date]-2h.md` 询问 "May I write"
- [ ] 技能本身不给出结论——协议的 Verdict 节留给测试者

---

### Case 2: 无参数 — 应用默认值

**Fixture:**
- 未提供参数；引擎已配置

**Input:** `/soak-test`

**Expected behavior:**
1. 时长默认为 `1h`，焦点默认为 `all`——开始前无需提问
2. 检查点：T+0、T+15、T+30、T+45、T+60
3. 协议头部记录 `Duration: 1h` 与 `Focus: all`
4. 技能询问 "May I write this soak test protocol to `production/qa/soak-test-[date]-1h.md`?"

**Assertions:**
- [ ] 未给参数时使用时长 `1h` 与焦点 `all`
- [ ] 检查点恰为 T+0、T+15、T+30、T+45、T+60
- [ ] 输出路径以 `-1h.md` 结尾
- [ ] 在 "May I write" 批准之前不写入任何内容

---

### Case 3: Unreal 上的窄焦点 — 4 小时内存浸泡

**Fixture:**
- `project.yaml` 中有 `engine.name: Unreal`

**Input:** `/soak-test 4h memory`

**Expected behavior:**
1. `4h` 的检查点：T+0、T+30、T+60、T+90、T+120、T+180、T+240
2. Unreal 内存项：每个检查点读取内存——`stat memory`，
   标记为 NOT SOURCEABLE，因为 `docs/engine-reference/unreal/` 未覆盖
   它；记录 Physical Memory Used 与 Available（单位按显示值）
3. 告警阈值：整个浸泡期间 Physical Memory Used 增长 > 20%，
   相对于本次运行的 T+0——没有绝对 MB 阈值
4. 不生成平衡/疲劳观察项（焦点为 `memory`）
5. 输出路径 `production/qa/soak-test-[date]-4h.md`

**Assertions:**
- [ ] 检查点恰为 T+0、T+30、T+60、T+90、T+120、T+180、T+240
- [ ] Unreal 阈值为相对的 > 20% 增长，而非绝对大小
- [ ] `stat memory` 标记为 NOT SOURCEABLE，是待确认的指针而非已验证命令
- [ ] 焦点为 `memory` 时省略平衡/疲劳项
- [ ] "May I write" 指明 `-4h.md` 路径

---

### Case 4: 无性能预算 — 记为 "not set"，绝不臆造

**Fixture:**
- `project.yaml` 中有 `engine.name: Unity`，且没有 `performance` 块
- `technical-preferences.md` 的 Performance Budgets 为 `[TO BE CONFIGURED]`

**Input:** `/soak-test 30m memory`

**Expected behavior:**
1. 技能从 `project.yaml` 回退到 `technical-preferences.md` 获取预算
2. 预算说明读作 `Memory ceiling: not set`、`Target FPS: not set`、
   `Frame budget: not set`——不以任何数字替代
3. 检查点：T+0、T+10、T+20、T+30
4. Unity 内存项：内存分析器，标记为 NOT SOURCEABLE（未被
   `docs/engine-reference/unity/` 覆盖）；记录 Total Reserved Memory、GC Allocated、
   Object Count（单位按显示值）；当 GC Allocated 在 3 个以上检查点
   持续单调增长时告警
5. 技能在写入 `production/qa/soak-test-[date]-30m.md` 之前询问 "May I write"

**Assertions:**
- [ ] 缺失的预算记为 "not set"，不用默认值填充
- [ ] 检查点恰为 T+0、T+10、T+20、T+30
- [ ] Unity 阈值是无单位的单调增长检查
- [ ] 在写入文件之前询问 "May I write"

---

### Case 5: 总监闸门检查 — 无闸门；soak-test 是规划工具

**Fixture:**
- 引擎已配置；提供了有效的时长与焦点

**Input:** `/soak-test 1h stability`

**Expected behavior:**
1. 技能生成并写入浸泡测试协议
2. 不派发任何总监代理
3. 输出中不出现闸门 ID

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 运行以 "Protocol written." 与运行步骤结束——没有闸门结论，技能也不发出浸泡结论

---

### Case 6: 最小工作流 — 运行步骤以 `/bug-triage full` 结束

**Fixture:**
- `project.yaml`：`engine.name: Godot`、`modes.workflow: minimal`（固定：Case 1 固定
  `standard`；本用例测试相反情况）
- 没有 `production/sprints/` 目录；用户批准写入

**Input:** `/soak-test 1h all`

**Expected behavior:**
1. 协议按 Case 2 构建并写入
2. 写入后，"Protocol written." 列出运行步骤；第 5 步读作
   `/bug-triage full`，因为 `workflow: minimal` 没有冲刺
3. 结尾行仍说明修复 FAIL 后再次运行 `/smoke-check`

**Assertions:**
- [ ] 会话后步骤为 `/bug-triage full`，而非 `/bug-triage sprint`
- [ ] 第 1–4 步与 `/smoke-check` 行与 `standard` 运行时一致
- [ ] 工作流从 `project.yaml` 解析，且只改变该步骤

---

## Protocol Compliance

- [ ] 解析 `[duration] [focus]`，默认 `1h` 与 `all`
- [ ] 对所选时长使用 Phase 3 检查点表
- [ ] 内存告警阈值为相对 T+0 的比例或增量；单位按显示值记录
- [ ] 未被 `docs/engine-reference/` 覆盖的引擎工具名标记为 NOT SOURCEABLE；测试者找不到内存工具时结论保持 NOT ASSESSED
- [ ] 协议的 Verdict 节提供 PASS / PASS WITH CONCERNS / NOT ASSESSED / FAIL，并说明短时浸泡不能返回 PASS
- [ ] 在创建 `production/qa/soak-test-[date]-[duration].md` 之前询问 "May I write"
- [ ] 绝不尝试自行运行浸泡

---

## Coverage Notes

- `stability` 与 `balance` 焦点值遵循 Case 3 的模式与其他观察组；
  未单独测试。
- 在 `rigor: minimal` 下，技能读取 `design/game-brief.md` 而非
  游戏概念；未单独测试。
- 执行协议超出本技能范围——它生成计划，
  由人运行。
