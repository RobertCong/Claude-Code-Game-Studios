# Godot 输入 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

### 4.7 变更
- **鼠标和键盘设备 ID**：`InputEvent.device` 为
  `InputEvent.DEVICE_ID_MOUSE` / `DEVICE_ID_KEYBOARD`（原为 `0`，某些
  手柄也会使用 `0`）。请按类型识别事件，而不是用 `device == 0`（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）
- **`VirtualJoystick` 节点**：屏幕摇杆，提供 Fixed、Dynamic 和
  Following 模式
- 可读取**手柄陀螺仪和加速度计**（4.7 发行说明：https://godotengine.org/releases/4.7/）

### 4.6 变更
- **双焦点系统**：鼠标/触摸焦点现在与键盘/手柄焦点分离
  - 视觉反馈因输入方式而异
  - 自定义焦点实现可能需要更新
- **Select Mode 键位变更**："Select Mode" 现在为 `v` 键；旧模式更名为 "Transform Mode"（`q` 键）

### 4.5 变更
- **SDL3 手柄驱动**：手柄处理委托给 SDL 库，以获得更好的跨平台支持
- **递归禁用 Control**：单个属性即可禁用整个节点层级的鼠标/焦点

### 4.3 变更（已在训练数据中）
- **InputEventShortcut**：用于菜单快捷键的专用事件类型（可选）

## 当前 API 模式

### 输入动作（未变）
```gdscript
func _physics_process(delta: float) -> void:
    var input_dir: Vector2 = Input.get_vector(
        &"move_left", &"move_right", &"move_forward", &"move_back"
    )
    if Input.is_action_just_pressed(&"jump"):
        jump()
```

### 输入事件（未变）
```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_click(event.position)
    elif event is InputEventKey:
        if event.keycode == KEY_ESCAPE and event.pressed:
            toggle_pause()
```

### 焦点管理（4.6 — 变更）
```gdscript
# Mouse/touch and keyboard/gamepad focus are now SEPARATE
# Visual styles may differ depending on which input method is active
# If you have custom focus drawing, test with both input methods

# Standard approach still works:
func _ready() -> void:
    %StartButton.grab_focus()  # Keyboard/gamepad focus

# But be aware: mouse hover focus != keyboard focus in 4.6
```

### 手柄（4.5+ — SDL3 后端）
```gdscript
# API unchanged, but SDL3 provides:
# - Better device detection across platforms
# - Improved rumble support
# - More consistent button mapping

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        if event.button_index == JOY_BUTTON_A and event.pressed:
            confirm_selection()
```

## 常见错误
- 不同时测试鼠标和键盘焦点路径（4.6 的双焦点）
- 假设 `grab_focus()` 会影响鼠标焦点（4.6 中它只影响键盘/手柄）
- 在热路径中为动作名使用字符串字面量而不是 `StringName`（`&"action"`）
