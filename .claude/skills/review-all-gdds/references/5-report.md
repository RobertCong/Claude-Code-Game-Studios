# /review-all-gdds — Phase 5: 输出评审报告

> 属于 `/review-all-gdds`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 5: 输出评审报告

**本文件包含：**

- 报告模板
- `NOT ASSESSED` 及其排序位置

```
## Cross-GDD Review Report
Date: [date]
GDDs Reviewed: [N] of [M] present
Not read: [each GDD that could not be read or is present but empty, by file name — or "none"]
Focus: [full / consistency only — design theory not run / design theory only — consistency not run]
Systems Covered: [list]

---

### Consistency Issues

#### Blocking (must resolve before architecture begins)
🔴 [Issue title]
[What GDDs are involved, what the contradiction is, what needs to change]

#### Warnings (should resolve, but won't block)
⚠️  [Issue title]
[What GDDs are involved, what the concern is]

---

### Game Design Issues

#### Blocking
🔴 [Issue title]
[What the problem is, which GDDs are involved, design recommendation]

#### Warnings
⚠️  [Issue title]
[What the concern is, which GDDs are affected, recommendation]

---

### Cross-System Scenario Issues

Scenarios walked: [N]
[List scenario names]

#### Blockers
🔴 [Scenario name] — [Systems involved]
[Step where failure occurs, nature of the failure mode, what must be resolved]

#### Warnings
⚠️  [Scenario name] — [Systems involved]
[What the unintended outcome is, recommendation]

#### Info
ℹ️  [Scenario name] — [Systems involved]
[Minor ordering ambiguity or note]

---

### GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| [system-a].md | Rule contradiction with [system-b].md | Consistency | Blocking |
| [system-b].md | Rule contradiction with [system-a].md | Consistency | Blocking |
| [system-c].md | Stale reference to nonexistent mechanic | Consistency | Blocking |
| [system-d].md | No pillar alignment | Design Theory | Warning |

---

### Verdict: [PASS / NOT ASSESSED / CONCERNS / FAIL]

PASS: No blocking issues and no warnings.
NOT ASSESSED: One or more review phases could not run — named below.
CONCERNS: Warnings present that should be resolved, but nothing blocking.
FAIL: One or more blocking issues must be resolved before architecture begins.

### If NOT ASSESSED — what could not be reviewed, and why:
[Name each phase that did not run and the input it needed, and each GDD that could not be read or is present but empty, by file name]

### If FAIL — required actions before re-running:
[Specific list of what must change in which GDD]
```

**`NOT ASSESSED` — 交叉评审的广度只等于它能读取到的范围。** 排序：**高于 PASS**，**低于 CONCERNS 和 FAIL**。本技能的全部价值在于把各系统*相互比较*，因此它极易看似详尽，实际只覆盖了一小部分范围。在出现以下任一情况时输出它：

- **可读取的 GDD 少于两个。** 在单个文档内找矛盾不是交叉评审；那里得到干净结果只说明没有比较过任何东西。这是本技能中最重要的单一触发条件。
- **某个完整的评审阶段没有运行** — 一致性、设计理论、经济、支柱漂移 — 而它本应运行。聚焦参数省去的某一轮不属于此触发条件：那是用户要求的。此时给出已运行那一轮的结论并加上标注 — `PASS (consistency only — design theory not run)` — 并填写 `Focus:` 行。返回空内容的并行阶段必须与返回无发现的阶段区分开；如果某个被启动的代理没有产出报告，该阶段是 NOT ASSESSED，而不是干净 — 代理可能返回一句流畅的话、什么都没写，却消耗了一个阶段。
- **设计支柱未定义**，因此支柱漂移没有可漂移的参照 — 这与没有提交层级设定的无障碍闸门情形相同。
- **某个 GDD 存在但为空**（只有标题，或全是占位符），**或无法读取**。存在不等于可评审，而一个存根不会与任何东西矛盾。

无论哪种情况都要明确报告覆盖集合：`GDDs reviewed: [N] of [M] present`（`[M]` 统计存在的系统 GDD — 即 Phase 1c 的集合，而非 `game-concept.md`、`game-pillars.md`、`systems-index.md` 或更早的 `gdd-cross-review-*.md`），以及 `Not read:` 行，按文件名列出每一个无法读取或存在但为空的 GDD，无论结论是什么 — 在已读取的 GDD 中发现 FAIL 并不会让未读取的 GDD 变成已评审。一个悄悄跳过一半系统的交叉评审，与一个发现它们彼此一致的交叉评审无法区分。

---
