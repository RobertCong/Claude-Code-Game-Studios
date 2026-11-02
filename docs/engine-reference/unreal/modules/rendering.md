# Unreal Engine 5.8 — 渲染模块参考

**Last verified:** 2026-10-18（对照 5.8 发布说明与源码核对 MegaLights 工具提示）；2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Knowledge Gap:** UE 5.8 拥有可用于生产的 MegaLights、可用于生产的 Substrate（5.7）、Lumen Lite，以及 Lumen 改进

> **UE 5.8 变更：** MegaLights 已可用于生产（在 Project
> Settings > Engine > Rendering > Direct Lighting > MegaLights 中启用，
> `r.MegaLights.EnableForProject`，默认 0）。Lumen Lite（Beta）是一个
> 中等质量的 GI 设置，速度约为 Lumen 高质量的两倍，并且是
> 当代掌机的默认设置。移动端：多 pass 延迟渲染
> 是默认路径（前向渲染需主动启用），支持 SSAO、SSR、延迟贴花与
> 接触阴影。Lumen 默认对反射光线命中应用高度雾
> （`r.Lumen.HeightFog 1`）。Substrate 自 5.7 起对新项目默认开启
> （`r.Substrate`）；Substrate NPR（卡通）着色与 Fog Screen Space Scattering
> 为 Experimental。来源：UE 5.8 发布说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8 ；
> `Engine/Source/Runtime/Engine/Classes/Engine/RendererSettings.h` 与
> `Engine/Source/Runtime/RenderCore/Private/RenderUtils.cpp`（5.8.1 安装）。

---

## 概述

UE 5.8 渲染栈：
- **Lumen**：实时全局光照（默认）
- **Nanite**：面向数百万三角形的虚拟化几何体
- **MegaLights**：大量投射阴影的动态光源（5.5+ 新增，5.8 中可用于生产）
- **Substrate**：可用于生产的模块化材质系统（5.7 新增）

---

## Lumen（全局光照）

### 启用 Lumen

```cpp
// Project Settings > Engine > Rendering > Dynamic Global Illumination Method = Lumen
// Real-time GI, no lightmap baking needed
```

### Lumen 质量设置

```ini
; DefaultEngine.ini
[/Script/Engine.RendererSettings]
r.Lumen.DiffuseColorBoost=1.0
r.Lumen.ScreenProbeGather.RadianceCache.NumFramesToKeepCached=2
```

### 在 C++ 中使用 Lumen

```cpp
// Check if Lumen is enabled
bool bIsLumenEnabled = IConsoleManager::Get().FindConsoleVariable(TEXT("r.DynamicGlobalIlluminationMethod"))->GetInt() == 1;
```

---

## Nanite（虚拟化几何体）

### 在静态网格上启用 Nanite

1. Static Mesh Editor
2. Details > Nanite Settings > Enable Nanite Support
3. 保存网格（自动构建 Nanite 数据）

### 在 C++ 中使用 Nanite

```cpp
// Spawn Nanite mesh
UStaticMeshComponent* MeshComp = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
MeshComp->SetStaticMesh(NaniteMesh); // Automatically uses Nanite if enabled
```

### Nanite 限制
- 不支持顶点动画（骨骼网格）
- 材质中不支持世界位置偏移（WPO）
- 最适合静态高面数几何体

---

## MegaLights（UE 5.5+，5.8 中可用于生产）

### 启用 MegaLights

```cpp
// Project Settings > Engine > Rendering > Direct Lighting > MegaLights
//   (r.MegaLights.EnableForProject, default 0; a Post Process Volume can
//   override it, and it can be disabled per light)
// Many shadow-casting lights at a consistent, low GPU cost
```

### 编辑器工具提示比 5.8 发布说明更旧

在 5.8.1 安装中，该设置的工具提示（`RendererSettings.h`）与
`r.MegaLights.EnableForProject` 的帮助文本（`MegaLights.cpp`）仍以
"Experimental feature." 结尾，并称 MegaLights "requires Hardware Ray Tracing, and
does not support Directional Lights"。请以发布说明和引擎
代码为准：

- **Status:** "Megalights is now entering Production Ready status with Unreal
  Engine 5.8"（5.8 发布说明，Rendering > Megalights）。
- **Ray tracing:** 渲染器接受硬件或软件光线追踪支持
  （`MegaLights.cpp` 中的 `HasRequiredTracingData`）。当
  `r.MegaLights.HardwareRayTracing` 为 1（默认值）时，阴影光线使用硬件光线
  追踪。阴影来自光线追踪（默认）或 Virtual Shadow Maps：
  `r.MegaLights.DefaultShadowMethod` 为 0 或 1。
- **Directional lights:** 由 `r.MegaLights.DirectionalLights`
  控制，默认 0（关闭）。5.7 发布说明列出了 Directional Light 支持。

来源，读取于 2026-10-18：5.8 与 5.7 发布说明（§ 来源）；在 UE
5.8.1 安装（CL 56057345）中，`Engine/Source/Runtime/Engine/Classes/Engine/RendererSettings.h`、
`Engine/Source/Runtime/Renderer/Private/MegaLights/MegaLights.cpp` 与
`MegaLightsRayTracing.cpp`。

### MegaLights 用法

```cpp
// Add point lights as usual
UPointLightComponent* Light = CreateDefaultSubobject<UPointLightComponent>(TEXT("Light"));
Light->SetIntensity(5000.0f);
Light->SetAttenuationRadius(500.0f);

// MegaLights handles many of these at a consistent GPU cost
```

---

## Substrate 材质（5.7 中可用于生产）

### 启用 Substrate

```cpp
// On by default for new projects created in 5.7+.
// Existing project: Project Settings > Engine > Rendering > Substrate >
//   Substrate materials (r.Substrate), then restart the editor
```

### Substrate 材质节点
- **Substrate Slab**：物理材质层（漫反射、高光等）
- **Substrate Blend**：混合多个层
- **Substrate Thin Film**：虹彩、肥皂泡
- **Substrate Hair**：面向头发的专用着色

### Substrate 材质图示例

```
Substrate Slab (Diffuse)
  └─ Base Color: Texture Sample
  └─ Roughness: Constant (0.5)
  └─ Metallic: Constant (0.0)
  └─ Connect to Material Output
```

---

## 材质（C++ API）

### 动态材质实例

```cpp
// Create dynamic material instance
UMaterialInstanceDynamic* DynMat = UMaterialInstanceDynamic::Create(BaseMaterial, this);

// Set parameters
DynMat->SetVectorParameterValue(TEXT("BaseColor"), FLinearColor::Red);
DynMat->SetScalarParameterValue(TEXT("Metallic"), 0.8f);
DynMat->SetTextureParameterValue(TEXT("DiffuseTexture"), MyTexture);

// Apply to mesh
MeshComp->SetMaterial(0, DynMat);
```

---

## 后处理

### Post-Process Volume

```cpp
// Add to level
APostProcessVolume* PPV = GetWorld()->SpawnActor<APostProcessVolume>();
PPV->bUnbound = true; // Affect entire world

// Configure settings
PPV->Settings.bOverride_MotionBlurAmount = true;
PPV->Settings.MotionBlurAmount = 0.5f;

PPV->Settings.bOverride_BloomIntensity = true;
PPV->Settings.BloomIntensity = 1.0f;
```

### 在 C++ 中使用后处理

```cpp
// Access camera post-process settings
APlayerController* PC = GetWorld()->GetFirstPlayerController();
if (APlayerCameraManager* CamManager = PC->PlayerCameraManager) {
    CamManager->PostProcessBlendWeight = 1.0f;
    CamManager->PostProcessSettings.BloomIntensity = 2.0f;
}
```

---

## 光照

### Directional Light（太阳）

```cpp
ADirectionalLight* Sun = GetWorld()->SpawnActor<ADirectionalLight>();
Sun->SetActorRotation(FRotator(-45.f, 0.f, 0.f));
Sun->GetLightComponent()->SetIntensity(10.0f);
Sun->GetLightComponent()->bCastShadows = true;
```

### 点光源

```cpp
APointLight* Light = GetWorld()->SpawnActor<APointLight>();
Light->SetActorLocation(FVector(0, 0, 200));
Light->GetPointLightComponent()->SetIntensity(5000.0f);
Light->GetPointLightComponent()->SetAttenuationRadius(1000.0f);
Light->GetPointLightComponent()->SetLightColor(FLinearColor::Red);
```

### 聚光源

```cpp
ASpotLight* Spotlight = GetWorld()->SpawnActor<ASpotLight>();
Spotlight->GetSpotLightComponent()->SetInnerConeAngle(20.0f);
Spotlight->GetSpotLightComponent()->SetOuterConeAngle(40.0f);
```

---

## 渲染目标（渲染到纹理）

### 创建 Render Target

```cpp
// Create render target asset (2D texture)
UTextureRenderTarget2D* RenderTarget = NewObject<UTextureRenderTarget2D>();
RenderTarget->InitAutoFormat(512, 512); // 512x512 resolution
RenderTarget->UpdateResourceImmediate();

// Render scene to texture
UKismetRenderingLibrary::DrawMaterialToRenderTarget(
    GetWorld(),
    RenderTarget,
    MaterialToDraw
);
```

---

## 自定义渲染 Pass（高级）

### Render Dependency Graph（RDG）

```cpp
// UE5 uses Render Dependency Graph for custom rendering
// Example: Custom post-process pass

#include "RenderGraphBuilder.h"

void RenderCustomPass(FRDGBuilder& GraphBuilder, const FViewInfo& View) {
    FRDGTextureRef SceneColor = /* Get scene color texture */;

    // Define pass parameters
    struct FPassParameters {
        FRDGTextureRef InputTexture;
    };

    FPassParameters* PassParams = GraphBuilder.AllocParameters<FPassParameters>();
    PassParams->InputTexture = SceneColor;

    // Add render pass
    GraphBuilder.AddPass(
        RDG_EVENT_NAME("CustomPass"),
        PassParams,
        ERDGPassFlags::Raster,
        [](FRHICommandList& RHICmdList, const FPassParameters* Params) {
            // Render commands
        }
    );
}
```

---

## 性能

### 渲染统计

```cpp
// Console commands for profiling:
// stat fps - Show FPS
// stat unit - Show frame time breakdown
// stat gpu - Show GPU timings
// profilegpu - Detailed GPU profile
```

### 可扩展性设置

```cpp
// Get current scalability settings
UGameUserSettings* Settings = UGameUserSettings::GetGameUserSettings();
int32 ViewDistanceQuality = Settings->GetViewDistanceQuality(); // 0-4

// Set scalability
Settings->SetViewDistanceQuality(3); // High
Settings->SetShadowQuality(2); // Medium
Settings->ApplySettings(false);
```

---

## 调试

### 可视化渲染特性

```
Console commands:
- r.Lumen.Visualize 1 - Show Lumen debug
- r.Nanite.Visualize 1 - Show Nanite triangles
- viewmode wireframe - Wireframe mode
- viewmode unlit - Disable lighting
- show collision - Show collision meshes
```

---

## 来源
- UE 5.8 发布说明：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8
- UE 5.7 发布说明：https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes?application_version=5.7
- https://docs.unrealengine.com/5.7/en-US/lumen-global-illumination-and-reflections-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/nanite-virtualized-geometry-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/substrate-materials-in-unreal-engine/
