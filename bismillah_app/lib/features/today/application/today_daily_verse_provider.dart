import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/today/domain/daily_verse_reference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today "Bugünün Ayeti" görüntü modeli (TASK 052) — metinler bundled
/// Tanzil (Arapça) ve QuranEnc Rowad (meal) depolarından gelir; bu tip
/// hiçbir metni ÜRETMEZ veya değiştirmez.
final class TodayDailyVerse {
  const TodayDailyVerse({
    required this.chapterId,
    required this.verseNumber,
    required this.verseKey,
    required this.chapterName,
    required this.arabicText,
    required this.translationText,
  });

  final int chapterId;
  final int verseNumber;
  final String verseKey;
  final String chapterName;
  final String arabicText;

  /// Meal bulunamazsa boş kalabilir — ayet yine de kaynağıyla gösterilir.
  final String translationText;

  /// "Bakara 2:255" biçimli referans.
  String get reference => '$chapterName $verseKey';
}

/// Günün ayeti (TASK 052).
///
/// `null` = ayet güvenle çözülemedi → çağıran sakin bir fallback gösterir;
/// YANLIŞ veya boş ayet ASLA gösterilmez. Depo hataları burada yutulur
/// (teknik hata kullanıcıya sızmaz) ve provider FIRLATMAZ.
///
/// Ağ/Firebase/analytics YOKTUR; tamamen cihaz-lokal bundled asset okuması
/// yapılır ve depolar kendi içinde cache'lidir (tekrar tekrar parse YOK).
final todayDailyVerseProvider = FutureProvider.autoDispose<TodayDailyVerse?>((
  ref,
) async {
  final now = ref.watch(clockProvider).nowLocal();
  final verseKey = DailyVerseReference.forLocalDate(now);
  final parts = verseKey.split(':');
  final chapterId = int.tryParse(parts.first);
  final verseNumber = int.tryParse(parts.last);
  if (chapterId == null || verseNumber == null) {
    return null;
  }

  final content = ref.watch(quranContentRepositoryProvider);

  final verse = (await content.getVerse(
    verseKey,
  )).fold(onSuccess: (verse) => verse, onFailure: (_) => null);
  final chapter = (await content.getChapter(
    chapterId,
  )).fold(onSuccess: (chapter) => chapter, onFailure: (_) => null);
  // Ayet metni veya sure künyesi yoksa kart gösterilmez (sahte içerik yok).
  if (verse == null || chapter == null) {
    return null;
  }

  // Meal ayrı depodadır; yüklenemezse ayet Arapça + kaynağıyla gösterilir.
  final translation =
      (await ref
              .watch(quranTranslationRepositoryProvider)
              .getChapterTranslation(chapterId))
          .fold(
            onSuccess: (translation) => translation,
            onFailure: (_) => null,
          );
  final translationText =
      translation != null && verseNumber <= translation.verses.length
      ? translation.verses[verseNumber - 1].translationText
      : '';

  return TodayDailyVerse(
    chapterId: chapterId,
    verseNumber: verseNumber,
    verseKey: verseKey,
    chapterName: chapter.transliteratedName,
    arabicText: verse.textUthmani,
    translationText: translationText,
  );
});
