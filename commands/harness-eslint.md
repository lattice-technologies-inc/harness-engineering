---
name: harness-eslint
description: "Add optional ESLint-based mechanical enforcement to steer agents (JS/TS repos)."
argument-hint: ""
---

Add optional ESLint-based mechanical enforcement to steer agents (JS/TS repos).

This is an optional add-on inspired by the "enforce invariants" idea in harness engineering. It scaffolds:
- A tiny local ESLint plugin with agent-readable messages (`tools/eslint-plugin-harness/`)
- An `eslint.config.cjs` that wires it in
- A `lint` script in `package.json` (if missing)

Find the harness-engineering skill directory and run:

```bash
bash <skill-dir>/scripts/add-eslint-agent-lints.sh --target "$(pwd)" --install
```

Notes:
- If you don't want installs, omit `--install` and install dependencies later.
- If ESLint is already configured, the script merges rather than overwrites.
- The plugin ships 6 rules: no-console-log, no-default-export, no-eval, filename-match-export, structured-logging, max-file-lines.
- Each rule has agent-readable remediation messages.

After running, verify with:
```bash
npx eslint . --max-warnings 0
```
