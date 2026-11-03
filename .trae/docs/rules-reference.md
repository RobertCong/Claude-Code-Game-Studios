# 路径专属规则（Path-Specific Rules）

`.trae/rules/` 中的规则带有 `globs:` frontmatter。Trae 在读取匹配其中某个 glob 的文件时
加载路径作用域规则。

由此产生三个后果，没有一个是可选阅读的：

1. **是读取，不是编辑。** 作用域为某个玩法文件夹的规则，只有在打开该处文件时才会
   到达模型。一个在该目录中写入全新文件却从未打开现有文件的代理永远看不到它。本
   框架中的多数工作是在创建文件而非读取文件，所以这是常见情况，而不是边缘情况。
2. **是上下文，不是强制。** 已加载的规则是模型会权衡的指导，与 `AGENTS.md` 相同。
   任何必须不论模型如何决定都要成立的内容，都应放入钩子 — `.trae/hooks/` 已经
   以这种方式强制 JSON 有效性和提交格式。
3. **使用 `alwaysApply: true`（或省略 globs）的规则会在每个会话中加载**，优先级与
   `AGENTS.md` 相同。这是让规则始终生效的杠杆；它会在每个会话中消耗上下文，因此是
   有意的取舍，而不是默认做法。

当某条规则与某份代理定义已经携带的指导重复时，两者必须一致。相互矛盾的指令会被
任意地取舍，因此规则与代理对同一标准表述不同版本，比只有其中任何一个都更糟。

Trae 没有 `InstructionsLoaded` 钩子；`.trae/hooks/log-instructions.sh` 未注册。
要确认某条规则是否生效，直接检查它的 `globs:` 是否匹配目标文件。

**Glob 匹配依赖文件搜索。** macOS 默认文件系统不区分大小写，因此 `Assets/**/UI/**`
也可能匹配 `assets/ui/`。这就是下文中 Unity 与 Unreal 的代码 glob 要指明文件类型
的原因。实际规则文件在迁移时已把 `{A,B}` 展开为多个 glob，因为 Trae 按逗号分隔
`globs`，不会解析大括号。

路径按 Godot · Unity · Unreal 顺序列出。文件夹名只展示一种大小写形式；每条规则
自身的 glob 会列出所有大小写变体。

| 规则文件 | 路径模式 | 强制内容 |
| ---- | ---- | ---- |
| `gameplay-code.md` | `src/gameplay/**` · `Assets/**/Gameplay/**/*.cs` · `Source/**/Gameplay/**/*.{h,cpp}` | 数据驱动取值、delta time、不引用 UI |
| `engine-code.md` | `src/core/**` · `Assets/**/Core/**/*.cs` · `Source/**/Core/**/*.{h,cpp}` | 热路径零分配、线程安全、API 稳定性 |
| `ai-code.md` | `src/ai/**` · `Assets/**/AI/**/*.cs` · `Source/**/AI/**/*.{h,cpp}` | 性能预算、可调试性、数据驱动参数 |
| `network-code.md` | `src/networking/**` · `Assets/**/Network(ing)/**/*.cs` · `Source/**/Network(ing)/**/*.{h,cpp}` | 服务器权威、版本化消息、安全 |
| `ui-code.md` | `src/ui/**` · `Assets/**/UI/**/*.cs` · `Source/**/UI/**/*.{h,cpp}` | 不持有游戏状态、可本地化、无障碍 |
| `design-docs.md` | `design/gdd/**` | 按 `modes.workflow` 规定的必需章节（`full` 为 8 个，`standard` 为 5 个）、公式格式、边界情况 |
| `narrative.md` | `design/narrative/**` | 设定一致性、角色口吻、正典层级 |
| `data-files.md` | `assets/data/**/*.json` · `Assets/**/Data/**/*.json` · `Content/**/Data/**/*.json` | JSON 有效性、命名约定、schema 规则 |
| `test-standards.md` | `tests/**` · `Assets/Tests/**/*.cs` · `Source/**/Tests/**/*.{h,cpp}` | 测试命名、覆盖率要求、fixture 模式 |
| `prototype-code.md` | `prototypes/**` | 放宽的标准、必需 README、记录假设 |
| `shader-code.md` | `assets/shaders/**`, `**/*.gdshader` · `Assets/**/*.{shader,hlsl,cginc,compute,shadergraph}` · `Shaders/**`, `**/*.{usf,ush}` | 命名约定、性能目标、跨平台规则 |
| `scene-files.md` | `**/*.tscn`, `**/*.tres` · `**/*.unity`, `**/*.prefab`, `Assets/**/*.asset` · — | 对编辑器写入的场景与资源文件的手工编辑限制；Unreal 的 `.uasset`/`.umap` 是二进制文件，项目规则禁止编辑它们 |
| `agent-memory.md` | `.trae/agent-memory/**` | 代理唯一可未经请求写入的地方 — 以及为何暂时的缺失绝不能被记录为持久事实 |
| `skill-authoring.md` | `.trae/skills/**`, `.trae/agents/**` | 检查必须能够报告自己未运行 — 关于结论、默认值、跳过、来源和派生覆盖率的五项义务 |

每条面向引擎的规则都会在三个引擎上加载：

- **代码规则**（`gameplay`、`engine`、`ai`、`network`、`ui`）匹配
  `Assets/**/<System>/**/*.cs` 和 `Source/**/<System>/**/*.{h,cpp}`（其余规则对应
  `Core`、`AI`、`Networking`/`Network`、`UI`）。
- **`data-files.md`** 匹配 `Assets/**/Data/**/*.json` 和
  `Content/**/Data/**/*.json` — 仅限 JSON，因此 `Data/` 文件夹中的 C# 或 C++ 不会
  套用其文件命名规则。
- **`shader-code.md`** 按类型匹配着色器文件：`.gdshader`、`.shader`、
  `.hlsl`、`.cginc`、`.compute`、`.shadergraph`、`.usf`、`.ush`，以及 `Shaders/**`。
- **`test-standards.md`** 匹配 `Assets/Tests/**/*.cs` 和
  `Source/**/Tests/**/*.{h,cpp}`。
- **`scene-files.md`** 是例外：Godot 与 Unity 的场景和资源文件是文本，因此有对应
  规则；Unreal 的是二进制，所以用 deny 规则阻止编辑，而不是用规则加以引导。

> **`skill-authoring.md` 是异类，而且是有意为之。** 这里的其他规则都作用于*游戏*
> 目录；它作用于**框架自身**的编写路径。它之所以存在，是因为同一种失败形态在不相关的
> 子系统中反复出现 — 一个无法运行的步骤产出的结果，与运行了却什么也没找到的步骤
> 无法区分。同一个错误出现在九个地方，说明缺失的是一条设计规则，而不是九个错误。
