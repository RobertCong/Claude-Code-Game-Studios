---
name: security-audit
description: "安全审计——存档篡改、作弊途径、网络漏洞利用、数据暴露、输入验证。在公开发布或多人发布之前使用。"
argument-hint: "[full | network | save | input | quick]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（协作模式始终询问 · 引导模式仅询问重大决策 · 自主模式记录并继续；
`automation_always_ask` 类别始终询问）。

**`workflow`**（上一步命令的输出已解析）只决定 Phase 7 就发布闸门告诉你什么：
在 `standard` 和 `full` 下它需要本报告；在 `minimal` 下不需要。
审计本身在每个层级都以相同方式运行。

# 安全审计

对任何已发布的游戏来说，安全都不是可选项。即便是单人游戏也有
存档篡改途径。多人游戏则有作弊面、数据暴露
风险和拒绝服务可能。本技能系统性地审计代码库中
最常见的游戏安全失效，并产出一份按优先级排序的
修复计划。

**运行本技能的时机：**
- 在任何公开发布之前（`workflow: standard` 和 `full` 下 Polish → Release 闸门要求如此）
- 在启用任何在线/多人功能之前
- 在实现任何从磁盘或网络读取的系统之后
- 当报告安全相关缺陷时

**输出：** `production/security/security-audit-[date]-[scope].md`——文件名中的
范围可防止同日的 `quick` 或 `save` 运行覆盖发布闸门所读取的 `full`
报告。

---

## Phase 1: 解析参数与范围

**模式：**
- `full`——所有类别（发布前推荐）
- `network`——仅网络/多人
- `save`——仅存档文件与序列化
- `input`——仅输入验证与注入
- `quick`——仅高严重度检查（最快，用于迭代使用）
- 无参数——运行 `full`

读取 `project.yaml` 以确定以下内容，当某个键缺失或为空时回退到 `.trae/docs/technical-preferences.md` 的引擎/语言/平台：
- `engine.name` 和 `engine.language`——**承重项：它们选择 Phase 3
  的模式集，而某个类别若没有针对该引擎的已溯源集合，该
  类别即成为 `NOT ASSESSED`。** 如果 `engine.name` 缺失或为空，在
  报告中说明，并把每个 grep 类别都视为 `NOT ASSESSED`；不要回退到
  Godot 列表，因为它们只是恰好被完整写出的那些
- `platform.targets`（影响哪些攻击面适用）
- `platform.multiplayer` 和 `platform.online`——多人/联网是否
  在范围内。`technical-preferences.md` 没有等价字段，因此旧版
  回退无法提供它们。

  > **缺失不等于 `false`。** 这些键有一个读取者——
  > 本技能——而**在设置流程中没有任何写入者**：`/setup-engine` 和
  > `/start` 都不产生 `platform:` 块，只有 `/settings`
  > 会设置它们，且要有人运行它，因此在大多数 CCGS 项目中这两个键都
  > 缺失。把它们默认为 `false` 会**在每个项目上跳过类别 2（网络与
  > 多人安全），包括真正的多人项目**——一个安全类别在一个无人设置的值上
  > 失效开放。
  >
  > 当任一键缺失或为空时：**不要假设是单人游戏，也不要
  > 跳过类别 2。** 询问用户游戏是否有多人或在线
  > 功能。如果无法询问，仍然运行类别 2 并将其标记为
  > `NOT ASSESSED — multiplayer scope unconfirmed (platform.multiplayer unset —
  > set it with /settings)`，根据 Phase 5 这会使 `CLEAR TO SHIP` 不可达。
  > 在范围未确认期间，按多人游戏评定严重度——一个
  > 未决的 HIGH 此时即为 DO NOT SHIP——并在报告中说明该评级假设了
  > 多人，正如 `security-engineer` 所做的那样。
  > 多扫描一个单人游戏只花几分钟；少扫描一个
  > 多人游戏则会让该类别未运行就发布。
  >
  > 用 `/settings platform.multiplayer=true` 显式设置它们（它们是
  > 项目级的，因此 `--local` 会被拒绝）。把它记录到 `project.yaml` 才是
  > 修复；本规则是有人这么做之前的守护。

---

## Phase 2: 派生安全工程师

通过 `Agent` 派生 `security-engineer`——审计是它的职责，因此不要
改在本会话中运行各类别。如果无法派生，说明原因，在此运行扫描，
并让报告的 **Audited by** 行说明这一点。

**发送以下固定简报模板。** 只填写 `{…}` 槽位，来源为
`project.yaml`（否则技术偏好）、按
`.trae/docs/code-root-resolution.md` 解析的代码根，以及原样复制的 Phase 3 文本。
不要添加任何其他内容：不对游戏类型发表看法，不预期严重度，不对
任何发现发表意见——你自己的一句话正是预评级混入的地方。

```text
Run a security audit of this project for /security-audit.

Scope: {full | network | save | input | quick}
Engine: {engine.name} {engine.version}, language {engine.language}
platform.multiplayer: {true | false | unset}    platform.online: {true | false | unset}    Phase 1 answer: {multiplayer | single-player | not asked}
Code root: {the resolved code root, or "unresolved"}
Also scan: {assets/data/ and the config files that exist, or "none"}
Categories to run, with their checks and grep patterns for this engine:
{each Phase 3 category this scope runs, copied as written, with the table's row for this engine}
NOT SOURCEABLE on this engine: {categories, or "none"} — report each NOT ASSESSED; never call it reviewed, verified safe or passed
Skipped, with reason: {e.g. "Category 2 — platform.multiplayer and platform.online are false", or "none"}
Report: production/security/security-audit-{date}-{scope}.md — return the report as text; /security-audit writes the file after asking

Severity (rate every finding yourself, against this table only):
- CRITICAL: Remote code execution, data breach, or trivially-exploitable cheat that breaks multiplayer integrity
- HIGH: Save tampering that bypasses progression, credential exposure, or server-side authority bypass
- MEDIUM: Client-side cheat enablement, information disclosure, or input validation gap with limited impact
- LOW: Defence-in-depth improvement — hardening that reduces attack surface but no direct exploit exists
Nothing in this brief sets or suggests a severity. The game's type never lowers a rating: a single-player game is rated on the same table. The one adjustment is upward — when the game is multiplayer, or its scope is unconfirmed (unset and not answered), a HIGH counts as CRITICAL; say so where it applies.
Report each finding as SEC-NNN with category, file:line, description, attack scenario, remediation and effort, grouped by severity.
```

模板已携带评级规则，因此没有什么需要重述：表格
已经把绕过进度的存档篡改评为 HIGH，代理
对照它评定每项发现，而 Phase 5 对
建议应用多人规则。

如果代码根未解析，不要传入猜测的：每个扫描代码
的类别都是 `NOT ASSESSED — code root unresolved`，报告也如此说明。
空代码根属于 Phase 5 的实现不足情形，而每个
扫描代码的类别都读作 `NOT ASSESSED — no source under <root>`，而不是零
发现。两者都绝不报告为干净。

security-engineer 跨 6 个类别运行审计（见 Phase 3）。在继续之前收集其完整发现。

---

## Phase 3: 审计类别

security-engineer 评估以下每一项。跳过不适用于项目范围的类别，
并在执行摘要中点名每个被跳过的类别及原因
（`Category 2 — skipped: platform.multiplayer and
platform.online are false`）。

### 引擎模式集——在阅读下面任何类别之前先读这里

**类别 1–3 中的每个模式列表都是为 Godot 写的。** 在 Unity 或
Unreal 项目中它们什么都匹配不到，而零命中扫描会让报告显得干净，
“这是安全审计中最危险的失败形态”。使用 Phase 1 中解析出的
`engine.name` 对应的表格。

| 类别 | Godot | Unity | Unreal |
|---|---|---|---|
| 1——存档 / 序列化 | 下文 Godot 列表 | **NOT SOURCEABLE** | **NOT SOURCEABLE** |
| 2——网络 / 多人 | 下文 Godot 列表 | `ServerRpc`、`ClientRpc`、`NetworkVariable`、`NetworkObject`、`NetworkManager`、`NetworkBehaviour`、`IsServer`、`IsOwner` | `UFUNCTION`、`Server`、`Client`、`NetMulticast`、`Replicated`、`DOREPLIFETIME`、`GetLifetimeReplicatedProps`、`HasAuthority` |
| 3——输入 | 下文 Godot 列表 | `InputSystem`、`PlayerInput`、`ReadValue`、`InputValue` | `EnhancedInput`、`UInputAction`、`InputMappingContext`、`BindAction`、`FInputActionValue` |
| 4——数据暴露 | 引擎无关——下文列表适用于三者 | | |
| 5、6 | 判断与清单，不是 grep——不需要引擎集合 | | |

上表中的 Unity 与 Unreal 名称**溯源自本仓库固定的
参考资料**（`docs/engine-reference/unity/modules/{networking,input}.md`、
`docs/engine-reference/unreal/modules/{networking,input}.md`），而非凭记忆。
使用前对照固定版本核验它们，并补充参考文档中本文表格省略的内容——
它是下限，不是完整集合。

> **`NOT SOURCEABLE` 是判定，不是要靠记忆填补的缺口。** 两棵
> 参考树都不包含序列化/存档模块，因此 Unity 和 Unreal 的存档 API 名称
> 在此无法确认。**不要凭训练数据写它们。** 一个自信却错误的模式列表
> 在本技能中比在任何其他技能中更糟：它产生的扫描看起来彻底、什么也没找到，
> 并读起来像通过。在表格说 NOT SOURCEABLE 的地方，该类别在此引擎下
> 是 **`NOT ASSESSED`**——见 Phase 5。要正确闭合它，请向
> `docs/engine-reference/<engine>/modules/` 添加一个像其他模块一样溯源的
> 存档/序列化模块；当它存在时，从其中取该类别的模式名称，在
> 报告中引用它，该类别即可运行。


### Category 1: 存档文件与序列化安全
- 加载前是否验证存档文件？（无盲目反序列化）
- 存档文件路径是否由用户输入构造？（路径遍历风险）
- 存档文件是否有校验和或签名？（篡改检测）
- 游戏是否在没有边界检查的情况下信任存档文件中的数值？
- 存档加载附近是否有任何 eval() 或动态代码执行调用？

Grep 模式——**在信任此列表前检查固定的引擎参考**
（见下方 API 名称警告）：`FileAccess`、`File.open`、`open(`、`load`、
`deserialize`、`parse`、`parse_string`、`from_json`、`read_file`、`get_var`、
`bytes_to_var`——逐一检查验证。

> **API 名称是版本特定的，此列表是起点，不是
> 完整集合。** `File.open` 是 **Godot 3.x**；Godot 4 将该类重命名为
> `FileAccess`（`docs/engine-reference/godot/breaking-changes.md`）。在依赖
> 这些模式之前，阅读 `docs/engine-reference/<engine>/` 中本项目
> 固定版本对应的内容，并补充其中记录的名称。grep 一个已不存在的类
> 会返回零命中，而**本类别中的零命中会让报告显得干净**——这是安全审计
> 中最危险的失败形态。仅搜索 `File.open` 对 Godot 4 项目什么都找不到，
> 会在一个无人检查的代码库上报告 CLEAR TO SHIP。如果你无法确认固定版本的
> 正确名称，请在报告中说明，而不是把零命中扫描当作通过。

### Category 2: 网络与多人安全（仅单人时跳过）
- 游戏状态是否在服务器上具有权威性，还是由客户端决定结果？
- 传入的网络数据包是否验证了大小、类型和值范围？
- 玩家位置和状态变更是否在服务器端验证？
- 对任何网络调用是否有限流？
- 认证令牌是否被正确处理（绝不以明文发送）？
- 游戏是否在发布构建中暴露任何调试端点？

Grep：`recv`、`receive`、`PacketPeer`、`socket`、`MultiplayerPeer`、
`ENetMultiplayerPeer`、`NetworkedMultiplayerPeer`、`rpc`、`rpc_id`、
`@rpc`——逐一检查调用点的验证。

> 与类别 1 相同的版本警示。`NetworkedMultiplayerPeer` 是 **Godot 3.x**；
> Godot 4 使用 `ENetMultiplayerPeer`
> （`docs/engine-reference/godot/modules/networking.md`）。裸子串
> `MultiplayerPeer` 两者都能匹配，是更安全的探测。

### Category 3: 输入验证
- 是否有任何玩家提供的字符串被用于文件路径？（路径遍历）
- 是否有任何玩家提供的字符串未经净化就被记录？（日志注入）
- 数值输入（例如物品数量、角色属性）在使用前是否做了边界检查？
- 成就/统计值在写入任何后端之前是否检查？

Grep：`get_input`、`Input.get_`、`input_map`、面向用户的文本字段——检查验证。

### Category 4: 数据暴露
- 是否有任何 API 密钥、凭证或机密硬编码在代码根或 `assets/` 中？
- 发布构建中是否包含调试符号或冗长的错误消息？
- 游戏是否把敏感玩家数据记录到磁盘或控制台？
- 是否有任何内部文件路径或系统信息暴露给玩家？

在面向发布的代码中大小写不敏感地 grep：`api[_-]?key`、`secret`、
`password`、`token`、`private[_-]?key`、`sk_live`、`BEGIN PRIVATE KEY`、`DEBUG`，
以及引擎的打印调用（Godot 上 `print(`、Unity 上 `Debug.Log`、Unreal 上
`UE_LOG`）。

### Category 5: 作弊与防篡改途径
- 玩法关键数值是否只存储在内存中，而不是易于编辑的文件中？
- 是否有任何关键游戏进度标志（例如“已付费购买 DLC”）在服务器端验证？
- 对多人游戏，是否有针对内存编辑工具（Cheat Engine 等）的任何防护？
- 排行榜/分数提交在接受前是否验证？

注意：客户端反作弊基本上无法执行。对任何竞争性或商业化内容，重点放在服务器端验证。

### Category 6: 依赖与供应链
- 是否使用了任何第三方插件或库？列出它们。
- 任何插件在使用版本中是否有已知 CVE？
- 插件来源是否经过核实（官方市场、经审阅的仓库）？

Glob：`addons/`、`plugins/`、`third_party/`、`vendor/`——列出所有外部依赖。

---

## Phase 4: 对发现分类

为每项发现分配：

**严重度：**
| 级别 | 定义 |
|-------|-----------|
| **CRITICAL** | 远程代码执行、数据泄露，或破坏多人完整性的可轻易利用作弊 |
| **HIGH** | 绕过进度的存档篡改、凭证暴露，或服务器端权威绕过 |
| **MEDIUM** | 客户端作弊启用、信息泄露，或影响有限的输入验证缺口 |
| **LOW** | 纵深防御改进——减少攻击面但不存在直接利用的加固 |

**状态：** Open / Accepted Risk / Out of Scope

---

## Phase 5: 生成报告

```markdown
# Security Audit Report

**Date**: [date]
**Scope**: [full | network | save | input | quick]
**Engine**: [engine + version]
**Audited by**: [security-engineer via /security-audit | this session — security-engineer not spawned: reason]
**Files scanned**: [N source files, N config files]

---

## Executive Summary

| Severity | Count | Must Fix Before Release |
|----------|-------|------------------------|
| CRITICAL | [N] | Yes — all |
| HIGH | [N] | Yes — all |
| MEDIUM | [N] | Recommended |
| LOW | [N] | Optional |

**Release recommendation**: [NOT ASSESSED — INSUFFICIENT IMPLEMENTATION / CLEAR TO SHIP / FIX BEFORE SHIPPING / DO NOT SHIP]

Choose it by the open findings, first match wins:
- **DO NOT SHIP** — any open CRITICAL finding (in a multiplayer game, any open HIGH
  counts as CRITICAL)
- **FIX BEFORE SHIPPING** — open HIGH findings and no CRITICAL; the Polish → Release
  gate needs zero open HIGH (at `standard` and `full`)
- **NOT ASSESSED** — per the rule below, when the scan could not cover the surface.
  It ranks below both failure values — a known finding is more actionable than an
  unscanned category, and still has to be fixed — and above CLEAR TO SHIP
- **CLEAR TO SHIP** — no open CRITICAL or HIGH (MEDIUM and LOW may remain)

> **`NOT ASSESSED` is required when there was not enough implemented surface to
> audit**, or when the API names for the pinned engine version could not be
> confirmed — **in place of CLEAR TO SHIP, never of a failure value.** An open
> CRITICAL or HIGH still decides the recommendation (first match above): a run
> with an unscanned category and an open HIGH is FIX BEFORE SHIPPING, and names
> the unscanned category beside it. A zero-finding scan over two files of source is not a clean bill of
> health, and `CLEAR TO SHIP` must never be reachable by having nothing to look
> at. Name what was missing and which skill produces it.
>
> **The engine axis is part of that rule, not a separate one.** If
> the Phase 3 table marks a category `NOT SOURCEABLE` for this project's
> `engine.name`, that category is `NOT ASSESSED` — state it by name in the
> Executive Summary, and **`CLEAR TO SHIP` is unreachable for the run**. The
> category reads `NOT ASSESSED — <category> has no sourced pattern set for
> <engine>`; the release recommendation is still the first match above, so it is
> NOT ASSESSED only where the run would otherwise have been CLEAR TO SHIP. Never
> report the category as reviewed by other means: files it covers may still be
> read for another category, and a finding that read turns up is reported, but
> the category stays NOT ASSESSED — never "reviewed", "verified safe" or passed.
> A scan that could not look is not a scan that found nothing, and only the
> report can tell the reader which of the two happened.

---

## CRITICAL Findings

### SEC-001: [Title]
**Category**: [Save / Network / Input / Data / Cheat / Dependency]
**File**: `[path]` line [N]
**Description**: [What the vulnerability is]
**Attack scenario**: [How a malicious user would exploit it]
**Remediation**: [Specific code change or pattern to apply]
**Effort**: [Low / Medium / High]

[repeat per finding]

---

## HIGH Findings

[same format]

---

## MEDIUM Findings

[same format]

---

## LOW Findings

[same format]

---

## Accepted Risk

[Any findings explicitly accepted by the team with rationale]

---

## Dependency Inventory

| Plugin / Library | Version | Source | Known CVEs |
|-----------------|---------|--------|------------|
| [name] | [version] | [source] | [none / CVE-XXXX-NNNN] |

---

## Remediation Priority Order

1. [SEC-NNN] — [1-line description] — Est. effort: [Low/Medium/High]
2. ...

---

## Re-Audit Trigger

Run `/security-audit` again after remediating any CRITICAL or HIGH findings.
At `workflow: standard` and `full`, the Polish → Release gate requires this report with no open CRITICAL or HIGH items.
```

---

## Phase 6: 写报告

在对话中呈现报告摘要（仅执行摘要 + CRITICAL/HIGH 发现）。

询问：“我可以把完整的安全审计报告写入 `production/security/security-audit-[date]-[scope].md` 吗？”

仅在批准后写入。

---

## Phase 7: 闸门集成

本报告是 `workflow: standard` 和 `full` 下 **Polish → Release 闸门**的必需产出物；
`minimal` 闸门则连同冒烟测试和 S1 缺陷之外的一切一起放弃它。根据上一步命令输出中的 `workflow`，
说明本项目适用哪一种。

修复发现后，重新运行：`/security-audit quick` 确认 CRITICAL/HIGH 项已解决，再运行 `/gate-check release`。

依据发布建议分支，而不是仅依据发现计数：

如果是 **DO NOT SHIP**（未决的 CRITICAL，或多人游戏中的未决 HIGH）：
> “⛔ 在任何公开发布之前必须解决 CRITICAL 安全发现。在这些问题得到处理之前，不要继续执行 `/launch-checklist`。”

如果是 **FIX BEFORE SHIPPING**（未决 HIGH、无 CRITICAL、单人）：
> 在 `workflow: standard`/`full` 下：“⚠️ 有 [N] 项 HIGH 发现未决。Polish → Release 闸门的安全审计项要求为零——请修复它们，并在 `/gate-check release` 之前重新运行 `/security-audit quick`。”
>
> 在 `minimal` 下：“⚠️ 有 [N] 项 HIGH 发现未决——请修复它们，并在发布之前重新运行 `/security-audit quick`。`minimal` 发布闸门不读取本报告；未决的 HIGH 仍使建议为 FIX BEFORE SHIPPING。”

如果是 **NOT ASSESSED**：
> “安全审计 NOT ASSESSED——[每个未评估的类别及原因]。报告已
> 写入。[在 `workflow: standard`/`full` 下：]在提供 [缺失的输入] 并重新运行审计之前，
> `/gate-check release` 会将其安全项报告为
> NOT ASSESSED。[在 `minimal` 下：]`minimal` 发布闸门不读取本报告，
> 但在提供 [缺失的输入] 之前，这些类别仍未被扫描。”
>
> 为每个类别点名缺失的输入：`engine.name`、代码根、
> 多人范围（`/settings platform.multiplayer=…`），或者——对于 Phase 3 表格
> 在此引擎上标记为 NOT SOURCEABLE 的类别（Unity 和 Unreal 上的常见原因）——
> `docs/engine-reference/<engine>/modules/` 中的存档/序列化模块
> （Phase 3），并点名该类别。

如果是 **CLEAR TO SHIP**：
> “✅ 没有阻塞性安全发现。报告已写入 `production/security/`。在运行 `/gate-check release` 时包含此路径。”

---

## 协作协议

- **绝不要假设某个模式是安全的**——标记它，让用户决定
- **接受风险是有效的结果**——对单人团队来说，一些 LOW 发现是可接受的取舍；记录该决定
- **多人游戏有更高的标准**——在多人情境中的任何 HIGH 发现都应视为 CRITICAL
- **这不是渗透测试**——本审计覆盖常见模式；在任何竞争性或商业化的多人上线之前，建议由人类安全专业人员进行真正的渗透测试