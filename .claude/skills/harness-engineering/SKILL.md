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

## Workflow

### Step 1: Detect Repo State

Determine whether the target is a new or existing repository:

```
Check:
1. Does .git/ exist? → existing repo
2. Does AGENTS.md exist? → already bootstrapped (report + exit unless --force)
3. Does the default docs/ directory have existing content? → potential conflict
```

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

**What the script creates:**

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
- `.gitkeep` in: `exec-plans/`, `plans/`, `plans/complete/`, `product-specs/`, `references/`, `generated/`

Claude config:
- `.claude/settings.json` — with `planDirectory` set to `<base-dir>/plans`

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

### Step 6: Report

Print summary:
- Files created vs skipped
- Base directory used
- Next steps: customize ARCHITECTURE.md, fill PRODUCT_SENSE.md, create first plan

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

## Agent Capabilities (Post-Bootstrap)

After bootstrapping, the following capabilities enhance agent-first development. These reference existing tools — install as needed:

### Browser Validation
Drive the app with Chrome DevTools for visual QA. Use `agent-browser` (headless) or `playwriter` (user's Chrome). Enables: screenshot validation, DOM inspection, user flow testing.

### Doc Gardening
Recurring scan for stale docs that don't match code behavior. Pattern: agent reads code → compares to docs → opens fix-up PRs for drift.

### Quality Sweeps
Background task scanning for golden principle violations. Updates quality scores in `<base-dir>/quality-score.md`. Opens targeted refactoring PRs.

### Plan Lifecycle
Manage plans as first-class artifacts:
- Create in `<base-dir>/plans/`
- Track status in `<base-dir>/PLANS.md`
- Move to `<base-dir>/plans/complete/` when done

## Resources

### scripts/bootstrap.sh
Shell script that creates the full directory structure and generates all files from templates. Accepts `--target`, `--name`, `--description`, `--base-dir`, `--stack`, `--domains` flags. Idempotent.

### assets/templates/
14 template files with `{{PLACEHOLDER}}` markers: `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{BASE_DIR}}`, `{{STACK}}`, `{{DOMAINS}}`, `{{DATE}}`. The bootstrap script handles substitution.

### references/
- `harness-engineering-article.md` — key insights extracted from the source article
