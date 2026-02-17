---
name: shaping
description: Start or continue a shaping session — iterate on requirements (R) and solution shapes (S) with fit checks.
---

Read the shaping skill, then read the full shaping reference at the skill's `references/shaping.md`.

You MUST read the entire reference file before proceeding. Do NOT skip or skim — the methodology has specific notation, conventions, and anti-patterns that must be followed exactly.

After reading, begin the shaping session:
- If starting fresh, create both:
  - Plan file: `docs/plans/<slug>-YYYY-MM-DD.md` (links to details directory)
  - Details directory: `docs/plan-details/<slug>/` (with `frame.md` and `shaping.md`)
- Write shaping output to `docs/plan-details/<slug>/shaping.md` (with `shaping: true` frontmatter)
- Also create `frame.md` in the details directory for problem definition, appetite, and constraints
- If no shaping doc exists, offer both entry points (start from R or start from S)
- If a shaping doc exists, display the fit check for the selected shape and summarize what's unsolved
