# /create-architecture — Phase 8: 交接

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 8: 交接

**第 1 步 —— 更新会话状态**：向 `production/session-state/active.md` 写入摘要，涵盖：已写入的产出物、TD/LP 签核结论、任何阻塞项、剩余必需 ADR，以及下一步。

**第 2 步 —— 使用完全相同的此模板输出交接**（不要自由散文，不要改写章节标题）：

---

## 架构完成

`docs/architecture/architecture.md` v[N] —— [TD-ARCHITECTURE: APPROVE / CONCERNS (accepted) / REVISED after CONCERNS / REVISED after REJECT / NOT ASSESSED / skipped — [mode] mode]。[一句说明架构覆盖了什么。]

---

## 接下来运行这些 ADR

**1. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[一句话：它定义了什么、解除了什么阻塞。]

**2. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[一句话。]

**3. `/architecture-decision "[Title]"` → ADR-[XXXX]**
[一句话。]

**然后：** `/architecture-review`，以及在其通过且那些 ADR 被 Accepted 后运行 `/create-control-manifest` —— 它会把它们转化为层级规则清单。

按优先级顺序列出 Phase 6 中的前 3 项。如果剩余少于 3 项，只列出未完成项。

---

## Gate-Check 就绪状态

> **`/gate-check pre-production` 之前必需：**
> - [ ] 接受 ADR：[列出必须被 Accepted 的 Proposed ADR ID]
> - [ ] 撰写 ADR：[列出仍必须撰写的 ADR ID]
> - [ ] 运行 `/architecture-review` —— 写入评审报告和可追溯性索引（`docs/architecture/requirements-traceability.md`），供闸门读取
> - [ ] 运行 `/test-setup` —— 搭建 `tests/unit/`、`tests/integration/`、CI 工作流和一个示例测试文件
> - [ ] 运行 `/ux-design` —— 创建 `design/ux/interaction-patterns.md` 和 `design/accessibility-requirements.md`
>
> 当所有复选框勾选后，运行 `/gate-check pre-production`。

如果没有任何阻塞，改为写入：
> 无阻塞 —— 现在运行 `/gate-check pre-production`。

---

## 需要关注的问题

| ID | 摘要 | 优先级 | 解决路径 |
|----|---------|----------|-----------------|
| QQ-XX | [简短描述] | High / Medium / Low | [解决它的 ADR 或系统] |

如果没有未决 QQ，完全省略此章节。

---

（交接结束。不要在收尾分隔线之后添加任何评论。）

---
