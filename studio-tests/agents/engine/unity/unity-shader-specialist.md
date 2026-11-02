# Agent Test Spec: unity-shader-specialist

## Agent Summary
领域：Unity Shader Graph、自定义 HLSL、VFX Graph、URP/HDRP 管线定制以及后处理效果。
不负责：玩法代码、美术风格方向。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Shader Graph / HLSL / VFX Graph / URP / HDRP）
- [ ] `tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声明对玩法代码或美术方向的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "在 URP 中用 Shader Graph 为角色创建一个描边效果。"
**Expected behavior:**
- 生成 Shader Graph 节点搭建说明（通过顶点偏移的反向外壳，或屏幕空间的深度/法线边缘检测），按自身命名约定命名（例如 `SG_Char_Outline`），并将可复用逻辑放入 Sub Graph
- 停留在 Shader Graph 中，仅在 Shader Graph 无法实现该效果时才下探到自定义 HLSL；任何 HLSL 都保持 SRP Batcher 兼容（`UnityPerMaterial` CBUFFER）
- 若是屏幕空间方案，使用 URP `ScriptableRendererFeature` / `ScriptableRenderPass`，通过 RenderGraph API（`RecordRenderGraph`）录制，而不是已弃用的 `Execute` / CommandBuffer 路径 — 依据 `docs/engine-reference/unity/modules/rendering.md`
- 在未确认渲染管线前不生成 HDRP 专属节点

### Case 2: 领域外重定向
**Input:** "用代码实现角色血条 UI。"
**Expected behavior:**
- 不生成 UI 实现代码
- 明确说明 UI 实现属于 `ui-programmer`（或 `unity-ui-specialist`）
- 适当地重定向请求
- 它保留的任何部分仅是着色器驱动的效果（例如血条上的溶解或填充渐变）— 不编写任何血条 UI 代码

### Case 3: HDRP 自定义 Pass 实现描边
**Input:** "我们使用 HDRP，希望把描边做成后处理效果。"
**Expected behavior:**
- 生成其自身规范所指定的 HDRP 自定义 pass 模式：一个继承 `CustomPass` 的 C# 类，由 Custom Pass Volume 运行，绘制全屏边缘检测着色器并采样深度/法线缓冲
- 使用 `docs/engine-reference/unity/current-best-practices.md` 记录的 HDRP 覆写方法 — `Setup(ScriptableRenderContext, CommandBuffer)`、`Execute(CustomPassContext ctx)`、`Cleanup()` — 绝不使用 URP 的 `RecordRenderGraph`，并将其使用的任何其他 HDRP 成员（渲染目标辅助方法、`CustomPassContext` 字段）标记为未核实 — 除这三者外不凭记忆断言任何内容
- 说明 CustomPass 需要 HDRP 包，在 URP 中不可用
- 在提供 HDRP 专属代码前确认项目使用 HDRP

### Case 4: VFX Graph 性能 — 粒子预算
**Input:** "爆炸 VFX Graph 每次事件有 10,000 个粒子，同时生成 20 个爆炸会导致 GPU 帧尖峰。"
**Expected behavior:**
- 指出 GPU 粒子生成是成本驱动因素（同时 200,000 个粒子）
- 为每个效果设定粒子容量上限，并对照 VFX GPU 总预算 < 2ms 来确定其大小
- 池化爆炸 VFX 实例并通过事件触发，而不是为每次爆炸创建一个 graph
- 降低远处或屏幕外爆炸的成本（粒子 LOD、基于包围盒的剔除），并按画质档位缩放数量
- 避免任何将 GPU 粒子数据回读到 CPU 的修复方式
- 不改变玩法事件系统 — 提出 VFX 侧的预算解决方案

### Case 5: 上下文校验 — 渲染管线（URP 或 HDRP）
**Input:** 项目上下文：URP 渲染管线，目标平台为 PC 与 Nintendo Switch。请求："添加景深后处理。"
**Expected behavior:**
- 使用 URP Volume 框架：在 Volume Profile 中添加 `DepthOfField` 覆写，并按 `docs/engine-reference/unity/modules/rendering.md` 所示通过 `profile.TryGet<>()` 进行脚本访问
- 不使用 HDRP Volume 组件（例如参数名不同的 HDRP `DepthOfField`）
- 将其放在 Global Volume 上作为基准外观，或放在局部 Volume 上用于特定区域，并设置优先级与混合距离
- 按平台与画质档位控制该效果的启用 — 在 Switch 上降低或禁用 — 并使后处理保持在其 1-2ms 帧预算内

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Shader Graph、HLSL、VFX Graph、URP/HDRP 定制）
- [ ] 将玩法与 UI 代码重定向到合适的代理
- [ ] 返回结构化输出（节点图说明、HLSL 代码、CustomPass 模式）
- [ ] 区分 URP 与 HDRP 方案 — 绝不混用管线专属 API
- [ ] 对自定义 URP pass 使用 RenderGraph API，而非已弃用的 `Execute` / CommandBuffer 路径
- [ ] 生成的 VFX 优化不改变玩法行为
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 描边效果（Case 1）应配套 `production/qa/evidence/` 中的视觉截图测试
- HDRP CustomPass（Case 3）确认代理生成正确的 Unity 模式，而非通用的后处理做法
- 管线区分（Case 5）验证代理在没有上下文时绝不臆测渲染管线
