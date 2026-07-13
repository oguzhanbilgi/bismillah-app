/// Kaydedilmiş ayet (TASK 037) — paket bağımsız, immutable. Sıra/tarih
/// bu görevde taşınmaz; liste ekranı TASK 038'de.
final class QuranVerseBookmark {
  QuranVerseBookmark({
    required this.chapterId,
    required this.verseNumber,
    required this.verseKey,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    if (verseNumber < 1) {
      throw ArgumentError.value(verseNumber, 'verseNumber', 'pozitif olmalı');
    }
    if (verseKey != '$chapterId:$verseNumber') {
      throw ArgumentError.value(
        verseKey,
        'verseKey',
        'chapterId:verseNumber ile uyumlu olmalı',
      );
    }
  }

  /// "1:1" biçimli anahtardan üretir; bozuk/geçersiz anahtar `null`
  /// (saklanan veriyi okurken göz ardı etme yolu).
  static QuranVerseBookmark? tryParse(String verseKey) {
    final parts = verseKey.split(':');
    if (parts.length != 2) {
      return null;
    }
    final chapterId = int.tryParse(parts[0]);
    final verseNumber = int.tryParse(parts[1]);
    if (chapterId == null ||
        verseNumber == null ||
        chapterId < 1 ||
        chapterId > 114 ||
        verseNumber < 1) {
      return null;
    }
    return QuranVerseBookmark(
      chapterId: chapterId,
      verseNumber: verseNumber,
      verseKey: '$chapterId:$verseNumber',
    );
  }

  final int chapterId;
  final int verseNumber;

  /// "1:1" biçiminde stabil anahtar.
  final String verseKey;
}
