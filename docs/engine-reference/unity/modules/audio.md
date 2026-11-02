# Unity 6.3 — 音频模块参考

**Last verified:** 2026-02-13
**Knowledge Gap:** Unity 6 音频混音器改进

---

## 概述

Unity 6.3 音频系统：
- **AudioSource**：在 GameObject 上播放声音
- **Audio Mixer**：混音、效果处理、动态混音
- **Spatial Audio**：3D 定位声音

---

## 基本音频播放

### AudioSource 组件

```csharp
AudioSource audioSource = GetComponent<AudioSource>();

// ✅ Play
audioSource.Play();

// ✅ Play with delay
audioSource.PlayDelayed(0.5f); // 0.5 seconds

// ✅ Play one-shot (doesn't interrupt current sound)
audioSource.PlayOneShot(clip);

// ✅ Stop
audioSource.Stop();

// ✅ Pause/Resume
audioSource.Pause();
audioSource.UnPause();
```

### 在指定位置播放声音（静态方法）

```csharp
// ✅ Quick 3D sound playback (auto-destroys when done)
AudioSource.PlayClipAtPoint(clip, transform.position);

// ✅ With volume
AudioSource.PlayClipAtPoint(clip, transform.position, 0.7f);
```

---

## 3D 空间音频

### AudioSource 3D 设置

```csharp
AudioSource source = GetComponent<AudioSource>();

// Spatial Blend: 0 = 2D, 1 = 3D
source.spatialBlend = 1.0f; // Fully 3D

// Doppler effect (pitch shift based on velocity)
source.dopplerLevel = 1.0f;

// Distance attenuation
source.minDistance = 1f;   // Full volume within this distance
source.maxDistance = 50f;  // Inaudible beyond this distance
source.rolloffMode = AudioRolloffMode.Logarithmic; // Natural falloff
```

### 音量衰减曲线
- **Logarithmic**：自然、真实（推荐）
- **Linear**：稳定递减
- **Custom**：自定义曲线

---

## Audio Mixer（高级混音）

### 设置 Audio Mixer

1. `Assets > Create > Audio Mixer`
2. 打开混音器：`Window > Audio > Audio Mixer`
3. 创建分组：Master > SFX、Music、Dialogue

### 将 AudioSource 分配到混音器分组

```csharp
using UnityEngine.Audio;

public AudioMixerGroup sfxGroup;

void Start() {
    AudioSource source = GetComponent<AudioSource>();
    source.outputAudioMixerGroup = sfxGroup; // Route to SFX group
}
```

### 通过代码控制混音器

```csharp
using UnityEngine.Audio;

public AudioMixer audioMixer;

// ✅ Set volume (exposed parameter)
audioMixer.SetFloat("MusicVolume", -10f); // dB (-80 to 0)

// ✅ Get volume
audioMixer.GetFloat("MusicVolume", out float volume);

// Convert linear (0-1) to dB
float volumeDB = Mathf.Log10(volumeLinear) * 20f;
audioMixer.SetFloat("MusicVolume", volumeDB);
```

### 暴露混音器参数
在 Audio Mixer 窗口中：
1. 右键点击参数（例如 Volume）
2. 选择 "Expose 'Volume' to script"
3. 在 "Exposed Parameters" 选项卡中重命名（例如 "MusicVolume"）

---

## 音频效果

### 为混音器分组添加效果

在 Audio Mixer 中：
- 点击分组（例如 SFX）
- 点击 "Add Effect"
- 选择：Reverb、Echo、Low Pass、High Pass、Distortion 等。

### 对话时压低音乐（侧链）

```csharp
// Setup in Audio Mixer:
// 1. Create "Duck Volume" snapshot
// 2. Lower music volume in that snapshot
// 3. Transition to snapshot when dialogue plays

public AudioMixerSnapshot normalSnapshot;
public AudioMixerSnapshot duckedSnapshot;

public void PlayDialogue(AudioClip clip) {
    duckedSnapshot.TransitionTo(0.5f); // 0.5s transition
    audioSource.PlayOneShot(clip);
    Invoke(nameof(RestoreMusic), clip.length);
}

void RestoreMusic() {
    normalSnapshot.TransitionTo(1.0f); // 1s transition back
}
```

---

## 音频性能

### 优化音频加载

```csharp
// Audio Import Settings (Inspector):
// - Load Type:
//   - Decompress On Load: Small clips (SFX), loads fully into memory
//   - Compressed In Memory: Medium clips, decompressed at runtime (RECOMMENDED)
//   - Streaming: Large clips (music), streamed from disk

// Compression Format:
// - PCM: Uncompressed, highest quality, largest size
// - ADPCM: 3.5x compression, good for SFX (RECOMMENDED for SFX)
// - Vorbis/MP3: High compression, good for music (RECOMMENDED for music)
```

### 预加载音频

```csharp
// Preload audio clip before playing (avoid stutter)
audioSource.clip.LoadAudioData();

// Check if loaded
if (audioSource.clip.loadState == AudioDataLoadState.Loaded) {
    audioSource.Play();
}
```

---

## 音乐系统

### 曲目间交叉淡入淡出

```csharp
public IEnumerator CrossfadeMusic(AudioSource from, AudioSource to, float duration) {
    float elapsed = 0f;
    to.Play();

    while (elapsed < duration) {
        elapsed += Time.deltaTime;
        float t = elapsed / duration;

        from.volume = Mathf.Lerp(1f, 0f, t);
        to.volume = Mathf.Lerp(0f, 1f, t);

        yield return null;
    }

    from.Stop();
}
```

### 无缝音乐循环

```csharp
// Audio Import Settings:
// - Check "Loop" for seamless music loops
audioSource.loop = true;
```

---

## 常见模式

### 随机音高变化（避免重复）

```csharp
void PlaySoundWithVariation(AudioClip clip) {
    AudioSource source = GetComponent<AudioSource>();
    source.pitch = Random.Range(0.9f, 1.1f); // ±10% pitch variation
    source.PlayOneShot(clip);
}
```

### 脚步声（从数组中随机选取）

```csharp
public AudioClip[] footstepClips;

void PlayFootstep() {
    AudioClip clip = footstepClips[Random.Range(0, footstepClips.Length)];
    AudioSource.PlayClipAtPoint(clip, transform.position, 0.5f);
}
```

### 检查声音是否正在播放

```csharp
if (audioSource.isPlaying) {
    // Sound is currently playing
}
```

---

## Audio Listener

### 单一监听器规则
- 同一时间只应有一个 `AudioListener` 处于激活状态
- 通常挂载到 Main Camera 上

```csharp
// Disable extra listeners
AudioListener listener = GetComponent<AudioListener>();
listener.enabled = false;
```

---

## 调试

### Audio 窗口
- `Window > Audio > Audio Mixer`
- 可视化电平，测试快照

### 音频设置
- `Edit > Project Settings > Audio`
- 全局音量、DSP 缓冲区大小、扬声器模式

---

## 来源
- https://docs.unity3d.com/6000.0/Documentation/Manual/Audio.html
- https://docs.unity3d.com/6000.0/Documentation/Manual/AudioMixer.html
