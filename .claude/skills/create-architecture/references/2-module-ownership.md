# /create-architecture — Phase 2: 模块归属映射

> 属于 `/create-architecture`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## Phase 2: 模块归属映射

对 Phase 1 中定义的每个模块，定义归属：

- **Owns**：此模块独家负责哪些数据与状态
- **Exposes**：其他模块可以读取或调用什么
- **Consumes**：它从其他模块读取什么
- **Engine APIs used**：此模块直接调用哪些具体的引擎类/节点/信号
  （注明版本与风险等级）

按层格式化为表格，然后给出 ASCII 依赖图。

**引擎感知检查**：对列出的每个引擎 API，对照相关模块参考文档进行验证。
如果 API 属于截止后版本，则标出：

```
⚠️  [ClassName.method()] — Godot 4.7 (post-cutoff, HIGH risk)
    Verified against: docs/engine-reference/godot/modules/[domain].md
    Behaviour confirmed: [yes / NEEDS VERIFICATION]
```

取得用户对归属映射的批准，然后记录到
`production/session-state/active.md`；它在 Phase 7 写入。

---
