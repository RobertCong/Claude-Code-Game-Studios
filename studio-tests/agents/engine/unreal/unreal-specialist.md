# Agent Test Spec: unreal-specialist

## Agent Summary
- **Domain**: Unreal Engine 模式与架构 —— Blueprint 与 C++ 的抉择、UE 子系统（GAS、Enhanced Input、Niagara）、UE 项目结构、插件集成以及引擎级配置
- **Does NOT own**: 美术风格与视觉方向（art-director）、服务器基础设施与部署（devops-engineer）、UI/UX 流程设计（ux-designer）
- **Gate IDs**: None；质量闸门（gate）结论交由 technical-director

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用 Unreal Engine）
- [ ] `tools:` 为 Read、Glob、Grep、Write、Edit、Bash 和 `Agent`，且其正文要求它只启动四个子专家（ue-gas、ue-blueprint、ue-replication、ue-umg），因为子代理 `tools` 中的类型列表会被忽略
- [ ] 模型档位为 `inherit` —— frontmatter `model:` 精确为 `inherit`（档位见：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称在声明领域之外拥有权限（不含美术、不含服务器基础设施）

---

## Test Cases

### Case 1: In-domain request — Blueprint 与 C++ 的抉择标准
**Input**: "我们的连击攻击系统应该用 Blueprint 还是 C++ 实现？"
**Expected behavior**:
- 应用其所述默认原则：连击系统的框架用 C++，内容和原型用 Blueprint
- 通过 GAS 路由战斗逻辑（连击攻击作为 Gameplay Ability，连击状态作为 Gameplay Tag，蒙太奇流程通过 Ability Task），并指明由 ue-gas-specialist 负责 GAS 设计，而非自行实现
- 建议用 Blueprint 处理设计师可调数值（通过 `EditAnywhere` / `BlueprintReadWrite` 暴露，连击变体使用仅数据 Blueprint，设计师覆盖行为处使用 `BlueprintNativeEvent`）
- 引用其每个函数约 20 个节点的阈值，作为 Blueprint 连击逻辑应改入 C++ 的分界点
- 在不了解项目上下文的情况下不会给出最终结论 —— 若缺少上下文，会提出澄清问题
- 将拆分作为拟议的类结构及其取舍呈现，而非自由发挥的意见

### Case 2: Out-of-domain request — Unity C# 代码
**Input**: "给我写一个处理玩家生命值并在死亡时触发 Unity 事件的 C# MonoBehaviour。"
**Expected behavior**:
- 不产出 Unity C# 代码
- 回答前先从 `project.yaml` 的 `engine.name` 确认项目引擎：若配置为 Unreal，说明项目使用 Unreal Engine 5 构建；若未设置，则询问项目使用哪种引擎，而不是假设
- 若配置为 Unreal，将请求映射到其自身标准所规定的 Unreal 等价方案：使用 GAS 时，生命值作为 Attribute Set 属性，只通过 Gameplay Effect 变更；否则使用 C++ `UActorComponent` 向 Blueprint 暴露死亡事件
- 不重定向到 unity-specialist —— 该代理仅服务 Unity 项目，而本代理的 `Agent` 授权仅覆盖其四个 Unreal 子专家

### Case 3: Domain boundary — UE5.4 API 需求
**Input**: "我需要使用 UE5.4 引入的新 Motion Matching API。"
**Expected behavior**:
- 标记 UE5.4 超出模型训练覆盖范围（`docs/engine-reference/unreal/VERSION.md` 的 Knowledge Gap Warning 将覆盖范围定为约 5.3，并将 5.4 列为 HIGH 风险版本）
- 在信任任何 API 建议前检查 `docs/engine-reference/unreal/`
- 说明 `docs/engine-reference/unreal/` 下没有任何文件记录 Motion Matching，并将其提供的任何类名或节点名标记为未经固定版本验证
- 不会在无警示的情况下静默产出过时或错误的 API 签名

### Case 4: Conflict — 核心系统中的 Blueprint 面条代码
**Input**: "我们的复制逻辑完全在一个深度嵌套的 Blueprint 事件图表中，有 300+ 个节点且没有任何函数。它变得越来越难以维护。"
**Expected behavior**:
- 识别出这是 Blueprint 架构问题，而非轻微的样式问题
- 建议将核心复制逻辑迁移到 C++ ActorComponent 或 GameplayAbility 系统
- 指出所需的协调：复制架构的变更必须让 lead-programmer 参与
- 不会在未向用户说明重构范围的情况下单方面宣布「迁移到 C++」
- 产出具体的迁移建议，而非模糊提议

### Case 5: Context pass — 版本相符的 API 建议
**Input context**: 项目引擎参考文件标明 Unreal Engine 5.3。
**Input**: "如何为新角色设置 Enhanced Input 动作？"
**Expected behavior**:
- 使用 UE5.3 时代的 Enhanced Input API（InputMappingContext、UEnhancedInputComponent::BindAction）
- 不引用 UE5.3 之后引入的 API，除非将其标记为可能不可用
- 在回复中引用项目所述的引擎版本
- 提供具体的、锚定版本的代码或 Blueprint 节点名

---

## Protocol Compliance

- [ ] 保持在声明领域内（Unreal 模式、Blueprint/C++、UE 子系统）
- [ ] 对 Unity 或其他引擎的请求以 Unreal 等价方案回答，绝不产出错误引擎的代码
- [ ] 在实现前先提出类结构、数据流和取舍（Implementation Workflow 第 3 步），而非自由发挥的意见
- [ ] 在产出 API 建议前明确标记版本不确定性，并引用 `docs/engine-reference/unreal/`
- [ ] 架构级重构与 lead-programmer 协调，而非单方面决定
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件

---

## Coverage Notes
- 代理行为测试没有自动运行器 —— 需手动审查或通过 `/skill-test`
- 版本感知（Case 3、Case 5）是该代理风险最高的失败模式；引擎版本变化时应定期测试
- Case 3 和 Case 5 只有在代理被引导到 `docs/engine-reference/unreal/` 时才会通过；`CLAUDE.md` 仅在 `/setup-engine` 选择 Unreal 后导入 Unreal 的 `VERSION.md`，因此代理自身文件必须包含该指引
- Case 4 与 lead-programmer 的集成是协调测试，而非技术正确性测试
