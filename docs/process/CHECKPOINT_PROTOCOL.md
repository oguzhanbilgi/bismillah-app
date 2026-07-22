# Checkpoint Protocol

Normal tasks get a **short** report. Some areas require a **wide audit** because a
mistake there can lose data, expose secrets, mishandle money, or break the
religious-content trust model.

## Areas that may require a wide audit

- Authentication
- Database migrations
- Cloud sync
- Data deletion / reset
- Payments / RevenueCat
- Store billing
- Firestore Security Rules
- App Check
- Release signing
- Secret management
- Data-loss risk
- Religious publication gate

## Checkpoint closing checklist

At the end of a checkpoint, verify and record:

- Analyze / lint clean
- Full test run (with exact counts)
- Build (when platform/dependency/native code changed)
- Required real-device checks (or `PENDING` if a device is unavailable)
- Git cleanliness (working tree, only expected untracked files)
- Docs / current-baseline updated
- Risk review (new and outstanding blockers)

A checkpoint is not "done" while any required gate is failing or unverified.
