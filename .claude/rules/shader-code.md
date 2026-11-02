---
paths:
  - "assets/shaders/**"
  - "**/*.gdshader"
  - "Assets/**/*.{shader,hlsl,cginc,compute,shadergraph}"
  - "Shaders/**"
  - "**/*.{usf,ush}"
---

# 着色器代码标准

所有引擎中的所有着色器文件都必须遵循这些标准，以维持视觉质量、性能和跨平台兼容性。

## 命名约定
- 文件命名：`[type]_[category]_[name].[ext]`
  - `spatial_env_water.gdshader`（Godot）
  - `SG_Env_Water`（Unity Shader Graph）
  - `M_Env_Water`（Unreal 材质）
- 使用能表明材质用途的描述性名称
- 按引擎的着色器类型加前缀——Godot `spatial_`、`canvas_`、`particles_`、`post_`；Unity `SG_`（Shader Graph）；Unreal `M_`、`MI_`（实例）、`MF_`（函数）

## 代码质量
- 所有 uniform/参数必须有描述性名称和合适的 hint
- 将相关参数分组（Godot：`group_uniforms`，Unity：`[Header]`，Unreal：Category）
- 为非显而易见的计算加注释（尤其是数学密集的部分）
- 不使用魔法数字——使用具名常量或文档化的 uniform 值
- 在每个着色器文件顶部包含作者和用途注释

## 性能要求
- 为每个着色器记录目标平台和复杂度预算
- 使用合适的精度：移动端不需要全精度时使用 `half`/`mediump`
- 尽量减少片元着色器中的纹理采样
- 避免片元着色器中的动态分支——使用 `step()`、`smoothstep()` 和 `mix()`（Godot、GLSL）或 `lerp()`（HLSL：Unity、Unreal）
- 循环内不得读取纹理
- 模糊效果使用两遍法（先水平后垂直）

## 跨平台
- 在最低配置的目标硬件上测试着色器
- 为较低质量档位提供回退/简化版本
- 记录着色器面向的渲染管线（Forward/Deferred、URP/HDRP、Forward+/Mobile/Compatibility）
- 不要在同一目录混用不同渲染管线的着色器

## 变体管理
- 尽量减少着色器变体——每个变体都是一个单独编译的着色器
- 记录所有关键字/变体及其用途
- 尽可能使用功能剥离以减小构建体积
- 记录并监控每个着色器的变体总数
