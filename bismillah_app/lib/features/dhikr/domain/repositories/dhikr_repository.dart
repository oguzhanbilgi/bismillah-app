import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/dhikr/domain/entities/dhikr_session_day.dart';
import 'package:bismillah_app/features/dhikr/domain/entities/dhikr_set.dart';

/// Zikir lokal veri sözleşmesi (10_DATA_MODEL §7).
///
/// Sayaç ara durumu RAM'dedir; tamamlanınca debounce'lu TEK yazım
/// yapılır (§26) — bu sözleşme yalnız kalıcı durumu taşır.
abstract interface class DhikrRepository {
  ResultFuture<List<DhikrSet>> getSets();

  ResultFuture<void> saveCustomSet(DhikrSet set);

  /// Custom set silme tombstone'ludur (§15).
  ResultFuture<void> deleteCustomSet(EntityId setId);

  ResultFuture<DhikrSessionDay?> getSessionDay(DayKey dayKey);

  Stream<DhikrSessionDay?> watchSessionDay(DayKey dayKey);

  ResultFuture<void> saveSessionDay(DhikrSessionDay day);
}
