#!/usr/bin/env bash
# Harness Engineering — Lint on Save Hook
#
# Runs after Edit/Write to give the agent immediate lint feedback.
# Reads tool input from stdin (JSON), extracts file_path, runs the
# appropriate linter based on file extension.
#
# Exit 0 = success (lint passed or no linter for this file type)
# Exit 2 = blocked (lint failed — stderr becomes feedback to Claude)

set -euo pipefail

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

EXT="${FILE_PATH##*.}"

case "$EXT" in
  js|cjs|mjs|ts|tsx|jsx)
    # JS/TS: run ESLint if available.
    if command -v npx >/dev/null 2>&1 && [[ -f "eslint.config.cjs" || -f "eslint.config.js" || -f "eslint.config.mjs" || -f ".eslintrc.json" || -f ".eslintrc.js" || -f ".eslintrc.yml" ]]; then
      RESULT=$(npx eslint --no-error-on-unmatched-pattern --format compact "$FILE_PATH" 2>&1) || {
        echo "$RESULT" >&2
        echo "" >&2
        echo "Lint failed on $FILE_PATH. Fix the issues above before continuing." >&2
        exit 2
      }
    fi
    ;;
  py)
    # Python: run ruff if available.
    if command -v ruff >/dev/null 2>&1; then
      RESULT=$(ruff check "$FILE_PATH" 2>&1) || {
        echo "$RESULT" >&2
        echo "" >&2
        echo "Lint failed on $FILE_PATH. Fix the issues above before continuing." >&2
        exit 2
      }
    fi
    ;;
  sh|bash)
    # Shell: run shellcheck if available.
    if command -v shellcheck >/dev/null 2>&1; then
      RESULT=$(shellcheck "$FILE_PATH" 2>&1) || {
        echo "$RESULT" >&2
        echo "" >&2
        echo "Lint failed on $FILE_PATH. Fix the issues above before continuing." >&2
        exit 2
      }
    fi
    ;;
  *)
    # No linter for this file type — pass through.
    ;;
esac

exit 0
