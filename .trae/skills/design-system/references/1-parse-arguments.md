# /design-system — Phase 1: 解析参数并校验

> 属于 `/design-system` 的一部分。`SKILL.md` 指定何时读取本文件；它已解析的设置
> 以及其后续标题下的规则在此处仍然适用。

## 1. 解析参数并校验

**本文件包含：**

- `docs.density`
- 未给出系统名称：由系统索引选取下一个
- 检测改造模式（retrofit）
- 本系统的 `workflow`，以及每个层级都需要的 `## Summary`

完整检查模式见 `.trae/docs/director-gates.md`。各个质量闸门（gate）的定义位于 `.trae/docs/director-gates/[gate-id].md` —— 被派生的代理读取自己的闸门文件；不要在父会话中读取它。


每次 `AskUserQuestion` 调用都遵循 `.trae/docs/automation-modes.md`
（协作模式始终询问 · 引导模式仅询问重大项 · 自主模式记录后继续；
`automation_always_ask` 类别始终提示）。

**`docs.density`** —— 它控制每个章节的*深度*，而 `workflow` 控制存在哪些章节。`modes.rigor` 同时设置两者；要单独改变深度，请显式设置 `docs.density`：`terse`（默认值，通过 `rigor: minimal` 设置）= 要点列表，每章 2–5 行，跳过理由说明和开头铺垫；`balanced` = 带轻度理由说明的段落（`rigor: standard`）；`thorough` = 完整行文，包含理由、示例和备选方案考量。对你撰写的每个章节都应用它。强制结构（Formulas 变量表、Given-When-Then 验收标准）在任何密度下都是正确性要求 —— `terse` 只裁剪周边行文，绝不裁剪必需的结构本身。

系统名称或改造路径是**必需的**。若缺失：

1. 检查 `design/gdd/systems-index.md` 是否存在。
2. 若存在：读取它，找到状态为 "Not Started" 或同等状态中优先级最高的系统，然后使用 `AskUserQuestion`：
   - 提示："你设计顺序中的下一个系统是 **[system-name]**（[priority] | [layer]）。开始设计它吗？"
   - 选项：`[A] Yes — design [system-name]` / `[B] Pick a different system` / `[C] Stop here`
   - 若选 [A]：使用该系统名称继续。若选 [B]：询问要设计哪个系统（纯文本）。若选 [C]：退出。
3. 若不存在系统索引，则报错退出：
   > "用法：`/design-system <system-name>` —— 例如 `/design-system movement`
   > 或为现有 GDD 补缺：`/design-system retrofit design/gdd/[system-name].md`
   > 未找到系统索引。请先运行 `/map-systems` 梳理你的系统并获取设计顺序。"

**检测改造模式（retrofit）：**
如果参数以 `retrofit` 开头，或者参数是 `design/gdd/` 中现有 `.md` 文件的路径，
则进入**改造模式**：

1. 读取现有 GDD 文件。按章节读取：用 Grep 工具找出标题（模式 `^#`，内容模式），
   再用 offset 和 limit 读取相应范围。
2. 识别 8 个**可能**章节中哪些已存在（扫描章节标题）：Overview、Player Fantasy、
   Detailed Design/Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、
   Acceptance Criteria。
   **其中哪些是*必需*的取决于生效层级**（§1）—— 在 `standard` 下只有 5 个，
   数学类别的还要加 Formulas，而 Player Fantasy 和 Tuning Knobs 是**按设计跳过**的。
   只有当层级要求时，才把缺失章节报告为缺口；否则将其列为可补充项。在这里把所有 8 个
   都当作必需项，会让每个 `standard` 项目都把两个按其设计本就缺失的章节报告为缺口。
3. 识别哪些章节只包含占位文本（`[To be designed]` 或同等内容 —— 空白、单行或明显不完整）。
4. 在做任何事之前先向用户呈现：
   ```
   ## Retrofit: [System Name]
   File: design/gdd/[filename].md

   Sections already written (will not be touched):
   ✓ [section name]
   ✓ [section name]

   Missing or incomplete sections (will be authored):
   ✗ [section name] — missing
   ✗ [section name] — placeholder only
   ```
5. 询问："要补齐这 [N] 个缺失章节吗？我不会修改任何现有内容。"
6. 若同意：照常进行到 **Phase 2（收集上下文）**，但在 **Phase 3** 中跳过创建
   骨架（文件已存在），在 **Phase 4** 中跳过已完成的章节。只对缺失/不完整的章节
   运行章节循环。
7. **绝不覆盖现有章节内容。** 使用 Edit 工具只替换 `[To be designed]` 占位符或空的
   章节正文。

若非改造模式，则将系统名称规范化为 kebab-case 作为文件名（例如 "combat system"
变为 `combat-system`）。

本系统的 **`workflow`**（依据 `.trae/docs/workflow-modes.md`）—— 如果该配置块中
列出了本系统的 `system_overrides` 行，则使用它，否则使用项目值。

解析出的层级决定哪些 GDD 章节是**必需的**（在 §4 中应用）。
**`## Summary` 在每个层级都是必需的，且不属于这 8 个章节** —— §5-pre 会无条件撰写它
（*"This runs at every tier"*）。下面的按层级列表不会重复它，而仅对照层级列表检查的
GDD 即使没有 Summary 也会通过 —— 而 `/review-all-gdds` 和分层加载读取方恰恰依赖
这一章节。请把下面的每个列表都读作 "`## Summary`，外加："。
- `full` —— 全部 8 个章节
- `standard` —— Overview、Detailed Design、Edge Cases、Dependencies、Acceptance
  Criteria（5 个必需）；**Formulas 为条件性** —— 当系统**定义了数值规则**时必需：
  速率、曲线、阈值、成本、伤害、掉落权重，或任何平衡性调整会调节的值。仅当系统
  不定义此类数值时才是可选。**`systems-index.md` 中的 `Category` 只是提示，不是判断
  依据** —— `Gameplay`、`Economy` 和 `Progression` 系统几乎总是符合条件，而定义了
  数值规则的 `Core`、`UI` 或 `Persistence` 系统同样符合。如果 Detailed Design 陈述了
  一个非引擎常量的数量，Formulas 就是必需的。**Player Fantasy 和 Tuning Knobs 跳过**，
  除非 `workflow_overrides` 强制要求（`tuning_knobs: true` 强制 Tuning Knobs）

  > **不要以类别标记作为判断依据。** 诸如 "类别是 combat / economy / progression / AI"
  > 这样的检查匹配的标记 `/map-systems` 并不会写入 —— `templates/systems-index.md`
  > 将类别定义为 `Core · Gameplay · Progression · Economy · Persistence · UI · Audio ·
  > Narrative · Meta`，并将 **combat 和 AI 列为 `Gameplay` 下的示例系统**。一个
  > 完全按模板指示分类的战斗系统，不会匹配这四个中的任何一个，于是 Formulas 会在
  > 最需要它的系统上被丢弃。
- `minimal` —— 不要求 GDD（游戏简报取代它）。若在 minimal 下自愿调用，则只撰写
  5 个标准章节（Overview、Detailed Design、Edge Cases、Dependencies、Acceptance
  Criteria）—— 条件性 Formulas 规则在 minimal 下**不会**重新适用 —— 并告知用户
  在此工作流层级下 GDD 是可选的。

改造模式不受影响 —— 无论层级如何，它都会补齐所有缺失章节。

---
