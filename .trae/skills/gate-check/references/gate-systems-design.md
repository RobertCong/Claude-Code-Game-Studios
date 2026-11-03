> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。


# 质量闸门：Concept → Systems Design


**必需产出物：**
- [ ] `design/gdd/game-concept.md` 存在且有内容
- [ ] 已定义游戏支柱（位于概念文档或 `design/gdd/game-pillars.md` 中）
- [ ] `design/gdd/game-concept.md` 中存在视觉识别锚点章节（来自头脑风暴 Phase 4 的 art-director 输出）

**推荐（非阻塞）：**
- [ ] `prototypes/` 中存在概念原型，其 REPORT.md 显示 PROCEED 结论
      （`/prototype [core-mechanic]`）——跳过它意味着 GDD 可能是为一个
      从未被玩过的点子而写。如果概念已通过其他方式得到验证，则可接受。

**质量检查：**
- [ ] 游戏概念已经过评审（`/design-review` 结论不是 MAJOR REVISION NEEDED）
- [ ] 核心循环已被描述并理解
- [ ] 已明确目标受众
- [ ] 视觉识别锚点包含一条一句话视觉规则和至少 2 条支撑性视觉原则

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的
削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的
机制。

- **`full`** —— game-concept.md + 游戏支柱 + 视觉识别锚点全部必需
- **`standard`** —— 游戏支柱 + 视觉识别锚点 → 推荐；`game-concept.md` 仍为必需
- **`minimal`** —— 闸门目标是 **`design/game-brief.md`**（而非 `game-concept.md`）；GDD / 游戏支柱 / 视觉识别锚点检查**取消**（有内容的简报 = PASS）。在此层级 `/brainstorm` 写入 `design/game-brief.md`（选项 A）；`game-concept.md` 仍是 `standard`/`full` 的概念文档。
