<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    把一个 Claude Code 会话变成完整的游戏开发工作室。
    <br />
    49 个代理，74 个技能，一支协同工作的 AI 团队。
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-74-green" alt="74 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-15-orange" alt="15 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-14-red" alt="14 Rules"></a>
  <a href="https://code.claude.com/docs"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20this%20project-FFDD00?logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Support%20this%20project-ea4aaa?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

---

## 目录

- [包含内容](#whats-included)
- [工作室层级](#studio-hierarchy)
- [斜杠命令](#slash-commands)
- [它产出游戏，还是文档？](#does-it-produce-games-or-documents)
- [快速开始](#getting-started)
- [配置](#configuration)
- [升级](#upgrading)
- [项目结构](#project-structure)
- [工作原理](#how-it-works)
- [设计哲学](#design-philosophy)
- [定制](#customization)
- [平台支持](#platform-support)
- [社区](#community)
- [支持这个项目](#supporting-this-project)
- [许可证](#license)

---

<a id="why-this-exists"></a>
## 为什么存在这个项目

用 AI 独自做游戏很强大——但单个聊天会话没有结构。没人阻止你硬编码魔法数字、跳过设计文档或写出意大利面代码。没有 QA 环节，没有设计评审，没有人问「这真的符合游戏愿景吗？」

**Claude Code Game Studios** 通过给你的 AI 会话赋予真实工作室的结构来解决这个问题。你得到的不是单个通用助手，而是按工作室层级组织的 49 个专业代理——守护愿景的总监、掌管各自领域的主管，以及负责动手工作的专家。每个代理都有明确的职责、上报路径和质量闸门。

结果是：每个决策仍然由你做，但现在你有一支会问对问题、及早发现错误、并把项目从最初的头脑风暴组织到上线的团队。

---

<a id="whats-included"></a>
## 包含内容

| 类别 | 数量 | 说明 |
|----------|-------|-------------|
| **代理** | 49 | 覆盖设计、程序、美术、音频、叙事、QA 和制作的专业子代理 |
| **技能** | 74 | 覆盖每个工作流阶段的斜杠命令（`/start`、`/design-system`、`/create-epics`、`/create-stories`、`/dev-story`、`/story-done` 等） |
| **钩子** | 15 | 在提交、推送、资源变更、设计文档读取、写入与注册表、会话生命周期、代理审计轨迹和缺口检测时自动校验 |
| **规则** | 14 | 按路径生效的编码标准，在编辑玩法、引擎、AI、UI、网络代码、场景和资源文件等时强制执行 |
| **模板** | 62 | GDD、UX 规格、ADR、冲刺计划、HUD 设计、无障碍等文档模板 |

<a id="studio-hierarchy"></a>
## 工作室层级

代理按三个层级组织，与真实工作室的运作方式一致：

```
Tier 1 — Directors
  creative-director    technical-director    producer

Tier 2 — Department Leads
  game-designer        lead-programmer       art-director
  audio-director       narrative-director    qa-lead
  release-manager      localization-lead

Tier 3 — Specialists
  gameplay-programmer  engine-programmer     ai-programmer
  network-programmer   tools-programmer      ui-programmer
  systems-designer     level-designer        economy-designer
  technical-artist     sound-designer        writer
  world-builder        ux-designer           prototyper
  performance-analyst  devops-engineer       analytics-engineer
  security-engineer    qa-tester             accessibility-specialist
  live-ops-designer    community-manager
```

每个代理都在 frontmatter 中声明模型：三位总监使用 Opus，`lead-programmer` 和十五位专家指定 Sonnet，其余三十位**继承你当前会话的模型**。请把这些层级理解为角色资历，而不是计费方案——工作室的大部分都运行在你已经在用的模型上。

### 引擎专家

模板包含三大引擎的代理集。请使用与你的项目匹配的一组：

| 引擎 | 主导代理 | 子专家 |
|--------|-----------|-----------------|
| **Godot 4** | `godot-specialist` | GDScript、着色器、GDExtension |
| **Unity** | `unity-specialist` | DOTS/ECS、着色器/VFX、Addressables、UI Toolkit |
| **Unreal Engine 5** | `unreal-specialist` | GAS、蓝图、复制、UMG/CommonUI |

<a id="slash-commands"></a>
## 斜杠命令

在 Claude Code 中输入 `/` 即可访问全部 74 个技能：

**上手与导航**
`/start` `/help` `/project-stage-detect` `/setup-engine` `/adopt` `/settings`

**游戏设计**
`/brainstorm` `/map-systems` `/design-system` `/quick-design` `/review-all-gdds` `/propagate-design-change`

**美术与资源**
`/art-bible` `/asset-spec` `/asset-audit`

**UX 与界面设计**
`/ux-design` `/ux-review`

**架构**
`/create-architecture` `/architecture-decision` `/architecture-review` `/create-control-manifest`

**故事与冲刺**
`/create-epics` `/create-stories` `/dev-story` `/sprint-plan` `/sprint-status` `/story-readiness` `/story-done` `/estimate`

**评审与分析**
`/design-review` `/code-review` `/balance-check` `/content-audit` `/scope-check` `/perf-profile` `/tech-debt` `/gate-check` `/consistency-check` `/security-audit`

**QA 与测试**
`/qa-plan` `/smoke-check` `/soak-test` `/regression-suite` `/test-setup` `/test-helpers` `/test-evidence-review` `/test-flakiness` `/skill-test` `/skill-improve`

**制作**
`/milestone-review` `/retrospective` `/bug-report` `/bug-triage` `/reverse-document` `/playtest-report`

**发布**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix` `/day-one-patch`

**创意与内容**
`/prototype` `/vertical-slice` `/onboard` `/localize`

**团队编排**（在单个功能上协调多个代理）
`/team-combat` `/team-narrative` `/team-ui` `/team-release` `/team-polish` `/team-audio` `/team-level` `/team-live-ops` `/team-qa`

<a id="does-it-produce-games-or-documents"></a>
## 它产出游戏，还是文档？

这是个合理的问题，而答案是测量结果，不是示例项目。用同一份简报在不同 `modes.rigor` 级别下构建了四款游戏，并统计每款游戏在**第一行游戏代码之前**写下的文档：

| `modes.rigor` | 第一行游戏代码前的文档数 | 时间 |
|---|---:|---:|
| `minimal` | **1**（一页纸简报） | 0 分钟 |
| `standard` | 30 | 58 分钟 |

它们都产出了可运行、经过测试的游戏。随后两位盲审评审员和一次真人试玩把 `standard` 构建排在**最后**——多出的 29 份文档换来了可追溯性，而不是更好的游戏。

### 它会运行游戏并查看它

上面的测量关乎成本。另一半是它到底能不能用，而对游戏来说，这意味着必须有人去*看*它——通过的测试无法说明菜单被画到了屏幕外。因此，任何改变玩家所见内容的故事，在游戏被启动、观察，并把截图保存到 `production/qa/evidence/` 之前都不算完成。解析检查不等于运行。这条规则在每个严谨级别都成立，包括 `minimal`——在该级别自动测试被豁免，但「看一眼」不能豁免。

这些游戏本身刻意**不**随仓库发布：这是一个供你克隆并开始自己项目的模板，别人做的游戏放在你的仓库里只是杂物，不是证据。

<a id="getting-started"></a>
## 快速开始

### 前置条件

- [Git](https://git-scm.com/)
- [Claude Code](https://code.claude.com/docs/en/setup)——推荐原生安装器（`npm install -g @anthropic-ai/claude-code` 也可以，需要 Node.js 22+）
- [Python 3](https://www.python.org/)——每个技能和钩子都会读取 `project.yaml`；没有它，所有设置都会静默回退到默认值
- Bash——运行所有钩子；macOS 和 Linux 内置，Windows 上随 [Git for Windows](https://git-scm.com/downloads/win) 提供
- **推荐**：[jq](https://jqlang.github.io/jq/)（用于钩子校验）

缺少可选工具时钩子会优雅失败——你只会失去校验——但有一个刻意的例外：当没有 Python 可验证时，暂存数据 JSON 的提交会被阻止。

### 安装

1. **克隆或用作模板**：
   ```bash
   git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
   cd my-game
   ```

2. **在项目根文件夹中打开 Claude Code**（即包含 `CLAUDE.md` 和 `project.yaml` 的文件夹）并启动会话：
   ```bash
   claude
   ```
   在 `src/` 之类的子文件夹中启动会跳过项目的钩子、拒绝规则和先询问权限模式。

3. **运行 `/start`**——系统会询问你从哪里开始（毫无头绪、模糊概念、清晰设计、已有工作），并引导你进入正确的工作流。不做任何假设。

   如果你已经知道自己需要什么，也可以直接跳到特定技能：
   - `/brainstorm`——从零探索游戏创意
   - `/setup-engine godot 4.7`——如果你已经知道，直接配置引擎
   - `/project-stage-detect`——分析现有项目

<a id="configuration"></a>
## 配置

仓库根目录的 `project.yaml` 是工作室在你项目上如何行为的唯一事实来源——引擎、命名约定，以及一个控制每个技能执行多少流程的 `modes` 块。`/start` 会替你写入它；你很少需要手动编辑。

最重要的一个问题是 **`modes.rigor`**——`minimal`、`standard` 或 `full`。它是六个独立旋钮（`workflow`——需要哪些 GDD 章节，`docs.density`，`qa.level`，`story_granularity`，`review_mode`——有多少总监代理评审你的工作，以及 `team.size`）之上的单一入口，因此 `/start` 只问一次而不是六次：

- **`minimal`**（默认）——Jam 游戏速度。不需要 GDD，文档简洁，QA 证据最少，单人评审。`/start` → `/setup-engine` → `/brainstorm`（一页纸简报）→ `/create-stories` → `/dev-story` ↔ `/story-done`。
- **`standard`**——5 个必需 GDD 章节，文档深度均衡，标准 QA 证据，精简评审。
- **`full`**——全部 8 个 GDD 章节，详尽文档，每种故事类型都有完整 QA 证据，完整总监评审。

`minimal` 是默认值，因为更重的层级要花更多成本才能到达可运行代码，却不会产出更好的结果，而且当新人接手项目时也没有任何回报。项目成长时，用一次 `/settings` 调用提升它——`/help` 和 `/gate-check` 在看到迹象时会建议你这么做。

两个兜底出口可以避免一个设置变成粗暴的一刀切。**`system_overrides`** 让单个系统采用比项目其余部分更高的标准——你的战斗系统获得完整待遇，而其他一切保持轻量。**`testing.strict`** 按测试类型（逻辑、集成、视觉、UI、配置）设置缺少证据时是阻塞故事还是仅警告。

六个底层旋钮中的任何一个仍然可以单独设置，如果你想要混合配置（例如 `workflow: full` 配 `docs.density: terse`——全面但紧凑）。其中两个——`review_mode`（`full` / `lean` / `solo`）和 `team.size`——还是**个人化**的：严谨级别设置团队级默认值，但你可以在被 gitignore 的 `project.local.yaml` 中按开发者覆盖它们，而不触碰共享配置。`modes.automation`（AI 在行动前暂停询问的频率）位于严谨级别之外，同样可以个人覆盖。

用 `/settings` 技能查看或修改任何设置：

```
/settings                              # view effective config
/settings modes.review_mode            # view one setting
/settings modes.rigor=full             # write to project.yaml (team-wide)
/settings --local modes.review_mode=solo   # write to project.local.yaml (just you)
```

完整 schema 与每项设置的行为：`.claude/docs/effects-map.md`。

<a id="upgrading"></a>
## 升级

已经在使用此模板的旧版本？请参阅 [UPGRADING.md](UPGRADING.md)，了解逐步迁移说明、各版本之间的变更明细，以及哪些文件可以安全覆盖、哪些需要手动合并。

<a id="project-structure"></a>
## 项目结构

```
CLAUDE.md                           # Master configuration
.claude/
  settings.json                     # Hooks, permissions, safety rules
  agents/                           # 49 agent definitions (markdown + YAML frontmatter)
  skills/                           # 74 slash commands (subdirectory per skill)
  hooks/                            # 18 scripts (bash) — 15 event hooks, two helpers they
                                    #   source (yaml-helper.sh, update-check.sh), and one
                                    #   opt-in diagnostic you wire yourself
  rules/                            # 14 path-scoped coding standards
  statusline.sh                     # Status line script (context%, model, stage, epic breadcrumb)
  docs/
    workflow-catalog.yaml           # 7-phase pipeline definition (read by /help)
    templates/                      # 62 document templates (+ per-section guidance)
src/                                # Game source code (Godot). The code root is
                                    #   ENGINE-SPECIFIC: Unity compiles only
                                    #   Assets/, Unreal builds from Source/<Module>/
assets/                             # Art, audio, VFX, shaders, data files
design/                             # GDDs, narrative docs, level designs
docs/                               # Technical documentation and ADRs
tests/                              # Test suites (unit, integration, performance, playtest)
tools/                              # Build and pipeline tools
prototypes/                         # Throwaway prototypes (isolated from src/)
production/                         # Sprint plans, milestones, release tracking
studio-tests/                       # QA for the skills and agents themselves — see below
```

### 测试你的定制

CCGS 是一个供你编辑的模板。`studio-tests/` 是你检查编辑过或新写的技能是否仍然可靠的方式——它包含全部 74 个技能和 49 个代理的目录、按类别的质量评分标准、行为规格，以及编写你自己规格的模板。

```
/skill-test static [name]     # structural linter — 7 compliance checks
/skill-test category [name]   # category-specific quality rubric
/skill-test spec [name]       # behavioral spec assertions
/skill-test audit             # coverage report across skills and agents
/skill-improve [name]         # test-fix-retest loop; keeps or reverts on score change
```

它测试的是*框架*，绝不是你的游戏——游戏测试位于 `tests/`。

<a id="how-it-works"></a>
## 工作原理

### 代理协调

代理遵循结构化的委派模型：

1. **纵向委派**——总监委派给主管，主管委派给专家
2. **横向咨询**——同级代理可以互相咨询，但不能做出有约束力的跨领域决策
3. **冲突解决**——分歧上报到共同的上级（设计问题找 `creative-director`，技术问题找 `technical-director`）
4. **变更传播**——跨部门变更由 `producer` 协调
5. **领域边界**——未经明确委派，代理不修改其领域之外的文件

### 协作，而非自主

这**不是**自动驾驶系统。每个代理都遵循严格的协作协议：

1. **询问**——代理在提出方案前先提问
2. **给出选项**——代理展示 2-4 个带优缺点的选项
3. **你来决定**——用户始终做最终决定
4. **草稿**——代理在定稿前展示成果
5. **批准**——没有你的签字，什么都不会写入

控制权始终在你手中。代理提供结构和专业知识，而不是自主权。

这是从项目根目录启动终端会话时的开箱行为。`guided` 和 `autonomous` 自动化设置，以及 Claude Code 自身的自动模式，会用其中一些提示换取速度；进入自动模式的路径见 [setup-requirements.md](.claude/docs/setup-requirements.md)。

### 自动安全

**钩子**在每次会话中自动运行：

| 钩子 | 触发时机 | 作用 |
|------|---------|--------------|
| `validate-commit.sh` | PreToolUse（Bash、PowerShell） | 检查硬编码值、TODO 格式、JSON 合法性、设计文档章节——如果命令不是 `git commit` 则提前退出 |
| `validate-push.sh` | PreToolUse（Bash、PowerShell） | 对推送到受保护分支发出警告，并对 `git tag`、`git merge`、`gh release`、`butler push` 和 `steamcmd +run_app_build` 发出警告——其他命令提前退出 |
| `validate-read.sh` | PreToolUse（Read） | 拒绝整文件读取超过 40 KB 的设计文档，并返回其标题，使重试只读一个章节（`features.read_guard`） |
| `validate-write.sh` | PreToolUse（Write/Edit） | 当写入会破坏技能声明的规则时发出警告，绝不阻塞：技能从不覆盖的文件、配置守卫、原型边界、本地化冻结 |
| `validate-registry.sh` | PreToolUse（Write/Edit） | 当对实体或 TR-ID 注册表的写入会删除或重新编号条目，或设置其头部未列出的状态时发出警告 |
| `validate-assets.sh` | PostToolUse（Write/Edit） | 检查 `assets/`、`Assets/` 或 `Content/` 下的数据文件 JSON，以及仅 Godot `assets/` 中的资源命名——如果文件不在这些路径下则提前退出 |
| `session-start.sh` | 会话打开 | 显示当前分支和最近提交，用于定位 |
| `detect-gaps.sh` | 会话打开 | 检测全新项目（建议 `/start`），以及代码或原型存在时缺失的设计文档 |
| `pre-compact.sh` | 压缩前 | 记录压缩（其输出不会到达 Claude——之后由 `session-start.sh` 恢复上下文） |
| `notify.sh` | 权限提示，或空闲约一分钟 | 通过 PowerShell 显示 Windows 通知 |
| `session-stop.sh` | 每次回复结束，后台 | 把 `active.md` 归档到会话日志并记录 git 活动 |
| `log-agent.sh` | 代理启动 | 审计轨迹开始——记录子代理调用 |
| `log-agent-stop.sh` | 代理停止 | 审计轨迹结束——补全子代理记录 |
| `validate-agent-artifact.sh` | 代理停止 | 当子代理停止时未写入其简报指定的文件，发出警告 |
| `validate-skill-change.sh` | PostToolUse（Write/Edit） | 建议在任何 `.claude/skills/` 变更后运行 `/skill-test` |

> **注意**：`validate-commit.sh`、`validate-push.sh`、`validate-read.sh`、`validate-write.sh`、`validate-registry.sh`、`validate-assets.sh` 和 `validate-skill-change.sh` 会在每次 Bash、PowerShell、Read、Write 或 Edit 工具调用时触发，并在命令或文件路径不相关时立即退出（exit 0）。这是正常的钩子行为——不是性能问题。

`settings.json` 中的**权限规则**会在 Bash 和 PowerShell 工具中自动允许测试运行，并阻止危险操作（force push、`rm -rf`、读取 `.env` 文件）。`git status`、`git log` 和 `ls` 等只读命令不需要规则：Claude Code 会直接运行而不询问。`git` 规则在 `git` 之后的任意位置匹配，因此一条 git 命令的文本只要提到 `push` 且其后出现 ` +` 或 ` -f`、`clean` 且其后出现 ` -f`、或 `reset` 且其后出现 `--hard`——包括 `git commit -m "push + pull"` 这样的提交信息——也会被拒绝：请改写信息。

### 按路径生效的规则

编码标准会根据文件位置自动执行。下面的路径是 Godot 的。每条规则也匹配 Unity 和 Unreal 的布局：代码规则匹配 `Assets/**/Gameplay/` 下的 C# 和 `Source/**/Gameplay/` 下的 C++（以及 `Core`、`AI`、`Networking`、`UI`），数据匹配 `Assets/**/Data/` 和 `Content/**/Data/` 下的 JSON，着色器按文件类型匹配，测试匹配 `Assets/Tests/` 下的 C# 和 `Source/**/Tests/` 下的 C++。

| 路径 | 强制执行 |
|------|----------|
| `src/gameplay/**` | 数据驱动数值、delta time 使用、不引用 UI |
| `src/core/**` | 热路径零分配、线程安全、API 稳定性 |
| `src/ai/**` | 性能预算、可调试性、数据驱动参数 |
| `src/networking/**` | 服务器权威、消息版本化、安全 |
| `src/ui/**` | 不拥有游戏状态、可本地化、无障碍 |
| `design/gdd/**` | 按 `modes.workflow` 的必需章节、公式格式、边缘情况 |
| `design/narrative/**` | 设定一致性、角色声音、正典等级 |
| `assets/data/**/*.json` | JSON 合法性、命名约定、schema 规则 |
| `assets/shaders/**` | 命名约定、性能目标、跨平台规则 |
| `**/*.tscn`, `**/*.tres` | 尽量在编辑器中修改场景与资源文件；安全的手工编辑规则 |
| `tests/**` | 测试命名、覆盖率要求、fixture 模式 |
| `prototypes/**` | 放宽标准、必需 README、记录假设 |

<a id="design-philosophy"></a>
## 设计哲学

这个模板以专业游戏开发实践为基础：

- **MDA 框架**——机制（Mechanics）、动态（Dynamics）、美学（Aesthetics）分析，用于游戏设计
- **自我决定理论**——自主性、胜任感、归属感，用于玩家动机
- **心流设计**——挑战与技能的平衡，用于玩家投入度
- **Bartle 玩家类型**——受众定位与验证
- **验证驱动开发**——先测试，后实现

<a id="customization"></a>
## 定制

这是一个**模板**，不是锁死的框架。一切都应被定制：

- **增删代理**——删除不需要的代理文件，为你的领域新增代理
- **编辑代理提示词**——调整代理行为，添加项目特定知识
- **修改技能**——调整工作流以匹配你团队的流程
- **添加规则**——为你的项目目录结构创建新的按路径规则
- **调整钩子**——调整校验严格度，添加新检查
- **选择引擎**——使用 Godot、Unity 或 Unreal 代理集（或都不用）
- **调整流程重量**——`project.yaml` 中的 `modes.rigor` 及其底层旋钮（见[配置](#configuration)）。在任何技能上用 `--review solo` 按次覆盖。

<a id="platform-support"></a>
## 平台支持

主要开发环境是 **Windows 10** 配 Git Bash。钩子和脚本也在 **macOS**（自带的 bash 3.2 和 BSD 工具，含或不含 `jq`）以及 **Linux** 上测试过。所有钩子都使用 POSIX 兼容模式（`grep -E`，不是 `grep -P`），并为缺失工具提供回退。`notify.sh` 钩子在 Windows 上使用 PowerShell 显示通知，在其他平台上不执行任何操作——macOS/Linux 的桌面通知尚未接入。请为任何平台特定的故障提交 issue。

<a id="community"></a>
## 社区

- **讨论**——[GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions)，用于提问、交流想法和展示你的作品
- **Issue**——[Bug 报告和功能请求](https://github.com/Donchitos/Claude-Code-Game-Studios/issues)

---

<a id="supporting-this-project"></a>
## 支持这个项目

Claude Code Game Studios 是免费开源的。如果它节省了你的时间或帮助你发布游戏，可以考虑支持持续开发：

<p>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

- **[Buy Me a Coffee](https://www.buymeacoffee.com/donchitos3)**——一次性支持
- **[GitHub Sponsors](https://github.com/sponsors/Donchitos)**——通过 GitHub 的定期支持

赞助有助于资助维护技能、添加新代理、跟进 Claude Code 和引擎 API 变化以及回应社区问题的时间。

---

*为 Claude Code 构建。持续维护与扩展——欢迎通过 [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 贡献。*

<a id="license"></a>
## 许可证

MIT 许可证。详见 [LICENSE](LICENSE)。
