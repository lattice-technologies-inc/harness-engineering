---
name: harness-onboard
description: "Onboard an existing repository into the harness-engineering knowledge base and fill in gaps using an automated audit."
argument-hint: ""
---

Onboard an existing repository into the harness-engineering knowledge base and fill in gaps using an automated audit.

This command is optimized for repos that already have code and context (README, existing docs, CI, conventions) and need:
- A structured knowledge base (`AGENTS.md` + `docs/`)
- A concrete "Phase 0: Standards" gap-fill plan to avoid endless hand-waving

---

## PHASE 1: Pre-flight (Silent)

1. Check if repo is bootstrapped -- if `AGENTS.md` or `docs/` scaffolding is missing, tell the user to run `/harness-init` first and stop.
2. Run the audit script to gather signals. Find the harness-engineering skill directory and execute:

```bash
bash <skill-dir>/scripts/audit.sh --target "$(pwd)"
```

3. Read the audit output carefully. It detects: stack, CI, domains, agent tooling, placeholder state.

---

## PHASE 2: Present & Ask (use AskUserQuestion)

Present the audit findings as a brief summary, then use `AskUserQuestion` for:

1. **One-liner**: "What does this project do?" -- Offer README-inferred description as first option.
2. **Domains**: "Are these the right domains?" -- Show detected domains, let user correct.
3. **Enforcement level**: "How strict should we be?" -- Options: "Knowledge base only", "Knowledge base + CI checks", "Knowledge base + CI + ESLint", Other.
4. **Ready to execute?**: "Should I fill the standards now?" -- Options: "Yes, fill everything", "Yes, but let me review the plan first", "No, just generate the plan", Other.

---

## PHASE 3: Execute Plan

Based on user's answer:

- **"Fill everything"**: Run the same Phase 3 as `/harness-shape` (fill AGENTS.md, ARCHITECTURE.md, PRODUCT_SENSE.md, RELIABILITY.md, SECURITY.md, golden-principles.md, quality-score.md).
- **"Review plan first"**: Write the plan to `docs/plans/harness-onboard-existing-YYYY-MM-DD.md` and stop.
- **"Generate plan only"**: Run `audit.sh --write-plan` and present the output.

---

## PHASE 4: Report

Summarize what was done, recommend next steps:
- `/harness-shape` if standards still need filling
- `/harness-eslint` for JS/TS mechanical enforcement
