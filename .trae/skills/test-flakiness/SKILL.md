---
name: test-flakiness
description: "从 CI 日志中发现不稳定测试 —— 汇总通过率、识别间歇性失败、建议隔离。在多次运行之后使用。"
argument-hint: "[ci-log-path | scan | registry]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(ls -t *), Bash(bash "*/.claude/skills/test-flakiness/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用与
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 总是询问 · guided 仅重大事项 · autonomous 记录后继续；
`automation_always_ask` 类别总是询问）。

# 不稳定测试检测

不稳定测试（flaky test）是指在没有代码变更的情况下有时通过、有时失败的测试。不稳定测试在某
些方面比没有测试更糟 —— 它们训练团队忽视红色的 CI 运行，从而掩盖真实的失败。本技能会识别
这类测试、解释可能的原因，并建议对每一个进行隔离还是修复。

**输出：** 更新后的 `tests/regression-suite.md` 隔离章节 + 可选的
`production/qa/flakiness-report-[date].md`

**何时运行：**
- 打磨阶段（测试已运行多次；统计信号可靠）
- 当开发者开始把 CI 失败当作"大概是不稳定"而忽略时
- 在 `/regression-suite` 识别出需要诊断的已隔离测试之后

---

## 1. 解析参数

**模式：**
- `/test-flakiness [ci-log-path]` —— 分析指定的 CI 运行日志文件
- `/test-flakiness scan` —— 扫描 `.github/` 或标准日志输出目录中所有可用的 CI 日志
- `/test-flakiness registry` —— 读取现有的 regression-suite.md 隔离章节，并为已知的不稳定
  测试提供整改指导
- 无参数 —— 自动检测：如果 CI 日志可访问则运行 `scan`，否则运行 `registry`

---

## 2. 定位 CI 日志数据

### 选项 A —— GitHub Actions（首选）

检查测试结果产出物：
```bash
ls -t .github/ 2>/dev/null
ls -t test-results/ 2>/dev/null
```

对于 Godot 项目：GdUnit4 输出的 XML 结果与 JUnit 格式兼容，位于 `reports/`（其默认报告文件夹，
`res://reports/`）下。检查 `reports/` 以及你保存运行结果的任何 `test-results/` 目录中的
`.xml` 文件。

对于 Unity 项目：game-ci 测试运行器默认把 NUnit XML 输出到 `test-results/`。

对于 Unreal 项目：自动化日志位于 `Saved/Logs/`。grep `Result={Success}` 与 `Result={Fail}`
—— 每个测试都会打印 `Test Completed. Result={<status>}`
（`docs/engine-reference/unreal/current-best-practices.md`，"Command Line"）。

### 选项 B —— 本地日志文件

如果提供了路径参数，直接读取该文件。

### 选项 C —— 没有可用的日志数据

如果未找到日志：
> "未找到 CI 日志数据。要检测不稳定测试，本技能需要多次运行的测试结果历史。可选方案：
> 1. 至少运行测试套件 3 次并收集输出日志
> 2. 检查 CI 流水线输出，并把一份日志保存到 `test-results/`
> 3. 运行 `/test-flakiness registry`，查看 `tests/regression-suite.md` 中已标记为不稳定的
>    测试"

停止并询问用户选择哪一方案。

---

## 3. 解析测试结果

对找到的每个 CI 日志或结果文件，解析：

**JUnit XML 格式**（GdUnit4）：
- grep `<testcase name=` 获取测试名称
- grep `<failure` 或 `<error` 识别失败
- 解析 `classname` 与 `name` 属性，得到完整的测试标识符

**NUnit XML 格式**（Unity —— `/smoke-check` 读取其 `<test-run>` 元素的那种文件）：
- 每个测试是一个 `<test-case` 元素；其 `fullname` 属性是标识符
- 其 `result` 属性为 `Passed`、`Failed`、`Inconclusive` 或 `Skipped`
  （`docs/engine-reference/unity/current-best-practices.md`，"Command Line"）；
  只有 `Passed` 与 `Failed` 进入历史

**纯文本日志**：
- grep 通过/失败模式：
  - Godot：测试名附近的 `PASSED` / `FAILED`
  - Unreal：`Result={Success}` / `Result={Fail}`
  - Unity：`Test passed` / `Test failed`

构建一张表：`test_id → [run1_result, run2_result, run3_result, ...]`

---

## 4. 识别不稳定测试

如果某个测试在结果历史中、在运行之间没有任何代码变更的情况下同时出现 PASS 与 FAIL 两种结果，
它就是**不稳定的**。

不稳定程度阈值：
- **高不稳定**：在 >25% 的运行中失败 —— 立即隔离
- **中等不稳定**：在 5–25% 的运行中失败 —— 尽快调查并修复
- **低/疑似不稳定**：在 1–5% 的运行中失败 —— 持续监控；可能确实是罕见失败

**运行次数少于 3 次时，无论失败率如何，每一项发现都只能算*疑似*。** 两次运行中失败一次会被
读作 50%，但那只是一个数据点：不要隔离它，将其标记为疑似，并询问是否有更多运行数据。
上面的分级以及隔离操作从 3 次运行起才适用。

对每个不稳定测试，分类其可能原因：

### 原因分类

| 原因 | 症状 | 修复方向 |
|-------|----------|---------------|
| **时序 / 异步** | 在等待信号或计时器之后失败；通过率与系统负载相关 | 增加显式 await/同步；避免基于时间的延迟 |
| **顺序依赖** | 在特定其他测试之后运行时失败；单独运行时通过 | 加入正确的 setup/teardown；确保测试隔离 |
| **随机种子** | 间歇性失败且无规律；涉及 RNG | 传入显式种子；不要在测试中使用 `randf()` |
| **资源泄漏** | 在测试运行后期更频繁失败 | 修复 teardown 中的清理；检查孤立节点（Godot）或对象释放（Unity） |
| **外部状态** | 当先前测试留下的文件、场景或全局存在时失败 | 让测试与文件系统隔离；使用内存中的 mock |
| **浮点** | 在 `== 0.5` 这类比较上失败 | 使用 epsilon 比较（`is_equal_approx`、`Assert.AreApproximately`） |
| **场景/预制体加载竞态** | 场景尚未就绪时失败 | 实例化后等待一帧；使用 `await get_tree().process_frame` |

使用 Grep 检查测试文件中的时序调用、randf、全局状态访问或浮点相等比较，以缩小原因范围。

---

## 5. 建议操作

对每个不稳定测试：

**隔离（高不稳定）：**
> "立即隔离此测试。使用引擎自带的机制跳过它，将其记录到 `tests/regression-suite.md` 的
> 隔离章节，并在移除隔离之前修复根因。"

跳过机制，按引擎 —— 只说明项目所用引擎的那一种：
- **Godot（gdUnit4），GDScript**：在测试函数上使用跳过参数 ——
  `func test_x(_do_skip := true, _skip_reason := "flaky: [cause]")`。gdUnit4 会在
  `addons/gdUnit4/src/core/GdUnitTestSuiteScanner.gd` 中读取参数名 `do_skip` 与
  `skip_reason`（允许前导 `_`），以 gdUnit4 6.2.2 为准；请针对已安装版本在该文件中确认。
- **Godot（gdUnit4），C#**：**NOT SOURCEABLE** —— gdUnit4 的 C# 测试特性不在
  `addons/gdUnit4/` 源码中，`docs/engine-reference/godot/` 也未覆盖它们。把它记录到隔离
  章节，并询问用户他们的 C# 测试是如何跳过的；不要臆造特性。
- **Unity（NUnit）**：`[Ignore("flaky: [cause]")]` —— NUnit 3 要求提供原因
- **Unreal**：**NOT SOURCEABLE** —— `docs/engine-reference/unreal/` 未记录任何跳过自动化测试
  的方法。把它记录到隔离章节，并询问用户他们的 CI 是如何排除测试的；不要臆造标志。

**调查并尽快修复（中等）：**
> "此测试间歇性不可靠。根因看起来是 [cause]。建议修复：[specific fix based on cause
> classification]。暂不隔离 —— 直接修复该测试。"

**监控（低/疑似）：**
> "此测试显示疑似不稳定。在隔离之前先收集更多运行数据。在回归套件中将其标记为
> 'suspected'。"

---

## 6. 生成报告

### 会话内摘要

```
## Flakiness Detection Results

**Runs analysed**: [N]
**Tests tracked**: [N]

### Flaky Tests Found

| Test | System | Fail Rate | Confidence | Likely Cause | Recommendation |
|------|--------|-----------|------------|--------------|----------------|
| [test_name] | [system] | [N]% | confirmed | Timing | Quarantine + fix async |
| [test_name] | [system] | [N]% | confirmed | Float comparison | Fix: use epsilon compare |
| [test_name] | [system] | [N]% | suspected (fewer than 3 runs) | Order dependency | Collect more runs before acting |

### Clean Tests (no flakiness detected)

[N] tests ran across [N] runs with consistent results — no flakiness detected.

### Data Limitations

[Note if fewer than 5 runs were available — fewer runs = less statistical confidence]
```

---

## 7. 更新回归套件 + 可选报告文件

询问："我可以把发现的不稳定测试更新到 `tests/regression-suite.md` 的隔离章节吗？"

若同意：使用 `Edit` 把条目追加到 Quarantined Tests 表格。绝不删除现有隔离条目 —— 只新增。

（另行）询问："我可以把完整的不稳定报告写入
`production/qa/flakiness-report-[date].md` 吗？"

完整报告包含逐个测试的分析、原因细节以及针对具体引擎的修复片段。

写入之后：

- 对每个已隔离测试："添加对应引擎的跳过注解，在 CI 中禁用此测试。根因修复后再重新启用。"
- 对可修复的测试："`[test]` 的修复很简单 —— 把第 [N] 行的相等比较改为使用 `is_equal_approx`。"
- 总结："一旦所有隔离注解都已应用，CI 应当运行成功。请在发布质量闸门之前安排修复 [N] 个
  已隔离测试的工作。"

---

## 协作协议

- **绝不删除测试文件** —— 隔离意味着添加注解并登记，而不是移除
- **统计置信度很重要** —— 运行次数 < 3 时，把发现标记为"suspected"而非"confirmed"；询问是否
  有更多运行数据
- **修复始终是目标** —— 隔离是临时的；即使建议隔离，也要给出修复方向
- **写入前先询问** —— 回归套件更新与报告文件都需要明确批准。写入后：Verdict：**COMPLETE**
  —— 不稳定报告已写入。被拒绝时：Verdict：**BLOCKED** —— 用户拒绝写入。
- **CI 中的不稳定是团队问题** —— 清晰地呈现清单与建议操作；不要在团队不知情的情况下悄悄
  隔离
