# /architecture-review — Phase 3 与 3b：可追溯性矩阵与用户故事关联

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 3: 构建可追溯性矩阵

**本文件包含：**

- Step 3b-1 — 加载用户故事
- Step 3b-2 — 加载测试文件
- Step 3b-3 — 构建扩展 RTM

对 Phase 2 提取的每个技术需求，搜索 ADR：

1. 使用**在 Phase 1b 中已加载**的 ADR —— 不要重新读取它们。从已在上文中的内容里
   提取每个 ADR 的 "GDD Requirements Addressed" 章节。（如果 Phase 1b 以某个未加载
   每个 ADR 的模式运行，`Grep pattern="## GDD
   Requirements Addressed" glob="docs/architecture/adr-*.md" output_mode="content"
   -A 15` 可补齐缺口，无需完整重读。）
2. 检查它是否明确引用了该需求或其 GDD
3. 检查 ADR 的决策文本是否隐含覆盖了该需求
4. 标记覆盖状态：

| 状态 | 含义 |
|--------|---------|
| ✅ **Covered** | 某个 **Accepted** 的 ADR 明确处理了该需求 |
| 🟡 **Covered (Proposed)** | 某个 ADR 处理了它，但该 ADR 仍为 `Proposed` |
| ⚠️ **Partial** | 某个 ADR 部分覆盖了它，或覆盖情况模糊 |
| ❌ **Gap** | 没有任何 ADR 处理该需求 |
| ❓ **Not assessed** | 该 ADR 不可读，或没有 `## Status` 章节 |

> **在标记覆盖之前先读取每个 ADR 的 `## Status` —— 未被接受的决策不是覆盖。** 如果
> `✅` 仅表示*某个 ADR 处理了它*，而不对状态加以限定，那么一项完全由 `Proposed` ADR
> 覆盖的需求也会被算作已覆盖，本次评审就可能对着一个人人都未接受的架构返回
> **PASS: All requirements covered**。有四个下游技能
> （`create-control-manifest`、`create-epics`、`create-stories`、`gate-check`）
> 要求 `Accepted`，因此基于该依据的 PASS 会把工作往前推，而它们每一个都会拒绝。
>
> `🟡` **不是**通过状态：它把结论上限设为 **CONCERNS**，并指出出路 ——
> `/architecture-decision accept ADR-NNNN`。该路径是唯一能把 ADR 变为 `Accepted` 的
> 方式；没有它，就只能把 `Proposed` 评为已覆盖，这正是绝不能这样评的原因。

构建完整矩阵：

```
## Traceability Matrix

| Requirement ID | GDD | System | Requirement | ADR Coverage | Status |
|---------------|-----|--------|-------------|--------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox detection < 1 frame | ADR-0003 | ✅ |
| TR-combat-002 | combat.md | Combat | Combo window timing | — | ❌ GAP |
| TR-inventory-001 | inventory.md | Inventory | Persistent item storage | ADR-0005 | ✅ |
```

统计总数：X 项已覆盖，Y 项部分覆盖，Z 项缺口。

---

## Phase 3b: 用户故事与测试关联（仅 RTM 模式）

*除非参数为 `rtm`，或为存在用户故事的 `full`，否则跳过本阶段。*

本阶段把 Phase 3 的矩阵扩展为纳入实现每个需求的用户故事与验证它的测试 —— 产出完整的
需求可追溯性矩阵（RTM）。

### Step 3b-1 — 加载用户故事

Glob `production/epics/**/*.md`（排除 EPIC.md 索引文件）以确立分母。然后通过
**定向章节 grep 收集字段，而不是完整读取每个用户故事** —— 与 `/test-evidence-review`
用于同样提取的两个 grep 形式相同：

```
Grep pattern="## Test Evidence" glob="production/epics/**/story-*.md" output_mode="content" -A 8
Grep pattern="TR-" glob="production/epics/**/story-*.md" output_mode="content"
```

- **TR-ID** —— 来自第二个 grep。
- **测试文件路径** —— 位于 `## Test Evidence` 下，由第一个 grep 的 `-A 8` 捕获。
- **Status** —— 来自用户故事头部；如果尚未捕获，添加 `Grep pattern="^> \*\*Status\*\*"`。
- **用户故事路径与标题** —— 来自文件名与路径；完全不需要读取。

只有当用户故事的 Test Evidence 章节缺失或含糊时，才完整读取它。

### Step 3b-2 — 加载测试文件

Glob 引擎的测试根目录（`.trae/docs/directory-structure.md`）：Godot
`tests/unit/**/*_test.*` 与 `tests/integration/**/*_test.*`；Unity
`Assets/Tests/**/*Tests.cs`；Unreal `Source/*/Private/Tests/**/*.cpp`。未配置引擎时，
要说明测试索引无法构建，而不是把空的 glob 读作"没有测试"。构建索引：系统 → [测试文件路径]。

对 Step 3b-1 中的每个测试文件路径，通过 Glob 确认该文件是否实际存在。如果所述路径
不存在，记为 MISSING。

### Step 3b-3 — 构建扩展 RTM

对 Phase 3 矩阵中的每个 TR-ID，添加：
- **Story**：引用该 TR-ID 的用户故事文件路径（可能多个）
- **Test File**：用户故事 Test Evidence 章节中所述的测试文件路径
- **Test Status**：COVERED（测试文件存在）/ MISSING（路径已述但未找到）/
  NONE（未述测试路径，用户故事类型可能为 Visual/Feel/UI）/
  NO STORY（需求尚无用户故事 —— 预制作阶段的缺口）

扩展矩阵格式：

```
## Requirements Traceability Matrix (RTM)

| TR-ID | GDD | Requirement | ADR | Story | Test File | Test Status |
|-------|-----|-------------|-----|-------|-----------|-------------|
| TR-combat-001 | combat.md | Hitbox < 1 frame | ADR-0003 | story-001-hitbox.md | tests/unit/combat/hitbox_test.gd | COVERED |
| TR-combat-002 | combat.md | Combo window | — | story-002-combo.md | — | NONE (Visual/Feel) |
| TR-inventory-001 | inventory.md | Persistent storage | ADR-0005 | — | — | NO STORY |
```

RTM 覆盖率摘要：
- COVERED: [N] —— 具备 ADR + 用户故事 + 通过测试的需求
- MISSING test: [N] —— 用户故事存在但未找到测试文件
- NO STORY: [N] —— 有 ADR 但尚无用户故事的需求
- NO ADR: [N] —— 没有架构覆盖的需求（来自 Phase 3 的缺口）
- 完整链路完成（COVERED）：[N/total]（[%]）

---
