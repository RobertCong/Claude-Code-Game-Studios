---
alwaysApply: false
globs: assets/data/**/*.json,Assets/**/Data/**/*.json,Assets/**/data/**/*.json,Content/**/Data/**/*.json,Content/**/data/**/*.json
---

# 数据文件规则

- 所有 JSON 文件必须是合法 JSON —— 损坏的 JSON 会阻塞整条构建流水线
- 文件命名：仅使用小写字母和下划线，遵循 `[system]_[name].json` 模式
- 每个数据文件都必须有文档化的 schema（JSON Schema，或记录在对应的设计文档中）
- 数值必须附带注释或配套文档，说明这些数字的含义
- 使用一致的键命名：**JSON 文件内的键使用 `snake_case`**，与上一行的 `[system]_[name].json` 文件约定以及本仓库其他标准所用的引擎惯例保持一致。

  > **在 Unity 和 Unreal 上，这会带来一层映射成本——请为此预留预算，而不是改键名。** `JsonUtility` 按*精确字段名*绑定，而 C# 字段按 `naming.variables` 是 `camelCase`，因此 snake_case 文件无法直接绑定到消费它的类型。请使用一个私有嵌套 DTO，其字段即传输格式，并一次性映射到你的真实类型；或者引入支持命名策略的依赖（Newtonsoft 的 `SnakeCaseNamingStrategy`、`System.Text.Json` 的 `JsonNamingPolicy`）。**不要**为了避免 DTO 而把文件改成 camelCase：键是跨引擎契约。写好 DTO，并把它记录为传输格式边界——这才是预期的形态。
- 不允许孤立的数据条目——每个条目都必须被代码或另一个数据文件引用
- 进行破坏性 schema 变更时，对数据文件做版本管理
- 为所有可选字段提供合理的默认值

## 示例

**正确**的命名与结构（`combat_enemies.json`）：

```json
{
  "goblin": {
    "base_health": 50,
    "base_damage": 8,
    "move_speed": 3.5,
    "loot_table": "loot_goblin_common"
  },
  "goblin_chief": {
    "base_health": 150,
    "base_damage": 20,
    "move_speed": 2.8,
    "loot_table": "loot_goblin_rare"
  }
}
```

**错误**（`EnemyData.json`）：

```json
{
  "Goblin": { "hp": 50 }
}
```

违规项：文件名大写、键名大写、缺少 `[system]_[name]` 模式、缺少必需字段。
