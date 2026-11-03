# /gate-check —— 第 7 与 8 节：下一步与后续行动

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 7. 收尾的下一步控件

**本文件包含：**

- 7. 收尾的下一步控件：逐闸门的选项，以及 `workflow: minimal` 路线
- 8. 后续行动

在呈现结论并完成任何阶段更新（project.yaml + stage.txt）之后，用 `AskUserQuestion` 以结构化下一步提示收尾。

**按刚运行的闸门定制选项。** 参数点名的是即将进入的阶段，因此 `/gate-check systems-design` 是 Concept → Systems Design 闸门。

**在 `workflow: minimal` 下，跳过下面的菜单。** 它们沿着阶段阶梯走，
而 minimal 路线不是这个阶梯：改为提供
`paths.minimal` 中的第一个未完成步骤（第 3 节中的 `--path minimal` 行）：
`/setup-engine`，然后 `/brainstorm`（当代码根中已有游戏时，用
`/reverse-document design [code root]`：它会根据已构建的内容写出简报），然后 `/create-stories`，然后对下一个用户故事运行 `/dev-story`——
这就是 `/help` 给出的路线。

对于 **Concept → Systems Design**（`/gate-check systems-design`）PASS——当 `design/gdd/systems-index.md` 尚不存在时，选项 [A] 是
`/map-systems`（许多项目会在 Concept 期间编写它，正如工作流目录所排序的那样），否则是
`/design-system [索引设计顺序中的第一个系统]`：
```
Gate passed. What would you like to do next?
[A] Run /map-systems — decompose the concept into systems and a design order (recommended next step)
    — or, when the systems index already exists: Run /design-system [first system] — author its GDD
[B] Revisit the concept first — return here when it is settled
[C] Stop here for this session
```

对于 **Systems Design → Technical Setup**（`/gate-check technical-setup`）PASS：
```
Gate passed. What would you like to do next?
[A] Run /create-architecture — produce your master architecture blueprint and ADR work plan (recommended next step)
[B] Design more GDDs first — return here when all MVP systems are complete
[C] Stop here for this session
```

> **Systems Design → Technical Setup PASS 的注意事项**：`/create-architecture` 是撰写任何 ADR 之前必需的下一步。它会产出一份主架构文档以及一份待撰写 ADR 的优先级列表。跳过这一步就直接运行 `/architecture-decision`，意味着在没有蓝图的情况下写 ADR——后果自负。

对于 **Technical Setup → Pre-Production**（`/gate-check pre-production`）PASS：
```
Gate passed. What would you like to do next?
[A] Run /create-control-manifest — generate the layer rules manifest from your Accepted ADRs (first, if docs/architecture/control-manifest.md does not exist yet)
[B] Run /vertical-slice — build the Vertical Slice (do this before writing epics — validate fun first)
[C] Write more ADRs first — run /architecture-decision [next-system]
[D] Stop here for this session
```

> **Technical Setup → Pre-Production PASS 的注意事项**：Pre-Production 的顺序是刻意安排的，
> 目的是在投入详细规划之前先验证趣味性：
>
> 1. `/create-control-manifest` —— 如果尚未完成，从 Accepted 的 ADR 中提取技术规则（`/create-epics` 在 `full` 下要求它）
> 2. `/vertical-slice` —— **首先**构建垂直切片，在编写史诗或用户故事之前
> 3. 试玩测试 → `/playtest-report` —— 至少 1 次有记录的会话，投入完整团队前最好 3 次以上。`/gate-check production` 把切片视为推荐项：跳过 → CONCERNS，未玩过 → NOT ASSESSED
> 4. `/ux-design [screen]` —— 主菜单、核心 HUD、暂停菜单的 UX 规格（若尚未完成）
> 5. `/create-epics layer:foundation` 然后 `/create-epics layer:core` —— 在趣味性得到验证后再规划
> 6. 对每个史诗运行 `/create-stories [epic-slug]`
> 7. `/sprint-plan new`
>
> **为什么先做原型再做史诗？** 如果原型表明核心循环需要改变，
> 在那项发现之前写好的史诗会部分出错。先以低成本验证趣味性，
> 再详细规划。这是 GDC 复盘数据中的头号教训。

对于其他所有闸门，提供该阶段最合乎逻辑的两个下一步，外加“在此停止”。

---

## 8. 后续行动

根据结论，建议具体的下一步：

- **没有美术圣经？** → `/art-bible` 创建视觉识别规格
- **美术圣经存在但没有资源规格？** → `/asset-spec system:[name]` 从已批准的 GDD 生成逐资源的视觉规格与生成提示
- **没有游戏概念？** → `/brainstorm` 创建一个
- **没有系统索引？** → `/map-systems` 把概念分解为系统
- **缺少设计文档？** → `/reverse-document`，或委托给 `game-designer`
- **需要小的设计变更？** → `/quick-design` 用于实现工作量约一周以内的变更（绕过完整 GDD 流水线）
- **没有 UX 规格？** → `/ux-design [screen name]` 撰写规格，或 `/team-ui [feature]` 走完整流水线
- **UX 规格未评审？** → `/ux-review [file]` 或 `/ux-review all` 进行校验
- **没有无障碍需求文档？** → `/ux-design accessibility` 写入 `design/accessibility-requirements.md`
- **没有交互模式库？** → `/ux-design patterns` 初始化它
- **概念或某个 GDD 未评审？** → `/design-review [doc]`
- **GDD 未做交叉评审？** → `/review-all-gdds`（在所有 MVP GDD 单独批准后运行）
- **存在跨 GDD 一致性问题？** → 修正被标记的 GDD，然后重新运行 `/review-all-gdds`
- **没有测试框架？** → `/test-setup` 为你的引擎搭建框架脚手架
- **当前冲刺没有 QA 计划？** → `/qa-plan sprint` 在实现开始前生成一份
- **缺少 ADR？** → `/architecture-decision` 处理个别决策
- **没有主架构文档？** → `/create-architecture` 生成完整蓝图
- **ADR 缺少引擎兼容性章节？** → 重新运行 `/architecture-decision`
  或手动为现有 ADR 添加 Engine Compatibility 章节
- **缺少控制清单？** → `/create-control-manifest`（需要 Accepted 的 ADR）
- **缺少史诗？** → `/create-epics layer: foundation` 然后 `/create-epics layer: core`（需要控制清单）
- **某个史诗缺少用户故事？** → `/create-stories [epic-slug]`（每个史诗创建后运行）
- **用户故事未达可实施状态？** → `/story-readiness` 在开发者领取前校验用户故事
- **测试失败？** → 委托给 `lead-programmer` 或 `qa-tester`
- **没有试玩数据？** → `/playtest-report`
- **试玩测试会话未超过最低要求？** → 更多会话能提供更可靠的信号。投入完整团队前推荐总计 3 次以上。用 `/playtest-report` 整理发现。
- **没有难度曲线文档？** → 按 `.trae/docs/templates/difficulty-curve.md` 的模板手工撰写 `design/difficulty-curve.md`。（`/quick-design` 是相关的会话，但写入 `design/quick-specs/`，而不是这个路径——可以用它把曲线想清楚，再把结果复制到这里。）
- **没有玩家旅程地图？** → 按 `.trae/docs/templates/player-journey.md` 的模板手工撰写 `design/player-journey.md`。

> **这两者都没有负责写入的技能——不要点名任何技能。**
> “`/ux-design` Phase 2b” 是*读取* `design/player-journey.md` 的步骤，
> 因此它会把用户带回刚刚失败的检查。`/quick-design`
> 写入的是 `design/quick-specs/[name]-[date].md`，并让本闸门
> 仍然失败。请直说这两份文档都需要按各自模板手工撰写。
- **需要快速冲刺检查？** → `/sprint-status` 获取当前冲刺进度快照
- **性能未知？** → `/perf-profile`
- **未本地化？** → `/localize`
- **没有安全审计，或存在未关闭的 CRITICAL/HIGH 发现项？** → `/security-audit`（修复后，用 `/security-audit quick` 确认）
- **准备好发布了？** → `/launch-checklist`

---
