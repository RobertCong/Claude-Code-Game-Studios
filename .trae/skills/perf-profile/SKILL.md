---
name: perf-profile
description: "性能剖析 —— 发现瓶颈、对照预算进行测量、产出按优先级排序的优化建议。"
argument-hint: "[system-name or 'full']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(bash "*/.claude/skills/perf-profile/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash "*/.claude/skills/perf-profile/../../hooks/yaml-helper.sh" get_effective_yaml_key *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys performance.enforce,automation,workflow`

以上已解析 —— 直接使用。没有对应配置块 → 使用
`.claude/docs/config-resolution.md` 中的默认值。

# 性能剖析

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

## 输入不足 —— 在产出任何报告之前先检查

**如果本技能所需的输入不存在，答案就是"无法运行" —— 而不是一份填好的报告。** 先检查，
若检查不通过就停止。

1. 列出本技能读取的输入（数据文件、既往报告、性能分析器输出、测试结果、注册表、源代码）。
2. 对每一项记录 `FOUND` 或 `ABSENT` —— 而不是"假定存在"。
3. 如果某个章节所需的任何输入为 ABSENT，该章节即为
   **`NOT ASSESSED — NO DATA`**。不要估算它，不要从相邻产出物推断，也不要留下一个应由
   下一位模板读者填写的必填单元格。
4. 如果**所有**必需输入都为 ABSENT，停止并把 **`NOT ASSESSED — NO DATA`** 作为整体结论
   报告，指明缺失了什么，以及由哪个技能产出它。

**`NOT ASSESSED` 的结论也是一种成功。** 在没有数据时，这是对"数据说明了什么？"这一问题
正确且有价值的回答。它防止的失败模式很具体：一个结论枚举中没有"无法运行"状态的报告会产生
**虚假的干净通过** —— 例如在没有资源、也没有标准的项目上返回 COMPLIANT 的资源审计，或在
零性能分析数据、从未设定预算的情况下报告"相对 16.67ms 预算 >99% 余量"的性能剖析。

**没有证据绝不等同于证明不存在。** 一次扫描因为没有文件可扫而找不到匹配，并没有验证任何
东西。要说明两者中发生的是哪一种 —— 读者无法从绿色结果中分辨。

---

## Phase 0: 解析预算强制级别

`performance.enforce` 决定本次运行中预算违规*意味着什么*。它不改变测量哪些预算 ——
`performance.target_framerate`、`frame_budget_ms`、`draw_call_limit` 与 `memory_ceiling_mb`
在每一层级都以相同方式剖析：

| 取值 | 对本次剖析发现的影响 |
|-------|-----------------------------------|
| `warn`（默认） | 违规作为发现报告。它们不会阻塞；CI 会记录它们但不报失败。 |
| `block` | 违规即为**阻塞项**。在报告中明确说明这一点 —— `block` 项目把超预算系统视为发布阻断项，`/gate-check` 会因此让打磨质量闸门 FAIL。 |
| `off` | 预算仅供参考。仍报告测得的值，但不要把违规作为发现或修复建议提出。 |

只有 `warn`、`block` 与 `off` 会被识别。任何其他取值都要向用户指出，并回退到 `warn`，而不是
猜测。

> 该值可在本地覆盖（`/settings --local performance.enforce=block`），因此请使用上方解析出的
> 配置块，而不是直接读取 `project.yaml` —— 队友更严格的本地设置只应在其自己的机器上生效。

## Phase 1: 确定范围

读取参数：

- 系统名称 → 聚焦剖析该特定系统
- `full` → 对所有系统运行全面剖析

---

## Phase 2: 加载性能预算

**先从配置中读取已提交的预算** —— 它们是项目对自身承诺的记录，设计文档只是后备来源，
而非来源本身：

```bash
bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" get_effective_yaml_key performance.target_framerate
bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" get_effective_yaml_key performance.frame_budget_ms
bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" get_effective_yaml_key performance.draw_call_limit
bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" get_effective_yaml_key performance.memory_ceiling_mb
```

把每一行当作独立命令运行，每次调用一个键：该辅助脚本会自行切换到项目根目录，因此在子文件夹
中启动会话时也能正常工作，而本技能只预批准这种形式（`source` 或 `cd ... &&` 包装每次都会
询问用户）。输出为空意味着该预算未设置。

> **从 `project.yaml` 解析这些预算，不要从散文描述中解析。** 上方的 Phase 0 声明这四项预算
> "在每一层级都以相同方式剖析"。如果改为从设计文档或 CLAUDE.md 读取预算，那么用户在
> `project.yaml` 中设置的 `performance.target_framerate: 60` 就会被忽略。

然后，对配置未承载的任何内容，回退到设计文档或 CLAUDE.md：

- 目标帧率（例如 60fps = 16.67ms 帧预算）
- 内存预算（总量与按系统）
- 加载时间目标
- Draw call 预算
- 网络带宽限制（若有多人玩法）

**没有已提交预算的指标是 `NOT ASSESSED`，不是通过。** 不要对照模板中的 `[16.67ms]` 占位符
进行测量 —— 未设置的预算不等于已达到的预算，而对照一个没人选定的数字报告余量，正是本技能
自身开头所警告的那种虚构。

---

## Phase 3: 分析代码库

**CPU 剖析目标：**
- `_process()` / `Update()` / `Tick()` 函数 —— 全部列出并估算开销
- 对大集合的嵌套循环
- 热路径中的字符串操作
- 每帧代码中的内存分配模式
- 对游戏实体未优化的搜索/排序
- 每帧执行的高开销物理查询（射线检测、重叠检测）

**内存剖析目标：**
- 大型数据结构及其增长模式
- 纹理/资源内存占用估算
- 对象池与实例化/销毁模式的对比
- 泄漏的引用（本应被释放却未被释放的对象）
- 缓存大小与淘汰策略

**渲染目标（如适用）：**
- Draw call 估算
- 重叠透明对象造成的过度绘制
- 着色器复杂度
- 未优化的粒子系统
- 缺失的 LOD 或遮挡剔除

**I/O 目标：**
- 存档/读档性能
- 资源加载模式（同步 vs 异步）
- 网络消息频率与大小

---

## Phase 4: 生成性能剖析报告

**把报告写入 `production/polish/[scope]-report-[date].md`**，并按协作协议先行询问：*"我可以
把这份性能剖析报告写入 `production/polish/[scope]-report-[date].md` 吗？"* 若目录不存在则创建。

> **要指明目标位置 —— 不要只是把模板渲染到对话中。** 只存在于对话记录里的剖析结果会在会话
> 结束的瞬间消失，也无法比较两次运行。`production/polish/` 与 `/team-polish` 写入的位置
> 相同，这是有意为之：无论经由哪条路径生成的剖析结果，都应归入同一处，否则本技能存在所
> 为了实现的对比就无法进行。
>
> 如果某个 `NOT ASSESSED` 章节保留到了报告中，就把它保留在写入的文件里。一份缺口在落盘途中
> 被编辑掉的剖析结果，日后读起来会像是完整的测量。


```markdown
## Performance Profile: [System or Full]
Generated: [Date]

### Performance Budgets
| Metric | Budget | Estimated Current | Status |
|--------|--------|-------------------|--------|
| Frame time | [16.67ms] | [estimate] | [OK/WARNING/OVER/NOT ASSESSED] |
| Memory | [target] | [estimate] | [OK/WARNING/OVER/NOT ASSESSED] |
| Load time | [target] | [estimate] | [OK/WARNING/OVER/NOT ASSESSED] |
| Draw calls | [target] | [estimate] | [OK/WARNING/OVER/NOT ASSESSED] |

### Hotspots Identified
| # | Location | Issue | Estimated Impact | Fix Effort |
|---|----------|-------|------------------|------------|

### Optimization Recommendations (Priority Order)
1. **[Title]** — [Description]
   - Location: [file:line]
   - Expected gain: [estimate]
   - Risk: [Low/Med/High]
   - Approach: [How to implement]

### Quick Wins (< 1 hour each)
- [Simple optimization 1]

### Requires Investigation
- [Area that needs actual runtime profiling to confirm impact]
```

输出报告并附上摘要：前 3 个热点、针对每个已设置预算估算的余量 —— 对没有预算的指标给出
`no budget set — headroom not assessed` —— 以及建议的后续操作。

---

## Phase 5: 范围与时间线决策

仅当任何热点的 Fix Effort 被评为 M 或 L 时，才启用此阶段。

呈现工作量显著的项目，并请用户逐一选择：

- **A) 实施优化**（现在着手修复或安排日程 —— 在 `workflow: minimal` 下没有冲刺，则加入
  简报的构建顺序）
- **B) 缩减功能范围**（运行 `/scope-check [feature]` 分析取舍）
- **C) 接受性能损失并推迟到打磨阶段**（记录为已知问题）
- **D) 上报给 technical-director 做架构决策**（运行 `/architecture-decision`）

如果有多个项目被推迟到打磨阶段（选择 C），将它们记录在 `### Deferred to Polish` 下。

---

## 结论（Verdict）

每一次产出了报告的运行 —— 无论 Phase 5 是否执行 —— 都以如下内容收尾：
Verdict：**COMPLETE** —— 性能剖析已生成（若写入获批，已保存至
`production/polish/[scope]-report-[date].md`）。唯一的另一种结果是上方
`NOT ASSESSED — NO DATA` 路径。

---

## Phase 6: 后续步骤

- 若瓶颈需要架构变更：运行 `/architecture-decision`。
- 若需要缩减范围：运行 `/scope-check [feature]`。
- 若要安排优化工作：运行 `/sprint-plan update`（在 `workflow: minimal` 下没有冲刺，改为把
  它们加入简报的构建顺序）。

### 规则
- 绝不在测量之前优化 —— 对性能的直觉并不可靠
- 建议必须包含预估影响 ——"让它更快"不可执行
- 在目标硬件上剖析，而不只是在开发机上
- 静态分析（本技能）识别候选对象；运行时剖析负责确认
