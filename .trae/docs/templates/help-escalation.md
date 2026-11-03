---
需要更多细节？
- `/project-stage-detect` — 完整差距分析，列出所有缺失的产出物
- `/gate-check` — 针对下一阶段的正式就绪检查
- `/start` — 从头重新定位
- `/settings` — 如果流程与你的项目不匹配，可调整
  `modes.rigor`。应用
  `.trae/docs/settings-guidance.md § 4` 中的变更触发条件：当用户对流程
  感到不堪重负时（且 rigor 尚未是 `minimal`）**下调**层级；或当项目
  已超出该层级时（系统众多，或在 `workflow: minimal` 下进入 Production）**上调**层级
