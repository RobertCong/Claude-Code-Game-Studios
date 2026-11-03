# 目录结构

```text
/
├── CLAUDE.md                    # Master configuration
├── project.yaml                 # Machine-readable project config — engine, modes, stage (source of truth)
├── .claude/                     # Agent definitions, skills, hooks, rules, docs
├── <code root>/                 # Game source code — THE PATH IS ENGINE-SPECIFIC, see below
├── assets/                      # Game assets (art, audio, vfx, shaders, data)
├── design/                      # Game design documents (gdd, narrative, levels, balance)
├── docs/                        # Technical documentation (architecture, api, postmortems)
│   └── engine-reference/        # Curated engine API snapshots (version-pinned)
├── tests/                       # Game test suites (unit, integration, performance, playtest)
├── tools/                       # Build and pipeline tools (ci, build, asset-pipeline)
├── prototypes/                  # Throwaway prototypes (outside the code root)
├── production/                  # Production management (sprints, milestones, releases)
│   ├── session-state/           # Ephemeral session state (active.md — gitignored)
│   └── session-logs/            # Session audit trail (gitignored)
└── studio-tests/                # QA for the skills/agents themselves — /skill-test, /skill-improve
```

## 代码根目录因引擎而异

**三个受支持引擎中有两个无法构建代码位于 `src/` 的项目。** 这不是风格偏好 —— 而是引擎自身工具链的硬性约束：

| `engine.name` | 代码根目录 | 为什么不能是 `src/` |
|---|---|---|
| **Godot** | `src/` | 无约束 —— Godot 会从项目根目录下的任意位置通过 `res://` 加载。 |
| **Unity** | `Assets/` | Unity **只**编译 `Assets/` 和 `Packages/`。它们之外的代码对编译器不可见。 |
| **Unreal** | `Source/<Module>/` | UnrealBuildTool 在 `Source/` 下发现模块；内容位于 `Content/`。位于其他位置的模块不会被构建。 |

**在写入任何源文件之前，先从 `engine.name` 解析出代码根目录。** 仅以 `src/…` 形式显示的路径是 Godot 示例：应把它读作*「代码根目录」*，并代入上表中的对应行。`src/` 是表中的 Godot 行，不是通用路径。

**测试遵循同样的规则** —— 同样的编译器决定它们能看到什么：

| `engine.name` | 测试根目录 | 其他位置 |
|---|---|---|
| **Godot** | `tests/unit/`、`tests/integration/` | — |
| **Unity** | `Assets/Tests/EditMode/`、`Assets/Tests/PlayMode/` | 不会被编译："0 tests, Passed" |
| **Unreal** | `Source/<Module>/Private/Tests/` | 不会被构建："No automation tests matched" |

在任何地方都把 `tests/unit/[system]/`（或 `integration/`）理解为测试根目录加上 `[System]/`。
