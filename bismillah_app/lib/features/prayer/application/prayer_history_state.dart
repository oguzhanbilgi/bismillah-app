import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';

/// Son 7 gün namaz geçmişi — SALT-OKUNUR görünüm durumu.
///
/// Kayıt yokluğu eksiklik değildir: kayıt bulunmayan gün `completedCount == 0`
/// ile sakin gösterilir (CLAUDE.md ton kuralları). Yazma yolu YOKTUR.
final class PrayerHistoryState {
  const PrayerHistoryState({required this.days});

  /// Yeni → eski sırayla 7 gün (bugün en üstte).
  final List<PrayerHistoryDay> days;
}

/// Tek gün özeti — yerel takvim günü + o güne ait tamamlanan vakit sayısı.
final class PrayerHistoryDay {
  const PrayerHistoryDay({
    required this.date,
    required this.dayKey,
    required this.completedCount,
  });

  /// Yerel gün (gece yarısı) — yerelleştirilmiş kısa tarih sunumda üretilir.
  final DateTime date;
  final DayKey dayKey;
  final int completedCount;

  /// Günde beş vakit (PrayerName enum'u sabittir).
  static final int totalCount = PrayerName.values.length;

  /// AppProgressBar için 0.0–1.0 oranı.
  double get progress => completedCount / totalCount;
}
