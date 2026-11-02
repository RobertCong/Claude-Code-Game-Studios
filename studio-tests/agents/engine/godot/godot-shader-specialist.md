# Agent Test Spec: godot-shader-specialist

## Agent Summary
领域：Godot 着色语言（GLSL 衍生）、可视化着色器（VisualShader 图）、材质设置、粒子着色器以及后处理效果。
不负责：玩法代码、美术风格方向。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Godot 着色语言 / 材质 / 后处理）
- [ ] `tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义引用 `docs/engine-reference/godot/VERSION.md` 作为 Godot 着色器 API 变更的权威来源

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "在 Godot 中为敌人死亡写一个溶解效果着色器。"
**Expected behavior:**
- 生成有效的 Godot 着色语言代码（不是 HLSL，也不是直接使用 GLSL）
- 视情况使用 `shader_type spatial;` 或 `canvas_item`
- 定义 `uniform float dissolve_amount : hint_range(0.0, 1.0);`
- 采样噪声纹理以确定逐像素的溶解阈值
- 对低于阈值的像素使用 `discard;`
- 可选地使用 emission 在溶解边界附近添加边缘辉光
- 代码在 Godot 着色语言中语法正确

### Case 2: HLSL 重定向
**Input:** "为这个溶解效果写一个 HLSL 计算着色器。"
**Expected behavior:**
- 不生成 HLSL 代码
- 说明 Godot 材质使用 Godot 自有着色语言（`.gdshader`，GLSL 衍生）而非 HLSL
- 把 HLSL 意图转换为等效的 `.gdshader` 方案（噪声阈值、`discard`、溶解边缘的 emission）
- 若真实意图确实是计算着色器，则指出计算着色器是独立的底层路径（RenderingDevice；在 Compatibility 渲染器上不可用），并引入 godot-gdextension-specialist 处理计算着色器卸载

### Case 3: 截止后 API 变更 — 着色器纹理类型（Godot 4.4）
**Input:** "在着色器中使用 `texture()` 配合 sampler2D 来采样噪声纹理。"
**Expected behavior:**
- 在编写着色器前检查版本参考资料（先 `VERSION.md`，再 `breaking-changes.md` 与 `modules/rendering.md`）
- 识别 4.4 变更的实际范围：引擎侧的着色器纹理参数/返回类型从 `Texture2D` 改为 `Texture` — 涉及处理着色器纹理的脚本与引擎 API 代码，而非着色语言语法
- 使用 `uniform sampler2D noise_texture;` 配合 `texture(noise_texture, UV)` — 其自身模式所用的形式；参考资料未记录着色语言采样语法有变更
- 不因 4.4 条目而为 4.4–4.6 杜撰变更后的采样语法，也不重写 `sampler2D` / `texture()`

### Case 4: 片元着色器 LOD 策略
**Input:** "水面片元着色器有 8 次纹理采样，在中端硬件上造成 GPU 瓶颈。"
**Expected behavior:**
- 指出逐片元的纹理采样次数是主要成本驱动因素
- 提出 LOD 策略：
  - 对远处水面使用简化 LOD 材质以随距离减少采样次数，而不是在片元着色器中做逐像素的距离分支
  - 将不需要逐像素计算的 UV/滚动计算移入顶点着色器，并通过 `varying` 传递
  - 确保水面纹理已生成 mipmap（例如 `filter_linear_mipmap`），使远处采样读取更小的 mip 层级
- 提供实现该 LOD 方案的着色器代码修改
- 不改变水体系统的玩法行为

### Case 5: 上下文校验 — Godot 4.6 辉光重做
**Input:** 引擎版本上下文：Godot 4.6。请求："给场景添加一个泛光/辉光后处理效果。"
**Expected behavior:**
- 引用 VERSION.md 的说明：Godot 4.6 包含辉光重做
- 由于 `VERSION.md` 将 `Installed at pin time` 记录为 NOT DETERMINED，在针对 4.6 辉光行为调参前先询问已安装的编辑器版本
- 基于 `WorldEnvironment` 节点的 `Environment` 资源给出辉光配置指导
- 说明文档记录的 4.6 变更：辉光现在在色调映射之前处理（此前在之后），并采用屏幕混合 — 因此在更早版本上调整好的辉光强度/混合看起来会不同，可能需要重新调整
- 不杜撰 `breaking-changes.md` 与 `modules/rendering.md` 未记录的辉光属性重命名或移除
- 标记任何因截止后时间点而可能使 LLM 训练数据信息有误的属性

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Godot 着色语言、材质、VFX 着色器、后处理）
- [ ] 将玩法代码请求重定向到 gameplay-programmer
- [ ] 将材质与后处理着色器写为 `.gdshader`（Godot 着色语言）— 绝不使用 HLSL
- [ ] 检查引擎版本参考资料中的截止后着色器 API 变更（4.4 纹理类型、4.6 辉光重做）
- [ ] 返回结构化输出（附带 uniform 说明的着色器代码、带性能理由的 LOD 策略）
- [ ] 将任何截止后 API 的使用标记为需要核实
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 溶解着色器（Case 1）应配套 `production/qa/evidence/` 中的视觉测试截图
- 纹理类型用例（Case 3）确认代理在应用截止后变更前会先读懂其实际范围，而不是重写该变更并未触及的语法
- 辉光重做（Case 5）是 Godot 4.6 专属测试 — 验证代理会应用截止后的迁移说明
