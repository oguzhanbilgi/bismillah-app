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
  String get premiumTitle => _t('premiumTitle');
  String get subscriptionSettingsTitle => _t('subscriptionSettingsTitle');

  // Ortak
  String get commonLoading => _t('commonLoading');
  String get commonRetry => _t('commonRetry');
  String get commonClose => _t('commonClose');

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
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'Abonelik',
      'commonLoading': 'Yükleniyor…',
      'commonRetry': 'Tekrar dene',
      'commonClose': 'Kapat',
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
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'Subscription',
      'commonLoading': 'Loading…',
      'commonRetry': 'Try again',
      'commonClose': 'Close',
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
      'premiumTitle': 'Bismillah+',
      'subscriptionSettingsTitle': 'الاشتراك',
      'commonLoading': 'جارٍ التحميل…',
      'commonRetry': 'حاول مجدداً',
      'commonClose': 'إغلاق',
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
