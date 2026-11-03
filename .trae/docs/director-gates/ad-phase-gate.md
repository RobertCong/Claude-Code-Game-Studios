> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# AD-PHASE-GATE — 阶段转换时的视觉就绪度

Agent：`art-director` | 模型层级：session（继承） | 领域：视觉识别、美术圣经、视觉制作就绪度

**触发时机**：在 `/gate-check` 中且 `modes.workflow` 为 `full` 时——评审小组按工作流收窄，只有 full 小组才包含 art-director；与 CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE 并行发起

**需传入的上下文**：
- 目标阶段名称与解析出的 `workflow` 层级
- 在解析层级下目标闸门必需与推荐的产出物（来自 `/gate-check` 已加载的闸门文件）
- 现存所有美术/视觉产出物的列表（文件路径）
- 来自 `design/gdd/game-concept.md` 的视觉识别锚点（如存在；若没有 `design/gdd/game-concept.md`，则用 `design/game-brief.md` 中 "Art & audio direction" 一行）
- 美术圣经路径（如存在，`design/art/art-bible.md`）

**提示词**：
> "从视觉方向角度审查当前项目状态相对于[目标阶段]闸门的就绪度，以本闸门在该层级
> 所要求的内容（即提供给你的必需产出物清单）为判据。视觉识别是否已按本阶段要求的
> 程度确立并记录在案？本阶段要求的视觉产出物是否就位？视觉团队能否在没有视觉方向
> 缺口的情况下开工，避免日后代价高昂的返工？是否存在被推迟到最晚责任时点之后的
> 视觉决策？
> 必需产出物被标为 "none" 算作一项发现；标为 "not expected before [phase]" 或
> "not required at `workflow: [tier]`" 则不算发现。
> 返回 READY、CONCERNS [可能导致制作返工的具体视觉方向缺口]，或 NOT READY [本阶段
> 成功之前必须具备的视觉阻塞项——指明缺失的是哪个产出物，以及它为何在此阶段重要]。"

**结论**：READY / CONCERNS / NOT READY
