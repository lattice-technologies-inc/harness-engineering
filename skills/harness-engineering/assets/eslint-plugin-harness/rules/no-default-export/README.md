# harness/no-default-export

Disallow `export default`. Enforce named exports exclusively.

## Why

Named exports are the single highest-leverage convention for agent-native codebases:

- **Grep-able**: `ripgrep` can precisely locate `export const Foo` and all `import { Foo } from ...`
- **Deterministic**: agents can predict symbol names from filenames and vice versa
- **Refactor-safe**: rename refactors are precise; default exports create ambiguity at import sites
- **Better tooling**: LSP go-to-definition, find-references, and auto-import all work more reliably

The Factory linting article calls this: "If you adopt only one category, adopt this one."

## Examples

### Bad

```js
export default function createUser(data) { ... }
```

### Good

```js
export function createUser(data) { ... }
```

## When to Disable

Legacy codebases with heavy default export usage may want to start with `"warn"` and migrate incrementally. Framework entry points (e.g., Next.js pages) that require default exports can use inline `// eslint-disable-next-line harness/no-default-export`.
