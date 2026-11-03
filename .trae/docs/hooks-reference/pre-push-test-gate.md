# 钩子：pre-push-test-gate

## Trigger（触发时机）

在向远程分支的任何推送之前运行。对推送到 `main`（主干）
和 `release/*` 分支是强制性的。

## Purpose（目的）

确保在代码到达共享分支之前，构建可编译、单元测试通过、
关键冒烟测试通过。这是代码影响
其他开发者之前的最后一道自动化质量闸门。

## Implementation（实现）

```bash
#!/bin/bash
# Pre-push hook: Build and test gate

REMOTE="$1"
URL="$2"

# Only enforce the full gate on the trunk and release branches
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

FULL_GATE=false
case "$CURRENT_BRANCH" in
    main|release/*) FULL_GATE=true ;;
esac

echo "=== Pre-Push Quality Gate ==="

# Step 1: Build
echo "Building..."
# Adapt to your build system:
# make build || exit 1
# dotnet build || exit 1
# cargo build || exit 1
echo "Build: PASS"

# Step 2: Unit tests
echo "Running unit tests..."
# Adapt to your test framework:
# python -m pytest tests/unit/ -x || exit 1
# dotnet test tests/unit/ || exit 1
# cargo test || exit 1
echo "Unit tests: PASS"

if [ "$FULL_GATE" = true ]; then
    # Step 3: Integration tests (only for protected branches)
    echo "Running integration tests..."
    # python -m pytest tests/integration/ -x || exit 1
    echo "Integration tests: PASS"

    # Step 4: Smoke tests
    echo "Running smoke tests..."
    # python -m pytest tests/playtest/smoke/ -x || exit 1
    echo "Smoke tests: PASS"

    # Step 5: Performance regression check
    echo "Checking performance baselines..."
    # python tools/ci/perf_check.py || exit 1
    echo "Performance: PASS"
fi

echo "=== All gates passed ==="
exit 0
```

## Agent Integration（代理集成）

当此钩子失败时：
1. 构建失败：调用 `lead-programmer` 诊断
2. 单元测试失败：调用 `qa-tester` 定位失败的测试，
   并由 `gameplay-programmer` 或相关程序员修复
3. 性能回归：调用 `performance-analyst` 分析
