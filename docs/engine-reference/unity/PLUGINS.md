# Unity 6.3 LTS — 可选包与系统

**Last Verified:** 2026-02-13

本文档索引 Unity 6.3 LTS 中可用的**可选包与系统**。
它们并非核心引擎的一部分，但在特定类型游戏中经常被使用。

---

## 如何使用本指南

**✅ 有详细文档**——参见 `plugins/` 目录获取完整指南
**🟡 仅简要概览**——链接到官方文档，详情请使用 WebSearch
**⚠️ 预览版**——未来版本中可能出现破坏性变更
**📦 需要安装包**——通过 Package Manager 安装

---

## 可用于生产的包（有详细文档）

### ✅ Cinemachine
- **用途：** 虚拟相机系统（动态相机、过场动画、相机混合）
- **使用场景：** 第三人称游戏、电影化内容、复杂相机行为
- **知识缺口：** Cinemachine 3.0+（Unity 6）相较 2.x 有重大 API 变更
- **Status:** 可用于生产
- **包：** `com.unity.cinemachine`（Package Manager）
- **详细文档：** [plugins/cinemachine.md](plugins/cinemachine.md)
- **官方：** https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html

---

### ✅ Addressables
- **用途：** 高级资源管理（异步加载、远程内容、内存控制）
- **使用场景：** 大型项目、DLC、远程内容分发
- **知识缺口：** Unity 6 改进，性能更好
- **Status:** 可用于生产
- **包：** `com.unity.addressables`（Package Manager）
- **详细文档：** [plugins/addressables.md](plugins/addressables.md)
- **官方：** https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html

---

### ✅ DOTS / Entities (ECS)
- **用途：** 面向数据的技术栈（面向大规模场景的高性能 ECS）
- **使用场景：** 拥有数千实体的游戏、RTS、模拟类
- **知识缺口：** Entities 1.3+（Unity 6）可用于生产，相较 0.x 大规模重写
- **Status:** 可用于生产（自 Unity 6.3 LTS 起）
- **包：** `com.unity.entities`（Package Manager）
- **详细文档：** [plugins/dots-entities.md](plugins/dots-entities.md)
- **官方：** https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html

---

## 其他可用于生产的包（简要概览）

### 🟡 Input System（已覆盖）
- **用途：** 现代输入处理（可重绑定、跨平台）
- **Status:** 可用于生产（Unity 6 中为默认）
- **包：** `com.unity.inputsystem`
- **文档：** 参见 [modules/input.md](modules/input.md)
- **官方：** https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html

---

### 🟡 UI Toolkit（已覆盖）
- **用途：** 现代运行时 UI（类似 HTML/CSS，性能良好）
- **Status:** 可用于生产（Unity 6）
- **包：** 内置
- **文档：** 参见 [modules/ui.md](modules/ui.md)
- **官方：** https://docs.unity3d.com/Packages/com.unity.ui@2.0/manual/index.html

---

### 🟡 Visual Effect Graph (VFX Graph)
- **用途：** GPU 加速粒子系统（数百万粒子）
- **使用场景：** 大规模 VFX、火焰、烟雾、魔法、爆炸
- **Status:** 可用于生产
- **包：** `com.unity.visualeffectgraph`（仅 URP/HDRP）
- **官方：** https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/index.html

---

### 🟡 Shader Graph
- **用途：** 可视化着色器编辑器（基于节点创建着色器）
- **使用场景：** 无需编写 HLSL 的自定义着色器
- **Status:** 可用于生产
- **包：** `com.unity.shadergraph`（URP/HDRP）
- **官方：** https://docs.unity3d.com/Packages/com.unity.shadergraph@17.0/manual/index.html

---

### 🟡 Timeline
- **用途：** 电影化序列编排（过场动画、脚本化事件）
- **使用场景：** 剧情驱动游戏、电影化内容、脚本化序列
- **Status:** 可用于生产
- **包：** `com.unity.timeline`（内置）
- **官方：** https://docs.unity3d.com/Packages/com.unity.timeline@1.8/manual/index.html

---

### 🟡 Animation Rigging
- **用途：** 运行时 IK、程序化动画
- **使用场景：** 足部 IK、瞄准偏移、程序化肢体摆放
- **Status:** 可用于生产（Unity 6）
- **包：** `com.unity.animation.rigging`
- **官方：** https://docs.unity3d.com/Packages/com.unity.animation.rigging@1.3/manual/index.html

---

### 🟡 ProBuilder
- **用途：** 编辑器内 3D 建模（关卡原型、灰盒搭建）
- **使用场景：** 快速原型、关卡块面搭建
- **Status:** 可用于生产
- **包：** `com.unity.probuilder`
- **官方：** https://docs.unity3d.com/Packages/com.unity.probuilder@6.0/manual/index.html

---

### 🟡 Netcode for GameObjects
- **用途：** Unity 官方多人网络
- **使用场景：** 多人游戏（客户端-服务器架构）
- **Status:** 可用于生产
- **包：** `com.unity.netcode.gameobjects`
- **官方：** https://docs-multiplayer.unity3d.com/netcode/current/about/

---

### 🟡 Burst Compiler
- **用途：** 面向 C# Jobs 的基于 LLVM 的编译器（大幅提升性能）
- **使用场景：** 性能关键代码、DOTS、Jobs System
- **Status:** 可用于生产
- **包：** `com.unity.burst`（随 DOTS 自动安装）
- **官方：** https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html

---

### 🟡 Jobs System
- **用途：** 多线程作业调度（CPU 并行）
- **使用场景：** 性能优化、并行处理
- **Status:** 可用于生产
- **包：** 内置
- **官方：** https://docs.unity3d.com/Manual/JobSystem.html

---

### 🟡 Mathematics
- **用途：** SIMD 数学库（针对 Burst 优化）
- **使用场景：** DOTS、高性能数学运算
- **Status:** 可用于生产
- **包：** `com.unity.mathematics`
- **官方：** https://docs.unity3d.com/Packages/com.unity.mathematics@1.3/manual/index.html

---

### 🟡 ML-Agents (Machine Learning)
- **用途：** 通过强化学习训练 AI
- **使用场景：** 高级 AI 训练、程序化行为
- **Status:** 可用于生产
- **包：** `com.unity.ml-agents`
- **官方：** https://github.com/Unity-Technologies/ml-agents

---

### 🟡 Recorder
- **用途：** 录制玩法影像、截图、动画片段
- **使用场景：** 预告片、回放、调试录制
- **Status:** 可用于生产
- **包：** `com.unity.recorder`
- **官方：** https://docs.unity3d.com/Packages/com.unity.recorder@5.0/manual/index.html

---

## 预览/实验性包（谨慎使用）

### ⚠️ Splines
- **用途：** 运行时样条创建与编辑
- **使用场景：** 道路、路径、程序化内容
- **Status:** 可用于生产（Unity 6）
- **包：** `com.unity.splines`
- **官方：** https://docs.unity3d.com/Packages/com.unity.splines@2.6/manual/index.html

---

### ⚠️ Muse (AI Assistant)
- **用途：** AI 驱动的资源创建（纹理、精灵、动画）
- **Status:** 预览（Unity 6）
- **包：** `com.unity.muse.*`
- **官方：** https://unity.com/products/muse

---

### ⚠️ Sentis (Neural Network Inference)
- **用途：** 在 Unity 中运行神经网络（AI 推理）
- **Status:** 预览
- **包：** `com.unity.sentis`
- **官方：** https://docs.unity3d.com/Packages/com.unity.sentis@2.0/manual/index.html

---

## 已弃用的包（新项目应避免）

### ❌ UGUI (Canvas UI)
- **弃用：** 仍然受支持，但推荐 UI Toolkit
- **改用：** UI Toolkit

---

### ❌ Legacy Particle System
- **弃用：** 使用 Visual Effect Graph (VFX Graph)
- **改用：** VFX Graph

---

### ❌ Legacy Animation
- **弃用：** 使用 Animator (Mecanim)
- **改用：** Animator Controller

---

## 按需 WebSearch 策略

对于上面未列出的包，当用户提问时采用以下方式：

1. 用 **WebSearch** 查询最新文档：`"Unity 6.3 [package name]"`
2. 核实该包是否：
   - 属于截止后内容（超出 2025 年 5 月的训练数据）
   - 是预览版还是可用于生产
   - 在 Unity 6.3 LTS 中仍受支持
3. 可选：将结论缓存到 `plugins/[package-name].md` 供日后参考

---

## 快速决策指南

**我需要虚拟相机** → **Cinemachine**
**我需要异步资源加载 / DLC** → **Addressables**
**我需要数千个实体（RTS、模拟）** → **DOTS/Entities**
**我需要现代输入** → **Input System**（参见 modules/input.md）
**我需要 GPU 粒子** → **Visual Effect Graph**
**我需要可视化着色器** → **Shader Graph**
**我需要电影化内容** → **Timeline**
**我需要运行时 IK** → **Animation Rigging**
**我需要关卡原型** → **ProBuilder**
**我需要多人游戏** → **Netcode for GameObjects**

---

**最后更新：** 2026-02-13
**引擎版本：** Unity 6.3 LTS
**LLM 知识截止时间：** 2025 年 5 月
