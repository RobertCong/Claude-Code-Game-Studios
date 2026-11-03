---
name: settings
description: "查看或修改项目配置 — 合并后的有效值，或在 project.local.yaml 中本地设置。"
argument-hint: "[key | key=value | --local key=value]"
user-invocable: true
---

# /settings — 查看或修改项目配置

管理 `project.yaml`（团队级配置，已提交）和 `project.local.yaml`
（按开发者覆盖，已 gitignore）。使用本技能可以检查当前设置或修改设置，
无需手动编辑 YAML。

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。Phase 4 和 Phase 5 中的审批闸门
遵循 `.trae/docs/automation-modes.md` 中的模式。**注意**：
写入 `project.yaml` 属于 `schema_changes` 决策（一个默认的
`automation_always_ask` 类别），因此 `/settings` 即使在
`autonomous` 模式下也会确认配置写入，除非用户已从
always-ask 列表中移除 `schema_changes`。

## Phase 0: 解析参数

确定用户调用的是四种形式中的哪一种：

| 形式 | 模式 |
|------|------|
| `/settings`（无参数） | **查看全部**（Phase 2） |
| `/settings <key>`（单参数，无 `=`） | **查看单个**（Phase 3） |
| `/settings <key>=<value>`（单参数含 `=`） | **设置 yaml**（Phase 4） |
| `/settings --local <key>=<value>`（`--local` 前缀） | **设置本地**（Phase 5） |

对于设置 yaml 和设置本地，`<key>` 是点分 YAML 路径（例如
`modes.review_mode`、`testing.strict.logic`），`<value>` 是新值。

**空操作数校验：** 在按 `=` 拆分 `key=value` 操作数后，如果
`<key>` 或 `<value>` 任一为空，则格式错误——转至
Phase 6（用法），而不是尝试写入。该规则同时适用于
设置 yaml 和设置本地的路由：对于 `--local`，先剥离 `--local` 标记，
再按同样方式检查剩余操作数（因此 `/settings --local =foo`
和 `/settings --local key=` 都会进入 Phase 6）。

其他任何不匹配上述四种形式的内容 → Phase 6（用法）。

## Phase 1: 加载辅助脚本

所有四个子命令都需要 `yaml-helper.sh`。将每次辅助调用作为单独的
普通命令运行：

```bash
bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" <helper call>
```

`<helper call>` 是下面各阶段指定的函数，例如
`resolve_setting modes.review_mode` 或 `validate_yaml_enum project.yaml`。
辅助脚本会自行切换到项目根目录，因此即使会话在子文件夹中启动，
这些 `project.yaml` 和 `project.local.yaml` 参数也能正确解析，
并且它会保留函数的退出状态。`is_locally_overridable`
还会打印其 `0` 或 `1`。完全按所示方式运行调用：不要 `source` 该文件，
不要用 `cd ... &&` 包裹，也不要追加 `; echo $?`。本技能只预先批准
普通形式，复合命令每次都会询问用户。

如果缺少 `.trae/hooks/yaml-helper.sh`，则这不是 CCGS 项目。
报告错误并退出。

## Phase 1b: 保留设置检测

有些设置已有完整文档记录且可设置，但**没有任何技能或钩子读取它们**——
设置它们不会改变任何东西。**本技能必须说明这一点。**
返回普通成功会让用户合理地认为该设置所描述的行为现在已被强制执行——
无障碍等级就是引发此需求的情形。（此处故意不点出该键名；见下文注释。）
该横幅只存在于 `.trae/docs/effects-map.md` 中，而配置项目的人
永远不会打开那个文件。一个不起作用的设置绝不能看起来
和一个有效设置一模一样——`.trae/rules/skill-authoring.md` 义务 3。

推导该集合；不要硬编码（义务 5）：

```bash
grep -B14 '^> ### RESERVED' .trae/docs/effects-map.md | grep -E '^## '
```

**匹配横幅标题（`> ### RESERVED`），绝不要匹配裸词 "RESERVED"。**
`platform.cert_tier` 的章节在正文中*提到*了该横幅，以记录它
曾带有该横幅、后来成为有效设置。更宽松的匹配会把一个正常工作的
设置重新报告为无效设置——这种方向会低估框架的能力，也是
死设置闸门同时断言两个方向的原因。

一个标题可能命名**两个用 " and " 连接的键**——按该分隔符拆分，
以便两个都被捕获，否则第二个会静默逃出集合。令
`RESERVED_SET` 为结果。

> 有意在措辞中不点名那些键。死设置闸门断言
> 允许列表中的设置**没有**读取者，并且会统计任何拼出该键的技能
> 文件。此处为说明拆分而点名它们，会让
> `/settings` 被登记为两个无人读取的设置读取者，闸门
> 就会失败——而且失败得正确。在解释为何不要使用
> 某个死路径时把它拼写出来，会触发同一根线。应改写措辞，而不是添加豁免：
> 严格性正是重点，因此不要为了把示例讲得更清楚而
> 重新引入字面名称。

绝不要拒绝写入保留键。存储用户想要的值是
正当的；*静默地*存储它才是缺陷。

## Phase 2: 查看全部模式

（无参数时）

1. 确认 `project.yaml` 存在。如果缺失，报告：
   > “未找到 `project.yaml`——运行 `/start` 创建一个。”
   然后退出。

2. 检查 `project.local.yaml` 是否存在。

3. 运行 `validate_yaml_enum project.yaml` 并捕获任何错误。
   如果 `project.local.yaml` 存在，也运行 `validate_yaml_enum project.local.yaml`。
   为每个错误标记其源文件，以便用户区分。

4. **枚举叶子。** 使用 `Read` 工具将两个 YAML 文件作为
   文本读取。遍历每个文件的结构，收集每个叶子键
   到去重后的点分路径列表中。叶子是
   值为非空（标量或内联数组）的 `key: value` 行——
   而不是引入嵌套映射的父块。按文件维护插入顺序；
   通过追加 `project.local.yaml` 中尚未在 `project.yaml` 中出现的叶子来合并。
   结果列表就是要显示的叶子集合。

   **然后追加 rigor 家族**——`modes.rigor`、`modes.workflow`、
   `docs.density`、`qa.level`、`modes.story_granularity`、`modes.review_mode`、
   `team.size`——合并列表中尚未包含的七个键。它们通常
   不是任一文件的叶子：`modes.rigor` 有终止默认值，其他六个由
   rigor 展开提供（`modes.review_mode` 和 `team.size` 在本地设置时
   也可能作为文件叶子出现，但仍必须追加，以便显示其*派生*值）。
   只枚举文件叶子会恰好隐藏用户刚刚选择的设置，而
   这个视图本意就是展示它们。

5. **对每个叶子**，执行三次读取和一项检查：
   - `resolve_setting <path>` → `<value>`、TAB、`<source>`。这会遍历
     整条链路（`project.local.yaml` → `project.yaml` → 遗留文件 →
     `rigor` 展开 → 默认值），因此它是唯一能报告
     派生值或说明其来源的读取。
   - `get_yaml_key project.yaml <path>` → 仅 yaml 中的值（仅用于
     显示本地覆盖遮蔽了什么）
   - `is_locally_overridable <path>` → 0（可覆盖）或 1（锁定）

   从 `<source>` 计算**来源标注**：

   | `<source>` | 标注 |
   |---|---|
   | `project.local.yaml`，仅 yaml 值非空 | `(LOCAL OVERRIDE — yaml has: <yamlvalue>)` |
   | `project.local.yaml`，仅 yaml 值为空 | `(project.local.yaml)` |
   | `project.yaml` | `(project.yaml)` |
   | 遗留文件路径（例如 `production/review-mode.txt`） | `(<path>, legacy)` |
   | `rigor:<level>` | `(derived from rigor: <level>)` |
   | `default` | `(default)` |
   | `unset` | 跳过该叶子（不打印未设置的键） |

   当 `is_locally_overridable` 返回 1 时，在标注后追加
   `, locked`。

   **当叶子在 `RESERVED_SET`（Phase 1b）中时，追加 `, reserved`**，
   并用下面的图例在块下方打印这一行：

   ```
   reserved = stored, but nothing reads it. Setting it changes
   no behaviour today.
   ```

   > **所有四个阶段都必须带上 reserved 标记——查看单个、查看全部，
   > 以及两条写入路径。** 只标记查看单个和写入而让
   > 查看全部——**本技能最常用的形式**——未标记，意味着设定了
   > 保留键的用户会看到它与正常工作的设置并列，带有普通的
   > `(project.yaml)` 标注，而且是在大多数人实际运行的视图中。
   > 保护全部四个：查看单个和查看全部是孪生关系，正如两条写入
   > 路径也是孪生关系。

6. **打印**，按顶层章节（`framework`、`modes`、
   `engine` 等）分组，顺序为叶子首次出现的顺序。分组由
   点分路径决定，而不是由叶子来自哪个文件决定——例如
   `modes.automation` 分组到 `modes:` 下，即使只有
   `project.local.yaml` 定义了它。在每个章节内，叶子缩进
   2 个空格；子块进一步嵌套（例如 `testing.strict.*`）。
   示例输出：

```
project.yaml: present
project.local.yaml: present

Schema validation: ok

Effective config:

framework:
  version: 1.2.0            (project.yaml, locked)

modes:
  review_mode: lean         (project.yaml)
  automation: autonomous    (LOCAL OVERRIDE — yaml has: collaborative)
  rigor: full               (project.yaml, locked)
  workflow: full            (derived from rigor: full, locked)
  story_granularity: fine   (derived from rigor: full, locked)

docs:
  density: terse            (project.yaml, locked)

qa:
  level: full               (derived from rigor: full, locked)

engine:
  name: Godot               (project.yaml, locked)
  version: 4.7              (project.yaml, locked)

testing:
  strict:
    logic: false            (LOCAL OVERRIDE — yaml has: true)
    integration: true       (project.yaml)

locked = cannot be overridden in project.local.yaml (project-wide setting).
It does NOT mean fixed: a derived value can still be set explicitly with
/settings <key>=<value>, and an explicit value wins over rigor.
```

只要任何渲染出来的行带有 `locked`，就在配置块之后打印
那行两行图例。没有它，用户会把 `locked` 理解为“不可更改”，
并得出由 rigor 派生的旋钮无法更改的结论——这与 Phase 3 的
查看单个对同一旋钮的说法（“显式值优先于 rigor”）相反。
两个视图不能对同一旋钮的可变性留下矛盾的印象。

上面的 `docs.density` 行体现了优先级规则：显式的 `project.yaml`
值始终优先于 `rigor` 本来会派生的级别，因此“全面但紧凑”
仍然可以表达。

如果存在 schema 错误，在有效配置块之前按以下形式打印它们：

```
Schema validation: ERRORS
  [project.yaml] modes.review_mode: 'chaotic' is not a valid value (expected: full|lean|solo)
  [project.local.yaml] engine.name: 'Pygame' is not a valid value (expected: Godot|Unity|Unreal)
```

## Phase 3: 查看单个模式

（单参数，无 `=` 时）

**如果 `<key>` 在 `RESERVED_SET` 中，就在值块之前打印以下内容**——
在上方，而不是下方。值下方的警告读起来像是对一个正常工作的设置的脚注：

> **`<key>` 是 RESERVED——没有东西读取它。** 下面的值会被存储；它
> 今天不改变任何行为。

令 `<key>` 为参数。执行四次读取：

1. `resolve_setting <key>` → `<value>`、TAB、`<source>`（有效值 + 来源）
2. `get_yaml_key project.yaml <key>` → 仅 yaml 中的值
3. `get_yaml_key project.local.yaml <key>` → 仅本地值（文件不存在则跳过）
4. `is_locally_overridable <key>` → 0（可覆盖）或 1（锁定）

从 `<source>` 确定**来源**（与 Phase 2 第 5 步相同的表）
以及**本地覆盖**状态：
- 如果仅本地值非空，则为 `yes`
- 否则为 `no`

打印：

```
<key>

  Effective value: <effective-value or "(not set)" if <source> is unset>
  Source: <project.yaml | project.local.yaml | project.local.yaml (overrides project.yaml) | derived from rigor: <level> | default>
  Locally overridden: <yes | no>
  Whitelist: <"can be locally overridden" if is_locally_overridable returned 0, else "locked — project-wide">
```

当两个文件都设置该键时（LOCAL OVERRIDE 情形），在 Source 下再增加两行：

```
  project.yaml value: <yamlvalue>
  project.local.yaml value: <localvalue>
```

当 `<source>` 为 `rigor:<level>` 时，在 Source 下增加一行，让用户
知道该值是可设置的以及如何设置：

```
  Set explicitly with: /settings <key>=<value>   (an explicit value wins over rigor)
```

当有效值为空（键在任何地方都未设置）时，只打印：

```
<key>

  Effective value: (not set)
  Locally overridden: no
  Whitelist: <"can be locally overridden" | "locked — project-wide">
```

## Phase 4: 设置 yaml 模式

（`<key>=<value>` 且无 `--local` 时）

1. **Schema 校验**：调用 `validate_enum_value <key> <value>`。如果
   返回 1，则原样向用户显示 stderr 行
   （`Invalid value '<value>' for '<key>'. Allowed: ...`），技能
   在不写入的情况下退出。如果返回 0，则该值要么有效，
   要么该键没有枚举约束——继续。

1b. **已知键检查**：按 Phase 1 所述从项目根目录运行
   `bash .trae/scripts/config-set.sh <key> <value> --dry-run`，读取其
   `known` 行。如果显示 `yes`，继续。如果显示 `no`，则 CCGS 中没有任何东西读取
   该键，因此写入它不会改变任何东西；这通常是拼写错误。先不要写入：
   说明这一点，并通过 `AskUserQuestion` 询问，选项为
   `Use <nearest> instead`（仅当该行以 `nearest: <key>` 结尾时）、
   `Write <key> anyway`、`Cancel`。仅在明确选择后继续；选择
   `Use <nearest> instead` 时，用该键重新开始本阶段。跳过或
   空答案视为取消。

2. **保留警告**：如果 `<key>` 在 `RESERVED_SET`（Phase 1b）中，在
   审批提示之前打印：
   > “注意：`<key>` 是 RESERVED——没有技能或钩子读取它，因此设置它
   > 不会改变任何行为。你的值无论如何都会被存储。”

   然后照常继续到审批闸门。Phase 5 带有完全相同的
   警告。只警告一条写入路径而不警告另一条，会留下通往
   同一结果的静默路径，而这正是本项防护要避免的失败。

3. **遮蔽警告**：读取 `get_yaml_key project.local.yaml <key>`。如果
   它返回非空值，就在审批提示之前打印：
   > “注意：此设置当前在 `project.local.yaml` 中被本地覆盖（值：`<localvalue>`）。写入 `project.yaml` 不会改变你的有效值。”

4. **审批闸门**：使用 `AskUserQuestion`：
   - 提示：``Set `<key>=<value>` in `project.yaml`?``
   - 选项：`[A] Yes, write` / `[B] No, cancel`

5. **写入**使用 `Edit` 工具。编辑策略取决于
   `project.yaml` 中已存在的内容：

   **情况 A——键已存在**：读取 `project.yaml`。定位行
   `<lastsegment>: <oldvalue>` 以及紧挨其上方、引入其父块的
   行（例如 `modes.review_mode` 的 `modes:`）。
   构建 `Edit` 的 `old_string`，包含父块行
   加上叶子行，这样即使 `<lastsegment>: <oldvalue>` 出现在别处，
   匹配也是唯一的。`modes.review_mode=full` 的示例：
   ```
   old_string:
     modes:
       review_mode: lean
   new_string:
     modes:
       review_mode: full
   ```

   **情况 B——父块存在，叶子不存在**：找到父块的最后一行。
   使用 `Edit` 在正确的缩进处追加新的叶子行，
   以最后一个现有叶子作为 `old_string` 锚点。

   **情况 C——父块不存在**：在文件末尾追加新的顶层
   块（确定性的——始终在文件末尾，绝不在块之间）。使用 `Edit`，
   以文件的最后一个非空行作为 `old_string`，并在其后
   追加新块。

   **情况 D——文件结构异常**（存在同名注释掉的键、
   嵌套有歧义、YAML 格式错误）：停止并通过
   `AskUserQuestion` 询问：
   > “无法在 `project.yaml` 中为 `<key>` 找到干净的插入点。请告诉我该怎么做。”

6. 确认：``Set `<key>=<value>` in `project.yaml`.``

   **当 `<key>` 是 `modes.rigor` 时**，写入还会移动另外六个
   旋钮，因此打印它们现在解析出的值——用
   `resolve_setting` 重新读取每一个，而不是背诵展开表，因为其中任何一个
   都可能带有仍会优先的显式值：

   ```
   Set modes.rigor=full in project.yaml. It now supplies:
     modes.workflow: full            (derived from rigor: full)
     docs.density: terse             (project.yaml — explicit, unchanged)
     qa.level: full                  (derived from rigor: full)
     modes.story_granularity: fine   (derived from rigor: full)
     modes.review_mode: full         (derived from rigor: full)
     team.size: studio               (derived from rigor: full)
   ```

## Phase 5: 设置本地模式

（`--local <key>=<value>` 时）

1. **允许列表检查**：调用 `is_locally_overridable <key>`。
   - 如果返回 1（锁定），打印一行：
     > ``<key> cannot be locally overridden — it's a project-wide setting. Use `/settings <key>=<value>` (no `--local`) to change it for the whole team.``
   - 不写入直接退出。

2. **Schema 校验**：调用 `validate_enum_value <key> <value>`。如果
   返回 1，原样显示 stderr 消息并在不写入的情况下
   退出。

2a. **已知键检查**：同 Phase 4 第 1b 步，在 `<key>` 前使用 `--local`：
   如果 `known` 行显示 `no`，在写入前询问，如果该行
   命名了 `nearest:` 键，则提供该键。

2b. **保留警告**：如果 `<key>` 在 `RESERVED_SET`（Phase 1b）中，在
   审批提示之前打印：
   > “注意：`<key>` 是 RESERVED——没有技能或钩子读取它，因此设置它
   > 不会改变任何行为。你的值无论如何都会被存储。”

   与 Phase 4 第 2 步完全相同，且是刻意如此。两条写入路径都会到达
   用户意图的同一记录文件；只对一条发出警告会让
   `--local` 成为静默路径。

3. **基础检查**：如果 `project.yaml` 不存在：
   > “无法创建 `project.local.yaml`——缺少 `project.yaml`。请先运行 `/start` 创建一个。”
   退出。（根据规范，本地覆盖需要基础文件。）

4. **审批闸门**：使用 `AskUserQuestion`：
   - 提示：``Set `<key>=<value>` in `project.local.yaml` (your personal override, gitignored)?``
   - 选项：`[A] Yes, write` / `[B] No, cancel`

5. **写入**：
   - 如果 `project.local.yaml` 不存在，使用 `Write` 创建它，
     将新设置包在其父块中。`--local modes.automation=autonomous`
     的最小示例：
     ```yaml
     # project.local.yaml — per-developer overrides (gitignored)
     modes:
       automation: autonomous
     ```
   - 如果存在，使用 `Edit`，采用与 Phase 4 第 4 步相同的
     情况 A/B/C 策略。

6. 确认：``Set `<key>=<value>` in `project.local.yaml` (your override).``

## Phase 6: 用法

当参数不匹配任何四种有效形式（或操作数为空）时，打印：

```
Usage:
  /settings                          — view all effective config
  /settings <key>                    — view a single setting
  /settings <key>=<value>            — change a setting (project.yaml)
  /settings --local <key>=<value>    — change a setting locally
                                       (project.local.yaml, gitignored)

Examples:
  /settings modes.review_mode
  /settings modes.review_mode=full
  /settings --local modes.automation=autonomous
```

## 说明

- 所有 YAML 写入都通过 `Edit`（现有键/块）或 `Write`
  （新文件）进行。本技能不依赖 `yq` 或任何外部 YAML 库。
- 允许列表在 `yaml-helper.sh` 中强制执行
  （`is_locally_overridable` 函数）。要扩展它，编辑
  `_yaml_helper_locally_overridable` 常量——不要在此处重复列表。
- **派生值不存储在任何地方。** `modes.workflow`、`docs.density`、
  `qa.level`、`modes.story_granularity`、`modes.review_mode` 和 `team.size` 没有
  终止默认值；当没有文件设置它们时，其值来自 `yaml-helper.sh`
  中的 `modes.rigor` 展开
  （`_yaml_helper_rigor_expansion`）。通过 `resolve_setting` 报告它们——一次
  `get_yaml_key` 读取会返回空，并会把它们渲染为“(not set)”，而实际上
  每个技能都在基于一个真实值行动。
- schema 校验的枚举常量在 `yaml-helper.sh`
  （`_yaml_helper_enums`）中。`validate_enum_value` 是用于待写入的
  单键校验器；`validate_yaml_enum` 校验整个
  文件（由 `session-start.sh` 使用）。
- `project.local.yaml` 已 gitignore。这些
  覆盖永远不会传播给队友。
- 关于针对给定游戏类型或情况**该选择哪个值**——以及何时
  建议修改——参见 `.trae/docs/settings-guidance.md`（建议预设
  + 修改触发条件）。`effects-map.md` 说明每个设置的作用；该文档说明
  该选哪个。