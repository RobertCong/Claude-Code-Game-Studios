# Test Evidence: [Story Title]

> **Story**: `[path to story file]`
> **Story Type**: [Visual/Feel | UI]
> **Date**: [date]
> **Tester**: [执行测试的人]
> **Build / Commit**: [版本或 git 哈希]

---

## What Was Tested

[一段话描述已验证的功能或行为。包含本证据覆盖的用户故事验收标准编号。]

**Acceptance criteria covered**: [AC-1, AC-2, AC-3]

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | [验收标准原文] | PASS / FAIL | [任何观察] |
| AC-2 | [验收标准原文] | PASS / FAIL | |
| AC-3 | [验收标准原文] | PASS / FAIL | |

---

## Screenshots / Video

在下方列出所有已捕获的证据。把文件存放在本文档所在目录，或
`production/qa/evidence/[story-slug]/` 中。

**文件必须确实存在于磁盘上。** Visual/Feel 和 UI 闸门默认是阻塞性的，
`/story-done` 和 `/test-evidence-review` 会通配查找图片——此处列出一个文件名
但旁边没有对应文件，不满足闸门要求。

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `[filename.png]` | [可见内容的简要描述] | AC-1 |
| 2 | `[filename.png]` | | AC-2 |

*如果是视频：注明时间戳及其展示的内容。*

---

## Test Conditions

- **Game state at start**: [例如「全新存档，玩家 1 级，无物品」]
- **Platform / hardware**: [例如「Windows 11，GTX 1080，1080p」]
- **Framerate during test**: [例如「稳定 60fps」或「约 45fps——处于预算内」]
- **Any special setup required**: [例如「使用开发菜单触发特定状态」]

---

## Observations

[任何值得注意但未导致 FAIL 的情况。示例：轻微视觉抖动、负载下的帧率下降、
技术上通过但感觉略有偏差的行为。这些会成为打磨工作的候选。]

- [观察 1]
- [观察 2]

如果无值得注意之处：*无重大观察。*

---

## Sign-Off

**Visual/Feel** 用户故事需要下方的主管签核——由 art-director 或拥有该功能的
设计师——之后 `/story-done` 才会把它标记为 COMPLETE。**UI** 用户故事通过
其触及的每个界面的保留截图来关闭；此处签核受欢迎但不是必需
（`.claude/docs/coding-standards.md`）。

**独立开发者**：你可以自己以主管身份签核。其意图是有人在标记完成前刻意
审阅证据。

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | | | [ ] Approved |

*可选：* 为团队希望参与评审的任何其他人添加一行，例如开发者或 QA 主管。
`/story-done` 和 `/test-evidence-review` 会把此表中的每一行都视为必需，因此
只为会签核的人添加行。

**任何签核都可以标记为 "Deferred — [reason]"**，如果该人无法到场。延后的签核
必须在用户故事通过冲刺评审之前解决。

---

*Template: `.claude/docs/templates/test-evidence.md`*
*Used for: Visual/Feel 和 UI 用户故事类型的证据记录*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
