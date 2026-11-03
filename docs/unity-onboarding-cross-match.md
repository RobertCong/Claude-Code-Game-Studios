# Cross-Match Unity 工程接入 CCGS —— 现状审计与接入方案

> **2026-11-03 更新：** CCGS 框架已迁移到 `.trae/`（技能、代理、规则、钩子、脚本）。
> 本文中的 `.claude/` 路径请按 `.trae/` 理解；`CLAUDE.md` 已改名为 `AGENTS.md`。
> 迁移后的安装清单与 Trae 设置见 `README.md` 和 `.trae/docs/setup-requirements.md`。

| 项目 | 值 |
|---|---|
| 目标工程 | `/Volumes/ORICO/cross-match`（git `master`，有未提交改动） |
| Unity 工程根 | `/Volumes/ORICO/cross-match/UnityProject` |
| Unity 版本 | `6000.6.6f1`（`ProjectSettings/ProjectVersion.txt`） |
| 渲染管线 | URP `17.6.0` |
| 游戏框架 | TEngine |
| C# 源文件 | 约 1605 个（`UnityProject/Assets` 下） |
| 文档日期 | 2026-11-02 |
| 本次动作 | **只读盘点 + 方案整理，未修改目标工程任何文件** |

---

## 1. 结论摘要

1. **可行，但框架根必须落在 `cross-match/UnityProject`，不能落在 `cross-match` 仓库根。**
   CCGS 对 Unity 的代码根是硬编码的 `Assets/`（见
   [code-root-resolution.md](file:///Volumes/ORICO/Claude-Code-Game-Studios/.claude/docs/code-root-resolution.md)），
   而本仓库的真实 `Assets/` 在 `UnityProject/` 下。装在仓库根会让所有代码扫描得到
   `NOT ASSESSED — code root unresolved`。
2. **现有工程没有任何 CCGS 形态的产出物**：无 `design/gdd`、无 `docs/architecture/adr-*`、
   无 `production/epics`、无 `Assets/Tests`。`/adopt` 会输出一份以「补齐缺口」为主的迁移计划。
3. **版本可固定**：CCGS 的 Unity 参考线固定在 6.3 LTS，但时间线已记录 6.4–6.7；
   本机 `6000.6.6f1` 正是 6.6 线最新版（2026-10-15）。接入时应固定「已安装版本」，
   并保留「6.4+ API 未在参考目录中逐条核实」的告警。
4. **存在两套技能目录的治理冲突**：目标工程 `UnityProject/AGENTS.md` 明确
   「`.trae/skills` 是技能唯一源，不要复制到第二套目录」。安装 CCGS 会新增
   `.claude/skills`，需要你明确放宽该规则，或约定「Trae 会话用 `.trae`、Claude Code 会话用 `.claude`」。
5. **安装时严禁整目录拷贝框架根**：框架根存在 `assets/`、`tools/`，在 macOS 大小写不敏感
   文件系统上会与 Unity 工程的 `Assets/` 冲突/合并。只能按清单复制（见 §5）。

---

## 2. 目标工程现状（只读）

### 2.1 目录与职责

```text
/Volumes/ORICO/cross-match/          # git 仓库根
├── UnityProject/                    # 真实 Unity 工程根 ← CCGS 应安装在这里
│   ├── Assets/                      # 代码根（1605 个 .cs）
│   │   ├── GameScripts/             # GameEntry / Procedure / GameLogic / GameProto / CrossMathMain
│   │   ├── TEngine/                 # 框架源码
│   │   ├── Launcher/  Scenes/  Setting/  AssetArt/  AssetRaw/  Plugins/  MaxSdk/
│   ├── Packages/  ProjectSettings/  UserSettings/
│   ├── .trae/skills/                # 现有技能：tengine-dev / unity-cli / luban-dev / html-to-ugui
│   ├── AgentScripts/  repowiki/
│   └── AGENTS.md
├── 01_Project/                      # 产物/导出工程（含 Assets、Bundles、Library、Logs）
├── Books/                           # TEngine 框架文档 14 篇
├── Configs/GameConfig/              # Luban 配置源
├── Tools/                           # build-luban、FileServer、GameEventSourceGenerator
├── BuildCLI/
├── AGENTS.md / README.md            # 仓库级工作约定
└── update-tengine.bat
```

### 2.2 与 CCGS 结构的对照

| CCGS 期望 | 目标工程现状 | 结论 |
|---|---|---|
| 框架根 = 含 `Assets/` 的目录 | `UnityProject/` 才含 `Assets/` | 安装到 `UnityProject` |
| `project.yaml`（引擎/模式/阶段） | 不存在 | 需 `/setup-engine` + `/start` |
| `CLAUDE.md` | 只有 `AGENTS.md` | 可新增，不覆盖 AGENTS.md |
| `design/gdd/game-concept.md`、`design/gdd/*.md` | 不存在（`Books/` 是引擎/框架文档，不是游戏 GDD） | 缺口 |
| `docs/architecture/adr-*.md` | 不存在（只有目标工程自有 `Books/`） | 缺口 |
| `production/epics/**` | 不存在 | 缺口 |
| Unity 测试根 `Assets/Tests/{EditMode,PlayMode}` | 不存在 | 缺口 |
| `docs/engine-reference/` | 不存在 | 需从 CCGS 复制 |
| `.claude/` 技能/代理/钩子 | 不存在（只有 `.trae/`） | 需复制，且涉及治理冲突 |

### 2.3 审计结论分级

| 级别 | 发现 | 影响 |
|---|---|---|
| P0 | 框架未安装、引擎未配置 | `/adopt`、`/dev-story` 等所有技能都无法按 CCGS 语义运行 |
| P0 | 无游戏 GDD / ADR | 无法建立 control manifest，用户故事缺少架构规则来源 |
| P1 | 无 epic / 用户故事 | 无法进入 `/create-stories` → `/dev-story` 流水线 |
| P1 | 无 `Assets/Tests` | CCGS 的 Unity 测试路径不存在，`/test-setup` 需先建目录 |
| P1 | Unity `6000.6.6f1` 高于参考固定线 6.3 LTS | 代理可能引用未核实的 6.4+ API，需要显式告警 |
| P2 | `Books/` 与 `repowiki/` 不是设计文档 | `/adopt` 不会把它们当作 GDD/ADR，属于正常 |
| P2 | `01_Project/` 是产物工程 | 不应纳入代码根，避免重复扫描 |
| P2 | 未探测到 Unity 编辑器与 `unity` CLI | `/setup-engine` 只能记录 `installed version NOT DETERMINED`；Unity 验证会受阻 |

> 关于未探测到编辑器：`/Applications/Unity/Hub/Editor` 不存在，`unity` 也不在 `PATH`。
> 如果编辑器装在自定义位置，接入时需提供路径，否则 CCGS 的 Unity 侧验证无法执行。

---

## 3. 接入方式对比

| 方案 | 框架根 | 优点 | 代价 / 风险 |
|---|---|---|---|
| **A. 装到 `UnityProject`（推荐）** | `cross-match/UnityProject` | `Assets/` 可直接解析；`/adopt`、`/reverse-document`、`/dev-story` 全部可用 | 新增 `.claude/` 第二套技能目录，与 `AGENTS.md` 的「唯一源」约定冲突 |
| B. 装到仓库根 | `cross-match` | 不侵入 UnityProject | 代码根解析失败，所有代码审计为 `NOT ASSESSED`；只能做文档/基础设施审计 |
| C. 独立 studio 工作区 | 新目录 | 完全不污染现有仓库 | 需要人工同步代码与文档，框架默认不支持外部代码根 |

**推荐 A。** 若治理上不接受 A，则先用 B 只跑 `/adopt` 的文档与基础设施部分，
但不要期待任何代码级审计结果。

---

## 4. 接入流程（未来执行时使用）

### Phase 0 —— 准备（不改框架）

```bash
cd /Volumes/ORICO/cross-match
git status                       # 先确认并提交/备份现有改动
git switch -c chore/ccgs-onboarding
```

检查项：

- [ ] 现有未提交改动已提交或另存分支
- [ ] 确认 Unity 编辑器实际安装路径（当前未在标准 Hub 目录与 `PATH` 中找到）
- [ ] 确认是否允许在 `UnityProject` 下新增 `.claude/`

### Phase 1 —— 复制框架（只复制清单内文件）

**不要**整目录拷贝框架根。以下文件/目录复制到 `UnityProject/`：

| 复制项 | 说明 |
|---|---|
| `.claude/` | 代理、技能、钩子、规则、脚本（约 134 MB） |
| `CLAUDE.md` | 框架主配置（目标工程无同名文件） |
| `project.yaml` | 模板配置，随后由 `/setup-engine`、`/start` 改写 |
| `docs/engine-reference/` | Unity 版本参考与最佳实践 |
| `docs/registry/`、`docs/architecture/tr-registry.yaml` | 注册表骨架 |
| `design/CLAUDE.md`、`design/registry/` | 设计目录骨架 |
| `production/`（仅骨架） | 生产目录；`session-state/`、`session-logs/` 需忽略 |

**禁止复制**：`assets/`、`tools/`、`tests/`、`src/`、`prototypes/`、`studio-tests/`、`.github/`、`README.md`、`.gitignore`。
其中 `assets/`、`tools/`、`tests/` 在 macOS 大小写不敏感文件系统上会与 Unity 的
`Assets/`、`Tools/` 以及可能的 `Tests/` 混淆或合并。

同时在 `UnityProject/.gitignore`（新建，不要改仓库根 `.gitignore`）中加入：

```gitignore
project.local.yaml
production/session-state/
production/session-logs/
```

### Phase 2 —— 固定引擎

在 `UnityProject` 根启动 Claude Code，执行：

```text
/setup-engine unity 6000.6.6f1
```

预期：

- `project.yaml` 写入 `engine.name: unity` 与版本
- `CLAUDE.md` 技术栈改为 Unity / C#
- `docs/engine-reference/unity/VERSION.md` 的 `Installed at pin time` 记录探测结果
- 版本对比会命中「不匹配」（参考固定线为 6.3 LTS）→ 选择**固定已安装版本**
- 在项目内保留告警：**6.4+ API 未在 CCGS 参考目录中逐条核实**

### Phase 3 —— 设定项目模式与阶段

```text
/start
```

选择「已有工作」路径。建议：

- `modes.rigor: minimal` —— 先以最低文档成本完成接入，后续用 `/settings` 升级
- `modes.automation: collaborative` —— 保持每步确认
- `project.stage` 按现有代码量应为 Production（有 1605 个源文件）

### Phase 4 —— 现状审计

```text
/adopt
```

产出 `docs/adoption-plan-2026-11-02.md`（日期按实际执行日）。预计结论：

- 无 GDD / ADR / 用户故事 → 建议先 `/reverse-document`
- 无注册表 / control manifest / sprint 状态 → 列入迁移计划
- `Books/` 不会被识别为游戏设计文档

### Phase 5 —— 反向文档化（接入后的下一步，不在本次范围）

```text
/reverse-document architecture UnityProject/Assets/GameScripts
/reverse-document design UnityProject/Assets/GameScripts/GameLogic
```

随后：

```text
/architecture-decision          # 把关键既有决策固化为 ADR
/create-control-manifest        # 生成架构规则表
/create-epics
/create-stories
/dev-story ↔ /story-done
```

### Phase 6 —— 验证接入结果

```bash
cd /Volumes/ORICO/cross-match/UnityProject
bash .claude/scripts/project-state.sh       # 查看 engine / code_root / source_files 行
```

通过标准：

- [ ] `engine.name` = `unity`
- [ ] `resolve_code_root` 返回 `Assets`（在 `UnityProject` 下）
- [ ] `/adopt` 成功产出迁移计划
- [ ] `git status` 只出现预期新增文件，没有覆盖既有文件
- [ ] 既有 `.trae/skills`、`AGENTS.md`、`Books/` 保持原样

---

## 5. 关键风险与决策点

1. **技能目录双源冲突（需你决策）**
   - `UnityProject/AGENTS.md` 要求 `.trae/skills` 为唯一源。
   - 可选：
     - **并行**：Trae 会话用 `.trae`，Claude Code 会话用 `.claude`，互不引用（推荐，改动最小）
     - **单源**：把 CCGS 技能迁入 `.trae/skills`（成本高，且 CCGS 技能依赖 `.claude/` 相对路径，不建议）
2. **代码根大小写陷阱（已规避）**
   - 只复制 `.claude/` 等清单项，不复制框架的 `assets/`、`tools/`、`tests/`。
3. **Unity 版本知识缺口**
   - 参考线 6.3 LTS，本机 6.6.6f1。接入后所有 Unity API 建议都要先对照
     `docs/engine-reference/unity/` 或官方文档，6.4+ 未确认项必须显式标注。
4. **编辑器/CLI 未探测到**
   - 接入前需确认 Unity 安装路径，否则 Unity 编译、资源与 Play Mode 验证无法执行。
5. **`01_Project/` 的定位**
   - 看起来是导出/产物工程。不要把它加入代码根，也不要用它替代 `UnityProject` 做验证。
6. **未提交改动**
   - 目标仓库当前有大量未提交修改（`.gitignore`、`AGENTS.md`、`Books/*`）。
     接入必须在新分支进行，且不得回滚这些改动。
7. **框架运行环境**
   - CCGS 为 Claude Code 设计；在 Trae 中运行时 `.claude` 钩子不会自动加载，
     技能需手动读取 `SKILL.md`。若要在 Trae 中完整体验，需另行决定是否镜像到 `.trae/skills`。

---

## 6. 不在本次范围

- 实际复制/安装框架
- 修改 `UnityProject` 的代码、资源、`ProjectSettings`、`Packages`
- 生成 GDD/ADR/用户故事
- 创建 epic、story 或执行 `/dev-story`
- 提交、推送或发布

---

## 7. 下一步

如果确认方案 A，按以下顺序执行：

1. 在 `cross-match` 新建接入分支并确认现有改动已保存
2. 按 Phase 1 清单复制框架（仅清单项）
3. `/setup-engine unity 6000.6.6f1`
4. `/start`（rigor = minimal，automation = collaborative）
5. `/adopt` 生成迁移计划，再决定是否 `/reverse-document`
