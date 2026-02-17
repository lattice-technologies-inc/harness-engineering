# harness-engineering

Agent-first development toolkit for Claude Code. Bootstrap knowledge bases, shape requirements, breadboard systems, and enforce standards.

## Components

| Type | Count | Details |
|------|-------|---------|
| Skills | 5 | harness-engineering, git-worktree, shaping, tdd, playwright-cli |
| Commands | 8 | harness-init, harness-shape, harness-standards, harness-onboard, harness-eslint, shaping, breadboarding, breadboard-reflection |
| Hooks | 4 | lint-on-save (ESLint/ruff/shellcheck), shaping-ripple (breadboard consistency), plan-capture (symlink on plan approval), plan-pipeline (end-of-turn stage check) |
| MCP Servers | 1 | context7 (framework documentation lookup) |

## Skills

### harness-engineering

Bootstrap an agent-first knowledge base in any repository. Creates AGENTS.md, structured docs, golden principles, quality scoring, and mechanical enforcement. Based on the methodology that produced ~1M LOC across 1,500 PRs with zero manually-written code.

### git-worktree

Manage Git worktrees for isolated parallel development. Create, list, switch, and clean up worktrees with automatic env file handling.

### shaping

Shape Up methodology adapted for LLMs. One skill with three commands: `/shaping` (requirements + solution shapes with fit checks), `/breadboarding` (affordance mapping with Places, UI/Code affordances, and wiring), `/breadboard-reflection` (design smell detection and naming test validation). Full pre-code workflow from problem definition through vertical slicing.

### tdd

Test-driven development with vertical red-green-refactor loops. Enforces behavior-over-implementation testing, boundary-only mocking, deep module design, and incremental tracer bullet workflow.

### playwright-cli

Microsoft's Playwright-powered browser automation CLI. Full browser control with snapshots, tabs, cookies, localStorage, network mocking, tracing, and DevTools integration. Supports connecting to existing browser sessions via CDP (e.g. Arc on port 9222).

## Commands

| Command | Description |
|---------|-------------|
| `/harness-init` | Bootstrap knowledge base scaffolding |
| `/harness-shape` | Fill placeholders with real project context |
| `/harness-standards` | Alias for harness-shape |
| `/harness-onboard` | Audit existing repo + generate gap-fill plan |
| `/harness-eslint` | Add ESLint enforcement (JS/TS repos) |
| `/shaping` | Iterate on requirements (R) and solution shapes (S) with fit checks |
| `/breadboarding` | Map systems into affordance tables with wiring |
| `/breadboard-reflection` | Validate breadboard design for smells |

### Typical sequence

```
New repo:      /harness-init -> /harness-shape -> /harness-eslint (optional)
Existing repo: /harness-init -> /harness-onboard -> /harness-shape -> /harness-eslint (optional)
```

## Install

```bash
# Add the marketplace
/plugin marketplace add hbruceweaver/HyperClaw

# Install the plugin
/plugin install harness-engineering@hyperclaw
```

Or load directly during development:

```bash
claude --plugin-dir /path/to/HyperClaw
```

## License

MIT
