> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# TD-MANIFEST — 控制清单评审

Agent：`technical-director` | 模型层级：session（继承） | 领域：架构、引擎风险、性能

**触发时机**：控制清单（control-manifest）规则已提取并预览之后
（`/create-control-manifest` Phase 4），在清单文件写入之前

**需传入的上下文**：
- Phase 4 的控制清单预览（各层规则数量、完整提取的规则清单）
- 已覆盖的 ADR 清单
- 引擎版本
- 任何取自 `technical-preferences.md` 或引擎参考资料文档的规则

**提示词**：
> "在写入之前审查这份控制清单。所有强制性 ADR 模式是否都已捕获并准确陈述？违禁
> 做法是否完整，且正确归属到其来源 ADR？是否加入了缺少来源 ADR 或偏好文档的规则
> ——即凭空发明而非提取的规则？性能护栏是否与 ADR 实际设定的约束一致？返回
> APPROVE、CONCERNS [列出需要修订的具体规则]，或 REJECT [错误或无出处的规则，
> 必须在写入清单前修正]。"

**结论**：APPROVE / CONCERNS / REJECT
