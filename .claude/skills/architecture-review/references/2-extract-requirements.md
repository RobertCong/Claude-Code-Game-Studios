# /architecture-review — Phase 2: 提取技术需求

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 2: 从每个 GDD 提取技术需求

### 预加载 TR 注册表

在提取任何需求之前，读取 `docs/architecture/tr-registry.yaml`（如果存在）。按 `id`
与规范化后的 `requirement` 文本（小写、去除首尾空白）为现有条目建立索引。这可防止
跨多次评审运行时 ID 重新编号。

然后读取 `docs/architecture/architecture.md` 中的技术需求基线（Technical
Requirements Baseline）（如果存在）。`/create-architecture` 会为注册表中未持有的每个
需求编号为 `(provisional)`，从注册表的下一个空闲 ID 开始，而基于该基线编写的 ADR
可能已经引用了这些 ID。

对你提取的每个需求，匹配规则如下：
1. **与同一系统的现有注册表条目精确/近似匹配** → 原样复用该条目的 TR-ID。仅当 GDD
   的措辞发生变化（意图相同、表述更清晰）时才更新注册表中的 `requirement` 文本 ——
   并添加 `revised: [date]` 字段。
2. **匹配到临时基线行**（同一系统、同一意图）→ 当注册表中没有以该 ID 存在的条目
   （无论启用还是已退役）时，保留该 ID：将其注册才是使其永久化的方式。当该 ID 已被
   占用时，分配下一个可用 ID，并在报告中列出重命名
   （`TR-[system]-004 (provisional) → TR-[system]-006`），以便引用它的 ADR 与用户
   故事可以更新。
3. **无匹配** → 分配新 ID：该系统的下一个可用 `TR-[system]-NNN`，从现有最高序号 + 1
   开始，跳过任何被临时基线行占用的 ID。
4. **模糊**（部分匹配、意图不明确）→ 询问用户：
   > "'[new requirement text]' 指的是与
   > `TR-[system]-NNN: [existing text]` 相同的需求，还是一个全新的需求？"
   用户回答："Same requirement"（复用 ID）或"New requirement"（新 ID）。

对于注册表中 `status: deprecated` 的任何需求 —— 跳过它。它是有意从 GDD 中移除的。

对每个 GDD，读取它并提取所有**技术需求** —— 即系统要工作、架构必须提供的内容。技术
需求是任何暗含特定架构决策的陈述。

要提取的类别：

| 类别 | 示例 |
|----------|---------|
| **数据结构** | "每个实体都有生命值、最大生命值、状态效果" → 需要一个组件/数据模式 |
| **性能约束** | "碰撞检测必须支持 200 个实体、60fps 运行" → 物理预算 ADR |
| **引擎能力** | "角色动画的反向运动学" → IK 系统 ADR |
| **跨系统通信** | "伤害系统同时通知 UI 与音频" → 事件/信号架构 ADR |
| **状态持久化** | "玩家进度在会话之间持久保存" → 存档系统 ADR |
| **线程/时序** | "AI 决策在主线程之外进行" → 并发 ADR |
| **平台需求** | "支持键盘、手柄、触摸" → 输入系统 ADR |

对每个 GDD，产出一份结构化列表：

```
GDD: [filename]
System: [system name]
Technical Requirements:
  TR-[GDD]-001: [requirement text] → Domain: [Physics/Rendering/etc]
  TR-[GDD]-002: [requirement text] → Domain: [...]
```

这就构成为**需求基线** —— 架构必须覆盖的完整集合。

---
