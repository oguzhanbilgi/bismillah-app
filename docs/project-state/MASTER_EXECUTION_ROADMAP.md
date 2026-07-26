# Master Execution Roadmap

The canonical product and revenue roadmap for Bismillah. Work proceeds in numbered
order; do not skip ahead without explicit user approval. Revenue figures are targets,
never guarantees.

## Task ranges

```text
TASK 001–060   Foundation, Quran, Prayer, Learn, Profile, Assistant
TASK 061–067   Public alpha and stabilization
TASK 068–075   Technical stabilization (CP09)
TASK 076–085   Today and 30-day personal plan (CP10)
TASK 086–094   Learn and Assistant depth (CP11)
TASK 095–101   Prayer quality and closed beta (CP12)
TASK 102–115   Premium and Google Play launch (CP13)
TASK 116–122   Revenue and growth validation (CP14)
TASK 123–130   iOS and App Store (CP15)
TASK 131–140   Sync, Ramadan, family and V1.1 (CP16)
```

## Historical tasks (TASK 001–060)

Exact one-by-one titles for TASK 001–060 are not individually reconstructable from
Git history and are **not** invented here. The verified delivered groups are:

- Flutter foundation and architecture
- Five-tab navigation
- Localization TR/EN/AR and RTL
- Onboarding
- Prayer calculations / logging / reminders
- Quran reader / search / audio / progress
- Learn source model and publication gate
- Profile
- Local deterministic Assistant

## Recorded tasks (061–068A)

```text
TASK 061A-2 — License, attribution and content policy — COMPLETED
TASK 061A-3 — Public documentation and CI — COMPLETED
TASK 061B   — Public alpha merge and v0.1.0-alpha.1 — COMPLETED
TASK 062A   — Dependency triage — COMPLETED
TASK 062B   — Master project audit — COMPLETED
TASK 063    — package_info_plus 10.2.1 — COMPLETED
TASK 064    — Drift schema and persistence baseline — COMPLETED
TASK 065    — Merge Drift baseline — COMPLETED
TASK 066    — Drift official tooling alignment — BLOCKED
TASK 067    — flutter-action v2.23.0 — COMPLETED
TASK 068    — Node.js 22 Functions runtime and Functions CI — COMPLETED
TASK 068A   — Permanent Claude project memory — COMPLETED
TASK 069    — fast-xml-parser 5.10.1 validation under Node.js 22 — COMPLETED
TASK 070    — flutter_local_notifications 22.1.0 update — SUPERSEDED by TASK 070A
TASK 070A   — Android scheduled-notification manifest receiver contract — COMPLETED
TASK 070B   — Samsung A36 device validation of the manifest fix — COMPLETED
TASK 070C   — Reapply flutter_local_notifications 22.1.0 on the manifest fix — COMPLETED
TASK 070D   — Exact-alarm permission deep-link UX — COMPLETED
TASK 071    — Final Samsung A36 end-to-end validation and PR #14 merge — COMPLETED
TASK 072    — Offline sync-queue architecture and data-loss risk audit — COMPLETED
TASK 073    — Local sync-queue hardening (backoff + taxonomy + pruning) — COMPLETED
TASK 074    — Firebase security and console readiness audit — COMPLETED
TASK 075    — CP09 technical stabilization and full regression checkpoint — COMPLETED
```

## CP09 — Technical stabilization

```text
TASK 068  — COMPLETED   — Node.js 22 runtime and Functions CI
TASK 068A — COMPLETED   — Permanent Claude project memory
TASK 069  — COMPLETED   — Validate and merge fast-xml-parser 5.10.1 under Node.js 22
TASK 070  — SUPERSEDED  — 22.1.0 update blocked by a pre-existing manifest gap; see 070A
TASK 070A — COMPLETED   — Declare scheduled-notification receivers + manifest tests
TASK 070B — COMPLETED   — Samsung A36 device validation (reboot delivery deferred to 071)
TASK 070C — COMPLETED   — Reapply flutter_local_notifications 22.1.0 on the manifest fix
TASK 070D — COMPLETED   — Exact-alarm permission deep-link UX (honest recheck + fallback)
TASK 071  — COMPLETED   — Final Samsung A36 end-to-end validation incl. reboot delivery
TASK 072  — COMPLETED   — Sync-queue audit (verdict: READY FOR LOCAL QUEUE HARDENING ONLY)
TASK 073  — COMPLETED   — Local sync-queue hardening (backoff + taxonomy + pruning +
                          stale-recovery + diagnostics; NO remote writes) — redefined by
                          TASK 072; original docs scope was largely done by TASK 068A
TASK 074  — COMPLETED   — Firebase security readiness audit (verdict: READY FOR
                          LOCAL SECURITY HARDENING ONLY; Rules/App Check/emulator/
                          staging absent; deployed callable on EOL nodejs20)
TASK 075  — COMPLETED   — CP09 full regression checkpoint (verdict: CP09 COMPLETE —
                          TECHNICALLY STABLE); all baselines re-run unchanged;
                          authoritative Firebase gate order G1–G14 fixed; deployed
                          nodejs20 drift re-verified as P1; npm advisories split into
                          dev-only vs production chains; product gate: READY TO ENTER
                          NEXT LOCAL-FIRST PRODUCT CHECKPOINT
```

**CP09 is closed.** CP10 may begin. Remote sync remains disabled and is gated
by G1–G14 (see `CURRENT_BASELINE.md`); none of those gates blocks CP10, which
is local-first by design.

## CP10 — Today and 30-day plan

```text
TASK 076 — DailyPlan repository and local persistence   <-- NEXT TASK
TASK 077 — Daily plan state machine
TASK 078 — Onboarding profile mapping
TASK 079 — Deterministic daily plan generator
TASK 080 — Prayer plan items
TASK 081 — Quran plan items
TASK 082 — Learn plan items
TASK 083 — Today task UI
TASK 084 — Missed-day recovery and gentle rollover
TASK 085 — 30-day plan and CP10 checkpoint
```

## CP11 — Learn and Assistant

```text
TASK 086 — Content-source matrix
TASK 087 — Learn pack: Hadith, Seerah, Prophets
TASK 088 — Learn pack: Dua, Family, Halal foundations
TASK 089 — Learn pack: Women, Afterlife, Islamic history
TASK 090 — Learn pack: Madhhabs, Islamic calendar and remaining gaps
TASK 091 — Review pending Learn articles
TASK 092 — Official-answer / fatwa-source index foundation
TASK 093 — Assistant retrieval ranking and no-source UX
TASK 094 — Learn/Assistant security, language and RTL checkpoint
```

## CP12 — Prayer quality and beta

```text
TASK 095 — Qibla
TASK 096 — Prayer calculation-method selection
TASK 097 — Short adhan / notification sound options
TASK 098 — TR/EN/AR real-device UX
TASK 099 — Accessibility and performance
TASK 100 — Privacy / reset regression
TASK 101 — Closed alpha/beta package
```

## CP13 — Premium and Google Play

```text
TASK 102 — Final free / Bismillah+ / Destekçi entitlement matrix
TASK 103 — RevenueCat architecture
TASK 104 — Google Play subscription products
TASK 105 — Purchase, restore and entitlement lifecycle
TASK 106 — Bismillah+ feature gates
TASK 107 — Destekçi tier
TASK 108 — Ethical paywall
TASK 109 — Subscription settings and management
TASK 110 — Privacy-safe conversion telemetry
TASK 111 — Android release signing and flavors
TASK 112 — Google Play store materials
TASK 113 — Play internal / closed testing
TASK 114 — Beta fixes and pricing validation
TASK 115 — Google Play soft launch and first possible real revenue
```

## CP14 — Revenue validation

```text
TASK 116 — ASO and organic launch
TASK 117 — First controlled paid acquisition test
TASK 118 — Funnel and retention review
TASK 119 — Product conversion improvements
TASK 120 — Second controlled advertising test
TASK 121 — First 30-day revenue review
TASK 122 — 90-day commercial checkpoint and 5,000–10,000 TL target evaluation
```

## CP15 — iOS

```text
TASK 123 — macOS/Xcode build
TASK 124 — Firebase iOS configuration
TASK 125 — iOS Quran background audio
TASK 126 — iOS notifications
TASK 127 — iOS RevenueCat products
TASK 128 — App Store materials
TASK 129 — TestFlight
TASK 130 — App Store public launch
```

## CP16 — V1.1

```text
TASK 131 — Optional account linking
TASK 132 — Cloud sync engine
TASK 133 — Firestore Security Rules
TASK 134 — App Check enforcement
TASK 135 — Advanced privacy-safe analytics
TASK 136 — Ethical XP / levels / achievements
TASK 137 — Ramadan layer
TASK 138 — Family plan
TASK 139 — Themes and widgets
TASK 140 — Khatm planner and V1.1 checkpoint
```

## Commercial milestones (targets, not guarantees)

```text
TASK 115 — First real payment can technically occur
TASK 121 — First meaningful 30-day revenue review
TASK 122 — Android commercial validation and 5,000–10,000 TL target evaluation
TASK 130 — Android + iOS first commercial release complete
TASK 140 — Planned V1.1 scope complete
```
