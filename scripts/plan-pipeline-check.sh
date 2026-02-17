#!/bin/bash
set -euo pipefail

# Stop hook: verify plan files are in the correct pipeline stage.
# Pipeline: docs/plans/ (draft) → in-progress/ (executing) → complete/ (done)
#
# Blocks stop if a plan in the draft root was modified during this session
# but not moved to in-progress/ — a common oversight.

HOOK_INPUT=$(cat)
CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
PROJECT_DIR="${CWD:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"

# No plans directory → nothing to check
if [[ ! -d "$PROJECT_DIR/docs/plans" ]]; then
  exit 0
fi

cd "$PROJECT_DIR"

# Bail if not a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Collect plan files changed since last commit (staged, unstaged, untracked)
CHANGED=$(
  {
    git diff --name-only 2>/dev/null || true
    git diff --cached --name-only 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | grep -E '^docs/plans/[^/]+\.md$' | sort -u || true
)

# Only flag draft-root plans (not in-progress/ or complete/ subdirs)
# The grep above already filters to docs/plans/<file>.md (no subdirs)
if [[ -z "$CHANGED" ]]; then
  exit 0
fi

# Check if any of these draft plans look like they should be in-progress
# (i.e., content was modified, not just created as an empty template)
NEEDS_MOVE=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$PROJECT_DIR/$file" ]] && continue
  # If the file has more than the template frontmatter, it's being worked on
  lines=$(wc -l < "$PROJECT_DIR/$file" | tr -d ' ')
  if [[ "$lines" -gt 20 ]]; then
    NEEDS_MOVE="${NEEDS_MOVE}  - ${file}\n"
  fi
done <<< "$CHANGED"

if [[ -z "$NEEDS_MOVE" ]]; then
  exit 0
fi

# Block: plans in draft root appear to be actively worked on
REASON=$(printf "Plan pipeline check: these plans in docs/plans/ (draft) appear to be actively worked on. Move them to docs/plans/in-progress/ before stopping:\n%b" "$NEEDS_MOVE")

jq -n \
  --arg reason "$REASON" \
  --arg msg "Plans were modified but not moved through the pipeline. Move active plans to docs/plans/in-progress/." \
  '{
    "decision": "block",
    "reason": $reason,
    "systemMessage": $msg
  }'
