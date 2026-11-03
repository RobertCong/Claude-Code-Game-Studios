# Active Session State — [project or branch]

<!--
  本文件如何运作。编辑前请先阅读。

  本文件有两个区域，二者不可互换：

    1. 下方的 CHECKPOINT 区域（STATUS + CHECKPOINT 块）是机器读取的部分。
       session-start.sh 会将其逐字显示在上下文中，因此它在构造上是有界的：
       保持在约 25 行以内。每次更新时它都会被覆盖，绝不追加。

    2. `<!-- /CHECKPOINT -->` 之后的所有内容是自由的叙事，供人以及需要细节的
       回归 agent 使用。没有任何钩子会注入它，因此它可以增长——但见下方的轮转。

  为何要拆分：一个只追加的文件同时承担两项职责会无限增长，而每个消费者
  随后读取的切片各不相同：顶部、底部，或一个没人写入的块。它们之所以不一致，
  是因为没有可供达成一致的契约。有了命名的区域，每个消费者读取的便是同一部分。

  轮转（ROTATION）。当下方叙事超过约 200 行时，将其移到
  `production/session-logs/` 并重新开始：
      bash .trae/scripts/rotate-session-state.sh
  什么都不会丢失——而且提交历史已经记录了叙事中重复的大部分内容。
-->

<!-- STATUS -->
Epic:
Feature:
Task:
<!-- /STATUS -->

<!-- CHECKPOINT -->
**Updated:** [YYYY-MM-DD]
**Branch:** `[branch]`
**Current task:** [一行——当前正在做什么]
**Next step:** [一行——紧接着的下一步动作，具体到可冷启动继续]
**Blocked on:** [一行，或 `nothing`]
**Files in progress:** [路径，逗号分隔，或 `none`]
**Run result:** [`/dev-story` 将其 `Run result:` 行逐字写在此处，供 `/story-done` 读取；其他写入者不要写这一行]
**Open questions:** [每行一个，或 `none`]
<!-- /CHECKPOINT -->

---

## Notes

[自由格式。决策及其理由、尝试过并否决的方案、重建代价高昂的背景。
不供机器读取——为冷启动接手的人或 agent 而写。]

<!--
  字段说明

  STATUS 块
    驱动状态行面包屑（`Combat System > Melee > Hitboxes`），且仅在
    Production / Polish / Release 阶段。三个字段都是可选的——
    某项不适用时留空，无活跃焦点时三者全部留空。不要删除标记本身——
    保留它们以便将来接入 Trae 的状态展示或手工读取。

  CHECKPOINT 块
    恢复载荷。当上一次会话留下了状态时，`session-start.sh` 会显示它，压缩后
    也会再次显示（那时 SessionStart 也会运行）。
    它只读取这个区域，别的什么都不读，这正是叙事无论多长、成本都保持固定的原因。

    保持 `Branch` 为最新。本文件不会被提交，因此切换分支时它仍留在原处；
    session-start.sh 会将 `Branch` 与你当前所在分支比较，不一致时追加一行。

    请写得让冷启动的读者无需阅读其他内容即可继续。「Current
    task: fixing the thing」毫无用处；「Current task: adding wall-jump to
    player_movement.gd」则不然。
-->
