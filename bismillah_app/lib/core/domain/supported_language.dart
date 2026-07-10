import 'package:bismillah_app/core/value_objects/language_code.dart';

/// Ürünün desteklediği diller (04_ONBOARDING §14 `language`): TR/EN/AR.
///
/// UI locale seçimi `SupportedLocale` (app katmanı) ile yapılır; bu enum
/// domain/veri katmanının dil gösterimidir.
enum SupportedLanguage {
  tr,
  en,
  ar;

  LanguageCode get code => LanguageCode(name);

  /// Bilinmeyen/desteklenmeyen kod İngilizce'ye düşer (güvenli varsayılan).
  static SupportedLanguage fromCode(String code) {
    return switch (code) {
      'tr' => SupportedLanguage.tr,
      'ar' => SupportedLanguage.ar,
      _ => SupportedLanguage.en,
    };
  }
}
