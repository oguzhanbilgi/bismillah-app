# Bismillah — Claude Project Instructions

You are working on **Bismillah**, a privacy-first, offline-first Islamic daily
companion built with Flutter (Android-primary, iOS planned). This file is the
entry point to the project's permanent memory. Read the imported files before
planning, editing, testing, committing, or reviewing any task.

## Read before every task

@docs/project-state/CURRENT_BASELINE.md
@docs/project-state/MASTER_EXECUTION_ROADMAP.md
@docs/project-state/TASK_INDEX.md
@docs/project-state/DO_NOT_BREAK.md
@docs/process/TASK_EXECUTION_PROTOCOL.md
@docs/process/PROJECT_MEMORY_UPDATE_PROTOCOL.md
@docs/business/MONETIZATION_DECISIONS.md

Deeper references (read when relevant):
`docs/project-state/MASTER_PROJECT_REPORT.md`,
`docs/process/CHECKPOINT_PROTOCOL.md`,
`docs/setup/NEW_COMPUTER_SETUP.md`,
`docs/task-reports/CHECKPOINT_HISTORY.md`,
and the product vision in `Bismillah Engineering Constitution.md`.

## What you must always know

**Where the live state lives.** Do not trust any task number, commit or test
count hard-coded in this file. The authoritative sources, in order:

1. **Live Git HEAD / `origin/main`** — always authoritative for the current commit.
2. **`docs/project-state/CURRENT_BASELINE.md`** — current task, next task, verified
   test baselines, dependency status, blockers.
3. **`docs/project-state/MASTER_PROJECT_STATE.json`** — the same state, machine-readable.

Read those three before planning any work. Stored commit fields in documentation
record the last verified baseline **at documentation time**, never the live HEAD.

**Position at the time of writing** (verify against the sources above — it moves
with every merged task):

- Current checkpoint branch: **CP09 / TASK 075** — CP09 technical stabilization
  and full regression checkpoint (docs-only).
- Next task after the TASK 075 merge: **TASK 076** — DailyPlan repository and
  local persistence, the first task of **CP10**.

**Stable facts** (these do not drift with task numbers):

- Functions runtime baseline: **Node.js 22**.
- First possible real revenue: **TASK 115**. Commercial validation: **TASK 122**.
- Five fixed tabs: **Today, Prayer, Quran, Learn, Profile**. The **Assistant is a
  FAB / root route, never a sixth tab**.
- **Remote sync is disabled** and must stay disabled until the full Firebase gate
  order recorded in `CURRENT_BASELINE.md` is satisfied.

## Mandatory operating rules

- Repository code and current Git history override stale documentation.
- Never invent completed tasks, test results, sources, religious claims, or device validation.
- Follow the numbered execution roadmap; do not skip ahead without explicit user approval.
- Use one narrow branch per task; verify the exact starting branch and commit before editing.
- Do not read, modify, delete, stage, commit, or gitignore the untracked `AGENTS.md`.
- Do not commit secrets, credentials, build outputs, `node_modules`, local absolute
  paths, or raw chat transcripts.
- Do not merge when required tests, CI, device validation, or security checks fail.
- After each merged task, update `CURRENT_BASELINE.md`, `TASK_INDEX.md`, and the
  relevant checkpoint report (see the memory-update protocol).
- Keep reports short, except for auth, sync, migrations, payments, store billing,
  Firestore Security Rules, App Check, secrets, or data-loss risks.
- Preserve every rule in `DO_NOT_BREAK.md` and every guardrail in `MONETIZATION_DECISIONS.md`.

## Language rule

The primary working language for this project is **Turkish**. Write assistant
responses, task summaries, explanations, planning notes, and non-code documentation
in Turkish unless explicitly asked otherwise. Code, identifiers, package names, and
standard developer terminology stay in English. Permanent public/technical documents
in `docs/project-state`, `docs/process`, `docs/business`, and `docs/setup` are written
in English for portability; owner-facing communication remains Turkish.

The full product vision, design language, and engineering principles live in
`Bismillah Engineering Constitution.md` and `Bismillah Product Requirements Document.md`.
