# Unreal Engine 5.8 — 音频模块参考

**Last verified:** 2026-10-17（UE 5.8 变更区块）；2026-02-13（文件其余部分，针对 5.7 编写）
**Knowledge Gap:** UE 5.7 MetaSounds 可用于生产；UE 5.8 Windows 上默认使用 WASAPI

> **UE 5.8 变更：** 默认的 Windows 音频后端现在为 WASAPI
> （XAudio2 是可选的备用方案；Epic 表示："No changes are required on the
> developers end"）。`au.EnableRelativeRenderCostVoiceLimit` 默认开启，
> 因此在相同语音数下可能播放更少的音效 — 请重新审视语音数
> 调优。此前被 `bEnableSubmixSends` 隐式禁用的衰减 submix 发送
> 现在可能变为可听。Audio Insights 可用于生产；
> Audio Subtitles 为 Beta；MetaSound Node Configuration 与 Templates 为
> Experimental。自定义 MetaSound 节点：`FNodeClassMetadata::DefaultInterface`
> 现在接收 `FClassInterface`。来源：UE 5.8 发布说明，https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-8-release-notes?application_version=5.8

---

## 概述

UE 5.8 音频系统：
- **MetaSounds**：基于节点的程序化音频（推荐，可用于生产）
- **Sound Cues**：遗留的基于节点音频（用于简单场景）
- **Audio Component**：在 actor 上播放声音

---

## 基础音频播放

### 在位置处播放声音

```cpp
#include "Kismet/GameplayStatics.h"

// ✅ Play 2D sound (no spatialization)
UGameplayStatics::PlaySound2D(GetWorld(), ExplosionSound);

// ✅ Play sound at location (3D spatial audio)
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation());

// ✅ With volume and pitch
UGameplayStatics::PlaySoundAtLocation(GetWorld(), ExplosionSound, GetActorLocation(), 0.7f, 1.2f);
```

---

## 音频组件（Audio Component）

### 音频组件（持久声音）

```cpp
// Create audio component
UAudioComponent* AudioComp = CreateDefaultSubobject<UAudioComponent>(TEXT("Audio"));
AudioComp->SetupAttachment(RootComponent);
AudioComp->SetSound(LoopingAmbience);

// Play/Stop
AudioComp->Play();
AudioComp->Stop();

// Fade in/out
AudioComp->FadeIn(2.0f); // 2 seconds
AudioComp->FadeOut(1.5f, 0.0f); // 1.5s to volume 0

// Adjust volume/pitch
AudioComp->SetVolumeMultiplier(0.5f);
AudioComp->SetPitchMultiplier(1.2f);
```

---

## 3D 空间音频

### 衰减设置（Attenuation Settings）

```cpp
// Create Sound Attenuation asset:
// Content Browser > Sounds > Sound Attenuation

// Configure:
// - Attenuation Shape: Sphere, Capsule, Box, Cone
// - Falloff Distance: Distance where sound becomes inaudible
// - Attenuation Function: Linear, Logarithmic, Inverse, etc.

// Assign in C++:
AudioComp->AttenuationSettings = AttenuationAsset;
```

### 在代码中覆盖衰减

```cpp
FSoundAttenuationSettings AttenuationOverride;
AttenuationOverride.AttenuationShape = EAttenuationShape::Sphere;
AttenuationOverride.FalloffDistance = 1000.0f;
AttenuationOverride.AttenuationShapeExtents = FVector(1000.0f);

AudioComp->AttenuationOverrides = AttenuationOverride;
AudioComp->bOverrideAttenuation = true;
```

---

## MetaSounds（程序化音频）

### 创建 MetaSound Source

1. Content Browser > Sounds > MetaSound Source
2. 打开 MetaSound 编辑器
3. 构建节点图：
   - **Inputs**：触发器、参数
   - **Generators**：振荡器、噪声、采样
   - **Modulators**：包络、LFO
   - **Effects**：滤波器、混响、延迟
   - **Output**：音频输出

### 播放 MetaSound

```cpp
// Play MetaSound like any sound
UGameplayStatics::PlaySound2D(GetWorld(), MetaSoundSource);

// Or with Audio Component
AudioComp->SetSound(MetaSoundSource);
AudioComp->Play();
```

### 设置 MetaSound 参数

```cpp
// Define parameter in MetaSound (Input node with exposed parameter)
// Set parameter in C++:
AudioComp->SetFloatParameter(FName("Volume"), 0.8f);
AudioComp->SetIntParameter(FName("OctaveShift"), 2);
AudioComp->SetBoolParameter(FName("EnableReverb"), true);
```

---

## Sound Cues（遗留）

### 创建 Sound Cue

1. Content Browser > Sounds > Sound Cue
2. 打开 Sound Cue 编辑器
3. 添加节点：Random、Modulator、Mixer 等

### 使用 Sound Cue

```cpp
// Play like any sound
UGameplayStatics::PlaySound2D(GetWorld(), SoundCue);
```

---

## 声音类与声音混合（Sound Class & Sound Mix）

### Sound Class（音量分组）

```cpp
// Create Sound Class: Content Browser > Sounds > Sound Class
// Hierarchy: Master > Music, SFX, Dialogue

// Assign to sound asset:
// Sound Wave > Sound Class = SFX

// Set volume in C++:
UAudioSettings* AudioSettings = GetMutableDefault<UAudioSettings>();
// Configure via Sound Class hierarchy
```

### Sound Mix（动态混音）

```cpp
// Create Sound Mix asset
// Define adjustments: Lower music during dialogue, etc.

// Push sound mix
UGameplayStatics::PushSoundMixModifier(GetWorld(), DuckedMusicMix);

// Pop sound mix
UGameplayStatics::PopSoundMixModifier(GetWorld(), DuckedMusicMix);
```

---

## 音频遮挡与混响

### 音频遮挡（墙体阻挡声音）

```cpp
// Enable in Audio Component:
AudioComp->bEnableOcclusion = true;

// Requires geometry with collision
```

### 混响体积（Reverb Volume）

```cpp
// Add Audio Volume to level (Volumes > Audio Volume)
// Configure reverb settings in Details panel
// Audio component automatically picks up reverb when inside volume
```

---

## 常见模式

### 脚步声（随机变化）

```cpp
// Use Sound Cue with Random node, or:
UPROPERTY(EditAnywhere, Category = "Audio")
TArray<TObjectPtr<USoundBase>> FootstepSounds;

void PlayFootstep() {
    int32 Index = FMath::RandRange(0, FootstepSounds.Num() - 1);
    UGameplayStatics::PlaySoundAtLocation(GetWorld(), FootstepSounds[Index], GetActorLocation());
}
```

### 音乐交叉淡入淡出

```cpp
UAudioComponent* MusicA;
UAudioComponent* MusicB;

void CrossfadeMusic(float Duration) {
    MusicA->FadeOut(Duration, 0.0f);
    MusicB->FadeIn(Duration);
}
```

### 检查声音是否正在播放

```cpp
if (AudioComp->IsPlaying()) {
    // Sound is playing
}
```

---

## 音频并发（Audio Concurrency）

### 限制同时播放的声音

```cpp
// Create Sound Concurrency asset:
// Content Browser > Sounds > Sound Concurrency

// Configure:
// - Max Count: Maximum instances of this sound
// - Resolution Rule: Stop Oldest, Stop Quietest, etc.

// Assign to sound:
// Sound Wave > Concurrency Settings
```

---

## 性能技巧

### 音频优化

```cpp
// Compression settings (Sound Wave asset):
// - Compression Quality: 40 (balance quality/size)
// - Streaming: Enable for large files (music)

// Reduce audio mixing cost:
// - Limit concurrent sounds via Sound Concurrency
// - Use simple attenuation shapes

// Disable audio for distant actors:
if (Distance > MaxAudibleDistance) {
    AudioComp->Stop();
}
```

---

## 调试

### 音频调试命令

```cpp
// Console commands:
// au.Debug.Sounds 1 - Show active sounds
// au.3dVisualize.Enabled 1 - Visualize 3D audio
// stat soundwaves - Show sound statistics
// stat soundmixes - Show active sound mixes
```

---

## 来源
- https://docs.unrealengine.com/5.7/en-US/audio-in-unreal-engine/
- https://docs.unrealengine.com/5.7/en-US/metasounds-in-unreal-engine/
