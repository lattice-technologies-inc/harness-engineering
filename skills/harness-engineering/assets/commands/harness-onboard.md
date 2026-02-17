Onboard an existing repository into the harness-engineering knowledge base and fill in gaps using an automated audit.

This command is optimized for repos that already have code and context (README, existing docs, CI, conventions) and need:
- A structured knowledge base (`AGENTS.md` + `docs/`)
- A concrete "Phase 0: Standards" gap-fill plan to avoid endless hand-waving

---

## PHASE 1: Pre-flight (Silent)

1. Check if repo is bootstrapped — if `AGENTS.md` or `docs/` scaffolding is missing, tell the user to run `/harness-init` first and stop.
2. Run the audit script to gather signals:

```bash
bash .claude/skills/harness-engineering/scripts/audit.sh --target "$(pwd)"
```

3. Read the audit output and extract: stack signals, CI, candidate domains, placeholder state.

---

## PHASE 2: Confirm with User (Use AskUserQuestion)

Present a brief summary of the audit findings as text. Then use `AskUserQuestion` to confirm the critical decisions before generating the plan:

1. **One-liner purpose**: "What's the one-liner purpose for AGENTS.md?" — Offer inferred description as first option.
2. **Domains**: "Which of these detected directories are real domains?" — Use multiSelect with the candidate list from the audit.
3. **Enforcement level**: "What mechanical enforcement do you want now?" — Options: "Minimal (knowledge-check.sh only)", "Stack-specific (ESLint/ruff/etc.)", "Not yet", Other.

If anything is unclear from the audit (e.g., no CI detected, ambiguous domain structure), ask a focused follow-up with `AskUserQuestion` rather than guessing.

---

## PHASE 3: Generate Plan

Run the audit with `--write-plan` to generate the onboarding plan:

```bash
bash .claude/skills/harness-engineering/scripts/audit.sh --target "$(pwd)" --write-plan
```

Open the generated plan in `docs/plans/` and present the task list to the user.

---

## PHASE 4: Execute or Hand Off

Ask the user (via `AskUserQuestion`):

- **Execute now**: "Want me to start filling standards now?" — Options: "Yes, run /harness-standards now", "No, I'll review the plan first", Other.

If yes, immediately run the `/harness-standards` workflow. If no, tell the user the plan is ready for review and they can run `/harness-standards` when ready.
