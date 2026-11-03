# Skill Test Spec: /skill-test

## Skill Summary

`/skill-test` 校验技能（`.trae/skills/*/SKILL.md`）与代理
（`.trae/agents/*.md`）。它有四种模式：

- **static** `[name | all]`：对技能运行 7 项结构检查（frontmatter、
  阶段、结论关键字、写前询问措辞、下一步交接、分叉
  复杂度、参数提示），并把每项报告为 PASS / WARN / FAIL。拆分为
  `references/` 文件的技能会被整体读取（`SKILL.md` 与每个 references 文件）以进行
  检查 2-5；frontmatter 检查（1、6、7）只读 `SKILL.md`。每个技能的结果为
  COMPLIANT、WARNINGS、NON-COMPLIANT 或 NOT ASSESSED。它还会运行
  `.trae/scripts/agent-check.sh`，把其中的代理与委派行作为
  从不改变结论的观察报告出来，并运行
  `.trae/scripts/trae-compat-check.sh`，按类别以同样方式报告文件仍然带有
  Trae 不会按 Claude Code 方式执行的构造；给定代理
  名称时，它只报告这些观察，不给结论。不写入任何内容。
- **spec** `[skill-or-agent-name]`：通过
  `studio-tests/catalog.yaml` 解析名称，读取文件与该条目 `spec:` 路径上的
  规格，以及 `AGENTS.md` 与其按路径引用的标准文件，
  并标记每条断言 —— 包括规格的 Static Assertions，技能
  与代理一视同仁 —— 为 PASS / PARTIAL / FAIL / NOT ASSESSED。用例结论与整体
  结论取其下最差的结果（FAIL、PARTIAL、NOT ASSESSED、
  PASS）。随后它询问 "May I write these results to
  `studio-tests/results/…` and update `catalog.yaml`?"
- **category** `[name | all]`：按 `studio-tests/quality-rubric.md` 中的对应章节
  为技能或代理评分（每个指标 PASS / FAIL / WARN），并在记录前
  询问 "May I update `catalog.yaml` …?"。
- **audit**（也是无参数时的默认）：列出每个技能与
  每个已编目代理的覆盖率表。不写入任何内容，也不给出结论。

不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论：COMPLIANT、WARNINGS、NON-COMPLIANT、NOT ASSESSED（static 模式）；PASS、PARTIAL、FAIL、NOT ASSESSED（spec 模式）
- [ ] 在写入 spec 结果前包含 "May I write"，在把 category 检查记录到 `catalog.yaml` 前包含 "May I update"
- [ ] 具备下一步交接（阶段 3：每种模式后的上下文相关后续）

---

## Director Gate Checks

无。`/skill-test` 是元工具技能。不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: Static Mode — Well-formed skill, all 7 checks pass, COMPLIANT

**Fixture:**
- `.trae/skills/brainstorm/SKILL.md` 存在且满足全部 7 项检查：
  - 具备全部 5 个必需 frontmatter 字段
  - 至少有 2 个阶段标题
  - 具备结论关键字
  - 具备 "May I write" 措辞
  - 以下一步交接结尾
  - 未设置 `context: fork`
  - `argument-hint` 与其 Parse Arguments 阶段记载的模式一致

**Input:** `/skill-test static brainstorm`

**Expected behavior:**
1. 技能完整读取 `.trae/skills/brainstorm/SKILL.md`
2. 技能运行全部 7 项结构检查
3. 输出为单技能区块 `=== Skill Static Check: /brainstorm ===`，
   列出 Check 1 – Check 7，每项均为 PASS
4. 结论为 COMPLIANT
5. 阶段 3 的后续建议 `/skill-test spec brainstorm`

**Assertions:**
- [ ] 恰好报告 7 项结构检查
- [ ] 全部 7 项标记为 PASS
- [ ] 结论为 COMPLIANT
- [ ] 不写入任何文件，也不询问 "May I write"

---

### Case 2: Static Mode — Skill Missing Ask-Before-Write Despite Write in Body

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 的 正文提到 `Write`
- 正文没有任何检查 4 可接受形式的写前询问措辞：
  没有 "May I write"，写入指令附近没有 "before writing"/"approval"，
  同一节中没有同时出现 "ask" 与 "write"

**Input:** `/skill-test static some-skill`

**Expected behavior:**
1. 技能读取 `some-skill/SKILL.md`
2. 检查 4（协作协议）为 FAIL —— 正文承诺写入，
   且未找到写前询问措辞
3. 其余六项检查各自列出结果
4. 结论为 NON-COMPLIANT，并附一行 Recommended 指出修复方式

**Assertions:**
- [ ] 检查 4 标记为 FAIL（不是 WARN —— 正文承诺写入）
- [ ] 检查 4 行或 Recommended 行指出不匹配（正文承诺写入却没有写前询问措辞）
- [ ] 结论为 NON-COMPLIANT
- [ ] 其他检查也被展示（不只是失败项）

---

### Case 3: Spec Mode — gate-check Skill Evaluated Against Its Spec

**Fixture:**
- `catalog.yaml` 在 `skills:` 下列出 `gate-check`，其
  `spec: studio-tests/skills/gate/gate-check.md`
- 沙箱中该规格的副本是现行版本（9 个测试用例与一份 Static
  Assertions 清单），但新增了一条 Static Assertion："Balance values link to
  their source formula or rationale" —— 仅由
  `.trae/docs/coding-standards.md`（被 `AGENTS.md` 导入）满足，而不由技能
  或其闸门文件本身满足。现行规格没有这一行，因此该副本为此用例做了修改
- `.trae/skills/gate-check/` 含 `SKILL.md` 与 12 个 `references/` 文件
  （6 个阶段文件、6 个闸门文件）
- 用户拒绝写入结果

**Input:** `/skill-test spec gate-check`

**Expected behavior:**
1. 技能通过 catalog 把 `gate-check` 解析为技能，并从其 `spec:` 字段取得规格
   路径
2. 技能读取该技能 —— `SKILL.md` 与全部 12 个 `references/` 文件 —— 以及
   规格、`AGENTS.md` 与其 `@` 导入的文件
3. 规格的 Static Assertions 在 Case 1 之前于一个
   `Static Assertions:` 区块中对照 `SKILL.md` 及其
   `references/` 文件接受检查
4. 每条断言标记为 PASS / PARTIAL / FAIL / NOT ASSESSED，每条非 PASS 都附
   Reason；balance-values 断言为 PASS，引用
   `coding-standards.md`
5. 每个用例得到 Case Verdict；报告以 Overall Verdict 结尾，即
   静态断言、用例与 Protocol Compliance 中的最差结果
6. 技能询问 "May I write these results to
   `studio-tests/results/skill-test-spec-gate-check-[date].md`
   and update `studio-tests/catalog.yaml`?"；若拒绝则不写入任何内容

**Assertions:**
- [ ] 规格路径来自 catalog 的 `spec:` 字段
- [ ] 规格的 Static Assertions 对照 `SKILL.md` 及其 `references/` 文件评估，而不当作 "static 模式的职责" 跳过
- [ ] 仅在 `references/` 文件中满足的断言为 PASS，不会因 `SKILL.md` 中缺失而判 FAIL
- [ ] 全部 9 个测试用例都被评估，每个都有各自的 Case Verdict
- [ ] balance-values 断言为 PASS，且报告引用 `coding-standards.md` 作为其来源文件
- [ ] 整体结论为最差结果 —— FAIL、PARTIAL、NOT ASSESSED 或 PASS；断言级的 NOT ASSESSED 会使其无法为 PASS
- [ ] 未经批准不写入任何文件（此处被拒绝，因此不写入任何内容）

---

### Case 4: Audit Mode — Coverage Table of All Skills and Agents

**Fixture:**
- `.trae/skills/` 含 74 个技能目录；73 个在其 catalog 条目指定的路径上有
  规格（在沙箱中，一个技能的 catalog `spec:` 被清空且其规格文件被移除 —— 现行
  每个技能都有规格）
- `catalog.yaml` 有一个 `agents:` 区块，含 49 个条目，全部都有规格

**Input:** `/skill-test audit`（以及另外单独的无参数 `/skill-test`）

**Expected behavior:**
1. 两种输入都运行 audit 模式 —— 无参数是 audit 默认行为，不是用法
   消息
2. 技能用 glob `.trae/skills/*/SKILL.md` 枚举技能，并读取 catalog 的
   `agents:` 区块获取代理
3. 对每个技能：Has Spec（来自 catalog `spec:` 路径，或在
   `studio-tests/skills/` 下 glob）、最近 static/category 日期与
   结果、category、priority
4. 分开的 SKILLS 与 AGENTS 表、Top 5 Priority Gaps 清单，以及
   `Skill coverage: 73/74 specs (99%)` 与 `Agent coverage: 49/49 specs (100%)` 行
5. 没有结论行；输出以运行 `static all`、
   `category all` 或 `spec [name]` 的提议结尾

**Assertions:**
- [ ] 无参数的 `/skill-test` 产出该 audit，而不是用法文本
- [ ] 枚举全部技能目录（不只是抽样）
- [ ] 每个条目的 "Has Spec" 列准确
- [ ] 技能与代理的摘要覆盖率计数正确
- [ ] audit 模式下不写入任何文件，也不给出结论

---

### Case 5: Category Mode — Gate Skill Evaluated Against Quality Rubric

**Fixture:**
- `studio-tests/quality-rubric.md` 有一个 `### gate` 章节，含
  指标 G1–G5
- `catalog.yaml` 给 `gate-check` 设定 `category: gate`
- `.trae/skills/gate-check/SKILL.md` 满足除 G2 外的每个指标 —— Director
  panel 宽度（`workflow: full` 下只派生 CD-PHASE-GATE）
- 用户批准 catalog 更新

**Input:** `/skill-test category gate-check`

**Expected behavior:**
1. 技能从 catalog 读取 `category:`，然后读取评分表的 `### gate` 章节
2. 技能读取该技能与 `AGENTS.md` 上下文，并评估 G1–G5
3. 每个指标标记为 PASS、FAIL 或 WARN；G2 为 FAIL 并附引用的 Gap 行
4. 报告以 `Verdict: FAIL (1 failure, 0 warnings)` 与一行 Fix 结尾
5. 技能询问 "May I update `studio-tests/catalog.yaml` to record
   this category check (`last_category`, `last_category_result`) for gate-check?"

**Assertions:**
- [ ] quality-rubric.md 中的全部 gate 指标（G1–G5）都被评估
- [ ] 每个指标都有各自的 PASS / FAIL / WARN 结果，G2 附 Gap 行
- [ ] 整体结论反映各指标结果
- [ ] 只有在 "May I update" 批准后才更新 catalog

---

### Case 6: Spec Mode — Agent Name Resolves to the Agent

**Fixture:**
- `catalog.yaml` 在 `agents:` 下列出 `creative-director`，其
  `spec: studio-tests/agents/directors/creative-director.md`
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
  `.trae/skills/creative-director/`
- 规格断言 "Model tier is `opus`"
- 假设一个规格用例是重定向：要求代理选择项目的
  引擎。代理的 "What This Agent Must NOT Do" 清单说 "Make engine or
  architecture choices (delegate to technical-director)"；它从不以自己的话
  重述该重定向

**Input:** `/skill-test spec creative-director`

**Expected behavior:**
1. 技能通过 catalog 的 `agents:` 区块解析名称 —— 它不会
   报告 "Skill 'creative-director' not found"
2. 技能读取代理文件与代理规格
3. 静态断言与 frontmatter 精确比较：例如 "tools includes
   Read" 对照 `tools: Read, Glob` 为 PASS，而对照
   `tools: Glob` 会为 FAIL（不是 PARTIAL）
4. 测试用例对照代理的指令评估；Protocol
   Compliance 使用规格自身的清单
5. 重定向用例满足：已加载的 `coordination-rules.md` 规则 2 覆盖
   它，且代理的 must-not 清单点名 technical-director —— 报告引用
   两者
6. 报告头部为 `=== Agent Spec Test: creative-director ===`

**Assertions:**
- [ ] 代理被解析并评估，而不会被当作缺失技能拒绝
- [ ] 字面值断言是精确比较（接近匹配 = FAIL）
- [ ] 每个用例与规格的 Protocol Compliance 清单都被评估
- [ ] 重定向用例依据 `coordination-rules.md` 加上代理自身的 must-not 清单通过，两者都被引用 —— 不要求代理重述它
- [ ] 未经批准不写入任何文件

---

### Case 7: Static All — an unreadable skill is NOT ASSESSED and counted

**Fixture:**
- `.trae/skills/` 含 74 个技能目录；有一个 `SKILL.md` 无法
  读取（Read 调用失败 —— 权限被拒），因此其检查均无法
  开始。（能读取但 frontmatter 无法解析的文件是
  另一种情况：检查 1 失败，结果为 NON-COMPLIANT。）

**Input:** `/skill-test static all`

**Expected behavior:**
1. 73 个可读技能被检查并列出其 Result
2. 不可读的技能在表中显示为 `NOT ASSESSED`，并附
   原因 —— 不被省略，不为 COMPLIANT
3. 头部说明分母，`73 of 74 skills checked`，且
   Summary 行计入该 NOT ASSESSED 技能

**Assertions:**
- [ ] 不可读技能的 Result 为 NOT ASSESSED，并附原因
- [ ] 头部或摘要显示 `73 of 74 skills checked`
- [ ] Summary 计数与表中的技能数一致

---

### Case 8: Spec Mode — an unevaluable assertion makes the run NOT ASSESSED

**Fixture:**
- `.trae/skills/brainstorm/SKILL.md` 及其规格存在
- 规格中除一条外所有断言都通过，该条点名了一个
  规格从未定义的夹具文件
- 用户批准写入结果

**Input:** `/skill-test spec brainstorm`

**Expected behavior:**
1. 该断言为 NOT ASSESSED，并附 Reason —— 绝不因技能
   "大概" 能处理而判为 PASS
2. 其 Case Verdict 为 NOT ASSESSED；由于任何地方都没有 PARTIAL 或 FAIL，
   Overall Verdict 为 NOT ASSESSED
3. 批准后，`catalog.yaml` 记录 `last_spec_result: NOT ASSESSED`

**Assertions:**
- [ ] 无法评估的断言为 NOT ASSESSED，不为 PASS
- [ ] Overall Verdict 为 NOT ASSESSED，不为 PASS
- [ ] catalog 记录 `NOT ASSESSED` 作为结果

---

### Case 9: Category Mode — no rubric section for the category

**Fixture:**
- `catalog.yaml` 给 `some-skill` 设定 `category: tooling` —— 该类别在
  其评分表章节写成之前就被加入 catalog
- `studio-tests/quality-rubric.md` 没有 `tooling` 章节

**Input:** `/skill-test category some-skill`

**Expected behavior:**
1. 技能读取该类别，然后查找其评分表章节，未找到
2. 结果为 NOT ASSESSED，并点名缺失的 `tooling` 章节
3. 不借用其他类别的指标来填补空缺 —— 连 `utility` 的也不借用

**Assertions:**
- [ ] 结果为 NOT ASSESSED，并点名缺失的评分表章节
- [ ] 不以任何其他类别的指标代替评估

---

### Case 10: Static Mode — a split skill is read whole, but its frontmatter comes from SKILL.md

**Fixture:**
- `.trae/skills/split-skill/SKILL.md` 具备全部五个 frontmatter 字段，没有
  `context:` 键，且有两个阶段标题（`## Phase 1: Gather`、`## Phase 2: Report`），
  各自说 "Read `references/N-name.md` now and follow it"。它本身没有结论
  关键字、没有写前询问措辞、也没有下一步交接
- `.trae/skills/split-skill/references/2-report.md` 含 `Verdict: **COMPLETE**`、
  一行 "May I write this report to `production/qa/report.md`?" 以及结尾的
  "Next step: `/gate-check`"；`references/1-gather.md` 只有指令
- 运行 A：如上。运行 B：同一技能，但 `argument-hint:` 从
  `SKILL.md` 中缺失，只出现在 `references/1-gather.md` 顶部的一个 frontmatter 风格区块中

**Input:** `/skill-test static split-skill`

**Expected behavior:**
1. 技能读取 `SKILL.md` 与 `references/` 中每个文件，并把它们作为一个技能运行 7 项检查
2. 运行 A：检查 2、3、4 与 5 读取整个技能，因此在 `references/2-report.md` 中找到的
   结论关键字、"May I write" 行与交接上为 PASS；检查 3 不会因 `SKILL.md` 中
   缺少结论词而判 FAIL。检查 1、6 与 7 读取 `SKILL.md` frontmatter：全部 PASS。结论 COMPLIANT
3. 运行 B：检查 1 只读取 `SKILL.md`，因此缺失的 `argument-hint:` 为 FAIL，
   尽管 references 文件中有；结论为 NON-COMPLIANT，并附
   `Recommended:` 行建议把它加到 `SKILL.md` frontmatter。检查 7 也不从
   references 文件取提示

**Assertions:**
- [ ] 运行 A：检查 3、4 与 5 对仅出现在 `references/` 中的文本为 PASS
- [ ] 运行 A：检查 3 不会因 `SKILL.md` 中缺少结论词而判 FAIL 或 WARN
- [ ] 运行 A：结论为 COMPLIANT，且不写入任何内容
- [ ] 运行 B：检查 1 为 FAIL —— 仅出现在 `references/` 文件中的 frontmatter 字段不计
- [ ] 运行 B：结论为 NON-COMPLIANT，且 `Recommended:` 行点名 `SKILL.md` frontmatter

---

## Protocol Compliance

- [ ] static 模式恰好检查 7 条结构断言
- [ ] static 模式对检查 2-5 一起读取拆分技能的 `SKILL.md` 与 `references/` 文件，对 frontmatter 检查（1、6、7）只读 `SKILL.md`
- [ ] spec 模式逐个评估规格文件中的每个测试用例，并把技能规格的 Static Assertions 对照 SKILL.md 及其 references/ 文件评估
- [ ] 每种模式都能报告 NOT ASSESSED —— static 模式按技能、spec 模式按断言与整体、category 模式对缺失的评分表章节
- [ ] audit 模式覆盖全部技能与代理（不只是某一类别）
- [ ] spec 与 category 模式同时接受代理名与技能名
- [ ] category 模式读取 quality-rubric.md 获取标准（不硬编码）
- [ ] static 与 audit 模式不写入任何内容；spec 与 category 模式只在 "May I write" / "May I update" 批准后写入
- [ ] spec FAIL 之后，建议审查失败断言并更新技能或代理，或规格

---

## Coverage Notes

- skill-test 技能是自引用的（它能测试自身）。针对 skill-test 自身 SKILL.md 的
  static 模式用例未单独做夹具测试，以避免测试设计中的
  无限递归。
- 具体的 7 项结构检查定义在技能正文中；此处只单独测试检查 4
  （写前询问），因为它的逻辑最微妙。单技能的 NOT ASSESSED 结论沿用 Case 7 的
  按技能规则；未单独测试。
- audit 模式的计数是近似值 —— 技能与代理的确切数量会
  随系统增长而变化；夹具中的数字仅作示例。
- 点名总监闸门 ID 的规格用例会让代理对照
  `.trae/docs/director-gates/[gate-id].md` 接受评估；未单独做夹具测试。
