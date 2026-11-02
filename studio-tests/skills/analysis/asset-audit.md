# Skill Test Spec: /asset-audit

## Skill Summary

`/asset-audit` 审计引擎的资源根——Godot 上为 `assets/`（美术、音频、vfx、着色器、数据），Unity 上为 `Assets/`，Unreal 上为 `Content/`——检查命名规范合规性、大小预算、格式标准、孤立资源和缺失资源。它从设计文档读取美术圣经或资源标准（Phase 1），解析引擎及其代码根，并用 Glob 扫描资源根（Phase 2），用预先批准的只读命令（`stat`、`file`、`od`、`wc`、`du`）测量大小和格式，并仅按美术圣经陈述的规则检查 Godot 名称与其自身模式的匹配——美术 `[category]_[name]_[variant]_[size].[ext]`，音频 `[category]_[context]_[name]_[variant].[ext]`，全部小写并使用下划线——而 Unity 和 Unreal 名称仅对照美术圣经陈述的规则检查。孤立资源和缺失资源通过在**代码根**中搜索资源引用来发现；GDD 层面的完整性是 `/content-audit` 的职责。报告只列出违规项，每个类别一张表，并点名它无法评估的每个章节。无法进行的测量为 `NOT ASSESSED`，绝不是估算。该技能为只读：不写入任何文件，也不调用任何总监质量闸门。结论按首个匹配优先：NON-COMPLIANT、WARNINGS、NOT ASSESSED、COMPLIANT——仅当至少扫描到一个资源且所有章节都已评估时才为 COMPLIANT。

---

## Static Assertions (Structural)

由 `/skill-test spec` 对照 SKILL.md 检查——无需夹具。

- [ ] 具有必需的前置元数据（frontmatter）字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含结论关键词：COMPLIANT、WARNINGS、NON-COMPLIANT、NOT ASSESSED
- [ ] 不要求「May I write」措辞（只读：`allowed-tools` 不含 Write/Edit，且技能声明不写入文件）
- [ ] 具有下一步交接（审计结果之后该做什么）

---

## Director Gate Checks

无。资源审计是只读分析技能；不调用任何质量闸门（gate）。

---

## Fixture Defaults

除非某个用例自己的 Fixture 另有说明，每个用例的 `project.yaml` 都设置 `modes.rigor: minimal` 和 `modes.automation: collaborative`，且没有 `project.local.yaml`。规则见 `studio-tests/CLAUDE.md` § Fixture defaults。

---

## Test Cases

### Case 1: 正常路径 — 所有资源都遵循命名规范

**Fixture:**
- `project.yaml`：`engine.name: godot`，因此资源根为 `assets/`，代码根为 `src/`
- `design/art/art-bible.md` Asset Standards：纹理 PNG、2 的幂、≤2MB；SFX OGG、44.1 kHz、≤500KB（无时长预算）
- `assets/art/characters/` 包含：`char_grunt_idle_512.png`、`char_sniper_run_512.png`（512×512 PNG，各 300KB）
- `assets/audio/sfx/` 包含：`sfx_player_jump_01.ogg`、`sfx_item_pickup_01.ogg`（OGG，44.1 kHz，80KB 且各不足 1 秒）
- `src/` 引用全部四个文件

**Input:** `/asset-audit`

**Expected behavior:**
1. 技能从 `design/art/art-bible.md` 读取资源标准（Phase 1）
2. 技能解析引擎为 Godot，并对 `assets/art/**/*` 和 `assets/audio/**/*` 执行 glob（Phase 2）
3. 每个名称都匹配 Phase 3 的美术或音频模式；每个文件都在预算内且格式符合预期；每个文件都被代码引用
4. 摘要显示扫描 4 个资源、所有违规计数均为 0、没有未评估章节；违规表为空
5. 结论为 COMPLIANT

**Assertions:**
- [ ] 审计覆盖美术和音频两个资源目录
- [ ] 每个文件都对照 Phase 3 命名模式和美术圣经中的大小预算检查
- [ ] 摘要报告 `Total assets scanned: 4`，命名、大小、格式、孤立和缺失计数均为零，且 `Sections not assessed: none`
- [ ] 结论为 COMPLIANT
- [ ] 不写入任何文件

---

### Case 2: 不合规 — 纹理超出大小预算

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `design/art/art-bible.md` 资源标准：纹理 PNG、2 的幂、≤2MB
- `assets/art/environment/` 包含 5 个命名正确、尺寸为 2 的幂的 PNG 纹理，且都被代码引用
- 其中 3 个为 4096×4096、各 4MB；2 个为 1024×1024、各 1MB

**Input:** `/asset-audit`

**Expected behavior:**
1. 技能从美术圣经读取 2MB 纹理预算
2. 技能用 `stat` 或 `du` 测量每个文件的大小——而不是估算
3. Size Violations 表列出 3 个超大文件，包含 Budget、Actual 和 Overage
4. 2 个在预算内的文件不出现在 Size Violations 表中；`Total assets scanned` 统计全部 5 个
5. 建议为每个超大文件给出各自的修复方案，点名目标——一个分辨率（例如 2048×2048）或可将其压缩到 2MB 以下的压缩设置
6. 结论为 NON-COMPLIANT

**Assertions:**
- [ ] 全部 3 个超大文件都出现在 Size Violations 表中，包含 Budget（2MB）、Actual（4MB）和 Overage
- [ ] 大小来自测量命令（`stat`/`du`），而不是估算
- [ ] 任何文件超出预算时结论为 NON-COMPLIANT
- [ ] 每个超大文件都有建议，点名其目标分辨率或压缩设置，而不只是「reduce size」
- [ ] 2 个在预算内的文件计入 `Total assets scanned`，但不列为违规

---

### Case 3: 格式问题 — 音乐格式错误

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `design/art/art-bible.md` 资源标准：SFX OGG ≤500KB；音乐 OGG 或 MP3 ≤8MB
- `assets/audio/music/music_menu_theme_01.wav` 存在（WAV 格式，6MB），被代码引用
- `assets/audio/sfx/sfx_player_footstep_01.ogg` 存在（OGG 格式，40KB），被代码引用

**Input:** `/asset-audit`

**Expected behavior:**
1. 技能应用 Phase 3 音频格式标准（SFX 用 OGG，音乐用 OGG/MP3）
2. 技能用 `file` 或读取文件头识别 WAV 文件的格式
3. Format Violations 表列出 `music_menu_theme_01.wav`，预期 OGG/MP3，实际 WAV
4. `sfx_player_footstep_01.ogg` 不出现在任何违规表中；两个文件都在各自大小预算内
5. 建议点名 WAV 文件的目标格式（重新导出为 OGG 或 MP3）
6. 结论为 WARNINGS（格式问题可修正）

**Assertions:**
- [ ] `music_menu_theme_01.wav` 出现在 Format Violations 表中，Expected Format 为 OGG/MP3，Actual Format 为 WAV
- [ ] 针对 WAV 文件的建议点名 OGG 或 MP3 作为其目标格式
- [ ] 仅有格式问题时结论为 WARNINGS（而非 NON-COMPLIANT）
- [ ] `sfx_player_footstep_01.ogg` 未列在任何违规表中
- [ ] 技能不修改或转换任何资源文件

---

### Case 4: 缺失资源 — 被代码引用但资源目录中缺失

**Fixture:**
- `project.yaml`：`engine.name: godot`；`design/art/art-bible.md` 设置纹理预算
- `assets/art/characters/` 存放另外 3 个命名正确、在预算内且被代码引用的纹理
- `src/enemies/boss.gd` 加载 `res://assets/art/characters/boss/char_boss_idle_512.png`
- `assets/art/characters/boss/` 为空——该文件不存在
- `design/gdd/enemies.md` 还点明 `char_boss_roar_512.png`，但没有任何代码引用它

**Input:** `/asset-audit`

**Expected behavior:**
1. 技能在代码中搜索资源引用（Phase 3「Missing assets」）并检查每个路径是否存在
2. 未找到 `char_boss_idle_512.png`
3. Missing Assets 表列出 Reference Location `src/enemies/boss.gd` 和 Expected Path
4. 仅存在于 GDD 中的名称 `char_boss_roar_512.png` 不会被报告——缺失资源检查搜索的是代码，而不是 GDD
5. 结论为 NON-COMPLIANT
6. 后续步骤指向 `/content-audit` 进行 GDD 交叉检查

**Assertions:**
- [ ] Missing Assets 表列出 `src/enemies/boss.gd` 作为引用位置、`assets/art/characters/boss/char_boss_idle_512.png` 作为预期路径
- [ ] 仅存在于 GDD 的资源名称不被报告为缺失
- [ ] 代码引用的资源缺失时结论为 NON-COMPLIANT
- [ ] 后续步骤点名 `/content-audit` 用于 GDD 与资源的完整性核对
- [ ] 技能不创建或添加占位资源

---

### Case 5: 无数据 — 没有资源也没有资源标准

**Fixture:**
- `project.yaml`：`engine.name: godot`、`modes.review_mode: full`
- `assets/` 不存在
- `design/art/art-bible.md` 不存在；没有设计文档定义资源标准

**Input:** `/asset-audit`

**Expected behavior:**
1. 技能在产出报告前运行输入不足检查：将每项输入记录为 FOUND 或 ABSENT
2. 每项必需输入都是 ABSENT，因此技能停止
3. 结论为 `NOT ASSESSED — NO DATA`，点名缺失的内容以及由哪个技能产出
4. 技能不报告 COMPLIANT，也不把零计数的违规表渲染为干净通过
5. 在任何评审模式下都不调用总监质量闸门；不写入文件，也不提供写入

**Assertions:**
- [ ] 在任何报告章节之前，输入被列为 FOUND / ABSENT
- [ ] 结论为 `NOT ASSESSED — NO DATA`，而不是 COMPLIANT
- [ ] 报告点名缺失的输入（`assets/`、资源标准）以及产出标准的技能（`/art-bible`）
- [ ] 即使评审模式为 `full`，也不调用总监质量闸门
- [ ] 不出现「May I write」提示，也不写入文件

---

### Case 6: 零资源 — 标准存在，但无内容可审计

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `design/art/art-bible.md` 资源标准：纹理 PNG ≤2MB；SFX OGG ≤500KB
- `assets/` 不存在；`src/` 存放的玩法代码尚未加载任何资源

**Input:** `/asset-audit`

**Expected behavior:**
1. 美术圣经为 FOUND，因此输入不足检查不会终止运行
2. Phase 2 对 `assets/` 执行 glob，未匹配到任何内容：`Total assets scanned: 0`
3. Naming、Size、Format 和 Orphaned 均为 `NOT ASSESSED — no assets under assets/`，且摘要列出它们；缺失资源搜索运行且未发现引用
4. 结论为 NOT ASSESSED——零文件上零违规并不等于合规

**Assertions:**
- [ ] `Total assets scanned` 为 0，四项文件检查为 NOT ASSESSED 并注明该原因
- [ ] 结论为 NOT ASSESSED，而不是 COMPLIANT
- [ ] 不写入任何文件

---

### Case 7: 无标准 — 资源存在，但任何地方都没有大小预算

**Fixture:**
- `project.yaml`：`engine.name: godot`
- `design/art/art-bible.md` 不存在；没有设计文档陈述资源标准
- `assets/art/ui/` 存放 3 个命名正确、尺寸为 2 的幂的 PNG；`src/` 引用全部三个

**Input:** `/asset-audit`

**Expected behavior:**
1. 资源为 FOUND、标准为 ABSENT，因此技能继续运行而不是停止
2. 检查 Naming、Format、Orphaned 和 Missing；都未发现违规
3. Size 为 `NOT ASSESSED — no size budget set`，报告点名 `/art-bible` 为编写标准的技能
4. 摘要在 Sections not assessed 下列出 Size
5. 结论为 NOT ASSESSED，并点名 Size

**Assertions:**
- [ ] 不依据臆造的预算评判任何大小
- [ ] Size 章节为 `NOT ASSESSED — no size budget set`，且点名 `/art-bible`
- [ ] 结论为 NOT ASSESSED，而不是 COMPLIANT

---

### Case 8: Unreal 项目 — 资源位于 `Content/` 下

**Fixture:**
- `project.yaml`：`engine.name: unreal`，因此代码根为 `Source/<Module>/`
- `design/art/art-bible.md` 资源标准：纹理 ≤4MB；未陈述命名规范
- `Content/Characters/Grunt/` 存放 `T_Grunt_D.uasset`（2.5MB）和 `T_Grunt_N.uasset`（2.1MB）
- `assets/` 不存在
- `Source/Arena/Private/GruntCharacter.cpp` 加载 `/Game/Characters/Grunt/T_Grunt_D`

**Input:** `/asset-audit`

**Expected behavior:**
1. Phase 2 对 `Content/**/*.uasset` 和 `Content/**/*.umap` 执行 glob，而不是 `assets/`：`Total assets scanned: 2`
2. 两个大小都对照 4MB 纹理预算测量；都未超出
3. PascalCase 名称不按 Godot 的小写模式检查；由于美术圣经中没有命名规则，Naming 为 `NOT ASSESSED — no naming rule for Unreal`，并点名 `/art-bible`
4. Format 为 NOT ASSESSED（Unreal 资源文件不保留其源格式），Orphaned 为 NOT ASSESSED（Unreal 资源由其他资源引用，而不只是从代码引用）
5. 代码引用解析到现有资源，因此 Missing 没有发现项
6. 结论为 NOT ASSESSED，并点名 Naming、Format 和 Orphaned

**Assertions:**
- [ ] 扫描覆盖 `Content/` 并计数 2 个资源，而不是 0
- [ ] 不会依据 Godot 小写模式提出命名违规
- [ ] Naming、Format 和 Orphaned 均列为 NOT ASSESSED 并附原因
- [ ] 结论为 NOT ASSESSED，绝不是 COMPLIANT，也绝不是零资源的报告

---

### Case 9: 引擎未解析 — 扫描前停止

**Fixture:**
- `project.yaml` 没有 `engine.name`；`.claude/docs/technical-preferences.md` 内容为 `[TO BE CONFIGURED]`
- `src/` 和 `Source/` 都存在，因此目录树无法判定引擎
- `design/art/art-bible.md` 有资源标准；`assets/art/` 存放 PNG 文件

**Input:** `/asset-audit`

**Expected behavior:**
1. Phase 2 无法按 `.claude/docs/code-root-resolution.md` 解析引擎或其代码根
2. 技能以 `NOT ASSESSED — engine unresolved` 停止，并点名 `/setup-engine`
3. 不猜测任何资源根，因此不应用 Godot 命名模式，也不把任何章节报告为干净

**Assertions:**
- [ ] 结论为 `NOT ASSESSED — engine unresolved`，而不是 COMPLIANT
- [ ] 输出点名 `/setup-engine`
- [ ] 不依据假定的 `assets/` 布局填充任何违规表

---

## Protocol Compliance

- [ ] 在扫描前读取美术圣经或资源标准设计文档（Phase 1）
- [ ] 解析引擎及其代码根，然后用 Glob 扫描该引擎的资源根（Godot 上的 `assets/` 子文件夹、Unity 上的 `Assets/`、Unreal 上的 `Content/`）；引擎未解析时以 NOT ASSESSED 停止运行
- [ ] 报告每个类别一张表：Naming（File、Expected Pattern、Issue）、Size（File、Budget、Actual、Overage）、Format（File、Expected Format、Actual Format）、Orphaned（File、Last Modified、Size、Recommendation）、Missing（Reference Location、Expected Path）
- [ ] 无法测量的大小或格式为 `NOT ASSESSED`，绝不是估算，且每个未评估章节都点名其原因
- [ ] 每条建议都点名针对其违规的改动（目标分辨率或压缩、修正后的名称、目标格式）
- [ ] 不修改任何资源文件，也不写入报告文件
- [ ] 不调用任何总监质量闸门
- [ ] 结论按首个匹配：NON-COMPLIANT、WARNINGS、NOT ASSESSED、COMPLIANT——仅当至少扫描到一个资源且所有章节都已评估时才为 COMPLIANT

---

## Coverage Notes

- 技能不检查导入元数据（Godot `.import` 文件、Unity `.meta` 文件、Unreal 导入设置）；缺失的导入设置不会被报告。
- Godot 上的孤立检测（没有代码引用的资源）没有单独用例；它使用与 Case 4 相同的代码搜索，只是方向相反。在 Unity 和 Unreal 上该检查为 NOT ASSESSED（Case 8）。
- Unity 遵循 Case 8 的命名和孤立规则，Format 仍检查 `Assets/` 下的源文件；未单独测试。
- `/asset-audit` 对照代码引用检查合规性；`/content-audit` 对照 GDD 检查完整性。Case 4 固定了这一边界。
- 音频时长预算无法用该技能的工具测量，因此该检查为 NOT ASSESSED；Case 1 的夹具未设置任何时长预算，该路径没有单独用例。
