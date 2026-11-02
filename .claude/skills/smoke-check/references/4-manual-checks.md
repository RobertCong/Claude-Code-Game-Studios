# /smoke-check — Phase 4: 运行手动冒烟检查

> 属于 `/smoke-check`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 4: 运行手动冒烟检查

**本文件包含：**

- 检查清单来源：在报告中指明它
- Batch 1 — 核心稳定性
- Batch 2 — 冲刺变更与回归
- Batch 3 — 数据完整性与性能
- 平台批次：PC、主机、移动端

按以下优先级顺序获取冒烟测试检查清单（并在报告中指明你使用的是哪一个）：
1. QA 计划的 "Smoke Test Scope" 章节（若 Phase 1 中找到了 QA 计划）
2. `production/qa/smoke-tests.md`（若存在）
3. `tests/smoke/` 目录内容（若存在）
4. 下面的标准回退清单（仅当以上都不存在时使用）

**在报告中指明你使用的来源**，单独一行 — *"Checklist source: `production/qa/smoke-tests.md`"*，或 *"Checklist source: standard fallback list — no QA plan scope, no `production/qa/smoke-tests.md`, no `tests/smoke/`."* 回退是真正的回退，因此此处没有内容被悄悄跳过，但如果没有这一行，一份取自通用清单的报告读起来会与一份取自本项目自身冒烟定义的报告一模一样。`/gate-check` 会对照仓库验证冒烟报告的主张，而如果不知道检查清单来自何处，它就无法权衡这些主张。

根据从冲刺或 QA 计划中识别出的实际系统，调整 Batch 2 和 Batch 3。用当前冲刺用户故事中的真实机制名称替换方括号占位符。

使用 `AskUserQuestion` 进行批量核验。最多保持 3 次调用。

**Batch 1 — 核心稳定性（始终运行）：** 一次调用，两个问题 — 除非有人启动过构建，否则空的失败列表说明不了什么。
```
question: "Did you launch the current build this session?"
multiSelect: false
options:
  - "Yes — I launched it and checked the items below"
  - "No — I have not launched the current build this session"

question: "Core stability — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Game does not launch or crashes before reaching the main menu"
  - "New game / session fails to start"
  - "Main menu does not respond to inputs"
  - "Crash or hang observed during basic navigation"
```

对任何被选中的项，在生成报告之前请用户简要描述失败了什么。

如果构建**未被启动**，则 Batch 1 检查无法执行：将它们记录为 `NOT RUN — build not launched this session`，跳过 Batch 2、Batch 3 以及任何平台批次（说明这一点 — 它们需要一个运行中的构建），并忽略未选中的失败列表。除非其他东西 FAILED，否则结论为 NOT ASSESSED。

**Batch 2 — 冲刺变更与回归（始终运行）：**
```
question: "Sprint changes and regression — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "[Primary mechanic this sprint] — FAILED"
  - "[Second notable change this sprint, if any] — FAILED"
  - "Regression in a previous sprint's feature — FAILED"
  - "Other unexpected breakage observed — FAILED"
```

对任何被选中的项，在生成报告之前请用户简要描述坏掉了什么。

**Batch 3 — 数据完整性与性能（除非有 `quick` 参数，否则运行）：**
```
question: "Data integrity and performance — select any items that FAILED or were skipped (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Save / load — FAILED (data loss or corruption observed)"
  - "Save / load — N/A (save system not yet implemented)"
  - "Frame rate drops or hitches observed — FAILED"
  - "Performance not checked this session"
```

对任何被选中的 FAILED 项，在生成报告之前请用户描述坏掉了什么。

逐字记录每个回答，供 Phase 5 报告使用。

**平台批次** *（仅在提供了 `--platform` 参数时运行）*：

**PC 平台**（`--platform pc` 或 `--platform all`）：
```
question: "PC Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Keyboard controls — FAILED (describe issue after)"
  - "Mouse input or cursor visibility — FAILED (describe issue after)"
  - "Windowed / fullscreen mode — FAILED (describe issue after)"
  - "Resolution change — FAILED (describe issue after)"
```

对任何被选中的项，在生成报告之前请用户简要描述失败了什么。

**主机平台**（`--platform console` 或 `--platform all`）：
```
question: "Console Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Gamepad input — FAILED (describe issue after)"
  - "UI outside TV safe zone / text clipped — FAILED (describe what is clipped after)"
  - "Keyboard/mouse fallback shown to gamepad user — FAILED (describe after)"
  - "Cold start (no prior save) — FAILED (describe issue after)"
```

对任何被选中的项，在生成报告之前请用户简要描述失败了什么。

**移动端平台**（`--platform mobile` 或 `--platform all`）：
```
question: "Mobile Platform — select any items that FAILED (leave all unselected if everything passed):"
multiSelect: true
options:
  - "Touch controls — FAILED (describe issue after)"
  - "Orientation change (portrait ↔ landscape) — FAILED (describe what breaks after)"
  - "Background / foreground transition (home button) — FAILED (describe issue after)"
  - "Performance / thermal throttling on target device — FAILED (describe after)"
```

对任何被选中的项，在生成报告之前请用户简要描述失败了什么。

---
