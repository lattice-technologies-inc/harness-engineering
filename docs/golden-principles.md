# Golden Principles

Mechanical rules that apply universally across the project. Non-negotiable.

---

## Code

- **Validate at boundaries, trust internals.** Validate user input, API responses, external data. Don't re-validate between trusted internal components.
- **Prefer shared utilities over hand-rolled helpers.** Check `src/utils/` (or equivalent) before writing a new helper. Duplication is a bug.
- **Keep files < 500 LOC.** Split when approaching the limit. Refactor proactively.
- **Structured logging only.** Use the project's logger. No `console.log`, `print()`, or `puts` in committed code.
- **No magic numbers or strings.** Use named constants or config values.
- **Errors are values.** Handle them explicitly. No silent swallowing.

## Process

- **Plans before implementation.** Multi-step work requires a plan in `docs/plans/`.
- **Docs before code.** Read relevant docs before coding. Update them after.
- **Tests prove behavior.** Every feature has tests. Every bug fix has a regression test.
- **Conventional Commits.** `feat|fix|refactor|build|ci|chore|docs|style|perf|test: description`
- **No tribal knowledge.** If it's not in the repo, it doesn't exist.

## Quality

- **Quality score must not regress.** Check `docs/quality-score.md` after changes.
- **Tech debt gets tracked.** New debt → entry in `docs/tech-debt-tracker.md`.
- **No TODOs without tracking.** If you write `TODO`, add a corresponding entry in the tech debt tracker.
- **Code review is mandatory.** No merging without review (human or agent).

## Project-Specific

[Customize per project — add rules specific to your stack, domain, or team conventions here.]
