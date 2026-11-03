# CLAUDE.local.md 模板

将此文件复制到项目根目录并命名为 `CLAUDE.local.md`，用于个人覆盖配置。该文件已被 gitignore，不会被提交。

```markdown
# Personal Preferences

## Model Preferences
- Prefer Opus for complex design tasks
- Use Haiku for quick lookups and simple edits

## Workflow Preferences
- Always run tests after code changes
- Compact context proactively at 60% usage
- Use /clear between unrelated tasks

## Local Environment
- Python command: python (or py / python3)
- Shell: Git Bash on Windows
- IDE: VS Code with Claude Code extension

## Communication Style
- Keep responses concise
- Show file paths in all code references
- Explain architectural decisions briefly

## Personal Shortcuts
- When I say "review", run /code-review on the last changed files
- When I say "status", show git status + sprint progress
```

## 设置

1. 将此模板复制到项目根目录：`cp .claude/docs/CLAUDE-local-template.md CLAUDE.local.md`
2. 按你的偏好进行编辑
3. 确认 `CLAUDE.local.md` 已列入 `.gitignore`（Claude Code 会从项目根目录读取它）
