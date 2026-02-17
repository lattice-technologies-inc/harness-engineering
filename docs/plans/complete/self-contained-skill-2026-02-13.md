# Plan: Make harness-engineering Skill 100% Self-Contained

**Date**: 2026-02-13

## Context

The harness-engineering skill currently has its core assets bundled (templates, ESLint plugin, scripts, references) but depends on 4 slash commands, 1 hook, and 1 companion skill that live OUTSIDE the skill directory. This means installing the skill alone isn't enough — you'd need to manually place commands, hooks, and the git-worktree skill separately.

Goal: a single `harness-engineering/` directory that contains everything. When deployed to any repo, `bootstrap.sh` creates the full knowledge base AND installs all tooling (commands, hooks, companion skills).

## What Gets Bundled

| Component | Source (current) | Destination (inside skill) |
|-----------|-----------------|---------------------------|
| `/harness-init` | `.claude/commands/harness-init.md` | `assets/commands/harness-init.md` |
| `/harness-onboard` | `.claude/commands/harness-onboard.md` | `assets/commands/harness-onboard.md` |
| `/harness-standards` | `.claude/commands/harness-standards.md` | `assets/commands/harness-standards.md` |
| `/harness-eslint` | `.claude/commands/harness-eslint.md` | `assets/commands/harness-eslint.md` |
| lint-on-save hook | `.claude/hooks/lint-on-save.sh` | `assets/hooks/lint-on-save.sh` |
| git-worktree skill | `.claude/skills/git-worktree/` | `assets/skills/git-worktree/` (SKILL.md + scripts/) |

**NOT bundled** (external marketplace plugins — recommend only):
- `agent-browser` — compound-engineering plugin, installed separately
- `chrome-devtools` — compound-engineering plugin, installed separately

## Implementation Steps

### Phase 1: Move assets into skill

1. Create `assets/commands/` inside harness-engineering, copy 4 command files there
2. Create `assets/hooks/` inside harness-engineering, copy lint-on-save.sh there
3. Create `assets/skills/git-worktree/` inside harness-engineering, copy SKILL.md + scripts/ there
4. Remove the originals from `.claude/commands/`, `.claude/hooks/`, `.claude/skills/git-worktree/`

### Phase 2: Update bootstrap.sh — deploy tooling section

Add a new section after the existing Claude settings block that deploys:

```
--- Agent tooling ---
.claude/commands/harness-init.md
.claude/commands/harness-onboard.md
.claude/commands/harness-standards.md
.claude/commands/harness-eslint.md
.claude/hooks/lint-on-save.sh
.claude/skills/git-worktree/SKILL.md
.claude/skills/git-worktree/scripts/worktree-manager.sh
```

These are TOOLING files (not user content), so bootstrap should **overwrite** them on re-run to allow updates. Use a separate `deploy_tool()` helper (always copies, no skip-if-exists).

### Phase 3: Update settings.json creation

The current bootstrap creates a minimal settings.json:
```json
{ "planDirectory": "docs/plans" }
```

Extend to include the hook config:
```json
{
  "planDirectory": "docs/plans",
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/lint-on-save.sh",
        "timeout": 30
      }]
    }]
  }
}
```

If settings.json already exists, **merge** the hooks config rather than skipping entirely. Use a simple check: if it exists but has no "hooks" key, patch it. If it has hooks already, skip.

### Phase 4: Update SKILL.md

- Update Resources section to list all bundled assets (commands, hooks, skills)
- Update the flow diagram to show tooling deployment
- Add "What Gets Deployed" section listing everything bootstrap installs

### Phase 5: Update command paths

The command files reference skill paths like:
```
bash .claude/skills/harness-engineering/scripts/bootstrap.sh
```

These paths remain correct after the move — commands reference the skill's scripts, not the assets. No changes needed.

The git-worktree skill gets deployed to `.claude/skills/git-worktree/`, so its paths also remain clean.

## Files to Modify

| File | Action |
|------|--------|
| `harness-engineering/assets/commands/harness-init.md` | CREATE (copy from .claude/commands/) |
| `harness-engineering/assets/commands/harness-onboard.md` | CREATE (copy from .claude/commands/) |
| `harness-engineering/assets/commands/harness-standards.md` | CREATE (copy from .claude/commands/) |
| `harness-engineering/assets/commands/harness-eslint.md` | CREATE (copy from .claude/commands/) |
| `harness-engineering/assets/hooks/lint-on-save.sh` | CREATE (copy from .claude/hooks/) |
| `harness-engineering/assets/skills/git-worktree/SKILL.md` | CREATE (copy from .claude/skills/git-worktree/) |
| `harness-engineering/assets/skills/git-worktree/scripts/worktree-manager.sh` | CREATE (copy) |
| `harness-engineering/scripts/bootstrap.sh` | EDIT — add tooling deployment section |
| `harness-engineering/SKILL.md` | EDIT — update resources + "What Gets Deployed" |
| `.claude/commands/harness-*.md` | DELETE (moved into skill) |
| `.claude/hooks/lint-on-save.sh` | DELETE (moved into skill) |
| `.claude/skills/git-worktree/` | DELETE (moved into skill) |

## Verification

1. Run `ls -R .claude/skills/harness-engineering/assets/` — confirm commands, hooks, skills all present
2. Run bootstrap on a temp dir:
   ```bash
   mkdir /tmp/test-harness && cd /tmp/test-harness && git init
   bash /path/to/bootstrap.sh --target . --name "Test"
   ```
3. Verify all files deployed:
   - `.claude/commands/harness-*.md` (4 files)
   - `.claude/hooks/lint-on-save.sh` (executable)
   - `.claude/skills/git-worktree/SKILL.md` + scripts/
   - `.claude/settings.json` with hooks config
4. Run bootstrap again on same dir — verify idempotent (tooling files overwritten, user content skipped)
