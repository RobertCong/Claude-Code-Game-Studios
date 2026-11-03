# 技术偏好（Technical Preferences）

<!-- 仓库根目录的 project.yaml 是 engine、specialists、naming、performance、platform
     和 testing.framework 的机器可读事实来源。
     本文件是人类可读的 LEGACY FALLBACK（旧版回退）：代理与技能优先从 project.yaml
     解析每个键，仅当 project.yaml 中缺失该键时才回退到这里。/setup-engine 会同时写入
     两处。
     禁止模式（Forbidden patterns）与允许的库（allowed libraries）不做迁移 — 它们只
     存在于本文件。由 /setup-engine 填充；随着决策的产生而更新。 -->

## 引擎与语言（Engine & Language）

- **Engine**: [TO BE CONFIGURED]
- **Language**: [TO BE CONFIGURED]
- **Rendering**: [TO BE CONFIGURED]
- **Physics**: [TO BE CONFIGURED]

## 输入与平台（Input & Platform）

<!-- 由 /setup-engine 写入。由 /ux-design、/ux-review、/test-setup、/team-ui 和 /dev-story 读取 -->
<!-- 用于把交互规格、测试辅助工具和实现限定到正确的输入方式。 -->

- **Target Platforms**: [TO BE CONFIGURED]
- **Input Methods**: [TO BE CONFIGURED]
- **Primary Input**: [TO BE CONFIGURED]
- **Gamepad Support**: [TO BE CONFIGURED]
- **Touch Support**: [TO BE CONFIGURED]
- **Platform Notes**: [TO BE CONFIGURED]

## 命名约定（Naming Conventions）

- **Classes**: [TO BE CONFIGURED]
- **Variables**: [TO BE CONFIGURED]
- **Signals/Events**: [TO BE CONFIGURED]
- **Files**: [TO BE CONFIGURED]
- **Scenes/Prefabs**: [TO BE CONFIGURED]
- **Constants**: [TO BE CONFIGURED]

## 性能预算（Performance Budgets）

- **Target Framerate**: [TO BE CONFIGURED]
- **Frame Budget**: [TO BE CONFIGURED]
- **Draw Calls**: [TO BE CONFIGURED]
- **Memory Ceiling**: [TO BE CONFIGURED]

## 测试（Testing）

- **Framework**: [TO BE CONFIGURED]
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: 平衡性公式、玩法系统、网络（如适用）

## 禁止模式（Forbidden Patterns）

<!-- 添加绝不应出现在本项目代码库中的模式 -->
- [尚未配置 — 做出架构决策时添加]

## 允许的库 / 插件（Allowed Libraries / Addons）

<!-- 在此添加已批准的第三方依赖 -->
- [尚未配置 — 依赖获批时添加]

## 架构决策日志（Architecture Decisions Log）

<!-- 快速索引，链接到 docs/architecture/ 中的完整 ADR -->
- [尚无 ADR — 使用 /architecture-decision 创建]

## 引擎专家（Engine Specialists）

<!-- 配置引擎时由 /setup-engine 写入。 -->
<!-- 由 /code-review、/architecture-decision、/architecture-review 和团队技能读取 -->
<!-- 用于确定派生哪位专家进行引擎相关验证。 -->

- **Primary**: [TO BE CONFIGURED]
- **Language/Code Specialist**: [TO BE CONFIGURED]
- **Shader Specialist**: [TO BE CONFIGURED]
- **UI Specialist**: [TO BE CONFIGURED]
- **Additional Specialists**: [TO BE CONFIGURED]
- **Routing Notes**: [TO BE CONFIGURED]

### 文件扩展名路由（File Extension Routing）

<!-- 技能使用此表按文件类型选择正确的专家。 -->
<!-- 如果某行显示 [TO BE CONFIGURED]，则该文件类型回退到 Primary。 -->

| 文件扩展名 / 类型 | 要派生的专家 |
|-----------------------|---------------------|
| 游戏代码（主要语言） | [TO BE CONFIGURED] |
| 着色器 / 材质文件 | [TO BE CONFIGURED] |
| UI / 界面文件 | [TO BE CONFIGURED] |
| 场景 / 预制体 / 关卡文件 | [TO BE CONFIGURED] |
| 原生扩展 / 插件文件 | [TO BE CONFIGURED] |
| 通用架构评审 | Primary |
