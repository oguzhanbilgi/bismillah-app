import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kayıtlı son okuma konumu (TASK 036). `null` = konum yok; okuma hatası
/// AsyncError (devam kartı sakin mesaj gösterir, reader baştan açılır).
final quranReadingPositionProvider =
    FutureProvider.autoDispose<QuranReadingPosition?>((ref) async {
      final result = await ref
          .watch(quranReadingPositionRepositoryProvider)
          .load();
      return result.fold(
        onSuccess: (position) => position,
        onFailure: (failure) => throw failure,
      );
    });

/// "Kaldığın yerden devam et" kartının verisi: kayıtlı konum + surenin
/// katalog girdisi (mevcut içerik deposu üzerinden çözülür — ikinci bir
/// sorgu sistemi YOK). `null` = gösterilecek kayıt yok.
final quranContinueReadingProvider = FutureProvider.autoDispose<
  ({QuranReadingPosition position, QuranChapter chapter})?
>((ref) async {
  final position = await ref.watch(quranReadingPositionProvider.future);
  if (position == null) {
    return null;
  }
  final chapterResult = await ref
      .watch(quranContentRepositoryProvider)
      .getChapter(position.chapterId);
  return chapterResult.fold(
    onSuccess: (chapter) =>
        chapter == null ? null : (position: position, chapter: chapter),
    onFailure: (failure) => throw failure,
  );
});
