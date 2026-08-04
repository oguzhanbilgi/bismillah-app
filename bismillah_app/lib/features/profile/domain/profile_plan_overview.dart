import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/today/domain/entities/daily_plan.dart';
import 'package:bismillah_app/features/today/domain/services/daily_plan_generator.dart';

/// Profil ekranındaki plan özeti — SAF hesaplama (TASK 095C).
///
/// ## Dürüstlük kuralı
///
/// Buradaki her sayı **kayıtlı gerçek plan kayıtlarından** türetilir.
/// Uygulamanın saklamadığı hiçbir metrik (seri/streak, puan, seviye,
/// rozet, ortalama, tahmin) ÜRETİLMEZ. Hesaplanamayan bir değer sıfır
/// olarak değil, **`null`** olarak döner ve arayüz o satırı hiç
/// göstermez — uydurma bir değer gösterilmez.
final class ProfilePlanProgress {
  const ProfilePlanProgress({
    required this.startDay,
    required this.dayCount,
    required this.currentDayNumber,
    required this.completedItems,
    required this.totalItems,
    required this.completedDays,
    required this.recentWindowDays,
    required this.recentCompletedItems,
    required this.recentTotalItems,
  });

  /// Bugünü içeren kesintisiz plan bloğunun ilk günü.
  final DayKey startDay;

  /// Blokta gerçekten kayıtlı gün sayısı (eksik kayıt varsa 30'dan azdır).
  final int dayCount;

  /// Bugünün blok içindeki sırası (1 tabanlı).
  final int currentDayNumber;

  final int completedItems;
  final int totalItems;

  /// Tüm öğeleri tamamlanmış gün sayısı. Öğesiz gün tamamlanmış SAYILMAZ.
  final int completedDays;

  /// Son ilerleme penceresinin uzunluğu (gün).
  final int recentWindowDays;

  final int recentCompletedItems;
  final int recentTotalItems;

  /// Plan öğesi olmayan bir blok için oran anlamsızdır.
  bool get hasItems => totalItems > 0;

  bool get hasRecentItems => recentTotalItems > 0;
}

/// Kayıtlı planlardan profil özetini üreten saf hesaplayıcı.
abstract final class ProfilePlanOverviewCalculator {
  /// "Son ilerleme" penceresi — bugün dahil geriye doğru gün sayısı.
  static const int recentWindowDays = 7;

  /// Bugünü içeren **kesintisiz** plan bloğunu bulur ve özetler.
  ///
  /// Bugün için kayıtlı plan yoksa `null` döner: bu bir hata değil,
  /// "aktif plan yok" verisidir. Blok kesintisiz aranır, çünkü araya
  /// giren boş bir gün farklı bir plan dönemine işaret eder ve iki dönem
  /// tek özet altında toplanamaz.
  static ProfilePlanProgress? summarize({
    required List<DailyPlan> plans,
    required DayKey today,
  }) {
    if (plans.isEmpty) {
      return null;
    }
    final byDay = <String, DailyPlan>{
      for (final plan in plans) plan.dayKey.value: plan,
    };
    if (!byDay.containsKey(today.value)) {
      return null;
    }

    // Bugünden geriye ve ileriye kesintisiz uzanan bloğu bul.
    var firstOffset = 0;
    while (byDay.containsKey(
      DailyPlanGenerator.dayAt(today, firstOffset - 1).value,
    )) {
      firstOffset--;
    }
    var lastOffset = 0;
    while (byDay.containsKey(
      DailyPlanGenerator.dayAt(today, lastOffset + 1).value,
    )) {
      lastOffset++;
    }

    final block = <DailyPlan>[
      for (var offset = firstOffset; offset <= lastOffset; offset++)
        byDay[DailyPlanGenerator.dayAt(today, offset).value]!,
    ];

    var completedItems = 0;
    var totalItems = 0;
    var completedDays = 0;
    for (final plan in block) {
      completedItems += plan.completedCount;
      totalItems += plan.items.length;
      if (plan.isFullyCompleted) {
        completedDays++;
      }
    }

    // Son pencere: bugün dahil, geriye doğru — gelecekteki günler
    // "ilerleme" sayılmaz, çünkü henüz yaşanmamıştır.
    var recentCompleted = 0;
    var recentTotal = 0;
    for (var back = 0; back < recentWindowDays; back++) {
      final plan = byDay[DailyPlanGenerator.dayAt(today, -back).value];
      if (plan == null) {
        break; // pencere kesintisizdir; boşluktan öncesi sayılmaz
      }
      recentCompleted += plan.completedCount;
      recentTotal += plan.items.length;
    }

    return ProfilePlanProgress(
      startDay: DailyPlanGenerator.dayAt(today, firstOffset),
      dayCount: block.length,
      currentDayNumber: -firstOffset + 1,
      completedItems: completedItems,
      totalItems: totalItems,
      completedDays: completedDays,
      recentWindowDays: recentWindowDays,
      recentCompletedItems: recentCompleted,
      recentTotalItems: recentTotal,
    );
  }
}
