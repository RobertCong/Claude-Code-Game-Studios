# Claude Code Game Studios —— 游戏工作室代理架构

通过 49 个协同工作的 Claude Code 子代理管理独立游戏开发。每个代理负责特定领域，强制执行关注点分离与质量。

## 技术栈

- **引擎**：[选择：Godot 4 / Unity / Unreal Engine 5]
- **语言**：[选择：GDScript / C# / C++ / Blueprint]
- **版本控制**：Git，采用主干开发
- **构建系统**：[选择引擎后指定]
- **资源流水线**：[选择引擎后指定]

> **注意**：Godot、Unity 和 Unreal 都有引擎专家代理，并配有专门的子专家。请使用与你的引擎匹配的一组。

## 项目结构

@.claude/docs/directory-structure.md

## 引擎版本参考

<!-- ENGINE-REFERENCE-IMPORT: the line below is engine-specific. /setup-engine
     rewrites it to @docs/engine-reference/<engine>/VERSION.md for the chosen
     engine, so a Unity or Unreal project stops loading the Godot reference every
     session. It defaults to Godot (the template's example engine); skills that
     need the pinned version read docs/engine-reference/<engine>/VERSION.md on
     demand regardless of this import. -->
@docs/engine-reference/godot/VERSION.md


## 技术偏好

仓库根目录的 `project.yaml` 是主要配置存储——引擎、专家、命名、平台、性能、模式。技能通过 `resolve_config` 解析它（见 `.claude/docs/config-resolution.md`）。

`.claude/docs/technical-preferences.md` 是**旧版回退**，当某个键在 `project.yaml` 中缺失时按需读取。它不在这里导入：在 `/setup-engine` 运行前，它几乎全是 `[TO BE CONFIGURED]` 占位符；运行后，`project.yaml` 持有真实值。

## 协作规则

@.claude/docs/coordination-rules.md

## 协作协议

**用户驱动的协作，而非自主执行。**
每个任务都遵循：**提问 -> 选项 -> 决策 -> 草稿 -> 批准**

- 代理在使用 Write/Edit 工具前必须询问「我可以把它写入 [filepath] 吗？」（豁免：向 `active.md` 追加、代理记忆、子代理在编排技能指定路径上新建文件；见 `.claude/rules/agent-memory.md`）
- 代理在请求批准前必须展示草稿或摘要
- 多文件变更需要用户对完整变更集明确批准
- 未经用户指示不得提交
- 跳过或关闭的问题不是回答：什么都不要做，用纯文本重新提问并等待
- 不在本文件所在文件夹启动？先警告：钩子、拒绝规则和先询问模式只在 Claude Code 从此处启动时加载

完整协议与示例见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

> **第一次会话？** 如果项目尚未配置引擎且没有游戏概念，运行 `/start` 开始引导式上手流程。

## 编码标准

@.claude/docs/coding-standards.md

## 上下文管理

按需阅读 `.claude/docs/context-management.md`——它是参考资料，不是会话上下文。其中两条约定是承重性的，并被仓库其他地方按名称引用，因此在此重申以免丢失：

- **`production/session-state/active.md` 是会话检查点。** 文件才是记忆，而不是对话。在任何压缩、崩溃或 `/clear` 之后先读它。
- **`.claude/scripts/` 中的辅助脚本只输出观察，绝不输出裁决。** 一个打分或评判的脚本最终会与它看不到的模式或覆盖设置冲突。（`artifact-check.sh` 和 `adr-dep-graph.sh` 引用了这一点。）
