---
name: harness-engineering
description: "Bootstrap an agent-first knowledge base in any repository. This skill should be used when initializing a new project with structured docs, AGENTS.md, CLAUDE.md, and the full knowledge scaffold for agent-driven development. Invoke via /harness-init."
---

# Harness Engineering — Agent-First Knowledge Base Bootstrap

## Overview

Bootstrap a universal, stack-agnostic knowledge base structure optimized for agent-first development. Creates AGENTS.md as a table of contents (not an encyclopedia), with all deep knowledge living in structured `docs/` files — mechanically discoverable, progressively disclosed.

Based on the system that produced ~1M LOC across 1,500 PRs with zero manually-written code.

## When to Use

- Initializing a new repository for agent-first development
- Adding structured knowledge scaffolding to an existing repo
- User invokes `/harness-init`

## Workflow

### Step 1: Pre-flight Check

Check if the target repo already has the structure. The skill is idempotent — skip files that already exist, only create missing ones.

```
Check for existence of:
- AGENTS.md
- CLAUDE.md
- ARCHITECTURE.md
- docs/ directory and subdirectories
```

If all files exist, report "Knowledge base already bootstrapped" and exit.

### Step 2: Gather Project Context

Ask the user for project-specific details to customize the scaffold:

1. **Project name** — used in AGENTS.md header
2. **One-liner description** — what the project does
3. **Stack** (optional) — language/framework (e.g., "TypeScript + Next.js", "Python + FastAPI", "Swift")
4. **Primary domains** (optional) — initial domain areas for ARCHITECTURE.md (e.g., "Auth, API, Dashboard")

If the user declines details, use placeholders — the scaffold is useful even without customization.

### Step 3: Create Directory Structure

```
docs/
├── design-docs/
├── exec-plans/
├── plans/
│   └── complete/
├── product-specs/
├── references/
├── generated/
```

Create `.gitkeep` in empty directories to ensure they're tracked by git.

### Step 4: Generate Files

Generate the following files using the templates in `assets/templates/`. Customize with project name, description, stack, and domains gathered in Step 2.

| File | Template | Purpose |
|------|----------|---------|
| `AGENTS.md` | `assets/templates/AGENTS.md.tmpl` | Table of contents (~70-100 lines) |
| `CLAUDE.md` | `assets/templates/CLAUDE.md.tmpl` | Repo-level Claude instructions |
| `ARCHITECTURE.md` | `assets/templates/ARCHITECTURE.md.tmpl` | Domain map |
| `docs/design-docs/index.md` | `assets/templates/design-docs-index.md.tmpl` | Design doc catalog |
| `docs/design-docs/core-beliefs.md` | `assets/templates/core-beliefs.md.tmpl` | Agent-first principles |
| `docs/product-specs/index.md` | `assets/templates/product-specs-index.md.tmpl` | Product spec catalog |
| `docs/golden-principles.md` | `assets/templates/golden-principles.md.tmpl` | Mechanical rules |
| `docs/quality-score.md` | `assets/templates/quality-score.md.tmpl` | Quality grading rubric |
| `docs/tech-debt-tracker.md` | `assets/templates/tech-debt-tracker.md.tmpl` | Tech debt register |
| `docs/DESIGN.md` | `assets/templates/DESIGN.md.tmpl` | Design system |
| `docs/PLANS.md` | `assets/templates/PLANS.md.tmpl` | Plans index |
| `docs/PRODUCT_SENSE.md` | `assets/templates/PRODUCT_SENSE.md.tmpl` | Product context |
| `docs/RELIABILITY.md` | `assets/templates/RELIABILITY.md.tmpl` | Reliability requirements |
| `docs/SECURITY.md` | `assets/templates/SECURITY.md.tmpl` | Security guidelines |

### Step 5: Git Setup

If not already a git repo:
1. `git init`
2. Rename branch to `main`
3. Stage all generated files
4. Commit: `chore: bootstrap agent-first knowledge base`

If already a git repo:
1. Stage new files only
2. Commit: `chore: add agent-first knowledge base scaffold`

### Step 6: Report

Print a summary:
- Files created (count)
- Files skipped (already existed)
- Next steps: customize ARCHITECTURE.md domains, fill PRODUCT_SENSE.md, add first plan to docs/plans/

## Key Principles Encoded

The templates encode these agent-first principles:

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

## Resources

### assets/templates/

Template files for all generated docs. Each template includes placeholder markers (`<!-- TODO -->`) for project-specific customization. Read these templates when generating files — substitute `{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{STACK}}`, and `{{DOMAINS}}` with values from Step 2.
