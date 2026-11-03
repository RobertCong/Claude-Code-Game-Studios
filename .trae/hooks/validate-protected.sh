#!/bin/bash

# --- work from the project root ----------------------------------------------
if [ -f "project.yaml" ] || { [ -d ".trae" ] && [ "${PWD##*/}" != ".trae" ]; }; then
  CCGS_ROOT="$PWD"
elif [ -n "${TRAE_PROJECT_DIR:-}" ] && [ -d "${TRAE_PROJECT_DIR}" ] && case "${TRAE_PROJECT_DIR%/}" in */.trae|*\\.trae) false ;; *) true ;; esac; then
  CCGS_ROOT="$TRAE_PROJECT_DIR"
else
  CCGS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
fi
[ -n "$CCGS_ROOT" ] && cd "$CCGS_ROOT" 2>/dev/null || true

# Trae PreToolUse hook: enforce the Read/Edit deny rules that Claude Code used
# to take from permissions.deny. Trae has no project permission file, so the
# protected paths are checked here.
#
# Rules:
#   Read       -> deny **/.env*
#   Write/Edit -> deny **/.env*, **/*.uasset, **/*.umap
#
# Exit behavior: always 0; the JSON permissionDecision does the blocking.

INPUT=$(cat)

PYBIN=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' >/dev/null 2>&1; then
      PYBIN="$candidate"; break
    fi
  fi
done
if [ -z "$PYBIN" ]; then
  printf '%s\n' "Protected-path guard skipped: python 3 not found." >&2
  exit 0
fi

PAYLOAD="$INPUT" "$PYBIN" - <<'PYEOF'
import json
import os
import sys

try:
    payload = json.loads(os.environ["PAYLOAD"])
except Exception:
    sys.exit(0)

tool = payload.get("tool_name") or ""
path = (payload.get("tool_input") or {}).get("file_path") or ""
if not path:
    sys.exit(0)

name = os.path.basename(path)
reason = ""

if tool == "Read":
    if name.startswith(".env"):
        reason = "Reading .env files is blocked by project safety policy"
elif tool in ("Write", "Edit"):
    if name.startswith(".env"):
        reason = "Writing .env files is blocked by project safety policy"
    elif name.endswith((".uasset", ".umap")):
        reason = "Editing Unreal binary assets is blocked by project safety policy"

if reason:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason + ": " + path,
        }
    }, ensure_ascii=False))
PYEOF
