#!/usr/bin/env bash
# Harness Engineering — Lint on Save Hook
#
# Runs after Edit/Write to give the agent immediate lint feedback.
# Reads tool input from stdin (JSON), extracts file_path, runs the
# appropriate linter on ONLY that file.
#
# Output is truncated to avoid flooding context (max 15 lines / 1500 chars).
#
# Exit 0 = success (lint passed or no linter for this file type)
# Exit 2 = blocked (lint failed — stderr becomes feedback to Claude)

set -euo pipefail

MAX_LINES=15
MAX_CHARS=1500

# Read JSON from stdin.
INPUT=$(cat)

# Extract file path from tool input.
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', ''))
" 2>/dev/null || true)

# No file path = nothing to lint.
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Truncate lint output to keep context small.
truncate_output() {
  local input="$1"
  local total_lines
  total_lines=$(echo "$input" | wc -l | tr -d ' ')

  local truncated
  truncated=$(echo "$input" | head -n "$MAX_LINES" | cut -c1-"$MAX_CHARS")

  if [[ "$total_lines" -gt "$MAX_LINES" ]]; then
    local remaining=$((total_lines - MAX_LINES))
    truncated+=$'\n'"... ($remaining more lines truncated)"
  fi

  echo "$truncated"
}

report_failure() {
  local result="$1"
  local file="$2"
  local short
  short=$(truncate_output "$result")

  echo "$short" >&2
  echo "" >&2
  echo "Lint failed on $(basename "$file"). Fix the issues above." >&2
  exit 2
}

EXT="${FILE_PATH##*.}"

case "$EXT" in
  js|cjs|mjs|ts|tsx|jsx)
    # JS/TS: run ESLint on this file only.
    if command -v npx >/dev/null 2>&1 && [[ -f "eslint.config.cjs" || -f "eslint.config.js" || -f "eslint.config.mjs" || -f ".eslintrc.json" || -f ".eslintrc.js" || -f ".eslintrc.yml" ]]; then
      RESULT=$(npx eslint --no-error-on-unmatched-pattern --format compact "$FILE_PATH" 2>&1) || report_failure "$RESULT" "$FILE_PATH"
    fi
    ;;
  py)
    # Python: run ruff on this file only.
    if command -v ruff >/dev/null 2>&1; then
      RESULT=$(ruff check "$FILE_PATH" 2>&1) || report_failure "$RESULT" "$FILE_PATH"
    fi
    ;;
  sh|bash)
    # Shell: run shellcheck on this file only.
    if command -v shellcheck >/dev/null 2>&1; then
      RESULT=$(shellcheck "$FILE_PATH" 2>&1) || report_failure "$RESULT" "$FILE_PATH"
    fi
    ;;
  *)
    # No linter for this file type.
    ;;
esac

exit 0
