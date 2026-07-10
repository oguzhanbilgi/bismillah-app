import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/today/domain/value_objects/plan_enums.dart';

/// Plan içi tek eylem — ayrı koleksiyon DEĞİL, plan belgesinde gömülü
/// (10_DATA_MODEL §4, §5).
final class PlanItem {
  const PlanItem({
    required this.itemId,
    required this.type,
    required this.status,
    this.targetRef,
    this.sizeParam,
    this.completedAt,
  });

  final EntityId itemId;
  final PlanItemType type;

  /// Hedef referansı (içerik ID'si / vakit adı kodu vb.).
  final String? targetRef;

  /// Boyut parametresi (ayet sayısı, dakika…).
  final int? sizeParam;

  final PlanItemStatus status;
  final UtcDateTime? completedAt;

  bool get isCompleted => status == PlanItemStatus.completed;

  /// Item bazlı completed-wins (10_DATA_MODEL §14): tamamlanma kaybolmaz;
  /// ikisi de tamamlanmışsa erken `completedAt` kazanır. Sıra-bağımsız.
  static PlanItem resolveCompletedWins(PlanItem a, PlanItem b) {
    assert(a.itemId == b.itemId, 'Aynı öğenin kopyaları çözülür');
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? a : b;
    }
    final at = a.completedAt;
    final bt = b.completedAt;
    if (at != null && bt != null && at != bt) {
      return at.isBefore(bt) ? a : b;
    }
    return at != null || bt == null ? a : b;
  }
}

/// Bir günün planı (10_DATA_MODEL §4). 30 günlük çatı = 30 DailyPlan
/// referans iskeleti.
final class DailyPlan implements Classified {
  DailyPlan({
    required this.dayKey,
    required List<PlanItem> items,
    required this.profileType,
    required this.sizeMinutes,
    required this.weekIndex,
    required this.generatedBy,
  }) : items = List.unmodifiable(items) {
    if (sizeMinutes < 0) {
      throw ArgumentError.value(sizeMinutes, 'sizeMinutes', 'Negatif olamaz');
    }
    if (weekIndex < 0) {
      throw ArgumentError.value(weekIndex, 'weekIndex', 'Negatif olamaz');
    }
    if (generatedBy.trim().isEmpty) {
      throw ArgumentError.value(
        generatedBy,
        'generatedBy',
        'Kural motoru sürümü zorunlu (üretim izlenebilirliği)',
      );
    }
  }

  final DayKey dayKey;
  final List<PlanItem> items;

  /// Üretim anındaki profil türü kovası.
  final String profileType;

  final int sizeMinutes;
  final int weekIndex;

  /// Üreten kural motoru sürümü (ör. `rule-engine-v1`).
  final String generatedBy;

  int get completedCount => items.where((i) => i.isCompleted).length;

  bool get isFullyCompleted =>
      items.isNotEmpty && completedCount == items.length;

  @override
  SensitivityClass get sensitivityClass => SensitivityClass.high;
}
