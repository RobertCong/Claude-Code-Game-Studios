# Agent Test Spec: unity-addressables-specialist

## Agent Summary
领域：Addressable Asset System — 分组、异步加载/卸载、句柄（handle）生命周期管理、内存预算、内容目录（content catalog）以及远程内容分发。
不负责：渲染系统（engine-programmer）、使用已加载资源的游戏逻辑（gameplay-programmer）。
未分配质量闸门（gate）ID。

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且与领域相关（提及 Addressables / 资源加载 / 内容目录 / 远程分发）
- [ ] `tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 `sonnet` — frontmatter `model:` 的内容恰好为 `sonnet`（层级说明：`.claude/docs/model-tiers.md`）
- [ ] 代理定义未声明对渲染系统或使用已加载资源的玩法代码的权限

---

## Test Cases

### Case 1: 领域内请求 — 输出得当
**Input:** "异步加载一个角色纹理，并在角色销毁时释放它。"
**Expected behavior:**
- 生成 `Addressables.LoadAssetAsync<Texture2D>()` 调用模式
- 将返回的 `AsyncOperationHandle<Texture2D>` 存储在发起请求的对象中
- 在角色销毁时（`OnDestroy()`）用存储的句柄调用 `Addressables.Release(handle)`
- 不使用 `Resources.Load()` 作为加载机制
- 在使用 `Result` 前检查加载是否成功（`handle.Status`），且绝不释放自己未持有的句柄（例如在加载启动前就被销毁的角色）
- 已加载资源使用 `Addressables.Release(handle)`，仅对 `InstantiateAsync` 的结果使用 `Addressables.ReleaseInstance()` — 不混用两者

### Case 2: 领域外重定向
**Input:** "实现把已加载纹理应用到角色网格上的渲染系统。"
**Expected behavior:**
- 不生成渲染或网格材质赋值代码
- 明确说明渲染系统实现属于 `engine-programmer`
- 将请求重定向到 `engine-programmer`
- 改为交接资源契约：加载成功后 `Texture2D` 来自句柄的 `Result`，并且仅在拥有它的句柄被释放前有效，因此消费方不得越过该时点继续持有它

### Case 3: 内存泄漏 — 未释放的句柄
**Input:** "每次关卡加载后内存占用都在持续上升。我们用 Addressables 加载关卡资源。"
**Expected behavior:**
- 诊断可能原因：`AsyncOperationHandle` 对象在使用后未被释放
- 指出句柄泄漏模式：把资源加载到局部变量、丢失引用、从不调用 `Addressables.Release()`
- 生成审计方法：每个 `LoadAssetAsync` 配对 `Release()`，每个 `InstantiateAsync` 配对 `ReleaseInstance()`，每个 `LoadSceneAsync` 配对 `UnloadSceneAsync()`
- 提供修正后的模式：每个活动句柄都保存在受跟踪的集合中，并在关卡卸载时释放，从而在关卡切换间不会累积
- 在得出结论前用 Addressables Event Viewer（逐资源引用计数）或 Memory Profiler 确认诊断 — 在没有证据的情况下不假设泄漏在别处

### Case 4: 远程内容分发 — 目录版本管理
**Input:** "我们需要支持可下载的内容更新，且不要求用户完整重装应用。"
**Expected behavior:**
- 生成 `docs/engine-reference/unity/plugins/addressables.md` 中记录的远程目录更新模式：
  - 启动时调用 `Addressables.CheckForCatalogUpdates()`
  - 对检测到的更新调用 `Addressables.UpdateCatalogs()`
  - 下载前调用 `Addressables.GetDownloadSizeAsync()`，然后用 `Addressables.DownloadDependenciesAsync()` 预下载更新内容
- 仅重新下载发生变化的 bundle；目录带版本号，因此客户端可回退到缓存内容，下载失败时以指数退避重试并显示进度
- 提出会话中场景（会话运行期间收到目录更新）并询问用户希望哪种行为，而不是悄悄选定一种
- 规划更新路径测试：全新安装、V1 到 V2，以及跳过 V2 的 V1 到 V3
- 不设计服务端 CDN 基础设施（交由 devops-engineer）

### Case 5: 上下文校验 — 平台内存约束
**Input:** 平台上下文：目标为 Nintendo Switch，4GB RAM，实际资源内存上限 512MB。请求："为一个大型开放世界关卡设计 Addressables 加载策略。"
**Expected behavior:**
- 引用所提供上下文中的 512MB 内存上限，并用它替代其自身默认的主机预算
- 设计流式加载策略：
  - 通过 `Addressables.LoadSceneAsync()` / `Addressables.UnloadSceneAsync()` 做叠加场景流式加载，并按加载上下文以区域为单位组织分组
  - 每个活动区域有内存预算，总和保持在 512MB 上限以内，切换时卸载区域而不是累积
  - 先加载区域必需内容，随后流式加载可选内容
- 将区域边界划到哪里交由 `level-designer` 决定
- 将目标硬件的存储 I/O 速度标记为需在设备上核实的加载时间风险，不凭记忆引用平台加载速度
- 不生成会超出所述 512MB 上限却未加标记的加载策略

---

## Protocol Compliance

- [ ] 保持在声明的领域内（Addressables 加载、句柄生命周期、内存、目录、远程分发）
- [ ] 将渲染与玩法资源使用代码重定向到 engine-programmer 与 gameplay-programmer
- [ ] 返回结构化输出（加载模式、句柄生命周期代码、流式区域设计）
- [ ] 始终将 `LoadAssetAsync` 与对应的 `Release()` 配对 — 将句柄泄漏标记为内存缺陷
- [ ] 依据所提供的内存上限设计加载策略，该上限优先于其默认的逐平台预算
- [ ] 仅规定客户端侧契约（远程加载路径 / URL 结构、目录版本管理、缓存响应头要求），并将 CDN 托管与分发流水线交由 devops-engineer
- [ ] 写入前询问 "May I write this to [filepath]?" 并指明文件名

---

## Coverage Notes
- 句柄生命周期（Case 1）必须包含验证释放后内存被回收的测试
- 句柄泄漏诊断（Case 3）应生成适合作为缺陷工单的发现报告
- 平台内存用例（Case 5）验证代理应用上下文中的硬约束，而非默认假设
