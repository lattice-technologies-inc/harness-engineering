# Changelog

All notable changes to this plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-16

### Added

- Plugin manifest and structure
- 5 skills: harness-engineering, git-worktree, shaping (with /shaping, /breadboarding, /breadboard-reflection commands), tdd, playwright-cli
- 8 commands: harness-init, harness-shape, harness-standards, harness-onboard, harness-eslint, shaping, breadboarding, breadboard-reflection
- 4 hooks: lint-on-save (ESLint/ruff/shellcheck), shaping-ripple (breadboard consistency), plan-capture (symlink on plan approval), plan-pipeline (Stop hook — end-of-turn plan stage check)
- 1 MCP server: context7 (framework documentation lookup)
- Bootstrap script for scaffolding agent-first knowledge bases
- 15 knowledge base templates
- 6 agent-readable ESLint rules
- Git worktree management with env file handling
