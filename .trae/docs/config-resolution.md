# 配置解析

技能如何得知其生效设置。**一条命令，不堆砌散文式链路。**

## 规则

需要配置的技能把这条命令放在其**正文**顶部附近（不是 frontmatter 中）：

````markdown
!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys a,b`
````

**并且**在其自己的 frontmatter 中精确预批准该命令，路径中使用自己的
目录名：

````yaml
allowed-tools: Read, …, Bash(bash "*/.claude/skills/<skill-name>/../../hooks/yaml-helper.sh" resolve_config *)
````

该命令在*模型看到技能之前*作为预处理运行，其输出会就地替换占位符。
随后技能读取已解析的值，**不再重新推导它们**。

解析按系统层级设置的技能会传入系统名：`resolve_config combat`。

## 为何放在正文，而非 `context:`

技能正文中的 `` !`cmd` `` 是文档化的机制。Frontmatter
`context:` 只接受 `context: fork`——它**不**运行 shell。包含 `!` 命令的
`context: |` 块**永远不会执行**；请把命令放在技能正文中。

## 为何偏偏是这条命令——权限检查

Claude Code 会在技能渲染**之前**对每条注入命令做权限检查。在自动模式之外，任何没有返回 "allow" 的东西——包括
一个通常只会弹出提示的命令——都会**中止整个调用**，
模型根本看不到该技能。像 `git status` 这样的只读命令，Claude Code 会自行
批准，返回 "allow" 并无需授权即可运行。预加载的技能（agent 上的 `skills:`）在 agent 启动时以同样方式
检查，因此一行失败的引导代码会让 agent 无法启动。在默认
模式下，引导形式的表现如下：

| 引导形式 | 仓库根目录 | 子目录 | 预先加载它的无 Bash agent |
|---|---|---|---|
| `source "${CLAUDE_PROJECT_DIR:-.}/…" && resolve_config` | 中止 | 中止 | 启动失败 |
| 同上，带裸 `Bash` 授权 | 中止 | — | — |
| `bash "${CLAUDE_PROJECT_DIR}/…"` + 授权 | 运行 | 中止 | — |
| **`bash "${CLAUDE_SKILL_DIR}/../../hooks/…"` + 每技能授权** | **运行** | **运行** | **启动** |

该表排除了哪些做法：

- **不能使用 `${VAR:-x}` 展开。** 它会以 "Contains expansion" 失败，且没有任何授权
  可以批准它。`${CLAUDE_SKILL_DIR}` 和 `${CLAUDE_PROJECT_DIR}` 没问题：Claude
  Code 会在检查前把它们作为文本替换。
- **路径不能使用 `${CLAUDE_PROJECT_DIR}`。** 在技能中它指的是
  Claude Code 启动时所在的目录，而不是仓库根目录，因此当 Claude
  Code 在子目录中启动时会出错。
  `${CLAUDE_SKILL_DIR}` 始终指向技能自己的文件夹。
- **不能使用 `source … && …` 复合命令。** 每一部分都必须被批准；`bash <file>
  resolve_config` 是一条命令。`yaml-helper.sh` 执行时只会分派
  `resolve_config`，并从自身位置找到仓库根目录。
- **授权是必需的。** `allowed-tools` 才是预批准注入命令的东西。
  模式必须在路径后包含字面量 `"`——以 `…yaml-helper.sh *` 结尾的模式
  不匹配。
- **任何非零退出也会中止。** 入口点始终以 0 退出；其他可能失败的
  注入命令以 `|| true` 结尾。

自动模式可以自行批准旧形式，v1.1.0 就是这样发布的。
请在默认模式下、在未设置 `settings.local.json` 的项目中测试引导变更。

`disableSkillShellExecution: true` 会把每条注入命令替换为
占位消息。如果技能看不到配置块，则回退到下方的默认值。

## 配置块

```
=== CCGS Resolved Config ===
review_mode: lean (production/review-mode.txt)
automation: guided (project.local.yaml)
workflow: standard (project.yaml)
docs.density: balanced (rigor:standard)
story_granularity: balanced (rigor:standard)
qa.level: standard (rigor:standard)
team.size: individual (rigor:standard)
project.stage: Systems Design (production/stage.txt)
automation_always_ask: scope_changes, file_deletions, schema_changes (default)
engine: Godot 4.7 (project.yaml)
testing.strict: logic=true integration=false visual=unset ui=unset config=unset (unset = each skill applies its own default)
system_overrides: combat=full inventory=minimal
notes: none
Values above are fully resolved (local -> yaml -> legacy -> default). Use as-is.
An inline --review flag, if passed, overrides review_mode.
=== end CCGS config ===
```

每个配置项行都以括号中的**来源（provenance）**结尾。这正是让错误值
可诊断的原因——当 `project.yaml` 写着 `full` 时出现
`review_mode: solo (rigor:minimal)`，会直接指向问题所在。

## 解析链

| 步骤 | 来源 | 适用于 |
|---|---|---|
| 1 | `project.local.yaml` | `/settings --local` 白名单上的任何设置（12 个键——`modes.review_mode`、`modes.automation`、`modes.automation_always_ask`、`team.size`、全部五个 `testing.strict.*`、`performance.enforce`、`features.*`） |
| 2 | `project.yaml` | 所有键 |
| 3 | 旧版纯文本镜像 | `modes.review_mode` → `production/review-mode.txt`；`project.stage` → `production/stage.txt` |
| 4 | **`modes.rigor` 展开** | `rigor` 前置的六个配置项——`modes.workflow`、`docs.density`、`qa.level`、`modes.story_granularity`、`modes.review_mode`、`team.size` |
| 5 | 文档化默认值 | 下表 |

**枚举无效的值不会胜出**——解析链会越过它继续，被拒绝的值会在 `notes:` 行中
点名。拼写错误会降级为文档化默认值，而不是把无意义的模式传播到每个
技能中。

> **第 4 步位于每个显式来源之下、终止默认值之上，
> 这个顺序就是整个向后兼容保证。** 一个已设置 `docs.density: terse` 的
> `project.yaml`，其解析结果与 `rigor` 出现之前完全一样，因为第 2 步先给出答案。
> 把第 4 步和第 5 步对调，`rigor` 就会变成空操作；把第 4 步提升到第 2 步之上，
> 它就会静默覆盖人们已有的设置。
>
> 派生值把其来源报告为 **`rigor:<level>`**，因此来源词汇表是
> `{project.local.yaml, project.yaml, <legacy path>, rigor:<level>,
> default, unset}`。`docs.density: balanced (rigor:standard)` 表示该值从未
> 被写到任何地方——它跟随项目的 rigor 级别，并会随该级别变化而移动。

> **读取范围 == 写入白名单。** `/settings --local` 可以*写入*的任何内容，
> 在解析期间也会被*读取*。如果读取范围曾经更窄，
> `/settings --local modes.review_mode=solo` 就会写入一个
> `/settings` 接受并显示、而每个技能随后忽略的值。测试套件
> 断言这两个列表保持一致——只向其中一个添加设置而不添加另一个，
> 就会重现该错误。
>
> 这符合规格：`effects-map.md` § "Local Override Pattern" 一直
> 声明该链适用于*每个*设置。较窄的读取范围是实现缺口，而非设计。

> **白名单之外、手写进 `project.local.yaml` 的键会被
> 报告，而不是被吞掉。** `/settings --local` 拒绝
> 写入这样的键，但该文件的存在就是为了手动编辑，因此那条路径需要自己的
> 守卫。写在那里的 `modes.rigor: full` 是一个具有合法值的真实键，所以
> `validate_yaml_enum` 会通过它——然后解析器永远不会为该路径查询本地
> 文件，于是设置消失，用户看到的是他们本想覆盖的默认值，且任何地方都没有错误。
> 解析链中的每个检查都验证了**值**；没有任何检查验证**位置**。
>
> `validate_local_scope` 现在会在 `notes:` 中列出这类键。它**只警告，从不
> 自行修正**，与阶段镜像检查同样的形态：它不编辑文件、不开始遵循该键、
> 也不改变解析结果。被锁定的设置之所以被锁定，是因为它决定磁盘上存在哪些产出物，
> 因此一个悄悄应用它的辅助函数会让两个开发者的检出版本产生分歧
> ——这正是白名单要防止的事情。用户可把该键移到
> `project.yaml` 或删除它。
>
> `schema_version` 和 `framework.*` 是豁免的：`effects-map.md` 将它们归类为
> 文件元数据而非偏好设置，携带 `schema_version: 1` 的 `project.local.yaml`
> 按其书写方式是正确的。

## 默认值

| 配置项 | 默认值 |
|---|---|
| `modes.automation` | `collaborative` |
| `modes.rigor` | `minimal` |
| `modes.automation_always_ask` | `scope_changes`、`file_deletions`、`schema_changes` |

**`rigor` 前置的六个配置项完全没有终止默认值。** `modes.workflow`、
`docs.density`、`qa.level`、`modes.story_granularity`、`modes.review_mode` 和 `team.size`
有意不出现在 `_yaml_helper_defaults` 中：那里的默认值会在第 5 步给出答案，
早于第 4 步的展开运行，从而使 `rigor` 对任何没有同时
设置子配置项的人变成空操作。它们的生效值来自 rigor 级别：

| `modes.rigor` | `modes.workflow` | `docs.density` | `qa.level` | `modes.story_granularity` | `modes.review_mode` | `team.size` |
|---|---|---|---|---|---|---|
| `minimal`（默认） | `minimal` | `terse` | `minimal` | `coarse` | `solo` | `individual` |
| `standard` | `standard` | `balanced` | `standard` | `balanced` | `lean` | `individual` |
| `full` | `full` | `thorough` | `full` | `fine` | `full` | `studio` |

由于 `rigor` 本身默认为 `minimal`，未配置的项目会把
这六项解析为精简行。该默认值曾是 `standard`；之所以更改，是因为较重的层级
在不产生更好结果的情况下，达到可运行代码的成本更高。推理和顺序
约束见 `.claude/hooks/yaml-helper.sh` 中 `_yaml_helper_defaults`
上方的理由说明块。提升层级是 `/start` 中的一个问题，或一次 `/settings`
调用，而 `settings-guidance.md § 4` 的上行触发条件正是从这个
起始状态出发设计的。（`team.size` 是唯一不受该翻转影响的配置项：
`minimal` 和 `standard` 都产生 `individual`，只有 `full` 才启用
`studio` 名册。）

> **该翻转确实会影响现有项目。** 一个显式设置了六项中某些项、
> 但从未设置 `rigor` 的 `project.yaml` 会保留其显式值，其余项则采用
> 新的 `minimal` 行——因此过去解析为 `standard` 的未设置 `qa.level` 现在解析为 `minimal`。
> 通过显式设置 `modes.rigor: standard` 来固定旧行为；见
> UPGRADING.md。

`modes.workflow` 是**被前置，而非被替换**：它保留
`workflow_overrides.system_overrides`，后者仍然优先于派生值。
显式设置六项中任一项只会覆盖该项，并让
其余项留在 rigor 级别上，这就是 "comprehensive but compact"
（`rigor: full` + `docs.density: terse`）仍可表达的原因。六项中的两项——
`modes.review_mode` 和 `team.size`——是个人体验类配置项，也
仍可从 `project.local.yaml` 覆盖（该来源位于展开之上），
不像磁盘上的四项配置项那样被锁定。

> **让此表与辅助函数保持一致。** 此处列出的每个配置项都必须携带
> `_yaml_helper_defaults` 返回的值（通过 `get_yaml_default` 读取它），
> 且六个前置配置项都不得出现在其中。

**`testing.strict.*` 有意没有中央默认值。** 其未设置时的默认值
按技能设计而异：`/smoke-check` 把未设置视为**阻塞**（它是
构建健康闸门），而 `/story-done` 和 `/dev-story` 应用
`.claude/docs/coding-standards.md` 中的按故事类型表。因此 `testing.strict` 行
只报告*配置状态*（缺失处为 `unset`）。`gate_level` 行
（见下文）应用该表，并在 `config` 旁标明 `/smoke-check` 自己的默认值。

**`engine` 行只从 `project.yaml` 报告。** `engine_values`
行（见下文）增加了到 `.claude/docs/technical-preferences.md` 的逐字段回退，
后者也仍是禁止模式与允许库的唯一来源——那些从未迁移。

## 派生行（仅按名输出）

另外六行给出技能本来需要手工推导的答案。每行**仅在 `--keys` 中点名时**打印；
完整的配置块从不包含它们。每个值都以括号携带其来源，YAML `null`
或 `~` 视为未设置（读取器把它们作为字符串返回，这些字符串并非空值）。

| 标签 | 打印内容 |
|---|---|
| `gate_level` | 按故事类型的闸门级别：`testing.strict.<type>`（先 `project.local.yaml`，再 `project.yaml`），然后是普通的 `testing.strict: true\|false`，最后是 `coding-standards.md` 中的默认表。`gate_level: logic=blocking(default) integration=advisory(project.yaml) visual=blocking(default) ui=blocking(default) config=advisory(default; /smoke-check: blocking)` |
| `engine_values` | `engine.name`、`.version` 和 `.language`，各自回退到 `technical-preferences.md`（其 Engine 行同时包含名称和版本）。`engine_values: name=Godot(project.yaml) version=4.7(project.yaml) language=GDScript(project.yaml)` |
| `specialists` | 引擎专家：`primary` 来自引擎，其余来自 `specialists` 块，其中 `null` 表示未设置，绝不是 agent 名；仅当该块缺失时才来自 `technical-preferences.md`。`specialists: primary=godot-specialist(engine.name) code=godot-gdscript-specialist shader=unset ui=godot-specialist additional=none (project.yaml; unset = skip that specialist)` |
| `review_gate` | 技能自己的总监闸门和 PHASE-GATE 是否以已解析的 `review_mode` 运行（`director-gates.md`）：`solo` 无，`lean` 仅 PHASE-GATE，`full` 全部。`review_gate: skill-gates=skip phase-gates=run (review_mode lean, rigor:standard; a --review flag overrides)` |
| `input_methods` | 来自 `platform` 块的输入方式，每项列出一次：当 `PC` 或 `Web` 是目标时包含键盘/鼠标，当手柄和触摸的支持级别为 Full 或 Partial 时包含它们，再加上主要输入，其中 `Keyboard`、`Controller` 或 `Touchscreen` 等主要输入分别读作键盘/鼠标、手柄或触摸；否则使用 `technical-preferences.md` 的 Input Methods 行。`input_methods: keyboard/mouse, gamepad (project.yaml platform; primary: Gamepad)` |
| `perf_budgets` | 四个 `performance.*` 预算（`target_framerate`、`frame_budget_ms`、`draw_call_limit`、`memory_ceiling_mb`），仅来自 `project.yaml`：它们不可在本地覆盖。`perf_budgets: target_framerate=60 frame_budget_ms=16.67 draw_call_limit=unset memory_ceiling_mb=unset (project.yaml)` |

## 失败模式

`resolve_config` **总是退出 0，并总是输出完整配置块。** 以下每种
情况都会降级为默认值，并在 `notes:` 中点名：

| 情况 | 行为 |
|---|---|
| `project.yaml` 缺失 | 旧版 → 默认值；`notes: project.yaml absent` |
| `project.yaml` **为空** | 默认值；`notes: project.yaml is EMPTY`。有意与缺失区分——截断的写入或中断的 `/setup-engine` 看起来就是这样 |
| YAML 格式错误 | 无法解析的键解析为空并继续向下回退 |
| 制表符缩进行 | 被拒绝，且**行号会在 `notes:` 中点名** |
| CRLF 行尾 | 正确解析（Windows 默认） |
| UTF-8 BOM | 正确解析；BOM 不会污染第一个键 |
| 3 空格缩进 | 正确解析；解析器对缩进宽容 |
| 键存在，值为空 | 视为**未设置**；回退到下一个来源，绝不回退为 `""` |
| 枚举无效的值 | 链继续；被拒绝的值在 `notes:` 中点名 |
| 重复键（两个 `modes:` 块，或同一块中 `rigor:` 出现两次） | 重复块会被**合并**，因此任一块中的每个键都会被读取；设置两次的键取**最后**一个值。在 `notes:` 中附其行号点名——``duplicate key `modes` (lines 2, 9): read here as one merged block, …`` |
| `project.local.yaml` 缺少基础文件 | `validate_local_yaml_base` 消息出现在 `notes:` |
| `project.local.yaml` 中的锁定键 | 一如既往被忽略，但现在会在 `notes:` 中**点名**——`local: not locally overridable, ignored — modes.rigor (move to project.yaml or delete)` |
| 无 Python 解释器 | 仅使用旧版文件和默认值；在 `notes:` 中**明确注明** |
| 完全没有配置块 | shell 预处理被禁用（`disableSkillShellExecution`）——使用上方的默认值表 |
| 配置块位置出现任务通知（"Command did not complete within its 120s timeout and was moved to the background"） | 设置行超出了 Claude Code 对技能 `!` 行的 120 秒限制，因为每个进程启动都被拖慢——通常是因为杀毒软件对项目文件夹的实时扫描。设置是存在的：自己从 `project.local.yaml`、然后 `project.yaml`、然后上方默认值表逐个读取每个键 |
| 引导行未获批准，或以非零退出 | **不是降级状态——技能根本不会渲染。** 见上文 "Why exactly this command" |

技能绝不能把缺失的配置块当作 "配置以某种有趣的方式未设置"。
它意味着配置块没有渲染；应应用默认值。例外是
那条任务通知：是设置行超时了，而不是设置本身，因此按该行所述读取
文件，而不是采用默认值。如果持续发生，请把项目文件夹排除在实时扫描之外。

### 不带注释就解析的输入

此处 `resolve_config` 遵循固定规则且不发出注释，因此它不会告诉你
你写的某内容未被使用。

| 输入 | 发生什么 | 发出的注释 |
|---|---|---|
| **形状错误**——本应是标量的地方是列表（`rigor:` 后跟 `- standard`） | 键解析为空，回退到默认值 | **无** |

枚举*无效*的值会被公示（`modes.workflow: 'medium' is not a valid
value … — ignored, chain continued`），重复键也会。形状错误则不会：
键存在但解析不出任何东西，这也正是带空值的键有意为之的行为
（上方 "Key present, value empty" 行），而 `resolve_config` 无法区分二者。
当某项设置似乎被忽略时，检查文件中其键的结构：键自己的行上只有一个标量，
其下没有列表。`/settings` 显示实际生效的值。

合并重复块并取重复键的最后一个值，是此处的固定
规则，但大多数其他 YAML 工具只保留最后一个块。请合并重复
块，而不要依赖该合并。

## 为何不在会话开始时注入

`resolve_config` 也可以安全地从钩子调用，但会话启动**不会**
调用它。无论是否有任何技能需要配置，该配置块都会在每次会话中消耗 token，
而且随着 `/settings` 的写入落地，它会在会话中途变旧。按技能正文调用
更新鲜，且只在被使用的地方加载。会话启动仍会打印已解析的评审模式和任何 schema
错误，这是人需要阅读的部分。

## 测试

解析链、旧版读取器、枚举回退、配置块形状以及上述每种失败模式
都由 `tests/` 下框架自带的测试套件覆盖，也包括 `modes.rigor` 展开
及其两个方向上的优先级。有两个容易丢失的属性被断言：

- 本地**读取**范围与 `/settings --local` **写入**白名单保持
  一致。如果它们漂移，`/settings` 接受并显示的值会被每个
  技能忽略。
- 该展开是*可触达的*（`/start` 会询问它）且*可读的*
  （`/settings` 报告派生值，而不是 "(not set)"）。一个没人被询问、也没有任何视图
  显示的正确展开将毫无价值。
