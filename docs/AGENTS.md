# Docs 目录

在本目录中编写或编辑文件时，请遵循以下标准。

## 架构决策记录（`docs/architecture/`）

使用 ADR 模板：`.claude/docs/templates/architecture-decision-record.md`

**必需章节：** Title、Status、Context、Decision、Consequences、
ADR Dependencies、Engine Compatibility、GDD Requirements Addressed

**状态生命周期：** `Proposed` → `Accepted` → `Superseded`
- 绝不跳过 `Accepted` —— 引用 `Proposed` ADR 的用户故事会被自动阻塞
- 使用 `/architecture-decision` 通过引导流程创建 ADR

**TR 注册表：** `docs/architecture/tr-registry.yaml`
- 稳定的需求 ID（例如 `TR-movement-001`），将 GDD 需求链接到用户故事
- 绝不重新编号已有 ID —— 只追加新 ID
- 由 `/architecture-review` Phase 8 更新

**控制清单：** `docs/architecture/control-manifest.md`
- 平实的程序员规则表：按层给出 Required / Forbidden / Guardrails
- 表头带日期戳的 `Manifest Version:`
- 用户故事会嵌入该版本；`/story-done` 会检查是否过期

**验证：** 完成一组 ADR 后运行 `/architecture-review`。

## 引擎参考（`docs/engine-reference/`）

版本锁定的引擎 API 快照。**使用任何引擎 API 之前务必先查这里** ——
LLM 的训练数据早于锁定的引擎版本。

当前引擎：参见 `docs/engine-reference/<engine>/VERSION.md`（`<engine>` 为 `godot`、`unity` 或 `unreal`，与 `project.yaml` 中的 `engine.name` 一致）
