import 'dart:ui';

/// Desteklenen diller (04_ONBOARDING_FLOW §17): TR/EN/AR ilk günden.
enum SupportedLocale {
  tr(Locale('tr'), 'Türkçe'),
  en(Locale('en'), 'English'),
  ar(Locale('ar'), 'العربية');

  const SupportedLocale(this.locale, this.nativeName);

  final Locale locale;

  /// Dilin KENDİ dilindeki adı (TASK 053 §5). Çevrilmez: kullanıcı arayüz
  /// dili ne olursa olsun kendi dilini tanıyabilmelidir.
  final String nativeName;

  bool get isRtl => this == SupportedLocale.ar;

  static List<Locale> get locales =>
      SupportedLocale.values.map((l) => l.locale).toList(growable: false);

  /// Kalıcı depoda saklanan stabil anahtar (enum `name` ile aynı).
  static SupportedLocale? fromStorageKey(Object? raw) =>
      SupportedLocale.values.asNameMap()[raw];

  /// Cihaz dilinden güvenli eşleme; desteklenmiyorsa Türkçe (TASK 053 §4).
  static SupportedLocale fromLocale(Locale? locale) {
    return switch (locale?.languageCode) {
      'en' => SupportedLocale.en,
      'ar' => SupportedLocale.ar,
      _ => SupportedLocale.tr,
    };
  }

  /// Cihazın tercih listesinden DESTEKLENEN ilk dili seçer; hiçbiri
  /// desteklenmiyorsa Türkçe'ye düşer (TASK 053 §4). Boş liste güvenlidir.
  static SupportedLocale fromSystemLocales(List<Locale> systemLocales) {
    for (final locale in systemLocales) {
      final match = switch (locale.languageCode) {
        'tr' => SupportedLocale.tr,
        'en' => SupportedLocale.en,
        'ar' => SupportedLocale.ar,
        _ => null,
      };
      if (match != null) {
        return match;
      }
    }
    return SupportedLocale.tr;
  }
}
