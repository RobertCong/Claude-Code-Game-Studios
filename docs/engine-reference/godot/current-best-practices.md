# Godot — 当前最佳实践

最后核对：2026-10-17（4.7 各节）；2026-02-12（其余部分） | Engine: Godot 4.7

自模型训练数据（约 4.3）以来**新增或变更**的实践。
本文件补充（而非取代）代理的内置知识。

## GDScript（4.5+）

- **可变参数（variadic arguments）**：函数可以接受任意数量的参数。剩余参数写作
  `...name`，放在最后，类型为 `Array` 或保持未标注类型——`values: Variant...` 与
  `...values: Array[int]` 都无法解析
  ```gdscript
  func log_values(prefix: String, ...values: Array) -> void:
      for v in values:
          print(prefix, ": ", v)
  ```

- **Lambda 按值捕获局部变量**（所有 Godot 4 版本）：局部变量在 lambda 创建时被
  捕获一次，且 lambda 不能重新赋值外层局部变量——`var hit := false` /
  `func(): hit = true` 会让调用方的 `hit` 仍为 false。通过引用类型（Dictionary、
  Array 或对象）共享状态并修改其内容。剩余参数在 lambda 中同样可用，因此
  `func(...args)` 可以连接到带任意数量参数的信号（在 4.6.1 上观察到；零参数信号上的
  单参数 lambda 会报错 "Method expected 1 argument(s), but called with 0"）
  ```gdscript
  var state := {"emitted": false}
  some_signal.connect(func(...args): state.emitted = true)
  ```

- **抽象类与方法**：使用 `@abstract` 强制继承
  ```gdscript
  @abstract
  class_name BaseEnemy extends CharacterBody3D

  # No body: "a newline or a semicolon is expected after the function header".
  # Subclasses MUST override it.
  @abstract func get_attack_pattern() -> Array[Attack]
  ```

- **脚本回溯（script backtracing）**：即使在 Release 构建中也能获得详细的调用栈

## GDScript（4.7）

- **类型化方法的覆盖会继承其返回类型**，因此需要显式的 `return` 语句；迁移指南给出的
  修复方式是 `return null`
- **写入紧凑数组（packed array）的单个元素不再调用该属性的 setter。** 对
  `PackedInt32Array`（等）属性的 setter 不再在 `arr[i] = v` 时执行；在必须触发
  setter 的地方，请赋整个数组

## 物理（4.7）

- **Jolt `WorldBoundaryShape3D`**：`plane.d` 的符号现在与 Godot Physics 一致，与
  4.6 相比是翻转的。在 4.6 上创建的场景中将其取负
- **Jolt `SoftBody3D`**：整个软体的质量为 1 kg（原为每个点 1 kg），且
  `linear_stiffness` 的应用方式不同；请重新调整 `linear_stiffness` 和
  `damping_coefficient`。`Area3D` 现在会报告 `SoftBody3D` 重叠
- **音频区域（audio areas）**：`AudioStreamPlayer2D`/`3D` 上的 `area_mask` 默认值
  为 `0`（原为层 `1`）；在使用 `audio_bus_override` 区域的地方，请将其设为层 `1`

## 物理（4.6）

- **Jolt Physics 是新项目的默认 3D 引擎**
  - 相比 GodotPhysics3D 具有更好的确定性与稳定性
  - 部分 HingeJoint3D 属性（`damp`）只在 GodotPhysics 下有效
  - 切换：Project Settings → Physics → 3D → Physics Engine
  - 2D 物理不变（仍为 Godot Physics 2D）

## 渲染（4.7）

- **`AreaLight3D`**：实时的矩形区域光，替代自发光材质加全局光照的方案
- 在 Windows、macOS、iOS、visionOS 和 Linux（Wayland）上支持 **HDR 输出**
- **`DrawableTexture2D`**：用于在纹理上绘制的更简单 API
- **`CanvasItem` 线条绘制时不再带抗锯齿羽化**，因此看起来比 4.6 更细；依赖旧外观的
  线条需要加宽
- `LinearToSRGB` 视觉着色器节点在 Forward+ 与 Mobile 下不再钳制到 `[0.0, 1.0]`

## 渲染（4.6）

- **Windows 上默认后端为 D3D12**（原为 Vulkan）——以获得更好的驱动兼容性
- **辉光（Glow）现在在色调映射之前处理**，使用屏幕混合模式——现有的辉光设置可能
  看起来不同
- **SSR 大幅重做**——在真实感、稳定性和性能方面有显著提升
- **AgX 色调映射器**——新增白点和对比度控制

## 渲染（4.5）

- **着色器烘焙器（Shader Baker）**：预编译着色器以消除启动卡顿
- **SMAA 1x**：新的 AA 选项——比 FXAA 更锐利，比 TAA 更廉价
- **模板缓冲区（Stencil buffer）**：可用于高级遮罩/传送门效果
- **弯折法线贴图（Bent normal maps）**：法线贴图中的方向性遮蔽
- **高光遮蔽（Specular occlusion）**：环境光遮蔽现在会影响反射

## 无障碍（4.5+）

- **屏幕阅读器支持**：Control 节点通过 AccessKit 与无障碍工具集成
- **实时翻译预览**：直接在编辑器中测试不同语言的 GUI 布局
- **FoldableContainer**：新的手风琴式 UI 节点，用于可折叠区段
- **递归禁用 Control**：用单个属性禁用整个节点层级的鼠标/焦点交互

## 动画（4.5+）

- **BoneConstraint3D**：通过修改器将骨骼绑定到其他骨骼
  - AimModifier3D、CopyTransformModifier3D、ConvertTransformModifier3D

## 动画（4.7）

- **`Tween.tween_await()`** 会暂停补间动画，直到发出信号
- **`LookAtModifier3D.relative`** 默认值为 `false`（原为 `true`）

## 动画（4.6）

- **IK 系统完全恢复**：为 3D 重新引入完整的反向运动学
  - 可用修改器：CCDIK、FABRIK、Jacobian IK、Spline IK、TwoBoneIK
  - 通过 `SkeletonModifier3D` 节点应用

## 资源（4.5+）

- **`duplicate_deep()`**：对嵌套资源树进行显式深复制
  - 为向后兼容保留了旧的 `duplicate()` 行为
  - 当需要嵌套资源的逐实例副本时，使用 `duplicate_deep()`

## 导航（4.5+）

- **专用的 2D 导航服务器**：不再通过 3D NavigationServer 代理
  - 减小仅 2D 游戏的导出二进制体积

## UI（4.6）

- **双焦点系统**：鼠标/触摸焦点现在与键盘/手柄焦点分离
  - 视觉反馈因输入方式而异
  - 设计自定义焦点行为时需考虑这一点

## UI 与输入（4.7）

- **`Control.offset_transform_*`**（`offset_transform_enabled`、
  `offset_transform_position`、`offset_transform_rotation`、
  `offset_transform_scale`、…）：一种容器不会重置的视觉变换，
  用于容器内的悬停与按下动画
- **`RichTextLabel` 图片可以相对于字体设定尺寸**
  （`[img height=1em]…[/img]`）；`add_image()` / `update_image()` 接受
  `width_unit` / `height_unit`（`RichTextLabel.ImageUnit`）替代
  `*_in_percent` 布尔值
- **`VirtualJoystick` 节点**用于触摸控制，提供 Fixed、Dynamic 和
  Following 模式
- **鼠标和键盘事件会报告 `InputEvent.DEVICE_ID_MOUSE` /
  `DEVICE_ID_KEYBOARD`**，而不是设备 `0`；请检查事件类型，而不是
  `device == 0`
- **新项目默认拉伸**：`display/window/stretch/mode` 为
  `canvas_items`，`aspect` 为 `expand`。在 4.7 之前创建的项目保留
  其设置

## 编辑器工作流（4.7）

- **Asset Store 取代 Asset Library**：编辑器工作区为
  "Asset Store"（原为 "AssetLib"），诸如 gdUnit4 的插件从那里安装
- 方法、信号和属性名称默认以等宽字体显示
  （关闭 "Use Monospace Font for Editor Symbols" 可禁用）

## 编辑器工作流（4.6）

- 灵活的停靠面板拖放，带蓝色轮廓预览（包括底部面板）
- 大多数面板支持浮动窗口（调试器除外）
- 新的键盘快捷键：Alt+O（Output）、Alt+S（Shader）
- 导出变量自动生成：将资源从 FileSystem 拖入脚本编辑器
- 启用 "Live Preview" 时，在快速打开对话框中实时预览
- 新的 "Select Mode"（v 键）可防止误变换；旧模式更名为 "Transform Mode"（q 键）

## 工具链

- **ripgrep 没有 `gdscript` 类型**：`*.gd` 注册在 `gap`（GAP 编程语言）下。
  `rg --type gdscript` 是硬错误——搜索永远不会执行。
  始终使用 `rg --glob "*.gd"`（shell）或 `glob: "*.gd"`（Grep 工具）来过滤 GDScript 文件。

## 命令行——测试与解析检查

来自 Godot 命令行教程的参数：`--headless`（无头显示和一个虚拟音频驱动，"useful for servers and with `--script`"）、`--path <dir>`（包含 `project.godot` 的目录）、`-s`/`--script <script>`、`-d`/`--debug`（本地 stdout 调试器）、`--remote-debug <protocol>://<host>[:<port>]`、`--import`（启动编辑器，等待导入，然后退出）、`--quit-after <n>`（迭代次数）、`--export-debug <preset>`（隐含 `--import`）以及 `--check-only`（配合 `--script` 解析错误并退出）。编辑器默认不在 `PATH` 中：在 Windows 和 Linux 上，通过相对或绝对路径运行二进制文件；在 macOS 上，运行 bundle 内的 `Godot.app/Contents/MacOS/Godot`。

gdUnit4 的 runner 是 `res://addons/gdUnit4/bin/GdUnitCmdTool.gd`；`-a <dir|suite>` 添加套件，报告默认输出到 `res://reports/`（`-rd` 可修改），文档化的退出码为 0（全部通过）、100（失败）和 101（警告）。
框架使用的命令：
`godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`。

gdUnit4 6.2.x 在其 README 中列出兼容 Godot 4.5 至 4.7.1
（https://github.com/godot-gdunit-labs/gdUnit4#compatibility-overview，核对于
2026-10-17）；4.7.2 尚未列在其中，但 gdUnit4 6.2.2 可在其上运行。在
Windows 上，2026-10-17，Godot 4.7.2 和 4.7.1 在上述命令下得到相同的退出码：
0 通过、100 失败、101 孤儿节点、105 解析错误、零测试时为 0 并输出 `No test cases
found`，以及首次导入之前为 1。

在 Godot 4.6.1 搭配 gdUnit4 6.1.3 上观察到，并在 4.7.2 搭配
6.2.2 上再次观察到这些退出码——文档中未记载：
- 101 也是所有测试通过但某个测试泄漏了孤儿节点时的退出码；
  105 表示测试脚本无法解析；103 表示 gdUnit4 拒绝以无头模式运行
  （缺少 `--ignoreHeadlessMode`）。104 是 gdUnit4 拒绝低于 4.3 的 Godot——在
  固定版本上无法复现。
- 零测试时，runner 会输出 `No test cases found` 并以 0 退出。
- 没有 `--remote-debug tcp://127.0.0.1:0` 时，脚本错误会打开 `-d`
  调试器，运行会停在 `debug>` 提示符处；带上它时，每次运行都会打印两行
  关于远程端口的 `ERROR:`，这属于预期。
- 全新克隆没有 `.godot/` 类缓存：请先运行
  `godot --headless --path . --import`，否则 `GdUnitCmdTool.gd` 无法
  加载，运行会在什么都没执行的情况下以 1 退出。
- 在 4.7.1 和 4.7.2（Windows，2026-10-17）上，全新项目的首次 `--import`
  在 17 次运行中有 3 次在退出时崩溃（139，段错误），但写入的 `.godot/`
  文件与干净运行相同；再次运行则以 0 退出。
  4.6.1 在 4 次运行中未崩溃。
- `--check-only` 配合 `-s <file>` 对引用了自动加载（autoload）的有效代码会以 1 退出
  （`Identifier not found`），而 `--import` / `--quit-after` 在解析错误时以 0 退出
  ——两者都不是解析检查。框架的解析检查是
  `godot --headless --path . -s res://.trae/scripts/godot-parse-check.gd -- res://<file>.gd …`
  （脚本无法加载时退出 1）。
- 在 Windows 上，编辑器带引号的完整路径（`"C:/Program Files/Godot/…exe"`）
  可从 Git Bash 运行，且 stdout 和退出码保持不变。

来源：
- 命令行教程：https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- gdUnit4 命令行工具：https://godot-gdunit-labs.github.io/gdUnit4/latest/advanced_testing/cmd/
- gdUnit4 发布版本：https://github.com/godot-gdunit-labs/gdUnit4/releases
- Godot 4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html
- Godot 4.7 发行说明：https://godotengine.org/releases/4.7/
- GDScript 参考、lambda 函数与剩余参数：https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html

## 平台（4.5+）

- **visionOS 导出**：自开源以来首个新平台（窗口化应用模式）
- **SDL3 手柄驱动**：更好的跨平台手柄支持
- **Android**：边到边显示、摄像头画面访问、16KB 页面支持（Android 15+）
- **Linux**：Wayland 子窗口支持，实现多窗口能力
