import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';

/// Günlük plan lokal veri sözleşmesi (10_DATA_MODEL §7).
abstract interface class DailyPlanRepository {
  ResultFuture<DailyPlan?> getPlan(DayKey dayKey);

  Stream<DailyPlan?> watchPlan(DayKey dayKey);

  ResultFuture<void> savePlan(DailyPlan plan);

  /// Birden çok günü **tek mantıksal yazma** olarak kaydeder (TASK 083A).
  ///
  /// 30 günlük ilk plan 30 ayrı `savePlan` çağrısıyla yazılamaz: araya
  /// giren bir hata veya süreç sonlanması yarım bir plan bırakırdı. Bu
  /// yöntem ya **hepsini** yazar ya da **hiçbirini**; çağıran açısından
  /// kısmi sonuç YOKTUR.
  ///
  /// Kurallar:
  /// - boş liste ve **tekrar eden `DayKey`** tipli doğrulama hatasıdır
  /// - toplu yazmada olmayan mevcut günler KORUNUR
  /// - saklanan veri bozuksa üzerine YAZILMAZ, tipli hata döner
  /// - izleyicilere bildirim yalnız yazma başarılı olduktan SONRA gider
  ResultFuture<void> savePlans(List<DailyPlan> plans);

  /// 30 günlük çatı iskeleti için aralık okuma.
  ResultFuture<List<DailyPlan>> getRange(DayKey from, DayKey to);
}
