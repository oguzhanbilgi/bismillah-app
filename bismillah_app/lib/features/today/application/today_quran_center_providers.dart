import 'package:bismillah_app/features/quran/application/quran_progress_summary_provider.dart';
import 'package:bismillah_app/features/quran/application/quran_reading_position_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today "Okumaya devam et" hedefi (TASK 050) — yalnız cihaz-lokal veriden
/// türetilir; içerik/meal taşınmaz.
final class TodayQuranResume {
  const TodayQuranResume({required this.chapter, this.verseNumber});

  final QuranChapter chapter;

  /// TASK 048 ayet-odaklı devam: yalnız bugünkü son okunan ayet AYNI
  /// surede ise doldurulur; aksi halde eski scroll-offset davranışı için
  /// `null` kalır (sahte ayet numarası ÜRETİLMEZ).
  final int? verseNumber;

  String? get verseKey =>
      verseNumber == null ? null : '${chapter.id}:$verseNumber';
}

/// Son okuma konumu + (varsa) bugünkü ayet-odağı (TASK 050).
///
/// `null` = gösterilecek gerçek konum yok — Today sahte sure/ayet ÜRETMEZ.
/// Konum okuma hatası AsyncError'a düşer; kart sessizce devam satırını
/// gizler, "Kur'an'ı aç" aksiyonu çalışmaya devam eder (TASK 050 §10).
final todayQuranResumeProvider = FutureProvider.autoDispose<TodayQuranResume?>((
  ref,
) async {
  final resume = await ref.watch(quranContinueReadingProvider.future);
  if (resume == null) {
    return null;
  }
  // Ayet hedefi yalnız bugünkü son okunan ayet aynı surede ise kullanılır;
  // farklı sure/gün ise chapter-only (scroll) davranışı korunur.
  final today = await ref.watch(quranTodayProgressProvider.future);
  int? verseNumber;
  final lastVerseKey = today.lastVerseKey;
  if (today.lastChapterId == resume.chapter.id && lastVerseKey != null) {
    verseNumber = int.tryParse(lastVerseKey.split(':').last);
  }
  return TodayQuranResume(chapter: resume.chapter, verseNumber: verseNumber);
});
