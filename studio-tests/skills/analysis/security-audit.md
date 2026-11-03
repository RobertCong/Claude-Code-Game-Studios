# Skill Test Spec: /security-audit

## Skill Summary

`/security-audit` 审计代码库中跨六个类别的常见游戏安全缺陷：存档/序列化、网络/多人、输入校验、数据暴露、作弊/防篡改向量和依赖。它接受一个范围（`full`、`network`、`save`、`input`、`quick`；不带参数时运行 `full`），从 `project.yaml` 读取 `engine.name`、`engine.language`、`platform.targets`、`platform.multiplayer` 和 `platform.online`，并用固定的简报模板启动 `security-engineer` 代理（agent）——仅填充其槽位：范围、引擎、`platform.*` 值、解析出的代码根、`assets/data/` 和配置文件、类别和报告路径——该模板自身的文本要求代理按其严重性表评定每个发现项，且游戏类型绝不会降低评级。Grep 模式按引擎从 Phase 3 表中选择；表中标记为该引擎 NOT SOURCEABLE 的类别为 NOT ASSESSED，且缺失的 `platform.multiplayer` 绝不会被读取为 `false`。被跳过的类别会点名并说明原因，代码根未解析则使代码类别为 NOT ASSESSED。发现项分为 CRITICAL / HIGH / MEDIUM / LOW，每个都包含文件、行号、攻击场景和修复建议。报告的发布建议按首个匹配优先：DO NOT SHIP、FIX BEFORE SHIPPING、NOT ASSESSED（例如 INSUFFICIENT IMPLEMENTATION）或 CLEAR TO SHIP。技能在对话中呈现执行摘要和 CRITICAL/HIGH 发现项，然后询问「May I write the full security audit report to `production/security/security-audit-[date]-[scope].md`?」在 `workflow: minimal` 下，Phase 7 消息说明发布质量闸门不读取该报告。不调用任何总监质量闸门。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`，且不含 `allowed-tools` / `model`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含结论关键词：CLEAR TO SHIP、FIX BEFORE SHIPPING、DO NOT SHIP、NOT ASSESSED，以及严重性 CRITICAL / HIGH / MEDIUM / LOW
- [ ] 包含点名 `production/security/security-audit-[date]-[scope].md` 的「May I write」措辞
- [ ] 具有下一步交接（Phase 7：`/security-audit quick`、`/gate-check release`、`/launch-checklist`）

---

## Director Gate Checks

无。该技能启动 `security-engineer` 专家来运行审计；这是其核心机制，而不是总监质量闸门。在任何评审模式下都不调用总监质量闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/AGENTS.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 单机 Godot 项目，无发现项

**Fixture:**
- `project.yaml`：`engine.name: godot`、`engine.language: gdscript`、`platform.multiplayer: false`、`platform.online: false`、`modes.rigor: standard`（因此 `workflow` 解析为 `standard`）；`modes.automation` 未设置（collaborative）
- `src/` 存放已实现的游戏：核心、玩法、UI 和存档系统中共有 42 个 `.gd` 文件
- `src/core/save_system.gd` 用 `FileAccess` 打开存档，校验校验和，并在使用前对每个加载值做边界检查
- `src/` 或 `assets/` 中任何地方都没有 API 密钥、机密、密码或令牌
- `addons/gdUnit4/` 是唯一的第三方依赖

**Input:** `/security-audit`

**Expected behavior:**
1. 无参数 → `full` 范围
2. 技能从 `project.yaml` 读取引擎、语言和平台键
3. 技能通过 `Agent` 用固定简报模板启动 `security-engineer`：范围、Godot/GDScript、`platform.multiplayer: false`、`platform.online: false`、代码根 `src/`、`assets/data/` 和配置文件、要运行的类别以及报告路径——槽位之外不添加任何内容
4. Category 1 使用 Godot 模式列表，包括 Godot 4 名称 `FileAccess`；Category 2 因两个平台键都明确为 `false` 而被跳过，执行摘要点名该跳过及其原因
5. Category 6 在 Dependency Inventory 中列出 `addons/gdUnit4/`
6. 执行摘要显示 42 个源文件在所有严重性上均为零发现项；Release recommendation: **CLEAR TO SHIP**
7. 技能呈现摘要，然后询问「May I write the full security audit report to `production/security/security-audit-[date]-full.md`?」
8. 写入后：「✅ No blocking security findings. Report written to `production/security/`. Include this path when running `/gate-check release`.」

**Assertions:**
- [ ] `security-engineer` 使用固定简报模板启动——范围、引擎/语言、`platform.*` 值以及以 `src/` 为根的源清单——且简报不添加任何严重性评级，也不评论游戏类型
- [ ] 存档处理按 Godot 4 名称（`FileAccess`）检查，而不只是 Godot 3 的 `File.open`
- [ ] 扫描硬编码凭据模式（`api_key`、`secret`、`password`、`token`、`private_key`）
- [ ] 执行摘要说明 Category 2 因 `platform.multiplayer` 和 `platform.online` 为 `false` 而被跳过——该跳过不是静默的
- [ ] Release recommendation 为 CLEAR TO SHIP
- [ ] 「May I write」先于报告写入

---

### Case 1b: 单机，一个 HIGH 发现项 — FIX BEFORE SHIPPING

**Fixture:**
- 同 Case 1，但 `src/core/save_system.gd` 在加载存档值时没有校验和或边界检查，因此编辑过的存档文件可解锁后期进度
- 没有其他发现项

**Input:** `/security-audit`

**Expected behavior:**
1. 该存档发现项被分类为 **HIGH**（绕过进度的存档篡改），并且**不会**被提升为 CRITICAL，因为 `platform.multiplayer` 为 `false`
2. Release recommendation: **FIX BEFORE SHIPPING**——存在一个未解决的 HIGH，没有 CRITICAL
3. 写入后：「⚠️ 1 HIGH finding(s) are open. The Polish → Release gate's
   security audit item requires none — fix them and re-run `/security-audit quick`
   before `/gate-check release`.」

**Assertions:**
- [ ] 发送给 `security-engineer` 的简报是固定模板：它不把该存档发现项称为 HIGH（或任何严重性），也不说单机游戏会降低标准——由代理依据其自身的表评定
- [ ] 在单机游戏中该发现项为 HIGH，而不是 CRITICAL
- [ ] Release recommendation 为 FIX BEFORE SHIPPING——有 HIGH 未解决时绝不 CLEAR TO SHIP，没有 CRITICAL 时也不 DO NOT SHIP
- [ ] ⚠️ HIGH 消息点名发布质量闸门的 security audit 项作为要求，并点名 `/security-audit quick` 和 `/gate-check release`
- [ ] 变体——在 `modes.rigor: minimal` 下建议仍为 FIX BEFORE SHIPPING，且消息说明 `minimal` 发布质量闸门不读取该报告，而不是点名该质量闸门项

---

### Case 2: 多人严重问题 — 客户端权威 RPC 与硬编码密钥

**Fixture:**
- `project.yaml`：`engine.name: godot`、`platform.multiplayer: true`、`platform.online: true`
- `src/net/combat_sync.gd` 第 42 行：`@rpc("any_peer") func apply_damage(target_id, amount)` 在没有发送者或范围校验的情况下应用 `amount`
- `src/online/leaderboard_client.gd` 第 8 行：`const API_KEY = "sk_live_..."`

**Input:** `/security-audit full`

**Expected behavior:**
1. Category 2 运行（多人游戏为 `true`），使用 Godot 网络模式（`MultiplayerPeer`、`rpc`、`@rpc` 等）
2. 未校验的 `apply_damage` RPC 是 CRITICAL 发现项（客户端决定结果，破坏多人游戏完整性）
3. 硬编码密钥属于凭据暴露（HIGH），因游戏为多人游戏而被按 CRITICAL 处理
4. 每个发现项写作 `SEC-NNN`，包含 Category、File 和 line、Description、Attack scenario、Remediation 和 Effort
5. Release recommendation 为 DO NOT SHIP——一个未解决的 CRITICAL 决定此结论
6. 技能呈现执行摘要和 CRITICAL/HIGH 发现项，然后询问「May I write」
7. Phase 7：「⛔ CRITICAL security findings must be resolved before any public release. Do not proceed to `/launch-checklist` until these are addressed.」，并在 `/gate-check release` 之前重新运行 `/security-audit quick`

**Assertions:**
- [ ] RPC 发现项引用 `src/net/combat_sync.gd` 及其行号，并给出攻击场景
- [ ] 硬编码密钥在多人游戏语境下被提升为 CRITICAL
- [ ] 每个发现项都带有具体的修复建议
- [ ] Release recommendation 为 DO NOT SHIP（存在未解决的 CRITICAL 发现项）——绝不是 FIX BEFORE SHIPPING 或 CLEAR TO SHIP
- [ ] 显示 ⛔ 消息，并阻止进入 `/launch-checklist`

---

### Case 3: 多人范围未设置 — 缺失不等于 `false`

**Fixture:**
- `project.yaml`：`engine.name: godot`；完全没有 `platform` 块
- `src/networking/lobby.gd` 定义了 `@rpc` 函数 `join_lobby()` 和 `send_chat()`
- `modes.automation` 未设置（collaborative）

**Input:** `/security-audit`

**Expected behavior:**
1. 技能发现 `platform.multiplayer` 和 `platform.online` 缺失
2. 技能不假定为单机，也不跳过 Category 2
3. 技能询问用户游戏是否有多人或在线功能
4. 回答「yes」后，Category 2 用 Godot 网络模式运行，并检查每个 `@rpc` 调用点的校验

**Assertions:**
- [ ] 缺失的 `platform.multiplayer` / `platform.online` 不被当作 `false`
- [ ] 技能询问用户游戏是否有多人或在线功能
- [ ] 不会因键缺失而跳过 Category 2
- [ ] 检查 `lobby.gd` 中未校验的 `@rpc` 入口点，任何缺口都连同修复建议一起报告
- [ ] 变体——在 `modes.automation: autonomous` 下无法提问：Category 2 仍运行，标记为 `NOT ASSESSED — multiplayer scope unconfirmed`，且建议绝不会是 CLEAR TO SHIP

---

### Case 4: 无可审计的实现面 — NOT ASSESSED — INSUFFICIENT IMPLEMENTATION

**Fixture:**
- `project.yaml`：`engine.name: godot`、`platform.multiplayer: false`、`platform.online: false`
- `src/` 存在但不含任何源文件；`assets/data/` 为空

**Input:** `/security-audit`

**Expected behavior:**
1. 代码根解析为 `src/`，但其中没有任何可审计内容
2. 每个代码扫描类别都没有文件可扫描，因此每个都是 NOT ASSESSED 而不是干净
3. Release recommendation: **NOT ASSESSED — INSUFFICIENT IMPLEMENTATION**
4. 报告点名缺失的内容（`src/` 下没有源文件）以及由哪个技能产出
5. 不报告 CLEAR TO SHIP

**Assertions:**
- [ ] 空代码根使每个代码扫描类别为 NOT ASSESSED；没有类别被报告为干净或零发现项
- [ ] Release recommendation 为 NOT ASSESSED — INSUFFICIENT IMPLEMENTATION
- [ ] 输出点名缺失的内容以及由哪个技能产出
- [ ] 在无可查看内容的扫描中，CLEAR TO SHIP 不可达
- [ ] 变体——没有 `engine.name`、`technical-preferences.md` 为 `[TO BE CONFIGURED]`、且 `src/` 和 `Source/` 都存在时，代码根未解析：不猜测任何根，代码类别显示 `NOT ASSESSED — code root unresolved`，且建议绝不会是 CLEAR TO SHIP

---

### Case 5: 完整评审模式下的 Unity 项目 — NOT SOURCEABLE 类别，无质量闸门

**Fixture:**
- `project.yaml`：`engine.name: unity`、`engine.language: csharp`、`platform.multiplayer: true`、`platform.online: true`、`modes.review_mode: full`
- `Assets/Scripts/Save/SaveManager.cs` 读写存档数据
- `Assets/Scripts/Net/PlayerNet.cs` 有会校验输入的 `[ServerRpc]` 方法
- 可运行的类别中没有发现项

**Input:** `/security-audit`

**Expected behavior:**
1. 传给 `security-engineer` 的清单以 `Assets/` 为根，而不是 `src/`
2. Category 1 对 Unity 为 `NOT SOURCEABLE` → `NOT ASSESSED`；不凭记忆编写任何 Unity 存档 API 名称
3. Category 2 和 3 使用 Phase 3 表中的 Unity 名称（`ServerRpc`、`ClientRpc`、`NetworkVariable` 等；`InputSystem`、`PlayerInput` 等），而不是 Godot 列表
4. 执行摘要点名 Category 1 为 NOT ASSESSED；Release recommendation: `NOT ASSESSED — Save / serialization has no sourced pattern set for Unity`
5. Phase 7 的 NOT ASSESSED 消息点名 Category 1 在 Unity 上为 NOT SOURCEABLE 及其修复——`docs/engine-reference/unity/modules/` 下的存档/序列化模块——而不是 `engine.name`、代码根或多人范围，这些都已提供
6. 无论评审模式如何，都不调用总监质量闸门
7. 技能在写入报告前询问「May I write」

**Assertions:**
- [ ] 源清单使用 Unity 代码根 `Assets/`
- [ ] Category 1 在 Unity 上为 NOT ASSESSED，且不臆造任何存档 API 模式列表
- [ ] Category 2 使用 Unity 网络名称，而不是 Godot 列表
- [ ] CLEAR TO SHIP 不可达；建议点名未找到来源的类别
- [ ] NOT ASSESSED 消息指向 `docs/engine-reference/unity/modules/` 下的序列化模块作为修复
- [ ] 在任何评审模式下都不调用总监质量闸门

---

### Case 5b: 排序 — 未解决的 HIGH 优先于未找到来源的类别

**Fixture:**
- `project.yaml`：`engine.name: unity`、`engine.language: csharp`、`platform.multiplayer: false`、`platform.online: false`
- `Assets/Scripts/` 存放已实现的游戏（35 个 `.cs` 文件），包括 `Assets/Scripts/Save/SaveManager.cs`
- `Assets/Scripts/Analytics/Telemetry.cs` 第 12 行：`const string ApiKey = "sk_live_...";`
- 没有其他发现项

**Input:** `/security-audit`

**Expected behavior:**
1. Category 1 对 Unity 为 `NOT SOURCEABLE`，因此为 NOT ASSESSED；Category 2 被跳过（两个平台键均为 `false`），并点名该跳过
2. 硬编码密钥属于凭据暴露：HIGH，且因游戏为单机而不提升为 CRITICAL
3. Release recommendation: **FIX BEFORE SHIPPING**——未解决的 HIGH 在 NOT ASSESSED 之前匹配
4. 执行摘要仍点名 Category 1 为 NOT ASSESSED

**Assertions:**
- [ ] Release recommendation 为 FIX BEFORE SHIPPING，而不是 NOT ASSESSED——已知缺陷不会被埋藏在未扫描类别之后
- [ ] Category 1 仍在执行摘要中报告为 NOT ASSESSED
- [ ] 不报告 CLEAR TO SHIP

---

## Protocol Compliance

- [ ] 在审计前从 `project.yaml` 读取 `engine.name`、`engine.language` 和 `platform.*` 键
- [ ] 通过 `Agent` 用固定简报模板启动 `security-engineer`——仅填充其命名槽位（范围、引擎/语言、`platform.*` 值、解析出的代码根、`assets/data/` 和配置文件、类别、报告路径）——不包含编排器自己的任何句子：不预先评定发现项，不说「single-player lowers the stakes」；代码根未解析会使代码类别为 NOT ASSESSED，而不是干净
- [ ] 使用解析出的引擎对应的 Phase 3 模式集；NOT SOURCEABLE 类别为 NOT ASSESSED，并使 CLEAR TO SHIP 不可达
- [ ] 绝不把缺失的 `platform.multiplayer` / `platform.online` 当作 `false`
- [ ] 在执行摘要中点名每个被跳过的类别及其原因
- [ ] 每个发现项都带有严重性、类别、文件和行号、攻击场景和修复建议
- [ ] Release recommendation 按首个匹配：DO NOT SHIP、FIX BEFORE SHIPPING、NOT ASSESSED、CLEAR TO SHIP
- [ ] 在询问「May I write」以写入 `production/security/security-audit-[date]-[scope].md` 之前呈现执行摘要和 CRITICAL/HIGH 发现项；仅在批准后写入
- [ ] 不调用任何总监质量闸门
- [ ] 以 Phase 7 的质量闸门集成指引结束

---

## Coverage Notes

- `network`、`save`、`input` 和 `quick` 范围未单独测试；它们按相同规则限制运行的类别。
- `engine.name` 缺失但目录树可解析（每个 grep 类别为 NOT ASSESSED，且不回退到 Godot 列表）的情况未单独测试。
- Unreal 遵循与 Case 5 相同的引擎表，未单独测试。
