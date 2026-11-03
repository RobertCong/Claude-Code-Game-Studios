# /smoke-check — Phase 6: 写入并把关

> 属于 `/smoke-check`。`SKILL.md` 指明何时读取本文件；它解析出的设置以及其后各标题下的规则在此同样适用。

## Phase 6: 写入并把关

**本文件包含：**

- 优先 `qa.level`
- 解析闸门执行级别
- 按结论：FAIL（阻塞或建议性）、NOT ASSESSED、PASS WITH WARNINGS、PASS

先在对话中呈现完整报告，然后询问：

"May I write this smoke check report to `production/qa/smoke-[date].md`?"

仅在获得批准后写入。

**首先应用 `qa.level`（此前已解析）。** 在 `qa.level: minimal` 下，FAIL 无论 `testing.strict.config` 如何都是**建议性**的 — 跳过下面的解析，直接给出建议性 FAIL 的结果（冒烟检查在 minimal 下是可选的，绝不阻塞交接）。否则：

**解析闸门执行级别。** FAIL 结论要么*阻塞* QA 交接，要么在*交接继续进行的同时被标记*，由 **本技能顶部 resolved-config 块中解析的** `testing.strict` 块决定（该块将 `project.local.yaml` 合并到 `project.yaml` 之上 — 读取该块，而不是文件，否则开发者的本地覆盖会被悄悄忽略）：

1. 从该已解析块中取 `testing.strict.config`。若其值为 `true`（不区分大小写）→ 阻塞；若为 `false` → 建议性；`unset` → 继续下一步。
2. 否则将 `testing.strict` 作为普通布尔值读取（旧版单值形式）— 若其值为 `true` 或 `false`，则适用。
3. 否则默认为**阻塞** — 未设置的 `testing.strict.config` 会保持冒烟检查的 FAIL 闸门为阻塞。冒烟检查是构建健康闸门，因此其未设置时的默认值是严格的，即使 `config` 测试类型在其他地方默认为建议性。对应的豁免记录在 `.claude/skills/story-done/SKILL.md` 和 `.claude/docs/coding-standards.md` 中，它们拥有按用户故事的证据表。

仅 `true` 和 `false`（不区分大小写）在第 1–2 步被识别。一个存在但持有其他任何值的键 — `maybe`、`1`、`yes` 等 — 按未设置处理：继续下一步，并向用户呈现该无法识别的值。

写入之后，给出闸门结论：

**若结论为 FAIL 且闸门为阻塞：**

"冒烟检查失败。在这些失败被解决之前，不要交接给 QA：

[列出每个失败的自动化测试或冒烟检查，附一行描述]

修复这些失败并再次运行 `/smoke-check`，在交接 QA 之前重新把关。"

**若结论为 FAIL 且闸门为建议性**（`testing.strict.config: false`）：

"冒烟检查失败，但 `testing.strict.config` 设为建议性 — QA 交接不被阻塞。在发布前解决这些问题：

[列出每个失败的自动化测试或冒烟检查，附一行描述]

QA 交接：把 `production/qa/qa-plan-[sprint].md` 交给 qa-tester 代理以开始手动验证。失败修复后重新运行 `/smoke-check`。"

**若结论为 NOT ASSESSED：**

"冒烟检查无法确立构建健康状况 — 它没有失败，它没有运行。不要基于此结果交接给 QA：

[列出每个无法执行的检查及原因：套件未确认 NOT RUN、`PlayMode: NOT RUN`、执行了零测试、运行器未安装、找不到引擎可执行文件、没有构建、本次会话未启动构建、平台不可用]

[对每一项，说明唯一能使其可运行的做法 — 例如 '从你的 IDE 或 CI 确认套件结果'、'运行 `/setup-engine`'、'设置 `engine.path`'、'产出构建'、'启动构建并试玩这些检查'。]

任何这些被解决后，重新运行 `/smoke-check`。"

此结果**不受 `testing.strict.config` 管辖**。该设置决定一次*失败*是否阻塞交接；它对一个从未产生结果的检查无话可说，而把一个未运行的检查读成"建议性因而没问题"正是此结论所要防止的替换。说明什么无法检查，让用户决定 — 不要替他们将其解析为通过或 FAIL。

**若结论为 PASS WITH WARNINGS：**

"冒烟检查通过，但有警告。构建已准备好进行手动 QA。

在受影响用户故事上运行 `/story-done` 之前需解决的建议性项：
[列出 MISSING 测试证据条目，以及任何运行器警告 — 例如孤儿节点数]

QA 交接：把 `production/qa/qa-plan-[sprint].md` 交给 qa-tester 代理以开始手动验证。"

**若结论为 PASS：**

"冒烟检查干净通过。构建已准备好进行手动 QA。

QA 交接：把 `production/qa/qa-plan-[sprint].md` 交给 qa-tester 代理以开始手动验证。"

---
