---
name: shaping
description: "Shape Up methodology adapted for LLMs. Three phases: /shaping (iterate on requirements and solution shapes with fit checks), /breadboarding (map systems into Places, UI affordances, Code affordances, and wiring), /breadboard-reflection (find and fix design smells in breadboards). Use when defining problems, exploring solutions, mapping systems, slicing into vertical scopes, or validating breadboard designs."
---

# Shaping Toolkit

Shape Up methodology adapted for working with an LLM. Three phases covering the full pre-code workflow: define the problem, design the solution, validate the design.

## Workflow

```
/shaping → /breadboarding → /breadboard-reflection → build
```

| Phase | Command | When to use |
|-------|---------|-------------|
| **Shape** | `/shaping` | Define problem (R) and solution options (S). Iterate with fit checks until a shape is selected. |
| **Breadboard** | `/breadboarding` | Map selected shape into concrete affordances (UI + Code) with wiring. Also used for slicing into vertical implementation increments. |
| **Reflect** | `/breadboard-reflection` | Validate a breadboard for design smells — incoherent wiring, naming resistance, missing paths, stale affordances. |

## Commands

### `/shaping` — Requirements and Shapes

**MANDATORY**: Before proceeding, read [references/shaping.md](references/shaping.md) in full.

Iterate on problem definition (requirements) and solution options (shapes). Produces:
- Requirements set (R0, R1, R2...)
- Shape options (A, B, C...) with parts/mechanisms
- Fit checks (R × S decision matrices)
- Spikes for unknowns

### `/breadboarding` — Affordance Mapping

**MANDATORY**: Before proceeding, read [references/breadboarding.md](references/breadboarding.md) in full.

Transform a shaped solution into concrete affordances with explicit wiring. Produces:
- Places table (bounded contexts of interaction)
- UI Affordances table (inputs, buttons, displays)
- Code Affordances table (methods, handlers, stores)
- Wiring (Wires Out = control flow, Returns To = data flow)
- Vertical slices (V1–V9) for implementation ordering

### `/breadboard-reflection` — Design Validation

**MANDATORY**: Before proceeding, read [references/breadboard-reflection.md](references/breadboard-reflection.md) in full.

Find and fix design smells in an existing breadboard. Checks for:
- Incoherent wiring (redundant or contradictory paths)
- Missing paths (user stories with no wiring)
- Naming resistance (affordances that can't be named with one verb)
- Stale/diagram-only affordances
- Implementation mismatches (code vs breadboard drift)

## File Conventions

Shaping produces two things:

1. **Plan file** (moves through pipeline): `docs/plans/<slug>-YYYY-MM-DD.md` — links to details
2. **Details directory** (permanent): `docs/plan-details/<slug>/` — supporting docs stay here

```
docs/plans/<slug>-YYYY-MM-DD.md          # plan card — moves draft → in-progress → complete

docs/plan-details/<slug>/     # permanent — never moves
  scratchpad.md      # working notes — learnings, failures, discoveries
  frame.md           # the "why" — problem definition, appetite, constraints
  shaping.md         # requirements (R), shapes (S), fit checks
  slices.md          # breadboard tables + vertical slices
  spike-<topic>.md   # investigation of unknowns
  V1-plan.md         # slice implementation plan
```

- Create both at the start of `/shaping` — plan file + details directory
- Plan file links to `../plan-details/<slug>/` for all supporting docs
- All shaping documents use `shaping: true` frontmatter (enables the ripple-check hook)
- **Plan lifecycle**: only the plan file moves — `docs/plans/` → `in-progress/` → `complete/`

## Key Principles

- **Tables are the source of truth** — Mermaid diagrams render them, not the other way around
- **Fit check is binary** — ✅ or ❌ only, no ⚠️ in fit checks
- **Every slice must be demo-able** — no horizontal layers
- **Changes ripple across levels** — shaping doc ↔ slices doc ↔ slice plans must stay in sync
