# Godot 音频 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

4.4–4.6 中音频 API 没有重大破坏性变更；4.7 移除了一个属性并更改了一个
默认值：

### 4.7 变更
- **`AudioEffectSpectrumAnalyzer.tap_back_pos` 已移除**
- **`AudioStreamPlayer2D`/`3D` 上的 `area_mask` 默认值为 `0`**（原为层 `1`）：
  在把掩码改回层 `1` 之前，`Area2D`/`Area3D` 上的 `audio_bus_override` 会随默认
  掩码停止工作（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）

### 4.6 变更
- **此版本没有音频相关的破坏性变更**

### 4.5 变更
- **此版本没有音频相关的破坏性变更**

## 当前 API 模式

### 播放音频
```gdscript
@onready var sfx_player: AudioStreamPlayer = %SFXPlayer
@onready var music_player: AudioStreamPlayer = %MusicPlayer

func play_sfx(stream: AudioStream) -> void:
    sfx_player.stream = stream
    sfx_player.play()

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
    var tween: Tween = create_tween()
    tween.tween_property(music_player, "volume_db", -80.0, fade_time)
    await tween.finished
    music_player.stream = stream
    music_player.volume_db = 0.0
    music_player.play()
```

### 3D 空间音频
```gdscript
@onready var audio_3d: AudioStreamPlayer3D = %AudioPlayer3D

func _ready() -> void:
    audio_3d.max_distance = 50.0
    audio_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
    audio_3d.unit_size = 10.0
```

### 音频总线
```gdscript
# Set bus volumes
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), volume_db)
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), volume_db)

# Mute a bus
AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music"), true)
```

### SFX 对象池
```gdscript
# Pre-create multiple AudioStreamPlayer nodes for concurrent sounds
var _sfx_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
    for i in range(8):
        var player := AudioStreamPlayer.new()
        player.bus = &"SFX"
        add_child(player)
        _sfx_pool.append(player)

func play_pooled(stream: AudioStream) -> void:
    for player in _sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
```

## 常见错误
- 在运行时创建新的 AudioStreamPlayer 节点，而不是使用对象池
- 不使用音频总线来分类音量（Music、SFX、UI、Voice）
- 使用 `_process()` 处理音频计时，而不是使用信号（`finished`）
