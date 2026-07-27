import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generation_request.dart';
// `dayAt` BİLİNÇLİ olarak yeniden yazılmaz: üretimle aynı yerel takvim
// aritmetiği kullanılır, böylece yaz saati geçişinde gün kaymaz.
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';

/// Bugüne kadar kesintisiz kaçırılmış plan günü sayısı (TASK 084).
///
/// **Bu bir seri (streak) modeli DEĞİLDİR:** kalıcı değildir, ödül/ceza
/// taşımaz, puan veya rütbe üretmez ve manevi bir değerlendirme yapmaz.
/// Yalnız Today'in sakin bir "yeniden başlama" mesajı gösterip
/// göstermeyeceğine karar vermek için hesaplanan geçici bir sunum
/// değeridir.
final class MissedDayRecovery {
  const MissedDayRecovery({required this.consecutiveMissedDays})
    : assert(consecutiveMissedDays >= 0, 'Negatif gün sayısı olamaz');

  /// Bugünden hemen önce, kesintisiz olarak kaçırılmış plan günü sayısı.
  ///
  /// Kullanıcıya **sayı olarak gösterilmez**; yalnız mesaj tonunu seçer.
  final int consecutiveMissedDays;

  /// Hiç kaçırılmış gün yok.
  static const MissedDayRecovery none = MissedDayRecovery(
    consecutiveMissedDays: 0,
  );

  /// Uzun aradan sonra daha sade bir dönüş metni kullanılacak eşik.
  static const int extendedAbsenceThreshold = 3;

  bool get hasMissedDays => consecutiveMissedDays > 0;

  /// Üç ve daha fazla kesintisiz kaçırılmış gün.
  bool get isExtendedAbsence =>
      consecutiveMissedDays >= extendedAbsenceThreshold;

  @override
  bool operator ==(Object other) =>
      other is MissedDayRecovery &&
      other.consecutiveMissedDays == consecutiveMissedDays;

  @override
  int get hashCode => consecutiveMissedDays.hashCode;

  @override
  String toString() =>
      'MissedDayRecovery(consecutiveMissedDays: $consecutiveMissedDays)';
}

/// Kaçırılmış gün hesabı — saf, senkron ve yan etkisiz (TASK 084).
///
/// ## Kaçırılmış gün tanımı
///
/// Bir geçmiş gün **yalnız** şu üç koşul birlikte sağlanırsa kaçırılmış
/// sayılır:
///
/// 1. o `DayKey` için geçerli bir `DailyPlan` kaydı **vardır**,
/// 2. planın **en az bir** öğesi vardır,
/// 3. öğelerin **hiçbiri** tamamlanmamıştır.
///
/// Aşağıdakiler kullanıcı davranışı DEĞİL, veri/ürün durumudur ve
/// kaçırılmış sayılmaz — ayrıca kesintisiz zinciri de **keser**:
///
/// - kaydı olmayan gün (plan hiç üretilmemiş veya aralık dışı)
/// - öğesiz (boş) plan
/// - bugünün kendisi
/// - bugünden sonraki günler
///
/// Bozuk kayıtlar zaten depo katmanında tipli hata olur ve buraya
/// ULAŞMAZ; çağıran okuma başarısız olduğunda [MissedDayRecovery.none]
/// kullanır — bozulma bir kullanıcı kusuru gibi sunulmaz.
///
/// ## Ne YAPMAZ
///
/// Hiçbir planı okumaz, yazmaz, tamamlamaz, silmez veya değiştirmez;
/// tarih üretmez (`DateTime.now()` yok) ve locale/timezone kullanmaz.
abstract final class MissedDayCalculator {
  /// Geriye doğru en fazla bakılacak gün sayısı — üretilen 30 günlük
  /// çatıdan daha geriye BAKILMAZ.
  static const int lookbackDays = DailyPlanGenerationRequest.planLengthDays;

  /// Bugünden hemen önceki kesintisiz kaçırılmış günleri sayar.
  ///
  /// [previousPlans] bugünden **önceki** günlere ait okunmuş planlardır;
  /// sıra önemsizdir (gün anahtarıyla eşlenir). Bugüne veya geleceğe ait
  /// kayıtlar sessizce yok sayılır — asla sayıma girmez.
  static MissedDayRecovery evaluate({
    required List<DailyPlan> previousPlans,
    required DayKey today,
  }) {
    final byDay = <String, DailyPlan>{
      for (final plan in previousPlans) plan.dayKey.value: plan,
    };

    var missed = 0;
    for (var back = 1; back <= lookbackDays; back++) {
      final day = DailyPlanGenerator.dayAt(today, -back);
      final plan = byDay[day.value];
      if (plan == null || plan.items.isEmpty || plan.completedCount > 0) {
        // Kayıt yok / boş plan / o gün bir şey yapılmış → zincir biter.
        break;
      }
      missed++;
    }
    return missed == 0
        ? MissedDayRecovery.none
        : MissedDayRecovery(consecutiveMissedDays: missed);
  }
}
