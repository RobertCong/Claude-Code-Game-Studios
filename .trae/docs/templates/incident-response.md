# Incident Response: [Incident Title]

**Severity**: [S1-Critical / S2-High / S3-Medium / S4-Low]
**Status**: [Active / Mitigated / Resolved / Post-Mortem Complete]
**Detected**: [Date Time UTC]
**Resolved**: [Date Time UTC or ONGOING]
**Duration**: [从发现到解决的总时长]
**Incident Commander**: [Name/Role]

---

## Impact Summary

[用 2-3 句话描述玩家经历了什么。从玩家视角而非技术视角撰写。]

- **Players affected**: [预估数量或百分比]
- **Platforms affected**: [PC / Console / Mobile / All]
- **Regions affected**: [All / 具体区域]
- **Revenue impact**: [如适用，预估]

---

## Timeline

| Time (UTC) | Event | Action Taken |
| ---- | ---- | ---- |
| [HH:MM] | 通过[监控/玩家报告/等]发现事件 | 已指定事件指挥官 |
| [HH:MM] | 已确定根本原因 | [原因的简要描述] |
| [HH:MM] | 已部署缓解措施 | [采取了什么措施] |
| [HH:MM] | 服务恢复 / 修复确认 | 监控是否复发 |
| [HH:MM] | 宣布全部恢复正常 | 已安排事后复盘 |

---

## Root Cause

### What Happened
[对根本原因的技术描述。具体说明导致事件发生的事件链。]

### Why It Happened
[系统性原因——为什么现有的流程、测试或防护措施未能阻止这一事件？这比技术原因更重要。]

### Contributing Factors
- [因素 1——例如「新匹配系统缺乏足够的负载测试」]
- [因素 2——例如「监控告警阈值设置过高」]
- [因素 3]

---

## Mitigation and Resolution

### Immediate Actions (during incident)
1. [为止血采取的措施]
2. [为恢复服务采取的措施]
3. [为验证问题已解决采取的措施]

### Follow-Up Actions (after resolution)
1. [若即时措施只是变通方案，所需的永久修复]
2. [新增的额外测试或监控]
3. [防止复发的流程变更]

---

## Player Communication

### Initial Acknowledgment
*Sent: [Time] via [channel]*
> [首条公开确认该问题的消息原文]

### Status Updates
*Sent: [Time] via [channel]*
> [每次后续更新的文本]

### Resolution Notice
*Sent: [Time] via [channel]*
> [宣布修复及任何补偿的文本]

### Compensation (if applicable)
- **What**: [补偿内容描述——例如「500 高级货币 + 24 小时经验加成」]
- **Who**: [所有玩家 / 仅受影响玩家 / 事件期间登录过的玩家]
- **When**: [发放日期和方式]
- **Rationale**: [为什么该补偿与影响程度相称]

---

## Prevention

### What We Are Changing

| Action Item | Owner | Deadline | Status |
| ---- | ---- | ---- | ---- |
| [具体预防措施] | [Role] | [Date] | [TODO/Done] |
| [为 X 增加监控] | [Role] | [Date] | [TODO/Done] |
| [为 Y 增加测试覆盖] | [Role] | [Date] | [TODO/Done] |
| [更新 Z 的运行手册] | [Role] | [Date] | [TODO/Done] |

### Process Improvements
- [防止类似事件的流程变更]
- [监控/告警改进]
- [测试改进]

---

## Lessons Learned

### What Went Well
- [事件响应中的积极方面——例如「得益于监控告警，发现速度很快」]
- [积极方面]

### What Went Poorly
- [响应中的问题——例如「花了 20 分钟才找到正确的值班人员」]
- [问题]

### Where We Got Lucky
- [偶然而非设计上减轻了影响的因素——这些是需要处理的隐藏风险]

---

## Sign-Offs

- [ ] Technical Director — 根本原因准确，预防计划充分
- [ ] QA Lead — 测试覆盖缺口已处理
- [ ] Producer — 时间线与沟通已审阅
- [ ] Community Manager — 玩家沟通已审阅

---

*本文档归档于 `production/hotfixes/`，并从修复版本的发布说明中链接。*
