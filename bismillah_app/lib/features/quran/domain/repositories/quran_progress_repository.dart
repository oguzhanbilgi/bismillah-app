import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_progress.dart';

/// Kur'an ilerleme lokal veri sözleşmesi (10_DATA_MODEL §7).
abstract interface class QuranProgressRepository {
  ResultFuture<QuranGoal?> getGoal();

  ResultFuture<void> saveGoal(QuranGoal goal);

  ResultFuture<QuranBookmark?> getBookmark();

  ResultFuture<void> saveBookmark(QuranBookmark bookmark);

  ResultFuture<List<QuranReadingSession>> getSessions(DayKey dayKey);

  /// Oturumlar UNION ile birleşir (§14) — ekleme idempotenttir
  /// (aynı sessionId ikinci kez eklenmez).
  ResultFuture<void> logSession(QuranReadingSession session);

  Stream<List<QuranReadingSession>> watchSessions(DayKey dayKey);
}
