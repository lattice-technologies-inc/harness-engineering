# Harness Engineering Skill v2

## Summary

Enhance the `/harness-init` skill with configurable paths, shell bootstrap script, Claude settings/hooks, new+existing repo support, and bundled agent skills/tools.

---

## Phase 1: Bootstrap Shell Script

Create `scripts/bootstrap.sh` in the skill:
- Takes positional args: `--name`, `--description`, `--base-dir` (default: `docs`), `--target` (repo root)
- Creates full directory structure under `$base_dir/`
- Copies and substitutes templates (`{{PROJECT_NAME}}`, `{{DESCRIPTION}}`, `{{DATE}}`, `{{DOMAINS}}`)
- Generates AGENTS.md, CLAUDE.md, ARCHITECTURE.md at repo root (paths reference `$base_dir/`)
- Idempotent — skips existing files, reports what was created/skipped
- Exit 0 with summary

## Phase 2: Configurable Base Directory

Update SKILL.md workflow:
1. Pre-flight explores repo — checks for existing `docs/` with content
2. If `docs/` already populated, surface to user: "docs/ has existing content. Use `docs/` anyway, or pick alternative? (e.g., `knowledge/`, `.docs/`, `agent-docs/`)"
3. All templates and AGENTS.md pointers use the chosen base dir
4. Shell script handles this via `--base-dir` flag

## Phase 3: New vs Existing Repo Support

Two paths in SKILL.md:
- **New repo**: `git init`, rename to `main`, full scaffold, initial commit
- **Existing repo**: detect `.git/`, create feature branch `chore/add-knowledge-base`, scaffold, commit, optionally open PR
- Both paths: detect what already exists, skip or merge

## Phase 4: Claude Settings & Hooks

Generate `.claude/settings.json` with:
```json
{
  "planDirectory": "<base_dir>/plans",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "# Future: lint-on-save hook placeholder"
      }
    ]
  }
}
```

Also generate `.claude/settings.local.json.example` showing optional hooks:
- Pre-commit quality check
- Doc freshness lint
- File size lint (< 500 LOC warning)

## Phase 5: Bundled Agent Skills

Create skill references in `.claude/skills/` (or skill pointers) for key capabilities from the article:

1. **browser-validation** — pointer/instructions for Chrome DevTools integration (screenshots, DOM snapshots, navigation)
2. **doc-gardening** — recurring scan for stale docs, opens fix-up PRs
3. **quality-sweep** — scan for golden principle violations, update quality scores
4. **plan-lifecycle** — manage plan creation, completion, archival

These can be lightweight SKILL.md files that reference external tools (agent-browser, peekaboo, etc.) rather than reimplementing them.

## Phase 6: Update SKILL.md

Rewrite SKILL.md to reflect all changes:
- Updated workflow with base-dir detection
- Shell script reference
- Settings generation
- New/existing repo branching
- Skill bundle description

## Phase 7: Update Templates

- All `.tmpl` files: replace hardcoded `docs/` with `{{BASE_DIR}}/`
- AGENTS.md.tmpl: paths reference `{{BASE_DIR}}/`
- CLAUDE.md.tmpl: planDirectory reference

---

## Verification

- [ ] `bootstrap.sh` runs standalone, creates full scaffold
- [ ] Existing `docs/` detected and user prompted
- [ ] New repo path: git init + commit works
- [ ] Existing repo path: branch + commit works
- [ ] `.claude/settings.json` generated with correct planDirectory
- [ ] AGENTS.md < 120 lines after generation
- [ ] All paths in generated files use chosen base dir
- [ ] Skill validates via `quick_validate.py`
