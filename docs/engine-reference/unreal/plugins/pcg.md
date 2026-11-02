# Unreal Engine 5.8 — PCG（程序化内容生成）

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Status:** Production-Ready（自 UE 5.7 起）
**Plugin:** `PCG`（内置，在 Plugins 中启用）

> **UE 5.8 变更：** 对 PCG 数据的非破坏性手动编辑（选择、
> 排除、修改、恢复；Data Overrides 窗口），复杂元数据
> 属性（数组、结构体、集合、映射），存储在图内部的
> 内嵌子图，图参数层级编辑器，以及 GPU 运行时散布（"within
> the same performance range as the landscape GPU grass system"）。新增节点
> 包括元数据数组操作、Align Points、Apply Spline to Component
> 与 Teleport Actors and Components。`UPCGComponent` 通过
> 执行源接口暴露 `SourceDataContainer`。来源：UE 5.8
> 发布说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

**Procedural Content Generation（PCG）** 是 Unreal 基于节点的框架，用于大规模
生成程序化内容。它专为在大型开放世界中填充
植被、岩石、道具、建筑及其他环境细节而设计。

**使用 PCG 的场景：**
- 程序化植被布置（树木、草、岩石）
- 基于生物群系的环境生成
- 道路/路径生成
- 建筑/结构布置
- 世界细节填充（道具、杂物）

**不要使用 PCG 的场景：**
- 玩法逻辑（请使用 Blueprints/C++）
- 一次性的手动摆放（请使用编辑器工具）

**⚠️ 注意：** PCG 在 UE 5.0-5.6 中为实验性，在 UE 5.7 中变为可用于生产。

---

## 核心概念

### 1. **PCG Graph**
- 基于节点的图（类似 Material Editor）
- 定义生成规则

### 2. **PCG Component**
- 放置在关卡中，执行 PCG Graph
- 在定义的体积内生成内容

### 3. **PCG Data**
- 点数据（位置、旋转、缩放）
- 样条数据（路径、道路、河流）
- 体积数据（密度、生物群系遮罩）

### 4. **Nodes**
- **Samplers**：生成点（Grid、Poisson、Surface）
- **Filters**：按规则移除点（Density、Tag、Bounds）
- **Modifiers**：变换点（Offset、Rotate、Scale）
- **Spawners**：在点上实例化网格/actor

---

## 设置

### 1. 启用插件

`Edit > Plugins > PCG > Enabled > Restart`

### 2. 创建 PCG Volume

1. Place Actors > Volumes > PCG Volume
2. 将体积缩放至所需的生成区域

### 3. 创建 PCG Graph

1. Content Browser > PCG > PCG Graph
2. 打开 PCG Graph Editor

---

## 基本工作流

### 示例：森林生成

#### 1. 创建 PCG Graph

**节点设置：**
```
Input (Volume)
  ↓
Surface Sampler (sample volume surface, points per m²: 0.5)
  ↓
Density Filter (use texture mask or noise)
  ↓
Static Mesh Spawner (tree meshes)
  ↓
Output
```

#### 2. 将 Graph 指定给 Volume

1. 选中 PCG Volume
2. Details Panel > PCG Component > Graph = 你的 PCG Graph
3. 点击 "Generate" 按钮

---

## 关键节点类型

### Sampler（点生成）

#### Grid Sampler
- 规则的点网格
- 配置：
  - **Grid Size**：点之间的距离
  - **Offset**：每个点的随机偏移

#### Poisson Disk Sampler
- 具有最小距离的随机点
- 配置：
  - **Points Per m²**：密度
  - **Min Distance**：点之间的间距

#### Surface Sampler
- 网格表面或景观上的点
- 配置：
  - **Points Per m²**：密度
  - **Surface Only**：仅表面，不含体积

---

### Filter（点移除）

#### Density Filter
- 根据密度值移除点
- 输入：纹理或噪声
- 用于：生物群系遮罩、空地、路径

#### Tag Filter
- 按标签过滤点
- 用于：条件生成

#### Bounds Filter
- 仅保留边界内的点
- 用于：将生成限制在特定区域

---

### Modifier（点变换）

#### Rotate
- 随机化点的旋转
- 配置：
  - **Min/Max Rotation**：各轴的旋转范围

#### Scale
- 随机化点的缩放
- 配置：
  - **Min/Max Scale**：缩放范围

#### Project to Ground
- 将点吸附到景观表面

---

### Spawner（网格/Actor 实例化）

#### Static Mesh Spawner
- 在点上生成静态网格
- 配置：
  - **Mesh List**：网格数组（随机选择）
  - **Culling Distance**：LOD/剔除设置

#### Actor Spawner
- 在点上生成蓝图 actor
- 用于：玩法 actor、可交互物体

---

## 数据源

### Landscape
- 使用景观作为采样输入
- 自动投影到景观高度

### Splines
- 沿样条生成内容（道路、河流、路径）
- 示例：沿路径生成树木

### Textures
- 使用纹理作为密度遮罩
- 绘制生物群系、空地、区域

---

## 生物群系示例（混合森林）

### Graph 设置

```
Input (Landscape)
  ↓
Surface Sampler (density: 1.0)
  ↓
┌─────────────────┬─────────────────┐
│ Tree Biome      │ Rock Biome      │
│ (density > 0.5) │ (density < 0.5) │
├─────────────────┼─────────────────┤
│ Tree Spawner    │ Rock Spawner    │
└─────────────────┴─────────────────┘
  ↓
Merge
  ↓
Output
```

---

## 基于样条的生成（带树木的道路）

### 1. 创建 PCG Graph

```
Spline Input
  ↓
Spline Sampler (sample along spline)
  ↓
Offset (offset from spline path)
  ↓
Tree Spawner
  ↓
Output
```

### 2. 为 PCG Volume 添加 Spline Component

1. PCG Volume > Add Component > Spline
2. 绘制样条路径
3. PCG Graph 读取样条数据

---

## 运行时生成

### 从 C++ 触发生成

```cpp
#include "PCGComponent.h"

UPCGComponent* PCGComp = /* Get PCG Component */;
PCGComp->Generate(); // Execute PCG graph
```

### 流式生成（大型世界）

- PCG 会自动随 World Partition 流式加载
- 仅在已加载的单元格中生成内容

---

## 性能

### 优化技巧

- 对生成的网格使用 **剔除距离（culling distance）**（LOD）
- 限制 **密度**（点越少性能越好）
- 对重复网格使用 **Hierarchical Instanced Static Meshes (HISM)**
- 为大型世界启用 **流式加载（streaming）**

### 调试性能

```cpp
// Console commands:
// pcg.graph.debug 1 - Show PCG debug info
// stat pcg - Show PCG performance stats
```

---

## 常见模式

### 带空地的森林

```
Surface Sampler
  ↓
Density Filter (noise texture with clearings)
  ↓
Tree Spawner (pine, oak, birch)
```

---

### 陡坡上的岩石

```
Landscape Input
  ↓
Surface Sampler
  ↓
Slope Filter (angle > 30°)
  ↓
Rock Spawner
```

---

### 道路旁的道具

```
Spline Input (road spline)
  ↓
Spline Sampler
  ↓
Offset (side of road)
  ↓
Street Light Spawner
```

---

## 调试

### PCG 调试可视化

```cpp
// Console commands:
// pcg.debug.display 1 - Show points and generation bounds
// pcg.debug.colormode points - Color-code points
```

### Graph 调试

- PCG Graph Editor > Debug > Show Debug Points
- 可视化图中每个节点的点

---

## 从 UE 5.6（实验性）迁移到 5.7（生产）

### API 变更

```cpp
// ❌ OLD (5.6 experimental API):
// Some nodes renamed, API unstable

// ✅ NEW (5.7 production API):
// Stable node types, documented API
```

**迁移：** 使用稳定的 5.7 节点重建 PCG 图。请充分测试。

---

## 限制

- **不用于玩法逻辑**：游戏规则请使用 Blueprints/C++
- **大型图可能较慢**：通过过滤器和降低密度来优化
- **运行时生成开销**：尽可能预生成

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/procedural-content-generation-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/pcg-quick-start-in-unreal-engine/
- UE 5.7 发布说明（PCG Production-Ready 公告）
