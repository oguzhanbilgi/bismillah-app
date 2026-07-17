import 'package:bismillah_app/features/quran/domain/entities/quran_daily_reading_progress.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';

/// 7 günlük görünümdeki tek günün noktası (TASK 047).
final class QuranDayProgressPoint {
  const QuranDayProgressPoint({
    required this.localDateKey,
    required this.goalProgressRatio,
    required this.isGoalCompleted,
    required this.isToday,
  });

  final String localDateKey;

  /// 0–1 aralığına clamp edilmiş görsel ilerleme.
  final double goalProgressRatio;
  final bool isGoalCompleted;
  final bool isToday;
}

/// Günlük hedef + bugünkü ilerleme + seri özeti (TASK 047) — paket
/// bağımsız; tüm alanlar İlerlemem/Oku ekranları için hazır hesaplanır.
final class QuranProgressSummary {
  const QuranProgressSummary({
    required this.goal,
    required this.today,
    required this.goalProgressRatio,
    required this.completedAmount,
    required this.remainingAmount,
    required this.isGoalCompleted,
    required this.currentStreakDays,
    required this.last7Days,
    required this.pageMappingUnavailable,
  });

  final QuranReadingGoal goal;
  final QuranDailyReadingProgress today;

  /// 0–1 clamp'li ilerleme (UI progress bar).
  final double goalProgressRatio;

  /// Tamamlanan miktar hedef biriminde (dakika hedefi: tam dakika,
  /// sayfa hedefi: benzersiz sayfa sayısı). Hedef üstü değer KESİLMEZ —
  /// sayısal olarak gösterilebilir.
  final int completedAmount;

  /// Kalan miktar (>= 0).
  final int remainingAmount;

  final bool isGoalCompleted;

  /// Hedefin tamamlandığı ardışık yerel gün sayısı. Bugün henüz
  /// tamamlanmadıysa dünle biten seri BOZULMUŞ SAYILMAZ.
  final int currentStreakDays;

  /// Bugün dahil son 7 gün, eskiden yeniye sıralı.
  final List<QuranDayProgressPoint> last7Days;

  /// Sayfa hedefi seçili ama doğrulanmış ayet→sayfa eşlemesi
  /// kullanılamıyor: ilerleme dakikaya SESSİZCE DÖNÜŞTÜRÜLMEZ, kontrollü
  /// unavailable durumu gösterilir.
  final bool pageMappingUnavailable;

  /// Bir günün hedefe göre ham ilerleme oranı (clamp'siz).
  static double rawRatioFor(
    QuranReadingGoal goal,
    QuranDailyReadingProgress day,
  ) => switch (goal.type) {
    QuranReadingGoalType.minutes =>
      day.activeReadingSeconds / (goal.amount * 60),
    QuranReadingGoalType.pages => day.viewedPageNumbers.length / goal.amount,
  };

  /// Bir günün hedefi gerçekten tamamlanmış mı.
  static bool isDayCompleted(
    QuranReadingGoal goal,
    QuranDailyReadingProgress day,
  ) => rawRatioFor(goal, day) >= 1;
}
