# Unity 6.3 — DOTS / Entities (ECS)

**Last verified:** 2026-02-13
**Status:** 生产就绪（Entities 1.3+，Unity 6.3 LTS）
**Package:** `com.unity.entities`（Package Manager）

---

## 概述

**DOTS (Data-Oriented Technology Stack)** 是 Unity 的高性能 ECS（Entity Component System）框架。它专为大规模游戏（1000s-10,000s 个实体）设计。

**使用 DOTS 的场景：**
- RTS 游戏（数千个单位）
- 模拟（人群、交通、物理）
- 程序化内容生成
- 性能关键型系统

**不要使用 DOTS 的场景：**
- 小型游戏（开销不值得）
- 需要频繁结构变更的玩法
- 大量使用 UnityEngine API（MonoBehaviour 更简单）

**⚠️ Knowledge Gap:** Entities 1.0+（Unity 6）相较 0.x 是一次完全重写。许多针对 Entities 0.x 的教程现已过时。

---

## 安装

### 通过 Package Manager 安装

1. `Window > Package Manager`
2. Unity Registry > 搜索 "Entities"
3. 安装：
   - `Entities`（ECS 核心）
   - `Burst`（LLVM 编译器）
   - `Jobs`（自动安装）
   - `Mathematics`（SIMD 数学）

---

## 核心概念

### 1. **Entity（实体）**
- 轻量级 ID（int）
- 没有行为，只是一个标识符

### 2. **Component（组件）**
- 仅数据（无方法）
- 实现 `IComponentData` 的 struct

### 3. **System（系统）**
- 对组件进行操作的逻辑
- 实现 `ISystem` 的 struct

### 4. **Archetype（原型）**
- 组件类型的唯一组合
- 具有相同组件的实体共享原型

---

## 基本 ECS 模式

### 定义组件

```csharp
using Unity.Entities;
using Unity.Mathematics;

// ✅ Component: Data only, no methods
public struct Position : IComponentData {
    public float3 Value;
}

public struct Velocity : IComponentData {
    public float3 Value;
}
```

---

### 定义系统

```csharp
using Unity.Entities;
using Unity.Burst;

// ✅ System: Logic that processes entities
[BurstCompile]
public partial struct MovementSystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        float deltaTime = SystemAPI.Time.DeltaTime;

        // Query all entities with Position + Velocity
        foreach (var (transform, velocity) in
            SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

            transform.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
        }
    }
}
```

---

### 创建实体

```csharp
using Unity.Entities;
using Unity.Mathematics;

public partial class EntitySpawner : SystemBase {
    protected override void OnUpdate() {
        var em = EntityManager;

        // Create entity
        Entity entity = em.CreateEntity();

        // Add components
        em.AddComponentData(entity, new Position { Value = float3.zero });
        em.AddComponentData(entity, new Velocity { Value = new float3(1, 0, 0) });
    }
}
```

---

## 混合 ECS（MonoBehaviour + ECS）

### Baker（将 GameObject 转换为 Entity）

```csharp
using Unity.Entities;
using UnityEngine;

public class PlayerAuthoring : MonoBehaviour {
    public float speed;
}

public class PlayerBaker : Baker<PlayerAuthoring> {
    public override void Bake(PlayerAuthoring authoring) {
        var entity = GetEntity(TransformUsageFlags.Dynamic);

        AddComponent(entity, new Position { Value = authoring.transform.position });
        AddComponent(entity, new Velocity { Value = new float3(authoring.speed, 0, 0) });
    }
}
```

**工作原理：**
1. 在编辑器中将 `PlayerAuthoring` 添加到 GameObject
2. Baker 在运行时自动转换为 Entity
3. Entity 拥有 Position + Velocity 组件

---

## 查询

### 查询所有带指定组件的实体

```csharp
foreach (var (position, velocity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>()) {

    position.ValueRW.Value += velocity.ValueRO.Value * deltaTime;
}
```

---

### 带 Entity 的查询

```csharp
foreach (var (position, velocity, entity) in
    SystemAPI.Query<RefRW<Position>, RefRO<Velocity>>().WithEntityAccess()) {

    // Access entity ID
    Debug.Log($"Entity: {entity}");
}
```

---

### 带过滤器的查询

```csharp
// Only entities with "Enemy" tag
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // Process enemies only
}
```

---

## Jobs（并行执行）

### IJobEntity（并行 Foreach）

```csharp
using Unity.Entities;
using Unity.Burst;

[BurstCompile]
public partial struct MovementJob : IJobEntity {
    public float DeltaTime;

    // Execute runs in parallel for each entity
    void Execute(ref Position position, in Velocity velocity) {
        position.Value += velocity.Value * DeltaTime;
    }
}

[BurstCompile]
public partial struct MovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var job = new MovementJob {
            DeltaTime = SystemAPI.Time.DeltaTime
        };
        job.ScheduleParallel(); // Parallel execution
    }
}
```

---

## Burst Compiler（性能）

### 启用 Burst

```csharp
using Unity.Burst;

[BurstCompile] // 10-100x faster than regular C#
public partial struct MySystem : ISystem {
    [BurstCompile]
    public void OnUpdate(ref SystemState state) {
        // Burst-compiled code
    }
}
```

**Burst 限制：**
- 不允许托管引用（类、字符串等）
- 仅限 blittable 类型（struct、基元类型、Unity.Mathematics 类型）
- 不允许异常

---

## Entity Command Buffer（结构变更）

### 延迟结构变更

```csharp
using Unity.Entities;

public partial struct SpawnSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        var ecb = new EntityCommandBuffer(Allocator.Temp);

        // Defer entity creation (don't modify during iteration)
        foreach (var spawner in SystemAPI.Query<Spawner>()) {
            Entity newEntity = ecb.CreateEntity();
            ecb.AddComponent(newEntity, new Position { Value = spawner.SpawnPos });
        }

        ecb.Playback(state.EntityManager); // Apply changes
        ecb.Dispose();
    }
}
```

---

## 动态缓冲区（类数组组件）

### 定义动态缓冲区

```csharp
public struct PathWaypoint : IBufferElementData {
    public float3 Position;
}
```

### 使用动态缓冲区

```csharp
// Add buffer to entity
var buffer = EntityManager.AddBuffer<PathWaypoint>(entity);
buffer.Add(new PathWaypoint { Position = new float3(0, 0, 0) });
buffer.Add(new PathWaypoint { Position = new float3(10, 0, 0) });

// Query buffer
foreach (var buffer in SystemAPI.Query<DynamicBuffer<PathWaypoint>>()) {
    foreach (var waypoint in buffer) {
        Debug.Log(waypoint.Position);
    }
}
```

---

## 标签（零大小组件）

### 定义标签

```csharp
public struct EnemyTag : IComponentData { } // Empty component = tag
```

### 使用标签进行过滤

```csharp
// Only process entities with EnemyTag
foreach (var position in
    SystemAPI.Query<RefRW<Position>>().WithAll<EnemyTag>()) {
    // Enemy-specific logic
}
```

---

## 系统排序

### 显式排序

```csharp
[UpdateBefore(typeof(PhysicsSystem))]
public partial struct InputSystem : ISystem { }

[UpdateAfter(typeof(PhysicsSystem))]
public partial struct RenderSystem : ISystem { }
```

---

## 性能模式

### Chunk 迭代（最高性能）

```csharp
public void OnUpdate(ref SystemState state) {
    var query = SystemAPI.QueryBuilder().WithAll<Position, Velocity>().Build();

    var chunks = query.ToArchetypeChunkArray(Allocator.Temp);
    var positionType = state.GetComponentTypeHandle<Position>();
    var velocityType = state.GetComponentTypeHandle<Velocity>(true); // Read-only

    foreach (var chunk in chunks) {
        var positions = chunk.GetNativeArray(ref positionType);
        var velocities = chunk.GetNativeArray(ref velocityType);

        for (int i = 0; i < chunk.Count; i++) {
            positions[i] = new Position {
                Value = positions[i].Value + velocities[i].Value * deltaTime
            };
        }
    }

    chunks.Dispose();
}
```

---

## 从 MonoBehaviour 迁移

```csharp
// ❌ OLD: MonoBehaviour (OOP)
public class Enemy : MonoBehaviour {
    public float speed;
    void Update() {
        transform.position += Vector3.forward * speed * Time.deltaTime;
    }
}

// ✅ NEW: DOTS (ECS)
public struct EnemyData : IComponentData {
    public float Speed;
}

[BurstCompile]
public partial struct EnemyMovementSystem : ISystem {
    public void OnUpdate(ref SystemState state) {
        float dt = SystemAPI.Time.DeltaTime;
        foreach (var (transform, enemy) in
            SystemAPI.Query<RefRW<LocalTransform>, RefRO<EnemyData>>()) {
            transform.ValueRW.Position += new float3(0, 0, enemy.ValueRO.Speed * dt);
        }
    }
}
```

---

## 调试

### Entities Hierarchy 窗口

`Window > Entities > Hierarchy`

- 显示所有实体及其组件
- 按原型、组件类型过滤

### Entities Profiler

`Window > Analysis > Profiler > Entities`

- 系统执行时间
- 每个原型的内存占用

---

## 来源
- https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html
- https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html
- https://learn.unity.com/tutorial/entity-component-system
