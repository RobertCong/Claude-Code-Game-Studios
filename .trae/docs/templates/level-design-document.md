# Level: [Level Name]

## Quick Reference

- **Area/Region**: [在游戏世界中的位置]
- **Type**: [Combat / Exploration / Puzzle / Hub / Boss / Mixed]
- **Estimated Play Time**: [X-Y 分钟]
- **Difficulty**: [1-10 相对量表]
- **Prerequisite**: [玩家必须完成什么才能到达此关卡]
- **Status**: [Concept | Layout | Graybox | Art Pass | Polish | Final]

## Narrative Context

- **Story Moment**: [本关卡位于叙事弧线的何处]
- **Narrative Purpose**: [本关卡承载的哪个故事节拍]
- **Emotional Target**: [玩家在此关卡中应有的感受]
- **Lore Discoveries**: [玩家可在此发现的世界观内容]

## Layout

### Overview Map

```
[ASCII diagram of the level layout. Use these symbols:]
[S] = Start point
[E] = Exit/end point
[C] = Combat encounter
[P] = Puzzle
[R] = Reward/loot
[!] = Story beat
[?] = Secret/optional
[>] = One-way passage
[=] = Two-way passage
[@] = NPC
[B] = Boss encounter
```

### Critical Path

[贯穿关卡的必经路线，逐步说明。]

1. 玩家从 [S] 进入
2. [路径上发生之事的描述]
3. 玩家从 [E] 离开

### Optional Paths

| Path | Access Requirement | Reward | Discovery Hint |
|------|-------------------|--------|---------------|

### Points of Interest

| Location | Type | Description | Purpose |
|----------|------|-------------|---------|

## Encounters

### Combat Encounters

| ID | Position | Enemy Composition | Difficulty | Arena Notes |
|----|----------|------------------|-----------|-------------|
| E-01 | [Map ref] | [2x Grunt, 1x Ranged] | 3/10 | 开阔区域，两翼有掩体 |
| E-02 | [Map ref] | [1x Elite, 3x Grunt] | 5/10 | 狭窄走廊，无退路 |

### Non-Combat Encounters

| ID | Position | Type | Description | Solution Hint |
|----|----------|------|-------------|---------------|

## Pacing Chart

```
Intensity
10 |                              *
 8 |                         *   * *
 6 |            *  *        * * *   *
 4 |     *  *  * ** *   *  *
 2 | * ** ** *        * * *          *
 0 |S-----------------------------------------E
     [Start]    [Mid]              [Climax] [Exit]
```

[描述预期的节奏：高峰、低谷、休息点分别在哪里？]

## Audio Direction

| Zone/Moment | Music Track | Ambience | Key SFX |
|-------------|------------|----------|---------|
| [Entry] | [Track] | [环境音] | [开门声] |
| [Combat] | [战斗音乐] | [压低的环境音] | [战斗音效] |
| [Post-combat] | [平静过渡] | [回归环境音] | |

## Visual Direction

- **Lighting**: [主光、补光、环境光的描述]
- **Color Palette**: [主导颜色及原因]
- **Mood Board References**: [视觉参考的描述]
- **Landmarks**: [可见的导航辅助物及其位置]
- **Sight Lines**: [玩家从关键位置应看到什么]

## Collectibles and Secrets

| Item | Location | Visibility | Hint | Required For |
|------|----------|-----------|------|-------------|

## Technical Notes

- **Estimated Object Count**: [N]
- **Streaming Zones**: [在何处切分关卡以进行流式加载]
- **Performance Concerns**: [任何已知的高负载区域]
- **Required Systems**: [此关卡中启用哪些游戏系统]
