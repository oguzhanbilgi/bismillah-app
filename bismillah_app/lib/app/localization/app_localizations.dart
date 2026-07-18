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
  String get commonGotIt => _t('commonGotIt');

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

  // Kur'an okuma hedefi (TASK 032 — yalnız hedef; okuma kaydı TASK 033.
  // Ton: sakin; streak/puan/suçlama YOK, ayet metni YOK)
  String get quranSupportLine => _t('quranSupportLine');
  String get quranGoalSetupTitle => _t('quranGoalSetupTitle');
  String get quranGoalSetupSupport => _t('quranGoalSetupSupport');
  String get quranGoalSaveCta => _t('quranGoalSaveCta');
  String get quranTodayGoalTitle => _t('quranTodayGoalTitle');
  String get quranGoalGentleLine => _t('quranGoalGentleLine');
  String get quranGoalChange => _t('quranGoalChange');
  String get quranGoalSaveIssue => _t('quranGoalSaveIssue');
  String get quranGoalLoadIssue => _t('quranGoalLoadIssue');

  /// "3 sayfa" biçimli sayfa etiketi (tekil/çoğul localization'da).
  String quranPagesCount(int count) => count == 1
      ? _t('quranPagesOne')
      : _t('quranPagesOther').replaceAll('{count}', '$count');

  /// "0 / 3 sayfa" biçimli günlük ilerleme metni.
  String quranPagesProgress(int read, int goal) => _t(
    'quranPagesProgress',
  ).replaceAll('{read}', '$read').replaceAll('{goal}', '$goal');

  // Kur'an ana ekranı + ilk kurulum (TASK 033 — sure/ayet/meal içeriği
  // YOK; kurulum yalnız Kur'an sekmesi içinde yaşar)
  String get quranTabRead => _t('quranTabRead');
  String get quranTabLearn => _t('quranTabLearn');
  String get quranTabProgress => _t('quranTabProgress');
  String get quranSetupScriptTitle => _t('quranSetupScriptTitle');
  String get quranScriptUthmani => _t('quranScriptUthmani');
  String get quranScriptUthmaniDesc => _t('quranScriptUthmaniDesc');
  String get quranScriptIndoPak => _t('quranScriptIndoPak');
  String get quranScriptIndoPakDesc => _t('quranScriptIndoPakDesc');
  String get quranSetupTranslationTitle => _t('quranSetupTranslationTitle');
  String get quranTranslationTurkish => _t('quranTranslationTurkish');
  String get quranTranslationTurkishDesc => _t('quranTranslationTurkishDesc');
  String get quranSetupGoalTitle => _t('quranSetupGoalTitle');
  String get quranGoalTypeMinutes => _t('quranGoalTypeMinutes');
  String get quranGoalTypePages => _t('quranGoalTypePages');
  String get quranSetupBack => _t('quranSetupBack');
  String get quranSetupContinue => _t('quranSetupContinue');
  String get quranSetupFinishCta => _t('quranSetupFinishCta');
  String get quranResumeTitle => _t('quranResumeTitle');
  String get quranResumeEmpty => _t('quranResumeEmpty');
  String get quranSurahsSection => _t('quranSurahsSection');
  String get quranLearnTitle => _t('quranLearnTitle');
  String get quranLearnBody => _t('quranLearnBody');
  String get quranGoalEdit => _t('quranGoalEdit');

  // Sure kataloğu (TASK 034/034B — yalnız metadata; ayet metni TASK 035)
  String get quranRevelationMeccan => _t('quranRevelationMeccan');
  String get quranRevelationMedinan => _t('quranRevelationMedinan');
  String get quranSearchHint => _t('quranSearchHint');
  String get quranSearchNoResults => _t('quranSearchNoResults');
  String get quranChaptersLoadIssue => _t('quranChaptersLoadIssue');

  // Sure okuyucu (TASK 035 — doğrulanmış Uthmani metin; meal/ses YOK)
  String get quranReaderLoadIssue => _t('quranReaderLoadIssue');
  String get quranTextSourceLabel => _t('quranTextSourceLabel');

  // Son okuma konumu (TASK 036 — devam kartı; ayet numarası gösterilmez)
  String get quranResumeCta => _t('quranResumeCta');
  String get quranPositionLoadIssue => _t('quranPositionLoadIssue');

  // Ayet kaydetme + okuma görünümü (TASK 037 — liste ekranı TASK 038)
  String get quranBookmarkAdd => _t('quranBookmarkAdd');
  String get quranBookmarkSaved => _t('quranBookmarkSaved');
  String get quranBookmarkSaveIssue => _t('quranBookmarkSaveIssue');
  String get quranBookmarkRemoveIssue => _t('quranBookmarkRemoveIssue');
  String get quranReaderSettings => _t('quranReaderSettings');
  String get quranReaderViewTitle => _t('quranReaderViewTitle');

  /// Tt okuma ayarları keşif göstergesi metni (TASK 044).
  String get quranSettingsHint => _t('quranSettingsHint');
  String get quranArabicTextSizeLabel => _t('quranArabicTextSizeLabel');
  String get quranTextSizeSmall => _t('quranTextSizeSmall');
  String get quranTextSizeMedium => _t('quranTextSizeMedium');
  String get quranTextSizeLarge => _t('quranTextSizeLarge');

  // Diyanet Türkçe meali (TASK 040 — güvenli callable üzerinden; meal
  // içeriği localization'a KOPYALANMAZ)
  String get quranShowTranslationToggle => _t('quranShowTranslationToggle');
  String get quranTranslationSourceLabel => _t('quranTranslationSourceLabel');
  String get quranDiyanetSourceName => _t('quranDiyanetSourceName');
  String get quranTranslationLoading => _t('quranTranslationLoading');
  String get quranTranslationLoadIssue => _t('quranTranslationLoadIssue');

  // Aktif meal kaynağı: QuranEnc Rowad V1.0.4 (CHECKPOINT 06 Recovery —
  // offline asset; Diyanet etiketleri inactive kaynak için saklı durur)
  String get quranTranslationRowadLine => _t('quranTranslationRowadLine');
  String get quranTranslationQuranEncLine => _t('quranTranslationQuranEncLine');

  // Ayet sesi (TASK 041 — MP3Quran read 5; arka plan oynatma YOK)
  String get quranAudioPlay => _t('quranAudioPlay');
  String get quranAudioPause => _t('quranAudioPause');
  String get quranAudioResume => _t('quranAudioResume');
  String get quranAudioLoading => _t('quranAudioLoading');
  String get quranAudioLoadIssue => _t('quranAudioLoadIssue');
  String get quranAudioSourceLabel => _t('quranAudioSourceLabel');
  String get quranReciterName => _t('quranReciterName');
  String get quranRewayaName => _t('quranRewayaName');

  // Kesintisiz sure dinleme (TASK 042 — arka plan oynatma YOK)
  String get quranChapterAudioPlay => _t('quranChapterAudioPlay');
  String get quranChapterAudioStop => _t('quranChapterAudioStop');
  String get quranAudioPrevVerse => _t('quranAudioPrevVerse');
  String get quranAudioNextVerse => _t('quranAudioNextVerse');
  String get quranChapterAudioLoadIssue => _t('quranChapterAudioLoadIssue');

  // Global arka plan ses oturumu (TASK 045)
  String get quranAudioChannelName => _t('quranAudioChannelName');
  String get quranAudioServiceUnavailable => _t('quranAudioServiceUnavailable');

  /// Mini oynatıcı gövdesi: aktif surenin okuyucusuna dönüş (TASK 046).
  String get quranMiniPlayerOpen => _t('quranMiniPlayerOpen');

  // Gerçek günlük hedef ve okuma ilerlemesi (TASK 047 — yalnız cihazda)
  String quranMinutesRemaining(int count) =>
      _t('quranMinutesRemaining').replaceAll('{count}', '$count');
  String quranPagesRemaining(int count) =>
      _t('quranPagesRemaining').replaceAll('{count}', '$count');
  String get quranGoalCompletedLine => _t('quranGoalCompletedLine');
  String get quranTodayActivityTitle => _t('quranTodayActivityTitle');
  String get quranActiveReadingLabel => _t('quranActiveReadingLabel');
  String get quranViewedVersesLabel => _t('quranViewedVersesLabel');
  String get quranViewedPagesLabel => _t('quranViewedPagesLabel');
  String get quranLast7DaysTitle => _t('quranLast7DaysTitle');
  String get quranStreakTitle => _t('quranStreakTitle');
  String quranDaysCount(int count) =>
      _t('quranDaysCount').replaceAll('{count}', '$count');
  String get quranProgressUnavailable => _t('quranProgressUnavailable');
  String get quranPageProgressUnavailable => _t('quranPageProgressUnavailable');

  // Offline Kur'an araması (TASK 048 — sorgular cihaz dışına ÇIKMAZ)
  String get quranSearchTitle => _t('quranSearchTitle');
  String get quranSearchFieldHint => _t('quranSearchFieldHint');
  String get quranSearchVersesSection => _t('quranSearchVersesSection');
  String quranSearchResultCount(int count) =>
      _t('quranSearchResultCount').replaceAll('{count}', '$count');
  String get quranSearchNoMatches => _t('quranSearchNoMatches');
  String get quranSearchUnavailable => _t('quranSearchUnavailable');
  String get quranSearchClear => _t('quranSearchClear');
  String get quranSearchGoToVerse => _t('quranSearchGoToVerse');
  String get quranSearchLoading => _t('quranSearchLoading');

  // Kâri seçimi (TASK 049 — kâri isimleri API'den doğrulanır, buraya
  // KOPYALANMAZ; yalnız arayüz etiketleri)
  String get quranReciterLabel => _t('quranReciterLabel');
  String get quranReciterSelectTitle => _t('quranReciterSelectTitle');
  String get quranReciterListLoadIssue => _t('quranReciterListLoadIssue');
  String get quranReciterChangeStopsPlayback =>
      _t('quranReciterChangeStopsPlayback');
  String get quranReciterDefaultLabel => _t('quranReciterDefaultLabel');
  String get quranReciterSelectedLabel => _t('quranReciterSelectedLabel');
  String get quranReciterSearchHint => _t('quranReciterSearchHint');
  String get quranReciterChangeFailed => _t('quranReciterChangeFailed');

  /// "Ayet 3 / 7" biçimli aktif ayet bilgisi.
  String quranAudioVerseOf(int current, int total) => _t(
    'quranAudioVerseOf',
  ).replaceAll('{current}', '$current').replaceAll('{total}', '$total');

  // Kaydedilen ayetler + Today Kur'an devam kartı (TASK 038)
  String get quranSavedVersesTitle => _t('quranSavedVersesTitle');
  String get quranSavedVersesEmptyTitle => _t('quranSavedVersesEmptyTitle');
  String get quranSavedVersesEmptyBody => _t('quranSavedVersesEmptyBody');
  String get quranSavedVersesLoadIssue => _t('quranSavedVersesLoadIssue');
  String get quranBookmarkRemove => _t('quranBookmarkRemove');
  String get quranGoToReading => _t('quranGoToReading');
  String get todayQuranContinueTitle => _t('todayQuranContinueTitle');
  String get todayQuranEmptyLine => _t('todayQuranEmptyLine');
  String get todayQuranStartCta => _t('todayQuranStartCta');
  String get todayQuranSetupLine => _t('todayQuranSetupLine');

  /// "Günlük hedefin: 3 sayfa" biçimli hedef satırı.
  String todayQuranDailyGoal(String goal) =>
      _t('todayQuranDailyGoal').replaceAll('{goal}', goal);

  // Today Kur'an merkezi (TASK 050)
  String get todayQuranSectionTitle => _t('todayQuranSectionTitle');
  String get todayQuranStartBody => _t('todayQuranStartBody');
  String get todayQuranOpenCta => _t('todayQuranOpenCta');
  String get todayQuranResumeCta => _t('todayQuranResumeCta');
  String get todayQuranProgressUnavailable =>
      _t('todayQuranProgressUnavailable');

  /// "7 ayet" biçimli ayet sayısı etiketi.
  String quranAyahCount(int count) =>
      _t('quranAyahCount').replaceAll('{count}', '$count');

  /// "1 / 3" biçimli kurulum adım göstergesi.
  String quranSetupStepLabel(int step, int total) => _t(
    'quranSetupStepLabel',
  ).replaceAll('{step}', '$step').replaceAll('{total}', '$total');

  /// "10 dakika" biçimli süre etiketi.
  String quranMinutesCount(int count) =>
      _t('quranMinutesCount').replaceAll('{count}', '$count');

  /// "0 / 10 dakika" biçimli günlük ilerleme metni.
  String quranMinutesProgress(int read, int goal) => _t(
    'quranMinutesProgress',
  ).replaceAll('{read}', '$read').replaceAll('{goal}', '$goal');

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
      'onboardingGoalQuranHabit': "Kur'an okumayı alışkanlık haline getirmek",
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
      'commonGotIt': 'Anladım',
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
      'quranSupportLine':
          'Okuma alışkanlığın için küçük ve sürdürülebilir bir alan.',
      'quranGoalSetupTitle': 'Günlük okuma hedefin',
      'quranGoalSetupSupport': 'Gününe uygun küçük bir hedef seç.',
      'quranPagesOne': '1 sayfa',
      'quranPagesOther': '{count} sayfa',
      'quranGoalSaveCta': 'Hedefimi kaydet',
      'quranTodayGoalTitle': 'Bugünkü hedefin',
      'quranGoalGentleLine': 'Küçük ve düzenli adımlar yeterli.',
      'quranGoalChange': 'Hedefi değiştir',
      'quranPagesProgress': '{read} / {goal} sayfa',
      'quranGoalSaveIssue': 'Kaydedilemedi. Tekrar deneyebilirsin.',
      'quranGoalLoadIssue': 'Hedefin şu an açılamadı.',
      'quranTabRead': 'Oku',
      'quranTabLearn': 'Öğren',
      'quranTabProgress': 'İlerlemem',
      'quranSetupStepLabel': '{step} / {total}',
      'quranSetupScriptTitle': 'Arapça yazı biçimini seç',
      'quranScriptUthmani': 'Uthmani',
      'quranScriptUthmaniDesc':
          'Medine mushafı tarzında, yaygın ve sade yazım.',
      'quranScriptIndoPak': 'IndoPak',
      'quranScriptIndoPakDesc': "Güney Asya'da yaygın kullanılan yazım.",
      'quranSetupTranslationTitle': 'Meal tercihini seç',
      'quranTranslationTurkish': 'Türkçe',
      'quranTranslationTurkishDesc':
          'Doğrulanmış meal kaynağı içerik entegrasyonunda bağlanacak.',
      'quranSetupGoalTitle': 'Günlük hedef',
      'quranGoalTypeMinutes': 'Süre',
      'quranGoalTypePages': 'Sayfa',
      'quranMinutesCount': '{count} dakika',
      'quranMinutesProgress': '{read} / {goal} dakika',
      'quranSetupBack': 'Geri',
      'quranSetupContinue': 'Devam et',
      'quranSetupFinishCta': "Kur'an deneyimimi hazırla",
      'quranResumeTitle': 'Kaldığın yerden devam et',
      'quranResumeEmpty': 'İlk okumanda kaldığın yer burada görünecek.',
      'quranSurahsSection': 'Sureler',
      'quranLearnTitle': "Kur'an'ı anlayarak ilerle",
      'quranLearnBody': 'Tecvid ve öğrenme içerikleri yakında burada olacak.',
      'quranGoalEdit': 'Hedefi düzenle',
      'quranRevelationMeccan': 'Mekkî',
      'quranRevelationMedinan': 'Medenî',
      'quranAyahCount': '{count} ayet',
      'quranSearchHint': 'Sure ara',
      'quranSearchNoResults': 'Aramanla eşleşen sure bulunamadı.',
      'quranChaptersLoadIssue': 'Sure listesi şu an açılamadı.',
      'quranReaderLoadIssue': "Kur'an metni yüklenemedi.",
      'quranTextSourceLabel': "Kur'an metni kaynağı",
      'quranResumeCta': 'Devam et',
      'quranPositionLoadIssue': 'Okuma konumu yüklenemedi.',
      'quranBookmarkAdd': 'Ayeti kaydet',
      'quranBookmarkSaved': 'Kaydedildi',
      'quranBookmarkSaveIssue': 'Ayet kaydedilemedi.',
      'quranBookmarkRemoveIssue': 'Ayet kaydı kaldırılamadı.',
      'quranReaderSettings': 'Okuma ayarları',
      'quranSettingsHint':
          'Türkçe meali buradan açabilir, yazı boyutunu değiştirebilirsiniz.',
      'quranReaderViewTitle': 'Okuma görünümü',
      'quranArabicTextSizeLabel': 'Arapça metin boyutu',
      'quranTextSizeSmall': 'Küçük',
      'quranTextSizeMedium': 'Orta',
      'quranTextSizeLarge': 'Büyük',
      'quranShowTranslationToggle': 'Türkçe meali göster',
      'quranTranslationSourceLabel': 'Meal kaynağı',
      'quranDiyanetSourceName': 'Diyanet İşleri Başkanlığı Meali',
      'quranTranslationLoading': 'Türkçe meal yükleniyor…',
      'quranTranslationLoadIssue': 'Türkçe meal şu anda yüklenemedi.',
      'quranTranslationRowadLine': 'Meal: Rowad Tercüme Merkezi',
      'quranTranslationQuranEncLine': 'Kaynak: QuranEnc.com · V1.0.4',
      'quranAudioPlay': 'Dinle',
      'quranAudioPause': 'Duraklat',
      'quranAudioResume': 'Devam et',
      'quranAudioLoading': 'Ses yükleniyor…',
      'quranAudioLoadIssue': 'Ses şu anda oynatılamadı.',
      'quranAudioSourceLabel': 'Ses kaynağı',
      'quranReciterName': 'Ahmed el-Acemi',
      'quranRewayaName': 'Hafs an Asım',
      'quranChapterAudioPlay': 'Sureyi dinle',
      'quranChapterAudioStop': 'Oynatmayı durdur',
      'quranAudioPrevVerse': 'Önceki ayet',
      'quranAudioNextVerse': 'Sonraki ayet',
      'quranAudioVerseOf': 'Ayet {current} / {total}',
      'quranChapterAudioLoadIssue': 'Sure sesi yüklenemedi.',
      'quranAudioChannelName': "Kur'an Sesli Okuma",
      'quranAudioServiceUnavailable': 'Ses hizmeti başlatılamadı.',
      'quranMiniPlayerOpen': "Kur'an oynatıcısını aç",
      'quranMinutesRemaining': '{count} dakika kaldı',
      'quranPagesRemaining': '{count} sayfa kaldı',
      'quranGoalCompletedLine': 'Bugünkü hedefin tamamlandı.',
      'quranTodayActivityTitle': 'Bugünkü aktivite',
      'quranActiveReadingLabel': 'Aktif okuma süresi',
      'quranViewedVersesLabel': 'Görüntülenen ayet',
      'quranViewedPagesLabel': 'Görüntülenen sayfa',
      'quranLast7DaysTitle': 'Son 7 gün',
      'quranStreakTitle': "Kur'an hedefi serisi",
      'quranDaysCount': '{count} gün',
      'quranProgressUnavailable': 'İlerleme şu anda yüklenemedi.',
      'quranPageProgressUnavailable':
          'Sayfa ilerlemesi şu anda kullanılamıyor.',
      'quranSearchTitle': "Kur'an'da ara",
      'quranSearchFieldHint': 'Sure, ayet veya kelime ara',
      'quranSearchVersesSection': 'Ayetler',
      'quranSearchResultCount': '{count} sonuç',
      'quranSearchNoMatches': 'Aramanızla eşleşen sure veya ayet bulunamadı.',
      'quranSearchUnavailable': "Kur'an araması şu anda kullanılamıyor.",
      'quranSearchClear': 'Aramayı temizle',
      'quranSearchGoToVerse': 'Ayete git',
      'quranSearchLoading': 'Arama yükleniyor…',
      'quranReciterLabel': 'Kâri',
      'quranReciterSelectTitle': 'Kâri seç',
      'quranReciterListLoadIssue': 'Kâri listesi şu anda yüklenemedi.',
      'quranReciterChangeStopsPlayback':
          'Kâri değiştirildiğinde mevcut oynatma durur.',
      'quranReciterDefaultLabel': 'Varsayılan',
      'quranReciterSelectedLabel': 'Seçili',
      'quranReciterSearchHint': 'Kâri ara',
      'quranReciterChangeFailed': 'Kâri değiştirilemedi.',
      'quranSavedVersesTitle': 'Kaydedilen ayetler',
      'quranSavedVersesEmptyTitle': 'Henüz kaydedilmiş ayetin yok.',
      'quranSavedVersesEmptyBody':
          'Okurken tekrar dönmek istediğin ayetleri kaydedebilirsin.',
      'quranSavedVersesLoadIssue': 'Kaydedilen ayetler yüklenemedi.',
      'quranBookmarkRemove': 'Kaydı kaldır',
      'quranGoToReading': "Kur'an okumaya git",
      'todayQuranContinueTitle': "Kur'an'a devam et",
      'todayQuranEmptyLine':
          "İlk Kur'an okumanda kaldığın yer burada görünecek.",
      'todayQuranStartCta': "Kur'an okumaya başla",
      'todayQuranSetupLine': "Kur'an deneyimini hazırla.",
      'todayQuranDailyGoal': 'Günlük hedefin: {goal}',
      'todayQuranSectionTitle': "Bugünkü Kur'an",
      'todayQuranStartBody':
          'Çevrimdışı Arapça metin ve Türkçe meal ile okumaya başlayabilirsiniz.',
      'todayQuranOpenCta': "Kur'an'ı aç",
      'todayQuranResumeCta': 'Okumaya devam et',
      'todayQuranProgressUnavailable': "Kur'an ilerlemesi şu anda yüklenemedi.",
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
      'commonGotIt': 'Got it',
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
      'quranSupportLine': 'A small, sustainable space for your reading habit.',
      'quranGoalSetupTitle': 'Your daily reading goal',
      'quranGoalSetupSupport': 'Choose a small goal that fits your day.',
      'quranPagesOne': '1 page',
      'quranPagesOther': '{count} pages',
      'quranGoalSaveCta': 'Save my goal',
      'quranTodayGoalTitle': "Today's goal",
      'quranGoalGentleLine': 'Small, steady steps are enough.',
      'quranGoalChange': 'Change goal',
      'quranPagesProgress': '{read} / {goal} pages',
      'quranGoalSaveIssue': 'Could not save. You can try again.',
      'quranGoalLoadIssue': 'Your goal could not be loaded right now.',
      'quranTabRead': 'Read',
      'quranTabLearn': 'Learn',
      'quranTabProgress': 'My progress',
      'quranSetupStepLabel': '{step} / {total}',
      'quranSetupScriptTitle': 'Choose your Arabic script',
      'quranScriptUthmani': 'Uthmani',
      'quranScriptUthmaniDesc':
          'The widespread, clean style of the Madinah mushaf.',
      'quranScriptIndoPak': 'IndoPak',
      'quranScriptIndoPakDesc': 'The script commonly used across South Asia.',
      'quranSetupTranslationTitle': 'Choose your translation',
      'quranTranslationTurkish': 'Turkish',
      'quranTranslationTurkishDesc':
          'A verified translation source will be connected during content '
          'integration.',
      'quranSetupGoalTitle': 'Daily goal',
      'quranGoalTypeMinutes': 'Time',
      'quranGoalTypePages': 'Pages',
      'quranMinutesCount': '{count} minutes',
      'quranMinutesProgress': '{read} / {goal} minutes',
      'quranSetupBack': 'Back',
      'quranSetupContinue': 'Continue',
      'quranSetupFinishCta': 'Prepare my Quran experience',
      'quranResumeTitle': 'Continue where you left off',
      'quranResumeEmpty':
          'Where you left off will appear here after your first reading.',
      'quranSurahsSection': 'Surahs',
      'quranLearnTitle': 'Grow in understanding the Quran',
      'quranLearnBody': 'Tajweed and learning content will be here soon.',
      'quranGoalEdit': 'Edit goal',
      'quranRevelationMeccan': 'Meccan',
      'quranRevelationMedinan': 'Medinan',
      'quranAyahCount': '{count} verses',
      'quranSearchHint': 'Search surahs',
      'quranSearchNoResults': 'No surahs match your search.',
      'quranChaptersLoadIssue': 'The surah list could not be loaded right now.',
      'quranReaderLoadIssue': 'The Quran text could not be loaded.',
      'quranTextSourceLabel': 'Quran text source',
      'quranResumeCta': 'Continue',
      'quranPositionLoadIssue': 'Your reading position could not be loaded.',
      'quranBookmarkAdd': 'Save verse',
      'quranBookmarkSaved': 'Saved',
      'quranBookmarkSaveIssue': 'The verse could not be saved.',
      'quranBookmarkRemoveIssue': 'The saved verse could not be removed.',
      'quranReaderSettings': 'Reading settings',
      'quranSettingsHint':
          'You can turn on the Turkish translation and change the text '
          'size here.',
      'quranReaderViewTitle': 'Reading view',
      'quranArabicTextSizeLabel': 'Arabic text size',
      'quranTextSizeSmall': 'Small',
      'quranTextSizeMedium': 'Medium',
      'quranTextSizeLarge': 'Large',
      'quranShowTranslationToggle': 'Show the Turkish translation',
      'quranTranslationSourceLabel': 'Translation source',
      'quranDiyanetSourceName': 'Diyanet İşleri Başkanlığı Meali',
      'quranTranslationLoading': 'Loading the Turkish translation…',
      'quranTranslationLoadIssue':
          'The Turkish translation could not be loaded right now.',
      'quranTranslationRowadLine': 'Translation: Rowad Translation Center',
      'quranTranslationQuranEncLine': 'Source: QuranEnc.com · V1.0.4',
      'quranAudioPlay': 'Listen',
      'quranAudioPause': 'Pause',
      'quranAudioResume': 'Resume',
      'quranAudioLoading': 'Loading audio…',
      'quranAudioLoadIssue': 'The audio could not be played right now.',
      'quranAudioSourceLabel': 'Audio source',
      'quranReciterName': 'Ahmed al-Ajmi',
      'quranRewayaName': 'Hafs an Asim',
      'quranChapterAudioPlay': 'Listen to the surah',
      'quranChapterAudioStop': 'Stop playback',
      'quranAudioPrevVerse': 'Previous verse',
      'quranAudioNextVerse': 'Next verse',
      'quranAudioVerseOf': 'Verse {current} / {total}',
      'quranChapterAudioLoadIssue': 'The surah audio could not be loaded.',
      'quranAudioChannelName': 'Quran Audio Recitation',
      'quranAudioServiceUnavailable': 'The audio service could not be started.',
      'quranMiniPlayerOpen': 'Open the Quran player',
      'quranMinutesRemaining': '{count} minutes left',
      'quranPagesRemaining': '{count} pages left',
      'quranGoalCompletedLine': "Today's goal is complete.",
      'quranTodayActivityTitle': "Today's activity",
      'quranActiveReadingLabel': 'Active reading time',
      'quranViewedVersesLabel': 'Verses viewed',
      'quranViewedPagesLabel': 'Pages viewed',
      'quranLast7DaysTitle': 'Last 7 days',
      'quranStreakTitle': 'Quran goal streak',
      'quranDaysCount': '{count} days',
      'quranProgressUnavailable': 'Progress could not be loaded right now.',
      'quranPageProgressUnavailable': 'Page progress is unavailable right now.',
      'quranSearchTitle': 'Search the Quran',
      'quranSearchFieldHint': 'Search surah, verse, or word',
      'quranSearchVersesSection': 'Verses',
      'quranSearchResultCount': '{count} results',
      'quranSearchNoMatches': 'No surah or verse matches your search.',
      'quranSearchUnavailable': 'Quran search is unavailable right now.',
      'quranSearchClear': 'Clear search',
      'quranSearchGoToVerse': 'Go to verse',
      'quranSearchLoading': 'Searching…',
      'quranReciterLabel': 'Reciter',
      'quranReciterSelectTitle': 'Choose reciter',
      'quranReciterListLoadIssue':
          'The reciter list could not be loaded right now.',
      'quranReciterChangeStopsPlayback':
          'Changing the reciter stops the current playback.',
      'quranReciterDefaultLabel': 'Default',
      'quranReciterSelectedLabel': 'Selected',
      'quranReciterSearchHint': 'Search reciters',
      'quranReciterChangeFailed': 'The reciter could not be changed.',
      'quranSavedVersesTitle': 'Saved verses',
      'quranSavedVersesEmptyTitle': 'You have no saved verses yet.',
      'quranSavedVersesEmptyBody':
          'While reading, you can save verses you want to return to.',
      'quranSavedVersesLoadIssue': 'Saved verses could not be loaded.',
      'quranBookmarkRemove': 'Remove',
      'quranGoToReading': 'Go to Quran reading',
      'todayQuranContinueTitle': 'Continue your Quran',
      'todayQuranEmptyLine':
          'Where you leave off in your first Quran reading will appear here.',
      'todayQuranStartCta': 'Start reading the Quran',
      'todayQuranSetupLine': 'Prepare your Quran experience.',
      'todayQuranDailyGoal': 'Your daily goal: {goal}',
      'todayQuranSectionTitle': "Today's Quran",
      'todayQuranStartBody':
          'Start reading with offline Arabic text and Turkish translation.',
      'todayQuranOpenCta': 'Open the Quran',
      'todayQuranResumeCta': 'Continue reading',
      'todayQuranProgressUnavailable':
          'Quran progress could not be loaded right now.',
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
      'commonGotIt': 'حسنًا',
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
      'prayerTimesLocationInvite': 'استخدم موقعك لعرض الأوقات وفق مكانك.',
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
      'quranSupportLine': 'مساحة صغيرة ومستدامة لعادة قراءتك.',
      'quranGoalSetupTitle': 'هدفك اليومي في القراءة',
      'quranGoalSetupSupport': 'اختر هدفًا صغيرًا يناسب يومك.',
      'quranPagesOne': 'صفحة واحدة',
      'quranPagesOther': '{count} صفحات',
      'quranGoalSaveCta': 'احفظ هدفي',
      'quranTodayGoalTitle': 'هدفك لهذا اليوم',
      'quranGoalGentleLine': 'خطوات صغيرة ومنتظمة تكفي.',
      'quranGoalChange': 'تغيير الهدف',
      'quranPagesProgress': '{read} / {goal} صفحات',
      'quranGoalSaveIssue': 'تعذّر الحفظ. يمكنك المحاولة مرة أخرى.',
      'quranGoalLoadIssue': 'تعذّر فتح هدفك الآن.',
      'quranTabRead': 'اقرأ',
      'quranTabLearn': 'تعلّم',
      'quranTabProgress': 'تقدّمي',
      'quranSetupStepLabel': '{step} / {total}',
      'quranSetupScriptTitle': 'اختر نمط الخط العربي',
      'quranScriptUthmani': 'العثماني',
      'quranScriptUthmaniDesc': 'أسلوب مصحف المدينة، شائع وواضح.',
      'quranScriptIndoPak': 'إندوباك',
      'quranScriptIndoPakDesc': 'الخط الشائع في جنوب آسيا.',
      'quranSetupTranslationTitle': 'اختر ترجمتك',
      'quranTranslationTurkish': 'التركية',
      'quranTranslationTurkishDesc': 'سيُربط مصدر ترجمة موثّق عند دمج المحتوى.',
      'quranSetupGoalTitle': 'الهدف اليومي',
      'quranGoalTypeMinutes': 'المدة',
      'quranGoalTypePages': 'الصفحات',
      'quranMinutesCount': '{count} دقائق',
      'quranMinutesProgress': '{read} / {goal} دقائق',
      'quranSetupBack': 'رجوع',
      'quranSetupContinue': 'متابعة',
      'quranSetupFinishCta': 'جهّز تجربتي مع القرآن',
      'quranResumeTitle': 'تابع من حيث توقفت',
      'quranResumeEmpty': 'سيظهر هنا موضع توقفك بعد قراءتك الأولى.',
      'quranSurahsSection': 'السور',
      'quranLearnTitle': 'تقدّم في فهم القرآن',
      'quranLearnBody': 'ستتوفر هنا قريبًا محتويات التجويد والتعلّم.',
      'quranGoalEdit': 'تعديل الهدف',
      'quranRevelationMeccan': 'مكية',
      'quranRevelationMedinan': 'مدنية',
      'quranAyahCount': '{count} آيات',
      'quranSearchHint': 'ابحث عن سورة',
      'quranSearchNoResults': 'لا توجد سور مطابقة لبحثك.',
      'quranChaptersLoadIssue': 'تعذّر فتح قائمة السور الآن.',
      'quranReaderLoadIssue': 'تعذّر تحميل نص القرآن.',
      'quranTextSourceLabel': 'مصدر نص القرآن',
      'quranResumeCta': 'متابعة',
      'quranPositionLoadIssue': 'تعذّر تحميل موضع القراءة.',
      'quranBookmarkAdd': 'احفظ الآية',
      'quranBookmarkSaved': 'محفوظة',
      'quranBookmarkSaveIssue': 'تعذّر حفظ الآية.',
      'quranBookmarkRemoveIssue': 'تعذّرت إزالة حفظ الآية.',
      'quranReaderSettings': 'إعدادات القراءة',
      'quranSettingsHint':
          'يمكنك تفعيل الترجمة التركية وتغيير حجم النص من هنا.',
      'quranReaderViewTitle': 'عرض القراءة',
      'quranArabicTextSizeLabel': 'حجم النص العربي',
      'quranTextSizeSmall': 'صغير',
      'quranTextSizeMedium': 'متوسط',
      'quranTextSizeLarge': 'كبير',
      'quranShowTranslationToggle': 'إظهار الترجمة التركية',
      'quranTranslationSourceLabel': 'مصدر الترجمة',
      'quranDiyanetSourceName': 'Diyanet İşleri Başkanlığı Meali',
      'quranTranslationLoading': 'يتم تحميل الترجمة التركية…',
      'quranTranslationLoadIssue': 'تعذّر تحميل الترجمة التركية الآن.',
      'quranTranslationRowadLine': 'الترجمة: مركز رواد الترجمة',
      'quranTranslationQuranEncLine': 'المصدر: QuranEnc.com · V1.0.4',
      'quranAudioPlay': 'استمع',
      'quranAudioPause': 'إيقاف مؤقت',
      'quranAudioResume': 'متابعة',
      'quranAudioLoading': 'يتم تحميل الصوت…',
      'quranAudioLoadIssue': 'تعذّر تشغيل الصوت الآن.',
      'quranAudioSourceLabel': 'مصدر الصوت',
      'quranReciterName': 'أحمد بن علي العجمي',
      'quranRewayaName': 'حفص عن عاصم',
      'quranChapterAudioPlay': 'استمع إلى السورة',
      'quranChapterAudioStop': 'إيقاف التشغيل',
      'quranAudioPrevVerse': 'الآية السابقة',
      'quranAudioNextVerse': 'الآية التالية',
      'quranAudioVerseOf': 'الآية {current} / {total}',
      'quranChapterAudioLoadIssue': 'تعذّر تحميل صوت السورة.',
      'quranAudioChannelName': 'تلاوة القرآن الصوتية',
      'quranAudioServiceUnavailable': 'تعذّر بدء خدمة الصوت.',
      'quranMiniPlayerOpen': 'افتح مشغّل القرآن',
      'quranMinutesRemaining': 'بقيت {count} دقائق',
      'quranPagesRemaining': 'بقيت {count} صفحات',
      'quranGoalCompletedLine': 'اكتمل هدفك لهذا اليوم.',
      'quranTodayActivityTitle': 'نشاط اليوم',
      'quranActiveReadingLabel': 'مدة القراءة النشطة',
      'quranViewedVersesLabel': 'الآيات المعروضة',
      'quranViewedPagesLabel': 'الصفحات المعروضة',
      'quranLast7DaysTitle': 'آخر 7 أيام',
      'quranStreakTitle': 'سلسلة هدف القرآن',
      'quranDaysCount': '{count} أيام',
      'quranProgressUnavailable': 'تعذّر تحميل التقدم الآن.',
      'quranPageProgressUnavailable': 'تقدم الصفحات غير متاح الآن.',
      'quranSearchTitle': 'ابحث في القرآن',
      'quranSearchFieldHint': 'ابحث عن سورة أو آية أو كلمة',
      'quranSearchVersesSection': 'الآيات',
      'quranSearchResultCount': '{count} نتائج',
      'quranSearchNoMatches': 'لا توجد سورة أو آية مطابقة لبحثك.',
      'quranSearchUnavailable': 'بحث القرآن غير متاح الآن.',
      'quranSearchClear': 'امسح البحث',
      'quranSearchGoToVerse': 'اذهب إلى الآية',
      'quranSearchLoading': 'جارٍ البحث…',
      'quranReciterLabel': 'القارئ',
      'quranReciterSelectTitle': 'اختر القارئ',
      'quranReciterListLoadIssue': 'تعذّر تحميل قائمة القراء الآن.',
      'quranReciterChangeStopsPlayback':
          'عند تغيير القارئ يتوقف التشغيل الحالي.',
      'quranReciterDefaultLabel': 'افتراضي',
      'quranReciterSelectedLabel': 'محدد',
      'quranReciterSearchHint': 'ابحث عن قارئ',
      'quranReciterChangeFailed': 'تعذّر تغيير القارئ.',
      'quranSavedVersesTitle': 'الآيات المحفوظة',
      'quranSavedVersesEmptyTitle': 'لا توجد آيات محفوظة بعد.',
      'quranSavedVersesEmptyBody':
          'أثناء القراءة يمكنك حفظ الآيات التي تريد العودة إليها.',
      'quranSavedVersesLoadIssue': 'تعذّر تحميل الآيات المحفوظة.',
      'quranBookmarkRemove': 'إزالة الحفظ',
      'quranGoToReading': 'اذهب إلى قراءة القرآن',
      'todayQuranContinueTitle': 'تابع قراءة القرآن',
      'todayQuranEmptyLine': 'سيظهر هنا موضع توقفك في قراءتك الأولى للقرآن.',
      'todayQuranStartCta': 'ابدأ قراءة القرآن',
      'todayQuranSetupLine': 'جهّز تجربتك مع القرآن.',
      'todayQuranDailyGoal': 'هدفك اليومي: {goal}',
      'todayQuranSectionTitle': 'قرآن اليوم',
      'todayQuranStartBody':
          'ابدأ القراءة مع النص العربي بلا اتصال والترجمة التركية.',
      'todayQuranOpenCta': 'افتح القرآن',
      'todayQuranResumeCta': 'تابع القراءة',
      'todayQuranProgressUnavailable': 'تعذّر تحميل تقدّم القرآن الآن.',
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
