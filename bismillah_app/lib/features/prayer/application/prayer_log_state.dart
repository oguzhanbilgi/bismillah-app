import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';

/// Prayer ekranının görünüm durumu — saf domain nesnesi + sakin UI
/// bayrakları. Drift/persistence tipi İÇERMEZ.
final class PrayerLogState {
  const PrayerLogState({required this.day, this.saveIssue = false});

  /// Günün kaydı. Hiç kayıt yoksa boş entry listeli varsayılan gün —
  /// boşluk bir eksiklik DEĞİL, sakin başlangıç durumudur (CLAUDE.md ton
  /// kuralları: suçlayıcı dil/durum yok).
  final PrayerLogDay day;

  /// Son kaydetme denemesi başarısız oldu mu? Ekranı DEVİRMEZ — mevcut
  /// durum korunur, yalnız yumuşak bir bilgi notu gösterilir.
  final bool saveIssue;

  DayKey get dayKey => day.dayKey;

  bool isCompleted(PrayerName name) => day.entryFor(name)?.isCompleted ?? false;

  int get completedCount => day.completedCount;

  PrayerLogState copyWith({PrayerLogDay? day, bool? saveIssue}) {
    return PrayerLogState(
      day: day ?? this.day,
      saveIssue: saveIssue ?? this.saveIssue,
    );
  }
}
