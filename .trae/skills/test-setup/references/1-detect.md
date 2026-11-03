# /test-setup — Phase 1: 检测引擎与现有状态

> `/test-setup` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 1: 检测引擎与现有状态

1. **读取引擎配置**：
   - 从 `project.yaml` 读取 `engine.name`；如果该键缺失或为空
     （包括 `project.yaml` 没有 `engine:` 块的情况），回退到
     `.claude/docs/technical-preferences.md` 中的 `Engine:` 值。
   - 如果两个来源都未给出已配置的引擎（project.yaml 的 `engine.name`
     缺失/为空，且 technical-preferences.md 显示 `[TO BE CONFIGURED]` 或
     缺失），停止：
     “引擎未配置。请先运行 `/setup-engine`，然后重新运行 `/test-setup`。”

2. **检查现有测试基础设施**：
   - Glob `tests/` — 目录是否存在？
   - Glob `tests/unit/` 和 `tests/integration/` — 子目录是否存在？
   - Glob `.github/workflows/` — 是否存在 CI 工作流文件？
   - Glob `addons/gdUnit4/bin/GdUnitCmdTool.gd`（Godot — 注意大写 U）或
     `Assets/Tests/EditMode/`（Unity）或 `Source/*/Private/Tests/`（Unreal），以查找
     引擎专属产出物。这些是
     `.claude/docs/directory-structure.md` 中的**测试根目录**；放在其他任何地方的测试在 Unity 或 Unreal 上
     永远不会被编译。

3. **报告发现**：
   - “引擎：[engine]。测试目录：[found / not found]。CI 工作流：[found / not found]。”
   - 如果所有内容都已存在且未传入 `force` 参数：
     “测试基础设施似乎已就位。使用 `/test-setup force`
     重新生成。继续执行不会覆盖现有测试文件。”

如果传入了 `force` 参数，跳过“已存在”的提前退出并
继续 — 但仍不要覆盖给定路径上已存在的文件。
只创建缺失的文件。

---
