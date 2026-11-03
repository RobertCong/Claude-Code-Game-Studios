> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。


# 质量闸门：Systems Design → Technical Setup


**必需产出物：**
- [ ] 系统索引存在于 `design/gdd/systems-index.md`，且至少枚举了 MVP 系统
- [ ] 所有 MVP 层级的 GDD 都存在于 `design/gdd/`，并各自通过 `/design-review`
- [ ] 跨 GDD 评审报告存在于 `design/gdd/`（来自 `/review-all-gdds`）

**质量检查：**
- [ ] 所有 MVP GDD 都通过单项设计评审（8 个必需章节，且没有 MAJOR REVISION NEEDED 结论）
- [ ] `/review-all-gdds` 的结论不是 FAIL（跨 GDD 一致性检查和设计理论检查均通过）。NOT ASSESSED 结论不满足此项：那次评审无法比较这些 GDD，因此此项在该闸门中为 NOT ASSESSED。聚焦运行报告也不算（其 `Focus:` 行只点名一次检查）：另一次检查从未运行，因此该项保持未决，直到一次评审同时运行两次检查
- [ ] `/review-all-gdds` 标记的所有跨 GDD 一致性问题都已解决或被明确接受
- [ ] 系统依赖已在系统索引中映射，并保持双向一致
- [ ] 已定义 MVP 优先级层级
- [ ] 没有标记出过时的 GDD 引用（较旧的 GDD 已更新，以反映后续 GDD 中做出的决策）

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的机制。

- **`full`** —— 系统索引 + 所有 MVP GDD 达到 8 个章节 + 跨 GDD 评审报告全部必需
- **`standard`** —— MVP GDD 按 **5 个标准章节**（+ 条件性 Formulas）验证；跨 GDD 评审报告 → 推荐
- **`minimal`** —— **闸门不适用** —— 简报与代码之间没有闸门；自动 PASS 并附注（见下）

> **`minimal` 的“不适用”闸门。** Systems Design → Technical Setup 闸门在 `minimal` 下没有意义（按设计不存在 GDD）。返回 PASS 结论并附注：*“minimal 工作流下没有设计闸门——minimal 跳过 Systems Design 阶段；从简报直接推进到代码。”* 第 6 节的阶段写入仍需用户确认。不要将缺失的 GDD 标记为阻塞项。这是第 2b 节“没有必需产出物剩余的闸门不得 PASS”规则的具名例外；总监小组不会为它运行。
