# Skill Contract Template

> **Status — read before using this template.**
>
> **Identity & Scope**、**Input Contract**、**Output Contract**、**Hard/Soft
> Constraints** 与 **Handoff Configuration** 各小节是现行有效的，反映了当前
> 契约的编写方式。
>
> **Testing Evidence Required** 与 **Drift Monitoring** 两节属于
> **愿景性质**——它们提到的运行器（`tests/smoke-tests/`、
> `tests/golden-datasets/`、`tests/behavioral-tests/`、`tests/integration/`）以及
> `production/session-state/drift-monitor.md` 都**不存在**，没有任何技能拥有
> `TESTS.md`，七个已交付的 `CONTRACT.md` 文件也都没有使用 ASI 或
> 漂移机制。请把它们当作未来技能质量体系的设计草图，而不是要遵循的步骤。
>
> 七个已交付的契约采用比本模板更简单的形态：
> `Inputs Consumed` / `Files That Must Exist` / `Preconditions` /
> `Outputs Produced` / `Output Guarantees` / `Immutability Rules`。在两者统一
> 之前，请参照现有契约（例如 `.trae/skills/dev-story/CONTRACT.md`），而不是
> 本模板这种 schema 繁重的形式。

**Purpose:** 为一个技能定义正式的交接契约。创建为 `.trae/skills/<skill-name>/CONTRACT.md`。

**How to Use:**
1. 复制本模板
2. 用你的技能细节替换 `[SKILL_NAME]`、`[ROLE]`、`[DESCRIPTION]`
3. 精确地定义输入/输出 schema
4. 列出硬约束（绝不可违反）与软约束（违反后可恢复）
5. 加入有效输入/输出的示例
6. 在你的 SKILL.md 文件中引用本契约

---

# [SKILL_NAME] Handoff Contract

**Version:** 1.0
**Last Updated:** [DATE]
**Skill File:** `.trae/skills/[SKILL_NAME]/SKILL.md`
**Test File:** `.trae/skills/[SKILL_NAME]/TESTS.md`

---

## Identity & Scope

### Role
[ROLE] — [ONE SENTENCE DESCRIBING WHAT THIS SKILL DOES]

### Example
Story Author——将游戏设计史诗（epic）拆解为原子化、可测试的用户故事，并附有清晰的验收标准。

### Domain Boundaries
**Can Read:**
- `design/gdd/`（游戏设计文档）
- `.trae/docs/`（架构指导）
- `production/session-state/`（来自先前技能的上下文）

**Can Write:**
- `production/epics/[epic-slug]/`（创建新的故事 Markdown 文件）
- `production/qa/evidence/`（创建测试证据桩）

**Cannot Touch:**
- 代码根目录——`src/`、`Assets/` 或按引擎而定的 `Source/`（不写游戏代码）
- `assets/`（不做资源修改）
- 源数据文件（只读）

---

## Input Contract

### What This Skill Receives

**Source Skill:** [PREVIOUS_SKILL_NAME]（例如 `/create-epics`）
**Format:** 带结构化 frontmatter 的 Markdown
**Transport:** 会话上下文或文件引用

### Required Fields

```yaml
# Example input epic (YAML frontmatter in Markdown)
epic_id: "COMBAT-BASIC"
epic_goal: "Implement core melee attack system"
epic_acceptance_criteria:
  - "Player can attack with sword"
  - "Damage is configurable"
  - "Animation plays on hit"
  - "Enemy health updates"
target_complexity: "medium"  # low | medium | high
estimated_story_count: 3
```

### Schema Definition

```json
{
  "type": "object",
  "required": ["epic_id", "epic_goal", "epic_acceptance_criteria", "target_complexity"],
  "properties": {
    "epic_id": {
      "type": "string",
      "pattern": "^[A-Z]+(-[A-Z0-9]+)?$",
      "minLength": 2,
      "maxLength": 50
    },
    "epic_goal": {
      "type": "string",
      "minLength": 10,
      "maxLength": 500,
      "description": "High-level objective, not implementation"
    },
    "epic_acceptance_criteria": {
      "type": "array",
      "minItems": 1,
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 5,
        "maxLength": 200
      }
    },
    "target_complexity": {
      "type": "string",
      "enum": ["low", "medium", "high"]
    },
    "estimated_story_count": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
}
```

### Validation Rules

- [ ] Epic ID 匹配模式 `^[A-Z]+-[A-Z0-9]+$`（例如 `COMBAT-BASIC`）
- [ ] Epic 目标为 10–500 个字符（不能太简略，也不能写成小说）
- [ ] 至少 1 条、至多 20 条验收标准
- [ ] 目标复杂度为以下之一：`low`、`medium`、`high`
- [ ] 若提供了预估故事数，需 >= 1 且 <= 50

### Examples of Valid Input

```markdown
## Valid Example 1: Simple Epic

epic_id: COMBAT-BASIC
epic_goal: Implement core melee attack system
epic_acceptance_criteria:
  - Player can attack with sword
  - Damage is configurable from external data
  - Attack animation plays when action triggered
  - Target health decreases by damage amount
target_complexity: medium
estimated_story_count: 3
```

```markdown
## Valid Example 2: Large Epic

epic_id: PROGRESSION-FULL
epic_goal: Implement complete character progression system
epic_acceptance_criteria:
  - Player gains experience from defeated enemies
  - Experience unlocks new abilities
  - Player can level up manually
  - Leveling resets some cooldowns
  - New abilities appear in player menu
target_complexity: high
estimated_story_count: 12
```

---

## Output Contract

### What This Skill Produces

**Destination Skill:** [NEXT_SKILL_NAME]（例如 `/dev-story`）
**Format:** 带结构化标题的 Markdown
**Location:** 通常写入 `production/epics/[epic-slug]/story-NNN-[slug].md`

### Output Structure

```markdown
# Stories for [EPIC_ID]

## [STORY_ID]: [STORY_TITLE]

### Description
[1-3 paragraph description of the user story, written from player/user perspective]

### Acceptance Criteria
1. [Testable criterion 1 — imperative mood, specific observable behavior]
2. [Testable criterion 2]
3. [Testable criterion 3]
4. [Optional: criterion 4+, up to 5 per story]

### Complexity Estimate
[low | medium | high]

### Dependencies
[List other stories that should complete first, if any. Format: "EPIC_ID-N"]

---
## [STORY_ID+1]: [NEXT_STORY_TITLE]
...
```

### Schema Definition

```json
{
  "type": "object",
  "required": ["stories"],
  "properties": {
    "epic_id": { "type": "string" },
    "stories": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["story_id", "title", "description", "acceptance_criteria"],
        "properties": {
          "story_id": {
            "type": "string",
            "pattern": "^[A-Z]+-[A-Z0-9]+-[0-9]+$",
            "description": "Format: EPIC-ID-N"
          },
          "title": {
            "type": "string",
            "minLength": 5,
            "maxLength": 100,
            "description": "User-centric; action-oriented"
          },
          "description": {
            "type": "string",
            "minLength": 20,
            "maxLength": 1000,
            "description": "1-3 paragraphs, player perspective"
          },
          "acceptance_criteria": {
            "type": "array",
            "minItems": 3,
            "maxItems": 5,
            "items": {
              "type": "string",
              "minLength": 10,
              "maxLength": 200,
              "description": "Testable, imperative mood"
            }
          },
          "complexity_estimate": {
            "type": "string",
            "enum": ["low", "medium", "high"]
          },
          "dependencies": {
            "type": "array",
            "items": { "type": "string" },
            "description": "Story IDs that should complete first"
          }
        }
      }
    }
  }
}
```

### Validation Rules

- [ ] 每个故事都有唯一的 story ID，匹配模式 `^[A-Z]+-[A-Z0-9]+-[0-9]+$`
- [ ] Story ID 按 epic 顺序编号（例如 `COMBAT-BASIC-1`、`COMBAT-BASIC-2` 等）
- [ ] 故事数量与 epic 预估值相差 ± 1（例如 epic 预估 3，则产出 2–4 个）
- [ ] 每个故事有 ≥3 且 ≤5 条验收标准
- [ ] 验收标准使用祈使语气（"Player can..."、"System validates..."）
- [ ] 故事描述中不给出代码建议（保持抽象）
- [ ] 不修改原始 epic 的验收标准（可以扩展，但不能更改）
- [ ] 依赖引用有效的 story ID（不能前向引用）

### Examples of Valid Output

```markdown
# Stories for COMBAT-BASIC

## COMBAT-BASIC-1: Player Can Attack with Sword

### Description
The player wields a sword and can trigger basic melee attacks against enemies. When the attack button is pressed, the player's character plays an attack animation and applies damage to the target if in range.

### Acceptance Criteria
1. Player equips sword from starting inventory
2. Attack action triggers when spacebar pressed
3. Attack animation plays (2-frame simple swing)
4. Damage applied to target if in melee range (2-unit radius)

### Complexity Estimate
low

### Dependencies
(none)

---

## COMBAT-BASIC-2: Damage Values Are Configurable

### Description
All damage values (sword damage, enemy health) come from external configuration files. This allows designers to tune balance without changing code.

### Acceptance Criteria
1. Sword damage loaded from `data/weapons.json`
2. Enemy health loaded from `data/enemies.json`
3. Changing JSON values changes in-game behavior immediately
4. Invalid values trigger error log and fall back to default

### Complexity Estimate
medium

### Dependencies
- COMBAT-BASIC-1
```

---

## Hard Constraints (Must Never Violate)

违反将自动触发干预/拒绝。

- ❌ **不要修改 epic 目标**——故事不得与输入 epic 的目标相矛盾或改写它
- ❌ **不要更改验收标准的来源**——如果 epic 说"伤害可配置"，就不要删除这一条
- ❌ **不要编写游戏代码**——故事保持抽象，不要给出像 `player.attack()` 这样的代码建议
- ❌ **不要修改输入的 epic 文件**——将其视为只读、不可变
- ❌ **不要产出无效的 story ID**——必须匹配模式 `EPIC-ID-N`
- ❌ **不要产出缺少验收标准的故事**——至少需要 3 条
- ❌ **不要跳过或合并故事**——如果 epic 预估 5 个故事，就交付 4–6 个，而不是 2–3 个
- ❌ **不要创建循环依赖**——故事不能依赖于更靠后的故事

**Enforcement:** 测试运行器中的 schema 校验 + 断言检查。失败将阻止交接。

---

## Soft Constraints (Recover if Violated)

违反会发出警告并尝试恢复；不会阻断。

- ⚠️ **超出故事数量预估**——如果 epic 预估 3 个却产出 6 个：记录警告并继续（通常不是致命错误，但需记录以便分析）
- ⚠️ **故事描述过于简略**——< 20 个字符：参考示例重新采样并继续
- ⚠️ **验收标准措辞不清**——未使用祈使语气：请求澄清或重新采样
- ⚠️ **语气不一致**——有些故事正式、有些随意：重新采样以对齐基线语气
- ⚠️ **缺少复杂度预估**——只提供了一部分：用已提供值的中位数补齐
- ⚠️ **依赖含糊**——循环或无效引用：记录并继续（下游可以校验）

**Enforcement:** 在行为测试中检测；记录到漂移监控器。不阻止交接，但标记待评审。

---

## Handoff Configuration

### Receives From
**Upstream Skill:** `/create-epics`（或等价的 epic 生成技能）

**How Data Arrives:**
- 选项 1：epic 内容作为上下文字符串传入
- 选项 2：提供 epic 文件路径；由技能读取
- 选项 3：epic 数据以结构化 YAML/JSON 提供

**Immutability at Boundary:**
- Epic 目标——只读，不修改
- 验收标准来源——只读，可扩展但不可矛盾
- Epic ID——只读，会被 story ID 引用

### Delivers To
**Downstream Skill:** `/dev-story`（或等价的 story 转 task 技能）

**How Data Handed Off:**
- 选项 1：故事 Markdown 写入 `production/epics/[epic-slug]/story-NNN-[slug].md`
- 选项 2：故事内容作为上下文字符串传给下一个技能
- 选项 3：故事元数据索引到中央注册表

**What Downstream Must Receive:**
- 所有 story ID 与内容
- 验收标准保持不变（下游可以添加技术说明，但不能更改标准）
- 依赖关系保留

**What Downstream Cannot Change:**
- Story ID
- 故事标题（可以添加上下文/备注，但不能重命名）
- 验收标准（可以添加实现指导，但不能修改标准）

### Rollback Procedure

如果下游技能（`/dev-story`）消费故事失败：

1. **Fail Signal:** 下游返回错误（例如"story validation failed"）
2. **Rollback Action:** 丢弃下游的任何部分工作；回到本技能的输出
3. **Recovery:** 本技能不会重新运行；由上游技能决定是否提供不同的 epic
4. **No State Mutation:** 故事文件保持不变；epic 保持不变；没有副作用

---

## Testing Evidence Required

每个 story 技能的产出在交接前都必须通过以下测试套件：

### T1: Schema Validation (Deterministic)
- [ ] 输出可解析为有效 Markdown
- [ ] 输出通过输出 schema 校验（见上方 JSON schema）
- [ ] Story ID 遵循模式 `EPIC-ID-N`
- [ ] 每个故事有 ≥3 条验收标准
- [ ] 无硬约束违反（断言检查）

**Test File:** `tests/smoke-tests/schema-validate.sh`

### T2: Golden Dataset Consistency (Stochastic)
- [ ] 输入：已知良好的 epic（golden dataset）
- [ ] 输出：与基线故事（golden dataset）比较
- [ ] 指标：语义相似度 >= 0.85（嵌入余弦距离）
- [ ] 通过：若相似度达标，则故事一致

**Test File:** `tests/golden-datasets/`（存放预期输出）

### T3: Format Stability (Stochastic)
- [ ] 对同一输入运行技能 5 次
- [ ] 测量多次运行之间的格式一致性
- [ ] 指标：5 次输出结构一致（不增加/删除小节）
- [ ] 通过：若 5 次运行格式相同

**Test File:** `tests/behavioral-tests/format-stability.sh`

### T4: Handoff Integration (Integration)
- [ ] 下游技能（`/dev-story`）接受本输出
- [ ] 下游无 schema 校验错误
- [ ] 下游产出有效的 task 输出
- [ ] 通过：若下游接受 >95% 的故事

**Test File:** `tests/integration/story-to-devstory.sh`

### Acceptance Criteria for Handoff

**This skill is READY TO HAND OFF when:**
- ✅ 所有硬约束通过（schema 校验、断言检查）
- ✅ 与 golden dataset 的语义相似度 >= 0.85
- ✅ 5 次运行格式稳定（结构全部一致）
- ✅ 下游技能接受输出（集成测试通过）
- ✅ 漂移监控器 ASI >= 0.75（无退化）

**Blocking Issues:**
- ❌ 硬约束违反 → 必须在交接前修复
- ❌ 相似度 < 0.85 → 调查漂移，重新采样或调整
- ❌ 下游拒绝 → 修复 schema 或内容

---

## Drift Monitoring

### Agent Stability Index (ASI) Components

**For `/create-stories`, we measure:**

1. **Response Consistency (30%)**——多次运行之间故事格式是否稳定？
   - 测量：同一输入 5 次运行的嵌入相似度（余弦距离）
   - 基线：>= 0.88（基于 10 个历史故事建立）
   - 告警：连续 3 次运行 < 0.85

2. **Tool Usage Patterns (25%)**——技能是否使用一致的模式？
   - 测量：工具调用、模板、引用是否一致
   - 基线：引用相同的设计文档，遵循相同的模式
   - 告警：出现无解释的新模式

3. **Acceptance Criteria Quality (25%)**——验收标准是否稳定且可测试？
   - 测量：措辞使用祈使语气、具体、可测试
   - 基线：每个故事 0 条含糊标准（例如不出现"should work"）
   - 告警：每个故事 >1 条含糊标准

4. **Behavioral Boundaries (20%)**——技能是否守住边界？
   - 测量：无代码建议、未修改 epic 目标、未触碰资源
   - 基线：每次输出 0 次违反
   - 告警：任何一次违反

**ASI Calculation:**
```
consistency_score = avg_embedding_similarity across 5 runs
tool_score = 1.0 if patterns consistent, 0.8 if slight drift, 0.6 if major change
criteria_score = 1.0 if all testable, 0.8 if 1 vague, 0.6 if >1 vague
boundary_score = 1.0 if no violations, 0.0 if any violation

ASI = (0.30 * consistency) + (0.25 * tool) + (0.25 * criteria) + (0.20 * boundary)
```

**Monitoring:**
- 每调用 5 次 story 技能后测量一次
- 记录到 `production/session-state/drift-monitor.md`
- 若 ASI 连续 3 个窗口 < 0.75 则告警

---

## Glossary & References

**Immutable:** 读取后不可更改的数据。在技能边界上，输入是不可变的（保护源 epic）。

**Handoff:** 一个技能的输出成为另一个技能的输入的时刻。必须经过机器校验。

**Hard Constraint:** 绝不可违反的规则。违反将阻止交接。

**Soft Constraint:** 应当遵循的规则。违反只发出警告而不阻断；会尝试恢复。

**ASI (Agent Stability Index):** 从 4 个维度衡量技能一致性的四维指标。阈值为 0.75。

**Drift:** 技能行为随时间或反复调用而逐渐退化。

**Semantic Similarity:** 基于嵌入的两段文本比较（0.0 = 完全不同，1.0 = 含义相同）。用于 LLM 输出，代替精确字符串匹配。

**Golden Dataset:** 精选的真实输入与预期输出集合，用作回归测试基线。

**Schema Validation:** 按 JSON/Markdown schema 校验输出。确定性强，可机器验证。

---

**Template Version:** 1.0
**Last Updated:** 2026-03-26
**Audience:** 编写新技能或升级现有技能以加入契约的技能作者
