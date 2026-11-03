# 可用技能

74 个按阶段组织的技能。在 Trae 中直接说「用 `<name>` 技能……」即可调用，Agent 也会根据 `description` 自动加载相关技能。

## 上手引导与导航

| 技能 | 用途 |
|---------|---------|
| `/start` | 首次上手引导 — 询问你当前所处的位置，然后引导你进入正确的工作流 |
| `/help` | 结合上下文的“我接下来该做什么？” — 读取当前阶段并给出必需的下一步 |
| `/project-stage-detect` | 完整项目审计 — 检测阶段、找出缺失项、建议后续步骤 |
| `/setup-engine` | 配置引擎与版本，检测知识缺口，填充与版本相关的参考资料文档 |
| `/adopt` | 既有项目格式审计 — 检查现有 GDD/ADR/用户故事的内部结构，产出迁移计划 |
| `/settings` | 查看或修改项目配置 — 生效的合并值，或 `project.local.yaml` 中的本地覆盖 |

## 游戏设计

| 技能 | 用途 |
|---------|---------|
| `/brainstorm` | 使用专业工作室方法（MDA、SDT、Bartle、动词优先）进行引导式创意发散 |
| `/map-systems` | 把游戏概念分解为系统，梳理依赖关系，排定设计优先级顺序 |
| `/design-system` | 针对单个游戏系统，逐章节引导编写 GDD |
| `/quick-design` | 面向小改动（调优、微调、小幅新增）的轻量设计规格 |
| `/review-all-gdds` | 跨 GDD 一致性以及所有设计文档的游戏设计整体性评审 |
| `/propagate-design-change` | GDD 修订后，找出受影响的 ADR 并产出影响报告 |

## 美术与资源

| 技能 | 用途 |
|---------|---------|
| `/art-bible` | 逐章节引导编写美术圣经 — 在资源生产开始前创建视觉识别规格 |
| `/asset-spec` | 根据 GDD、关卡文档或角色档案生成逐个资源的视觉规格与 AI 生成提示词 |
| `/asset-audit` | 审计资源的命名约定、文件大小预算与流水线合规性 |

## 用户体验与界面设计

| 技能 | 用途 |
|---------|---------|
| `/ux-design` | 逐章节引导编写用户体验规格（屏幕/流程、HUD 或模式库） |
| `/ux-review` | 校验用户体验规格是否符合 GDD、无障碍要求与模式规范 |

## 架构

| 技能 | 用途 |
|---------|---------|
| `/create-architecture` | 引导编写主架构文档 |
| `/architecture-decision` | 创建架构决策记录（ADR） |
| `/architecture-review` | 校验所有 ADR 的完整性、依赖顺序与 GDD 覆盖 |
| `/create-control-manifest` | 根据已接受的 ADR 生成扁平化的程序员规则表 |

## 用户故事与冲刺

| 技能 | 用途 |
|---------|---------|
| `/create-epics` | 将 GDD 与 ADR 转化为史诗 — 每个架构模块一个 |
| `/create-stories` | 把单个史诗拆分为可实现的故事文件 |
| `/dev-story` | 读取用户故事并实现它 — 路由到正确的程序员代理 |
| `/sprint-plan` | 生成或更新冲刺计划；初始化 sprint-status.yaml |
| `/sprint-status` | 快速生成 30 行的冲刺快照（读取 sprint-status.yaml） |
| `/story-readiness` | 在领取之前校验用户故事是否已具备实现条件（READY/NEEDS WORK/BLOCKED） |
| `/story-done` | 实现后的 8 阶段完成评审；更新用户故事文件并给出下一个用户故事 |
| `/estimate` | 结构化工作量估算，含复杂度、依赖与风险分解 |

## 评审与分析

| 技能 | 用途 |
|---------|---------|
| `/design-review` | 评审游戏设计文档的完整性与一致性 |
| `/code-review` | 针对文件或变更集的架构级代码评审 |
| `/balance-check` | 分析游戏平衡性数据、公式与配置 — 标记异常值 |
| `/content-audit` | 将 GDD 规定的内容数量与实际实现的内容进行审计对比 |
| `/scope-check` | 对照原始计划分析功能或冲刺范围，标记范围蔓延 |
| `/perf-profile` | 结构化性能剖析，识别瓶颈 |
| `/tech-debt` | 扫描、跟踪、排序并报告技术债 |
| `/gate-check` | 校验在开发阶段之间推进的就绪度（PASS/CONCERNS/NOT ASSESSED/FAIL） |
| `/consistency-check` | 将所有 GDD 与实体注册表比对，检测跨文档不一致（数值、名称、相互矛盾的规则） |
| `/security-audit` | 审计游戏的安全漏洞：存档篡改、作弊途径、网络漏洞、数据暴露与输入校验缺口 |

## 质量保证与测试

| 技能 | 用途 |
|---------|---------|
| `/qa-plan` | 为某个冲刺或功能生成质量保证测试计划 |
| `/smoke-check` | 在质量保证交接前运行关键路径冒烟测试闸门 |
| `/soak-test` | 为长时间游玩会话生成浸泡测试方案 |
| `/regression-suite` | 将测试覆盖率映射到 GDD 关键路径，找出没有回归测试的已修复缺陷 |
| `/test-setup` | 为项目所用引擎搭建测试框架与 CI/CD 流水线 |
| `/test-helpers` | 为测试套件生成引擎专属的测试辅助库 |
| `/test-evidence-review` | 对测试文件与人工证据文档进行质量评审 |
| `/test-flakiness` | 从 CI 运行日志中检测非确定性（不稳定）测试 |
| `/skill-test` | 校验技能文件的结构合规性与行为正确性 |
| `/skill-improve` | 通过测试—修复—重测循环改进技能 — 诊断、提出修复、重写、验证 |

## 制作

| 技能 | 用途 |
|---------|---------|
| `/milestone-review` | 评审里程碑进度并生成状态报告 |
| `/retrospective` | 开展结构化的冲刺或里程碑回顾 |
| `/bug-report` | 创建结构化的缺陷报告 |
| `/bug-triage` | 读取所有未关闭缺陷，重新评估优先级与严重程度，指派负责人与标签 |
| `/reverse-document` | 根据现有实现生成设计或架构文档 |
| `/playtest-report` | 生成结构化的试玩测试报告，或分析已有的试玩测试笔记 |

## 发布

| 技能 | 用途 |
|---------|---------|
| `/release-checklist` | 为当前构建生成并校验发布前检查清单 |
| `/launch-checklist` | 完成跨所有部门的发布就绪验证 |
| `/changelog` | 根据 git 提交与冲刺数据自动生成变更日志 |
| `/patch-notes` | 根据 git 历史与内部数据生成面向玩家的补丁说明 |
| `/hotfix` | 带审计轨迹的紧急修复工作流，绕过常规冲刺流程 |
| `/day-one-patch` | 为金母版之后、公开发布之前或发布时发现的已知问题准备聚焦的首日补丁 |

## 创意与内容

| 技能 | 用途 |
|---------|---------|
| `/prototype` | 概念原型 — 头脑风暴后立即构建用于验证核心想法的一次性构建（Phase 1） |
| `/vertical-slice` | 预制作阶段验证 — 在投入 Production 之前构建达到生产质量的端到端版本（Phase 4） |
| `/onboard` | 为新贡献者或代理生成结合上下文的引导文档 |
| `/localize` | 本地化工作流：字符串提取、校验、翻译就绪检查 |

## 团队编排

在单个功能领域上协调多个代理：

| 命令 | 协调的代理 |
|---------|-------------|
| `/team-combat` | game-designer + gameplay-programmer + ai-programmer + technical-artist + sound-designer + qa-tester |
| `/team-narrative` | narrative-director + writer + world-builder + level-designer |
| `/team-ui` | ux-designer + ui-programmer + art-director + accessibility-specialist |
| `/team-release` | release-manager + qa-lead + devops-engineer + producer |
| `/team-polish` | performance-analyst + technical-artist + sound-designer + qa-tester |
| `/team-audio` | audio-director + sound-designer + technical-artist + gameplay-programmer |
| `/team-level` | level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester |
| `/team-live-ops` | live-ops-designer + economy-designer + community-manager + analytics-engineer |
| `/team-qa` | qa-lead + qa-tester + gameplay-programmer + producer |

## 与 Trae 内置技能的重叠

Trae 自带一组以 `TRAE-` 为前缀的内置技能，与本项目的 `code-review` 功能相邻但不冲突。

| 你调用 | 实际得到 | 适用场景 |
|---------|---------|-----------|
| `code-review` | **CCGS 的**项目技能 | 对照本项目的编码标准、SOLID、可测试性与控制清单进行架构评审。它了解 ADR、用户故事和 `docs/architecture/`。 |
| `TRAE-code-review` | **Trae 内置**的通用代码评审 | 评审拉取请求或普通 diff 中的正确性缺陷，不涉及 CCGS 的设计文档或闸门。 |

两者都有用；它们回答不同的问题。在 `dev-story` 期间以及 `story-done` 之前使用
CCGS 的那个，因为它检查的正是后续闸门会检查的内容。当你需要对与用户故事无关的
diff 做通用评审时，使用内置的那个。

CCGS **不会**关闭 Trae 的内置技能。如果你希望减少技能列表噪音，在 Trae 的技能面板中按需禁用单个内置技能，而不是移除整个技能集。
