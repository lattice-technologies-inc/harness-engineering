# harness/structured-logging

Enforce structured logging with static message strings and metadata objects.

Why this exists (agent-first):
- Agents default to template literals in log messages, making logs unsearchable.
- Structured logging (static message + metadata object) enables grep, aggregation, and alerting.
- A lint error is faster for an agent to fix than a review comment.

What triggers this rule:
- Template literals with expressions in logging calls: `` logger.error(`Failed for ${userId}`) ``
- String concatenation in logging calls: `logger.info("User " + userId + " logged in")`

What to do instead:
```js
// Good: static message + metadata
logger.error("Failed to process request", { userId, orderId });
logger.info("User logged in", { userId, timestamp: Date.now() });

// Good: no dynamic content in message
logger.warn("Rate limit exceeded");
```

Detected logging patterns:
- `logger.info/warn/error/debug/trace/fatal(...)`
- `logError(...)`, `logInfo(...)`, etc.
- `console.warn(...)`, `console.error(...)` (if not caught by no-console-log)

Scope:
- Only checks the first argument (the message). Metadata objects in later arguments are fine.
- Static template literals (no expressions) are allowed.
