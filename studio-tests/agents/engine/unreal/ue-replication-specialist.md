# Agent Test Spec: ue-replication-specialist

## Agent Summary
- **Domain**: 属性复制（UPROPERTY Replicated/ReplicatedUsing）、RPC（Server/Client/NetMulticast）、客户端预测与校正、网络相关性与 always-relevant 设置、网络序列化（FArchive/NetSerialize）、带宽优化与复制频率调优
- **Does NOT own**: 被复制的玩法逻辑（gameplay-programmer）、传输层网络与匹配（network-programmer，其与 devops-engineer 协调服务器托管）、GAS 专用预测（ue-gas-specialist 处理 GAS 网络预测）
- **Gate IDs**: None；将安全相关的复制问题提交给 security-engineer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且限定于本领域（引用复制、RPC、客户端预测、带宽）
- [ ] `tools:` 为 Read、Glob、Grep、Write、Edit、Bash —— 无 `Agent` 工具
- [ ] 模型档位为 `sonnet` —— frontmatter `model:` 精确为 `sonnet`（档位见：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对服务器基础设施、游戏服务器架构或玩法逻辑正确性拥有权限

---

## Test Cases

### Case 1: In-domain request — 带客户端预测的玩家生命值复制
**Input**: "设置可复制的玩家生命值，客户端可以在本地预测（例如承受自伤时），并由服务器校正。"
**Expected behavior**:
- 在合适的 Character 或 AttributeSet 类中产出 UPROPERTY(ReplicatedUsing=OnRep_Health) 声明
- 描述 OnRep_Health 函数：施加视觉/音频反馈，将预测值与服务器权威值校正
- 解释客户端预测模式：本地客户端立即施加暂定伤害，服务器权威值通过 OnRep 到达并纠正任何偏差
- 指出如果使用了 GAS，GAS 内置预测会处理此事 —— 建议与 ue-gas-specialist 协调
- 输出具体的代码结构（属性声明 + OnRep 大纲），而不仅是概念描述

### Case 2: Out-of-domain request — 游戏服务器架构
**Input**: "设计我们的游戏服务器基础设施 —— 需要多少专用服务器、区域部署、匹配架构。"
**Expected behavior**:
- 不产出服务器基础设施架构、托管建议或匹配设计
- 说明其范围是运行中游戏会话内的 Unreal 复制层，并指明 network-programmer（其在该层之下网络方面的协调伙伴）为匹配与服务器架构的转交对象
- 不将游戏内复制与服务器托管问题混为一谈

### Case 3: Domain boundary — 缺少服务器权限校验的 RPC
**Input**: "我们有一个名为 ServerSpendCurrency 的 Server RPC，用于扣除游戏内货币。客户端调用它，服务器不做任何检查就直接扣除。"
**Expected behavior**:
- 将其标记为严重安全漏洞：未校验的 Server RPC 可被作弊者利用，发送任意 RPC 调用
- 给出必需的修复：扣除前在服务器端校验 —— 检查玩家确实拥有该货币、验证交易有效，否则拒绝并记录日志
- 校验覆盖每个客户端 RPC 所需的三个检查：该玩家当前能否执行此操作、参数是否在有效范围内、请求频率是否在限制内（对 RPC 限流）
- 指出鉴于其经济影响，此事应由 security-engineer（其网络安全性校验的指定伙伴）评审
- 不会在不解释原始写法为何危险的情况下直接产出「修复后」的代码

### Case 4: Bandwidth optimization — 高频移动复制
**Input**: "我们的玩家移动每 tick 使用 Vector3 位置进行复制。32 名玩家时，我们超出了带宽预算。"
**Expected behavior**:
- 识别出对全精度 Vector3 按 tick 复制会消耗大量带宽
- 建议量化复制：使用 FVector_NetQuantize 或 FVector_NetQuantize100 代替原始 FVector，以减少每次更新的字节数
- 建议降低移动 Actor 的复制频率 —— 按 Actor 的网络更新频率（其标准中的 `NetUpdateFrequency`），而非按客户端设置 —— 指明所用 API，并在 `docs/engine-reference/unreal/` 未记录时标记为未验证
- 指出 Unreal 内置的 Character Movement Component 已有优化的移动复制 —— 建议使用或扩展它，而非自行实现自定义系统
- 对照其每客户端目标（动作游戏低于 10 KB/s）衡量结果，并指出确认节省的工具（`stat net`、Network Profiler）

### Case 5: Context pass — 在网络预算内进行设计
**Input context**: 项目网络预算为每玩家 64 KB/s，32 名玩家 = 服务器总出站 2 MB/s。当前移动复制已占用每玩家 40 KB/s。
**Input**: "我们想加入实时背包复制，让所有客户端能立即看到其他玩家的装备变化。"
**Expected behavior**:
- 承认现有 40 KB/s 的移动开销意味着每玩家只剩 24 KB/s 用于其他一切
- 指出这些项目数值远高于其自身默认目标（动作游戏每客户端低于 10 KB/s），在遵循项目所述预算的同时标记该差距
- 不会设计朴素的全背包复制方案（会超出预算）
- 区分其他玩家看到的内容（已装备物品，复制给所有人）与完整背包（`COND_OwnerOnly`）
- 建议仅增量或事件驱动方案：只复制变化的槽位而非完整背包数组，并用 `ReplicatedUsing` 触发定向更新
- 明确说明所提方案相对剩余 24 KB/s 预算的带宽估算

---

## Protocol Compliance

- [ ] 保持在声明领域内（属性复制、RPC、客户端预测、带宽）
- [ ] 将服务器基础设施与匹配请求转交 network-programmer，且不产出基础设施设计
- [ ] 将未校验的 Server RPC 标记为安全问题，并建议由 security-engineer 评审
- [ ] 返回结构化发现（属性声明、带宽估算、优化选项），而非自由建议
- [ ] 评估复制设计选择时使用项目提供的带宽预算数字
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件

---

## Coverage Notes
- Case 3（RPC 安全）是交付关键测试 —— 未校验的 RPC 是多人游戏十大漏洞利用途径之一
- Case 5 是最重要的上下文感知测试；代理必须使用实际预算数字，而非泛泛建议
- Case 1 的 GAS 分支：如果配置了 GAS，代理应检测到并交由 ue-gas-specialist 处理 GAS 管理的属性
- 无自动运行器；请手动审查或通过 `/skill-test`
