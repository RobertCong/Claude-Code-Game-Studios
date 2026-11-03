# Studio Tests

**Claude Code Game Studios** 框架的质量保证基础设施。
测试技能和代理本身 —— 而不是用它们构建的任何游戏。

**它作为模板的一部分发布，而且本就应当如此。** CCGS 是一个预期由你定制的
模板 —— 编辑技能、添加自己的技能、重新调整代理。这个文件夹用来检查你所做的
修改是否仍然站得住脚：`catalog.yaml` 跟踪全部 74 个技能和 49 个代理，
`quality-rubric.md` 定义按类别的通过/失败指标，`templates/` 为你新写的任何
规格提供格式。由 `/skill-test` 和 `/skill-improve` 驱动。

> **如果删除它，`/skill-test` 四个模式中的两个会停止工作。**
>
> | 模式 | 没有此文件夹时 |
> |------|---------------------|
> | `/skill-test static` | **可用** —— 7 项结构检查只读取技能自己的文件 |
> | `/skill-test audit` | **降级** —— 报告不存在目录 |
> | `/skill-test spec` | **失效** —— 行为规格存放在这里 |
> | `/skill-test category` | **失效** —— 从这里读取 `quality-rubric.md` |
> | `/skill-improve` | **降级** —— 其测试-修复-重测循环失去类别通过环节 |
>
> `/skill-test` 和 `/skill-improve` 按路径读取此文件夹，因此删除它是一个真实的
> 取舍，不是免费的清理 —— 上表说明了实际代价。

---

## 这里有什么

```
studio-tests/
├── README.md              ← you are here
├── AGENTS.md              ← tells Claude how to use this framework
├── catalog.yaml           ← master registry: all 74 skills + 49 agents, coverage tracking
├── quality-rubric.md      ← category-specific pass/fail metrics for /skill-test category
│
├── skills/                ← behavioral spec files for all 74 skills
│   ├── gate/              ← gate category specs
│   ├── review/            ← review category specs
│   ├── authoring/         ← authoring category specs
│   ├── readiness/         ← readiness category specs
│   ├── pipeline/          ← pipeline category specs
│   ├── analysis/          ← analysis category specs
│   ├── team/              ← team category specs
│   ├── sprint/            ← sprint category specs
│   └── utility/           ← utility category specs
│
├── agents/                ← behavioral spec files for agents (one per agent)
│   ├── directors/         ← creative-director, technical-director, producer, art-director
│   ├── leads/             ← lead-programmer, narrative-director, audio-director, game-designer, systems-designer, level-designer, qa-lead
│   ├── specialists/       ← gameplay/engine/network/AI/tools/UI programmers, technical-artist, sound-designer, ux-designer, performance-analyst, prototyper, writer, world-builder
│   ├── engine/            ← engine-specific specialists, split per engine:
│   │   ├── godot/         ← Godot-specific specialists
│   │   ├── unity/         ← Unity-specific specialists
│   │   └── unreal/        ← Unreal-specific specialists
│   ├── operations/        ← devops, release, live-ops, community, analytics, economy, localization
│   └── qa/                ← qa-tester, security-engineer, accessibility-specialist
│
├── templates/             ← spec file templates for writing new specs
│   ├── skill-test-spec.md ← template for skill behavioral specs
│   └── agent-test-spec.md ← template for agent behavioral specs
│
└── results/               ← test run outputs (written by /skill-test spec; not gitignored — add it to .gitignore to keep them out of commits)
```

---

## 如何使用

所有测试都由框架中已有的两个技能驱动：

### 检查结构合规

```
/skill-test static [skill-name]     # Check one skill (7 checks)
/skill-test static all              # Check all 74 skills
```

### 运行行为规格测试

```
/skill-test spec gate-check         # Evaluate a skill against its written spec
/skill-test spec design-review
/skill-test spec creative-director  # Agents too: evaluates agents/directors/creative-director.md
```

### 按类别评分标准检查

```
/skill-test category gate-check     # Evaluate one skill against its category metrics
/skill-test category art-director   # Or one agent, against its agent category
/skill-test category all            # Run rubric checks across every categorized skill and agent
```

### 查看完整覆盖情况

```
/skill-test audit                   # Skills + agents: has-spec, last tested, result
```

### 改进失败的技能

```
/skill-improve gate-check           # Test → diagnose → propose fix → retest loop
```

---

## 技能类别

| 类别 | 技能 | 关键指标 |
|----------|--------|-------------|
| `gate` | gate-check | 读取评审模式、full/lean/solo 总监小组、不自动推进 |
| `review` | design-review, architecture-review, review-all-gdds | 只读、8 章节检查、正确结论 |
| `authoring` | design-system, quick-design, art-bible, create-architecture, … | 逐章节 May-I-write、骨架优先 |
| `readiness` | story-readiness, story-done | 暴露阻塞项、full 模式下的总监闸门 |
| `pipeline` | create-epics, create-stories, dev-story, map-systems, … | 上游依赖检查、交接路径清晰 |
| `analysis` | consistency-check, balance-check, code-review, tech-debt, … | 只读报告、结论关键词、不写入 |
| `team` | team-combat, team-narrative, team-audio, … | 生成所有必需代理、暴露阻塞 |
| `sprint` | sprint-plan, sprint-status, milestone-review, … | 读取冲刺数据、包含状态关键词 |
| `utility` | start, adopt, hotfix, localize, setup-engine, … | 通过静态检查 |

---

## 代理层级

| 层级（目录） | 代理 |
|------|--------|
| `directors` | creative-director, technical-director, producer, art-director |
| `leads` | lead-programmer, narrative-director, audio-director, game-designer, systems-designer, level-designer, qa-lead |
| `specialists` | gameplay-programmer, engine-programmer, network-programmer, ai-programmer, tools-programmer, ui-programmer, ux-designer, technical-artist, sound-designer, performance-analyst, prototyper, writer, world-builder |
| `engine/godot` | godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist |
| `engine/unity` | unity-specialist, unity-ui-specialist, unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist |
| `engine/unreal` | unreal-specialist, ue-gas-specialist, ue-replication-specialist, ue-umg-specialist, ue-blueprint-specialist |
| `operations` | devops-engineer, release-manager, live-ops-designer, community-manager, analytics-engineer, economy-designer, localization-lead |
| `qa` | qa-tester, security-engineer, accessibility-specialist |

---

## 更新目录

`catalog.yaml` 跟踪每个技能和代理的测试覆盖情况。运行测试后：

- `/skill-test spec [name]` 会提出更新 `last_spec` 和 `last_spec_result`
- `/skill-test category [name]` 会提出更新 `last_category` 和 `last_category_result`
- `last_static` 和 `last_static_result` 手动更新，或通过 `/skill-improve` 更新

---

## 编写新规格

1. 找到规格模板 `templates/skill-test-spec.md`
2. 将其复制到 `skills/[category]/[skill-name].md`
3. 更新 `catalog.yaml` 中的 `spec:` 字段，指向新文件
4. 运行 `/skill-test spec [skill-name]` 验证

对于代理，把 `templates/agent-test-spec.md` 复制到 `agents/[tier]/[agent-name].md`，
在 `catalog.yaml` 的 `agents:` 下该条目上设置 `spec:` 字段，然后运行
`/skill-test spec [agent-name]`。

---

## 删除此框架

主项目中没有任何钩子或导入依赖此文件夹，但 `/skill-test`
和 `/skill-improve` 会按路径读取它。删除方法：

```bash
rm -rf studio-tests
```

之后 `/skill-test static` 照常工作，`spec` 和 `category` 停止工作，
`audit` 报告不存在目录，`/skill-improve` 跳过其类别检查 —— 本文件顶部的
表格列出了每个模式的代价。
