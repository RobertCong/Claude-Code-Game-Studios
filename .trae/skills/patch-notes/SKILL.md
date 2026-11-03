---
name: patch-notes
description: "根据 git 历史与变更日志生成面向玩家的补丁说明。把开发者语言转译为玩家沟通语言。"
argument-hint: "[version] [--style brief|detailed|full]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.trae/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

# 补丁说明

## 来源校验 —— 在读取任何历史之前

**确认你即将读取的历史属于本游戏。** 在 Phase 2 之前运行此项检查，若不通过就停止。

1. 抽样最近的日志：`git log --oneline -20`。**如果它为空或 git 不可用，跳过此项检查** ——
   没有可分类的内容，Phase 2 的无变更日志数据分支就是正确的停止点。
2. **逐一分类范围内的每一条提交**，归入且仅归入以下之一：
   - **Game** —— 改变玩家所玩的游戏：机制、内容、平衡性、美术、音频、UI，或其中任何一项的
     缺陷。
   - **Framework / maintenance** —— 改变 CCGS 本身或项目工具链：主题涉及技能、钩子、agent、
     测试计划、CI、框架自身文档。**从面向玩家的说明中排除，但不是停止的理由。**
   - **Unclear** —— 按框架处理。无法有把握归位的提交，不适合用来撰写玩家文案。
3. 然后根据计数决定：
   - **至少有一个 Game 提交** → 继续，**只**使用这些提交。说明你从多少条中用了多少条，
     以便读者看到过滤确实执行过。
   - **零个 Game 提交** → 停止，使用下面的消息，并给出计数（从多少条中取 0 条），以便读者
     看到过滤确实执行过。

> **按单个提交过滤；不要因为仓库中仅仅含有维护工作就停止。**
> 建立在本框架上的每个项目都会累积触及钩子、CI 和技能的提交 —— 游戏仓库*就是*框架仓库，
> 所以在仓库层面停止几乎会在每个真实项目上触发。危险不在于这类提交*存在*，而在于它们被
> **渲染成面向玩家的文案**。排除它们恰好能解决这一点，而在仓库层面停止则不能。

继续之前，用低成本的方式佐证：Game 提交应当点名 `design/` 与代码根目录（`src/`、`Assets/`
或 `Source/`）中出现过的系统。如果它们点名的产品在这些目录中从未被提及，那才是真正的错误
历史信号 —— 停止。

如果该范围内**没有**任何提交属于本游戏，说明并停止：

> "此仓库的 git 历史似乎不属于 [game]：最近 [N] 条提交中有 0 条是 Game 提交。这些最近的
> 提交描述的是 [它们实际描述的内容]。我无法据此生成发布说明 —— 请指引我到正确的历史，
> 或直接提供变更清单。"

Verdict：**BLOCKED** —— 就此停止，不生成说明。

**为什么这是硬性停止而非警告。** 框架内部的提交一旦被渲染为玩家文案，读起来就像真实变更：
一个会话钩子超时，会在一个**没有存档系统**的游戏里变成*"修复了上次会话进度可能在启动时
丢失的问题"*。这种文案流畅、可信，却完全虚假。读者无法分辨；只有这项检查能分辨。

---

## Phase 1: 解析参数

- `version`：要为其生成说明的发布版本（例如 `1.2.0`）
- `--style`：输出风格 —— `brief`（要点列表）、`detailed`（含背景）、`full`（含开发者
  评注）。默认：`detailed`。

如果未提供版本，先询问用户再继续。

---

## Phase 2: 收集变更数据

- 如果 `production/releases/[version]/changelog.md` 存在，读取其中的内部变更日志
- 同时检查 `docs/CHANGELOG.md` 中是否有相关版本条目
- 作为后备，在上一发布标签与当前标签/HEAD 之间运行 `git log`
- 读取 `production/sprints/` 中的冲刺回顾以获取背景
- 读取 `design/balance/` 中的任何平衡性变更文档
- 若 QA 处有缺陷修复记录，读取它们

**如果没有可用的变更日志数据**（既不存在 `production/releases/[version]/changelog.md`，
也不存在该版本的 `docs/CHANGELOG.md` 条目，且 git log 为空或不可用）：

> "未找到 [version] 的变更日志数据。请先运行 `/changelog [version]` 生成内部变更日志，
> 然后重新运行 `/patch-notes [version]`。"

Verdict：**BLOCKED** —— 就此停止，不生成说明。

---

## Phase 2b: 检测语气指南与模板

**语气指南检测** —— 起草说明之前，检查写作风格指引：

1. 检查 `.trae/docs/technical-preferences.md` 中是否有任何 "tone"、"voice" 或 "style"
   字段或章节。
2. 如果 `docs/PATCH-NOTES-STYLE.md` 存在，检查它。
3. 如果 `design/community/tone-guide.md` 存在，检查它。
4. 如果任何来源包含语气/口吻/风格指引，提取它们，并应用到所生成说明的语言与表述框架上。
5. 如果在任何地方都找不到语气指引，默认使用：
   对玩家友好、非技术性的语言；热情但不夸张；
   聚焦于玩家体验到的内容，而非开发者改动了什么。

**模板检测** —— 检查是否存在补丁说明模板：

1. Glob `docs/patch-notes-template.md` 与 `.trae/docs/templates/patch-notes-template.md`。
2. 若在任一位置找到，读取它，并在 Phase 4 中用它替代内置风格模板（Brief / Detailed /
   Full）作为输出结构。用已分类的数据填写模板的各个章节，把每个类别映射到含义相同的模板
   章节（New Content → 其 new-features 章节，Bug Fixes → 其 fixes 章节）；没有对应章节的
   类别归入最接近的章节下，绝不丢弃。按原样保留模板的页眉与页脚文字。在输出中说明使用了
   哪个模板 —— 并且，如果传入了 `--style`，说明模板取代了它。
3. 若未找到，使用 Phase 4 中定义的内置风格模板。

---

## Phase 3: 分类与转译

把所有变更归入面向玩家的类别：

- **新内容**：新功能、地图、角色、物品、模式
- **玩法变更**：平衡性调整、机制变更、成长曲线变更
- **体验优化**：UI 改进、便利性功能、无障碍
- **缺陷修复**：按系统归组（战斗、UI、网络等）
- **性能**：玩家可能察觉到的优化改进
- **已知问题**：对未解决问题的透明说明

把开发者语言转译为玩家语言：

- “重构了伤害计算流水线” → “提升了命中判定精度”
- “修复了背包管理器中的空引用” → “修复了打开背包时的崩溃”
- “减少了战斗循环中的 GC 分配” → “提升了战斗性能”
- 移除不影响玩家的纯内部变更
- 保留平衡性变更的具体数值（伤害：50 → 45）

---

## Phase 4: 生成补丁说明

### Brief 风格
```markdown
# Patch [Version] — [Title]

**New**
- [Feature 1]
- [Feature 2]

**Changes**
- [Balance/mechanic change with before → after values]

**Fixes**
- [Bug fix 1]
- [Bug fix 2]

**Known Issues**
- [Issue 1]
```

### Detailed 风格
```markdown
# Patch [Version] — [Title]
*[Date]*

## Highlights
[1-2 sentence summary of the most exciting changes]

## New Content
### [Feature Name]
[2-3 sentences describing the feature and why players should be excited]

## Gameplay Changes
### Balance
| Change | Before | After | Reason |
| ---- | ---- | ---- | ---- |
| [Item/ability] | [old value] | [new value] | [brief rationale] |

### Mechanics
- **[Change]**: [explanation of what changed and why]

## Quality of Life
- [Improvement with context]

## Bug Fixes
### Combat
- Fixed [description of what players experienced]

### UI
- Fixed [description]

### Networking
- Fixed [description]

## Performance
- [Improvement players will notice]

## Known Issues
- [Issue and workaround if available]
```

### Full 风格
包含 Detailed 的全部内容，外加：
```markdown
## Developer Commentary
### [Topic]
> [Developer insight into a major change — why it was made, what was considered,
> what the team learned. Written in first-person team voice.]
```

---

## Phase 5: 检查输出

检查生成的说明是否存在：

- 没有任何内部术语（用玩家友好的语言替换技术术语）
- 不引用内部系统、工单或冲刺编号
- 平衡性变更包含修改前/后的数值
- 缺陷修复描述玩家体验，而非技术原因
- 语气符合游戏的声音（根据游戏风格调整正式程度）

---

## Phase 6: 保存补丁说明

向用户呈现已完成的补丁说明，并附上：按类别统计的变更数量，以及被排除的任何内部变更（供查阅）。

询问："我可以把这些补丁说明写入 `docs/patch-notes/[version].md`，并把一份存档副本写入
`production/releases/[version]/patch-notes.md` 吗？"

若同意，写入两个文件，必要时创建目录。
若不同意，不写入任何内容。

---

## Phase 7: 后续步骤

Verdict：**COMPLETE** —— 补丁说明已生成并保存。（若写入被拒绝：Verdict：**COMPLETE** ——
补丁说明已生成并展示，未保存。）

- 运行 `/release-checklist`，在发布前确认所有其他发布质量闸门均已满足。
- 公开发布前，把补丁说明草稿交给 community-manager 做语气评审。