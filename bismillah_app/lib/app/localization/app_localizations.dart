import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:flutter/widgets.dart';

/// Scaffold aşaması localization soyutlaması.
///
/// Kullanıcıya görünen HİÇBİR metin widget içine hardcode edilmez — hepsi
/// buradan gelir. Tam ARB/gen-l10n sistemine geçiş sonraki görevde yapılır;
/// bu sınıfın API'si (getter'lar) o geçişte aynen korunur, yalnız kaynak
/// değişir (06_FLUTTER_ARCHITECTURE §18).
final class AppLocalizations {
  const AppLocalizations(this.supportedLocale);

  final SupportedLocale supportedLocale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(SupportedLocale.en);

  String _t(String key) =>
      _strings[supportedLocale]?[key] ?? _strings[SupportedLocale.en]![key]!;

  // Uygulama
  String get appTitle => _t('appTitle');

  // Sekmeler (05_INFORMATION_ARCHITECTURE §19 etiket sözlüğü)
  String get tabToday => _t('tabToday');
  String get tabPrayer => _t('tabPrayer');
  String get tabQuran => _t('tabQuran');
  String get tabLearn => _t('tabLearn');
  String get tabProfile => _t('tabProfile');

  // Asistan
  String get assistantFabLabel => _t('assistantFabLabel');
  String get assistantTitle => _t('assistantTitle');

  // Placeholder ekran metinleri
  String get placeholderComingSoon => _t('placeholderComingSoon');
  String get onboardingTitle => _t('onboardingTitle');

  // Onboarding karşılama + hedef seçimi (TASK 026 — ton: sakin, davetkâr;
  // korku/suçluluk/paywall dili YASAK, 04_ONBOARDING §2)
  String get onboardingWelcomeEyebrow => _t('onboardingWelcomeEyebrow');
  String get onboardingWelcomeTitle => _t('onboardingWelcomeTitle');
  String get onboardingWelcomeSupport => _t('onboardingWelcomeSupport');
  String get onboardingWelcomeCta => _t('onboardingWelcomeCta');
  String get onboardingWelcomeNote => _t('onboardingWelcomeNote');
  String get onboardingGoalsTitle => _t('onboardingGoalsTitle');
  String get onboardingGoalsSupport => _t('onboardingGoalsSupport');
  String get onboardingGoalTrackPrayers => _t('onboardingGoalTrackPrayers');
  String get onboardingGoalPrayOnTime => _t('onboardingGoalPrayOnTime');
  String get onboardingGoalQuranHabit => _t('onboardingGoalQuranHabit');
  String get onboardingGoalDhikrRoutine => _t('onboardingGoalDhikrRoutine');
  String get onboardingGoalKnowledge => _t('onboardingGoalKnowledge');
  String get onboardingGoalsCta => _t('onboardingGoalsCta');

  // Onboarding yolculuk aşaması + günlük tempo (TASK 027 — yargı/seviye
  // ölçümü YASAK; tempo bağlayıcı değildir)
  String get onboardingJourneyTitle => _t('onboardingJourneyTitle');
  String get onboardingJourneySupport => _t('onboardingJourneySupport');
  String get onboardingJourneyNew => _t('onboardingJourneyNew');
  String get onboardingJourneyRebuilding => _t('onboardingJourneyRebuilding');
  String get onboardingJourneyStrengthening =>
      _t('onboardingJourneyStrengthening');
  String get onboardingPaceTitle => _t('onboardingPaceTitle');
  String get onboardingPaceSupport => _t('onboardingPaceSupport');
  String get onboardingPaceLight => _t('onboardingPaceLight');
  String get onboardingPaceLightDesc => _t('onboardingPaceLightDesc');
  String get onboardingPaceBalanced => _t('onboardingPaceBalanced');
  String get onboardingPaceBalancedDesc => _t('onboardingPaceBalancedDesc');
  String get onboardingPaceFocused => _t('onboardingPaceFocused');
  String get onboardingPaceFocusedDesc => _t('onboardingPaceFocusedDesc');
  String get onboardingPaceCta => _t('onboardingPaceCta');

  // Onboarding tamamlama (TASK 028 — kayıt + startup kapısı)
  String get onboardingPreparingStart => _t('onboardingPreparingStart');
  String get onboardingSaveIssue => _t('onboardingSaveIssue');
  String get premiumTitle => _t('premiumTitle');
  String get subscriptionSettingsTitle => _t('subscriptionSettingsTitle');

  // Ortak
  String get commonLoading => _t('commonLoading');
  String get commonRetry => _t('commonRetry');
  String get commonClose => _t('commonClose');

  // Today özeti (TASK 017 — ton: sakin, suçlayıcı dil YASAK)
  String get todayGreeting => _t('todayGreeting');
  String get todayGentleLine => _t('todayGentleLine');
  String get todayPrayerCardTitle => _t('todayPrayerCardTitle');
  String get todayGoToPrayers => _t('todayGoToPrayers');
  String get todayLocalNote => _t('todayLocalNote');
  String get todayLoadIssue => _t('todayLoadIssue');

  // Today haftalık ritim kartı (TASK 025 — salt-okunur; streak/puan YOK)
  String get todayWeeklyRhythmLine => _t('todayWeeklyRhythmLine');
  String get todayWeeklyHistoryCta => _t('todayWeeklyHistoryCta');

  // Today kişiselleştirilmiş küçük adım (TASK 031 — AI değil; baskı dili YOK)
  String get todaySmallStepTitle => _t('todaySmallStepTitle');
  String get todaySmallStepBadge => _t('todaySmallStepBadge');
  String get todaySuggestionTrackPrayers => _t('todaySuggestionTrackPrayers');
  String get todaySuggestionPrayOnTime => _t('todaySuggestionPrayOnTime');
  String get todaySuggestionQuran => _t('todaySuggestionQuran');
  String get todaySuggestionDhikr => _t('todaySuggestionDhikr');
  String get todaySuggestionKnowledge => _t('todaySuggestionKnowledge');
  String get todayPaceLight => _t('todayPaceLight');
  String get todayPaceBalanced => _t('todayPaceBalanced');
  String get todayPaceFocused => _t('todayPaceFocused');
  String get todayCtaSeeTimes => _t('todayCtaSeeTimes');
  String get todayCtaGoQuran => _t('todayCtaGoQuran');
  String get todayCtaGoLearn => _t('todayCtaGoLearn');

  // Today sıradaki namaz kartı (TASK 023 — salt-okunur; canlı sayaç YOK)
  String get todayNextPrayerTitle => _t('todayNextPrayerTitle');
  String get todayNextPrayerAllDone => _t('todayNextPrayerAllDone');
  String get todayNextPrayerLocationCta => _t('todayNextPrayerLocationCta');
  String get todayNextPrayerUnavailable => _t('todayNextPrayerUnavailable');

  /// "2/5 tamamlandı" biçimli ilerleme metni.
  String todayPrayerProgress(int completed, int total) => _t(
    'todayPrayerProgress',
  ).replaceAll('{completed}', '$completed').replaceAll('{total}', '$total');

  // Namaz takibi (TASK 016 — ton: sakin, suçlayıcı dil YASAK)
  String get prayerTodaySubtitle => _t('prayerTodaySubtitle');
  String get prayerGentleLine => _t('prayerGentleLine');
  String get prayerMark => _t('prayerMark');
  String get prayerCompleted => _t('prayerCompleted');
  String get prayerUndo => _t('prayerUndo');
  String get prayerLocalNote => _t('prayerLocalNote');
  String get prayerSaveIssue => _t('prayerSaveIssue');
  String get prayerLoadIssue => _t('prayerLoadIssue');
  String get prayerNameFajr => _t('prayerNameFajr');
  String get prayerNameDhuhr => _t('prayerNameDhuhr');
  String get prayerNameAsr => _t('prayerNameAsr');
  String get prayerNameMaghrib => _t('prayerNameMaghrib');
  String get prayerNameIsha => _t('prayerNameIsha');

  // Son 7 gün namaz geçmişi (TASK 024 — salt-okunur; streak/puan/suçlama YOK)
  String get prayerHistoryTitle => _t('prayerHistoryTitle');
  String get prayerHistorySubtitle => _t('prayerHistorySubtitle');

  // Namaz vakitleri (TASK 021 — hesaplama offline; "resmi Diyanet" iddiası YOK)
  String get prayerTimesMethodLabel => _t('prayerTimesMethodLabel');
  String get prayerTimesSunrise => _t('prayerTimesSunrise');
  String get prayerTimesUseLocation => _t('prayerTimesUseLocation');
  String get prayerTimesLocationInvite => _t('prayerTimesLocationInvite');
  String get prayerTimesLocationDeniedForever =>
      _t('prayerTimesLocationDeniedForever');
  String get prayerTimesOpenSettings => _t('prayerTimesOpenSettings');
  String get prayerTimesUnavailable => _t('prayerTimesUnavailable');
  String get prayerTimesApproximate => _t('prayerTimesApproximate');

  // Namaz hatırlatıcıları (TASK 022 — ton: sakin; suçlayıcı/streak/kaçırma YOK)
  String get reminderCardTitle => _t('reminderCardTitle');
  String get reminderEnable => _t('reminderEnable');
  String get reminderDisable => _t('reminderDisable');
  String get reminderEnabledState => _t('reminderEnabledState');
  String get reminderInexactNote => _t('reminderInexactNote');
  String get reminderPermissionNeeded => _t('reminderPermissionNeeded');
  String get reminderLocationNeeded => _t('reminderLocationNeeded');

  /// Bildirim başlığı (widget bağlamı dışında da kullanılır).
  String get reminderNotificationTitle => _t('reminderNotificationTitle');

  /// Bildirim gövdesi: "{prayer} vakti için sakin bir hatırlatma."
  String reminderNotificationBody(String prayer) =>
      _t('reminderNotificationBody').replaceAll('{prayer}', prayer);

  // Profil kişiselleştirme özeti (TASK 029 — salt-okunur; düzenleme TASK 030)
  String get profilePersonalizationTitle => _t('profilePersonalizationTitle');
  String get profilePersonalizationSubtitle =>
      _t('profilePersonalizationSubtitle');
  String get profileFocusAreas => _t('profileFocusAreas');
  String get profileJourneyStage => _t('profileJourneyStage');
  String get profileDailyPace => _t('profileDailyPace');
  String get profilePersonalizationEmpty => _t('profilePersonalizationEmpty');
  String get profilePersonalizationLoadIssue =>
      _t('profilePersonalizationLoadIssue');

  // Kişiselleştirme düzenleme (TASK 030)
  String get profilePersonalizationEdit => _t('profilePersonalizationEdit');
  String get profilePersonalizationEditTitle =>
      _t('profilePersonalizationEditTitle');
  String get profilePersonalizationEditSupport =>
      _t('profilePersonalizationEditSupport');
  String get profileSaveChanges => _t('profileSaveChanges');
  String get profileChangesSaved => _t('profileChangesSaved');

  // Premium (davet dili — 02_BRAND_GUIDELINES §26; kilit/unlock dili YASAK)
  String get premiumBadgeLabel => _t('premiumBadgeLabel');
  String get premiumInviteLine => _t('premiumInviteLine');

  static const Map<SupportedLocale, Map<String, String>> _strings = {
    SupportedLocale.tr: {
      'appTitle': 'Bismillah',
      'tabToday': 'Bugün',
      'tabPrayer': 'Namaz',
      'tabQuran': "Kur'an",
      'tabLearn': 'Öğren',
      'tabProfile': 'Profil',
      'assistantFabLabel': 'Bismillah Asistanı',
      'assistantTitle': 'Bismillah Asistanı',
      'placeholderComingSoon': 'Bu bölüm hazırlanıyor.',
      'onboardingTitle': 'Hoş geldin',
      'onboardingWelcomeEyebrow': 'Her güne Bismillah',
      'onboardingWelcomeTitle':
          'İbadetlerini sakin ve düzenli bir şekilde geliştir.',
      'onboardingWelcomeSupport':
          'Namazlarını takip et, vakitlerini gör ve sana uygun küçük '
              'adımlarla ilerle.',
      'onboardingWelcomeCta': 'Başlayalım',
      'onboardingWelcomeNote': 'Yargılamadan, baskı kurmadan.',
      'onboardingGoalsTitle': 'Şu anda neye odaklanmak istersin?',
      'onboardingGoalsSupport': 'Bir veya birkaç seçenek seçebilirsin.',
      'onboardingGoalTrackPrayers': 'Namazlarımı daha düzenli takip etmek',
      'onboardingGoalPrayOnTime': 'Namaz vakitlerini kaçırmamak',
      'onboardingGoalQuranHabit':
          "Kur'an okumayı alışkanlık haline getirmek",
      'onboardingGoalDhikrRoutine': 'Dua ve zikir rutinimi geliştirmek',
      'onboardingGoalKnowledge': 'İslami bilgilerimi artırmak',
      'onboardingGoalsCta': 'Devam et',
      'onboardingJourneyTitle': 'Bu yolculukta kendini nasıl görüyorsun?',
      'onboardingJourneySupport':
          'Sana uygun bir başlangıç hazırlamamıza yardımcı olur.',
      'onboardingJourneyNew': 'Yeni başlıyorum',
      'onboardingJourneyRebuilding': 'Yeniden düzen kuruyorum',
      'onboardingJourneyStrengthening': 'Düzenimi güçlendirmek istiyorum',
      'onboardingPaceTitle': 'Günlük tempon nasıl olsun?',
      'onboardingPaceSupport': 'Bunu daha sonra değiştirebilirsin.',
      'onboardingPaceLight': 'Hafif',
      'onboardingPaceLightDesc': 'Küçük ve kolay adımlar',
      'onboardingPaceBalanced': 'Dengeli',
      'onboardingPaceBalancedDesc': 'Düzenli bir günlük ritim',
      'onboardingPaceFocused': 'Odaklı',
      'onboardingPaceFocusedDesc': 'Biraz daha fazla zaman ayırmak istiyorum',
      'onboardingPaceCta': 'Planımı hazırla',
      'onboardingPreparingStart': 'Başlangıcın hazırlanıyor…',
      'onboardingSaveIssue':
          'Seçimlerin şu an kaydedilemedi — tekrar deneyebilirsin.',
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'Abonelik',
      'commonLoading': 'Yükleniyor…',
      'commonRetry': 'Tekrar dene',
      'commonClose': 'Kapat',
      'todayGreeting': 'Bugünün ritmi',
      'todayGentleLine': 'Bugün için küçük adımlar.',
      'todayPrayerCardTitle': 'Bugünün namaz takibi',
      'todayPrayerProgress': '{completed}/{total} tamamlandı',
      'todayGoToPrayers': 'Namazlara git',
      'todayLocalNote': 'Kayıtların cihazında saklanır.',
      'todayLoadIssue': 'Özet şu an açılamadı.',
      'todaySmallStepTitle': 'Bugün için küçük bir adım',
      'todaySmallStepBadge': 'Kişiselleştirilmiş öneri',
      'todaySuggestionTrackPrayers':
          'Bugünkü namazlarını işaretleyerek günlük ritmini görünür kıl.',
      'todaySuggestionPrayOnTime':
          'Sıradaki namaz vaktine göz atarak gününde sakin bir yer aç.',
      'todaySuggestionQuran': "Bugün kısa bir Kur'an okuma anı ayır.",
      'todaySuggestionDhikr':
          'Bugün kısa bir dua veya zikir için sakin bir an seç.',
      'todaySuggestionKnowledge': 'Bugün kısa bir konuyla bilgini tazele.',
      'todayPaceLight': 'Birkaç dakikalık küçük bir adım yeterli.',
      'todayPaceBalanced': 'Gününde kısa ve düzenli bir alan ayır.',
      'todayPaceFocused':
          'Bugün biraz daha uzun ve sakin bir alan ayırabilirsin.',
      'todayCtaSeeTimes': 'Vakitleri gör',
      'todayCtaGoQuran': "Kur'an'a git",
      'todayCtaGoLearn': "Öğren'e git",
      'todayWeeklyRhythmLine': 'Haftalık ritmine sakin bir bakış.',
      'todayWeeklyHistoryCta': 'Geçmişi gör',
      'todayNextPrayerTitle': 'Sıradaki namaz',
      'todayNextPrayerAllDone': 'Bugünün vakitleri tamamlandı.',
      'todayNextPrayerLocationCta': 'Vakitleri görmek için konumu kullan.',
      'todayNextPrayerUnavailable': 'Vakitler şu an gösterilemiyor.',
      'prayerTodaySubtitle': 'Bugünün namaz takibi',
      'prayerGentleLine': 'Bugün için küçük bir adım.',
      'prayerMark': 'İşaretle',
      'prayerCompleted': 'Tamamlandı',
      'prayerUndo': 'Geri al',
      'prayerLocalNote': 'Kayıtlar cihazında güvenle saklanır.',
      'prayerSaveIssue': 'Kaydedilemedi — dilediğinde tekrar deneyebilirsin.',
      'prayerLoadIssue': 'Kayıtlar şu an açılamadı.',
      'prayerNameFajr': 'Sabah',
      'prayerNameDhuhr': 'Öğle',
      'prayerNameAsr': 'İkindi',
      'prayerNameMaghrib': 'Akşam',
      'prayerNameIsha': 'Yatsı',
      'prayerHistoryTitle': 'Son 7 gün',
      'prayerHistorySubtitle': 'Günlük ritmine sakin bir bakış.',
      'prayerTimesMethodLabel': 'Türkiye hesaplama yöntemi',
      'prayerTimesSunrise': 'Güneş',
      'prayerTimesUseLocation': 'Konumu kullan',
      'prayerTimesLocationInvite':
          'Vakitleri bulunduğun yere göre görmek için konumunu kullanabilirsin.',
      'prayerTimesLocationDeniedForever':
          'Konum izni kapalı. Ayarlardan açarsan vakitleri gösterebiliriz.',
      'prayerTimesOpenSettings': 'Ayarları aç',
      'prayerTimesUnavailable':
          'Konum şu an alınamadı — dilediğinde tekrar deneyebilirsin.',
      'prayerTimesApproximate': 'Yaklaşık konuma göre',
      'reminderCardTitle': 'Namaz hatırlatıcıları',
      'reminderEnable': 'Hatırlatıcıları aç',
      'reminderDisable': 'Hatırlatıcıları kapat',
      'reminderEnabledState': 'Hatırlatıcılar açık',
      'reminderInexactNote':
          'Hatırlatma zamanı cihazına göre birkaç dakika kayabilir.',
      'reminderPermissionNeeded': 'Hatırlatıcılar için bildirim izni gerekli.',
      'reminderLocationNeeded': 'Vakitleri hesaplamak için konum gerekli.',
      'reminderNotificationTitle': 'Namaz vakti',
      'reminderNotificationBody': '{prayer} vakti için sakin bir hatırlatma.',
      'profilePersonalizationTitle': 'Kişiselleştirme',
      'profilePersonalizationSubtitle': 'Başlangıç tercihlerin',
      'profileFocusAreas': 'Odak alanların',
      'profileJourneyStage': 'Yolculuk aşaman',
      'profileDailyPace': 'Günlük tempon',
      'profilePersonalizationEmpty':
          'Kişiselleştirme tercihlerin henüz tamamlanmamış.',
      'profilePersonalizationLoadIssue': 'Tercihlerin şu an açılamadı.',
      'profilePersonalizationEdit': 'Düzenle',
      'profilePersonalizationEditTitle': 'Kişiselleştirme tercihleri',
      'profilePersonalizationEditSupport':
          'Bu seçimleri dilediğin zaman değiştirebilirsin.',
      'profileSaveChanges': 'Değişiklikleri kaydet',
      'profileChangesSaved': 'Değişiklikler kaydedildi.',
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'Yolculuğunu derinleştirmek istersen…',
    },
    SupportedLocale.en: {
      'appTitle': 'Bismillah',
      'tabToday': 'Today',
      'tabPrayer': 'Prayer',
      'tabQuran': 'Quran',
      'tabLearn': 'Learn',
      'tabProfile': 'Profile',
      'assistantFabLabel': 'Bismillah Assistant',
      'assistantTitle': 'Bismillah Assistant',
      'placeholderComingSoon': 'This section is being prepared.',
      'onboardingTitle': 'Welcome',
      'onboardingWelcomeEyebrow': 'Bismillah for every day',
      'onboardingWelcomeTitle': 'Grow your worship calmly and consistently.',
      'onboardingWelcomeSupport':
          'Track your prayers, see the times, and move forward with small '
              'steps that fit you.',
      'onboardingWelcomeCta': "Let's begin",
      'onboardingWelcomeNote': 'No judgment, no pressure.',
      'onboardingGoalsTitle': 'What would you like to focus on right now?',
      'onboardingGoalsSupport': 'You can choose one or more options.',
      'onboardingGoalTrackPrayers': 'Track my prayers more consistently',
      'onboardingGoalPrayOnTime': 'Keep up with prayer times',
      'onboardingGoalQuranHabit': 'Make Quran reading a habit',
      'onboardingGoalDhikrRoutine': 'Grow my dua and dhikr routine',
      'onboardingGoalKnowledge': 'Deepen my Islamic knowledge',
      'onboardingGoalsCta': 'Continue',
      'onboardingJourneyTitle': 'How do you see yourself on this journey?',
      'onboardingJourneySupport':
          'This helps us prepare a start that fits you.',
      'onboardingJourneyNew': 'I am just beginning',
      'onboardingJourneyRebuilding': 'I am rebuilding my routine',
      'onboardingJourneyStrengthening': 'I want to strengthen my routine',
      'onboardingPaceTitle': 'What should your daily pace be?',
      'onboardingPaceSupport': 'You can change this later.',
      'onboardingPaceLight': 'Light',
      'onboardingPaceLightDesc': 'Small, easy steps',
      'onboardingPaceBalanced': 'Balanced',
      'onboardingPaceBalancedDesc': 'A steady daily rhythm',
      'onboardingPaceFocused': 'Focused',
      'onboardingPaceFocusedDesc': 'I want to give it a bit more time',
      'onboardingPaceCta': 'Prepare my plan',
      'onboardingPreparingStart': 'Preparing your start…',
      'onboardingSaveIssue':
          'Your choices could not be saved right now — you can try again.',
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'Subscription',
      'commonLoading': 'Loading…',
      'commonRetry': 'Try again',
      'commonClose': 'Close',
      'todayGreeting': "Today's rhythm",
      'todayGentleLine': 'Small steps for today.',
      'todayPrayerCardTitle': "Today's prayer tracking",
      'todayPrayerProgress': '{completed}/{total} completed',
      'todayGoToPrayers': 'Go to prayers',
      'todayLocalNote': 'Your records stay on your device.',
      'todayLoadIssue': 'The summary could not be opened right now.',
      'todaySmallStepTitle': 'A small step for today',
      'todaySmallStepBadge': 'Personalized suggestion',
      'todaySuggestionTrackPrayers':
          "Make your daily rhythm visible by marking today's prayers.",
      'todaySuggestionPrayOnTime':
          'Open a calm space in your day by glancing at the next prayer time.',
      'todaySuggestionQuran':
          'Set aside a short moment for Quran reading today.',
      'todaySuggestionDhikr':
          'Choose a calm moment today for a short dua or dhikr.',
      'todaySuggestionKnowledge':
          'Refresh your knowledge with a short topic today.',
      'todayPaceLight': 'A small step of a few minutes is enough.',
      'todayPaceBalanced': 'Set aside a short, steady space in your day.',
      'todayPaceFocused': 'You could give it a bit more calm time today.',
      'todayCtaSeeTimes': 'See the times',
      'todayCtaGoQuran': 'Go to Quran',
      'todayCtaGoLearn': 'Go to Learn',
      'todayWeeklyRhythmLine': 'A calm look at your weekly rhythm.',
      'todayWeeklyHistoryCta': 'See history',
      'todayNextPrayerTitle': 'Next prayer',
      'todayNextPrayerAllDone': "Today's prayer times are complete.",
      'todayNextPrayerLocationCta': 'Use your location to see the times.',
      'todayNextPrayerUnavailable': 'Times are unavailable right now.',
      'prayerTodaySubtitle': "Today's prayer tracking",
      'prayerGentleLine': 'A small step for today.',
      'prayerMark': 'Mark',
      'prayerCompleted': 'Completed',
      'prayerUndo': 'Undo',
      'prayerLocalNote': 'Your records are stored safely on your device.',
      'prayerSaveIssue': 'Could not save — you can try again anytime.',
      'prayerLoadIssue': 'Your records could not be opened right now.',
      'prayerNameFajr': 'Fajr',
      'prayerNameDhuhr': 'Dhuhr',
      'prayerNameAsr': 'Asr',
      'prayerNameMaghrib': 'Maghrib',
      'prayerNameIsha': 'Isha',
      'prayerHistoryTitle': 'Last 7 days',
      'prayerHistorySubtitle': 'A calm look at your daily rhythm.',
      'prayerTimesMethodLabel': 'Türkiye calculation method',
      'prayerTimesSunrise': 'Sunrise',
      'prayerTimesUseLocation': 'Use location',
      'prayerTimesLocationInvite':
          'Use your location to see times for where you are.',
      'prayerTimesLocationDeniedForever':
          'Location is off. Enable it in Settings to show your times.',
      'prayerTimesOpenSettings': 'Open settings',
      'prayerTimesUnavailable':
          'Location is unavailable right now — you can try again anytime.',
      'prayerTimesApproximate': 'Based on approximate location',
      'reminderCardTitle': 'Prayer reminders',
      'reminderEnable': 'Turn on reminders',
      'reminderDisable': 'Turn off reminders',
      'reminderEnabledState': 'Reminders are on',
      'reminderInexactNote':
          'Reminder timing may vary by a few minutes on your device.',
      'reminderPermissionNeeded':
          'Notification permission is needed for reminders.',
      'reminderLocationNeeded': 'Location is needed to calculate the times.',
      'reminderNotificationTitle': 'Prayer time',
      'reminderNotificationBody': 'A calm reminder for {prayer}.',
      'profilePersonalizationTitle': 'Personalization',
      'profilePersonalizationSubtitle': 'Your starting preferences',
      'profileFocusAreas': 'Your focus areas',
      'profileJourneyStage': 'Your journey stage',
      'profileDailyPace': 'Your daily pace',
      'profilePersonalizationEmpty':
          'Your personalization preferences are not completed yet.',
      'profilePersonalizationLoadIssue':
          'Your preferences could not be opened right now.',
      'profilePersonalizationEdit': 'Edit',
      'profilePersonalizationEditTitle': 'Personalization preferences',
      'profilePersonalizationEditSupport':
          'You can change these choices anytime.',
      'profileSaveChanges': 'Save changes',
      'profileChangesSaved': 'Changes saved.',
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'If you would like to go deeper…',
    },
    SupportedLocale.ar: {
      'appTitle': 'Bismillah',
      'tabToday': 'اليوم',
      'tabPrayer': 'الصلاة',
      'tabQuran': 'القرآن',
      'tabLearn': 'تعلّم',
      'tabProfile': 'الملف',
      'assistantFabLabel': 'مساعد Bismillah',
      'assistantTitle': 'مساعد Bismillah',
      'placeholderComingSoon': 'هذا القسم قيد التجهيز.',
      'onboardingTitle': 'أهلاً بك',
      'onboardingWelcomeEyebrow': 'بسم الله لكل يوم',
      'onboardingWelcomeTitle': 'طوّر عباداتك بهدوء وانتظام.',
      'onboardingWelcomeSupport':
          'تابع صلواتك، واطّلع على الأوقات، وتقدّم بخطوات صغيرة تناسبك.',
      'onboardingWelcomeCta': 'لنبدأ',
      'onboardingWelcomeNote': 'بلا حكم، وبلا ضغط.',
      'onboardingGoalsTitle': 'علامَ تودّ التركيز الآن؟',
      'onboardingGoalsSupport': 'يمكنك اختيار خيار واحد أو أكثر.',
      'onboardingGoalTrackPrayers': 'متابعة صلواتي بانتظام أكبر',
      'onboardingGoalPrayOnTime': 'المواظبة على أوقات الصلاة',
      'onboardingGoalQuranHabit': 'جعل قراءة القرآن عادة',
      'onboardingGoalDhikrRoutine': 'تطوير وردي من الدعاء والذكر',
      'onboardingGoalKnowledge': 'زيادة معرفتي الإسلامية',
      'onboardingGoalsCta': 'متابعة',
      'onboardingJourneyTitle': 'كيف ترى نفسك في هذه الرحلة؟',
      'onboardingJourneySupport': 'يساعدنا هذا على تجهيز بداية تناسبك.',
      'onboardingJourneyNew': 'أبدأ للتو',
      'onboardingJourneyRebuilding': 'أُعيد بناء انتظامي',
      'onboardingJourneyStrengthening': 'أريد تقوية انتظامي',
      'onboardingPaceTitle': 'كيف تحب أن يكون إيقاعك اليومي؟',
      'onboardingPaceSupport': 'يمكنك تغيير هذا لاحقاً.',
      'onboardingPaceLight': 'خفيف',
      'onboardingPaceLightDesc': 'خطوات صغيرة وسهلة',
      'onboardingPaceBalanced': 'متوازن',
      'onboardingPaceBalancedDesc': 'إيقاع يومي منتظم',
      'onboardingPaceFocused': 'مركّز',
      'onboardingPaceFocusedDesc': 'أودّ تخصيص وقت أكبر',
      'onboardingPaceCta': 'جهّز خطتي',
      'onboardingPreparingStart': 'يجري تجهيز بدايتك…',
      'onboardingSaveIssue':
          'تعذّر حفظ اختياراتك الآن — يمكنك المحاولة مجدداً.',
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'الاشتراك',
      'commonLoading': 'جارٍ التحميل…',
      'commonRetry': 'حاول مجدداً',
      'commonClose': 'إغلاق',
      'todayGreeting': 'إيقاع اليوم',
      'todayGentleLine': 'خطوات صغيرة لهذا اليوم.',
      'todayPrayerCardTitle': 'متابعة صلوات اليوم',
      'todayPrayerProgress': 'اكتملت {completed}/{total}',
      'todayGoToPrayers': 'اذهب إلى الصلوات',
      'todayLocalNote': 'تبقى سجلاتك على جهازك.',
      'todayLoadIssue': 'تعذّر فتح الملخّص الآن.',
      'todaySmallStepTitle': 'خطوة صغيرة لهذا اليوم',
      'todaySmallStepBadge': 'اقتراح مخصّص لك',
      'todaySuggestionTrackPrayers':
          'اجعل إيقاعك اليومي ظاهراً بتسجيل صلوات اليوم.',
      'todaySuggestionPrayOnTime':
          'افتح مساحة هادئة في يومك بالاطلاع على وقت الصلاة القادمة.',
      'todaySuggestionQuran': 'خصّص اليوم لحظة قصيرة لقراءة القرآن.',
      'todaySuggestionDhikr': 'اختر اليوم لحظة هادئة لدعاء أو ذكر قصير.',
      'todaySuggestionKnowledge': 'جدّد معلوماتك اليوم بموضوع قصير.',
      'todayPaceLight': 'خطوة صغيرة من بضع دقائق تكفي.',
      'todayPaceBalanced': 'خصّص مساحة قصيرة ومنتظمة في يومك.',
      'todayPaceFocused': 'يمكنك اليوم تخصيص وقت هادئ أطول قليلاً.',
      'todayCtaSeeTimes': 'اطّلع على الأوقات',
      'todayCtaGoQuran': 'اذهب إلى القرآن',
      'todayCtaGoLearn': 'اذهب إلى التعلّم',
      'todayWeeklyRhythmLine': 'نظرة هادئة إلى إيقاعك الأسبوعي.',
      'todayWeeklyHistoryCta': 'عرض السجل',
      'todayNextPrayerTitle': 'الصلاة القادمة',
      'todayNextPrayerAllDone': 'اكتملت أوقات صلوات اليوم.',
      'todayNextPrayerLocationCta': 'استخدم موقعك لعرض الأوقات.',
      'todayNextPrayerUnavailable': 'الأوقات غير متاحة الآن.',
      'prayerTodaySubtitle': 'متابعة صلوات اليوم',
      'prayerGentleLine': 'خطوة صغيرة لهذا اليوم.',
      'prayerMark': 'تسجيل',
      'prayerCompleted': 'تمّت',
      'prayerUndo': 'تراجع',
      'prayerLocalNote': 'تُحفَظ سجلاتك بأمان على جهازك.',
      'prayerSaveIssue': 'تعذّر الحفظ — يمكنك المحاولة مجدداً في أي وقت.',
      'prayerLoadIssue': 'تعذّر فتح السجلات الآن.',
      'prayerNameFajr': 'الفجر',
      'prayerNameDhuhr': 'الظهر',
      'prayerNameAsr': 'العصر',
      'prayerNameMaghrib': 'المغرب',
      'prayerNameIsha': 'العشاء',
      'prayerHistoryTitle': 'آخر 7 أيام',
      'prayerHistorySubtitle': 'نظرة هادئة إلى إيقاعك اليومي.',
      'prayerTimesMethodLabel': 'طريقة الحساب التركية',
      'prayerTimesSunrise': 'الشروق',
      'prayerTimesUseLocation': 'استخدم الموقع',
      'prayerTimesLocationInvite':
          'استخدم موقعك لعرض الأوقات وفق مكانك.',
      'prayerTimesLocationDeniedForever':
          'الموقع متوقّف. فعّله من الإعدادات لعرض الأوقات.',
      'prayerTimesOpenSettings': 'افتح الإعدادات',
      'prayerTimesUnavailable':
          'تعذّر الحصول على الموقع الآن — يمكنك المحاولة لاحقاً.',
      'prayerTimesApproximate': 'بحسب موقع تقريبي',
      'reminderCardTitle': 'تذكيرات الصلاة',
      'reminderEnable': 'تفعيل التذكيرات',
      'reminderDisable': 'إيقاف التذكيرات',
      'reminderEnabledState': 'التذكيرات مفعّلة',
      'reminderInexactNote': 'قد يتغيّر وقت التذكير بضع دقائق حسب جهازك.',
      'reminderPermissionNeeded': 'يلزم إذن الإشعارات للتذكيرات.',
      'reminderLocationNeeded': 'يلزم تحديد الموقع لحساب الأوقات.',
      'reminderNotificationTitle': 'وقت الصلاة',
      'reminderNotificationBody': 'تذكير هادئ لصلاة {prayer}.',
      'profilePersonalizationTitle': 'التخصيص',
      'profilePersonalizationSubtitle': 'تفضيلاتك الأولى',
      'profileFocusAreas': 'مجالات تركيزك',
      'profileJourneyStage': 'مرحلة رحلتك',
      'profileDailyPace': 'إيقاعك اليومي',
      'profilePersonalizationEmpty': 'لم تكتمل تفضيلات التخصيص بعد.',
      'profilePersonalizationLoadIssue': 'تعذّر فتح تفضيلاتك الآن.',
      'profilePersonalizationEdit': 'تعديل',
      'profilePersonalizationEditTitle': 'تفضيلات التخصيص',
      'profilePersonalizationEditSupport':
          'يمكنك تغيير هذه الاختيارات في أي وقت.',
      'profileSaveChanges': 'حفظ التغييرات',
      'profileChangesSaved': 'تم حفظ التغييرات.',
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'إن أحببت أن تتعمق في رحلتك…',
    },
  };
}

final class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      SupportedLocale.locales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(SupportedLocale.fromLocale(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
