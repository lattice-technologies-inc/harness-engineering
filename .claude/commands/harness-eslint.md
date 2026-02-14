Add optional ESLint-based mechanical enforcement to steer agents (JS/TS repos).

This is an optional add-on inspired by the "enforce invariants" idea in harness engineering. It scaffolds:
- A tiny local ESLint plugin with agent-readable messages (`tools/eslint-plugin-harness/`)
- An `eslint.config.cjs` that wires it in
- A `lint` script in `package.json` (if missing)

Run:

```bash
bash .claude/skills/harness-engineering/scripts/add-eslint-agent-lints.sh --target "$(pwd)" --install
```

Notes:
- If you don’t want installs, omit `--install` and install dependencies later.
- This is meant as a starting point. Copy patterns from Factory’s plugin, but tailor rules to your repo.

