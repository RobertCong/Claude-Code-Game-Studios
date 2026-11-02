# Agent Test Spec: tools-programmer

## Agent Summary
领域：编辑器扩展、内容制作工具、调试实用工具与流水线自动化脚本。
不负责：游戏运行时（runtime）代码（gameplay-programmer）、引擎核心系统（engine-programmer）、美术流水线需求（technical-artist）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域特定（提及编辑器工具 / 流水线 / 调试工具）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型档位为 `inherit` — frontmatter `model:` 的值恰为 `inherit`（档位说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声称对游戏源代码或引擎内部拥有权限

---

## Test Cases

### Case 1: 域内请求 — 合适的输出
**Input:** “创建一个自定义编辑器工具，用于在关卡中放置敌人巡逻路径点。”
**Expected behavior:**
- 为所配置引擎产出编辑器扩展规格与代码骨架（例如 Godot EditorPlugin、Unity 编辑器窗口、Unreal Detail Customization）
- 工具允许设计师在场景/视口中点击放置路径点
- 路径点序列化为引擎原生资源（而非硬编码），使 level-designer 无需代码即可编辑
- 按编辑器插件最佳实践包含撤销/重做支持
- 不修改 AI 寻路运行时代码（属于 ai-programmer）

### Case 2: 域外请求 — 正确重定向
**Input:** “用代码实现敌人的近战连招系统。”
**Expected behavior:**
- 不产出玩法机制代码
- 明确说明战斗系统实现属于 `gameplay-programmer`
- 将请求重定向给 `gameplay-programmer`
- 其提供的任何部分都是自身侧的工具——例如可视化连招状态的调试叠加层——绝不是连招逻辑

### Case 3: 运行时数据访问 — 需要协作
**Input:** “路径点编辑器必须在编辑时检查每段巡逻路径可行走，但回答此问题的碰撞查询位于游戏运行时（runtime）代码中，编辑器无法调用它们。”
**Expected behavior:**
- 识别该工具需要编辑器尚无法调用的运行时查询，且添加该查询属于对游戏运行时（runtime）代码的更改
- 不自行添加运行时钩子——将其委派给 `engine-programmer`（碰撞查询属于引擎级运行时代码），并在协调前询问（“This will require changes to [other system]. Should I coordinate with that first?”）
- 在实现工具前记录工具所需的只读接口（输入、输出、从编辑器上下文调用）
- 将失败区段报告为清晰、可操作的错误，而不是静默跳过

### Case 4: 引擎版本破坏
**Input:** “引擎升级后，路径点编辑器工具在启动时崩溃。”
**Expected behavior:**
- 在触碰编辑器插件 API 前检查引擎版本参考（`docs/engine-reference/`），包括对照升级后的编辑器核对 VERSION.md 中的锁定版本（`Installed at pin time` 为 NOT DETERMINED 表示未知缺口，而非匹配）
- 在参考资料的破坏性变更与已弃用 API 文件中查找失败 API，而不是从训练数据回忆；若其中未涵盖，则如实说明，而不是断言原因
- 为该破坏性变更产出有针对性的修复
- 在宣布工具已修复前，用代表性数据测试修复

### Case 5: 上下文传递 — 美术流水线需求
**Input:** 上下文中提供美术流水线需求：“所有纹理导入必须将压缩设为 VRAM Compressed、生成 mipmap，并标记 LOD 组。”请求：“构建一个强制执行这些设置的资源导入工具。”
**Expected behavior:**
- 引用上下文中的全部三项要求：VRAM 压缩、生成 mipmap、LOD 组标记
- 产出一个导入工具，在导入时验证并应用全部三项设置
- 对未满足指定设置的资源添加警告或错误报告
- 将三项设置视为既定：不自行更改或增加要求——其认为需要的任何变更都与 `technical-artist`（其美术流水线工具伙伴）提出

---

## Protocol Compliance

- [ ] 保持在声明的领域内（编辑器工具、流水线脚本、调试工具）
- [ ] 将游戏代码请求重定向给相应的程序员代理
- [ ] 返回结构化发现（工具规格、编辑器扩展代码、流水线脚本）
- [ ] 将工具依赖的任何运行时代码更改（例如查询 API）委派给 engine-programmer 或 gameplay-programmer，而不是自行实施
- [ ] 在使用编辑器插件 API 前检查引擎版本参考
- [ ] 构建工具来执行要求，不自行制定要求
- [ ] 写入前询问“May I write this to [filepath]?”并指明文件

---

## Coverage Notes
- 路径点编辑器工具（Case 1）应包含冒烟测试，验证其在编辑器中加载无错误
- 运行时数据访问（Case 3）确认代理尊重 engine-programmer 对核心 API 的所有权
- 美术流水线上下文（Case 5）验证代理按所提供规格构建，而不是自行发明要求
