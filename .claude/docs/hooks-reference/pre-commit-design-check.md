# 钩子：pre-commit-design-check

## Trigger（触发时机）

在任何修改 `design/` 或 `assets/data/` 中文件的提交之前运行。

## Purpose（目的）

确保设计文档与游戏数据文件在进入版本控制之前保持一致性
与完整性。捕获缺失的章节、
断裂的交叉引用和无效数据，防止其扩散。

## Implementation（实现）

```bash
#!/bin/bash
# Pre-commit hook: Design document and game data validation
# Place in .git/hooks/pre-commit or configure via your hook manager

DESIGN_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^design/')
DATA_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^assets/data/')

EXIT_CODE=0

# Check design documents for required sections
if [ -n "$DESIGN_FILES" ]; then
    for file in $DESIGN_FILES; do
        if [[ "$file" == *.md ]]; then
            # Check for required sections in GDD documents
            if [[ "$file" == design/gdd/* ]]; then
                for section in "Overview" "Detailed" "Edge Cases" "Dependencies" "Acceptance Criteria"; do
                    if ! grep -qi "$section" "$file"; then
                        echo "ERROR: $file missing required section: $section"
                        EXIT_CODE=1
                    fi
                done
            fi
        fi
    done
fi

# Validate JSON data files
if [ -n "$DATA_FILES" ]; then
    for file in $DATA_FILES; do
        if [[ "$file" == *.json ]]; then
            # Find a working Python command
            PYTHON_CMD=""
            for cmd in python python3 py; do
                if command -v "$cmd" >/dev/null 2>&1; then
                    PYTHON_CMD="$cmd"
                    break
                fi
            done
            if [ -n "$PYTHON_CMD" ] && ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                echo "ERROR: $file is not valid JSON"
                EXIT_CODE=1
            fi
        fi
    done
fi

exit $EXIT_CODE
```

## Agent Integration（代理集成）

当此钩子失败时，提交者应当：
1. 设计章节缺失：调用 `game-designer` 代理补全
   该文档
2. JSON 无效：调用 `tools-programmer` 代理，或手动修复
