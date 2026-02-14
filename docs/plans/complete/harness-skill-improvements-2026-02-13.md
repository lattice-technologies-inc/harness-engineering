# Harness Skill Improvements (2026-02-13)

## Phase 1: Beef Up `/harness-standards`

Rewrite the command to actually research the codebase before asking the user to fill things in. Modeled after Droidz `/standards-shaper`.

**Current**: 22-line checklist telling the agent to ask questions and update files.
**Target**: Multi-phase workflow that detects stack, reads code, infers conventions, then fills standards with real data.

### Steps
- [x] Rewrite `.claude/commands/harness-standards.md` with multi-phase workflow
- [x] Phase 1: Analyze repo (detect stack, CI, existing conventions)
- [x] Phase 2: Ask user for scope/confirmation
- [x] Phase 3: Fill standards docs with detected + confirmed data

## Phase 2: Add ESLint Rules

Add 2-3 more rules to the harness ESLint plugin skeleton that map to golden principles.

### Rules to add
- [x] `structured-logging` — enforce structured logging with static messages + metadata object. Inspired by Factory's version.
- [x] `max-file-lines` — proper harness rule with agent-readable message pointing to golden-principles.md
- [x] Add README.md per rule (Factory pattern)
- [x] Update `index.js` to register new rules
- [x] Update `eslint.config.cjs` template to include new rules

## Phase 3: Polish

- [x] Expand `audit.sh` placeholder detection (checks all generated files now, not just 2)
- [x] Add flow diagram to SKILL.md
- [x] Fix TS parser conditional in `add-eslint-agent-lints.sh` (now detects TS files before installing parser)
- [x] Fix license in ESLint plugin package.json (UNLICENSED → MIT)
