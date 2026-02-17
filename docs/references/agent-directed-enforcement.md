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

In harness-engineering, the analog is:
- `/harness-standards` to fill placeholders and encode guardrails
- `/harness-onboard` to generate a gap-fill plan for existing repos

## What We Ship Here

This repository includes a minimal, stack-agnostic enforcement loop:

```bash
bash scripts/harness/knowledge-check.sh
```

It checks that the agent knowledge base exists and stays small/legible.

## Lint Rule Categories (From Factory's Linting Article)

The Factory team published a companion article on using linters to direct agents. Their taxonomy of agent-focused lint categories:

| Category | What It Enforces | Our Rules |
|----------|-----------------|-----------|
| **Grep-ability** | Named exports, consistent error types, explicit DTOs | `no-default-export`, `filename-match-export` |
| **Glob-ability** | Predictable file structure, deterministic placement | `max-file-lines` |
| **Architectural boundaries** | Cross-layer import prevention, domain boundaries | *(project-specific — add per repo)* |
| **Security & privacy** | Block eval, require input validation, no secrets | `no-eval` |
| **Testability** | Colocated tests, no network in unit tests | *(add per repo)* |
| **Observability** | Structured logging, error metadata, telemetry naming | `no-console-log`, `structured-logging` |
| **Documentation signals** | Module-level docstrings, public API docs | *(add per repo)* |

Key insight: "If you adopt only one category, adopt grep-ability." Named exports + deterministic file placement let agents `ripgrep` for definitions and predict file locations.

## The Lint Development Cycle

1. **Observe drift** — spot a recurring anti-pattern in review
2. **Codify the rule** — write an ESLint rule with agent-readable remediation
3. **Surface violations** — run across the repo, triage by risk
4. **Remediate at scale** — spawn agents to apply fixes in batches
5. **Prevent regressions** — wire into CI, pre-commit, agent toolchains

## AGENTS.md + Linters: Complementary, Not Redundant

- **AGENTS.md** = the "why" and the examples. Maps each guideline to rules and docs.
- **Linters** = the "how" and the guarantee. Blocks violations, provides machine feedback.

Guidance alone has failure modes: ambiguity, no enforcement, limited cross-file reach. Linters turn intent into a compiler-like contract.

## Next Step: Project-Specific Enforcement

Once the stack is real (JS/TS, Python, Ruby, etc.), add the *next* enforcement layer:
- language lints/formatters
- architecture boundary checks (cross-layer import prevention)
- "tests required" policies (colocated test enforcement)
- reliability budgets for critical paths
- migration-driven linting (encode "new way" as rules, autofix "old way")

Keep the goal tight: reduce whole classes of agent mistakes.

