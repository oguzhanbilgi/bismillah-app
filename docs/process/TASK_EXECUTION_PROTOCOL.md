# Task Execution Protocol

The ordered procedure Claude follows for every task.

1. Read `CLAUDE.md` and its imported files.
2. Git preflight (`status`, `branch`, `rev-parse HEAD`, `rev-parse origin/main`, `diff --check`).
3. Confirm the exact required starting branch and commit.
4. `git fetch origin --prune --tags` and `git pull --ff-only origin main`; re-verify.
5. Create one narrow task branch.
6. Inspect existing code before editing.
7. Make only scoped changes.
8. Format changed files.
9. Run focused tests.
10. Run analyze / lint.
11. Run full tests when required.
12. Build when platform / dependency / native code changes.
13. Run real-device validation when the task requires it.
14. Inspect the full diff.
15. Stage only intended files.
16. Commit with a scoped message.
17. Push the task branch.
18. Open a PR.
19. Wait for CI.
20. Merge only after all required gates pass.
21. Verify `main` after merge.
22. Update the project-memory files (see `PROJECT_MEMORY_UPDATE_PROTOCOL.md`).

## Stop conditions

Do not start a new task, and do not proceed, when any of these hold:

- Starting commit mismatch
- Unexpected tracked changes
- Test failure
- Analyze / lint failure
- Unexpected dependency churn
- Secret exposure
- Data-loss possibility
- Required device absent
- Religious source uncertainty
- CI failure
- Scope ambiguity

When a stop condition is hit, report the real state and the blocker, and wait for
new instructions instead of forcing a workaround.
