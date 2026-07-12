/// Onboarding yolculuk aşaması seçenekleri (TASK 027).
///
/// Paket-bağımsız; etiketler localization'dan gelir. Kaç vakit kılındığı
/// SORULMAZ, seviye ölçümü YOKTUR (04_ONBOARDING ton kuralları) — bu
/// yalnız kullanıcının kendini nasıl gördüğüdür. Seçim şimdilik bellekte
/// yaşar; kalıcılık TASK 028'dedir.
enum OnboardingJourneyStage {
  justBeginning,
  rebuildingRoutine,
  strengtheningRoutine,
}
