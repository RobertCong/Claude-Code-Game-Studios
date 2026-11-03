---
name: smoke-check
description: "QA 交接前的关键路径冒烟闸门 — 运行自动化测试套件。检查失败意味着该构建尚未达到可交 QA 的状态。"
argument-hint: "[sprint | quick | --platform pc|console|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(bash "*/.claude/skills/smoke-check/../../hooks/yaml-helper.sh" resolve_config *), Bash(bash .claude/scripts/project-coherence.sh*), Bash(command -v *), Bash(uname -s), Bash(godot --headless --path . --import), Bash(timeout 900 godot --headless *), Bash(timeout 1800 godot --headless *), Bash(grep -q 'com.unity.test-framework' Packages/manifest.json), Bash(echo present), Bash(echo ABSENT)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level,testing.strict`

# 冒烟检查

本技能是"实现完成"与"可交接 QA"之间的闸门。它运行自动化测试套件、检查测试覆盖率缺口、与开发者批量核验关键路径，并生成 PASS/FAIL 报告。

规则很简单：**冒烟检查失败的构建不能交给 QA。** 把坏掉的构建交给 QA 会浪费他们的时间并打击团队士气。

**输出：** `production/qa/smoke-[date].md`

---

每次 `AskUserQuestion` 调用都遵循 `.claude/docs/automation-modes.md`（collaborative 始终询问 · guided 仅重大事项 · autonomous 记录后继续；`automation_always_ask` 类别始终询问）。

**`qa.level`**：在 `minimal` 下，冒烟检查是**可选的** — 若运行，FAIL 仅为建议性，绝不阻塞交接，且没有游戏测试的项目仅通过其构建、启动和关键路径来检查（Phase 1 第 1 步）；在 `standard` 下，它是阶段转换前的必需项；在 `full` 下，它在每次提交前必需。这位于 Phase 6 的 `testing.strict.config` 解析之前（后者只有在某次冒烟运行开始把关后才起作用）。与 `workflow` 是不同维度。

## 解析参数

参数可以组合使用：`/smoke-check sprint --platform console`

**基础模式**（第一个参数，默认：`sprint`）：
- `sprint` — 针对当前冲刺的用户故事执行完整冒烟检查
- `quick` — 跳过覆盖率扫描（Phase 3）和 Batch 3；用于快速复检

**平台标志**（`--platform`，默认：无）：
- `--platform pc` — 增加 PC 特定检查（键盘、鼠标、窗口化模式）
- `--platform console` — 增加主机特定检查（手柄、电视安全区、
  平台认证要求）
- `--platform mobile` — 增加移动端特定检查（触摸、竖屏/横屏、
  电池/发热表现）
- `--platform all` — 增加所有平台变体；输出按平台的结论表

如果提供了 `--platform`，Phase 4 会增加平台特定的批次，Phase 5 会在总体结论之外输出一张按平台的结论表。

---

## Phase 1: 检测测试环境

**现在读取 `references/1-detect-setup.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 2: 运行自动化测试

**现在读取 `references/2-run-tests.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 3: 检查测试覆盖率

**现在读取 `references/3-coverage.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 4: 运行手动冒烟检查

**现在读取 `references/4-manual-checks.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 5: 生成报告

**现在读取 `references/5-report.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## Phase 6: 写入并把关

**现在读取 `references/6-write-gate.md` 并照做** — 本阶段的步骤在该文件中，不在此处。如果本阶段进行中对话被压缩或恢复，请再次读取该文件。

## 协作协议

**适用于 `collaborative` 模式（默认）。** 关于 `guided` 和 `autonomous` 模式，见 `.claude/docs/automation-modes.md` — 下面的规则描述的是 collaborative 模式的要求，而非通用行为。

- **绝不把 NOT RUN 视为自动 FAIL** — 将其记录为 NOT RUN，让开发者手动确认状态。未经确认的 NOT RUN 得出 **NOT ASSESSED**，不是 FAIL — 也不是通过结论。
- **绝不自动修复失败** — 报告它们并说明必须解决什么。不要尝试编辑源代码或测试文件。
- **PASS WITH WARNINGS 不阻塞 QA 交接** — 它记录建议性缺口，供 `/story-done` 后续跟进。
- **`quick` 参数**跳过 Phase 3（覆盖率扫描）和 Phase 4 的 Batch 3。用于修复特定失败后的快速复检。
- 所有手动冒烟检查核验都使用 `AskUserQuestion`。
- **绝不未询问就写报告** — Phase 6 要求在创建任何文件之前获得明确批准。
