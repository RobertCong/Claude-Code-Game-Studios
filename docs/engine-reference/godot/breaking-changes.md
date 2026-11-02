# Godot — 破坏性变更

最后核对：2026-10-17（4.6 → 4.7 及各节日期）；2026-02-12（较早的各节）

Godot 各版本之间的变更，聚焦于 LLM 知识截止日期之后的变更（4.4+）。

## 4.6 → 4.7（2026 年 6 月 — 截止日之后，高风险）

摘自官方迁移指南
（https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html，
核对于 2026-10-17）。标记为 **GDScript breaks** 的行会让现有 GDScript 停止工作；其余行则添加可选参数、仅改变 C# 兼容性，或改变行为或默认值。该指南未列出任何弃用项。

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| GDScript | 覆盖方法继承类型化返回 | 对带类型化返回的方法做覆盖时，现在会继承该类型，因此需要显式的 `return`（加上 `return null` 可修复该错误）。**GDScript breaks** |
| GDScript | 紧凑数组（packed array）元素写入 | 设置紧凑数组的单个元素时，不再调用整个紧凑数组属性的 setter |
| GUI | `RichTextLabel.ImageUpdateMask.UPDATE_WIDTH_IN_PERCENT` 重命名 | 现为 `UPDATE_WIDTH_UNIT`。**GDScript breaks** |
| GUI | `RichTextLabel.add_image()` / `update_image()` | `width` / `height` 为 `float`（原为 `int`）；`width_in_percent` / `height_in_percent` 重命名为 `width_unit` / `height_unit`，类型为 `RichTextLabel.ImageUnit`（原为 `bool`，默认 `false` → `0`）。C# source breaks |
| GUI | `Control.accessibility_live` 类型 | `AccessibilityServer.AccessibilityLiveMode`（原为 `DisplayServer.AccessibilityLiveMode`）。C# breaks |
| Core | `Object.is_class()` | 参数为 `StringName`（原为 `String`） |
| Core | `OptimizedTranslation.generate()` | 返回 `bool`（原为 `void`）。C# binary breaks |
| Input | 鼠标与键盘设备 ID | 原为 `0`；现为 `InputEvent.DEVICE_ID_MOUSE` 和 `InputEvent.DEVICE_ID_KEYBOARD`，因为某些手柄会使用 `0`。请按类型识别事件，或将 `InputEvent.device` 与这些常量比较 |
| Physics | Jolt：`WorldBoundaryShape3D` 平面符号 | `plane.d` 的符号按 Godot Physics 的方式读取，因此与 4.6 相比是翻转的：取负即可保持 4.6 的行为 |
| Physics | Jolt：`SoftBody3D` 质量与刚度 | 质量默认对整个软体为 1 kg（原为每个点 1 kg）；`linear_stiffness` 的应用方式不同。需对每个 `SoftBody3D` 重新调整 `linear_stiffness` 和 `damping_coefficient` |
| Physics | Jolt：`Area3D` 与 `SoftBody3D` | `Area3D` 现在会报告与 `SoftBody3D` 的重叠；使用碰撞层和掩码将其忽略 |
| Physics | `PhysicsServer2D.body_set_shape_as_one_way_collision()` | 新增可选参数 `direction`；`PhysicsServer2DExtension._body_set_shape_as_one_way_collision()` 要求该参数（extensions break） |
| Audio | `AudioStreamPlayer2D` / `AudioStreamPlayer3D` 的 `area_mask` 默认值 | 从层 `1` 改为 `0`（禁用）。依赖默认掩码的 `Area2D`/`Area3D` `audio_bus_override` 会停止工作，直到把掩码改回层 `1` |
| Audio | `AudioEffectSpectrumAnalyzer.tap_back_pos` | 已移除。使用处会出现 **GDScript breaks** |
| Rendering | `CanvasItem` 线条绘制 | 不再添加抗锯齿羽化，因此线条看起来更细；依赖旧粗细的线条需要加宽 |
| Rendering | `LinearToSRGB` 视觉着色器节点 | 在 Forward+ 与 Mobile 下不再钳制到 `[0.0, 1.0]` |
| Rendering | `get_format()` 移动 | 从 `ImageTexture` / `PortableCompressedTexture2D` 移至基类 `Texture2D` |
| Rendering | `RenderingServer.particles_request_process_time()` | `time` 重命名为 `process_time`；新增可选参数 `process_time_residual`（四个粒子节点的 `request_particles_process()` 同样如此） |
| Rendering | 天空反射粗糙度层 | `rendering/reflections/sky_reflections/roughness_layers` 默认值 `7` → `8` |
| Animation | `Animation.length` | 类型元数据为 `double`（原为 `float`）。C# breaks |
| Animation | `LookAtModifier3D.relative` | 默认 `false`（原为 `true`） |
| Animation | `AnimationNodeBlendSpace1D/2D.add_blend_point()` | 新增可选参数 `name` |
| Project | 新建项目的拉伸默认值 | `display/window/stretch/mode` 为 `canvas_items`（原为 `disabled`），`display/window/stretch/aspect` 为 `expand`（原为 `keep`）。现有项目保留其设置 |
| Text | `ResourceImporterDynamicFont.hinting` | 默认 `3`（原为 `1`） |
| Editor | `EditorSceneFormatImporter` 导入常量 | 移入 `ImportFlags` 枚举（`IMPORT_SCENE`、`IMPORT_ANIMATION`、…）。C# source breaks |
| Editor | `EditorVCSInterface._commit()` | 新增参数 `amend`；VCS plugins break |
| Editor | Asset Library 被 Asset Store 取代 | 编辑器工作区现在叫 "Asset Store"（发布说明：https://godotengine.org/releases/4.7/） |
| XR | `OpenXRExtensionWrapper._on_register_metadata()` | 新增参数 `interaction_profile_metadata`；extensions break |

## 4.5 → 4.6（2026 年 1 月 — 截止日之后，高风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Physics | Jolt 现为默认 3D 物理引擎 | 新项目自动使用 Jolt。现有项目保留其设置。部分 HingeJoint3D 属性（如 `damp`）仅在 GodotPhysics 下有效。 |
| Rendering | 辉光在色调映射之前处理 | 原为色调映射之后。含辉光的场景看起来会不同。在 WorldEnvironment 中调整强度/混合。 |
| Rendering | Windows 上默认使用 D3D12 | 原为 Vulkan。为了更好的驱动兼容性。 |
| Rendering | AgX 色调映射器新增控制项 | 新增白点和对比度参数。 |
| Core | Quaternion 初始化为单位四元数 | 原为零。不太可能影响多数代码，但技术上属于破坏性变更。 |
| UI | 双焦点系统 | 鼠标/触摸焦点现在与键盘/手柄焦点分离。视觉反馈因输入方式而异。 |
| Animation | IK 系统完全恢复 | 通过 SkeletonModifier3D 节点提供 CCDIK、FABRIK、Jacobian IK、Spline IK、TwoBoneIK。 |
| Editor | 新的 "Modern" 主题成为默认 | 灰度取代蓝色调。恢复方式：Editor Settings → Interface → Theme → Style: Classic |
| Editor | "Select Mode" 快捷键变更 | 新增 "Select Mode"（v 键）防止误变换。旧模式更名为 "Transform Mode"（q 键）。 |
| 2D | TileMapLayer 场景图块旋转 | 场景图块现在可以像图集图块一样旋转。 |
| Localization | CSV 复数形式支持 | 复数不再需要 Gettext。新增上下文列。 |
| C# | 自动字符串提取 | 翻译字符串从 C# 代码自动提取。 |
| Plugins | 新增 EditorDock 类 | 用于插件停靠面板的专用容器，支持布局控制。 |

## 4.4 → 4.5（2025 年 9 月 — 截止日之后，高风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| GDScript | 新增可变参数 | 函数可接受 `...` 任意参数——新语言特性 |
| GDScript | `@abstract` 装饰器 | 抽象类和抽象方法现在可强制执行 |
| GDScript | 脚本回溯 | 即使在 Release 构建中也可获得详细调用栈 |
| Rendering | 模板缓冲区支持 | 高级视觉效果的新能力 |
| Rendering | SMAA 1x 抗锯齿 | 新的后处理 AA 选项 |
| Rendering | 着色器烘焙器 | 预编译着色器——据称在某些演示中启动速度提升 20 倍 |
| Rendering | 弯曲法线贴图、镜面遮蔽 | 新的材质特性 |
| Accessibility | 屏幕阅读器支持 | Control 节点可通过 AccessKit 与无障碍工具配合工作 |
| Editor | 实时翻译预览 | 在编辑器内测试不同语言的 GUI 布局 |
| Physics | 3D 插值重新架构 | 从 RenderingServer 移至 SceneTree。API 未变但内部实现不同。 |
| Animation | BoneConstraint3D | 新增：AimModifier3D、CopyTransformModifier3D、ConvertTransformModifier3D |
| Resources | 新增 `duplicate_deep()` | 用于深层复制嵌套资源的新显式方法 |
| Navigation | 专用 2D 导航服务器 | 不再是 3D 导航的代理；2D 游戏导出体积更小 |
| UI | FoldableContainer 节点 | 用于可折叠 UI 区块的新型手风琴式容器 |
| UI | 递归 Control 行为 | 可跨整个节点层级禁用鼠标/焦点交互 |
| Platform | visionOS 导出支持 | 新的平台目标 |
| Platform | SDL3 手柄驱动 | 将手柄处理委托给 SDL 库 |
| Platform | Android 16KB 页面支持 | 面向 Android 15+ 的 Google Play 所必需 |

## 4.3 → 4.4（2025 年 3 月 — 截止日之前，需核实）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Core | `FileAccess.store_*` 返回 `bool` | 原为 `void`。方法：`store_8`、`store_16`、`store_32`、`store_64`、`store_buffer`、`store_csv_line`、`store_double`、`store_float`、`store_half`、`store_line`、`store_pascal_string`、`store_real`、`store_string`、`store_var` |
| Core | `OS.execute_with_pipe` | 新增可选参数 `blocking` |
| Core | `RegEx.compile/create_from_string` | 新增可选参数 `show_error` |
| Rendering | `RenderingDevice.draw_list_begin` | 移除了许多参数；新增参数 `breadcrumb` |
| Rendering | `Shader.set_default_texture_parameter()` / `get_default_texture_parameter()` | 参数/返回类型从 `Texture2D` 改为 `Texture`；着色语言未变 |
| Particles | `.restart()` 方法 | 新增可选参数 `keep_seed`（CPU/GPU 2D/3D） |
| GUI | `RichTextLabel.push_meta` | 新增可选参数 `tooltip` |
| GUI | `GraphEdit.connect_node` | 新增可选参数 `keep_alive` |

## 4.2 → 4.3（在训练数据内 — 低风险）

| 子系统 | 变更 | 详情 |
|-----------|--------|---------|
| Animation | `Skeleton3D.add_bone` 返回 `int32` | 原为 `void` |
| Animation | `bone_pose_updated` 信号 | 由 `skeleton_updated` 取代 |
| TileMap | `TileMapLayer` 取代 `TileMap` | 每层一个节点，而不是单个多图层节点 |
| Navigation | `NavigationRegion2D` | 移除 `avoidance_layers`、`constrain_avoidance` 属性 |
| Editor | `EditorSceneFormatImporterFBX` | 更名为 `EditorSceneFormatImporterFBX2GLTF` |
| Animation | AnimationMixer 基类 | AnimationPlayer 和 AnimationTree 现在继承 AnimationMixer |

## Sources

- 官方文档：https://docs.godotengine.org/en/stable/
- 4.6→4.7 迁移：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html
- 4.5→4.6 迁移：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 迁移：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- 变更日志：https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- 发布说明：https://godotengine.org/releases/4.7/（4.6：https://godotengine.org/releases/4.6/）
- 版本与日期：https://github.com/godotengine/godot/releases
