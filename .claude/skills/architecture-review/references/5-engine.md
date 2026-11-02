# /architecture-review — Phase 5 与 5b：引擎交叉检查与设计修订标记

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 5: 引擎兼容性交叉检查

**本文件包含：**

- 版本一致性
- 截止日期后 API 一致性
- 已弃用 API 检查
- 缺失的引擎兼容性章节
- 引擎专家咨询

跨所有 ADR 检查引擎一致性：

### 版本一致性
- 所有提及引擎版本的 ADR 是否都同意使用同一版本？
- 若任何 ADR 是为较旧的引擎版本编写的，将其标记为可能过时

### 截止日期后 API 一致性
- 收集所有 ADR 中的 "Post-Cutoff APIs Used" 字段
- 对每一项，对照相关模块参考资料进行验证
- 检查是否没有两个 ADR 对同一截止日期后 API 做出相互矛盾的假设

### 已弃用 API 检查
- 在所有 ADR 中 grep `deprecated-apis.md` 列出的 API 名称
- 标记任何引用已弃用 API 的 ADR

### 缺失的引擎兼容性章节
- 列出完全缺失 Engine Compatibility 章节的所有 ADR
- 这些是盲区 —— 它们的引擎假设未知

输出格式：
```
### Engine Audit Results
Engine: [name + version]
ADRs with Engine Compatibility section: X / Y total

Deprecated API References:
  - ADR-0002: uses [deprecated API] — deprecated since [version]

Stale Version References:
  - ADR-0001: written for [older version] — current project version is [version]

Post-Cutoff API Conflicts:
  - ADR-0004 and ADR-0007 both use [API] with incompatible assumptions
```

---

### 引擎专家咨询

完成上述引擎审计后，通过 `Agent` 派生**主引擎专家**以获取领域专家的第二意见：
- 解析主专家：`<engine>-specialist`，由 `project.yaml` 中的 `engine.name` 推导（Godot→`godot-specialist`，Unity→`unity-specialist`，Unreal→`unreal-specialist`）；若 `engine.name` 缺失或为空，读取 `.claude/docs/technical-preferences.md` 中 `## Engine Specialists` 章节的 Primary 行
- 若未配置引擎（两个来源都得不到引擎），跳过本次咨询，**在本次运行的输出中记录 ``Engine validation: NOT ASSESSED — no engine configured (`engine.name` unset in `project.yaml`)``。** 静默跳过的检查与通过的检查无法区分；读者无法得知从未寻求过引擎指导。
- 以 `subagent_type: [primary specialist]` 派生，并提供：所有包含引擎特定决策或 `Post-Cutoff APIs Used` 字段的 ADR、引擎参考资料，以及 Phase 5 审计发现。请他们：
  1. 确认或质疑每项审计发现 —— 专家可能了解参考资料未捕获的引擎细节
  2. 识别 ADR 中审计可能遗漏的引擎特定反模式（例如使用错误的 Godot 节点类型、Unity 组件耦合、Unreal 子系统误用）
  3. 标记那些对引擎行为的假设与实际固定版本不符的 ADR

将额外发现归入 Phase 5 输出中的 `### Engine Specialist Findings` 下。这些发现会进入
最终结论 —— 专家识别的问题与审计识别的问题权重相同。

---

## Phase 5b: 设计修订标记（架构 → GDD 反馈）

对 Phase 5 中的每个**高风险引擎发现**，检查是否有任何 GDD 做出的假设与已验证的引擎
实际情况相矛盾。

需要检查的具体情形：

1. **截止日期后 API 行为与训练数据假设不同**：如果某个 ADR 记录了与 LLM 默认假设
   不同的已验证 API 行为，检查所有引用相关系统的 GDD。寻找围绕旧（假定）行为编写的
   设计规则。

2. **ADR 中的已知引擎限制**：如果某个 ADR 记录了已知引擎限制
   （例如 "Jolt ignores HingeJoint3D damp"、"D3D12 is now the default backend"），
   检查围绕受影响功能设计机制的 GDD。

3. **已弃用 API 冲突**：如果 Phase 5 标出了 ADR 中使用的已弃用 API，检查是否有任何
   GDD 包含假定该已弃用 API 行为的机制。

对发现的每个冲突，将其记录在 GDD Revision Flags 表中：

```
### GDD Revision Flags (Architecture → Design Feedback)
These GDD assumptions conflict with verified engine behaviour or accepted ADRs.
The GDD should be revised before its system enters implementation.

| GDD | Assumption | Reality (from ADR/engine-reference) | Action |
|-----|-----------|--------------------------------------|--------|
| combat.md | "Use HingeJoint3D damp for weapon recoil" | Jolt ignores damp — ADR-0003 | Revise GDD |
```

若未发现修订标记，写："没有 GDD 修订标记 —— 所有 GDD 假设
都与已验证的引擎行为一致。"

在询问之前，内联显示拟议变更 —— 并排展示每个被标记 GDD 当前的 systems-index 行与
拟议更新后的行，让用户能确切看到将发生什么变化。

然后使用 `AskUserQuestion`：
- "我发现 [N] 个 GDD 修订标记。我可以更新系统索引吗？"
  - [A] Yes — apply all [N] updates to the systems index now
  - [B] Show me the full diff first, then ask again
  - [C] No — leave the systems index unchanged for now

若选 [A]：应用更新。Status 字段必须精确为 `Needs Revision` —— 不带括号说明
（其他技能匹配该精确字符串，括号说明会破坏匹配）。
若选 [B]：显示完整的拟议 systems-index 章节，然后用 `AskUserQuestion` 重新询问。

---
