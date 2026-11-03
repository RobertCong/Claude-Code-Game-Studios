# Skill Test Spec: /settings

## Skill Summary

`/settings` 展示并修改项目配置。它有四种形式：
`/settings`（查看全部：每个生效设置及其来源）、`/settings
<key>`（查看单项）、`/settings <key>=<value>`（写入 `project.yaml`）以及
`/settings --local <key>=<value>`（把个人覆盖写入已被 git 忽略的
`project.local.yaml`）。其他任何输入，包括空键或空值，都会打印
用法区块。它运行在 Sonnet 模型上，并通过
`yaml-helper.sh`（`resolve_setting`、`get_yaml_key`、`is_locally_overridable`、
`validate_enum_value`）读取每个值，因此由 `modes.rigor` 预设提供的值会显示为
`(derived from rigor: <level>)`，而不是 "(not set)"。

每次写入都先按 schema 枚举校验，再通过
`AskUserQuestion` 批准闸门确认（`[A] Yes, write` / `[B] No, cancel`）。
对 `project.yaml` 的写入属于 `schema_changes` 决策，因此即使在
`autonomous` 模式下也会确认。`--local` 会拒绝不在本地覆盖
白名单中的键。`.trae/docs/effects-map.md` 用
`> ### RESERVED` 横幅标记的设置在被要求时会存储，但每种形式都会说明没有任何东西读取
它。该技能不给出结论：它打印并写入配置。不适用任何总监
闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 至少有 2 个阶段标题
- [ ] 不要求结论关键字：输出是配置，而不是判断（对本次技能，`/skill-test static` 的检查 3 给出 WARN，绝不给出 FAIL）
- [ ] 两个写入阶段都在 `Edit` 或 `Write` 之前用 `AskUserQuestion` 请求批准
- [ ] 保留集来自 `effects-map.md` 的 `> ### RESERVED` 标题，而非硬编码
- [ ] 指向 `.trae/docs/settings-guidance.md` 以了解该选择哪个值

---

## Director Gate Checks

无。`/settings` 是配置工具。不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: Happy Path — view-all shows derived values, a local override and the legend

**Fixture:**
- `project.yaml`：
  ```yaml
  framework:
    version: 1.2.0
  modes:
    rigor: full
    automation: collaborative
  docs:
    density: terse
  engine:
    name: Godot
  ```
- `project.local.yaml`：
  ```yaml
  modes:
    automation: autonomous
  ```

**Input:** `/settings`

**Expected behavior:**
1. 报告两个文件都存在且 `Schema validation: ok`
2. 列出每个文件叶子，然后追加文件未设置的 rigor 家族：
   `modes.workflow`、`qa.level`、`modes.story_granularity`、`modes.review_mode`
   与 `team.size`，各自标注 `(derived from rigor: full, …)`
3. `docs.density: terse` 标注为 `(project.yaml, locked)` —— 显式
   值胜过 `rigor: full` 会提供的 `thorough`
4. `modes.automation: autonomous` 标注为
   `(LOCAL OVERRIDE — yaml has: collaborative)`
5. 叶子按顶层区块分组（`modes:`、`docs:`、`qa:`、…），而不是
   按来源文件分组
6. 区块下方是两行图例：`locked` 表示它不能在 `project.local.yaml`
   中被覆盖，也不表示固定不变
7. 不写入任何文件

**Assertions:**
- [ ] 五个由 rigor 派生的旋钮都以真实值出现，没有一个是 "(not set)"
- [ ] 显式的 `docs.density` 显示其自身值与来源，而非预设值
- [ ] 本地覆盖点名它所遮蔽的 `project.yaml` 值
- [ ] 打印 `locked` 图例，并说明派生值仍可显式设置
- [ ] 不写入任何内容

---

### Case 2: View-one — a rigor-derived key says how to set it

**Fixture:**
- `project.yaml` 设置 `modes.rigor: standard`，未设置 `qa.level`

**Input:** `/settings qa.level`

**Expected behavior:**
1. 打印 `Effective value: standard` 与 `Source: derived from rigor: standard`
2. 增加一行 `Set explicitly with: /settings qa.level=<value>   (an explicit value wins over rigor)`
3. `Locally overridden: no`；白名单行显示 `locked — project-wide`

**Assertions:**
- [ ] 值来自 rigor 展开，不是 "(not set)"
- [ ] 对派生值显示 "Set explicitly with" 行
- [ ] 不写入任何内容

---

### Case 3: Set-yaml — changing `modes.rigor` reports the six knobs it moves

**Fixture:**
- `project.yaml`：
  ```yaml
  modes:
    rigor: minimal
    automation: collaborative
  docs:
    density: thorough
  ```
- 用户回答 `[A] Yes, write`

**Input:** `/settings modes.rigor=standard`

**Expected behavior:**
1. `validate_enum_value modes.rigor standard` 通过
2. `AskUserQuestion` 询问 ``Set `modes.rigor=standard` in `project.yaml`?``
   并提供 `[A] Yes, write` / `[B] No, cancel`
3. `Edit` 以 `modes:` 行加 `rigor: minimal` 行为锚点，只改动该值；
   不新增第二个 `modes:` 区块
4. 确认 ``Set `modes.rigor=standard` in `project.yaml`.``，并列出六个旋钮
   现在解析为什么值，通过 `resolve_setting` 重新读取：
   `modes.workflow: standard`、`qa.level: standard`、
   `modes.story_granularity: balanced`、`modes.review_mode: lean`、
   `team.size: individual`（各自派生自 rigor: standard）以及
   `docs.density: thorough`（`project.yaml` —— 显式，未变）

**Assertions:**
- [ ] 在编辑文件之前请求批准
- [ ] `project.yaml` 仍恰好有一个 `modes:` 区块，含 `rigor: standard`
- [ ] 六旋钮清单把显式的 `docs.density` 显示为未变，而不是 `balanced`
- [ ] `project.yaml` 的其他行不变

---

### Case 4: Invalid value — rejected before any question

**Fixture:**
- `project.yaml` 设置 `modes.review_mode: lean`

**Input:** `/settings modes.review_mode=chaotic`

**Expected behavior:**
1. `validate_enum_value` 返回 1；其消息原样显示：
   `Invalid value 'chaotic' for 'modes.review_mode'. Allowed: ...`
2. 技能退出：无批准问题、无写入

**Assertions:**
- [ ] 原样显示辅助脚本的报错行，并点名允许的值
- [ ] 不询问 `AskUserQuestion`
- [ ] `project.yaml` 不变

---

### Case 5: `--local` on a locked key — refused with the team-wide route

**Fixture:**
- `project.yaml` 设置 `engine.name: Godot`；无 `project.local.yaml`

**Input:** `/settings --local engine.name=Unity`

**Expected behavior:**
1. `is_locally_overridable engine.name` 返回 1
2. 一行：``engine.name cannot be locally overridden — it's a project-wide setting. Use `/settings engine.name=Unity` (no `--local`) to change it for the whole team.``
3. 技能退出且不写入

**Assertions:**
- [ ] 拒绝信息点名 `/settings <key>=<value>` 途径
- [ ] 不询问批准问题
- [ ] 不创建 `project.local.yaml`

---

### Case 6: `--local` on a whitelisted key — creates the override file

**Fixture:**
- `project.yaml` 存在且含 `modes.automation: collaborative`；无
  `project.local.yaml`
- 用户回答 `[A] Yes, write`

**Input:** `/settings --local modes.automation=autonomous`

**Expected behavior:**
1. 白名单与枚举检查通过
2. `AskUserQuestion` 询问 ``Set `modes.automation=autonomous` in `project.local.yaml` (your personal override, gitignored)?``
3. 创建 `project.local.yaml`，把值放入其 `modes:` 父
   区块中
4. 确认 ``Set `modes.automation=autonomous` in `project.local.yaml` (your override).``

**Assertions:**
- [ ] 在创建文件之前请求批准
- [ ] 新文件把键嵌套在 `modes:` 下，而不是作为点分隔的顶层行
- [ ] `project.yaml` 不变

---

### Case 7: Reserved setting — stored on request, flagged on every form

**Fixture:**
- `.trae/docs/effects-map.md` 为现行文件；选择一个其章节
  带有 `> ### RESERVED` 横幅的键（本规格编写时为 `accessibility.target` ——
  用技能自身的 grep 重新推导）
- `project.yaml` 未设置该键；用户回答 `[A] Yes, write`

**Input:** `/settings accessibility.target=standard`，然后 `/settings`，再
`/settings accessibility.target`

**Expected behavior:**
1. 写入在批准问题之前打印："Note: `accessibility.target`
   is RESERVED — no skill or hook reads it, so setting it will not change any
   behaviour. Your value is stored either way."
2. 回答 yes 后写入该值 —— 技能从不拒绝保留键
3. 查看全部在叶子上标注 `, reserved`，并在区块下方打印保留
   图例
4. 查看单项在值区块上方（而非下方）打印 "**`accessibility.target` is RESERVED — nothing reads it.**"

**Assertions:**
- [ ] 警告出现在批准问题之前
- [ ] 回答 yes 后写入该值
- [ ] 查看全部与查看单项都标记该键为保留
- [ ] 仅在正文中提及该横幅的键（`platform.cert_tier`）不被标记为保留

---

### Case 8: Shadowed write and autonomous mode — still asked, with the shadow named

**Fixture:**
- `project.yaml` 设置 `modes.review_mode: lean` 与 `modes.automation: autonomous`
- `project.local.yaml` 设置 `modes.review_mode: solo`
- 用户回答 `[A] Yes, write`

**Input:** `/settings modes.review_mode=full`

**Expected behavior:**
1. 在批准问题之前："Note: this setting is currently locally
   overridden in `project.local.yaml` (value: `solo`). Writing to `project.yaml`
   will not change your effective value."
2. 尽管 `modes.automation` 为 `autonomous`，仍会询问批准问题：
   对 `project.yaml` 的写入属于 `schema_changes` 决策，它在
   默认的始终询问清单上
3. `project.yaml` 得到 `review_mode: full`；`project.local.yaml` 不变

**Assertions:**
- [ ] 遮蔽提示点名本地值，且出现在问题之前
- [ ] autonomous 模式不跳过批准问题
- [ ] 只编辑 `project.yaml`

---

### Case 9: Malformed operand — usage, no write

**Fixture:**
- `project.yaml` 存在

**Input:** `/settings --local modes.automation=`（以及另外单独
`/settings =full`）

**Expected behavior:**
1. 空值（或空键）路由到阶段 6
2. 打印用法区块，含四种形式与三个示例
3. 不校验、不询问、不写入任何内容

**Assertions:**
- [ ] 两种输入都打印用法区块
- [ ] 不询问批准问题，文件不变

---

## Protocol Compliance

- [ ] 每次写入之前都有 `AskUserQuestion` 批准闸门；`[B] No, cancel` 使两个文件都保持不变
- [ ] 在批准问题之前用 `validate_enum_value` 校验值
- [ ] 用 `resolve_setting` 读取值，因此派生值会显示其 rigor 来源
- [ ] `--local` 只写入白名单键，且在没有 `project.yaml` 时绝不创建 `project.local.yaml`
- [ ] 在查看全部、查看单项与两条写入路径上都标记保留键
- [ ] 每次辅助脚本调用都从项目根目录、在 sourcing `yaml-helper.sh` 的同一 Bash 命令中运行

---

## Coverage Notes

- 一个或两个文件存在 schema 错误时的查看全部、阶段 4 的 Case D（没有干净的
  插入点）以及在子文件夹中启动的会话，未单独做
  夹具测试。
- 缺失 `project.yaml` 的停止情形（查看全部，以及没有基础文件时的 `--local`）
  与缺失 `yaml-helper.sh` 的情形未单独做夹具测试。
