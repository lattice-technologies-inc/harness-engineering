Onboard an existing repository into the harness-engineering knowledge base and fill in gaps using an automated audit.

This command is optimized for repos that already have code and context (README, existing docs, CI, conventions) and need:
- A structured knowledge base (`AGENTS.md` + `docs/`)
- A concrete "Phase 0: Standards" gap-fill plan to avoid endless hand-waving

Workflow:

1. Ensure the repo is bootstrapped:
   - If `AGENTS.md` or `docs/` scaffolding is missing, run `/harness-init` first.
2. Run the audit to produce an onboarding plan:

```bash
bash .claude/skills/harness-engineering/scripts/audit.sh --target "$(pwd)" --write-plan
```

3. Open the generated plan in `docs/plans/` (or the configured `planDirectory`) and execute it.

