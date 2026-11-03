---
name: test-setup
description: "搭建测试框架与 CI — tests/ 目录、引擎测试运行器、GitHub Actions 工作流。在首个冲刺之前执行一次。"
argument-hint: "[force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash(grep -q 'com.unity.test-framework' Packages/manifest.json), Bash(bash "*/.claude/skills/test-setup/../../hooks/yaml-helper.sh" resolve_config *)
model: sonnet
---

!`bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys automation,workflow,qa.level`

**自动化模式**：解析 `modes.automation`（`project.local.yaml` →
`project.yaml` → 默认 `collaborative`）。每次 `AskUserQuestion` 调用和
每次文件写入都遵循 `.claude/docs/automation-modes.md`
（collaborative 始终询问 · guided 仅重大事项 · autonomous 记录并继续；
`automation_always_ask` 类别始终提示）。

# Test Setup

本技能为项目搭建自动化测试基础设施。
它检测已配置的引擎，生成相应的测试运行器
配置，创建标准目录布局，并接通 CI/CD，
使测试在每次推送时运行。

在 Technical Setup 阶段、任何实现开始之前运行一次。
在冲刺开始时安装测试框架只需 30 分钟。
在第四个冲刺时安装测试框架则要花费 3 个冲刺。

**输出：** `tests/` 目录结构 + `.github/workflows/tests.yml`

---

## Phase 1: 检测引擎与现有状态

**现在读取 `references/1-detect.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 2: 呈现计划

**现在读取 `references/2-plan.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 3: 创建目录结构

**现在读取 `references/3-directories.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 4: 创建 CI/CD 工作流

**现在读取 `references/4-ci.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 5: 创建冒烟测试种子

**现在读取 `references/5-smoke-seed.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## Phase 6: 安装后摘要

**现在读取 `references/6-summary.md` 并遵循其中的步骤** — 本阶段的步骤在该文件中，不在此处。如果在执行本阶段期间对话被压缩或恢复，请再次读取该文件。

## 协作协议

- **绝不覆盖现有测试文件** — 只创建缺失的文件。
  如果测试运行器文件已存在，保持原样。
- **创建文件前始终询问** — Phase 2 需要明确批准。
- **引擎检测不可协商** — 如果引擎未配置，
  停止并重定向到 `/setup-engine`。不要猜测。
- **`force` 标志跳过“已存在”的提前退出，但绝不覆盖。**
  它意味着“即使目录已存在，也创建任何缺失的文件。”
- 对于 Unity CI，注意必须手动配置 `UNITY_LICENSE` 密钥。
  不要试图自动化许可证管理。
