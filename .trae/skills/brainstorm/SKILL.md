---
name: brainstorm
description: "引导用户发现并选定游戏概念。当用户想要游戏创意、新概念、game jam 创意，或想探索其他方向（包括放弃当前想法从头开始）时使用。"
argument-hint: "[genre or theme hint, or 'open'] [--review full|lean|solo]"
user-invocable: true
---

**运行并读取输出：** `bash "${CLAUDE_SKILL_DIR}/../../hooks/yaml-helper.sh" resolve_config --keys review_mode,automation,docs.density,workflow`

以上命令的输出已解析；直接使用。无配置块 → 使用 `.trae/docs/config-resolution.md`
中的默认值（`workflow: minimal`、`review_mode: solo`、`automation: collaborative`、`docs.density: terse`），
并说明这些设置未被读取。

# 头脑风暴（Brainstorm）

把「没有想法」或「含糊的想法」变成下一步可以据以构建的书面的设计。写多少
取决于 `workflow`：

- **`minimal`：** 走下面的精简简报（Lean Brief）流程：写一页 `design/game-brief.md`，然后停止。不做
  探索性问题、游戏支柱（pillar）、总监质量闸门（director gate），也不写 `game-concept.md`，并且不要加载
  `references/full-concept.md`。
- **`standard` 或 `full`：** 读取 `references/full-concept.md` 并遵循它。它依据 `.trae/docs/templates/game-concept.md`
  写出 `design/gdd/game-concept.md`。它的质量闸门（gate）遵循
  `.trae/docs/director-gates.md`；每个总监代理（director agent）会拿到自己的闸门文件，
  `.trae/docs/director-gates/<gate-id in lower case>.md`（`cd-pillars.md`、
  `ad-concept-visual.md`、`td-feasibility.md`、`pr-scope.md`），你不要自己去读这些文件。

技能名之后输入的文本中的 `--review` 会覆盖本次运行的 `review_mode`。
`docs.density` 设定每节的深度：`terse` = 要点列表；`balanced` = 附简要理由；
`thorough` = 理由与备选方案。提问遵循 `.trae/docs/automation-modes.md`
（collaborative 会问，guided 只问重大决策，autonomous 记录日志并继续；
always-ask 类别始终会问）。

用提问工具提问。若没有该工具，把选项编号列出并结束本轮以等待。问题
是回复中的最后一件事：其后不给建议或倾向。被跳过或关闭的问题不算答案：用纯文本再问一次。

## 精简简报流程（`workflow: minimal`）

几次交流，而不是十五次：把支撑这款游戏的想法浓缩到一页，然后进入
编码。依据模板 `.trae/docs/templates/game-brief.md` 撰写（六个必填字段、三个
单行项）。如果 `design/game-brief.md` 已存在，读取并完善它，而不是从头开始。

1. **概念。** 根据技能名之后输入的提示（若没有提示，则问一个简短的开放式问题），提出 **2 或 3 个单行概念**（以动词开头，或类型与主题的混搭），而不是
   完整的概念卡片。请用户选择或组合。这是每次运行都会问的唯一一个创意性问题。
2. **在对话中填写简报**，每次交流填几个字段：
   - **暂定名称：** 简报的标题行。基于所选概念提供一个，并让用户
     修改；`/create-stories` 会用它命名史诗（epic）文件夹。
   - **提案（Pitch）：** 令人兴奋的一句话介绍。
   - **核心循环：** 玩家重复的 2 到 4 个步骤。
   - **玩家目标与失败状态**：玩家试图做什么，以及他们如何失败。
     `/create-stories` 会把它转成验收标准。
   - **MVP：** 让它成为这款游戏的简短列表；每一项都会变成一个用户故事。**超过 7
     项就推回去。** 说明这对 MVP 来说太长，提出应删减哪些项（核心循环缺了也能运转的那些），
     并把简报控制在 7 项或更少。
   - **范围之外：** 他们刻意不做的内容（删掉的项放到这里）。
   - **构建顺序：** 风险最高或最未经证实部分排在最前。
   - **面向谁以及他们的感受**、**美术与音频方向**、**参考游戏**（最接近的已发行游戏，以及 MVP 保留其中哪一部分）：各一行；提供建议，不要强加。
3. **完整展示填好的简报。** 然后单独提问："简报已就绪。我可以把它写入
   `design/game-brief.md` 吗？" `Yes — write it` / `Revise a field first`。只有对该问题的明确
   yes 才写入；同意删减某项或说"go on"不算对写入的 yes。若需修改，改动所指定的字段，展示
   修改前后，然后再问一次。然后写入
   `design/game-brief.md`，按需创建文件夹。在此层级绝不写 `design/gdd/game-concept.md`。
4. **后续步骤。** 读取 `project.yaml` 中的 `engine.name`：
   1. `/setup-engine`：配置引擎。**仅**当 `engine.name` 缺失或
      为空时才列出它：在 minimal 路径上，它通常在本技能之前已运行过。
   2. `/create-stories`：把 MVP 列表转成用户故事。在 `minimal` 下没有单独的
      `/create-epics` 或 `/sprint-plan`；构建顺序就是计划。
   3. `/dev-story`：第一行游戏代码。

   然后一行总结：提案、MVP 条目数和 `design/game-brief.md`。以
   这一行结尾 `Verdict: COMPLETE — game brief written; next stop is code.`

如果用户在写入前停下，说明简报未被写入，因此它只存在于这次
对话中。