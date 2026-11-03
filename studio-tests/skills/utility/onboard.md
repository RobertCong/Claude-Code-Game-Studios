# Skill Test Spec: /onboard

## Skill Summary

`/onboard [role|area]` 为新贡献者或代理生成一份上手引导文档。它读取
`AGENTS.md`；当给出角色时，读取 `.trae/agents/` 中匹配的代理定义；扫描该角色
工作的领域（程序员为代码根目录，设计师为 `design/`，叙事为 `design/narrative/`，
QA 为 `tests/`，制作人为 `production/`），并读取最近的 git 历史。

在产出任何内容之前，它把各项输入列为 FOUND 或 ABSENT。输入为 ABSENT 的章节
写作 `NOT ASSESSED — NO DATA`，由未解析的代码根目录支撑的章节写作
`NOT ASSESSED — code root unresolved`。当前状态章节按路径指明 Phase 2 发现的内容
（对设计师而言，即每份现有 GDD 与设计文档）。如果所有输入均为 ABSENT，
则整个结论为 `NOT ASSESSED — NO DATA`，并指明缺失了什么。否则它填写
`# Onboarding: [Role/Area]` 模板，呈现出来，并询问 "May I
write this to `production/onboarding/onboard-[role]-[date].md`?"。结论为
**COMPLETE**，随后是指向 `/sprint-status` 与 `/help` 的后续步骤。不适用
任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE、NOT ASSESSED
- [ ] 在保存上手引导文档之前包含 "May I write" 措辞
- [ ] 有建议 `/sprint-status` 与 `/help` 的下一步交接

---

## Director Gate Checks

无。`/onboard` 是定向类实用技能。它不生成任何代理（`Agent` 不在其允许的工具
中），也不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Godot 项目上的程序员角色

**Fixture:**
- `AGENTS.md` 存在
- `project.yaml` 含 `engine.name: Godot`，因此代码根目录为 `src/`
- `src/` 含游戏代码；`.trae/agents/gameplay-programmer.md` 存在
- `production/sprints/sprint-005.md` 存在；git log 有近期提交
- `modes.automation` 未设置（默认为 `collaborative`）

**Input:** `/onboard gameplay-programmer`

**Expected behavior:**
1. 技能读取 `AGENTS.md` 与 `.trae/agents/gameplay-programmer.md`
2. 技能扫描代码根目录 `src/` 以了解架构、模式与关键文件，并读取最近的 git 历史
3. 技能生成一份标题为 `# Onboarding: gameplay-programmer` 的文档，包含
   模板各节（Project Summary、Your Role、Project Architecture、Current
   Standards and Conventions、Current State of Your Area、Current Sprint Context、
   Key Dependencies、Common Pitfalls、First Tasks、Questions to Ask）
4. 技能呈现该文档，然后询问 "May I write this to
   `production/onboarding/onboard-gameplay-programmer-[date].md`?"
5. 获批后写入文件（必要时创建目录）；结论为 COMPLETE，后续步骤为
   `/sprint-status` 与 `/help`

**Assertions:**
- [ ] 读取所指角色的代理定义
- [ ] 为该程序员角色扫描代码根目录 `src/`
- [ ] 文档使用 `# Onboarding: [Role/Area]` 模板各节
- [ ] 在 "May I write" 询问之前呈现文档，且该询问指明 `production/onboarding/onboard-gameplay-programmer-[date].md`
- [ ] 结论为 COMPLETE，后续步骤指明 `/sprint-status` 与 `/help`

---

### Case 2: Designer Role — 扫描 design/，而非代码根目录

**Fixture:**
- `AGENTS.md` 存在；`.trae/agents/game-designer.md` 存在
- `design/gdd/` 含三份系统 GDD
- `src/` 也含代码

**Input:** `/onboard game-designer`

**Expected behavior:**
1. 技能读取 `AGENTS.md` 与 `.trae/agents/game-designer.md`
2. Phase 2 走设计师分支，扫描 `design/` 中已有的设计文档
3. "Current State of Your Area" 反映找到的三份 GDD
4. 呈现文档，并就 `production/onboarding/onboard-game-designer-[date].md` 询问
   "May I write"；结论为 COMPLETE

**Assertions:**
- [ ] 为该角色扫描的领域是 `design/`
- [ ] 文档的当前状态章节指明现有 GDD
- [ ] "May I write" 询问中的文件路径使用角色名
- [ ] 结论为 COMPLETE

---

### Case 3: Every Input Absent — NOT ASSESSED，无文档

**Fixture:**
- `AGENTS.md` 不存在
- `.trae/agents/` 不存在，因此无法读取任何代理定义
- `tests/` 不存在；该目录不是 git 仓库

**Input:** `/onboard qa-tester`

**Expected behavior:**
1. 技能列出其输入，并把每一项记为 ABSENT
2. 由于所有必需输入均为 ABSENT，它停止并把
   `NOT ASSESSED — NO DATA` 作为整个结论报告
3. 报告指明缺失了什么以及由什么产生：`tests/` 由 `/test-setup` 产生；
   `AGENTS.md` 与 `.trae/agents/` 随框架本身提供——没有技能会创建它们——
   因此它们被报告为安装中缺失，而不归因于某个技能
4. 不生成任何上手引导文档，也不写入任何文件

**Assertions:**
- [ ] 在产出任何报告之前，把各输入记为 FOUND 或 ABSENT
- [ ] 结论为 `NOT ASSESSED — NO DATA`，而不是 COMPLETE
- [ ] 指明缺失的输入；`tests/` 指向 `/test-setup`
- [ ] 不把任何技能命名为 `AGENTS.md` 或 `.trae/agents/` 的产出者——没有技能创建它们
- [ ] 不填写任何模板，也不出现 "May I write" 询问

---

### Case 4: Edge Case — 程序员角色遇到未解析的代码根目录

**Fixture:**
- `AGENTS.md` 存在；`.trae/agents/gameplay-programmer.md` 存在
- `project.yaml` 没有 `engine.name`，technical-preferences 中为
  `[TO BE CONFIGURED]`，且 `src/` 与 `Assets/` 都存在（目录树有歧义）

**Input:** `/onboard gameplay-programmer`

**Expected behavior:**
1. 技能尝试解析代码根目录，并发现无法解析（有两个候选根目录，未设置引擎）
2. 它不会默认使用 `src/`
3. 依赖代码的章节（Project Architecture、Key Files）写作
   `NOT ASSESSED — code root unresolved`，而不是根据猜测填写——代码存在，
   因此这不是缺失数据的情况
4. 由已找到输入支撑的章节（Project Summary、Your Role、Current
   Standards and Conventions）仍会产出；文档在 "May I write" 询问之前呈现

**Assertions:**
- [ ] 不假定代码根目录为 `src/`
- [ ] 架构/关键文件内容标记为 `NOT ASSESSED — code root unresolved`，而不是 `NO DATA`
- [ ] 拥有已找到输入的章节仍会生成
- [ ] 在写入任何文件之前询问 "May I write"

---

### Case 5: Director Gate Check — 无；不生成代理

**Fixture:**
- 任何存在 `AGENTS.md` 的项目状态
- 任意评审模式

**Input:** `/onboard producer`

**Expected behavior:**
1. 技能扫描 `production/` 以了解当前冲刺与里程碑
2. 不生成任何种类的代理；输出中不出现任何闸门 ID
3. 呈现文档，然后询问 "May I write this to
   `production/onboarding/onboard-producer-[date].md`?"
4. 结论为 COMPLETE

**Assertions:**
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 不生成任何子代理
- [ ] 为该角色扫描的领域是 `production/`
- [ ] 写入询问之后 结论为 COMPLETE

---

## Protocol Compliance

- [ ] 生成之前读取 `AGENTS.md`，并在给出角色时读取其代理定义
- [ ] 只扫描与角色匹配的领域
- [ ] 把每项输入记为 FOUND 或 ABSENT；由 ABSENT 支撑的章节写作 `NOT ASSESSED — NO DATA`
- [ ] 在询问 "May I write" 写入 `production/onboarding/onboard-[role]-[date].md` 之前呈现文档
- [ ] 以 Verdict COMPLETE 与 `/sprint-status` / `/help` 后续步骤收尾——或者，当所有输入均缺失时，停在 `NOT ASSESSED — NO DATA` 并指明每项缺失输入由什么产生

---

## Coverage Notes

- 不带角色参数的调用（`/onboard`）走 Phase 2 的通用定向分支（`design/`、
  `docs/architecture/`、`production/` 与代码根目录的顶层，加上 `active.md`，
  并说明给出角色可让下一轮更聚焦）；未单独测试。
- `narrative`（`design/narrative/`）以及已有 `tests/` 目录的 QA 遵循与
  Case 1、Case 2 相同的分支模式，未单独测试。
- `modes.automation: autonomous`（记录后继续，而非询问）未在此测试。
