#!/usr/bin/env bash
set -euo pipefail

# Harness Engineering — Agent-First Knowledge Base Bootstrap
# Usage: bootstrap.sh --target <repo-root> [--name <project>] [--description <desc>] [--base-dir <dir>] [--stack <stack>] [--domains <domains>]

# Defaults
TARGET_DIR="."
PROJECT_NAME="Project"
DESCRIPTION="[One-liner description — fill per project]"
BASE_DIR="docs"
STACK=""
DOMAINS="| — | — | — | — |"
DATE=$(date +%Y-%m-%d)

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)     TARGET_DIR="$2"; shift 2 ;;
    --name)       PROJECT_NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --base-dir)   BASE_DIR="$2"; shift 2 ;;
    --stack)      STACK="$2"; shift 2 ;;
    --domains)    DOMAINS="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: bootstrap.sh --target <repo-root> [--name <project>] [--description <desc>] [--base-dir <dir>] [--stack <stack>] [--domains <domains>]"
      exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)
TEMPLATE_DIR="$(cd "$(dirname "$0")/../assets/templates" && pwd)"

created=0
skipped=0

# Helper: create file from template with substitutions
create_from_template() {
  local template="$1"
  local dest="$2"

  if [[ -f "$dest" ]]; then
    echo "  SKIP  $dest (exists)"
    ((skipped++)) || true
    return
  fi

  mkdir -p "$(dirname "$dest")"
  # Use env vars + perl for safe substitution (handles pipes, special chars)
  HE_PROJECT_NAME="$PROJECT_NAME" \
  HE_DESCRIPTION="$DESCRIPTION" \
  HE_BASE_DIR="$BASE_DIR" \
  HE_STACK="$STACK" \
  HE_DOMAINS="$DOMAINS" \
  HE_DATE="$DATE" \
  perl -pe '
    s/\{\{PROJECT_NAME\}\}/$ENV{HE_PROJECT_NAME}/g;
    s/\{\{DESCRIPTION\}\}/$ENV{HE_DESCRIPTION}/g;
    s/\{\{BASE_DIR\}\}/$ENV{HE_BASE_DIR}/g;
    s/\{\{STACK\}\}/$ENV{HE_STACK}/g;
    s/\{\{DOMAINS\}\}/$ENV{HE_DOMAINS}/g;
    s/\{\{DATE\}\}/$ENV{HE_DATE}/g;
  ' "$template" > "$dest"
  echo "  CREATE $dest"
  ((created++)) || true
}

# Helper: create empty file if missing
ensure_file() {
  local dest="$1"
  if [[ -f "$dest" ]]; then
    echo "  SKIP  $dest (exists)"
    ((skipped++)) || true
    return
  fi
  mkdir -p "$(dirname "$dest")"
  touch "$dest"
  echo "  CREATE $dest"
  ((created++)) || true
}

echo "=== Harness Engineering Bootstrap ==="
echo "  Target:  $TARGET_DIR"
echo "  Name:    $PROJECT_NAME"
echo "  Base:    $BASE_DIR"
echo ""

# --- Directory structure ---
echo "--- Directories ---"
dirs=(
  "${BASE_DIR}/design-docs"
  "${BASE_DIR}/exec-plans"
  "${BASE_DIR}/plans/complete"
  "${BASE_DIR}/product-specs"
  "${BASE_DIR}/references"
  "${BASE_DIR}/generated"
  "scripts/harness"
)
for d in "${dirs[@]}"; do
  full="${TARGET_DIR}/${d}"
  if [[ -d "$full" ]]; then
    echo "  SKIP  $d/ (exists)"
  else
    mkdir -p "$full"
    echo "  CREATE $d/"
  fi
done

# --- .gitkeep files ---
echo ""
echo "--- Gitkeep files ---"
gitkeep_dirs=(
  "${BASE_DIR}/exec-plans"
  "${BASE_DIR}/plans"
  "${BASE_DIR}/plans/complete"
  "${BASE_DIR}/product-specs"
  "${BASE_DIR}/references"
  "${BASE_DIR}/generated"
)
for d in "${gitkeep_dirs[@]}"; do
  ensure_file "${TARGET_DIR}/${d}/.gitkeep"
done

# --- Root files from templates ---
echo ""
echo "--- Root files ---"
create_from_template "$TEMPLATE_DIR/AGENTS.md.tmpl"    "${TARGET_DIR}/AGENTS.md"
create_from_template "$TEMPLATE_DIR/CLAUDE.md.tmpl"     "${TARGET_DIR}/CLAUDE.md"
create_from_template "$TEMPLATE_DIR/ARCHITECTURE.md.tmpl" "${TARGET_DIR}/ARCHITECTURE.md"

# --- Docs files from templates ---
echo ""
echo "--- Knowledge base files ---"
create_from_template "$TEMPLATE_DIR/design-docs-index.md.tmpl"   "${TARGET_DIR}/${BASE_DIR}/design-docs/index.md"
create_from_template "$TEMPLATE_DIR/core-beliefs.md.tmpl"        "${TARGET_DIR}/${BASE_DIR}/design-docs/core-beliefs.md"
create_from_template "$TEMPLATE_DIR/product-specs-index.md.tmpl" "${TARGET_DIR}/${BASE_DIR}/product-specs/index.md"
create_from_template "$TEMPLATE_DIR/golden-principles.md.tmpl"   "${TARGET_DIR}/${BASE_DIR}/golden-principles.md"
create_from_template "$TEMPLATE_DIR/quality-score.md.tmpl"       "${TARGET_DIR}/${BASE_DIR}/quality-score.md"
create_from_template "$TEMPLATE_DIR/tech-debt-tracker.md.tmpl"   "${TARGET_DIR}/${BASE_DIR}/tech-debt-tracker.md"
create_from_template "$TEMPLATE_DIR/DESIGN.md.tmpl"              "${TARGET_DIR}/${BASE_DIR}/DESIGN.md"
create_from_template "$TEMPLATE_DIR/PLANS.md.tmpl"               "${TARGET_DIR}/${BASE_DIR}/PLANS.md"
create_from_template "$TEMPLATE_DIR/PRODUCT_SENSE.md.tmpl"       "${TARGET_DIR}/${BASE_DIR}/PRODUCT_SENSE.md"
create_from_template "$TEMPLATE_DIR/RELIABILITY.md.tmpl"         "${TARGET_DIR}/${BASE_DIR}/RELIABILITY.md"
create_from_template "$TEMPLATE_DIR/SECURITY.md.tmpl"            "${TARGET_DIR}/${BASE_DIR}/SECURITY.md"
create_from_template "$TEMPLATE_DIR/scripts-harness-knowledge-check.sh.tmpl" "${TARGET_DIR}/scripts/harness/knowledge-check.sh"

chmod +x "${TARGET_DIR}/scripts/harness/knowledge-check.sh" 2>/dev/null || true

# --- Claude settings ---
echo ""
echo "--- Claude settings ---"
CLAUDE_DIR="${TARGET_DIR}/.claude"
mkdir -p "$CLAUDE_DIR"

if [[ ! -f "${CLAUDE_DIR}/settings.json" ]]; then
  cat > "${CLAUDE_DIR}/settings.json" <<SETTINGS_EOF
{
  "planDirectory": "${BASE_DIR}/plans"
}
SETTINGS_EOF
  echo "  CREATE .claude/settings.json"
  ((created++)) || true
else
  echo "  SKIP  .claude/settings.json (exists)"
  ((skipped++)) || true
fi

# --- Summary ---
echo ""
echo "=== Done ==="
echo "  Created: $created files"
echo "  Skipped: $skipped files (already existed)"
echo ""
echo "Next steps:"
echo "  1. Customize ARCHITECTURE.md with your domains"
echo "  2. Fill PRODUCT_SENSE.md with user context"
echo "  3. Create your first plan in ${BASE_DIR}/plans/"
