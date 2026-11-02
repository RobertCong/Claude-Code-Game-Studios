# Skill Test Spec: /setup-engine

## Skill Summary

`/setup-engine` 固定项目的引擎、版本与语言。它接受
`[engine]`、`[engine] [version]`、`refresh`、`upgrade [old] [new]`，或不带
参数以进入引导式选择。对 Godot，它在展示 Technology Stack 之前会先询问使用哪种语言
（GDScript、C# 还是 Both）。随后它：

- 在 "May I write these engine settings to `CLAUDE.md`?" 之后，把 Technology Stack
  与 `ENGINE-REFERENCE-IMPORT` 行写入 `CLAUDE.md`
- 在用户批准所展示的默认值之后，填充 `.claude/docs/technical-preferences.md`
  （旧式镜像：命名约定、专家路由表、输入/平台、性能预算）
- 在 "May I write the `engine`, `specialists`, `naming`, and `commands` blocks to
  `project.yaml`?" 之后，把 `engine`、`specialists`、`naming` 与 `commands` 区块
  双写到 `project.yaml` —— 主配置存储
- 更新或创建 `docs/engine-reference/<engine>/`，为 Godot 搭建
  `project.godot` 脚手架（绝不为 Unity 或 Unreal），并用
  `project-coherence.sh` 回读全部内容

重新运行时，它原地编辑已有的 `project.yaml` 区块，而不是
重复它们。不适用任何总监闸门。当引擎配置完成后，结论为 COMPLETE。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查 —— 无需夹具。

- [ ] 具备必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个阶段标题
- [ ] 包含结论关键字：COMPLETE
- [ ] 在写入 `CLAUDE.md` 与写入 `project.yaml` 区块之前，包含 "May I write" 措辞
- [ ] 具备下一步交接（第 12 节输出一份与层级匹配的 Next-Steps 清单，例如 `minimal` 下的 `/brainstorm`）

---

## Director Gate Checks

无。`/setup-engine` 是技术配置技能。不适用任何总监闸门。

---

## Fixture Defaults

除非用例自身的夹具另有说明，每个用例的 `project.yaml` 都设置
`modes.rigor: minimal` 与 `modes.automation: collaborative`，且没有
`project.local.yaml`。规则见：`studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: Godot 4 + GDScript — Full engine configuration

**Fixture:**
- `project.yaml` 没有 `engine` 区块；`technical-preferences.md` 只有占位符
- 没有 `design/gdd/game-concept.md`，也没有 `design/game-brief.md`
- `docs/engine-reference/godot/VERSION.md` 已固定为 4.7
- 仓库根目录没有 `project.godot`；用户批准每一次写入

**Input:** `/setup-engine godot 4.7`

**Expected behavior:**
1. 完整规格模式：跳过第 2 节的引导式选择
2. 技能询问 Godot 语言问题（A GDScript / B C# / C Both）；用户选择 GDScript
3. 技能展示 Technology Stack 并询问 "May I write these engine settings to `CLAUDE.md`?"
4. 技术偏好以 GDScript 命名（snake_case 文件与
   变量）和 A3 路由表呈现：`.gd` → godot-gdscript-specialist、
   `.gdshader` → godot-shader-specialist、`.tscn` → godot-specialist
5. 由于第 2 节从未运行且不存在设计产出物，技能会询问
   项目形态问题（2D/3D、是否 Web），而不是依据引擎名直接写入
   `Forward+`/`Jolt`
6. `commands.build` 的导出预设会被询问，绝不使用默认值；`commands.test` 为
   gdUnit4 的 `GdUnitCmdTool.gd` 命令
7. 技能询问 "May I write the `engine`, `specialists`, `naming`, and `commands` blocks to `project.yaml`?"
8. 第 6 节读取其覆盖表：4.7 超出 Godot 行（约 4.3），因此
   知识风险为 HIGH
9. VERSION.md 已固定为 4.7 → 无内容需重新生成；只写入其
   `Installed at pin time` 行，数据来自第 3 节的探测
10. 技能提议 `project.godot` 并在创建前询问；结论为 COMPLETE

**Assertions:**
- [ ] `project.yaml` 中 `engine.name` 为 Godot，`engine.language` 为 GDScript
- [ ] `naming.variables` 与 `naming.files` 为 `snake_case`
- [ ] 路由表包含 `.gd`、`.gdshader` 与 `.tscn` 条目；`specialists.code` 为 `godot-gdscript-specialist`
- [ ] 渲染/物理形态会被询问，而非从引擎名推断
- [ ] 在写入 `CLAUDE.md` 与 `project.yaml` 之前询问 "May I write"
- [ ] Knowledge Risk 为 HIGH —— 第 6 节表的截止时间为 2025 年 5 月，其 Godot 行约为 4.3，与随附的 VERSION.md 一致
- [ ] 结论为 COMPLETE

---

### Case 2: Unity + C# — Unity-specific configuration

**Fixture:**
- `technical-preferences.md` 只有占位符；`project.yaml` 没有 `engine` 区块
- 用户在询问时提供版本与构建目标

**Input:** `/setup-engine unity`

**Expected behavior:**
1. 仅引擎模式：查询版本并与用户确认
2. 不问语言问题（Unity 为 C#）；CLAUDE.md 的 Language 为 `C#`
3. 命名：PascalCase 类/方法、`_camelCase` 私有字段
4. 路由：`.cs` → unity-specialist、`.shader`/`.shadergraph` → unity-shader-specialist、
   `.unity`/`.prefab` → unity-specialist、`.uxml`/`.uss` → unity-ui-specialist
5. 直接写入 `rendering: URP`、`physics: PhysX` —— 不问形态问题
6. 询问 `commands.build` 目标（不硬编码 `StandaloneLinux64`）；
   `naming.constants` 携带 `# UNVERIFIED` 注释
7. 不搭建任何 Unity 项目脚手架；告知用户在 Unity Hub 中创建

**Assertions:**
- [ ] Engine 字段设为 Unity，Language 设为 C#
- [ ] 命名约定反映 C# 约定
- [ ] 路由表包含 `.cs` 与 `.unity` 条目
- [ ] 对 Unity 不问项目形态问题
- [ ] 不写入任何 Unity 项目文件
- [ ] 结论为 COMPLETE

---

### Case 3: Unreal — C++ primary, Blueprint routed to its specialist

**Fixture:**
- 仅有占位符；用户从未声明项目以 Blueprint 为主
- 会话运行在 Windows 上（`uname -s` 既不是 `Linux` 也不是 `Darwin`），因此适用 Windows 的 `commands` 区块

**Input:** `/setup-engine unreal 5.8`

**Expected behavior:**
1. 主语言问题默认为 C++，因此 CLAUDE.md 的 Language 写为
   `C++ (primary), Blueprint (gameplay prototyping)` —— 该行随
   回答而定，若回答以 Blueprint 为主则写入
   `Blueprint (primary), C++ where needed`
2. `project.yaml` 得到 `engine.language: "C++"`（仅当项目以 Blueprint 为主时才为 Blueprint）
3. 路由：`.uasset` BP 类 → ue-blueprint-specialist；`.umap`/`.uasset` → unreal-specialist；
   `specialists.additional` 包含 ue-blueprint-specialist
4. `commands` 以单引号标量写入，置于
   `# TODO: confirm these` 注释下；记录 `engine.path`
5. 性能预算通过 `AskUserQuestion` 询问（设置默认值 / 保留
   `[TO BE CONFIGURED]`），不预填
6. 不搭建 `.uproject` 脚手架；结论为 COMPLETE

**Assertions:**
- [ ] Engine 字段设为 Unreal Engine 5.8，`engine.language` 为 `C++`
- [ ] 路由表包含 `.uasset` 与 `.umap` 条目
- [ ] 为 Blueprint 图表分配 ue-blueprint-specialist
- [ ] `commands` 携带 `# TODO: confirm these` 注释
- [ ] 结论为 COMPLETE

---

### Case 4: Re-run on a Configured Project — blocks edited in place

**Fixture:**
- `project.yaml` 已有 `engine`（Godot 4.7）、`specialists`、`naming`、一个
  `modes` 区块，以及一个缺少 `smoke` 键的 `commands` 区块
- 仓库根目录存在 `project.godot`
- `docs/engine-reference/godot/VERSION.md` 固定为 4.7

**Input:** `/setup-engine godot 4.7`

**Expected behavior:**
1. 技能在编辑 `project.yaml` 之前先读取它
2. 每个已有区块原地编辑；`commands.smoke` 被补入
   不完整的区块；不追加任何区块的第二份副本
3. `modes` 及所有其他非引擎区块原样保留
4. 已有的 `project.godot` 不被覆盖 —— 技能会说明并跳过
5. VERSION.md 固定同一版本 → 无内容需重新生成：Engine Version、
   Project Pinned 与 Last Docs Verified 保持原样，只写入
   `Installed at pin time` 行，内容为第 3 节的探测结果
6. 结论为 COMPLETE

**Assertions:**
- [ ] `project.yaml` 中不重复任何区块，且缺失的 `commands.smoke` 键被补上
- [ ] `modes`（及所有其他非引擎内容）保持不变
- [ ] `project.godot` 不被覆盖
- [ ] 对同版本固定，Engine Version、Project Pinned 与 Last Docs Verified 保持不变，写入 `Installed at pin time`
- [ ] 结论为 COMPLETE

---

### Case 5: Director Gate Check — No gate; setup-engine is a utility skill

**Fixture:**
- 未配置引擎的全新项目

**Input:** `/setup-engine godot`

**Expected behavior:**
1. 技能完成完整的引擎配置
2. 任何时刻都不派生总监代理
3. 输出中不出现闸门 ID

**Assertions:**
- [ ] 不调用任何总监闸门
- [ ] 不出现闸门跳过消息
- [ ] 结论为 COMPLETE，且不经任何闸门检查

---

### Case 6: Installed Editor Older Than the Chosen Version — ask, then record

**Fixture:**
- 同 Case 1；`docs/engine-reference/godot/VERSION.md` 固定为 4.7
- `godot --version` 报告 `4.5.1.stable`
- 用户选择 "pin the newer one and upgrade later"

**Input:** `/setup-engine godot 4.7`

**Expected behavior:**
1. 第 3 节探测已安装编辑器，发现 4.5.1 —— 版本不符
2. 技能说明两个版本并询问，提供三个选项：固定
   已安装版本；固定较新版本并在之后升级；或有意
   固定较新版本
3. 回答被记录；技能不为用户做选择
4. VERSION.md 已固定为 4.7，因此不重新生成，但其
   `Installed at pin time` 行写入 4.5.1
5. 结论为 COMPLETE

**Assertions:**
- [ ] 两个版本都被说明，且三个选项全部提供
- [ ] 技能等待用户选择，而不是静默决定
- [ ] `Installed at pin time` 记录 4.5.1 —— 同版本分支不会跳过它
- [ ] Engine Version、Project Pinned 与 Last Docs Verified 不被重新标记

---

### Case 7: Godot not on PATH — the probed executable goes into `commands.*`

**Fixture:**
- 同 Case 1，在 Windows 上；`godot --version` 失败 —— `godot` 不在 `PATH` 上
- 探测找到 `C:/Program Files/Godot/Godot_v4.7.2-stable_win64.exe`，其报告 `4.7.2.stable`
- 用户把导出预设命名为 `Windows Desktop`

**Input:** `/setup-engine godot 4.7`

**Expected behavior:**
1. 第 3 节从找到的可执行文件读取版本 —— 不会报告 "no engine installed"
2. `build`、`test`、`run` 与 `smoke` 均以带引号的完整路径开头，作为单引号标量；`build` 用双引号引用其预设：
   `build: '"C:/Program Files/Godot/Godot_v4.7.2-stable_win64.exe" --headless --export-debug "Windows Desktop"'`
3. `test` 在路径之后保留 `--remote-debug tcp://127.0.0.1:0` 与 gdUnit4 运行器参数
4. `engine.path` 记录该可执行文件
5. 结论为 COMPLETE

**Assertions:**
- [ ] 没有任何 `commands.*` 值使用裸的 `godot`
- [ ] 每个 Godot 命令值都是单引号标量，且没有值同时包含两种引号
- [ ] `engine.path` 记录编辑器可执行文件
- [ ] 变体 —— 探测未找到任何内容且用户不知道 Godot 在哪：裸 `godot` 保留在 `# TODO: godot is not on PATH here` 注释下，且技能说明在设置路径之前命令不会运行

---

### Case 8: A skipped question is not an answer

**Fixture:**
- 全新项目：未配置引擎，`project.yaml` 无 engine 区块
- 引擎问题返回为跳过：用户关闭它，或无人值守运行
  把每个问题都返回为跳过
- 沙箱携带框架的 `CLAUDE.md`。本用例检查的规则
  在那里声明（"A skipped or dismissed question is not an answer"），也在
  `.claude/docs/automation-modes.md` 中，而不在 `/setup-engine` 自己的文件中；由
  `CLAUDE.md` 加载的规则算作技能自身的规则（`/skill-test` spec 模式，步骤 3），
  因此缺少它的沙箱属于配置错误，而不是技能 FAIL

**Input:** `/setup-engine`

**Expected behavior:**
1. 技能不自行选择引擎、语言或版本
2. 它以纯文本再次询问，说明正在等待该回答，并等待
3. 在用户回答之前，不向 `CLAUDE.md`、`project.yaml`、`technical-preferences.md`
   或 `VERSION.md` 写入任何内容
4. 在无人能回答的运行中，它停止并报告正在等待什么

**Assertions:**
- [ ] 不代用户选择引擎、语言或版本
- [ ] 以纯文本再次询问该问题
- [ ] 在回答到达之前不写入任何文件

---

## Protocol Compliance

- [ ] 在请求写入之前展示配置草稿
- [ ] 在写入 `CLAUDE.md` 与 `project.yaml` 区块前询问 "May I write"；技术偏好只有在用户批准所展示的默认值之后才写入
- [ ] 提供引擎参数时尊重它（跳过引导式选择）
- [ ] 双写 `project.yaml` 与 `technical-preferences.md`，然后回读 `project.yaml` 确认两者一致
- [ ] 重新运行时，原地编辑已有的 `project.yaml` 区块而不重复它们
- [ ] 把探测到的编辑器路径写入 `commands.*` —— Unity 始终如此，Godot 在 `godot` 不在 `PATH` 上时总是如此 —— 绝不写入无法解析的裸可执行文件
- [ ] 绝不为 Godot 导出预设或 Unity 构建目标设置默认值 —— 而是询问；Unreal 的 `commands` 是按机器操作系统尽力匹配的值（Windows 上 `-platform=Win64`，Linux 上 `Linux`），置于 `# TODO` 注释下；在 macOS 上只写 `build`，`test`、`run` 与 `smoke` 保留为 TODO 行
- [ ] 无论结果如何，在询问 "May I record `Installed at pin time: …` in `docs/engine-reference/<engine>/VERSION.md`?" 之后，把第 3 节的探测写入 VERSION.md 的 `Installed at pin time` 行
- [ ] 配置写入后结论为 COMPLETE

---

## Coverage Notes

- Godot C# 与 Both 沿用 Case 1 的流程，采用
  `references/godot-language-config.md` 中的 A1/A2/A3 变体；未单独测试。
- `refresh` 与 `upgrade` 子命令（第 10–11 节）此处未测试。
- Unreal 的 Linux 与 macOS `commands` 区块（由 `uname -s` 选择）未做
  夹具测试；Case 3 固定为 Windows。
- 第 6 节是对技能自身覆盖表的查表，已在
  Case 1 中断言。对尚无参考集的版本，第 7 节的参考文档
  依赖 WebSearch 结果；未做断言测试。
- 无法运行的探测会报告 `installed version NOT DETERMINED` —— 绝不报告
  "no engine installed"；未单独测试。
- 以 Blueprint 为主的 Unreal 回答（`engine.language: "Blueprint"`）沿用
  Case 3 的流程，Language 行不同；未单独测试。
