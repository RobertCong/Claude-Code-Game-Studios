#!/bin/bash

# --- work from the project root ----------------------------------------------
# Mirrors the other hooks: a cwd that is a project root wins, then
# TRAE_PROJECT_DIR, then this script's own location.
if [ -f "project.yaml" ] || { [ -d ".trae" ] && [ "${PWD##*/}" != ".trae" ]; }; then
  CCGS_ROOT="$PWD"
elif [ -n "${TRAE_PROJECT_DIR:-}" ] && [ -d "${TRAE_PROJECT_DIR}" ] && case "${TRAE_PROJECT_DIR%/}" in */.trae|*\\.trae) false ;; *) true ;; esac; then
  CCGS_ROOT="$TRAE_PROJECT_DIR"
else
  CCGS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
fi
[ -n "$CCGS_ROOT" ] && cd "$CCGS_ROOT" 2>/dev/null || true

# Trae PreToolUse hook: enforce the deny list that used to live in the
# Claude Code project settings. Trae has no project-scoped permission file, so
# the list is kept in .trae/hooks/deny-rules.json and evaluated here before a
# RunCommand executes.
#
# Input schema (PreToolUse for RunCommand):
# { "tool_name": "RunCommand", "tool_input": { "command": "..." } }
#
# Exit behavior: always 0; the JSON permissionDecision does the blocking.

INPUT=$(cat)

case "$INPUT" in
  *'"tool_input"'*'"command"'*) ;;
  *) exit 0 ;;
esac

PYBIN=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' >/dev/null 2>&1; then
      PYBIN="$candidate"; break
    fi
  fi
done
if [ -z "$PYBIN" ]; then
  # Do not block every command when the interpreter is unavailable.
  printf '%s\n' "Deny guard skipped: python 3 not found." >&2
  exit 0
fi

PAYLOAD="$INPUT" "$PYBIN" - "$CCGS_ROOT/.trae/hooks/deny-rules.json" <<'PYEOF'
import json
import os
import re
import sys

try:
    payload = json.loads(os.environ["PAYLOAD"])
    rules = json.load(open(sys.argv[1], encoding="utf-8")).get("deny", [])
except Exception:
    sys.exit(0)

command = (payload.get("tool_input") or {}).get("command") or ""
if not command:
    sys.exit(0)


def to_regex(pattern):
    if pattern.startswith("Bash(") and pattern.endswith(")"):
        pattern = pattern[5:-1]
    elif pattern.startswith("PowerShell(") and pattern.endswith(")"):
        pattern = pattern[11:-1]
    # Claude permission syntax: `*` is a wildcard, everything else literal.
    return re.compile(re.escape(pattern).replace(r"\*", ".*"))


for raw in rules:
    try:
        if to_regex(raw).search(command):
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": "Blocked by project safety policy: " + raw,
                }
            }, ensure_ascii=False))
            break
    except re.error:
        continue
PYEOF
