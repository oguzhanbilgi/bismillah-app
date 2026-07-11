import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';

/// Today panosundaki namaz özeti — SALT-OKUNUR görünüm durumu.
///
/// Kayıt yokluğu bir eksiklik değildir: `completedCount == 0` sakin
/// başlangıçtır (CLAUDE.md ton kuralları). Yazma yolu YOKTUR — tek
/// doğruluk kaynağı Prayer dilimindeki `PrayerLogRepository`'dir.
final class TodayPrayerSummaryState {
  TodayPrayerSummaryState({
    required this.dayKey,
    required this.completedCount,
  }) : assert(
         completedCount >= 0 && completedCount <= totalCount,
         'completedCount 0–$totalCount aralığında olmalı',
       );

  /// Günde beş vakit (PrayerName enum'u sabittir).
  static final int totalCount = PrayerName.values.length;

  final DayKey dayKey;
  final int completedCount;

  /// AppProgressBar için 0.0–1.0 oranı.
  double get progress => completedCount / totalCount;
}
