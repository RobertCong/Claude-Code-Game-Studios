---
alwaysApply: false
globs: Assets/**/*.asset,**/*.tscn,**/*.tres,**/*.unity,**/*.prefab
---

# 场景与资源文件规则

这些文件由引擎编辑器写入。手工编辑破坏其中一个，可能导致场景无法加载，或在没有报错的情况下丢失引用。尽量在编辑器里修改它们。

## Godot（`.tscn`、`.tres`、`.uid`）

当你手动编辑文本时：

- 绝不要修改 `[gd_scene]` 或 `[gd_resource]` 头部中的 `format=` 值。
- 绝不要复用 `id`：每个 `[ext_resource]` 和 `[sub_resource]` 的 id 在其文件中唯一。
- 绝不要连 `unique_id=` 一起复制节点块（Godot 4.6+）。复制时去掉它。
- 绝不要凭空编造 `uid://` 值。新的引用不要写 `uid=`，让编辑器或 `godot --headless --path . --import` 分配。
- 绝不要手动编辑 TileMapLayer 或 GridMap 的单元数据。它是编码过的，请在编辑器中修改。
- 绝不要编辑或删除 `.uid` 文件，并把它与对应脚本或着色器一起提交。Godot 4.4+ 会在每个脚本/着色器旁写一个；当你在编辑器外移动或重命名脚本或着色器时，一并移动它的 `.uid`。
- 手动编辑后，运行 `godot --headless --path . --import`，并打开或运行该场景一次，确认它能无错误加载。

## Unity（`.unity`、`.prefab`、`.asset`）

- 当 Unity 编辑器可达时（打开着本项目，或可通过其命令行或 MCP 工具访问），绝不要手动编辑 `.unity`、`.prefab` 或 `.asset` 的 YAML。编辑器持有自己的副本，下一次保存可能覆盖或与你的编辑冲突。请通过编辑器修改，或把操作步骤交给用户。如果你无法判断编辑器是否可达，按可达处理。
- 在没有编辑器可达时，保持所有 `fileID` 和 `guid` 引用完整，绝不凭空编造 GUID，绝不编辑或删除 `.meta` 文件，并在之后用编辑器打开场景确认其加载。
