/// Offline Kur'an arama sonuç modelleri (TASK 048) — paket bağımsız.
///
/// Sonuç metinleri her zaman ORİJİNAL Tanzil Arapça ve QuranEnc Rowad
/// meal metnidir (snippet yalnız kelime sınırında kısaltılabilir);
/// normalize edilmiş değerler yalnız eşleştirmede kullanılır ve ASLA
/// gösterilmez. Sıralama deterministiktir — dini önem/popülerlik/AI
/// puanı YOKTUR.
enum QuranSearchMatchType {
  exactReference,
  exactChapterName,
  chapterNamePrefix,
  chapterNameContains,
  arabicVerse,
  turkishTranslation,
}

sealed class QuranSearchResult {
  const QuranSearchResult({required this.matchType});

  final QuranSearchMatchType matchType;
}

/// Sure sonucu (katalog kartı; dokunuş mevcut reader route'unu açar).
final class QuranChapterSearchResult extends QuranSearchResult {
  QuranChapterSearchResult({
    required this.chapterId,
    required this.chapterName,
    required this.arabicName,
    required this.verseCount,
    required super.matchType,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
  }

  final int chapterId;
  final String chapterName;
  final String arabicName;
  final int verseCount;
}

/// Ayet sonucu: orijinal metinlerden güvenli kısa snippet'ler taşır.
final class QuranVerseSearchResult extends QuranSearchResult {
  QuranVerseSearchResult({
    required this.chapterId,
    required this.chapterName,
    required this.verseNumber,
    required this.verseKey,
    required this.arabicSnippet,
    required this.translationSnippet,
    required super.matchType,
  }) {
    if (verseKey != '$chapterId:$verseNumber') {
      throw ArgumentError.value(verseKey, 'verseKey', 'referansla uyumsuz');
    }
  }

  final int chapterId;
  final String chapterName;
  final int verseNumber;
  final String verseKey;
  final String arabicSnippet;
  final String translationSnippet;
}

/// Bölümlenmiş arama yanıtı (sure + ayet sonuçları, sınırlar uygulanmış).
final class QuranSearchResponse {
  const QuranSearchResponse({this.chapters = const [], this.verses = const []});

  static const QuranSearchResponse empty = QuranSearchResponse();

  final List<QuranChapterSearchResult> chapters;
  final List<QuranVerseSearchResult> verses;

  int get totalCount => chapters.length + verses.length;

  bool get isEmpty => chapters.isEmpty && verses.isEmpty;
}

/// Çözülmüş ayet referansı hedefi (ör. `2:255` → sure 2, ayet 255).
final class QuranVerseSearchTarget {
  const QuranVerseSearchTarget({
    required this.chapterId,
    required this.verseNumber,
  });

  final int chapterId;
  final int verseNumber;
}
