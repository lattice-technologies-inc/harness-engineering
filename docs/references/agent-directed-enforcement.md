# Agent-Directed Enforcement (Linters As Steering)

This repo is set up around the harness-engineering idea: agents execute, humans steer.

One of the highest-leverage steering mechanisms is **mechanical enforcement**:
- encode invariants once
- surface violations with **agent-readable remediation**
- run checks continuously (CI, pre-push, background sweeps)

## What We Mean By "Invariants"

Examples of invariants that keep agent output coherent:
- file location and naming conventions (so agents know where to put things)
- boundary validation rules (schemas at the edges, trust internals)
- structured logging conventions (no ad-hoc logs)
- file size limits (split before 500 LOC)
- tests required for product code (regression tests for bug fixes)

## Reference Implementations

### Factory-AI ESLint Plugin (Inspiration)

Factory published an ESLint plugin repo (`Factory-AI/eslint-plugin`) demonstrating:
- custom lint rules that encode conventions (file organization, testing, logging)
- per-rule markdown docs under `rules/<rule-name>/README.md`
- lint messages written like "do X instead" so an agent can repair quickly

Recommendation: treat it as an idea bank, not a dependency you blindly import.

### Droidz (Process + Commands)

Droidz is a framework that operationalizes a set of slash commands and artifacts
to keep AI development consistent. The part we borrow most directly is the idea of a
"Phase 0: standards shaping" step after bootstrap.

In HyperClaw, the analog is:
- `/harness-standards` to fill placeholders and encode guardrails
- `/harness-onboard` to generate a gap-fill plan for existing repos

## What We Ship Here

This repository includes a minimal, stack-agnostic enforcement loop:

```bash
bash scripts/harness/knowledge-check.sh
```

It checks that the agent knowledge base exists and stays small/legible.

## Next Step: Project-Specific Enforcement

Once the stack is real (JS/TS, Python, Ruby, etc.), add the *next* enforcement layer:
- language lints/formatters
- architecture boundary checks
- "tests required" policies
- reliability budgets for critical paths

Keep the goal tight: reduce whole classes of agent mistakes.

