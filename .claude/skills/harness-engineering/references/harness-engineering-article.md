# Harness Engineering: Leveraging Codex in an Agent-First World

> Source: OpenAI blog, by Ryan Lopopolo
> Key reference for the harness-engineering skill design

## Key Insights

### Architecture
- AGENTS.md is ~100 lines, table of contents only
- Deep knowledge in structured `docs/` directory
- Progressive disclosure: entry point → doc → code
- Plans are first-class versioned artifacts

### Tooling That Matters
- **Chrome DevTools Protocol** wired into agent runtime — DOM snapshots, screenshots, navigation
- **Local observability stack** per worktree — logs (LogQL), metrics (PromQL), traces (TraceQL)
- App bootable per git worktree for isolated validation
- Custom linters with agent-readable error messages
- Structural tests enforcing domain boundaries
- "Doc-gardening" agent for stale doc cleanup

### Enforcement
- Custom linters enforce: structured logging, naming conventions, file size limits, reliability requirements
- Lint error messages written as remediation instructions (agent-readable)
- Layered domain architecture: Types → Config → Repo → Service → Runtime → UI
- Cross-cutting via explicit Providers interface
- Dependency direction validation

### Quality Loop
- "Golden principles" encoded in repo — mechanical rules
- Recurring background Codex tasks: scan deviations, update quality grades, open refactoring PRs
- Quality scores per domain graded regularly
- Tech debt tracked continuously, not in bursts
- Friday cleanup replaced by automated garbage collection

### Agent Autonomy Chain
1. Validate codebase state
2. Reproduce bug
3. Record video of failure
4. Implement fix
5. Validate fix by driving the app
6. Record resolution video
7. Open PR
8. Respond to feedback
9. Detect/remediate build failures
10. Escalate only when judgment required
11. Merge

### Philosophy
- No manually-written code constraint
- "What capability is missing?" not "try harder"
- Boring tech preferred (composability, API stability, training set presence)
- Sometimes cheaper to reimplement than work around opaque upstream
- Human taste fed back as doc updates or encoded into tooling
- Corrections cheap, waiting expensive
