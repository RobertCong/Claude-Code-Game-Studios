# 安装要求

此模板需要安装若干工具才能获得完整功能。
钩子在缺少可选工具时仍可继续运行，只失去该工具驱动的检查。必需项
则是必需的：没有 Python 3，每项设置都会回退到默认值，且暂存数据 JSON 的提交会被阻塞；没有 Bash，任何钩子
都无法运行。

## 必需

| 工具 | 用途 | 安装 |
| ---- | ---- | ---- |
| **Git** | 版本控制、分支管理 | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | AI agent CLI | 原生安装器：`curl -fsSL https://claude.ai/install.sh \| bash`（macOS、Linux、WSL）或 `irm https://claude.ai/install.ps1 \| iex`（Windows PowerShell）。npm 也可用：`npm install -g @anthropic-ai/claude-code`（Node.js 22+）。见 [code.claude.com/docs/en/setup](https://code.claude.com/docs/en/setup) |
| **Python 3** | 每个技能和钩子都通过它读取 `project.yaml` | [python.org](https://www.python.org/)。没有它，每项设置都会静默回退到默认值，且暂存数据 JSON 的提交会因为无法验证而被阻塞 |
| **Bash** | 运行每个钩子 | macOS 和 Linux 内置。在 Windows 上，安装 [Git for Windows](https://git-scm.com/downloads/win)——Claude Code 没有它也能运行，但不会有任何 CCGS 钩子运行 |

## 推荐

| 工具 | 使用方 | 用途 | 安装 |
| ---- | ---- | ---- | ---- |
| **jq** | 钩子（12 个中的 8 个） | 提交/推送/资源/agent 钩子中的 JSON 解析 | 见下文 |

### 安装 jq

**Windows**（任选其一）：
```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**：
```
brew install jq
```

**Linux**：
```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## 平台说明

### Windows
- Git for Windows 包含 **Git Bash**，它提供 `settings.json` 中所有钩子
  使用的 `bash` 命令
- 如果 Claude Code 找不到 Git Bash，请在设置的 `env` 块中把
  `CLAUDE_CODE_GIT_BASH_PATH` 设置为其 `bash.exe`（例如
  JSON 中的 `C:\\Program Files\\Git\\bin\\bash.exe`）
- 钩子使用 `bash .claude/hooks/[name].sh`——这在 Windows 上可行，因为
  Claude Code 通过一个能找到 `bash.exe` 的 shell 调用命令

### macOS / Linux
- Bash 原生可用
- 通过你的包管理器安装 `jq`，以获得完整的钩子支持

## 验证安装

运行以下命令检查前置条件：

```bash
git --version          # Should show git version
bash --version         # Should show bash version
jq --version           # Should show jq version (optional)
python --version       # Required: Python 3 (python3 or py also work)
```

## 缺少可选工具时会发生什么

| 缺少的工具 | 影响 |
| ---- | ---- |
| **jq** | 没有损失：每个钩子都会回退到 `grep` 读取其 JSON 输入。jq 只在处理异常输入时更稳健。 |
| **Python 3** | 不可选（见 "必需"）。每项设置都会回退到默认值，因为 `project.yaml` 通过 Python 读取；资源钩子会跳过 JSON 验证并说明这一点；暂存数据 JSON 的提交会被阻塞。 |
| **两者都缺** | 与缺少 Python 时相同。 |

## 可选性能设置

CCGS 有意不为以下设置提供**任何**值。每一项的最佳值都取决于你的机器、你的 Claude 套餐以及你的工作方式，因此在这里提交一个值就会成为每个用户
不知不觉继承的猜测。在 `.claude/settings.local.json` 中设置你需要的项，该文件被 git 忽略，且仅属于你。

| 设置 | 作用 | 何时更改 |
| ---- | ---- | ---- |
| `promptCacheTtl` | 主对话的提示缓存存活多久。 | 如果你在长会话中间有间断，请调高它；缓存在中断后仍存活可避免重新发送上下文。 |
| `subagentPromptCacheTtl` | 同上，适用于子代理和其他对话外请求。 | 对于像此项目这样的 49 个 agent 项目，`team-*` 技能会反复生成，值得调高。 |
| `autoCompactWindow` | 上下文达到多满时 Claude Code 会压缩它。 | 如果压缩总是在任务中途让你措手不及，请调低；如果你更愿意减少压缩频率并保留更多历史，请调高。 |
| `skillListingBudgetFraction` | 技能列表可占用的上下文比例。 | CCGS 提供 74 个技能，所以列表并不小。如果你想要更多工作空间，请调低；`skillListingMaxDescChars` 则改为裁剪每个描述。 |

`sandbox.enabled` 会把 shell 命令与你的文件系统和网络隔离。它
值得开启，但仅在 **macOS、Linux 和 WSL2** 上运行——它在原生
Windows 上不可用，而 Windows 是 CCGS 的主要平台。

### CCGS 确实提供的一项设置

`permissions.defaultMode` 在 `.claude/settings.json` 中被设置为 `default`，
这是有意为之。**在项目根目录**启动的终端会话随后会以
Claude Code 的先询问模式启动，因此文件编辑会等待你的批准，即使你
自己的配置设置了 `acceptEdits` 或 `auto`。

它设置的是会话启动时所用的模式。它是兜底，而非保证，且
以下途径会绕过它：

- **在子文件夹中启动**，例如 `design/` 或代码根目录（`src/`、
  `Assets/` 或 `Source/`，取决于引擎）。Claude Code 只从启动时所在的文件夹加载
  `.claude/settings.json`，因此该会话
  没有此项目的任何钩子、拒绝规则或权限模式。请从根目录启动。
- **恢复会话。** 恢复的会话保持其结束时的模式。
- **会话期间切换**：Shift+Tab、回答 "Yes, and switch to auto
  mode"，或允许本次会话的所有编辑。
- **命令行上的 `claude --permission-mode auto`**。
- **VS Code 扩展**，它从不读取项目的 `.claude/settings.json`
  来获取对话启动时的模式。在你的 VS Code 用户设置中把 `claudeCode.initialPermissionMode`
  设置为 `default`，以获得相同行为。
- **桌面应用**，它会记住你上次为某个文件夹选择的模式，
  并改用该模式。

在任何无需询问就接受编辑的模式下，框架的 "May I write?" 是
对模型的指令，而不是停止点。

若要以其他模式启动终端会话，请在
`.claude/settings.local.json` 中设置 `permissions.defaultMode`，它具有更高优先级。终端会话接受其中除 `auto` 和 `bypassPermissions` 之外的任何模式。
请先理解你正在关闭什么。

## 推荐 IDE

Claude Code 可与任何编辑器配合使用，但该模板针对以下环境做了优化：
- **VS Code** 搭配 Claude Code 扩展
- **Cursor**（兼容 Claude Code）
- 基于终端的 Claude Code CLI
