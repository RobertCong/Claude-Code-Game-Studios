# /architecture-review — Phase 9: 交接

> 属于 `/architecture-review` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## Phase 9: 交接

完成评审并写入已批准文件后，呈现：

1. **立即行动**：列出要创建的前 3 个 ADR（影响最大的缺口优先，
   Foundation 层先于 Feature 层）
2. **质量闸门前检查清单**：通过 Glob 检查这些是否存在，并逐项标记 ✅ 或 ❌：
   - 引擎的测试根目录 —— `tests/unit/` 和 `tests/integration/`（Godot）、`Assets/Tests/EditMode/` 和 `Assets/Tests/PlayMode/`（Unity）、`Source/<Module>/Private/Tests/`（Unreal）—— 若为 ❌：运行 `/test-setup`
   - `.github/workflows/tests.yml` —— 若为 ❌：运行 `/test-setup`
   - `design/accessibility-requirements.md` —— 若为 ❌：运行 `/ux-design`
   - `design/ux/interaction-patterns.md` —— 若为 ❌：运行 `/ux-design`
   将 ❌ 项作为质量闸门检查前的必需步骤呈现。若任何一项为 ❌，不要提供 `/gate-check`
   选项 —— 改为提供需要运行的缺失技能。
3. **重跑触发条件**："每写完一个新 ADR 后重新运行 `/architecture-review`，
   以验证覆盖率有所提升"

然后用根据质量闸门前检查清单状态定制的 `AskUserQuestion` 收尾：
- 若仍有 ADR 缺口或任何质量闸门前项为 ❌：
  - "架构评审完成。你接下来想做什么？"
    - [A] Write a missing ADR — open a fresh session and run `/architecture-decision [system]`
    - [B] Run `/test-setup` — required before gate-check (only show if test infrastructure is ❌)
    - [C] Run `/ux-design` — required before gate-check (only show if UX/accessibility files are ❌)
    - [D] Stop here for this session
- 若质量闸门前检查清单所有项均为 ✅，且没有阻塞性的 ADR 缺口：
  - "架构评审完成。所有质量闸门前项已确认。你接下来想做什么？"
    - [A] Run `/gate-check pre-production`
    - [B] Write a missing ADR — open a fresh session and run `/architecture-decision [system]`
    - [C] Stop here for this session

---
