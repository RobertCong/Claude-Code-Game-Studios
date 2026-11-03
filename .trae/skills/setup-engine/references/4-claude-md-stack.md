# /setup-engine — 第 4 节：更新 CLAUDE.md 技术栈

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 4. 更新 CLAUDE.md 技术栈

### 语言选择（仅 Godot）

如果选择了 Godot，在展示拟议的技术栈**之前**询问用户使用哪种语言：

> "Godot 支持两种主要语言：
>
>   **A) GDScript** — 类似 Python、Godot 原生、迭代最快。最适合初学者、单人开发者和来自 Python 或 Lua 的团队。
>   **B) C#** — .NET 8+，Unity 开发者很熟悉，IDE 工具更强（Rider / Visual Studio），在重逻辑上有轻微性能优势。
>   **C) 两者** — GDScript 用于玩法/UI 脚本，C# 用于性能关键系统。高级配置 — 需要在 Godot 之外安装 .NET SDK。
>
> 本项目主要使用哪一种？"

记录该选择。它决定 CLAUDE.md 模板、命名约定、专家路由，以及整个项目中为代码文件生成哪个 agent。

### 主要语言（Unreal）

如果选择了 Unreal，通过 `AskUserQuestion` 询问："大部分玩法逻辑会写在
C++ 还是 Blueprint 中？" — `[A] C++ (Blueprints for tuning and prototyping)` /
`[B] Blueprint-primary (C++ only where needed)`。如果用户没有偏好，默认为 C++。该回答设置 `engine.language`（`"C++"` 或 `"Blueprint"`）。

---

读取 `CLAUDE.md` 并向用户展示拟议的技术栈变更。
询问："我可以把这些引擎设置写入 `CLAUDE.md` 吗？"

在做任何编辑之前等待确认。

更新技术栈章节，用实际值替换 `[CHOOSE]` 占位符：

**对于 Godot** — 使用与上面所选语言匹配的模板。见 `references/godot-language-config.md`（**A1**）中所有三种变体（GDScript、C#、Both）。

**对于 Unity：**
```markdown
- **Engine**: Unity [version]
- **Language**: C#
- **Build System**: Unity Build Pipeline
- **Asset Pipeline**: Unity Asset Import Pipeline + Addressables
```

**对于 Unreal：**
```markdown
- **Engine**: Unreal Engine [version]
- **Language**: [C++ (primary), Blueprint (gameplay prototyping) | Blueprint (primary), C++ where needed]
- **Build System**: Unreal Build Tool (UBT)
- **Asset Pipeline**: Unreal Content Pipeline
```
Language 行遵循上面的主要语言回答：`[A]`（`engine.language: "C++"`）使用第一种形式，
`[B]`（`"Blueprint"`）使用第二种。

### 引擎引用导入

在同一次 CLAUDE.md 写入中，把 **Engine Version Reference** 导入设置为
所选引擎。找到标记为 `ENGINE-REFERENCE-IMPORT` 的行（其注释下方的
`@docs/engine-reference/<engine>/VERSION.md` 行），Edit 它
使其指向已配置的引擎：
- Godot → `@docs/engine-reference/godot/VERSION.md`
- Unity → `@docs/engine-reference/unity/VERSION.md`
- Unreal → `@docs/engine-reference/unreal/VERSION.md`

这可以避免 Unity 或 Unreal 项目在每个会话中都加载 Godot 参考资料。它是幂等的 — 为另一个
引擎重新运行 `/setup-engine` 会重写同一行。（目标 `docs/engine-reference/<engine>/`
目录会在第 7 节"填充引擎参考资料"中创建，如果它尚不存在的话。）

---
