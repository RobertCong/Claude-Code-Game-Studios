# Skill Test Spec: /art-bible

## Skill Summary

`/art-bible` 负责编写 `design/art/art-bible.md` 处的美术设定集（art bible），共九个部分：1 Visual Identity Statement、2 Mood & Atmosphere、3 Shape Language、4 Color System、5 Character Design Direction、6 Environment Design Language、7 UI/HUD Visual Direction、8 Asset Standards、9 Reference Direction。

它首先读取 `design/gdd/game-concept.md`（在 `rigor: minimal` 下读取 `design/game-brief.md`），若两者都不存在则停止。一个双标签页的 `AskUserQuestion` 为会话定下框架：**Scope**（其中解析出的 `workflow` 层级所要求的选项被标记为 Recommended）与 **References**（自由文本）。编写是渐进式的：每个小节的草稿都来自被启动的专家代理（`art-director`；第 7 节另加 `ux-designer`，第 8 节另加 `technical-artist`），先呈现给用户、获得批准，并在下一小节开始前立即写入文件。第 2–4 节共用一次 `art-director` 调用，第 5–6 节也是如此，但它们的审批和写入仍是一次一个小节。首次写入会询问 “May I create `design/art/art-bible.md` from the art bible template?”；每个小节只有在获得明确指明写入的选项（`[A] Lock this in and write it to design/art/art-bible.md`）的批准后才会写入。只编写所选范围内的部分，收尾会说明被排除的部分及原因。

如果文件已存在，技能会通过两次 Grep（标题与占位符标记）构建小节状态表，而不读取整份文档，并且只编写 Empty 或 Placeholder 的小节。

范围内的小节写完后，Phase 5 仅在 `full` 评审模式下运行 AD-ART-BIBLE 签核，并把结论记录到美术设定集的状态头中。Phase 6 以按项目状态筛选的下一步 `AskUserQuestion` 收尾。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含记录在状态头中的质量闸门（gate）结论关键词：`APPROVED`、`CONCERNS`
- [ ] 包含写入前询问用语：在文件存在之前询问 “May I create `design/art/art-bible.md` from the art bible template?”，以及每个小节明确指明写入的批准选项（`Lock this in and write it to design/art/art-bible.md`）
- [ ] 记录 AD-ART-BIBLE 总监质量闸门（gate）及其模式行为
- [ ] 包含下一步交接（例如 `/map-systems`、`/create-architecture`）

---

## Director Gate Checks

| Gate ID      | Trigger condition                                        | Mode guard |
|--------------|----------------------------------------------------------|------------|
| AD-ART-BIBLE | Phase 5 — 在 Phase 1 范围内的所有小节写入之后 | 仅 full；lean 注明 “AD-ART-BIBLE skipped — Lean mode.”，solo 注明 “AD-ART-BIBLE skipped — Solo mode.” |

该闸门以其定义中指定的代理身份启动（`.trae/docs/director-gates/ad-art-bible.md`：`art-director`），并接收该定义列出的四项内容：美术设定集路径、游戏支柱与核心幻想、平台与性能约束（`platform.*` 和 `performance.*`），以及视觉识别锚点。当输入为一页式简报时，它会把简报的提案（pitch）和 “what they feel” 行作为游戏支柱与核心幻想，并把 “Art & audio direction” 行作为锚点。

向 `art-director`（以及 `ux-designer` / `technical-artist`）分派小节起草不属于质量闸门（gate）：它是强制性的，在每种评审模式下都会运行。

---

## Fixture Defaults

除非某个案例自身的 Fixture 另有说明，每个案例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — full 模式、full 工作流、全部九个小节，AD-ART-BIBLE 通过

**Fixture:**
- 没有 `design/art/art-bible.md`
- `design/gdd/game-concept.md` 存在，包含游戏支柱和 Visual Identity Anchor 小节
- `project.yaml` 中 `modes.review_mode: full`，`modes.workflow: full`
- AD-ART-BIBLE 返回 APPROVE

**Input:** `/art-bible`

**Expected behavior:**
1. Phase 0 读取游戏概念，并提取标题、提案、游戏支柱、Visual Identity Anchor 和平台
2. Phase 1 提出一个 `AskUserQuestion`，包含 Scope 标签页（将 Full bible 标记为 Recommended，因为 `full` 要求全部 9 个小节）和自由文本 References 标签页，并说明它找到的锚点
3. 第 1 节：由 `art-director` 起草；用户从 `[A] Lock this in and write it to design/art/art-bible.md` / `[B] Revise the one-liner` / `[C] Revise a supporting principle` / `[D] Describe my own direction` 中选择；在 “May I create `design/art/art-bible.md` from the art bible template?” 之后，从 `.trae/docs/templates/art-bible.md` 创建文件，并用已批准的小节替换第 1 节的 `[To be designed]` 行
4. 第 2–4 节：一次 `art-director` 调用返回三个带标签的块；第 2 节先呈现，用明确指明写入的选项批准并写入，然后再呈现第 3 节，依此类推
5. 第 5–6 节：一次 `art-director` 调用；逐节呈现、批准和写入
6. 第 7 节：`art-director` 与 `ux-designer` 并行启动；第 8 节：`art-director` 与 `technical-artist` 并行启动；第 9 节：`art-director`
7. Phase 5：AD-ART-BIBLE 在第九个小节写入之后启动，并接收美术设定集路径、游戏支柱与核心幻想、平台与性能约束，以及视觉识别锚点
8. 状态头记录 `> **Art Director Sign-Off (AD-ART-BIBLE)**: APPROVED [date]`
9. Phase 6：下一步 `AskUserQuestion`，始终包含 `/create-architecture` 和 “Stop here”

**Assertions:**
- [ ] Scope 标签页将 “Full bible — all 9 sections” 标记为 Recommended 并说明原因
- [ ] 每个小节的内容都来自被启动的专家代理，绝不来自编排器（orchestrator）自行起草
- [ ] 第 2–4 节来自单次 `art-director` 调用，但逐节呈现、批准和写入
- [ ] 在获得明确指明写入的选项批准之前不写入任何小节（`Lock this in and write it to design/art/art-bible.md`），且每个小节都在批准后立即写入
- [ ] 只有在询问 “May I create `design/art/art-bible.md` from the art bible template?”（该询问明确指名文件）之后，才会从 `.trae/docs/templates/art-bible.md` 创建文件，从而其九个 `## N. Name` 标题正是 retrofit 模式（Case 4）所读取的标题
- [ ] AD-ART-BIBLE 仅在全部九个小节写入之后才以 `art-director`（其闸门定义指定的代理）身份启动
- [ ] AD-ART-BIBLE 接收全部四项上下文：美术设定集路径、游戏支柱与核心幻想、平台与性能约束，以及视觉识别锚点
- [ ] APPROVE 结论记录在美术设定集的状态头行中
- [ ] 收尾选项包含 `/create-architecture` 和 “Stop here”

---

### Case 2: AD-ART-BIBLE 返回 CONCERNS 或 NOT ASSESSED

**Fixture:**
- 全部九个小节都已写入 `design/art/art-bible.md`
- `project.yaml` 中 `modes.review_mode: full`，`modes.workflow: full`
- Scenario (a)：AD-ART-BIBLE 返回 CONCERNS：“Color System does not match the Mood & Atmosphere targets for combat”
- Scenario (b)：AD-ART-BIBLE 返回 NOT ASSESSED——没有可用的平台或性能约束来对照检查资源标准

**Input:** `/art-bible`（运行到 Phase 5）

**Expected behavior:**
1. (a) CONCERNS 通过 `AskUserQuestion` 呈现给用户，并附上 `director-gates.md` 中的标准选项：`Revise flagged items` / `Accept and proceed` / `Discuss further`
2. (a) 如果选择 “Accept and proceed”：状态头记录 `CONCERNS (accepted) [date]`
3. (a) 如果选择 “Revise flagged items”：由 `art-director`——即 Color System 自身的专家——重新起草第 4 节；先呈现给用户，并用以明确指明写入的选项批准后才写入；随后状态头记录 `REVISED [date]`
4. (b) 明确指出缺失的输入，状态头记录 `NOT ASSESSED [date] — [missing input]`，绝不记录 `APPROVED`
5. Phase 6 仅在结论记录之后运行

**Assertions:**
- [ ] (a) CONCERNS 连同三个标准选项一起展示给用户，不会自动接受
- [ ] (a) 选择 “Accept and proceed” 会在状态头记录 `CONCERNS (accepted) [date]`
- [ ] (a) 被标记的小节由其专家重新起草，而不是由编排器起草，并在写入前获得批准；状态头记录 `REVISED [date]`
- [ ] (b) NOT ASSESSED 按原样记录，并指出缺失的输入——不记为批准
- [ ] 在结论记录之前不呈现 Phase 6 的下一步

---

### Case 3: Lean 模式、standard 工作流 — 仅核心小节，跳过闸门

**Fixture:**
- 没有现成的美术设定集
- `design/gdd/game-concept.md` 存在
- `project.yaml` 中 `modes.review_mode: lean`，`modes.workflow: standard`
- 用户选择 Recommended 范围

**Input:** `/art-bible`

**Expected behavior:**
1. Scope 标签页将 “Visual identity core (sections 1–4 only)” 标记为 Recommended，并说明 “Sections 1–4 are what `standard` requires; 5–9 are available if you want them.”
2. 第 1–4 节由 `art-director` 起草，每节都在下一节之前获得批准并写入
3. Phase 3 和 Phase 4（第 5–9 节）不运行，因为它们不在所选范围之内
4. Phase 5 不启动 AD-ART-BIBLE，并打印 “AD-ART-BIBLE skipped — Lean mode.”
5. Phase 6 先说明第 5–9 节本次未编写（不在所选范围内），然后呈现下一步

**Assertions:**
- [ ] Scope 推荐为第 1–4 节，并给出 `standard` 的解释
- [ ] 仅编写第 1–4 节
- [ ] 收尾说明第 5–9 节未编写及原因，使这份四节版设定集不会被误读为完整
- [ ] lean 模式下不启动 AD-ART-BIBLE，且跳过说明为 “AD-ART-BIBLE skipped — Lean mode.”
- [ ] 每次写入之前仍需逐节获得用户批准

---

### Case 4: 已有美术设定集 — 仅对不完整小节执行 retrofit

**Fixture:**
- `design/art/art-bible.md` 存在，第 1–4 节已完整写入
- 第 5 节标题后为 `[To be designed]`
- 第 6–9 节只有标题，标题之间没有内容
- `design/gdd/game-concept.md` 存在；`project.yaml` 中 `modes.workflow: full`，`modes.review_mode: full`
- 在 Scope 标签页，用户选择 `Resume — fill in missing sections`
- AD-ART-BIBLE 返回 APPROVE

**Input:** `/art-bible`

**Expected behavior:**
1. Phase 0 用 glob 匹配 `design/art/art-bible.md` 并找到它
2. 技能运行两次 Grep——`^## ` 标题和占位符标记（`[To be designed]`、`[TBD]`、`[To be written]`、`TODO`）——并且不读取整份文档；含糊的小节只按行范围读取
3. 它构建状态表（第 1–4 节 Complete，第 5 节 Placeholder，第 6–9 节 Empty），并说明：“Found existing art bible at `design/art/art-bible.md`. 4 sections are complete, 5 need content. I'll work on the incomplete sections only — existing content will not be touched.”
4. 仅编写、批准并写入第 5–9 节；第 1–4 节不重新起草或改写
5. 第九个小节写入后，Phase 5 启动 AD-ART-BIBLE——retrofit 在 `full` 评审模式下同样以签核收尾——状态头记录 `APPROVED [date]`
6. Phase 6 说明第 1–4 节本次未编写（已完整）

**Assertions:**
- [ ] 小节状态来自两次 Grep，而不是完整阅读文件
- [ ] retrofit 消息说明完整与不完整的数量，并说明不会改动现有内容
- [ ] 仅编写 Empty 和 Placeholder 小节；Complete 小节保持不变
- [ ] 状态表各行使用技能编写时的小节名称（例如 `Mood & Atmosphere`、`Shape Language`、`Reference Direction`）
- [ ] AD-ART-BIBLE 在 retrofitted 小节写入之后运行，与全新运行时一致

---

### Case 5: Solo 模式与缺失的游戏概念

**Fixture:**
- Scenario (a)：没有 `design/gdd/game-concept.md`；`design/game-brief.md` 存在；`project.yaml` 中 `modes.review_mode: solo`，`modes.workflow: minimal`
- Scenario (b)：`design/gdd/game-concept.md` 和 `design/game-brief.md` 都不存在

**Input:** `/art-bible`

**Expected behavior:**
1. (a) Phase 0 读取一页式简报（工作标题、提案、“what they feel” 行、“Art & audio direction” 行）来替代游戏概念
2. (a) 在 Scope 问题之前，技能说明在 `minimal` 下不要求美术设定集，并提供第 1–4 节，而不是默认全部 9 节
3. (a) 仍会启动 `art-director` 起草每个已编写的小节——solo 评审模式跳过的是签核，而不是起草分派
4. (a) Phase 5 打印 “AD-ART-BIBLE skipped — Solo mode.”，不启动闸门代理；对 “May I record the skipped sign-off in `design/art/art-bible.md`'s header?” 回答同意后，状态头记录 `> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED [date] — solo mode`
5. (a) Phase 6 在 `workflow: minimal` 下提供 `/create-stories`、`/dev-story [next story]` 和 Stop here——而不是 `/create-architecture` 或 GDD/`/map-systems` 选项池
6. (b) 技能停止并提示：“No game concept found. Run `/brainstorm` first — the art bible is authored after the game concept is approved.”。不创建文件，也不启动代理

**Assertions:**
- [ ] (a) 游戏概念缺失时使用游戏简报
- [ ] (a) 技能在询问 Scope 问题之前说明在 `minimal` 下不要求美术设定集
- [ ] (a) solo 模式下 `art-director` 仍会起草各小节
- [ ] (a) 不启动 AD-ART-BIBLE；跳过说明为 “AD-ART-BIBLE skipped — Solo mode.”，且状态头记录带模式和日期的 SKIPPED 签核行
- [ ] (a) Phase 6 的选项池为 `workflow: minimal` 集合，而不是 `standard`/`full` 的 GDD 选项池
- [ ] (b) 技能以 `/brainstorm` 提示停止，不写入任何内容

---

## Protocol Compliance

- [ ] 在编写之前读取游戏概念（或游戏简报）；若两者都不存在，则以 `/brainstorm` 提示停止
- [ ] 每个小节都由专家代理起草；编排器绝不自起草内容
- [ ] 每个小节逐节呈现、批准和写入——审批和写入绝不批量处理
- [ ] 只有在 “May I create `design/art/art-bible.md`…” 询问之后才创建文件，且每个小节只有在明确指明写入的批准选项之后才写入
- [ ] 只编写所选范围内的部分，收尾会说明每个被排除的部分及原因
- [ ] `art-director` 与 `ux-designer` 或 `technical-artist` 之间的冲突会呈现给用户，绝不静默解决
- [ ] AD-ART-BIBLE 仅在 full 模式下、范围内小节写入之后运行；lean 和 solo 打印指明闸门和模式的跳过说明
- [ ] 以按项目状态筛选的下一步 `AskUserQuestion` 结尾——在 `standard`/`full` 下始终包含 `/create-architecture` 和 “Stop here”；在 `workflow: minimal` 下为 `/create-stories` 或 `/dev-story [next story]` 加 Stop here

---

## Coverage Notes

- AD-ART-BIBLE 的 REJECT 结论未单独测试；按标准结论规则，技能会指出阻塞项，
  在阻塞项解决之前不会继续推进，被标记的小节由其专家重新起草，
  并按 Case 2 (a) 重新批准。
- 在 `workflow: standard` 下，仅当存在视觉资源用户故事时才要求美术设定集。
  该条件未做 fixture 测试；Case 3 仅覆盖 `standard` 的范围推荐。
- 第 7 节（`art-director` 与 `ux-designer`）和第 8 节
  （`art-director` 与 `technical-artist`）的冲突处理仅在 Protocol Compliance
  中覆盖，没有专门的 fixture。
- “Asset standards only (section 8)” 范围选项未做 fixture 测试
  （Case 4 覆盖的是 “Resume”）。
- `docs.density` 的深度变化以及 `guided` / `autonomous` 自动化模式
  未测试。
- Phase 6 的选项筛选（当 `design/gdd/systems-index.md` 存在时跳过
  `/map-systems` 等）未单独测试。
