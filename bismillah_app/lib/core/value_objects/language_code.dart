/// Dil ve locale kodu değer nesneleri.
///
/// İçerik belgeleri dil alanını serbest string değil bu tiplerle taşır
/// (10_DATA_MODEL §20 zarf alanı `language`). Desteklenen ürün dilleri
/// ayrıca `SupportedLanguage` enum'undadır — bu tipler içerik/veri
/// katmanının genel ISO gösterimidir.
library;

final class LanguageCode {
  LanguageCode(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'LanguageCode iki küçük harf olmalı (ISO 639-1, ör. "tr")',
      );
    }
  }

  static final RegExp _pattern = RegExp(r'^[a-z]{2}$');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is LanguageCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// `tr` veya `tr-TR` biçiminde locale kodu.
final class LocaleCode {
  LocaleCode(this.value) {
    if (!_pattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'LocaleCode "tr" veya "tr-TR" biçiminde olmalı',
      );
    }
  }

  static final RegExp _pattern = RegExp(r'^[a-z]{2}(-[A-Z]{2})?$');

  final String value;

  /// Yalnız dil bileşeni.
  LanguageCode get language => LanguageCode(value.substring(0, 2));

  @override
  bool operator ==(Object other) => other is LocaleCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
