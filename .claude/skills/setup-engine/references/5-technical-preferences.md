# /setup-engine — 第 5 节：填充技术偏好

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 5. 填充技术偏好

**本文件内容：**

- 引擎与语言章节
- 命名约定（引擎默认值）
- 输入与平台章节
- 其余章节
- 引擎专家路由
- 协作步骤

更新 CLAUDE.md 之后，创建或更新 `.claude/docs/technical-preferences.md`，
填入符合引擎的默认值。先读取现有模板，然后填写：

### 引擎与语言章节
- 根据第 4 步中做出的引擎选择填写

### 命名约定（引擎默认值）

**对于 Godot** — 见 `references/godot-language-config.md`（**A2**）中的 GDScript、C# 和两者变体。

**对于 Unity（C#）：**
- 类：PascalCase（例如 `PlayerController`）
- 公共字段/属性：PascalCase（例如 `MoveSpeed`）
- 私有字段：_camelCase（例如 `_moveSpeed`）
- 方法：PascalCase（例如 `TakeDamage()`）
- 文件：PascalCase，与类名一致（例如 `PlayerController.cs`）
- 常量：PascalCase 或 UPPER_SNAKE_CASE

**对于 Unreal（C++）：**
- 类：带前缀的 PascalCase（Actor 用 `A`，UObject 用 `U`，struct 用 `F`）
- 变量：PascalCase（例如 `MoveSpeed`）
- 函数：PascalCase（例如 `TakeDamage()`）
- 布尔值：`b` 前缀（例如 `bIsAlive`）
- 文件：与类名一致但不含前缀（例如 `PlayerController.h`）

### 输入与平台章节

使用第 2 节收集到的答案（或从游戏概念中提取的内容）填充
`## Input & Platform`。使用以下映射推导各项值：

| 平台目标 | 手柄支持 | 触摸支持 |
|-----------------|-----------------|---------------|
| 仅 PC | 部分（推荐） | 无 |
| 主机 | 完整 | 无 |
| 移动端 | 无 | 完整 |
| PC + 主机 | 完整 | 无 |
| PC + 移动端 | 部分 | 完整 |
| Web | 部分 | 部分 |

对于**主要输入**（Primary Input），使用该游戏类型的主导输入方式：
- 面向主机的动作/RPG/平台跳跃游戏 → 手柄
- 策略/点击式/RTS → 键盘/鼠标
- 移动端游戏 → 触摸
- 跨平台 → 询问用户

> **类型可能尚不存在 — 在据此推导之前先检查。** 在 `minimal` 层级，
> 设计产出物是 `design/game-brief.md`，而它是在本技能运行*之后*才编写的
> （第 2 节已明确说明）。此时没有可映射的类型。在任何层级，
> 如果概念尚不存在就运行 `/setup-engine`，情况同样如此。
>
> 当类型不可用时，**要询问** — 不要从平台推断，也不要
> 让该字段悄无声息地留空：
> - 提示："[2D/3D] [platform] 游戏的主要输入方式是什么？类型尚未确定
>   — 简报接下来才会编写 — 因此无法推导。"
> - 选项：该平台可能适用的输入方式，加上
>   `Leave as [TO BE CONFIGURED]` — 在这里这是合理的答案，待简报存在后
>   可通过 `/settings` 重新设置。
>
> 手柄支持和触摸支持仍来自上面的平台表；
> 只有主要输入取决于游戏类型。

展示推导出的值，并在写入前请用户确认或调整。

填写示例：
```markdown
## Input & Platform
- **Target Platforms**: PC, Console
- **Input Methods**: Keyboard/Mouse, Gamepad
- **Primary Input**: Gamepad
- **Gamepad Support**: Full
- **Touch Support**: None
- **Platform Notes**: All UI must support d-pad navigation. No hover-only interactions.
```

### 其余章节
- **Performance Budgets**（性能预算）：使用 `AskUserQuestion`：
  - 提示："现在设置默认性能预算，还是留到以后？"
  - 选项：`[A] Set defaults now (60fps, 16.6ms frame budget, engine-appropriate draw call limit)` / `[B] Leave as [TO BE CONFIGURED] — I'll set these when I know my target hardware`
  - 如果选 [A]：填入建议的默认值。如果选 [B]：保留占位符。
- **Testing**（测试）：建议使用适合引擎的框架 — Godot 用 **gdUnit4**，
  Unity 用 NUnit，Unreal 用 Automation Spec — 并在添加前询问。
  > **必须与第 5.5.1 节中的 `commands.test` 一致，后者写入 gdUnit4 自己的
  > 运行器（`res://addons/gdUnit4/bin/GdUnitCmdTool.gd`），也必须与
  > `.claude/docs/coding-standards.md` 一致，其中引用了同一个运行器。** 如果在这里写 GUT，
  > 就会导致该技能在同一次运行中推荐一个框架，却配置了另一个。
- **Forbidden Patterns**（禁止模式）：保留占位符 — 不要预先填充。
- **Allowed Libraries**（允许的库）：保留占位符 — 不要预先填充项目当前不需要的依赖。只有当某个库正在被实际集成时才添加到此处，而不是推测性地添加。

> **防护栏**：绝不向 Allowed Libraries 添加推测性的依赖。例如，除非本次会话正在实际开始集成 Steam，否则不要添加 GodotSteam。发布后集成应在那项工作开始时才加入 Allowed Libraries，而不是在引擎设置期间。

### 引擎专家路由

同时用所选引擎的正确路由填充 `technical-preferences.md` 中的 `## Engine Specialists` 章节：

**对于 Godot** — 见 `references/godot-language-config.md`（**A3**）中与所选语言匹配的路由表。

**对于 Unity：**
```markdown
## Engine Specialists
- **Primary**: unity-specialist
- **Language/Code Specialist**: unity-specialist (C# review — primary covers it)
- **Shader Specialist**: unity-shader-specialist (Shader Graph, HLSL, URP/HDRP materials)
- **UI Specialist**: unity-ui-specialist (UI Toolkit UXML/USS, UGUI Canvas, runtime UI)
- **Additional Specialists**: unity-dots-specialist (ECS, Jobs system, Burst compiler), unity-addressables-specialist (asset loading, memory management, content catalogs)
- **Routing Notes**: Invoke primary for architecture and general C# code review. Invoke DOTS specialist for any ECS/Jobs/Burst code. Invoke shader specialist for rendering and visual effects. Invoke UI specialist for all interface implementation. Invoke Addressables specialist for asset management systems.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.cs files) | unity-specialist |
| Shader / material files (.shader, .shadergraph, .mat) | unity-shader-specialist |
| UI / screen files (.uxml, .uss, Canvas prefabs) | unity-ui-specialist |
| Scene / prefab / level files (.unity, .prefab) | unity-specialist |
| Native extension / plugin files (.dll, native plugins) | unity-specialist |
| General architecture review | unity-specialist |
```

**对于 Unreal：**
```markdown
## Engine Specialists
- **Primary**: unreal-specialist
- **Language/Code Specialist**: ue-blueprint-specialist (Blueprint graphs) or unreal-specialist (C++)
- **Shader Specialist**: unreal-specialist (no dedicated shader specialist — primary covers materials)
- **UI Specialist**: ue-umg-specialist (UMG widgets, CommonUI, input routing, widget styling)
- **Additional Specialists**: ue-gas-specialist (Gameplay Ability System, attributes, gameplay effects), ue-replication-specialist (property replication, RPCs, client prediction, netcode)
- **Routing Notes**: Invoke primary for C++ architecture and broad engine decisions. Invoke Blueprint specialist for Blueprint graph architecture and BP/C++ boundary design. Invoke GAS specialist for all ability and attribute code. Invoke replication specialist for any multiplayer or networked systems. Invoke UMG specialist for all UI implementation.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.cpp, .h files) | unreal-specialist |
| Shader / material files (.usf, .ush, Material assets) | unreal-specialist |
| UI / screen files (.umg, UMG Widget Blueprints) | ue-umg-specialist |
| Scene / prefab / level files (.umap, .uasset) | unreal-specialist |
| Native extension / plugin files (Plugin .uplugin, modules) | unreal-specialist |
| Blueprint graphs (.uasset BP classes) | ue-blueprint-specialist |
| General architecture review | unreal-specialist |
```

### 协作步骤
向用户展示已填写的偏好。对于 Godot，说明所选语言，并指出完整命名约定和路由表的所在位置：
> "以下是 [engine]（Godot 时为 [language]）的默认技术偏好。命名约定和专家路由位于本技能的 references 目录中 — 我将应用 [GDScript/C#/Both] 变体。想要自定义其中任何一项，还是可以保存到 `.claude/docs/technical-preferences.md`？"

对于所有其他引擎，直接展示默认值，不引用附录。

写入文件前等待批准。

---
