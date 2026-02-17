---
name: git-worktree
description: >
  This skill manages Git worktrees for isolated parallel development. It handles creating,
  listing, switching, and cleaning up worktrees with automatic .env file copying and
  shared-context configuration. Use when spinning up parallel feature branches, code
  review in isolation, or multi-agent development.
---

# Git Worktree Manager

Manage Git worktrees for isolated parallel development with environment file management
and shared-context support for multi-agent workflows.

## When to Use

- Spinning up a parallel feature branch without disrupting current work
- Isolated code review of a PR
- Multi-agent development where each agent works in its own worktree
- Any time `git stash` / branch-switching friction is slowing things down

## CRITICAL: Always Use the Manager Script

**Never call `git worktree add` directly.** Always use the manager script — it handles
env file copying, `.gitignore` management, and writes `.worktree-config` for agent use.

```bash
# Correct
bash .claude/skills/git-worktree/scripts/worktree-manager.sh create feature-name

# Wrong
git worktree add .worktrees/feature-name -b feature-name main
```

## Commands

```bash
SCRIPT=".claude/skills/git-worktree/scripts/worktree-manager.sh"

# Create new worktree (copies .env files, writes .worktree-config)
bash $SCRIPT create <branch-name> [from-branch]

# List all worktrees
bash $SCRIPT list

# Switch to a worktree
bash $SCRIPT switch <name>

# Refresh .env files from main repo
bash $SCRIPT copy-env [name]

# Clean up inactive worktrees
bash $SCRIPT cleanup
```

## What Happens on Create

1. Updates the base branch from remote
2. Creates worktree at `.worktrees/<branch-name>/`
3. Copies all `.env*` files from main repo (except `.env.example`)
4. Writes `.worktree-config` with `MAIN_REPO` path
5. Adds `.worktrees` to `.gitignore` if missing

## Shared Context Pattern

Worktrees are isolated file trees — they do NOT share `docs/`, `plans/`, or other
non-git content with the main repo. To avoid drift and duplication:

### For Agents Working in a Worktree

1. Read `.worktree-config` to get `MAIN_REPO` path
2. Reference shared docs from `$MAIN_REPO/docs/` — do not duplicate them into the worktree
3. When creating or editing plans, write to `$MAIN_REPO/docs/plans/`
4. The worktree is for **code changes only**; docs live in the main repo

```bash
# Example: read MAIN_REPO from config
source .worktree-config
cat "$MAIN_REPO/docs/plans/my-plan.md"
```

### Why Not Symlinks?

Symlinks point one direction. If `worktree/docs → main/docs`, edits in the worktree
modify main's files directly. With multiple agents in multiple worktrees, this creates
race conditions. The config-based approach is explicit and safe.

## Directory Structure

```
project-root/
├── .worktrees/                    # gitignored
│   ├── feat/new-feature/          # worktree 1
│   │   ├── .git
│   │   ├── .env                   # copied from main
│   │   ├── .worktree-config       # MAIN_REPO pointer
│   │   └── src/
│   └── fix/bug-123/               # worktree 2
│       ├── .git
│       ├── .env
│       ├── .worktree-config
│       └── src/
├── docs/                          # single source of truth
│   ├── plans/
│   └── references/
└── .gitignore                     # includes .worktrees
```

## Integration Notes

- Worktrees share git objects with the main repo (lightweight, no duplication)
- Each worktree has its own branch — commits from one don't affect others
- Push from any worktree normally
- `.worktree-config` is auto-generated and should not be committed
