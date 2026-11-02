# Godot 引擎 — 版本参考

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7 |
| **Installed at pin time** | NOT DETERMINED — `/setup-engine` §3 会探测已安装的编辑器并把结果记录在此。 |
| **Release Date** | 2026 年 6 月（最新补丁：4.7.2，2026 年 8 月） |
| **Project Pinned** | 2026-10-17 |
| **Last Docs Verified** | 2026-10-17（发布时间线与 4.7 变更）；2026-02-12（4.4-4.6 内容） |
| **LLM Knowledge Cutoff** | 2025 年 5 月 |

## 知识缺口警告

LLM 的训练数据可能只覆盖到 Godot ~4.3。4.5、4.6 和 4.7 版本是在知识截止日期之后发布的，引入了模型**并不**了解的重大变更；4.4 在截止日期前不久发布，覆盖可能较为单薄。在建议任何 Godot API 调用前，务必交叉核对本目录。

## 已安装版本缺口警告

上面的警告是单向的——它描述的是**模型**所知少于本固定版本的情况。反向缺口真实存在，并且是 `/setup-engine` §3 有意造成的（“固定较新版本，之后再升级”）：本参考资料可能**超前于已安装的编辑器**，代理正确地引用它，却输出了无法在本地编译的 API。**在信任任何带版本限定的说法之前，先检查上方的 `Installed at pin time`**——`NOT DETERMINED` 意味着缺口未知，而不是不存在。

## 截止日之后的版本时间线

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.5 | 2025 年 9 月 | HIGH | 无障碍（AccessKit）、可变参数、@abstract、着色器烘焙器、SMAA |
| 4.6 | 2026 年 1 月 | HIGH | Jolt 成为默认、辉光重做、Windows 上 D3D12 成为默认、IK 恢复 |
| 4.7 | 2026 年 6 月 | HIGH | AreaLight3D、HDR 输出、Asset Store 取代 Asset Library、VirtualJoystick、Jolt 软体与世界边界变更、类型化返回覆盖 |

## 截止日之前

4.4（2025 年 3 月，Jolt 选项、FileAccess 返回类型）早于 2025 年 5 月的截止日期；知识缺口警告对它仍然适用。

日期取自 https://github.com/godotengine/godot/releases，核对于 2026-10-17：
4.4 于 2025-03-03，4.5 于 2025-09-15，4.6 于 2026-01-26，4.7 于 2026-06-18，4.7.2 于
2026-08-18。迁移指南与发布说明：`breaking-changes.md` § Sources。
