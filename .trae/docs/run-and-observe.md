# 运行并观察（Run and Observe）

任何关闭「会改变玩家可见内容」的用户故事的技能共用的流程。由 `/dev-story`
（Phase 6）和 `/story-done`（Phase 3）使用。
**解析检查不等于运行，没人看过的用户故事不能关闭。**
本文件说明如何去看。

`.trae/docs/coding-standards.md` 是「用户故事需要什么证据」的权威依据。
本文件是「如何产出其中视觉部分」的流程。

## 规则

每个改变玩家可观察内容的用户故事都必须在**关闭前启动并观察**，观察结果是一张
**保留的截图**，存放在 `production/qa/evidence/`。编译只能证明代码能加载。测试只能
证明逻辑。两者都不能证明文字是否放得进框里。

代理能看图片：Trae 的 `Read` 工具可以渲染 PNG。整个问题在于如何无人值守地
从引擎里拿到一张图片，而每个受支持的引擎都有原生方式。

## 流程

1. **以窗口模式启动**，使用固定分辨率 — 除非项目另有说明，使用 `1280x720` —
   通过 `project.yaml` 中的 `commands.run` 执行。绝不要使用 headless / batch /
   null-RHI 标志：它们存在的目的就是*跳过*渲染。
2. **直接启动到用户故事所涉及的场景或地图。** 一个只能通过主菜单和三次点击才能到达
   的功能，就是本次运行到不了的功能。编写用户故事时应让其界面能通过启动参数到达
   （场景路径、地图 URL、`--scene` 标志）。
3. **等待、截图、退出。** 让引擎渲染真实帧 — 60 帧是安全的底线 — 截取一张，然后退出。
   各引擎的具体机制见下文。
4. **查看。** 用 `Read` 读取 PNG。将屏幕内容与验收标准对比。文字被裁切、面板溢出、
   元素缺失、颜色错误 — 这些都是缺陷，而这一步是唯一能发现它们的步骤。
5. **保留。** 直接截图到该用户故事的证据文件夹，这样无需再复制：
   `mkdir -p production/qa/evidence/[story-slug]`，然后把
   `production/qa/evidence/[story-slug]/[NN]-[what-it-shows].png` 作为截图路径传入
   （Godot 会自己在文件名后加帧号）。`[story-slug]` 是用户故事文件名去掉 `.md`：
   例如 `production/epics/core/story-003-light-pickup.md` 对应
   `story-003-light-pickup`。在证据文档中引用该图片。截了又丢弃的截图只是断言，
   不是证据。同时在旁边为它证明的文件打上戳记：
   `bash .trae/scripts/review-receipts.sh hash <each file the story changed> > production/qa/evidence/[story-slug]/stamp.txt`。
   之后若其中一个文件被修改，证据就会显示得比代码更旧。
6. 在实现总结中**报告**一行 `Run result:` — 词汇见下文。

## 各引擎做法

| `engine.name` | 启动 | 截图 | 输出位置 | 绝不要使用 | 需要的脚手架 |
|---|---|---|---|---|---|
| Godot 4 | `godot --path . --windowed --resolution 1280x720 <scene>.tscn` | `--write-movie <path>.png --quit-after <N>` | 给定路径旁，`<name>00000000.png` … | `--headless` | **无** |
| Unity 6 | built player `.exe -screen-width 1280 -screen-height 720 -screen-fullscreen 0 --scene <Name>` | 由引导脚本调用 `ScreenCapture.CaptureScreenshot(<abs path>)` | 你传入的绝对路径 | `-batchmode`、`-nographics` | 一个 MonoBehaviour |
| Unreal 5 | `MSYS_NO_PATHCONV=1 "<UE root>/Engine/Binaries/Win64/UnrealEditor.exe" "$(pwd -W 2>/dev/null || pwd)/<Game>.uproject" <MapURL> -game -windowed -ResX=1280 -ResY=720` | `HighResShot 1280x720 filename=<abs path>` 控制台命令 | 你传入的路径（否则为 `Saved/Screenshots/WindowsEditor/`） | `-nullrhi`、单独使用 `-unattended` | 一个 actor 或 `-ExecCmds` |

### Godot 4 — 零脚手架

```
godot --path . --windowed --resolution 1280x720 --write-movie shots/shop.png --quit-after 60 res://scenes/shop.tscn
```

`--write-movie` 是 Movie Maker 模式：目标为 `.png` 时它会写出一组帧序列，
`--quit-after` 设定帧数。文件名包含 **8** 位补零数字 — 从 `shop00000000.png`
到 `shop00000059.png` — 所以取最后一张；同目录还会生成 `shop.wav`。`--fixed-fps`
会自动应用。场景路径是位置参数；任何 `.tscn` 都可直接启动，这正是满足第 2 步的
方式。帧按项目的视口尺寸录制（`display/window/size/viewport_width` 和 `_height`，
未设置时为 1152x648），而不是按 `--resolution`，后者只决定窗口大小；日志中的
`recording movie in <W>×<H>` 行会说明实际尺寸。下面的触发式截图备选方案则按窗口
尺寸保存。

触发式截图备选方案，用于场景启动无法到达的状态：一个 autoload，在满足所需条件时
执行 `await RenderingServer.frame_post_draw`，然后
`get_viewport().get_texture().get_image().save_png(path)`，再
`get_tree().quit()`。

### Unity 6 — 一个 MonoBehaviour

`-batchmode` 不显示任何内容，因此运行方式要么是**构建后的播放器**，要么是编辑器
的播放模式。播放器是更稳妥的路径：

```
Builds/Win64/Game.exe -screen-width 1280 -screen-height 720 -screen-fullscreen 0 --scene Shop --screenshot C:/abs/path/shop.png --after 60
```

`-screen-*` 是 Unity 自带的播放器参数。`--scene`、`--screenshot` 和
`--after` 是**你自己定义的**，由下面的脚本读取。模板不附带该脚本：当 Unity
用户故事首次需要截图时，`/dev-story` 会请求将它逐字写入
`Assets/Scripts/ScreenshotOnArg.cs`。它无需编辑场景 — 它会自行启动，且除非播放器
带 `--screenshot` 启动，否则什么都不做：

```csharp
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

// Run-and-observe capture: Game.exe --scene Shop --screenshot C:/abs/shop.png --after 60
public class ScreenshotOnArg : MonoBehaviour
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Boot()
    {
        if (Arg("--screenshot") == null) return;
        var go = new GameObject(nameof(ScreenshotOnArg));
        DontDestroyOnLoad(go);
        go.AddComponent<ScreenshotOnArg>();
    }

    static string Arg(string name)
    {
        var args = System.Environment.GetCommandLineArgs();
        for (int i = 0; i < args.Length - 1; i++)
            if (args[i] == name) return args[i + 1];
        return null;
    }

    IEnumerator Start()
    {
        var scene = Arg("--scene");
        if (!string.IsNullOrEmpty(scene)) yield return SceneManager.LoadSceneAsync(scene);
        int after = int.TryParse(Arg("--after"), out var n) ? n : 60;
        for (int i = 0; i < after; i++) yield return null;
        yield return new WaitForEndOfFrame();
        ScreenCapture.CaptureScreenshot(Arg("--screenshot"));
        for (int i = 0; i < 3; i++) yield return null;   // the file is written after the frame
        Application.Quit();
    }
}
```

传入**绝对**路径 — 编辑器与播放器的相对基准不同。`--scene` 必须在构建设置中。
先构建播放器在小项目上要花 1–3 分钟；这就是查看你要发布的东西而非编辑器的代价。

### Unreal 5 — 一个 actor，或 `-ExecCmds`

```
MSYS_NO_PATHCONV=1 timeout 60 "<UE root>/Engine/Binaries/Win64/UnrealEditor.exe" "$(pwd -W 2>/dev/null || pwd)/Game.uproject" /Game/Maps/Shop -game -windowed -ResX=1280 -ResY=720
```

这一行是 Windows 的。在 Linux 上，同样的参数交给
`"<UE root>/Engine/Binaries/Linux/UnrealEditor"`（无需 `MSYS_NO_PATHCONV`）；
在 macOS 上 Epic 只记录了 `UnrealEditor.app` 包，因此请从编辑器或你已确认的命令
运行该地图（见 `docs/engine-reference/unreal/current-best-practices.md`，
"Command Line" 一节）。

`-game` 以独立模式运行，不带编辑器 UI。地图是**紧跟在 `.uproject` 之后的位置参数
URL** — 不是控制台命令。**在 Windows 上必须加 `MSYS_NO_PATHCONV=1` 前缀：**
Trae 在 Git Bash 中运行命令，Git Bash 会把任何以 `/` 开头的参数改写为
Windows 路径，因此 `/Game/Maps/Shop` 到达引擎时变成
`C:/Program Files/Git/Game/Maps/Shop`，游戏会停在没人能看到的 "map not found"
对话框上。备选方案是通过 `-ExecCmds="open /Game/Maps/Shop"` 传入地图，它不会被
转换。**项目路径必须是绝对路径** — 设置了 `MSYS_NO_PATHCONV` 时，只有
`$(pwd -W 2>/dev/null || pwd)` 能给出绝对路径：相对路径 `Game.uproject` 会找不到，
启动会永远等在错误对话框上（已在 5.7 上验证）。这一行没有 `-unattended`，所以任何
失败都会变成没人点击的对话框：始终在 `timeout` 下运行它。截图使用 `HighResShot`
控制台命令，可以由开发用 actor 触发（在 BeginPlay 后延迟一小段时间执行
`Execute Console Command`，然后 `quit`），也可以从启动行触发：

```
-ExecCmds="HighResShot 1280x720 filename=C:/abs/path/shop.png"
```

尺寸（或诸如 `2` 的倍数）必须放在 `filename=` **之前**：单独
`HighResShot filename=…` 会因输入非法被拒绝且不保存任何内容。没有 `filename=` 时
文件会落在 `Saved/Screenshots/WindowsEditor/` 中。**不要把 `Quit` 放进同一个
`-ExecCmds` 列表** — 它会在同一帧执行，早于文件写入，磁盘上不会留下任何东西。
`-ExecCmds` 没有延迟，因此让 `timeout` 结束启动（退出码 124 是预期结果），并检查
文件是否存在；开发用 actor 则可以改为等待一秒再 `quit`。蓝图节点
`Take High Res Screenshot` 仅限编辑器使用，在 `-game` 启动中无效。

### 任何引擎 — 操作系统截图备选方案

在 Windows 上，使用 PowerShell 与 `System.Drawing` 可以把屏幕 `CopyFromScreen`
到 bitmap 并保存。它需要可见桌面且游戏窗口在最前，而且截取的是屏幕上的一切 —
无法指定「商店面板」。仅在引擎原生方式不可用时使用，并在运行结果中说明。没有
显示器的 Linux CI 需要在启动命令前加 `xvfb-run`；`--headless` 不是替代方案。

## `Run result:` 行

在实现总结中，恰好使用以下三种形式之一：

- **`Run result: OBSERVED — <what was on screen, one line>`** 并附上保留路径。
  *"商店面板正常渲染，全部 6 个槽位都在框内，720p 下价格可读 —
  `production/qa/evidence/shop-panel/01-shop-open.png`。"*
- **`Run result: NOT VERIFIED — <reason>`**。找不到引擎可执行文件、
  `commands.run` 未设置、启动崩溃、截图为空。在 Visual/Feel 和 UI 用户故事的
  默认闸门级别下，这是**阻塞项**，不是备注 — 没人看过的用户故事不能关闭。在显式
  `testing.strict.visual`/`.ui: false` 下，它会被记录，用户故事可以带着
  `## Completion Notes` 中的缺口关闭。
- **`Run result: N/A — <reason>`**，仅用于确实没有任何可观察内容的用户故事 —
  纯数据迁移、没有界面表现的存档格式变更。要说明原因。"这是 Logic 用户故事"不是
  理由：伤害公式在屏幕某处也有数字。

在 `qa.level: minimal` 下，运行**不会**被豁免。测试在那里会被豁免；查看不会。
它是流水线中最便宜的验证，也是缺失后会导致「测试充分但看起来不对」的游戏的那一项。

## 静态截图能显示与不能显示的内容

**能：** 布局、裁切、溢出、存在性、对齐、颜色、可读性、是否出现了正确的界面。
已发布的视觉缺陷实际上就藏在这里。

**不能：** 时序、响应性、手感、动画曲线、音频同步 — 即 Visual/Feel 中「感觉」的
那一半。Godot 的 `--write-movie` 能给出帧序列；其他引擎需要操作系统视频录制。
手感仍由人工在 `/team-qa` 中检查。要说明截图覆盖了哪一半。

## 到达目标状态

标题画面的截图无法验证深度 2 的任何内容。要么直接启动场景/地图（Godot 场景参数、
Unreal 地图 URL、Unity `--scene`），要么给引导脚本一个设置状态的调试参数
（`--gold=500 --depth=2`）。编写用户故事时应让其界面能通过这些方式之一到达；
无法到达的用户故事每次都会被标记为 `NOT VERIFIED`。

## 查找引擎

三个引擎在 Windows 上都不会安装到 `PATH`。`project.yaml` 中的 `engine.path` 是
编辑器所在位置；在得出「这台机器上没有引擎」之前先解析它。路径不存在不等于引擎
不存在。

---

*上述命令在 Windows 上运行过：Godot 4.6.1（gdUnit4 6.1.3），Godot 部分又在 4.7.2
（gdUnit4 6.2.2）上运行过，Unity 6000.3.23f1 和 Unreal Engine 5.7；Unreal 的
Linux 与 macOS 说明来自 Epic 的文档。`docs/engine-reference/<engine>/` 是本项目
锁定的权威依据；在采信此处任何带版本限定的说法之前，先查它。*
