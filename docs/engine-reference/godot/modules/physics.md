# Godot 物理 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

### 4.7 变更
- **Jolt `WorldBoundaryShape3D`**：`plane.d` 的符号现在与 Godot Physics 一致，
  与 4.6 相比是翻转的；将其取负以保持 4.6 行为
- **Jolt `SoftBody3D`**：整个软体的质量默认 1 kg（原为每个点 1 kg），且
  `linear_stiffness` 的应用方式不同；请重新调整
  `linear_stiffness` 和 `damping_coefficient`
- **Jolt `Area3D`** 会报告与 `SoftBody3D` 的重叠；使用层/掩码进行过滤
- **`PhysicsServer2D.body_set_shape_as_one_way_collision()`**：可选
  `direction` 参数（在 `PhysicsServer2DExtension` 中为必需）（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）

### 4.6 变更
- **Jolt Physics 是新项目的默认 3D 引擎**
  - 现有项目保留其当前物理引擎设置
  - 相比 GodotPhysics3D 具有更好的确定性、稳定性和性能
  - 部分 HingeJoint3D 属性（`damp`）只在 GodotPhysics3D 下有效
  - 2D 物理不变（仍为 Godot Physics 2D）

### 4.5 变更
- **3D 物理插值重新架构**：从 RenderingServer 移至 SceneTree
  - 面向用户的 API 未变，但在边缘情况下内部行为可能不同

## 物理引擎选择（4.6）

```
Project Settings → Physics → 3D → Physics Engine:
- Jolt Physics (DEFAULT for new projects)
- GodotPhysics3D (legacy, still available)
```

### Jolt 与 GodotPhysics3D

| 特性 | Jolt（默认） | GodotPhysics3D |
|---------|---------------|----------------|
| 确定性 | 更好 | 不一致 |
| 稳定性 | 更好 | 足够 |
| 性能 | 复杂场景下更好 | 足够 |
| HingeJoint3D `damp` | 不支持 | 支持 |
| 运行时警告 | 有，针对不支持的属性 | 无 |
| 碰撞边距 | 行为可能不同 | 原始行为 |

## 当前 API 模式

### 基础物理设置（未变）
```gdscript
# CharacterBody3D movement — API unchanged across engines
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "back")
    var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    move_and_slide()
```

### 射线检测（未变）
```gdscript
var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
var query := PhysicsRayQueryParameters3D.create(from, to)
query.collision_mask = collision_mask
var result: Dictionary = space_state.intersect_ray(query)
if result:
    var hit_point: Vector3 = result.position
    var hit_normal: Vector3 = result.normal
```

## 常见错误
- 假设 GodotPhysics3D 是默认引擎（自 4.6 起为 Jolt）
- 不检查物理引擎就使用 HingeJoint3D 的 `damp` 属性（Jolt 会忽略它）
- 在物理引擎之间切换时不测试碰撞边缘情况
