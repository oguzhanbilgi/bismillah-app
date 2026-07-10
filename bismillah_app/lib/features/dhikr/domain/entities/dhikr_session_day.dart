import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';

/// Set başına sayım kaydı — keyfi map yerine tipli giriş
/// (10_DATA_MODEL §7 hardening: embedded `{setId, count}` listesi).
final class DhikrCountEntry {
  DhikrCountEntry({required this.setId, required this.count}) {
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'Negatif olamaz');
    }
  }

  final EntityId setId;
  final int count;
}

/// Günün zikir tamamlamaları — gün-belgesi deseni (10_DATA_MODEL §4).
final class DhikrSessionDay implements Classified {
  DhikrSessionDay({
    required this.dayKey,
    required List<EntityId> completedSetIds,
    required List<DhikrCountEntry> counts,
    required this.updatedAt,
  }) : completedSetIds = List.unmodifiable(completedSetIds),
       counts = List.unmodifiable(counts);

  final DayKey dayKey;
  final List<EntityId> completedSetIds;
  final List<DhikrCountEntry> counts;
  final UtcDateTime updatedAt;

  int countFor(EntityId setId) {
    for (final entry in counts) {
      if (entry.setId == setId) {
        return entry.count;
      }
    }
    return 0;
  }

  /// Çakışma çözümü (10_DATA_MODEL §14): set bazında max(count) +
  /// completedSets union — sayım kaybolmaz. Sıra-bağımsız.
  DhikrSessionDay mergeMaxUnion(DhikrSessionDay other) {
    assert(dayKey == other.dayKey, 'Aynı günün kopyaları birleştirilir');

    final mergedCounts = <EntityId, int>{};
    for (final entry in [...counts, ...other.counts]) {
      final existing = mergedCounts[entry.setId];
      mergedCounts[entry.setId] = existing == null
          ? entry.count
          : (entry.count > existing ? entry.count : existing);
    }
    final mergedCompleted = <EntityId>{
      ...completedSetIds,
      ...other.completedSetIds,
    };

    final sortedSetIds = mergedCounts.keys.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: mergedCompleted.toList()
        ..sort((a, b) => a.value.compareTo(b.value)),
      counts: [
        for (final setId in sortedSetIds)
          DhikrCountEntry(setId: setId, count: mergedCounts[setId]!),
      ],
      updatedAt: updatedAt.isAfter(other.updatedAt)
          ? updatedAt
          : other.updatedAt,
    );
  }

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}
