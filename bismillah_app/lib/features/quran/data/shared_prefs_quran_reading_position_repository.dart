import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_reading_position.dart';
import 'package:bismillah_app/features/quran/domain/repositories/quran_reading_position_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı son okuma konumu deposu (TASK 036).
///
/// Bozuk/eksik/yanlış tipte değer konum YOK sayılır (crash yok). Enum
/// veya kullanıcıya gösterilen metin saklanmaz — yalnız sayılar + ISO
/// zaman damgası.
final class SharedPrefsQuranReadingPositionRepository
    implements QuranReadingPositionRepository {
  const SharedPrefsQuranReadingPositionRepository();

  static const String _chapterKey = 'bismillah.quran_last_chapter_id';
  static const String _offsetKey = 'bismillah.quran_last_scroll_offset';
  static const String _readAtKey = 'bismillah.quran_last_read_at_utc';

  @override
  ResultFuture<QuranReadingPosition?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chapterId = prefs.get(_chapterKey);
      final offset = prefs.get(_offsetKey);
      final readAtRaw = prefs.get(_readAtKey);
      final readAt = readAtRaw is String ? DateTime.tryParse(readAtRaw) : null;
      if (chapterId is! int ||
          chapterId < 1 ||
          chapterId > 114 ||
          offset is! double ||
          offset < 0 ||
          offset.isNaN ||
          !offset.isFinite ||
          readAt == null) {
        return const Result.success(null);
      }
      return Result.success(
        QuranReadingPosition(
          chapterId: chapterId,
          scrollOffset: offset,
          updatedAtUtc: readAt.toUtc(),
        ),
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> save(QuranReadingPosition position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_chapterKey, position.chapterId);
      await prefs.setDouble(_offsetKey, position.scrollOffset);
      await prefs.setString(
        _readAtKey,
        position.updatedAtUtc.toIso8601String(),
      );
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chapterKey);
      await prefs.remove(_offsetKey);
      await prefs.remove(_readAtKey);
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}
