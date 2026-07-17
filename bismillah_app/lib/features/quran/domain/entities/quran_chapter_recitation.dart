/// Kıraat kaynağı (TASK 041/049) — paket bağımsız. MP3Quran timed-read
/// kaydından doğrulanarak üretilir; katalogda gösterilen ad API'den gelen
/// DOĞRULANMIŞ özel isimdir (localization'a kopyalanmaz).
final class QuranRecitationSource {
  QuranRecitationSource({
    required this.readId,
    required this.reciterName,
    required this.rewayaName,
    required this.folderUrl,
    required this.chapterCount,
    this.isDefault = false,
  }) {
    if (readId < 1) {
      throw ArgumentError.value(readId, 'readId', 'pozitif olmalı');
    }
    if (reciterName.trim().isEmpty) {
      throw ArgumentError.value(reciterName, 'reciterName', 'boş olamaz');
    }
    if (rewayaName.trim().isEmpty) {
      throw ArgumentError.value(rewayaName, 'rewayaName', 'boş olamaz');
    }
    if (!folderUrl.startsWith('https://')) {
      throw ArgumentError.value(folderUrl, 'folderUrl', 'HTTPS olmalı');
    }
    if (chapterCount < 114) {
      throw ArgumentError.value(
        chapterCount,
        'chapterCount',
        '114 sure desteklenmeli',
      );
    }
  }

  final int readId;
  final String reciterName;
  final String rewayaName;
  final String folderUrl;
  final int chapterCount;

  /// Uygulamanın her zaman mevcut fallback kaynağı mı (read 5).
  final bool isDefault;

  /// Eşitlik deterministik olarak readId üzerindendir (TASK 049).
  @override
  bool operator ==(Object other) =>
      other is QuranRecitationSource && other.readId == readId;

  @override
  int get hashCode => readId.hashCode;
}

/// Tek ayetin ses zaman aralığı (TASK 041).
final class QuranVerseTiming {
  QuranVerseTiming({
    required this.chapterId,
    required this.verseNumber,
    required this.start,
    required this.end,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    if (verseNumber < 1) {
      throw ArgumentError.value(verseNumber, 'verseNumber', 'pozitif olmalı');
    }
    if (start < Duration.zero) {
      throw ArgumentError.value(start, 'start', 'negatif olamaz');
    }
    if (end <= start) {
      throw ArgumentError.value(end, 'end', 'start değerinden büyük olmalı');
    }
  }

  final int chapterId;
  final int verseNumber;
  final Duration start;
  final Duration end;
}

/// Bir surenin kıraati: tek MP3 + ayet zaman aralıkları (TASK 041).
final class QuranChapterRecitation {
  QuranChapterRecitation({
    required this.chapterId,
    required this.audioUrl,
    required this.source,
    required this.verseTimings,
  }) {
    if (chapterId < 1 || chapterId > 114) {
      throw ArgumentError.value(chapterId, 'chapterId', '1–114 olmalı');
    }
    final expectedSuffix = '${chapterId.toString().padLeft(3, '0')}.mp3';
    if (!audioUrl.startsWith('https://') ||
        !audioUrl.endsWith(expectedSuffix)) {
      throw ArgumentError.value(
        audioUrl,
        'audioUrl',
        'HTTPS ve üç haneli sure numarasıyla bitmeli',
      );
    }
    final seen = <int>{};
    for (final timing in verseTimings) {
      if (timing.chapterId != chapterId) {
        throw ArgumentError.value(
          timing.verseNumber,
          'verseTimings',
          'farklı sureye ait timing',
        );
      }
      if (!seen.add(timing.verseNumber)) {
        throw ArgumentError.value(
          timing.verseNumber,
          'verseTimings',
          'duplicate verseNumber',
        );
      }
    }
  }

  final int chapterId;
  final String audioUrl;
  final QuranRecitationSource source;
  final List<QuranVerseTiming> verseTimings;

  /// Ayetin zaman aralığı; yoksa `null` (UI sakin hata gösterir).
  QuranVerseTiming? timingFor(int verseNumber) {
    for (final timing in verseTimings) {
      if (timing.verseNumber == verseNumber) {
        return timing;
      }
    }
    return null;
  }
}
