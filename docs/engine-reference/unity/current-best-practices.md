# Unity 6.3 LTS — 当前最佳实践

**Last verified:** 2026-02-13

LLM 训练数据中可能未包含的现代 Unity 6 模式。这些是截至 Unity 6.3 LTS 的生产就绪建议。

---

## 项目设置

### 生产环境使用 Unity 6.3 LTS
- **受支持的 Update 版本**（6.4+）：最新功能，仅支持到下一个版本发布
- **LTS**（6.3）：生产就绪，两年支持期（至 2027 年 12 月）

### 选择合适的渲染管线
- **URP (Universal)**：移动端、跨平台、性能良好 ✅ 大多数游戏推荐
- **HDRP (High Definition)**：高端 PC/主机、照片级真实感
- **Built-in**：已弃用，新项目应避免

---

## 脚本

### 使用 C# 9+ 特性（Unity 6 支持 C# 9）

```csharp
// ✅ Record types for data
public record PlayerData(string Name, int Level, float Health);

// ✅ Init-only properties
public class Config {
    public string GameMode { get; init; }
}

// ✅ Pattern matching
var result = enemy switch {
    Boss boss => boss.Enrage(),
    Minion minion => minion.Flee(),
    _ => null
};
```

### 使用 Async/Await 进行资源加载

```csharp
// ✅ Modern async pattern
public async Task<GameObject> LoadEnemyAsync(string key) {
    var handle = Addressables.LoadAssetAsync<GameObject>(key);
    return await handle.Task;
}
```

### 使用源生成器进行序列化（Unity 6+）

```csharp
// ✅ Source-generated serialization (faster, less reflection)
[GenerateSerializer]
public partial struct PlayerStats : IComponentData {
    public int Health;
    public int Mana;
}
```

---

## DOTS/ECS（Unity 6.3 LTS 中已生产就绪）

### 使用 ISystem（而非 ComponentSystem）

```csharp
// ✅ Modern unmanaged ISystem (Burst-compatible)
public partial struct MovementSystem : ISystem {
    public void OnCreate(ref SystemState state) { }

    public void OnUpdate(ref SystemState state) {
        foreach (var (transform, speed) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<MoveSpeed>>()) {
            transform.ValueRW.Position += speed.ValueRO.Value * SystemAPI.Time.DeltaTime;
        }
    }
}
```

### 使用 IJobEntity 执行并行作业

```csharp
// ✅ IJobEntity (replaces IJobForEach)
[BurstCompile]
public partial struct DamageJob : IJobEntity {
    public float DeltaTime;

    void Execute(ref Health health, in DamageOverTime dot) {
        health.Value -= dot.DamagePerSecond * DeltaTime;
    }
}

// Schedule it
var job = new DamageJob { DeltaTime = SystemAPI.Time.DeltaTime };
job.ScheduleParallel();
```

---

## 输入

### 使用 Input System 包（而非旧版 Input）

```csharp
// ✅ Input Actions (rebindable, cross-platform)
using UnityEngine.InputSystem;

public class PlayerInput : MonoBehaviour {
    private PlayerControls controls;

    void Awake() {
        controls = new PlayerControls();
        controls.Gameplay.Jump.performed += ctx => Jump();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();
}
```

在编辑器中创建 Input Actions 资源，通过检视面板生成 C# 类。

---

## UI

### 运行时 UI 使用 UI Toolkit（Unity 6 中已生产就绪）

```csharp
// ✅ UI Toolkit (replaces UGUI for new projects)
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour {
    void OnEnable() {
        var root = GetComponent<UIDocument>().rootVisualElement;

        var playButton = root.Q<Button>("play-button");
        playButton.clicked += StartGame;

        var scoreLabel = root.Q<Label>("score");
        scoreLabel.text = $"High Score: {PlayerPrefs.GetInt("HighScore")}";
    }
}
```

**UXML**（UI 结构）+ **USS**（样式）= 类似 HTML/CSS 的工作流。

---

## 资源管理

### 使用 Addressables（而非 Resources）

```csharp
// ✅ Addressables (async, memory-efficient)
using UnityEngine.AddressableAssets;

public async Task SpawnEnemyAsync(string enemyKey) {
    var handle = Addressables.InstantiateAsync(enemyKey);
    var enemy = await handle.Task;

    // Cleanup: release when destroyed
    Addressables.ReleaseInstance(enemy);
}
```

**优势：** 异步加载、远程内容分发、更好的内存控制。

---

## 渲染

### 自定义通道使用 RenderGraph API（URP/HDRP）

```csharp
// ✅ RenderGraph API (Unity 6+)
public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
    using (var builder = renderGraph.AddRasterRenderPass<PassData>("My Pass", out var passData)) {
        // Setup pass
        builder.SetRenderFunc((PassData data, RasterGraphContext context) => {
            // Execute commands
        });
    }
}
```

**取代：** 旧的 `CommandBuffer.Execute()` 模式。

**这是 URP 的 API。** `RecordRenderGraph` 重写 URP 的 `ScriptableRenderPass`。
HDRP 自定义通道是另一套 API：`CustomPass` 的子类，由 Custom Pass Volume
运行，重写 `Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)`、
`Execute(CustomPassContext ctx)` 和 `Cleanup()`（HDRP 17.3，*Create a Custom
Pass in a C# script*：
https://docs.unity3d.com/Packages/com.unity.render-pipelines.high-definition@17.3/manual/Custom-Pass-Scripting.html）。

---

## 性能

### 使用 Burst Compiler + Jobs System

```csharp
// ✅ Burst-compiled job (massive performance gain)
[BurstCompile]
struct ParticleUpdateJob : IJobParallelFor {
    public NativeArray<float3> Positions;
    public NativeArray<float3> Velocities;
    public float DeltaTime;

    public void Execute(int index) {
        Positions[index] += Velocities[index] * DeltaTime;
    }
}

// Schedule
var job = new ParticleUpdateJob {
    Positions = positions,
    Velocities = velocities,
    DeltaTime = Time.deltaTime
};
job.Schedule(positions.Length, 64).Complete();
```

比等效的 C# 代码**快 20-100 倍**。

---

### 对重复对象使用 GPU Instancing

```csharp
// ✅ GPU Instancing (thousands of objects, minimal draw calls)
Graphics.RenderMeshInstanced(
    new RenderParams(material),
    mesh,
    0,
    matrices // NativeArray<Matrix4x4>
);
```

---

## 内存管理

### 使用 NativeContainers（作业中不要使用托管数组）

```csharp
// ✅ NativeArray (no GC, Burst-compatible)
NativeArray<int> data = new NativeArray<int>(1000, Allocator.TempJob);
// ... use in job
data.Dispose(); // Manual cleanup required

// ✅ Or use using statement
using var data = new NativeArray<int>(1000, Allocator.TempJob);
// Auto-disposed
```

---

## 多人游戏

### 使用 Netcode for GameObjects（官方）

```csharp
// ✅ Unity's official netcode
using Unity.Netcode;

public class Player : NetworkBehaviour {
    private NetworkVariable<int> health = new NetworkVariable<int>(100);

    [ServerRpc]
    public void TakeDamageServerRpc(int damage) {
        health.Value -= damage;
    }
}
```

**取代：** UNet（已弃用）、MLAPI（已更名为 Netcode for GameObjects）。

---

## 测试

### 使用 Unity Test Framework（基于 NUnit）

```csharp
// ✅ Play Mode Test
[UnityTest]
public IEnumerator Player_TakesDamage_HealthDecreases() {
    var player = new GameObject().AddComponent<Player>();
    player.Health = 100;

    player.TakeDamage(25);
    yield return null; // Wait one frame

    Assert.AreEqual(75, player.Health);
}
```

---

## 命令行 — 测试

有文档记载（Unity 手册 *Run tests from the command line*；Test Framework
命令行参考）：
`<Unity editor> -runTests -batchmode -projectPath <path> -testPlatform <platform> -testResults <file>`。
`-batchmode` 无需用户输入。`-testPlatform` 接受 `EditMode`、
`PlayMode`（编辑器中的 Play Mode 测试）或某个播放器平台；不指定值时，
测试在 Edit Mode 下运行。`-testResults` 默认输出到项目根目录，文件遵循
NUnit 的 XML 格式：`<test-run>` 元素携带
`testcasecount`、`result`、`passed` 和 `failed`，每个 `<test-case>` 携带
`fullname` 以及取值为 `Passed`、`Failed`、`Inconclusive` 或 `Skipped` 的 `result`。
Unity 未定义测试运行的通用退出码。

在 Unity 6000.3.23f1 上观察到的行为——文档中未记载：
- 全部测试通过时 `-runTests` 退出码为 0，有测试失败时为 2；1 表示
  编译错误（不会写入结果文件），3 表示运行失败，4 表示未知的
  `-testPlatform`。它会自行退出——无需 `-quit`。
- `Assets/` 之外的测试永远不会被编译：运行会报告
  `testcasecount="0"`、`result="Passed"` 并以 0 退出——这是假通过。
- 没有 `com.unity.test-framework` 包时，`-runTests` 会挂起，而不是
  失败。
- `PATH` 上的 `Unity` 可能是 Unity 独立的 CLI，而非编辑器；它会拒绝
  `-batchmode` 和 `-version` 并以 2 退出。请用完整路径指定编辑器可执行文件。
- `-batchmode -quit -projectPath . -logFile -` 在编译错误时退出码为 1，
  干净时退出码为 0。

来源：
- Run tests from the command line: https://docs.unity3d.com/6000.3/Documentation/Manual/test-framework/run-tests-from-command-line.html
- Test Framework command-line arguments: https://docs.unity3d.com/Packages/com.unity.test-framework@1.4/manual/reference-command-line.html
- NUnit test result XML format: https://docs.nunit.org/articles/nunit/technical-notes/usage/Test-Result-XML-Format.html

---

## 调试

### 使用日志记录最佳实践

```csharp
// ✅ Structured logging (Unity 6+)
using UnityEngine;

Debug.Log($"Player {playerName} scored {score} points");

// ✅ Conditional compilation for debug code
#if UNITY_EDITOR || DEVELOPMENT_BUILD
    Debug.DrawRay(transform.position, direction, Color.red);
#endif
```

---

## 总结：Unity 6 技术栈

| 功能 | 使用此方案（2026） | 避免此方案（旧版） |
|---------|------------------|----------------------|
| **Input** | Input System 包 | `Input` 类 |
| **UI** | UI Toolkit | UGUI (Canvas) |
| **ECS** | ISystem + IJobEntity | ComponentSystem |
| **Rendering** | URP + RenderGraph | Built-in 管线 |
| **Assets** | Addressables | Resources |
| **Jobs** | Burst + IJobParallelFor | 用于重负载的协程 |
| **Multiplayer** | Netcode for GameObjects | UNet |

---

**Sources:**
- https://docs.unity3d.com/6000.0/Documentation/Manual/BestPracticeGuides.html
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html
