# Godot 动画 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

### 4.7 变更
- **`Tween.tween_await()`**：暂停补间动画，直到发出信号（4.7 发行说明：https://godotengine.org/releases/4.7/）
- **`LookAtModifier3D.relative`** 默认值为 `false`（原为 `true`）
- **`AnimationNodeBlendSpace1D/2D.add_blend_point()`**：可选 `name` 参数
- **`Animation.length`** 在 C# 中为 `double`（原为 `float`）；GDScript 不受影响（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）

### 4.6 变更
- **IK 系统完全恢复**：为 3D 骨骼提供完整的反向运动学
  - CCDIK、FABRIK、Jacobian IK、Spline IK、TwoBoneIK
  - 通过 `SkeletonModifier3D` 节点应用（不是旧的 IK 方案）
- **动画编辑器体验优化（QoL）**：Bezier 节点组的 Solo/hide/lock/delete；可拖动的时间轴

### 4.5 变更
- **BoneConstraint3D**：通过修改器将骨骼绑定到其他骨骼
  - `AimModifier3D`、`CopyTransformModifier3D`、`ConvertTransformModifier3D`

### 4.3 变更（已在训练数据中）
- **AnimationMixer**：AnimationPlayer 与 AnimationTree 的基类
  - `method_call_mode` → `callback_mode_method`
  - `playback_active` → `active`
  - `bone_pose_updated` 信号 → `skeleton_updated`
- **`Skeleton3D.add_bone()`**：现在返回 `int32`（原为 `void`）

## 当前 API 模式

### AnimationPlayer（API 未变，新的基类）
```gdscript
@onready var anim_player: AnimationPlayer = %AnimationPlayer

func play_attack() -> void:
    anim_player.play(&"attack")
    await anim_player.animation_finished
```

### IK 设置（4.6 — 新增）
```gdscript
# Add SkeletonModifier3D-based IK nodes as children of Skeleton3D
# Available types:
# - SkeletonModifier3D (base)
# - TwoBoneIK (arms, legs)
# - FABRIK (chains, tentacles)
# - CCDIK (tails, spines)
# - Jacobian IK (complex multi-joint)
# - Spline IK (along curves)

# Configure in editor or code:
# 1. Add IK modifier node as child of Skeleton3D
# 2. Set target bone and tip bone
# 3. Add a Marker3D as the IK target
# 4. IK solver runs automatically each frame
```

### BoneConstraint3D（4.5 — 新增）
```gdscript
# Add as child of Skeleton3D
# Types:
# - AimModifier3D: Point bone at target
# - CopyTransformModifier3D: Mirror another bone's transform
# - ConvertTransformModifier3D: Remap transform values
```

### AnimationTree（基类在 4.3 中变更）
```gdscript
# AnimationTree now extends AnimationMixer (not Node directly)
# Use AnimationMixer properties:
@onready var anim_tree: AnimationTree = %AnimationTree

func _ready() -> void:
    anim_tree.active = true  # NOT playback_active (deprecated 4.3)
```

## 常见错误
- 使用 `playback_active` 而不是 `active`（自 4.3 起弃用）
- 使用 `bone_pose_updated` 信号而不是 `skeleton_updated`（4.3 中重命名）
- 使用旧的 IK 方案而不是 SkeletonModifier3D 系统（4.6 中恢复）
- 对动画节点做类型检查时不检查 `is AnimationMixer`
