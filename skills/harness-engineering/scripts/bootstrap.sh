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
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../assets/templates"
ASSET_DIR="${SCRIPT_DIR}/../assets"

created=0
skipped=0
deployed=0

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

# Helper: deploy tooling file (always overwrites — these are managed, not user content)
deploy_tool() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  DEPLOY $dest"
  ((deployed++)) || true
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
  "${BASE_DIR}/plans/in-progress"
  "${BASE_DIR}/plans/complete"
  "${BASE_DIR}/plan-details"
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
  "${BASE_DIR}/plans"
  "${BASE_DIR}/plans/in-progress"
  "${BASE_DIR}/plans/complete"
  "${BASE_DIR}/plan-details"
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
  "planDirectory": "${BASE_DIR}/plans",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/lint-on-save.sh",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/shaping-ripple.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  echo "  CREATE .claude/settings.json"
  ((created++)) || true
else
  # Merge hooks config if settings.json exists but has no hooks
  if ! grep -q '"hooks"' "${CLAUDE_DIR}/settings.json" 2>/dev/null; then
    # Insert hooks before the closing brace
    python3 -c "
import json, sys
with open('${CLAUDE_DIR}/settings.json') as f:
    cfg = json.load(f)
cfg['hooks'] = {
    'PostToolUse': [{
        'matcher': 'Edit|Write',
        'hooks': [{
            'type': 'command',
            'command': '\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/lint-on-save.sh',
            'timeout': 30
        }, {
            'type': 'command',
            'command': '\"\$CLAUDE_PROJECT_DIR\"/.claude/hooks/shaping-ripple.sh',
            'timeout': 5
        }]
    }]
}
with open('${CLAUDE_DIR}/settings.json', 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo "  PATCH  .claude/settings.json (added hooks)" || echo "  SKIP  .claude/settings.json (merge failed, add hooks manually)"
  else
    echo "  SKIP  .claude/settings.json (exists with hooks)"
  fi
  ((skipped++)) || true
fi

# --- Agent tooling (always deployed — these are managed, not user content) ---
echo ""
echo "--- Agent tooling ---"

# Slash commands
deploy_tool "${ASSET_DIR}/commands/harness-init.md"       "${CLAUDE_DIR}/commands/harness-init.md"
deploy_tool "${ASSET_DIR}/commands/harness-onboard.md"    "${CLAUDE_DIR}/commands/harness-onboard.md"
deploy_tool "${ASSET_DIR}/commands/harness-standards.md"  "${CLAUDE_DIR}/commands/harness-standards.md"
deploy_tool "${ASSET_DIR}/commands/harness-eslint.md"     "${CLAUDE_DIR}/commands/harness-eslint.md"
deploy_tool "${ASSET_DIR}/commands/harness-shape.md"     "${CLAUDE_DIR}/commands/harness-shape.md"

# Hooks
deploy_tool "${ASSET_DIR}/hooks/lint-on-save.sh"          "${CLAUDE_DIR}/hooks/lint-on-save.sh"
chmod +x "${CLAUDE_DIR}/hooks/lint-on-save.sh"
deploy_tool "${ASSET_DIR}/hooks/shaping-ripple.sh"        "${CLAUDE_DIR}/hooks/shaping-ripple.sh"
chmod +x "${CLAUDE_DIR}/hooks/shaping-ripple.sh"

# Companion skills
deploy_tool "${ASSET_DIR}/skills/git-worktree/SKILL.md"   "${CLAUDE_DIR}/skills/git-worktree/SKILL.md"
deploy_tool "${ASSET_DIR}/skills/git-worktree/scripts/worktree-manager.sh" "${CLAUDE_DIR}/skills/git-worktree/scripts/worktree-manager.sh"
chmod +x "${CLAUDE_DIR}/skills/git-worktree/scripts/worktree-manager.sh"

# --- Summary ---
echo ""
echo "=== Done ==="
echo "  Created:  $created files"
echo "  Deployed: $deployed tooling files"
echo "  Skipped:  $skipped files (already existed)"
echo ""
echo "Next steps:"
echo "  1. Run /harness-shape to fill standards with real project context"
echo "  2. Run /harness-eslint to add mechanical enforcement (JS/TS repos)"
echo "  3. Create your first plan in ${BASE_DIR}/plans/"
echo ""
echo "Available commands:"
echo "  /harness-shape      — Fill knowledge base with real project context (run this next)"
echo "  /harness-eslint     — Add ESLint enforcement (JS/TS repos — run after shape)"
echo "  /harness-onboard    — Audit existing repo + generate gap-fill plan"
echo "  /harness-standards  — Alias for /harness-shape"
echo ""
echo "Recommended skill installs:"
echo "  npx skills add https://github.com/vercel-labs/agent-browser --skill agent-browser"
echo "  npx skills add https://github.com/mrgoonie/claudekit-skills --skill chrome-devtools"
