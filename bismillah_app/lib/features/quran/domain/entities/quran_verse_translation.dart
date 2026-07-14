/// Tek ayetin Türkçe meali (TASK 040) — paket bağımsız, immutable.
/// Meal metni AYNEN taşınır: yeniden yazma/özetleme/düzeltme ve AI
/// fallback YOK.
final class QuranVerseTranslation {
  QuranVerseTranslation({
    required this.chapterId,
    required this.verseNumber,
    required this.verseKey,
    required this.translationText,
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
    if (translationText.trim().isEmpty) {
      throw ArgumentError.value(
        translationText,
        'translationText',
        'boş olamaz',
      );
    }
  }

  final int chapterId;
  final int verseNumber;
  final String verseKey;
  final String translationText;
}

/// Bir surenin tam meali (TASK 040) — kaynak künyesiyle taşınır
/// ("no source, no render").
final class QuranChapterTranslation {
  QuranChapterTranslation({
    required this.chapterId,
    required this.source,
    required this.verses,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    if (source.trim().isEmpty) {
      throw ArgumentError.value(source, 'source', 'boş olamaz');
    }
    final seenKeys = <String>{};
    for (var i = 0; i < verses.length; i++) {
      final verse = verses[i];
      if (verse.chapterId != chapterId) {
        throw ArgumentError.value(
          verse.verseKey,
          'verses',
          'farklı sureye ait ayet',
        );
      }
      if (!seenKeys.add(verse.verseKey)) {
        throw ArgumentError.value(
          verse.verseKey,
          'verses',
          'duplicate verseKey',
        );
      }
      if (i > 0 && verses[i - 1].verseNumber >= verse.verseNumber) {
        throw ArgumentError.value(
          verse.verseKey,
          'verses',
          'verseNumber sırasıyla tutulmalı',
        );
      }
    }
  }

  final int chapterId;
  final String source;
  final List<QuranVerseTranslation> verses;
}
