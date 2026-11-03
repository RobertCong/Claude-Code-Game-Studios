# 安装要求

此模板需要安装若干工具才能获得完整功能。
钩子在缺少可选工具时仍可继续运行，只失去该工具驱动的检查。必需项
则是必需的：没有 Python 3，每项设置都会回退到默认值，且暂存数据 JSON 的提交会被阻塞；没有 Bash，任何钩子
都无法运行。

## 必需

| 工具 | 用途 | 安装 |
| ---- | ---- | ---- |
| **Git** | 版本控制、分支管理 | [git-scm.com](https://git-scm.com/) |
| **Trae CN** | AI agent IDE | [docs.trae.cn](https://docs.trae.cn/)。需要支持 Skills / Subagents / Hooks 的版本 |
| **Python 3** | 每个技能和钩子都通过它读取 `project.yaml` | [python.org](https://www.python.org/)。没有它，每项设置都会静默回退到默认值，且暂存数据 JSON 的提交会因为无法验证而被阻塞 |
| **Bash** | 运行每个钩子 | macOS 和 Linux 内置。在 Windows 上，安装 [Git for Windows](https://git-scm.com/downloads/win)，并在 Trae 中把默认终端设为 Git Bash |

## 推荐

| 工具 | 使用方 | 用途 | 安装 |
| ---- | ---- | ---- | ---- |
| **jq** | 钩子（14 个中的 9 个） | 提交/推送/资源钩子中的 JSON 解析 | 见下文 |

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

## Trae 中的一次性设置

1. **设置 > Beta > Subagents**：打开「启用 Subagents 目录」，否则 `.trae/agents/` 不会被加载。
2. **设置 > Hooks**：选择「项目」，启用 `.trae/hooks.json`。
3. **设置 > Hooks > 运行方式**：选择「本地自动运行」，否则沙箱可能阻止钩子写入 `production/session-state/`。
4. **设置 > 规则**：确认「将 AGENTS.md 包含在上下文中」已打开。

## 平台说明

### Windows
- Git for Windows 包含 **Git Bash**，它提供 `.trae/hooks.json` 中所有钩子使用的 `bash` 命令。
- 在 Trae 中把默认终端配置为 Git Bash；若 Trae 找不到 `bash`，钩子会静默失效。
- `notify.sh` 使用 PowerShell 显示通知。

### macOS / Linux
- Bash 原生可用。
- 通过你的包管理器安装 `jq`，以获得完整的钩子支持。

## 验证安装

运行以下命令检查前置条件：

```bash
git --version          # Should show git version
bash --version         # Should show bash version
jq --version           # Should show jq version (optional)
python3 --version      # Required: Python 3 (python or py also work)
```

## 缺少可选工具时会发生什么

| 缺少的工具 | 影响 |
| ---- | ---- |
| **jq** | 没有损失：每个钩子都会回退到 `grep` 读取其 JSON 输入。jq 只在处理异常输入时更稳健。 |
| **Python 3** | 不可选（见 "必需"）。每项设置都会回退到默认值，因为 `project.yaml` 通过 Python 读取；资源钩子会跳过 JSON 验证并说明这一点；暂存数据 JSON 的提交会被阻塞。 |
| **两者都缺** | 与缺少 Python 时相同。 |

## 可选性能设置

CCGS 有意不为以下设置提供**任何**值。每一项的最佳值都取决于你的机器、你的套餐以及你的工作方式，因此在这里提交一个值就会成为每个用户
不知不觉继承的猜测。请在 Trae 的用户设置中调整，这些设置不随项目仓库分发。

| 设置 | 作用 | 何时更改 |
| ---- | ---- | ---- |
| 上下文压缩阈值 | 上下文达到多满时 Trae 会压缩它。 | 如果压缩总是在任务中途让你措手不及，请调低；如果你更愿意减少压缩频率并保留更多历史，请调高。 |
| 模型选择 | Agent 与子代理使用哪个模型。 | 子代理默认继承当前会话模型；需要更强推理时在 Trae 中切换。 |
| 技能列表展示 | 技能描述占用的上下文。 | CCGS 提供 74 个技能，列表并不小；如果你想要更多工作空间，可在 Trae 中收紧技能描述展示。 |

## 安全与审批

Trae 没有项目级的 `settings.json` 权限模式。本仓库的行为由两层保证：

- **`.trae/hooks/deny-rules.json` + `validate-deny.sh`**：在每次 RunCommand 前
  执行 130 条 deny 规则（force push、`rm -rf`、读取 `.env` 等）。
- **协作协议**：写文件前的「我可以把它写入 [filepath] 吗？」是模型必须遵守的
  指令；在 Trae 的自动模式或减少询问模式下，它不是硬停止点。

请从**项目根目录**打开 Trae。只从 `design/`、`src/` 或 `Assets/` 等子目录打开时，
`.trae/rules`、`.trae/hooks.json` 和先询问模式都不会加载。

## 推荐 IDE

- **Trae CN**（本模板的默认环境）
- 任何能编辑 Markdown / Bash 的编辑器，用于手工维护技能与钩子
