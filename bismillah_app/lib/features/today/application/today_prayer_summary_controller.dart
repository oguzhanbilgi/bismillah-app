import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today namaz özeti controller'ı — SALT-OKUNUR.
///
/// Prayer dilimiyle AYNI kaynaktan beslenir: `PrayerLogRepository.watchDay`
/// (lokal Drift, 06 §14). Yeni bir kayıt sistemi YOKTUR; bu controller
/// yazma metodu içermez. Prayer sekmesindeki her değişiklik akış
/// üzerinden buraya kendiliğinden yansır.
final todayPrayerSummaryControllerProvider =
    AsyncNotifierProvider<TodayPrayerSummaryController, TodayPrayerSummaryState>(
      TodayPrayerSummaryController.new,
    );

final class TodayPrayerSummaryController
    extends AsyncNotifier<TodayPrayerSummaryState> {
  @override
  Future<TodayPrayerSummaryState> build() async {
    // Prayer ekranıyla aynı saat kaynağı → aynı gün anahtarı (10 §27-11).
    final dayKey = DayKey.fromLocal(ref.watch(clockProvider).nowLocal());
    final repository = ref.watch(prayerLogRepositoryProvider);

    final subscription = repository.watchDay(dayKey).listen(
      (day) => state = AsyncData(_toState(dayKey, day)),
      // Akış sözleşmesi (core/contracts): watch hatası son bilinen durumu
      // DEVİRMEZ; hata ayrı okuma yolundan raporlanır. Sessizce korunur.
      onError: (Object _, StackTrace _) {},
    );
    ref.onDispose(subscription.cancel);

    final initial = await repository.getDay(dayKey);
    return initial.fold(
      onSuccess: (day) => _toState(dayKey, day),
      // Yükleme hatası sakin fallback'e düşer (UI: yumuşak metin, retry).
      onFailure: (failure) => throw failure,
    );
  }

  static TodayPrayerSummaryState _toState(DayKey dayKey, PrayerLogDay? day) {
    return TodayPrayerSummaryState(
      dayKey: dayKey,
      completedCount: day?.completedCount ?? 0,
    );
  }
}
