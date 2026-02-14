Fill in "Phase 0: Standards" after harness bootstrapping. This command researches the actual codebase before asking the user to confirm — never start from blank.

Goal: replace placeholders with repo-specific standards and guardrails so agents can ship without drifting.

---

## PHASE 1: Analyze Current Repository

Before asking the user anything, gather real signals from the repo.

### 1a. Detect Tech Stack

Read these files (skip if missing):

- `package.json` → JS/TS frameworks, scripts, dependencies
- `pyproject.toml` / `requirements.txt` → Python stack
- `Gemfile` → Ruby/Rails
- `go.mod` → Go
- `Cargo.toml` → Rust
- `Podfile` / `*.xcodeproj` → iOS/Swift
- `pubspec.yaml` → Dart/Flutter

Extract: primary language(s), framework(s), test runner, linter, formatter, build tool.

### 1b. Detect CI & Quality Gates

Check for:

- `.github/workflows/` → GitHub Actions (read workflow files for test/lint/deploy steps)
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

- `AGENTS.md` — does it still have `[One-liner description — fill per project]`?
- `ARCHITECTURE.md` — are domains filled or placeholder?
- `docs/PRODUCT_SENSE.md` — placeholder or real content?
- `docs/RELIABILITY.md` — placeholder or real content?
- `docs/SECURITY.md` — placeholder or real content?
- `docs/golden-principles.md` — generic or project-specific?

### 1e. Use Research Tools (if available)

If `ref_search_documentation` or `get_code_context_exa` are available:

- Search for best practices for the detected framework(s)
- Search for testing patterns specific to the stack
- Search for security best practices for the stack

If not available, proceed with general knowledge + codebase analysis.

---

## PHASE 2: Present Findings & Confirm with User

Present a summary of what was detected and propose standards. Ask the user ONE tight set of questions:

```
I analyzed the repo. Here's what I found:

**Stack**: [detected languages/frameworks]
**CI**: [what runs, what blocks merges]
**Domains**: [candidate list]
**Tests**: [pattern detected or none]
**Gaps**: [which docs are still placeholder]

I'd like to fill in the standards. A few questions:

1. **One-liner**: What does this project do? (I suggest: "[inferred from README]")
2. **Primary users**: Who uses this? (developers, end-users, internal team?)
3. **Quality gates**: What must ALWAYS hold? (I detected these from CI: [list])
   - Anything to add or change?
4. **Merge philosophy**: What blocks a merge vs what can be fixed post-merge?
5. **Security boundaries**: Any auth/secrets/data classification I should know about?
```

If the user gives terse answers, that's fine — fill in the rest from analysis.

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

## PHASE 4: Report

Summarize what was updated:

```
Standards filled:
- ✅ AGENTS.md — one-liner set
- ✅ ARCHITECTURE.md — N domains mapped
- ✅ PRODUCT_SENSE.md — users, problem, metrics
- ✅ RELIABILITY.md — expectations set
- ✅ SECURITY.md — boundaries documented
- ✅ golden-principles.md — N rules, stack-specific
- ✅ quality-score.md — baseline grades

Research used:
- Codebase analysis: Yes
- Framework docs: [Yes/No]
- CI analysis: [Yes/No]

Suggested next steps:
- Review the filled docs and adjust anything that's off
- Wire `scripts/harness/knowledge-check.sh` into CI
- Consider adding mechanical enforcement (`/harness-eslint` for JS/TS repos)
```
