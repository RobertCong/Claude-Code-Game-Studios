# /gate-check —— 第 2b 节：工作流层级调整

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 2b. 工作流层级调整

**本文件包含：**

- 如何应用闸门文件的层级削减
- `qa.level` 与测试项；冒烟检查是底线
- 没有剩余必需产出物的闸门为 NOT ASSESSED，但有一个例外
- `performance.enforce`
- 按系统覆盖（`workflow_overrides.system_overrides`），以及叠加式覆盖

每个闸门文件都带有自己的层级削减（见第 2 节）。有两条规则适用于所有闸门：

> **如何应用：** 先运行已加载闸门的清单，再对第 1 节解析出的层级应用该
> 文件的层级削减。**drop** = 本层级不检查；**→ recommended** = 缺失时呈现为
> CONCERNS，绝不算阻塞项；未点名的条目保持其基线状态。削减只会*放宽*
> 要求——唯一会新增要求的是 `workflow_overrides`（见下文）。
>
> **`qa.level`（第 1 节）会独立于层级进一步放宽测试项：** 在
> `qa.level: minimal` 下，测试证据 / 单元测试项在每个工作流层级都变为
> 非必需（因此即便 `workflow: full` 也不要求它们）；第 3 节的
> `testing.strict` 检查随之成为空操作。
>
> **它放宽的是测试，不是观感。** 只要闸门文件要求用户故事证据，
> UI 用户故事的留存截图，以及 Visual/Feel 用户故事的截图加主管签核，
> 在每个 `qa.level` 下都是必需的
> （`.claude/docs/coding-standards.md`：测试在 `minimal` 下被豁免，但观感
> 不是）。
>
> **冒烟检查不在该放宽范围内，它就是底线。**
> `qa.level` 放宽的是*逐故事的测试证据*；冒烟检查是**构建健康度**，
> 不是用户故事证据，二者在 `.claude/docs/coding-standards.md` 中正是依据这一
> 区别被分开的（“`/smoke-check` 是构建健康度闸门，不是
> 逐故事证据闸门……这种差异是有意为之”）。因此，要求冒烟报告的闸门文件
> 在每个 `qa.level` 下都继续要求它。
>
> 若没有这一排除，Production → Polish 闸门在 `rigor: minimal` 下将
> **没有任何必需产出物**，从而在构造上不可能因产出物而失败：
> `minimal` 把闸门削减到只剩冒烟检查，`qa.level` 随后又会把冒烟检查也拿掉，
> 而这两者由同一个 `modes.rigor` 设置同时触发。

> **没有剩余必需产出物的闸门必须说明这一点，且不得返回 PASS。**
> 在应用层级削减和 `qa.level` 放宽之后，统计还剩多少必需项。如果计数为
> 零，就报告 **NOT ASSESSED**，并同时点名两个削减机制和该闸门——
> *“`workflow: minimal` + `qa.level: minimal` 下的 Production → Polish
> 没有留下任何必需产出物；本闸门未核实任何内容”*——而不是让
> 一个因为无可检查而得的 PASS 通过。按照 `.claude/rules/skill-authoring.md`
> 的第 1 条义务，无法评估自身范围的运行并未确认范围良好，而第 3 条义务
> 要求这种空无必须在输出中可见，而不是从一个沉默的绿灯中推断出来。
>
> **唯一的例外：层级参考文件把某闸门标记为在本层级“不适用”**
> （`workflow: minimal` 下的 Systems Design → Technical Setup）。那不是
> 无物可查的闸门，而是该层级不存在的一次跃迁：
> 它按该文件的说明以 PASS 结束，并在报告中打印该说明。总监面板
> 不会为它运行——注明“已跳过总监面板——闸门在
> `workflow: [tier]` 下不适用”——第 6 节的阶段写入仍会先询问。
>
> **`performance.enforce` 同样独立于层级，层级削减绝不会压制它。**
> 第 3 节中的性能检查在每个工作流层级都会运行，而 `block` 会让违规
> 在每个工作流层级都成为阻塞项。**不要**把闸门文件里的
> *“其余全部取消”* 读成把性能检查也取消：
> `off` 是唯一能让预算变成参考信息的设置，而它是用户在同一键上
> 主动做出的选择。
>
> 这在 `rigor: minimal` 项目上影响最大：Polish 闸门的 `minimal`
> 削减会把底线之外的一切取消，而“性能在预算内”正属于被取消的
> 剩余部分。无论如何都要运行该检查。

### 按系统覆盖（`workflow_overrides.system_overrides`）

独立于上述项目级层级，且**仅**在那些校验 MVP GDD 的闸门上应用
（Systems Design → Technical Setup，以及 Pre-Production → Production 中的
GDD 完整性检查）。对每个系统，解析其有效层级：

1. 如果该块的 `system_overrides` 列出了 `<system>` → 使用该层级
2. 否则使用项目级 `workflow`

**在应用其中任何一项之前，请反过来检查这个块：每个 KEY 都对应一个系统吗？**
`<system>` 是 GDD 的文件名主干
（`.claude/docs/workflow-modes.md`），因此对 `system_overrides` 中的每个键，
在 `design/gdd/<key>.md` 中查找。任何找不到匹配主干的键都会被报告，
并点名该键及实际存在的主干列表：

> `system_overrides key 'no-such-system' matches no GDD in design/gdd/. Available stems: combat, inventory, forge-heat-system. This override is doing nothing.`

把它作为 **CONCERNS** 级别的发现项呈现，而不是阻塞项——项目仍可通过
闸门，但一个用户以为生效、实际并未生效的覆盖，正是
有文档记录的兜底出口悄悄失效的方式。

这就是 `.claude/docs/workflow-modes.md` 中的规则：匹配不到任何系统的键
是错误，而不是空操作。用户故事类的技能只按系统 → 覆盖的方向解析，
因此孤儿键对它们不可见；`/gate-check` 会解析整个块，所以它是
发现该问题的地方。

按每个 GDD 自身有效层级的章节数进行校验：

- 被钉在**高于**项目层级的系统（例如 `standard` 项目中的
  `system_overrides.combat: full`）在该系统的 GDD 满足更高标准
  （combat → 全部 8 个章节）之前会**阻塞闸门**。这是按系统设置
  让闸门比项目层级*更严格*的唯一情形。
- 被钉在**较低**层级的系统（例如 `inventory: minimal`）只放宽该系统
  ——其 GDD 按较低层级检查；其他所有系统仍保持项目
  层级。被钉为 **`minimal` 的系统完全不施加 GDD 章节要求**
  （`minimal` = “游戏简报取代 GDD”——`.claude/docs/workflow-modes.md`）：
  它绝不会因 GDD 缺失或不完整而阻塞闸门。不要为它发明一个
  “仅验收标准”的底线——并不存在这样的底线。

> **叠加式覆盖（唯一会让闸门更严格的东西）。**
> - `workflow_overrides.art_bible_strict: true` 会在 Technical Setup → Pre-Production
>   和 Pre-Production → Production 闸门上强制要求完整的（9 章节）
>   美术圣经，无论层级如何、也无论是否存在视觉资源用户故事。
> - `workflow_overrides.edge_cases: true` 与 `workflow_overrides.tuning_knobs:
>   true` 会在校验 GDD 完整性时强制要求相应 GDD 章节，
>   在解析出的层级之上叠加（例如在 `standard` 下，`tuning_knobs: true`
>   会让本可选的 Tuning Knobs 章节变为阻塞）。这些绝不
>   放宽——`false` 值是默认值/空操作，绝不是去掉某个
>   层级已要求章节的手段。

---
