# Skill Test Spec: /skill-improve

## Skill Summary

`/skill-improve [skill-name]` 对单个技能运行一轮 测试 → 修复 → 重测 → 保留或回退
循环。它用 `/skill-test static [name]` 记录静态基线
（FAIL 与 WARN 计数，以及检查 1–7 中哪些失败），然后当技能在
`studio-tests/catalog.yaml` 中有 `category:` 时，用 `/skill-test category [name]` 记录
类别基线。如果两个基线都干净，它以 "No improvements needed." 停止。否则它展示
诊断、提出前后对比的修复、询问 "May I write this improved
version to `.trae/skills/[name]/SKILL.md`?"（同时点名修复所改动的每个
`references/` 文件 —— 某个阶段的修复写在其 `references/` 文件中）、写入、
重新运行相同的测试，
并展示每个维度的 前 → 后 对比，外加一行合并行
（`Combined: 3 → 0 (improved)`）。

阶段 6 比较合并计数（静态 FAIL + 类别 FAIL + 静态
WARN + 类别 WARN）。低于基线 → "Score improved. Changes kept."
相同或更差 → "Combined score did not improve."，随后询问 "May I restore
`.trae/skills/[name]/SKILL.md` to the content it had before this run?"（点名阶段 5 写入的每个文件）——
回退仅在回答 yes 时运行，并写回阶段 5 记录的副本（绝不用
`git checkout`，那也会丢弃此前未提交的编辑）。不适用任何总监闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 阶段 6 同时说明两种结果："Score improved. Changes kept." 与 "Combined score did not improve."
- [ ] 在应用修复之前包含 "May I write" 协作协议措辞
- [ ] 具备下一步交接（阶段 7：`/skill-test static all`、`/skill-improve [next-name]`、`/skill-test audit`）

---

## Director Gate Checks

无。`/skill-improve` 是元工具技能。不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Check 4 FAIL and Check 5 WARN fixed, changes kept

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 的 正文提到 `Write`，但没有
  写前询问措辞（检查 4 FAIL），也没有下一步章节（检查 5 WARN）
- catalog 给 `some-skill` 设定 `category: utility`；其类别基线为
  1 个 FAIL（U1，因为静态检查失败）
- 用户批准写入；重测在两个维度上都干净

**Input:** `/skill-improve some-skill`

**Expected behavior:**
1. 显示静态基线："Static baseline: 1 failures, 1 warnings"，并附
   "Failing: Check 4 (no ask-before-write), Check 5 (no handoff)"
2. 显示类别基线："Category baseline: 1 failures, 0 warnings (utility rubric)"
3. 在提出任何改动之前展示完整诊断
4. 只为失败部分提出前/后区块；技能询问
   "May I write this improved version to `.trae/skills/some-skill/SKILL.md`?"
5. 写入文件；重新运行两项测试；对比显示
   `Static: Before 1 failures, 1 warnings → After 0 failures, 0 warnings`、类别行
   以及一行合并行 `Combined: 3 → 0 (improved)`
6. 输出 "Score improved. Changes kept." 并附各维度摘要

**Assertions:**
- [ ] 在提出任何改动之前显示静态与类别基线
- [ ] 提出的修复中诊断并处理检查 4 与检查 5 二者
- [ ] 在写入文件之前询问 "May I write"
- [ ] 两个维度都展示 前 → 后 对比，外加单行 `Combined: 3 → 0 (improved)`
- [ ] 结果为 "Score improved. Changes kept."

---

### Case 2: Fix Causes Regression — revert offered, runs only on yes

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 的静态基线为 0 个 FAIL、
  1 个 WARN（检查 5，无交接）
- 应用的修复新增了交接，但删除了承载结论
  关键字与写前询问行的章节：静态重测显示 2 个 FAIL
  （检查 3 与 4），类别结果也不优于基线 ——
  合并计数上升
- 用户批准写入，随后对回退回答 yes

**Input:** `/skill-improve some-skill`

**Expected behavior:**
1. 记录基线；提出修复；批准 "May I write …"；写入文件
2. 重测对比的合并行显示 `Combined: [before] → [after] (worse)`，
   其中 after 计数更高；after 数字是重新运行
   `/skill-test static some-skill` 测得的结果，而不是该编辑本意要
   达成的结果（新增的交接不会被计为清除检查 5，除非
   重测如此说明）
3. 技能报告 "Combined score did not improve."，并展示变更内容与
   它为何可能没有帮助
4. 技能询问 "May I restore `.trae/skills/some-skill/SKILL.md` to the content it had before this run?"
5. 回答 yes 时：用 Write 写回阶段 5 的副本 —— 不运行 `git checkout`

**Assertions:**
- [ ] 在定稿之前将重测合并计数与基线比较
- [ ] 更高的合并计数走 "did not improve" 分支
- [ ] after 分数来自重新运行 `/skill-test static`，绝不由编辑内容声称：重测在记录中可见，且显示的 after 计数与其结果一致（2 个 FAIL），而不是该编辑瞄准的 0 个 FAIL
- [ ] 回退是询问所得，不是自动执行
- [ ] 只有在用户回答 yes 之后，才从记录的副本恢复文件 —— 绝不通过 `git checkout`
- [ ] 不报告 "Score improved. Changes kept."

---

### Case 3: Gate Skill — combined static + category baseline

**Fixture:**
- 现行 `gate-check` 技能的沙箱副本（其 `SKILL.md` 与全部 12 个
  `references/` 文件），植入三个缺陷 —— 现行技能是干净的，
  因此本用例从不依赖其当前状态：
  - `SKILL.md` frontmatter 没有 `argument-hint:` 行（静态检查 1 FAIL）
  - `references/4-assessment.md` 没有 "Name the omissions in the output"
    段落（G2 FAIL —— 窄面板不再点名谁被遗漏）
  - `references/4-assessment.md` 的 `solo` 条目被改为 "run the
    panel"（G4 FAIL —— solo 模式下会派生总监）
- G2 与 G4 是 `studio-tests/quality-rubric.md` 中的 `### gate` 指标
- catalog 给 `gate-check` 设定 `category: gate`；用户批准写入，且
  重测在两个维度上都干净

**Input:** `/skill-improve gate-check`

**Expected behavior:**
1. 静态基线与类别基线（`gate rubric`）均被记录
2. 诊断点名静态检查与两个 G 指标，并给出各自确切的文本缺口
3. 检查 1 的修复写在 `SKILL.md`；G2 与 G4 的修复写在
   `references/4-assessment.md`，而不是放回 `SKILL.md`
4. 写入询问点名两个文件："May I write this improved version to
   `.trae/skills/gate-check/SKILL.md` and `.trae/skills/gate-check/references/4-assessment.md`?"
5. 重新运行 `/skill-test static gate-check` 与 `/skill-test category gate-check`
6. 对比以 `Combined: 3 → 0 (improved)` 结尾："Score improved. Changes kept."

**Assertions:**
- [ ] 基线中同时捕获静态与类别分数
- [ ] 阶段 6 比较的是合并计数（两个维度的 FAIL + WARN）
- [ ] 3 个失败都在提出的修复中得到处理
- [ ] 每个修复都落在承载失败文本的文件中 —— 阶段修复落在 `references/4-assessment.md`
- [ ] 写入询问点名修复改动的每个文件，而不只是 `SKILL.md`
- [ ] 写入后重新运行两种测试
- [ ] 结果为 "Score improved. Changes kept."，并附合并前/后

---

### Case 4: Skill Already Clean — No improvements needed

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 为使本用例通过而编写，通过全部 7 项
  静态检查且无 WARN：五个 frontmatter 字段、一个与其记载模式一致的 `argument-hint`、
  三个 `## Phase N` 标题、一个 `PASS` /
  `FAIL` 结论、正文承诺写入并附前置 "May I write"、
  一个点名 `/skill-test` 的结尾下一步章节，且无 `context: fork`
- catalog 给 `some-skill` 设定 `category: utility`；U1 与 U2 均通过
- 专门编写的技能，而非 `brainstorm` 之类的现行技能：现行技能今天是否干净
  只能通过运行 `/skill-test` 得知，因此它不能
  作为固定夹具

**Input:** `/skill-improve some-skill`

**Expected behavior:**
1. 静态基线 0/0 → 继续到类别基线（不是立即停止）
2. 类别基线 0/0（utility rubric）
3. 技能停止："This skill already passes all static and category checks. No improvements needed."
4. 无诊断、无提出改动、无 "May I write"、不修改文件

**Assertions:**
- [ ] 在停止之前运行类别基线（仅静态结果干净不会停止）
- [ ] 显示 "No improvements needed" 消息
- [ ] 不提出任何改动
- [ ] 不询问 "May I write"，也不修改任何文件

---

### Case 5: Director Gate Check — No gate; skill-improve is a meta utility

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 至少 1 个静态失败；用户
  批准写入

**Input:** `/skill-improve some-skill`

**Expected behavior:**
1. 技能运行 测试-修复-重测 循环
2. 不派生总监代理
3. 输出中不出现闸门 ID

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 运行以阶段 6 两种结果消息之一结束 —— 没有闸门结论

---

### Case 6: Equal Score — "no change" does not keep the fix as an improvement

**Fixture:**
- `.trae/skills/some-skill/SKILL.md` 的静态基线为 0 个 FAIL、
  1 个 WARN（检查 7，参数提示与记载的模式不一致）
- catalog 未给 `some-skill` 设定 `category:`，因此跳过类别检查
- 应用的修复纠正了提示，但删除了结尾下一步章节：
  重测显示 0 个 FAIL、1 个 WARN（检查 5）
- 用户批准写入，随后对恢复回答 no

**Input:** `/skill-improve some-skill`

**Expected behavior:**
1. 显示 "Category: not yet assigned — skipping category checks."
2. 对比的合并行显示 `Combined: 1 → 1 (no change)`
3. 相等计数走 "did not improve" 分支："Combined score did not
   improve."，随后 "May I restore `.trae/skills/some-skill/SKILL.md` to the
   content it had before this run?"
4. 回答 no 时，文件保持写入后的样子，不恢复任何内容

**Assertions:**
- [ ] 相等的合并计数被视为 "did not improve"，而非改进
- [ ] 合并行显示 `Combined: 1 → 1 (no change)`
- [ ] 不报告 "Score improved. Changes kept."
- [ ] 会询问回退，拒绝则保留已写入的文件

---

### Case 7: Split Skill Regression — every file named, recorded and restored

**Fixture:**
- 专门编写的技能 `.trae/skills/split-skill/`，含 `SKILL.md` 与
  `references/` 中的两个文件：`1-gather.md` 与 `2-report.md`。`references/`
  文件承载各阶段步骤；`SKILL.md` 承载 frontmatter 与
  阶段清单
- 静态基线：0 个 FAIL、2 个 WARN —— `SKILL.md` 中的检查 7
  （`argument-hint` 与记载的模式不一致）以及 `references/2-report.md` 中的检查 5
  （结尾阶段没有下一步章节）。结论关键字与 "May I write" 行
  都在 `references/2-report.md` 中
- catalog 未给 `split-skill` 设定 `category:`，因此跳过类别检查
- 修复改动 `SKILL.md`（提示）与 `references/2-report.md`，但
  `2-report.md` 的重写删除了其结论行与 "May I write"
  行，只新增一个裸的 "Next steps" 标题：重测显示 2 个 FAIL
  （检查 3 与 4）与 1 个 WARN（检查 5），因此合并计数从 2 升到 3
- 修复不改变 `references/1-gather.md`
- 用户批准写入，随后对恢复回答 yes

**Input:** `/skill-improve split-skill`

**Expected behavior:**
1. 阶段 3 在诊断之前读取 `SKILL.md` 与 `references/` 中的每个文件（`1-gather.md` 与
   `2-report.md`）
2. 诊断点名每个缺口所在文件：`SKILL.md` 中的检查 7、
   `references/2-report.md` 中的检查 5
3. 提出的修复把提示改动放入 `SKILL.md`，把结尾阶段
   改动放入 `references/2-report.md`；写入询问点名两个文件，
   而不点名 `1-gather.md`
4. 写入前记录两个被改动文件的当前文本；随后两者
   都被写入
5. 重新运行测量新分数；对比以
   `Combined: 2 → 3 (worse)` 结尾，技能报告 "Combined score did not improve."
6. 恢复询问点名阶段 5 写入的每个文件："May I restore
   `.trae/skills/split-skill/SKILL.md` and
   `.trae/skills/split-skill/references/2-report.md` to the content they had
   before this run?"
7. 回答 yes 时：用 Write 写回每个文件记录的文本；不用
   `git checkout`；不触碰 `1-gather.md`

**Assertions:**
- [ ] 诊断时读取两个 `references/` 文件，而不只是 `SKILL.md`
- [ ] 每个诊断出的缺口都点名其所在文件（检查 7 在 `SKILL.md`，检查 5 在 `references/2-report.md`）
- [ ] 阶段修复写入 `references/2-report.md`，而不是折回 `SKILL.md`
- [ ] 在首次写入之前记录修复所改动每个文件的文本：`SKILL.md` 与 `references/2-report.md` 两者
- [ ] after 分数来自重新运行 `/skill-test static split-skill`，而非编辑的本意
- [ ] 恢复询问点名本次运行写入的两个文件，而不点名 `references/1-gather.md`
- [ ] 回答 yes 后，两个文件恰好保持其运行前文本，且 `references/1-gather.md` 从未被写入
- [ ] 恢复使用记录的副本，绝不使用 `git checkout`

---

## Protocol Compliance

- [ ] 始终在提出任何改动之前建立基线
- [ ] 在请求写入之前展示完整诊断，然后展示前/后区块
- [ ] 在应用任何修复之前询问 "May I write"
- [ ] 通过把重测合并计数与基线比较来检测未改进 —— 相等计数即未改进
- [ ] 在各维度行旁展示一行合并 前 → 后，例如 `Combined: 3 → 0 (improved)`
- [ ] 回退前询问用户确认（不是自动执行）
- [ ] 以 "Score improved. Changes kept." 或 "Combined score did not improve." 结尾 —— 或更早以 "No improvements needed." / 拒绝写入停止

---

## Coverage Notes

- 每次调用一个 修复-重测 循环；再次处理需要新的 `/skill-improve` 运行。
- 行为（spec 模式）结果不属于该循环 —— 只有静态与
  类别分数属于。
- 阶段 1 的停止情形 —— 无参数时输出用法文本、不存在 `SKILL.md` 时输出
  "Skill '[name]' not found." —— 以及阶段 4 中用户拒绝写入，
  均未单独做夹具测试。
