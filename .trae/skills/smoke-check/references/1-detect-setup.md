# /smoke-check — Phase 1: 检测测试环境

> 属于 `/smoke-check`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 1: 检测测试环境

在运行任何东西之前，先理解环境：

0. **配置一致性**：运行 `bash .claude/scripts/project-coherence.sh`。

   它会把 `project.yaml` 声明的内容与真实项目文件、已安装的引擎二进制文件，以及 `commands.*` 所指名的文件进行比对。这一步最先运行，因为其中两项检查关乎*本技能自身的输入*：一个指向不存在的运行器的 `commands.test`，或一个指向没有 `export_presets.cfg` 的导出预设的 `commands.build`，都会在这里失败，并被读成构建损坏而不是配置损坏。

   在报告的 Environment 章节中报告所有 `[DIFFERS]` 行。它们本身不决定结论 — 但针对一个声明引擎与已安装引擎不一致的项目运行冒烟检查，值得明说。

1. **测试框架检查**：确认存在 **游戏**测试文件 — 而不仅仅是 `tests/` 目录存在。检查引擎的**测试根目录**（来自第 3 步；表格在 `.claude/docs/directory-structure.md` — Godot `tests/unit/` 和 `tests/integration/`，Unity `Assets/Tests/`，Unreal `Source/*/Private/Tests/`）以及 `tests/smoke/` 中是否存在实际的测试文件。**测试文件**指引擎测试运行器会执行的文件 — `*_test.gd` 套件、C# 测试类、Unreal 自动化测试源文件。Markdown 检查清单不算：`/test-setup` 总会写入 `tests/smoke/critical-paths.md`，把它计入会恰好掩盖本步骤要捕捉的零测试状态。如果在 **`qa.level: minimal`** 下未找到任何测试，则测试在此层级被豁免：将自动化行记录为 `WAIVED — qa.level: minimal, no game tests`，跳过 Phase 2 的测试运行和整个 Phase 3（各用一行说明），运行 Phase 2 的**构建检查**，然后继续 Phase 4 — 构建检查以及启动和关键路径检查在此层级就是冒烟检查，因此没有测试的项目仍可能达到 PASS，但绝不能没有运行：Batch 1 若回答本次会话没有启动构建，则结论为 NOT ASSESSED。如果在 **`standard` 或 `full`** 下未找到任何测试，**给出 NOT ASSESSED 结论 — 不要只是停下。** "Smoke check: **NOT ASSESSED — no game tests found** under [the test root] or `tests/smoke/`. Run `/test-setup` to scaffold the testing infrastructure, or point me at where tests live." 然后停止。

   > 此处直接中止是错误的形式。
   > 这是关于构建健康状况**信息最少**的状态，因此它最不该在没有结论的情况下退出：调用方得不到机器可读的结果，而"技能什么都没说"很容易被读成"没有出问题"。用*没有*结论替代*错误*结论也不是改进 — 诚实的结果是那个明确指出无法确立什么的结果。

   > **不要以 `tests/` 是否存在作为闸门。** `/test-setup` 会创建带占位文件的 `tests/unit/` 和 `tests/integration/`，因此任何运行过初始化的项目都会有这棵目录树 — 无论是否曾编写过一个游戏测试。应改为统计实际的测试文件；若以目录为闸门，一个没有构建且零游戏测试的项目也能通过此步骤。

2. **CI 检查**：检查 `.github/workflows/` 是否包含引用测试的工作流文件。在报告中注明是否配置了 CI。

3. **引擎检测**：从 `project.yaml` 读取 `engine.name`；若该键缺失或为空（包括 `project.yaml` 没有 `engine:` 块的情况），回退到 `.claude/docs/technical-preferences.md` 中的 `Engine:` 值（`[TO BE CONFIGURED]` 值表示未配置）。保存该值用于 Phase 2 的测试命令选择。

   然后查找**编辑器可执行文件** — 这三种引擎在 Windows 或 macOS 上默认都不会安装到 `PATH`，所以一个无法解析的裸 `godot` 不能说明引擎是否已安装。取第一个能解析的（文件存在，或 `command -v` 能找到）：`commands.test` 所指名的可执行文件（其引号路径或第一个词；在 Godot 上，仅当其文件名表明是 godot 时才算，因为诸如 `bash run-tests.sh` 的包装脚本不是编辑器），否则取 `engine.path` 记录的编辑器，否则取引擎在 `PATH` 上的名称（`godot`）。在 Phase 2 书写 `godot` 或 `"<Unity editor>"` 的任何位置都使用它，对含空格的路径加引号；在 Unreal 上，`<UE root>` 即 `engine.path`。若都无法解析，则测试运行器不可用（Phase 2）— 在 Godot 上为 `NOT ASSESSED — Godot executable not found (commands.test, engine.path, PATH)`。

4. **冒烟测试清单**：检查 `production/qa/smoke-tests.md` 或 `tests/smoke/` 是否存在。若找到冒烟测试清单，加载以供 Phase 4 使用。若两者都不存在，冒烟测试将从当前 QA 计划中提取（Phase 4 回退方案）。

5. **QA 计划检查**：glob `production/qa/qa-plan-*.md` 并取最近修改的文件。若找到，记下路径 — 它将在 Phase 3 和 Phase 4 中使用。若未找到，注明："No QA plan found. Run `/qa-plan sprint` before smoke-checking for best results."（在 `workflow: minimal` 下没有冲刺，QA 计划是可选的 — 应说明这一点，而不是推荐一个。）

在继续之前报告发现："Environment: [engine]. Editor: [the resolved executable / not found]. Test directory: [found / not found]. CI configured: [yes / no]. QA plan: [path / not found]."

---
