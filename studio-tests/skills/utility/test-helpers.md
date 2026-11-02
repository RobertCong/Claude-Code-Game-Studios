# Skill Test Spec: /test-helpers

## Skill Summary

`/test-helpers [system-name | all | scaffold]` 在引擎的 **helper root** 中生成测试辅助文件——这是其测试运行器唯一会编译这些文件的位置：Godot 上为 `tests/helpers/`，Unity 上为 `Assets/Tests/EditMode/Helpers/`（位于 `EditModeTests` 程序集内），Unreal 上为 `Source/<Module>/Private/Tests/Helpers/`。它会写入基础断言与工厂辅助文件（`scaffold`），并按系统写入一个 `[helper root]/[system]_factory.[ext]`，该文件依据系统的 GDD 构建（`[system-name]` 或 `all`）。无参数时，若不存在任何辅助文件则运行 `scaffold`，否则运行 `all`。它从 `project.yaml` 读取 `engine.name`、`engine.language` 和 `testing.framework`（回退到 `technical-preferences.md`），抽样最多 5 个现有测试文件以了解项目风格，并按小节 grep GDD（Formulas、Edge Cases、Detailed Rules/Design），而不是整篇读取。

辅助文件必须通过所配置框架的 API 进行断言——绝不能裸用 `assert()`——且不得继承框架的测试套件基类。若无法确认框架的断言 API，技能会明确说明，并且不生成任何辅助文件。它绝不覆盖已有辅助文件：会跳过并给出提示。展示文件列表后，它会询问 "May I write these helper files to `[helper root]`?"。不适用任何总监闸门。结论：创建辅助文件后为 COMPLETE。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需 fixture。

- [ ] 具备必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 在写入辅助文件前包含 "May I write" 协作协议用语
- [ ] 具备下一步交接（Next Steps：`/test-setup`、`/dev-story`、`/skill-test`）

---

## Director Gate Checks

无。`/test-helpers` 是一个脚手架工具。不适用任何总监闸门。

---

## Fixture Defaults

除非某个用例自身的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且不存在 `project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 为 Godot/GDScript 生成 Player 辅助文件

**Fixture:**
- `project.yaml` 中有 `engine.name: Godot`、`engine.language: GDScript`、
  `testing.framework: gdUnit4`；已安装 `addons/gdUnit4/`，因此可从项目中确认其
  断言 API
- 存在 `tests/unit/player/player_movement_test.gd`
- `design/gdd/player.md` 有 Formulas 小节，将生命值限定在 0–100
- `tests/helpers/` 中没有现有文件；用户批准写入

**Input:** `/test-helpers player`

**Expected behavior:**
1. 技能读取引擎、语言和框架；抽样现有测试文件
2. 技能 grep `design/gdd/player.md` 中的 Formulas / Edge Cases / Detailed
   Rules 标题，而不是整篇读取
3. 技能起草 `tests/helpers/player_factory.gd`：一个 `class_name` 辅助类，
   `extends RefCounted`，带默认参数的静态 `make_*` 工厂方法，
   将约束常量注释为来自 GDD，并写一行头部
   "Based on: design/gdd/player.md"
4. 每条断言都通过 gdUnit4 已确认的 API——不使用裸 `assert()`，
   不使用 `FAIL_IF` 占位符
5. 技能展示文件列表并询问 "May I write these helper files to `tests/helpers/`?"
6. 获批后写入文件；结论为 COMPLETE，随后给出按引擎的使用提示

**Assertions:**
- [ ] 生成的辅助文件是位于 `tests/helpers/player_factory.gd` 的 GDScript
- [ ] 约束常量可追溯到 GDD 的 Formulas 小节（不是凭空编造的值）
- [ ] 辅助类继承 `RefCounted`，而非测试套件基类，且不使用 Autoload/单例
- [ ] 文件中不出现裸 `assert()`，也不出现未解决的 `FAIL_IF`
- [ ] 结论为 COMPLETE

---

### Case 2: 引擎未配置 — 以 /setup-engine 停止

**Fixture:**
- `project.yaml` 没有 `engine` 块；`technical-preferences.md` 的 Engine
  显示 `[TO BE CONFIGURED]`

**Input:** `/test-helpers player`

**Expected behavior:**
1. 技能检查 `project.yaml`，再检查 `technical-preferences.md`——两者都没有引擎
2. 技能输出："Engine not configured. Run `/setup-engine` first."
3. 技能停止——不扫描测试、不起草、不写入

**Assertions:**
- [ ] 消息说明引擎未配置
- [ ] `/setup-engine` 被指明为前提条件
- [ ] 未调用任何写入工具
- [ ] 结论不是 COMPLETE（未创建任何内容）

---

### Case 3: 辅助文件已存在 — 跳过，绝不覆盖

**Fixture:**
- 按 Case 1 配置 Godot/GDScript/gdUnit4
- `tests/helpers/game_assertions.gd` 已存在，且包含手写新增内容
- `tests/helpers/game_factory.gd` 和 `tests/helpers/scene_runner_helper.gd`
  不存在；用户批准写入

**Input:** `/test-helpers scaffold`

**Expected behavior:**
1. 技能只起草 Godot 基础辅助文件——`game_assertions.gd`、
   `game_factory.gd` 和 `scene_runner_helper.gd`；在 `scaffold` 模式下
   不生成系统专属辅助文件
2. 技能询问 "May I write these helper files to `tests/helpers/`?"
3. 创建缺失的两个文件：`tests/helpers/game_factory.gd` 和
   `tests/helpers/scene_runner_helper.gd`
4. 对于已存在的文件，技能报告："Skipping `tests/helpers/game_assertions.gd`
   — already exists. Remove the file manually if you want it regenerated."
5. 结论为 COMPLETE

**Assertions:**
- [ ] `scaffold` 模式不生成任何 `[system]_factory` 辅助文件
- [ ] 现有 `game_assertions.gd` 逐字节保持不变
- [ ] 跳过消息指出已存在的文件以及如何重新生成它
- [ ] 只写入缺失的两个文件；结论为 COMPLETE

---

### Case 4: 框架断言 API 无法确认 — 不生成辅助文件

**Fixture:**
- `project.yaml` 有 `engine.name: Godot`、`engine.language: GDScript`；
  `testing.framework` 缺失，且 `technical-preferences.md` 未显示 Framework
- 没有 `addons/gdUnit4/`，也没有可用来学习该 API 的现有测试文件

**Input:** `/test-helpers scaffold`

**Expected behavior:**
1. 技能无法确认哪种断言调用会向运行器登记失败
2. 技能说明这一点，并且不生成辅助文件，而不是猜测 `assert_that`、
   `assert_eq`、`assert_true` 或裸 `assert()` 之类的形式
3. 不询问 "May I write"，也不写入任何内容

**Assertions:**
- [ ] 技能说明无法确认框架的断言 API
- [ ] 不写入任何辅助文件
- [ ] 不将任何猜测的断言形式（也不将 `FAIL_IF` 占位符）呈现为可写入状态
- [ ] 结论不是 COMPLETE

---

### Case 5: 总监闸门检查 — 无闸门；test-helpers 是脚手架工具

**Fixture:**
- 按 Case 1 配置引擎与框架，没有现有辅助文件

**Input:** `/test-helpers player`

**Expected behavior:**
1. 技能生成并写入辅助文件
2. 不生成任何总监代理
3. 输出中不出现闸门 ID

**Assertions:**
- [ ] 未调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 在任何闸门检查之外结论为 COMPLETE

---

### Case 6: Unity — 辅助文件位于引擎的测试根目录下

**Fixture:**
- `project.yaml` 有 `engine.name: Unity`、`engine.language: C#`、
  `testing.framework: NUnit`；`Packages/manifest.json` 中有
  `com.unity.test-framework`，因此可从已安装包中确认 NUnit 的断言 API
- `/test-setup` 已创建 `Assets/Tests/EditMode/EditModeTests.asmdef`
- 尚不存在辅助文件；用户批准写入

**Input:** `/test-helpers scaffold`

**Expected behavior:**
1. 辅助文件根目录为 `Assets/Tests/EditMode/Helpers/`——位于
   `EditModeTests` 程序集内，Unity 会在此编译它
2. 技能为该文件夹起草 `GameAssertions.cs` 和 `GameFactory.cs`，
   通过 NUnit 的 `Assert` 进行断言
3. 技能询问 "May I write these helper files to `Assets/Tests/EditMode/Helpers/`?"
4. 获批后写入文件；使用提示说明要引用测试程序集；
   结论为 COMPLETE

**Assertions:**
- [ ] 辅助文件写入 `Assets/Tests/EditMode/Helpers/` 下
- [ ] 不在 `tests/helpers/` 下写入任何内容——该路径在 `Assets/` 之外，Unity 永远不会编译它
- [ ] "May I write" 询问中指明 Unity 辅助文件根目录
- [ ] 结论为 COMPLETE

---

## Protocol Compliance

- [ ] 在生成任何辅助文件之前读取引擎、语言和测试框架
- [ ] 仅将辅助文件写入引擎的 helper root（`tests/helpers/`、`Assets/Tests/EditMode/Helpers/` 或 `Source/<Module>/Private/Tests/Helpers/`）
- [ ] 为系统辅助文件按小节 grep GDD（包括 `## 4. Formulas` 这类带编号的标题）；常量可追溯到其 Formulas 小节
- [ ] Godot 信号断言将标志保存在 lambda 会修改的 Dictionary 中，并连接变参 lambda（`func(...args)`）——捕获的 `bool` 在调用方中永远不会改变，而单参数 lambda 会在任何其他信号上失败
- [ ] 仅通过所配置的框架进行断言——绝不裸用 `assert()`——当无法确认该 API 时不生成任何内容
- [ ] 辅助文件绝不继承框架的测试套件基类
- [ ] 绝不覆盖已有辅助文件；改为报告跳过
- [ ] 在创建任何文件之前询问 "May I write"
- [ ] 写入辅助文件后结论为 COMPLETE

---

## Coverage Notes

- `all` 模式（每个有测试文件的系统各一个工厂）的用例未单独测试，按其系统逐个遵循 Case 1。
- Unreal 辅助文件生成（`Source/<Module>/Private/Tests/Helpers/`）未单独测试，按其自身 helper root 遵循 Case 6 的模式。也未单独测试 PlayMode 测试同样需要这些辅助文件的 Unity 项目（技能在创建共享 `TestHelpers.asmdef` 前会先询问）。
- 未测试请求的系统没有 GDD 的情况；技能未定义该路径。
