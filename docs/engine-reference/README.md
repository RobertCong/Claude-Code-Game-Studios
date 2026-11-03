# Engine Reference Documentation

本目录包含本项目所用游戏引擎的精选、版本锁定的文档快照。
这些文件之所以存在，是因为 **LLM 知识存在截止日期**，而游戏引擎更新频繁。

## Why This Exists

模型的训练数据存在知识截止日期（目前为 2025 年 5 月）。Godot、Unity 和 Unreal
等游戏引擎发布的更新会引入破坏性 API 变更、新功能以及已弃用的模式。
如果没有这些参考资料，agent 会给出过时的代码。

## Structure

每个引擎都有自己的目录：

```
<engine>/
├── VERSION.md              # Pinned version, verification date, knowledge gap window
├── breaking-changes.md     # API changes between versions, organized by risk level
├── deprecated-apis.md      # "Don't use X → Use Y" lookup tables
├── current-best-practices.md  # New practices not in model training data
└── modules/                # Per-subsystem quick references (~150 lines max each)
    ├── rendering.md
    ├── physics.md
    └── ...
```

## How Agents Use These Files

引擎专家 agent 被指示执行以下步骤：

1. 读取 `VERSION.md` 以确认当前引擎版本
2. 在建议任何引擎 API 之前先查看 `deprecated-apis.md`
3. 查阅 `breaking-changes.md` 了解与版本相关的注意事项
4. 阅读相关的 `modules/*.md` 以进行子系统相关的工作

## Maintenance

### When to Update

- 升级引擎版本之后
- LLM 模型更新（新的知识截止日期）之后
- 运行 `/setup-engine refresh` 之后
- 当你发现模型对某个 API 理解有误时

### How to Update

1. 用新的引擎版本和日期更新 `VERSION.md`
2. 为版本过渡向 `breaking-changes.md` 添加新条目
3. 将新近弃用的 API 移入 `deprecated-apis.md`
4. 用新模式更新 `current-best-practices.md`
5. 用 API 变更更新相关的 `modules/*.md`
6. 在所有修改过的文件上设置 "Last verified" 日期

### Quality Rules

- 每个文件都必须有 "Last verified: YYYY-MM-DD" 日期
- 模块文件保持在 150 行以内（上下文预算）
- 包含展示正确/错误模式的代码示例
- 链接到官方文档 URL 以便核实
- 只记录与模型训练数据不同的内容
