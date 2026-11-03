# /setup-engine — 第 3 节：查询当前版本

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 3. 查询当前版本

引擎选定之后：

- 如果已提供版本，直接使用
- 如果未提供版本，使用 WebSearch 查找最新的稳定版本：
  - 搜索：`"[engine] latest stable version [current year]"`
  - 与用户确认："最新的稳定版 [engine] 是 [version]。使用这个吗？"

### 将所选版本与实际安装的版本核对

通过网络搜索找到的版本是"存在的版本"，不是"开发者拥有的版本"。固定一个
他们无法运行的版本，意味着之后的所有指令 — 构建、测试、冒烟测试、
引擎参考资料 — 都指向一台机器上并不存在的引擎。

探测二进制文件（Bash），并把失败视为未知，绝不要视为不存在：

| 引擎 | 探测方式 |
|--------|-------|
| Godot | `godot --version`，否则在 PATH 中或平台的常见安装位置查找 `godot`/`Godot_v*`（macOS：bundle 内的二进制文件，`Godot.app/Contents/MacOS/Godot`） |
| Unity | Hub 的编辑器目录，然后是那个编辑器的 `-version` — Windows 上为 `C:/Program Files/Unity/Hub/Editor/<version>/Editor/Unity.exe`，macOS 上为 `/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity`，Linux 上为 `/home/<user>/Unity/Hub/Editor/<version>/Editor/Unity`。不要用裸 `Unity`：在 `PATH` 中它可能是 Unity 独立的 CLI，会拒绝 `-version` |
| Unreal | 启动器的安装目录（Windows 上 `C:/Program Files/Epic Games/` 下的 `UE_<version>` 文件夹）；其他平台上，询问引擎构建或安装在哪里。编辑器默认不在 `PATH` 中 |

保留探测找到的可执行文件（对 Godot 而言，即裸 `godot --version`
是否运行成功 — 也就是 `godot` 是否在 `PATH` 中）：第 5.5.1 节会把它写入 `commands.*`
和 `engine.path`。

然后：
- **匹配** — 用一行说明并继续。
- **不匹配** — 给出两个版本并询问，提供三个选项：固定已安装的
  版本、固定较新的版本稍后升级，或有意地固定较新的版本。记录回答；不要静默选择。
- **未找到 / 探测失败** — 报告 `installed version NOT DETERMINED` 并
  继续使用所选版本。**不要**把它报告为"未安装引擎"：无法运行的探测
  并未证明它不存在。

无论结果如何，都将其写入第 7 节的 `VERSION.md`，作为
`Installed at pin time` 行，以便之后的读者能区分有意超前固定版本
与偶然为之。

---
