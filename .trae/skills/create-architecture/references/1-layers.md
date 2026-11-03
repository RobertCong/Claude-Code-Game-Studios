# /create-architecture — Phase 1: 系统层级映射

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 1: 系统层级映射

将 `systems-index.md` 中的每个系统映射到一个架构层。标准的
游戏架构层是：

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │  ← UI, HUD, menus, VFX, audio
├─────────────────────────────────────────────┤
│  FEATURE LAYER                              │  ← gameplay systems, AI, quests
├─────────────────────────────────────────────┤
│  CORE LAYER                                 │  ← physics, input, combat, movement
├─────────────────────────────────────────────┤
│  FOUNDATION LAYER                           │  ← engine integration, save/load,
│                                             │    scene management, event bus
├─────────────────────────────────────────────┤
│  PLATFORM LAYER                             │  ← OS, hardware, engine API surface
└─────────────────────────────────────────────┘
```

Platform 层是游戏所运行的引擎与操作系统，不是项目编写的代码。
没有 GDD 系统会放入其中，因此它没有史诗、用户故事或 control-manifest
规则：包装平台或引擎 API 的系统属于 Foundation 层。

对每个 GDD 系统，询问：
- 它属于哪一层？
- 它的模块边界是什么？
- 它独家拥有什么？（数据、状态、行为）

呈现提议的层级分配，并在进入下一章节前请求批准。将批准的层级映射记录到
`production/session-state/active.md`；它会在 Phase 7 写入文档。

**引擎感知检查**：对分配到 Core 和 Foundation 层的每个系统，若其触及
HIGH 或 MEDIUM 风险引擎领域则标出。内联展示相关
引擎参考摘录。

---
