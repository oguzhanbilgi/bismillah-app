import 'dart:ui';

/// Desteklenen diller (04_ONBOARDING_FLOW §17): TR/EN/AR ilk günden.
enum SupportedLocale {
  tr(Locale('tr')),
  en(Locale('en')),
  ar(Locale('ar'));

  const SupportedLocale(this.locale);

  final Locale locale;

  bool get isRtl => this == SupportedLocale.ar;

  static List<Locale> get locales =>
      SupportedLocale.values.map((l) => l.locale).toList(growable: false);

  /// Cihaz dilinden güvenli eşleme; desteklenmiyorsa İngilizce.
  static SupportedLocale fromLocale(Locale? locale) {
    return switch (locale?.languageCode) {
      'tr' => SupportedLocale.tr,
      'ar' => SupportedLocale.ar,
      _ => SupportedLocale.en,
    };
  }
}
