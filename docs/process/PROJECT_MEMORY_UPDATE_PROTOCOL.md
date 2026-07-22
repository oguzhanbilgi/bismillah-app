# Project Memory Update Protocol

After each **merged** task, update the project memory so the next session starts
from an accurate baseline.

## Fields to update

- Current main commit (read from Git; see the source-of-truth rule below)
- Current task status and next task
- Test counts (Flutter / storage / Functions)
- New validation evidence
- New blocker(s)
- Dependency status (open/deferred/superseded PRs)
- Device validation status
- Store / revenue milestone progress
- Relevant checkpoint history entry

## Files typically touched

- `docs/project-state/CURRENT_BASELINE.md`
- `docs/project-state/TASK_INDEX.md`
- `docs/project-state/MASTER_EXECUTION_ROADMAP.md` (status changes only)
- `docs/project-state/MASTER_PROJECT_STATE.json` (keep valid JSON)
- `docs/task-reports/CHECKPOINT_HISTORY.md` (at checkpoints)

## Rules

- The live Git HEAD / `origin/main` are authoritative for the current commit.
  Stored commit fields represent the last verified baseline at documentation time —
  never write a task-branch commit as if it were canonical `main`.
- Do not mark a task COMPLETED before its PR is actually merged.
- Do not change a test count without terminal evidence from an actual run.
- If a required device test was not performed, write `PENDING`.
- Do not show a blocked task as completed.
- Do not dump raw terminal logs into memory; write short, verified results.
- When an earlier decision changes, mark the old record **SUPERSEDED** — do not
  silently delete it.
