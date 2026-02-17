# Plan: Convert harness-engineering Repo into a Claude Code Plugin

## Context

The harness-engineering repo contains the harness-engineering skill, shaping skills, git-worktree skill, commands, and hooks — all currently scattered across `.claude/skills/`, `.claude/commands/`, `.claude/hooks/`, and `shaping-skills/`. We want to restructure it as a proper Claude Code plugin so it's installable via `/plugin install` and distributable via a marketplace.

**Reference implementation:** compound-engineering at `~/.claude/plugins/cache/every-marketplace/compound-engineering/2.34.0/`

## Target Structure

```
harness-engineering/
├── .claude-plugin/
│   └── plugin.json                  # Manifest (name, version, mcpServers)
├── skills/                          # 5 skills
│   ├── harness-engineering/         # Main skill (unchanged internals)
│   │   ├── SKILL.md
│   │   ├── scripts/ (bootstrap.sh, audit.sh, add-eslint-agent-lints.sh)
│   │   ├── assets/ (templates/, commands/, hooks/, skills/, eslint-plugin-harness/)
│   │   └── references/
│   ├── git-worktree/                # Worktree management
│   │   ├── SKILL.md
│   │   └── scripts/worktree-manager.sh
│   ├── shaping/SKILL.md            # Shape Up methodology
│   ├── breadboarding/SKILL.md      # Affordance tables + wiring
│   └── breadboard-reflection/SKILL.md  # Design smell detection
├── commands/                        # 5 plugin commands (frontmatter + ${CLAUDE_PLUGIN_ROOT})
│   ├── harness-init.md
│   ├── harness-shape.md
│   ├── harness-standards.md
│   ├── harness-onboard.md
│   └── harness-eslint.md
├── hooks/
│   └── hooks.json                   # PostToolUse config for both hooks
├── scripts/                         # Plugin-level hook scripts
│   ├── lint-on-save.sh
│   └── shaping-ripple.sh
├── .mcp.json                        # context7 MCP server
├── README.md                        # Plugin docs
├── CHANGELOG.md
├── LICENSE
├── CLAUDE.md                        # Updated with plugin dev section
├── AGENTS.md                        # Repo's own docs (stays)
├── ARCHITECTURE.md                  # Repo's own docs (stays)
└── docs/                            # Repo's own knowledge base (stays)
```

## Key Design Decision: Dual-Nature Commands

Commands exist in TWO versions:
- **`commands/`** (plugin root) — what users get when they install the plugin. Uses "Read the harness-engineering skill" and `${CLAUDE_PLUGIN_ROOT}` paths. Has YAML frontmatter.
- **`skills/harness-engineering/assets/commands/`** — what bootstrap.sh deploys to target repos. Uses explicit `.claude/skills/...` paths for standalone operation. No frontmatter.

When updating commands, update BOTH versions.

## Phases

### Phase 1: Create Plugin Scaffold
- Create `.claude-plugin/plugin.json` — name "harness-engineering", version "1.0.0", context7 MCP inline
- Create `.mcp.json` at root (fallback for inline mcpServers bug)
- Create `hooks/hooks.json` with lint-on-save + shaping-ripple config using `${CLAUDE_PLUGIN_ROOT}/scripts/`
- Create `LICENSE` (MIT)
- Create `CHANGELOG.md`

### Phase 2: Move Skills to Plugin Root
- Move `.claude/skills/harness-engineering/` → `skills/harness-engineering/`
- Move `.claude/skills/git-worktree/` → `skills/git-worktree/`
- Copy `shaping-skills/shaping/SKILL.md` → `skills/shaping/SKILL.md`
- Copy `shaping-skills/breadboarding/skill.md` → `skills/breadboarding/SKILL.md` (rename to uppercase)
- Copy `shaping-skills/breadboard-reflection/skill.md` → `skills/breadboard-reflection/SKILL.md` (already has frontmatter from earlier fix)

### Phase 3: Create Plugin Commands
Create 5 new command files in `commands/` with:
- YAML frontmatter (`name`, `description`, `argument-hint`)
- References to skills by name (not path)
- `${CLAUDE_PLUGIN_ROOT}` for script execution paths

### Phase 4: Set Up Plugin Hook Scripts
- Copy `.claude/hooks/lint-on-save.sh` → `scripts/lint-on-save.sh`
- Copy `shaping-skills/hooks/shaping-ripple.sh` → `scripts/shaping-ripple.sh`
- Both scripts are self-contained (read JSON from stdin) — no path changes needed

### Phase 5: Update Bootstrap for Shaping-Ripple Deploy
- Copy `shaping-ripple.sh` into `skills/harness-engineering/assets/hooks/`
- Update `bootstrap.sh`: deploy shaping-ripple hook to target repos
- Update `bootstrap.sh`: add shaping-ripple to settings.json hook config template

### Phase 6: Clean Up Old Locations
- Remove `.claude/commands/harness-*.md` (5 files)
- Remove `.claude/hooks/lint-on-save.sh`
- Remove `.claude/skills/` directory entirely (moved to plugin root)
- Simplify `.claude/settings.json` to `{"planDirectory": "docs/plans"}` only
- Remove `shaping-skills/` directory (content absorbed into plugin)

### Phase 7: Documentation
- Create `README.md` with component inventory, install instructions, usage
- Update `CLAUDE.md` with plugin development section (versioning, dual commands, hook locations)

## Files to Modify
- `skills/harness-engineering/scripts/bootstrap.sh` — add shaping-ripple deploy + settings.json hook
- `CLAUDE.md` — add plugin dev section

## Files That Don't Change
- `skills/harness-engineering/scripts/bootstrap.sh` path resolution — `SCRIPT_DIR=$(dirname "$0")` already resolves relative to wherever the script lives
- `skills/harness-engineering/assets/commands/` — deployed versions keep `.claude/` paths
- `skills/harness-engineering/assets/templates/` — unchanged
- `AGENTS.md`, `ARCHITECTURE.md`, `docs/` — repo's own content

## Verification
1. `claude plugin validate .` — validate plugin structure
2. `claude --plugin-dir .` — load plugin locally, verify 5 skills + 5 commands + 2 hooks + 1 MCP
3. Run `/harness-engineering:harness-init` on a temp dir — verify bootstrap works from plugin context
4. Verify deployed target repo works standalone (commands reference `.claude/` paths correctly)
