import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_chapter.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tek surenin katalog girdisi (TASK 035). `null` = tanınmayan id
/// (sakin hata durumu); hata = kontrollü katalog okuma sorunu.
final quranChapterProvider = FutureProvider.autoDispose
    .family<QuranChapter?, int>((ref, chapterId) async {
      final result = await ref
          .watch(quranContentRepositoryProvider)
          .getChapter(chapterId);
      return result.fold(
        onSuccess: (chapter) => chapter,
        onFailure: (failure) => throw failure,
      );
    });

/// Bir surenin doğrulanmış Uthmani ayetleri, numaraya sıralı (TASK 035).
/// Depo cache'i ilk başarılı okumadan sonra bellekte kalır.
final quranChapterVersesProvider = FutureProvider.autoDispose
    .family<List<QuranVerse>, int>((ref, chapterId) async {
      final result = await ref
          .watch(quranContentRepositoryProvider)
          .getVersesForChapter(chapterId);
      return result.fold(
        onSuccess: (verses) => verses,
        onFailure: (failure) => throw failure,
      );
    });
