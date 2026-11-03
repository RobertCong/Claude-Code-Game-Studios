# Adoption Plan

> **Generated**: [date]
> **Project phase**: [phase]
> **Engine**: [name + version, or "Not configured"]
> **Template version**: v1.0+

按顺序逐项完成这些步骤。每完成一项就勾选。
随时重新运行 `/adopt` 以检查剩余的差距。

---

## Step 1: Fix Blocking Gaps

[每个阻塞性差距一个子小节，包含问题、修复命令、时间估算、复选框]

---

## Step 2: Fix High-Priority Gaps

[每个高优先级差距一个子小节]

---

## Step 3: Bootstrap Infrastructure

[在 `workflow: minimal` 下，用一行替换 3a–3d：「不在最小路径上——
简报的构建顺序就是计划。下一步：`/create-stories`（故事存在后则用 `/dev-story`）。」]

### 3a. Register existing requirements (creates tr-registry.yaml)
运行 `/architecture-review`——即使 ADR 已存在，这次运行也会依据你现有的 GDD 和 ADR
引导建立 TR 注册表。
**Time**: 1 个会话（大型代码库的评审可能较长）
- [ ] 已创建 tr-registry.yaml

### 3b. Create control manifest
运行 `/create-control-manifest`
**Time**: 30 分钟
- [ ] 已创建 docs/architecture/control-manifest.md

### 3c. Create sprint tracking file
运行 `/sprint-plan update`
**Time**: 5 分钟（若冲刺计划已以 Markdown 形式存在）
- [ ] 已创建 production/sprint-status.yaml

### 3d. Set authoritative project stage
运行 `/gate-check [current-phase]`（进入项目当前所处阶段的那道 gate；
在 Concept 阶段没有 gate——Concept 是默认阶段，无需运行）
**Time**: 5 分钟
- [ ] 已写入 `project.yaml` 中的 `project.stage`（旧的 `production/stage.txt` 也已更新）

---

## Step 4: Medium-Priority Gaps

[每个中优先级差距一个子小节]

---

## Step 5: Optional Improvements

[每个低优先级差距一个子小节]

---

## What to Expect from Existing Stories

现有故事可继续与所有模板技能配合工作。当字段缺失时，新格式检查（TR-ID 校验、
清单版本过期检查）会自动通过——因此不会有任何中断。在重新生成之前，它们不会
受益于过期追踪。不要重新生成正在进行或已完成的故事。

---

## Re-run

完成 Step 3 后再次运行 `/adopt`，以验证所有阻塞性差距与高优先级差距都已解决。
新的运行结果将反映项目的当前状态。
