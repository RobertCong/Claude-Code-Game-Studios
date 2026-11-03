# /test-setup — Phase 3: 创建目录结构

> `/test-setup` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 3: 创建目录结构

**本文件内容：**

- `tests/README.md`
- `production/qa/evidence/.gitkeep`
- 引擎专属文件

批准后，创建以下文件：

### `tests/README.md`

````markdown
# Test Infrastructure

**Engine**: [engine name + version]
**Test Framework**: [GdUnit4 | Unity Test Framework | UE Automation]
**CI**: `.github/workflows/tests.yml`
**Setup date**: [date]

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system and save/load tests
  smoke/          # Critical path test list for /smoke-check gate
```

[Unity/Unreal — replace the unit/integration lines: unit and integration tests
live under the engine's test root, `Assets/Tests/EditMode|PlayMode/[System]/`
or `Source/<Module>/Private/Tests/[System]/`; `tests/` keeps this README and
`smoke/`. Every `tests/unit/` path below means that test root.]

```
production/qa/
  evidence/       # Screenshot logs and manual test sign-off records
```

> **Manual evidence lives under `production/qa/evidence/`, not `tests/`** — that
> is where every consumer reads it.

## Running Tests

[Engine-specific command — see below]

## Test Naming

Names follow the engine's language (`.trae/rules/test-standards.md`):
- **Godot**: file `[system]_[feature]_test.gd`, function `test_[scenario]_[expected]`
  — `combat_damage_test.gd` → `test_base_attack_returns_expected_damage()`
- **Unity**: class `[System]Tests` in `[System]Tests.cs`, method `[Scenario]_[Expected]`
  — `CombatTests.cs` → `BaseAttack_ReturnsExpectedDamage()`
- **Unreal**: class `F[System][Scenario]Test`, test name `<Project>.[System].[Scenario]`
  — `FCombatBaseAttackTest` → `<Project>.Combat.BaseAttack`
  [`<Project>` is the root the filter in `commands.test` uses — write it out:
  the project name, or the distinct root `/setup-engine` chose]

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `production/qa/evidence/` |
| UI | Retained screenshot of each screen touched | `production/qa/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.
````

README 和本技能的完成摘要指明相同的证据路径 —
`production/qa/evidence/` 正是 `/smoke-check`、`/test-evidence-review`、
`/qa-plan` 以及 `.trae/docs/coding-standards.md` 中证据表读取的位置，
因此 `tests/evidence/` 会是一个无人读取的目录。

### `production/qa/evidence/.gitkeep`

以空内容创建它。Git 不保留空目录，而这里正是
`/story-done`、`/smoke-check` 和 `/test-evidence-review` 查找截图和
签署记录的地方 — 完成摘要会列出它，因此它必须存在。

### 引擎专属文件

#### Godot 4 (`Engine: Godot`)

**不要编写运行器脚本。** gdUnit4 自带命令行运行器，
`res://addons/gdUnit4/bin/GdUnitCmdTool.gd`。CI、`/smoke-check`
和 `commands.test` 使用的命令是：

```bash
godot --headless --path . --import
godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode
```

先运行导入。全新克隆没有 `.godot/` 类缓存，而没有缓存的运行会以 **1**
退出 — `GdUnitCmdTool.gd` 未加载（`Failed to load
script`），因此没有测试运行。比新 `class_name` 更旧的缓存会让有效
代码以 105 失败。CI action 会自行导入。

每个测试通过时退出码为 **0**，任何测试失败时为 **100** — 已在
Godot 4.6.1 + gdUnit4 6.1.3 以及 Godot 4.7.2 + gdUnit4 6.2.2 上验证。
**101** 表示每个测试都通过了，但有测试
泄漏了节点：这是警告，不是失败。103 和 104 表示 gdUnit4 无法运行
（拒绝 headless、Godot 低于 4.3）；105 表示某个测试脚本无法解析。`-a res://tests` 会运行 `tests/`
下的所有测试套件；`--ignoreHeadlessMode` 是必需的，因为 gdUnit4 否则
拒绝以 headless 运行。`--remote-debug tcp://127.0.0.1:0` 同样必需 —
它是 gdUnit4 自身的 `runtest` 脚本所传的参数。没有它，脚本错误
会打开 Godot 的交互式调试器，运行会永远停在 `debug>` 提示符
而不是以 105 退出。该标志会让每次运行打印两行关于远程端口的 `ERROR:`
（`127.0.0.1:0`）；它们是预期内的，不是失败。
找不到测试的运行会打印 `No test cases found` 并以 0 退出 — 那
不是通过。文件夹是 `addons/gdUnit4/`，**U 大写**。

创建 `tests/unit/.gdignore_placeholder`，内容为：
`# Unit tests go here — one subdirectory per system (e.g., tests/unit/combat/)`

创建 `tests/integration/.gdignore_placeholder`，内容为：
`# Integration tests go here — one subdirectory per system`

在 README 中注明：**Installing GdUnit4**
```
1. Open Godot → Asset Store (AssetLib before Godot 4.7) → search "GdUnit4" → install it
2. Enable the plugin: Project → Project Settings → Plugins → GdUnit4 ✓
3. Restart the editor
4. Verify: res://addons/gdUnit4/bin/GdUnitCmdTool.gd exists (capital U)
```

#### Unity (`Engine: Unity`)

测试位于 **`Assets/Tests/`** 下 — Unity 只编译 `Assets/` 和
`Packages/`。`tests/` 下的测试永远不会被编译，运行时会报告
**0 个测试、`Passed`、退出码 0**（已在 6000.3.23f1 上验证）：虚假通过。

先检查 Test Framework 包：
`grep -q 'com.unity.test-framework' Packages/manifest.json`。没有它
`-runTests` 不会失败 — 而是会挂起。若缺失，请求在 `dependencies` 中
添加 `"com.unity.test-framework"`，版本使用你的编辑器所捆绑的版本。Unity 6 各版本捆绑的版本不同 — 6000.3.23f1 中是 1.6.0，6000.1.0f1 中是
1.5.1 — 因此要读取它，而不是照抄一个数字：在 Windows 上，它是
包含 `Unity.exe` 的文件夹下
`Data/Resources/PackageManager/BuiltInPackages/com.unity.test-framework/package.json` 中的
`version`。

创建 `Assets/Tests/EditMode/EditModeTests.asmdef` — 单元测试，无 Play Mode：
```json
{
  "name": "EditModeTests",
  "references": ["UnityEngine.TestRunner", "UnityEditor.TestRunner"],
  "includePlatforms": ["Editor"],
  "overrideReferences": true,
  "precompiledReferences": ["nunit.framework.dll"],
  "autoReferenced": false,
  "defineConstraints": ["UNITY_INCLUDE_TESTS"]
}
```

创建 `Assets/Tests/PlayMode/PlayModeTests.asmdef` — 在运行中场景里的
集成测试：相同的 JSON，`"name"` 改为 `"PlayModeTests"`，
`"includePlatforms": []`。

> **测试程序集无法看到默认 `Assembly-CSharp` 中的代码。** 一个
> `.asmdef` 只能引用其他 `.asmdef`。如果游戏的脚本没有自己的
> `.asmdef`，在创建前询问（例如 `Assets/Scripts/Game.asmdef`），
> 并把 `"Game"` 添加到两个测试程序集的 `references`。没有它，第一个
> 命名游戏类的测试就会编译失败。把脚本移入
> `.asmdef` 会改变它们能看到什么，因此在创建它之前：
>
> - **列出脚本使用的包。** `Assembly-CSharp` 会自行引用每个
>   包；`.asmdef` 只引用它指明的内容。读取
>   脚本的 `using` 行并添加匹配的程序集 — 常见的有
>   `"Unity.InputSystem"`、`"Unity.TextMeshPro"`、`"UnityEngine.UI"`：
>   `{ "name": "Game", "references": ["Unity.InputSystem", "Unity.TextMeshPro"] }`。
>   只指明项目已安装的包。
> - **为它下面的每个 `Editor/` 文件夹提供自己的 `.asmdef`**，配置为
>   `"includePlatforms": ["Editor"]` 和 `"references": ["Game"]`。否则
>   编辑器脚本会加入运行时程序集，`using UnityEditor;` 会破坏
>   player 构建。

在 README 中注明：**Running Unity tests**（使用编辑器可执行文件 —
`PATH` 中的 `Unity` 可能是 Unity 的独立 CLI，而非编辑器）
```
"<Unity editor>" -batchmode -runTests -projectPath . -testPlatform EditMode -testResults test-results/editmode.xml
"<Unity editor>" -batchmode -runTests -projectPath . -testPlatform PlayMode -testResults test-results/playmode.xml
```
每个测试通过时退出 **0**，任何测试失败时退出 **2**。退出码 1 或 3 也是 FAIL：
1 是编译错误，不会写出结果文件；3 是运行失败。
4（未知的 `-testPlatform`）以及任何其他非零退出码同样如此。
每次运行前删除 `test-results/editmode.xml`，这样旧文件绝不会被
当作新结果读取。读取结果文件的 `<test-run>`
元素：`testcasecount="0"` 表示什么都没编译或找到 — 报告为未评估，绝不要报告为通过。不要添加 `-quit`；
`-runTests` 会自行退出。Play Mode 是第二行：一次独立的运行，
有自己的结果文件，以相同方式读取，并在每次运行前以相同方式删除。
Edit Mode 运行绝不会运行 `Assets/Tests/PlayMode/` 中的测试，因此
只要该文件夹中有测试，`/smoke-check` 就会运行两者。

#### Unreal Engine (`Engine: Unreal` 或 `Engine: UE5`)

测试位于**游戏模块内部**：`Source/<Module>/Private/Tests/`，其中
`<Module>` 是主游戏模块（对于 C++ 项目，就是 `.uproject` 名称）。
UnrealBuildTool 只编译模块文件夹 — 直接位于
`Source/` 下的测试文件夹不是模块，因此放在那里的测试会静默地从不被构建，每次
运行都报告 `No automation tests matched`。

创建 `Source/<Module>/Private/Tests/README.md`。其中的 `<Project>.` —
以及下方 CI 过滤器中的 `[ProjectName].` — 是 `commands.test` 中
过滤器使用的测试根：项目名称，或当项目名称同时是引擎区域时
`/setup-engine` 选择的独特根。写出该根：
```markdown
# Unreal Automation Tests
Tests use the UE Automation Testing Framework and compile with this module.
Wrap each test file in `#if WITH_DEV_AUTOMATION_TESTS` … `#endif`.
Flags: `EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter`
(there is no `GameFilter` flag).

Run via: Session Frontend → Automation → select "<Project>." tests
Or headlessly from the project root, after building the editor target — on a
fresh checkout the editor exits before any test runs:
"<UE root>/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" <Project>Editor Win64 Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject"
"<UE root>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" -ExecCmds="Automation RunTests <Project>.; Quit" -unattended -nullrhi -stdout -FullStdOutLogOutput
The project path must be absolute: UE does not find a relative one (exit 1,
"Project file not found"). Those two lines are Windows'. On Linux build with
`Engine/Build/BatchFiles/Linux/Build.sh <Project>Editor Linux Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject"` and run
the tests with `Engine/Binaries/Linux/UnrealEditor` and the same arguments; on
macOS build with `Engine/Build/BatchFiles/Mac/Build.sh <Project>Editor Mac Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject"`
— Epic documents no command-line editor inside `UnrealEditor.app` for the test
run (see `docs/engine-reference/unreal/current-best-practices.md`, "Command Line").

Read the output, not the exit code: a failing test and a run that matched nothing both exit 255.
`Result={Fail}` is a failure; `No automation tests matched` means no test was
built or named `<Project>.…`.

Test class naming: F[System][Scenario]Test — one class per test; a second
test reusing a class name fails to link
Test name: "<Project>.[System].[Scenario]"
```

---
