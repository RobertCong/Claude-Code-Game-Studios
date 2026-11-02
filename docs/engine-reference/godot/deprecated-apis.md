# Godot — 已弃用 API

最后核对：2026-10-17（4.7 各行）；2026-02-12（其余部分）

4.7 迁移指南未列出任何正式的弃用项；下表中的 4.7 各行是其中的重命名和移除
（https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）。

如果代理建议使用"已弃用"列中的任何 API，则必须替换为"改用"列中的 API。

## 节点与类

| 已弃用 | 改用 | 起始版本 | 说明 |
|------------|-------------|-------|-------|
| `TileMap` | `TileMapLayer` | 4.3 | 每层一个节点，而不是多层级节点 |
| `VisibilityNotifier2D` | `VisibleOnScreenNotifier2D` | 4.0 | 为清晰起见重命名 |
| `VisibilityNotifier3D` | `VisibleOnScreenNotifier3D` | 4.0 | 为清晰起见重命名 |
| `YSort` | `Node2D.y_sort_enabled` | 4.0 | 是 Node2D 上的属性，不是独立节点 |
| `Navigation2D` / `Navigation3D` | `NavigationServer2D` / `NavigationServer3D` | 4.0 | 基于服务器的 API |
| `EditorSceneFormatImporterFBX` | `EditorSceneFormatImporterFBX2GLTF` | 4.3 | 已重命名 |

## 方法与属性

| 已弃用 | 改用 | 起始版本 | 说明 |
|------------|-------------|-------|-------|
| `yield()` | `await signal` | 4.0 | GDScript 2.0 协程语法 |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 | 基于 Callable 的连接 |
| `instance()` | `instantiate()` | 4.0 | 已重命名 |
| `PackedScene.instance()` | `PackedScene.instantiate()` | 4.0 | 已重命名 |
| `get_world()` | `get_world_3d()` | 4.0 | 显式的 2D/3D 拆分 |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 | 首选 Time 单例 |
| 用于嵌套资源的 `duplicate()` | `duplicate_deep()` | 4.5 | 显式的深复制控制 |
| `Skeleton3D` 信号 `bone_pose_updated` | `skeleton_updated` | 4.3 | 已重命名 |
| `AnimationPlayer.method_call_mode` | `AnimationMixer.callback_mode_method` | 4.3 | 移至基类 |
| `AnimationPlayer.playback_active` | `AnimationMixer.active` | 4.3 | 移至基类 |
| `RichTextLabel.ImageUpdateMask.UPDATE_WIDTH_IN_PERCENT` | `ImageUpdateMask.UPDATE_WIDTH_UNIT` | 4.7 | 已重命名；使用旧名称的 GDScript 会失效 |
| `add_image()` / `update_image()` 的 `width_in_percent`、`height_in_percent`（`bool`） | `width_unit`、`height_unit`（`RichTextLabel.ImageUnit`） | 4.7 | 已重命名并更改类型 |
| `Control.accessibility_live` 使用的 `DisplayServer.AccessibilityLiveMode` | `AccessibilityServer.AccessibilityLiveMode` | 4.7 | 枚举移至 `AccessibilityServer` |
| `AudioEffectSpectrumAnalyzer.tap_back_pos` | — | 4.7 | 已移除 |
| `EditorSceneFormatImporter.IMPORT_*` 常量 | `EditorSceneFormatImporter.ImportFlags` 枚举 | 4.7 | 名称相同，现在位于枚举中 |

## 模式（不仅是 API）

| 已弃用的模式 | 改用 | 原因 |
|--------------------|-------------|-----|
| 基于字符串的 `connect()` | 类型化信号连接 | 类型安全、便于重构 |
| `_process()` 中的 `$NodePath` | `@onready var` 缓存的引用 | 性能：每帧都会查找路径 |
| 未类型化的 `Array` / `Dictionary` | `Array[Type]`、类型化变量 | GDScript 编译器优化 |
| `Shader.set_default_texture_parameter()` / `get_default_texture_parameter()` 中的 `Texture2D` | `Texture` 基类型 | 4.4 中变更；着色语言的 `sampler2D` / `texture()` 未变 |
| 手动的后处理视口链 | `Compositor` + `CompositorEffect` | 结构化后处理（4.3+） |
| 新项目使用 GodotPhysics3D | Jolt Physics 3D | 自 4.6 起为默认；稳定性更好 |
| 用 `event.device == 0` 检测鼠标或键盘 | `event is InputEventMouse` / `InputEventKey`，或 `InputEvent.DEVICE_ID_MOUSE` / `DEVICE_ID_KEYBOARD` | 自 4.7 起鼠标和键盘不再报告设备 `0`，而某些手柄会使用 `0` |
| 从编辑器的 AssetLib 标签页安装插件 | 编辑器的 Asset Store 工作区（4.7+） | 4.7 用 Asset Store 取代了 Asset Library |
