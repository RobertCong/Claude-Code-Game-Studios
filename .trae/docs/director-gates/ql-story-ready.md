> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# QL-STORY-READY — QA 主管用户故事就绪度检查

Agent：`qa-lead` | 模型层级：session（继承）

**触发时机**：用户故事被接纳进冲刺之前——由 `/create-stories`
与 `/story-readiness` 发起

**需传入的上下文**：
- 用户故事文件路径——或，来自 `/create-stories`（它在写入任何用户故事前运行本闸门）的，故事内联内容
- 故事类型（Logic / Integration / Visual/Feel / UI / Config/Data）
- 验收标准清单（逐字取自该故事）
- 该故事覆盖的 GDD 需求（TR-ID 与文本）

**提示词**：
> "在该故事进入冲刺之前，审查其验收标准的可测试性。所有标准是否都足够具体，使
> 开发者能明确知道何时完成？对于 Logic 类故事：每条标准是否都能通过自动化测试
> 验证？对于 Integration 故事：每条标准是否都能在受控测试环境中观察到？标出过于
> 模糊而无法据以实施的标准，以及需要完整游戏构建才能测试的标准（将这些标为
> DEFERRED，而非 BLOCKED）。返回 ADEQUATE（标准按原样可实现）、GAPS [需要细化的
> 具体标准]，或 INADEQUATE [标准过于模糊——故事必须修订后才能纳入冲刺]。"

**结论**：ADEQUATE / GAPS / INADEQUATE
