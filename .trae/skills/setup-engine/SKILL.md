---
name: setup-engine
description: "配置引擎与版本。将其固定写入 AGENTS.md；当版本超出 LLM 训练数据范围时，由 WebSearch 填充参考资料。"
argument-hint: "[engine] | [engine version] | refresh | upgrade [old-version] [new-version] | no args for guided selection"
user-invocable: true
---

# 引擎配置

当本技能被调用时：

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys workflow`

**层级感知。** 上一步命令输出中解析出的 `workflow` 层级决定本技能期望哪一份设计产出物，以及它在 §12 中推荐的收尾路径：
- **`minimal`** — 设计产出物是单页的 `design/game-brief.md`
  （该层级没有 GDD、系统拆解或逐系统设计）。
  在 minimal 路径中 `/setup-engine` *最先*运行，因此此处缺少简报是
  正常的，不是缺口。收尾路径是 4 步基线。
- **`standard` / `full`** — 设计产出物是 `design/gdd/game-concept.md`，
  收尾路径是完整流水线。

如果该代码块未渲染（shell 预处理被禁用），则假定为 `minimal`（默认值）。

## 1. 解析参数

四种模式：

- **完整规格**：`/setup-engine godot 4.7` — 已提供引擎和版本
- **仅引擎**：`/setup-engine unity` — 已提供引擎，版本稍后查询
- **无参数**：`/setup-engine` — 完全引导模式（引擎推荐 + 版本）
- **刷新**：`/setup-engine refresh` — 更新参考资料（见第 10 节）
- **升级**：`/setup-engine upgrade [old-version] [new-version]` — 迁移到新的引擎版本（见第 11 节）

---

## 2. 引导模式（无参数）

**现在读取 `references/2-guided-mode.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 3. 查询当前版本

**现在读取 `references/3-version.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 4. 更新 AGENTS.md 技术栈

**现在读取 `references/4-claude-md-stack.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 5. 填充技术偏好

**现在读取 `references/5-technical-preferences.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 5.5 填充 `project.yaml`（主配置存储）

**现在读取 `references/5.5-project-yaml.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 6. 判定知识缺口

**现在读取 `references/6-knowledge-gap.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 7. 填充引擎参考资料

**现在读取 `references/7-reference-docs.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 7.5 搭建引擎项目骨架

**现在读取 `references/7.5-scaffold.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 8. 校验 AGENTS.md 的导入

**现在读取 `references/8-verify.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 9. 更新 agent 指令

在做任何编辑之前询问："我可以在各引擎专家 agent 文件中添加一个版本感知（Version Awareness）章节吗？"

对于所选引擎的专家 agent，确认它们是否有
"Version Awareness" 章节。如果没有，参照现有 Godot 专家 agent
的模式添加一个。

该章节应指示 agent：
1. 读取 `docs/engine-reference/<engine>/VERSION.md`
2. 在建议代码之前检查是否有已弃用的 API
3. 检查相关版本过渡中的破坏性变更
4. 使用 WebSearch 验证不确定的 API

---

## 10. 刷新子命令

如果以 `/setup-engine refresh` 调用：

1. 读取现有的 `docs/engine-reference/<engine>/VERSION.md` 以获取
   当前引擎和版本
2. 使用 WebSearch 检查：
   - 自上次验证以来的新引擎发布
   - 更新的迁移指南
   - 新近弃用的 API
3. 用新发现更新所有参考资料
4. 更新所有已修改文件的 "Last verified" 日期
5. 报告变更内容

---

## 11. 升级子命令

**现在读取 `references/11-upgrade.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 12. 输出摘要

**现在读取 `references/12-output-summary.md` 并遵循它** — 本阶段的步骤在该文件中，不在此处。如果本阶段期间对话被压缩或恢复，请重新读取它。

## 防护规则

- 绝不要猜测引擎版本 — 始终通过 WebSearch 或用户确认来核实
- `project.yaml` 是主配置存储（v1.1）。始终将引擎配置双写到
  `project.yaml`（主）**和** `technical-preferences.md`（旧版镜像）
  两处。如果两者出现分歧，以 `project.yaml` 为准。
- 未经询问，绝不要覆盖现有参考资料 — 应追加或更新
- 如果已存在针对其他引擎的参考资料，替换前先询问
- 在编辑 AGENTS.md 之前，始终先向用户展示你将要更改的内容
- 如果 WebSearch 返回含糊的结果，展示给用户并由他们决定
- 当用户选择 **GDScript** 时：原样复制 `references/godot-language-config.md`
  中 **A1** 的 GDScript AGENTS.md 模板。绝不要向 Language 字段添加
  "C++ via GDExtension"。GDScript 项目可以使用 GDExtension，但它不是
  项目的主要语言。路由表中的 `godot-gdextension-specialist` 在需要原生扩展时
  可用 — 这并不使 C++ 成为项目语言。

---

## 附录 A — Godot 语言配置

已从本文件移出，以便在非 Godot 运行中不产生任何开销。

**当所选引擎为 Godot 时，读取**
`references/godot-language-config.md`
并使用所选语言对应的子节：

- **A1** — AGENTS.md 技术栈模板（GDScript / C# / Both）
- **A2** — 命名约定
- **A3** — 引擎专家路由与文件扩展名表

**加载纪律。** 对于 Godot 以外的任何引擎，**绝不要加载它** — 第 4、5 或 5.5 节中没有任何内容需要它，无论如何读取都会消耗掉拆分本文件所要节省的 token。在 Godot 上，第一次到达第 4 节时读取一次，并在第 5、5.5 节继续使用；不要在每次引用时重新读取。