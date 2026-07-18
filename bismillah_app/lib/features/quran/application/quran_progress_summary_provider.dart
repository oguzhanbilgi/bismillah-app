import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/utils/date_key.dart';
import 'package:bismillah_app/features/quran/data/quran_data_providers.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_daily_reading_progress.dart';
import 'package:bismillah_app/features/quran/domain/entities/quran_progress_summary.dart';
import 'package:bismillah_app/features/quran/domain/value_objects/quran_reading_goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:bismillah_app/features/quran/domain/entities/quran_progress_summary.dart';

/// Bugünün gün kaydı (TASK 047): boşsa sıfır ilerlemeli kayıt döner.
/// Depodaki her bugünkü değişiklikte kendini tazeler.
final quranTodayProgressProvider =
    FutureProvider.autoDispose<QuranDailyReadingProgress>((ref) async {
      final repository = ref.watch(quranDailyProgressRepositoryProvider);
      final clock = ref.watch(clockProvider);
      final subscription = repository.watchToday().listen(
        (_) => ref.invalidateSelf(),
      );
      ref.onDispose(subscription.cancel);
      final todayKey = DateKey.fromLocal(clock.nowLocal());
      final result = await repository.loadDay(todayKey);
      return result.fold(
        onSuccess: (day) =>
            day ??
            QuranDailyReadingProgress.empty(
              localDateKey: todayKey,
              updatedAtUtc: clock.nowUtc(),
            ),
        onFailure: (failure) => throw failure,
      );
    });

/// Bugün dahil son 7 günün mevcut kayıtları (TASK 047).
final quranLast7DaysProgressProvider =
    FutureProvider.autoDispose<List<QuranDailyReadingProgress>>((ref) async {
      final repository = ref.watch(quranDailyProgressRepositoryProvider);
      final now = ref.watch(clockProvider).nowLocal();
      final result = await repository.loadRange(
        DateKey.fromLocal(DateTime(now.year, now.month, now.day - 6)),
        DateKey.fromLocal(now),
      );
      return result.fold(
        onSuccess: (days) => days,
        onFailure: (failure) => throw failure,
      );
    });

/// İlerlemem/Oku ekranlarının tek özet kaynağı (TASK 047): hedef +
/// bugün + son 7 gün + seri. `null` = hedef kurulmamış. Sağlayıcılar
/// birbirini döngüsel invalidate ETMEZ: yalnız bugünkü kayıt değişimi
/// bu özeti tazeler; heartbeat tick'i UI'ı yeniden kurmaz (tracker
/// state yayınlamaz, yalnız ~45 sn'lik persist'ler yansır).
final quranProgressSummaryProvider =
    FutureProvider.autoDispose<QuranProgressSummary?>((ref) async {
      final goalResult = await ref
          .watch(quranReadingPreferencesRepositoryProvider)
          .load();
      final goal = goalResult.fold(
        onSuccess: (preferences) => preferences?.goal,
        onFailure: (failure) => throw failure,
      );
      if (goal == null) {
        return null;
      }

      final today = await ref.watch(quranTodayProgressProvider.future);
      final last7 = await ref.watch(quranLast7DaysProgressProvider.future);
      final clock = ref.watch(clockProvider);
      final repository = ref.watch(quranDailyProgressRepositoryProvider);

      // Sayfa hedefi yalnız doğrulanmış eşleme varken hesaplanır; eşleme
      // yoksa dakikaya SESSİZCE DÖNÜŞTÜRÜLMEZ — kontrollü unavailable.
      var pageMappingUnavailable = false;
      if (goal.type == QuranReadingGoalType.pages) {
        final probe = await ref
            .watch(quranVersePageRepositoryProvider)
            .pagesForChapter(1);
        pageMappingUnavailable = probe.fold(
          onSuccess: (_) => false,
          onFailure: (_) => true,
        );
      }

      final byDateKey = {for (final day in last7) day.localDateKey: day};
      final now = clock.nowLocal();
      final last7Points = <QuranDayProgressPoint>[
        for (var i = 6; i >= 0; i--)
          _pointFor(
            goal,
            DateKey.fromLocal(DateTime(now.year, now.month, now.day - i)),
            byDateKey,
            isToday: i == 0,
            todayOverride: today,
          ),
      ];

      final ratio = QuranProgressSummary.rawRatioFor(goal, today);
      final completedAmount = switch (goal.type) {
        QuranReadingGoalType.minutes => today.activeReadingSeconds ~/ 60,
        QuranReadingGoalType.pages => today.viewedPageNumbers.length,
      };
      final remaining = goal.amount - completedAmount;

      // Seri: bugün tamamlandıysa bugünden, değilse dünden geriye doğru
      // ardışık tamamlanmış günler (dün de boşsa 0). Üst sınır 365 gün.
      final todayCompleted = QuranProgressSummary.isDayCompleted(goal, today);
      var streak = todayCompleted ? 1 : 0;
      for (var i = 1; i <= 365; i++) {
        final dayKey = DateKey.fromLocal(
          DateTime(now.year, now.month, now.day - i),
        );
        final cached = byDateKey[dayKey];
        final day = i <= 6
            ? cached
            : await repository
                  .loadDay(dayKey)
                  .then(
                    (result) => result.fold(
                      onSuccess: (d) => d,
                      onFailure: (_) => null,
                    ),
                  );
        if (day == null || !QuranProgressSummary.isDayCompleted(goal, day)) {
          break;
        }
        streak++;
      }

      return QuranProgressSummary(
        goal: goal,
        today: today,
        goalProgressRatio: ratio.clamp(0.0, 1.0),
        completedAmount: completedAmount,
        remainingAmount: remaining < 0 ? 0 : remaining,
        isGoalCompleted: ratio >= 1,
        currentStreakDays: streak,
        last7Days: last7Points,
        pageMappingUnavailable: pageMappingUnavailable,
      );
    });

QuranDayProgressPoint _pointFor(
  QuranReadingGoal goal,
  String dateKey,
  Map<String, QuranDailyReadingProgress> byDateKey, {
  required bool isToday,
  required QuranDailyReadingProgress todayOverride,
}) {
  final day = isToday ? todayOverride : byDateKey[dateKey];
  final ratio = day == null ? 0.0 : QuranProgressSummary.rawRatioFor(goal, day);
  return QuranDayProgressPoint(
    localDateKey: dateKey,
    goalProgressRatio: ratio.clamp(0.0, 1.0),
    isGoalCompleted: ratio >= 1,
    isToday: isToday,
  );
}
