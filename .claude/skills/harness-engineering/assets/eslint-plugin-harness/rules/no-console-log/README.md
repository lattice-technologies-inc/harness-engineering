# harness/no-console-log

Disallow committed `console.log` / `console.debug` / `console.info`.

Why this exists (agent-first):
- Console logging is easy for agents to spray everywhere.
- It quickly becomes noise and degrades observability.
- A crisp linter error is faster for an agent to remediate than a review comment.

What to do instead:
- Use the repo's structured logger.
- For temporary debugging, keep it on a local branch and do not commit.

