# Phase 6: Unity 和 Unreal 上的解析检查与捕获

仅在引擎为 Unity 或 Unreal 时阅读。报告命令、其退出码
和任何错误行。没有可执行文件：`parse NOT VERIFIED — engine binary not
available`。

## Unity

**解析检查：** `commands.smoke` 命令（`-batchmode -quit -projectPath .
-logFile -`）。退出码 1 并带有 `error CS…` 行表示某个脚本未编译通过。

**捕获**需要 `Assets/Scripts/ScreenshotOnArg.cs`，其内容在
`run-and-observe.md` 中逐字给出（`SKILL.md` 的 Phase 6 会点名它）。当项目没有该文件时
（查找 `Assets/**/ScreenshotOnArg.cs`），询问“May I write
`Assets/Scripts/ScreenshotOnArg.cs`?” 并在启动前完全按给定内容写入。被拒绝：什么都无法捕获，
因此报告
`Run result: NOT VERIFIED — ScreenshotOnArg.cs not written`。

## Unreal

**解析检查：** 构建编辑器目标。编译错误会导致失败（`Result:
Failed`，非零退出）。

- Windows：`"<UE root>/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" <Project>Editor Win64 Development -Project="<absolute path>/<Project>.uproject"`
- Linux：`"<UE root>/Engine/Build/BatchFiles/Linux/Build.sh" <Project>Editor Linux Development -Project=…`
- macOS：`"<UE root>/Engine/Build/BatchFiles/Mac/Build.sh" <Project>Editor Mac Development -Project=…`

这些命令来自 Epic 的文档，记录在
`docs/engine-reference/unreal/current-best-practices.md`（“Command Line”）中。

**捕获：** 直接启动到故事触及的地图，按
`run-and-observe.md` 给出。
