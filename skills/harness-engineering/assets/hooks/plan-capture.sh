#!/usr/bin/env bash
# Harness Engineering — Plan Capture Hook
#
# Fires after ExitPlanMode (plan approved). Reminds agent to:
# 1. Symlink the plan into docs/plans/ with a proper dated slug name
# 2. Create a plan-details directory with a scratchpad
#
# Exit 2 = feedback injected into agent context

cat >&2 <<'MSG'
Plan approved — capture it in the plans pipeline:

1. Find the plan file you just wrote (check the plan directory configured in .claude/settings.json)
2. Create a symlink in docs/plans/ with a proper name:
   ln -s <path-to-original-plan> docs/plans/<slug>-YYYY-MM-DD.md
   - <slug> = short descriptive kebab-case name based on the plan content
   - YYYY-MM-DD = today's date
3. Create a matching plan-details directory with a scratchpad:
   mkdir -p docs/plan-details/<slug>/
   Create docs/plan-details/<slug>/scratchpad.md with this template:
   ---
   # Scratchpad — <Plan Name>
   Working notes for this plan. Document learnings, failures, and discoveries here.
   ---
4. The symlink goes in docs/plans/ (draft stage) — move it through the pipeline as work progresses

If the plan file is already in docs/plans/ with a proper name, just verify the naming convention
and ensure docs/plan-details/<slug>/scratchpad.md exists.
MSG
exit 2
