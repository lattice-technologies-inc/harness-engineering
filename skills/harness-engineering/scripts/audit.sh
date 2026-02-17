#!/usr/bin/env bash
set -euo pipefail

# Harness Engineering — Existing Repo Audit
#
# Produces a concrete "Phase 0: Standards" onboarding plan for an existing repository.
# Usage:
#   bash audit.sh --target <repo-root> [--base-dir <dir>] [--write-plan] [--plan-path <path>]

TARGET_DIR="."
BASE_DIR=""
WRITE_PLAN=0
PLAN_PATH=""
DATE=$(date +%Y-%m-%d)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2 ;;
    --base-dir) BASE_DIR="$2"; shift 2 ;;
    --write-plan) WRITE_PLAN=1; shift 1 ;;
    --plan-path) PLAN_PATH="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: audit.sh --target <repo-root> [--base-dir <dir>] [--write-plan] [--plan-path <path>]"
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

if [[ ! -d "${TARGET_DIR}/.git" ]]; then
  echo "ERROR: ${TARGET_DIR} does not look like a git repository (.git missing)." >&2
  exit 1
fi

infer_base_dir_from_claude_settings() {
  local settings_path="${TARGET_DIR}/.claude/settings.json"
  if [[ ! -f "$settings_path" ]]; then
    return 0
  fi

  # Extract value of planDirectory and strip trailing "/plans" if present.
  local plan_dir
  plan_dir=$(
    sed -nE 's/.*"planDirectory"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$settings_path" | head -n 1
  )
  if [[ -n "$plan_dir" ]]; then
    plan_dir=${plan_dir%/plans}
    echo "$plan_dir"
  fi
}

if [[ -z "$BASE_DIR" ]]; then
  BASE_DIR=$(infer_base_dir_from_claude_settings || true)
fi
if [[ -z "$BASE_DIR" ]]; then
  BASE_DIR="docs"
fi

repo_name=$(basename "$TARGET_DIR")
git_remote=$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)
default_branch=$(git -C "$TARGET_DIR" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)

has_agents=0; [[ -f "${TARGET_DIR}/AGENTS.md" ]] && has_agents=1
has_arch=0; [[ -f "${TARGET_DIR}/ARCHITECTURE.md" ]] && has_arch=1
has_claude=0; [[ -f "${TARGET_DIR}/CLAUDE.md" ]] && has_claude=1
has_docs=0; [[ -d "${TARGET_DIR}/${BASE_DIR}" ]] && has_docs=1

# Prefer rg, fall back to grep.
has_rg=0
if command -v rg >/dev/null 2>&1; then
  has_rg=1
fi

file_has_pattern() {
  local pattern="$1"
  local path="$2"

  if [[ "$has_rg" -eq 1 ]]; then
    rg -n --fixed-strings "$pattern" "$path" >/dev/null 2>&1
  else
    grep -nF "$pattern" "$path" >/dev/null 2>&1
  fi
}

# Heuristic: detect placeholders that should be filled.
placeholders=()
if [[ -f "${TARGET_DIR}/AGENTS.md" ]] && file_has_pattern "[One-liner description — fill per project]" "${TARGET_DIR}/AGENTS.md"; then
  placeholders+=("AGENTS.md one-liner placeholder")
fi
if [[ -f "${TARGET_DIR}/ARCHITECTURE.md" ]] && file_has_pattern "| — | — | — | — |" "${TARGET_DIR}/ARCHITECTURE.md"; then
  placeholders+=("ARCHITECTURE.md domains table placeholder")
fi
if [[ -f "${TARGET_DIR}/${BASE_DIR}/PRODUCT_SENSE.md" ]] && file_has_pattern "[Fill per project" "${TARGET_DIR}/${BASE_DIR}/PRODUCT_SENSE.md"; then
  placeholders+=("PRODUCT_SENSE.md has unfilled placeholders")
fi
if [[ -f "${TARGET_DIR}/${BASE_DIR}/RELIABILITY.md" ]] && file_has_pattern "[Fill per project" "${TARGET_DIR}/${BASE_DIR}/RELIABILITY.md"; then
  placeholders+=("RELIABILITY.md has unfilled placeholders")
fi
if [[ -f "${TARGET_DIR}/${BASE_DIR}/SECURITY.md" ]] && file_has_pattern "[Fill per project" "${TARGET_DIR}/${BASE_DIR}/SECURITY.md"; then
  placeholders+=("SECURITY.md has unfilled placeholders")
fi
if [[ -f "${TARGET_DIR}/${BASE_DIR}/golden-principles.md" ]] && file_has_pattern "[Customize per project" "${TARGET_DIR}/${BASE_DIR}/golden-principles.md"; then
  placeholders+=("golden-principles.md has unfilled placeholders")
fi
if [[ -f "${TARGET_DIR}/${BASE_DIR}/quality-score.md" ]] && file_has_pattern "| — |" "${TARGET_DIR}/${BASE_DIR}/quality-score.md"; then
  placeholders+=("quality-score.md has unfilled grades")
fi

# Language sniff (top extensions).
ext_counts=$(
  find "$TARGET_DIR" -type f \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.next/*' \
    -not -path '*/coverage/*' \
    -not -path '*/vendor/*' \
    -print \
  | awk -F. '
      NF<2 { next }
      {
        ext=$NF
        gsub(/[^A-Za-z0-9]/, "", ext)
        if (length(ext)==0) next
        count[ext]++
      }
      END {
        for (e in count) printf "%s %d\n", e, count[e]
      }' \
  | sort -k2,2nr \
  | head -n 10 \
  | awk '{printf "- %s: %d\n", $1, $2}'
)

if [[ -z "$ext_counts" ]]; then
  ext_counts="- (no files detected or all excluded)"
fi

has_package_json=0; [[ -f "${TARGET_DIR}/package.json" ]] && has_package_json=1
has_pyproject=0; [[ -f "${TARGET_DIR}/pyproject.toml" ]] && has_pyproject=1
has_gemfile=0; [[ -f "${TARGET_DIR}/Gemfile" ]] && has_gemfile=1
has_go_mod=0; [[ -f "${TARGET_DIR}/go.mod" ]] && has_go_mod=1
has_cargo=0; [[ -f "${TARGET_DIR}/Cargo.toml" ]] && has_cargo=1

ci_signals=()
[[ -d "${TARGET_DIR}/.github/workflows" ]] && ci_signals+=(".github/workflows/")
[[ -f "${TARGET_DIR}/.gitlab-ci.yml" ]] && ci_signals+=(".gitlab-ci.yml")
[[ -f "${TARGET_DIR}/circleci/config.yml" ]] && ci_signals+=(".circleci/config.yml")

if [[ ${#ci_signals[@]} -eq 0 ]]; then
  ci_summary="- (no CI config detected)"
else
  ci_summary=$(printf "%s\n" "${ci_signals[@]}" | awk '{printf "- %s\n", $0}')
fi

# Agent tooling detection.
agent_tools=()
command -v agent-browser >/dev/null 2>&1 && agent_tools+=("agent-browser (headless browser automation)")
command -v playwriter >/dev/null 2>&1 && agent_tools+=("playwriter (user Chrome control)")
command -v peekaboo >/dev/null 2>&1 && agent_tools+=("peekaboo (macOS screenshot/click)")
command -v oracle >/dev/null 2>&1 || command -v oracle-browser >/dev/null 2>&1 && agent_tools+=("oracle (second-opinion from another model)")
command -v gh >/dev/null 2>&1 && agent_tools+=("gh (GitHub CLI)")

if [[ ${#agent_tools[@]} -eq 0 ]]; then
  agent_tools_summary="- (none detected)"
else
  agent_tools_summary=$(printf "%s\n" "${agent_tools[@]}" | awk '{printf "- %s\n", $0}')
fi

candidate_domains=$(
  # Prefer domain-y directories; this is intentionally heuristic.
  for root in src app apps packages services lib server backend frontend; do
    if [[ -d "${TARGET_DIR}/${root}" ]]; then
      find "${TARGET_DIR}/${root}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null
    fi
  done \
  | sed "s#^${TARGET_DIR}/##" \
  | sort -u \
  | head -n 20 \
  | awk '{printf "- %s/\n", $0}'
)

if [[ -z "$candidate_domains" ]]; then
  candidate_domains="- (no obvious domain directories detected)"
fi

plan_default_path="${TARGET_DIR}/${BASE_DIR}/plans/harness-onboard-existing-${DATE}.md"
if [[ -z "$PLAN_PATH" ]]; then
  PLAN_PATH="$plan_default_path"
fi

report_md=$(
  cat <<EOF
# Harness Onboarding Audit (Existing Repo)

- Date: ${DATE}
- Repo: ${repo_name}
- Remote: ${git_remote:-"(none)"}
- Default branch: ${default_branch:-"(unknown)"}
- Knowledge base base dir: ${BASE_DIR}

## Current State

- Has \`AGENTS.md\`: ${has_agents}
- Has \`ARCHITECTURE.md\`: ${has_arch}
- Has \`CLAUDE.md\`: ${has_claude}
- Has \`${BASE_DIR}/\`: ${has_docs}

## Detected Languages (Top Extensions)

${ext_counts}

## Build/Stack Signals

- package.json: ${has_package_json}
- pyproject.toml: ${has_pyproject}
- Gemfile: ${has_gemfile}
- go.mod: ${has_go_mod}
- Cargo.toml: ${has_cargo}

## CI Signals

${ci_summary}

## Agent Tooling (Available on PATH)

${agent_tools_summary}

## Candidate Domains (Heuristic)

${candidate_domains}

## Likely Missing / Needs Filling

EOF
)
report_md+=$'\n'

if [[ ${#placeholders[@]} -eq 0 ]]; then
  report_md+=$'\n- (no obvious placeholders detected)\n'
else
  for p in "${placeholders[@]}"; do
    report_md+=$"- ${p}"$'\n'
  done
fi

report_md+=$(
  cat <<'EOF'

## Recommended Phase 0 (Standards) Outputs

1. Update `AGENTS.md` one-liner so the repo has a clear purpose.
2. Fill `ARCHITECTURE.md` with real domains and boundaries (start with the candidate list above).
3. Fill `docs/PRODUCT_SENSE.md` with:
   - Primary user(s)
   - Problem(s) solved
   - Success metrics and non-goals
4. Decide and encode mechanical enforcement:
   - At minimum: CI checks for docs drift + file size policy + logging policy.
   - For JS/TS repos: consider ESLint rules as agent-readable remediation.
5. Create an onboarding plan and execute it; avoid ad-hoc "fix as we go".
6. Install missing agent tooling (see "Agent Tooling" above):
   - \`agent-browser\`: headless browser automation for UI validation (\`npm i -g agent-browser && agent-browser install\`)
   - \`gh\`: GitHub CLI for PR/issue management (\`brew install gh\`)

EOF
)

echo "$report_md"

if [[ "$WRITE_PLAN" -eq 0 ]]; then
  exit 0
fi

mkdir -p "$(dirname "$PLAN_PATH")"

cat > "$PLAN_PATH" <<EOF
# Onboard Existing Repo Into Harness Knowledge Base (${DATE})

This plan is generated by \`.claude/skills/harness-engineering/scripts/audit.sh\`.

## Goals

- Make repo context legible to agents (map, not encyclopedia).
- Fill the minimum "Phase 0: Standards" blanks so agent work doesn’t drift.
- Add at least one mechanical enforcement loop (CI or equivalent).

## Detected Context (Snapshot)

- Repo: ${repo_name}
- Remote: ${git_remote:-"(none)"}
- Base dir: ${BASE_DIR}
- CI: $(printf "%s" "${ci_signals[*]:-(none)}")

## Decisions Needed (Keep This Short)

- What is the one-liner purpose of this repo (for \`AGENTS.md\`)?
- What are the primary domains? (confirm or edit the candidate list)
- What blocks merges vs what can be follow-up fixed? (merge philosophy)
- What enforcement do we want now?
  - Generic: docs drift checks + file size rule + "no tribal knowledge"
  - JS/TS: ESLint + custom rules (optionally inspired by @factory/eslint-plugin)

## Tasks

- [ ] Run \`/harness-standards\` to fill placeholders across docs.
- [ ] Fill \`ARCHITECTURE.md\` domains table (start with candidate domains below).
- [ ] Fill \`${BASE_DIR}/PRODUCT_SENSE.md\` with user/problem/success metrics.
- [ ] Update \`${BASE_DIR}/quality-score.md\` with initial grades (even if "C across the board").
- [ ] Add 1-3 "golden principle" enforcement checks to CI (or add a script to wire into CI).
- [ ] Add a doc-gardening cadence (weekly or daily) and capture it as a recurring plan in \`${BASE_DIR}/plans/\`.

## Candidate Domains (Heuristic)

${candidate_domains}

## Notes

- Keep AGENTS.md short; put details in \`${BASE_DIR}/\`.
- Prefer enforcing invariants (linters, structural tests) over writing more prose rules.

EOF

echo ""
echo "Wrote onboarding plan: ${PLAN_PATH}"
