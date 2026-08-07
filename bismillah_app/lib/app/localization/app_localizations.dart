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

  // Today günlük görev listesi (TASK 083). Ton kuralları: suçlama, seri
  // kaybı, puan, rütbe ve manevi değerlendirme YASAK. İşaretleme
  // uygulama içi bir TAKİP eylemidir — ibadetin kabul edildiği iddiası
  // değildir.
  String get todayPlanTitle => _t('todayPlanTitle');
  String get todayPlanLoading => _t('todayPlanLoading');
  String get todayPlanEmptyTitle => _t('todayPlanEmptyTitle');
  String get todayPlanEmptyBody => _t('todayPlanEmptyBody');
  String get todayPlanNoItems => _t('todayPlanNoItems');
  String get todayPlanCorruptTitle => _t('todayPlanCorruptTitle');
  String get todayPlanCorruptBody => _t('todayPlanCorruptBody');
  String get todayPlanFailureBody => _t('todayPlanFailureBody');
  String get todayPlanItemCompleted => _t('todayPlanItemCompleted');
  String get todayPlanItemPending => _t('todayPlanItemPending');

  /// Namaz/Kur'an şablonlarının nötr karşılıkları — kota, ayet ataması,
  /// süre veya hüküm İÇERMEZ.
  String get todayPlanItemPrayerTrack => _t('todayPlanItemPrayerTrack');
  String get todayPlanItemPrayerOnTime => _t('todayPlanItemPrayerOnTime');
  String get todayPlanItemQuranContinue => _t('todayPlanItemQuranContinue');

  /// Tip bazlı nötr yedekler — tanınmayan şablon için UYDURMA başlık
  /// üretilmez.
  String get todayPlanItemPrayerFallback => _t('todayPlanItemPrayerFallback');
  String get todayPlanItemQuranFallback => _t('todayPlanItemQuranFallback');
  String get todayPlanItemLessonFallback => _t('todayPlanItemLessonFallback');
  String get todayPlanItemDhikrFallback => _t('todayPlanItemDhikrFallback');
  String get todayPlanItemDuaFallback => _t('todayPlanItemDuaFallback');
  String get todayPlanItemReflectionFallback =>
      _t('todayPlanItemReflectionFallback');

  // Ara verdikten sonra sakin dönüş notu (TASK 084). Kaçırılan gün SAYISI
  // gösterilmez; suçlama, seri kaybı, ceza ve manevi değerlendirme dili
  // YASAK.
  String get todayRecoveryTitle => _t('todayRecoveryTitle');
  String get todayRecoveryGentleBody => _t('todayRecoveryGentleBody');
  String get todayRecoveryExtendedBody => _t('todayRecoveryExtendedBody');

  /// "Seçili gün: 2026-07-27" biçimli satır.
  String todayPlanSelectedDay(String day) =>
      _t('todayPlanSelectedDay').replaceAll('{day}', day);

  /// "1/4 tamamlandı" biçimli plan ilerlemesi.
  String todayPlanProgress(int completed, int total) => _t(
    'todayPlanProgress',
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

  // Hesaplama yöntemi seçimi (TASK 096).
  //
  // Ton kuralı: yöntem adları, parametre setinin YAYIMLANDIĞI kaynağı
  // adlandırır — kurumun bu uygulamayı onayladığı ya da vakitleri sağladığı
  // anlamına GELMEZ. Bu yüzden hiçbir etikette "resmî", "onaylı" ya da
  // "Diyanet takvimi" iddiası YOKTUR; Türkiye yöntemi yalnız BÖLGE adıyla
  // anılır ve [prayerMethodNotEndorsement] her zaman görünür.
  String get prayerMethodEntryTitle => _t('prayerMethodEntryTitle');
  String get prayerMethodEntrySubtitle => _t('prayerMethodEntrySubtitle');
  String get prayerMethodTitle => _t('prayerMethodTitle');
  String get prayerMethodIntro => _t('prayerMethodIntro');
  String get prayerMethodNotEndorsement => _t('prayerMethodNotEndorsement');
  String get prayerMethodCurrentLabel => _t('prayerMethodCurrentLabel');
  String get prayerMethodSelected => _t('prayerMethodSelected');
  String get prayerMethodAdjustmentsNote => _t('prayerMethodAdjustmentsNote');
  String get prayerMethodConfirmTitle => _t('prayerMethodConfirmTitle');
  String get prayerMethodConfirmApply => _t('prayerMethodConfirmApply');
  String get prayerMethodConfirmCancel => _t('prayerMethodConfirmCancel');
  String get prayerMethodApplying => _t('prayerMethodApplying');
  String get prayerMethodRemindersNotUpdated =>
      _t('prayerMethodRemindersNotUpdated');
  String get prayerMethodRetryReminders => _t('prayerMethodRetryReminders');
  String get prayerMethodSaveFailed => _t('prayerMethodSaveFailed');

  /// Yöntem adı — anahtar `PrayerTimeCalculationMethod.stableName` ile
  /// kurulur; localization katmanı feature domain'ini import ETMEZ.
  String prayerMethodName(String stableId) => _t('prayerMethodName.$stableId');

  /// Açı tabanlı yöntemin parametreleri (motordan okunur, metne gömülmez).
  String prayerMethodAngles(String fajr, String isha) => _t(
    'prayerMethodAngles',
  ).replaceFirst('{fajr}', fajr).replaceFirst('{isha}', isha);

  /// Yatsının akşamdan sabit dakika sonra hesaplandığı yöntemler.
  String prayerMethodInterval(String fajr, int minutes) => _t(
    'prayerMethodInterval',
  ).replaceFirst('{fajr}', fajr).replaceFirst('{minutes}', '$minutes');

  String prayerMethodConfirmBody(String method) =>
      _t('prayerMethodConfirmBody').replaceFirst('{method}', method);

  String prayerMethodChanged(String method) =>
      _t('prayerMethodChanged').replaceFirst('{method}', method);

  // Kıble yönü (TASK 095 — ton: sakin ve DÜRÜST. Telefon sensörünün verdiği
  // yön yaklaşıktır; "kesin ölçüm" ya da dinî hüküm iddiası YASAKTIR.)
  String get qiblaTitle => _t('qiblaTitle');
  String get qiblaEntryTitle => _t('qiblaEntryTitle');
  String get qiblaEntrySubtitle => _t('qiblaEntrySubtitle');
  String get qiblaBearingLabel => _t('qiblaBearingLabel');
  String get qiblaAligned => _t('qiblaAligned');
  String get qiblaTurnHint => _t('qiblaTurnHint');
  String get qiblaCompassWaiting => _t('qiblaCompassWaiting');
  String get qiblaCompassInterrupted => _t('qiblaCompassInterrupted');
  String get qiblaCompassUnsupported => _t('qiblaCompassUnsupported');
  String get qiblaStaticBearingNote => _t('qiblaStaticBearingNote');
  String get qiblaLowConfidence => _t('qiblaLowConfidence');
  String get qiblaLocationInvite => _t('qiblaLocationInvite');
  String get qiblaUseLocation => _t('qiblaUseLocation');
  String get qiblaLocationDeniedForever => _t('qiblaLocationDeniedForever');
  String get qiblaLocationServiceDisabled => _t('qiblaLocationServiceDisabled');
  String get qiblaLocationUnavailable => _t('qiblaLocationUnavailable');
  String get qiblaCalculationError => _t('qiblaCalculationError');
  String get qiblaApproximateLocationNote => _t('qiblaApproximateLocationNote');
  String get qiblaGuidanceTitle => _t('qiblaGuidanceTitle');
  String get qiblaGuidanceFlat => _t('qiblaGuidanceFlat');
  String get qiblaGuidanceMetal => _t('qiblaGuidanceMetal');
  String get qiblaGuidanceCalibrate => _t('qiblaGuidanceCalibrate');
  String get qiblaHonestyNote => _t('qiblaHonestyNote');

  /// Kadran yön harfleri. Kadranla DÖNMEZLER: konumları açıya göre
  /// hesaplanır ama harfin kendisi daima dik durur.
  String get qiblaCardinalNorth => _t('qiblaCardinalNorth');
  String get qiblaCardinalEast => _t('qiblaCardinalEast');
  String get qiblaCardinalSouth => _t('qiblaCardinalSouth');
  String get qiblaCardinalWest => _t('qiblaCardinalWest');

  /// Kadranın merkezindeki Kâbe görselinin ekran okuyucu açıklaması.
  String get qiblaKaabaSemantics => _t('qiblaKaabaSemantics');

  /// "151°" biçimli açı okuması (kadranla DÖNMEZ, sabit metindir).
  String qiblaDegrees(int degrees) =>
      _t('qiblaDegrees').replaceFirst('{degrees}', '$degrees');

  /// Ekran okuyucu için yön açıklaması.
  String qiblaSemanticsBearing(int degrees) =>
      _t('qiblaSemanticsBearing').replaceFirst('{degrees}', '$degrees');

  // Namaz hatırlatıcıları (TASK 022 — ton: sakin; suçlayıcı/streak/kaçırma YOK)
  String get reminderCardTitle => _t('reminderCardTitle');
  String get reminderEnable => _t('reminderEnable');
  String get reminderDisable => _t('reminderDisable');
  String get reminderEnabledState => _t('reminderEnabledState');
  String get reminderInexactNote => _t('reminderInexactNote');
  String get reminderPermissionNeeded => _t('reminderPermissionNeeded');
  String get reminderLocationNeeded => _t('reminderLocationNeeded');

  // Kesin (exact) alarm özel-erişimi UX'i (TASK 070D). Ton: sakin, dürüst,
  // suçlayıcı değil; teknik terim yok; izin zorunluymuş gibi sunulmaz.
  String get reminderExactTitle => _t('reminderExactTitle');
  String get reminderExactBody => _t('reminderExactBody');
  String get reminderExactOpenSettings => _t('reminderExactOpenSettings');
  String get reminderExactNotNow => _t('reminderExactNotNow');
  String get reminderExactGranted => _t('reminderExactGranted');
  String get reminderExactNotGranted => _t('reminderExactNotGranted');
  String get reminderExactAction => _t('reminderExactAction');

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

  // Profil ana ekranı — plan özeti ve yenileme (TASK 095C).
  // Ton: sakin ve dürüst. Seri/puan/seviye/rozet dili, yarışma ve
  // abartılı kutlama YASAKTIR; gösterilen her sayı kayıtlı gerçek
  // veriden gelir.
  String get profilePlanSection => _t('profilePlanSection');
  String get profilePlanTypeLabel => _t('profilePlanTypeLabel');
  String get profilePlanNone => _t('profilePlanNone');
  String get profilePlanSummaryUnavailable =>
      _t('profilePlanSummaryUnavailable');
  String get profilePlanRecentTitle => _t('profilePlanRecentTitle');
  String get profilePlanLoadIssue => _t('profilePlanLoadIssue');
  String get profilePlanEditPreferences => _t('profilePlanEditPreferences');
  String get profilePlanRegenerateAction => _t('profilePlanRegenerateAction');
  String get profilePlanRegenerateTitle => _t('profilePlanRegenerateTitle');
  String get profilePlanRegenerateBody => _t('profilePlanRegenerateBody');
  String get profilePlanRegenerateConfirm => _t('profilePlanRegenerateConfirm');
  String get profilePlanRegenerateSuccess => _t('profilePlanRegenerateSuccess');
  String get profilePlanRegenerateFailed => _t('profilePlanRegenerateFailed');
  String get profilePlanRegenerateIncomplete =>
      _t('profilePlanRegenerateIncomplete');
  String get profileLocalDataTitle => _t('profileLocalDataTitle');
  String get profileLocalDataBody => _t('profileLocalDataBody');

  /// "Gün 4 / 30" biçimli plan konumu.
  String profilePlanDayOf(int current, int total) => _t(
    'profilePlanDayOf',
  ).replaceAll('{current}', '$current').replaceAll('{total}', '$total');

  /// "12 / 90 görev tamamlandı" biçimli sayaç.
  String profilePlanTasksDone(int done, int total) => _t(
    'profilePlanTasksDone',
  ).replaceAll('{done}', '$done').replaceAll('{total}', '$total');

  /// "3 gün tamamlandı" biçimli sayaç (seri DEĞİLDİR).
  String profilePlanDaysCompleted(int count) =>
      _t('profilePlanDaysCompleted').replaceAll('{count}', '$count');

  /// "Son 7 gün" penceresi başlığı.
  String profilePlanRecentWindow(int days) =>
      _t('profilePlanRecentWindow').replaceAll('{days}', '$days');

  /// Tamamlanma kaydı taşınamayan öğe sayısı için dürüst not.
  String profilePlanRegenerateDropped(int count) =>
      _t('profilePlanRegenerateDropped').replaceAll('{count}', '$count');

  /// Plan profili etiketleri — nötr tanımlardır; seviye/rütbe DEĞİL.
  String get profilePlanTypeBeginner => _t('profilePlanTypeBeginner');
  String get profilePlanTypeReturning => _t('profilePlanTypeReturning');
  String get profilePlanTypePrayerFocused => _t('profilePlanTypePrayerFocused');
  String get profilePlanTypeQuranFocused => _t('profilePlanTypeQuranFocused');
  String get profilePlanTypeDhikrFocused => _t('profilePlanTypeDhikrFocused');
  String get profilePlanTypeLearningFocused =>
      _t('profilePlanTypeLearningFocused');
  String get profilePlanTypeAdvanced => _t('profilePlanTypeAdvanced');
  String get profilePlanTypeLowTime => _t('profilePlanTypeLowTime');
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

  /// Kıraat takibi (TASK 095A): kullanıcı elle kaydırıp takibi askıya
  /// aldığında görünen dönüş yolu ve çalan ayetin ekran okuyucu etiketi.
  String get quranFollowRecitation => _t('quranFollowRecitation');
  String get quranSemanticsPlayingVerse => _t('quranSemanticsPlayingVerse');
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
  String get sourcesUnavailable => _t('sourcesUnavailable');
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

  // Gizlilik özeti ve tam politika (ALPHA-R3A)
  String get privacyLocalPlan => _t('privacyLocalPlan');
  String get privacyLocalAssistant => _t('privacyLocalAssistant');
  String get privacyAssistantTitle => _t('privacyAssistantTitle');
  String get privacyAssistantOnDevice => _t('privacyAssistantOnDevice');
  String get privacyAssistantSensitive => _t('privacyAssistantSensitive');
  String get privacyPermissionsTitle => _t('privacyPermissionsTitle');
  String get privacyPermissionLocation => _t('privacyPermissionLocation');
  String get privacyPermissionNotifications =>
      _t('privacyPermissionNotifications');
  String get privacyPermissionExactAlarm => _t('privacyPermissionExactAlarm');
  String get privacyNetworkFirebase => _t('privacyNetworkFirebase');
  String get privacyNoCloudTitle => _t('privacyNoCloudTitle');
  String get privacyNoCloudBody => _t('privacyNoCloudBody');
  String get privacyOpenFullPolicy => _t('privacyOpenFullPolicy');
  String get privacyOpenWebPolicy => _t('privacyOpenWebPolicy');
  String get privacyWebPolicyUnavailable => _t('privacyWebPolicyUnavailable');
  String get privacyPolicyTitle => _t('privacyPolicyTitle');
  String get privacyPolicyUpdated => _t('privacyPolicyUpdated');
  String get privacyPolicySummaryTitle => _t('privacyPolicySummaryTitle');
  String get privacyPolicySummaryBody => _t('privacyPolicySummaryBody');
  String get privacyPolicyStoredTitle => _t('privacyPolicyStoredTitle');
  String get privacyPolicyStoredBody => _t('privacyPolicyStoredBody');
  String get privacyPolicyAssistantTitle => _t('privacyPolicyAssistantTitle');
  String get privacyPolicyAssistantBody => _t('privacyPolicyAssistantBody');
  String get privacyPolicyCloudTitle => _t('privacyPolicyCloudTitle');
  String get privacyPolicyCloudBody => _t('privacyPolicyCloudBody');
  String get privacyPolicyPermissionsTitle =>
      _t('privacyPolicyPermissionsTitle');
  String get privacyPolicyPermissionsBody => _t('privacyPolicyPermissionsBody');
  String get privacyPolicyNetworkTitle => _t('privacyPolicyNetworkTitle');
  String get privacyPolicyNetworkBody => _t('privacyPolicyNetworkBody');
  String get privacyPolicyNoTrackingTitle => _t('privacyPolicyNoTrackingTitle');
  String get privacyPolicyNoTrackingBody => _t('privacyPolicyNoTrackingBody');
  String get privacyPolicyChildrenTitle => _t('privacyPolicyChildrenTitle');
  String get privacyPolicyChildrenBody => _t('privacyPolicyChildrenBody');
  String get privacyPolicyControlTitle => _t('privacyPolicyControlTitle');
  String get privacyPolicyControlBody => _t('privacyPolicyControlBody');
  String get privacyPolicyContactTitle => _t('privacyPolicyContactTitle');
  String get privacyPolicyContactBody => _t('privacyPolicyContactBody');

  // Destek / geri bildirim (ALPHA-R3A)
  String get supportContactAction => _t('supportContactAction');
  String get supportContactRow => _t('supportContactRow');
  String get supportContactRowSubtitle => _t('supportContactRowSubtitle');
  String get supportEmailUnavailable => _t('supportEmailUnavailable');

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

  // Asistan iniş ekranı, güvenli sonraki adım ve dürüst hata durumları
  // (TASK 095D). Hiçbiri dinî bir iddia taşımaz; yalnız kapsam, sınır ve
  // hata anlatımıdır.
  String get assistantLandingCanTitle => _t('assistantLandingCanTitle');
  String get assistantLandingCan1 => _t('assistantLandingCan1');
  String get assistantLandingCan2 => _t('assistantLandingCan2');
  String get assistantLandingCan3 => _t('assistantLandingCan3');
  String get assistantLandingLimitTitle => _t('assistantLandingLimitTitle');
  String get assistantLandingLocalOnly => _t('assistantLandingLocalOnly');
  String get assistantBadgeOfficialFatwa => _t('assistantBadgeOfficialFatwa');
  String get assistantNextStepGuidance => _t('assistantNextStepGuidance');
  String get assistantNextStepNoSource => _t('assistantNextStepNoSource');
  String get assistantSourceLinkUnavailable =>
      _t('assistantSourceLinkUnavailable');
  String get assistantRetrievalFailedTitle =>
      _t('assistantRetrievalFailedTitle');
  String get assistantRetrievalFailedBody => _t('assistantRetrievalFailedBody');
  String get assistantRetry => _t('assistantRetry');
  String get assistantClearFailed => _t('assistantClearFailed');

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
      // Today günlük görev listesi (TASK 083)
      'todayPlanTitle': 'Bugünün görevleri',
      'todayPlanSelectedDay': 'Seçili gün: {day}',
      'todayPlanProgress': '{completed}/{total} tamamlandı',
      'todayPlanLoading': 'Bugünün görevleri hazırlanıyor',
      'todayPlanEmptyTitle': 'Bu gün için henüz bir plan yok.',
      'todayPlanEmptyBody':
          'Günlük planın hazır olduğunda görevlerin burada görünecek.',
      'todayPlanNoItems': 'Bu güne görev eklenmemiş.',
      'todayPlanCorruptTitle': 'Bu günün planı okunamıyor.',
      'todayPlanCorruptBody':
          'Kayıtlı veri açılamadı. Hiçbir şey silinmedi; bu günün planı '
          'yeniden hazırlandığında görünecek.',
      'todayPlanFailureBody':
          'Bugünün görevleri şu an açılamadı. Tekrar deneyebilirsin.',
      'todayPlanItemCompleted': 'İşaretlendi',
      'todayPlanItemPending': 'Henüz işaretlenmedi',
      'todayPlanItemPrayerTrack': 'Günlük namaz takibi',
      'todayPlanItemPrayerOnTime': 'Namaz vakti takibi',
      'todayPlanItemQuranContinue': "Kur'an alışkanlığına devam et",
      'todayPlanItemPrayerFallback': 'Namaz görevi',
      'todayPlanItemQuranFallback': "Kur'an görevi",
      'todayPlanItemLessonFallback': 'Öğrenme görevi',
      'todayPlanItemDhikrFallback': 'Zikir görevi',
      'todayPlanItemDuaFallback': 'Dua görevi',
      'todayPlanItemReflectionFallback': 'Düşünme görevi',
      // Sakin dönüş notu (TASK 084)
      'todayRecoveryTitle': 'Yeni bir gün',
      'todayRecoveryGentleBody':
          'Hazır olduğunda küçük bir adımla devam edebilirsin.',
      'todayRecoveryExtendedBody':
          'Buraya dönmen güzel. Bugün tek bir küçük adım yeter.',
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
      // TASK 096: yöntem artık seçilebilir olduğundan sabit "Türkiye" etiketi
      // KALDIRILDI — başlık nötr, seçili yöntemin adı yanında gösterilir.
      'prayerTimesMethodLabel': 'Hesaplama yöntemi',
      'prayerTimesSunrise': 'Güneş',
      'prayerMethodEntryTitle': 'Hesaplama yöntemi',
      'prayerMethodEntrySubtitle':
          'Vakitlerin hangi yönteme göre hesaplandığını seçebilirsin.',
      'prayerMethodTitle': 'Hesaplama yöntemi',
      'prayerMethodIntro':
          'Namaz vakitleri, kabul görmüş farklı hesaplama yöntemleriyle '
          'bulunabilir. Yöntemler arasında birkaç dakikalık farklar olması '
          'olağandır. Bulunduğun bölgede yaygın olarak kullanılan yöntemi '
          'seçebilirsin.',
      'prayerMethodNotEndorsement':
          'Yöntem adları, o parametre setini yayımlayan kaynağı belirtir; '
          'ilgili kurumun bu uygulamayı onayladığı veya vakitleri sağladığı '
          'anlamına gelmez. Vakitler cihazında hesaplanır ve resmî takvim '
          'yerine geçmez.',
      'prayerMethodCurrentLabel': 'Şu an kullanılan',
      'prayerMethodSelected': 'Seçili',
      'prayerMethodAdjustmentsNote': 'Yöntemin kendi dakika ayarlarıyla',
      'prayerMethodAngles': 'İmsak {fajr}° · Yatsı {isha}°',
      'prayerMethodInterval':
          'İmsak {fajr}° · Yatsı akşamdan {minutes} dk sonra',
      'prayerMethodConfirmTitle': 'Yöntem değiştirilsin mi?',
      'prayerMethodConfirmBody':
          '“{method}” yöntemine geçilecek. Namaz vakitleri yeniden hesaplanacak '
          've açık olan namaz hatırlatıcıları yeni vakitlere göre yeniden '
          'kurulacak. İşaretlediğin namazlar ve geçmişin değişmez.',
      'prayerMethodConfirmApply': 'Değiştir',
      'prayerMethodConfirmCancel': 'Vazgeç',
      'prayerMethodApplying': 'Uygulanıyor…',
      'prayerMethodChanged': 'Yöntem “{method}” olarak güncellendi.',
      'prayerMethodRemindersNotUpdated':
          'Yöntem kaydedildi ve vakitler yeniden hesaplandı, ancak '
          'hatırlatıcılar şu an yeni vakitlere göre kurulamadı.',
      'prayerMethodRetryReminders': 'Hatırlatıcıları yeniden kur',
      'prayerMethodSaveFailed': 'Yöntem kaydedilemedi. Hiçbir şey değişmedi.',
      'prayerMethodName.turkiyeDiyanet': 'Türkiye',
      'prayerMethodName.muslimWorldLeague': 'Râbıta (Müslüman Dünya Ligi)',
      'prayerMethodName.egyptian': 'Mısır Genel Ölçüm Kurumu',
      'prayerMethodName.karachi': 'Karaçi İslam İlimleri Üniversitesi',
      'prayerMethodName.northAmerica': 'Kuzey Amerika (ISNA)',
      'prayerMethodName.ummAlQura': 'Ümmü’l-Kurâ Üniversitesi (Mekke)',
      'prayerMethodName.dubai': 'Dubai',
      'prayerMethodName.qatar': 'Katar',
      'prayerMethodName.kuwait': 'Kuveyt',
      'prayerMethodName.gulfRegion': 'Körfez bölgesi',
      'prayerMethodName.moonsightingCommittee': 'Moonsighting Committee',
      'prayerMethodName.singapore': 'Singapur',
      'prayerMethodName.indonesian': 'Endonezya (KEMENAG)',
      'prayerMethodName.morocco': 'Fas',
      'prayerMethodName.algerian': 'Cezayir Din İşleri Bakanlığı',
      'prayerMethodName.tunisia': 'Tunus Din İşleri Bakanlığı',
      'prayerMethodName.jordan': 'Ürdün',
      'prayerMethodName.france': 'Fransa (UOIF)',
      'prayerMethodName.portugal': 'Portekiz (Lizbon İslam Cemaati)',
      'prayerMethodName.russia': 'Rusya Müslümanları Dinî İdaresi',
      'prayerTimesUseLocation': 'Konumu kullan',
      'prayerTimesLocationInvite':
          'Vakitleri bulunduğun yere göre görmek için konumunu kullanabilirsin.',
      'prayerTimesLocationDeniedForever':
          'Konum izni kapalı. Ayarlardan açarsan vakitleri gösterebiliriz.',
      'prayerTimesOpenSettings': 'Ayarları aç',
      'prayerTimesUnavailable':
          'Konum şu an alınamadı — dilediğinde tekrar deneyebilirsin.',
      'prayerTimesApproximate': 'Yaklaşık konuma göre',
      'qiblaTitle': 'Kıble',
      'qiblaEntryTitle': 'Kıble yönü',
      'qiblaEntrySubtitle': 'Bulunduğun yerden Kâbe yönüne sakin bir bakış.',
      'qiblaBearingLabel': 'Kuzeyden kıble açısı',
      'qiblaDegrees': '{degrees}°',
      'qiblaAligned': 'Telefon kıble yönüne dönük.',
      'qiblaTurnHint': 'Telefonu yavaşça çevir.',
      'qiblaCompassWaiting': 'Pusula okuması bekleniyor.',
      'qiblaCompassInterrupted': 'Yön okuması şu an alınamıyor.',
      'qiblaCompassUnsupported': 'Bu cihazda pusula sensörü bulunamadı.',
      'qiblaStaticBearingNote':
          'Yalnız kuzeyden ölçülen kıble açısı gösteriliyor.',
      'qiblaLowConfidence': 'Okuma oynak görünüyor.',
      'qiblaLocationInvite':
          'Kıble yönünü hesaplamak için bulunduğun yerin konumu gerekir. '
          'Konum yalnız bu hesap için kullanılır; kaydedilmez.',
      'qiblaUseLocation': 'Konumu kullan',
      'qiblaLocationDeniedForever':
          'Konum izni kapalı. Ayarlardan açarsan kıble yönünü gösterebiliriz.',
      'qiblaLocationServiceDisabled':
          'Cihazın konum servisi kapalı. Açtıktan sonra tekrar deneyebilirsin.',
      'qiblaLocationUnavailable':
          'Konum şu an alınamadı — dilediğinde tekrar deneyebilirsin.',
      'qiblaCalculationError': 'Kıble yönü bu konum için hesaplanamadı.',
      'qiblaApproximateLocationNote': 'Yaklaşık konuma göre',
      'qiblaGuidanceTitle': 'Daha iyi bir okuma için',
      'qiblaGuidanceFlat': 'Telefonu yere paralel, düz tut.',
      'qiblaGuidanceMetal': 'Metal ve mıknatıslı nesnelerden biraz uzaklaş.',
      'qiblaGuidanceCalibrate':
          'Okuma oynaksa telefonu havada sekiz çizerek pusulayı kalibre et.',
      'qiblaHonestyNote':
          'Telefon sensörü yaklaşık bir yön verir. Bu gösterge kesin bir '
          'ölçüm ya da dinî bir hüküm değildir.',
      'qiblaSemanticsBearing': 'Kıble yönü kuzeyden {degrees} derece.',
      'qiblaCardinalNorth': 'K',
      'qiblaCardinalEast': 'D',
      'qiblaCardinalSouth': 'G',
      'qiblaCardinalWest': 'B',
      'qiblaKaabaSemantics': 'Kadranın merkezinde Kâbe: yön hedefi.',
      'reminderCardTitle': 'Namaz hatırlatıcıları',
      'reminderEnable': 'Hatırlatıcıları aç',
      'reminderDisable': 'Hatırlatıcıları kapat',
      'reminderEnabledState': 'Hatırlatıcılar açık',
      'reminderInexactNote':
          'Hatırlatma zamanı cihazına göre birkaç dakika kayabilir.',
      'reminderPermissionNeeded': 'Hatırlatıcılar için bildirim izni gerekli.',
      'reminderLocationNeeded': 'Vakitleri hesaplamak için konum gerekli.',
      'reminderExactTitle': 'Hatırlatmalar tam zamanında gelsin',
      'reminderExactBody':
          'Android, namaz hatırlatmalarını tam vaktinde gösterebilmek için ayrı '
          'bir “Alarmlar ve hatırlatıcılar” izni ister. İzin vermezsen '
          'hatırlatmalar yaklaşık zamanda çalışmaya devam eder.',
      'reminderExactOpenSettings': 'İzin ekranını aç',
      'reminderExactNotNow': 'Şimdi değil',
      'reminderExactGranted': 'Tam zamanlı hatırlatmalar etkinleştirildi.',
      'reminderExactNotGranted':
          'Hatırlatmalar yaklaşık zamanda çalışmaya devam edecek.',
      'reminderExactAction': 'Tam zamanlı hatırlatmalar',
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
      'profilePlanSection': '30 günlük planın',
      'profilePlanTypeLabel': 'Plan profilin',
      'profilePlanNone':
          'Şu an aktif bir plan görünmüyor. Bugün için bir plan '
          'oluşturulduğunda özet burada görünür.',
      'profilePlanSummaryUnavailable': 'Plan özeti şu an hesaplanamadı.',
      'profilePlanDayOf': 'Gün {current} / {total}',
      'profilePlanTasksDone': '{done} / {total} görev tamamlandı',
      'profilePlanDaysCompleted': '{count} gün tamamen tamamlandı',
      'profilePlanRecentTitle': 'Son ilerleme',
      'profilePlanRecentWindow': 'Son {days} gün',
      'profilePlanLoadIssue': 'Profil bilgilerin şu an açılamadı.',
      'profilePlanEditPreferences': 'Tercihleri düzenle',
      'profilePlanRegenerateAction': 'Planı tercihlerine göre yenile',
      'profilePlanRegenerateTitle': 'Plan yenilensin mi?',
      'profilePlanRegenerateBody':
          'Bugünden itibaren 30 günlük plan, kayıtlı tercihlerine göre '
          'yeniden oluşturulur. Geçmiş günlere dokunulmaz. Yeni planda '
          'da yer alan görevlerin tamamlanma işaretleri korunur; '
          'tercihlerin nedeniyle artık plana girmeyen görevlerin '
          'işaretleri onlarla birlikte kalkar.',
      'profilePlanRegenerateConfirm': 'Planı yenile',
      'profilePlanRegenerateSuccess': 'Plan tercihlerine göre yenilendi.',
      'profilePlanRegenerateDropped':
          '{count} tamamlanmış görev yeni planda yer almadığı için işareti '
          'taşınmadı.',
      'profilePlanRegenerateFailed':
          'Plan yenilenemedi — planın olduğu gibi kaldı.',
      'profilePlanRegenerateIncomplete':
          'Önce tercihlerini tamamlaman gerekiyor.',
      'profileLocalDataTitle': 'Verilerin bu cihazda',
      'profileLocalDataBody':
          'Tercihlerin, planın ve ilerlemen yalnız bu cihazda saklanır. '
          'Bulut yedekleme ve hesap eşitlemesi şu an etkin değildir; '
          'uygulamayı kaldırmak veya uygulama verilerini temizlemek '
          'yerel ilerlemeni siler.',
      'profilePlanTypeBeginner': 'Başlangıç',
      'profilePlanTypeReturning': 'Yeniden başlama',
      'profilePlanTypePrayerFocused': 'Namaz odaklı',
      'profilePlanTypeQuranFocused': "Kur'an odaklı",
      'profilePlanTypeDhikrFocused': 'Zikir odaklı',
      'profilePlanTypeLearningFocused': 'Öğrenme odaklı',
      'profilePlanTypeAdvanced': 'Güçlendirme',
      'profilePlanTypeLowTime': 'Kısa zamanlı',
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
      'quranFollowRecitation': 'Kıraati takip et',
      'quranSemanticsPlayingVerse': 'Şu an çalan ayet',
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
      'sourcesUnavailable':
          'Kaynak künyeleri şu anda yüklenemedi. Lütfen daha sonra tekrar deneyin.',
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
      // Gizlilik özeti ve tam politika (ALPHA-R3A)
      'privacyLocalPlan': '30 günlük plan ve görev tamamlamaların',
      'privacyLocalAssistant': 'Asistan sohbet geçmişi (son 20 mesaj)',
      'privacyAssistantTitle': 'Asistan',
      'privacyAssistantOnDevice':
          'Sorular cihazda işlenir; dış bir yapay zekâ servisine gönderilmez',
      'privacyAssistantSensitive':
          'Hüküm, kişisel durum ve ibadet kuralı soruları cihazda saklanmaz',
      'privacyPermissionsTitle': 'İzinler',
      'privacyPermissionLocation':
          'Konum (yalnız uygulama açıkken): namaz vakti ve kıble hesabı',
      'privacyPermissionNotifications':
          'Bildirimler: namaz hatırlatıcıları için',
      'privacyPermissionExactAlarm':
          'Tam zamanlı alarm: izin yoksa yaklaşık zamanlamaya dönülür',
      'privacyNetworkFirebase':
          'Firebase anonim kimlik doğrulaması (Google servisleri)',
      'privacyNoCloudTitle': 'Bulut yedeklemesi yok',
      'privacyNoCloudBody':
          'Etkin bir bulut yedekleme veya hesap senkronizasyonu yoktur. '
          'Uygulamayı kaldırırsan ya da uygulama verilerini temizlersen '
          'yerel ilerlemen kalıcı olarak silinir.',
      'privacyOpenFullPolicy': 'Gizlilik politikasının tamamı',
      'privacyOpenWebPolicy': "Web'de gizlilik politikasını aç",
      'privacyWebPolicyUnavailable':
          'Tarayıcı açılamadı. Politikanın web adresi:',
      'privacyPolicyTitle': 'Gizlilik politikası',
      'privacyPolicyUpdated': 'Son güncelleme: 7 Ağustos 2026 · Android alpha',
      'privacyPolicySummaryTitle': 'Kısaca',
      'privacyPolicySummaryBody':
          'Bismillah önce-cihaz çalışır: planın, ilerlemen, tercihlerin ve '
          'Asistan geçmişin öncelikle kendi cihazında saklanır ve hesap '
          'açman gerekmez. Bu, hiçbir verinin cihazdan çıkmadığı anlamına '
          'gelmez; ağ kullanılan yerler aşağıda tek tek yazılıdır.',
      'privacyPolicyStoredTitle': 'Cihazında saklananlar',
      'privacyPolicyStoredBody':
          'Onboarding tercihlerin ve türetilen plan profilin, 30 günlük plan '
          'kayıtların ve görev tamamlamaların, namaz takip geçmişin, '
          "Kur'an okuma konumun ve yer imlerin, öğrenme kayıtların, dil ve "
          'hesaplama yöntemi tercihlerin, Asistan sohbet geçmişin '
          '(en fazla son 20 mesaj).',
      'privacyPolicyAssistantTitle': 'Asistan ve hassas sorular',
      'privacyPolicyAssistantBody':
          'Asistan tamamen cihaz üzerinde çalışır; soruların hiçbir dış '
          'üretken yapay zekâ servisine gönderilmez. Hüküm, kişisel durum ve '
          'ibadet kuralı niteliğindeki hassas sorular ile cevapları cihazda '
          'saklanmaz. Bu ayrım anahtar kelimeye dayalıdır, bu yüzden zaman '
          'zaman zararsız bir soru da saklanmayan gruba girebilir. Geçmişi '
          'istediğin an uygulama içinden silebilirsin.',
      'privacyPolicyCloudTitle': 'Bulut yedekleme ve hesap',
      'privacyPolicyCloudBody':
          'Şu anda etkin bir bulut yedekleme veya hesap senkronizasyonu '
          'yoktur ve verilerin başka bir cihaza taşınmaz. Bunun doğrudan '
          'sonucu: uygulamayı kaldırırsan veya uygulama verilerini '
          'temizlersen yerel ilerlemen kalıcı olarak silinir.',
      'privacyPolicyPermissionsTitle': 'İzinler',
      'privacyPolicyPermissionsBody':
          'Konum yalnız uygulama açıkken ve yalnız namaz vakitlerini ve '
          'kıble yönünü cihazında hesaplamak için kullanılır; bir sunucuya '
          'gönderilmez ve arka planda toplanmaz. Bildirim izni namaz '
          'hatırlatıcıları içindir; hatırlatıcılar cihazda planlanır. Tam '
          'zamanlı alarm izni yoksa uygulama yaklaşık zamanlamaya döner ve '
          'bunu sana açıkça söyler.',
      'privacyPolicyNetworkTitle': 'Ağ kullanılan yerler',
      'privacyPolicyNetworkBody':
          "Kur'an sesi MP3Quran.net üzerinden akıtılır; bir kaydı çaldığında "
          'cihazının IP adresi teknik olarak o servise ulaşır. Tanzil, '
          'QuranEnc ve resmî kaynak bağlantılarını açtığında sistem tarayıcın '
          'ilgili siteye bağlanır ve o siteler kendi gizlilik politikalarına '
          'tabidir. Uygulama Firebase anonim kimlik doğrulaması başlatır; bu '
          'sırada cihaz Google servisleriyle iletişim kurabilir ve adına ya '
          'da e-postana bağlı olmayan anonim bir kimlik oluşturulur. Uygulama '
          'paketinde standart Firebase istemci yapılandırması bulunur.',
      'privacyPolicyNoTrackingTitle': 'Reklam, ölçümleme ve ödeme',
      'privacyPolicyNoTrackingBody':
          'Hiçbir reklam SDK\'sı entegre değildir. Etkin bir analitik veya '
          'çökme raporlama arka ucu yoktur. Etkin bir ödeme veya abonelik '
          'sistemi yoktur; alpha sürümünde satın alma yapılamaz.',
      'privacyPolicyChildrenTitle': 'Çocuklar',
      'privacyPolicyChildrenBody':
          'Bismillah çocuklara yönelik bir ürün olarak tasarlanmamıştır ve '
          'çocuklara özel bir veri toplama uygulaması yürütmez. Yaşa dayalı '
          'profilleme yapılmaz.',
      'privacyPolicyControlTitle': 'Kontrol sende',
      'privacyPolicyControlBody':
          'Uygulama içinden öğrenme verilerini veya tüm yerel verilerini '
          'sıfırlayabilir, Asistan geçmişini silebilirsin. Cihaz ayarlarından '
          'uygulama verilerini temizlemek de aynı sonucu verir.',
      'privacyPolicyContactTitle': 'İletişim',
      'privacyPolicyContactBody':
          'Soru, geri bildirim veya gizlilik talebi için bize yazabilirsin.',
      // Destek / geri bildirim (ALPHA-R3A)
      'supportContactAction': 'Destek ile iletişime geç',
      'supportContactRow': 'Destek ve geri bildirim',
      'supportContactRowSubtitle': 'E-posta ile yaz',
      'supportEmailUnavailable':
          'E-posta uygulaması açılamadı. Bize şu adresten yazabilirsin:',
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
      // TASK 095D düzeltmesi: eski metin "bilgi tabanımızda bulunmuyor" ile
      // başlıyordu ve kullanıcıya "kaynak yok" durumundan AYIRT EDİLEMEZ
      // görünüyordu. Metin, BİSMİLLAH'IN SINIRINI söyler; "yalnız resmî
      // merci hüküm verebilir" gibi bir DIŞLAYICILIK iddiası KURMAZ.
      'assistantOfficialFatwaRequired':
          'Bu soru dinî hüküm gerektiriyor. Bismillah bu konuda kesin bir '
          'fetva üretmez. Doğrudan ve güvenilir bir cevap için resmî bir '
          'fetva kaynağına veya ehil bir din âlimine başvurun.',
      'assistantQualifiedGuidance':
          'Bu konu kişisel duruma özel değerlendirme gerektiriyor. Kesin bir '
          'hüküm için yetkili bir mercie danışman en doğrusudur.',
      'assistantGeneralInfoNotRuling':
          'Bu genel bir bilgidir; özel durumuna kesin bir hüküm uygulamaz.',
      'assistantPersonalCaseGeneralInfo':
          'Aşağıdaki genel bilgi konuya ışık tutar; ancak senin özel durumun '
          'için hüküm içermez.',
      'assistantSourceNotDirectlyAddressing':
          'Aşağıdaki kaynak konu hakkında genel bilgi verir; bu hüküm '
          'sorusunu doğrudan cevaplamaz.',
      // TASK 095D
      'assistantLandingCanTitle': 'Neler yapabilir?',
      'assistantLandingCan1':
          "Sorunu Bismillah'ın yayınlanmış, kaynağı doğrulanmış içeriğinde "
          'arar.',
      'assistantLandingCan2':
          'Cevabı, kaynak künyesi ve kesin sayfa/bölüm bilgisiyle birlikte '
          'gösterir.',
      'assistantLandingCan3':
          'İlgili Learn içeriğine bağlar; konuyu oradan okumaya devam '
          'edebilirsin.',
      'assistantLandingLimitTitle': 'Sınırları',
      'assistantLandingLocalOnly':
          'Sorular bu cihazda işlenir; harici bir yapay zekâ servisine '
          'gönderilmez.',
      'assistantBadgeOfficialFatwa': 'Resmî fetva gerekir',
      'assistantNextStepGuidance':
          'Bunun yerine konunun genel bilgisini okuyabilir veya resmî soru '
          'sayfasına gidebilirsin.',
      'assistantNextStepNoSource':
          'Soruyu farklı kelimelerle yazabilir ya da aşağıdaki ilgili '
          'başlıklara bakabilirsin.',
      'assistantSourceLinkUnavailable':
          'Bu kaynağın açılabilir bir adresi kayıtlı değil.',
      'assistantRetrievalFailedTitle': 'Arama tamamlanamadı',
      'assistantRetrievalFailedBody':
          'Doğrulanmış içerikte arama şu an tamamlanamadı. Cevap üretilmedi; '
          'tekrar deneyebilirsin.',
      'assistantRetry': 'Tekrar dene',
      'assistantClearFailed':
          'Sohbet geçmişi silinemedi. Tekrar deneyebilirsin.',
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
      // Today daily task list (TASK 083)
      'todayPlanTitle': 'Today\'s tasks',
      'todayPlanSelectedDay': 'Selected day: {day}',
      'todayPlanProgress': '{completed}/{total} completed',
      'todayPlanLoading': 'Preparing today\'s tasks',
      'todayPlanEmptyTitle': 'There is no plan for this day yet.',
      'todayPlanEmptyBody':
          'Your tasks will appear here once your daily plan is ready.',
      'todayPlanNoItems': 'No tasks were added to this day.',
      'todayPlanCorruptTitle': 'This day\'s plan cannot be read.',
      'todayPlanCorruptBody':
          'The saved data could not be opened. Nothing was deleted; this '
          'day will appear again once its plan is prepared.',
      'todayPlanFailureBody':
          'Today\'s tasks could not be opened right now. You can try again.',
      'todayPlanItemCompleted': 'Marked',
      'todayPlanItemPending': 'Not marked yet',
      'todayPlanItemPrayerTrack': 'Daily prayer tracking',
      'todayPlanItemPrayerOnTime': 'Prayer timeliness tracking',
      'todayPlanItemQuranContinue': 'Continue your Quran habit',
      'todayPlanItemPrayerFallback': 'Prayer task',
      'todayPlanItemQuranFallback': 'Quran task',
      'todayPlanItemLessonFallback': 'Learning task',
      'todayPlanItemDhikrFallback': 'Dhikr task',
      'todayPlanItemDuaFallback': 'Dua task',
      'todayPlanItemReflectionFallback': 'Reflection task',
      // Calm return note (TASK 084)
      'todayRecoveryTitle': 'A new day',
      'todayRecoveryGentleBody':
          'Continue with one small step whenever you are ready.',
      'todayRecoveryExtendedBody':
          'Good to see you back. One small step is enough for today.',
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
      'prayerTimesMethodLabel': 'Calculation method',
      'prayerTimesSunrise': 'Sunrise',
      'prayerMethodEntryTitle': 'Calculation method',
      'prayerMethodEntrySubtitle':
          'Choose the method your prayer times are calculated with.',
      'prayerMethodTitle': 'Calculation method',
      'prayerMethodIntro':
          'Prayer times can be worked out with several accepted calculation '
          'methods. A few minutes of difference between them is normal. You '
          'can pick the method commonly used where you are.',
      'prayerMethodNotEndorsement':
          'A method name identifies the source that published those '
          'parameters; it does not mean that body endorses this app or '
          'supplies these times. Times are calculated on your device and do '
          'not replace an official timetable.',
      'prayerMethodCurrentLabel': 'Currently used',
      'prayerMethodSelected': 'Selected',
      'prayerMethodAdjustmentsNote': 'With the method’s own minute adjustments',
      'prayerMethodAngles': 'Fajr {fajr}° · Isha {isha}°',
      'prayerMethodInterval': 'Fajr {fajr}° · Isha {minutes} min after Maghrib',
      'prayerMethodConfirmTitle': 'Change the method?',
      'prayerMethodConfirmBody':
          'You are switching to “{method}”. Prayer times will be recalculated '
          'and any enabled prayer reminders will be rescheduled to the new '
          'times. Your marked prayers and history stay unchanged.',
      'prayerMethodConfirmApply': 'Change',
      'prayerMethodConfirmCancel': 'Cancel',
      'prayerMethodApplying': 'Applying…',
      'prayerMethodChanged': 'Method updated to “{method}”.',
      'prayerMethodRemindersNotUpdated':
          'The method was saved and times were recalculated, but reminders '
          'could not be rescheduled to the new times right now.',
      'prayerMethodRetryReminders': 'Reschedule reminders',
      'prayerMethodSaveFailed':
          'The method could not be saved. Nothing was changed.',
      'prayerMethodName.turkiyeDiyanet': 'Türkiye',
      'prayerMethodName.muslimWorldLeague': 'Muslim World League',
      'prayerMethodName.egyptian': 'Egyptian General Authority of Survey',
      'prayerMethodName.karachi': 'University of Islamic Sciences, Karachi',
      'prayerMethodName.northAmerica': 'North America (ISNA)',
      'prayerMethodName.ummAlQura': 'Umm al-Qura University, Makkah',
      'prayerMethodName.dubai': 'Dubai',
      'prayerMethodName.qatar': 'Qatar',
      'prayerMethodName.kuwait': 'Kuwait',
      'prayerMethodName.gulfRegion': 'Gulf Region',
      'prayerMethodName.moonsightingCommittee': 'Moonsighting Committee',
      'prayerMethodName.singapore': 'Singapore',
      'prayerMethodName.indonesian': 'Indonesia (KEMENAG)',
      'prayerMethodName.morocco': 'Morocco',
      'prayerMethodName.algerian': 'Algerian Ministry of Religious Affairs',
      'prayerMethodName.tunisia': 'Tunisian Ministry of Religious Affairs',
      'prayerMethodName.jordan': 'Jordan',
      'prayerMethodName.france': 'France (UOIF)',
      'prayerMethodName.portugal': 'Portugal (Islamic Community of Lisbon)',
      'prayerMethodName.russia':
          'Spiritual Administration of Muslims of Russia',
      'prayerTimesUseLocation': 'Use location',
      'prayerTimesLocationInvite':
          'Use your location to see times for where you are.',
      'prayerTimesLocationDeniedForever':
          'Location is off. Enable it in Settings to show your times.',
      'prayerTimesOpenSettings': 'Open settings',
      'prayerTimesUnavailable':
          'Location is unavailable right now — you can try again anytime.',
      'prayerTimesApproximate': 'Based on approximate location',
      'qiblaTitle': 'Qibla',
      'qiblaEntryTitle': 'Qibla direction',
      'qiblaEntrySubtitle':
          'A calm look at the Kaaba direction from where you are.',
      'qiblaBearingLabel': 'Qibla angle from north',
      'qiblaDegrees': '{degrees}°',
      'qiblaAligned': 'The phone is facing the Qibla direction.',
      'qiblaTurnHint': 'Turn the phone slowly.',
      'qiblaCompassWaiting': 'Waiting for a compass reading.',
      'qiblaCompassInterrupted':
          'The direction reading is unavailable right now.',
      'qiblaCompassUnsupported': 'No compass sensor was found on this device.',
      'qiblaStaticBearingNote':
          'Only the Qibla angle measured from north is shown.',
      'qiblaLowConfidence': 'The reading looks unsteady.',
      'qiblaLocationInvite':
          'Your location is needed to calculate the Qibla direction. It is '
          'used only for this calculation and is not stored.',
      'qiblaUseLocation': 'Use location',
      'qiblaLocationDeniedForever':
          'Location permission is off. If you enable it in settings we can '
          'show the Qibla direction.',
      'qiblaLocationServiceDisabled':
          'Your device location service is off. You can try again once it is on.',
      'qiblaLocationUnavailable':
          'Location could not be read right now — you can try again whenever you like.',
      'qiblaCalculationError':
          'The Qibla direction could not be calculated for this location.',
      'qiblaApproximateLocationNote': 'Based on approximate location',
      'qiblaGuidanceTitle': 'For a better reading',
      'qiblaGuidanceFlat': 'Hold the phone flat, parallel to the ground.',
      'qiblaGuidanceMetal':
          'Move a little away from metal and magnetic objects.',
      'qiblaGuidanceCalibrate':
          'If the reading is unsteady, calibrate the compass by moving the '
          'phone in a figure eight.',
      'qiblaHonestyNote':
          'The phone sensor gives an approximate direction. This indicator is '
          'not an exact measurement and not a religious ruling.',
      'qiblaSemanticsBearing':
          'Qibla direction is {degrees} degrees from north.',
      'qiblaCardinalNorth': 'N',
      'qiblaCardinalEast': 'E',
      'qiblaCardinalSouth': 'S',
      'qiblaCardinalWest': 'W',
      'qiblaKaabaSemantics':
          'The Kaaba at the centre of the dial: the direction target.',
      'reminderCardTitle': 'Prayer reminders',
      'reminderEnable': 'Turn on reminders',
      'reminderDisable': 'Turn off reminders',
      'reminderEnabledState': 'Reminders are on',
      'reminderInexactNote':
          'Reminder timing may vary by a few minutes on your device.',
      'reminderPermissionNeeded':
          'Notification permission is needed for reminders.',
      'reminderLocationNeeded': 'Location is needed to calculate the times.',
      'reminderExactTitle': 'Let reminders arrive right on time',
      'reminderExactBody':
          'Android asks for a separate “Alarms & reminders” permission so prayer '
          'reminders can show exactly on time. If you don’t allow it, reminders '
          'keep working at an approximate time.',
      'reminderExactOpenSettings': 'Open permission screen',
      'reminderExactNotNow': 'Not now',
      'reminderExactGranted': 'On-time reminders enabled.',
      'reminderExactNotGranted':
          'Reminders will keep working at an approximate time.',
      'reminderExactAction': 'On-time reminders',
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
      'profilePlanSection': 'Your 30-day plan',
      'profilePlanTypeLabel': 'Your plan profile',
      'profilePlanNone':
          'There is no active plan right now. Once a plan exists for today, '
          'the summary appears here.',
      'profilePlanSummaryUnavailable':
          'The plan summary could not be calculated right now.',
      'profilePlanDayOf': 'Day {current} of {total}',
      'profilePlanTasksDone': '{done} of {total} tasks completed',
      'profilePlanDaysCompleted': '{count} days fully completed',
      'profilePlanRecentTitle': 'Recent progress',
      'profilePlanRecentWindow': 'Last {days} days',
      'profilePlanLoadIssue': 'Your profile could not be opened right now.',
      'profilePlanEditPreferences': 'Edit preferences',
      'profilePlanRegenerateAction': 'Rebuild the plan from your preferences',
      'profilePlanRegenerateTitle': 'Rebuild the plan?',
      'profilePlanRegenerateBody':
          'The 30-day plan starting today will be rebuilt from your saved '
          'preferences. Past days are left untouched. Completion marks '
          'are kept for tasks that are still in the new plan; tasks your '
          'preferences no longer include are removed together with their '
          'marks.',
      'profilePlanRegenerateConfirm': 'Rebuild plan',
      'profilePlanRegenerateSuccess':
          'The plan was rebuilt from your preferences.',
      'profilePlanRegenerateDropped':
          '{count} completed tasks are not in the new plan, so their marks '
          'were not carried over.',
      'profilePlanRegenerateFailed':
          'The plan could not be rebuilt — your plan is unchanged.',
      'profilePlanRegenerateIncomplete':
          'Please complete your preferences first.',
      'profileLocalDataTitle': 'Your data stays on this device',
      'profileLocalDataBody':
          'Your preferences, plan and progress are stored only on this '
          'device. Cloud backup and account sync are not active; '
          'uninstalling the app or clearing its data removes your local '
          'progress.',
      'profilePlanTypeBeginner': 'Getting started',
      'profilePlanTypeReturning': 'Rebuilding a routine',
      'profilePlanTypePrayerFocused': 'Prayer focused',
      'profilePlanTypeQuranFocused': 'Quran focused',
      'profilePlanTypeDhikrFocused': 'Dhikr focused',
      'profilePlanTypeLearningFocused': 'Learning focused',
      'profilePlanTypeAdvanced': 'Strengthening',
      'profilePlanTypeLowTime': 'Short on time',
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
      'quranFollowRecitation': 'Follow recitation',
      'quranSemanticsPlayingVerse': 'Currently playing verse',
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
      'sourcesUnavailable':
          'Source details could not be loaded right now. Please try again later.',
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
      // Privacy summary and full policy (ALPHA-R3A)
      'privacyLocalPlan': 'Your 30-day plan and task completions',
      'privacyLocalAssistant': 'Assistant conversation history (last 20)',
      'privacyAssistantTitle': 'Assistant',
      'privacyAssistantOnDevice':
          'Questions are handled on this device, not sent to an external AI',
      'privacyAssistantSensitive':
          'Ruling, personal-case and worship-rule questions are not stored',
      'privacyPermissionsTitle': 'Permissions',
      'privacyPermissionLocation':
          'Location (foreground only): prayer times and Qibla direction',
      'privacyPermissionNotifications':
          'Notifications: used for prayer reminders',
      'privacyPermissionExactAlarm':
          'Exact alarm: without it the app falls back to inexact timing',
      'privacyNetworkFirebase':
          'Firebase anonymous authentication (Google services)',
      'privacyNoCloudTitle': 'No cloud backup',
      'privacyNoCloudBody':
          'There is no active cloud backup and no account sync. If you '
          'uninstall the app or clear its app data, your local progress is '
          'permanently deleted.',
      'privacyOpenFullPolicy': 'Read the full privacy policy',
      'privacyOpenWebPolicy': 'Open the privacy policy on the web',
      'privacyWebPolicyUnavailable':
          'No browser could be opened. The policy address is:',
      'privacyPolicyTitle': 'Privacy policy',
      'privacyPolicyUpdated': 'Last updated: 7 August 2026 · Android alpha',
      'privacyPolicySummaryTitle': 'In short',
      'privacyPolicySummaryBody':
          'Bismillah is local-first: your plan, progress, preferences and '
          'Assistant history are stored primarily on your own device, and no '
          'account is required. This does not mean no data ever leaves the '
          'device; every place the network is used is listed below.',
      'privacyPolicyStoredTitle': 'Stored on your device',
      'privacyPolicyStoredBody':
          'Your onboarding preferences and the plan profile derived from '
          'them, your 30-day plan records and task completions, your prayer '
          'tracking history, your Quran reading position and bookmarks, your '
          'learning records, your language and calculation-method '
          'preferences, and your Assistant conversation history (at most the '
          'last 20 messages).',
      'privacyPolicyAssistantTitle': 'Assistant and sensitive questions',
      'privacyPolicyAssistantBody':
          'The Assistant runs entirely on your device; your questions are '
          'never sent to any external generative-AI service. Sensitive '
          'questions — rulings, personal cases and worship rules — and their '
          'answers are not stored on the device. This distinction is made '
          'with keyword matching, so occasionally a harmless question may '
          'also fall into the not-stored group. You can delete your history '
          'from inside the app at any time.',
      'privacyPolicyCloudTitle': 'Cloud backup and accounts',
      'privacyPolicyCloudBody':
          'There is currently no active cloud backup and no account sync, '
          'and your data is not carried to another device. The direct '
          'consequence: if you uninstall the app or clear its app data, your '
          'local progress is permanently deleted.',
      'privacyPolicyPermissionsTitle': 'Permissions',
      'privacyPolicyPermissionsBody':
          'Location is used only while the app is open and only to compute '
          'prayer times and the Qibla direction on your device; it is not '
          'sent to a server and not collected in the background. The '
          'notification permission is for prayer reminders, which are '
          'scheduled on the device. Without the exact-alarm permission the '
          'app falls back to inexact scheduling and tells you so plainly.',
      'privacyPolicyNetworkTitle': 'Where the network is used',
      'privacyPolicyNetworkBody':
          'Quran audio is streamed from MP3Quran.net, so when you play a '
          "recitation your device's IP address technically reaches that "
          'service. When you open Tanzil, QuranEnc or official source links, '
          'your system browser connects to that site and those sites are '
          'governed by their own privacy policies. The app starts Firebase '
          'anonymous authentication; during this the device may contact '
          'Google services and an anonymous identifier is created that is '
          'not tied to your name or e-mail. The app package contains '
          'standard Firebase client configuration.',
      'privacyPolicyNoTrackingTitle': 'Advertising, measurement and payments',
      'privacyPolicyNoTrackingBody':
          'No advertising SDK is integrated. No analytics or crash-reporting '
          'backend is active. No payment or subscription system is active; '
          'no purchase can be made in the alpha.',
      'privacyPolicyChildrenTitle': 'Children',
      'privacyPolicyChildrenBody':
          'Bismillah is not designed as a children\'s product and does not '
          'run any children-specific data collection. No age-based profiling '
          'is performed.',
      'privacyPolicyControlTitle': 'You stay in control',
      'privacyPolicyControlBody':
          'From inside the app you can reset your learning data or all your '
          'local data, and delete your Assistant history. Clearing app data '
          'from device settings has the same effect.',
      'privacyPolicyContactTitle': 'Contact',
      'privacyPolicyContactBody':
          'You can write to us for questions, feedback or privacy requests.',
      // Support / feedback (ALPHA-R3A)
      'supportContactAction': 'Contact support',
      'supportContactRow': 'Support and feedback',
      'supportContactRowSubtitle': 'Write to us by e-mail',
      'supportEmailUnavailable':
          'No e-mail app could be opened. You can write to us at:',
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
      // TASK 095D: see the Turkish note — states Bismillah's own limit, with
      // no exclusivity claim about who may give religious guidance.
      'assistantOfficialFatwaRequired':
          'This question calls for a religious ruling. Bismillah does not '
          'issue a definite fatwa on such matters. For a direct and reliable '
          'answer, consult an official fatwa source or a qualified religious '
          'scholar.',
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
          'The source below provides general information about the topic; it '
          'does not directly answer this ruling question.',
      // TASK 095D
      'assistantLandingCanTitle': 'What it can do',
      'assistantLandingCan1':
          "Searches your question in Bismillah's published, source-verified "
          'content.',
      'assistantLandingCan2':
          'Shows the answer together with the source details and the exact '
          'page or section.',
      'assistantLandingCan3':
          'Links to the related Learn content so you can keep reading there.',
      'assistantLandingLimitTitle': 'Its limits',
      'assistantLandingLocalOnly':
          'Questions are handled on this device; they are not sent to an '
          'external AI service.',
      'assistantBadgeOfficialFatwa': 'Official fatwa required',
      'assistantNextStepGuidance':
          'Instead, you can read the general information on the topic or open '
          'the official question page.',
      'assistantNextStepNoSource':
          'You can rephrase the question or look at the related topics below.',
      'assistantSourceLinkUnavailable':
          'No openable address is recorded for this source.',
      'assistantRetrievalFailedTitle': 'The search could not be completed',
      'assistantRetrievalFailedBody':
          'Searching the verified content could not be completed right now. '
          'No answer was produced; you can try again.',
      'assistantRetry': 'Try again',
      'assistantClearFailed':
          'The chat history could not be deleted. You can try again.',
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
      // قائمة مهام اليوم (TASK 083)
      'todayPlanTitle': 'مهام اليوم',
      'todayPlanSelectedDay': 'اليوم المحدد: {day}',
      'todayPlanProgress': 'اكتملت {completed}/{total}',
      'todayPlanLoading': 'يجري تحضير مهام اليوم',
      'todayPlanEmptyTitle': 'لا توجد خطة لهذا اليوم بعد.',
      'todayPlanEmptyBody': 'ستظهر مهامك هنا عندما تصبح خطتك اليومية جاهزة.',
      'todayPlanNoItems': 'لم تُضَف مهام إلى هذا اليوم.',
      'todayPlanCorruptTitle': 'تعذّرت قراءة خطة هذا اليوم.',
      'todayPlanCorruptBody':
          'تعذّر فتح البيانات المحفوظة. لم يُحذف شيء؛ وسيظهر هذا اليوم مجدداً '
          'عند تحضير خطته.',
      'todayPlanFailureBody':
          'تعذّر فتح مهام اليوم الآن. يمكنك المحاولة مرة أخرى.',
      'todayPlanItemCompleted': 'تم التحديد',
      'todayPlanItemPending': 'لم يُحدَّد بعد',
      'todayPlanItemPrayerTrack': 'متابعة الصلاة اليومية',
      'todayPlanItemPrayerOnTime': 'متابعة أوقات الصلاة',
      'todayPlanItemQuranContinue': 'واصل عادتك مع القرآن',
      'todayPlanItemPrayerFallback': 'مهمة صلاة',
      'todayPlanItemQuranFallback': 'مهمة قرآن',
      'todayPlanItemLessonFallback': 'مهمة تعلّم',
      'todayPlanItemDhikrFallback': 'مهمة ذكر',
      'todayPlanItemDuaFallback': 'مهمة دعاء',
      'todayPlanItemReflectionFallback': 'مهمة تأمل',
      // ملاحظة العودة الهادئة (TASK 084)
      'todayRecoveryTitle': 'يوم جديد',
      'todayRecoveryGentleBody': 'واصل بخطوة صغيرة عندما تكون مستعداً.',
      'todayRecoveryExtendedBody':
          'سعيدون بعودتك. تكفيك اليوم خطوة صغيرة واحدة.',
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
      'prayerTimesMethodLabel': 'طريقة الحساب',
      'prayerTimesSunrise': 'الشروق',
      'prayerMethodEntryTitle': 'طريقة الحساب',
      'prayerMethodEntrySubtitle': 'اختر الطريقة التي تُحسب بها أوقات الصلاة.',
      'prayerMethodTitle': 'طريقة الحساب',
      'prayerMethodIntro':
          'يمكن استخراج أوقات الصلاة بعدّة طرق حساب معتمدة، ومن الطبيعي أن '
          'يكون بينها فرق دقائق قليلة. يمكنك اختيار الطريقة الشائعة في '
          'منطقتك.',
      'prayerMethodNotEndorsement':
          'اسم الطريقة يشير إلى الجهة التي نشرت هذه المعاملات، ولا يعني أنّ '
          'تلك الجهة تعتمد هذا التطبيق أو توفّر هذه الأوقات. تُحسب الأوقات '
          'على جهازك ولا تُغني عن التقويم الرسمي.',
      'prayerMethodCurrentLabel': 'المستخدمة حالياً',
      'prayerMethodSelected': 'مختارة',
      'prayerMethodAdjustmentsNote': 'مع تعديلات الدقائق الخاصة بالطريقة',
      'prayerMethodAngles': 'الفجر {fajr}° · العشاء {isha}°',
      'prayerMethodInterval':
          'الفجر {fajr}° · العشاء بعد المغرب بـ {minutes} دقيقة',
      'prayerMethodConfirmTitle': 'هل تريد تغيير الطريقة؟',
      'prayerMethodConfirmBody':
          'سيتم التحويل إلى «{method}». ستُحسب أوقات الصلاة من جديد، وسيُعاد '
          'ضبط تذكيرات الصلاة المفعّلة على الأوقات الجديدة. تبقى صلواتك '
          'المسجّلة وسجلّك دون تغيير.',
      'prayerMethodConfirmApply': 'تغيير',
      'prayerMethodConfirmCancel': 'إلغاء',
      'prayerMethodApplying': 'جارٍ التطبيق…',
      'prayerMethodChanged': 'تم تحديث الطريقة إلى «{method}».',
      'prayerMethodRemindersNotUpdated':
          'تم حفظ الطريقة وإعادة حساب الأوقات، لكن تعذّر إعادة ضبط التذكيرات '
          'على الأوقات الجديدة الآن.',
      'prayerMethodRetryReminders': 'إعادة ضبط التذكيرات',
      'prayerMethodSaveFailed': 'تعذّر حفظ الطريقة. لم يتغيّر شيء.',
      'prayerMethodName.turkiyeDiyanet': 'تركيا',
      'prayerMethodName.muslimWorldLeague': 'رابطة العالم الإسلامي',
      'prayerMethodName.egyptian': 'الهيئة المصرية العامة للمساحة',
      'prayerMethodName.karachi': 'جامعة العلوم الإسلامية بكراتشي',
      'prayerMethodName.northAmerica': 'أمريكا الشمالية (ISNA)',
      'prayerMethodName.ummAlQura': 'جامعة أم القرى، مكة',
      'prayerMethodName.dubai': 'دبي',
      'prayerMethodName.qatar': 'قطر',
      'prayerMethodName.kuwait': 'الكويت',
      'prayerMethodName.gulfRegion': 'منطقة الخليج',
      'prayerMethodName.moonsightingCommittee': 'لجنة رؤية الهلال',
      'prayerMethodName.singapore': 'سنغافورة',
      'prayerMethodName.indonesian': 'إندونيسيا (كيمناغ)',
      'prayerMethodName.morocco': 'المغرب',
      'prayerMethodName.algerian': 'وزارة الشؤون الدينية الجزائرية',
      'prayerMethodName.tunisia': 'وزارة الشؤون الدينية التونسية',
      'prayerMethodName.jordan': 'الأردن',
      'prayerMethodName.france': 'فرنسا (UOIF)',
      'prayerMethodName.portugal': 'البرتغال (الجالية الإسلامية بلشبونة)',
      'prayerMethodName.russia': 'الإدارة الدينية لمسلمي روسيا',
      'prayerTimesUseLocation': 'استخدم الموقع',
      'prayerTimesLocationInvite': 'استخدم موقعك لعرض الأوقات وفق مكانك.',
      'prayerTimesLocationDeniedForever':
          'الموقع متوقّف. فعّله من الإعدادات لعرض الأوقات.',
      'prayerTimesOpenSettings': 'افتح الإعدادات',
      'prayerTimesUnavailable':
          'تعذّر الحصول على الموقع الآن — يمكنك المحاولة لاحقاً.',
      'prayerTimesApproximate': 'بحسب موقع تقريبي',
      'qiblaTitle': 'القبلة',
      'qiblaEntryTitle': 'اتجاه القبلة',
      'qiblaEntrySubtitle': 'نظرة هادئة إلى اتجاه الكعبة من مكانك.',
      'qiblaBearingLabel': 'زاوية القبلة من الشمال',
      'qiblaDegrees': '{degrees}°',
      'qiblaAligned': 'الهاتف موجَّه نحو القبلة.',
      'qiblaTurnHint': 'أدر الهاتف ببطء.',
      'qiblaCompassWaiting': 'في انتظار قراءة البوصلة.',
      'qiblaCompassInterrupted': 'قراءة الاتجاه غير متاحة الآن.',
      'qiblaCompassUnsupported': 'لم يُعثر على مستشعر بوصلة في هذا الجهاز.',
      'qiblaStaticBearingNote': 'تُعرض زاوية القبلة المقيسة من الشمال فقط.',
      'qiblaLowConfidence': 'تبدو القراءة غير مستقرة.',
      'qiblaLocationInvite':
          'نحتاج إلى موقعك لحساب اتجاه القبلة. يُستخدم الموقع لهذا الحساب '
          'فقط ولا يُحفَظ.',
      'qiblaUseLocation': 'استخدم الموقع',
      'qiblaLocationDeniedForever':
          'إذن الموقع مغلق. إذا فعّلته من الإعدادات يمكننا عرض اتجاه القبلة.',
      'qiblaLocationServiceDisabled':
          'خدمة الموقع في جهازك مغلقة. يمكنك المحاولة مرة أخرى بعد تفعيلها.',
      'qiblaLocationUnavailable':
          'تعذّر الحصول على الموقع الآن — يمكنك المحاولة مرة أخرى متى شئت.',
      'qiblaCalculationError': 'تعذّر حساب اتجاه القبلة لهذا الموقع.',
      'qiblaApproximateLocationNote': 'بحسب موقع تقريبي',
      'qiblaGuidanceTitle': 'لقراءة أفضل',
      'qiblaGuidanceFlat': 'أمسك الهاتف مستوياً وموازياً للأرض.',
      'qiblaGuidanceMetal': 'ابتعد قليلاً عن الأجسام المعدنية والمغناطيسية.',
      'qiblaGuidanceCalibrate':
          'إذا كانت القراءة غير مستقرة فعايِر البوصلة بتحريك الهاتف على '
          'شكل رقم ثمانية.',
      'qiblaHonestyNote':
          'يعطي مستشعر الهاتف اتجاهاً تقريبياً. هذا المؤشر ليس قياساً دقيقاً '
          'وليس حكماً شرعياً.',
      'qiblaSemanticsBearing': 'اتجاه القبلة {degrees} درجة من الشمال.',
      'qiblaCardinalNorth': 'ش',
      'qiblaCardinalEast': 'ق',
      'qiblaCardinalSouth': 'ج',
      'qiblaCardinalWest': 'غ',
      'qiblaKaabaSemantics': 'الكعبة في مركز القرص: هدف الاتجاه.',
      'reminderCardTitle': 'تذكيرات الصلاة',
      'reminderEnable': 'تفعيل التذكيرات',
      'reminderDisable': 'إيقاف التذكيرات',
      'reminderEnabledState': 'التذكيرات مفعّلة',
      'reminderInexactNote': 'قد يتغيّر وقت التذكير بضع دقائق حسب جهازك.',
      'reminderPermissionNeeded': 'يلزم إذن الإشعارات للتذكيرات.',
      'reminderLocationNeeded': 'يلزم تحديد الموقع لحساب الأوقات.',
      'reminderExactTitle': 'لتصل التذكيرات في وقتها تمامًا',
      'reminderExactBody':
          'يطلب أندرويد إذنًا منفصلًا باسم «المنبّهات والتذكيرات» حتى تظهر تذكيرات '
          'الصلاة في وقتها تمامًا. إن لم تسمح به، تستمر التذكيرات في العمل في وقت '
          'تقريبي.',
      'reminderExactOpenSettings': 'فتح شاشة الإذن',
      'reminderExactNotNow': 'ليس الآن',
      'reminderExactGranted': 'تم تفعيل التذكيرات في وقتها.',
      'reminderExactNotGranted': 'ستستمر التذكيرات في العمل في وقت تقريبي.',
      'reminderExactAction': 'تذكيرات في وقتها',
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
      'profilePlanSection': 'خطتك لثلاثين يوماً',
      'profilePlanTypeLabel': 'نمط خطتك',
      'profilePlanNone':
          'لا توجد خطة نشطة الآن. عند وجود خطة لليوم سيظهر الملخّص هنا.',
      'profilePlanSummaryUnavailable': 'تعذّر حساب ملخّص الخطة الآن.',
      'profilePlanDayOf': 'اليوم {current} من {total}',
      'profilePlanTasksDone': 'اكتملت {done} من {total} مهمة',
      'profilePlanDaysCompleted': 'اكتملت {count} أيام بالكامل',
      'profilePlanRecentTitle': 'التقدّم الأخير',
      'profilePlanRecentWindow': 'آخر {days} أيام',
      'profilePlanLoadIssue': 'تعذّر فتح ملفك الشخصي الآن.',
      'profilePlanEditPreferences': 'تعديل التفضيلات',
      'profilePlanRegenerateAction': 'أعد بناء الخطة وفق تفضيلاتك',
      'profilePlanRegenerateTitle': 'هل نعيد بناء الخطة؟',
      'profilePlanRegenerateBody':
          'ستُعاد خطة الثلاثين يوماً ابتداءً من اليوم وفق تفضيلاتك '
          'المحفوظة. ولن تُمسّ الأيام الماضية. تُحفَظ علامات الإنجاز '
          'للمهام التي تبقى في الخطة الجديدة، أما المهام التي لم تعد '
          'ضمن تفضيلاتك فتُزال مع علاماتها.',
      'profilePlanRegenerateConfirm': 'أعد بناء الخطة',
      'profilePlanRegenerateSuccess': 'أُعيد بناء الخطة وفق تفضيلاتك.',
      'profilePlanRegenerateDropped':
          'لم تُنقَل علامات {count} مهمة مكتملة لأنها ليست في الخطة الجديدة.',
      'profilePlanRegenerateFailed':
          'تعذّرت إعادة بناء الخطة — بقيت خطتك كما هي.',
      'profilePlanRegenerateIncomplete': 'أكمل تفضيلاتك أولاً.',
      'profileLocalDataTitle': 'بياناتك على هذا الجهاز',
      'profileLocalDataBody':
          'تُحفَظ تفضيلاتك وخطتك وتقدّمك على هذا الجهاز فقط. النسخ '
          'الاحتياطي السحابي ومزامنة الحساب غير مفعّلين حالياً؛ وإزالة '
          'التطبيق أو مسح بياناته يحذف تقدّمك المحلي.',
      'profilePlanTypeBeginner': 'بداية',
      'profilePlanTypeReturning': 'استئناف',
      'profilePlanTypePrayerFocused': 'التركيز على الصلاة',
      'profilePlanTypeQuranFocused': 'التركيز على القرآن',
      'profilePlanTypeDhikrFocused': 'التركيز على الذكر',
      'profilePlanTypeLearningFocused': 'التركيز على التعلّم',
      'profilePlanTypeAdvanced': 'ترسيخ',
      'profilePlanTypeLowTime': 'وقت محدود',
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
      'quranFollowRecitation': 'تابع التلاوة',
      'quranSemanticsPlayingVerse': 'الآية قيد التشغيل الآن',
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
      'sourcesUnavailable':
          'تعذّر تحميل بيانات المصادر الآن. يرجى المحاولة لاحقاً.',
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
      // ملخّص الخصوصية والسياسة الكاملة (ALPHA-R3A)
      'privacyLocalPlan': 'خطة الثلاثين يومًا وإتمام المهامّ',
      'privacyLocalAssistant': 'سجل محادثة المساعد (آخر ٢٠ رسالة)',
      'privacyAssistantTitle': 'المساعد',
      'privacyAssistantOnDevice':
          'تُعالَج الأسئلة على هذا الجهاز ولا تُرسل إلى خدمة ذكاء اصطناعي '
          'خارجية',
      'privacyAssistantSensitive':
          'أسئلة الحكم والحالات الشخصية وأحكام العبادة لا تُحفظ على الجهاز',
      'privacyPermissionsTitle': 'الأذونات',
      'privacyPermissionLocation':
          'الموقع (أثناء الاستخدام فقط): حساب أوقات الصلاة واتجاه القبلة',
      'privacyPermissionNotifications': 'الإشعارات: لتذكيرات الصلاة',
      'privacyPermissionExactAlarm':
          'المنبّه الدقيق: بدونه يتحوّل التطبيق إلى جدولة تقريبية',
      'privacyNetworkFirebase': 'مصادقة Firebase المجهولة (خدمات Google)',
      'privacyNoCloudTitle': 'لا يوجد نسخ احتياطي سحابي',
      'privacyNoCloudBody':
          'لا يوجد نسخ احتياطي سحابي فعّال ولا مزامنة حساب. وإذا أزلت '
          'التطبيق أو مسحت بياناته يُحذف تقدّمك المحلي نهائيًا.',
      'privacyOpenFullPolicy': 'سياسة الخصوصية كاملةً',
      'privacyOpenWebPolicy': 'افتح سياسة الخصوصية على الويب',
      'privacyWebPolicyUnavailable':
          'تعذّر فتح المتصفّح. عنوان السياسة على الويب:',
      'privacyPolicyTitle': 'سياسة الخصوصية',
      'privacyPolicyUpdated': 'آخر تحديث: ٧ أغسطس ٢٠٢٦ · ألفا لأندرويد',
      'privacyPolicySummaryTitle': 'باختصار',
      'privacyPolicySummaryBody':
          'يعمل Bismillah محليًا أولًا: تُحفظ خطتك وتقدّمك وتفضيلاتك وسجل '
          'المساعد بصورة أساسية على جهازك، ولا يلزم حساب. وهذا لا يعني أنّ '
          'أيّ بيانات لا تغادر الجهاز أبدًا؛ فكلّ موضع تُستخدم فيه الشبكة '
          'مذكور أدناه.',
      'privacyPolicyStoredTitle': 'ما يُحفظ على جهازك',
      'privacyPolicyStoredBody':
          'تفضيلات التهيئة وملفّ الخطة المشتقّ منها، وسجلات خطة الثلاثين '
          'يومًا وإتمام المهامّ، وسجل متابعة الصلاة، وموضع القراءة في القرآن '
          'والإشارات المرجعية، وسجلات التعلّم، وتفضيلات اللغة وطريقة الحساب، '
          'وسجل محادثة المساعد (عشرون رسالة كحدّ أقصى).',
      'privacyPolicyAssistantTitle': 'المساعد والأسئلة الحسّاسة',
      'privacyPolicyAssistantBody':
          'يعمل المساعد على جهازك بالكامل، ولا تُرسل أسئلتك إلى أيّ خدمة '
          'ذكاء اصطناعي توليدي خارجية. أمّا الأسئلة الحسّاسة — أسئلة الحكم '
          'والحالات الشخصية وأحكام العبادة — وإجاباتها فلا تُحفظ على الجهاز. '
          'ويجري هذا التمييز بمطابقة كلمات مفتاحية، ولذلك قد يقع أحيانًا '
          'سؤال غير حسّاس ضمن المجموعة التي لا تُحفظ. ويمكنك حذف السجل من '
          'داخل التطبيق في أيّ وقت.',
      'privacyPolicyCloudTitle': 'النسخ الاحتياطي السحابي والحسابات',
      'privacyPolicyCloudBody':
          'لا يوجد حاليًا نسخ احتياطي سحابي فعّال ولا مزامنة حساب، ولا تُنقل '
          'بياناتك إلى جهاز آخر. والنتيجة المباشرة: إذا أزلت التطبيق أو مسحت '
          'بياناته يُحذف تقدّمك المحلي نهائيًا.',
      'privacyPolicyPermissionsTitle': 'الأذونات',
      'privacyPolicyPermissionsBody':
          'يُستخدم الموقع أثناء فتح التطبيق فقط، ولحساب أوقات الصلاة واتجاه '
          'القبلة على جهازك فقط؛ ولا يُرسل إلى خادم ولا يُجمع في الخلفية. '
          'وإذن الإشعارات لتذكيرات الصلاة، وهي تُجدوَل على الجهاز. وبدون إذن '
          'المنبّه الدقيق يتحوّل التطبيق إلى جدولة تقريبية ويوضّح لك ذلك '
          'صراحةً.',
      'privacyPolicyNetworkTitle': 'مواضع استخدام الشبكة',
      'privacyPolicyNetworkBody':
          'يُبثّ صوت القرآن من MP3Quran.net، وعند تشغيل تلاوة يصل عنوان IP '
          'الخاصّ بجهازك تقنيًا إلى تلك الخدمة. وعند فتح روابط Tanzil أو '
          'QuranEnc أو روابط المصادر الرسمية يتّصل متصفّح النظام بذلك الموقع، '
          'وتخضع تلك المواقع لسياسات الخصوصية الخاصّة بها. ويبدأ التطبيق '
          'مصادقة Firebase المجهولة، وقد يتّصل الجهاز خلالها بخدمات Google '
          'ويُنشأ معرّف مجهول غير مرتبط باسمك أو بريدك. ويحتوي التطبيق على '
          'إعدادات عميل Firebase القياسية.',
      'privacyPolicyNoTrackingTitle': 'الإعلانات والقياس والمدفوعات',
      'privacyPolicyNoTrackingBody':
          'لا توجد أيّ حزمة إعلانات مدمجة. ولا يوجد خادم تحليلات أو تقارير '
          'أعطال فعّال. ولا يوجد نظام دفع أو اشتراك فعّال، ولا يمكن إجراء أيّ '
          'شراء في نسخة ألفا.',
      'privacyPolicyChildrenTitle': 'الأطفال',
      'privacyPolicyChildrenBody':
          'لم يُصمَّم Bismillah منتجًا موجَّهًا للأطفال، ولا يُجري أيّ جمع '
          'بيانات خاصّ بالأطفال. ولا تُجرى أيّ تصنيفات قائمة على العمر.',
      'privacyPolicyControlTitle': 'التحكّم بيدك',
      'privacyPolicyControlBody':
          'يمكنك من داخل التطبيق إعادة تعيين بيانات التعلّم أو جميع بياناتك '
          'المحلية، وحذف سجل المساعد. ومسح بيانات التطبيق من إعدادات الجهاز '
          'يؤدّي إلى النتيجة نفسها.',
      'privacyPolicyContactTitle': 'التواصل',
      'privacyPolicyContactBody':
          'يمكنك مراسلتنا للأسئلة أو الملاحظات أو طلبات الخصوصية.',
      // الدعم والملاحظات (ALPHA-R3A)
      'supportContactAction': 'تواصل مع الدعم',
      'supportContactRow': 'الدعم والملاحظات',
      'supportContactRowSubtitle': 'راسِلنا بالبريد الإلكتروني',
      'supportEmailUnavailable': 'تعذّر فتح تطبيق البريد. يمكنك مراسلتنا على:',
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
      // Anlam korunur ("namaza nasıl hazırlanırım"); yalnız retrieval'ın
      // gerçekten döndürdüğü ifadeye yaklaştırıldı — TASK 095D, önerilen
      // soruların kaynaksız duruma düşmemesi kuralı.
      'assistantSuggested4': 'كيف يكون الاستعداد للصلاة؟',
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
      // TASK 095D: bkz. Türkçe not — dışlayıcılık iddiası yoktur.
      'assistantOfficialFatwaRequired':
          'هذا السؤال يتطلّب حكماً شرعياً. ولا يُصدر تطبيق بِسم الله فتوى '
          'قاطعة في مثل هذه المسائل. وللحصول على جواب مباشر وموثوق، يُرجى '
          'الرجوع إلى مصدر فتوى رسمي أو إلى عالم دين مؤهَّل.',
      'assistantQualifiedGuidance':
          'هذا يعتمد على ظروفك الشخصية. للحصول على حكم قاطع يُفضَّل مراجعة '
          'جهة مختصّة معتمدة.',
      'assistantGeneralInfoNotRuling':
          'هذه معلومة عامة؛ ولا تُطبّق حكماً قاطعاً على حالتك الخاصة.',
      'assistantPersonalCaseGeneralInfo':
          'المعلومة العامة أدناه تُلقي الضوء على الموضوع، لكنها لا تتضمّن '
          'حكماً لحالتك الخاصة.',
      'assistantSourceNotDirectlyAddressing':
          'المصدر أدناه يقدّم معلومات عامة عن الموضوع، ولا يجيب مباشرةً عن '
          'سؤال الحكم هذا.',
      // TASK 095D
      'assistantLandingCanTitle': 'ماذا يستطيع أن يفعل؟',
      'assistantLandingCan1':
          'يبحث عن سؤالك في محتوى بِسم الله المنشور والمُتحقَّق من مصادره.',
      'assistantLandingCan2':
          'يعرض الجواب مع بيانات المصدر والصفحة أو القسم بدقّة.',
      'assistantLandingCan3':
          'يربطك بمحتوى التعلّم ذي الصلة لمتابعة القراءة هناك.',
      'assistantLandingLimitTitle': 'حدوده',
      'assistantLandingLocalOnly':
          'تُعالَج الأسئلة على هذا الجهاز، ولا تُرسَل إلى خدمة ذكاء اصطناعي '
          'خارجية.',
      'assistantBadgeOfficialFatwa': 'يلزم فتوى رسمية',
      'assistantNextStepGuidance':
          'بدلاً من ذلك يمكنك قراءة المعلومة العامة عن الموضوع أو فتح صفحة '
          'السؤال الرسمية.',
      'assistantNextStepNoSource':
          'يمكنك إعادة صياغة السؤال أو الاطّلاع على المواضيع ذات الصلة أدناه.',
      'assistantSourceLinkUnavailable':
          'لا يوجد عنوان قابل للفتح مسجَّل لهذا المصدر.',
      'assistantRetrievalFailedTitle': 'تعذّر إكمال البحث',
      'assistantRetrievalFailedBody':
          'تعذّر إكمال البحث في المحتوى المُتحقَّق منه الآن. لم يُنشأ أي '
          'جواب، ويمكنك المحاولة مرة أخرى.',
      'assistantRetry': 'حاول مرة أخرى',
      'assistantClearFailed':
          'تعذّر حذف سجلّ المحادثة. يمكنك المحاولة مرة أخرى.',
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
