# /setup-engine — 第 11 节：升级子命令

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 11. 升级子命令

**本文件内容：**

- 步骤 1 — 读取当前版本状态
- 步骤 2 — 获取迁移指南
- 步骤 3 — 升级前审计
- 步骤 4 — 更新前确认
- 步骤 5 — 更新 VERSION.md
- 步骤 6 — 升级后提醒

如果以 `/setup-engine upgrade [old-version] [new-version]` 调用：

### 步骤 1 — 读取当前版本状态

读取 `docs/engine-reference/<engine>/VERSION.md`，确认当前固定的
版本、风险等级，以及已记录的任何迁移说明 URL。如果
`old-version` 未作为参数提供，则使用该文件中固定的版本。

### 步骤 2 — 获取迁移指南

使用 WebSearch 和 WebFetch 查找 `old-version` 与 `new-version` 之间的官方迁移指南：

- 搜索：`"[engine] [old-version] to [new-version] migration guide"`
- 搜索：`"[engine] [new-version] breaking changes changelog"`
- 如果 VERSION.md 中已记录迁移指南 URL，则从中获取，否则
  使用搜索找到的 URL。

提取：重命名的 API、移除的 API、变更的默认值、行为变化，以及
任何"必须迁移"的条目。

### 步骤 3 — 升级前审计

扫描**代码根目录**（按 `.trae/docs/code-root-resolution.md` 解析），查找使用了目标版本中已知会弃用或发生变更的 API 的代码：

- 使用 Grep 搜索从迁移指南中提取的弃用 API 名称
  （例如旧函数名、移除的节点类型、变更的属性名）
- 列出每个匹配的文件，并给出找到的具体 API 引用

以表格形式呈现审计结果：

```
Pre-Upgrade Audit: [engine] [old-version] → [new-version]
==========================================================

Files requiring changes:
  File                              | Deprecated API Found       | Effort
  --------------------------------- | -------------------------- | ------
  src/gameplay/player_movement.gd   | old_api_name               | Low
  src/ui/hud.gd                     | removed_node_type          | Medium

Breaking changes to watch for:
  - [change description from migration guide]
  - [change description from migration guide]

Recommended migration order (dependency-sorted):
  1. [system/layer with fewest dependencies first]
  2. [next system]
  ...
```

如果代码根目录中未找到弃用的 API，报告："代码根目录中未发现弃用 API
的使用 — 升级风险可能较低。"

### 步骤 4 — 更新前确认

在做任何更改之前询问用户：

> "升级前审计完成。发现 [N] 个文件使用了弃用的 API。
> 是否继续将 VERSION.md 升级到 [new-version]？
> （这会更新固定版本并添加迁移说明 — 不会
> 更改任何源文件。源代码迁移需手动完成或通过用户故事完成。）"

等待明确确认后再继续。

### 步骤 5 — 更新 VERSION.md

确认之后：

1. 更新 `docs/engine-reference/<engine>/VERSION.md`：
   - `Engine Version` → `[new-version]`
   - `Project Pinned` → 今天的日期
   - `Last Docs Verified` → 今天的日期
   - 如果新版本超出 LLM 知识截止时间，重新评估并更新 `Risk Level` 和
     `Post-Cutoff Version Timeline` 表
   - 添加 `## Migration Notes — [old-version] → [new-version]` 章节，
     包含：迁移指南 URL、关键破坏性变更、本项目中发现
     的弃用 API，以及审计给出的建议迁移顺序

2. 如果引擎参考资料目录中存在 `breaking-changes.md` 或 `deprecated-apis.md`，
   将新版本的变更追加到这些文件中。

3. 如果仓库根目录存在 `project.yaml` 且包含 `engine` 块，先 Read 它，
   然后将 `engine.version` 更新为 `[new-version]`，使主配置
   存储与 VERSION.md 保持同步。

### 步骤 6 — 升级后提醒

更新 VERSION.md 之后，输出：

```
VERSION.md updated: [engine] [old-version] → [new-version]

Next steps:
1. Migrate deprecated API usages in the [N] files listed above
2. Run /setup-engine refresh after upgrading the actual engine binary to
   verify no new deprecations were missed
3. Run /architecture-review — the engine upgrade may invalidate ADRs that
   reference specific APIs or engine capabilities
4. If any ADRs are invalidated, run /propagate-design-change to update
   downstream stories
```

---
