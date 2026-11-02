# Godot 渲染 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

### 4.7 变更
- **`AreaLight3D`**：实时矩形区域光
- 在 Windows、macOS、iOS、visionOS 和 Linux（Wayland）上支持 **HDR 输出**
- **`DrawableTexture2D`**：在纹理上绘制的简单 API（4.7 发行说明：https://godotengine.org/releases/4.7/）
- **`CanvasItem` 线条**：没有抗锯齿羽化，因此线条看起来更细
- **`LinearToSRGB` 视觉着色器**在 Forward+、Mobile 下不再钳制到 `[0.0, 1.0]`
- **`get_format()`** 从 `ImageTexture` / `PortableCompressedTexture2D` 移至 `Texture2D`
- **`rendering/reflections/sky_reflections/roughness_layers`** 默认值 `7` → `8`（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）

### 4.6 变更
- **Windows 上默认渲染后端为 D3D12**（原为 Vulkan）
- **辉光在色调映射之前处理**（原为之后）——使用屏幕混合模式
- **AgX 色调映射器**：新增白点和对比度控制
- **SSR 重做**：更好的真实感、视觉稳定性和性能

### 4.5 变更
- **着色器烘焙器**：预编译着色器以缩短启动时间
- **SMAA 1x**：新的抗锯齿选项（比 FXAA 更锐利，比 TAA 更廉价）
- **模板缓冲区支持**：实现选择性几何遮罩/传送门效果
- **弯折法线贴图**：编码在法线贴图中的方向性遮蔽
- **高光遮蔽**：环境光遮蔽现在能正确影响反射

### 4.4 变更
- **`RenderingDevice.draw_list_begin`**：移除了多个参数；新增可选 `breadcrumb`
- **`Shader` 默认纹理方法**：`set_default_texture_parameter()` 接受且
  `get_default_texture_parameter()` 返回 `Texture`，而不是 `Texture2D`（着色
  语言的 `sampler2D` / `texture()` 未变）
- **粒子 `.restart()`**：新增可选 `keep_seed` 参数

### 4.3 变更（已在训练数据中）
- **Compositor 节点**：用于后处理链的 `Compositor` + `CompositorEffect`

## 当前 API 模式

### 后处理（4.3+）
```gdscript
# Use Compositor node — NOT manual viewport shader chains
# Add Compositor as child of WorldEnvironment or Camera3D
# Create CompositorEffect resources for each post-process step
```

### 抗锯齿选项（4.6）
```
Project Settings → Rendering → Anti Aliasing:
- MSAA 2D/3D: Hardware MSAA (quality but expensive)
- Screen Space AA: FXAA (fast, blurry) or SMAA (sharp, moderate cost)  # SMAA new in 4.5
- TAA: Temporal (best quality, ghosting on fast motion)
```

### 渲染后端选择（4.6）
```
Project Settings → Rendering → Renderer:
- Forward+ (default): Full featured, desktop-focused
- Mobile: Optimized for mobile/low-end, limited features
- Compatibility: OpenGL 3.3 / WebGL 2, broadest hardware support

Windows default backend: D3D12 (was Vulkan pre-4.6)
```

## 常见错误
- 假设 Windows 上默认后端是 Vulkan（自 4.6 起为 D3D12）
- 使用手动的视口链而不是 Compositor 进行后处理
- 在 `Shader.set_default_texture_parameter()` /
  `get_default_texture_parameter()` 中传入或期望 `Texture2D`（自 4.4 起类型为 `Texture`——着色
  语言的 `sampler2D` / `texture()` 未变）
- 对具有大量着色器变体的项目不使用着色器烘焙器
