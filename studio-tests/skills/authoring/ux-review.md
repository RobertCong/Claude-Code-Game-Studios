# Skill Test Spec: /ux-review

## Skill Summary

`/ux-review` 在 UX 文档进入实现流水线之前对其进行验证。它接受文件路径、`hud`（`design/ux/hud.md`）、`patterns`（`design/ux/interaction-patterns.md`）、`all`（`design/ux/` 中的每个文件，先给出摘要表），或无参数（它会询问要检查哪份规格）。

Phase 2 加载交叉引用上下文：来自 `project.yaml` `platform` 块的输入方式（输入覆盖检查的权威来源）、`design/accessibility-requirements.md` 中承诺的无障碍层级、模式库、规格头部指明的 GDD 的 UI Requirements，以及玩家旅程。随后它按文档类型运行检查清单——UX 规格使用 Phase 3A（15 个完整性项加质量检查），HUD 设计使用 3B，模式库使用 3C——并输出结构化报告。类型来自文件的 `> **Template**:` 头部行（由 `/ux-design` 写入）；没有该行的文件按名称分类（`hud.md` → 3B，`interaction-patterns.md` → 3C，其他 → 3A），报告会说明假定了哪套检查清单。

结论：**APPROVED**、**NOT ASSESSED**（无法读取规格，或某维度没有判断标准——例如未承诺无障碍层级）、**NEEDS REVISION**、**MAJOR REVISION NEEDED**。该技能为只读（`allowed-tools: Read, Glob, Grep`，外加唯一一次为 Pattern Library 规则解析 `workflow` 的 `resolve_config` 调用），不启动任何代理，其结论仅供参考。交接：APPROVED → `/team-ui` Phase 2；NEEDS REVISION → 修复后重新运行 `/ux-review`；MAJOR REVISION NEEDED → 返回 `/ux-design`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具有必填的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：`APPROVED`、`NOT ASSESSED`、`NEEDS REVISION`、`MAJOR REVISION NEEDED`
- [ ] 不包含 “May I write” 用语，且 `allowed-tools` 中没有 Write 或 Edit（技能为只读）
- [ ] 包含按结论区分的下一步交接（`/team-ui`、NOT ASSESSED 时缺失的输入、重新运行 `/ux-review`、`/ux-design`）

---

## Director Gate Checks

无。`/ux-review` 本身就是 UX 规格的评审步骤；它没有 `Agent` 工具，也不调用任何总监闸门。

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 完整的 UX 规格，APPROVED

**Fixture:**
- `design/ux/inventory.md` 遵循 `.claude/docs/templates/ux-spec.md`：头部包含 Status、Author、Platform Target（PC、Console）、Related GDDs（`design/gdd/inventory.md`）、Accessibility Tier 和 `> **Template**: UX Spec`；每个小节都已填充，包括 States & Variants（loading、empty、populated、error）、带焦点顺序的键盘与方向键导航、分别针对键盘/鼠标和手柄且每项都勾选的 Input Method Completeness Checklist 块，以及至少 5 条可测试的验收标准
- `design/accessibility-requirements.md` 承诺 Standard 层级
- `design/ux/interaction-patterns.md` 存在，且规格中的每个交互组件都指明其中的一个模式
- `project.yaml` 的 `platform` 块：`targets: [PC, Console]`、`gamepad_support: Full`
- `design/gdd/inventory.md` 的 UI Requirements 全部被规格覆盖

**Input:** `/ux-review design/ux/inventory.md`

**Expected behavior:**
1. Phase 2 从 `platform` 块推导输入方式（键盘/鼠标、手柄），读取已承诺的层级、模式库（若存在），以及 `design/gdd/inventory.md` 的 UI Requirements
2. Phase 3A 运行完整性项和质量检查
3. 报告指明 Phase 3A 为所用检查清单（依据 Template 行），并显示 “Completeness: [X/Y sections present]”、Quality Issues、相对于 Standard 层级的 “GDD Alignment: ALIGNED”、“Accessibility: COMPLIANT”，以及 “Pattern Library: CONSISTENT”
4. 结论：APPROVED——“This spec is ready for handoff to `/team-ui` Phase 2 (Visual Design).”
5. Phase 5 建议运行 `/team-ui`

**Assertions:**
- [ ] 输入方式覆盖情况对照 `project.yaml` 的 platform 块检查，而不仅是规格头部
- [ ] 使用 UX 规格检查清单（Phase 3A），包括 States & Variants、Interaction Map 覆盖和 Input Method Completeness Checklist 项
- [ ] 每个评审维度都有可对照的内容——已承诺的层级、模式库、引用的 GDD——因此没有维度是 NOT ASSESSED
- [ ] 无障碍情况对照 `design/accessibility-requirements.md` 中承诺的层级检查
- [ ] 结论为 APPROVED，并交接至 `/team-ui`
- [ ] 不写入任何文件

---

### Case 2: 无障碍小节为空 — NEEDS REVISION

**Fixture:**
- 与 Case 1 相同，但规格的 Accessibility 小节为空
- `design/accessibility-requirements.md` 承诺 Standard 层级

**Input:** `/ux-review design/ux/inventory.md`

**Expected behavior:**
1. Accessibility Requirements 完整性项失败，Standard 层级的文本对比度检查无法满足；焦点顺序检查仍然通过，因为规格仍定义了键盘和方向键焦点顺序（Case 1 的 fixture）
2. 每个发现都列为编号质量问题，包含 BLOCKING/ADVISORY、“What's wrong”、“Where” 和 “Fix”
3. 结论：NEEDS REVISION——“Address the [N] blocking issues above, then re-run `/ux-review`.”
4. 技能提出可以协助起草缺失内容，但不编辑文件；它会等待用户

**Assertions:**
- [ ] 返回 NEEDS REVISION（不是 APPROVED 或 MAJOR REVISION NEEDED）
- [ ] 发现项指出小节并给出具体修复
- [ ] 交接为修复问题并重新运行 `/ux-review`
- [ ] 技能提供帮助但不自动修复，且不写入任何文件

---

### Case 3: 状态不完整 — NEEDS REVISION 优先于 NOT ASSESSED

**Fixture:**
- `design/ux/settings-menu.md` 遵循 UX 规格模板，带有 `> **Template**: UX Spec`，其余部分完整
- 其 States & Variants 小节只记录 populated 状态——没有 loading、empty 或 error 状态；该屏幕异步获取数据
- `design/ux/interaction-patterns.md` 存在，且规格的组件指明了其中的模式
- 没有 `design/accessibility-requirements.md`，因此没有已承诺的层级

**Input:** `/ux-review design/ux/settings-menu.md`

**Expected behavior:**
1. States & Variants 完整性项失败（“at minimum: loading, empty/populated, and error states”）
2. Completeness 列表标记它，例如 “States & Variants — MISSING: error state not documented”，并点名每个缺失状态（loading、empty、error）
3. 报告显示 “Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md absent)”，并将其列在 “Dimensions not assessed” 下
4. 结论为 NEEDS REVISION：已发现的缺口优先于无法检查的维度。它不是 NOT ASSESSED，也不会因为这个可修复的缺口而判为 MAJOR REVISION NEEDED
5. 交接为修复缺口并重新运行 `/ux-review`

**Assertions:**
- [ ] 返回 NEEDS REVISION，而不是 NOT ASSESSED——NOT ASSESSED 的优先级低于修订类结论
- [ ] 报告中仍点名未评估的 Accessibility 维度
- [ ] 缺失的 loading、empty 和 error 状态都在输出中点名
- [ ] 对于这个可修复的缺口，不返回 MAJOR REVISION NEEDED
- [ ] 交接为修复后重新运行 `/ux-review`

---

### Case 4: 无可对照内容 — NOT ASSESSED

**Fixture:**
- Scenario (a)：`design/ux/inventory-screen.md` 不存在
- Scenario (b)：`design/ux/inventory.md` 完整（如 Case 1），但 `design/accessibility-requirements.md` 不存在；规格头部声明 “Accessibility Tier: Standard”

**Input:** (a) `/ux-review design/ux/inventory-screen.md` (b) `/ux-review design/ux/inventory.md`

**Expected behavior:**
1. (a) 无法读取规格：结论为 NOT ASSESSED，点名缺失的路径，且不生成任何检查清单
2. (b) 报告显示 “Accessibility: NOT ASSESSED — no committed tier (design/accessibility-requirements.md absent)”——绝不是 COMPLIANT
3. (b) 头部的 Standard 层级会被沿用，并说明为假设，而不是承诺
4. (b) 建议运行 `/ux-design accessibility` 来建立层级
5. 结论为 NOT ASSESSED，点名未评估的维度以及使其可检查所需的输入，并且不建议交接至 `/team-ui`

**Assertions:**
- [ ] (a) 规格缺失时产生 NOT ASSESSED 并点名路径，不输出检查清单
- [ ] (b) 未承诺层级时，Accessibility 报告为 NOT ASSESSED，而不是 COMPLIANT
- [ ] (b) 建议运行 `/ux-design accessibility`
- [ ] 在 NOT ASSESSED 结果下，报告不建议交接至 `/team-ui`
- [ ] 不写入任何文件

---

### Case 5: `all` 参数与无总监闸门

**Fixture:**
- `design/ux/` 包含 `hud.md`（由 `/ux-design hud` 写入，头部行为 `> **Template**: HUD Design`）、`inventory.md`（由 `/ux-design inventory` 写入，`> **Template**: UX Spec`）和 `pause-menu.md`（依据 `.claude/docs/templates/ux-spec.md` 手写，没有 Template 行）
- `project.yaml` 中 `modes.review_mode: full`

**Input:** `/ux-review all`

**Expected behavior:**
1. 技能找到 `design/ux/` 中的每个文件，先输出摘要表（file | verdict | primary issue），然后输出每个文件的完整报告
2. `hud.md` 使用 HUD 检查清单（Phase 3B），`inventory.md` 使用 UX 规格检查清单（Phase 3A），各自依据其 Template 行
3. `pause-menu.md` 没有 Template 行，也不是 `hud.md` 或 `interaction-patterns.md`，因此使用 Phase 3A，其报告说明检查清单是根据文件名假定的
4. 不启动任何代理，也不出现闸门 ID 或闸门跳过消息；评审模式没有影响
5. 每个结论都是 APPROVED / NOT ASSESSED / NEEDS REVISION / MAJOR REVISION NEEDED 之一

**Assertions:**
- [ ] 摘要表（file | verdict | primary issue）出现在逐文件详情之前
- [ ] 每个文档的检查清单来自其 Template 行（HUD 或 UX 规格）
- [ ] 没有 Template 行的文件按名称分类，且报告说明假定了哪套检查清单
- [ ] 不调用任何总监闸门，也不出现闸门跳过消息
- [ ] 每个结论都来自技能的四种结论集合

---

## Protocol Compliance

- [ ] 在验证之前加载交叉引用上下文（平台配置、无障碍层级、模式库、引用的 GDD、玩家旅程）
- [ ] 使用与文档类型匹配的检查清单（UX 规格、HUD、模式库）——来自 Template 行，或按文件名并说明假设
- [ ] 对照已承诺的层级检查无障碍情况，未承诺层级时报告 NOT ASSESSED——绝不报告 COMPLIANT
- [ ] 将 NOT ASSESSED 排在 APPROVED 之上，并排在 NEEDS REVISION 和 MAJOR REVISION NEEDED 之下
- [ ] 不写入或编辑任何文件
- [ ] 对 NEEDS REVISION 和 MAJOR REVISION NEEDED 给出具体发现（What's wrong / Where / Fix，BLOCKING 或 ADVISORY）；对 NOT ASSESSED，点名每个未评估的维度以及使其可检查所需的输入
- [ ] 以按结论区分的交接结尾：`/team-ui`（APPROVED）、各维度缺失的输入且不交接 `/team-ui`（NOT ASSESSED）、重新运行 `/ux-review`（NEEDS REVISION）、`/ux-design`（MAJOR REVISION NEEDED）

---

## Coverage Notes

- MAJOR REVISION NEEDED（在范围、玩家需求或完整性方面存在根本性问题）
  未用专门的 fixture 测试。
- 模式库检查清单（Phase 3C，`patterns` 参数）未做
  fixture 测试。
- 无参数提示（“要验证哪份规格”）未测试。
- 当 `project.yaml` 没有 `platform` 块时回退到
  `.claude/docs/technical-preferences.md`，再回退到规格头部的行为未测试。
