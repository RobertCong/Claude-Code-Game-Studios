---
paths:
  - "src/core/**"
  - "Assets/**/{Core,core}/**/*.cs"
  - "Source/**/{Core,core}/**/*.{h,cpp}"
---

# 引擎代码规则

- 热路径（更新循环、渲染、物理）中零分配——预分配、对象池、复用
- 所有引擎 API 必须线程安全，或明确记录为仅单线程
- 每次优化前后都要做性能分析——记录实测数字
- 引擎代码绝不能依赖玩法代码（严格依赖方向：engine <- gameplay）
- 每个公共 API 的文档注释中都必须有用法示例
- 公共接口的变更需要弃用期和迁移指南
- 所有资源使用 RAII / 确定性清理
- 所有引擎系统必须支持优雅降级
- 在编写引擎 API 代码前，查阅 `docs/engine-reference/` 了解当前引擎版本，并对照参考文档验证 API

## 示例

**正确**（零分配热路径）——Godot：

```gdscript
# Pre-allocated array reused each frame
var _nearby_cache: Array[Node3D] = []

func _physics_process(delta: float) -> void:
    _nearby_cache.clear()  # Reuse, don't reallocate
    _spatial_grid.query_radius(position, radius, _nearby_cache)
```

Unity：

```csharp
private readonly Collider[] _nearbyCache = new Collider[64];  // allocated once

void FixedUpdate()
{
    int count = Physics.OverlapSphereNonAlloc(transform.position, radius, _nearbyCache);
}
```

Unreal：

```cpp
// TArray member, reserved once; Reset() keeps the allocation
void UProximityComponent::TickComponent(float DeltaTime, ELevelTick TickType,
                                        FActorComponentTickFunction* ThisTickFunction)
{
    NearbyCache.Reset();
    SpatialGrid->QueryRadius(GetComponentLocation(), Radius, NearbyCache);
}
```

**错误**（在热路径中分配）：

```gdscript
func _physics_process(delta: float) -> void:
    var nearby: Array[Node3D] = []  # VIOLATION: allocates every frame
    nearby = get_tree().get_nodes_in_group("enemies")  # VIOLATION: tree query every frame
```
