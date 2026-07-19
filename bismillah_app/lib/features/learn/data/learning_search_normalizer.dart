/// Offline arama normalizasyonu (TASK 056 §8).
///
/// Yeni bir arama paketi EKLENMEZ: Türkçe ve Arapça için gereken davranış
/// küçük ve deterministik bir normalize fonksiyonuyla sağlanır.
abstract final class LearningSearchNormalizer {
  /// Türkçe harf eşlemeleri: kullanıcı "gusul" yazınca "gusül" bulunmalı,
  /// "kuran" yazınca "Kur'an" bulunmalıdır.
  ///
  /// `İ` ve `I` küçültme davranışı Türkçede özeldir; bu yüzden küçültme
  /// ELLE yapılır (Dart'ın `toLowerCase()` çağrısı `I` → `i` verir ve
  /// Türkçe `ı` ayrımını kaybettirir).
  static const Map<String, String> _turkishFolding = {
    'ı': 'i',
    'İ': 'i',
    'I': 'i',
    'ğ': 'g',
    'Ğ': 'g',
    'ü': 'u',
    'Ü': 'u',
    'ş': 's',
    'Ş': 's',
    'ö': 'o',
    'Ö': 'o',
    'ç': 'c',
    'Ç': 'c',
    'â': 'a',
    'Â': 'a',
    'î': 'i',
    'Î': 'i',
    'û': 'u',
    'Û': 'u',
  };

  /// Arapça normalizasyonu: hareke/tatvil kaldırılır, elif ve ta-marbuta
  /// varyantları sadeleşir — "القرآن" ve "القران" aynı sonuca ulaşır.
  static const Map<String, String> _arabicFolding = {
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ى': 'ي',
    'ة': 'ه',
    'ؤ': 'و',
    'ئ': 'ي',
  };

  /// Arapça hareke ve tatvil aralığı (kaldırılır).
  static final RegExp _arabicDiacritics = RegExp(
    r'[ؐ-ًؚ-ٰٟۖ-ۭـ]',
  );

  /// Alfanümerik olmayan her şeyi tek boşluğa indirger. Kesme işareti
  /// böylece kaybolur: "kur'an" → "kur an" ve "kuran" ile eşleşebilmesi
  /// için ayrıca boşluklar da kaldırılır.
  static final RegExp _nonAlphanumeric = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// Arama karşılaştırması için metni normalize eder.
  ///
  /// Sonuç boşluksuzdur: "kur'an" ve "kuran" aynı anahtara indirgenir,
  /// böylece kullanıcı hangi yazımı kullanırsa kullansın içeriği bulur.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final folded = _turkishFolding[char] ?? _arabicFolding[char] ?? char;
      buffer.write(folded);
    }
    return buffer
        .toString()
        .toLowerCase()
        .replaceAll(_arabicDiacritics, '')
        .replaceAll(_nonAlphanumeric, '');
  }

  /// Sorgunun hedef metinlerden herhangi birinde geçip geçmediği.
  static bool matches(String query, Iterable<String> haystacks) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) {
      return false;
    }
    for (final haystack in haystacks) {
      if (normalize(haystack).contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }
}
