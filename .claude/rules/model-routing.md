# Model routing

Project policy for delegating Bismillah work to subagents by risk. The three
project agents live in `.claude/agents/` and carry their model in frontmatter:

| Agent | Model | Tools |
|---|---|---|
| `bismillah-fast-auditor` | `haiku` | Read, Glob, Grep (read-only) |
| `bismillah-implementer` | `sonnet` | Read, Glob, Grep, Edit, Write, Bash |
| `bismillah-critical-reviewer` | `opus` | Read, Glob, Grep, Bash (review-only) |

## Low-risk investigation → `bismillah-fast-auditor` (haiku)

Delegate read-only questions:

- finding files, symbols or identifiers
- reading narrowly scoped repository state
- checking counts, IDs and totals
- inspecting test output that has already been produced
- checking whether a file appears in a diff
- compact documentation lookup
- mechanical comparison against acceptance criteria
- interpreting a CI status or result when no fix is required

Do **not** spin up a subagent for a single trivial read where the delegation
overhead exceeds the work. Read it directly.

## Normal product work → `bismillah-implementer` (sonnet)

Delegate ordinary implementation once scope is settled:

- routine Flutter UI
- normal Riverpod state changes
- local repositories and adapters with no migration
- ordinary localization and RTL changes
- accessibility improvements
- focused bug fixes
- standard tests
- routine project documentation

The main agent still owns scope, sequencing and final delivery.

## High-risk work → Opus review sandwich

Applies to any of:

- RevenueCat, subscriptions, entitlements, store payments
- authentication or account linking
- Firestore Security Rules or App Check
- remote sync
- schema migrations
- destructive persistence changes
- data deletion or any data-loss risk
- privacy-sensitive logging or history
- security boundaries
- release signing or production configuration
- major architecture changes
- religious-content governance or sensitive publication rules

Sequence, when practical:

1. `bismillah-critical-reviewer` plans or reviews the proposed approach
2. `bismillah-implementer` performs the approved implementation
3. `bismillah-critical-reviewer` reviews the final diff and tests

A reviewer verdict of `PASS` **does not** replace user approval or qualified
human review. It is one input to a human decision.

## Religious content

- Haiku may locate article IDs, source records, locators and existing review
  statuses.
- Opus may review governance risk, unsupported claims and locale-strength drift.
- **No agent may invent owner source-fidelity approval.**
- **No agent may invent qualified scholarly approval.**
- Production religious content stops at the real human-review gate whenever the
  task requires one; an agent may prepare, never approve.
- Full drafts stay **outside the repository** until approved, and are not pasted
  into chat unless explicitly requested.

## Efficiency

- Use the cheapest agent that can do the job correctly.
- Do not delegate the same inspection twice — reuse the answer.
- Do not re-read broad repository history.
- Run the full Flutter suite only once, and only when task risk requires it.
- Agents are not a reason to expand scope.
- Keep subagent responses compact; the main agent synthesizes rather than
  forwarding full agent output.

## Configuration safety

- **Never** set `CLAUDE_CODE_SUBAGENT_MODEL` globally — it overrides every
  agent's `model:` frontmatter, including critical review.
- Per-agent `model:` frontmatter is authoritative.
- Never silently fall back to Haiku for critical review.
- If an assigned model is unavailable, **report it**. Do not present a review
  performed by a different model as the requested review.
