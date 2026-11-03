---
name: gate-check
description: "准备好推进到下一个开发阶段了吗？给出 PASS/CONCERNS/NOT ASSESSED/FAIL 结论，并列出阻塞项与所需产出物。『可以进入制作阶段了吗？』"
argument-hint: "[target-phase: systems-design | technical-setup | pre-production | production | polish | release] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,workflow,qa.level,testing.strict,performance.enforce,team.size,project.stage,system_overrides`

以上命令的输出即解析结果——直接使用；`--review` 会覆盖 `review_mode`。若无解析块，则采用
`.trae/docs/config-resolution.md` 中的默认值。

# 阶段质量闸门校验

本技能校验项目是否已准备好推进到下一个开发阶段。它会检查必需的产出物、质量标准和阻塞项。

**与 `/project-stage-detect` 的区别**：那个技能是诊断性的（“我们在哪里？”）。
本技能是规范性的（“我们准备好推进了吗？”，并给出正式结论）。

## 制作阶段（7 个）

项目会依次经历以下阶段：

1. **Concept（概念）** — 头脑风暴、游戏概念文档
2. **Systems Design（系统设计）** — 梳理系统、编写 GDD
3. **Technical Setup（技术搭建）** — 引擎配置、架构决策
4. **Pre-Production（预制作）** — 原型制作、垂直切片验证
5. **Production（制作）** — 功能开发（史诗/功能/任务跟踪已启用）
6. **Polish（打磨）** — 性能、试玩测试、缺陷修复
7. **Release（发布）** — 上线准备、认证

**当某个闸门通过时**（或用户明确接受 CONCERNS 结论的风险——第 6 节），要同时更新两处的阶段：在 `project.yaml` 中设置 `project.stage: <new-stage>`，并把新阶段名写入 `production/stage.txt`（单行，例如 `Production`）。双写可保持与尚未迁移的钩子向后兼容。这会立即更新状态行。

---

## 1. 解析参数

**目标阶段：** `$ARGUMENTS` 去掉所有 `--review <mode>` 组合后的内容（为空 = 自动检测当前阶段，然后校验下一次跃迁）。`/gate-check --review full` 不指定任何阶段。

注意：在 `solo` 模式下，会跳过总监派生（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）——gate-check 退化为仅检查产出物是否存在。在 `lean` 模式下，阶段闸门总监仍会运行（阶段闸门正是 lean 模式的目的）；运行多少位由下文的 `workflow` 决定。

**`workflow`**（参见 `.trae/docs/workflow-modes.md`）：

`gate-check` 是项目级运行的，因此它使用项目级 `workflow` 来决定闸门整体的产出物清单（即加载的闸门文件），并在校验 MVP GDD 时，按系统查阅 `workflow_overrides.system_overrides.<system>`——被钉在更高层级的系统，必须先满足该层级的章节数，闸门才能通过，无论项目级工作流如何（见第 2b 节“按系统覆盖”）。

> **gate-check 遵循 `workflow`，但不受 `automation` 约束。** 产出物清单
> 随层级变化；协作提示协议（“协作协议”一节）始终适用——阶段闸门是
> 有意设置的人工检查点，绝不自动运行。

**`qa.level`**：控制阶段闸门对测试的强制程度，而 `workflow` 控制要求哪些产出物。`modes.rigor` 会同时设定两者；单独显式设置 `qa.level` 可只改变强制程度。在 `minimal` 下不适用任何测试闸门——测试证据与单元测试产出物项变为非必需，第 3 节的 `testing.strict` 检查成为空操作；冒烟检查不会放宽（第 2b 节）——但在此级别下 `/smoke-check` 会在没有游戏测试的情况下运行（其自动化行读作 WAIVED），因此构建检查（`commands.smoke`，未设置时用 `commands.build`）以及启动和关键路径检查就是底线——没有人启动过的构建属于 NOT ASSESSED——没有测试的项目仍可通过。在 `standard` 下，Logic + Integration 测试必须通过。在 `full` 下，需要完整的覆盖率检查 + 回归套件（覆盖率下限取自 `qa.coverage_minimum`，若已设置）。UI 与 Visual/Feel 用户故事所需的留存截图不属于测试项：没有任何 `qa.level` 会放宽它们（第 2b 节）。

**`team.size`**：不改变阶段闸门派生多少位总监——面板宽度是 `workflow` 的维度（第 4b 节）。该值只影响**每位总监评审内的专家深度**。
`individual` 使用核心专家组；`small` 使用标准组；`studio` 额外加入引擎子专家。它从不跳过总监——跳过总监是 `review_mode` 的职责。`review_mode` 与 `team.size` 都由 `modes.rigor` 设定——一次 rigor 选择同时设定两者——并且各自在被显式设置时仍会覆盖该维度（全 rigor 项目得到 `studio` 组；较轻层级得到 `individual`）。

- **带参数**：`/gate-check production` —— 校验是否已准备好进入该特定阶段
- **不带参数**：使用与 `/project-stage-detect` 相同的启发式方法自动检测当前阶段，然后**在运行前与用户确认**：

  使用 `AskUserQuestion`：
  - 提示：“检测到的阶段：**[当前阶段]**。即将运行 [当前] → [下一阶段] 跃迁的闸门。是否正确？”
  - 选项：
    - `[A] 是——运行此闸门`
    - `[B] 否——换一个闸门`（若选择此项，显示第二个控件，列出所有闸门选项：Concept → Systems Design、Systems Design → Technical Setup、Technical Setup → Pre-Production、Pre-Production → Production、Production → Polish、Polish → Release）
  
  未提供参数时，不要跳过此确认步骤。

---

## 2. 阶段闸门定义

每个闸门的清单——必需产出物、质量检查及其工作流层级的削减——都放在各自文件中。**只读取目标阶段跃迁那一行对应的文件；绝不加载其他文件。**

| 质量闸门 | 定义文件 |
|------|-----------------|
| Concept → Systems Design | `references/gate-systems-design.md` |
| Systems Design → Technical Setup | `references/gate-technical-setup.md` |
| Technical Setup → Pre-Production | `references/gate-pre-production.md` |
| Pre-Production → Production | `references/gate-production.md` |
| Production → Polish | `references/gate-polish.md` |
| Polish → Release | `references/gate-release.md` |

每个文件先陈述 `full` 基线，再给出该闸门在 `standard` 与 `minimal` 下的削减。采用第 1 节解析出的层级。

## 2b. 工作流层级调整

**现在读取 `references/2b-workflow-tier.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 3. 运行质量闸门校验

**现在读取 `references/3-run-gate-check.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 4. 协作式评估

**现在读取 `references/4-assessment.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 5. 输出结论

**现在读取 `references/5-verdict.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 6. 在 PASS 时更新阶段

**现在读取 `references/6-update-stage.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 7. 收尾的下一步控件

**现在读取 `references/7-next-steps.md` 并遵循它**——本阶段的步骤在该文件中，不在此处。如果本阶段对话被压缩或恢复，请再次读取。

## 协作协议

本技能遵循协作式设计原则：

1. **先扫描**：检查所有产出物与质量闸门
2. **询问未知项**：不要为你无法核实的事项假定 PASS
3. **呈现发现**：展示带状态的完整清单
4. **由用户决定**：结论只是建议——下一步做什么由用户最终决定；只有阶段写入与结论绑定（第 6 节）
5. **获取批准**：“我可以把这份闸门校验报告写入 production/gate-checks/ 吗？”
6. **绝不自动修复**：如果缺少必需产出物，报告 FAIL 结论并指出应运行的技能（例如“运行 `/test-setup`”）。不要创建缺失文件，也不要自动重跑闸门。为制造 PASS 而创建文件会破坏闸门的意义。

**绝不**阻止用户继续工作——结论只决定本技能是否写入新阶段。在 CONCERNS 下，用户可通过明确接受所列风险来推进，报告会记录这些风险（第 6 节）；在 FAIL 或 NOT ASSESSED 下，阶段保持原样，直到重跑通过为止，期间没有任何东西阻止用户继续处理阻塞项。