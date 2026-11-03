# /setup-engine — 第 7 节：填充引擎参考资料

> 属于 `/setup-engine` 的一部分。`SKILL.md` 指明何时读取本文件；它解析出的
> 设置及其后续标题下的规则在此仍然适用。

## 7. 填充引擎参考资料

**本文件内容：**

- 首先：此引擎是否已有参考资料集？
- 本节所有内容的取材来源规则
- 如果在训练数据之内（LOW RISK）：
- 如果超出训练数据（MEDIUM 或 HIGH RISK）：

### 首先：此引擎是否已有参考资料集？

**在做任何其他事情之前先检查。** 模板自带
**已填充**的 `docs/engine-reference/godot/`、`unity/` 和 `unreal/`，因此
"目录存在并固定了版本"是*每个*新项目的状态，
而不是边缘情况。下面的两个分支都写着"创建"，若在已预填充的目录上
照字面执行其中任何一个，要么覆盖精心整理的内容，要么
让 `project.yaml` 与 AGENTS.md 导入的参考资料互不一致。

读取 `docs/engine-reference/<engine>/VERSION.md`，将其
**Engine Version** 与第 3 节选定的版本比较：

- **无目录，或无 `VERSION.md`** → 创建，使用下面的风险分支。
- **版本相同** → 无需重新生成。仅当你确实在本次运行中对照文档重新验证过时，
  才刷新 `Last Docs Verified`。不要重新盖上你未核实的日期。
  仍要写入的一行是 `Installed at pin time`，来自
  第 3 节 — 无论结果如何都要记录其探测结果，先询问
  "我可以在 `docs/engine-reference/<engine>/VERSION.md` 中记录
  `Installed at pin time: [result]` 吗？"（这是受跟踪的文件）。
- **目录固定的版本比所选版本更旧** → **更新，而不是替换。**
  这是常见情况。展示下面的更改，然后询问"我可以更新
  `docs/engine-reference/<engine>/` 中针对 [version] 的文件吗？"再编辑。
  1. 就地编辑 `VERSION.md`：新的 **Engine Version**、新的 **Project Pinned**
     和 **Last Docs Verified**、第 3 节的 `Installed at pin time` 行，
     以及为每个新增版本在截止后时间线中新增一行。
  2. 在 `breaking-changes.md`、`deprecated-apis.md` 和
     `current-best-practices.md` 中**追加**内容，标题指明版本跨度
     （`## 4.6 → 4.7`）。绝不要截断更早的跨度 — 跨两个版本
     迁移的项目仍然需要更早的那个。
  3. 如果截止时间已越过更早的时间线行，重新评级这些行。
- **目录固定的版本比所选版本更新** → 停止并询问。要么是有人
  有意向前固定，要么是版本选择有误。不要静默降级
  精心整理的参考资料。

### 本节所有内容的取材来源规则

**绝不要用训练数据填补空白。把空白写下来。**

这些文件的全部意义在于成为 agent *替代*其训练数据
查阅的东西。这里一条自信的错误条目比没有条目更糟：它
会产生看起来已验证、实际并未验证的工作。

- 每一项声明都必须来自你在本次运行中抓取的页面。记录 URL。
- 如果官方文档没有说明模板要求的内容 — 发布日期、
  子系统行为、Web 导出细节 — 写入
  **`NOT SOURCEABLE — <what>, not stated at <url>`** 并继续。
- `NOT SOURCEABLE` 行是成功的结果，不是未能完成。
- 不要从一个相邻事实推断另一个事实。"迁移指南未列出物理变更"
  不等于"物理默认值未变"；如果你记录了推断，将其标注为推断，
  并说明它依据什么。

### 如果在训练数据之内（LOW RISK）：

询问："我可以创建 `docs/engine-reference/<engine>/VERSION.md` 吗？"等待
确认，然后创建这个最小文件：

```markdown
# [Engine] — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | [version] |
| **Project Pinned** | [today's date] |
| **Installed at pin time** | [Section 3 result — the installed version, or NOT DETERMINED] |
| **LLM Knowledge Cutoff** | [the cutoff from the Section 6 coverage table] |
| **Risk Level** | LOW — version is within LLM training data |

## Note

This engine version is within the LLM's training data. Engine reference
docs are optional but can be added later if agents suggest incorrect APIs.

Run `/setup-engine refresh` to populate full reference docs at any time.
```

不要创建 breaking-changes.md、deprecated-apis.md 等 — 它们会增加
上下文成本，却价值有限。

### 如果超出训练数据（MEDIUM 或 HIGH RISK）：

通过网络搜索创建完整的参考资料集：

1. **搜索官方迁移/升级指南**：
   - `"[engine] [old version] to [new version] migration guide"`
   - `"[engine] [version] breaking changes"`
   - `"[engine] [version] changelog"`
   - `"[engine] [version] deprecated API"`

2. **从官方文档中抓取并提取**：
   - 从训练截止时间到当前版本之间每个版本的破坏性变更
   - 弃用的 API 及其替代方案
   - 新功能与最佳实践

询问："我可以创建 `docs/engine-reference/<engine>/` 下的引擎参考资料吗？"

在写入任何文件之前等待确认。

3. **创建完整的参考资料目录**：
   ```
   docs/engine-reference/<engine>/
   ├── VERSION.md              # Version pin + knowledge gap analysis
   ├── breaking-changes.md     # Version-by-version breaking changes
   ├── deprecated-apis.md      # "Don't use X → Use Y" tables
   ├── current-best-practices.md  # New practices since training cutoff
   └── modules/                # Per-subsystem references (create as needed)
   ```

4. **使用网络搜索中的真实数据填充每个文件**，遵循
   现有参考资料中确立的格式。每个文件都必须有
   "Last verified: [date]" 头部。

5. **对于模块文件**：只为发生了重大变更的子系统创建模块。不要创建空白或最简的模块文件。

---
