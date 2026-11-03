# 钩子：pre-commit-code-quality

## Trigger（触发时机）

在任何修改代码根目录下文件的提交之前运行——`src/`
（Godot）、`Assets/`（Unity）或 `Source/`（Unreal）；参见
`.trae/docs/code-root-resolution.md`。

## Purpose（目的）

在代码进入版本控制之前强制执行编码规范。捕获风格
违规、缺失的文档、过于复杂的方法，以及本应
数据驱动却硬编码的值。

## Implementation（实现）

```bash
#!/bin/bash
# Pre-commit hook: Code quality checks
# Adapt the specific checks to your language and tooling

# The code root depends on the engine; resolve it the way the shipped commit
# check does. An unresolved root is reported, never guessed as src/.
. "$(git rev-parse --show-toplevel)/.trae/hooks/yaml-helper.sh"
CODE_ROOT=$(resolve_code_root | cut -f1)
if [ -z "$CODE_ROOT" ]; then
    echo "SKIPPED: no code root (set engine.name in project.yaml) — code checks did not run."
    exit 0
fi

CODE_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "^$CODE_ROOT/")

EXIT_CODE=0

if [ -n "$CODE_FILES" ]; then
    for file in $CODE_FILES; do
        # Check for hardcoded magic numbers in gameplay code
        if [[ "$file" == */[Gg]ameplay/* ]]; then
            # Look for numeric literals that are likely balance values
            # Adjust the pattern for your language
            if grep -nE '(damage|health|speed|rate|chance|cost|duration)[[:space:]]*[:=][[:space:]]*[0-9]+' "$file"; then
                echo "WARNING: $file may contain hardcoded gameplay values. Use data files."
                # Warning only, not blocking
            fi
        fi

        # Check for TODO/FIXME without assignee
        if grep -nE '(TODO|FIXME|HACK)[^(]' "$file"; then
            echo "WARNING: $file has TODO/FIXME without owner tag. Use TODO(name) format."
        fi

        # Run language-specific linter (uncomment appropriate line)
        # For GDScript: gdlint "$file" || EXIT_CODE=1
        # For C#: dotnet format --check "$file" || EXIT_CODE=1
        # For C++: clang-format --dry-run -Werror "$file" || EXIT_CODE=1
    done

    # Run unit tests for modified systems
    # Uncomment and adapt for your test framework
    # python -m pytest tests/unit/ -x --quiet || EXIT_CODE=1
fi

exit $EXIT_CODE
```

## Agent Integration（代理集成）

当此钩子失败时：
1. 风格违规：用你的格式化工具自动修复，或调用 `lead-programmer`
2. 硬编码值：调用 `gameplay-programmer` 将这些值外置
3. 测试失败：调用 `qa-tester` 诊断，调用 `gameplay-programmer` 修复
