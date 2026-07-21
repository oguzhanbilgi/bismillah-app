import 'package:bismillah_app/core/text/islamic_text_normalizer.dart';

/// Offline arama normalizasyonu (TASK 056 §8).
///
/// Gerçek mantık paylaşılan [IslamicTextNormalizer]'a taşınmıştır (TASK
/// 059 §7): Learn araması ve Bismillah Asistanı AYNI normalizasyonu
/// kullanır, kod kopyalanmaz. Bu sınıf geriye dönük uyumluluk için ince
/// bir delegasyon katmanıdır.
abstract final class LearningSearchNormalizer {
  /// Bkz. [IslamicTextNormalizer.normalize].
  static String normalize(String input) =>
      IslamicTextNormalizer.normalize(input);

  /// Bkz. [IslamicTextNormalizer.matches].
  static bool matches(String query, Iterable<String> haystacks) =>
      IslamicTextNormalizer.matches(query, haystacks);
}
