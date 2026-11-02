> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# CD-GDD-ALIGN — GDD 支柱一致性检查

Agent：`creative-director` | 模型层级：session（继承） | 领域：愿景、支柱、玩家体验

**触发时机**：系统 GDD 编写完成后（design-system，或任何产出 GDD 的工作流）

**需传入的上下文**：
- GDD 文件路径
- 游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`；若两者皆无，`design/game-brief.md` 不含支柱——改传其提案与 "what they feel" 一行）
- 本游戏的 MDA 美学目标
- 系统所声明的 Player Fantasy 章节

**提示词**：
> "审查这份系统 GDD 的支柱一致性。每个章节是否都服务既定支柱？是否存在与某个
> 支柱相矛盾或削弱它的机制或规则？Player Fantasy 章节是否匹配游戏的核心幻想？
> 返回 APPROVE、CONCERNS [存在问题的具体章节]，或 REJECT [必须重新设计后本系统
> 才能实现的支柱违规]。"

**结论**：APPROVE / CONCERNS / REJECT
