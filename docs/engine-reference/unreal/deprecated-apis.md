# Unreal Engine 5.8 — 已弃用 API

**最后核实：** 2026-10-17（Deprecated in UE 5.8、Gameplay Ability System 行、总结）；2026-02-13（文件其余部分，依据 5.7 编写）

已弃用 API 及其替代项的快速查询表。
格式：**不要使用 X** → **改用 Y**

---

## UE 5.8 中弃用

来自 5.8 发布说明的 Upgrade Notes 以及 5.8 引擎头文件（来源列于本文件末尾）。除非“说明”列另有交代，已弃用项仍可编译，但会产生警告。

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| `UE_LOG(...)` | `UE_LOGF(Category, Verbosity, "fmt", ...)` | 尚未弃用：Epic 表示 UE_LOG“最终会被弃用”，并建议使用 `UE_LOGF`。头文件说明其格式为 printf 风格字面量，可写作 `"..."` 或 `UTF8TEXT("...")`。5.8 附带 `ConvertUELog.py` 以处理大多数用法 |
| `#if PLATFORM_IOS`（以及其他 `PLATFORM_*`） | `#if UE_PLATFORM_IOS`（`UE_PLATFORM_*`） | 可选迁移；`PLATFORM_IOS` 可能被 Apple 框架头文件覆盖 |
| `CppStandardVersion.Cpp17` / `Cpp14` | `CppStandardVersion.Default`（C++20） | 在 5.8 中已废弃：使用它们时代码不再编译 |
| Raw Input 插件（`RawInput`） | Game Input for Windows 插件（`GameInputWindows`，Beta） | `RawInput.uplugin` 中的 `"DeprecatedEngineVersion": "5.8"` |
| PhysicsMover（Mover 插件） | ChaosMover 插件 | 在 5.8 中已移除，而非仅弃用 |
| `FActiveGameplayEffectHandle(int32)` | `FActiveGameplayEffectHandle::GenerateNewHandle` 或 `GetInstantExecutedHandle()` | `UE_DEPRECATED(5.8, ...)` |
| `FSmartName`、`FSmartNameMapping`、`FSmartNameContainer` | 无：删除相关用法 | `UE_DEPRECATED(5.8, "Smart names and their mappings are no longer used")` |
| `UFadeFunction`、`FFadeFunctionData`、`EWaveEditorFadeMode` | `UTransformationFadeFunction`、`UWaveformTransformationFade` | Waveform Editor |
| 蓝图中 `URigHierarchy::FindBone` / `FindControl` / `FindNull` | `Contains(Key)`、`GetBoneType(Key)`、`GetControlSettings(Key)`、`IsSelected(Key)`、`GetIndex(Key)` | Control Rig；现有图表仍可运行，但会给出警告 |
| 插件中的 `PluginName.ini` / `BasePluginName.ini` | `DefaultPluginName.ini` | 插件配置文件 |
| `r.Water.SingleLayer.ForceVelocity` | `r.Water.SingleLayer.VelocityOutputPass`（或项目设置） | 渲染 CVar |
| `EWindowType::GameWindow` | `EWindowType::Normal` | Slate |

---

## 输入

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| `InputComponent->BindAction()` | Enhanced Input 的 `BindAction()` | 新输入系统 |
| `InputComponent->BindAxis()` | Enhanced Input 的 `BindAxis()` | 新输入系统 |
| `PlayerController->GetInputAxisValue()` | Enhanced Input Action Values | 新输入系统 |

**迁移：** 安装 Enhanced Input 插件，创建 Input Actions 和 Input Mapping Contexts。

---

## 渲染

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| 旧版材质节点 | Substrate 材质节点 | Substrate 在 5.7 达到生产可用，新项目默认开启 |
| 前向着色（默认） | 延迟着色 + Lumen | Lumen 在 UE5 中为默认 |
| 旧光照工作流 | Lumen 全局光照 | 实时 GI |

---

## 世界构建

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| UE4 World Composition | World Partition（UE5） | 大型世界的流式加载 |
| Level Streaming Volumes | World Partition Data Layers | 更好的关卡流式加载 |

---

## 动画

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| 旧动画重定向 | IK Rig + IK Retargeter | UE5 重定向系统 |
| 旧版 Control Rig | Control Rig 2.0 | 生产可用的绑定 |

---

## 玩法

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| `UGameplayStatics::LoadStreamLevel()` | World Partition 流式加载 | 使用 Data Layers |
| 硬编码输入绑定 | Enhanced Input 系统 | 可重绑、模块化输入 |

---

## Gameplay Ability System

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| `UGameplayAbility::AbilityTags`（直接访问） | 读取用 `GetAssetTags()`；设置用构造函数中的 `SetAssetTags()` | 5.8 头文件中的 `UE_DEPRECATED_FORGAME(5.5, ...)`：“This is being made non-mutable, private and renamed to AssetTags in the future” |
| `FActiveGameplayEffectHandle(int32)` | `GenerateNewHandle` / `GetInstantExecutedHandle()` | 在 5.8 中弃用 |

---

## Niagara（VFX）

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| Cascade 粒子系统 | Niagara | Cascade 已完全弃用 |

---

## 音频

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| 旧音频混音器 | MetaSounds | 程序化音频系统 |
| Sound Cue（用于复杂逻辑） | MetaSounds | 更强大，基于节点 |

---

## 网络

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| `DOREPLIFETIME()`（基础版） | `DOREPLIFETIME_CONDITION()` | 为优化而使用的条件复制 |

---

## C++ 脚本

| 已弃用 | 替代项 | 说明 |
|------------|-------------|-------|
| UObject 使用 `TSharedPtr<T>` | `TObjectPtr<T>` | UE5 类型安全指针 |
| 手动 RTTI 检查 | `Cast<T>()` / `IsA<T>()` | 类型安全转换 |

---

## 快速迁移范式

### 输入示例
```cpp
// ❌ Deprecated
void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);
}

// ✅ Enhanced Input
#include "EnhancedInputComponent.h"

void AMyCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
    UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(PlayerInputComponent);
    if (EIC) {
        EIC->BindAction(JumpAction, ETriggerEvent::Started, this, &ACharacter::Jump);
    }
}
```

### 材质示例
```cpp
// ❌ Deprecated: Legacy material
// Use standard material graph (still works but not recommended)

// ✅ Substrate Material
// Enable: Project Settings > Engine > Substrate > Enable Substrate
// Use Substrate nodes in material editor
```

### World Partition 示例
```cpp
// ❌ Deprecated: Level streaming volumes
// Load/unload levels manually

// ✅ World Partition
// Enable: World Settings > Enable World Partition
// Use Data Layers for streaming
```

### 粒子系统示例
```cpp
// ❌ Deprecated: Cascade
UParticleSystemComponent* PSC = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("Particles"));

// ✅ Niagara
UNiagaraComponent* NiagaraComp = CreateDefaultSubobject<UNiagaraComponent>(TEXT("Niagara"));
```

### 音频示例
```cpp
// ❌ Deprecated: Sound Cue for complex logic
// Use Sound Cue editor nodes

// ✅ MetaSounds
// Create MetaSound Source asset, use node-based audio
```

---

## 总结：UE 5.8 技术栈

| 功能 | 使用此项（2026） | 避免此项（旧版） |
|---------|------------------|----------------------|
| **Input** | Enhanced Input | Legacy Input Bindings |
| **Materials** | Substrate | Legacy Material System |
| **Lighting** | Lumen + MegaLights | Lightmaps + Limited Lights |
| **Particles** | Niagara | Cascade |
| **Audio** | MetaSounds | Sound Cue (for logic) |
| **World Streaming** | World Partition | World Composition |
| **Animation Retarget** | IK Rig + Retargeter | Old Retargeting |
| **Geometry** | Nanite (high-poly) | Standard Static Mesh LODs |
| **Logging** | `UE_LOGF` (5.8) | `UE_LOG` (still supported) |
| **Windows device input** | Game Input for Windows | Raw Input plugin (deprecated 5.8) |

---

**Sources:**
- UE 5.8 release notes，Upgrade Notes 与 API Change 条目：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8
- 5.8 引擎头文件，于 2026-10-17 从 UE 5.8.1 安装中读取：`Engine/Source/Runtime/Core/Public/Logging/LogMacros.h`（`UE_LOGF`）；`Engine/Source/Runtime/Core/Public/HAL/Platform.h`（`UE_PLATFORM_*`）；`Engine/Source/Programs/UnrealBuildTool/System/CppCompileEnvironment.cs`；`Engine/Plugins/Experimental/RawInput/RawInput.uplugin` 与 `Engine/Plugins/GameInputWindows/GameInputWindows.uplugin`；`Engine/Plugins/Runtime/GameplayAbilities/Source/GameplayAbilities/Public/ActiveGameplayEffectHandle.h` 与 `.../Public/Abilities/GameplayAbility.h`；`Engine/Source/Runtime/Engine/Classes/Animation/SmartName.h`
- https://docs.unrealengine.com/5.7/en-US/deprecated-and-removed-features/
- https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
