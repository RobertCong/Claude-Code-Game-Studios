# Skill Test Spec: /test-setup

## Skill Summary

`/test-setup [force]` 为已配置的引擎搭建测试框架。
它从 `project.yaml` 读取 `engine.name`（回退到
`technical-preferences.md`），当两者都未指明引擎时，以重定向到 `/setup-engine` 停止。
它检查现有基础设施，展示计划，
并在写入前询问 "May I create these files? I will not overwrite any test files that
already exist at these paths."。

它创建 `tests/README.md`、`tests/smoke/critical-paths.md`、
`production/qa/evidence/`、`.github/workflows/tests.yml`，以及引擎的测试
根目录：对 Godot 为 `tests/unit/` 与 `tests/integration/`（占位文件，且
没有运行器脚本——gdUnit4 的 `addons/gdUnit4/bin/GdUnitCmdTool.gd` 就是
运行器）；对 Unity 为 `Assets/Tests/EditMode/` 与 `Assets/Tests/PlayMode/` 及其 `.asmdef` 文件；
对 Unreal 为 `Source/<Module>/Private/Tests/`。当
基础设施已存在时，除非传入 `force`，否则提前退出，且
`force` 只创建缺失的文件——绝不覆盖。不适用任何总监闸门。
当脚手架就位后，结论为 COMPLETE。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 有 ≥2 个 phase 标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 在创建文件之前包含先询问后写入的用语（"May I create these files?"）
- [ ] 有下一步交接（Phase 6 Next steps：`/qa-plan sprint`、`/smoke-check`）

---

## Director Gate Checks

无。`/test-setup` 是脚手架工具。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，否则每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有 `project.local.yaml`。
规则见：`studio-tests/CLAUDE.md` §
Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — Godot 项目，搭建 GdUnit4 测试结构

**Fixture:**
- `project.yaml` 中有 `engine.name: Godot`
- `tests/` 不存在；未安装 `addons/gdUnit4/`；没有 CI 工作流
- 用户批准该计划

**Input:** `/test-setup`

**Expected behavior:**
1. Phase 1 报告 "Engine: Godot. Test directory: not found. CI workflow: not found."
2. Phase 2 展示计划：`tests/unit/`、`tests/integration/`、`tests/smoke/`、
   `tests/README.md`、`production/qa/evidence/`、`.github/workflows/tests.yml`——
   且没有运行器脚本
3. 技能询问 "May I create these files? I will not overwrite any test files that
   already exist at these paths."
4. 批准后：`tests/unit/.gdignore_placeholder`、
   `tests/integration/.gdignore_placeholder`、`tests/README.md`（含
   Installing GdUnit4 步骤与大写 U 的 `addons/gdUnit4/` 路径）、
   `tests/smoke/critical-paths.md`，以及 `production/qa/evidence/` 下的一个文件
5. `.github/workflows/tests.yml` 使用 `godot-gdunit-labs/gdUnit4-action@v1`，
   配置 `version: 'installed'` 与 `checks: write`
6. 文档化的测试命令与 `coding-standards.md` 的 CI 命令一致：
   `godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
7. Phase 6 总结；结论 COMPLETE

**Assertions:**
- [ ] 之后 `tests/unit/`、`tests/integration/`、`tests/smoke/` 与 `production/qa/evidence/` 都存在（各自含一个写入的文件）
- [ ] 不写入自定义运行器脚本（旧的手写运行器加载了 gdUnit4 从未发布的文件，导致每次运行都失败）
- [ ] 测试命令与 coding-standards.md 的 CI 命令一致
- [ ] 在创建任何文件之前请求批准
- [ ] 结论为 COMPLETE

---

### Case 2: Unity 项目 — 搭建带 asmdef 的 Unity Test Runner

**Fixture:**
- `project.yaml` 中有 `engine.name: Unity`
- `Packages/manifest.json` 列出 `com.unity.test-framework`
- 没有 `Assets/Tests/`；用户批准该计划

**Input:** `/test-setup`

**Expected behavior:**
1. 技能读取引擎 → Unity；Test Framework 包检查通过
2. 计划将单元测试与集成测试放在 `Assets/Tests/` 下——Unity
   只编译 `Assets/` 与 `Packages/`——而不是 `tests/unit/`
3. 技能生成 `Assets/Tests/EditMode/EditModeTests.asmdef`（仅 Editor）
   与 `Assets/Tests/PlayMode/PlayModeTests.asmdef`
4. `.github/workflows/tests.yml` 对 `editmode` 与
   `playmode` 运行 `game-ci/unity-test-runner@v4`，并注明 `UNITY_LICENSE` 密钥
5. README 的 Running Unity tests 说明给出两次运行——Edit Mode 输出到
   `test-results/editmode.xml`，Play Mode 输出到 `test-results/playmode.xml`
6. Phase 6 闸门说明指明 Unity 的测试根（`Assets/Tests/EditMode/` 与
   `Assets/Tests/PlayMode/`），而非 `tests/unit/` 与 `tests/integration/`
7. 写入之前请求批准；结论 COMPLETE

**Assertions:**
- [ ] 测试位于 `Assets/Tests/` 下，绝不在 `tests/` 或顶层 `Tests/`（两者都不被编译：0 个测试，"Passed"）
- [ ] 生成 `.asmdef` 文件
- [ ] EditMode 与 PlayMode 运行器配置存在，既在 CI 中，也作为两次本地运行且结果文件分开
- [ ] 闸门说明指明 Unity 测试根
- [ ] 结论为 COMPLETE

---

### Case 3: 基础设施已存在 — 提前退出，不重新初始化

**Fixture:**
- Godot 项目；`tests/unit/`、`tests/integration/`、`.github/workflows/tests.yml`
  与 `addons/gdUnit4/bin/GdUnitCmdTool.gd` 都存在
- 没有 `force` 参数

**Input:** `/test-setup`

**Expected behavior:**
1. Phase 1 报告 "Engine: Godot. Test directory: found. CI workflow: found."
2. 技能说明："Test infrastructure appears to be in place. Re-run with
   `/test-setup force` to regenerate. Proceeding will not overwrite existing test files."
3. 不请求计划批准，也不写入任何文件

**Assertions:**
- [ ] 基础设施存在时，技能不重新初始化
- [ ] 消息指向 `/test-setup force`
- [ ] 不修改任何现有文件，也不写入任何新文件

---

### Case 4: 未配置引擎 — 重定向到 /setup-engine

**Fixture:**
- `project.yaml` 没有 `engine.name`；`technical-preferences.md` 的 Engine 显示
  `[TO BE CONFIGURED]`

**Input:** `/test-setup`

**Expected behavior:**
1. 技能检查 `project.yaml`，再检查 `technical-preferences.md`——没有引擎
2. 技能停止："Engine not configured. Run `/setup-engine` first, then re-run `/test-setup`."
3. 不创建任何目录或文件

**Assertions:**
- [ ] 错误消息明确说明引擎未配置
- [ ] 建议下一步运行 `/setup-engine`
- [ ] 不调用任何写入工具
- [ ] 结论不是 COMPLETE（阻塞状态）

---

### Case 5: 总监闸门检查 — 无闸门；test-setup 是脚手架工具

**Fixture:**
- 引擎已配置，tests/ 不存在

**Input:** `/test-setup`

**Expected behavior:**
1. 技能搭建并写入所有测试框架文件
2. 不派发任何总监代理
3. 输出中不出现闸门 ID

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 不进行任何闸门检查，结论为 COMPLETE

---

## Protocol Compliance

- [ ] 在生成任何脚手架之前读取引擎（先 `project.yaml`，再 `technical-preferences.md`）
- [ ] 生成适配引擎的测试运行器配置与 CI 工作流（而非通用配置）
- [ ] 将单元测试与集成测试放入引擎的测试根（Godot 为 `tests/`，Unity 为 `Assets/Tests/`，Unreal 为 `Source/<Module>/Private/Tests/`）
- [ ] 创建 `production/qa/evidence/`——即 Phase 6 总结报告的路径
- [ ] 在创建文件之前请求批准
- [ ] 基础设施存在时提前退出；`force` 只创建缺失文件且绝不覆盖
- [ ] 脚手架就位时结论为 COMPLETE

---

## Coverage Notes

- Unreal Engine 测试脚手架（`Source/<Module>/Private/Tests/README.md`、自托管
  Windows CI 运行器）未单独做 fixture 测试。
- 部分脚手架下的 `force` 路径（只创建缺失文件）
  由协议合规覆盖，而非专门用例。
- tests/ 存在但来自不同引擎的情况（例如现在的 Godot 项目中有 Unity 测试）
  未测试。
- 没有 `com.unity.test-framework` 的 Unity 项目（技能要求添加已安装编辑器
  自带的版本，绝不复制数字）未测试。
