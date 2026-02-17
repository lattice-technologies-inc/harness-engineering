# Claude Code — Repo Instructions

## Primary Knowledge Base

**Read @AGENTS.md before any task.** It is the table of contents for all project knowledge.

## Enforced Behaviors

1. **Read @AGENTS.md first.** Before coding, planning, or reviewing — read AGENTS.md and follow its pointers.
2. **Update docs/ when code changes.** If behavior changes, docs must change in the same PR.
3. **Create plans before multi-step work.** Plans are always single files: `docs/plans/<slug>-YYYY-MM-DD.md`. For deep work, the plan links to a details directory at `docs/plan-details/<slug>/`.
4. **Plan lifecycle.** Draft → `in-progress/` when executing → `complete/` when done. Move plans through the pipeline.
5. **No tribal knowledge.** If it was discussed in Slack, a meeting, or a conversation — encode it into `docs/`. The repo is the single source of truth.
6. **Quality score must not regress.** Check `docs/quality-score.md` after changes.
7. **Track tech debt.** New debt gets logged in `docs/tech-debt-tracker.md`.
8. **Conventional Commits.** Use `feat|fix|refactor|build|ci|chore|docs|style|perf|test` prefixes.
9. **Files < 500 LOC.** Split large files proactively.

## Plugin Development

This repo is a Claude Code plugin. Structure: `.claude-plugin/plugin.json` + `skills/` + `commands/` + `hooks/` + `scripts/`.

### Versioning

Every change must update: `.claude-plugin/plugin.json` (version), `CHANGELOG.md`, `README.md` (component counts).

- **MAJOR**: Breaking changes to bootstrap output or skill interfaces
- **MINOR**: New skills, commands, templates, or hooks
- **PATCH**: Bug fixes, doc updates, template improvements

### Dual-Nature Commands

Commands exist in TWO versions — update BOTH when changing:

1. **`commands/`** — Plugin versions. Use "Read the X skill" and skill-relative paths.
2. **`skills/harness-engineering/assets/commands/`** — Deployed versions. Use `.claude/skills/...` paths for standalone repos.

### Hook Locations (THREE places)

1. **`hooks/hooks.json`** — Plugin hook config (uses `${CLAUDE_PLUGIN_ROOT}/scripts/`)
2. **`scripts/`** — Plugin hook scripts
3. **`skills/harness-engineering/assets/hooks/`** — Deployed versions for target repos

### Testing

```bash
claude --plugin-dir .
```
