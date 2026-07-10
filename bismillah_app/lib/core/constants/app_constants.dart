/// Uygulama geneli sabitler. Her sabit, dayandığı dokümana referans verir
/// (06_FLUTTER_ARCHITECTURE §7 — "sihirli sayı çöplüğü yasak").
abstract final class AppConstants {
  /// Today panosunda aynı anda gösterilebilecek en fazla kart sayısı
  /// (03_DESIGN_SYSTEM §14).
  static const int maxTodayCards = 4;

  /// Onboarding sonrası ilk otomatik paywall gösterimi için minimum gün
  /// (08_BUSINESS_MODEL §9 — ilk 14 gün otomatik paywall yok).
  static const int minDaysBeforeAutoPaywall = 14;

  /// Desteklenen onboarding sorusu sayısı (04_ONBOARDING_FLOW §4).
  static const int onboardingQuestionCount = 16;
}

/// Bileşen boyut token'ları (03_DESIGN_SYSTEM §36 `size.*`).
abstract final class AppSizes {
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double bottomNavHeight = 64;
  static const double fabSize = 56;
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double progressRingLarge = 96;
  static const double progressRingSmall = 32;
  static const double progressBarHeight = 8;
  static const double maxContentWidth = 480;
}
