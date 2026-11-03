# /gate-check —— 第 3 节：运行质量闸门校验

> 属于 `/gate-check` 的一部分。`SKILL.md` 会指明何时读取本文件；它
> 解析出的设置及其后续各标题下的规则在此仍然适用。

## 3. 运行质量闸门校验

**本文件包含：**

- 产出物检查
- 质量检查
- 交叉引用检查

**在运行产出物检查之前**，若 `docs/consistency-failures.md` 存在，请先读取它。
提取 Domain 与目标阶段匹配的条目（例如，若检查 Systems Design → Technical Setup，
就提取 Economy、Combat 或任何 GDD 领域的条目；
若检查 Technical Setup → Pre-Production，就提取 Architecture、Engine 的条目）。
把这些作为上下文携带——目标领域中反复出现的冲突模式，值得在那些特定检查中
加大审查力度。

对目标闸门中的每一项：

### 产出物检查

**确定性地解析存在性与计数——不要靠打开文件去判断存在什么：**

```
Bash: bash .trae/scripts/artifact-check.sh --phase [source-phase]
```

传入被推进*离开*的阶段（它的步骤就是必须完成的工作）：Systems Design → Technical Setup 闸门传 `systems-design`，
Pre-Production → Production 传 `pre-production`，以此类推。

在 `workflow: minimal` 下，还要运行
`bash .trae/scripts/artifact-check.sh --path minimal`：简报与用户故事
位于该路径上，而不属于任何阶段，它的 `game-brief` 与 `create-stories`
行就是该层级的底线。

它会读取 `workflow-catalog.yaml`——其中已经编码了每个步骤的 `glob`、
`pattern`、`min_count` 和 `any_of`——并按步骤报告：

| 状态 | 含义 |
|---|---|
| `PRESENT` | glob 匹配、满足 `min_count`、在指定处找到了 `pattern` |
| `ABSENT` | 没有任何匹配 |
| `SHORT` | 有匹配但少于 `min_count`（会给出 `count=` 和 `min=`） |
| `PATTERN_MISS` | 文件存在，但没有任何一个包含所需标记 |
| `NO_CHECK` | 该步骤未声明产出物——**无法从磁盘检测** |

它只输出观察结果，绝不给结论：**你**负责应用第 2 节中的工作流层级
以及必需/可选划分。一个 `ABSENT` 的必需产出物在 `full` 下是阻塞项，
在 `minimal` 下则常常不是；脚本并不知道这一点，也不做这个判断。

**`NO_CHECK` 不等于 `PRESENT`。** 表头会在任何行之前打印 `NO_CHECK:` 计数，
正是为了防止这一点被略过。那些步骤是*被扫描过*，而不是*被满足*——
把每一项带入第 4 节（协作式评估）并询问，或标记为 MANUAL CHECK NEEDED。
一个因为清单大部分内容无法检测而报告 PASS 的闸门，正是这个计数要
防止的失败模式。

**存在不等于充分。** 脚本区分不了真实文档和模板骨架。因此：对结论
实际依赖的任何产出物，都要抽查阅读，确认它有真实内容——这与下文
`gdd-structure-check.sh` 步骤使用的升级规则相同。不要抽查结论
并不依赖的产出物。

> **冒烟报告始终是结论所依赖的产出物——抽查它是强制性的，不是可选的。**
> 在 `minimal` 下，它常常是*唯一*的必需产出物，因此整个闸门都压在
> 一个既非由任何流程生成、也无人核实过的文件上。把它的声明与仓库对照检查，
> 凡是代码树与之矛盾的都要提出来：
>
> - 它报告自动化套件通过 → 引擎的测试根下必须确实存在
>   测试文件，且项目必须配置了运行器。“24 passed, 0 failed”
>   出现在该根下没有任何测试文件的仓库里——Godot 的 `tests/unit/` 与
>   `tests/integration/`、Unity 的 `Assets/Tests/`、
>   Unreal 的 `Source/<Module>/Private/Tests/`——且没有运行器，这是一个
>   发现项，而不是证据。
> - 它把某条关键路径标记为 PASS → 该路径的代码必须存在于代码根中。
>   在没有相关代码的情况下对“结算会结束本局”标 PASS，是一个发现项。
> - 它没有日期，或早于最近一次触及代码根的提交 → 要指出来；
>   过期的冒烟报告描述的是一个已不存在的构建。
>
> 在要求该产出物的同一层级报告矛盾：冒烟检查为必需时是
> 阻塞项，为推荐时是 CONCERNS。仅仅“文件存在 + 对结论行做一次 grep”
> 会让一份伪造的报告蒙混过关。

对于代码检查，核实目录结构与文件计数。

**Systems Design → Technical Setup 闸门——跨 GDD 评审检查**：
使用 `Glob('design/gdd/gdd-cross-review-*.md')` 查找 `/review-all-gdds` 报告。
如果没有文件匹配：在 `full` 下把“跨 GDD 评审报告存在”这一产出物标记为
**FAIL** 并醒目呈现（“`design/gdd/` 中未找到 `/review-all-gdds` 报告。
请在推进到 Technical Setup 之前运行 `/review-all-gdds`。”）；在
`standard` 下该报告是推荐项，因此标记为 **CONCERNS**，而不是阻塞项；在
`minimal` 下此闸门不适用（见闸门文件）。如果找到文件，请读取并
检查结论行：FAIL 结论意味着跨 GDD 一致性检查未通过，
必须在推进前解决。NOT ASSESSED 结论意味着该评审无法比较 GDD，
因此它在此不能证明任何事项：把该项标记为本闸门的
NOT ASSESSED，绝不标记为通过。
若报告的 `Focus:` 行只点名了一轮检查（`consistency` 或
`design-theory` 运行），也按同样方式处理：另一轮从未运行。

### 质量检查
- 对于测试检查：如果配置了测试运行器，则通过 `Bash` 运行测试套件。
  **如果未配置运行器，那就是 `NOT ASSESSED`，不是静默跳过**——参见
  结论一节中的触发条件。没跑测试的闸门没发现测试失败，这与
  通过并不相同。
  测试失败对结论的影响取决于 **Phase 1 中解析出的** `testing.strict` 块
  （`resolve_config` 会把 `project.local.yaml` 合并到
  `project.yaml` 之上；直接读取文件会丢掉本地覆盖），并按测试类型区分：
  - **Logic**——单元级失败（Godot 的 `tests/unit/`、Unity 的 Edit Mode），
    由 `testing.strict.logic` 控制。
  - **Integration**——Godot 的 `tests/integration/`、Unity 的 Play Mode 中的失败，
    由 `testing.strict.integration` 控制。在 Unreal 中，一个根目录
    （`Source/<Module>/Private/Tests/`）同时容纳两者，因此按失败所属
    用户故事的 Type 分类，若未知则采用两个级别中更严格的一个。
  - 对每种类型：从该块中取 `testing.strict.<type>`；仅当其值为 `true` 或 `false`
    （不区分大小写）时才使用。如果该键缺失、为空或持有任何其他值，
    则把 `testing.strict` 当作普通布尔值读取（旧版单值形式）；
    如果它同样缺失或无效，则默认为 `true`（Logic 与 Integration 默认都严格——
    行为与此设置出现之前一致）。把任何无法识别的值呈现给用户。
  - 在严格（`true`）闸门级别下，该类型的失败是**阻塞项**
    （结论 FAIL）。在建议性（`false`）级别下，它们是**关注项**
    （结论最低为 CONCERNS，而非 FAIL）——把它们列在“建议”下，而不是
    “阻塞项”下。
- 对于设计评审检查，**确定性地**收集章节存在情况——不要
  为了统计标题而读取 GDD：

  ```
  Bash: bash .trae/scripts/gdd-structure-check.sh
  ```

  它会为每个 GDD 打印一对 `PRESENT:` / `ABSENT:`，外加一行 `PLACEHOLDER:`
  列出仅含 `[To be designed]` 的现有章节（存在但未撰写：
  适用 `5-verdict.md` 关于模板占位符的规则），并且
  已经接受把 `## Detailed Design` 视为满足 `Detailed Rules` 要求。
  它只报告存在性，不做 REQUIRED/ADVISORY 判断。

  然后对每个 GDD 应用其**有效层级**（见下方的按系统解析）到这些
  列表中——`full` 下全部 8 个章节，`standard` 下 5 个标准章节
  （外加条件性 Formulas）。缺失*必需*章节会阻塞；在有效层级下
  可选的章节缺失则属于建议性。报告为 PRESENT 的章节如果只是空标题，
  仍可能评审不合格——对结论实际依赖的任何章节都要抽查阅读。按章节阅读 GDD：
  用 Grep 工具（模式 `^#`，content 模式）找到标题，再用 offset
  和 limit 读取相应区间。
- 对于性能检查：从 `project.yaml` 读取预算（`performance.target_framerate`、
  `frame_budget_ms`、`draw_call_limit`、`memory_ceiling_mb`）
  （否则读 technical-preferences.md），并与 `tests/performance/` 中的任何性能剖析数据
  或最近的 `/perf-profile` 输出进行对比。违规*意味着*什么
  由 `performance.enforce` 决定，取自 Phase 1 解析出的块（它可在本地覆盖，
  因此不要为这一项直接读文件）：
  - `warn`（默认）——违规是 **CONCERNS**，绝不是阻塞项。
  - `block`——从 Polish 闸门起，违规是**阻塞项**。
  - `off`——预算是参考信息；不要把违规呈现在结论中。

  只识别这三个值。把其他任何值呈现给用户，并
  回退到 `warn`，而不是猜测。
- 对于本地化检查：在**代码根**中 `Grep` 硬编码字符串（按 `.trae/docs/code-root-resolution.md` 解析）。**如果代码根无法解析，报告 `NOT ASSESSED — code root unresolved`，而不是零命中。**

### 交叉引用检查
- 将 `design/gdd/` 文档与**代码根**中的实现进行对比
- 检查架构文档中引用的每个系统都有对应代码
- 核实冲刺计划引用的是真实的工作项

---
