# /gate-check —— 第 6 节：在 PASS 时更新阶段

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 6. 在 PASS 时更新阶段

当结论为 **PASS** 且用户确认要推进时，把新阶段同时写入
`project.yaml` 和旧版 `production/stage.txt`。

**在 CONCERNS 下，用户可以覆盖——必须明确。** 不要默认提供阶段
写入。如果用户仍要求推进，请列出每一条关注项并
询问：“闸门返回了 CONCERNS。请接受这些风险——[列表]——我可以把
`project.yaml` 中的 `project.stage` 更新为 '[stage]'（并更新旧版
`production/stage.txt`）吗？”只有在明确同意时，才在闸门报告中加入
`### Accepted Risks` 一节（每条关注项、由用户接受、附日期），并按下方
写入阶段。**FAIL 绝不被覆盖为阶段变更，NOT ASSESSED 也一样**
——必须修复阻塞项，或产出缺失的输入，然后重跑闸门。这在 CONCERNS
结论内部同样成立：CONCERNS 在结论中高于 NOT ASSESSED，但只要还有
任何必需检查为 NOT ASSESSED，就不会提供覆盖。点名每一项这样的检查，
以及怎样才能让它运行。

### 6.1 写入阶段

在用户同意后，用一条命令写入两个阶段文件（两个词的阶段名要加引号）：

```bash
bash .trae/scripts/set-stage.sh "<new-stage>"
```

它会设置 `project.yaml` 中的 `project.stage`：编辑 `stage:` 行，
在缺少 `project:` 块时于 `framework:` 之后添加，或在没有 `project.yaml` 时
从最小模板创建文件。它会保留注释、其他
键和行尾格式。它还会写入旧版 `production/stage.txt`，以便尚未迁移的钩子
仍能工作，然后回读两个文件。它绝不预置
`modes.review_mode`：那由 `modes.rigor` 提供，显式值会把
评审模式固定住，无论项目的严格度如何。

### 6.2 核实两次写入

展示它的 `stage_yaml` 与 `stage_txt` 行。退出码 0 表示两个文件都持有新
阶段。退出码 4 表示写入后两者不一致：向用户报告这一差异并停止，
因为分裂的阶段指示器会破坏未来的自动检测。
退出码 5 表示 `project.yaml` 的布局是脚本不会编辑的（`project:` 是
单行值）：什么也没写入，因此要说明这一点，并在用户同意后手动编辑
`project.yaml`。任何其他非零退出码：报告消息并停止。

**写入前始终询问**：“闸门已通过。我可以把 `project.yaml` 中的 `project.stage` 更新为 'Production'（并更新旧版 `production/stage.txt`）吗？”——在接受 CONCERNS 覆盖时，上文的明确同意就是这次询问。

### 6.3 严格度匹配检查（建议性——绝不影响结论）

在确认阶段推进后，应用
`.trae/docs/settings-guidance.md § 4` 中的提升触发条件：如果新阶段是 **Production**（或更晚），
而已解析的 `modes.workflow` 是 `minimal`（即上文配置块中的 `rigor: minimal`
态势），则添加一行：

> “你正以 `rigor: minimal` 进入 [stage]——这个规模的大多数项目运行
> `standard`。是否用 `/settings modes.rigor=standard` 重新考虑？”

在这里的闸门处**提供一次**即可。引导到 `/settings`——绝不要自己更改
设置。

---
