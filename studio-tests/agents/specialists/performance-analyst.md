# Agent Test Spec: performance-analyst

## Agent Summary
领域：性能剖析、瓶颈识别、性能指标跟踪与优化建议。
不负责：实现优化（属于相应领域的程序员）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及剖析 / 瓶颈分析 / 性能指标）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型档位为 `inherit` — frontmatter `model:` 的值恰为 `inherit`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对实现任何优化拥有权限——明确自述仅为分析/建议角色

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “分析这份帧时间数据：CPU 14ms、GPU 8ms、物理 6ms、绘制调用 420、脚本 3ms。”
**Expected behavior:**
- 识别主要瓶颈：该帧受 CPU 限制（CPU 14ms vs GPU 8ms）——处于 16.67ms（60fps）一帧之内，但余量不足 3ms
- 拆解贡献者：物理（6ms，占 CPU 时间 43%）是头号元凶
- 如果预算上限更低（例如项目 `performance.draw_call_limit` 为 200 次绘制调用），则将绘制调用（420）标为次要关注项
- 产出按优先级排序的瓶颈报告：
  1. 物理 — 6ms，降低模拟频率或切换 broadphase 算法
  2. 绘制调用 — 420，实现批处理或 LOD
  3. 脚本 — 3ms，剖析热路径
- 不实现上述任何优化

### Case 2: 域外请求 — 正确重定向
**Input:** “实现批处理优化，把绘制调用从 420 降到 200 以下。”
**Expected behavior:**
- 不产出批处理实现代码
- 明确说明实现优化属于系统所有者——`technical-artist`，其渲染优化涵盖批处理（同时点名 `engine-programmer`，针对批处理所需的引擎级渲染改动，也是可以的）
- 将实现重定向给 `technical-artist`，将建议作为简报移交：目标（低于 200 次绘制调用）、预计影响与实现成本

### Case 3: 回归识别
**Input:** “上周的提交之后性能显著下降。帧时间从 10ms 变成 18ms。”
**Expected behavior:**
- 对比窗口前构建（约 10ms）与窗口后构建（约 18ms）的剖析；如果任一构建没有剖析数据，则请求或提议采集，而不是猜测
- 将 8ms 差异定位到增长的帧时间类别（玩法逻辑、渲染、物理、AI、音频），而不是仅凭提交信息或差异猜测原因
- 只有当剖析支持时才指出可疑提交或系统（例如提交范围内的构建剖析）——绝不只凭提交信息或差异
- 在“Regressions Since Last Report”下报告，附测得差异（10ms → 18ms）与受影响类别，并建议修复负责人，而不是实现修复

### Case 4: 建议与代码质量的取舍
**Input:** “脚本瓶颈最快的优化是内联所有调用并移除抽象层。”
**Expected behavior:**
- 揭示取舍：内联提高性能但降低可测试性，并违反要求公开方法可单元测试的编码规范
- 不推荐该优化而不注明代码质量代价
- 将取舍升级给其汇报对象 `technical-director` 决策
- 呈现带取舍的选项——例如只内联最热的 2–3 个方法，从而保持公开方法可测试——而不是全有或全无的单一建议

### Case 5: 上下文传递 — 项目性能预算
**Input:** 上下文中提供项目配置中的性能预算（`project.yaml` 中的 `performance.*`）：目标 60fps、帧预算 16.67ms、绘制调用上限 200、内存上限 512MB。请求：“评审当前构建的性能剖析。”
**Expected behavior:**
- 引用所提供上下文中的具体数值：16.67ms、200 次绘制调用、512MB
- 按其 Performance Report Format 明确将当前测量与每个阈值比较（帧时间与内存的 Budget / Actual / Status 表）
- 根据所提供数字将每个指标的 Status 标为 OK 或 OVER
- 不使用与上下文所提供不同的预算数值

---

## Protocol Compliance

- [ ] 保持在声明的领域内（剖析、分析、建议——而非实现）
- [ ] 将优化实现重定向给系统所有者（渲染优化如批处理交给 technical-artist，引擎系统交给 engine-programmer），而不是自行实现
- [ ] 按其 Performance Report Format 返回结构化发现（预算/实际/状态表、带影响与建议的顶级瓶颈、回归）
- [ ] 将代码质量取舍升级给 technical-director，而不是自行决定
- [ ] 应用所提供上下文的预算阈值，而不是假定的默认值
- [ ] 为每项推荐的优化指定应实现者（“recommend and assign”），而不是亲自实现
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 帧时间分析（Case 1）输出遵循代理的 Performance Report Format；在 `/perf-profile` 或 `/team-polish` 下运行时，报告写入 `production/polish/`
- 回归用例（Case 3）确认代理从跨构建的剖析定位原因，而不仅是测量症状或凭差异猜测
- 代码质量取舍（Case 4）验证代理不会推荐违反编码规范的优化而不标记冲突
