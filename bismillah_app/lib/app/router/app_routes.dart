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

  /// Onboarding karşılama adımı (TASK 026). Startup yönlendirmesi HENÜZ
  /// buraya bağlanmaz — TASK 028'de bağlanır; şimdilik manuel açılır.
  static const String onboardingWelcome = '/onboarding/welcome';

  /// Onboarding hedef seçimi adımı (TASK 026; akış TASK 027'de sürer).
  static const String onboardingGoals = '/onboarding/goals';

  /// Onboarding yolculuk aşaması adımı (TASK 027).
  static const String onboardingJourney = '/onboarding/journey';

  /// Onboarding günlük tempo adımı (TASK 027; kalıcılık TASK 028).
  static const String onboardingPace = '/onboarding/pace';

  static const String assistant = '/assistant';

  /// Full-screen modal paywall (05_IA §6; yalnız doğal dönüşüm
  /// anlarından kontrollü push ile açılır — redirect ASLA).
  static const String premium = '/premium';

  /// Abonelik yönetimi (push route, Profile branch içinde).
  static const String subscriptionSettings = '/settings/subscription';

  /// Kişiselleştirme tercihlerini düzenleme (TASK 030; push route,
  /// Profile branch içinde — onboarding AKIŞI DEĞİLDİR).
  static const String profilePersonalization = '/profile/personalization';

  /// Sure okuyucu tabanı (TASK 035; Quran branch içinde push route —
  /// tam konum için [quranChapterPath] kullanılır).
  static const String quranChapter = '/quran/chapter';

  /// Belirli bir surenin okuyucu konumu: `/quran/chapter/:chapterId`.
  static String quranChapterPath(int chapterId) =>
      '$quranChapter/$chapterId';

  /// Kaydedilen ayetler (TASK 038; Quran branch içinde push route).
  static const String quranBookmarks = '/quran/bookmarks';

  // Route adları (typed navigation için)
  static const String todayName = 'today';
  static const String prayerName = 'prayer';
  static const String prayerHistoryName = 'prayerHistory';
  static const String quranName = 'quran';
  static const String learnName = 'learn';
  static const String profileName = 'profile';
  static const String onboardingName = 'onboarding';
  static const String onboardingWelcomeName = 'onboardingWelcome';
  static const String onboardingGoalsName = 'onboardingGoals';
  static const String onboardingJourneyName = 'onboardingJourney';
  static const String onboardingPaceName = 'onboardingPace';
  static const String assistantName = 'assistant';
  static const String premiumName = 'premium';
  static const String subscriptionSettingsName = 'subscriptionSettings';
  static const String profilePersonalizationName = 'profilePersonalization';
  static const String quranChapterName = 'quranChapter';
  static const String quranBookmarksName = 'quranBookmarks';
}
