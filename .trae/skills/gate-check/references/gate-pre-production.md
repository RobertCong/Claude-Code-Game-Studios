> 闸门定义，由 `/gate-check` 仅为目标阶段加载。
> 绝不加载其他五个——每次调用只适用一个闸门。




# 质量闸门：Technical Setup → Pre-Production

**必需产出物：**
- [ ] 已选定引擎（CLAUDE.md 技术栈不是 `[CHOOSE]`）
- [ ] 项目配置已填充（`project.yaml` 已设置 engine/naming/performance，或旧版 `.claude/docs/technical-preferences.md` 已填充）
- [ ] 美术圣经存在于 `design/art/art-bible.md`，且至少包含第 1–4 节（视觉识别基础）
- [ ] `docs/architecture/` 中至少有 3 份架构决策记录，覆盖
      Foundation 层系统（场景管理、事件架构、存档/读档）
- [ ] 引擎参考文档存在于 `docs/engine-reference/[engine]/`
- [ ] 测试框架已初始化：引擎的测试根存在——`tests/unit/` 与 `tests/integration/`（Godot）、`Assets/Tests/EditMode/` 与 `Assets/Tests/PlayMode/`（Unity），或 `Source/<Module>/Private/Tests/`（Unreal）；见 `.claude/docs/directory-structure.md`
- [ ] CI/CD 测试工作流存在于 `.github/workflows/tests.yml`（或等价物）
- [ ] 至少存在一个示例测试文件，以确认框架可用
- [ ] 主架构文档存在于 `docs/architecture/architecture.md`
- [ ] 架构可追溯性索引存在于 `docs/architecture/requirements-traceability.md`
- [ ] 已运行 `/architecture-review`（`docs/architecture/` 中存在评审报告文件）
- [ ] `design/accessibility-requirements.md` 存在，且已确定无障碍层级
- [ ] `design/ux/interaction-patterns.md` 存在（模式库已初始化，即便很简略）

**哪份 `/architecture-review` 报告才算数。** 读取每个
`docs/architecture/architecture-review-*.md` 的 `Mode:` 行，对下面每个检查项使用
模式确实检查了它的最新报告：

| 检查项 | 会检查它的模式 |
|---|---|
| `/architecture-review` 已运行 | `full` |
| 可追溯性矩阵的 Foundation 层缺口为零 | `full`、`coverage`、`rtm` |
| 引擎审计显示没有使用已弃用 API | `full`、`engine` |

`single-gdd` 报告只看到了一个系统，`consistency` 报告只比较了
ADR，因此两者在此都不算数。若没有任何报告的模式检查过某个项，
该项就是 NOT ASSESSED，绝不基于更窄的报告算作通过：点名最新报告的
模式以及能闭合它的运行（运行 `/architecture-review full`，或表中点名的
模式）。没有 `Mode:` 行的报告写于 1.2.0 之前，
无法说明它检查了什么，因此对这三项都不算数，正如
`/architecture-review` 自身的规则所述。

**质量检查：**
- [ ] 架构决策覆盖核心系统（渲染、输入、状态管理）
- [ ] 技术偏好已设置有命名约定和性能预算
- [ ] 无障碍层级已定义并记录（即便是“Basic”也可接受——未定义则不可）
- [ ] 至少一个界面的 UX 规格已开始（主菜单或核心 HUD 通常在 Technical Setup 期间设计）
- [ ] 所有 ADR 都有带引擎版本标记的 **Engine Compatibility 章节**
- [ ] 所有 ADR 都有明确关联 GDD 的 **GDD Requirements Addressed 章节**
- [ ] 没有 ADR 引用 `docs/engine-reference/[engine]/deprecated-apis.md` 中列出的 API
- [ ] 所有高风险引擎领域（依据 VERSION.md）都已在架构文档中
      被明确处理，或被标记为未决问题
- [ ] 架构可追溯性矩阵的 **Foundation 层缺口为零**
      （所有 Foundation 需求在进入 Pre-Production 前都必须有 ADR 覆盖）

**ADR 循环依赖检查**：运行确定性的图构建器，而不是
手工阅读每一份 ADR 来追踪依赖图——手工追踪十几份 ADR
最终总会漏掉一条边；脚本不会：
```
Bash: bash .claude/scripts/adr-dep-graph.sh
```
它会打印 `ADRS`、`EDGES`（每条 Depends-On 引用一行 `adr-A -> adr-B`）、
`NO_DEPS_SECTION`（没有 Depends On 的 ADR）、`UNFILLED_DEPS`（仍为模板占位符的
Depends On 行）、每个处于依赖环上的 ADR 对应的 `CYCLE:` 行
（并列出其进入该环的边）、`BLOCKED_BY_CYCLE`（不在环上但依赖
环中 ADR 的 ADR）以及 `ORDER`（其余部分，依赖在前）。
- **任何 `CYCLE:` 行 → FAIL**：“ADR 循环依赖：[`CYCLE:`
  行上的节点]。只要循环存在，两者都无法达到 Accepted。删除
  `CYCLE:` 行上显示的一条 ‘Depends On’ 边以打破循环。” 把
  `BLOCKED_BY_CYCLE` 中的 ADR 说明为在等待该循环，而不是循环的一部分：它们
  自己的边都不是要删除的那条。
- 没有 `CYCLE:` 行 → 此检查通过。但无环结果的可信度
  取决于依赖章节的完整度：如果 `NO_DEPS_SECTION` 或
  `UNFILLED_DEPS` 列出了许多 ADR，请把它作为 CONCERNS 注记呈现，
  而不是干净通过，并把每个 `UNFILLED_DEPS` ADR 都点名为未填写
  （它所依赖的内容未知，而不是没有依赖）。

**引擎校验**（先读 `docs/engine-reference/[engine]/VERSION.md`）：
- [ ] 触及 cutoff 之后引擎 API 的 ADR 都标记了 Knowledge Risk: HIGH/MEDIUM
- [ ] `/architecture-review` 的引擎审计显示没有使用已弃用 API
- [ ] 所有 ADR 对同一引擎版本保持一致（没有过期的版本引用）

## 工作流层级削减

以上清单是 **`full` 基线**。在较低层级应用已解析层级对应的
削减；未点名的条目保持上述状态。
削减只会*放宽*要求——`workflow_overrides` 是唯一会新增要求的
机制。

- **`full`** —— 引擎 + 美术圣经第 1–4 节及以上 + 3 份以上 ADR + 架构 + UX 规格已开始 + 无障碍文档 + 可追溯性索引全部必需
- **`standard`** —— 美术圣经**仅在存在视觉资源用户故事时**必需；ADR 削减为**仅关键（Foundation 层）**；UX 规格已开始、无障碍文档、交互模式、可追溯性索引 → 推荐
- **`minimal`** —— 只要求**引擎已配置**（minimal 底线）；其余一切**取消**
