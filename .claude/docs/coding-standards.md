# 编码标准

- 所有游戏代码的公共 API 都必须包含文档注释
- 架构决策以 ADR 形式记录在 `docs/architecture/` 中。**要记录多少由 `modes.workflow` 决定** —— `full` 下记录全部 ADR，`standard` 下只记录*关键* ADR，`minimal` 下不作要求，此时由决策日志和 `design/game-brief.md` 承载理由。参见 `.claude/docs/workflow-modes.md`。
- 玩法数值必须数据驱动（外部配置），绝不硬编码
- 所有公共方法都必须可进行单元测试（用依赖注入替代单例）
- 提交（commit）必须引用相关的设计文档或任务 ID
- **提交信息**：使用 Conventional Commits 格式 —— `feat:`、`fix:`、`chore:`、`docs:`、`test:`、`refactor:`。在正文中引用故事或任务 ID（例如 `Story: EPIC-001-S02`）。
- **验证驱动开发**：新增玩法系统时先写测试。
  对于 UI 变更，用截图验证。在将工作标记为完成之前，比较预期输出与实际输出。
  每次实现都应当有一种能证明其有效的方式。
- **解析检查不等于实际运行。** 每个改变了玩家可观察内容的故事在关闭前都必须启动并观察，
  且观察结果要是保留在 `production/qa/evidence/` 中的截图。各引擎的操作流程见
  `.claude/docs/run-and-observe.md`。在 `qa.level: minimal` 下也不豁免 —— 可以豁免的是测试，不是实际观察。

# 设计文档标准

- 所有设计文档使用 Markdown
- 每个机制在 `design/gdd/` 中都有专属文档
- **这 8 个章节中有多少是必需的取决于 `modes.workflow`** ——
  `full` 下全部 8 个，`standard` 下 5 个（当系统定义了数值规则 —— 速率、
  曲线、阈值、成本 —— 时再加 Formulas；系统的 `Category` 只是提示，不是判断依据），
  而 `minimal` 下完全不需要
  GDD，此时 `design/game-brief.md` 就是设计记录。
  参见 `.claude/docs/workflow-modes.md`。这 8 个章节为：
  1. **Overview** —— 一段话概述
  2. **Player Fantasy** —— 预期的感受与体验
  3. **Detailed Rules** —— 无歧义的机制
  4. **Formulas** —— 用变量定义的所有数学计算
  5. **Edge Cases** —— 已处理的特殊情况
  6. **Dependencies** —— 列出的其他系统
  7. **Tuning Knobs** —— 已识别的可配置数值
  8. **Acceptance Criteria** —— 可测试的成功条件
- 平衡数值必须链接到其来源公式或理由

# 测试标准

## 按故事类型的测试证据

所有故事在标记为 Done 之前都必须具备相应的测试证据：

| 故事类型 | 所需证据 | 位置 | 默认闸门级别 |
|---|---|---|---|
| **Logic**（公式、AI、状态机） | 自动化单元测试 —— 必须通过 | `tests/unit/[system]/` | BLOCKING |
| **Integration**（多系统） | 集成测试或已记录的试玩测试 | `tests/integration/[system]/` | BLOCKING |
| **Visual/Feel**（动画、VFX、手感） | 保留的截图 + 主管签核 | `production/qa/evidence/` | BLOCKING |
| **UI**（菜单、HUD、界面） | 每个涉及界面的保留截图 | `production/qa/evidence/` | BLOCKING |
| **Config/Data**（平衡调优） | 冒烟检查通过 | `production/qa/smoke-[date].md` | ADVISORY |

当 `project.yaml` 中未设置 `testing.strict` 时，适用**默认闸门级别**。项目可以按测试类型覆盖它：`testing.strict.logic`、`.integration`、`.visual`、`.ui` 和 `.config` 各自取 `true`（BLOCKING）或 `false`（ADVISORY）。`/story-done`、`/story-readiness`、`/dev-story`、`/gate-check` 和 `/smoke-check` 会从该设置解析出实际生效的级别，设置缺失时回退到上面的默认值。

> **为什么视觉和 UI 会阻塞。**「保留」是关键 —— 当故事关闭时，截图必须仍在磁盘上的 `production/qa/evidence/` 中。捕获后即丢弃的截图只是断言，不是证据。这两行之所以阻塞，是因为对游戏而言，它的样子*就是*产品：建议性的视觉闸门总会被推迟，让位于任何会阻塞的事项，结果就是一个测试良好但外观出错的游戏。

> **例外 —— `/smoke-check`。** 上面 **Config/Data** 的 ADVISORY 默认值适用于*按故事*收集的证据闸门。`/smoke-check` 是构建健康闸门，不是按故事收集证据的闸门，因此它自己针对 `testing.strict.config` 的未设置默认值是 **BLOCKING**。这两个默认值故意不同。

## 自动化测试规则

- **命名**：按引擎而定 —— `.claude/rules/test-standards.md`
- **确定性**：测试每次运行都必须产生相同结果 —— 不使用随机种子，不使用依赖时间的断言
- **隔离**：每个测试自行建立和清理自己的状态；测试不得依赖执行顺序
- **无硬编码数据**：测试夹具使用常量文件或工厂函数，而不是内联魔术数字
  （例外：边界值测试，其中确切数字*本身*就是重点）
- **独立性**：单元测试不调用外部 API、数据库或文件 I/O —— 使用依赖注入

## 不应自动化的内容

- 视觉保真度（着色器输出、VFX 外观、动画曲线）
- 「手感」特质（输入响应、感知重量、时机）
- 平台特定的渲染（在目标硬件上测试，而非无头测试）
- 完整的游戏会话（由试玩测试覆盖，而非自动化）

## CI/CD 规则

- 每次推送到 main 和每个 PR 都会运行自动化测试套件
- 测试失败则不得合并 —— 测试是 CI 中的阻塞闸门
- 绝不要为了通过 CI 而禁用或跳过失败的测试 —— 修复根本问题
- 引擎特定的 CI 命令：
  - **Godot**：`godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
  - **Unity**：`game-ci/unity-test-runner@v4`（GitHub Actions）
  - **Unreal**：带 `-nullrhi` 标志的无头运行器
