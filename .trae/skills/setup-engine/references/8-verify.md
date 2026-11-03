# /setup-engine — 第 8 节和第 8.5 节：验证与回读

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 8. 验证 CLAUDE.md 导入

**此导入已在第 4 节写入 — 不要再次编辑，也不要再次
询问。** 第 4 节已将其作为同一次 CLAUDE.md 写入的一部分设置，锚定在
`ENGINE-REFERENCE-IMPORT` 标记上。本步骤只确认结果。

读取 `CLAUDE.md`，确认标记下方的行内容为：

```markdown
@docs/engine-reference/<engine>/VERSION.md
```

其中 `<engine>` 是刚刚配置的引擎。如果它仍指向其他
引擎，说明第 4 节未完成 — 回去完成它，而不是在这里
修补该行。

> **为什么这是一次检查而不是第二次写入。** 在这里重复编辑并
> 使用自己的批准提示，会为同一个改动向用户询问两次，而第二次
> 询问针对的是已经完成的工作。通过标记定位该行，绝不要通过
> `## Engine Version Reference` 标题 — 标记的存在正是为了在标题移动或
> 改写后仍能找到该行。

---

## 8.5 回读你刚刚写入的内容

第 5.5.1 节的 rendering/physics 表警告了这里最常犯的
两个错误，而现在仍然很容易**同时**犯下这两个错误，为 2D 浏览器游戏
写入 `Forward+` 和 `Jolt`。第 3 节的 `Installed at pin time`
行同样容易被静默遗漏，因为缺失的行不会留下痕迹。
通过在写入后验证文件来同时捕获两者：

```bash
bash .claude/scripts/project-coherence.sh
```

它会将 `project.yaml` 与 `docs/engine-reference/<engine>/VERSION.md`、
与 `project.godot`、与实际在 PATH 中的引擎二进制文件进行比较，并
检查 `commands.build` 和 `commands.test` 指定的文件是否存在。

**向用户报告每一行 `[DIFFERS]`，并在结束前解决它。**
每一行都意味着本技能刚写入的两个文件存在分歧，或描述了
并不存在的东西。

在新的 Godot 项目上，有一行是预期内的：`commands.test` 指定了
`addons/gdUnit4/` 下的 gdUnit4 运行器，而 `/test-setup` 稍后才会安装它。报告该
行为预期，说明 `/test-setup` 是清除它的步骤，并且绝不为了
让它消失而编辑 `commands.test`。其他每一行 `[DIFFERS]` 都在这里解决。

**`[NOT CHECKED]` 不算通过。** 每个这样的行都说明了为什么无法进行
比较 -- 缺少二进制文件、缺少 `project.godot`。说明哪些情况
适用。未能执行的比较并未确立一致性。

按照 CLAUDE.md 中的约定，脚本只输出观察结果，从不给出结论。
判断由你和用户做出。

---
