/// Ayar katmanı enum'ları (10_DATA_MODEL §4 `AppSettings`).
library;

/// Tema tercihi — kullanıcıya görünen metinler lokalizasyon katmanında,
/// enum yalnız kod taşır.
enum AppThemeMode { system, light, dark }

/// Ayar scope'ları (10_DATA_MODEL §4, §7 `SettingsModel.scope`).
///
/// Firestore eşlemesi `users/{uid}/settings/{scope}` belge-başına-scope
/// desenidir; `onboarding` scope'u ayrıca vardır ama `OnboardingAnswers`
/// entity'siyle taşınır (§8 — kök profile KOYULMAZ).
enum SettingsScope { notifications, prayerCalc, display, privacy }
