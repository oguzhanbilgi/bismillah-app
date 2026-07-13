import 'package:bismillah_app/features/quran/application/quran_verse_bookmarks_controller.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_bookmark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kaydedilmiş ayetin görüntü modeli (TASK 038) — paket bağımsız.
final class QuranSavedVerse {
  const QuranSavedVerse({required this.chapter, required this.verse});

  final QuranChapter chapter;
  final QuranVerse verse;
}

/// Kaydedilen ayetlerin SALT-OKUNUR listesi (TASK 038).
///
/// Bookmark controller state'ini İZLER — kayıt kaldırma iyimser
/// güncellemeyle anında yansır, reader'daki durumla tek kaynaktan
/// tutarlı kalır. İçerik mevcut cache'li depodan çözülür (ikinci sistem
/// YOK); bozuk/artık bulunamayan anahtarlar sessizce atlanır, aynı ayet
/// iki kez gösterilmez. Sıra: chapterId, sonra verseNumber.
final quranSavedVersesProvider =
    FutureProvider.autoDispose<List<QuranSavedVerse>>((ref) async {
      final bookmarksState = await ref.watch(
        quranVerseBookmarksControllerProvider.future,
      );
      final bookmarks = bookmarksState.bookmarkedKeys
          .map(QuranVerseBookmark.tryParse)
          .whereType<QuranVerseBookmark>()
          .toList()
        ..sort(
          (a, b) => a.chapterId != b.chapterId
              ? a.chapterId.compareTo(b.chapterId)
              : a.verseNumber.compareTo(b.verseNumber),
        );
      if (bookmarks.isEmpty) {
        return const [];
      }

      final content = ref.watch(quranContentRepositoryProvider);
      final saved = <QuranSavedVerse>[];
      final seenKeys = <String>{};
      for (final bookmark in bookmarks) {
        if (!seenKeys.add(bookmark.verseKey)) {
          continue;
        }
        final chapter = (await content.getChapter(bookmark.chapterId)).fold(
          onSuccess: (chapter) => chapter,
          onFailure: (failure) => throw failure,
        );
        final verse = (await content.getVerse(bookmark.verseKey)).fold(
          onSuccess: (verse) => verse,
          onFailure: (failure) => throw failure,
        );
        if (chapter == null || verse == null) {
          continue; // artık bulunamayan anahtar — crash yok
        }
        saved.add(QuranSavedVerse(chapter: chapter, verse: verse));
      }
      return saved;
    });
