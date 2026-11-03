# Agent Test Spec: technical-artist

## Agent Summary
领域：着色器、VFX、渲染优化、美术流水线工具与视觉性能。
不负责：美术风格决策或调色板（art-director）、玩法代码（gameplay-programmer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及着色器 / VFX / 渲染）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对美术风格方向或玩法逻辑拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “为敌人死亡序列创建一个溶解效果着色器。”
**Expected behavior:**
- 在实现前提出方案（着色器结构、暴露的参数），并在写入前询问“May I write this to [filepath]?”
- 产出适配所配置引擎的着色器代码或 Shader Graph 节点规格（Godot 着色语言 / Unity Shader Graph / Unreal Material Blueprint）
- 将溶解驱动作为有文档的着色器参数暴露（例如 `dissolve_amount` uniform，0.0–1.0，对噪声纹理做阈值处理），并记录每个参数的视觉效果
- 说明该效果的性能预算（例如纹理采样数、着色器指令数）
- 将效果外观（边缘颜色、辉光）留给 art-director，而不是自行决定
- 输出感知引擎版本（若需要截止后 API 则检查版本参考）

### Case 2: 域外请求 — 正确重定向
**Input:** “定义美术圣经的调色板：用于 UI 的主色、辅色与强调色。”
**Expected behavior:**
- 不产出调色板决策或美术方向文档
- 明确说明美术风格决策属于 `art-director`
- 将请求重定向给 `art-director`
- 其提供的任何后续工作都是自身侧的实现——例如在 art-director 确定调色板后的调色或调色板 LUT 着色器——不包含它选定的调色板值

### Case 3: 性能警告 — GPU 粒子数
**Input:** “VFX 系统在爆炸池达到 50,000 个粒子时触发 GPU 粒子数警告。”
**Expected behavior:**
- 产出针对该具体警告的优化规格
- 提出具体策略：每个发射器的粒子预算上限、基于 LOD 的粒子削减、GPU 实例化，或对远景效果改用基于网格的 VFX
- 为爆炸效果设定明确的粒子数预算，并说明各策略的视觉质量代价（例如以有文档的质量档位表示）
- 将爆炸外观的任何可见变化标记给 art-director，而不是自行决定
- 不改变爆炸的玩法行为（任何玩法影响都委派给 gameplay-programmer）

### Case 4: 引擎版本兼容性
**Input:** “为水面着色器使用新的纹理采样器 API。”
**Expected behavior:**
- 在建议任何 API 前检查引擎版本参考（例如 `docs/engine-reference/godot/VERSION.md`）
- 标记所请求 API 是否为截止后（例如 Godot 4.4+ 纹理类型变更）
- 提供适用于项目锁定引擎版本的正确语法
- 若对截止后行为不确定，明确说明不确定性并指向已验证文档

### Case 5: 上下文传递 — 使用性能预算
**Input:** 上下文中提供性能预算：森林场景 2ms GPU 预算，每帧最多 200 次绘制调用。请求：“优化森林渲染系统。”
**Expected behavior:**
- 将所提供上下文中的 2ms GPU 预算与 200 次绘制调用上限视为其执行的预算——不替换为其他数值
- 提出渲染优化（LOD、遮挡剔除、批处理、图集），每项都与其目标预算挂钩（例如“批处理将绘制调用从 340 降至约 180，处于 200 上限内”）
- 指出任何以另一预算为代价帮助某一预算的优化（例如合并网格减少绘制调用，但可能破坏遮挡剔除并使 GPU 时间超过 2ms），而不是将其呈现为无代价收益
- 在实现前提出方案，并在写入文件前询问

---

## Protocol Compliance

- [ ] 保持在声明的领域内（着色器、VFX、渲染优化、美术流水线）
- [ ] 将美术风格决策重定向给 art-director
- [ ] 返回结构化发现（着色器代码、带指标的优化规格、节点图）
- [ ] 未经明确委派，不修改玩法代码文件
- [ ] 在建议截止后 API 前检查引擎版本参考
- [ ] 将每项拟议优化与其服务的分类预算挂钩（绘制调用、粒子数、着色器指令、纹理内存、过度绘制）

---

## Coverage Notes
- 溶解着色器（Case 1）应在 `production/qa/evidence/` 中包含视觉测试参考
- 引擎版本检查（Case 4）确认代理将 VERSION.md 视为权威
- 性能预算用例（Case 5）验证代理读取并应用所提供上下文中的数值
