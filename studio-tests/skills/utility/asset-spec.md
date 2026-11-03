# Skill Test Spec: /asset-spec

## Skill Summary

`/asset-spec` 把一个目标对象的视觉需求转化为带 AI 生成提示词的资源规格。
参数指定一个目标 —— `system:<name>`、`level:<name>` 或
`character:<name>`（资源清单（inventory）中的 `entity:` 条目按角色读取）——
外加可选的 `--review full|lean|solo`。它读取 `design/art/art-bible.md` 中的美术圣经
（若缺失则停止，除非适用最小路径例外）、`project.yaml` 中的 `performance.*` 与
`naming.*`，以及目标对象的源文档。它会与用户确认识别出的资源清单，为每个资源
起草一个 `ASSET-NNN` 区块，并在获得批准后把 **每个目标一个文件** 写入
`design/assets/specs/[target-name]-assets.md`，然后更新
`design/assets/asset-manifest.md`。资源 ID 在整个项目中按顺序递增。对已存在
规格文件的目标重新运行时，会在 "May I update" 之后原地更新该文件（保留已有
区块与 ID，追加新资源）。

解析出的评审模式决定由谁起草：`full` 并行派生 `art-director` 与
`technical-artist`，`lean` 只派生 `art-director`，`solo`（默认，经
`modes.rigor: minimal`）不派生任何代理；`modes.rigor: full` 也解析为 `full`。
每个被跳过的代理都会在输出中按名称声明。这些是起草咨询，不是质量闸门（gate）。
该技能产出一个产出物，而不是判断，因此没有运行结论（verdict）；它以一个
`AskUserQuestion` 收尾，提供下一个目标或 `/asset-audit`。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 对其错误恢复协议的 `BLOCKED` 关键字执行检查 3 通过；该技能按设计没有运行结论（产出物生产者），运行以 "Asset specs complete for **[target]**. What's next?" 收尾
- [ ] 对规格文件包含 "May I write" 措辞，对清单包含 "May I update"
- [ ] 具备下一步交接（`/asset-spec [next-context]`、`/asset-audit`）

---

## Director Gate Checks

没有闸门 ID，也没有 `/gate-check`。评审模式只控制起草代理：

- **Full mode**（`modes.rigor: full` 解析所得）：并行派生 `art-director` 与
  `technical-artist`
- **Lean mode**：只派生 `art-director`；输出会说明 "technical-artist skipped —
  Lean mode: technical constraints not validated."
- **Solo mode**（`modes.rigor: minimal` 下的默认值）：不派生任何代理；主会话
  从美术圣经推导规格，输出会点名两个被跳过的代理，并说明技术约束未经验证

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — Character spec in lean mode

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`（评审模式解析为 `lean`），并
  具有 `performance.*` 与 `naming.*` 的值
- `design/art/art-bible.md` 存在，含 Shape Language、Color System 与 Section 8 Asset Standards
- `design/narrative/characters/goblin-enemy.md` 存在，含视觉描述
- 没有 `design/assets/asset-manifest.md`

**Input:** `/asset-spec character:goblin-enemy`

**Expected behavior:**
1. 技能在询问任何内容之前先读取美术圣经、项目配置与角色文档
2. 技能呈现上下文摘要（"Asset Spec: Character — goblin-enemy"）
3. 阶段 2 识别该角色的资源（idle、walk、attack、death 等精灵图集；
   portrait；技能 VFX；UI 图标），按类别分组展示，并在编写规格前通过
   `AskUserQuestion` 询问
4. Lean 模式：只派生 `art-director`，并如此说明："technical-artist skipped —
   Lean mode: technical constraints not validated."
5. 阶段 4 为每个资源呈现一个 `ASSET-NNN` 区块，含字段表
   （Category、Dimensions、Format、Naming、Polycount、Texture Res）、Visual
   Description、引用相关章节的 Art Bible Anchors、Generation Prompt 以及 `Status: Needed`
6. 批准后询问 "May I write the spec to `design/assets/specs/goblin-enemy-assets.md`?"
7. 在询问 "May I update `design/assets/asset-manifest.md`?" 之后创建清单；
   ID 从 `ASSET-001` 开始
8. 阶段 6 的 `AskUserQuestion` 提供另一个目标或 `/asset-audit`

**Assertions:**
- [ ] 在生成任何规格之前，资源清单通过 `AskUserQuestion` 得到确认
- [ ] 只派生 `art-director`（lean 模式下没有 `technical-artist`）
- [ ] 输出点名 `technical-artist` 被跳过，并说明技术约束未经验证
- [ ] 每个资源区块都含字段表、按章节引用的 Art Bible Anchors、Generation Prompt 与 `Status: Needed`
- [ ] "May I write" 中指明 `design/assets/specs/goblin-enemy-assets.md`
- [ ] 清单被创建，含 Progress Summary，且 ID 从 `ASSET-001` 开始
- [ ] 阶段 6 在下一步选项中提供 `/asset-audit`

---

### Case 2: No Art Bible — Skill stops before speccing

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`
- `design/gdd/combat.md` 存在，含 Visual/Audio Requirements 章节
- `design/art/art-bible.md` 不存在
- `design/game-brief.md` 不存在

**Input:** `/asset-spec system:combat`

**Expected behavior:**
1. 阶段 1 查找 `design/art/art-bible.md`，未找到
2. 最小路径例外不适用（没有游戏简报）
3. 技能停止并提示："No art bible found. Run `/art-bible` first — asset specs are
   anchored to the art bible's visual rules and asset standards."
4. 不做资源识别，不派生代理，不写文件

**Assertions:**
- [ ] 显示 "No art bible found. Run `/art-bible` first" 消息
- [ ] 不呈现资源清单，也不发起 `Agent` 调用
- [ ] 不写入任何规格文件或清单
- [ ] 不用凭空编造的风格规则生成规格

---

### Case 3: Manifest Already Exists — IDs continue and shared assets are reused

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`；美术圣经存在
- `design/assets/asset-manifest.md` 存在；最高 ID 为 `ASSET-014`，且
  `ASSET-012`（Generic Hit Spark）已为 Combat 系统写规格到
  `design/assets/specs/combat-assets.md`
- `design/gdd/tower-defense.md` 的 Visual/Audio 章节列出一个命中火花与一个建塔 VFX

**Input:** `/asset-spec system:tower-defense`

**Expected behavior:**
1. 技能读取清单，并 glob `design/assets/specs/*.md` 查找可共享资源
2. 上下文摘要列出在其他规格中找到的共享资源
3. 命中火花复用 `ASSET-012` 而不创建重复项，并附注如
   "ASSET-012 (Generic Hit Spark) already specced for Combat system. Reusing for Tower Defense"
4. 新的建塔 VFX 编号为 `ASSET-015`
5. 在针对 `design/assets/specs/tower-defense-assets.md` 的 "May I write" 之后，技能询问
   "May I update `design/assets/asset-manifest.md`?"，追加一个 Tower Defense 上下文
   区块，并更新 Progress Summary 计数

**Assertions:**
- [ ] 命中火花引用 `ASSET-012`；不创建重复的命中火花规格
- [ ] 新资源的 ID 为 `ASSET-015`（项目级序列，不按目标重启）
- [ ] 在 "May I update" 询问之后，清单是追加而非重建
- [ ] Progress Summary 计数被更新

---

### Case 4: Several Assets in One Target — One file, per-asset revision before write

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`；美术圣经存在；无清单
- `design/gdd/combat.md` 的 Visual/Audio 章节列出命中火花 VFX、浮动的
  伤害数字（UI）与命中音效（audio）

**Input:** `/asset-spec system:combat`

**Expected behavior:**
1. 阶段 2 列出全部三个资源，分别归入 VFX、UI 与 Audio，并请用户确认
2. 阶段 4 呈现 `ASSET-001` 至 `ASSET-003`；音频资源包含其音色特征的
   描述，且没有图像生成提示词
3. 用户为伤害数字选择 `[B] Revise a specific asset`；技能就地修改它并
   重新呈现，不重新派生代理
4. 用户批准全部；技能只询问 **一次** "May I write"，目标为
   `design/assets/specs/combat-assets.md`，其中包含全部三个资源

**Assertions:**
- [ ] 一次 "May I write" 询问覆盖同一文件中的全部三个资源（不是每个资源一次询问或一个文件）
- [ ] 音频资源没有图像生成提示词
- [ ] 次要修改不重新派生 `art-director`
- [ ] 全部三个 `ASSET-NNN` 区块都在 `design/assets/specs/combat-assets.md` 中

---

### Case 5: Director Gate Check — Solo default, brief instead of art bible

**Fixture:**
- `project.yaml` 没有 `modes` 区块（评审模式经 `modes.rigor: minimal` 解析为 `solo`）
- `design/game-brief.md` 存在，含一行 Art & audio direction
- 没有 `design/art/art-bible.md`
- `design/narrative/` 或 `design/assets/entity-inventory.md` 中没有 `hero` 的角色档案

**Input:** `/asset-spec character:hero`

**Expected behavior:**
1. 最小路径例外适用：技能不停止，并在顶部声明
   "Anchored to the brief's one-line art direction; there is no art bible, so colour,
   shape and asset-standard rules below are proposals, not constraints."
2. `/art-bible` 作为可选项提供一次
3. 未找到档案 → `AskUserQuestion`："No profile found for **hero**. Describe it
   briefly"，选项为 Describe / Skip / Stop
4. Solo 模式：没有 `Agent` 调用；输出声明 "art-director and
   technical-artist skipped — Solo mode: specs derived in this session; technical
   constraints not validated."
5. 不出现闸门 ID，也不调用 `/gate-check`

**Assertions:**
- [ ] 技能在没有美术圣经的情况下继续，并说明规格锚定于简报
- [ ] 缺少档案触发 "Describe it briefly" 询问，而不是失败
- [ ] 不派生 `art-director` 或 `technical-artist`
- [ ] 两个被跳过的代理都在输出中点名，且输出说明技术约束未经验证
- [ ] 若写出规格，其头部把 `design/game-brief.md` 命名为美术方向来源（没有 `> **Art Bible**:` 行），每个资源携带 `**Brief anchor:**` 行而非 Art Bible Anchors，且不引用任何 Art Bible 章节或 §8 层级
- [ ] 不出现闸门 ID —— 跳过说明点名的是代理，不是闸门

---

### Case 6: Re-run on an Existing Spec — Updated in place, not overwritten

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`；美术圣经存在
- `design/assets/specs/goblin-enemy-assets.md` 存在，含 `ASSET-001` 至
  `ASSET-004`（idle、walk、attack 精灵图；portrait）；清单的最高 ID
  为 `ASSET-009`
- `design/narrative/characters/goblin-enemy.md` 此后新增了一项冲锋攻击
  能力

**Input:** `/asset-spec character:goblin-enemy`

**Expected behavior:**
1. 阶段 1 读取该目标的现有规格文件以及角色文档
2. 阶段 2 只提出新增内容 —— 冲锋攻击精灵图及其 VFX —— 并与用户
   确认该清单
3. 新资源的编号为 `ASSET-010` 与 `ASSET-011`（项目级序列）
4. 技能展示变更内容，然后询问 "May I update
   `design/assets/specs/goblin-enemy-assets.md`?" —— 而不是 "May I write"
5. `ASSET-001` 至 `ASSET-004` 在文件中保持不变；新块被追加

**Assertions:**
- [ ] 在提出资源清单之前，检测并读取现有规格文件
- [ ] 询问为 "May I update"，并指明现有文件
- [ ] 保留已有区块与 ID；文件不被整体覆盖
- [ ] 新资源延续项目级 ID 序列（`ASSET-010`、`ASSET-011`）

---

## Protocol Compliance

- [ ] 在询问用户任何内容之前读取美术圣经、项目配置与源文档
- [ ] 在用户确认资源清单之前绝不为资源编写规格
- [ ] 严格按照解析出的评审模式派生代理（`--review` 对单次运行覆盖），并在输出中点名每个被跳过的代理
- [ ] 暴露任何 art-director / technical-artist 冲突，而不是静默解决
- [ ] 新规格文件前询问 "May I write"，修改现有文件前询问 "May I update"，更新清单前询问 "May I update"
- [ ] 先读取清单，再在整个项目中按顺序分配资源 ID

---

## Coverage Notes

- 无参数流程（从 `design/assets/entity-inventory.md` 中选择下一个 "Needed" 项，
  或在阶段 0b 构建清单）未被单独测试。
- `level:` 目标以及带暴露出的 art-director / technical-artist 冲突的 full 模式
  并行派生未被单独测试。
- 代理 BLOCKED 处理（错误恢复协议：始终产出部分规格）未被单独测试。
