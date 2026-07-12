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

  // Today özeti (TASK 017 — ton: sakin, suçlayıcı dil YASAK)
  String get todayGreeting => _t('todayGreeting');
  String get todayGentleLine => _t('todayGentleLine');
  String get todayPrayerCardTitle => _t('todayPrayerCardTitle');
  String get todayGoToPrayers => _t('todayGoToPrayers');
  String get todayLocalNote => _t('todayLocalNote');
  String get todayLoadIssue => _t('todayLoadIssue');

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
      'todayGreeting': 'Bugünün ritmi',
      'todayGentleLine': 'Bugün için küçük adımlar.',
      'todayPrayerCardTitle': 'Bugünün namaz takibi',
      'todayPrayerProgress': '{completed}/{total} tamamlandı',
      'todayGoToPrayers': 'Namazlara git',
      'todayLocalNote': 'Kayıtların cihazında saklanır.',
      'todayLoadIssue': 'Özet şu an açılamadı.',
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
      'todayGreeting': "Today's rhythm",
      'todayGentleLine': 'Small steps for today.',
      'todayPrayerCardTitle': "Today's prayer tracking",
      'todayPrayerProgress': '{completed}/{total} completed',
      'todayGoToPrayers': 'Go to prayers',
      'todayLocalNote': 'Your records stay on your device.',
      'todayLoadIssue': 'The summary could not be opened right now.',
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
      'todayGreeting': 'إيقاع اليوم',
      'todayGentleLine': 'خطوات صغيرة لهذا اليوم.',
      'todayPrayerCardTitle': 'متابعة صلوات اليوم',
      'todayPrayerProgress': 'اكتملت {completed}/{total}',
      'todayGoToPrayers': 'اذهب إلى الصلوات',
      'todayLocalNote': 'تبقى سجلاتك على جهازك.',
      'todayLoadIssue': 'تعذّر فتح الملخّص الآن.',
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
