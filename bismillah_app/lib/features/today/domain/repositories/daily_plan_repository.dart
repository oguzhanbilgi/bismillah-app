import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';

/// Günlük plan lokal veri sözleşmesi (10_DATA_MODEL §7).
abstract interface class DailyPlanRepository {
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey);

  Stream<DailyPlan?> watchPlan(DayKey dayKey);

  ResultFuture<void> savePlan(DailyPlan plan);

  /// 30 günlük çatı iskeleti için aralık okuma.
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to);
}
