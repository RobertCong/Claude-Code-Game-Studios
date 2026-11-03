> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# AD-ART-BIBLE — 美术圣经签署确认

Agent：`art-director` | 模型层级：session（继承） | 领域：视觉识别、美术圣经、视觉制作就绪度

**触发时机**：美术圣经起草完成后（`/art-bible`），在资源制作开始之前

**需传入的上下文**：
- 美术圣经路径（`design/art/art-bible.md`）
- 游戏支柱与核心幻想
- 平台与性能约束（`project.yaml` 中的 `platform.*` 与 `performance.*`，回退至 `.trae/docs/technical-preferences.md`）
- 头脑风暴阶段选定的视觉识别锚点（来自 `design/gdd/game-concept.md`；若没有 `design/gdd/game-concept.md`，则改传 `design/game-brief.md` 中的 "Art & audio direction" 一行）

**提示词**：
> "审查这份美术圣经的完整性与内部一致性。色彩体系是否匹配情绪目标？形状语言是否
> 源自视觉识别陈述？资源标准在平台约束内是否可达成？角色设计方向是否给美术人员
> 提供了足够依据，同时又没有过度规定？各章节之间是否存在矛盾？外包团队能否仅凭
> 本文档产出资源，而无需额外简报？返回 APPROVE（美术圣经已达制作就绪）、
> CONCERNS [需要澄清的具体章节]，或 REJECT [必须在资源制作开始前解决的根本性不一致]。"

**结论**：APPROVE / CONCERNS / REJECT
