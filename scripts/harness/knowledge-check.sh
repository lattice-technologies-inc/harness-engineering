#!/usr/bin/env bash
set -euo pipefail

# Harness Knowledge Base Checks
#
# Purpose: mechanically enforce the minimum scaffolding that keeps this repo legible to agents.
# Philosophy: enforce invariants, not implementations.
#
# Wire into CI with something like:
#   bash scripts/harness/knowledge-check.sh

BASE_DIR="docs"
MAX_AGENTS_LINES="${MAX_AGENTS_LINES:-160}"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

warn() {
  echo "WARN: $1" >&2
}

require_file() {
  local p="$1"
  [[ -f "$p" ]] || fail "Missing required file: $p"
}

require_dir() {
  local p="$1"
  [[ -d "$p" ]] || fail "Missing required directory: $p"
}

require_file "AGENTS.md"
require_file "ARCHITECTURE.md"
require_file "CLAUDE.md"

require_dir "$BASE_DIR"
require_dir "$BASE_DIR/plans"
require_dir "$BASE_DIR/plans/complete"
require_dir "$BASE_DIR/design-docs"
require_dir "$BASE_DIR/product-specs"

require_file "$BASE_DIR/golden-principles.md"
require_file "$BASE_DIR/quality-score.md"
require_file "$BASE_DIR/tech-debt-tracker.md"
require_file "$BASE_DIR/PLANS.md"
require_file "$BASE_DIR/PRODUCT_SENSE.md"
require_file "$BASE_DIR/RELIABILITY.md"
require_file "$BASE_DIR/SECURITY.md"

agents_lines=$(wc -l < AGENTS.md | tr -d ' ')
if [[ "$agents_lines" -gt "$MAX_AGENTS_LINES" ]]; then
  fail "AGENTS.md is too long ($agents_lines lines). Keep it a table of contents (<= $MAX_AGENTS_LINES)."
fi

if grep -nF "[One-liner description — fill per project]" AGENTS.md >/dev/null 2>&1; then
  warn "AGENTS.md still contains the one-liner placeholder. Fill it in (agents treat missing context as missing reality)."
fi

# Plan files must include a date (YYYY-MM-DD) in filename or heading.
# Check both active plans and completed plans.
plan_files_without_date=()
for plan_dir in "$BASE_DIR"/plans "$BASE_DIR"/plans/complete; do
  for plan in "$plan_dir"/*.md; do
    [[ -f "$plan" ]] || continue
    basename_plan=$(basename "$plan")
    [[ "$basename_plan" == "index.md" ]] && continue
    if ! echo "$basename_plan" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
      if ! head -n 5 "$plan" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
        plan_files_without_date+=("$plan")
      fi
    fi
  done
done
if [[ ${#plan_files_without_date[@]} -gt 0 ]]; then
  for p in "${plan_files_without_date[@]}"; do
    warn "Plan '$p' has no date (YYYY-MM-DD) in filename or heading. Plans must be dated for traceability."
  done
fi

if [[ -f ".claude/settings.json" ]]; then
  # Soft check: helpful remediation, but not all repos use this.
  if ! sed -nE 's/.*"planDirectory"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' .claude/settings.json | head -n 1 | grep -qE "^${BASE_DIR}/plans$"; then
    warn ".claude/settings.json planDirectory does not match ${BASE_DIR}/plans. If you changed base dir, regenerate or edit settings."
  fi
else
  warn "Missing .claude/settings.json (optional). If you use Claude plan tooling, set planDirectory to ${BASE_DIR}/plans."
fi

echo "OK: harness knowledge base checks passed"

