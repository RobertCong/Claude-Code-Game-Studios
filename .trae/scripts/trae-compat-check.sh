#!/usr/bin/env bash
# trae-compat-check.sh — observations for the Trae migration.
#
# Prints every place the framework still carries a construct that Trae does not
# execute the way Claude Code did. OBSERVATIONS, NEVER VERDICTS: each line is a
# place to inspect, not a failure, and the script always exits 0 once it ran.
#
# Usage: bash .trae/scripts/trae-compat-check.sh [--skill <name> | --agent <name>] [project-root]

set -u

SKILL_FILTER=""
AGENT_FILTER=""
ROOT_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --skill|--agent)
      [ $# -ge 2 ] || { echo "trae-compat-check: $1 needs a value" >&2; exit 2; }
      if [ "$1" = "--skill" ]; then SKILL_FILTER="$2"; else AGENT_FILTER="$2"; fi
      shift 2 ;;
    --skill=*) SKILL_FILTER="${1#--skill=}"; shift ;;
    --agent=*) AGENT_FILTER="${1#--agent=}"; shift ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) ROOT_ARG="$1"; shift ;;
  esac
done

if [ -n "$SKILL_FILTER" ] && [ -n "$AGENT_FILTER" ]; then
  echo "trae-compat-check: give --skill or --agent, not both" >&2
  exit 2
fi

if [ -n "$ROOT_ARG" ]; then
  ROOT="$ROOT_ARG"
else
  cd "$(dirname "$0")/../.." || { echo "trae-compat-check: cannot reach repo root" >&2; exit 1; }
  ROOT="$(pwd -W 2>/dev/null || pwd)"
fi

if [ ! -d "$ROOT/.trae" ]; then
  echo "trae-compat-check: no .trae folder under $ROOT" >&2
  exit 1
fi

PYBIN=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)' >/dev/null 2>&1; then
      PYBIN="$candidate"; break
    fi
  fi
done
if [ -z "$PYBIN" ]; then
  echo "trae-compat-check: no python 3 interpreter found (tried python3, python)" >&2
  exit 1
fi

"$PYBIN" - "$ROOT" "$SKILL_FILTER" "$AGENT_FILTER" <<'PYEOF'
import glob
import json
import os
import re
import sys

root, skill_filter, agent_filter = sys.argv[1:4]
trae = os.path.join(root, ".trae")
found = []
counts = {}


def add(category, path, line, detail):
    found.append((category, os.path.relpath(path, root).replace(os.sep, "/"), line, detail))
    counts[category] = counts.get(category, 0) + 1


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read().splitlines()
    except OSError:
        return []


def frontmatter(lines):
    if not lines or lines[0].strip() != "---":
        return []
    out = []
    for n in range(1, len(lines)):
        if lines[n].strip() == "---":
            return out
        m = re.match(r"^([A-Za-z][\w-]*):(.*)$", lines[n])
        if m:
            out.append((n + 1, m.group(1), m.group(2).strip()))
    return []


# --- skills -----------------------------------------------------------------
skill_paths = sorted(glob.glob(os.path.join(trae, "skills", "*", "SKILL.md")))
if skill_filter:
    skill_paths = [p for p in skill_paths if os.path.basename(os.path.dirname(p)) == skill_filter]

for path in skill_paths:
    lines = read(path)
    for n, key, _ in frontmatter(lines):
        if key in ("model", "allowed-tools"):
            add("frontmatter", path, n, key + " (Trae skill frontmatter does not use this field)")
    for n, line in enumerate(lines, start=1):
        if re.match(r"^[ \t]*!`", line):
            add("shell-lines", path, n, "!`cmd` prelude (Trae does not pre-execute it)")
        if "subagent_type" in line:
            add("subagents", path, n, "subagent_type (Trae dispatches by description)")
        for var in re.findall(r"\$\{(CLAUDE_[A-Z0-9_]+)\}", line):
            if var in ("CLAUDE_SKILL_DIR", "CLAUDE_SESSION_ID"):
                continue  # supported by the Trae skill runtime
            add("variables", path, n, "var:" + var + " (verify Trae support)")

# --- agents -----------------------------------------------------------------
agent_paths = sorted(glob.glob(os.path.join(trae, "agents", "*.md")))
if agent_filter:
    agent_paths = [p for p in agent_paths if os.path.basename(p)[:-3] == agent_filter]

for path in agent_paths:
    lines = read(path)
    for n, key, _ in frontmatter(lines):
        if key in ("model", "maxTurns", "memory", "skills", "isolation"):
            add("frontmatter", path, n, key + " (Trae subagent frontmatter does not support it)")
    for n, line in enumerate(lines, start=1):
        if "subagent_type" in line:
            add("subagents", path, n, "subagent_type (Trae dispatches by description)")

# --- rules ------------------------------------------------------------------
if not skill_filter and not agent_filter:
    for path in sorted(glob.glob(os.path.join(trae, "rules", "*.md"))):
        lines = read(path)
        for n, key, _ in frontmatter(lines):
            if key == "paths":
                add("rules", path, n, "paths (Trae uses globs)")

# --- hooks ------------------------------------------------------------------
if not skill_filter and not agent_filter:
    hooks_path = os.path.join(trae, "hooks.json")
    if os.path.isfile(hooks_path):
        lines = read(hooks_path)
        try:
            data = json.loads("\n".join(lines))
        except ValueError:
            data = {}
        for event, groups in (data.get("hooks") or {}).items():
            if event in ("SubagentStart", "SubagentStop"):
                add("hooks", hooks_path, 1, event + " (Trae does not support this event)")
            for group in groups if isinstance(groups, list) else []:
                matcher = (group.get("matcher") or "") if isinstance(group, dict) else ""
                if "Bash" in matcher or "PowerShell" in matcher:
                    add("hooks", hooks_path, 1, "matcher " + matcher + " (Trae uses RunCommand)")
        if "systemMessage" in "\n".join(lines):
            add("hooks", hooks_path, 1, "systemMessage (Trae ignores it)")

# --- legacy paths -----------------------------------------------------------
if not skill_filter and not agent_filter:
    for dirpath, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in {".git", "node_modules"}]
        for name in files:
            if not name.endswith((".md", ".sh", ".py", ".yaml", ".yml", ".json")):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root).replace(os.sep, "/")
            if rel in ("docs/unity-onboarding-cross-match.md", ".trae/scripts/trae-compat-check.sh"):
                continue
            for n, line in enumerate(read(path), start=1):
                if ".claude" in line:
                    add("legacy-paths", path, n, "'.claude' reference")

# --- output -----------------------------------------------------------------
print("ROOT: " + root)
print("FILES: skills=%d agents=%d" % (len(skill_paths), len(agent_paths)))
print("FOUND_LINES: %d" % len(found))
for category in sorted(counts):
    print("COUNT: %s hits=%d" % (category, counts[category]))
for category, path, line, detail in sorted(found):
    print("FOUND: %s %s:%d %s" % (category, path, line, detail))
if not skill_filter and not agent_filter:
    print("NOT FOUND: rules=0 hooks=0 legacy-paths=0" if not found else "NOT FOUND: (see COUNT lines)")
PYEOF
