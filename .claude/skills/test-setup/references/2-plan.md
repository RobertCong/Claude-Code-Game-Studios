# /test-setup — Phase 2: 呈现计划

> `/test-setup` 的一部分。`SKILL.md` 说明何时读取本文件；它解析出的设置
> 以及其后续标题下的规则在此仍然适用。

## Phase 2: 呈现计划

根据检测到的引擎和现有状态，呈现一份计划：

```
## Test Setup Plan — [Engine]

I will create the following (skipping any that already exist):

tests/
  unit/           — Isolated unit tests for formulas, state, and logic   (Godot only)
  integration/    — Cross-system tests and save/load round-trips         (Godot only)
  smoke/          — Critical path test list (15-minute manual gate)
  README.md       — Test framework documentation

[Unity/Unreal: unit and integration tests go under the engine's test root
 instead — Unity Assets/Tests/EditMode|PlayMode/, Unreal
 Source/<Module>/Private/Tests/ — because neither compiles code in tests/]

production/qa/
  evidence/       — Screenshot and manual test sign-off records

[Engine-specific files — see per-engine details below]

.github/workflows/tests.yml  — CI: run tests on every push to main

Estimated time: ~5 minutes to create all files.
```

询问：“May I create these files? I will not overwrite any test files that
already exist at these paths.”

**在 `collaborative` 和 `guided` 下** — 未经批准不要继续。这些是
**新**文件，且 `automation-modes.md:81` 在 `guided` 下也会对新文件写入设闸，
因此两种模式下的答案相同。**在 `autonomous` 下** — 创建它们并记录
该决策；不要阻塞。

---
