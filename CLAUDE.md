# Bismillah Engineering Constitution

Version: 1.0

## Project Identity

- **Project Name:** Bismillah
- **Product Type:** Premium Islamic Lifestyle Companion

**Mission:** Help Muslims build consistent Islamic habits through beautiful design, intelligent personalization, authentic Islamic knowledge, and modern technology.

**Vision:** Build the highest quality Islamic mobile application in the world. The application should feel premium, peaceful, personal, and trustworthy.

We are NOT building another prayer time application. We are building an Islamic companion people want to open every single day.

## Core Principles

Every decision should improve one of these:

- Increase consistency in worship
- Help users grow spiritually
- Reduce friction
- Create peace
- Build trust
- Respect Islamic values
- Delight the user

Never add features just because competitors have them. Every feature must solve a real problem.

## Product Philosophy

Bismillah should feel like:

- Apple Health
- Headspace
- Duolingo
- Notion
- Calm

...for Islamic life.

The experience should be calm. Minimal. Elegant. Warm. Personal. Never overwhelming.

## User Experience Principles

Every screen should answer: **What should I do now?**

- The user should never feel lost.
- The interface should guide naturally.
- Navigation must require as few taps as possible.
- Large touch targets.
- Beautiful typography.
- Readable spacing.
- Modern cards.
- Soft animations.
- Premium transitions.

## Design Language

Visual Style: Modern, Elegant, Peaceful, Premium, Minimal

| Role | Color |
|------|-------|
| Primary | Deep Emerald Green |
| Secondary | Forest Green |
| Background | Warm White |
| Accent | Soft Gold (very limited use) |
| Success | Green |
| Error | Soft Red |

- **Cards:** Rounded corners, soft shadows, large spacing
- **Icons:** Simple outline icons

No clutter. No visual noise.

## Animation Principles

- Animations should be subtle. Never distracting.
- Use smooth transitions.
- Prioritize delight over decoration.
- The application should feel alive.

## Tone of Voice

**Always:** Warm, Respectful, Encouraging, Hopeful

**Never:** Judgmental, Aggressive, Fear-based, Guilt-driven

The app should motivate users gently.

## Islamic Principles

- Authenticity is more important than speed.
- Never invent Islamic rulings.
- Never generate fatwas.
- When scholarly opinions differ: explain that multiple opinions exist, and encourage users to consult trusted local scholars for personal rulings.
- Always distinguish between: Quran, Hadith, Scholarly opinion, and AI explanation.
- The application must never present AI-generated text as revelation.

## AI Principles

The AI is an assistant. Not a Mufti. Not an Imam. Not a replacement for scholars.

Its goals: Teach, Encourage, Explain, Simplify, Motivate, Organize, Personalize.

The AI should:

- Suggest habits.
- Recommend Quran reading.
- Recommend duas.
- Track progress.
- Answer beginner questions responsibly.
- Create personalized plans.
- Never shame users. Always encourage.

## Personalization

Every user is different. The application should learn:

- Prayer habits
- Reading habits
- Dhikr habits
- Learning interests
- Goals
- Available time
- Preferred language
- Experience level

The application should become smarter over time.

## Gamification

Motivation. Not addiction. Reward effort. Reward consistency. Never manipulate users.

Use: XP, Levels, Achievements, Streaks, Monthly goals, Seasonal events, Ramadan challenges.

## Accessibility

- Large fonts.
- High contrast.
- Screen reader support.
- Simple navigation.
- One-handed usage whenever possible.

## Performance

- Cold launch under 2 seconds.
- Smooth scrolling.
- Fast animations.
- Offline-first whenever possible.
- Battery efficient.

## Technical Stack

| Concern | Choice |
|---------|--------|
| Frontend | Flutter |
| State Management | Riverpod |
| Routing | GoRouter |
| Backend | Firebase |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Analytics | Firebase Analytics |
| Crash Reporting | Crashlytics |
| Notifications | Firebase Cloud Messaging |
| Local Database | Isar |
| Payments | RevenueCat |
| AI | Provider abstraction (initial implementation may use OpenAI or Anthropic, but the architecture must allow switching providers without major code changes) |

Architecture:

- Clean Architecture
- Feature-first folder structure
- Repository Pattern
- Dependency Injection
- Strong typing
- Reusable components

## Code Standards

- Readable code over clever code.
- Small widgets. Small classes.
- Document public APIs.
- Avoid duplication.
- Prefer composition.
- Follow SOLID principles.
- Write scalable code.
- Never sacrifice maintainability for speed.

## Security

- Never expose API keys.
- Validate all user input.
- Respect user privacy.
- Store sensitive data securely.
- Follow least privilege principles.

## Privacy

- Collect only necessary data.
- Explain why permissions are requested.
- Users own their data.
- Provide account deletion support.
- Be transparent.

## Quality Standards

Every feature should feel production-ready.

- No placeholder UI in production.
- No inconsistent spacing.
- No broken animations.
- No unnecessary dialogs.
- No visual clutter.

Premium quality is mandatory.

## Definition of Done

A task is complete only if:

- UX is polished
- UI is beautiful
- Code is clean
- Accessibility is considered
- Performance is acceptable
- Edge cases are handled
- Documentation is updated
- The feature matches the project vision

## Long-Term Vision

Bismillah should become the daily companion for Muslims worldwide. Not simply an application. A trusted companion that helps users grow closer to Allah through consistency, knowledge, and sincere encouragement.

Every design decision, every line of code, and every feature should contribute to that mission.

# Language Rule

The primary working language for this project is Turkish.

All assistant responses, task summaries, explanations, planning notes, and non-code documentation should be written in Turkish unless explicitly requested otherwise.

Code, file names, class names, variables, technical identifiers, package names, and standard developer terminology may remain in English.

Product documentation may use English section titles only when it improves technical clarity, but the main explanation should be Turkish.

When communicating with the project owner, always write in Turkish.
