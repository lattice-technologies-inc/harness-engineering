Bootstrap an agent-first knowledge base in this repository using the harness-engineering skill.

Follow the workflow in `.claude/skills/harness-engineering/SKILL.md`:

1. Pre-flight: check which files already exist (idempotent — skip existing)
2. Gather context: ask for project name, one-liner, stack, domains
3. Create directory structure with .gitkeep files
4. Generate all files from templates in `.claude/skills/harness-engineering/assets/templates/`, substituting placeholders
5. Git init + commit (or add to existing repo)
6. Report summary

Read the SKILL.md first, then execute each step.
