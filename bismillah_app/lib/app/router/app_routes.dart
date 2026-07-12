/// Route path/name sabitleri (05_INFORMATION_ARCHITECTURE §6).
/// String route yazımı yasaktır — daima bu sınıf kullanılır.
abstract final class AppRoutes {
  // Shell sekmeleri
  static const String today = '/today';
  static const String prayer = '/prayer';

  /// Son 7 gün namaz geçmişi — Prayer branch içinde push route (salt-okunur).
  static const String prayerHistory = '/prayer/history';
  static const String quran = '/quran';
  static const String learn = '/learn';
  static const String profile = '/profile';

  // Shell dışı katmanlar
  static const String onboarding = '/onboarding';
  static const String assistant = '/assistant';

  /// Full-screen modal paywall (05_IA §6; yalnız doğal dönüşüm
  /// anlarından kontrollü push ile açılır — redirect ASLA).
  static const String premium = '/premium';

  /// Abonelik yönetimi (push route, Profile branch içinde).
  static const String subscriptionSettings = '/settings/subscription';

  // Route adları (typed navigation için)
  static const String todayName = 'today';
  static const String prayerName = 'prayer';
  static const String prayerHistoryName = 'prayerHistory';
  static const String quranName = 'quran';
  static const String learnName = 'learn';
  static const String profileName = 'profile';
  static const String onboardingName = 'onboarding';
  static const String assistantName = 'assistant';
  static const String premiumName = 'premium';
  static const String subscriptionSettingsName = 'subscriptionSettings';
}
