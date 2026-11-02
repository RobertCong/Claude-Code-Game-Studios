# Skill Test Spec: /create-control-manifest

## Skill Summary

`/create-control-manifest` 读取 `docs/architecture/` 中已接受（Accepted）的 ADR，
并生成一份控制清单（control manifest）—— 一张扁平、可执行的规则表，记录每个
架构层（Foundation、Core、Feature、Presentation）所需的模式、禁止的做法、
性能护栏和引擎 API 约束，以及来自项目配置和引擎参考资料文档的全局规则。
用户故事作者借助它，让用户故事继承正确的架构规则，而无需阅读每一份 ADR。

该技能先统计 ADR 数量，在读取任何 ADR 正文之前用 Grep 解析每份 ADR 的
`## Status`，并仅基于 Accepted 集合构建清单。它会预览每个层的规则数量，在
评审模式为 `full` 时运行 **TD-MANIFEST** 总监质量闸门（gate）（在 `solo` 和
`lean` 下跳过并附注说明），然后在写入
`docs/architecture/control-manifest.md` 之前询问
"May I write the Control Manifest?"。结论：写入后为 COMPLETE，用户拒绝写入时
为 BLOCKED。

---

## Static Assertions (Structural)

由 `/skill-test spec` 针对 SKILL.md 检查 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议用语（针对控制清单）
- [ ] 结尾有下一步交接（先 `/create-epics`，再 `/create-stories`）
- [ ] 说明只包含 Accepted ADR（不含 Proposed）
- [ ] 点明质量闸门 TD-MANIFEST 及其 solo/lean 跳过说明

---

## Director Gate Checks

一个质量闸门：**TD-MANIFEST**（`technical-director`，
`.claude/docs/director-gates/td-manifest.md`），在用户接受 Phase 4 规则摘要之后、
Phase 5 写入询问之前被派发。

- `full` → 派发；接收控制清单预览（Control Manifest Preview）、覆盖的 ADR、
  引擎版本，以及任何来自偏好设置或引擎参考资料文档的规则
- `lean` → 跳过；输出注明 "TD-MANIFEST skipped — Lean mode."
- `solo` → 跳过；输出注明 "TD-MANIFEST skipped — Solo mode."

结论处理：APPROVE → 进入写入询问；CONCERNS → 通过 `AskUserQuestion` 提供
`Revise flagged rules` / `Accept and proceed` / `Discuss further`；REJECT →
不写入清单，修复被标记的规则并重新呈现摘要；NOT ASSESSED [missing input] →
绝不当作 APPROVE 读取：先指出缺失的输入，随后补齐并重新运行质量闸门，或者继续
运行并在输出和结论行中注明 `TD-MANIFEST: NOT ASSESSED — [input]`。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 —— 4 份 Accepted ADR 生成正确的清单

**Fixture:**
- `docs/architecture/` 包含 `adr-0001-*.md` … `adr-0004-*.md`，每份都有
  一个内容为 `Accepted` 的 `## Status` 小节
- 每份 ADR 都有 `## Decision`（含 "must"/"always" 表述）和
  `## Alternatives Considered`（含被否决的备选方案）
- 不存在 `docs/architecture/control-manifest.md`
- 评审模式解析为 `solo`

**Input:** `/create-control-manifest`

**Expected behavior:**
1. Glob `docs/architecture/adr-*.md`（N = 4），然后在读取任何 ADR 正文之前
   Grep `^## Status` 以确定 Accepted 集合
2. 只 Grep Accepted ADR 的 Decision / Alternatives Considered / Performance
   Implications / Engine Compatibility 小节
3. 报告 "Loaded 4 Accepted ADRs, engine: [name + version]."
4. 显示控制清单预览（每层规则数量、覆盖的 ADR），并询问
   "Does this rule summary look complete?"
5. 注明 "TD-MANIFEST skipped — Solo mode."
6. 询问 "May I write the Control Manifest?"，选项为
   `[A] Yes — write to docs/architecture/control-manifest.md`
7. 获得批准后写入清单；结论：COMPLETE

**Assertions:**
- [ ] 全部 4 份 Accepted ADR 都列在清单头部的 `ADRs Covered` 下
- [ ] 每个层小节都有 `### Required Patterns` 和 `### Forbidden Approaches`
- [ ] 每条规则都带有来源 —— 层规则为 `— source: [ADR-NNNN]`；全局规则需指明其 `project.yaml` / `technical-preferences.md` 键或引擎参考资料文件（例如 `deprecated-apis.md`）
- [ ] 在任何写入询问之前显示预览并询问 "Does this rule summary look complete?"
- [ ] 出现 "TD-MANIFEST skipped — Solo mode."；未派发 technical-director
- [ ] 在 "May I write the Control Manifest?" 获得批准前，技能不写入
- [ ] 写入后结论为 COMPLETE

---

### Case 2: 失败路径 —— 未找到 ADR

**Fixture:**
- `docs/architecture/` 目录存在，但不含任何 `adr-*.md` 文件

**Input:** `/create-control-manifest`

**Expected behavior:**
1. Glob 返回 N = 0
2. 技能输出："No ADRs found — run `/architecture-decision` before building a
   control manifest."
3. 技能停止 —— 不执行 Status Grep、不显示预览、不发起写入询问、不写文件

**Assertions:**
- [ ] 打印出 "No ADRs found" 消息
- [ ] 技能推荐以 `/architecture-decision` 作为下一步操作
- [ ] 不写入任何控制清单文件，也不显示 "May I write" 询问
- [ ] 不输出 COMPLETE 结论（技能在 Phase 1 即停止）

---

### Case 3: ADR 状态混合 —— 只纳入 Accepted ADR

**Fixture:**
- `docs/architecture/` 包含 5 份 ADR：3 份的 `## Status` 为 Accepted，2 份的
  `## Status` 为 Proposed（ADR-0004、ADR-0005）

**Input:** `/create-control-manifest`

**Expected behavior:**
1. N = 5；`^## Status` Grep 返回 5 个匹配，其中 3 个为 Accepted —— 适用
   "some Accepted" 行，Accepted 集合 A = 这 3 份 ADR
2. 小节提取被过滤到集合 A
3. 预览报告 "Loaded 3 Accepted ADRs"，`ADRs covered` 只列出这 3 份，
   且 `ADRs excluded` 指名 ADR-0004（Proposed）和 ADR-0005（Proposed）
4. 继续执行，不询问如何处理 Proposed ADR（该询问保留给无 Accepted ADR 的情形）

**Assertions:**
- [ ] 在读取任何 ADR 小节之前，用 `^## Status` Grep 确定状态
- [ ] 预览的 `ADRs covered` 和清单的 `ADRs Covered` 恰好列出这 3 份 Accepted ADR
- [ ] 两份被排除的 ADR 都在用户批准前看到的预览中被指名并标注状态 —— 技能不会静默省略它们
- [ ] 清单中没有任何规则来源于这两份 Proposed ADR
- [ ] 此 fixture 下不显示 "none Accepted — proceed with Proposed or stop?" 询问

---

### Case 4: 边界情况 —— 重新生成已存在的清单

**Fixture:**
- `docs/architecture/control-manifest.md` 已存在，其
  `Manifest Version` 和 `Last Updated` 均为上周日期
- `docs/architecture/` 包含 Accepted ADR，其中一份是此后才被接受的
- `production/epics/` 已存有带用户故事的史诗（epic），因此首次运行的
  `/create-epics` 下一步不适用

**Input:** `/create-control-manifest update`

**Expected behavior:**
1. 技能基于当前 Accepted ADR 重建清单（同样的 Phase 1–4）
2. 覆盖之前询问 "May I write the Control Manifest?"
3. 新清单的 `Manifest Version` 和 `Last Updated` 均为今天的日期
4. 写入后打印 "Updated. Recommend notifying the team of changed rules —
   especially any new Forbidden entries."

**Assertions:**
- [ ] 在 "May I write the Control Manifest?" 获得批准前，不覆盖已存在的文件
- [ ] 新接受的 ADR 出现在 `ADRs Covered` 中
- [ ] `Manifest Version` 等于 `Last Updated`，且为生成日期（不是 v1→v2 计数器）
- [ ] 显示重新生成的下一步提示（"Updated. Recommend notifying the team…"），而不是首次运行的 `/create-epics` 交接

---

### Case 5: 总监质量闸门 —— 在 full 评审模式下 TD-MANIFEST 返回 REJECT

**Fixture:**
- 存在 4 份 Accepted ADR
- 评审模式解析为 `full`
- TD-MANIFEST 返回 REJECT，并指名一条没有来源 ADR 的规则

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能显示 Phase 4 预览；用户选择
   `[A] Yes — looks good, run the director review and write the manifest`
2. 通过 `Agent` 派发 `technical-director`，质量闸门为 TD-MANIFEST，并传入
   预览（完整规则列表）、覆盖的 ADR 和引擎版本
3. 收到 REJECT 时：不写入清单；修复被标记的规则并重新呈现摘要
4. 在 REJECT 仍然有效期间，不询问 "May I write the Control Manifest?"

**Assertions:**
- [ ] 仅在 Phase 4 摘要被接受后才派发 TD-MANIFEST
- [ ] 质量闸门接收规则列表、覆盖的 ADR 和引擎版本
- [ ] 收到 REJECT 时不写入任何清单文件
- [ ] 在任何写入询问之前修订被标记的规则并重新呈现摘要
- [ ] `full` 模式下不出现 "TD-MANIFEST skipped" 提示

---

### Case 6: 边界情况 —— 无 Accepted ADR，以及 ADR 缺少 `## Status`

**Fixture (none Accepted):**
- `docs/architecture/` 包含 3 份 ADR，每份的 `## Status` 均为 Proposed

**Fixture (malformed):**
- `docs/architecture/` 包含 3 份 ADR，均无 `## Status` 小节

**Input (both fixtures):** `/create-control-manifest`

**Expected behavior (none Accepted):**
1. N = 3；`^## Status` Grep 匹配 3 个，均不是 Accepted
2. 报告 "3 ADRs found, none Accepted. A manifest built from Proposed ADRs would
   encode decisions that may still change."，并询问是继续使用 Proposed ADR
   还是停止

**Expected behavior (malformed):**
1. N = 3；`^## Status` Grep 无匹配
2. 报告 "3 ADRs found, none has a `## Status` section — acceptance cannot be
   determined. Run `/architecture-decision retrofit [file]` on each." 并停止

**Assertions:**
- [ ] 无 Accepted 时：显示询问，不写入空清单
- [ ] 格式异常时：运行停止 —— ADR 不被视为 Accepted，且不写入清单
- [ ] 格式异常时：retrofit 命令的写法为 `/architecture-decision retrofit [file]` —— 即该技能可解析的形式
- [ ] 两种 fixture 下，在用户继续之前都不预览规则摘要、也不显示 "May I write" 询问

---

## Protocol Compliance

- [ ] 在读取 ADR 小节之前统计 ADR 数量并确定 `## Status`
- [ ] 只纳入 Accepted ADR，且每份被排除的 ADR 都在预览中被指名并标注状态；无 Accepted 和缺少 `## Status` 的情形应停止或询问，而不是输出空清单
- [ ] 在质量闸门之前、在 "May I write" 之前向用户显示规则摘要
- [ ] 在写入 `docs/architecture/control-manifest.md` 之前询问 "May I write the Control Manifest?"
- [ ] TD-MANIFEST 在 `full` 下运行，在 `lean`/`solo` 下跳过并给出具名说明
- [ ] 以下一步交接结尾：先 `/create-epics layer: foundation`，再 `/create-stories [epic-slug]`

---

## Coverage Notes

- 生成清单的具体小节结构（约束表、模式列表）由技能正文定义，不在测试断言中再次列举。
- 用户在 Case 6 中选择继续使用 Proposed ADR 后的行为未做 fixture 测试。
- TD-MANIFEST 的 APPROVE、CONCERNS 和 NOT ASSESSED 路径，以及 `lean` 跳过说明，未单独做 fixture 测试。
- `deprecated-apis.md` 条目的相关性过滤（2D 与 3D 的范围划分）未覆盖。
