# Skill Test Spec: /bug-report

## Skill Summary

`/bug-report` 有四种模式，由参数选择：纯描述（**Description Mode**）、`analyze [path]`（**Analyze Mode**——读取代码并报告潜在缺陷）、`verify [BUG-ID]`（**Verify Mode**）和 `close [BUG-ID]`（**Close Mode**）。无参数时，它先询问缺陷描述。

Description Mode 解析描述，用 Grep/Glob 搜索代码库中相关文件，并起草报告模板：Title、ID `BUG-[NNNN]`、Severity 采用 `S1-Critical / S2-High / S3-Medium / S4-Low` 量表、Priority 采用 `P1-Fix this sprint / P2-Fix soon / P3-Backlog / P4-Won't fix` 阶梯（必须与 `/bug-triage` 一致）、Status `Open`、Classification（Category、System、Frequency、Regression——对于跨系统缺陷，`System` 是代码必须变更的那个系统）、Environment（Build、Platform、Scene/Level）、带 Expected 和 Actual Result 的 Reproduction Steps，以及 Technical Context（可能受影响的文件、相关系统）。它展示报告并询问 "May I write this to `production/qa/bugs/BUG-[NNNN].md`?"——写入后为 `Verdict: **COMPLETE**`，被拒绝时为 `Verdict: **BLOCKED**`。ID 为现有最大编号加一；一次运行中生成多个报告（Analyze Mode）会使用连续 ID，一次询问会指明所有文件。下一步：`/bug-triage`，S1/S2 用 `/hotfix [BUG-ID]`。不使用任何总监闸门。

Verify 和 Close Mode 按编号查找缺陷文件，无论其补零形式如何——包括带 slug 的旧式三位数文件。Verify 使用 `project.yaml` 中的 `commands.test` 运行相关测试（绝不凭记忆写运行器命令行）。当没有测试运行——没有测试覆盖该缺陷、`commands.test` 未设置或运行未完成——或缺陷为 Visual 或 UI 时，它会询问用户是否复现了步骤：`[No longer occurs]` → VERIFIED FIXED，记录为针对该构建的人工验证；`[Still occurs]` → STILL PRESENT；`[Not played yet]` → CANNOT VERIFY。它在设置 Status 前询问 "May I update"；只有 `Verified Fixed` 的缺陷才能关闭，Close Mode 会展示关闭记录并在写入任何内容前询问。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED（以及 Verify Mode 的 VERIFIED FIXED / STILL PRESENT / CANNOT VERIFY）
- [ ] 在写入报告前包含 "May I write" 用语，在更改现有缺陷文件前包含 "May I update"
- [ ] 具备下一步交接（`/bug-triage`；S1/S2 用 `/hotfix [BUG-ID]`；`/bug-report verify` → `close`）

---

## Director Gate Checks

无。`/bug-report` 是一个运维文档技能。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 用户描述崩溃，生成完整报告

**Fixture:**
- `production/qa/bugs/` 尚不存在
- 代码根目录包含一个首领竞技场场景脚本

**Input:** `/bug-report The game crashes to desktop every time the player enters the boss arena — progress is blocked`

**Expected behavior:**
1. Description Mode（无关键词）
2. 技能解析描述并 grep 代码库中的首领竞技场文件
3. 起草报告模板：Category `Crash`、Severity `S1-Critical`、
   Status `Open`、复现步骤、Expected Result（无崩溃）和 Actual
   Result（崩溃到桌面）、根据搜索得到的可能受影响文件
4. glob `production/qa/bugs/BUG-*.md`，未找到任何文件，分配 `BUG-0001`，展示
   报告并询问 "May I write this to `production/qa/bugs/BUG-0001.md`?"
5. 获批后写入文件，并创建 `production/qa/bugs/`；结论为 COMPLETE
6. 下一步：`/bug-triage`，以及因为缺陷为 S1 而使用 `/hotfix [BUG-ID]`

**Assertions:**
- [ ] 报告包含 Title、ID、Severity、Priority、Status、Category、System、Build、Reproduction Steps、Expected Result 和 Actual Result
- [ ] Severity 使用 S1–S4 量表（此处为 `S1-Critical`），Priority 使用 P1–P4 标签
- [ ] "Likely affected files" 根据代码库搜索填写
- [ ] "May I write" 指明 `production/qa/bugs/BUG-0001.md`——尚不存在任何缺陷文件
- [ ] 变体——若已存在 `BUG-0001.md` 和 `BUG-0003.md`，新 ID 为
      `BUG-0004`：现有最大编号加一，而不是文件数量加一
- [ ] 写入后结论为 COMPLETE
- [ ] 因为严重程度为 S1，建议使用 `/hotfix [BUG-ID]`

---

### Case 2: 无参数 — 起草前先询问描述

**Fixture:**
- 没有现有缺陷报告

**Input:** `/bug-report`

**Expected behavior:**
1. 无参数 → 技能在继续之前询问用户缺陷描述
2. 在收到描述之前，不起草任何模板，也不写入任何内容
3. 用户回答后（"Sometimes the audio cuts out"），Description Mode 继续；
   未知值（例如 Build、Frequency）保留在草稿中可见，由用户更正
4. 创建文件前询问 "May I write"

**Assertions:**
- [ ] 技能询问描述，而不是凭空起草
- [ ] 在给出描述之前不起草或写入任何报告
- [ ] 写入之前进行 "May I write" 询问
- [ ] 仅在文件写入后结论为 COMPLETE

---

### Case 3: Close Mode — 尚未验证的缺陷被拒绝关闭

**Fixture:**
- `production/qa/bugs/BUG-0007.md` 存在，`**Status**: Open`

**Input:** `/bug-report close BUG-0007`

**Expected behavior:**
1. Close Mode 读取 `production/qa/bugs/BUG-0007.md`
2. Status 不是 `Verified Fixed`，因此技能停止：
   "Bug BUG-0007 must be Verified Fixed before it can be closed. Run `/bug-report verify BUG-0007` first."
3. 不追加 Closure Record，Status 字段也不改变

**Assertions:**
- [ ] 显示 "must be Verified Fixed before it can be closed" 消息
- [ ] 指明 `/bug-report verify BUG-0007` 为下一步
- [ ] 不写入 Closure Record，也不编辑 `BUG-0007.md`
- [ ] 不发出 "May I update" 询问（没有可更新的内容）

---

### Case 4: 多系统缺陷 — 一份报告，主系统与相关系统

**Fixture:**
- 没有现有报告
- 代码根目录有一个存档管理器和一关卡完成 UI 界面

**Input:** `/bug-report After finishing a level, the save system freezes and the UI doesn't show the completion screen`

**Expected behavior:**
1. Description Mode 起草 **一份** 报告
2. Classification 的 `System` 指明存档系统——其冻结才是必须
   修复的问题，完成界面缺失是它的后果；Technical Context
   的 "Related systems" 列出 UI；"Likely affected files" 根据代码库搜索列出两者
   相关文件
3. 技能为一份 `BUG-[NNNN].md` 只询问一次 "May I write"
4. 写入后结论为 COMPLETE

**Assertions:**
- [ ] 只创建一份报告（不是每个系统一份）
- [ ] `System` 为存档系统，即代码必须变更的那个；UI 位于 Related systems 下
- [ ] Likely affected files 覆盖两个系统
- [ ] 结论为 COMPLETE

---

### Case 5: 总监闸门检查 — Analyze Mode，无闸门

**Fixture:**
- 存在 `src/save/save_manager.gd`，其中包含未防护的空引用解引用和未关闭的文件句柄
- `production/qa/bugs/` 中有 `BUG-0011.md`（现有最大编号）

**Input:** `/bug-report analyze src/save/save_manager.gd`

**Expected behavior:**
1. Analyze Mode 读取目标文件
2. 识别潜在缺陷（空引用、资源泄漏），并为每个缺陷起草一份报告，
   包含触发场景和建议修复
3. 分配连续 ID `BUG-0012` 和 `BUG-0013`，每份报告一个
4. 展示报告并询问一次，指明两个文件："May I write these to
   `production/qa/bugs/BUG-0012.md`, `production/qa/bugs/BUG-0013.md`?"
5. 不生成任何总监代理；不出现闸门 ID

**Assertions:**
- [ ] 每个潜在缺陷一份报告，各自包含触发场景和建议修复
- [ ] 两份报告获得不同且连续的 ID（`BUG-0012`、`BUG-0013`）——绝不复用同一 ID
- [ ] 单次 "May I write" 询问在保存任何报告前指明所有文件
- [ ] 未调用任何总监闸门，也不出现闸门跳过消息
- [ ] 若用户拒绝，结论为 BLOCKED，且不写入任何内容

---

### Case 6: Verify Mode — 按编号找到旧式三位数文件，CANNOT VERIFY

**Fixture:**
- `production/qa/bugs/` 中有一个编号为 42 的缺陷文件，采用旧格式：
  三位数编号后跟 slug（`-save-corruption.md`），且
  `**Status**: Fixed — Pending Verification`
- 该缺陷的根本原因代码路径已从 `src/save/` 中移除，但 `tests/` 中没有测试
  覆盖存档系统，且复现需要控制台挂起，
  任何自动化检查都无法驱动

**Input:** `/bug-report verify BUG-0042`

**Expected behavior:**
1. Verify Mode glob `production/qa/bugs/BUG-*.md`，并取编号为 42 的文件
   ——即带 slug 的三位数文件——而不是因缺失 `BUG-0042.md` 而停止
2. 它检查根本原因代码路径（已变更）并查找相关测试
   （无），然后 grep 该模式是否复发
3. 没有测试运行，因此通过 `AskUserQuestion` 询问用户是否在包含修复的构建上
   复现了步骤——`[No longer occurs]` /
   `[Still occurs]` / `[Not played yet]`；用户回答 `[Not played yet]`
4. 结论为 **CANNOT VERIFY**：它指出缺失的内容（没有相关测试），
   并说明复现步骤可以解决问题
5. 它询问 "May I update `production/qa/bugs/[that file]` to set Status: … Cannot
   Verify?"，并指明它找到的文件
6. 不建议 `/bug-report close`——只有 `Verified Fixed` 的缺陷才能
   关闭

**Assertions:**
- [ ] 按编号找到旧式三位数文件；技能不报告 "No bug BUG-0042"
- [ ] 在给出结论前询问人工试玩问题，并提供三个答案
- [ ] 结论为 CANNOT VERIFY，而非 VERIFIED FIXED——变更的代码路径不被视为通过，"Not played yet" 也不被视为通过
- [ ] 说明复现步骤是解决问题的方式
- [ ] "May I update" 询问在 Status 变更前指明实际找到的文件
- [ ] 结论为 CANNOT VERIFY 期间不提供 Close

---

### Case 7: 先 Verify 后 Close — 没有测试覆盖缺陷，用户试玩确认

**Fixture:**
- `project.yaml` 没有 `modes` 块（因此 `qa.level: minimal`——测试被豁免）
  且没有 `commands` 块
- `production/qa/bugs/BUG-0005.md`：Category `UI`、System `HUD`，"health bar does
  not update after healing"、`**Status**: Fixed — Pending Verification`
- 引擎测试根目录中没有测试覆盖 HUD

**Input:** `/bug-report verify BUG-0005`，然后 `/bug-report close BUG-0005`

**Expected behavior:**
1. Verify 找不到相关测试，也不自行运行任何运行器命令行——`commands.test`
   未设置，且它会说明这一点
2. 通过 `AskUserQuestion` 询问用户是否在包含修复的构建上复现了步骤，
   以及是哪个构建——`[No longer occurs]` /
   `[Still occurs]` / `[Not played yet]`；用户回答 `[No longer occurs]`，
   构建 `0.3.1`
3. 结论 **VERIFIED FIXED**，为人工验证；它询问 "May I update
   `production/qa/bugs/BUG-0005.md` to set Status: Verified Fixed …?"，并在
   同意后写入 Status 以及 `**Verified by**: [user], manual, build 0.3.1`
4. 下一步：`/bug-report close BUG-0005`
5. Close 读取 `Verified Fixed`，展示关闭记录（`Verified by` 来自
   verify 记录，`Regression test: Manual verification`）和 Status 变更，
   并在追加任何内容或更改 Status 前询问 "May I update `production/qa/bugs/BUG-0005.md` to mark it Closed?"
6. 同意后，它追加 Closure Record 并设置 `**Status**: Closed`

**Assertions:**
- [ ] 不凭记忆写入任何测试命令；明确指出未设置的 `commands.test`
- [ ] 人工试玩问题附带三个答案询问，并按用户给出的内容记录构建
- [ ] 结论为 VERIFIED FIXED，记录为人工验证（`[user], manual, build 0.3.1`）——没有测试覆盖的缺陷也可以达到 Verified Fixed
- [ ] 在追加 Closure Record 或更改 Status 前，Close 询问 "May I update … to mark it Closed?"
- [ ] Closure Record 的 Regression test 显示 "Manual verification"
- [ ] 变体——回答 `[Still occurs]` 得到 STILL PRESENT（缺陷重新打开并建议 `/hotfix [BUG-ID]`）；回答 `[Not played yet]` 得到 CANNOT VERIFY

---

## Protocol Compliance

- [ ] 从参数选择模式；未提供参数时询问描述
- [ ] 使用与 `/bug-triage` 共享的 S1–S4 严重程度量表和 P1–P4 优先级标签
- [ ] Verify 使用 `project.yaml` 中的 `commands.test` 运行相关测试，绝不凭记忆写运行器命令行
- [ ] 仅当所有适用的检查都通过时，Verify 才说明 VERIFIED FIXED——相关测试运行并通过，或者在没有测试运行（或缺陷为 Visual 或 UI）时，用户在具名构建上复现步骤且问题不再出现，记录为人工验证；若为 "Not played yet" 且没有其他可确认方式，则为 CANNOT VERIFY
- [ ] Reporter 字段绝不包含从会话中获取的电子邮件地址或账号 ID
- [ ] 起草前搜索代码库以找到受影响文件
- [ ] 写入前询问 "May I write this to `production/qa/bugs/BUG-[NNNN].md`?"
- [ ] 在更改现有缺陷文件（Verify / Close）前询问 "May I update"；Close Mode 展示关闭记录并在追加前询问
- [ ] 在 Verify 和 Close Mode 中按编号查找缺陷文件，且绝不关闭不是 `Verified Fixed` 的缺陷
- [ ] 写入时结论为 COMPLETE，用户拒绝时为 BLOCKED

---

## Coverage Notes

- 未单独测试相关测试运行并通过的缺陷在 Verify Mode 下的行为（VERIFIED FIXED 且没有人工问题）；Case 6 覆盖 CANNOT VERIFY，Case 7 覆盖人工 VERIFIED FIXED 以及作为变体的 STILL PRESENT。
- Close Mode 的分类报告引用说明未单独测试。
- 使用没有任何文件携带的编号进行 verify 或 close（"No bug [BUG-ID] in
  `production/qa/bugs/`"，结论 BLOCKED）未单独测试。
