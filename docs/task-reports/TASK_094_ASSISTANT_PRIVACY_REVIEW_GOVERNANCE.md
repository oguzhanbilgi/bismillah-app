# TASK 094 — Learn/Assistant security, language and RTL checkpoint

Status: **COMPLETE** (privacy/governance portion merged as `e8b0de7`;
remaining scope closed by the completion branch — see the closing section)
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

**Closed by the completion branch** (`task/094-complete-language-rtl-source-drift`):

- **language verification** (TR/EN/AR)
- **RTL verification**
- **Finding F2** — source-metadata duplication/drift
- **persistence-boundary defense-in-depth** (repository now enforces the
  canonical predicate itself)

See the closing section at the end of this report.

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
TASK 094 file holds **9**. Proved: `worshipRule` is sensitive; all three sensitive
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
- Focused TASK 094 file: **9 / 9**
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


---

# TASK 094 — completion (language, RTL, source drift, persistence boundary)

Branch: `task/094-complete-language-rtl-source-drift` · base `829c8db`

## Persistence-boundary defense-in-depth (§A)

The earlier work stopped sensitive history at the **controller**. The repository
itself still trusted its caller. `SharedPrefsAssistantHistoryRepository.save`
now runs the same `_pruneSensitive` pass that `load()` uses, so a **direct**
repository call cannot write sensitive history. No second sensitivity list was
introduced — both paths call `AssistantQueryClassifier.isSensitiveVerdict`.

Pruning runs **before** the 20-message cap, so dropped sensitive records cannot
consume the quota. `save` now returns `ResultFuture<void>` (mirroring `clear`),
so a failed write is no longer silently indistinguishable from success; the one
production caller and the test fake were updated.

## Source-metadata drift, finding F2 (§B)

`app_source_reference.dart` previously hand-copied the name, original language
and canonical URL of four registered Diyanet sources. Those four entries now
carry **only a `registrySourceId`**; the fields are resolved at runtime from
`assets/content/learn/sources.json` via the existing `getSourceById`. There is
nothing left to drift.

Tanzil, QuranEnc and MP3Quran are **infrastructure** sources with no registry
entry, so they keep literal metadata — they are a single definition, not a
copy, and a test asserts they are absent from the registry.

A missing id **fails safely and visibly**: the provider surfaces an error and the
screen shows a neutral message. No metadata is invented and no source is silently
skipped. **No religious claim, article body, locator or source record was
changed.**

## Language verification (§C)

`_t()` falls back to English on a missing key, so a missing translation leaks
English into the Turkish or Arabic UI. A test now asserts the **TR/EN/AR key
sets are identical** — the real regression guard. Affected safety surfaces
(no-source, official-fatwa redirect, qualified-guidance, source labels and
policy lines) are asserted present, distinct per locale, and Arabic values are
asserted to contain Arabic script. One new key, `sourcesUnavailable`, was added
in all three locales. **No copy was rewritten and no religious meaning changed.**

## RTL verification (§D)

Focused widget tests on the highest-risk affected surfaces. They assert
behaviour, not mere rendering: the Assistant screen and content-sources screen
resolve to `TextDirection.rtl` under Arabic and `ltr` under Turkish; the user
bubble is on the **end** side in both directions (right in LTR, mirrored left in
RTL — proving logical rather than hard-coded alignment); refusal and no-source
states render under RTL; a Latin source name stays LTR inside the Arabic page;
and RTL at 1.5× text scale on a narrow screen produces no overflow.

## Validation

- Persistence boundary: **15 / 15**
- Source drift: **8 / 8**
- Language + RTL (sources screen): **21 / 21** within `test/features/settings`
- Assistant RTL: **8 / 8**
- Profile + settings focused run: **65 / 65**
- `flutter analyze`: clean
- Full suite: **1705 / 1705** (was 1658)
- Functions: not run — no Functions file, dependency or lockfile changed

## Remaining follow-ups (non-blocking)

- A neutral "could not clear history" localized string for the `clear()` failure
  path (today the screen correctly shows nothing rather than a false success).
- Assistant source-reference rows resolve asynchronously, so an isolated widget
  harness must await them; RTL of that row is covered on the content-sources
  screen instead.
