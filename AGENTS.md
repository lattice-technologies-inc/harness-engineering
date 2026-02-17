# harness-engineering

> [One-liner description — fill per project]

---

## Where to Look

| Question | Go to |
|----------|-------|
| Architecture / domain map | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Design decisions & rationale | [docs/design-docs/](docs/design-docs/index.md) |
| Draft plans | [docs/plans/](docs/plans/) |
| In-progress plans | [docs/plans/in-progress/](docs/plans/in-progress/) |
| Completed plans | [docs/plans/complete/](docs/plans/complete/) |
| Plan details (supporting docs) | [docs/plan-details/](docs/plan-details/) |
| Plans index | [docs/PLANS.md](docs/PLANS.md) |
| Product specs & requirements | [docs/product-specs/](docs/product-specs/index.md) |
| Product sense & user context | [docs/PRODUCT_SENSE.md](docs/PRODUCT_SENSE.md) |
| Design system & patterns | [docs/DESIGN.md](docs/DESIGN.md) |
| Golden principles (mechanical rules) | [docs/golden-principles.md](docs/golden-principles.md) |
| Quality scores per domain | [docs/quality-score.md](docs/quality-score.md) |
| Tech debt register | [docs/tech-debt-tracker.md](docs/tech-debt-tracker.md) |
| Reliability requirements | [docs/RELIABILITY.md](docs/RELIABILITY.md) |
| Security guidelines | [docs/SECURITY.md](docs/SECURITY.md) |
| External references & llms.txt | [docs/references/](docs/references/) |
| Auto-generated docs | [docs/generated/](docs/generated/) |
| Core beliefs (agent-first principles) | [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) |

---

## How to Work

### Before Coding

1. **Read docs first.** Start with this file, then follow pointers relevant to your task.
2. **Check plans.** Look in `docs/plans/in-progress/` for active work and `docs/plans/` for drafts. Don't duplicate work. If a plan has a details directory, read `scratchpad.md` first for prior learnings.
3. **Check tech debt.** Consult `docs/tech-debt-tracker.md` — your change might address (or worsen) known debt.

### Planning

4. **Plans are always single files.** Every plan is one `.md` file: `docs/plans/<slug>-YYYY-MM-DD.md`. This file moves through the pipeline.
5. **Plan details for deep work.** When a plan needs supporting documents (shaping, breadboarding, spikes, slice plans), create a details directory that the plan file links to:
   ```
   docs/plan-details/<slug>/    # permanent — never moves
     scratchpad.md      # working notes — learnings, failures, discoveries (always created)
     frame.md           # the "why" — problem definition, appetite, constraints
     shaping.md         # requirements (R), shapes (S), fit checks
     slices.md          # breadboard tables + vertical slices
     spike-<topic>.md   # investigation of unknowns
     V1-plan.md         # slice implementation plan
   ```
   The plan file in `docs/plans/` links to its details directory. Details stay put; only the plan file moves.
6. **Scratchpad.** Every plan-details directory gets a `scratchpad.md`. Use it to record:
   - Things that failed and why
   - Discoveries made during implementation
   - Workarounds and their reasoning
   - Context that would help a future session pick up where you left off

   This is optional but encouraged — write to it whenever you learn something worth preserving.
7. **Plan lifecycle.** Plans move through a three-stage pipeline:
   - `docs/plans/` — draft (not yet started)
   - `docs/plans/in-progress/` — actively being executed
   - `docs/plans/complete/` — fully implemented

### Building

8. **Validate at boundaries, trust internals.** Don't over-validate between trusted components.
9. **Keep files < 500 LOC.** Split and refactor as needed.
10. **Prefer shared utilities** over hand-rolled helpers.
11. **Structured logging only.** No `console.log` debugging in committed code.
12. **Tests prove behavior.** Write tests that demonstrate correctness, not implementation.

### After Coding

13. **Update docs when behavior changes.** No shipping without doc updates.
14. **Quality score must not regress.** Check `docs/quality-score.md`.
15. **Track new tech debt.** If you introduce debt knowingly, add it to the tracker.
16. **No knowledge lives outside the repo.** Encode Slack conversations, meeting notes, and verbal decisions into `docs/`.

---

## Quick Reference

- **Conventional Commits**: `feat|fix|refactor|build|ci|chore|docs|style|perf|test`
- **File limit**: ~500 LOC
- **Plans pipeline**: `docs/plans/` (draft) → `in-progress/` (executing) → `complete/` (done)
- **Design docs**: `docs/design-docs/`
- **Product specs**: `docs/product-specs/`
