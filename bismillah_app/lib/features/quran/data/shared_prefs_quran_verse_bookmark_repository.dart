import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_verse_bookmark.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_verse_bookmark_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı ayet kaydı deposu (TASK 037).
///
/// Anahtarlar stabil verseKey listesi olarak saklanır; okurken bozuk/
/// geçersiz girdiler [QuranVerseBookmark.tryParse] ile GÖZ ARDI edilir
/// (crash yok). Set semantiği duplicate'i engeller; tek kaydın
/// kaldırılması diğerlerini etkilemez.
final class SharedPrefsQuranVerseBookmarkRepository
    implements QuranVerseBookmarkRepository {
  const SharedPrefsQuranVerseBookmarkRepository();

  static const String _bookmarksKey = 'bismillah.quran_bookmarked_verse_keys';

  @override
  ResultFuture<Set<String>> loadBookmarkedVerseKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Result.success(_readValidKeys(prefs));
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<bool> isBookmarked(String verseKey) async {
    final result = await loadBookmarkedVerseKeys();
    return result.fold(
      onSuccess: (keys) => Result.success(keys.contains(verseKey)),
      onFailure: Result.failure,
    );
  }

  @override
  ResultFuture<void> setBookmarked(
    String verseKey, {
    required bool bookmarked,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = _readValidKeys(prefs);
      final changed = bookmarked ? keys.add(verseKey) : keys.remove(verseKey);
      if (changed) {
        // Deterministik sıra: okunaklı ve tekrarlanabilir saklama.
        final sorted = keys.toList()..sort();
        await prefs.setStringList(_bookmarksKey, sorted);
      }
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  static Set<String> _readValidKeys(SharedPreferences prefs) {
    final raw = prefs.get(_bookmarksKey);
    if (raw is! List) {
      return <String>{};
    }
    return {
      for (final entry in raw)
        if (entry is String && QuranVerseBookmark.tryParse(entry) != null)
          entry,
    };
  }
}
