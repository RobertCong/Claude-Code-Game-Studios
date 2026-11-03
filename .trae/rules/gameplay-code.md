---
alwaysApply: false
globs: src/gameplay/**,Assets/**/Gameplay/**/*.cs,Assets/**/gameplay/**/*.cs,Source/**/Gameplay/**/*.h,Source/**/Gameplay/**/*.cpp,Source/**/gameplay/**/*.h,Source/**/gameplay/**/*.cpp
---

# 玩法代码规则

- 所有玩法数值必须来自外部配置/数据文件，绝不能硬编码
- 所有与时间相关的计算都使用 delta time（帧率无关）
- 不得直接引用 UI 代码——使用事件进行跨系统通信（Godot 信号、C# 事件、Unreal 委托）
- 每个玩法系统都必须实现清晰的接口
- 状态机必须有明确的转换表，并记录状态
- 为所有玩法逻辑编写单元测试——将逻辑与表现分离
- 在代码注释中记录每个功能实现的是哪份设计文档
- 游戏状态不使用静态单例——使用依赖注入

## 示例

**正确**（数据驱动）——Godot：

```gdscript
var damage: float = config.get_value("combat", "base_damage", 10.0)
var speed: float = stats_resource.movement_speed * delta
```

Unity（数值来自 ScriptableObject）：

```csharp
float damage = combatConfig.BaseDamage;
float speed = stats.MovementSpeed * Time.deltaTime;
```

Unreal（数值来自数据资产）：

```cpp
const float Damage = CombatConfig->BaseDamage;
const float Speed = Stats->MovementSpeed * DeltaTime;
```

**错误**（硬编码）：

```gdscript
var damage: float = 25.0   # VIOLATION: hardcoded gameplay value
var speed: float = 5.0      # VIOLATION: not from config, not using delta
```
