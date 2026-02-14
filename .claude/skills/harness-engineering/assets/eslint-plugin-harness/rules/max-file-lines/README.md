# harness/max-file-lines

Enforce maximum file length (default: 500 lines) to keep code legible.

Why this exists (agent-first):
- Large files overwhelm agent context windows and cause partial reads.
- Agents are more accurate when files have a single, clear responsibility.
- This rule makes the "< 500 LOC" golden principle mechanically enforceable.

Options:
```json
{
  "harness/max-file-lines": ["warn", { "max": 500, "skipBlankLines": true, "skipComments": true }]
}
```

- `max` (default: 500) — maximum non-blank, non-comment lines
- `skipBlankLines` (default: true) — don't count empty lines
- `skipComments` (default: true) — don't count comment-only lines

How to fix:
- Extract helper functions into separate modules
- Move types/interfaces to a `types.ts` file
- Move constants to a `constants.ts` file
- Split along domain boundaries (one concern per file)
- If a component is too long, extract sub-components

Differs from ESLint built-in `max-lines`:
- Agent-readable error message with remediation steps
- Points to `docs/golden-principles.md` for context
- Defaults to 500 (the harness standard)
