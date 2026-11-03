> 质量闸门定义。发起调用的技能会把本文件路径传给总监代理；由该 AGENT 读取——父会话不应读取。

# QL-TEST-COVERAGE — QA 主管测试覆盖率评审

Agent：`qa-lead` | 模型层级：session（继承）

**触发时机**：实现类用户故事完成之后——`/story-done` 会在将每个故事标记为
Complete 之前对其运行本闸门

**需传入的上下文**：
- 已实现用户故事清单及其故事类型（Logic / Integration / Visual / UI / Config）
- `tests/` 中的测试文件路径
- 该系统的 GDD 验收标准

**提示词**：
> "审查这些实现类用户故事的测试覆盖率。所有 Logic 故事是否都由通过的单元测试
> 覆盖？Integration 故事是否由集成测试或记录在案的试玩测试覆盖？GDD 验收标准是否
> 每条都至少映射到一个测试？GDD Edge Cases（边界情况）章节中是否存在未被测试的
> 边界情况？返回 ADEQUATE（覆盖率达到标准）、GAPS [具体缺失的测试]，或
> INADEQUATE [关键逻辑未测试——不得推进]。"

**结论**：ADEQUATE / GAPS / INADEQUATE
