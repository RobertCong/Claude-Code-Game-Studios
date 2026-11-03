# Skill Test Spec: /design-review

## Skill Summary

`/design-review` 依据项目的设计标准（Overview、Player Fantasy、Detailed Rules、
Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria）评审一份
游戏设计文档（GDD）。哪些小节是 REQUIRED 取决于为该系统的解析出的工作流层级：
`full` 下全部 8 个；`standard` 下 5 个（当系统定义数值规则时再加 Formulas）。
它通过 `.trae/scripts/gdd-structure-check.sh` 收集小节是否存在，校验声明的
依赖图，检查内部一致性、可实现性和跨系统契合度，并产生 APPROVED、
NEEDS REVISION、MAJOR REVISION NEEDED 或 NOT ASSESSED 的结论。

评审模式设定其深度：`full` 增加一次并行的对抗性专家评审加一次
`creative-director` 资深综合（Phase 3b）；`lean` 在无代理的情况下运行所有阶段；
`solo` 只运行 Phase 1–4，且没有下一步提示。Phase 4 不写入任何内容。在 Phase 5
中它可更新 `design/gdd/systems-index.md`，并向
`design/gdd/reviews/[doc-name]-review-log.md` 追加内容，每次都要经由
`AskUserQuestion` 获得用户批准。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具备 ≥2 个阶段标题或编号步骤
- [ ] 包含结论关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED、NOT ASSESSED
- [ ] 正文承诺写入文件，因此存在 "May I" 写入批准措辞（systems-index 更新、review-log 追加）
- [ ] 有文档化的输出格式（技能正文中展示了评审模板）

---

## Fixture Defaults

除非用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 完整 GDD，8 个小节齐备

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/light-manipulation.md` 存在，全部 8 个小节都有实质内容
  （Detailed Rules 小节的标题为 `## Detailed Design`）
- Formulas 小节至少定义了一个含具名变量的公式
- Acceptance Criteria 小节包含至少 3 条可测试的标准
- 其 Dependencies 小节中命名的每个系统都在 `design/gdd/` 中有 GDD
- 本文档没有此前的评审日志

**输入：** `/design-review design/gdd/light-manipulation.md --review lean`

**预期行为：**
1. 新鲜度检查（`review-receipts.sh check …`）未找到回执 → 完整评审
2. 技能完整读取目标文档并读取 AGENTS.md
3. 技能运行 `bash .trae/scripts/gdd-structure-check.sh design/gdd/light-manipulation.md`
4. 技能对每个声明的依赖在 `design/gdd/` 中执行 Glob
5. 技能检查内部一致性、可实现性和跨系统契合度
6. 不启动任何代理（lean）
7. 技能输出 Phase 4 评审，以结论结尾
8. 在 APPROVED 时，一个多选 `AskUserQuestion` 提供两项跟踪更新；只写入被选中的
   那些；然后是最后的收尾部件

**断言：**
- [ ] 技能在产生任何输出前读取目标文件
- [ ] 小节是否存在来自 `gdd-structure-check.sh`，且 `## Detailed Design` 被接受为 Detailed Rules 小节（不被标记为缺失）
- [ ] 输出包含 "Completeness: 8/8"（N 为 8，因为层级是 `full`）
- [ ] 输出包含 "Dependency Graph" 小节，列出每个声明的依赖及其 GDD 是否存在
- [ ] 输出包含 "Required Before Implementation"、"Recommended Revisions" 和 "Scope Signal" 小节，以及 "Re-review: No — first review"
- [ ] 当所有 REQUIRED 小节都存在且未发现阻塞问题时，输出以 `### Verdict:` APPROVED 结尾
- [ ] 在跟踪记录部件之前不写入任何文件，且只写入用户选择的选项
- [ ] 若选择了 review-log 选项，追加的条目包含 `Review mode:` 行，以及该文档、技能文件及其读取的相关 GDD 的 `review-receipts.sh hash` 输出

---

### Case 2: 失败路径 — 不完整的 GDD（`full` 下 4/8 小节）

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/light-manipulation.md` 只有 Overview、Player Fantasy、Detailed
  Rules 和 Dependencies；Formulas、Edge Cases、Tuning Knobs 和
  Acceptance Criteria 缺失

**输入：** `/design-review design/gdd/light-manipulation.md --review lean`

**预期行为：**
1. `gdd-structure-check.sh` 在其 `ABSENT:` 列表中报告这 4 个小节
2. 在 `full` 下这 4 个都是 REQUIRED，因此每个都阻塞批准
3. 技能输出 "Completeness: 4/8" 并点名每个缺失的小节
4. 结论是修订类结论，绝不是 APPROVED
5. Phase 5 提供 `[A] Revise the GDD now` / `[B] Stop here`；"Accept as-is"
   仅在所有条目都是建议性时提供，而此处并非如此

**断言：**
- [ ] 完整性小节显示 "4/8"（而不是更高的数字）
- [ ] 输出明确点名每个缺失的小节（Formulas、Edge Cases、Tuning Knobs、Acceptance Criteria）为 REQUIRED
- [ ] 结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED —— 在 REQUIRED 小节缺失时绝不 APPROVED，也不是 NOT ASSESSED（文档已被读取）
- [ ] 输出不暗示该文档已具备实现条件
- [ ] 不提供 "Accept as-is and move on"，因为缺失的小节是阻塞性的
- [ ] 除经明确的 Phase 5 选择外不写入任何文件：`[A] Revise the GDD now`、"May I update `design/gdd/systems-index.md`…"，或 "May I append this review summary…"
- [ ] systems-index 提示提供 `Needs Revision` 或 `In Review` —— 在此修订结论下绝不提供 `Approved` —— 且 review-log 条目记录该修订结论，而非批准

---

### Case 3: 部分路径 — `standard` 层级，有数值规则但无 Formulas 小节

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: standard`
- GDD 有 Overview、Player Fantasy、`## Detailed Design`、Edge Cases、
  Dependencies、Tuning Knobs 和 Acceptance Criteria；没有 Formulas 小节
- Detailed Design 陈述了数值规则（"drain 2 oxygen per second"、"refill
  costs 50 credits"），但没有公式定义它们
- Acceptance Criteria 含糊（"feels good" 而不是可测量）

**输入：** `/design-review design/gdd/oxygen.md --review lean`

**预期行为：**
1. 技能在 `standard` 下将 Formulas 标记为 REQUIRED，因为该系统定义了数值规则
   （仅系统的 `Category` 永远不能清除它）
2. N = 6（5 个标准小节 + Formulas）；Completeness 显示 5/6，而不是 /8 计数
3. 技能将含糊的验收标准标记为可实现性问题
4. 结论是修订类结论

**断言：**
- [ ] 由于存在数值规则，输出将缺失的 Formulas 小节识别为 REQUIRED（而非建议性）
- [ ] 完整性按 `standard` 计数报告（"5/6"），而不是 "7/8"
- [ ] 输出将含糊的验收标准标记为实现缺口，并逐条引用 —— 由主评审自行完成，因为 `lean` 下不运行 `qa-lead`
- [ ] 结论为 NEEDS REVISION 或 MAJOR REVISION NEEDED，绝不 APPROVED

---

### Case 4: 边界情况 — 文件未找到

**测试夹具：**
- 提供的路径在项目中不存在

**输入：** `/design-review design/gdd/nonexistent.md --review lean`

（`lean`，因此 Phase 5 运行。在 `solo` 下 —— 当 `project.yaml` 既未设置
`modes.review_mode` 也未设置 `modes.rigor` 时评审模式解析出的结果 —— Phase 5
从不运行，下面的最后一条断言就什么也测不到。）

**预期行为：**
1. 新鲜度检查报告无回执；技能尝试读取该文件
2. 文件未找到
3. 技能输出 `### Verdict: NOT ASSESSED`，点名缺失的文档和产生它的技能
   （`/design-system`）
4. 技能不产生质量结论，也不做任何跟踪写入
5. Phase 5 跳过跟踪部件，进入最后的收尾部件，并以 `/design-system` 打头

**断言：**
- [ ] 结论为 NOT ASSESSED —— 不是 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED
- [ ] 输出点名缺失的文件以及哪个技能会产出它
- [ ] Phase 5 运行，既不为 `systems-index.md` 提供状态更新，也不提供 review-log 条目 —— 特别是绝不提议将该系统标记为 Approved

---

### Case 5: 评审模式 — `full` 下委派专家，`lean` / `solo` 下不委派

**测试夹具（所有子用例）：**
- `project.yaml` 设置 `modes.workflow: full`
- `design/gdd/light-manipulation.md` 存在，8 个小节齐备，包括公式和战斗数值

**Case 5a — full：** `/design-review design/gdd/light-manipulation.md --review full`

**预期行为：**
1. 启动前，技能打印 "Full review: spawning specialist agents in parallel…"
2. 技能以真实 `Agent` 调用并行启动相关专家 —— 此处至少为 `game-designer`
   （任何玩法系统）和 `systems-designer`（公式）
3. 专家返回后，技能启动 `creative-director` 作为资深评审；其综合成为最终结论
4. 发现带有来源标签；分歧被列出，而不是静默解决

**断言（5a）：**
- [ ] 在任何代理被启动前打印该通知
- [ ] 专家通过 `Agent` 并行启动（不在会话内模拟）
- [ ] `creative-director` 仅在专家响应后启动，且输出有 "Senior Verdict [creative-director]" 小节
- [ ] "Specialists consulted:" 列出实际启动的代理，且每条发现带有来源标签，例如 `[game-designer]`
- [ ] 专家分歧出现在 "Specialist Disagreements" 下
- [ ] `### Verdict:` 行只承载本技能词汇之一 —— APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED —— 取自 creative-director 的综合；绝不使用总监闸门词汇，如 READY、CONCERNS、NOT READY、APPROVE 或 REJECT
- [ ] 不出现总监闸门 ID（"Gate: CD-…" 等）—— 资深评审是直接启动，而非来自 `director-gates.md` 的闸门

**Case 5b — 通过遗留标志使用 lean：** `/design-review design/gdd/light-manipulation.md --depth lean`

**断言（5b）：**
- [ ] `--depth lean` 被当作 `--review lean` 处理，且技能说明一次该标志已更名
- [ ] 不发起 `Agent` 调用；评审在会话内运行
- [ ] Phase 5 的下一步部件仍然运行

**Case 5c — solo：** `/design-review design/gdd/light-manipulation.md --review solo`

**断言（5c）：**
- [ ] 不发起 `Agent` 调用
- [ ] 只运行 Phase 1–4：没有 Phase 5 下一步提示，因此不提供 systems-index 或 review-log 写入

---

### Case 6: 来自已解析配置的评审模式 —— 无标志

**测试夹具：**
- `project.yaml` 设置 `modes.workflow: full` 和 `modes.review_mode: lean`
- `design/gdd/light-manipulation.md` 存在，8 个小节齐备

**输入：** `/design-review design/gdd/light-manipulation.md`

**预期行为：**
1. 没有 `--review` 标志，因此技能从技能顶部的已解析配置块取得
   `review_mode: lean`
2. 评审在会话内运行，没有 `Agent` 调用
3. Phase 5 的部件运行 —— 若是 `rigor: minimal` 默认值下的 `solo`，它们本会被跳过

**断言：**
- [ ] 未给出标志时，评审模式来自已解析的配置块（`review_mode: lean (project.yaml)`）
- [ ] 不发起 `Agent` 调用，且 Phase 5 的下一步部件运行 —— 因此本次运行是 `lean`，而不是 `solo` 默认值
- [ ] 变体 —— 同一夹具，输入加 `--review solo`：标志优先于配置，且不运行任何 Phase 5 部件

---

## Protocol Compliance

- [ ] 评审本身（Phase 4）期间不写入任何内容
- [ ] 每次写入（systems-index 状态、review-log 追加）都仅在 `AskUserQuestion` 批准后发生
- [ ] 在结论行之前展示完整发现
- [ ] 在 `solo` 之外，以 `AskUserQuestion` 下一步部件收尾，而不是纯文本（协作/引导模式）

---

## Coverage Notes

- 多个 GDD 之间的跨系统一致性由 `/review-all-gdds` 规格覆盖；本规格只检查单个文档的依赖引用。
- 新鲜度回执路径（字节相同的重评审提供先前结论；要求更深评审时给出较浅的已记录评审；仅跨文档变更）未在此做 fixture 测试。
- 实体注册表 grep 路径（注册表列出该系统）未测试；上述 fixture 使用读取 Dependencies 中命名的 GDD 的兜底方案。
- `minimal` 层级（不期望 GDD；标准小节以建议方式检查）未测试。
- 涉及超大 GDD 文件的性能和边界情况不在范围内。
