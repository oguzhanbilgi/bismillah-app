/// Son okuma konumu (TASK 036) — paket bağımsız, immutable.
///
/// Yalnız sure + kaydırma konumu saklanır; ayet numarası TAKİP EDİLMEZ
/// (sahte hassasiyet gösterilmez). Günlük ilerleme/yer imi ayrı görevler.
final class QuranReadingPosition {
  QuranReadingPosition({
    required this.chapterId,
    required this.scrollOffset,
    required this.updatedAtUtc,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    if (scrollOffset < 0) {
      throw ArgumentError.value(
        scrollOffset,
        'scrollOffset',
        'negatif olamaz',
      );
    }
    if (!updatedAtUtc.isUtc) {
      throw ArgumentError.value(updatedAtUtc, 'updatedAtUtc', 'UTC olmalı');
    }
  }

  final int chapterId;
  final double scrollOffset;
  final DateTime updatedAtUtc;
}
