---
name: harness-shape
description: Shape the knowledge base with real project context. Replaces placeholders with actual standards, domains, and guardrails.
argument-hint: ""
---

Shape the knowledge base with real project context. Replaces placeholders with actual standards, domains, and guardrails.

This is the step after `/harness-init` -- the scaffolding exists, now fill it with substance.

Read the harness-engineering skill for full context, then follow this workflow:

---

## PHASE 1: Analyze Current Repository (Silent -- no user interaction yet)

Before asking the user anything, gather real signals from the repo.

### 1a. Detect Tech Stack

Read these files (skip if missing):

- `package.json` -- JS/TS frameworks, scripts, dependencies
- `pyproject.toml` / `requirements.txt` -- Python stack
- `Gemfile` -- Ruby/Rails
- `go.mod` -- Go
- `Cargo.toml` -- Rust
- `Podfile` / `*.xcodeproj` -- iOS/Swift
- `pubspec.yaml` -- Dart/Flutter

Extract: primary language(s), framework(s), test runner, linter, formatter, build tool.

### 1b. Detect CI & Quality Gates

Check for:

- `.github/workflows/` -- GitHub Actions (read workflow files for test/lint/deploy steps)
- `.gitlab-ci.yml`, `.circleci/config.yml`, `Jenkinsfile`
- `Makefile`, `justfile`, `Taskfile.yml`

Extract: what runs on CI, what blocks merges, deploy targets.

### 1c. Scan Codebase Structure

Use Glob/Grep to find:

- Top-level directories (`src/`, `app/`, `apps/`, `packages/`, `services/`, `lib/`)
- Candidate domains (subdirectories under the above)
- Test file patterns (`.test.`, `.spec.`, `__tests__/`, `tests/`)
- Existing conventions: naming patterns, import style, module boundaries
- README.md for project description

### 1d. Check Existing Docs State

Read the bootstrapped files and note which still have placeholders:

- `AGENTS.md` -- does it still have `[One-liner description -- fill per project]`?
- `ARCHITECTURE.md` -- are domains filled or placeholder?
- `docs/PRODUCT_SENSE.md` -- placeholder or real content?
- `docs/RELIABILITY.md` -- placeholder or real content?
- `docs/SECURITY.md` -- placeholder or real content?
- `docs/golden-principles.md` -- generic or project-specific?

### 1e. Use Research Tools (if available)

If `ref_search_documentation` or `get_code_context_exa` are available:

- Search for best practices for the detected framework(s)
- Search for testing patterns specific to the stack
- Search for security best practices for the stack

If not available, proceed with general knowledge + codebase analysis.

---

## PHASE 2: Present Findings & Ask User to Clarify

**IMPORTANT**: Use the `AskUserQuestion` tool here. Do NOT just print questions as text -- the tool gives the user structured options and ensures real answers.

First, present a brief summary of what was detected (as regular text output). Then immediately use `AskUserQuestion` to get the critical inputs that can't be inferred from code:

### Question set (use AskUserQuestion with these):

1. **One-liner**: "What does this project do in one sentence?" -- Offer the inferred description from README as the first option.
2. **Primary users**: "Who are the primary users?" -- Options: Developers, End users, Internal team, Other.
3. **Merge philosophy**: "What blocks a merge?" -- Options: "Tests + lint must pass", "Tests + lint + review", "Fast and loose (fix forward)", Other.
4. **Security sensitivity**: "What's the security posture?" -- Options: "Handles user data/PII", "Internal tool (low sensitivity)", "Public API (high sensitivity)", Other.

If the user's answers are terse or they pick "Other" with custom text, that's fine -- fill in the rest from analysis.

### If answers are ambiguous

Use `AskUserQuestion` again for a focused follow-up. Do NOT guess on things that could lead to incorrect standards (e.g., security boundaries, auth strategy).

---

## PHASE 3: Fill Standards Documents

Using the confirmed inputs + codebase analysis, update these files:

### 3a. `AGENTS.md`

- Replace the one-liner placeholder with the confirmed description
- Verify the "Where to Look" table is accurate for the actual directory structure

### 3b. `ARCHITECTURE.md`

- Fill the domains table with detected domains from Phase 1c
- Add boundary descriptions (what each domain owns, what it doesn't)
- Note key dependencies between domains

### 3c. `docs/PRODUCT_SENSE.md`

- Primary user(s) and their context
- Problem(s) the product solves
- Success metrics (even rough ones)
- Non-goals (what this project deliberately doesn't do)

### 3d. `docs/RELIABILITY.md`

- Performance expectations (if detected from CI budgets or config)
- SLO-ish targets (if applicable)
- Critical paths that must not break
- Logging and observability expectations

### 3e. `docs/SECURITY.md`

- Auth/authz boundaries
- Secrets management approach
- Data classification (PII, credentials, public)
- API security patterns in use

### 3f. `docs/golden-principles.md`

Make principles project-specific. Replace generic entries with stack-aware rules:

- For JS/TS: "Use structured logger, not console.log"
- For Python: "Use logging module with structured output"
- For the detected test runner: "Tests must pass before merge"
- For the detected linter: "[linter] must pass with zero warnings"

### 3g. `docs/quality-score.md`

Set initial grades (even if "C" across the board). Having a baseline is better than having placeholders.

---

## PHASE 4: Report & Recommend Next Steps

Summarize what was updated, then recommend additional tooling:

```
Standards filled:
- AGENTS.md -- one-liner set
- ARCHITECTURE.md -- N domains mapped
- PRODUCT_SENSE.md -- users, problem, metrics
- RELIABILITY.md -- expectations set
- SECURITY.md -- boundaries documented
- golden-principles.md -- N rules, stack-specific
- quality-score.md -- baseline grades

Next steps:
- Review filled docs and adjust
- /harness-eslint for JS/TS mechanical enforcement
- /harness-onboard if migrating an existing codebase
```
