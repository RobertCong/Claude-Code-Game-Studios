> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# CD-SYSTEMS — 系统拆解愿景检查

Agent：`creative-director` | 模型层级：session（继承） | 领域：愿景、支柱、玩家体验

**触发时机**：`/map-systems` 写完系统索引之后——在 GDD 编写开始前校验完整的系统集合

**需传入的上下文**：
- 系统索引路径（`design/gdd/systems-index.md`）
- 游戏支柱与核心幻想（来自 `design/gdd/game-concept.md`；若没有 `design/gdd/game-concept.md`，则用 `design/game-brief.md` 的提案与 "what they feel" 一行，该文件不含支柱）
- 优先级层级划分（MVP / Vertical Slice / Alpha / Full Vision）
- 依赖图中识别出的任何高风险或瓶颈系统

**提示词**：
> "对照游戏设计支柱审查这套系统拆解。整个 MVP 层级系统集合合起来是否交付了核心
> 幻想？是否存在其机制不服务任何既定支柱的系统——这说明它们可能是范围蔓延？
> 是否存在支柱关键的玩家体验，却没有系统负责交付？核心循环所需的系统是否有
> 缺失？返回 APPROVE（系统服务愿景）、CONCERNS [具体缺口或错位及其支柱影响]，
> 或 REJECT [根本性缺口——拆解遗漏了关键设计意图，必须先修订才能开始 GDD 编写]。"

**结论**：APPROVE / CONCERNS / REJECT
