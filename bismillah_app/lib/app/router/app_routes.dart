/// Route path/name sabitleri (05_INFORMATION_ARCHITECTURE §6).
/// String route yazımı yasaktır — daima bu sınıf kullanılır.
abstract final class AppRoutes {
  // Shell sekmeleri
  static const String today = '/today';
  static const String prayer = '/prayer';

  /// Son 7 gün namaz geçmişi — Prayer branch içinde push route (salt-okunur).
  static const String prayerHistory = '/prayer/history';

  /// Kıble yönü (TASK 095) — Prayer branch içinde push route.
  static const String qibla = '/prayer/qibla';

  /// Namaz vakti hesaplama yöntemi seçimi (TASK 096) — Prayer branch içinde
  /// push route (namaz ayarları Namaz sekmesinde kalır).
  static const String prayerCalculationMethod = '/prayer/calculation-method';
  static const String quran = '/quran';
  static const String learn = '/learn';

  /// Öğrenme kategorisi (TASK 056; Learn branch içinde push route).
  /// Tam konum için [learnCategoryPath] kullanılır.
  static const String learnCategory = '/learn/category';

  static String learnCategoryPath(String slug) => '$learnCategory/$slug';

  /// Öğrenme içeriği detayı: `/learn/article/:slug`.
  static const String learnArticle = '/learn/article';

  static String learnArticlePath(String slug) => '$learnArticle/$slug';
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

  /// Uygulama dili seçimi (TASK 053; push route, Profile branch içinde).
  static const String languageSettings = '/settings/language';

  /// Kişiselleştirme tercihlerini düzenleme (TASK 030; push route,
  /// Profile branch içinde — onboarding AKIŞI DEĞİLDİR).
  static const String profilePersonalization = '/profile/personalization';

  /// İçerik kaynakları ve doğrulama politikası (TASK 058; Profile branch
  /// içinde push route).
  static const String profileSources = '/profile/sources';

  /// Gizlilik ve yerel veriler + veri sıfırlama (TASK 058; Profile branch
  /// içinde push route).
  static const String profilePrivacy = '/profile/privacy';

  /// Hakkında + lisanslar (TASK 058; Profile branch içinde push route).
  static const String profileAbout = '/profile/about';

  /// Sure okuyucu tabanı (TASK 035; Quran branch içinde push route —
  /// tam konum için [quranChapterPath] kullanılır).
  static const String quranChapter = '/quran/chapter';

  /// Belirli bir surenin okuyucu konumu: `/quran/chapter/:chapterId`.
  static String quranChapterPath(int chapterId) => '$quranChapter/$chapterId';

  /// Hedef ayete odaklı okuyucu konumu (TASK 048 arama sonucu):
  /// `/quran/chapter/:chapterId?verse=:verseNumber` — aynı route, yeni
  /// paralel reader route'u YOK.
  static String quranChapterVersePath(int chapterId, int verseNumber) =>
      '$quranChapter/$chapterId?verse=$verseNumber';

  /// Kaydedilen ayetler (TASK 038; Quran branch içinde push route).
  static const String quranBookmarks = '/quran/bookmarks';

  // Route adları (typed navigation için)
  static const String todayName = 'today';
  static const String prayerName = 'prayer';
  static const String prayerHistoryName = 'prayerHistory';
  static const String qiblaName = 'qibla';
  static const String prayerCalculationMethodName = 'prayerCalculationMethod';
  static const String quranName = 'quran';
  static const String learnName = 'learn';
  static const String learnCategoryName = 'learnCategory';
  static const String learnArticleName = 'learnArticle';
  static const String profileName = 'profile';
  static const String onboardingName = 'onboarding';
  static const String onboardingWelcomeName = 'onboardingWelcome';
  static const String onboardingGoalsName = 'onboardingGoals';
  static const String onboardingJourneyName = 'onboardingJourney';
  static const String onboardingPaceName = 'onboardingPace';
  static const String assistantName = 'assistant';
  static const String premiumName = 'premium';
  static const String subscriptionSettingsName = 'subscriptionSettings';
  static const String languageSettingsName = 'languageSettings';
  static const String profilePersonalizationName = 'profilePersonalization';
  static const String profileSourcesName = 'profileSources';
  static const String profilePrivacyName = 'profilePrivacy';
  static const String profileAboutName = 'profileAbout';
  static const String quranChapterName = 'quranChapter';
  static const String quranBookmarksName = 'quranBookmarks';
}
