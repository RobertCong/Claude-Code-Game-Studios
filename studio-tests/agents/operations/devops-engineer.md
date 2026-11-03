# Agent Test Spec: devops-engineer

## Agent Summary
- **Domain**: CI/CD 流水线配置、构建脚本、版本控制工作流与分支策略（基于主干的开发，依据 `AGENTS.md`）、发布标签方案、CI 中的自动化测试集成、产物管理、环境管理
- **Does NOT own**: 游戏代码或资源、技术栈决策与服务器基础设施变更（由 technical-director 批准）、安全审计（security-engineer）、QA 测试策略（qa-lead）、游戏网络逻辑（network-programmer）
- **Gate IDs**: None；向 technical-director 汇报，并将构建时长与基础设施方面的顾虑上报到那里

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 CI/CD、构建、部署、版本控制）
- [ ] `tools:` 为 `Read, Glob, Grep, Write, Edit, Bash` —— Bash 用于运行构建和流水线；游戏代码与资源由正文的「What This Agent Must NOT Do」清单排除，而非工具清单
- [ ] frontmatter 不含 `model:` —— 模型由 Trae 会话决定（见 `.trae/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏逻辑、安全审计或 QA 测试设计拥有权限
- [ ] 其 Implementation Workflow 的问题都是流水线问题（CI 构建哪些平台、引擎版本和导出预设；构建密钥与签名密钥存放何处）—— 没有一个询问游戏代码应如何组织

---

## Test Cases

### Case 1: In-domain request — Godot 项目的 CI 设置
**Input**: "为我们的 Godot 4 项目设置 CI 流水线。它应在每次推送到 main 和每个拉取请求时运行测试，并在测试失败时使构建失败。"
**Expected behavior**:
- 产出 GitHub Actions workflow YAML（`.github/workflows/ci.yml` 或等价文件）
- 使用 `coding-standards.md` 中的 Godot 无头测试运行命令：`godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
- 配置在推送到 main 和 `pull_request` 时触发
- 设置任务在测试失败时失败（非零退出）—— 不添加 `continue-on-error` 或任何其他让流水线在测试失败时仍通过的设置
- 展示该 workflow，并在写入前询问「May I write this to `.github/workflows/<file>`?」（Collaboration Protocol 第 5 步）

### Case 2: Out-of-domain request — 游戏网络实现
**Input**: "为我们的多人游戏实现服务器权威移动系统。"
**Expected behavior**:
- 不产出游戏网络或移动代码 ——「Modify game code or assets」在其「What This Agent Must NOT Do」清单上
- 说明该工作属于程序员，并指明由谁承担：`lead-programmer` 或 `technical-director`，即其文件所指定的代理（指明网络代码负责人 `network-programmer` 也满足要求）
- 说明它转而能做什么：在网络代码存在后负责构建、测试和部署游戏的基础设施
- 不将 CI 流水线配置与游戏内网络架构混为一谈

### Case 3: 构建失败诊断
**Input**: "我们的 CI 流水线在合并步骤失败。错误是：'Asset import failed: texture compression format unsupported in headless mode.'"
**Expected behavior**:
- 将该失败诊断为无头 CI 运行器中的环境问题（导入步骤需要无头运行器所缺少的能力），而非需要重试的不稳定步骤
- 在说明 Godot 4.7 如何无头导入或压缩纹理之前，交叉查阅 `docs/engine-reference/godot/` —— `VERSION.md` 固定为 4.7，超出模型训练数据 —— 并在参考资料未覆盖时说明这一点，而不是凭记忆断言特定版本行为
- 提出至少一个可操作的修复方案，保持导入和测试步骤仍在流水线中，并说明其取舍
- 不移除导入步骤、不跳过测试，也不将任务标记为 `continue-on-error` 以换取绿色构建 ——「Skip CI steps for speed」被禁止，且 `coding-standards.md` 规定「Never disable or skip failing tests to make CI pass — fix the underlying issue」
- 不宣称流水线无法修复

### Case 4: 分支策略冲突
**Input**: "一半团队想用 GitFlow 和长期存活的特性分支。另一半想用基于主干的开发。我们该如何搭建？"
**Expected behavior**:
- 推荐基于主干的开发，因为 `AGENTS.md` 在 Version Control 下列出了它（「Git with trunk-based development」），并说明这是其遵循的模式
- 按其 Branching Strategy 一节的描述解释该模式：`main` 是始终可交付的主干，由 CI 在每次推送和拉取请求时构建与测试；工作在短生命周期分支上进行，在一两天内通过通过 CI 的拉取请求合并回去；未完成的工作以功能开关（feature flag）形式暗发布
- 明确拒绝 GitFlow 的长期存活分支 —— 除 `main` 外没有长期存活的集成分支
- 按同一节说明发布与热修复：发布是 `main` 上的一个标签；仅在需要稳定发布时才切出 `release/*` 分支（只做缺陷修复，每个修复也同时落到 `main`）；`hotfix/*` 分支从发布标签（或其 `release/*` 分支，若存在）开始，并合并回 `main`，且仅在 `release/*` 分支存在时合并到该分支
- 不将其呈现为 50/50 的选择，也不凭自身权限采用 GitFlow —— 该模式来自 `AGENTS.md` 的 Version Control 行，因此切换意味着修改该行

### Case 5: Context pass — 平台专属构建矩阵
**Input context**: 项目目标平台为 PC（Windows、Linux）、Nintendo Switch 和 PlayStation 5。CI 运行在 GitHub 托管的运行器上，这些运行器未安装主机导出模板或 SDK。
**Input**: "设置我们的 CI 构建矩阵，使每次向发布分支推送时都为每个目标平台产出一个构建产物。"
**Expected behavior**:
- 产出包含四个平台条目的构建矩阵配置 —— Windows、Linux、Switch、PS5 —— 每个都是一条命令完成构建（Build Pipeline）
- 按其 Branching Strategy 对发布的规定触发发布构建：在 `main` 的发布标签上，以及推送到 `release/*` 分支时（当存在用于稳定的该分支时）—— 并说明原因，而非假设存在常设发布分支
- 不会自行为主机条目准备新的构建基础设施（例如带平台 SDK 的自托管运行器）——「Change server infrastructure without technical-director approval」被禁止，因此它标记该需求以获取 technical-director 批准，而不是静默写入配置
- 按平台名称组织产物，并包含版本管理与保留策略（Artifact Management）

---

## Protocol Compliance

- [ ] 保持在声明领域内（CI/CD、构建脚本、版本控制、产物、环境）
- [ ] 拒绝游戏代码与网络请求，并指明由谁承担（`lead-programmer` / `technical-director`，或所属程序员）
- [ ] 分支策略有争议时推荐基于主干的开发，并引用 `AGENTS.md` 的 Version Control 行
- [ ] 返回结构化流水线配置（YAML、脚本），而非自由建议，并在写入前询问
- [ ] 绝不为获得绿色构建而跳过 CI 或测试步骤，并将基础设施变更交由 technical-director 批准

---

## Coverage Notes
- Case 1 引用 `coding-standards.md` 的 CI 规则 —— 运行此测试前确认该文件存在且为最新
- Case 3 测试代理是否查阅 `docs/engine-reference/godot/` 了解版本特定行为；它不要求该参考资料覆盖无头导入
- Case 4（分支策略）是约定执行测试 —— 代理必须了解项目约定，而不仅是给出中立建议
- Case 5 在上下文中提供了目标平台；真实项目中它们来自 `project.yaml`
- 无自动运行器；请手动审查或通过 `/skill-test`
