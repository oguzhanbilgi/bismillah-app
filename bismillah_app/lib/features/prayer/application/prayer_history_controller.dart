import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/application/prayer_history_state.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Son 7 gün namaz geçmişi controller'ı — SALT-OKUNUR.
///
/// Mevcut `PrayerLogRepository.getRange` ile TEK aralık sorgusu yapar
/// (yedi bağımsız okuma değil). Yazma yolu YOKTUR; işaretleme/sync kuyruğu
/// bu koddan etkilenmez. `autoDispose`: ekran her açıldığında güncel güne
/// göre yeniden hesaplanır.
final prayerHistoryControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PrayerHistoryController,
      PrayerHistoryState
    >(PrayerHistoryController.new);

final class PrayerHistoryController
    extends AsyncNotifier<PrayerHistoryState> {
  /// Kaç gün gösterilir (bugün dahil).
  static const int windowDays = 7;

  @override
  Future<PrayerHistoryState> build() async {
    // Prayer/Today ile AYNI saat kaynağı → aynı gün anahtarı (10 §27-11).
    final now = ref.watch(clockProvider).nowLocal();

    // Yerel takvim günleri: bugün ve önceki 6 (yeni → eski). Gün-of-ay
    // eksiltmesi DateTime tarafından normalize edilir (ay/yıl sınırı DST-güvenli).
    final dates = [
      for (var i = 0; i < windowDays; i++)
        DateTime(now.year, now.month, now.day - i),
    ];
    final dayKeys = [for (final d in dates) DayKey.fromLocal(d)];

    final repository = ref.watch(prayerLogRepositoryProvider);

    // Bugün cihazda değişebilen TEK gündür (işaretleme yalnız bugüne yazar);
    // Today özetiyle aynı desenle bugünün watch akışı dinlenir ki kart,
    // ekran canlıyken de güncel kalsın. Geçmiş günler bu oturumda değişmez.
    final todayKey = dayKeys.first;
    final subscription = repository.watchDay(todayKey).listen((day) {
      final current = state.value;
      if (current == null) {
        return;
      }
      state = AsyncData(
        PrayerHistoryState(
          days: [
            for (final d in current.days)
              d.dayKey == todayKey
                  ? PrayerHistoryDay(
                      date: d.date,
                      dayKey: d.dayKey,
                      completedCount: day?.completedCount ?? 0,
                    )
                  : d,
          ],
        ),
      );
    },
    // Akış sözleşmesi: watch hatası son bilinen durumu DEVİRMEZ.
    onError: (Object _, StackTrace _) {});
    ref.onDispose(subscription.cancel);

    // Tek aralık sorgusu: en eski gün → bugün.
    final result = await repository.getRange(dayKeys.last, dayKeys.first);

    return result.fold(
      onSuccess: (loggedDays) {
        final countByKey = {
          for (final day in loggedDays) day.dayKey.value: day.completedCount,
        };
        return PrayerHistoryState(
          days: [
            for (var i = 0; i < windowDays; i++)
              PrayerHistoryDay(
                date: dates[i],
                dayKey: dayKeys[i],
                // Kayıt bulunmayan gün sakin 0/5'tir (hata değil).
                completedCount: countByKey[dayKeys[i].value] ?? 0,
              ),
          ],
        );
      },
      onFailure: (failure) => throw failure,
    );
  }
}
