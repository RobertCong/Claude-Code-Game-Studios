---
name: test-helpers
description: "生成引擎专属的测试辅助库 —— 断言工具、工厂函数、Mock，放在引擎的测试文件夹中。减少样板代码。"
argument-hint: "[system-name | all | scaffold]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/test-helpers/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项询问 · autonomous 记录后继续；
`automation_always_ask` 类别始终提示）。

# 测试辅助库

当常见的初始化、清理和断言模式被抽象为辅助函数时，编写测试用例
会更快、更一致。本技能会生成一个 `tests/helpers/` 库，针对项目实际使用的引擎、
语言和系统量身定制 —— 让每位开发者写更少的样板代码、更多的断言。

**输出**：引擎专属的辅助文件，放在引擎的**辅助根目录**中 ——
这是其测试运行器唯一会编译它们的位置（`.claude/docs/directory-structure.md`）：

| 引擎 | 辅助根目录 |
|---|---|
| Godot | `tests/helpers/` |
| Unity | `Assets/Tests/EditMode/Helpers/` —— 位于 `/test-setup` 创建的 `EditModeTests` 程序集内。如果 PlayMode 测试需要相同的辅助函数，在创建 `Assets/Tests/Helpers/TestHelpers.asmdef` 并从两个测试程序集引用它之前先询问。 |
| Unreal | `Source/<Module>/Private/Tests/Helpers/` |

下文的 `tests/helpers/` 指项目所用引擎的辅助根目录。

**何时运行：**
- 在 `/test-setup` 搭建框架之后（首次）
- 当多个测试文件重复相同的初始化样板代码时
- 开始为新系统编写测试时

---

## 断言：使用项目的测试框架，绝不使用裸 `assert()`

**生成的辅助函数必须通过已配置测试框架的断言
API 进行断言**，该框架由 `testing.framework` 解析 —— 而不是通过 GDScript 内置的
`assert()`。

在辅助函数中使用裸 `assert()` 会出两个问题，而且都是静默的：

1. **它会中止运行，而不是让测试失败。** 框架断言会
   记录失败并继续，因此一个错误的预期只产生一个红色测试。
   裸 `assert()` 会停止执行，因此第一个失败会掩盖其后的
   所有结果。
2. **它会在发布构建中被剥离。** 基于 `assert()` 构建的辅助库
   会在你最想检查的那个构建中完全停止断言，而且
   不会产生任何错误 —— 测试仍然"通过"。

**在生成代码之前，先查清已配置框架的断言语形式。**
不要将本文件或其他技能示例中的写法当作权威 —— 它们只是
示意，且已经过时（`assert_eq`、
`assert_true` 和 `assert_that` 在全仓库中都出现过）。如果无法
确认项目框架的正确 API，说明这一点并不要生成
辅助函数，而不是猜测。

**辅助函数不得继承框架的测试套件基类。** `tests/helpers/` 中
继承套件类型的文件会被运行器发现为一个包含零个测试的
测试套件。辅助函数是普通类；只有真正的测试文件
才继承套件。

---

## 1. 解析参数

**模式：**
- `/test-helpers [system-name]` —— 为特定系统生成辅助函数
  （例如 `/test-helpers combat`）
- `/test-helpers all` —— 为所有含测试文件的系统生成辅助函数
- `/test-helpers scaffold` —— 仅生成基础辅助库（不含
  系统专属辅助函数）；首次运行时使用
- 无参数 —— 若无辅助函数则运行 `scaffold`，否则运行 `all`

---

## 2. 检测引擎与语言

先从 `project.yaml` 读取，对任何缺失或为空的键回退到 `.claude/docs/technical-preferences.md`：
- `engine.name`（否则用 `Engine:` 值）
- `engine.language`（否则用 `Language:` 值）
- `testing.framework`（否则用 Testing 节的 `Framework:`）

如果两个来源都未配置引擎："Engine not configured. Run `/setup-engine` first."

---

## 3. 加载现有测试模式

扫描引擎的测试根目录中已在使用的模式（Godot `tests/`，Unity
`Assets/Tests/`，Unreal `Source/<Module>/Private/Tests/`）：

```
Glob pattern="tests/**/*_test.*"                  (Godot)
Glob pattern="Assets/Tests/**/*Tests.cs"          (Unity)
Glob pattern="Source/*/Private/Tests/**/*.cpp"    (Unreal)
```

对有代表性的样本（最多 5 个文件），读取测试文件并提取：
- 初始化模式（`before_each` / `setUp` / fixture 是如何编写的）
- 常见断言模式（最常断言什么）
- 对象创建模式（测试中如何实例化游戏对象或场景）
- Mock/桩模式（如何替换依赖）

这能确保生成的辅助函数匹配项目现有风格，而不是
通用模板。

还要读取：
- `design/gdd/systems-index.md` —— 了解存在哪些系统
- 范围内的 GDD —— 了解需要测试哪些数据类型和数值。按节
  读取它们：用 Grep 工具找到需要的标题（pattern `^#`，
  content 模式），再用 offset 和 limit 读取那些范围。
- `docs/architecture/tr-registry.yaml` —— 将需求映射到被测系统

---

## 4. 生成引擎专属辅助函数

### Godot 4（GDUnit4 / GDScript）

> **下面示例中的 `FAIL_IF(...)` 是占位符，不是 API。** 它标记了
> 在输出任何内容之前，你必须按 §2 的规则从项目实际测试框架中
> 解析出的那一行。替换为框架真实的失败调用 —— 即**向运行器
> 登记失败并让套件继续**的形式 —— 并删除标记注释。
>
> **它刻意没有被写成 `assert_that`、`assert_eq` 或 `assert_true`。**
> 这三种都在本仓库的某处出现过，彼此不一致，而且 **GdUnit4 的 API
> 不在 `docs/engine-reference/` 的覆盖范围内** —— 因此在此写下其中任何一个，
> 都是在断言本仓库无法溯源的 API，而且是在这样一个以阻止
> 他人这么做为全部职责的文件里。如果你无法确认已配置
> 框架的正确调用，§2 已经告诉你答案：**不要生成辅助函数。** 一个未解析的
> `FAIL_IF` 落到磁盘上是缺陷；缺少辅助函数是一个任务。
>
> 示例同样必须遵守 §2 —— 这里的一个裸 `assert()` 正是 §2 所禁止的
> 形式，且位于 §2 禁止它之后六十行。以文字陈述的规则
> 不会自动覆盖到自己的示例，除非有人去落实。

**基础辅助函数**（`tests/helpers/game_assertions.gd`）：

```gdscript
## Game-specific assertion utilities for [Project Name] tests.
## Domain-specific helpers built on the project's test framework.
##
## Usage (static — no instance needed):
##   GameAssertions.assert_in_range(entity.health, 0, entity.max_health, "health")

class_name GameAssertions
extends RefCounted

## Assert a value is within the inclusive range [min_val, max_val].
## Use for any formula output that has defined bounds in a GDD.
static func assert_in_range(
    value: float,
    min_val: float,
    max_val: float,
    label: String = "value"
) -> void:
    # FRAMEWORK ASSERT — resolve per the rule above; do not emit `assert()`.
    FAIL_IF(
        not (value >= min_val and value <= max_val),
        "%s %.2f is outside expected range [%.2f, %.2f]" % [label, value, min_val, max_val]
    )

## Assert a signal was emitted during a callable block.
## Usage: assert_signal_emitted(entity, "health_changed", func(): entity.take_damage(10))
static func assert_signal_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    # A lambda captures a local by value: `emitted = true` inside it would set
    # the lambda's own copy. Mutate a Dictionary it shares instead. `...args`
    # (4.5+) accepts a signal with any number of arguments.
    var state := {"emitted": false}
    obj.connect(signal_name, func(...args): state.emitted = true)
    action.call()
    # FRAMEWORK ASSERT — resolve per the rule above; do not emit `assert()`.
    FAIL_IF(not state.emitted, "Expected signal '%s' to be emitted, but it was not." % signal_name)

## Assert that a callable does NOT emit a signal.
static func assert_signal_not_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    var state := {"emitted": false}  # a Dictionary, as above
    obj.connect(signal_name, func(...args): state.emitted = true)
    action.call()
    # FRAMEWORK ASSERT — resolve per the rule above; do not emit `assert()`.
    FAIL_IF(state.emitted, "Expected signal '%s' NOT to be emitted, but it was." % signal_name)

## Assert a node exists at path within a parent.
static func assert_node_exists(parent: Node, path: NodePath) -> void:
    # FRAMEWORK ASSERT — resolve per the rule above; do not emit `assert()`.
    FAIL_IF(
        not parent.has_node(path),
        "Expected node at path '%s' to exist." % str(path)
    )
```

**工厂辅助函数**（`tests/helpers/game_factory.gd`）：

```gdscript
## Factory functions for creating test game objects.
## Returns minimal objects configured for unit testing (no scene tree required).
##
## Usage: var player = GameFactory.make_player(health: 100)

class_name GameFactory
extends RefCounted

## Create a minimal player-like object for testing.
## Override fields as needed.
static func make_player(health: int = 100) -> Node:
    var player = Node.new()
    player.set_meta("health", health)
    player.set_meta("max_health", health)
    return player
```

**场景辅助函数**（`tests/helpers/scene_runner_helper.gd`）：

```gdscript
## Utilities for scene-based integration tests. For input simulation and frame
## stepping, use gdUnit4's own `scene_runner()` from inside the suite.

class_name SceneRunnerHelper
extends RefCounted

## Load a scene under `host` — the calling test suite, which passes `self` —
## and wait one frame for _ready() to complete. A plain class, so the runner
## never discovers this file as a suite with zero tests.
static func load_scene_and_wait(host: Node, scene_path: String) -> Node:
    var scene: Node = load(scene_path).instantiate()
    host.add_child(scene)
    await host.get_tree().process_frame
    return scene
```

---

### Unity（NUnit / C#）

**基础辅助函数**（`Assets/Tests/EditMode/Helpers/GameAssertions.cs`）：

```csharp
using NUnit.Framework;
using UnityEngine;

/// <summary>
/// Game-specific assertion utilities for [Project Name] tests.
/// Extends NUnit's Assert with domain-specific helpers.
/// </summary>
public static class GameAssertions
{
    /// <summary>
    /// Assert a value is within an inclusive range [min, max].
    /// Use for any formula output defined in GDD Formulas sections.
    /// </summary>
    public static void AssertInRange(float value, float min, float max, string label = "value")
    {
        Assert.That(value, Is.InRange(min, max),
            $"{label} ({value:F2}) is outside expected range [{min:F2}, {max:F2}]");
    }

    /// <summary>Assert a UnityEvent or C# event was raised during an action.</summary>
    public static void AssertEventRaised(ref bool wasCalled, System.Action action, string eventName)
    {
        wasCalled = false;
        action();
        Assert.IsTrue(wasCalled, $"Expected event '{eventName}' to be raised, but it was not.");
    }

    /// <summary>Assert a component exists on a GameObject.</summary>
    public static void AssertHasComponent<T>(GameObject obj) where T : Component
    {
        var component = obj.GetComponent<T>();
        Assert.IsNotNull(component,
            $"Expected GameObject '{obj.name}' to have component {typeof(T).Name}.");
    }
}
```

**工厂辅助函数**（`Assets/Tests/EditMode/Helpers/GameFactory.cs`）：

```csharp
using UnityEngine;

/// <summary>
/// Factory methods for creating minimal test objects without loading scenes.
/// </summary>
public static class GameFactory
{
    /// <summary>Create a minimal GameObject with a named component for testing.</summary>
    public static GameObject MakeGameObject(string name = "TestObject")
    {
        var go = new GameObject(name);
        return go;
    }

    /// <summary>
    /// Create a ScriptableObject of type T for data-driven tests.
    /// Dispose with Object.DestroyImmediate after test.
    /// </summary>
    public static T MakeScriptableObject<T>() where T : ScriptableObject
    {
        return ScriptableObject.CreateInstance<T>();
    }
}
```

---

### Unreal Engine（C++）

**基础辅助函数**（`Source/<Module>/Private/Tests/Helpers/GameTestHelpers.h`）：

```cpp
#pragma once

#include "CoreMinimal.h"
#include "Misc/AutomationTest.h"

/**
 * Game-specific assertion macros and helpers for [Project Name] automation tests.
 * Include in any test file that needs domain-specific assertions.
 *
 * Usage:
 *   GAME_TEST_ASSERT_IN_RANGE(TestName, DamageValue, 10.0f, 50.0f, TEXT("Damage"));
 */

// Assert a float value is within inclusive range [Min, Max]
#define GAME_TEST_ASSERT_IN_RANGE(TestName, Value, Min, Max, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s (%.2f) in range [%.2f, %.2f]"), Label, Value, Min, Max), \
        (Value) >= (Min) && (Value) <= (Max) \
    )

// Assert a UObject pointer is valid (not null, not garbage collected)
#define GAME_TEST_ASSERT_VALID(TestName, Ptr, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s is valid"), Label), \
        IsValid(Ptr) \
    )

// Assert an Actor is in the world (spawned successfully)
#define GAME_TEST_ASSERT_SPAWNED(TestName, ActorPtr, ClassName) \
    TestNotNull( \
        FString::Printf(TEXT("Spawned actor of class %s"), TEXT(#ClassName)), \
        ActorPtr \
    )

/**
 * Helper to create a minimal test world.
 * Remember to call World->DestroyWorld(false) in teardown.
 */
namespace GameTestHelpers
{
    inline UWorld* CreateTestWorld(const FString& WorldName = TEXT("TestWorld"))
    {
        UWorld* World = UWorld::CreateWorld(EWorldType::Game, false);
        FWorldContext& WorldContext = GEngine->CreateNewWorldContext(EWorldType::Game);
        WorldContext.SetCurrentWorld(World);
        return World;
    }
}
```

---

## 5. 生成系统专属辅助函数

对于 `[system-name]` 或 `all` 模式，为每个系统生成一个辅助函数：

只读取所需 GDD 中需要的节 —— `Grep pattern="^## ([0-9]+\. )?(Formulas|Edge Cases|Detailed Rules|Detailed Design)" path="design/gdd/[system].md" output_mode="content" -A 30`（可选编号匹配反向生成的 GDD 的 `## 4. Formulas`）—— 而不是完整读取（每个同类技能都按节 Grep GDD；在 `all` 模式下，完整读取会乘以每个系统 400+ 行的 GDD）。提取：
- 数据类型（实体类型、组件名称）
- 公式变量及其边界
- Edge Cases 中提到的常见测试场景

生成 `tests/helpers/[system]_factory.[ext]`，包含该系统对象
专属的工厂函数。

`combat` 系统的示例模式（Godot/GDScript）：

```gdscript
## Factory and assertion helpers for Combat system tests.
## Generated by /test-helpers combat on [date].
## Based on: design/gdd/combat.md

class_name CombatTestFactory
extends RefCounted

const DAMAGE_MIN := 0
const DAMAGE_MAX := 999  # From GDD: damage formula upper bound

## Create a minimal attacker object for damage formula tests.
static func make_attacker(attack: float = 10.0, crit_chance: float = 0.0) -> Node:
    var attacker = Node.new()
    attacker.set_meta("attack", attack)
    attacker.set_meta("crit_chance", crit_chance)
    return attacker

## Create a minimal target object for damage receive tests.
static func make_target(defense: float = 0.0, health: float = 100.0) -> Node:
    var target = Node.new()
    target.set_meta("defense", defense)
    target.set_meta("health", health)
    target.set_meta("max_health", health)
    return target

## Assert damage output is within GDD-specified bounds.
static func assert_damage_in_bounds(damage: float) -> void:
    GameAssertions.assert_in_range(damage, DAMAGE_MIN, DAMAGE_MAX, "damage")
```

---

## 6. 写出输出

呈现将要创建内容的摘要：

```
## Test Helpers to Create

Base helpers (engine: [engine], helper root: [helper root]):
- [helper root]/game_assertions.[ext]
- [helper root]/game_factory.[ext]
[engine-specific extras]

System helpers ([mode]):
- [helper root]/[system]_factory.[ext]  ← from [system] GDD
```

询问："我可以将这些辅助文件写入 `[helper root]` 吗？"

**绝不覆盖现有文件。** 如果文件已存在，报告：
"正在跳过 `[path]` —— 已存在。如果你想重新生成，请手动删除该文件。"

写入之后：结论：**COMPLETE** —— 辅助文件已创建。

"辅助文件已创建。在测试中使用它们：
- Godot：`class_name` 会自动导入 —— 无需显式 import
- Unity：添加 `using` 指令或引用测试程序集
- Unreal：`#include \"Tests/Helpers/GameTestHelpers.h\"`（在模块内部）"

---

## 协作协议

- **绝不覆盖现有辅助函数** —— 它们可能包含手写的
  自定义内容。只生成尚不存在的新文件
- **生成的代码是起点** —— 生成的工厂函数出于简便使用
  元数据模式；等实际代码存在后，再调整为实际的类结构
- **辅助函数应反映 GDD** —— 辅助函数中的边界和常量应
  可追溯到 GDD 的 Formulas 节，而不是臆造的值
- **写入前先询问** —— 在 `tests/` 中创建文件前始终确认

## 后续步骤

- 如果测试框架尚未搭建，运行 `/test-setup`。
- 使用 `/dev-story` 实现用户故事 —— 辅助函数可减少新测试文件中的样板代码。
- 运行 `/skill-test` 以验证其他可能需要辅助函数覆盖的技能。
