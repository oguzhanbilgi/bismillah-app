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

  // Learn sıcak giriş (TASK 055). Bu ifadeler AYET/HADİS DEĞİLDİR:
  // tırnak içine alınmaz, kaynak etiketi verilmez, dini vaat içermez.
  String get learnHeroTitle => _t('learnHeroTitle');
  String get learnHeroBody => _t('learnHeroBody');
  String get learnExploreSection => _t('learnExploreSection');

  // Learn bilgi kütüphanesi (TASK 056)
  String get learnSearchHint => _t('learnSearchHint');
  String get learnSearchEmpty => _t('learnSearchEmpty');
  String get learnContinueSection => _t('learnContinueSection');
  String get learnBeginnerPathSection => _t('learnBeginnerPathSection');
  String get learnFeaturedSection => _t('learnFeaturedSection');
  String get learnSavedSection => _t('learnSavedSection');
  String get learnCompletedSection => _t('learnCompletedSection');
  String get learnAllCategoriesSection => _t('learnAllCategoriesSection');
  String get learnCategoryPreparing => _t('learnCategoryPreparing');
  String get learnVerifyingTitle => _t('learnVerifyingTitle');
  String get learnVerifyingMessage => _t('learnVerifyingMessage');
  String get learnCategoryEmptyTitle => _t('learnCategoryEmptyTitle');
  String get learnLoadIssue => _t('learnLoadIssue');
  String get learnSave => _t('learnSave');
  String get learnSaved => _t('learnSaved');
  String get learnMarkCompleted => _t('learnMarkCompleted');
  String get learnCompleted => _t('learnCompleted');
  String get learnRelatedSection => _t('learnRelatedSection');
  String get learnSourcesSection => _t('learnSourcesSection');
  String get learnOpenOfficialPage => _t('learnOpenOfficialPage');
  String get learnLinkUnavailable => _t('learnLinkUnavailable');
  String get learnLastVerified => _t('learnLastVerified');
  String get learnOriginalLanguageTr => _t('learnOriginalLanguageTr');
  String get learnTranslationDisclaimer => _t('learnTranslationDisclaimer');
  String get learnGuidanceTitle => _t('learnGuidanceTitle');
  String get learnAskAssistantSoon => _t('learnAskAssistantSoon');
  String get learnDifferenceNoteTitle => _t('learnDifferenceNoteTitle');

  /// İçerik türü etiketleri — genel özet ile resmî fetva GÖRSEL olarak
  /// ayrılabilsin diye her içerikte gösterilir (TASK 056 §13).
  String get learnTypeGeneralTeaching => _t('learnTypeGeneralTeaching');
  String get learnTypeQuranExplanation => _t('learnTypeQuranExplanation');
  String get learnTypeHadithBased => _t('learnTypeHadithBased');
  String get learnTypeIlmihalKnowledge => _t('learnTypeIlmihalKnowledge');
  String get learnTypeOfficialFatwa => _t('learnTypeOfficialFatwa');

  String get learnDifficultyBeginner => _t('learnDifficultyBeginner');
  String get learnDifficultyBasic => _t('learnDifficultyBasic');
  String get learnDifficultyDeep => _t('learnDifficultyDeep');

  /// "5 dk okuma" biçimli süre etiketi.
  String learnReadingMinutes(int minutes) =>
      _t('learnReadingMinutes').replaceFirst('{minutes}', '$minutes');

  /// "12 konu" biçimli sayaç.
  String learnTopicCount(int count) =>
      _t('learnTopicCount').replaceFirst('{count}', '$count');

  // Profile ayar grubu başlığı (TASK 055).
  String get profileSettingsSection => _t('profileSettingsSection');
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

  // Dil ayarları (TASK 053). Dillerin KENDİ adları burada DEĞİLDİR —
  // `SupportedLocale.nativeName` çevrilmeden gösterilir.
  String get settingsLanguageTitle => _t('settingsLanguageTitle');
  String get settingsLanguageSubtitle => _t('settingsLanguageSubtitle');
  String get settingsLanguageSelected => _t('settingsLanguageSelected');
  String get settingsLanguageChanged => _t('settingsLanguageChanged');
  String get settingsLanguageTranslationNote =>
      _t('settingsLanguageTranslationNote');
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
  // Kur'an ana ekranı sıcak hero'su (TASK 054). Bu ifadeler AYET VEYA
  // HADİS DEĞİLDİR: tırnak içine alınmaz, kaynak etiketi verilmez.
  String get quranHomeHeroTitle => _t('quranHomeHeroTitle');
  String get quranHomeHeroBody => _t('quranHomeHeroBody');
  String get quranHomeContinueCta => _t('quranHomeContinueCta');
  String get todayJourneyTitle => _t('todayJourneyTitle');
  String get todayKeepGoingHint => _t('todayKeepGoingHint');

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

  // Today manevi hero + günün ayeti (TASK 052)
  String get todayHeroTitle => _t('todayHeroTitle');
  String get todayHeroBody => _t('todayHeroBody');
  String get todayHeroCta => _t('todayHeroCta');
  String get todayVerseSectionTitle => _t('todayVerseSectionTitle');
  String get todayVerseUnavailable => _t('todayVerseUnavailable');
  String get todayVerseOpenReader => _t('todayVerseOpenReader');

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

  // Profile ayar/veri merkezi (TASK 058)
  String get profileJourneySection => _t('profileJourneySection');
  String get profileLocalUsageTitle => _t('profileLocalUsageTitle');
  String get profileLocalUsageBody => _t('profileLocalUsageBody');
  String get profileAppSection => _t('profileAppSection');
  String get profilePrayerSection => _t('profilePrayerSection');
  String get profileQuranSection => _t('profileQuranSection');
  String get profileLearnSection => _t('profileLearnSection');
  String get profileSupportSection => _t('profileSupportSection');

  String get settingsNotificationsTitle => _t('settingsNotificationsTitle');
  String get settingsNotificationsSubtitle =>
      _t('settingsNotificationsSubtitle');
  String get settingsPrivacyDataTitle => _t('settingsPrivacyDataTitle');

  String get profilePrayerTimesRow => _t('profilePrayerTimesRow');
  String get profilePrayerTimesSubtitle => _t('profilePrayerTimesSubtitle');
  String get profilePrayerTrackingRow => _t('profilePrayerTrackingRow');
  String get profilePrayerTrackingSubtitle =>
      _t('profilePrayerTrackingSubtitle');

  String get profileQuranPreferencesRow => _t('profileQuranPreferencesRow');
  String get profileQuranPreferencesSubtitle =>
      _t('profileQuranPreferencesSubtitle');
  String get profileQuranSavedRow => _t('profileQuranSavedRow');
  String get profileQuranSavedSubtitle => _t('profileQuranSavedSubtitle');

  String get profileLearnSavedRow => _t('profileLearnSavedRow');
  String get profileLearnCompletedRow => _t('profileLearnCompletedRow');
  String get profileLearnLastReadRow => _t('profileLearnLastReadRow');
  String get profileLearnLastReadEmpty => _t('profileLearnLastReadEmpty');
  String get profileLearnSourcesRow => _t('profileLearnSourcesRow');
  String get profileLearnSourcesSubtitle => _t('profileLearnSourcesSubtitle');

  String get profileAboutRow => _t('profileAboutRow');
  String get profilePrivacyApproachRow => _t('profilePrivacyApproachRow');
  String get profileLicensesRow => _t('profileLicensesRow');

  String get commonCancel => _t('commonCancel');

  // İçerik kaynakları ekranı (TASK 058 §5)
  String get sourcesTitle => _t('sourcesTitle');
  String get sourcesIntro => _t('sourcesIntro');
  String get sourcesOriginalLanguageLabel => _t('sourcesOriginalLanguageLabel');
  String get sourcesOpenFailed => _t('sourcesOpenFailed');
  String get sourcesCopied => _t('sourcesCopied');
  String get sourcesLangArabic => _t('sourcesLangArabic');
  String get sourcesLangTurkish => _t('sourcesLangTurkish');
  String get sourcePurposeTanzil => _t('sourcePurposeTanzil');
  String get sourcePurposeQuranenc => _t('sourcePurposeQuranenc');
  String get sourcePurposeMp3quran => _t('sourcePurposeMp3quran');
  String get sourcePurposeIlmihal => _t('sourcePurposeIlmihal');
  String get sourcePurposePortal => _t('sourcePurposePortal');
  String get sourcePurposeHadis => _t('sourcePurposeHadis');
  String get sourcePurposeKurul => _t('sourcePurposeKurul');
  String get sourcesPolicyTitle => _t('sourcesPolicyTitle');
  String get sourcesPolicyLocator => _t('sourcesPolicyLocator');
  String get sourcesPolicyTurkishSummary => _t('sourcesPolicyTurkishSummary');
  String get sourcesPolicyTranslation => _t('sourcesPolicyTranslation');
  String get sourcesPolicyNoEndorsement => _t('sourcesPolicyNoEndorsement');
  String get sourcesPolicyPending => _t('sourcesPolicyPending');
  String get sourcesPolicyFatwa => _t('sourcesPolicyFatwa');

  // Gizlilik ve veriler ekranı (TASK 058 §6)
  String get privacyTitle => _t('privacyTitle');
  String get privacyIntro => _t('privacyIntro');
  String get privacyLocalTitle => _t('privacyLocalTitle');
  String get privacyLocalOnboarding => _t('privacyLocalOnboarding');
  String get privacyLocalPrayerHistory => _t('privacyLocalPrayerHistory');
  String get privacyLocalQuran => _t('privacyLocalQuran');
  String get privacyLocalQuranPrefs => _t('privacyLocalQuranPrefs');
  String get privacyLocalLearn => _t('privacyLocalLearn');
  String get privacyLocalAppPrefs => _t('privacyLocalAppPrefs');
  String get privacyComputedTitle => _t('privacyComputedTitle');
  String get privacyComputedPrayerTimes => _t('privacyComputedPrayerTimes');
  String get privacyComputedProgress => _t('privacyComputedProgress');
  String get privacyNetworkTitle => _t('privacyNetworkTitle');
  String get privacyNetworkAudio => _t('privacyNetworkAudio');
  String get privacyNetworkLinks => _t('privacyNetworkLinks');
  String get privacyNote => _t('privacyNote');

  // Veri sıfırlama (TASK 058 §7)
  String get resetSectionTitle => _t('resetSectionTitle');
  String get resetLearningTitle => _t('resetLearningTitle');
  String get resetLearningSubtitle => _t('resetLearningSubtitle');
  String get resetLearningConfirmTitle => _t('resetLearningConfirmTitle');
  String get resetLearningConfirmBody => _t('resetLearningConfirmBody');
  String get resetLearningDone => _t('resetLearningDone');
  String get resetAllTitle => _t('resetAllTitle');
  String get resetAllSubtitle => _t('resetAllSubtitle');
  String get resetAllStep1Title => _t('resetAllStep1Title');
  String get resetAllStep1Body => _t('resetAllStep1Body');
  String get resetAllStep1Continue => _t('resetAllStep1Continue');
  String get resetAllStep2Title => _t('resetAllStep2Title');
  String get resetAllStep2Body => _t('resetAllStep2Body');
  String get resetAllConfirm => _t('resetAllConfirm');
  String get resetAllDone => _t('resetAllDone');
  String get resetKeepsLanguage => _t('resetKeepsLanguage');

  // Hakkında ekranı (TASK 058 §8)
  String get aboutTitle => _t('aboutTitle');
  String get aboutTagline => _t('aboutTagline');
  String get aboutVersionLabel => _t('aboutVersionLabel');
  String get aboutBuildLabel => _t('aboutBuildLabel');
  String get aboutStageAlpha => _t('aboutStageAlpha');
  String get aboutBuiltWithFlutter => _t('aboutBuiltWithFlutter');
  String get aboutLicensesButton => _t('aboutLicensesButton');
  String get aboutVersionUnavailable => _t('aboutVersionUnavailable');

  // Bismillah Asistanı (TASK 059)
  String get assistantIntroBody => _t('assistantIntroBody');
  String get assistantNotMuftiNotice => _t('assistantNotMuftiNotice');
  String get assistantSuggestedTitle => _t('assistantSuggestedTitle');
  String get assistantSuggested1 => _t('assistantSuggested1');
  String get assistantSuggested2 => _t('assistantSuggested2');
  String get assistantSuggested3 => _t('assistantSuggested3');
  String get assistantSuggested4 => _t('assistantSuggested4');
  String get assistantSuggested5 => _t('assistantSuggested5');
  String get assistantInputHint => _t('assistantInputHint');
  String get assistantSendLabel => _t('assistantSendLabel');
  String get assistantThinking => _t('assistantThinking');
  String get assistantClearTitle => _t('assistantClearTitle');
  String get assistantClearConfirmTitle => _t('assistantClearConfirmTitle');
  String get assistantClearConfirmBody => _t('assistantClearConfirmBody');
  String get assistantClearConfirm => _t('assistantClearConfirm');
  String get assistantCleared => _t('assistantCleared');
  String get assistantYouLabel => _t('assistantYouLabel');
  String get assistantSummaryTitle => _t('assistantSummaryTitle');
  String get assistantStepsTitle => _t('assistantStepsTitle');
  String get assistantKeyPointsTitle => _t('assistantKeyPointsTitle');
  String get assistantPracticalTitle => _t('assistantPracticalTitle');
  String get assistantSourcesTitle => _t('assistantSourcesTitle');
  String get assistantOfficialSourceTag => _t('assistantOfficialSourceTag');
  String get assistantRelatedTitle => _t('assistantRelatedTitle');
  String get assistantReadInLearn => _t('assistantReadInLearn');
  String get assistantOfficialGuidanceCta => _t('assistantOfficialGuidanceCta');
  String get assistantOpenAssistant => _t('assistantOpenAssistant');
  String get assistantBadgeVerified => _t('assistantBadgeVerified');
  String get assistantBadgeGeneral => _t('assistantBadgeGeneral');
  String get assistantBadgeNoSource => _t('assistantBadgeNoSource');
  String get assistantBadgeGuidance => _t('assistantBadgeGuidance');
  // Composer sabit metinleri
  String get assistantNoVerifiedSource => _t('assistantNoVerifiedSource');
  String get assistantOfficialFatwaRequired =>
      _t('assistantOfficialFatwaRequired');
  String get assistantQualifiedGuidance => _t('assistantQualifiedGuidance');
  String get assistantGeneralInfoNotRuling =>
      _t('assistantGeneralInfoNotRuling');
  String get assistantPersonalCaseGeneralInfo =>
      _t('assistantPersonalCaseGeneralInfo');
  String get assistantSourceNotDirectlyAddressing =>
      _t('assistantSourceNotDirectlyAddressing');

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
      'learnHeroTitle': 'Bilgini sakince derinleştir',
      'learnHeroBody': 'Bugün küçük bir konuyla başlayabilirsin',
      'learnExploreSection': 'Keşfetmeye devam et',
      'learnSearchHint': 'Konu ara (abdest, namaz, oruç…)',
      'learnSearchEmpty': 'Aramanla eşleşen bir konu bulunamadı.',
      'learnContinueSection': 'Kaldığın yerden devam',
      'learnBeginnerPathSection': 'Yeni başlayanlar yolu',
      'learnFeaturedSection': 'Öne çıkan konular',
      'learnSavedSection': 'Kaydettiklerin',
      'learnCompletedSection': 'Tamamladıkların',
      'learnAllCategoriesSection': 'Tüm başlıklar',
      'learnCategoryPreparing': 'Hazırlanıyor',
      'learnVerifyingTitle': 'Doğrulama sürüyor',
      'learnVerifyingMessage':
          'Bu içerikler resmî kaynaklarla doğrulanıyor. Yalnız kaynağı '
          'doğrulanmış konular burada gösterilir.',
      'learnCategoryEmptyTitle': 'Bu bölüm hazırlanıyor',
      'learnLoadIssue': 'Öğrenme içerikleri şu anda açılamadı.',
      'learnSave': 'Kaydet',
      'learnSaved': 'Kaydedildi',
      'learnMarkCompleted': 'Tamamlandı olarak işaretle',
      'learnCompleted': 'Tamamlandı',
      'learnRelatedSection': 'İlgili konular',
      'learnSourcesSection': 'Kaynaklar',
      'learnOpenOfficialPage': 'Resmî sayfayı aç',
      'learnLinkUnavailable': 'Bağlantı şu anda açılamadı.',
      'learnLastVerified': 'Son kaynak kontrolü',
      'learnOriginalLanguageTr': 'Kaynağın özgün dili: Türkçe',
      'learnTranslationDisclaimer':
          'Bu metin, Türkçe resmî kaynağa dayanan resmî olmayan açıklayıcı '
          'bir çeviridir.',
      'learnGuidanceTitle': 'Kişisel durumun için danış',
      'learnAskAssistantSoon': 'Asistana sor — yakında',
      'learnDifferenceNoteTitle': 'Görüş farkı',
      'learnTypeGeneralTeaching': 'Genel öğretici özet',
      'learnTypeQuranExplanation': 'Kur\'an açıklaması',
      'learnTypeHadithBased': 'Hadis temelli açıklama',
      'learnTypeIlmihalKnowledge': 'İlmihal bilgisi',
      'learnTypeOfficialFatwa': 'Din İşleri Yüksek Kurulu cevabı',
      'learnDifficultyBeginner': 'Başlangıç',
      'learnDifficultyBasic': 'Temel',
      'learnDifficultyDeep': 'Derinleşme',
      'learnReadingMinutes': '{minutes} dk okuma',
      'learnTopicCount': '{count} konu',
      'profileSettingsSection': 'Ayarlar',
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
      'prayerNameFajr': 'İmsak',
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
      'settingsLanguageTitle': 'Uygulama dili',
      'settingsLanguageSubtitle': 'Arayüzün görüneceği dili seç.',
      'settingsLanguageSelected': 'Seçili',
      'settingsLanguageChanged': 'Uygulama dili güncellendi.',
      'settingsLanguageTranslationNote':
          'Kur\'an meali kendi dil tercihini korur; okuyucu ayarlarından '
          'ayrıca değiştirebilirsin.',
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
      'quranHomeHeroTitle': 'Kur\'an ile yeniden buluş',
      'quranHomeHeroBody': 'Kaldığın yerden sakince devam et.',
      'quranHomeContinueCta': 'Okumaya devam et',
      'todayJourneyTitle': 'Bugünkü yolculuğun',
      'todayKeepGoingHint': 'Küçük bir adımla devam et',
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
      'todayHeroTitle': 'Bugün yeniden başlayabilirsin',
      'todayHeroBody':
          'Her küçük adım, kalbini ibadete biraz daha yaklaştırır.',
      'todayHeroCta': 'Bugünün planını gör',
      'todayVerseSectionTitle': 'Bugünün Ayeti',
      'todayVerseUnavailable': 'Bugünün ayeti şu anda yüklenemedi.',
      'todayVerseOpenReader': 'Ayeti okuyucuda aç',
      'todayQuranSectionTitle': "Bugünkü Kur'an",
      'todayQuranStartBody':
          'Çevrimdışı Arapça metin ve Türkçe meal ile okumaya başlayabilirsiniz.',
      'todayQuranOpenCta': "Kur'an'ı aç",
      'todayQuranResumeCta': 'Okumaya devam et',
      'todayQuranProgressUnavailable': "Kur'an ilerlemesi şu anda yüklenemedi.",
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'Yolculuğunu derinleştirmek istersen…',
      // Profile ayar/veri merkezi (TASK 058)
      'profileJourneySection': 'Kişisel yolculuk',
      'profileLocalUsageTitle': 'Yerel kullanım',
      'profileLocalUsageBody':
          'Uygulamayı hesap oluşturmadan kullanıyorsun. Kayıtların bu '
          'cihazda tutulur.',
      'profileAppSection': 'Uygulama',
      'profilePrayerSection': 'Namaz',
      'profileQuranSection': "Kur'an",
      'profileLearnSection': 'Öğren',
      'profileSupportSection': 'Destek ve uygulama',
      'settingsNotificationsTitle': 'Bildirimler',
      'settingsNotificationsSubtitle': 'Namaz hatırlatmaları',
      'settingsPrivacyDataTitle': 'Gizlilik ve veriler',
      'profilePrayerTimesRow': 'Namaz vakitleri ve konum',
      'profilePrayerTimesSubtitle': 'Konum ve hesaplama yöntemi',
      'profilePrayerTrackingRow': 'Namaz takibi',
      'profilePrayerTrackingSubtitle': 'Son 7 gün',
      'profileQuranPreferencesRow': "Kur'an tercihleri ve ilerleme",
      'profileQuranPreferencesSubtitle':
          'Okuyucu, meal, kâri, günlük hedef ve ilerlemen',
      'profileQuranSavedRow': 'Kaydedilen ayetler',
      'profileQuranSavedSubtitle': 'İşaretlediğin ayetler',
      'profileLearnSavedRow': 'Kaydedilen makaleler',
      'profileLearnCompletedRow': 'Tamamlanan makaleler',
      'profileLearnLastReadRow': 'Son okunan',
      'profileLearnLastReadEmpty': 'Henüz yok',
      'profileLearnSourcesRow': 'İçerik kaynakları ve doğrulama',
      'profileLearnSourcesSubtitle': 'Kaynaklar ve içerik politikası',
      'profileAboutRow': 'Hakkında',
      'profilePrivacyApproachRow': 'Gizlilik yaklaşımı',
      'profileLicensesRow': 'Açık kaynak lisansları',
      'commonCancel': 'İptal',
      // İçerik kaynakları (TASK 058 §5)
      'sourcesTitle': 'İçerik kaynakları',
      'sourcesIntro':
          'Bismillah, içeriğini aşağıdaki resmî ve köklü kaynaklara '
          'dayandırır. Bağlantılar sistem tarayıcısında açılır.',
      'sourcesOriginalLanguageLabel': 'Özgün dil',
      'sourcesOpenFailed': 'Bağlantı açılamadı; adres panoya kopyalandı.',
      'sourcesCopied': 'Adres panoya kopyalandı.',
      'sourcesLangArabic': 'Arapça',
      'sourcesLangTurkish': 'Türkçe',
      'sourcePurposeTanzil': "Arapça Kur'an metni (Uthmani hat).",
      'sourcePurposeQuranenc': 'Türkçe meal (Rowad Tercüme Merkezi).',
      'sourcePurposeMp3quran': 'Kâri ses kayıtları ve listesi.',
      'sourcePurposeIlmihal':
          'Öğren bölümündeki Türkçe içeriklerin dayandığı temel eser.',
      'sourcePurposePortal': "Kur'an metni ve meal referansı.",
      'sourcePurposeHadis': 'Hadis metinleri referansı.',
      'sourcePurposeKurul': 'Resmî dinî görüş ve fetva kaynağı.',
      'sourcesPolicyTitle': 'İçerik politikası',
      'sourcesPolicyLocator':
          'Yayınlanan her içerik, dayandığı kaynağın tam konumunu taşır.',
      'sourcesPolicyTurkishSummary':
          'Türkçe içerikler Diyanet kaynaklarına dayalı özgün özetlerdir.',
      'sourcesPolicyTranslation':
          'İngilizce ve Arapça içerikler açıklayıcı çeviridir.',
      'sourcesPolicyNoEndorsement':
          "Diyanet'in Bismillah'a özel bir onayı olduğu ileri sürülmez.",
      'sourcesPolicyPending':
          'Doğrulaması tamamlanmayan içerikler kullanıcıya gösterilmez.',
      'sourcesPolicyFatwa': 'Kişisel fetva için yetkili bir kuruma başvurun.',
      // Gizlilik ve veriler (TASK 058 §6)
      'privacyTitle': 'Gizlilik ve veriler',
      'privacyIntro': 'Verilerinin nerede tutulduğunu açıkça görebilirsin.',
      'privacyLocalTitle': 'Cihazında saklananlar',
      'privacyLocalOnboarding': 'Onboarding tercihleri',
      'privacyLocalPrayerHistory': 'Namaz takip geçmişi',
      'privacyLocalQuran': "Kur'an bookmark ve ilerlemesi",
      'privacyLocalQuranPrefs': "Kur'an tercihleri",
      'privacyLocalLearn':
          'Öğrenme kayıtları (kaydedilen, tamamlanan, son okunan)',
      'privacyLocalAppPrefs': 'Dil ve uygulama tercihleri',
      'privacyComputedTitle': 'Cihazında hesaplananlar',
      'privacyComputedPrayerTimes': 'Namaz vakitleri',
      'privacyComputedProgress': 'Günlük ilerleme özetleri',
      'privacyNetworkTitle': 'Ağ kullanılan alanlar',
      'privacyNetworkAudio': "Kur'an ses dosyaları",
      'privacyNetworkLinks': 'Açtığında resmî kaynak bağlantıları',
      'privacyNote':
          'Bu kayıtlar cihazında tutulur; yukarıda belirtilen ağ alanları '
          'dışında bir sunucuya gönderilmez.',
      // Veri sıfırlama (TASK 058 §7)
      'resetSectionTitle': 'Verileri sıfırla',
      'resetLearningTitle': 'Öğrenme verilerini sıfırla',
      'resetLearningSubtitle': 'Kaydedilen, tamamlanan ve son okunan',
      'resetLearningConfirmTitle': 'Öğrenme verilerini sıfırla?',
      'resetLearningConfirmBody':
          'Yalnız öğrenme kayıtların (kaydedilen, tamamlanan ve son okunan '
          'makaleler) silinir. Diğer verilerine dokunulmaz.',
      'resetLearningDone': 'Öğrenme verilerin sıfırlandı.',
      'resetAllTitle': 'Tüm yerel verileri sıfırla',
      'resetAllSubtitle': "Uygulamayı onboarding'e döndürür",
      'resetAllStep1Title': 'Tüm yerel veriler silinsin mi?',
      'resetAllStep1Body':
          'Silinecekler: onboarding tercihleri, namaz takip geçmişi, '
          "Kur'an bookmark ve ilerlemesi, Kur'an tercihleri ve öğrenme "
          'kayıtların.',
      'resetAllStep1Continue': 'Devam et',
      'resetAllStep2Title': 'Emin misin?',
      'resetAllStep2Body':
          'Bu işlem geri alınamaz. Uygulama yeniden onboarding ile açılır.',
      'resetAllConfirm': 'Kalıcı olarak sil',
      'resetAllDone': 'Tüm yerel verilerin sıfırlandı.',
      'resetKeepsLanguage': 'Dil tercihin korunur.',
      // Hakkında (TASK 058 §8)
      'aboutTitle': 'Hakkında',
      'aboutTagline': 'Premium İslami yaşam arkadaşı',
      'aboutVersionLabel': 'Sürüm',
      'aboutBuildLabel': 'Yapı',
      'aboutStageAlpha': 'Alpha — aktif geliştirme',
      'aboutBuiltWithFlutter': 'Flutter ile geliştirildi',
      'aboutLicensesButton': 'Açık kaynak lisansları',
      'aboutVersionUnavailable': 'Sürüm bilgisi alınamadı.',
      // Bismillah Asistanı (TASK 059)
      'assistantIntroBody': 'Doğrulanmış kaynaklı açıklamalarla yardımcı olur.',
      'assistantNotMuftiNotice':
          'Bismillah Asistanı bir fetva makamı değildir.',
      'assistantSuggestedTitle': 'Örnek sorular',
      'assistantSuggested1': 'Abdest nasıl alınır?',
      'assistantSuggested2': 'İmanın şartları nelerdir?',
      'assistantSuggested3': 'Teyemmüm nedir?',
      'assistantSuggested4': 'Namaza nasıl hazırlanırım?',
      'assistantSuggested5': "Kur'an nedir?",
      'assistantInputHint': 'Bir soru yaz…',
      'assistantSendLabel': 'Gönder',
      'assistantThinking': 'Doğrulanmış kaynaklarda aranıyor…',
      'assistantClearTitle': 'Konuşmayı temizle',
      'assistantClearConfirmTitle': 'Konuşma temizlensin mi?',
      'assistantClearConfirmBody':
          'Bu cihazdaki sohbet geçmişi silinir. Bu işlem geri alınamaz.',
      'assistantClearConfirm': 'Temizle',
      'assistantCleared': 'Konuşma temizlendi.',
      'assistantYouLabel': 'Sen',
      'assistantSummaryTitle': 'Kaynaklı açıklama',
      'assistantStepsTitle': 'Adımlar',
      'assistantKeyPointsTitle': 'Önemli noktalar',
      'assistantPracticalTitle': 'Uygulama',
      'assistantSourcesTitle': 'Resmî kaynaklar',
      'assistantOfficialSourceTag': 'Resmî kaynak',
      'assistantRelatedTitle': 'İlgili Learn içeriği',
      'assistantReadInLearn': "Learn'de oku",
      'assistantOfficialGuidanceCta': 'Resmî soru sayfasını aç',
      'assistantOpenAssistant': "Bismillah'a Sor",
      'assistantBadgeVerified': 'Doğrulanmış kaynak',
      'assistantBadgeGeneral': 'Genel kaynaklı bilgi',
      'assistantBadgeNoSource': 'Doğrulanmış kaynak yok',
      'assistantBadgeGuidance': 'Yetkiliye danışın',
      'assistantNoVerifiedSource':
          'Bu konuda doğrulanmış bir kaynak bulamadım; bu yüzden kesin bir '
          'cevap vermem doğru olmaz. İlgili öğrenme başlıklarına '
          'bakabilirsin.',
      'assistantOfficialFatwaRequired':
          'Bu soru için doğrulanmış doğrudan bir Din İşleri Yüksek Kurulu '
          'cevabı bilgi tabanımızda bulunmuyor. Kesin hüküm vermem doğru '
          'olmaz.',
      'assistantQualifiedGuidance':
          'Bu konu kişisel duruma özel değerlendirme gerektiriyor. Kesin bir '
          'hüküm için yetkili bir mercie danışman en doğrusudur.',
      'assistantGeneralInfoNotRuling':
          'Bu genel bir bilgidir; özel durumuna kesin bir hüküm uygulamaz.',
      'assistantPersonalCaseGeneralInfo':
          'Aşağıdaki genel bilgi konuya ışık tutar; ancak senin özel durumun '
          'için hüküm içermez.',
      'assistantSourceNotDirectlyAddressing':
          'Bu kaynak özel durumunuzu doğrudan ele almıyor.',
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
      'learnHeroTitle': 'Deepen your knowledge gently',
      'learnHeroBody': 'You can begin with one small topic today',
      'learnExploreSection': 'Continue exploring',
      'learnSearchHint': 'Search topics (wudu, prayer, fasting…)',
      'learnSearchEmpty': 'No topic matched your search.',
      'learnContinueSection': 'Continue where you left off',
      'learnBeginnerPathSection': 'Path for beginners',
      'learnFeaturedSection': 'Featured topics',
      'learnSavedSection': 'Your saved topics',
      'learnCompletedSection': 'Topics you completed',
      'learnAllCategoriesSection': 'All topics',
      'learnCategoryPreparing': 'In preparation',
      'learnVerifyingTitle': 'Verification in progress',
      'learnVerifyingMessage':
          'These topics are being verified against official sources. Only '
          'source-verified topics are shown here.',
      'learnCategoryEmptyTitle': 'This section is in preparation',
      'learnLoadIssue': 'Learning content could not be opened right now.',
      'learnSave': 'Save',
      'learnSaved': 'Saved',
      'learnMarkCompleted': 'Mark as completed',
      'learnCompleted': 'Completed',
      'learnRelatedSection': 'Related topics',
      'learnSourcesSection': 'Sources',
      'learnOpenOfficialPage': 'Open the official page',
      'learnLinkUnavailable': 'The link could not be opened right now.',
      'learnLastVerified': 'Source last checked',
      'learnOriginalLanguageTr': 'Original source language: Turkish',
      'learnTranslationDisclaimer':
          'This text is an unofficial explanatory translation based on the '
          'Turkish official source.',
      'learnGuidanceTitle': 'Seek guidance for your own situation',
      'learnAskAssistantSoon': 'Ask the assistant — coming soon',
      'learnDifferenceNoteTitle': 'Difference of opinion',
      'learnTypeGeneralTeaching': 'General teaching summary',
      'learnTypeQuranExplanation': 'Quran explanation',
      'learnTypeHadithBased': 'Hadith-based explanation',
      'learnTypeIlmihalKnowledge': 'Handbook knowledge',
      'learnTypeOfficialFatwa': 'High Board of Religious Affairs answer',
      'learnDifficultyBeginner': 'Beginner',
      'learnDifficultyBasic': 'Basic',
      'learnDifficultyDeep': 'In depth',
      'learnReadingMinutes': '{minutes} min read',
      'learnTopicCount': '{count} topics',
      'profileSettingsSection': 'Settings',
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
      'settingsLanguageTitle': 'App language',
      'settingsLanguageSubtitle': 'Choose the language for the interface.',
      'settingsLanguageSelected': 'Selected',
      'settingsLanguageChanged': 'App language updated.',
      'settingsLanguageTranslationNote':
          'Your Quran translation keeps its own language; you can change it '
          'separately in the reader settings.',
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
      'quranHomeHeroTitle': 'Return to the Quran',
      'quranHomeHeroBody': 'Continue gently from where you left off.',
      'quranHomeContinueCta': 'Continue reading',
      'todayJourneyTitle': 'Today’s journey',
      'todayKeepGoingHint': 'Keep going with one small step',
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
      'todayHeroTitle': 'You can begin again today',
      'todayHeroBody':
          'Every small step can bring your heart closer to worship.',
      'todayHeroCta': "View today's plan",
      'todayVerseSectionTitle': 'Verse of the Day',
      'todayVerseUnavailable': "Today's verse could not be loaded right now.",
      'todayVerseOpenReader': 'Open the verse in the reader',
      'todayQuranSectionTitle': "Today's Quran",
      'todayQuranStartBody':
          'Start reading with offline Arabic text and Turkish translation.',
      'todayQuranOpenCta': 'Open the Quran',
      'todayQuranResumeCta': 'Continue reading',
      'todayQuranProgressUnavailable':
          'Quran progress could not be loaded right now.',
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'If you would like to go deeper…',
      // Profile settings/data hub (TASK 058)
      'profileJourneySection': 'Your journey',
      'profileLocalUsageTitle': 'Local use',
      'profileLocalUsageBody':
          'You are using the app without an account. Your records are kept '
          'on this device.',
      'profileAppSection': 'App',
      'profilePrayerSection': 'Prayer',
      'profileQuranSection': 'Quran',
      'profileLearnSection': 'Learn',
      'profileSupportSection': 'Support & app',
      'settingsNotificationsTitle': 'Notifications',
      'settingsNotificationsSubtitle': 'Prayer reminders',
      'settingsPrivacyDataTitle': 'Privacy & data',
      'profilePrayerTimesRow': 'Prayer times & location',
      'profilePrayerTimesSubtitle': 'Location and calculation method',
      'profilePrayerTrackingRow': 'Prayer tracking',
      'profilePrayerTrackingSubtitle': 'Last 7 days',
      'profileQuranPreferencesRow': 'Quran preferences & progress',
      'profileQuranPreferencesSubtitle':
          'Reader, translation, reciter, daily goal and your progress',
      'profileQuranSavedRow': 'Saved verses',
      'profileQuranSavedSubtitle': 'Verses you bookmarked',
      'profileLearnSavedRow': 'Saved articles',
      'profileLearnCompletedRow': 'Completed articles',
      'profileLearnLastReadRow': 'Last read',
      'profileLearnLastReadEmpty': 'None yet',
      'profileLearnSourcesRow': 'Content sources & verification',
      'profileLearnSourcesSubtitle': 'Sources and content policy',
      'profileAboutRow': 'About',
      'profilePrivacyApproachRow': 'Privacy approach',
      'profileLicensesRow': 'Open source licenses',
      'commonCancel': 'Cancel',
      // Content sources (TASK 058 §5)
      'sourcesTitle': 'Content sources',
      'sourcesIntro':
          'Bismillah bases its content on the official and established '
          'sources below. Links open in your system browser.',
      'sourcesOriginalLanguageLabel': 'Original language',
      'sourcesOpenFailed': 'Could not open the link; address copied.',
      'sourcesCopied': 'Address copied to clipboard.',
      'sourcesLangArabic': 'Arabic',
      'sourcesLangTurkish': 'Turkish',
      'sourcePurposeTanzil': 'Arabic Quran text (Uthmani script).',
      'sourcePurposeQuranenc':
          'Turkish translation (Rowad Translation Center).',
      'sourcePurposeMp3quran': 'Reciter audio recordings and catalog.',
      'sourcePurposeIlmihal':
          'The core work the Turkish Learn content is based on.',
      'sourcePurposePortal': 'Quran text and translation reference.',
      'sourcePurposeHadis': 'Hadith text reference.',
      'sourcePurposeKurul': 'Official religious opinion and fatwa source.',
      'sourcesPolicyTitle': 'Content policy',
      'sourcesPolicyLocator':
          'Every published item carries the exact locator of its source.',
      'sourcesPolicyTurkishSummary':
          'Turkish content consists of original summaries based on Diyanet '
          'sources.',
      'sourcesPolicyTranslation':
          'English and Arabic content is explanatory translation.',
      'sourcesPolicyNoEndorsement':
          'No special endorsement of Bismillah by Diyanet is claimed.',
      'sourcesPolicyPending':
          'Content that is not fully verified is not shown to users.',
      'sourcesPolicyFatwa':
          'For a personal ruling, consult a qualified institution.',
      // Privacy & data (TASK 058 §6)
      'privacyTitle': 'Privacy & data',
      'privacyIntro': 'You can clearly see where your data is kept.',
      'privacyLocalTitle': 'Stored on your device',
      'privacyLocalOnboarding': 'Onboarding preferences',
      'privacyLocalPrayerHistory': 'Prayer tracking history',
      'privacyLocalQuran': 'Quran bookmarks and progress',
      'privacyLocalQuranPrefs': 'Quran preferences',
      'privacyLocalLearn': 'Learning records (saved, completed, last read)',
      'privacyLocalAppPrefs': 'Language and app preferences',
      'privacyComputedTitle': 'Computed on your device',
      'privacyComputedPrayerTimes': 'Prayer times',
      'privacyComputedProgress': 'Daily progress summaries',
      'privacyNetworkTitle': 'Where the network is used',
      'privacyNetworkAudio': 'Quran audio files',
      'privacyNetworkLinks': 'Official source links when you open them',
      'privacyNote':
          'These records are kept on your device and are not sent to a '
          'server beyond the network areas listed above.',
      // Data reset (TASK 058 §7)
      'resetSectionTitle': 'Reset data',
      'resetLearningTitle': 'Reset learning data',
      'resetLearningSubtitle': 'Saved, completed and last read',
      'resetLearningConfirmTitle': 'Reset learning data?',
      'resetLearningConfirmBody':
          'Only your learning records (saved, completed and last read '
          'articles) are deleted. Your other data is untouched.',
      'resetLearningDone': 'Your learning data has been reset.',
      'resetAllTitle': 'Reset all local data',
      'resetAllSubtitle': 'Returns the app to onboarding',
      'resetAllStep1Title': 'Delete all local data?',
      'resetAllStep1Body':
          'Will be deleted: onboarding preferences, prayer tracking history, '
          'Quran bookmarks and progress, Quran preferences and your learning '
          'records.',
      'resetAllStep1Continue': 'Continue',
      'resetAllStep2Title': 'Are you sure?',
      'resetAllStep2Body':
          'This cannot be undone. The app reopens with onboarding.',
      'resetAllConfirm': 'Delete permanently',
      'resetAllDone': 'All your local data has been reset.',
      'resetKeepsLanguage': 'Your language preference is kept.',
      // About (TASK 058 §8)
      'aboutTitle': 'About',
      'aboutTagline': 'Premium Islamic lifestyle companion',
      'aboutVersionLabel': 'Version',
      'aboutBuildLabel': 'Build',
      'aboutStageAlpha': 'Alpha — active development',
      'aboutBuiltWithFlutter': 'Built with Flutter',
      'aboutLicensesButton': 'Open source licenses',
      'aboutVersionUnavailable': 'Version information unavailable.',
      // Bismillah Assistant (TASK 059)
      'assistantIntroBody':
          'Helps with explanations grounded in verified sources.',
      'assistantNotMuftiNotice':
          'The Bismillah Assistant is not a source of fatwa.',
      'assistantSuggestedTitle': 'Example questions',
      'assistantSuggested1': 'How is wudu performed?',
      'assistantSuggested2': 'What are the pillars of faith?',
      'assistantSuggested3': 'What is tayammum?',
      'assistantSuggested4': 'How do I prepare for prayer?',
      'assistantSuggested5': 'What is the Quran?',
      'assistantInputHint': 'Type a question…',
      'assistantSendLabel': 'Send',
      'assistantThinking': 'Searching verified sources…',
      'assistantClearTitle': 'Clear conversation',
      'assistantClearConfirmTitle': 'Clear the conversation?',
      'assistantClearConfirmBody':
          'The chat history on this device will be deleted. This cannot be '
          'undone.',
      'assistantClearConfirm': 'Clear',
      'assistantCleared': 'Conversation cleared.',
      'assistantYouLabel': 'You',
      'assistantSummaryTitle': 'Sourced explanation',
      'assistantStepsTitle': 'Steps',
      'assistantKeyPointsTitle': 'Key points',
      'assistantPracticalTitle': 'In practice',
      'assistantSourcesTitle': 'Official sources',
      'assistantOfficialSourceTag': 'Official source',
      'assistantRelatedTitle': 'Related Learn content',
      'assistantReadInLearn': 'Read in Learn',
      'assistantOfficialGuidanceCta': 'Open the official question page',
      'assistantOpenAssistant': 'Ask Bismillah',
      'assistantBadgeVerified': 'Verified source',
      'assistantBadgeGeneral': 'General sourced info',
      'assistantBadgeNoSource': 'No verified source',
      'assistantBadgeGuidance': 'Consult an authority',
      'assistantNoVerifiedSource':
          'I could not find a verified source on this, so it would not be '
          'right for me to give a definite answer. You can look at the '
          'related learning topics.',
      'assistantOfficialFatwaRequired':
          'Our knowledge base does not have a verified direct answer from the '
          'High Board of Religious Affairs for this question. It would not be '
          'right for me to issue a definite ruling.',
      'assistantQualifiedGuidance':
          'This depends on your personal circumstances. For a definite '
          'ruling it is best to consult a qualified authority.',
      'assistantGeneralInfoNotRuling':
          'This is general information; it does not apply a definite ruling '
          'to your specific case.',
      'assistantPersonalCaseGeneralInfo':
          'The general information below sheds light on the topic, but does '
          'not contain a ruling for your specific situation.',
      'assistantSourceNotDirectlyAddressing':
          'This source does not directly address your specific situation.',
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
      'learnHeroTitle': 'عمّق معرفتك بهدوء',
      'learnHeroBody': 'يمكنك أن تبدأ اليوم بموضوع صغير',
      'learnExploreSection': 'واصل الاستكشاف',
      'learnSearchHint': 'ابحث عن موضوع (الوضوء، الصلاة، الصوم…)',
      'learnSearchEmpty': 'لم يُعثر على موضوع يطابق بحثك.',
      'learnContinueSection': 'تابع من حيث توقفت',
      'learnBeginnerPathSection': 'مسار المبتدئين',
      'learnFeaturedSection': 'موضوعات مختارة',
      'learnSavedSection': 'ما حفظته',
      'learnCompletedSection': 'ما أتممته',
      'learnAllCategoriesSection': 'جميع الأبواب',
      'learnCategoryPreparing': 'قيد التجهيز',
      'learnVerifyingTitle': 'التحقق جارٍ',
      'learnVerifyingMessage':
          'يجري التحقق من هذه الموضوعات بالرجوع إلى المصادر الرسمية. ولا '
          'تُعرض هنا إلا الموضوعات المتحقق من مصدرها.',
      'learnCategoryEmptyTitle': 'هذا القسم قيد التجهيز',
      'learnLoadIssue': 'تعذّر فتح محتوى التعلّم في الوقت الحالي.',
      'learnSave': 'حفظ',
      'learnSaved': 'محفوظ',
      'learnMarkCompleted': 'وضع علامة الإتمام',
      'learnCompleted': 'تم الإتمام',
      'learnRelatedSection': 'موضوعات ذات صلة',
      'learnSourcesSection': 'المصادر',
      'learnOpenOfficialPage': 'افتح الصفحة الرسمية',
      'learnLinkUnavailable': 'تعذّر فتح الرابط في الوقت الحالي.',
      'learnLastVerified': 'آخر تحقق من المصدر',
      'learnOriginalLanguageTr': 'لغة المصدر الأصلية: التركية',
      'learnTranslationDisclaimer':
          'هذا النص ترجمة تفسيرية غير رسمية مستندة إلى المصدر التركي الرسمي.',
      'learnGuidanceTitle': 'استشر بشأن حالتك الخاصة',
      'learnAskAssistantSoon': 'اسأل المساعد — قريبًا',
      'learnDifferenceNoteTitle': 'اختلاف في الرأي',
      'learnTypeGeneralTeaching': 'ملخص تعليمي عام',
      'learnTypeQuranExplanation': 'شرح قرآني',
      'learnTypeHadithBased': 'شرح مستند إلى الحديث',
      'learnTypeIlmihalKnowledge': 'معلومة فقهية تعليمية',
      'learnTypeOfficialFatwa': 'جواب المجلس الأعلى للشؤون الدينية',
      'learnDifficultyBeginner': 'مبتدئ',
      'learnDifficultyBasic': 'أساسي',
      'learnDifficultyDeep': 'تعمّق',
      'learnReadingMinutes': 'قراءة {minutes} د',
      'learnTopicCount': '{count} موضوعًا',
      'profileSettingsSection': 'الإعدادات',
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
      'settingsLanguageTitle': 'لغة التطبيق',
      'settingsLanguageSubtitle': 'اختر اللغة التي تظهر بها الواجهة.',
      'settingsLanguageSelected': 'محددة',
      'settingsLanguageChanged': 'تم تحديث لغة التطبيق.',
      'settingsLanguageTranslationNote':
          'تحتفظ ترجمة القرآن بلغتها الخاصة، ويمكنك تغييرها بشكل منفصل من '
          'إعدادات القارئ.',
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
      'quranHomeHeroTitle': 'عُد إلى القرآن',
      'quranHomeHeroBody': 'تابع بهدوء من حيث توقفت',
      'quranHomeContinueCta': 'متابعة القراءة',
      'todayJourneyTitle': 'رحلتك اليوم',
      'todayKeepGoingHint': 'واصل بخطوة صغيرة',
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
      'todayHeroTitle': 'يمكنك أن تبدأ من جديد اليوم',
      'todayHeroBody': 'كل خطوة صغيرة قد تقرّب قلبك أكثر من العبادة.',
      'todayHeroCta': 'عرض خطة اليوم',
      'todayVerseSectionTitle': 'آية اليوم',
      'todayVerseUnavailable': 'تعذّر تحميل آية اليوم الآن.',
      'todayVerseOpenReader': 'افتح الآية في القارئ',
      'todayQuranSectionTitle': 'قرآن اليوم',
      'todayQuranStartBody':
          'ابدأ القراءة مع النص العربي بلا اتصال والترجمة التركية.',
      'todayQuranOpenCta': 'افتح القرآن',
      'todayQuranResumeCta': 'تابع القراءة',
      'todayQuranProgressUnavailable': 'تعذّر تحميل تقدّم القرآن الآن.',
      'premiumBadgeLabel': 'Bismillah+',
      'premiumInviteLine': 'إن أحببت أن تتعمق في رحلتك…',
      // مركز الإعدادات والبيانات (TASK 058)
      'profileJourneySection': 'رحلتك الشخصية',
      'profileLocalUsageTitle': 'الاستخدام المحلي',
      'profileLocalUsageBody':
          'أنت تستخدم التطبيق دون حساب. تُحفظ سجلاتك على هذا الجهاز.',
      'profileAppSection': 'التطبيق',
      'profilePrayerSection': 'الصلاة',
      'profileQuranSection': 'القرآن',
      'profileLearnSection': 'التعلّم',
      'profileSupportSection': 'الدعم والتطبيق',
      'settingsNotificationsTitle': 'الإشعارات',
      'settingsNotificationsSubtitle': 'تذكيرات الصلاة',
      'settingsPrivacyDataTitle': 'الخصوصية والبيانات',
      'profilePrayerTimesRow': 'أوقات الصلاة والموقع',
      'profilePrayerTimesSubtitle': 'الموقع وطريقة الحساب',
      'profilePrayerTrackingRow': 'متابعة الصلاة',
      'profilePrayerTrackingSubtitle': 'آخر ٧ أيام',
      'profileQuranPreferencesRow': 'تفضيلات القرآن والتقدّم',
      'profileQuranPreferencesSubtitle':
          'القارئ، الترجمة، المقرئ، الهدف اليومي وتقدّمك',
      'profileQuranSavedRow': 'الآيات المحفوظة',
      'profileQuranSavedSubtitle': 'الآيات التي حفظتها',
      'profileLearnSavedRow': 'المقالات المحفوظة',
      'profileLearnCompletedRow': 'المقالات المكتملة',
      'profileLearnLastReadRow': 'آخر ما قرأت',
      'profileLearnLastReadEmpty': 'لا شيء بعد',
      'profileLearnSourcesRow': 'مصادر المحتوى والتحقّق',
      'profileLearnSourcesSubtitle': 'المصادر وسياسة المحتوى',
      'profileAboutRow': 'حول التطبيق',
      'profilePrivacyApproachRow': 'نهج الخصوصية',
      'profileLicensesRow': 'تراخيص المصدر المفتوح',
      'commonCancel': 'إلغاء',
      // مصادر المحتوى (TASK 058 §5)
      'sourcesTitle': 'مصادر المحتوى',
      'sourcesIntro':
          'يستند بِسم الله في محتواه إلى المصادر الرسمية والمعتمدة أدناه. '
          'تُفتح الروابط في متصفح النظام.',
      'sourcesOriginalLanguageLabel': 'اللغة الأصلية',
      'sourcesOpenFailed': 'تعذّر فتح الرابط؛ تم نسخ العنوان.',
      'sourcesCopied': 'تم نسخ العنوان إلى الحافظة.',
      'sourcesLangArabic': 'العربية',
      'sourcesLangTurkish': 'التركية',
      'sourcePurposeTanzil': 'نص القرآن العربي (الرسم العثماني).',
      'sourcePurposeQuranenc': 'الترجمة التركية (مركز رواد الترجمة).',
      'sourcePurposeMp3quran': 'تسجيلات القرّاء وقائمتها.',
      'sourcePurposeIlmihal':
          'العمل الأساسي الذي يستند إليه محتوى التعلّم التركي.',
      'sourcePurposePortal': 'مرجع نص القرآن والترجمة.',
      'sourcePurposeHadis': 'مرجع نصوص الحديث.',
      'sourcePurposeKurul': 'مصدر رسمي للرأي الديني والفتوى.',
      'sourcesPolicyTitle': 'سياسة المحتوى',
      'sourcesPolicyLocator': 'كل محتوى منشور يحمل الموضع الدقيق لمصدره.',
      'sourcesPolicyTurkishSummary':
          'المحتوى التركي عبارة عن ملخّصات أصلية تستند إلى مصادر ديانت.',
      'sourcesPolicyTranslation': 'المحتوى الإنجليزي والعربي ترجمة تفسيرية.',
      'sourcesPolicyNoEndorsement':
          'لا يُدّعى وجود اعتماد خاص من ديانت لتطبيق بِسم الله.',
      'sourcesPolicyPending':
          'المحتوى غير المُتحقَّق منه بالكامل لا يُعرض للمستخدم.',
      'sourcesPolicyFatwa': 'للفتوى الشخصية راجِع جهة مختصّة معتمدة.',
      // الخصوصية والبيانات (TASK 058 §6)
      'privacyTitle': 'الخصوصية والبيانات',
      'privacyIntro': 'يمكنك أن ترى بوضوح أين تُحفظ بياناتك.',
      'privacyLocalTitle': 'ما يُحفظ على جهازك',
      'privacyLocalOnboarding': 'تفضيلات التهيئة',
      'privacyLocalPrayerHistory': 'سجل متابعة الصلاة',
      'privacyLocalQuran': 'إشارات القرآن المرجعية والتقدّم',
      'privacyLocalQuranPrefs': 'تفضيلات القرآن',
      'privacyLocalLearn': 'سجلات التعلّم (المحفوظ، المكتمل، آخر ما قُرئ)',
      'privacyLocalAppPrefs': 'تفضيلات اللغة والتطبيق',
      'privacyComputedTitle': 'ما يُحسَب على جهازك',
      'privacyComputedPrayerTimes': 'أوقات الصلاة',
      'privacyComputedProgress': 'ملخّصات التقدّم اليومي',
      'privacyNetworkTitle': 'المواضع التي تُستخدم فيها الشبكة',
      'privacyNetworkAudio': 'ملفات صوت القرآن',
      'privacyNetworkLinks': 'روابط المصادر الرسمية عند فتحها',
      'privacyNote':
          'تُحفظ هذه السجلات على جهازك ولا تُرسل إلى خادم خارج المواضع '
          'الشبكية المذكورة أعلاه.',
      // إعادة تعيين البيانات (TASK 058 §7)
      'resetSectionTitle': 'إعادة تعيين البيانات',
      'resetLearningTitle': 'إعادة تعيين بيانات التعلّم',
      'resetLearningSubtitle': 'المحفوظ والمكتمل وآخر ما قُرئ',
      'resetLearningConfirmTitle': 'إعادة تعيين بيانات التعلّم؟',
      'resetLearningConfirmBody':
          'تُحذف سجلات التعلّم فقط (المقالات المحفوظة والمكتملة وآخر ما قُرئ). '
          'ولا تُمَسّ بياناتك الأخرى.',
      'resetLearningDone': 'تمت إعادة تعيين بيانات التعلّم.',
      'resetAllTitle': 'إعادة تعيين جميع البيانات المحلية',
      'resetAllSubtitle': 'يعيد التطبيق إلى التهيئة',
      'resetAllStep1Title': 'حذف جميع البيانات المحلية؟',
      'resetAllStep1Body':
          'سيُحذف: تفضيلات التهيئة، سجل متابعة الصلاة، إشارات القرآن المرجعية '
          'والتقدّم، تفضيلات القرآن، وسجلات التعلّم.',
      'resetAllStep1Continue': 'متابعة',
      'resetAllStep2Title': 'هل أنت متأكد؟',
      'resetAllStep2Body':
          'لا يمكن التراجع عن هذا الإجراء. يُعاد فتح التطبيق بالتهيئة.',
      'resetAllConfirm': 'حذف نهائي',
      'resetAllDone': 'تمت إعادة تعيين جميع بياناتك المحلية.',
      'resetKeepsLanguage': 'يُحتفَظ بتفضيل لغتك.',
      // حول التطبيق (TASK 058 §8)
      'aboutTitle': 'حول التطبيق',
      'aboutTagline': 'رفيق نمط الحياة الإسلامي المميّز',
      'aboutVersionLabel': 'الإصدار',
      'aboutBuildLabel': 'البناء',
      'aboutStageAlpha': 'ألفا — تطوير نشط',
      'aboutBuiltWithFlutter': 'بُني باستخدام Flutter',
      'aboutLicensesButton': 'تراخيص المصدر المفتوح',
      'aboutVersionUnavailable': 'معلومات الإصدار غير متوفّرة.',
      // مساعد بِسم الله (TASK 059)
      'assistantIntroBody': 'يساعد بشروحات مستندة إلى مصادر مُتحقَّق منها.',
      'assistantNotMuftiNotice': 'مساعد بِسم الله ليس جهة إفتاء.',
      'assistantSuggestedTitle': 'أسئلة مقترحة',
      'assistantSuggested1': 'كيف يُؤخذ الوضوء؟',
      'assistantSuggested2': 'ما هي أركان الإيمان؟',
      'assistantSuggested3': 'ما هو التيمم؟',
      'assistantSuggested4': 'كيف أستعدّ للصلاة؟',
      'assistantSuggested5': 'ما هو القرآن؟',
      'assistantInputHint': 'اكتب سؤالاً…',
      'assistantSendLabel': 'إرسال',
      'assistantThinking': 'جارٍ البحث في المصادر المُتحقَّقة…',
      'assistantClearTitle': 'مسح المحادثة',
      'assistantClearConfirmTitle': 'مسح المحادثة؟',
      'assistantClearConfirmBody':
          'سيُحذف سجل المحادثة على هذا الجهاز. لا يمكن التراجع عن ذلك.',
      'assistantClearConfirm': 'مسح',
      'assistantCleared': 'تم مسح المحادثة.',
      'assistantYouLabel': 'أنت',
      'assistantSummaryTitle': 'شرح مستند إلى مصدر',
      'assistantStepsTitle': 'الخطوات',
      'assistantKeyPointsTitle': 'نقاط أساسية',
      'assistantPracticalTitle': 'التطبيق',
      'assistantSourcesTitle': 'المصادر الرسمية',
      'assistantOfficialSourceTag': 'مصدر رسمي',
      'assistantRelatedTitle': 'محتوى التعلّم ذو الصلة',
      'assistantReadInLearn': 'اقرأ في التعلّم',
      'assistantOfficialGuidanceCta': 'افتح صفحة السؤال الرسمية',
      'assistantOpenAssistant': 'اسأل بِسم الله',
      'assistantBadgeVerified': 'مصدر مُتحقَّق',
      'assistantBadgeGeneral': 'معلومة عامة مستندة',
      'assistantBadgeNoSource': 'لا يوجد مصدر مُتحقَّق',
      'assistantBadgeGuidance': 'راجِع جهة مختصّة',
      'assistantNoVerifiedSource':
          'لم أجد مصدراً مُتحقَّقاً منه في هذا الموضوع، لذا لا يصحّ أن أقدّم '
          'جواباً قاطعاً. يمكنك الاطّلاع على مواضيع التعلّم ذات الصلة.',
      'assistantOfficialFatwaRequired':
          'لا تتضمّن قاعدة معرفتنا جواباً مباشراً مُتحقَّقاً من المجلس الأعلى '
          'للشؤون الدينية لهذا السؤال. لا يصحّ أن أُصدر حكماً قاطعاً.',
      'assistantQualifiedGuidance':
          'هذا يعتمد على ظروفك الشخصية. للحصول على حكم قاطع يُفضَّل مراجعة '
          'جهة مختصّة معتمدة.',
      'assistantGeneralInfoNotRuling':
          'هذه معلومة عامة؛ ولا تُطبّق حكماً قاطعاً على حالتك الخاصة.',
      'assistantPersonalCaseGeneralInfo':
          'المعلومة العامة أدناه تُلقي الضوء على الموضوع، لكنها لا تتضمّن '
          'حكماً لحالتك الخاصة.',
      'assistantSourceNotDirectlyAddressing':
          'هذا المصدر لا يتناول حالتك الخاصة مباشرةً.',
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
