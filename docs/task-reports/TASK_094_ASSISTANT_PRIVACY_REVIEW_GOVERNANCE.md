# TASK 094 — Learn/Assistant security, language and RTL checkpoint

Status: **PARTIAL / IN PROGRESS — NOT COMPLETE**
Checkpoint: **CP11 — Learn and Assistant depth**
Branch: `task/094-assistant-privacy-review-governance`
Starting commit: `0f69ea7`

## Scope actually delivered, and what remains open

TASK 094's roadmap title is "Learn/Assistant **security, language and RTL**
checkpoint"; `TASK_INDEX.md` calls it "Learn/Assistant depth checkpoint". It is a
one-line entry with **no acceptance criteria**. The owner pulled it forward to
close one specific privacy defect and scoped it explicitly, so this delivery is
recorded as **PARTIAL** by owner decision.

**Closed by this delivery:**

- **Finding F1** — Assistant sensitive-query persistence / privacy hardening
- the formal **`editorialReview`** definition

**Still OPEN under TASK 094 — not closed, no owning follow-up task yet:**

- **language verification**
- **RTL verification**
- **Finding F2** — `app_source_reference.dart` duplicates `sources.json` with no
  cross-check

Recording TASK 094 COMPLETE would falsely close language/RTL and F2, so it is
deliberately not marked complete. No `TASK 094A` was invented.

## The confirmed privacy defect (F1)

`assistant_providers.dart` decided persistence with an **inline duplicate list**:

```dart
final sensitive =
    queryClass == AssistantQueryClass.personalCase ||
    queryClass == AssistantQueryClass.halalHaramVerdict;
```

**`worshipRule` was missing**, so sensitive worship-rule query pairs — including
the raw user question text — **were persisted** to SharedPreferences key
`bismillah.assistant_history`. `DO_NOT_BREAK.md` states "Sensitive verdict queries
are not persisted." The classifier's own `isSensitiveVerdict` already included
`worshipRule` but had **zero production callers**.

Only that one key ever receives Assistant query text — no Drift table, no sync
queue, no other key (verified).

## Single canonical sensitivity predicate

`AssistantQueryClassifier.isSensitiveVerdict` is now an **exhaustive `switch`
expression over `AssistantQueryClass` with no `default` and no wildcard**, so
adding an enum value is a **compile error**, not a silent `false`. It returns true
for `personalCase`, `halalHaramVerdict` and `worshipRule`.

`assistant_providers.dart` now calls that predicate. **No duplicate sensitivity
list remains in any persistence path** (verified by grep across `lib/`). The
helper now has its first production caller.

## Legacy records already on disk (owner decision)

`queryClass` was never persisted and `answerType` is not a usable proxy
(`worshipRule` maps to `generalSourceSummary` or `noVerifiedSource`, both shared
with non-sensitive classes). But the raw `text` **is** stored and
`classify(String)` is static and pure, so detection re-classifies stored text on
read.

`load()` now prunes any user-role message whose stored text re-classifies as
sensitive, plus the immediately-following entry **only if its `role == assistant`**
— a **role check, never index parity**, because `save` caps with
`sublist(length - 20)` and the stored list may legitimately begin with an orphan
assistant message.

**The pruned list is written back, so the records are actually deleted**, not
merely hidden. The write-back is **gated on pruning having removed something**
(`pruned.length != messages.length`): `_decodeMessage` drops records with empty
text, unparseable `createdAt` or an unknown role, so an unconditional resave would
have **permanently erased otherwise-harmless corrupt records**. A test asserts the
stored bytes are unchanged when no sensitive record is present.

The cleanup is bounded (≤20 records), idempotent (a second `load()` finds nothing,
returns the identical list and does not rewrite the key), touches only
`bismillah.assistant_history`, preserves all unrelated keys, writes **no backup or
quarantine copy**, and **never logs, prints, asserts on or embeds the removed raw
text**. `_writeBack` contains `Error` as well as `Exception`.

**Accepted limitation, recorded by owner decision:** detection is keyword-based
(`worshipRule` keys on `{'bozar', 'invalidate', 'يبطل'}`), so a benign line such as
"bu gürültü konsantrasyonumu bozar mı" **is deleted too**. This is a known,
accepted, one-time collateral deletion of non-sensitive local history — Assistant
history is a small local convenience cache, not a source of truth, and retaining
possibly-sensitive religious-query text on disk is the greater risk. The cleanup
is **not** precise and is not described as such. A test named honestly as an
accepted false positive proves this deletion happens.

## `clear()` silent failure (owner approved in scope)

`clear()` swallowed every exception while the provider set state empty regardless,
so the user could be told history was cleared while the key still held raw text.
`AssistantHistoryRepository.clear` now returns `ResultFuture<void>`, the controller
returns `Future<bool>`, and on failure the state and `_nonPersistableIds` are left
untouched and the "cleared" confirmation is suppressed. Both production call sites
were updated. No new localization string was added: on failure the screen shows no
message rather than inventing copy — silence is honest, and a neutral "could not
clear" string is recorded as a later l10n follow-up.

## Logging and redaction

No Assistant code calls `print`, `debugPrint`, `AppLogger`, `developer.log`,
Crashlytics or analytics. `NoOpAnalyticsService` sends nothing and passes a
`PrivacyGuard`. No `AppFailure` or exception path embeds query text. A test asserts
no raw sensitive text appears in observable output. **No broader protection is
claimed than the tests prove.**

## `editorialReview` governance

Root `CONTENT_POLICY.md` and `docs/LEARN_CONTENT_REVIEW.md` now carry the same
definition, cross-referencing each other so they cannot diverge:
**`editorialReview` means an owner/editor source-fidelity and presentation review
only.** It is explicitly **not** qualified scholarly review, fatwa review, hadith
grading, legal review, Diyanet approval or institutional endorsement.
`scholarlyReview` is preserved as a separate, stronger gate.

The definition is scoped as **the requirement going forward**, and states plainly
that the historical review provenance of already-published records carrying the
label is **not re-verified** by it — TASK 087 recorded that provenance as
**AMBIGUOUS**. This prevents the definition reading as retroactive certification of
the 55 shipped `editorialReview` records. No content was reclassified, **no
publication status changed**, and the document grants no approval, retroactive or
prospective. The words "approved" and "cleared" are avoided.

Current label distribution, unchanged by this task: **55 `editorialReview`, 1
`scholarlyReview`.**

## Governance documents corrected

`docs/CONTENT_SOURCE_MATRIX.md` recorded F1 as open, including the now-false claim
that `isSensitiveVerdict` has no production caller. F1 is marked **CLOSED (TASK
094)** with the original evidence preserved, and the affected row's limitation
replaced with the true one — that `load()` prunes re-classified records and, being
keyword-based, may delete a benign record. `docs/PRIVACY_MODEL.md` now documents
the retroactive cleanup, its bounds, and the accepted false-positive limitation.

## Tests

Assistant suite **84 / 84** (was 82 before the last two additions); the focused
TASK 094 file holds **10**. Proved: `worshipRule` is sensitive; all three sensitive
classes share the one canonical predicate; a table-driven test over **every**
`AssistantQueryClass` value asserts key-set equality with `values`, so a new enum
value cannot be silently missed; a `worshipRule` pair is not persisted;
non-sensitive queries still persist unchanged; a legacy sensitive record is neither
returned nor left on disk; the acknowledged false positive is deleted; the cleanup
is idempotent; a corrupt record is **not** erased when nothing sensitive is present;
unrelated `bismillah.*` keys keep their exact values and the key set is identical
before/after (proving no backup or quarantine key); no raw text in observable
output; and `clear()` failure is not reported as success.

No unrelated growing total is frozen.

## Validation

- Assistant suite: **84 / 84**
- Focused TASK 094 file: **10 / 10**
- TASK 092 official-answer gate + content governance: **63 / 63** — the
  negative-control asserting `editorialReview` still satisfies the **Learn** gate
  passes, so Learn publication behaviour does not regress
- Content governance alone (`test/content`): **14 / 14**
- `flutter analyze`: **clean**
- Full Flutter suite: **1658 / 1658** (1639 baseline + 19)
- Functions: **not run** — no Functions file, dependency or lockfile changed
- Device validation: **not required** (no platform or native change)

## Critical review

- Pre-implementation (Opus): **PASS WITH FOLLOW-UPS** — 3 blockers (write-back
  gating, role-check pairing, and not recording the full titled checkpoint) plus a
  requirement that the accepted false-positive deletion get explicit owner
  acknowledgement. The owner made all three decisions before implementation.
- Final (Opus): **BLOCKED** — solely because the task report and project-state
  updates did not yet exist, the matrix still described F1 as open, and two
  guarantees were untested. All were closed: wording scoped, matrix and privacy
  model corrected, and the two tests added.

## Deferred, genuinely non-blocking for closed alpha

- **Language verification, RTL verification and finding F2** remain open under
  TASK 094.
- `save()` still trusts its caller and applies no sensitivity check of its own;
  defence rests on the next `load()` pruning. Pruning inside `save()` too would be
  belt-and-braces.
- When a genuinely sensitive record **is** pruned, the write-back re-encodes only
  decodable messages, so a corrupt sibling is dropped in that pass. Bounded, and
  only on real cleanup.
- A neutral "could not clear history" localized string for the `clear()` failure
  path.
- TASK 093 remains deferred until real official-answer records exist.
