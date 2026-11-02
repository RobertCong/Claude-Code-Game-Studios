# Godot 网络 — 快速参考

最后核对：2026-10-17（4.7 变更）；2026-02-12（其余部分） | Engine: Godot 4.7

## 自 ~4.3（LLM 知识截止）以来的变更

### 4.7 变更
- 4.7 迁移指南中**未列出网络相关的变更**（4.7 迁移指南：https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html）

### 4.6 变更
- **破坏性变更中的网络部分**：4.5→4.6 层级的具体细节见官方迁移指南

### 4.5 变更
- **没有重大的网络 API 破坏**——核心多人 API 保持稳定

## 当前 API 模式

### 高层多人
```gdscript
# Server
func host_game(port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# Client
func join_game(address: String, port: int = 9999) -> void:
    var peer := ENetMultiplayerPeer.new()
    peer.create_client(address, port)
    multiplayer.multiplayer_peer = peer
```

### RPC
```gdscript
# Server-authoritative pattern
@rpc("any_peer", "call_local", "reliable")
func request_action(action_data: Dictionary) -> void:
    if not multiplayer.is_server():
        return
    # Validate on server, then broadcast
    _execute_action.rpc(action_data)

@rpc("authority", "call_local", "reliable")
func _execute_action(action_data: Dictionary) -> void:
    # All peers execute the validated action
    pass
```

### MultiplayerSpawner 与 MultiplayerSynchronizer
```gdscript
# Use MultiplayerSpawner for automatic node replication
# Use MultiplayerSynchronizer for property synchronization

# MultiplayerSynchronizer setup:
# 1. Add as child of the node to sync
# 2. Configure replication properties in editor
# 3. Set visibility filters for relevancy
```

### SceneMultiplayer 配置
```gdscript
func _ready() -> void:
    var scene_mp := multiplayer as SceneMultiplayer
    scene_mp.auth_callback = _authenticate_peer
    scene_mp.server_relay = false  # Direct peer connections

func _authenticate_peer(id: int, data: PackedByteArray) -> void:
    # Custom authentication logic
    pass
```

## 常见错误
- 客户端到服务器的 RPC 未使用 `"any_peer"`（默认仅限权威端）
- 不经验证就信任客户端数据
- 对游戏状态变更使用 `"unreliable"`（仅用于位置更新）
- 未在生成的节点上设置多人权威（`set_multiplayer_authority()`）
