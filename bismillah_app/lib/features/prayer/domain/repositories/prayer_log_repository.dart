import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';

/// Namaz kayıtları lokal veri sözleşmesi (Isar-first; 10_DATA_MODEL §7).
///
/// Yazma daima lokale gider ve aynı transaction'da sync kuyruğuna op
/// düşer (§12-1/2); bu interface'in implementasyonu TASK 013+.
abstract interface class PrayerLogRepository {
  ResultFuture<PrayerLogDay?> getDay(DayKey dayKey);

  /// UI'ın tek besleme kanalı — lokal watch akışı (06_FLUTTER_ARCH §14).
  Stream<PrayerLogDay?> watchDay(DayKey dayKey);

  ResultFuture<void> saveDay(PrayerLogDay day);

  /// Seri/istatistik yeniden hesabı için aralık okuma (10_DATA_MODEL §21).
  ResultFuture<List<PrayerLogDay>> getRange(DayKey from, DayKey to);
}
