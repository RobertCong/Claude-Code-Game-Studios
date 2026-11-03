---
paths:
  - "tests/**"
  - "Assets/Tests/**/*.cs"
  - "Source/**/Tests/**/*.{h,cpp}"
---

# 测试标准

- 测试命名遵循引擎的语言——每个名称都说明场景和预期结果：
  - **Godot（gdUnit4）：** 文件 `[system]_[feature]_test.gd`，函数
    `test_[scenario]_[expected]`
  - **Unity（NUnit）：** 类 `[System]Tests` 放在同名文件中，方法
    `[Scenario]_[Expected]` 使用 PascalCase
  - **Unreal（Automation）：** 类 `F[System][Scenario]Test` —— 每个测试一个：
    每个 `IMPLEMENT_SIMPLE_AUTOMATION_TEST` 定义自己的类，因此第二个测试
    复用名称会链接失败 —— 测试名
    `<Project>.[System].[Scenario]` —— 项目的测试命令
    `Automation RunTests <Project>.` 会运行所有名称包含
    `<Project>.` 的测试（子串匹配，不是前缀匹配）。`<Project>.` 是
    `commands.test` 中过滤器的根：项目名，或当项目名同时也是一个引擎领域
    （`Audio`、`Core`、`Input`……）时 `/setup-engine` 选择的独特根——无论哪种，
    都把测试命名在它之下
- 每个测试必须有清晰的 arrange/act/assert 结构
- 单元测试不得依赖外部状态（文件系统、网络、数据库）
- 集成测试必须自行清理
- 性能测试必须指定可接受的阈值，并在超限时失败
- 测试数据必须定义在测试内或专用 fixture 中，绝不能共享可变状态
- 对外部依赖进行 mock——测试应当快速且确定性
- 每个 bug 修复都必须有一个能捕获原始 bug 的回归测试——
  并且**在信任它之前，你必须亲眼见它失败。** 对未修复的代码运行新测试，
  确认它失败，然后应用修复并确认它通过。一个只见过通过的
  回归测试，不能算作测试了任何东西。

  > 这是把 `.claude/rules/skill-authoring.md` 的「没有亲眼见它失败的闸门
  > 不是闸门」应用到测试上。这里写出来是因为只陈述
  > *目标*不够。针对迭代顺序缺陷的回归测试可能使用
  > 一个没有任何单元在单个 tick 内参与两次传输的 fixture——于是它对着
  > 它所针对的那个 bug 也通过，还显得权威。让测试无效的是
  > fixture，而不是断言，只有对未修复代码运行它才能暴露这一点。

## 示例

**正确**（恰当的命名 + Arrange/Act/Assert）——Godot，gdUnit4：

```gdscript
extends GdUnitTestSuite

func test_take_damage_reduces_health() -> void:
    # Arrange — auto_free: a Node left alive is an orphan (gdUnit4 exit 101)
    var health: HealthComponent = auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 100

    # Act
    health.take_damage(25)

    # Assert
    assert_int(health.current_health).is_equal(75)
```

Unity，NUnit（`Assets/Tests/EditMode/HealthTests.cs`）：

```csharp
using NUnit.Framework;

public class HealthTests
{
    [Test]
    public void TakeDamage_ReducesHealth()
    {
        // Arrange
        var health = new Health(maxHealth: 100);

        // Act
        health.TakeDamage(25);

        // Assert
        Assert.AreEqual(75, health.Current);
    }
}
```

Unreal，Automation（`Source/<Module>/Private/Tests/HealthTest.cpp`）：

```cpp
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FHealthTakeDamageTest, "<Project>.Health.TakeDamageReducesHealth",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::ProductFilter)

bool FHealthTakeDamageTest::RunTest(const FString& Parameters)
{
    // Arrange
    FHealthPool Health(100);

    // Act
    Health.TakeDamage(25);

    // Assert
    TestEqual(TEXT("health after 25 damage"), Health.GetCurrent(), 75);
    return true;
}

#endif
```

**错误**：

```gdscript
func test1() -> void:  # VIOLATION: no descriptive name
    var h := HealthComponent.new()
    h.take_damage(25)  # VIOLATION: no arrange step, no clear assert
    assert_bool(h.current_health < 100).is_true()  # VIOLATION: imprecise assertion
```
