# /smoke-check — Phase 2: 运行自动化测试

> 属于 `/smoke-check`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 2: 运行自动化测试

**本文件包含：**

- 优先使用 `commands.test`
- Godot 4
- Unity：先 Edit Mode，再以第二次运行执行 Play Mode
- Unreal Engine：先构建，按操作系统给出命令，macOS
- 未知引擎 / 未配置
- 此处测试运行器不可用
- 构建检查（仅 WAIVED 路径）

**当 `project.yaml` 中设置了 `commands.test` 时，运行它** — 这是项目自己的测试命令，即 `/setup-engine` 写入并由 CI 运行的那条。仅在 `commands.test` 缺失时才使用下面按引擎的默认值，并在报告中说明你运行的是两者中的哪一个。用超时包装它（`timeout 900 …`）：**超时（退出码 124）是闸门失败，绝不是通过** — 运行从未完成，什么都没验证。macOS 没有 `timeout`：使用 Homebrew `coreutils` 的 `gtimeout 900 …`（同样退出码 124），或者，若什么都没安装，使用 `perl -e 'alarm shift; exec @ARGV' 900 …`，它在时间耗尽时以 142 退出 — 同样视为失败。然后根据引擎读取结果。在每种引擎上，都有一种结果看起来像成功其实不是；下面逐一指出。

**Godot 4** — 先检查 `addons/gdUnit4/bin/GdUnitCmdTool.gd` 是否存在 — 文件夹名是**大写 U**。若不存在，报告 `NOT ASSESSED — gdUnit4 not installed at addons/gdUnit4/` 而不是运行任何东西。然后执行导入，无论你运行的是 `commands.test` 还是默认命令。新克隆的项目没有 `.godot/` 类缓存，缺少它 gdUnit4 的运行器不会加载；而一个早于新 `class_name` 的缓存会以 105 让有效代码失败。无变化时导入只需几秒（下面的 `godot` 即 Phase 1 第 3 步解析出的可执行文件）：
```bash
godot --headless --path . --import
godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode 2>&1
```
gdUnit4 的退出码给出结论（在 6.1.3 和 6.2.2 上运行过）：
- **0** — 所有测试通过：PASS。**但零测试的退出码 0 不是通过：** gdUnit4 会中止却仍以 0 退出，因此若输出显示 `No test cases found`，结论为 `NOT ASSESSED — no tests found`。
- **101** — 所有测试通过但有测试泄漏了节点（孤儿节点）：PASS WITH WARNINGS，从输出中指出孤儿节点数。不是失败。
- **100** — 有测试失败：FAIL。**105** — 测试脚本无法解析：FAIL。
- **103** — gdUnit4 拒绝无头运行（缺少 `--ignoreHeadlessMode`）；**104** — Godot 低于 4.3：`NOT ASSESSED`，并附上该原因。
- **1** — Godot 自身错误：`GdUnitCmdTool.gd` 未加载（`Failed to load script`），因此没有测试运行。通常是跳过了上面的导入；在导入之后，退出码 1 为 FAIL。

每次运行开头都会有两行关于远程端口的 `ERROR:`（`127.0.0.1:0`）— 那是 `--remote-debug` 标志在起作用，不是失败。绝不要去掉该标志：没有它，脚本错误会打开 Godot 的交互式调试器，运行会卡在 `debug>` 提示符直到超时。

**Unity：**
Unity **可以**通过 shell 无头运行测试。不要跳到读取产出物。

先确认 Unity Test Framework 已安装。没有它的项目不会干净地失败 — 它会**挂起**直到被杀死：
```bash
grep -q 'com.unity.test-framework' Packages/manifest.json && echo present || echo ABSENT
```
若为 ABSENT，报告 `NOT ASSESSED — Unity Test Framework not installed` 并给出一行修复方法（将 `com.unity.test-framework` 添加到 `Packages/manifest.json`）。**不要退而读取过期的产出物** — 把一个不清楚年代的 XML 报告为通过，比没有闸门更糟。

若存在，默认命令为（**编辑器**可执行文件 — `PATH` 上的 `Unity` 可能是 Unity 的独立 CLI）。先删除旧结果文件，无论你运行的是 `commands.test` 还是此默认命令：
```bash
rm -f test-results/editmode.xml
timeout 900 "<Unity editor>" -batchmode -runTests -projectPath . -testPlatform EditMode -testResults test-results/editmode.xml
```
所有测试通过时退出 0，失败时退出 2。**退出码 1 或 3 为 FAIL**：1 表示项目未编译通过（编辑器日志中有 `error CS…` 行），3 表示运行本身失败；4（未知的 `-testPlatform`）或任何其他非零退出码也是 FAIL。编译错误不会写结果文件 — 这就是先删除旧文件的原因：若保留，上一次运行的通过会被读成本次运行的。任何退出之后，若没有结果文件即为 FAIL。解析结果文件中的 `<test-run>` 元素以获取 `testcasecount`、`passed` 和 `failed`。**`testcasecount="0"` 是 NOT ASSESSED，绝不是通过**：`Assets/` 之外的测试永远不会被编译，而 Unity 随后会在零测试上报告 `result="Passed"` 并以 0 退出。

**Play Mode 是第二次运行。** `-testPlatform EditMode` — 此默认值，以及 `/setup-engine` 写入的 `commands.test` — 从不运行 `/test-setup` 在 `Assets/Tests/PlayMode/` 下搭建的集成测试。当该文件夹中有测试文件，且你运行的命令尚未传入 `-testPlatform PlayMode` 时，以同样方式运行 Play Mode，写入各自的结果文件，并按同样的规则读取：
```bash
rm -f test-results/playmode.xml
timeout 900 "<Unity editor>" -batchmode -runTests -projectPath . -testPlatform PlayMode -testResults test-results/playmode.xml
```
每个平台各占一行报告 — `EditMode: PASS (12/12)`、`PlayMode: FAIL (1 failure)`。无法完成的 Play Mode 运行按名称报告，`PlayMode: NOT RUN — [reason]`：Edit Mode 的结果不覆盖那些测试，因此它无法让自动化测试行成为 PASS。

**Unreal Engine** — 先构建编辑器目标，无论你随后运行 `commands.test` 还是默认命令。`Binaries/` 不会被提交，没有已构建的游戏模块，编辑器会在运行任何测试之前以 "The game module could not be found" 退出，退出码 1。构建是增量的 — 无变化时只需几秒；构建失败即为 FAIL。

**用 `uname -s` 为这台机器选择命令**：`Linux` → Linux，`Darwin` → macOS，其他（`MINGW*`、`MSYS*`、`CYGWIN*`）→ Windows。下面的 Windows 形式在 UE 5.7 上运行过；Linux 和 macOS 形式来自 Epic 的文档 — `docs/engine-reference/unreal/current-best-practices.md` 的 "Command Line" 一节有这些命令及其来源。在 Windows 上使用 `UnrealBuildTool.exe`，而非 `Build.bat`：在 bash 中运行时，`Build.bat` 会在含空格的引擎路径上失败。
```bash
# Windows
timeout 1800 "<UE root>/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" <Project>Editor Win64 Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" 2>&1
# Linux
timeout 1800 "<UE root>/Engine/Build/BatchFiles/Linux/Build.sh" <Project>Editor Linux Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" 2>&1
# macOS (timeout: see the macOS note above)
gtimeout 1800 "<UE root>/Engine/Build/BatchFiles/Mac/Build.sh" <Project>Editor Mac Development -Project="$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" 2>&1
```
然后是默认命令。保留 `-stdout -FullStdOutLogOutput`；当 `commands.test` 缺少它们时，仅为本次运行将其加入命令：没有它们编辑器什么都不打印，而下面的行只存在于 `Saved/Logs/<Project>.log`。以**绝对**路径给出项目 — 当 `commands.test` 传入相对路径时，改用绝对路径运行：UE 5.7 找不到相对的 `<Project>.uproject` 并以 1 退出（`Project file not found`）。`$(pwd -W 2>/dev/null || pwd)` 在 Git Bash 中给出 `C:/…` 形式，在其他位置给出普通路径；当设置了 `MSYS_NO_PATHCONV` 时，单用 `$PWD` 会失败。无论哪种情况，都要在报告中说明你改了什么，并告知用户去修正 `project.yaml` 中的 `commands.test` — 绝不未经询问就编辑 `project.yaml`。过滤器中的 `<Project>.` 是测试命名所在的根：项目名，或当项目名同时也是一个引擎领域时 `/setup-engine` 选取的独立根 — 若不确定，读取 `Source/*/Private/Tests/` 下某个测试的名称字符串。
```bash
# Windows
timeout 1800 "<UE root>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" -ExecCmds="Automation RunTests <Project>.; Quit" -unattended -nullrhi -stdout -FullStdOutLogOutput 2>&1
# Linux
timeout 1800 "<UE root>/Engine/Binaries/Linux/UnrealEditor" "$(pwd -W 2>/dev/null || pwd)/<Project>.uproject" -ExecCmds="Automation RunTests <Project>.; Quit" -unattended -nullrhi -stdout -FullStdOutLogOutput 2>&1
```
**macOS 没有可引用的测试命令。** Epic 只记录了 `UnrealEditor.app` 包，未记录其中的命令行编辑器。运行用户已设置并确认的 `commands.test`；若没有，报告 `NOT ASSESSED — Unreal test command on macOS not sourced; set commands.test to the editor command you use`，而不是猜测路径。
读取输出，而不是退出码：失败测试和没有匹配到任何内容的运行都以 255 退出。
- 任何行出现 `Result={Fail}` → FAIL。
- `No automation tests matched` → `NOT ASSESSED — no tests found`（`Source/<Module>/` 之外的测试永远不会被构建），不是 FAIL。
- 退出 0 且出现 `Result={Success}` 行 → PASS。
- 任何其他非零退出（`Project file not found`、`The game module … could not be found`）→ FAIL：没有测试运行。例外：编辑器从未启动（退出 126 或 127，`command not found`）— 那是运行器不可用，见下文，为 `NOT ASSESSED`。

**未知引擎 / 未配置：**
"Engine not configured in `project.yaml` or `.trae/docs/technical-preferences.md`. Run `/setup-engine` to specify the engine, then re-run `/smoke-check`."

**如果测试运行器在此环境中不可用**（Phase 1 第 3 步未解析出编辑器可执行文件、找不到运行器脚本等），请清楚地报告：

"Automated tests could not be executed — engine executable not found (checked `commands.test`, `engine.path` and `PATH`; set `engine.path`, or put the editor's full path in `commands.test`). Status will be recorded as NOT RUN. Confirm test results from your local IDE or CI pipeline. Until you do, the verdict is NOT ASSESSED — not FAIL, and not a pass either: nothing has been observed about this build yet."

不要将 NOT RUN 视为自动 FAIL。记录它，让开发者在 Phase 4 中的手动确认来解决它。在确认到来之前，结论是 **NOT ASSESSED**（见 Phase 5 的结论规则），它排序在两个通过值之上、FAIL 之下。未运行的套件不是健康的构建；它是不明的构建，两者需要不同的后续处理。

解析运行器输出并提取：
- 运行的测试总数
- 通过数
- 失败数
- 任何失败测试的名称（最多 10 个；若更多，注明数量）
- 运行器自身输出的任何崩溃或错误信息

**构建检查 — 仅 WAIVED 路径**（`qa.level: minimal`，无游戏测试；Phase 1 第 1 步）。没有套件可运行时，运行项目自身的启动检查：已设置则用 `commands.smoke`，否则已设置则用 `commands.build`，并使用 Phase 1 第 3 步解析出的可执行文件，遵循相同的超时规则（`timeout 900`，或 `commands.build` 用 `timeout 1800`；超时即为 FAIL）。在 Godot 上，先运行上面的导入行。按 `/setup-engine` 的说明读取结果：Godot 的 `smoke` 即便解析出错也以 0 退出，因此其输出中的 `SCRIPT ERROR` 行为 FAIL，`Can't run project: no main scene defined` 也是 FAIL — 游戏无法启动；Unity 的 `smoke` 在编译错误时退出 1；任何其他非零退出为 FAIL。记录 `Build check: PASS — [command] exit 0`、`FAIL — [reason]` 或 `NOT RUN — [commands.smoke and commands.build unset | executable not found]`。未运行的构建检查会在报告中指名，并让 Batch 1 中的启动检查承载结论；它本身绝不算通过。

---
