# /architecture-decision — 第 1 步：加载引擎上下文

> 属于 `/architecture-decision`。`SKILL.md` 指明了何时读取此文件；它所解析的
> 设置以及其后续标题下的规则在这里同样适用。

## 1. 加载引擎上下文（始终第一步）

在做任何其他事情之前，先建立引擎环境：

1. 读取 `docs/engine-reference/[engine]/VERSION.md` 以获取：
   - 引擎名称与版本
   - LLM 知识截止日期
   - 截止后版本风险等级（LOW / MEDIUM / HIGH）

2. 根据标题或用户描述，识别此架构决策的**领域**。常见领域：Physics、Rendering、UI、Audio、Navigation、
   Animation、Networking、Core、Input、Scripting。

3. 如果存在对应的模块参考，则读取它：
   `docs/engine-reference/[engine]/modules/[domain].md`

4. 读取 `docs/engine-reference/[engine]/breaking-changes.md` —— 标出相关领域中
   晚于 LLM 训练截止日期的任何变更。

5. 读取 `docs/engine-reference/[engine]/deprecated-apis.md` —— 标出相关领域中
   不应使用的任何 API。

6. 如果领域带有 MEDIUM 或 HIGH 风险，在继续之前**显示知识缺口警告**：

   ```
   ⚠️  ENGINE KNOWLEDGE GAP WARNING
   Engine: [name + version]
   Domain: [domain]
   Risk Level: HIGH — This version is post-LLM-cutoff.

   Key changes verified from engine-reference docs:
   - [Change 1 relevant to this domain]
   - [Change 2]

   This ADR will be cross-referenced against the engine reference library.
   Proceed with verified information only — do NOT rely solely on training data.
   ```

   如果尚未配置引擎，提示："No engine is configured.
   Run `/setup-engine` first, or tell me which engine you are using."

---
