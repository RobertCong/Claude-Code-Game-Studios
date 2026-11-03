---
name: release-checklist
description: "发布前检查清单 —— 构建验证、认证要求、商店元数据、上线就绪度。"
argument-hint: "[platform: pc|console|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/release-checklist/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---
!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys rigor,workflow,project.stage,cert_tier,automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

已在上方解析 —— 直接使用。无解析块 → 使用 `.claude/docs/config-resolution.md` 中的默认值。

# 发布检查清单

**将本清单限定到本项目。** 为每个平台罗列所有条目会让读者
养成跳过列表的习惯，从而使闸门失效：

- **`project.stage`** —— 本项目尚未到达的阶段所对应的条目
  不在范围内；要说明这一点，而不是将其列为未勾选。
- **`modes.rigor`** —— 在 `minimal` 下，去掉那些唯一理由只是本项目
  已选择退出的流程负担的条目。
- **`platform.cert_tier`** —— **仅**为项目目标的层级输出认证条目。
  如果它**未设置**，**询问哪些平台在范围内**，
  而不是输出全部 —— 未设置的值是一个问题，而不是输出每条认证
  轨道的许可。如果无法确定，将该节标记为
  **`NOT ASSESSED — cert tier unknown`**。**未设置不是 `none`：** `none` 是一个
  决定，未设置是缺失的决定，二者绝不能产生相同输出。
  按**该键的四个取值**分支 —— `none | itch | steam | console` ——
  而不是按平台名称。完整要求表是 `.claude/docs/effects-map.md` 的
  `## platform.cert_tier` 节 —— **只读该节**（Grep 其
  标题，然后做有边界的 Read）；整个文件不是运行时输入。
  - `none` —— **完全不输出认证节。** 内部发布、alpha 或
     game jam 游戏。说明该节已省略及原因；不要留空。
  - `itch` —— 仅 itch.io 上传要求：构建大小、页面设置、年龄标签。
    **不含主机与 Steamworks 条目。**
  - `steam` —— Steamworks：商店页面、depot 构建、成就、系统
    要求、通用内容规则。**不含主机认证条目。**
  - `console` —— 完整平台认证（TRC / XR / Lotcheck）、存档数据
    规则、手柄映射规则、年龄分级机构。最重的层级。

  > **按上面的 `cert_tier` 取值分支，而不是按平台名称。** 基于
  > 目标平台的判断会把 `itch` 项目和 `steam` 项目视为相同，
  > 把 `none` 与未设置混为一谈，并以 `mobile` 为键，而它根本
  > 不是 `cert_tier` 取值。使用配置定义的词汇。

如果某条目因配置缺失而无法界定范围，将其标记为
**`NOT ASSESSED — platform/stage unknown`**。不要静默包含它：一个
`rigor: standard` 的单平台项目否则会收到约 150 项的
清单，要求 PC **和**主机**和**移动认证加上年龄
分级，其中约 140 项无法评估。

---


## Phase 1: 解析参数

读取参数中的目标平台（`pc`、`console`、`mobile` 或 `all`）。如果未指定平台，默认使用 `all`。

**参数选择的是设备要求。它从不选择认证
轨道。** 认证由 `platform.cert_tier` 决定，该值在本技能顶部的已解析配置块中解析 ——
参见上方的 `platform.cert_tier` 规则。这两个轴是不同的列表，只是
恰好共用一个词：`pc`/`console`/`mobile` 是硬件形态，而
`none|itch|steam|console` 是认证制度。它们仅在 `console` 上一致，
此外毫无重合 —— `itch` 和 `none` 根本没有设备块，而 `mobile` 不是
`cert_tier` 取值。因此输出设备块并不说明应输出哪个
认证块，`all` **也不是**输出每条
认证轨道的许可。

---

## Phase 2: 加载项目上下文

- 读取 `CLAUDE.md` 以获取项目上下文、版本信息和平台目标。
- 从 `production/milestones/` 读取当前里程碑，以了解本次发布应包含哪些功能与内容。
- 从 `production/qa/bugs/` 读取未关闭的缺陷：Grep `production/qa/bugs/*.md` 的 `**Severity**` 和 `**Status**` 行，与 `/bug-triage` 的做法一致。除非其 Status 为 `Closed` 或 `Verified Fixed`，否则该缺陷即为未关闭。缺陷条目使用 `/gate-check release` 针对已解析 `workflow` 应用的阈值：在 `full` 下，未关闭的 S1、S2 或 S3 缺陷会使该条目失败；在 `standard` 和 `minimal` 下，只有未关闭的 S1 会，未关闭的 S2 或 S3 会在 Rationale 中列为风险。每个失败的缺陷都会在 Rationale 中作为阻塞项列出。**`production/qa/bugs/` 中没有缺陷文件** → 缺陷条目读作 `NOT ASSESSED — no bug records` —— 绝不是零，也绝不勾选，因为缺失的记录与干净的记录绝不能产生相同的清单；缺陷通过 `/bug-report` 登记。

---

## Phase 3: 扫描代码库

> **每个计数都要给出分母。** 这些扫描查找的是坏东西，
> 因此 `0` 可能意味着"搜索过且没找到"或"根本没有可搜索的东西"，
> 而在发布闸门上这是两种相反的发现。报告
> `scanned [N] source files: [M] TODO, [M] FIXME, [M] HACK` —— 或者，当代码
> 根目录（`src/`、`Assets/` 或 `Source/`；按
> `.claude/docs/code-root-resolution.md` 解析）无法解析时，
> 报告 **`NOT ASSESSED — code root unresolved`**；当它不存在或不含任何
> 源文件时，报告 **`NOT ASSESSED — no source files found to scan`**。光秃秃的 `0` 不是
> 结果。

扫描待处理问题：

- 统计 `TODO` 注释
- 统计 `FIXME` 注释
- 统计 `HACK` 注释
- 记录其位置与严重程度

检查任何测试输出目录或 CI 日志中是否有测试结果（若可用）。
**若未找到，要说明** —— `Test results: NOT ASSESSED — no test output or
CI logs found` —— 而不是省略该行。缺失的测试结果与通过的测试结果
绝不能产生相同的发布清单。

---

## Phase 4: 生成发布检查清单

```markdown
## Release Checklist: [Version] -- [Platform]
Generated: [Date]

### Codebase Health
- Scanned: [N] source files (or `NOT ASSESSED — [reason]`, per Phase 3)
- TODO count: [N] ([list top 5 if many])
- FIXME count: [N] ([list all -- these are potential blockers])
- HACK count: [N] ([list all -- these need review])

### Build Verification
- [ ] Clean build succeeds on all target platforms
- [ ] No compiler warnings (zero-warning policy)
- [ ] All assets included and loading correctly
- [ ] Build size within budget ([target size])
- [ ] Build version number correctly set ([version])
- [ ] Build is reproducible from tagged commit

### Quality Gates
- Open bugs (`production/qa/bugs/`): [N] S1, [N] S2, [N] S3 -- or `NOT ASSESSED — no bug records`
- [ ] Zero open S1 (Critical) bugs
- [ ] Zero open S2 (High) and S3 (Medium) bugs, no exceptions -- this row at `workflow: full` only; at `standard`/`minimal` open S2/S3 bugs go in the Rationale as risks
- [ ] All critical path features tested and signed off by QA
- [ ] Performance within budgets:
  - [ ] Target FPS met on minimum spec hardware
  - [ ] Memory usage within budget
  - [ ] Load times within budget
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build
- [ ] Soak test passed (4+ hours continuous play)

### Content Complete
- [ ] All placeholder assets replaced with final versions
- [ ] All TODO/FIXME in content files resolved or documented
- [ ] All player-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate
```

根据参数添加**设备**节。这些不含认证或
商店 SDK 条目 —— 那些在下一小节按 `platform.cert_tier` 判定，在这里
重复它们会把 Steamworks 行交给一个 `itch` 项目。

**对于 `pc`：**
```markdown
### Platform Requirements: PC
- [ ] Minimum and recommended specs verified and documented
- [ ] Keyboard+mouse controls fully functional
- [ ] Controller support tested (Xbox, PlayStation, generic)
- [ ] Resolution scaling tested (1080p, 1440p, 4K, ultrawide)
- [ ] Windowed, borderless, and fullscreen modes working
- [ ] Graphics settings save and load correctly
```

**对于 `console`：**
```markdown
### Platform Requirements: Console
- [ ] Platform-specific controller prompts display correctly
- [ ] Suspend/resume works correctly
- [ ] User switching handled properly
- [ ] Network connectivity loss handled gracefully
- [ ] Storage full scenario handled
```

**对于 `mobile`：**
```markdown
### Platform Requirements: Mobile
- [ ] App store guidelines compliance verified
- [ ] All required device permissions justified and documented
- [ ] Privacy policy linked and accurate
- [ ] Data safety/nutrition labels completed
- [ ] Touch controls tested on multiple screen sizes
- [ ] Battery usage within acceptable range
- [ ] Background behavior correct (pause, resume, terminate)
- [ ] Push notification permissions handled correctly
- [ ] In-app purchase flow tested (if applicable)
- [ ] App size within store limits
```

> **移动商店行特意保留在这里。** `platform.cert_tier` 建模的是
> `none|itch|steam|console`，没有移动制式，因此 App Store / Play Store
> 合规无法以其为闸门。将这些留在设备块中是有意为之，
> 而非疏漏 —— 不要通过发明一个 `mobile`
> 层级来"修复"它，那正是 `cert_tier` 规则所警告的错误词汇。

**认证 —— 仅输出与 `platform.cert_tier` 匹配的块**（在本技能顶部的
已解析配置块中解析）。不要输出本小节的其他块，也不要因为平台参数是
`all` 就回退为输出全部块。

**在 `none` 下** —— 完全不输出认证块。取而代之只输出这一行，
使省略清晰可见，而不是看起来像缺失的节：
```markdown
Certification: omitted — cert_tier is 'none' (internal build, alpha or jam release).
```

**在 `itch` 下：**
```markdown
### Certification: itch.io
- [ ] Build size within itch.io upload limits
- [ ] itch.io page complete (cover art, screenshots, description)
- [ ] Age/content tags set honestly
- [ ] Downloadable vs browser build decided and tested
- [ ] Butler channel names correct for each platform uploaded
```

**在 `steam` 下：**
```markdown
### Certification: Steamworks
- [ ] Steamworks SDK integrated and tested
- [ ] Depot build uploaded and installs cleanly from a fresh account
- [ ] Achievements functional
- [ ] Cloud saves functional
- [ ] Steam Deck compatibility verified (if targeting)
- [ ] Steam common content rules reviewed
```

**在 `console` 下：**
```markdown
### Certification: Console
- [ ] TRC/TCR/Lotcheck requirements checklist complete
- [ ] First-party certification submission prepared
- [ ] Platform-specific achievement/trophy integration tested
- [ ] Parental controls respected
- [ ] Save-data rules compliant (corruption, full storage, user switching)
- [ ] Age ratings obtained (ESRB, PEGI, regional)
```

如果 `cert_tier` **未设置**，询问哪些平台在范围内，而不是
输出每条轨道；如果无法确定，输出
`### Certification: NOT ASSESSED — cert tier unknown` 并说明原因。**未设置不是
`none`** —— `none` 是一个决定，未设置是缺失的决定。

> **认证行属于这里，位于一个由 `cert_tier` 判定的子节中。** 不要
> 将它们放入 PC、Console 和 Mobile 设备块：那些由
> 命令参数选择且默认 `all`，因此一个 `itch` 项目在无参数运行
> `/release-checklist` 时会被交予 Steamworks SDK 行
> *和* Lotcheck 行，这是本技能顶部的 `cert_tier` 规则
> 所禁止的。
>
> **`console` 在本文件中有两种不同含义。** 它既是设备块
> 的参数值*又是* `cert_tier` 取值，四个词中有一个词发生碰撞。
> `**For \`console\`:**` 标题是参数判定，不是层级判定 —— 不要
> 把它读作认证已按层级界定范围的证据。

**商店与上线节（所有平台）：**
```markdown
### Store / Distribution
- [ ] Store page metadata complete and proofread
  - [ ] Short description
  - [ ] Long description
  - [ ] Feature list
  - [ ] System requirements (PC)
- [ ] Screenshots up to date and per-platform resolution requirements met
- [ ] Trailers up to date
- [ ] Key art and capsule images current
- [ ] Age rating obtained and configured:
  - [ ] ESRB
  - [ ] PEGI
  - [ ] Other regional ratings as required
- [ ] Legal notices, EULA, and privacy policy in place
- [ ] Third-party license attributions complete
- [ ] Pricing configured for all regions

### Launch Readiness
- [ ] Analytics / telemetry verified and receiving data
- [ ] Crash reporting configured and dashboard accessible
- [ ] Day-one patch prepared and tested (if needed)
- [ ] On-call team schedule set for first 72 hours
- [ ] Community launch announcements drafted
- [ ] Press/influencer keys prepared for distribution
- [ ] Support team briefed on known issues and FAQ
- [ ] Rollback plan documented (if critical issues found post-launch)

### Go / No-Go: [READY / NOT ASSESSED / NOT READY]

First match wins: **NOT READY** if any blocking item fails; else **NOT ASSESSED**
if any section or item came out `NOT ASSESSED` (name each one); else **READY**. NOT
ASSESSED outranks READY — an unassessed section is not a passed one — and ranks
below NOT READY, so a known blocker is never buried behind it.

**Rationale:**
[Summary of readiness assessment. List any blocking items that must be
resolved before launch. If NOT READY, list the specific items that need
resolution and estimated time to address them.]

**Sign-offs Required:**
- [ ] QA Lead
- [ ] Technical Director
- [ ] Producer
- [ ] Creative Director
```

---

## Phase 5: 保存清单

向用户呈现清单，包含：清单条目总数、已知阻塞项数量（FIXME/HACK 计数、已知缺陷）。

询问："我可以将其写入 `production/releases/release-checklist-[version].md` 吗？"

如果同意，写入该文件，必要时创建目录。

---

## Phase 6: 后续步骤

- 起草变更日志或补丁说明（`/changelog`、`/patch-notes`）（若尚未完成）—— 发布闸门会检查它们。
- 运行 `/gate-check release` —— Polish → Release 闸门会读取本清单。
- PASS 之后：`/launch-checklist`，然后通过 `/team-release` 协调发布。
