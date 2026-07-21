import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_progress.dart';
import 'package:bismillah_app/features/learn/domain/repositories/learning_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı öğrenme ilerlemesi (TASK 056 §11).
///
/// Cihaz-lokaldir; Firebase GEREKTİRMEZ. Kayıtlar locale'den BAĞIMSIZ
/// içerik id'leriyle tutulur — dil değiştirmek ilerlemeyi silmez.
/// Bozuk/eksik değer sakin biçimde boş duruma düşer (crash yok).
final class SharedPrefsLearningProgressRepository
    implements LearningProgressRepository {
  const SharedPrefsLearningProgressRepository();

  static const String _bookmarksKey = 'bismillah.learn_bookmarked_ids';
  static const String _completedKey = 'bismillah.learn_completed_ids';
  static const String _lastOpenedKey = 'bismillah.learn_last_opened_id';
  static const String _lastSectionKey = 'bismillah.learn_last_section_index';
  static const String _lastOpenedAtKey = 'bismillah.learn_last_opened_at';

  @override
  ResultFuture<LearningProgress> load() async {
    try {
      return Result.success(await _read());
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  Future<LearningProgress> _read() async {
    final prefs = await SharedPreferences.getInstance();
    return LearningProgress(
      bookmarkedArticleIds: _readIdSet(prefs, _bookmarksKey),
      completedArticleIds: _readIdSet(prefs, _completedKey),
      lastOpenedArticleId: prefs.get(_lastOpenedKey) is String
          ? prefs.getString(_lastOpenedKey)
          : null,
      lastReadSectionIndex: prefs.get(_lastSectionKey) is int
          ? prefs.getInt(_lastSectionKey)
          : null,
      lastOpenedAt: prefs.get(_lastOpenedAtKey) is String
          ? prefs.getString(_lastOpenedAtKey)
          : null,
    );
  }

  /// Bozuk/yanlış tipli değer BOŞ küme sayılır — okuma asla patlamaz.
  Set<String> _readIdSet(SharedPreferences prefs, String key) {
    final raw = prefs.get(key);
    if (raw is! List) {
      return <String>{};
    }
    return {
      for (final entry in raw)
        if (entry is String && entry.isNotEmpty) entry,
    };
  }

  @override
  ResultFuture<LearningProgress> toggleBookmark(String articleId) =>
      _mutate((current) {
        final next = {...current.bookmarkedArticleIds};
        next.contains(articleId) ? next.remove(articleId) : next.add(articleId);
        return current.copyWith(bookmarkedArticleIds: next);
      }, persistKey: _bookmarksKey);

  @override
  ResultFuture<LearningProgress> toggleCompleted(String articleId) =>
      _mutate((current) {
        final next = {...current.completedArticleIds};
        next.contains(articleId) ? next.remove(articleId) : next.add(articleId);
        return current.copyWith(completedArticleIds: next);
      }, persistKey: _completedKey);

  @override
  ResultFuture<LearningProgress> noteOpened(
    String articleId, {
    int? sectionIndex,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await _read();
      await prefs.setString(_lastOpenedKey, articleId);
      await prefs.setString(
        _lastOpenedAtKey,
        DateTime.now().toUtc().toIso8601String(),
      );
      if (sectionIndex != null) {
        await prefs.setInt(_lastSectionKey, sectionIndex);
      }
      return Result.success(
        current.copyWith(
          lastOpenedArticleId: articleId,
          lastReadSectionIndex: sectionIndex,
          lastOpenedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  Future<Result<LearningProgress>> _mutate(
    LearningProgress Function(LearningProgress current) change, {
    required String persistKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updated = change(await _read());
      final values = persistKey == _bookmarksKey
          ? updated.bookmarkedArticleIds
          : updated.completedArticleIds;
      await prefs.setStringList(persistKey, values.toList()..sort());
      return Result.success(updated);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}
