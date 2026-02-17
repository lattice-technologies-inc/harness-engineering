---
name: harness-engineering
description: "Bootstrap an agent-first knowledge base in any repository. This skill should be used when initializing a new project or adding structured knowledge scaffolding to an existing repo. Supports configurable base directory, new/existing repos, Claude settings with plan directory, and bundled agent capabilities. Invoke via /harness-init."
---

# Harness Engineering — Agent-First Knowledge Base Bootstrap

## Overview

Bootstrap a universal, stack-agnostic knowledge base optimized for agent-first development. Creates AGENTS.md as a table of contents (not an encyclopedia), with deep knowledge in structured docs, mechanically discoverable, progressively disclosed.

Based on the system that produced ~1M LOC across 1,500 PRs with zero manually-written code. See `references/harness-engineering-article.md` for the full source material.

## When to Use

- Initializing a new repository for agent-first development
- Adding structured knowledge scaffolding to an existing repo
- User invokes `/harness-init`

## Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  HARNESS ENGINEERING FLOW                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  /harness-init          Bootstrap scaffolding               │
│       ↓                 (AGENTS.md, docs/, commands, hooks) │
│                                                             │
│  /harness-shape         Fill with real project context      │
│       ↓                 (analyze repo → confirm → fill)     │
│                                                             │
│  /harness-onboard       Existing repo gap-fill              │
│       ↓                 (audit → onboarding plan)           │
│                                                             │
│  /harness-eslint        Optional: mechanical enforcement    │
│                         (ESLint rules for JS/TS repos)      │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Typical sequence:
  New repo:      /harness-init → /harness-shape
  Existing repo: /harness-init → /harness-onboard → /harness-shape
  JS/TS repo:    ... → /harness-eslint (optional add-on)
```

## Workflow

### Step 1: Detect Repo State

Determine whether the target is a new or existing repository:

```
Check:
1. Does .git/ exist? → existing repo
2. Does AGENTS.md exist? → likely already bootstrapped (prefer audit + gap-fill)
3. Does the default docs/ directory have existing content? → potential conflict
```

Notes:
- The bootstrap script is idempotent and will skip existing files. If the repo is already bootstrapped, prefer running the **existing repo onboarding audit** (Step 6) instead of re-running bootstrap.

### Step 2: Choose Base Directory

The knowledge base defaults to `docs/` but is configurable.

**If `docs/` already has significant content** (>5 non-generated files), surface to user:

> "`docs/` already contains files. Options:"
> 1. Use `docs/` anyway (merge alongside existing content)
> 2. Use `knowledge/` instead
> 3. Use a custom path
> 4. Cancel

All generated files, templates, and path references adapt to the chosen base directory.

### Step 3: Gather Project Context

Ask the user (skip if already provided via args):

1. **Project name** — used in AGENTS.md header
2. **One-liner description** — what the project does
3. **Stack** (optional) — language/framework
4. **Primary domains** (optional) — initial areas for ARCHITECTURE.md

If the user declines, use placeholders.

### Step 4: Run Bootstrap Script

Execute the bootstrap shell script which handles all file creation:

```bash
bash .claude/skills/harness-engineering/scripts/bootstrap.sh \
  --target "$(pwd)" \
  --name "Project Name" \
  --description "One-liner" \
  --base-dir "docs" \
  --stack "TypeScript" \
  --domains "| Auth | src/auth/ | — | Authentication |"
```

The script is idempotent — it skips existing files and reports what was created vs skipped.

**What the script creates (knowledge base — skips existing files):**

Root files:
- `AGENTS.md` — table of contents (~70 lines, all paths reference chosen base dir)
- `CLAUDE.md` — repo-level Claude instructions
- `ARCHITECTURE.md` — domain map template

Knowledge base (under `<base-dir>/`):
- `design-docs/index.md` + `design-docs/core-beliefs.md`
- `product-specs/index.md`
- `golden-principles.md` — mechanical rules
- `quality-score.md` — grading rubric (A-F)
- `tech-debt-tracker.md` — debt register
- `DESIGN.md`, `PLANS.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `SECURITY.md`
- `.gitkeep` in: `plans/`, `plans/in-progress/`, `plans/complete/`, `plan-details/`, `product-specs/`, `references/`, `generated/`

Repo checks (root):
- `scripts/harness/knowledge-check.sh` — minimal mechanical checks to keep the knowledge base legible to agents (wire into CI when ready)

**What the script deploys (agent tooling — always overwrites for updates):**

Slash commands:
- `.claude/commands/harness-init.md` — bootstrap entry point
- `.claude/commands/harness-shape.md` — fill knowledge base with real project context
- `.claude/commands/harness-onboard.md` — existing repo audit + gap-fill plan
- `.claude/commands/harness-standards.md` — alias for harness-shape (original name)
- `.claude/commands/harness-eslint.md` — optional ESLint enforcement

Hooks:
- `.claude/hooks/lint-on-save.sh` — immediate lint feedback on Edit/Write (ESLint, ruff, shellcheck)
- `.claude/hooks/shaping-ripple.sh` — PostToolUse on Edit/Write. Detects edits to `shaping: true` files and reminds agent to check cross-level consistency
- Plan-capture — PostToolUse on ExitPlanMode. Reminds agent to symlink approved plan into `docs/plans/` with proper `<slug>-YYYY-MM-DD.md` name
- Plan-pipeline — prompt-based Stop hook. Fires at end of turn to verify plans are in the correct pipeline stage

Companion skills:
- `.claude/skills/git-worktree/` — isolated parallel development with env file management

Claude config:
- `.claude/settings.json` — `planDirectory` + lint-on-save hook config

### Step 5: Git Operations

**New repo:**
1. `git init` + rename branch to `main`
2. Stage all generated files
3. Commit: `chore: bootstrap agent-first knowledge base`

**Existing repo:**
1. Create branch: `chore/add-knowledge-base`
2. Stage new files only
3. Commit: `chore: add agent-first knowledge base scaffold`
4. Optionally open PR if user wants

### Step 6: Existing Repo Onboarding Audit (Gap Fill)

For existing repositories, the hard part isn’t creating empty scaffolding. It’s filling the **Phase 0: Standards** gaps using the repo’s real context (code, README, CI, existing conventions), and producing a short execution plan so agents don’t drift.

Run the audit script to generate a concrete onboarding plan:

```bash
bash .claude/skills/harness-engineering/scripts/audit.sh --target "$(pwd)" --write-plan
```

The audit will:
- Infer the knowledge base base dir from `.claude/settings.json` when possible
- Detect stack signals (JS/TS, Python, Ruby, Go, Rust, etc.)
- Suggest candidate domains by scanning common directory roots (`src/`, `apps/`, `packages/`, etc.)
- Write a plan to `<base-dir>/plans/harness-onboard-existing-YYYY-MM-DD.md`

### Optional: Mechanical Enforcement Add-On (Agent-Directed Linters)

The source article emphasizes enforcing invariants via custom linters and structural tests with **agent-readable remediation**.

This skill ships a minimal, stack-agnostic enforcement loop:

```bash
bash scripts/harness/knowledge-check.sh
```

When the repo is JS/TS-heavy and ESLint is already in play, consider:
- Adding custom ESLint rules for your project conventions (best)
- Or using an external rule set for inspiration (e.g. `@factory/eslint-plugin`) and adapting it

The right outcome is not “more rules.” It’s “rules that eliminate whole classes of agent mistakes.”

This template includes a small, repo-local ESLint plugin skeleton you can copy into a JS/TS repo:

```bash
bash .claude/skills/harness-engineering/scripts/add-eslint-agent-lints.sh --target "$(pwd)" --install
```

It creates:
- `tools/eslint-plugin-harness/` (tiny plugin with agent-readable messages)
- `eslint.config.cjs`
- `package.json` `lint` script (if missing)

If the repo already has a stack and package manager, ask the user one tight question:
- "Do you want to add mechanical enforcement now?"
  - "No, not yet" (keep only `scripts/harness/knowledge-check.sh`)
  - "Yes, minimal" (wire `scripts/harness/knowledge-check.sh` into CI)
  - "Yes, stack-specific" (add JS/TS ESLint or Python ruff, etc., plus CI)

### Step 7: Report

Print summary:
- Files created vs skipped
- Base directory used
- Next steps: run the existing-repo audit (if relevant), customize ARCHITECTURE.md, fill PRODUCT_SENSE.md, create first plan

## Key Principles Encoded

The generated templates encode these agent-first principles:

1. **AGENTS.md is a table of contents** — short, maps questions to docs
2. **Knowledge is mechanically discoverable** — structured, not tribal
3. **Progressive disclosure** — pointer → doc → code
4. **Plans are first-class artifacts** — versioned, reviewed, completed
5. **Quality is measured** — grading rubric, no regression
6. **Tech debt is visible** — tracked, not ignored
7. **No tribal knowledge** — if it's not in the repo, it doesn't exist
8. **Validate at boundaries** — trust internals
9. **Tests prove behavior** — not implementation
10. **Docs ship with code** — same commit

## Recommended Skills & Tools (Post-Bootstrap)

After bootstrapping, install these tools to unlock the full agent-first development loop. The audit script (`audit.sh`) checks for their presence on PATH.

### Required

| Tool | Purpose | Install |
|------|---------|---------|
| `gh` | GitHub CLI — PRs, issues, CI checks | `brew install gh` |

### Recommended

| Tool | Purpose | Install |
|------|---------|---------|
| `agent-browser` | Headless browser automation — screenshot validation, DOM inspection, user flow testing | `npm i -g agent-browser && agent-browser install` |
| `playwriter` | Control user's Chrome via extension — authenticated flows, debugging | Load skill: `/playwriter` |
| `peekaboo` | macOS screenshot/click automation — visual QA | `brew install steipete/tap/peekaboo` |

### Recommended Skills

| Skill | Purpose |
|-------|---------|
| `harness-engineering` | This skill — bootstrap + onboard + standards |
| `git-worktree` | Isolated parallel development — one worktree per task |
| `compound-engineering:agent-browser` | Browser automation skill (load with `/compound-engineering:agent-browser`) |

### Agent Capabilities

These patterns are enabled by the tools above:

**Browser Validation**: Drive the app with Chrome DevTools for visual QA. Use `agent-browser` (headless) or `playwriter` (user's Chrome). Enables: screenshot validation, DOM inspection, user flow testing.

**Doc Gardening**: Recurring scan for stale docs that don't match code behavior. Pattern: agent reads code → compares to docs → opens fix-up PRs for drift.

**Quality Sweeps**: Background task scanning for golden principle violations. Updates quality scores in `<base-dir>/quality-score.md`. Opens targeted refactoring PRs.

**Plan Lifecycle**: Manage plans as first-class artifacts:
- Create in `<base-dir>/plans/`
- Track status in `<base-dir>/PLANS.md`
- Move to `<base-dir>/plans/complete/` when done

## ESLint Plugin Rules

The bundled `eslint-plugin-harness` ships these rules, mapped to the article's lint categories:

| Rule | Category | Severity | Description |
|------|----------|----------|-------------|
| `no-console-log` | Observability | error | No committed console.log |
| `no-default-export` | Grep-ability | warn | Named exports only — highest leverage for agents |
| `no-eval` | Security | error | Block eval() and new Function() |
| `filename-match-export` | Grep-ability | warn | Filename matches single named export |
| `structured-logging` | Observability | error | Static message + metadata object |
| `max-file-lines` | Glob-ability | warn | Keep files < 500 LOC |

See `assets/eslint-plugin-harness/rules/<rule>/README.md` for per-rule docs with rationale and examples.

## Resources (All Bundled)

This skill is fully self-contained. Everything needed to bootstrap a repo lives inside this directory.

### scripts/
- `bootstrap.sh` — creates knowledge base + deploys all tooling. Accepts `--target`, `--name`, `--description`, `--base-dir`, `--stack`, `--domains` flags. Idempotent for knowledge base; always updates tooling.
- `audit.sh` — analyzes existing repo for stack, CI, domains, agent tooling, placeholders. Generates onboarding plans.
- `add-eslint-agent-lints.sh` — scaffolds local ESLint plugin with agent-readable rules into JS/TS repos.

### assets/templates/
15 template files with `{{PLACEHOLDER}}` markers: `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{BASE_DIR}}`, `{{STACK}}`, `{{DOMAINS}}`, `{{DATE}}`. The bootstrap script handles substitution.

### assets/commands/
5 slash command files deployed to `.claude/commands/` during bootstrap:
- `harness-init.md` — bootstrap entry point
- `harness-shape.md` — fill knowledge base with real project context (primary post-bootstrap command)
- `harness-standards.md` — alias for harness-shape (original name)
- `harness-onboard.md` — existing repo audit + gap-fill plan
- `harness-eslint.md` — optional ESLint enforcement

### assets/hooks/
- `lint-on-save.sh` — PostToolUse hook deployed to `.claude/hooks/`. Runs ESLint (JS/TS), ruff (Python), or shellcheck (Shell) after every Edit/Write. Exit 2 blocks with feedback.

### Plugin-only hooks (defined in `hooks/hooks.json`, no deployed asset)
- `plan-capture.sh` — PostToolUse on ExitPlanMode. Reminds agent to symlink approved plan into `docs/plans/` with proper `<slug>-YYYY-MM-DD.md` naming.
- Plan-pipeline Stop — prompt-based Stop hook. Fires at end of turn. Uses LLM reasoning to check if plans are in the correct pipeline stage (draft → in-progress → complete).

### assets/skills/
- `git-worktree/` — companion skill deployed to `.claude/skills/git-worktree/`. Manages worktree create/list/switch/cleanup with env file copying and `.worktree-config` for agent use.

### assets/eslint-plugin-harness/
6-rule ESLint plugin with agent-readable error messages. Deployed to `tools/eslint-plugin-harness/` via `/harness-eslint`.

### references/
- `harness-engineering-article.md` — key insights from the OpenAI harness engineering article (includes lint categories, enforcement patterns, and development cycle)
