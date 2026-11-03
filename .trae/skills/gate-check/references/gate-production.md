> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。




# 质量闸门：Pre-Production → Production

**必需产出物：**
- [ ] 垂直切片存在于 `prototypes/` 中并带有 REPORT.md（运行 `/vertical-slice`）——**推荐，非阻塞**；若缺失，作为 CONCERNS 呈现
- [ ] 首个冲刺计划存在于 `production/sprints/`
- [ ] 美术圣经完整（全部 9 节），且 AD-ART-BIBLE 签核结论记录在 `design/art/art-bible.md` 中——当 `review_mode` 跳过该闸门（`lean`、`solo`）时，由 `/art-bible` 记录的 `SKIPPED` 签核行代替；在此类项目上，若文件头仍写着 `[Not yet reviewed]`，应读作“已跳过签核——[mode] 模式”，绝不算作缺失
- [ ] 实体清单存在于 `design/assets/entity-inventory.md`（推荐——无参数运行 `/asset-spec`，从 GDD + 美术圣经协作生成）
- [ ] 系统索引中的所有 MVP 层级 GDD 都已完成
- [ ] 主架构文档存在于 `docs/architecture/architecture.md`
- [ ] `docs/architecture/` 中至少有 3 份覆盖 Foundation 层决策的 ADR
- [ ] 所有 Foundation 与 Core 层 ADR 的状态均为 `Accepted`（而非 `Proposed`）——在治理该故事的 ADR 被接受之前，用户故事无法解除阻塞
- [ ] 控制清单存在于 `docs/architecture/control-manifest.md`
      （由 `/create-control-manifest` 从 Accepted 的 ADR 生成）
- [ ] 史诗已在 `production/epics/` 中定义，且至少包含 Foundation 与 Core
      层史诗（用 `/create-epics layer: foundation` 和
      `/create-epics layer: core` 创建，然后对每个史诗运行
      `/create-stories [epic-slug]`）
- [ ] 垂直切片构建存在且可玩（不只是划定了范围）——**推荐，非阻塞**；若缺失，作为 CONCERNS 呈现
- [ ] 垂直切片已经过试玩测试，至少有 1 次有记录的会话——**推荐，非阻塞**；若缺失，作为 CONCERNS 呈现
- [ ] 垂直切片试玩测试报告存在于 `production/qa/playtests/` 或等价位置——**推荐，非阻塞**；若缺失，作为 CONCERNS 呈现
- [ ] 关键界面已有 UX 规格：主菜单、核心玩法 HUD（位于 `design/ux/`）、暂停菜单
- [ ] HUD 设计文档存在于 `design/ux/hud.md`（若游戏有游戏内 HUD）
- [ ] 所有关键界面的 UX 规格都通过了 `/ux-review`（结论为 APPROVED，或 NEEDS REVISION 已被接受）

**质量检查：**
- [ ] **核心循环的趣味性已得到验证**——试玩数据确认核心机制令人愉快，而不仅仅是可运行。明确检查垂直切片试玩测试报告。
- [ ] UX 规格覆盖 MVP 层级 GDD 中的所有 UI Requirements 章节
- [ ] 交互模式库记录了关键界面中使用的模式
- [ ] `design/accessibility-requirements.md` 中的无障碍层级已在所有关键界面 UX 规格中得到处理
- [ ] 冲刺计划引用 `production/epics/` 中真实的用户故事文件路径
      （不只是 GDD——用户故事必须内嵌 GDD 需求 ID + ADR 引用）
- [ ] **垂直切片是完整的**，而不只是划定了范围——构建端到端展示了完整的核心循环。至少一个完整的 [开始 → 挑战 → 解决] 循环可运行。
- [ ] 架构文档在 Foundation 或 Core 层没有未解决的未决问题
- [ ] 所有 ADR 都有带引擎版本标记的 Engine Compatibility 章节
- [ ] 所有 ADR 都有 ADR Dependencies 章节（即便所有字段都是“None”）
- [ ] 人工校验确认 GDD + 架构 + 史诗彼此连贯
      （若近期未做，运行 `/review-all-gdds` 与 `/architecture-review`）
- [ ] **核心幻想已得到传达**——至少一名试玩者主动描述了与核心系统 GDD 中 Player Fantasy 章节相符的体验（在未被提示的情况下）。

**垂直切片校验**（仅在已构建垂直切片时运行这些检查）：
- [ ] 有人在没有开发者引导的情况下玩通了核心循环
- [ ] 游戏在游玩的前 2 分钟内传达了该做什么
- [ ] 垂直切片构建中不存在关键的“趣味阻塞”缺陷
- [ ] 核心机制的交互手感良好（这是主观检查——询问用户）

> **垂直切片的结论规则：**
> - **切片已构建且任何校验项为 NO** → 结论自动为 FAIL。损坏
>   或无趣的垂直切片不应推进到 Production。
> - **切片已构建但其报告为 NOT ASSESSED**（没人玩过）→ 它不算
>   PROCEED，其校验项也未检查（它们不是 NO）：垂直切片
>   校验块不运行，因此上面的 FAIL 规则不适用。该闸门项为 NOT
>   ASSESSED，绝不算通过——“还没玩过”对“有人玩过”这一问意味着同样结果。
> - **切片未构建（跳过）** → 仅降级为 CONCERNS，而非 FAIL。清晰地
>   呈现风险：“在没有经过验证的垂直切片的情况下推进，会增加后期设计
>   转向的风险。建议在投入完整制作范围之前完成。”由用户决定。
> - 跳过是独立开发者或时间受限情况下的合理选择。交付损坏的切片则不是。

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的
削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的
机制。

- **`full`** —— 冲刺计划 + 完整的（9 节）美术圣经 + 史诗 + UX 规格 + 控制清单全部必需；**垂直切片保持其第 2 节状态**（见注）——其试玩测试为推荐，1 次有记录会话，3 次以上更佳
- **`standard`** —— 史诗 + 冲刺计划必需；美术圣经完整 + UX 规格 + 控制清单 → 推荐；**垂直切片保持其第 2 节状态**
- **`minimal`** —— 只有 minimal 底线：一份填写完整的 **`design/game-brief.md`**（含其构建顺序），以及 `production/epics/` 下的**用户故事**（`workflow-modes.md`——简报的构建顺序就是计划，因此**没有冲刺计划**）；其余一切**取消**——冲刺计划、史诗、试玩测试、美术圣经、实体清单、MVP GDD、主架构文档、两项 ADR 项、控制清单、UX 项（关键界面规格、HUD 文档、`/ux-review`）以及垂直切片项（切片、其试玩测试、垂直切片校验块）——由下面的两项当前构建检查替代
  **`minimal` 下的质量检查：** 每一项读取被取消产出物的检查也随之取消——冲刺计划、架构、两项 ADR、GDD 连贯性、UX 与无障碍检查，以及 Player Fantasy 检查（没有 GDD 承载它）。仍有两项适用，针对当前构建而非切片：**核心循环有趣**（询问用户，或若有试玩笔记则读取）以及**能端到端跑通**——一个完整的开始 → 挑战 → 解决循环。对任一回答“否”即为 FAIL，与在已构建切片上回答 NO 在其他层级的效果相同；对趣味性问题回答“还没”意味着没人玩过该构建——NOT ASSESSED。

> **垂直切片在 `full` 与 `standard` 下保持其第 2 节状态。** Pre-Production → Production
> 的“原型/垂直切片”底线**不会**被层级表提升为
> 阻塞——垂直切片产出物保持*推荐、
> 非阻塞*（缺失 → CONCERNS，而非 FAIL），完全如第 2 节所定义，
> 在 `full` 与 `standard` 下都一样。在 `minimal` 下它们取消——minimal 路线从不
> 构建切片——由两项当前构建检查替代。本闸门真正
> 必需的底线项是 `standard` 与 `full` 下的**冲刺计划**，
> 以及 `minimal` 下的**简报构建顺序加用户故事**。在所有层级都具约束力的
> 一条硬规则：如果垂直切片*已构建*且其任何校验项为 NO（在 `minimal` 下，
> 若当前构建未通过其两项检查中的任一项），结论为 FAIL，无论层级如何——层级削减放宽的是
> 必须*存在*的东西，绝不是必须*可用*的东西。
