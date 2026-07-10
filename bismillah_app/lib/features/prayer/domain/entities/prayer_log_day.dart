import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';

/// Tek vakit kaydı — "completed wins" biriminin kendisi
/// (10_DATA_MODEL §4, §14-1).
final class PrayerEntry {
  const PrayerEntry({
    required this.prayerName,
    required this.status,
    this.loggedAt,
    this.undone = false,
  });

  final PrayerName prayerName;
  final PrayerCompletionStatus status;

  /// Yerel niyet zamanı; çakışma kararının kendisi sunucu zamanıyla
  /// verilir (§27-10) — burada deterministik tie-break ölçütüdür.
  final UtcDateTime? loggedAt;

  /// Açık geri alma tombstone'u — tamamlanmış kaydı geri alabilen TEK yol.
  final bool undone;

  bool get isCompleted => status.isCompleted && !undone;

  /// Entry bazlı completed-wins çözümü (10_DATA_MODEL §14-1).
  ///
  /// Sıra-bağımsızdır: `resolve(a, b) == resolve(b, a)`. Kurallar:
  /// 1. Tamamlanmış kayıt kaybolmaz — İSTİSNA: açık `undone` tombstone'u,
  ///    geri aldığı kayıttan KESİN olarak daha yeniyse geçerlidir.
  /// 2. İkisi de tamamlanmışsa erken `loggedAt` kazanır (ilk kayıt gerçeği).
  /// 3. İkisi de tamamlanmamışsa geç `loggedAt` kazanır (son niyet).
  /// 4. Kalan eşitlikler durum enum sırası, sonra `undone` bayrağıyla
  ///    deterministik kırılır — eşit zamanda tombstone kazanamaz
  ///    ("kayıt kutsaldır", §31).
  static PrayerEntry resolveCompletedWins(PrayerEntry a, PrayerEntry b) {
    assert(a.prayerName == b.prayerName, 'Aynı vakit kayıtları çözülür');

    if (a.isCompleted != b.isCompleted) {
      final completed = a.isCompleted ? a : b;
      final other = a.isCompleted ? b : a;
      // Açık geri alma yalnız KESİN daha yeniyse kazanır; eşitlikte
      // tamamlanmış kayıt korunur ("kayıt kutsaldır", §31).
      if (other.undone && _isStrictlyNewer(other, completed)) {
        return other;
      }
      return completed;
    }

    final aTime = a.loggedAt;
    final bTime = b.loggedAt;
    if (aTime != null && bTime != null && aTime != bTime) {
      if (a.isCompleted) {
        return aTime.isBefore(bTime) ? a : b; // erken kayıt kazanır
      }
      return aTime.isAfter(bTime) ? a : b; // son niyet kazanır
    }
    if ((aTime == null) != (bTime == null)) {
      return aTime != null ? a : b; // zaman damgalı olan deterministik önce
    }
    if (a.status != b.status) {
      return a.status.index < b.status.index ? a : b;
    }
    // Aynı durum + aynı zaman: açık geri alma işareti OLMAYAN kayıt korunur —
    // eşitlikte tombstone kazanamaz; sonraki merge'lerde tamamlanmış kaydı
    // düşürme riski taşıyan bayrak ancak KESİN daha yeni kanıtla yaşar.
    if (a.undone != b.undone) {
      return a.undone ? b : a;
    }
    return a; // tüm alanlar eşit — iki kopya aynı değerdir
  }

  static bool _isStrictlyNewer(PrayerEntry x, PrayerEntry y) {
    final xt = x.loggedAt;
    final yt = y.loggedAt;
    if (xt == null) {
      return false;
    }
    return yt == null || xt.isAfter(yt);
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerEntry &&
      other.prayerName == prayerName &&
      other.status == status &&
      other.loggedAt == loggedAt &&
      other.undone == undone;

  @override
  int get hashCode => Object.hash(prayerName, status, loggedAt, undone);
}

/// Bir günün namaz kaydı — gün-başına-tek-belge deseni
/// (10_DATA_MODEL §4; sync birimi bu belgedir).
final class PrayerLogDay implements Classified {
  PrayerLogDay({
    required this.dayKey,
    required List<PrayerEntry> entries,
    required this.updatedAt,
    required this.deviceId,
  }) : entries = List.unmodifiable(entries);

  final DayKey dayKey;
  final List<PrayerEntry> entries;
  final UtcDateTime updatedAt;
  final DeviceId deviceId;

  /// İbadet kaydı Yüksek hassasiyettir: ASLA loglanmaz, analytics'e
  /// ham gitmez (10_DATA_MODEL §19).
  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;

  PrayerEntry? entryFor(PrayerName name) {
    for (final entry in entries) {
      if (entry.prayerName == name) {
        return entry;
      }
    }
    return null;
  }

  int get completedCount => entries.where((e) => e.isCompleted).length;

  /// İki cihaz kopyasını entry bazlı completed-wins ile birleştirir
  /// (10_DATA_MODEL §14-1). Sıra-bağımsızdır — hangi cihaz önce
  /// senkronlarsa sonuç aynıdır (§2-6 test zorunluluğu).
  PrayerLogDay mergeCompletedWins(PrayerLogDay other) {
    assert(dayKey == other.dayKey, 'Aynı günün kopyaları birleştirilir');

    final merged = <PrayerName, PrayerEntry>{};
    for (final entry in [...entries, ...other.entries]) {
      final existing = merged[entry.prayerName];
      merged[entry.prayerName] = existing == null
          ? entry
          : PrayerEntry.resolveCompletedWins(existing, entry);
    }

    final newer = updatedAt.isAfter(other.updatedAt) ? this : other;
    final resolved = [
      for (final name in PrayerName.values)
        if (merged[name] != null) merged[name]!,
    ];
    return PrayerLogDay(
      dayKey: dayKey,
      entries: resolved,
      updatedAt: newer.updatedAt,
      deviceId: newer.deviceId,
    );
  }
}
