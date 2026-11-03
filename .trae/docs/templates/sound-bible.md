# Sound Bible: [Project Name]

> **Location**: `design/audio/sound-bible.md` —— 不是 `design/gdd/`，因为 GDD 检查会把那里的每个文件都算作系统 GDD
> **Owned By**: audio-director

## Audio Vision

### Sonic Identity
[用 2-3 句话描述游戏的整体音频个性。这款游戏「听起来」像什么？音频应唤起怎样的情绪？]

### Audio Pillars
1. **[Pillar 1]**：[该支柱在音频中如何体现]
2. **[Pillar 2]**：[该支柱在音频中如何体现]
3. **[Pillar 3]**：[该支柱在音频中如何体现]

### Reference Games / Media
| Reference | What to Take From It | What to Avoid |
| ---- | ---- | ---- |
| [Game/Film 1] | [要效仿的具体音频特质] | [不符合我们愿景的内容] |
| [Game/Film 2] | [要效仿的具体音频特质] | [不符合我们愿景的内容] |

---

## Music Direction

### Style and Genre
[主要音乐风格、乐器编制、速度范围]

### Instrumentation Palette
- **Core instruments**: [列出定义音色的主要乐器/合成器]
- **Accent instruments**: [用于强调、过渡和特殊时刻]
- **Avoid**: [不适合本游戏的乐器或风格]

### Adaptive Music System
| Game State | Music Behavior | Transition |
| ---- | ---- | ---- |
| Exploration | [速度、能量、乐器编制] | [如何过渡到下一状态] |
| Combat | [速度、能量、乐器编制] | [触发条件和交叉淡入淡出时长] |
| Stealth/Tension | [速度、能量、乐器编制] | [触发条件和过渡] |
| Victory/Reward | [短音效或过渡行为] | [返回探索状态] |
| Menu/UI | [菜单风格] | [游戏开始时淡出] |

### Music Rules
- [关于循环的规则，例如「所有探索曲目必须在 2-4 分钟后无缝循环」]
- [关于静默的规则，例如「探索循环之间允许 10-15 秒静默」]
- [关于强度的规则，例如「战斗音乐必须在战斗开始 3 秒内达到最高强度」]
- [关于过渡的规则，例如「所有音乐过渡使用 1.5 秒交叉淡入淡出」]

---

## Sound Effects

### SFX Palette
| Category | Description | Style Notes |
| ---- | ---- | ---- |
| Player Actions | [移动、攻击、技能] | [干脆、响应迅速、混音靠前] |
| Enemy Actions | [攻击、技能、死亡] | [与玩家音效区分，略微靠后] |
| UI | [按钮点击、菜单过渡、通知] | [干净、细微，重复播放也不烦人] |
| Environment | [环境循环、天气、物体] | [沉浸、分层、具空间感] |
| Feedback | [受到伤害、拾取物品、升级] | [清晰、令人满足、不易疲劳] |

### Audio Feedback Priority
当多个声音竞争时，此优先级决定播放什么：
1. 玩家受伤 / 关键警告（始终可听见）
2. 玩家动作（攻击、技能）
3. 敌人动作（优先附近敌人）
4. UI 反馈
5. 环境 / 氛围

### SFX Rules
- [关于重复的规则，例如「每分钟播放超过 3 次的音效需要 3 种以上变体」]
- [关于空间音频的规则，例如「所有玩法音效必须是 3D 定位，UI 音效为 2D」]
- [关于闪避（ducking）的规则，例如「玩家受击音效会把其他所有音效压低 3dB，持续 200ms」]
- [关于响应时间的规则，例如「动作音效必须在动作发生后的 1 帧内触发」]

---

## Mixing

### Mix Bus Structure
| Bus | Content | Target Level |
| ---- | ---- | ---- |
| Master | Everything | 0 dB |
| Music | All music tracks | [target dBFS] |
| SFX | All sound effects | [target dBFS] |
| Dialogue | All voice/narration | [target dBFS] |
| UI | All interface sounds | [target dBFS] |
| Ambient | Environment loops | [target dBFS] |

### Mixing Rules
- 对话始终优先——对话期间压低音乐和音效
- 音乐应被感受到，而不是占据主导——如果玩家在音乐中听不清音效，说明音乐太响
- 主输出绝不能削波——在主总线上使用限制器
- 所有音量都必须可由玩家按总线调节
- 默认混音在扬声器和耳机上都应听起来良好

### Dynamic Range
- [指定响度目标，例如「目标 -14 LUFS 积分响度，-1 dBTP 真峰值」]
- [指定压缩策略，例如「音效总线轻度压缩，音乐不压缩」]

---

## Technical Specifications

### Format Requirements
| Type | Format | Sample Rate | Bit Depth | Notes |
| ---- | ---- | ---- | ---- | ---- |
| Music | [OGG/WAV] | [44.1/48 kHz] | [16/24 bit] | [从磁盘流式播放] |
| SFX | [WAV/OGG] | [44.1/48 kHz] | [16 bit] | [加载到内存] |
| Ambient | [OGG] | [44.1 kHz] | [16 bit] | [流式播放，可循环] |
| Dialogue | [OGG/WAV] | [44.1 kHz] | [16 bit] | [流式播放] |

### Naming Convention
`[category]_[subcategory]_[name]_[variation].ext`
- Example: `sfx_weapon_sword_swing_01.wav`
- Example: `music_exploration_forest_loop.ogg`
- Example: `amb_environment_cave_drip_loop.ogg`

### Memory Budget
- 音频内存总量：[目标，例如 128 MB]
- 音效池：[目标]
- 音乐流式缓冲：[目标]
- 语音流式缓冲：[目标]

---

## Accessibility

- 所有关键音频提示都必须有视觉替代方案（字幕、屏幕闪光、图标）
- 为听障玩家提供单声道音频选项
- 所有总线都有独立音量控制
- 可选项：禁用突发巨响
- 所有对话都支持字幕，并标明说话者
