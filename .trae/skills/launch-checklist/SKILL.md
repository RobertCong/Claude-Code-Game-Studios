---
name: launch-checklist
description: "覆盖各部门的上线就绪度：代码、内容、商店、市场、社区、基础设施、法务、go/no-go 签署。"
argument-hint: "[launch-date or 'dry-run']"
user-invocable: true
disable-model-invocation: true
---
**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys rigor,workflow,project.stage,cert_tier,automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每一次 `AskUserQuestion` 调用和
每一次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 每次必问 · guided 仅重大事项 · autonomous 记录日志并继续；
`automation_always_ask` 类别始终提示）。

以上命令的输出已解析——直接使用。无配置块 → 使用 `.trae/docs/config-resolution.md` 中的默认值。

# 上线检查清单

**把这份清单限定在本项目范围内。** 为每个平台输出所有条目会训练读者跳过这份清单，反而使这道质量闸门（gate）失效：

- **`project.stage`** —— 本项目尚未到达的阶段对应条目不在范围内；应当说明这一点，而不是把它们列为未勾选条目。
- **`modes.rigor`** —— 在 `minimal` 下，删除那些唯一理由是本项目已选择放弃的流程负担的条目。
- **`platform.cert_tier`** —— **仅**为项目所针对的层级（tier）输出认证条目。如果它是**未设置**的，**询问哪些平台在范围内**，而不是把全部输出——未设置的值是一个问题，而不是输出所有认证轨道的许可。答案映射到下面四个值，就是本次运行的层级。如果无法确定，就把该节标记为 **`NOT ASSESSED — cert tier unknown`**。**未设置不等于 `none`：** `none` 是一个决定，未设置是缺失的决定，两者不得产生相同的输出。按**该键的四个取值**分支——`none | itch | steam | console` ——而不是按平台名称。完整的需求表是 `.trae/docs/effects-map.md` 的 `## platform.cert_tier` 节——**只读那一节**（Grep 它的标题，然后做一次有边界的 Read）；整个文件不是运行时输入。
  - `none` —— **完全不输出认证章节。** 内部发布、alpha 或 game jam 游戏。说明该章节已省略以及原因；不要让它留空。
  - `itch` —— 仅 itch.io 上传要求：构建体积、页面设置、年龄标签。**没有主机条目，也没有 Steamworks 条目。**
  - `steam` —— Steamworks：商店页面、depot 构建、成就、系统需求、通用内容规则。**没有主机认证条目。**
  - `console` —— 完整平台认证（TRC / XR / Lotcheck）、存档数据规则、手柄映射规则、年龄分级机构。最重的层级。

  > **按上面的 `cert_tier` 取值分支，而不是按平台名称。** 针对目标平台做判断会把 `itch` 项目和 `steam` 项目同等对待、把 `none` 与未设置混为一谈，并且以 `mobile` 为键——而它根本不是 `cert_tier` 的取值。请使用配置定义的词汇。

如果因配置缺失而无法限定某条目的范围，就把它标记为
**`NOT ASSESSED — platform/stage unknown`**。不要悄悄纳入它：否则一个
`rigor: standard` 的单平台项目会收到一份约 150 条的清单，要求 PC **以及**主机**以及**移动端认证外加年龄分级，其中约 140 条无法评估。

---


## Phase 1: 解析参数

读取参数中的上线日期或 `dry-run` 模式。试运行（dry-run）模式生成清单，但不创建签署条目、不写文件。无参数时为常规运行，目标日期未设置（`Target Launch: not set`）——只有当参数为 `dry-run` 时才走试运行。

---

## Phase 2: 收集项目上下文

- 读取 `AGENTS.md`，获取技术栈、目标平台和团队结构
- 读取 `production/milestones/` 中最近的里程碑
- 读取 `production/releases/` 中已有的发布检查清单
- 如果存在，读取 `design/live-ops/content-calendar.md` 中的内容日历

---

## Phase 3: 扫描代码库健康状况

> **本阶段的每一次扫描都是在寻找坏东西，因此零命中结果在构造上就是模棱两可的：它既可能表示"扫描了但没找到"，也可能表示"根本没有可扫描的东西"。在上线质量闸门（gate）上，这两种结论正好相反，而一个绿色的勾选框会把它们渲染得一模一样。**
>
> **在下面每一次扫描之前先确立分母，并报告它。** 每一行要么写
> `scanned [N] files, [M] hits`，要么写
> `NOT ASSESSED — [code root unresolved | no source files | no asset folder | directory empty]`。
> 绝不要只给一个勾。代码根（code root）按引擎为 `src/`、`Assets/` 或 `Source/`
> （按 `.trae/docs/code-root-resolution.md` 解析）；资源位于
> `assets/`、`Assets/` 或 `Content/`。
>
> 这适用于下面的全部四个要点：每一个都以同样的方式搜索占位资源、TODO、调试输出和硬编码测试值，而每一个在空或缺席的根目录上都会返回零命中。例如，没有 `assets/` 目录时，占位资源扫描返回零命中，而一个裸勾会把"所有占位美术已替换"标成绿色。

- 统计 `TODO`、`FIXME`、`HACK` 注释的数量及其位置
- 检查生产代码中是否残留任何 `console.log`、`print()` 或调试输出
- 检查占位资源（搜索 `placeholder`、`temp_`、`WIP_`）
- 检查硬编码的测试/开发值（localhost、测试凭据、调试开关）

**把这个区分带入清单本身。** 扫描返回 `NOT ASSESSED` 的条目写成
`- [?]`，而不是 `- [ ]`。未勾选的方框表示*还有工作要做*；`[?]` 表示*没人能检查*，而只有前者能通过完成工作来关闭。凡出现 `[?]` 的地方都要附上图例：
`[?] = not assessed — the input to this check was absent`。

---

## Phase 4: 生成上线检查清单

```markdown
# Launch Checklist: [Game Title]
Target Launch: [Date or DRY RUN]
Generated: [Date]

---

## 1. Code Readiness

### Build Health
- [ ] Clean build on all target platforms
- [ ] Zero compiler warnings
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Performance benchmarks within targets
- [ ] No memory leaks (verified via extended soak test)
- [ ] Build size within platform limits
- [ ] Build version correctly set and tagged in source control

### Code Quality
- [ ] TODO count: [N] (zero required for launch, or documented exceptions)
- [ ] FIXME count: [N] (zero required)
- [ ] HACK count: [N] (each must have documented justification)
- [ ] No debug output in production code
- [ ] No hardcoded dev/test values
- [ ] All feature flags set to production values
- [ ] Error handling covers all critical paths
- [ ] Crash reporting integrated and verified

### Security
- [ ] No exposed API keys or credentials in source
- [ ] Save data encrypted
- [ ] Network communication secured (TLS/DTLS)
- [ ] Anti-cheat measures active (if multiplayer)
- [ ] Input validation on all server endpoints (if multiplayer)
- [ ] Privacy policy compliance verified

---

## 2. Content Readiness

### Assets
- [ ] All placeholder art replaced with final assets
- [ ] All placeholder audio replaced with final audio
- [ ] Audio mix finalized and approved by audio director
- [ ] All VFX polished and performance-verified
- [ ] No missing or broken asset references
- [ ] Asset naming conventions enforced

### Text and Localization
- [ ] All player-facing text proofread
- [ ] No hardcoded strings (all externalized for localization)
- [ ] All supported languages translated and verified
- [ ] Text fits UI in all languages (text fitting pass complete)
- [ ] Font coverage verified for all supported languages
- [ ] Credits complete, accurate, and up to date

### Game Content
- [ ] All levels/maps playable from start to finish
- [ ] Tutorial flow complete and tested with new players
- [ ] All achievements/trophies implemented and tested
- [ ] Save/load works correctly for all game states
- [ ] Difficulty settings balanced and tested
- [ ] End-game/credits sequence complete

---

## 3. Quality Assurance

### Testing
- [ ] Full regression test suite passed
- [ ] Zero S1 (Critical) bugs open
- [ ] Zero S2 (High) bugs open (or documented exceptions) — at `workflow: full` instead: zero S2 (High) and S3 (Medium) bugs open, no exceptions
- [ ] Soak test passed (the longest soak `/soak-test` runs, or longer by hand if a play session lasts longer)
- [ ] Multiplayer stress test passed (if applicable)
- [ ] All critical user paths tested on every platform
- [ ] Edge cases tested (full storage, no network, suspend/resume)

### Platform Certification

**Emit ONLY the block matching `platform.cert_tier`** (resolved in the resolved-config block at the top of this skill — see
the `platform.cert_tier` rule above). Do not emit this section's other blocks, and
do not fall back to emitting all of them.

**At `none`** — omit the section and say so in one line:
`Platform Certification: omitted — cert_tier is 'none' (internal/jam release).`

**At `itch`:**
- [ ] Build size within itch.io upload limits
- [ ] itch.io page complete (cover art, screenshots, description, tags)
- [ ] Age/content tags set honestly
- [ ] Downloadable vs browser build decided and tested

**At `steam`:**
- [ ] Steamworks SDK integrated and tested
- [ ] Store page complete (capsule art, trailer, description, system requirements)
- [ ] Depot build uploaded and installs cleanly from a fresh account
- [ ] Achievements functional
- [ ] Steam common content rules reviewed

**At `console`:**
- [ ] TRC/TCR/Lotcheck submission prepared
- [ ] Save-data rules compliant (corruption, full storage, user switching)
- [ ] Controller-mapping rules met, platform-correct button prompts
- [ ] Suspend/resume verified
- [ ] Age ratings obtained (ESRB, PEGI, regional)

**Every tier**, because these are not certification-gated:
- [ ] Accessibility: minimum standards met (remapping, text scaling, colorblind)

> **Emit this section gated by tier, never as one ungated list.** PC *and*
> Console *and* Mobile rows emitted at every tier contradict the `cert_tier` rule
> at the top of this skill, which says an `itch` project gets no console and no
> Steamworks items.

### Performance
- [ ] Target FPS met on minimum spec hardware
- [ ] Load times within budget on all platforms
- [ ] Memory usage within budget on all platforms
- [ ] Network bandwidth within targets (if multiplayer)
- [ ] No frame hitches in critical gameplay moments

---

## 4. Store and Distribution

### Store Pages
- [ ] Store page copy finalized and proofread
- [ ] Screenshots current and per-platform resolution
- [ ] Trailers current and approved
- [ ] Key art and capsule images finalized
- [ ] System requirements accurate (PC)
- [ ] Pricing configured for all regions
- [ ] Pre-purchase/wishlist campaigns active (if applicable)

### Legal
- [ ] EULA finalized and approved by legal
- [ ] Privacy policy published and linked
- [ ] Third-party license attributions complete
- [ ] Music/audio licensing verified
- [ ] Trademark/IP clearance confirmed
- [ ] GDPR/CCPA compliance verified (data collection, consent, deletion)

---

## 5. Infrastructure

### Servers (if multiplayer/online)
- [ ] Production servers provisioned and load-tested
- [ ] Auto-scaling configured and tested
- [ ] Database backups configured
- [ ] CDN configured for content delivery
- [ ] DDoS protection active
- [ ] Monitoring and alerting configured

### Analytics and Monitoring
- [ ] Analytics pipeline verified and receiving data
- [ ] Crash reporting active and dashboard accessible
- [ ] Server monitoring dashboards live
- [ ] Key metrics tracked: DAU, session length, retention, crashes
- [ ] Alerts configured for critical thresholds

---

## 6. Community and Marketing

### Community Readiness
- [ ] Community guidelines published
- [ ] Moderation team briefed and tools ready
- [ ] Discord/forum/social channels set up
- [ ] FAQ and known issues page prepared
- [ ] Support email/ticketing system active

### Marketing
- [ ] Launch trailer published
- [ ] Press/influencer review keys distributed
- [ ] Social media launch posts scheduled
- [ ] Launch day blog post/dev update drafted
- [ ] Patch notes for launch version published

---

## 7. Operations

### Team Readiness
- [ ] On-call schedule set for first 72 hours post-launch
- [ ] Incident response playbook reviewed by team
- [ ] Rollback plan documented and tested
- [ ] Hotfix pipeline tested (can ship emergency fix within 4 hours)
- [ ] Communication plan for launch issues (who posts, where, how fast)

### Day-One Plan
- [ ] Day-one patch prepared (if needed)
- [ ] Server unlock/go-live procedure documented
- [ ] Launch monitoring dashboard bookmarked by all leads
- [ ] War room/channel established for launch day

---

## Go / No-Go Decision

**Overall Status**: [READY / CONDITIONAL / NOT ASSESSED / NOT READY]

First match wins: **NOT READY** if Blocking Items is not empty; else **NOT
ASSESSED** if any item is `- [?]`, any section came out `NOT ASSESSED`, or any
item is still unconfirmed — neither ticked on evidence or on a Phase 4b answer,
nor marked N/A, nor listed below (name each; group by section when there are
many); else **CONDITIONAL** if Conditional
Items is not empty; else **READY**. NOT ASSESSED outranks CONDITIONAL and READY —
an item nobody could check is not a passed one — and ranks below NOT READY, so a
known blocker is never buried behind it.

### Blocking Items
[Every FAIL or unresolved finding: a check that found a problem — FIXMEs, debug
output, placeholder assets, hardcoded dev values, an open S1 bug, a failing
build or test — with no documented workaround and no explicitly accepted risk]

### Conditional Items
[Every shortfall with a documented workaround or an explicitly accepted risk —
e.g. a HACK with its documented justification, an S2 with a documented
exception (below `workflow: full`, which allows none). Name the workaround, or
who accepted the risk]

### Sign-Offs Required
- [ ] Creative Director — Content and experience quality
- [ ] Technical Director — Technical health and stability
- [ ] QA Lead — Quality and test coverage
- [ ] Producer — Schedule and overall readiness
- [ ] Release Manager — Build and deployment readiness
```

---

## Phase 4b: 确认只有人才能确认的事项

上面大多数条目无法从代码库中确定——值班表、EULA、媒体密钥、定价、某人跑过的浸泡测试（soak test）。如果不去问，它们每一个都会保持未确认，总体状态只能为 NOT ASSESSED，所以要问。

对七个章节中的每一个，收集没有任何扫描或文件能确定的事项（Phase 3 的计数和 Phase 2 中读到的内容不再重复询问），并**每节问一次 `AskUserQuestion`**，把这些事项编号列出。每个事项的答案是 **yes / no / not yet / N/A**。选项：`Yes — all of them` / `Not yet — none of them` / `N/A — this section does not apply` / `Some differ — I'll answer per item`（随后用户逐条给出答案）。没有剩余问题要问的章节跳过。

- **yes** → 勾选为 `- [x]`，并标记 `(confirmed by the user)`
- **no** 或 **not yet** → 失败条目：放在 Blocking Items 下，或者当用户给出变通方案或接受风险时放在 Conditional Items 下
- **N/A** → 写成 `- N/A — [item]`，并从总体状态中排除
- 未回答的条目保持未确认，状态中会指出它

这些是只有用户才能回答的事实性问题，因此在 `collaborative` 和 `guided` 下都一样询问，绝不代替用户作答。在 `autonomous` 模式和 `dry-run` 下跳过本阶段并说明：它本会询问的条目保持未确认，总体状态为 NOT ASSESSED。

然后根据答案填写 Go / No-Go 章节。

---

## Phase 5: 保存检查清单

向用户展示完成的清单和摘要（总体状态、条目总数、阻塞条目数、条件条目数、未评估条目数、存在未完成章节的部门）。

如果不在试运行模式，询问："我可以把它写入 `production/releases/launch-checklist-[date].md` 吗？"

在得到答案之前不要创建任何东西——连 `production/releases/` 目录也不要创建。若同意，写文件；写入时会随文件一起创建目录。

---

## Phase 6: 后续步骤

- 如果 `project.stage` 不是 `Release`（`Polish`、更早的阶段或未设置），先运行 `/gate-check release` ——它是上线前的就绪度质量闸门（gate）。
- 通过 `/team-release` 协调签署与部署。