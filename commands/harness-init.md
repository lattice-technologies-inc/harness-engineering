---
name: harness-init
description: Bootstrap an agent-first knowledge base in this repository
argument-hint: "[project name]"
---

Bootstrap an agent-first knowledge base in this repository using the harness-engineering skill.

Read the harness-engineering skill for full context, then follow this workflow:

1. **Detect repo state** -- check for .git/, existing AGENTS.md, existing docs/ content
2. **Choose base directory** -- default `docs/`, but if it has existing content, ask user for alternative
3. **Gather context** -- ask for project name, one-liner, stack, domains (or use placeholders)
4. **Run bootstrap script** -- find the harness-engineering skill directory and execute `scripts/bootstrap.sh` with gathered args
5. **Git operations** -- new repo: init + commit. Existing repo: branch + commit, optionally open PR
6. **Report** -- summarize what was created, skipped, and next steps

Suggested next steps after bootstrap:
- Run `/harness-shape` to fill placeholders with repo-specific standards.
- If this was an existing repo, run `/harness-onboard` to generate an onboarding gap-fill plan based on real repo context.
