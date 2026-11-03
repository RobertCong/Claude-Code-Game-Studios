# Skill Test Spec: /start

## Skill Summary

`/start` 是首次上手引导技能。Phase 1 使用 `project-state.sh` 读取项目但不打印内容（引擎、代码根目录与源文件、概念或简报、GDD、ADR、其他工作，以及 `origin` 是否仍指向模板仓库）；`source_files: unknown` 被报告为代码根目录未知，而绝不报告为没有代码。Phase 2 用四个选项询问用户当前所处的位置（A 还没有想法，B 模糊的想法，C 清晰的概念，D 已有工作）；此处不问引擎，由 `/setup-engine` 选择。

Phase 3 按回答进行路由，并且只给出紧接着的下一步。Phase 4 判定阶段（A/B/C：`Concept`；D：依据 GDD 与 ADR 数量）以及 rigor：若已设置 `modes.rigor` 则保留该值，否则根据用户所述内容推断（`settings-guidance.md` §3；没有信号或没有想法 → `minimal`）。它把两者展示在一张假设卡片上，卡片指明后续修改使用 `/settings`，并询问一个问题：`Save them` / `Don't save`。它不问 rigor 相关问题。只有明确的肯定才会写入：通过 `set-stage.sh` 写入阶段（`project.yaml` 与旧版镜像 `production/stage.txt`），并通过 `config-set.sh` 写入推断出的 rigor。Phase 5 在键未设置时询问自动化问题，并通过 `config-set.sh` 写入所选项。`/start` 从不写入 `modes.rigor` 所统领的六个旋钮中的任何一个（`modes.review_mode`、`modes.workflow`、`docs.density`、`qa.level`、`modes.story_granularity`、`team.size`），也不写入 `production/review-mode.txt`。

Phase 6 打印对应 rigor 的路径（包含 Path D 的已有工作路径；在 `minimal` 下，没有简报的 D 类用户会被告知简报从何而来），并询问先执行哪一步；Phase 7 只打印一行 "Type `[skill]` to begin."，不启动任何内容。回访用户（已设置引擎且存在概念或简报）跳过上手引导。不适用任何总监质量闸门。结论：COMPLETE。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查，无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 为每一次写入说明写入规则：阶段与推断出的 rigor 只在用户对保存问题明确回答是之后写入，且该问题需指明 `project.yaml` 与 `production/stage.txt`；`modes.automation` 按用户选择写入，且当保存被拒绝时绝不写入
- [ ] 结尾有下一步交接（Phase 7："Type `[skill]` to begin."）

---

## Director Gate Checks

无。`/start` 是实用型设置技能。在该技能运行的时间点上，尚不存在任何总监代理。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` §
Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — 全新仓库、Path A、rigor 为推断值

**Fixture:**
- 无 `project.yaml`、无 `production/stage.txt`；`technical-preferences.md` 仅含占位符（运行时不含 Fixture Defaults 块）
- 没有设计文档、原型或源代码；`origin` 是用户自己的仓库
- 用户依次选择 `A) No idea yet`、`Save them`、`Guided`

**Input:** `/start`

**Expected behavior:**
1. Phase 1 运行 `project-state.sh` 但不打印其各行内容
2. Phase 2 只提供 A–D 四个选项；不问引擎问题
3. Path A 只把 `/brainstorm open` 命名为下一步，完整路径留待之后
4. Phase 4 展示卡片：阶段 `Concept`、rigor `minimal` 及其原因（尚无概念），并请求将它们保存到 `project.yaml`、将阶段保存到 `production/stage.txt`；它不问 rigor 问题
5. 在 `Save them` 之后，`set-stage.sh Concept` 创建 `project.yaml` 并写入 `production/stage.txt`，`config-set.sh modes.rigor minimal` 添加 rigor
6. Phase 5 询问自动化问题；按所选项运行 `config-set.sh modes.automation guided`
7. Phase 6 打印 minimal 的 4 步路径（`/setup-engine`、`/brainstorm`、`/create-stories`、`/dev-story`）并询问先执行哪一步
8. Phase 7 只打印 "Type `[skill]` to begin."；Verdict COMPLETE

**Assertions:**
- [ ] Phase 2 只提供 A–D 四个选项，且没有引擎选择
- [ ] 不问 rigor 问题；推断出的 `minimal` 连同原因显示在卡片上
- [ ] 在明确的 `Save them` 之前不写入任何内容
- [ ] `project.stage` 与 `production/stage.txt` 均为 `Concept`
- [ ] `project.yaml` 最终只包含 `/start` 写入的 `project.stage`、`modes.rigor` 与 `modes.automation`：六个 rigor 旋钮一个都没有，也没有 `production/review-mode.txt`
- [ ] `project.yaml` 恰好有一个 `modes:` 块，包含 `rigor` 与 `automation`
- [ ] Phase 6 打印 minimal 的 4 步路径
- [ ] 不启动下一个技能；结论为 COMPLETE

---

### Case 2: Returning User — 跳过上手引导

**Fixture:**
- `project.yaml` 含 `engine.name: Godot` 与 `modes.rigor: minimal`；没有显式的 `modes.review_mode`
- `design/game-brief.md` 存在

**Input:** `/start`

**Expected behavior:**
1. Phase 1 发现引擎已设置且简报已存在
2. 技能跳过上手引导，并指明引擎（Godot）与简报
3. 评审模式被报告为 `solo`（源自 `modes.rigor: minimal`）
4. 技能指向 `/help`

**Assertions:**
- [ ] 不问 A–D 起点问题
- [ ] 消息指明已配置的引擎（Godot）与简报路径
- [ ] 评审模式被报告为 `solo`，由 rigor 解析得出
- [ ] 不对 `project.yaml` 或 `production/stage.txt` 做任何写入

---

### Case 3: Existing Work on Unity — Path D、阶段由文件推断、rigor 已设置

**Fixture:**
- `project.yaml` 含 `engine.name: Unity`、`modes.rigor: standard` 与
  `modes.automation: collaborative`
- `Assets/Scripts/` 下存在 C# 脚本；`design/gdd/` 含 3 份系统 GDD；
  没有 `design/gdd/game-concept.md`，也没有 `docs/architecture/`
- 用户选择 `D) Existing work` 与 `Save them`

**Input:** `/start`

**Expected behavior:**
1. Phase 1 解析出代码根目录为 `Assets/` 并在那里找到源文件（它不会扫描 `src/` 然后断定没有代码）
2. Phase 3 的 D 分支说明其发现（源文件、3 份 GDD、引擎 Unity），并把 `/project-stage-detect` 命名为紧接的步骤
3. Phase 4 的卡片显示阶段 `Systems Design`（有 GDD，无 ADR），rigor 为已设置的 `standard`
4. 在用户回答是之后，`set-stage.sh "Systems Design"` 写入两个文件；不写入 rigor
5. Phase 5 说明 "Automation is `collaborative`"，不再提问
6. Phase 6 打印 `standard` 下的已有工作路径：`/project-stage-detect`、
   `/adopt`、`/design-system retrofit`、`/architecture-decision retrofit`、
   `/architecture-review`、`/gate-check`

**Assertions:**
- [ ] 源文件在 `Assets/` 下被发现，而不是被报告为不存在
- [ ] 阶段 `Systems Design` 在用户回答是之后写入 `project.yaml` 与 `production/stage.txt` 两个文件
- [ ] 不问 rigor 或自动化问题，且两个键都不会被重写
- [ ] `standard` 下的已有工作路径包含 GDD、ADR 与注册表回填步骤
- [ ] 结论为 COMPLETE

---

### Case 4: Clone Still Wired to the Template Repo — 远程提示、绝不执行

**Fixture:**
- 与 Case 1 相同的全新项目
- `.git/config` 含 `[remote "origin"]`，其 url 为
  `https://github.com/Donchitos/Claude-Code-Game-Studios.git`
- 用户选择 `B) Vague idea`，提示为 "a small weekend puzzler"，随后选择 `Save them`

**Input:** `/start`

**Expected behavior:**
1. `origin_url` 以不区分大小写的方式匹配模板仓库
2. Path B 把 `/brainstorm a small weekend puzzler` 命名为紧接的步骤
3. 卡片根据 "weekend" 与 "small" 推断 rigor 为 `minimal`
4. 在 Phase 6 的路径之后，技能追加一次说明：`origin` 仍指向 CCGS 模板仓库，建议先执行 `git remote rename origin template` 再执行 `git remote add origin <your repo URL>`，并说明应跳过 `UPGRADING.md` 自带的 `git remote add template` 步骤，因为该远程现在已存在
5. 这些命令仅为建议；不执行任何 git 命令

**Assertions:**
- [ ] 模板起点提示恰好出现一次，且位于路径之后
- [ ] 两条建议命令与上文所述完全一致
- [ ] 提示说明在重命名之后应跳过 `UPGRADING.md` 的 `git remote add template` 步骤，并说明原因
- [ ] 不执行任何 git 命令
- [ ] 卡片的 rigor 为 `minimal`，并以用户的原话作为原因

---

### Case 5: Director Gate Check — 无闸门；start 是实用型设置技能

**Fixture:**
- 全新项目，回答同 Case 1

**Input:** `/start`

**Expected behavior:**
1. 技能完成从 Phase 1 到 Phase 7 的上手引导流程
2. 不向任何总监代理交接工作
3. 输出中不出现任何闸门 ID（CD-*、TD-*、AD-*、PR-*）

**Assertions:**
- [ ] 不运行任何总监闸门
- [ ] 不出现闸门跳过消息（闸门本就不存在，而非被抑制）
- [ ] 技能在没有任何闸门结论的情况下到达 COMPLETE

---

### Case 6: Path D With Rigor Unset — 由描述推断，而非提问

**Fixture:**
- `project.yaml` 含 `engine.name: Godot`，且没有 `modes` 块
- `src/` 含 GDScript 文件；`design/gdd/` 含 4 份系统 GDD；没有
  `docs/architecture/`
- 用户选择 `D) Existing work` 并说 "a commercial game for Steam with
  one clear core loop"，随后选择 `Save them`，再选择 `Collaborative`

**Input:** `/start`

**Expected behavior:**
1. Phase 3 的 D 分支把 `/project-stage-detect` 命名为紧接的步骤，且此时不打印分层路径
2. 卡片显示阶段 `Systems Design` 与 rigor `standard`，以用户的原话（"commercial"、"Steam"）作为原因，并有一行指明 `/settings`
3. 保存问题只提供 `Save them` / `Don't save`；不问 rigor 问题
4. 在 `Save them` 之后，`modes.rigor: standard` 与阶段一同写入
5. Phase 6 打印 `standard` 下的已有工作路径，包含
   `/design-system retrofit`、`/architecture-decision retrofit` 与
   `/architecture-review`

**Assertions:**
- [ ] 在 rigor 未知之前不打印分层路径
- [ ] 不问 rigor 问题；卡片指明 `/settings` 作为修改途径
- [ ] 写入的 rigor 为推断出的 `standard`
- [ ] 六个 rigor 旋钮中的任何一个都不写入；文件只含一个 `modes:` 块

---

### Case 7: Existing `modes:` Block — rigor 与 automation 写入其中，绝不新建第二个

**Fixture:**
- `project.yaml` 含 `engine.name: Godot`，并已有一个 `modes:` 块，其下只有
  `review_mode: lean`；`modes.rigor` 与 `modes.automation` 未设置（运行时不含
  Fixture Defaults 块，因为本用例测试这些键如何被添加）
- 没有 `design/game-brief.md`，也没有概念，因此这不是回访用户
- 用户依次选择 `A) No idea yet`、`Save them`、`Guided`

**Input:** `/start`

**Expected behavior:**
1. `set-stage.sh Concept` 在已有文件中添加 `project:` 块
2. `config-set.sh modes.rigor minimal` 与 `config-set.sh modes.automation guided`
   在已有的 `modes:` 块下添加这两个键
3. `review_mode: lean` 保持用户原有设置不变

**Assertions:**
- [ ] 最终的 `project.yaml` 恰好只有一个 `modes:` 键，包含 `review_mode`、`rigor` 与 `automation`
- [ ] 已有的 `review_mode: lean` 未被改动，且 `/start` 不写入其他任何 rigor 旋钮
- [ ] 阶段与 rigor 只有一个保存问题，自动化选择无需再次询问

---

### Case 8: Path D at `minimal` With No Brief — 指明简报从何而来

**Fixture:**
- `project.yaml` 含 `engine.name: Godot`、`modes.rigor: minimal` 与
  `modes.automation: collaborative`
- `src/` 含 14 个 GDScript 文件；`design/gdd/` 含 2 份系统 GDD；没有
  `docs/architecture/`；没有 `design/game-brief.md`，也没有
  `design/gdd/game-concept.md`
- 用户选择 `D) Existing work` 与 `Save them`

**Input:** `/start`

**Expected behavior:**
1. Phase 1 发现引擎已设置，但没有概念或简报，因此提出 A–D 问题
2. Phase 3 的 D 分支把 `/project-stage-detect` 命名为紧接的步骤
3. 卡片显示 `Systems Design` 与已设置的 rigor `minimal`；Phase 5 不再提问
4. Phase 6 打印 `minimal` 下的已有工作路径：`/project-stage-detect`、
   `/adopt`，然后是简报的来源，不含 GDD、ADR 或注册表回填
5. 在没有简报且源文件达到 10 个或更多时，简报的来源为
   `/reverse-document design src/`；不把 `/brainstorm` 提供为来源

**Assertions:**
- [ ] minimal 路径列出 `/project-stage-detect` 与 `/adopt`，且不含 `/design-system retrofit`、`/architecture-decision retrofit` 或 `/architecture-review`
- [ ] 没有 `design/game-brief.md` 时，路径把 `/reverse-document design src/` 命名为简报的来源，并填入代码根目录
- [ ] 不把 `/brainstorm` 命名为简报的来源
- [ ] 变体——`src/` 只有 4 个源文件：简报的来源为 `/brainstorm`，且不指明 `/reverse-document`
- [ ] 变体——`design/game-brief.md` 存在：此时为回访用户跳过

---

## Protocol Compliance

- [ ] 在第一个问题之前用 `project-state.sh` 读取项目，且不打印内容
- [ ] 用 A–D 选项提出起点问题；把引擎留给 `/setup-engine`
- [ ] 绝不写入六个 rigor 旋钮中的任何一个（`modes.review_mode`、`modes.workflow`、`docs.density`、`qa.level`、`modes.story_granularity`、`team.size`），也不写入 `production/review-mode.txt`
- [ ] 在卡片上展示阶段与 rigor，仅在明确回答是时写入；不问 rigor 问题
- [ ] 当键已设置时跳过自动化问题
- [ ] 通过 `set-stage.sh` 与 `config-set.sh` 写入，绝不手工编辑 YAML
- [ ] 只在 Phase 6 中、rigor 已知之后打印已有工作路径
- [ ] 绝不启动下一个技能；一次完成的运行（不含以 `/help` 指引结束的回访用户跳过）以 "Type `[skill]` to begin." 与 Verdict COMPLETE 结束

---

## Coverage Notes

- Path C（清晰概念，`Formalize it first` 对比 `Jump straight in`）未单独测试。
- 新游戏的 `standard` 与 `full` 路径遵循 Case 1，只是流水线更长；未单独测试。
- 边界情况 "picks D but project is empty" / "picks A but code exists" 未单独测试。
- `Don't save`（不写入任何内容，值仅保留用于本次运行并报告为未保存，且不写入自动化）未单独测试。
