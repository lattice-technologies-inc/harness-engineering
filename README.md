<p align="center">
  <strong>harness-engineering</strong><br>
  <em>Agent-first development toolkit for Claude Code</em>
</p>

<p align="center">
  <a href="#install">Install</a> &middot;
  <a href="#skills">Skills</a> &middot;
  <a href="#commands">Commands</a> &middot;
  <a href="#hooks">Hooks</a> &middot;
  <a href="#contributing">Contributing</a>
</p>

---

Bootstrap knowledge bases, shape requirements, breadboard systems, and enforce standards — all from inside Claude Code.

Built on the methodology behind ~1M LOC across 1,500 PRs with zero manually-written code.

## What's Inside

| Component | Count | Summary |
|-----------|------:|---------|
| **Skills** | 5 | harness-engineering, git-worktree, shaping, tdd, playwright-cli |
| **Commands** | 8 | `/harness-init`, `/harness-shape`, `/shaping`, `/breadboarding`, and more |
| **Hooks** | 4 | Lint-on-save, shaping ripple checks, plan capture, plan pipeline |
| **MCP Servers** | 1 | [context7](https://context7.com) — framework documentation lookup |

## Install

### From the marketplace (recommended)

Inside Claude Code:

```
/plugin marketplace add hbruceweaver/harness-engineering
/plugin install harness-engineering@harness-engineering-marketplace
```

### From a local clone

```bash
git clone https://github.com/hbruceweaver/harness-engineering.git
cd harness-engineering

# Load for a single session
claude --plugin-dir .
```

### From a local path (persistent)

```
/plugin marketplace add /path/to/harness-engineering
/plugin install harness-engineering@harness-engineering-marketplace
```

> **Scope options:** Add `--scope project` to share with your team (writes to `.claude/settings.json`) or `--scope local` for this repo only (gitignored).

## Quick Start

```
/harness-init          # Bootstrap knowledge base in your repo
/harness-shape         # Fill placeholders with real project context
/shaping               # Shape a feature (requirements + solution options)
/breadboarding         # Map system into affordance tables
```

**New repo:**
```
/harness-init  -->  /harness-shape  -->  /harness-eslint (optional)
```

**Existing repo:**
```
/harness-init  -->  /harness-onboard  -->  /harness-shape  -->  /harness-eslint (optional)
```

## Skills

### harness-engineering

Bootstrap an agent-first knowledge base in any repository. Creates `AGENTS.md`, structured docs, golden principles, quality scoring, and mechanical enforcement.

What gets scaffolded:
- `AGENTS.md` — table of contents (not an encyclopedia)
- `ARCHITECTURE.md` — domain map
- `docs/` — golden principles, quality scores, tech debt tracker, design docs, plans pipeline
- `.claude/` — commands, hooks, settings
- `scripts/harness/knowledge-check.sh` — CI-ready structural checks

### shaping

[Shape Up](https://basecamp.com/shapeup) methodology adapted for LLMs. Three commands covering the full pre-code workflow:

| Command | Phase | Output |
|---------|-------|--------|
| `/shaping` | Define problem + solution options | Requirements (R), Shapes (S), fit checks |
| `/breadboarding` | Map into concrete affordances | Places, UI/Code affordances, wiring, vertical slices |
| `/breadboard-reflection` | Validate design | Smell detection, naming tests, wiring coherence |

### tdd

Test-driven development with vertical red-green-refactor loops. Enforces behavior-over-implementation testing, boundary-only mocking, and incremental tracer bullet workflow.

### git-worktree

Manage Git worktrees for isolated parallel development. Handles env file copying, `.worktree-config` for multi-agent coordination, and cleanup.

### playwright-cli

Playwright-powered browser automation CLI. Full browser control with snapshots, tabs, cookies, network mocking, tracing, and CDP support (connect to Arc, Chrome, Edge).

## Commands

| Command | Description |
|---------|-------------|
| `/harness-init` | Bootstrap knowledge base scaffolding |
| `/harness-shape` | Fill placeholders with real project context |
| `/harness-standards` | Alias for `/harness-shape` |
| `/harness-onboard` | Audit existing repo and generate gap-fill plan |
| `/harness-eslint` | Add agent-readable ESLint enforcement (JS/TS) |
| `/shaping` | Iterate on requirements and solution shapes with fit checks |
| `/breadboarding` | Map systems into affordance tables with wiring |
| `/breadboard-reflection` | Validate breadboard design for smells |

## Hooks

| Hook | Trigger | What it does |
|------|---------|--------------|
| **lint-on-save** | `PostToolUse` on Edit/Write | Runs ESLint, ruff, or shellcheck and feeds errors back to the agent |
| **shaping-ripple** | `PostToolUse` on Edit/Write | Checks if shaping doc edits need to ripple to related docs |
| **plan-capture** | `PostToolUse` on ExitPlanMode | Reminds agent to file the approved plan in `docs/plans/` |
| **plan-pipeline** | `Stop` | Verifies plans are in the correct pipeline stage before session ends |

## ESLint Rules

The bundled `eslint-plugin-harness` ships 6 agent-readable rules for JS/TS repos:

| Rule | Why |
|------|-----|
| `no-console-log` | No committed `console.log` — use structured logging |
| `no-default-export` | Named exports only — highest leverage for agent grep-ability |
| `no-eval` | Block `eval()` and `new Function()` |
| `filename-match-export` | Filename matches the single named export |
| `structured-logging` | Static message + metadata object pattern |
| `max-file-lines` | Keep files under 500 LOC |

## Project Structure

```
harness-engineering/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace catalog
├── skills/
│   ├── harness-engineering/     # Bootstrap + onboard + standards
│   ├── shaping/                 # Shape Up methodology
│   ├── tdd/                     # Test-driven development
│   ├── git-worktree/            # Parallel development
│   └── playwright-cli/          # Browser automation
├── commands/                    # 8 slash commands
├── hooks/
│   └── hooks.json               # Hook configuration
├── scripts/                     # Hook scripts
├── .mcp.json                    # MCP server config
├── CHANGELOG.md
└── LICENSE
```

## Updating

```
/plugin marketplace update harness-engineering-marketplace
/plugin uninstall harness-engineering@harness-engineering-marketplace
/plugin install harness-engineering@harness-engineering-marketplace
```

## Contributing

1. Clone the repo
2. Make changes
3. Test locally: `claude --plugin-dir .`
4. Use [Conventional Commits](https://www.conventionalcommits.org/): `feat|fix|refactor|docs|chore`
5. Update version in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
6. Update `CHANGELOG.md`

## License

[MIT](LICENSE)
