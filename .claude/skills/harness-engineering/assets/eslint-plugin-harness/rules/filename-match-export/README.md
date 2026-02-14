# harness/filename-match-export

When a file has exactly one named export, enforce that the filename matches the exported symbol.

Why this exists (agent-first):
- Mechanical discoverability: agents can guess where code lives.
- Reduced "where should I put this" ambiguity.

Scope (intentionally narrow):
- Only triggers when there is exactly one `export` declaration with a direct declaration:
  - `export function Foo() {}`
  - `export class Foo {}`
  - `export const Foo = ...`
- Skips `index.*` files.

How to fix:
- Rename the file to match the export, or rename the export to match the file.

